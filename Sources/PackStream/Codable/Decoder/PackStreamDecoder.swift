//
//  PackStreamDecoder.swift
//  
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

public final class PackStreamDecoder: Sendable {
    
    public static let shared = PackStreamDecoder()
    
    public init() {

    }

    public func decode<T: Decodable>(value: PackStreamValue, _ type: T.Type) throws -> T {
        let decoder = _PackStreamDecoder(value: value, codingPath: [])
        return try decoder.unwrap(as: T.self)
    }
}
