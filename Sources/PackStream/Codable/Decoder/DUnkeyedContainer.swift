//
//  D_UnkeyedContainer.swift
//
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import NIOCore
#if canImport(Foundation)
import Foundation
#endif

extension _PackStreamDecoder {
    
    struct UnkeyedContainer: UnkeyedDecodingContainer {
        
        let decoder: _PackStreamDecoder
        
        let array: [PackStreamValue]
        var codingPath: [CodingKey] = []
        var currentIndex: Int = 0
        
        var count: Int? {
            return array.count
        }
        var isAtEnd: Bool {
            return currentIndex >= array.count
        }
        
        @inline(__always)
        private func getNextValue<T>(ofType: T.Type) throws -> PackStreamValue {
            guard !self.isAtEnd else {
                var message = "Unkeyed container is at end."
                if T.self == UnkeyedContainer.self {
                    message = "Cannot get nested unkeyed container -- unkeyed container is at end."
                }
                if T.self == Decoder.self {
                    message = "Cannot get superDecoder() -- unkeyed container is at end."
                }
                
                var path = self.codingPath
                path.append(PackStreamKey(index: self.currentIndex))
                
                throw DecodingError.valueNotFound(T.self, .init(codingPath: path, debugDescription: message,underlyingError: nil))
            }
            return self.array[self.currentIndex]
        }
        
        // MARK: - Mull
        
        mutating func decodeNil() throws -> Bool {
            if try self.getNextValue(ofType: Void.self) == .null {
                self.currentIndex += 1
                return true
            }
            return false
        }
        
        // MARK: - Boolean
        
        mutating func decode(_ type: Bool.Type) throws -> Bool {
            let value = try self.getNextValue(ofType: Bool.self)
            guard case .boolean(let bool) = value else {
                throw decoder.createTypeMismatchError(type: type, for: PackStreamKey(index: currentIndex), value: value)
            }
            
            self.currentIndex += 1
            return bool
        }
        
        // MARK: - Integer
        
        @inline(__always) private mutating func decodeFixedWidthInteger<T: FixedWidthInteger>() throws -> T {
            let value = try self.getNextValue(ofType: T.self)
            let key = PackStreamKey(index: self.currentIndex)
            let result = try self.decoder.unwrapFixedWidthInteger(from: value, for: key, as: T.self)
            self.currentIndex += 1
            return result
        }
        
        mutating func decode(_: Int.Type) throws -> Int {
            try decodeFixedWidthInteger()
        }
        
        mutating func decode(_: Int8.Type) throws -> Int8 {
            try decodeFixedWidthInteger()
        }
        
        mutating func decode(_: Int16.Type) throws -> Int16 {
            try decodeFixedWidthInteger()
        }
        
        mutating func decode(_: Int32.Type) throws -> Int32 {
            try decodeFixedWidthInteger()
        }
        
        mutating func decode(_: Int64.Type) throws -> Int64 {
            try decodeFixedWidthInteger()
        }
        
        mutating func decode(_: UInt.Type) throws -> UInt {
            try decodeFixedWidthInteger()
        }
        
        mutating func decode(_: UInt8.Type) throws -> UInt8 {
            try decodeFixedWidthInteger()
        }
        
        mutating func decode(_: UInt16.Type) throws -> UInt16 {
            try decodeFixedWidthInteger()
        }
        
        mutating func decode(_: UInt32.Type) throws -> UInt32 {
            try decodeFixedWidthInteger()
        }
        
        mutating func decode(_: UInt64.Type) throws -> UInt64 {
            try decodeFixedWidthInteger()
        }
        
        // MARK: - Floating point
        
        mutating func decode(_ type: Double.Type) throws -> Double {
            let value = try self.getNextValue(ofType: Double.self)
            guard case .float(let double) = value else {
                throw decoder.createTypeMismatchError(type: type, for: PackStreamKey(index: currentIndex), value: value)
            }
            
            self.currentIndex += 1
            return double
        }
        
        mutating func decode(_ type: Float.Type) throws -> Float {
            let value = try self.getNextValue(ofType: Float.self)
            guard case .float(let double) = value else {
                throw decoder.createTypeMismatchError(type: type, for: PackStreamKey(index: currentIndex), value: value)
            }
            
            self.currentIndex += 1
            return Float(double)
        }
        
        // MARK: - String
        
        mutating func decode(_ type: String.Type) throws -> String {
            let value = try self.getNextValue(ofType: String.self)
            guard case .string(let string) = value else {
                throw decoder.createTypeMismatchError(type: type, for: PackStreamKey(index: currentIndex), value: value)
            }
            
            self.currentIndex += 1
            return string
        }
        
        mutating func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
            let newDecoder = try decoderForNextElement(ofType: type)
            let result = try newDecoder.unwrap(as: type)

            // Decode succeed, increment counter.
            self.currentIndex += 1
            return result
        }
        
        mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
            let decoder = try decoderForNextElement(ofType: KeyedDecodingContainer<NestedKey>.self)
            let container = try decoder.container(keyedBy: type)
            
            self.currentIndex += 1
            return container
        }
        
        mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            let decoder = try decoderForNextElement(ofType: UnkeyedDecodingContainer.self)
            let container = try decoder.unkeyedContainer()
            
            self.currentIndex += 1
            return container
        }
        
        mutating func superDecoder() throws -> Decoder {
            let decoder = try decoderForNextElement(ofType: Decoder.self)
            self.currentIndex += 1
            return decoder
        }
        
        private mutating func decoderForNextElement<T>(ofType: T.Type) throws -> _PackStreamDecoder {
            let value = try self.getNextValue(ofType: T.self)
            let newPath = self.codingPath + [PackStreamKey(index: self.currentIndex)]
            
            return _PackStreamDecoder(value: value, codingPath: newPath)
        }
    }
    
}
