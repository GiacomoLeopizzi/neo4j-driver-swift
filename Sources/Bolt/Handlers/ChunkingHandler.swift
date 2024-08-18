//
//  ChunkingHandler.swift
//  
//
//  Created by Giacomo Leopizzi on 02/07/24.
//

import NIO

final class ChunkingHandler: ChannelDuplexHandler {
    
    typealias InboundIn = ByteBuffer
    typealias InboundOut = ByteBuffer
    typealias OutboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    static let maxChunkSize: Int = Int(UInt16.max)
    
    private var cumulationBuffer: ByteBuffer!

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        var buffer = self.unwrapOutboundIn(data)
        
        while buffer.readableBytes > 0 {
            let chunkSize = min(buffer.readableBytes, Self.maxChunkSize)
            if let chunk = buffer.readSlice(length: chunkSize) {
                context.writeAndFlush(self.wrapOutboundOut(chunk), promise: nil)
            }
        }

        // Send termination
        context.writeAndFlush(self.wrapOutboundOut(ByteBuffer()), promise: promise)
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var chunk = self.unwrapInboundIn(data)

        if chunk.readableBytes == 0 {
            // NOOP chunk.
            if let fullBuffer = self.cumulationBuffer {
                // Cumulation buffer is now fully received.
                context.fireChannelRead(self.wrapInboundOut(fullBuffer))
                self.cumulationBuffer = nil
            }
        } else {
            if self.cumulationBuffer != nil {
                // Append new chunk
                self.cumulationBuffer.writeBuffer(&chunk)
            } else {
                // Wait for more
                self.cumulationBuffer = chunk
            }
        }
    }
    
}
