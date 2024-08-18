//
//  Failure.swift
//  
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream

struct Failure: Error, Equatable, StructureDecodable {

    static let signature: Byte = 0x7F
    
    let metadata: FailureMetadata
    
    init(from container: inout any UnkeyedDecodingContainer) throws {
        self.metadata = try container.decode(FailureMetadata.self)
    }
}
