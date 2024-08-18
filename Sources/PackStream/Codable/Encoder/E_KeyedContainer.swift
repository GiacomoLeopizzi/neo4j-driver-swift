//
//  E_KeyedContainer.swift
//  
//
//  Created by Giacomo Leopizzi on 08/07/24.
//

extension _PackStreamEncoder {
    
    struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
        
        let encoder: _PackStreamEncoder
        var codingPath: [any CodingKey]
        let object: PackStreamFuture.RefDictionary
        
        init(encoder: _PackStreamEncoder, codingPath: [any CodingKey], object: PackStreamFuture.RefDictionary) {
            self.encoder = encoder
            self.codingPath = codingPath
            self.object = object
        }
        
        // MARK: - Null
        
        mutating func encodeNil(forKey key: Key) throws {
            object.set(.null, for: key.stringValue)
        }
        
        // MARK: - Boolean
        
        mutating func encode(_ value: Bool, forKey key: Key) throws {
            object.set(.boolean(value), for: key.stringValue)
        }
        
        // MARK: - Integer
        
        private mutating func encodeFixedWidthInteger<T: FixedWidthInteger>(_ value: T, forKey key: Key) throws {
            guard value <= Int64.max else {
                throw EncodingError.invalidValue(value, .init(codingPath: codingPath, debugDescription: "Value \(self) is out of range."))
            }
            let integer = Int64(value)
            object.set(.integer(integer), for: key.stringValue)
        }
        
        mutating func encode(_ value: Int, forKey key: Key) throws {
            try encodeFixedWidthInteger(value, forKey: key)
        }
        
        mutating func encode(_ value: Int8, forKey key: Key) throws {
            try encodeFixedWidthInteger(value, forKey: key)
        }
        
        mutating func encode(_ value: Int16, forKey key: Key) throws {
            try encodeFixedWidthInteger(value, forKey: key)
        }
        
        mutating func encode(_ value: Int32, forKey key: Key) throws {
            try encodeFixedWidthInteger(value, forKey: key)
        }
        
        mutating func encode(_ value: Int64, forKey key: Key) throws {
            try encodeFixedWidthInteger(value, forKey: key)
        }
        
        mutating func encode(_ value: UInt, forKey key: Key) throws {
            try encodeFixedWidthInteger(value, forKey: key)
        }
        
        mutating func encode(_ value: UInt8, forKey key: Key) throws {
            try encodeFixedWidthInteger(value, forKey: key)
        }
        
        mutating func encode(_ value: UInt16, forKey key: Key) throws {
            try encodeFixedWidthInteger(value, forKey: key)
        }
        
        mutating func encode(_ value: UInt32, forKey key: Key) throws {
            try encodeFixedWidthInteger(value, forKey: key)
        }
        
        mutating func encode(_ value: UInt64, forKey key: Key) throws {
            try encodeFixedWidthInteger(value, forKey: key)
        }
        
        // MARK: - Floating point
        
        mutating func encode(_ value: Double, forKey key: Key) throws {
            object.set(.float(value), for: key.stringValue)
        }
        
        mutating func encode(_ value: Float, forKey key: Key) throws {
            object.set(.float(Double(value)), for: key.stringValue)
        }
        
        // MARK: - String
        
        mutating func encode(_ value: String, forKey key: Key) throws {
            object.set(.string(value), for: key.stringValue)
        }
        
        func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
            let encoded = try encoder.wrapEncodable(value, for: key)
            self.object.set(encoded, for: key.stringValue)
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            let newPath = self.codingPath + [key]
            let dict = self.object.setDictionary(for: key.stringValue)
            let nestedContainer = KeyedContainer<NestedKey>(encoder: encoder, codingPath: newPath, object: dict)
            return KeyedEncodingContainer(nestedContainer)
        }
        
        mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
            let newPath = self.codingPath + [key]
            let array = self.object.setList(for: key.stringValue)
            let nestedContainer = UnkeyedContainer(encoder: encoder, object: array, codingPath: newPath)
            return nestedContainer
        }
        
        mutating func superEncoder() -> Encoder {
            fatalError()
        }
        
        mutating func superEncoder(forKey key: Key) -> any Encoder {
            return encoder.getEncoder(for: key)
        }
        
    }
    
}
