//
//  File.swift
//
//
//  Created by Giacomo Leopizzi on 02/07/24.
//

import NIO

struct InitializationRequest {
    let supportedVersions: [Version]
    let result: EventLoopPromise<Version>
    
    init(supportedVersions: [Version], result: EventLoopPromise<Version>) {
        precondition(supportedVersions.count == 4)
        self.supportedVersions = supportedVersions
        self.result = result
    }
}

final class InitializationHandler: ChannelDuplexHandler {
    
    typealias InboundIn = ByteBuffer
    typealias InboundOut = Never
    typealias OutboundIn = InitializationRequest
    typealias OutboundOut = ByteBuffer
    
    private static var identificationBytes: [UInt8] {
        [0x60, 0x60, 0xB0, 0x17]
    }
    
    enum Errors: Error {
        case notInitialized
        case unexpectedIncomingData
        case notValidInitResponse
        
        case notSupported
    }
    
    enum State {
        case idle
        case onGoing(InitializationRequest)
        case completed
    }
    
    private var state: State
    
    init() {
        self.state = .idle
    }
    
    func handlerRemoved(context: ChannelHandlerContext) {
        if case .onGoing(let request) = state {
            request.result.fail(Errors.notInitialized)
        }
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        guard case .idle = state else {
            promise?.fail(Errors.notSupported)
            return
        }
        let request = self.unwrapOutboundIn(data)
        self.state = .onGoing(request)
        
        let identification = context.channel.allocator.buffer(bytes: Self.identificationBytes)
        var version = context.channel.allocator.buffer(capacity: Version.size * 4)
        for i in request.supportedVersions {
            version.writeInteger(i.rawValue, endianness: .big, as: Version.RawValue.self)
        }
        context.write(self.wrapOutboundOut(identification), promise: nil)
        context.writeAndFlush(self.wrapOutboundOut(version), promise: promise)
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        guard case .onGoing(let request) = self.state else {
            return
        }
        defer {
            self.state = .completed
        }
        do {
            var buffer = self.unwrapInboundIn(data)
            guard let supported = buffer.readInteger(endianness: .big, as: Version.RawValue.self), buffer.readableBytes == 0 else {
                throw Errors.notValidInitResponse
            }
            guard supported != 0 else {
                throw Errors.notSupported
            }
            request.result.succeed(Version(rawValue: supported))
        } catch {
            request.result.fail(error)
        }
    }
}

extension InitializationHandler: RemovableChannelHandler {
    
    func removeHandler(context: ChannelHandlerContext, removalToken: ChannelHandlerContext.RemovalToken) {
        precondition(context.handler === self)
        context.leavePipeline(removalToken: removalToken)
    }
}
