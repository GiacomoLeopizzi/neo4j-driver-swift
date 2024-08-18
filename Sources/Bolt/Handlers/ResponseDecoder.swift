//
//  File.swift
//  
//
//  Created by Giacomo Leopizzi on 02/07/24.
//

import NIO
import PackStream

final class ResponseDecoder: ByteToMessageDecoder {
    
    typealias InboundOut = Response
        
    private var records: [[PackStreamValue]]
    
    init() {
        self.records = []
    }
    
    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        guard buffer.readableBytes > 0 else {
            return .needMoreData
        }
        let value = try buffer.readPackStream()
        let response = try ResponseMessage(value: value)
        
        switch response {
        case .detail(let record):
            self.records.append(record.data)
            return .needMoreData
        case .summary(let summary):
            let records = self.records
            defer {
                // Empty the records buffer.
                self.records.removeAll(keepingCapacity: true)
            }
            let completeResponse = Response(records: records, summary: summary)
            context.fireChannelRead(self.wrapInboundOut(completeResponse))
            return .continue
        }
    }
}

fileprivate enum ResponseMessage {
    case detail(Record)
    case summary(Summary)
    
    init(value: PackStreamValue) throws {
        let (signature, _) = try value.requireStructure()
        
        let decoder = PackStreamDecoder()
        
        switch signature {
        case Record.signature:
            let record = try decoder.decode(value: value, Record.self)
            self = .detail(record)
        case Success.signature:
            let success = try decoder.decode(value: value, Success.self)
            self = .summary(.success(metadata: success.metadata))
        case Failure.signature:
            let failure = try decoder.decode(value: value, Failure.self)
            self = .summary(.failure(metadata: failure.metadata))
        case Ignored.signature:
            self = .summary(.ignored)
        default:
            throw PackStreamError.external(error: BoltError(.notValidResponse, location: .here()), location: .here())
        }
    }
}
