//
//  UnboundRelationship.swift
//  
//
//  Created by Giacomo Leopizzi on 27/06/24.
//

import PackStream

/*
 tag byte: 72
 Number of fields: 4 (3 before version 5.0)
 UnboundRelationship::Structure(
     id::Integer,
     type::String,
     properties::Dictionary,
     element_id::String,
 )
 */

extension Bolt {
        
    public struct UnboundRelationship: Hashable, StructureCodable, Sendable {
        
        public static var signature: Byte { 0x72 }
        
        public let id: Int64
        public let type: String
        public let properties: PackStreamValue.RawMap
        public let elementID: String
        
        public init(id: Int64, type: String, properties: PackStreamValue.RawMap, elementID: String) {
            self.id = id
            self.type = type
            self.properties = properties
            self.elementID = elementID
        }
        
        public init(from container: inout UnkeyedDecodingContainer) throws {
            self.id = try container.decode(Int64.self)
            self.type = try container.decode(String.self)
            self.properties = try container.decode(PackStreamValue.RawMap.self)
            self.elementID = try container.decode(String.self)
        }
        
        public func encode(to container: inout UnkeyedEncodingContainer) throws {
            try container.encode(self.id)
            try container.encode(self.type)
            try container.encode(self.properties)
            try container.encode(self.elementID)
        }
    }
}
