//
//  EventLoopGroupConnectionPool.swift
//  neo4j-driver-swift
//
//  Created by Giacomo Leopizzi on 02/09/24.
//

import NIOCore
import ServiceLifecycle

/// A connection pool manager that handles multiple `EventLoopConnectionPool` instances,
/// each associated with a specific `EventLoop` within a provided `EventLoopGroup`.
///
/// The `EventLoopGroupConnectionPool` class is responsible for managing connections efficiently
/// across different event loops, ensuring that each event loop has access to a dedicated pool
/// of connections created by a specified `Factory`. 
public final class EventLoopGroupConnectionPool<Factory: PoolableConnectionFactory>: Service {
    
    // MARK: - Types
    
    /// Typealias for the connection type provided by the factory.
    public typealias Connection = Factory.Connection
    
    // MARK: - Properties
    
    /// The event loop group that manages the event loops.
    private let eventLoopGroup: EventLoopGroup
    
    /// The factory responsible for creating connections.
    private let factory: Factory
    
    /// The actual connection pool storage, keyed by the event loop's unique identifier.
    private let storage: [EventLoop.ObjectID: EventLoopConnectionPool<Factory>]
    
    // MARK: - Init
    
    /// Initializes the `EventLoopGroupConnectionPool` with the provided event loop group and connection factory.
    ///
    /// - Parameters:
    ///   - eventLoopGroup: The event loop group that the connection pools will be associated with.
    ///   - factory: The factory used to create connections for each event loop's pool.
    ///   - confifuration: The configuration of the pool.
    public init(eventLoopGroup: EventLoopGroup, factory: Factory, confifuration: PoolConfiguration) {
        self.eventLoopGroup = eventLoopGroup
        self.factory = factory
        self.storage = Dictionary(uniqueKeysWithValues: eventLoopGroup.makeIterator().map({
            return ($0.objectID, EventLoopConnectionPool<Factory>(eventLoop: $0,
                                                                  factory: factory,
                                                                  configuration: confifuration))
        }))
    }
    
    // MARK: - Methods
    
    /// Starts all the connection pools within the event loop group asynchronously.
    ///
    /// This method will run each `EventLoopConnectionPool` in a separate asynchronous task.
    public func run() async throws {
        try await withThrowingDiscardingTaskGroup(returning: Void.self, body: { group in
            for pool in self.storage.values {
                group.addTask(operation: pool.run)
            }
        })
    }
    
    /// Returns the `EventLoopConnectionPool` for a specific event loop.
    ///
    /// - Parameter eventLoop: The event loop for which the connection pool is required.
    /// - Returns: The connection pool associated with the specified event loop.
    /// - Note: This method will trigger a fatal error if the event loop is not part of the event loop group provided during initialization.
    public func pool(for eventLoop: EventLoop) -> EventLoopConnectionPool<Factory> {
        guard let pool = self.storage[eventLoop.objectID] else {
            fatalError("The EventLoop is not in the group provided with the init. Only EventLoops from the group can be used.")
        }
        return pool
    }
    
    /// Returns any `EventLoopConnectionPool` disregarding the specific event loop.
    ///
    /// - Returns: A connection pool running on an unspecified event loop.
    /// - Note: This is useful when the specific event loop is not crucial, and any available connection pool can be used.
    public func anyPool() -> EventLoopConnectionPool<Factory> {
        let eventLoop = eventLoopGroup.any()
        return pool(for: eventLoop)
    }
}

extension EventLoopGroupConnectionPool {
    
    public func requestConnection(on eventLoop: EventLoop) async throws -> Connection {
        return try await pool(for: eventLoop).requestConnection()
    }
    
    public func returnConnection(_ connection: Connection, on eventLoop: EventLoop) async {
        return await pool(for: eventLoop).returnConnection(connection)
    }
    
    public func withConnection<T: Sendable>(on eventLoop: EventLoop, _ body: @Sendable (Connection) async throws -> T) async throws -> T {
        return try await pool(for: eventLoop).withConnection(body)
    }
}
