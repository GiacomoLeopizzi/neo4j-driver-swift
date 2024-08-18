//
//  Time.swift
//  
//
//  Created by Giacomo Leopizzi on 27/06/24.
//

import PackStream

/*
 tag byte: 54
 Number of fields: 2
 Time::Structure(
     nanoseconds::Integer,
     tz_offset_seconds::Integer,
 )
 */

extension Bolt {
    
    public struct Time: Hashable, StructureCodable, Sendable {
        
        public static let signature: Byte = 0x54
        
        public let nanoseconds: Int64
        public let tzOffsetSeconds: Int64
        
        public init(nanoseconds: Int64, tzOffsetSeconds: Int64) {
            self.nanoseconds = nanoseconds
            self.tzOffsetSeconds = tzOffsetSeconds
        }
        
        public init(from container: inout UnkeyedDecodingContainer) throws {
            self.nanoseconds = try container.decode(Int64.self)
            self.tzOffsetSeconds = try container.decode(Int64.self)
        }
        
        public func encode(to container: inout UnkeyedEncodingContainer) throws {
            try container.encode(self.nanoseconds)
            try container.encode(self.tzOffsetSeconds)
        }
    }
}
