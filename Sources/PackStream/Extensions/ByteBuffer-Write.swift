//
//  PackStreamEncoder.swift
//
//
//  Created by Giacomo Leopizzi on 26/06/24.
//

import NIOCore

extension ByteBuffer {
    
    /// Writes a PackStream value to the `ByteBuffer`.
    ///
    /// - Parameter value: The `PackStreamValue` to write.
    /// - Throws: `PackStreamError` if encoding fails.
    public mutating func writePackStream(_ value: PackStreamValue) throws(PackStreamError) {
        switch value {
        case .null:
            encodeNull()
        case .boolean(let bool):
            encodeBool(bool)
        case .integer(let int64):
            encodeInteger(int64)
        case .float(let double):
            encodeFloat(double)
        case .bytes(let byteBuffer):
            try encodeBytes(byteBuffer)
        case .string(let string):
            try encodeString(string)
        case .list(let array):
            try encodeList(array)
        case .dictionary(let dictionary):
            try encodeDictionary(dictionary)
        case .structure(let tag, let items):
            try encodeStructure(tag: tag, items: items)
        }
    }
    
}

fileprivate extension ByteBuffer {
    
    @inline(__always)
    mutating func encodeNull() {
        writeByte(Marker.null)
    }
    
    @inline(__always)
    mutating func encodeBool(_ value: Bool) {
        writeByte(value ? Marker.booleanTrue : Marker.booleanFalse)
    }
    
    @inline(__always)
    mutating func encodeInteger(_ value: Int64) {
        switch value {
        case -16...127:
            writeInteger(Int8(value), endianness: .big)
            
        case Int64(Int8.min)...Int64(Int8.max):
            writeByte(Marker.int8)
            writeInteger(Int8(value), endianness: .big)
            
        case Int64(Int16.min)...Int64(Int16.max):
            writeByte(Marker.int16)
            writeInteger(Int16(value), endianness: .big)
            
        case Int64(Int32.min)...Int64(Int32.max):
           writeByte(Marker.int32)
           writeInteger(Int32(value), endianness: .big)
            
        default:
           writeByte(Marker.int64)
           writeInteger(Int64(value), endianness: .big)
        }
    }
    
    @inline(__always)
    mutating func encodeFloat(_ value: Double) {
       writeByte(Marker.float)
       writeInteger(value.bitPattern, endianness: .big)
    }
    
    @inline(__always)
    mutating func encodeBytes(_ value: ByteBuffer) throws(PackStreamError) {
        try CompositeMarker.bytes.writeHeader(for: value.readableBytes, to: &self)
        writeImmutableBuffer(value)
    }
    
    @inline(__always)
    mutating func encodeString(_ value: String) throws(PackStreamError) {
        try CompositeMarker.string.writeHeader(for: value.utf8.count, to: &self)
        writeString(value)
    }
    
    @inline(__always)
    mutating func encodeList(_ value: [PackStreamValue]) throws(PackStreamError) {
        try CompositeMarker.list.writeHeader(for: value.count, to: &self)
        for item in value {
            try writePackStream(item)
        }
    }
    
    @inline(__always)
    mutating func encodeDictionary(_ value: [String : PackStreamValue]) throws(PackStreamError) {
        try CompositeMarker.dictionary.writeHeader(for: value.count, to: &self)
        for (key, item) in value {
            try writePackStream(.string(key))
            try writePackStream(item)
        }
    }
    
    @inline(__always)
    mutating func encodeStructure(tag: Byte, items: [PackStreamValue]) throws(PackStreamError) {
        try CompositeMarker.structure.writeHeader(for: items.count, to: &self)
        writeByte(tag)
        for item in items {
            try writePackStream(item)
        }
    }
}
