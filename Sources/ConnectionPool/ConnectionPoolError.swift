//
//  ConnectionPoolError.swift
//  neo4j-driver-swift
//
//  Created by Giacomo Leopizzi on 02/09/24.
//

public struct ConnectionPoolError: Error {
    
    // TEMP
    public struct ErrorLocation: Sendable {
        
        public var function: StaticString
        public var file: StaticString
        public var line: Int
        
        public init(function: StaticString, file: StaticString, line: Int) {
            self.function = function
            self.file = file
            self.line = line
        }
        
        public static func here(function: StaticString = #function, file: StaticString = #fileID, line: Int = #line) -> ErrorLocation {
            return ErrorLocation(function: function, file: file, line: line)
        }
    }
    
    enum Base: String {        
        case invalidState = "Invalid state."
        case timeout = "Timeout."
    }
    
    let base: Base
    let detail: String?
    
    // The location where the error occurred.
    let location: ErrorLocation
    
    /// A full error description.
    public var errorDescription: String? {
        return [base.rawValue, detail, "at \(self.location.file):\(self.location.line)"].compactMap { $0 }.joined(separator: " ")
    }
    
    init(_ base: Base, detail: String? = nil, location: ErrorLocation) {
        self.base = base
        self.detail = detail
        self.location = location
    }
    
}
