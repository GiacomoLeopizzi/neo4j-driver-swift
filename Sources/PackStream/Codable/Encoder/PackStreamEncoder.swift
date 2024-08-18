//
//  PackStreamEncoder.swift
//  
//
//  Created by Giacomo Leopizzi on 08/07/24.
//

public final class PackStreamEncoder: Sendable {
    
    public static let shared = PackStreamEncoder()
    
    public init() {

    }

    public func encode<T: Encodable>(_ value: T) throws -> PackStreamValue {
        let encoder = _PackStreamEncoder(codingPath: [], userInfo: [:])
        return try encoder.wrapEncodable(value, for: nil)
    }
}
