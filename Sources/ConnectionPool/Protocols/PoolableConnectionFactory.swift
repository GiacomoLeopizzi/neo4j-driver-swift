//
//  PoolableConnectionFactory.swift
//  neo4j-driver-swift
//
//  Created by Giacomo Leopizzi on 02/09/24.
//

import NIOCore

/// Protocol for creating connections that can be pooled.
public protocol PoolableConnectionFactory: AnyObject, Sendable {
    
    /// An associated type `Connection` conforming to `PoolableConnection`.
    associatedtype Connection: PoolableConnection
    
    /// Asynchronously creates and returns a new connection instance.
    func createConnection(on eventLoop: EventLoop) async -> Connection
}
