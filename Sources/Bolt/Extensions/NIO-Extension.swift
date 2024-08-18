//
//  File.swift
//  
//
//  Created by Giacomo Leopizzi on 07/11/23.
//

import NIO
import NIOExtras

extension ChannelPipeline {
        
    func addInitialHandlers() -> EventLoopFuture<Void> {
        return self.addHandler(InitializationHandler())
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
