//
//  Auth.swift
//  
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream

public enum Auth: Sendable {
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
    
    public static func basic(username: String, password: String) -> Auth {
        return .custom(scheme: SchemeNames.basic, additionalParameters: [
            Constants.principal.rawValue : .string(username),
            Constants.credentials.rawValue : .string(password)
        ])
    }
    
    public static func bearer(token: String) -> Auth {
        return .custom(scheme: SchemeNames.bearer, additionalParameters: [
            Constants.credentials.rawValue : .string(token)
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
