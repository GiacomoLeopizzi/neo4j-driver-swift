//
//  File.swift
//  
//
//  Created by Giacomo Leopizzi on 02/07/24.
//

import NIO
import PackStream

final class RequestEncoder: MessageToByteEncoder {
   
    typealias OutboundIn = StructureEncodable
        
    let encoder = PackStreamEncoder()
    
    func encode(data: StructureEncodable, out: inout ByteBuffer) throws {
        let value = try encoder.encode(data)
        try out.writePackStream(value)
    }
}
