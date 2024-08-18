//
//  Record.swift
//  
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream

struct Record: Equatable, StructureDecodable {

    static let signature: Byte = 0x71
    
    let data: [PackStreamValue]

    init(from container: inout any UnkeyedDecodingContainer) throws {
        self.data = try container.decode([PackStreamValue].self)
    }
}
