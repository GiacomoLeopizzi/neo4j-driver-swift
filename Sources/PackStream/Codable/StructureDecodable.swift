//
//  StructureDecodable.swift
//  
//
//  Created by Giacomo Leopizzi on 08/07/24.
//

public protocol StructureDecodable: PackStreamStructure, Decodable {
    
    init(from container: inout UnkeyedDecodingContainer) throws
}

extension StructureDecodable {
    
    public init(from decoder: any Decoder) throws {
        var container = try decoder.unkeyedContainer()
        try self.init(from: &container)
    }
    
}
