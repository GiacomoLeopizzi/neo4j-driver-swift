//
//  PackStreamError.swift
//
//
//  Created by Giacomo Leopizzi on 26/06/24.
//

/// Represents errors that occur during PackStream operations.
public struct PackStreamError: Error {
    
    /// Base types of PackStream errors.
    enum Base: String {
        case generic = "Generic error."
        case notPackable = "The value cannot be packed."
        case notEnoughBytes = "Not enough bytes to proceed."
        case incorrectValue = "The value is incorrect."
        case unexpectedByteMarker = "The byte marker is unrecognized."
        case incorrectNumberOfFields = "The number of fields is incorrect."
        case typeMismatch = "Incorrect type."
        case signatureMismatch = "The PackStream signature has the wrong tag byte."
        case outOfBoundary = "Out of boundary."
        case unsupportedType = "The type is unsupported."
        
        
        
        case connectionClosed = "The connection has been closed."
        case external = "An error occurred outside the PackStream library."
    }
    
    /// Detail types providing specific information about PackStream errors.
    enum Detail: CustomStringConvertible, Sendable {
        case custom(String)
        case expectation(expected: CustomStringConvertible & Sendable, found: CustomStringConvertible & Sendable)
        
        var description: String {
            switch self {
            case .custom(let string): return string
            case .expectation(let expected, let found): return "Expected \(expected), found \(found)."
            }
        }
    }
    
    /// The base type of the error.
    private let base: Base
    
    /// Additional detail describing the error.
    private let detail: Detail?
    
    /// The location where the error occurred.
    public let location: ErrorLocation
    
    /// A full error description.
    public var errorDescription: String? {
        return [base.rawValue, detail?.description, "at \(self.location.file):\(self.location.line)"].compactMap { $0 }.joined(separator: " ")
    }
    
    init(_ base: Base, detail: Detail? = nil, location: ErrorLocation) {
        self.base = base
        self.detail = detail
        self.location = location
    }

    init(_ base: Base, detail: String, location: ErrorLocation) {
        self.init(base, detail: .custom(detail), location: location)
    }
    
    public static func external(error: Error, location: ErrorLocation) -> PackStreamError {
        return PackStreamError(.external, detail: error.localizedDescription, location: location)
    }
}
