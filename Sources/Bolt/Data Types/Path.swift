//
//  Path.swift
//  
//
//  Created by Giacomo Leopizzi on 27/06/24.
//

import PackStream

/*
 tag byte: 50
 Number of fields: 3
 Path::Structure(
     nodes::List<Node>,
     rels::List<UnboundRelationship>,
     indices::List<Integer>,
 )
 */

extension Bolt {
        
    public struct Path: Hashable, StructureCodable, Sendable {
        
        public static var signature: Byte { 0x50 }
        
        public let nodes: [Node]
        public let relationships: [UnboundRelationship]
        public let indices: [Int64]
        
        public init(nodes: [Node], relationships: [UnboundRelationship], indices: [Int64]) {
            self.nodes = nodes
            self.relationships = relationships
            self.indices = indices
        }
        
        public init(from container: inout UnkeyedDecodingContainer) throws {
            self.nodes = try container.decode([Node].self)
            self.relationships = try container.decode([UnboundRelationship].self)
            self.indices = try container.decode([Int64].self)
        }
        
        public func encode(to container: inout UnkeyedEncodingContainer) throws {
            try container.encode(nodes)
            try container.encode(relationships)
            try container.encode(indices)
        }
    }
}
