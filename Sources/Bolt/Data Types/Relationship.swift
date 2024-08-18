//
//  Relationship.swift
//  
//
//  Created by Giacomo Leopizzi on 27/06/24.
//

import PackStream

/*
 tag byte: 52
 Number of fields: 8 (5 before version 5.0)
 Relationship::Structure(
     id::Integer,
     startNodeId::Integer,
     endNodeId::Integer,
     type::String,
     properties::Dictionary,
     element_id::String,
     start_node_element_id::String,
     end_node_element_id::String,
 )
 */

extension Bolt {
        
    public struct Relationship: Hashable, StructureCodable, Sendable {
        
        public static var signature: Byte { 0x52 }
        
        public let id: Int64
        public let startNodeID: Int64
        public let endNodeID: Int64
        public let type: String
        public let properties: PackStreamValue.RawMap
        public let elementID: String
        public let startNodeElementID: String
        public let endNodeElementID: String
        
        public init(id: Int64, startNodeID: Int64, endNodeID: Int64, type: String, properties: PackStreamValue.RawMap, elementID: String, startNodeElementID: String, endNodeElementID: String) {
            self.id = id
            self.startNodeID = startNodeID
            self.endNodeID = endNodeID
            self.type = type
            self.properties = properties
            self.elementID = elementID
            self.startNodeElementID = startNodeElementID
            self.endNodeElementID = endNodeElementID
        }
        
        public init(from container: inout UnkeyedDecodingContainer) throws {
            self.id = try container.decode(Int64.self)
            self.startNodeID = try container.decode(Int64.self)
            self.endNodeID = try container.decode(Int64.self)
            self.type = try container.decode(String.self)
            self.properties = try container.decode(PackStreamValue.RawMap.self)
            self.elementID = try container.decode(String.self)
            self.startNodeElementID = try container.decode(String.self)
            self.endNodeElementID = try container.decode(String.self)
        }
        
        public func encode(to container: inout UnkeyedEncodingContainer) throws {
            try container.encode(self.id)
            try container.encode(self.startNodeID)
            try container.encode(self.endNodeID)
            try container.encode(self.type)
            try container.encode(self.properties)
            try container.encode(self.elementID)
            try container.encode(self.startNodeElementID)
            try container.encode(self.endNodeElementID)
        }
    }
}
