//
//  File.swift
//  
//
//  Created by Giacomo Leopizzi on 07/11/23.
//

import NIO
import NIOSSL
import NIOExtras

extension ChannelPipeline {
        
    func addInitialHandlers(ssl: BoltConfiguration.SSL?, on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        guard let ssl = ssl else {
            // SSL not enabled, just add initialization handler.
            return self.addHandler(InitializationHandler())
        }
        do {
            // Add the SSL handler first.
            let handler = try NIOSSLClientHandler(context: ssl.context, serverHostname: ssl.serverHostname, customVerificationCallback: ssl.customVerificationCallback, configuration: .init())
            return self.addHandler(handler).flatMap({
                return self.addHandler(InitializationHandler())
            })
        } catch {
            return eventLoop.makeFailedFuture(error)
        }
    }
    
    func configAfterInitialization() -> EventLoopFuture<Void> {
        self.handler(type: InitializationHandler.self)
            .flatMap({ handler in
                return self.removeHandler(handler)
            })
            .flatMap({
                let handlers: [(ChannelHandler, name: String)] = [
                    (LengthFieldPrepender(lengthFieldLength: .two, lengthFieldEndianness: .big), "Bolt.OutboundFrame"),
                    (ByteToMessageHandler(LengthFieldBasedFrameDecoder(lengthFieldLength: .two, lengthFieldEndianness: .big)), "Bolt.InboundFrame"),
                    
                    (ChunkingHandler(), "Bolt.ChunkingHandler"),
                    
                    (MessageToByteHandler(RequestEncoder()), "Bolt.RequestEncoder"),
                    (ByteToMessageHandler(ResponseDecoder()), "Bolt.ResponseDecoder"),
                ]
                
                return .andAllSucceed(handlers.map({ self.addHandler($0, name: $1) }), on: self.eventLoop)
            })
    }
}
