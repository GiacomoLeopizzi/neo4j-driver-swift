//
//  ConnectionList.swift
//  neo4j-driver-swift
//
//  Created by Giacomo Leopizzi on 02/09/24.
//

import Collections
import NIOCore

extension EventLoopConnectionPool {
    
    actor ConnectionList<Connection: PoolableConnection> {
        
        private nonisolated let eventLoop: EventLoop
        private var available: Deque<Connection>
        private var connections: Set<Connection.ObjectID>
        
        nonisolated var unownedExecutor: UnownedSerialExecutor {
            eventLoop.executor.asUnownedSerialExecutor()
        }
        
        var count: Int {
            eventLoop.assertInEventLoop()
            return connections.count
        }
        
        init(minimumCapacity: Int, eventLoop: EventLoop) {
            self.eventLoop = eventLoop
            self.available = Deque(minimumCapacity: minimumCapacity)
            self.connections = Set(minimumCapacity: minimumCapacity)
        }
        
        func new(connection: Connection) {
            eventLoop.assertInEventLoop()
            precondition(!connections.contains(connection.objectID), "You can add only once a new connection.")
            
            available.append(connection)
            connections.insert(connection.objectID)
        }
        
        func borrowConnection() async -> Connection? {
            eventLoop.assertInEventLoop()
            while let connection = self.available.popFirst() {
                guard await !connection.isClosed else {
                    connections.remove(connection.objectID)
                    continue
                }
                // A connection is available, use it.
                return connection
            }
            return nil
        }
        
        func returnConnection(_ connection: Connection, isReusable: Bool) {
            eventLoop.assertInEventLoop()
            precondition(connections.contains(connection.objectID), "You can return only a connection that is in the pool.")
            if isReusable {
                // Add to the deque of available.
                available.append(connection)
            } else {
                // Connection is closed, remove it.
                connections.remove(connection.objectID)
            }
        }
    }
    
}
