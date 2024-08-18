//
//  HelloExtra.swift
//  
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream

public struct HelloExtra: Equatable, Encodable, Sendable {
    
    fileprivate enum CodingKeys: String, CodingKey {
        case userAgent = "user_agent"
        case patchBolt = "patch_bolt"
        case routing
        case notificationsMinimumSeverity = "notifications_minimum_severity"
        case notificationsDisabledCategories = "notifications_disabled_categories"
        case boltAgent = "bolt_agent"
    }
    
    /// The user_agent should conform to "Name/Version" for example "Example/4.1.0" (see https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/User-Agent for more information).
    public var userAgent: String
    public var patchBolt: [String]
    public var routing: [String : String]?
    public var notificationsMinimumSeverity: String?
    public var notificationsDisabledCategories: [String]?
    public var boltAgent: BoltAgent
    
    public init(userAgent: String, patchBolt: [String] = [], routing: [String : String]? = nil, notificationsMinimumSeverity: String? = nil, notificationsDisabledCategories: [String]? = nil, boltAgent: BoltAgent = .current) {
        self.userAgent = userAgent
        self.patchBolt = patchBolt
        self.routing = routing
        self.notificationsMinimumSeverity = notificationsMinimumSeverity
        self.notificationsDisabledCategories = notificationsDisabledCategories
        self.boltAgent = boltAgent
    }
}
