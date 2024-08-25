//
//  BoltError.swift
//
//
//  Created by Giacomo Leopizzi on 04/07/24.
//

import Bolt

public struct Neo4JError: Error {
    
    enum Base: String {
        case generic = "Generic error."
        
        case invalidState = "Invalid state."
        case invalidConnectionURI = "Connection URI is not valid."
        case indexOutOfRange = "Index out of range."
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
