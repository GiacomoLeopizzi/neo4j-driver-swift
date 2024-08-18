//
//  LocalDateTime.swift
//  
//
//  Created by Giacomo Leopizzi on 27/06/24.
//

import PackStream

/*
 tag byte: 64
 Number of fields: 2
 LocalDateTime::Structure(
     seconds::Integer,
     nanoseconds::Integer,
 )
 */

extension Bolt {
    
    public struct LocalDateTime: Hashable, StructureCodable, Sendable {
        
        public static let signature: Byte = 0x64
        
        public let seconds: Int64
        public let nanoseconds: Int64
        
        public init(seconds: Int64, nanoseconds: Int64) {
            self.seconds = seconds
            self.nanoseconds = nanoseconds
        }
        
        public init(from container: inout UnkeyedDecodingContainer) throws {
            self.seconds = try container.decode(Int64.self)
            self.nanoseconds = try container.decode(Int64.self)
        }
        
        public func encode(to container: inout UnkeyedEncodingContainer) throws {
            try container.encode(self.seconds)
            try container.encode(self.nanoseconds)
        }
    }
}
