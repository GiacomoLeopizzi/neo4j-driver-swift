//
//  _PackStreamDecoder.swift
//
//
//  Created by Giacomo Leopizzi on 08/07/24.
//

import NIOCore
#if canImport(NIOFoundationCompat)
import NIOFoundationCompat
#endif

final class _PackStreamDecoder: Decoder {
    
    let value: PackStreamValue
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    var structureSignature: Byte? {
        value.structure?.signature
    }
    
    init(value: PackStreamValue, codingPath: [CodingKey]) {
        self.value = value
        self.codingPath = codingPath
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        guard case .dictionary(let dict) = value else {
            throw DecodingError.typeMismatch([String : PackStreamValue].self, .init(codingPath: codingPath, debugDescription: "Expected a dictionary"))
        }
        let container = KeyedContainer<Key>(decoder: self, codingPath: codingPath, dictionary: dict)
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        switch value {
        case .structure(signature: _, fields: let fields):
            return UnkeyedContainer(decoder: self, array: fields)
        case .list(let array):
            return UnkeyedContainer(decoder: self, array: array)
        default:
            // Unable to create a container.
            throw DecodingError.typeMismatch(PackStreamValue.self, .init(codingPath: self.codingPath, debugDescription: "Exepected the PackStreamValue to be a list or structure."))
        }
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueContainer(decoder: self, value: value)
    }
}

extension _PackStreamDecoder {
    
    func createTypeMismatchError(type: Any.Type, for additionalKey: CodingKey? = nil, value: PackStreamValue) -> DecodingError {
        var path = self.codingPath
        if let additionalKey = additionalKey {
            path.append(additionalKey)
        }
        
        return .typeMismatch(type, .init(codingPath: path, debugDescription: "Expected to decode \(type) but found \(value.description) instead."))
    }
    
    func createDataCorreuptedError(for additionalKey: CodingKey? = nil, value: PackStreamValue) -> DecodingError {
        var path = self.codingPath
        if let additionalKey = additionalKey {
            path.append(additionalKey)
        }
        
        return .dataCorrupted(.init(codingPath: path, debugDescription: "Value \(value) is not valid."))
    }
}

extension _PackStreamDecoder {
    
    func unwrapFixedWidthInteger<T: FixedWidthInteger>(from value: PackStreamValue, for additionalKey: CodingKey? = nil, as type: T.Type) throws -> T {
        guard case .integer(let integer) = value else {
            throw self.createTypeMismatchError(type: T.self, for: additionalKey, value: value)
        }
        guard integer <= T.max else {
            var path = self.codingPath
            if let additionalKey = additionalKey {
                path.append(additionalKey)
            }
            throw DecodingError.dataCorrupted(.init(codingPath: path, debugDescription: "Parsed number is too large."))
        }
        return T(integer)
    }
    
    func unwrapByteBuffer() throws -> ByteBuffer {
        guard case .bytes(let buffer) = value else {
            throw DecodingError.typeMismatch(ByteBuffer.self, .init(codingPath: codingPath, debugDescription: "The type is not bytes."))
        }
        return buffer
    }
    
    #if canImport(NIOFoundationCompat)
    func unwrapData() throws -> Data {
        guard case .bytes(let buffer) = value else {
            throw DecodingError.typeMismatch(Data.self, .init(codingPath: codingPath, debugDescription: "The type is not bytes."))
        }
        return Data(buffer: buffer)
    }
    #endif
    
    func unwrap<T: Decodable>(as type: T.Type) throws -> T {
        if type == PackStreamValue.self {
            return value as! T
        }
        if type == ByteBuffer.self {
            return try unwrapByteBuffer() as! T
        }
        #if canImport(NIOFoundationCompat)
        if type == Data.self {
            return try unwrapData() as! T
        }
        #endif
        if let type = type.self as? PackStreamStructure.Type, type.signature != self.structureSignature {
            throw DecodingError.dataCorrupted(.init(codingPath: codingPath, debugDescription: "The structure signature does not match. Expected decoding \(type.signature), but found \(value) instead"))
        }
        return try T(from: self)
    }
    
}
