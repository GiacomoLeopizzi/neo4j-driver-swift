//
//  File.swift
//  
//
//  Created by Giacomo Leopizzi on 04/11/23.
//

import NIOCore

extension ByteBuffer {
    
    @discardableResult
    mutating func readByte() -> Byte? {
        return readBytes(length: 1)?.first
    }
    
    @discardableResult
    mutating func writeByte(_ byte: Byte) -> Int {
        return self.writeBytes([byte])
    }
    
}
