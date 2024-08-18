//
//  PackStreamDecoder.swift
//  
//
//  Created by Giacomo Leopizzi on 26/06/24.
//

import NIOCore

extension ByteBuffer {
    
    /// Reads a PackStream value from the `ByteBuffer`.
    ///
    /// - Returns: The decoded `PackStreamValue`.
    /// - Throws: `PackStreamError` if decoding fails.
    public mutating func readPackStream() throws(PackStreamError) -> PackStreamValue {
        guard let firstByte = self.readByte() else {
            throw PackStreamError(.notEnoughBytes, location: .here())
        }
        switch firstByte {
        case Marker.null:
            return .null
        case Marker.booleanFalse:
            return .boolean(false)
        case Marker.booleanTrue:
            return .boolean(true)
        case _ where Marker.tinyInt.contains(Int8(bitPattern: firstByte)):
            return .integer(Int64(Int8(bitPattern: firstByte)))
        case Marker.int8:
            return try decodeInteger(Int8.self)
        case Marker.int16:
            return try decodeInteger(Int16.self)
        case Marker.int32:
            return try decodeInteger(Int32.self)
        case Marker.int64:
            return try decodeInteger(Int64.self)
        case Marker.float:
            return try decodeFloat()
        default:
            break
        }
        
        if let size = try CompositeMarker.bytes.size(for: firstByte, from: &self) {
            return try decodeBytes(size)
        } else if let size = try CompositeMarker.string.size(for: firstByte, from: &self) {
            return try decodeString(size)
        } else if let size = try CompositeMarker.list.size(for: firstByte, from: &self) {
            return try decodeList(size)
        } else if let size = try CompositeMarker.dictionary.size(for: firstByte, from: &self) {
            return try decodeDictionary(size)
        } else if let size = try CompositeMarker.structure.size(for: firstByte, from: &self) {
            return try decodeStructure(size)
        } else {
            throw PackStreamError(.unexpectedByteMarker, detail: "Marker \(firstByte) not recognized.", location: .here())
        }
    }
    
}

fileprivate extension ByteBuffer {
    
    @inline(__always)
    mutating func decodeInteger<T: FixedWidthInteger>(_: T.Type) throws(PackStreamError) -> PackStreamValue {
        guard let integer = self.readInteger(endianness: .big, as: T.self) else {
            throw PackStreamError(.notEnoughBytes, location: .here())
        }
        return .integer(Int64(integer))
    }
    
    @inline(__always)
    mutating func decodeFloat() throws(PackStreamError) -> PackStreamValue {
        guard let bitPattern = self.readInteger(endianness: .big, as: UInt64.self) else {
            throw PackStreamError(.notEnoughBytes, location: .here())
        }
        let value = Double(bitPattern: bitPattern)
        return .float(value)
    }
    
    @inline(__always)
    mutating func decodeBytes(_ size: Int) throws(PackStreamError) -> PackStreamValue {
        guard let data = self.readSlice(length: size) else {
            throw PackStreamError(.notEnoughBytes, location: .here())
        }
        return .bytes(data)
    }
    
    @inline(__always)
    mutating func decodeString(_ size: Int) throws(PackStreamError) -> PackStreamValue {
        guard let string = self.readString(length: size) else {
            throw PackStreamError(.notEnoughBytes, location: .here())
        }
        return .string(string)
    }
    
    @inline(__always)
    mutating func decodeList(_ size: Int) throws(PackStreamError) -> PackStreamValue {
        let elements = try (0..<size).map({ _  throws(PackStreamError) in
            return try self.readPackStream()
        })
        return .list(elements)
    }
    
    @inline(__always)
    mutating func decodeDictionary(_ size: Int) throws(PackStreamError) -> PackStreamValue {
        let elements = try (0..<size).map({ _  throws(PackStreamError) in
            let rawKey = try self.readPackStream()
            let key = try rawKey.requireString()
            let value = try self.readPackStream()
            return (key, value)
        })
        let dictionary = Dictionary(uniqueKeysWithValues: elements)
        return .dictionary(dictionary)
    }
    
    @inline(__always)
    mutating func decodeStructure(_ size: Int) throws(PackStreamError) -> PackStreamValue {
        guard let signature = self.readByte() else {
            throw PackStreamError(.notEnoughBytes, location: .here())
        }
        let fields = try (0..<size).map({ _  throws(PackStreamError) in
            return try self.readPackStream()
        })
        return .structure(signature: signature, fields: fields)
    }
    
}
