//
//  Ignored.swift
//  
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream

struct Ignored: Equatable, StructureDecodable {

    static let signature: Byte = 0x7E
    
    init(from container: inout any UnkeyedDecodingContainer) throws {
        
    }
    
}
