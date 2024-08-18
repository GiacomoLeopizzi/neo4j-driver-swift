//
//  Date.swift
//  
//
//  Created by Giacomo Leopizzi on 27/06/24.
//

import PackStream

/*
 tag byte: 44
 Number of fields: 1
 Date::Structure(
     days::Integer,
 )
 */

extension Bolt {
    
    public struct Date: Hashable, StructureCodable, Sendable {

        public static let signature: Byte = 0x44
        
        public let days: Int64
        
        public init(days: Int64) {
            self.days = days
        }
        
        public init(from container: inout UnkeyedDecodingContainer) throws {
            self.days = try container.decode(Int64.self)
        }
        
        public func encode(to container: inout UnkeyedEncodingContainer) throws {
            try container.encode(self.days)
        }
    }
}
