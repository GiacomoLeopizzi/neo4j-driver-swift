//
//  Node.swift
//
//
//  Created by Giacomo Leopizzi on 27/06/24.
//

import PackStream

/*
 tag byte: 4E
 Number of fields: 4 (3 before version 5.0)
 Node::Structure(
 id::Integer,
 labels::List<String>,
 properties::Dictionary,
 element_id::String,
 )
 */

extension Bolt {
        
    public struct Node: Hashable, StructureCodable, Sendable {
        
        public static var signature: Byte { 0x4E }
        
        public let id: Int64
        public let labels: [String]
        public let properties: PackStreamValue.RawMap
        public let elementID: String
        
        public init(id: Int64, labels: [String], properties: PackStreamValue.RawMap, elementID: String) {
            self.id = id
            self.labels = labels
            self.properties = properties
            self.elementID = elementID
        }
        
        public init(from container: inout UnkeyedDecodingContainer) throws {
            self.id = try container.decode(Int64.self)
            self.labels = try container.decode([String].self)
            self.properties = try container.decode(PackStreamValue.RawMap.self)
            self.elementID = try container.decode(String.self)
        }
        
        public func encode(to container: inout UnkeyedEncodingContainer) throws {
            try container.encode(self.id)
            try container.encode(self.labels)
            try container.encode(self.properties)
            try container.encode(self.elementID)
        }
    }
}
