//
//  D_KeyedContainer.swift
//  
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import NIOCore
#if canImport(Foundation)
import Foundation
#endif

extension _PackStreamDecoder {
    
    struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {

        let decoder: _PackStreamDecoder
        let codingPath: [CodingKey]
        let dictionary: [String : PackStreamValue]

        init(decoder: _PackStreamDecoder, codingPath: [CodingKey], dictionary: [String : PackStreamValue]) {
            self.decoder = decoder
            self.codingPath = codingPath
            self.dictionary = dictionary
        }

        var allKeys: [Key] {
            self.dictionary.keys.compactMap { Key(stringValue: $0) }
        }

        func contains(_ key: Key) -> Bool {
            dictionary[key.stringValue] != nil
        }

        // MARK: - Null
        
        func decodeNil(forKey key: Key) throws -> Bool {
            let value = try getValue(forKey: key)
            return value == .null
        }

        // MARK: - Boolean
        
        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            let value = try getValue(forKey: key)
            guard case .boolean(let bool) = value else {
                throw createTypeMismatchError(type: type, forKey: key, value: value)
            }
            return bool
        }

        // MARK: - Integer
        
        func decode(_: Int.Type, forKey key: Key) throws -> Int {
            try decodeFixedWidthInteger(key: key)
        }

        func decode(_: Int8.Type, forKey key: Key) throws -> Int8 {
            try decodeFixedWidthInteger(key: key)
        }

        func decode(_: Int16.Type, forKey key: Key) throws -> Int16 {
            try decodeFixedWidthInteger(key: key)
        }

        func decode(_: Int32.Type, forKey key: Key) throws -> Int32 {
            try decodeFixedWidthInteger(key: key)
        }

        func decode(_: Int64.Type, forKey key: Key) throws -> Int64 {
            try decodeFixedWidthInteger(key: key)
        }

        func decode(_: UInt.Type, forKey key: Key) throws -> UInt {
            try decodeFixedWidthInteger(key: key)
        }

        func decode(_: UInt8.Type, forKey key: Key) throws -> UInt8 {
            try decodeFixedWidthInteger(key: key)
        }

        func decode(_: UInt16.Type, forKey key: Key) throws -> UInt16 {
            try decodeFixedWidthInteger(key: key)
        }

        func decode(_: UInt32.Type, forKey key: Key) throws -> UInt32 {
            try decodeFixedWidthInteger(key: key)
        }

        func decode(_: UInt64.Type, forKey key: Key) throws -> UInt64 {
            try decodeFixedWidthInteger(key: key)
        }
        
        // MARK: - Floating point
        
        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            let value = try getValue(forKey: key)
            guard case .float(let double) = value else {
                throw createTypeMismatchError(type: type, forKey: key, value: value)
            }
            return double
        }

        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            let value = try getValue(forKey: key)
            guard case .float(let double) = value else {
                throw createTypeMismatchError(type: type, forKey: key, value: value)
            }
            return Float(double)
        }
        
        // MARK: - String
        
        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            let value = try getValue(forKey: key)
            guard case .string(let string) = value else {
                throw createTypeMismatchError(type: type, forKey: key, value: value)
            }
            return string
        }

        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
            let newDecoder = try decoderForKey(key)
            return try newDecoder.unwrap(as: type)
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            try decoderForKey(key).container(keyedBy: type)
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            try decoderForKey(key).unkeyedContainer()
        }

        func superDecoder() throws -> any Decoder {
            fatalError("Unsupported")
        }
        
        func superDecoder(forKey key: Key) throws -> any Decoder {
            fatalError("Unsupported")
        }
        
        private func decoderForKey<LocalKey: CodingKey>(_ key: LocalKey) throws -> _PackStreamDecoder {
            let value = try getValue(forKey: key)
            var newPath = self.codingPath
            newPath.append(key)
            
            return _PackStreamDecoder(value: value, codingPath: newPath)
        }

        @inline(__always) private func getValue<LocalKey: CodingKey>(forKey key: LocalKey) throws -> PackStreamValue {
            guard let value = dictionary[key.stringValue] else {
                throw DecodingError.keyNotFound(key, .init(codingPath: self.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
            }
            return value
        }

        @inline(__always) private func createTypeMismatchError(type: Any.Type, forKey key: Key, value: PackStreamValue) -> DecodingError {
            let codingPath = self.codingPath + [key]
            return DecodingError.typeMismatch(type, .init(codingPath: codingPath, debugDescription: "Expected to decode \(type) but found \(value) instead."))
        }

        @inline(__always) private func decodeFixedWidthInteger<T: FixedWidthInteger>(key: Self.Key) throws -> T {
            let value = try getValue(forKey: key)
            return try self.decoder.unwrapFixedWidthInteger(from: value, for: key, as: T.self)
        }
    }
}
