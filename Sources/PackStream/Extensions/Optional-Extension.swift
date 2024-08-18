//
//  Optional-Extension.swift
//  
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

extension Optional {
    
    /// Unwraps the optional value or throws an error if the optional is `nil`.
    ///
    /// - Parameters:
    ///   - error: An autoclosure that returns an error to throw if the optional is `nil`.
    /// - Returns: The unwrapped value if the optional is not `nil`.
    /// - Throws: The error returned by the autoclosure if the optional is `nil`.
    public func unwrapped<E: Error>(onFailure error: @autoclosure () -> E) throws(E) -> Wrapped {
        switch self {
        case .none:
            throw error()
        case .some(let wrapped):
            return wrapped
        }
    }
}
