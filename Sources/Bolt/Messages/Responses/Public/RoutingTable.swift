//
//  RoutingTable.swift
//  
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream

public struct RoutingTable: Equatable, Decodable, Sendable {
    
    public struct Server: Equatable, Decodable, Sendable {
        
        public enum Role: String, Decodable, Equatable, Sendable {
            case route = "ROUTE"
            case read = "READ"
            case write = "WRITE"
        }
        
        public let addresses: [String]
        public let role: Role
    }
    
    public let ttl: Int64
    public let db: String
    public let servers: [Server]
}
