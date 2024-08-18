//
//  PackStreamValue.swift
//  
//
//  Created by Giacomo Leopizzi on 26/06/24.
//

import NIOCore

/// Enum to represent PackStream values.
public indirect enum PackStreamValue: Sendable, Hashable, Codable {
    
    public typealias RawList = [PackStreamValue]
    public typealias RawMap = [String : PackStreamValue]
    
    case null
    case boolean(Bool)
    case integer(Int64)
    case float(Double)
    case bytes(ByteBuffer)
    case string(String)
    case list(RawList)
    case dictionary(RawMap)
    case structure(signature: Byte, fields: RawList)
}

/// Extension for handling null values.
extension PackStreamValue {
    
    /// Check if the value is null.
    public var isNull: Bool {
        switch self {
        case .null: return true
        default: return false
        }
    }

    /// Ensure the value is null, otherwise throw an error.
    public func requireNull() throws(PackStreamError) {
        if !isNull {
            throw PackStreamError(.typeMismatch, detail: .expectation(expected: "null", found: self), location: .here())
        }
    }
}

/// Extension for handling boolean values.
extension PackStreamValue {
    
    /// Get the boolean value, if available.
    public var boolean: Bool? {
        switch self {
        case .boolean(let v): return v
        default: return nil
        }
    }

    /// Ensure the value is a boolean, otherwise throw an error.
    public func requireBoolean() throws(PackStreamError) -> Bool {
        return try boolean.unwrapped(onFailure: PackStreamError(.typeMismatch, detail: .expectation(expected: "boolean", found: self), location: .here()))
    }
}

/// Extension for handling integer values.
extension PackStreamValue {
    
    /// Get the integer value, if available.
    public var integer: Int64? {
        switch self {
        case .integer(let v): return v
        default: return nil
        }
    }

    /// Ensure the value is an integer, otherwise throw an error.
    public func requireInteger() throws(PackStreamError) -> Int64 {
        return try integer.unwrapped(onFailure: PackStreamError(.typeMismatch, detail: .expectation(expected: "integer", found: self), location: .here()))
    }
}

/// Extension for handling float values.
extension PackStreamValue {
    
    /// Get the float value, if available.
    public var float: Double? {
        switch self {
        case .float(let v): return v
        default: return nil
        }
    }

    /// Ensure the value is a float, otherwise throw an error.
    public func requireFloat() throws(PackStreamError) -> Double {
        return try float.unwrapped(onFailure: PackStreamError(.typeMismatch, detail: .expectation(expected: "float", found: self), location: .here()))
    }
}

/// Extension for handling bytes values.
extension PackStreamValue {
    
    /// Get the bytes value, if available.
    public var bytes: ByteBuffer? {
        switch self {
        case .bytes(let v): return v
        default: return nil
        }
    }

    /// Ensure the value is bytes, otherwise throw an error.
    public func requireBytes() throws(PackStreamError) -> ByteBuffer {
        return try bytes.unwrapped(onFailure: PackStreamError(.typeMismatch, detail: .expectation(expected: "bytes", found: self), location: .here()))
    }
}

/// Extension for handling string values.
extension PackStreamValue {
    
    /// Get the string value, if available.
    public var string: String? {
        switch self {
        case .string(let v): return v
        default: return nil
        }
    }

    /// Ensure the value is a string, otherwise throw an error.
    public func requireString() throws(PackStreamError) -> String {
        return try string.unwrapped(onFailure: PackStreamError(.typeMismatch, detail: .expectation(expected: "string", found: self), location: .here()))
    }
}

/// Extension for handling list values.
extension PackStreamValue {
    
    /// Get the list value, if available.
    public var list: [PackStreamValue]? {
        switch self {
        case .list(let v): return v
        default: return nil
        }
    }

    /// Ensure the value is a list, otherwise throw an error.
    public func requireList() throws(PackStreamError) -> [PackStreamValue] {
        return try list.unwrapped(onFailure: PackStreamError(.typeMismatch, detail: .expectation(expected: "list", found: self), location: .here()))
    }
}

/// Extension for handling dictionary values.
extension PackStreamValue {
    
    /// Get the dictionary value, if available.
    public var dictionary: [String: PackStreamValue]? {
        switch self {
        case .dictionary(let v): return v
        default: return nil
        }
    }

    /// Ensure the value is a dictionary, otherwise throw an error.
    public func requireDictionary() throws(PackStreamError) -> [String: PackStreamValue] {
        return try dictionary.unwrapped(onFailure: PackStreamError(.typeMismatch, detail: .expectation(expected: "dictionary", found: self), location: .here()))
    }
}

/// Extension for handling structure values.
extension PackStreamValue {
    
    /// Get the structure value, if available.
    public var structure: (signature: Byte, fields: [PackStreamValue])? {
        switch self {
        case .structure(let s, let f): return (s, f)
        default: return nil
        }
    }

    /// Ensure the value is a structure, otherwise throw an error.
    public func requireStructure() throws(PackStreamError) -> (signature: Byte, fields: [PackStreamValue]) {
        return try structure.unwrapped(onFailure: PackStreamError(.typeMismatch, detail: .expectation(expected: "structure", found: self), location: .here()))
    }
}

/// Extension for providing a custom description of PackStreamValue.
extension PackStreamValue: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .null:
            return "null"
        case .boolean(let bool):
            return "boolean:\(bool)"
        case .integer(let int64):
            return "integer:\(int64)"
        case .float(let double):
            return "float:\(double)"
        case .bytes(let byteBuffer):
            return "bytes:\(byteBuffer.readableBytes) bytes"
        case .string(let string):
            return "string:\(string)"
        case .list(let array):
            return "list:\(array)"
        case .dictionary(let dict):
            return "dictionary:\(dict)"
        case .structure(let signature, let fields):
            return "structure:\(signature):\(fields)"
        }
    }
}

/// Extension for ExpressibleByNilLiteral protocol.
extension PackStreamValue: ExpressibleByNilLiteral {
    
    public init(nilLiteral: ()) {
        self = .null
    }
}

/// Extension for ExpressibleByBooleanLiteral protocol.
extension PackStreamValue: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .boolean(value)
    }
}

/// Extension for ExpressibleByIntegerLiteral protocol.
extension PackStreamValue: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: Int64) {
        self = .integer(value)
    }
}

/// Extension for ExpressibleByFloatLiteral protocol.
extension PackStreamValue: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: Double) {
        self = .float(value)
    }
}

/// Extension for ExpressibleByStringLiteral protocol.
extension PackStreamValue: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

/// Extension for ExpressibleByArrayLiteral protocol.
extension PackStreamValue: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: PackStreamValue...) {
        self = .list(elements)
    }
}

/// Extension for ExpressibleByDictionaryLiteral protocol.
extension PackStreamValue: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, PackStreamValue)...) {
        self = .dictionary(Dictionary(uniqueKeysWithValues: elements))
    }
}
