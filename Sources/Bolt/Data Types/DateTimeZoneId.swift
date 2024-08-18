//
//  DateTimeZoneId.swift
//  
//
//  Created by Giacomo Leopizzi on 27/06/24.
//

import PackStream

/*
 tag byte: 69
 Number of fields: 3
 DateTimeZoneId::Structure(
     seconds::Integer,
     nanoseconds::Integer,
     tz_id::String,
 )
 */

extension Bolt {
    
    public struct DateTimeZoneId: Hashable, StructureCodable, Sendable {
        
        public static let signature: Byte = 0x69
        
        public let seconds: Int64
        public let nanoseconds: Int64
        public let tzID: String
        
        public init(seconds: Int64, nanoseconds: Int64, tzID: String) {
            self.seconds = seconds
            self.nanoseconds = nanoseconds
            self.tzID = tzID
        }
        
        public init(from container: inout UnkeyedDecodingContainer) throws {
            self.seconds = try container.decode(Int64.self)
            self.nanoseconds = try container.decode(Int64.self)
            self.tzID = try container.decode(String.self)
        }
        
        public func encode(to container: inout UnkeyedEncodingContainer) throws {
            try container.encode(self.seconds)
            try container.encode(self.nanoseconds)
            try container.encode(self.tzID)
        }
    }
}
