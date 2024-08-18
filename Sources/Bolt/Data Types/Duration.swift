//
//  Duration.swift
//  
//
//  Created by Giacomo Leopizzi on 27/06/24.
//

import PackStream

/*
 tag byte: 45
 Number of fields: 4
 Duration::Structure(
     months::Integer,
     days::Integer,
     seconds::Integer,
     nanoseconds::Integer,
 )
 */

extension Bolt {

    public struct Duration: Hashable, StructureCodable, Sendable {
        
        public static let signature: Byte = 0x45
        
        public let months: Int64
        public let days: Int64
        public let seconds: Int64
        public let nanoseconds: Int64
        
        public init(months: Int64, days: Int64, seconds: Int64, nanoseconds: Int64) {
            self.months = months
            self.days = days
            self.seconds = seconds
            self.nanoseconds = nanoseconds
        }
        
        public init(from container: inout UnkeyedDecodingContainer) throws {
            self.months = try container.decode(Int64.self)
            self.days = try container.decode(Int64.self)
            self.seconds = try container.decode(Int64.self)
            self.nanoseconds = try container.decode(Int64.self)
        }
        
        
        public func encode(to container: inout UnkeyedEncodingContainer) throws {
            try container.encode(self.months)
            try container.encode(self.days)
            try container.encode(self.seconds)
            try container.encode(self.nanoseconds)
        }
    }
}
