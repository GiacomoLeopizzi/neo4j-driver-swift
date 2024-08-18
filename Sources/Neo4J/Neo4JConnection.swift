//
//  Neo4JConnection.swift
//
//
//  Created by Giacomo Leopizzi on 09/07/24.
//

import NIO
import Bolt
import PackStream
import ServiceLifecycle

public actor Neo4JConnection: Service {
    
    // MARK: - Properties
    
    /// The configuration provided for the connection.
    private let configuration: Neo4JConfiguration
    /// The underlying Bolt connection used to perform requests.
    public let underlyingConnection: BoltConnection
    /// The server state, taken from the underlying connection.
    public var serverState: ServerState {
        get async {
            await underlyingConnection.serverState
        }
    }
    
    // MARK: - Initialization
    
    /// Creates a new Neo4J connection.
    /// - Parameters:
    ///   - configuration: The configuration used to create the connection.
    ///   - eventLoopGroup: The event loop group used to open the connection.
    public init(configuration: Neo4JConfiguration, eventLoopGroup: EventLoopGroup) {
        self.configuration = configuration
        self.underlyingConnection = BoltConnection(configuration: configuration.boltConfiguration, eventLoopGroup: eventLoopGroup)
    }
    
    // MARK: - Methods
    
    /// Called when the ``ServiceGroup`` is starting all the services.
    /// - Important: Unless strictly needed, do not call this method directly.
    public func run() async throws {
        configuration.logger?.info("Starting Neo4J connection to \(configuration.host):\(configuration.port)")
        try await underlyingConnection.run()
    }
    
    /// Prepares the underlying connection. This method automatically sends hello, logon, and reset requests based on the server state of the underlying connection.
    /// - Note: Do not call this method directly unless you plan to use the `underlyingConnection` directly. The methods provided in this actor automatically invoke this method.
    public func prepareIfNeeded(function: String = #function) async throws {
        configuration.logger?.trace("Begin preparing the underlying connection.", metadata: [
            "caller" : .string(function)
        ])
        if await serverState == .disconnected {
            configuration.logger?.trace("Dispatching the hello request.")
            // Send the hello request.
            try await underlyingConnection.hello(extra: configuration.hello)
        }
        if await serverState == .authentication {
            configuration.logger?.trace("Dispatching the authentication request.")
            // Authenticate.
            try await underlyingConnection.logon(auth: configuration.auth)
        }
        if await serverState == .failed {
            configuration.logger?.trace("Dispatching the reset request.")
            // Connection is in a failed state. Reset to ready.
            try await underlyingConnection.reset()
        }
    }
    
    /// Executes a transaction within the provided closure.
    /// - Parameters:
    ///   - extra: Additional parameters for beginning the transaction. Default is `.none`.
    ///   - closure: A closure that performs operations within the transaction.
    public func withinTransaction(extra: BeginExtra = .none, _ closure: (TransactionConnection) async throws -> Void) async throws {
        try await prepareIfNeeded()
        // 1. Start the transaction.
        try await underlyingConnection.begin(extra: extra)
        do {
            // 2. Execute the closure.
            try await closure(self)
        } catch {
            // An error occurred while executing the closure. If state is not failed, roll back.
            if await serverState != .failed {
                try await underlyingConnection.rollback()
            }
            throw error
        }
        // 3. Commit the transaction.
        try await underlyingConnection.commit()
    }
    
    /// Executes a Cypher query and automatically retrieves all the results.
    /// - Parameters:
    ///   - query: The query to execute.
    ///   - parameters: The parameters for the query. Default is empty.
    ///   - extra: Additional parameters for the run request. Default is `.none`.
    ///   - types: A tuple of types to decode from the result.
    /// - Returns: An array containing a tuple of types. Each element represents a row of results.
    /// - Note: The tuple of types must represent a whole row, with one type for each parameter returned in the "RETURN" clause of the query.
    public func run<each T: Decodable & Sendable>(query: String, parameters: [String : any Encodable & Sendable] = [:], extra: RunExtra = .none, decodingResultsAs types: (repeat each T).Type) async throws -> [(repeat each T)] {
        let convertedParameters = try parameters.mapValues { try PackStreamEncoder.shared.encode($0) }
        try await prepareIfNeeded()
        try await underlyingConnection.run(query: query, parameters: convertedParameters, extra: extra)
        let (results, _) = try await underlyingConnection.pull(n: .all)
        
        var converted: [(repeat each T)] = []
        converted.reserveCapacity(results.count)
        
        for row in results {
            let decoded = try Helper.decode(row, as: repeat (each T).self, using: .shared)
            converted.append(decoded)
        }
        
        return converted
    }
    
    /// Executes a Cypher query and returns the generated metadata. This method is meant for executions that do not have a return statement, as it discards all the records automatically.
    /// - Parameters:
    ///   - query: The query to execute.
    ///   - parameters: The parameters for the query. Default is empty.
    ///   - extra: Additional parameters for the run request. Default is `.none`.
    /// - Returns: The metadata of the query.
    @discardableResult
    public func run(query: String, parameters: [String : any Encodable & Sendable] = [:], extra: RunExtra = .none) async throws -> SuccessMetadata {
        let convertedParameters = try parameters.mapValues { try PackStreamEncoder.shared.encode($0) }
        try await prepareIfNeeded()
        try await underlyingConnection.run(query: query, parameters: convertedParameters, extra: extra)
        return try await underlyingConnection.discard(n: .all)
    }
}
