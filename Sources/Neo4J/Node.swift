//
//  Node.swift
//  neo4j-driver
//
//  Created by Giacomo Leopizzi on 18/08/24.
//

import Bolt

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

public final class Node<P: NodeProperties>: Hashable, StructureDecodable, Sendable, CustomStringConvertible {
    
    // MARK: - Types
    
    public struct Metadata: Hashable, Sendable {
        public let id: Int64
        public let labels: [String]
        public let elementID: String
    }
    
    // MARK: - Properties
    
    public static var signature: Byte { Bolt.Node.signature }
    
    public let metadata: Metadata
    public let properties: P
    
    public var description: String {
        return "Node(metadata: \(metadata), properties: \(properties))"
    }
    
    // MARK: - Init and deinit
    
    init(metadata: Metadata, properties: P) {
        self.metadata = metadata
        self.properties = properties
    }
    
    public init(from container: inout UnkeyedDecodingContainer) throws {
        let id = try container.decode(Int64.self)
        let labels = try container.decode([String].self)
        let properties = try container.decode(P.self)
        let elementID = try container.decode(String.self)
        
        self.metadata = Metadata(id: id, labels: labels, elementID: elementID)
        self.properties = properties
    }
    
    // MARK: - Methods
    
    public static func == (lhs: Node<P>, rhs: Node<P>) -> Bool {
        return lhs.metadata == rhs.metadata && lhs.properties == rhs.properties
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(metadata)
        hasher.combine(properties)
    }
}
