//
//  D_SingleValueContainer.swift
//  
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import NIOCore
#if canImport(Foundation)
import Foundation
#endif

extension _PackStreamDecoder {
    
    struct SingleValueContainer: SingleValueDecodingContainer {
        
        let decoder: _PackStreamDecoder
        let value: PackStreamValue
        
        var codingPath: [CodingKey] = []
        
        // MARK: - Mull
        
        func decodeNil() -> Bool {
            return value.isNull
        }
        
        // MARK: - Boolean
        
        func decode(_ type: Bool.Type) throws -> Bool {
            guard case .boolean(let v) = value else {
                throw decoder.createTypeMismatchError(type: Bool.self, value: self.value)
            }
            return v
        }
        
        // MARK: - Integer
        
        func decode(_: Int.Type) throws -> Int {
            try self.decoder.unwrapFixedWidthInteger(from: value, as: Int.self)
        }
        
        func decode(_: Int8.Type) throws -> Int8 {
            try self.decoder.unwrapFixedWidthInteger(from: value, as: Int8.self)
        }
        
        func decode(_: Int16.Type) throws -> Int16 {
            try self.decoder.unwrapFixedWidthInteger(from: value, as: Int16.self)
        }
        
        func decode(_: Int32.Type) throws -> Int32 {
            try self.decoder.unwrapFixedWidthInteger(from: value, as: Int32.self)
        }
        
        func decode(_: Int64.Type) throws -> Int64 {
            try self.decoder.unwrapFixedWidthInteger(from: value, as: Int64.self)
        }
        
        func decode(_: UInt.Type) throws -> UInt {
            try self.decoder.unwrapFixedWidthInteger(from: value, as: UInt.self)
        }
        
        func decode(_: UInt8.Type) throws -> UInt8 {
            try self.decoder.unwrapFixedWidthInteger(from: value, as: UInt8.self)
        }
        
        func decode(_: UInt16.Type) throws -> UInt16 {
            try self.decoder.unwrapFixedWidthInteger(from: value, as: UInt16.self)
        }
        
        func decode(_: UInt32.Type) throws -> UInt32 {
            try self.decoder.unwrapFixedWidthInteger(from: value, as: UInt32.self)
        }
        
        func decode(_: UInt64.Type) throws -> UInt64 {
            try self.decoder.unwrapFixedWidthInteger(from: value, as: UInt64.self)
        }
        
        // MARK: - Floating point
        
        func decode(_ type: Double.Type) throws -> Double {
            guard case .float(let double) = value else {
                throw decoder.createTypeMismatchError(type: type, value: value)
            }
            return double
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            guard case .float(let double) = value else {
                throw decoder.createTypeMismatchError(type: type, value: value)
            }
            return Float(double)
        }
        
        // MARK: - String
        
        func decode(_ type: String.Type) throws -> String {
            guard case .string(let string) = value else {
                throw decoder.createTypeMismatchError(type: type, value: value)
            }
            return string
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
            try self.decoder.unwrap(as: type)
        }
    }
}
