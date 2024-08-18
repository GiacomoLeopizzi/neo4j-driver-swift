//
//  Relationship.swift
//  neo4j-driver
//
//  Created by Giacomo Leopizzi on 18/08/24.
//

import Bolt

public final class Relationship<P: RelationshipProperties>: Hashable, StructureDecodable, Sendable {
    
    // MARK: - Types
    
    public struct Metadata: Hashable, Sendable {
        public let id: Int64
        public let startNodeID: Int64
        public let endNodeID: Int64
        public let type: String
        public let elementID: String
        public let startNodeElementID: String
        public let endNodeElementID: String
    }
    
    // MARK: - Properties
    
    public static var signature: Byte { Bolt.Relationship.signature }
    
    public let metadata: Metadata
    public let properties: P
    
    // MARK: - Init and deinit
    
    init(metadata: Metadata, properties: P) {
        self.metadata = metadata
        self.properties = properties
    }
    
    public init(from container: inout UnkeyedDecodingContainer) throws {
        let id = try container.decode(Int64.self)
        let startNodeID = try container.decode(Int64.self)
        let endNodeID = try container.decode(Int64.self)
        let type = try container.decode(String.self)
        let properties = try container.decode(P.self)
        let elementID = try container.decode(String.self)
        let startNodeElementID = try container.decode(String.self)
        let endNodeElementID = try container.decode(String.self)

        self.metadata = Metadata(id: id, startNodeID: startNodeID, endNodeID: endNodeID, type: type, elementID: elementID, startNodeElementID: startNodeElementID, endNodeElementID: endNodeElementID)
        self.properties = properties
    }
    
    // MARK: - Methods
    
    public static func == (lhs: Relationship<P>, rhs: Relationship<P>) -> Bool {
        return lhs.metadata == rhs.metadata && lhs.properties == rhs.properties
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(metadata)
        hasher.combine(properties)
    }
}
