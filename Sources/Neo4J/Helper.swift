//
//  Helper.swift
//  
//
//  Created by Giacomo Leopizzi on 09/07/24.
//

import PackStream

struct Helper {
    
    static func decode<each T: Decodable>(_ items: [PackStreamValue], as types: repeat (each T).Type, using decoder: PackStreamDecoder) throws -> (repeat each T) {
        func decode<U: Decodable>(index: inout Int, from items: [PackStreamValue], as _: U.Type, using decoder: PackStreamDecoder) throws -> U {
            defer {
                index += 1
            }
            guard items.indices.contains(index) else {
                throw Neo4JError(.indexOutOfRange, detail: "Index \(index) is out of range for array. Max valid index: \(items.count - 1)", location: .here())
            }
            return try decoder.decode(value: items[index], U.self)
        }
        
        var index = 0
        return try (repeat decode(index: &index, from: items, as: (each T).self, using: decoder))
    }
    
}
