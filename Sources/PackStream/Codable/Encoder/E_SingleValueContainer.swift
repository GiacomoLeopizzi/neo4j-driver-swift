//
//  E_SingleValueContainer.swift
//  
//
//  Created by Giacomo Leopizzi on 08/07/24.
//

import NIOCore

extension _PackStreamEncoder {
    
    struct SingleValueContainer: SingleValueEncodingContainer {
        
        let encoder: _PackStreamEncoder
        var codingPath: [CodingKey]

        init(encoder: _PackStreamEncoder, codingPath: [CodingKey]) {
            self.encoder = encoder
            self.codingPath = codingPath
        }
        
        // MARK: - Null
        
        mutating func encodeNil() throws {
            encoder.singleValue = .null
        }
        
        // MARK: - Boolean
        
        mutating func encode(_ value: Bool) throws {
            encoder.singleValue = .boolean(value)
        }
        
        // MARK: - Integer
        
        private mutating func encodeFixedWidthInteger<T: FixedWidthInteger>(_ value: T) throws {
            guard value <= Int64.max else {
                throw EncodingError.invalidValue(value, .init(codingPath: codingPath, debugDescription: "Value \(self) is out of range."))
            }
            let integer = Int64(value)
            self.encoder.singleValue = .integer(integer)
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
            encoder.singleValue = .float(value)
        }
        
        mutating func encode(_ value: Float) throws {
            encoder.singleValue = .float(Double(value))
        }
        
        // MARK: - String
        
        mutating func encode(_ value: String) throws {
            encoder.singleValue = .string(value)
        }
        
        mutating func encode<T>(_ value: T) throws where T : Encodable {
            encoder.singleValue = try encoder.wrapEncodable(value, for: nil)
        }
    }
}
