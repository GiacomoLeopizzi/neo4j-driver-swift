//
//  TransactionConnection.swift
//
//
//  Created by Giacomo Leopizzi on 09/07/24.
//

import Bolt

public protocol TransactionConnection: AnyObject {
    
    var serverState: ServerState { get async }
    var underlyingConnection: BoltConnection { get async }
    
    func run<each T: Decodable>(query: String, parameters: [String : any Encodable & Sendable], extra: RunExtra, decodingResultsAs types: (repeat each T).Type) async throws -> [(repeat each T)]
    func run(query: String, parameters: [String : any Encodable & Sendable], extra: RunExtra) async throws -> SuccessMetadata
}

// Should not require any changes as it represent a subset of the connection itself.
extension Neo4JConnection: TransactionConnection { }
