//
//  PoolableConnection.swift
//  neo4j-driver-swift
//
//  Created by Giacomo Leopizzi on 02/09/24.
//

import ServiceLifecycle

// Protocol representing a connection that can be pooled.
public protocol PoolableConnection: Actor, Service {
    
    // Asynchronous property to check if the connection is closed.
    var isClosed: Bool { get async }
}


extension PoolableConnection {
    
    /// A typealias for `ObjectIdentifier`, representing a unique identifier for the event loop.
    typealias ObjectID = ObjectIdentifier
    
    /// A computed property that returns a unique identifier for the current `EventLoop` instance.
    nonisolated var objectID: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}
