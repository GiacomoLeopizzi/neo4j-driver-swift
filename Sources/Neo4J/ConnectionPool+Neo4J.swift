//
//  ConnectionPool+Neo4J.swift
//  neo4j-driver-swift
//
//  Created by Giacomo Leopizzi on 02/09/24.
//

import NIOCore
import ConnectionPool

/// A typealias for an `EventLoopGroupConnectionPool` specifically configured to manage `Neo4JConnection` instances.
public typealias Neo4JConnectionPool = EventLoopGroupConnectionPool<Neo4JConnectionFactory>

/// Extension to make `Neo4JConnection` conform to the `PoolableConnection` protocol.
extension Neo4JConnection: PoolableConnection {
    
    /// A boolean indicating whether the connection is closed.
    ///
    /// This property checks the server state of the `Neo4JConnection`. If the state is `.defunct`,
    /// the connection is considered closed.
    public var isClosed: Bool {
        get async {
            let state = await self.serverState
            return state == .defunct
        }
    }
}

/// A factory class responsible for creating `Neo4JConnection` instances.
///
/// The `Neo4JConnectionFactory` creates and configures new connections to a Neo4J database
/// using the provided configuration. It is used by the `Neo4JConnectionPool` to manage connections.
public final class Neo4JConnectionFactory: PoolableConnectionFactory {
    
    /// The type of connection this factory creates.
    public typealias Connection = Neo4JConnection
    
    /// The configuration used to create new `Neo4JConnection` instances.
    private let configuration: Neo4JConfiguration
    
    /// Initializes a new `Neo4JConnectionFactory` with the specified configuration.
    ///
    /// - Parameter configuration: The configuration to be used for creating `Neo4JConnection` instances.
    fileprivate init(configuration: Neo4JConfiguration) {
        self.configuration = configuration
    }
    
    /// Creates a new `Neo4JConnection` on the specified event loop.
    ///
    /// This method returns a new instance of `Neo4JConnection`, configured with the provided
    /// event loop and the factory's configuration.
    ///
    /// - Parameter eventLoop: The event loop that the connection will run on.
    /// - Returns: A new `Neo4JConnection` instance.
    public func createConnection(on eventLoop: EventLoop) async -> Neo4JConnection {
        return Neo4JConnection(configuration: configuration, eventLoop: eventLoop)
    }
}

/// Extension to `Neo4JConnectionPool` to add convenience initializers.
public extension Neo4JConnectionPool {
    
    /// A convenience initializer for creating a `Neo4JConnectionPool`.
    ///
    /// This initializer sets up a connection pool for Neo4J connections using the provided event loop group,
    /// pool configuration, and Neo4J configuration.
    ///
    /// - Parameters:
    ///   - eventLoopGroup: The event loop group that the connection pool will use.
    ///   - poolConfiguration: The configuration settings for the connection pool.
    ///   - neo4JConfiguration: The configuration settings for the Neo4J connections.
    convenience init(eventLoopGroup: EventLoopGroup, poolConfiguration: PoolConfiguration, neo4JConfiguration: Neo4JConfiguration) {
        let factory = Neo4JConnectionFactory(configuration: neo4JConfiguration)
        self.init(eventLoopGroup: eventLoopGroup, factory: factory, configuration: poolConfiguration)
    }
}
