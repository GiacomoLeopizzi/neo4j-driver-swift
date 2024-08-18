//
//  LocalTime.swift
//  
//
//  Created by Giacomo Leopizzi on 27/06/24.
//

import PackStream

/*
 tag byte: 74
 Number of fields: 1
 LocalTime::Structure(
     nanoseconds::Integer,
 )
 */

extension Bolt {
    
    public struct LocalTime: Hashable, StructureCodable, Sendable {
     
        public static let signature: Byte = 0x74
        
        public let nanoseconds: Int64
        
        public init(nanoseconds: Int64) {
            self.nanoseconds = nanoseconds
        }
        
        public init(from container: inout UnkeyedDecodingContainer) throws {
            self.nanoseconds = try container.decode(Int64.self)
        }
        
        public func encode(to container: inout UnkeyedEncodingContainer) throws {
            try container.encode(self.nanoseconds)
        }
    }
}
