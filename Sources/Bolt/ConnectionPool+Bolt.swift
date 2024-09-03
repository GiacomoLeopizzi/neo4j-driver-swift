//
//  ConnectionPool+Bolt.swift
//  neo4j-driver-swift
//
//  Created by Giacomo Leopizzi on 02/09/24.
//

import NIOCore
import ConnectionPool

/// A typealias for an `EventLoopGroupConnectionPool` specifically configured to manage `BoltConnection` instances.
public typealias BoltConnectionPool = EventLoopGroupConnectionPool<BoltConnectionFactory>

/// Extension to make `BoltConnection` conform to the `PoolableConnection` protocol.
extension BoltConnection: PoolableConnection {
    
    /// A boolean indicating whether the connection is closed.
    ///
    /// This property checks the server state of the `BoltConnection`. If the state is `.defunct`,
    /// the connection is considered closed.
    public var isClosed: Bool {
        let state = self.serverState
        return state == .defunct
    }
}

/// A factory class responsible for creating `BoltConnection` instances.
///
/// The `BoltConnectionFactory` creates and configures new connections using the provided configuration.
/// It is used by the `BoltConnectionPool` to manage connections.
public final class BoltConnectionFactory: PoolableConnectionFactory {
    
    /// The type of connection this factory creates.
    public typealias Connection = BoltConnection
    
    /// The configuration used to create new `BoltConnection` instances.
    private let configuration: BoltConfiguration
    
    /// Initializes a new `BoltConnectionFactory` with the specified configuration.
    ///
    /// - Parameter configuration: The configuration to be used for creating `BoltConnection` instances.
    fileprivate init(configuration: BoltConfiguration) {
        self.configuration = configuration
    }
    
    /// Creates a new `BoltConnection` on the specified event loop.
    ///
    /// This method returns a new instance of `BoltConnection`, configured with the provided
    /// event loop and the factory's configuration.
    ///
    /// - Parameter eventLoop: The event loop that the connection will run on.
    /// - Returns: A new `BoltConnection` instance.
    public func createConnection(on eventLoop: EventLoop) async -> BoltConnection {
        return BoltConnection(configuration: configuration, eventLoop: eventLoop)
    }
}

/// Extension to `BoltConnectionPool` to add convenience initializers.
public extension BoltConnectionPool {
    
    /// A convenience initializer for creating a `BoltConnectionPool`.
    ///
    /// This initializer sets up a connection pool for Bolt connections using the provided event loop group,
    /// pool configuration, and Bolt configuration.
    ///
    /// - Parameters:
    ///   - eventLoopGroup: The event loop group that the connection pool will use.
    ///   - poolConfifuration: The configuration settings for the connection pool.
    ///   - boltConfiguration: The configuration settings for the Bolt connections.
    convenience init(eventLoopGroup: EventLoopGroup, poolConfifuration: PoolConfiguration, boltConfiguration: BoltConfiguration) {
        let factory = BoltConnectionFactory(configuration: boltConfiguration)
        self.init(eventLoopGroup: eventLoopGroup, factory: factory, confifuration: poolConfifuration)
    }
}
