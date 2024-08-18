//
//  SuccessMetadata.swift
//
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream

public struct SuccessMetadata: Equatable, Decodable, Sendable {
    
    fileprivate enum CodingKeys: String, CodingKey {
        case server
        case connectionID = "connection_id"
        case hints
        case fields
        case tFirst = "t_first"
        case qid
        case hasMore = "has_more"
        case bookmark
        case db
        case notifications
        case plan
        case profile
        case stats
        case tLast = "t_last"
        case type
        case rt
    }
    
    
    public enum StatementType: String, Decodable, Equatable, Sendable {
        case readOnly = "r"
        case writeOnly = "w"
        case readAndWrite = "rw"
        case schema = "s"
    }
    
    public let server: String?
    public let connectionID: String?
    public let hints: Hints?
    
    public let fields: [String]?
    public let tFirst: Int64?
    public let qid: Int64?
    
    public let hasMore: Bool?
    
    public let bookmark: String?
    public let db: String?
    public let notifications: [[String : PackStreamValue]]?
    public let plan: [String : PackStreamValue]?
    public let profile: [String : PackStreamValue]?
    public let stats: Stats?
    public let tLast: Int64?
    public let type: StatementType?
     
    public let rt: RoutingTable?
}

extension SuccessMetadata: CustomStringConvertible {
    
    public var description: String {
        var description = [String]()

        if let server = server {
            description.append("\(CodingKeys.server.rawValue): \(server)")
        }
        if let connectionID = connectionID {
            description.append("\(CodingKeys.connectionID.rawValue): \(connectionID)")
        }
        if let hints = hints {
            description.append("\(CodingKeys.hints.rawValue): \(hints)")
        }
        if let fields = fields {
            description.append("\(CodingKeys.fields.rawValue): \(fields)")
        }
        if let tFirst = tFirst {
            description.append("\(CodingKeys.tFirst.rawValue): \(tFirst)")
        }
        if let qid = qid {
            description.append("\(CodingKeys.qid.rawValue): \(qid)")
        }
        if let hasMore = hasMore {
            description.append("\(CodingKeys.hasMore.rawValue): \(hasMore)")
        }
        if let bookmark = bookmark {
            description.append("\(CodingKeys.bookmark.rawValue): \(bookmark)")
        }
        if let db = db {
            description.append("\(CodingKeys.db.rawValue): \(db)")
        }
        if let notifications = notifications {
            description.append("\(CodingKeys.notifications.rawValue): \(notifications)")
        }
        if let plan = plan {
            description.append("\(CodingKeys.plan.rawValue): \(plan)")
        }
        if let profile = profile {
            description.append("\(CodingKeys.profile.rawValue): \(profile)")
        }
        if let stats = stats {
            description.append("\(CodingKeys.stats.rawValue): \(stats)")
        }
        if let tLast = tLast {
            description.append("\(CodingKeys.tLast.rawValue): \(tLast)")
        }
        if let type = type {
            description.append("\(CodingKeys.type.rawValue): \(type.rawValue)")
        }
        if let rt = rt {
            description.append("\(CodingKeys.rt.rawValue): \(rt)")
        }

        return description.joined(separator: ", ")
    }
}
