//
//  WaitingList.swift
//  neo4j-driver-swift
//
//  Created by Giacomo Leopizzi on 02/09/24.
//

import NIOCore
import Collections

extension EventLoopConnectionPool {
    
    /// A waiting list for connection requests, supporting timeout functionality.
    ///
    /// The `WaitingList` class manages connection requests in an ordered list, where each request is tied to an `EventLoopPromise`.
    /// The waiting list supports timeouts, meaning if a connection is not fulfilled within the specified timeout period,
    /// the request is automatically removed from the list.
    ///
    /// - Note: This class is marked as `@unchecked Sendable` because each method must be executed on the `EventLoop`
    /// provided at initialization. Failure to do so will result in a crash due to assertion failure.
    actor WaitingList<Connection: PoolableConnection> {
        
        // MARK: - Types
        
        /// A unique identifier for each request in the waiting list.
        private typealias RequestID = UInt64
        
        // MARK: - Properties
        
        /// The current identifier for the next request in the waiting list.
        private var waitingListID: RequestID
        
        /// An ordered dictionary that stores the requests, keyed by their unique `RequestID`.
        private var waitingList: OrderedDictionary<RequestID, EventLoopPromise<Connection>>
        
        /// The timeout duration for each request in the waiting list.
        private let timeout: TimeAmount
        
        /// The event loop that this waiting list operates on.
        private nonisolated let eventLoop: EventLoop
        
        nonisolated var unownedExecutor: UnownedSerialExecutor {
            eventLoop.executor.asUnownedSerialExecutor()
        }
        
        var isEmpty: Bool {
            eventLoop.assertInEventLoop()
            return waitingList.isEmpty
        }
        
        // MARK: - Init
        
        /// Initializes a new `WaitingList` with the specified event loop and timeout.
        ///
        /// - Parameters:
        ///   - eventLoop: The `EventLoop` on which all operations must be performed.
        ///   - timeout: The timeout duration for connection requests in the waiting list.
        init(eventLoop: EventLoop, timeout: TimeAmount) {
            self.eventLoop = eventLoop
            self.timeout = timeout
            
            self.waitingListID = 0
            self.waitingList = OrderedDictionary()
        }
        
        // MARK: - Methods
        
        /// Generates the next unique request ID for the waiting list.
        ///
        /// This method asserts that it is being called on the correct event loop.
        /// - Returns: The next unique `RequestID`.
        private func nextID() -> RequestID {
            eventLoop.assertInEventLoop()
            
            let next = waitingListID.addingReportingOverflow(1).partialValue
            self.waitingListID = next
            return next
        }
        
        private func remove(_ requestID: RequestID) {
            eventLoop.assertInEventLoop()
        
            waitingList.removeValue(forKey: requestID)
        }
        
        /// Schedules a connection request and returns the connection when available.
        ///
        /// This method creates a promise for a connection and adds it to the waiting list.
        /// If the request is not fulfilled within the timeout period, it is removed from the list.
        /// - Returns: The connection when it becomes available.
        /// - Throws: An error if the promise fails to fulfill within the timeout period.
        func scheduleRequest() async throws -> Connection {
            eventLoop.assertInEventLoop()
            
            let promise = eventLoop.makePromise(of: Connection.self)
            let requestID = self.nextID()
            
            self.waitingList[requestID] = promise
            
            let task: Scheduled<Void> = eventLoop.scheduleTask(in: timeout, { [unowned self] in
                Task {
                    await self.remove(requestID)
                    promise.fail(ConnectionPoolError(.timeout, detail: "Connection request timed out", location: .here()))
                }
            })
                                    
            promise.futureResult.whenComplete({ _ in
                // Cancel task in case the timeout is still running.
                task.cancel()
            })
            
            return try await promise.futureResult.get()
        }
        
        /// Fulfills a connection request from the waiting list.
        ///
        /// This method removes the first request from the waiting list and fulfills it with the provided connection.
        /// - Parameter connection: The connection to fulfill the request with.
        func fulfillRequest(_ connection: Connection) {
            eventLoop.assertInEventLoop()
            let (_, promise) = waitingList.removeFirst()
            promise.succeed(connection)
        }
    }
    
}
