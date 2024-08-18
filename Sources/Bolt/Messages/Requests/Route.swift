//
//  Route.swift
//  
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream

/*
 routing::Dictionary,
 bookmarks::List<String>,
 db::String,
 extra::Dictionary(
   db::String,
   imp_user::String,
 )
 */

struct Route: Equatable {
    
    var routing: [String : PackStreamValue]
    var bookmarks: [String]
    var extra: RouteExtra
    
    init(routing: [String : PackStreamValue], bookmarks: [String], extra: RouteExtra) {
        self.routing = routing
        self.bookmarks = bookmarks
        self.extra = extra
    }
}

extension Route: Request {
        
    static let allowedStates: [ServerState] = [.ready, .failed]
    static let signature: Byte = 0x66
    
    static func nextState(from currentState: ServerState, afterReceiving response: Response) -> ServerState {
        switch (currentState, response.summary) {
        case (.ready, .success):
            return .ready
        case (.ready, .failure):
            return .failed
        case (.failed, .ignored):
            return .failed
        default:
            fatalError("Should not happen.")
        }
    }
    
    func encode(to container: inout any UnkeyedEncodingContainer) throws {
        try container.encode(routing)
        try container.encode(bookmarks)
        try container.encode(extra)
    }
}
