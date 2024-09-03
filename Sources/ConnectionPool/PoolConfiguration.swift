//
//  PoolConfiguration.swift
//  neo4j-driver-swift
//
//  Created by Giacomo Leopizzi on 02/09/24.
//

import NIOCore

/// A configuration structure for managing the connection pool settings.
///
/// `PoolConfiguration` defines the limits and behaviors of the connection pool, including the maximum number of connections allowed per event loop and the timeout duration when requesting a new connection. This structure is marked as `Sendable`, meaning it is safe to be used across concurrent contexts.
public struct PoolConfiguration: Sendable {
    
    // MARK: - Properties
    
    /// The maximum number of connections that the pool can generate per event loop.
    /// This property limits the total number of connections that can be open simultaneously for each event loop within the connection pool.
    public let maxConnectionsPerEventLoop: Int
    
    /// The timeout duration for requesting a new connection.
    /// This property specifies the maximum amount of time to wait for a connection to become available before the request fails or times out.
    public let requestTimeout: TimeAmount
    
    // MARK: - Init
    
    /// Initializes a new `PoolConfiguration` instance with specified settings.
    ///
    /// - Parameters:
    ///   - maxConnectionsPerEventLoop: The maximum number of connections that can be open per event loop.
    ///   - requestTimeout: The duration to wait for a connection to become available before timing out.
    public init(maxConnectionsPerEventLoop: Int, requestTimeout: TimeAmount) {
        self.maxConnectionsPerEventLoop = maxConnectionsPerEventLoop
        self.requestTimeout = requestTimeout
    }
}
