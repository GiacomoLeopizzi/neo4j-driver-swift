//
//  BoltConnection.swift
//
//
//  Created by Giacomo Leopizzi on 08/07/24.
//

import NIOSSL
import NIOCore
import Logging
import NIOPosix
import PackStream
import ServiceLifecycle

public final actor BoltConnection: Service {
    
    fileprivate struct StreamElement: Sendable {
        var payload: any Request
        var isStateValid: @Sendable (ServerState) -> Bool
        var continuation: CheckedContinuation<Response, Error>
    }
    
    fileprivate enum State {
        case initial(eventLoopGroup: EventLoopGroup, configuration: BoltConfiguration, stream: AsyncStream<StreamElement>, continuation: AsyncStream<StreamElement>.Continuation)
        case running(channel: NIOAsyncChannel<Response, any Request>, stream: AsyncStream<StreamElement>, continuation: AsyncStream<StreamElement>.Continuation, serverState: ServerState)
        case finished
    }
    
    public var serverState: ServerState {
        state.serverState
    }
    
    private var state: State 
    private var logger: Logger?
    
    public init(configuration: BoltConfiguration, eventLoopGroup: EventLoopGroup) {
        let (stream, continuation) = AsyncStream<StreamElement>.makeStream()
        self.state = .initial(eventLoopGroup: eventLoopGroup, configuration: configuration, stream: stream, continuation: continuation)
        self.logger = configuration.logger
    }
    
    public func run() async throws {
        do {
            logger?.info("Starting BoltConnection")
            guard case .initial(let eventLoopGroup, let configuration, let stream, let continuation) = state else {
                logger?.error("Attempting to run a BoltConnection that was previously started.")
                throw BoltError(.connectionClosed, detail: "The connection to the server has been shut down.", location: .here())
            }
            let loggerCopy = self.logger
            let channel = try await ClientBootstrap(group: eventLoopGroup)
                .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
                .channelInitializer({ $0.pipeline.addInitialHandlers(ssl: configuration.ssl, on: $0.eventLoop) })
                .connect(host: configuration.host, port: configuration.port)
                .flatMap({ channel in
                    return Self.negotiate(channel: channel, logger: loggerCopy)
                }).flatMapThrowing({ channel in
                    return try NIOAsyncChannel<Response, any Request>(wrappingChannelSynchronously: channel)
                })
                .get()
            
            self.state = .running(channel: channel, stream: stream, continuation: continuation, serverState: .negotiation)
            
            // Start evaluating the stream
            
            try await channel.executeThenClose({ [weak self] inbound, outbound in
                await self?.handleChannel(inbound: inbound, outbound: outbound)
            })
            self.state = .finished
            
        } catch {
            // Channel creation failed. Fail request stream and terminate.
            if let stream = state.stream {
                for try await request in stream {
                    request.continuation.resume(throwing: BoltError(.connectionClosed, location: .here()))
                }
            }
            self.state = .finished
        }
    }
    
    private func handleChannel(inbound: NIOAsyncChannelInboundStream<Response>, outbound:  NIOAsyncChannelOutboundWriter<any Request>) async {
        guard case .running(_, let stream, let continuation, _) = state else {
            return
        }
        var inboundIterator = inbound.makeAsyncIterator()
        
        for await element in stream {
            // A new request. Write it.
            do {
                guard element.isStateValid(self.serverState) else {
                    let error = BoltError(.forbidden, detail: "Request is not allowed in current state: \(state.serverState)", location: .here())
                    element.continuation.resume(throwing: error)
                    continue
                }
                try await outbound.write(element.payload)
                if let response = try await inboundIterator.next() {
                    element.continuation.resume(returning: response)
                } else {
                    self.state = .finished
                    continuation.finish()
                    element.continuation.resume(throwing: BoltError(.connectionClosed, detail: "The connection to the server was unexpectedly closed.", location: .here()))
                }
            } catch {
                // Fail
                element.continuation.resume(throwing: BoltError(.connectionClosed, detail: "The connection to the server was unexpectedly closed.", location: .here()))
            }
        }
    }
    
    func execute<R: Request>(request: R) async throws -> R.SuccessResponse {
        guard let requestContinuation = state.requestContinuation else {
            throw BoltError(.connectionClosed, detail: "Cannot send a new request, the connection is terminated.", location: .here())
        }
        let response: Response = try await withCheckedThrowingContinuation { continuation in
            let yieldResult = requestContinuation.yield(StreamElement(payload: request, isStateValid: R.isAllowed, continuation: continuation))
            
            switch yieldResult {
            case .enqueued:
                break
            case .terminated, .dropped:
                let error = BoltError(.connectionClosed, detail: "Unable to enqueue request due to the connection being shutdown.", location: .here())
                continuation.resume(throwing: error)
            @unknown default:
                break
            }
        }
        let newState = R.nextState(from: state.serverState, afterReceiving: response)
        state.set(serverState: newState)
        return try R.convert(response: response)
    }
    
}

extension BoltConnection {
    
    static func negotiate(channel: Channel, logger: Logger?) -> EventLoopFuture<Channel> {
        let promise = channel.eventLoop.makePromise(of: Version.self)
        let supportedVersions: [Version] = [.v5_4, .zero, .zero, .zero]
        let initRequest = InitializationRequest(supportedVersions: supportedVersions, result: promise)
        logger?.trace("Starting handshake", metadata: [
            "supported_bolt_versions" : .stringConvertible(supportedVersions)
        ])
        let initSent = channel.eventLoop.makePromise(of: Void.self)
        channel.writeAndFlush(initRequest, promise: initSent)
        
        promise.futureResult.whenFailure({ error in
            if error is NIOSSLError {
                logger?.error("SSL error", metadata: [
                    "error" : .string(String(describing: error))
                ])
            }
        })
        
        return initSent.futureResult
            .flatMap({ _ in promise.futureResult })
            .always({ result in
                if case .failure = result {
                    logger?.error("Unable to negotiate a compatible Bolt version.")
                }
            })
            .flatMap({ negotiatedVersion in
                logger?.trace("Bolt handshake completed", metadata: [
                    "bolt_version" : .stringConvertible(negotiatedVersion)
                ])
                return channel.pipeline
                    .configAfterInitialization()
                    .map({ _ in channel })
            })
    }
}

fileprivate extension BoltConnection.State {
    
    var requestContinuation: AsyncStream<BoltConnection.StreamElement>.Continuation? {
        switch self {
        case .initial(_, _, _, let continuation): return continuation
        case .running(_, _, let continuation, _): return continuation
        case .finished: return nil
        }
    }
    
    var stream: AsyncStream<BoltConnection.StreamElement>? {
        switch self {
        case .initial(_, _, let stream, _): return stream
        case .running(_, let stream, _, _): return stream
        case .finished: return nil
        }
    }
    
    var serverState: ServerState {
        switch self {
        case .initial: return .disconnected
        case .running(_, _, _, let serverState): return serverState
        case .finished: return .defunct
        }
    }
    
    mutating func set(serverState: ServerState) {
        guard case .running(let channel, let stream, let continuation, _) = self else {
            return
        }
        self = .running(channel: channel, stream: stream, continuation: continuation, serverState: serverState)
    }
    
    
}

extension BoltConnection {
    
    @discardableResult
    public func hello(extra: HelloExtra) async throws -> SuccessMetadata {
        let hello = Hello(extra: extra)
        let response = try await execute(request: hello)
        if let connectionID = response.connectionID {
            self.logger?[metadataKey: "server_connection_id"] = .string(connectionID)
        }
        return response
    }
    
    @discardableResult
    public func logon(auth: Auth) async throws -> SuccessMetadata {
        let logon = Logon(auth: auth)
        return try await execute(request: logon)
    }
    
    @discardableResult
    public func logoff() async throws -> SuccessMetadata {
        let logoff = Logoff()
        return try await execute(request: logoff)
    }
    
    @discardableResult
    public func telemetry(api: TelemetryAPI) async throws -> SuccessMetadata {
        let telemtry = Telemetry(api: api)
        return try await execute(request: telemtry)
    }
    
    public func goodbye() async throws {
        let goodbye = Goodbye()
        do {
            return try await execute(request: goodbye)
        } catch let error as BoltError where error.base == .connectionClosed {
            // Expected error because of the goodbye request.
            return
        }
    }
    
    @discardableResult
    public func reset() async throws -> SuccessMetadata {
        let reset = Reset()
        return try await execute(request: reset)
    }
    
    @discardableResult
    public func run(query: String, parameters: [String : PackStreamValue] = [:], extra: RunExtra = .none) async throws -> SuccessMetadata {
        let run = Run(query: query, parameters: parameters, extra: extra)
        return try await execute(request: run)
    }
    
    @discardableResult
    public func discard(n: DiscardExtra.Amount, qid: Int64? = nil) async throws -> SuccessMetadata {
        let discard = Discard(extra: .init(n: n, qid: qid))
        return try await execute(request: discard)
    }
    
    public func pull(n: PullExtra.Amount, qid: Int64? = nil) async throws -> ([[PackStreamValue]], SuccessMetadata) {
        let pull = Pull(extra: .init(n: n, qid: qid))
        return try await execute(request: pull)
    }
    
    @discardableResult
    public func begin(extra: BeginExtra = .none) async throws -> SuccessMetadata {
        let begin = Begin(extra: extra)
        return try await execute(request: begin)
    }
    
    @discardableResult
    public func commit() async throws -> SuccessMetadata {
        let commit = Commit()
        return try await execute(request: commit)
    }
    
    @discardableResult
    public func rollback() async throws -> SuccessMetadata {
        let rollback = Rollback()
        return try await execute(request: rollback)
    }
    
    @discardableResult
    public func route(routing: [String : PackStreamValue], bookmarks: [String], extra: RouteExtra = .none) async throws -> SuccessMetadata {
        let route = Route(routing: routing, bookmarks: bookmarks, extra: extra)
        return try await execute(request: route)
    }
}
