//
//  BoltError.swift
//
//
//  Created by Giacomo Leopizzi on 04/07/24.
//

import PackStream

public struct BoltError: Error {
    
    enum Base: String {
        case generic = "Generic error."
        
        case connectionClosed = "The connection is closed."
        case notValidResponse = "The response sent from server is not valid."
        case forbidden = "The operation is forbidden in the current state."   
        
        case failed = "The server has reported a failure outcome."
        case ignored = "The server has ignored the request."
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
