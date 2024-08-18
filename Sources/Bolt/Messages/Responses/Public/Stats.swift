//
//  Stats.swift
//
//
//  Created by Giacomo Leopizzi on 09/07/24.
//

public struct Stats: Decodable, Equatable, Sendable {
    
    enum CodingKeys: String, CodingKey {
        case constraintsAdded = "constraints-added"
        case constraintsRemoved = "constraints-removed"
        case indexesAdded = "indexes-added"
        case indexesRemoved = "indexes-removed"
        case labelsAdded = "labels-added"
        case labelsRemoved = "labels-removed"
        case nodesCreated = "nodes-created"
        case nodesDeleted = "nodes-deleted"
        case propertiesSet = "properties-set"
        case relationshipsCreated = "relationships-created"
        case relationshipsDeleted = "relationships-deleted"
        
        case containsUpdates = "contains-updates"
        case containsSystemUpdates = "contains-system-updates"
        case systemUpdates = "system-updates"
    }
    
    public var constraintsAdded: Int
    public var constraintsRemoved: Int
    public var indexesAdded: Int
    public var indexesRemoved: Int
    public var labelsAdded: Int
    public var labelsRemoved: Int
    public var nodesCreated: Int
    public var nodesDeleted: Int
    public var propertiesSet: Int
    public var relationshipsCreated: Int
    public var relationshipsDeleted: Int
    
    public var containsUpdates: Bool
    public var containsSystemUpdates: Bool
    public var systemUpdates: Int
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.constraintsAdded = try container.decodeIfPresent(Int.self, forKey: .constraintsAdded) ?? 0
        self.constraintsRemoved = try container.decodeIfPresent(Int.self, forKey: .constraintsRemoved) ?? 0
        self.indexesAdded = try container.decodeIfPresent(Int.self, forKey: .indexesAdded) ?? 0
        self.indexesRemoved = try container.decodeIfPresent(Int.self, forKey: .indexesRemoved) ?? 0
        self.labelsAdded = try container.decodeIfPresent(Int.self, forKey: .labelsAdded) ?? 0
        self.labelsRemoved = try container.decodeIfPresent(Int.self, forKey: .labelsRemoved) ?? 0
        self.nodesCreated = try container.decodeIfPresent(Int.self, forKey: .nodesCreated) ?? 0
        self.nodesDeleted = try container.decodeIfPresent(Int.self, forKey: .nodesDeleted) ?? 0
        self.propertiesSet = try container.decodeIfPresent(Int.self, forKey: .propertiesSet) ?? 0
        self.relationshipsCreated = try container.decodeIfPresent(Int.self, forKey: .relationshipsCreated) ?? 0
        self.relationshipsDeleted = try container.decodeIfPresent(Int.self, forKey: .relationshipsDeleted) ?? 0
        
        self.containsUpdates = try container.decodeIfPresent(Bool.self, forKey: .containsUpdates) ?? false
        self.containsSystemUpdates = try container.decodeIfPresent(Bool.self, forKey: .containsSystemUpdates) ?? false
        self.systemUpdates = try container.decodeIfPresent(Int.self, forKey: .systemUpdates) ?? 0
    }
}

extension Stats: CustomStringConvertible {
    
    public var description: String {
        var description = [String]()
        
        if constraintsAdded != 0 {
            description.append("\(CodingKeys.constraintsAdded.rawValue): \(constraintsAdded)")
        }
        if constraintsRemoved != 0 {
            description.append("\(CodingKeys.constraintsRemoved.rawValue): \(constraintsRemoved)")
        }
        if indexesAdded != 0 {
            description.append("\(CodingKeys.indexesAdded.rawValue): \(indexesAdded)")
        }
        if indexesRemoved != 0 {
            description.append("\(CodingKeys.indexesRemoved.rawValue): \(indexesRemoved)")
        }
        if labelsAdded != 0 {
            description.append("\(CodingKeys.labelsAdded.rawValue): \(labelsAdded)")
        }
        if labelsRemoved != 0 {
            description.append("\(CodingKeys.labelsRemoved.rawValue): \(labelsRemoved)")
        }
        if nodesCreated != 0 {
            description.append("\(CodingKeys.nodesCreated.rawValue): \(nodesCreated)")
        }
        if nodesDeleted != 0 {
            description.append("\(CodingKeys.nodesDeleted.rawValue): \(nodesDeleted)")
        }
        if propertiesSet != 0 {
            description.append("\(CodingKeys.propertiesSet.rawValue): \(propertiesSet)")
        }
        if relationshipsCreated != 0 {
            description.append("\(CodingKeys.relationshipsCreated.rawValue): \(relationshipsCreated)")
        }
        if relationshipsDeleted != 0 {
            description.append("\(CodingKeys.relationshipsDeleted.rawValue): \(relationshipsDeleted)")
        }
        if containsUpdates {
            description.append("\(CodingKeys.containsUpdates.rawValue): \(containsUpdates)")
        }
        if containsSystemUpdates {
            description.append("\(CodingKeys.containsSystemUpdates.rawValue): \(containsSystemUpdates)")
        }
        if systemUpdates != 0 {
            description.append("\(CodingKeys.systemUpdates.rawValue): \(systemUpdates)")
        }

        return description.joined(separator: ", ")
    }
}
