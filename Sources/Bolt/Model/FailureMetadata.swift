//
//  FailureMetadata.swift
//  
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream

struct FailureMetadata: Equatable, CustomStringConvertible, Decodable, Sendable {

    let code: String
    let message: String
    
    var description: String {
        "\(CodingKeys.code.stringValue): \(code), \(CodingKeys.message.stringValue): \(message)"
    }
}
