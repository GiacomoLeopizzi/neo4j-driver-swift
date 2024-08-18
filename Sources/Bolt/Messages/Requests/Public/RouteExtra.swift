//
//  RouteExtra.swift
//  
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream

public struct RouteExtra: Equatable, Encodable, Sendable {
    
    fileprivate enum CodingKeys: String, CodingKey {
        case db
        case impUser = "imp_user"
    }
    
    public static var none: RouteExtra { .init() }
    
    public var db: String?
    public var impUser: String?
    
    public init(db: String? = nil, impUser: String? = nil) {
        self.db = db
        self.impUser = impUser
    }
}
