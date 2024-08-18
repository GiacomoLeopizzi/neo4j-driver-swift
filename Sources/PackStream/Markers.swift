//
//  CompositeMarker.swift
//
//
//  Created by Giacomo Leopizzi on 26/06/24.
//

import NIOCore

struct Marker {
    static let null: Byte = 0xC0
    
    static let booleanFalse: Byte = 0xC2
    static let booleanTrue: Byte  = 0xC3
    
    static let tinyInt: CountableClosedRange<Int8> = Int8(bitPattern: 0xF0)...Int8(bitPattern: 0x7F)
    static let int8: Byte = 0xC8
    static let int16: Byte = 0xC9
    static let int32: Byte = 0xCA
    static let int64: Byte = 0xCB
    
    static let float: Byte = 0xC1
}

struct CompositeMarker {
    
    static let bytes = CompositeMarker(long: (0xCC, 0xCD,0xCE))
    static let string = CompositeMarker(compact: (0x80...0x8F), long: (0xD0, 0xD1, 0xD2))
    static let list = CompositeMarker(compact: (0x90...0x9F), long: (0xD4, 0xD5, 0xD6))
    static let dictionary = CompositeMarker(compact: (0xA0...0xAF), long: (0xD8, 0xD9, 0xDA))
    static let structure = CompositeMarker(compact: (0xB0...0xBF))
    
    var compact: CountableClosedRange<Byte>?
    var long: (bit8: Byte, bit16: Byte, bit32: Byte)?
    
    /// Determines the size indicated by a marker within a ByteBuffer.
    ///
    /// - Parameters:
    ///   - marker: The marker byte to examine.
    ///   - buffer: The ByteBuffer containing the marker.
    /// - Returns: The size inferred from the marker, if applicable.
    /// - Throws: `PackStreamError` if an error occurs during reading.
    func size(for marker:  Byte, from buffer: inout ByteBuffer) throws(PackStreamError) -> Int? {
        if let compact = self.compact, compact.contains(marker) {
            return Int(marker - compact.lowerBound)
        }
        guard let long = self.long else {
            return nil
        }
        switch marker {
        case long.bit8:
            let integer = try buffer.readInteger(endianness: .big, as: UInt8.self).unwrapped(onFailure: PackStreamError(.notEnoughBytes, location: .here()))
            return Int(integer)
        case long.bit16:
            let integer = try buffer.readInteger(endianness: .big, as: UInt16.self).unwrapped(onFailure: PackStreamError(.notEnoughBytes, location: .here()))
            return Int(integer)
        case long.bit32:
            let integer = try buffer.readInteger(endianness: .big, as: UInt32.self).unwrapped(onFailure: PackStreamError(.notEnoughBytes, location: .here()))
            guard integer <= Int32.max else {
                throw PackStreamError(.outOfBoundary, location: .here())
            }
            return Int(integer)
        default:
            return nil
        }
    }
    
    /// Writes a header with the specified count to a ByteBuffer.
    ///
    /// - Parameters:
    ///   - count: The count to encode in the header.
    ///   - buffer: The ByteBuffer to write into.
    /// - Throws: `PackStreamError` if an error occurs during writing.
    func writeHeader(for count: Int, to buffer: inout ByteBuffer) throws(PackStreamError) {
        // Compact
        if let compact = self.compact, count <= 15 {
            let marker = compact.lowerBound + Byte(count)
            buffer.writeByte(marker)
            return
        }
        guard let long = self.long else {
            throw PackStreamError(.notPackable, location: .here())
        }
        
        switch count {
        case 0...Int(Int8.max):
            buffer.writeByte(long.bit8)
            buffer.writeInteger(UInt8(count), endianness: .big)
        case 0...Int(Int16.max):
            buffer.writeByte(long.bit16)
            buffer.writeInteger(UInt16(count), endianness: .big)
        case 0...Int(Int32.max):
            buffer.writeByte(long.bit32)
            buffer.writeInteger(UInt32(count), endianness: .big)
        default:
            throw PackStreamError(.notPackable, detail: "Too big to be parsed.", location: .here())
        }
    }
    
}
