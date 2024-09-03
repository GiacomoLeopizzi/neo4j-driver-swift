//
//  AnyObject-Extension.swift
//  neo4j-driver-swift
//
//  Created by Giacomo Leopizzi on 02/09/24.
//

import NIOCore

/// Extension for `EventLoop` that adds an `ObjectID` typealias and a computed property to retrieve a unique identifier for the event loop instance.
extension EventLoop {
    
    /// A typealias for `ObjectIdentifier`, representing a unique identifier for the event loop.
    typealias ObjectID = ObjectIdentifier
    
    /// A computed property that returns a unique identifier for the current `EventLoop` instance.
    var objectID: ObjectID {
        ObjectIdentifier(self)
    }
}
