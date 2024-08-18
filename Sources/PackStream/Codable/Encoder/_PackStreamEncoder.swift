//
//  _PackStreamEncoder.swift
//  
//
//  Created by Giacomo Leopizzi on 08/07/24.
//

import NIOCore
#if canImport(NIOFoundationCompat)
import NIOFoundationCompat
#endif

extension CodingUserInfoKey {
    static let structureSignature: CodingUserInfoKey = CodingUserInfoKey(rawValue: "structureSignature")!
}


final class _PackStreamEncoder: Encoder {
    
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    
    var structureSignature: Byte? {
        userInfo[.structureSignature] as? Byte
    }
    
    var singleValue: PackStreamValue?
    var list: PackStreamFuture.RefList?
    var structure: (signature: Byte, fields: PackStreamFuture.RefList)?
    var dictionary: PackStreamFuture.RefDictionary?

    var value: PackStreamValue? {
        if let dictionary = self.dictionary {
            return .dictionary(dictionary.values)
        }
        if let array = self.list {
            return .list(array.values)
        }
        if let structure = self.structure {
            return .structure(signature: structure.signature, fields: structure.fields.values)
        }
        return self.singleValue
    }

    
    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        if let dictionary = dictionary {
            let container = KeyedContainer<Key>(encoder: self, codingPath: self.codingPath, object: dictionary)
            return KeyedEncodingContainer(container)
        }

        guard self.singleValue == nil, self.list == nil else {
            preconditionFailure()
        }

        let dictionary = PackStreamFuture.RefDictionary()
        self.dictionary = dictionary
        let container = KeyedContainer<Key>(encoder: self, codingPath: self.codingPath, object: dictionary)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        if let list = self.list {
            return UnkeyedContainer(encoder: self, object: list, codingPath: self.codingPath)
        }
        if let structure = self.structure {
            return UnkeyedContainer(encoder: self, object: structure.fields, codingPath: self.codingPath)
        }

        guard self.singleValue == nil, self.dictionary == nil else {
            preconditionFailure()
        }

        if let signature = self.structureSignature {
            let fields = PackStreamFuture.RefList()
            self.structure = (signature, fields)
            return UnkeyedContainer(encoder: self, object: fields, codingPath: self.codingPath)
        } else {
            let list = PackStreamFuture.RefList()
            self.list = list
            return UnkeyedContainer(encoder: self, object: list, codingPath: self.codingPath)
        }
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        guard self.dictionary == nil, self.list == nil else {
            preconditionFailure()
        }
        return SingleValueContainer(encoder: self, codingPath: self.codingPath)
    }
    
    func getEncoder(for additionalKey: CodingKey?) -> _PackStreamEncoder {
        if let additionalKey = additionalKey {
            var newCodingPath = self.codingPath
            newCodingPath.append(additionalKey)
            return _PackStreamEncoder(codingPath: newCodingPath, userInfo: [:])
        }

        return self
    }
    
    func wrapEncodable<E: Encodable>(_ encodable: E, for additionalKey: CodingKey?) throws -> PackStreamValue {
        if let value = encodable as? PackStreamValue {
            return value
        }
        if let buffer = encodable as? ByteBuffer {
            return .bytes(buffer)
        }
        #if canImport(NIOFoundationCompat)
        if let data = encodable as? Data {
            return .bytes(ByteBuffer(bytes: data))
        }
        #endif
        
        let encoder = self.getEncoder(for: additionalKey)
        
        if let e = E.self as? PackStreamStructure.Type {
            encoder.userInfo[.structureSignature] = e.signature
        }
        
        try encodable.encode(to: encoder)
        guard let value = encoder.value else {
            throw EncodingError.invalidValue(encodable, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(E.self) did not encode any values."))
        }
        return value
    }
}
