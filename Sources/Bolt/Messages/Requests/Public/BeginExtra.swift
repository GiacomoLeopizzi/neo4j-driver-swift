//
//  BeginExtra.swift
//
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream

public struct BeginExtra: Equatable, Encodable, Sendable {
    
    fileprivate enum CodingKeys: String, CodingKey {
        case bookmarks
        case txTimeout = "tx_timeout"
        case txMetadata = "tx_metadata"
        case mode
        case db
        case impUser = "imp_user"
        case notificationsMinimumSeverity = "notifications_minimum_severity"
        case notificationsDisabledCategories = "notifications_disabled_categories"
    }
    
    public static var none: BeginExtra { .init() }
    
    public var bookmarks: [String]
    public var txTimeout: Int64?
    public var txMetadata: [String : PackStreamValue]?
    public var mode: Mode?
    public var db: String?
    public var impUser: String?
    public var notificationsMinimumSeverity: String?
    public var notificationsDisabledCategories: [String]?
    
    public init(bookmarks: [String] = [], txTimeout: Int64? = nil, txMetadata: [String : PackStreamValue]? = nil, mode: Mode? = nil, db: String? = nil, impUser: String? = nil, notificationsMinimumSeverity: String? = nil, notificationsDisabledCategories: [String]? = nil) {
        self.bookmarks = bookmarks
        self.txTimeout = txTimeout
        self.txMetadata = txMetadata
        self.mode = mode
        self.db = db
        self.impUser = impUser
        self.notificationsMinimumSeverity = notificationsMinimumSeverity
        self.notificationsDisabledCategories = notificationsDisabledCategories
    }
}
