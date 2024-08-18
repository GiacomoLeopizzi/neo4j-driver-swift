//
//  E_UnkeyedContainer.swift
//  
//
//  Created by Giacomo Leopizzi on 08/07/24.
//

import NIOCore

extension _PackStreamEncoder {
    
    struct UnkeyedContainer: UnkeyedEncodingContainer {
    
        let encoder: _PackStreamEncoder
        let object: PackStreamFuture.RefList
        var codingPath: [CodingKey]
        var count: Int {
            object.list.count
        }
        
        init(encoder: _PackStreamEncoder, object: PackStreamFuture.RefList, codingPath: [CodingKey]) {
            self.encoder = encoder
            self.object = object
            self.codingPath = codingPath
        }
        
        // MARK: - Null
        
        mutating func encodeNil() throws {
            object.append(.null)
        }
        
        // MARK: - Boolean
        
        mutating func encode(_ value: Bool) throws {
            object.append(.boolean(value))
        }
        
        // MARK: - Integer
        
        private mutating func encodeFixedWidthInteger<T: FixedWidthInteger>(_ value: T) throws {
            guard value <= Int64.max else {
                throw EncodingError.invalidValue(value, .init(codingPath: codingPath, debugDescription: "Value \(self) is out of range."))
            }
            let integer = Int64(value)
            object.append(.integer(integer))
        }
        
        mutating func encode(_ value: Int) throws {
            try encodeFixedWidthInteger(value)
        }
        
        mutating func encode(_ value: Int8) throws {
            try encodeFixedWidthInteger(value)
        }

        mutating func encode(_ value: Int16) throws {
            try encodeFixedWidthInteger(value)
        }
        
        mutating func encode(_ value: Int32) throws {
            try encodeFixedWidthInteger(value)
        }
        
        mutating func encode(_ value: Int64) throws {
            try encodeFixedWidthInteger(value)
        }
        
        mutating func encode(_ value: UInt) throws {
            try encodeFixedWidthInteger(value)
        }
        
        mutating func encode(_ value: UInt8) throws {
            try encodeFixedWidthInteger(value)
        }

        mutating func encode(_ value: UInt16) throws {
            try encodeFixedWidthInteger(value)
        }
        
        mutating func encode(_ value: UInt32) throws {
            try encodeFixedWidthInteger(value)
        }
        
        mutating func encode(_ value: UInt64) throws {
            try encodeFixedWidthInteger(value)
        }
        
        // MARK: - Floating point
        
        mutating func encode(_ value: Double) throws {
            object.append(.float(value))
        }
        
        mutating func encode(_ value: Float) throws {
            object.append(.float(Double(value)))
        }
        
        // MARK: - String
        
        mutating func encode(_ value: String) throws {
            object.append(.string(value))
        }
        
        mutating func encode<T>(_ value: T) throws where T: Encodable {
            let key = PackStreamKey(stringValue: "Index \(self.count)", intValue: self.count)
            let encoded = try encoder.wrapEncodable(value, for: key)
            self.object.append(encoded)
        }

        mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
            let newPath = self.codingPath + [PackStreamKey(index: self.count)]
            let dict = self.object.appendDictionary()
            let nestedContainer = KeyedContainer<NestedKey>(encoder: encoder, codingPath: newPath, object: dict)
            return KeyedEncodingContainer(nestedContainer)
        }

        mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            let newPath = self.codingPath + [PackStreamKey(index: self.count)]
            let array = self.object.appendList()
            let nestedContainer = UnkeyedContainer(encoder: encoder, object: array, codingPath: newPath)
            return nestedContainer
        }

        mutating func superEncoder() -> Encoder {
            let encoder = encoder.getEncoder(for: PackStreamKey(index: self.count))
            self.object.append(encoder)
            return encoder
        }
        
    }
    
}
