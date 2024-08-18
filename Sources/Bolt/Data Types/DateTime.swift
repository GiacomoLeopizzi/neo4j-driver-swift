//
//  DateTime.swift
//  
//
//  Created by Giacomo Leopizzi on 27/06/24.
//

import PackStream

/*
 tag byte: 49
 Number of fields: 3
 DateTime::Structure(
     seconds::Integer,
     nanoseconds::Integer,
     tz_offset_seconds::Integer,
 )
 */

extension Bolt {
    
    public struct DateTime: Hashable, StructureCodable, Sendable {

        public static let signature: Byte = 0x49
        
        public let seconds: Int64
        public let nanoseconds: Int64
        public let tzOffsetSeconds: Int64
        
        public init(seconds: Int64, nanoseconds: Int64, tzOffsetSeconds: Int64) {
            self.seconds = seconds
            self.nanoseconds = nanoseconds
            self.tzOffsetSeconds = tzOffsetSeconds
        }
        
        public init(from container: inout UnkeyedDecodingContainer) throws {
            self.seconds = try container.decode(Int64.self)
            self.nanoseconds = try container.decode(Int64.self)
            self.tzOffsetSeconds = try container.decode(Int64.self)
        }
        
        public func encode(to container: inout UnkeyedEncodingContainer) throws {
            try container.encode(self.seconds)
            try container.encode(self.nanoseconds)
            try container.encode(self.tzOffsetSeconds)
        }
    }
}
