//
//  EventLoopConnectionPool.swift
//  neo4j-driver-swift
//
//  Created by Giacomo Leopizzi on 02/09/24.
//

import NIOCore
import Collections
import ServiceLifecycle

public actor EventLoopConnectionPool<Factory: PoolableConnectionFactory>: Service {
    
    public typealias Connection = Factory.Connection
    
    private enum State {
        case idle(stream: AsyncStream<Service>, continuation: AsyncStream<Service>.Continuation)
        case running(continuation: AsyncStream<Service>.Continuation)
        case terminated
    }
    
    private var state: State
    
    private let factory: Factory
    private let configuration: PoolConfiguration
    
    private var connections: ConnectionList<Connection>
    private let waitingList: WaitingList<Connection>
    
    private nonisolated let eventLoop: EventLoop
    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        eventLoop.executor.asUnownedSerialExecutor()
    }
    
    init(eventLoop: EventLoop, factory: Factory, configuration: PoolConfiguration) {
        let (stream, continuation) = AsyncStream.makeStream(of: Service.self)
        self.state = .idle(stream: stream, continuation: continuation)
        self.eventLoop = eventLoop
        self.factory = factory
        self.configuration = configuration
        
        self.connections = ConnectionList(minimumCapacity: configuration.maxConnectionsPerEventLoop, eventLoop: eventLoop)
        self.waitingList = WaitingList(eventLoop: eventLoop, timeout: configuration.requestTimeout)
    }
    
    public func run() async throws {
        guard case .idle(stream: let stream, continuation: let continuation) = state else {
            throw ConnectionPoolError(.invalidState, detail: "The function run can only be called when the pool is idle.", location: .here())
        }
        try await withThrowingDiscardingTaskGroup(returning: Void.self, body: { group in
            state = .running(continuation: continuation)
            defer {
                state = .terminated
            }
            
            // 2. Start new services (connections) when available.
            for await service in stream {
                group.addTask(operation: service.run)
            }
        })
    }
    
    public func requestConnection() async throws -> Connection {
        eventLoop.assertInEventLoop()
        if let connection = await self.requestConnectionIfAvailable() {
            return connection
        }
        return try await waitingList.scheduleRequest()
    }
    
    
    private func requestConnectionIfAvailable() async -> Connection? {
        eventLoop.assertInEventLoop()
        switch state {
        case .idle(_, let continuation), .running(let continuation):
            // 1. Check all the connections in the available deque.
            if let connection = await self.connections.borrowConnection() {
                // A connection is available, use it.
                return connection
            }

            // 2. Check if a new connection can be created.
            if await connections.count < configuration.maxConnectionsPerEventLoop {
                // Connections are below the maximum, can create a new one.
                let newConnection = await self.newConnection(continuation: continuation)
                // make it run
                return newConnection
            }
            
            // All available connections are already used.
            return nil
        case .terminated:
            return nil
        }
    }
    
    public func returnConnection(_ connection: Connection) async {
        if case .terminated = state {
            await connections.returnConnection(connection, isReusable: false)
            return
        }

        // 1. Return the connection to the list.
        let isClosed = await connection.isClosed
        await connections.returnConnection(connection, isReusable: !isClosed)
        
        // 2. Fullfill all request that
        while await !waitingList.isEmpty, let connection = await requestConnectionIfAvailable() {
            await waitingList.fulfillRequest(connection)
        }
    }
}

extension EventLoopConnectionPool {
    
    private func newConnection(continuation: AsyncStream<Service>.Continuation) async -> Connection {
        let connection = await factory.createConnection(on: self.eventLoop)
        await self.connections.new(connection: connection)
        continuation.yield(connection)
        return connection
    }
    
    public func withConnection<T: Sendable>(_ body: @Sendable (Connection) async throws -> T) async throws -> T {
        let connection = try await requestConnection()
        do {
            let result = try await body(connection)
            await returnConnection(connection)
            return result
        } catch {
            await returnConnection(connection)
            throw error
        }
    }
}
