//
//  Begin.swift
//
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream

/*
 extra::Dictionary(
 bookmarks::List<String>,
 tx_timeout::Integer,
 tx_metadata::Dictionary,
 mode::String,
 db::String,
 imp_user::String,
 notifications_minimum_severity::String,
 notifications_disabled_categories::List<String>
 )
 */

struct Begin: Equatable {
    
    var extra: BeginExtra
    
    init(extra: BeginExtra) {
        self.extra = extra
    }
}

extension Begin: Request {
        
    static let signature: Byte = 0x11
    static let allowedStates: [ServerState] = [.ready, .failed, .interrupted]
    
    static func nextState(from currentState: ServerState, afterReceiving response: Response) -> ServerState {        
        switch (currentState, response.summary) {
        case (.ready, .success):
            return .txReady
        case (.ready, .failure):
            return .failed
        case (.failed, .ignored):
            return .failed
        case (.interrupted, .ignored):
            return .interrupted
        default:
            fatalError("Should not happen.")
        }
    }
    
    func encode(to container: inout any UnkeyedEncodingContainer) throws {
        try container.encode(extra)
    }
}

