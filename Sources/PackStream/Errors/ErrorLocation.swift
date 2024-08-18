//
//  ErrorLocation.swift
//  
//
//  Created by Giacomo Leopizzi on 04/07/24.
//

/// Represents the location  where an error occurred.
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
