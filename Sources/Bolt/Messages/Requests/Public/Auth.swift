//
//  Auth.swift
//
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream

/// An enumeration representing different authentication schemes that can be used when connecting to Neo4j.
public enum Auth: Sendable {
    /// A custom authentication scheme with a specified scheme name and additional parameters.
    case custom(scheme: String, additionalParameters: [String : PackStreamValue])
}

extension Auth {
    
    fileprivate struct SchemeNames {
        static let basic = "basic"
        static let bearer = "bearer"
    }
    
    fileprivate enum Constants: String {
        case scheme
        case principal
        case credentials
    }
    
    /// A static property that returns the default username for authentication, which is "neo4j".
    public static var defaultUsername: String {
        "neo4j"
    }
    
    /// A  method to create a basic authentication scheme with the given username and password.
    ///
    /// - Parameters:
    ///   - username: The username for basic authentication. Defaults to "neo4j" if not provided.
    ///   - password: The password associated with the username.
    /// - Returns: An `Auth` instance configured for basic authentication.
    public static func basic(username: String = defaultUsername, password: String) -> Auth {
        return .custom(scheme: SchemeNames.basic, additionalParameters: [
            Constants.principal.rawValue : .string(username),       // The principal (username) parameter.
            Constants.credentials.rawValue : .string(password)      // The credentials (password) parameter.
        ])
    }
    
    /// A  method to create a bearer token authentication scheme with the given token.
    ///
    /// - Parameter token: The bearer token used for authentication.
    /// - Returns: An `Auth` instance configured for bearer token authentication.
    public static func bearer(token: String) -> Auth {
        return .custom(scheme: SchemeNames.bearer, additionalParameters: [
            Constants.credentials.rawValue : .string(token) // The credentials (token) parameter.
        ])
    }
}

extension Auth: Equatable, Encodable {
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .custom(let scheme, var additionalParameters):
            additionalParameters[Constants.scheme.rawValue] = .string(scheme)
            try container.encode(additionalParameters)
        }
    }
}
