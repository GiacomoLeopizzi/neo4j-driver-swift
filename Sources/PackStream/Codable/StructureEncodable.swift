//
//  StructureEncodable.swift
//  
//
//  Created by Giacomo Leopizzi on 08/07/24.
//

public protocol StructureEncodable: Encodable, PackStreamStructure {
    
    func encode(to container: inout UnkeyedEncodingContainer) throws
}

extension StructureEncodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try encode(to: &container)
    }
}
