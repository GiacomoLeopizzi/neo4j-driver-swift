//
//  Success.swift
//  
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream

struct Success: Equatable, StructureDecodable {

    static let signature: Byte = 0x70
    
    let metadata: SuccessMetadata
    
    init(from container: inout any UnkeyedDecodingContainer) throws {
        self.metadata = try container.decode(SuccessMetadata.self)
    }
}
