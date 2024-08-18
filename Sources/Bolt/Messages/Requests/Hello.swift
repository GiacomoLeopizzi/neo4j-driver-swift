//
//  Hello.swift
//  
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream

/*
 extra::Dictionary(
   auth::Dictionary(
     scheme::String,
     ...
   )
   user_agent::String,
   patch_bolt::List<String>,
   routing::Dictionary(address::String),
   notifications_minimum_severity::String,
   notifications_disabled_categories::List<String>,
   bolt_agent::Dictionary(
     product::String,
     platform::String,
     language::String,
     language_details::String
   )
 )
 */

struct Hello: Equatable {

    var extra: HelloExtra
    
    init(extra: HelloExtra) {
        self.extra = extra
    }
}

extension Hello: Request {
        
    static let signature: Byte = 0x01
    static let allowedStates: [ServerState] = [.negotiation]
    
    static func nextState(from currentState: ServerState, afterReceiving response: Response) -> ServerState {
        switch response.summary {
        case .success:
            return .authentication
        case .failure, .ignored:
            return .defunct
        }
    }
    
    func encode(to container: inout any UnkeyedEncodingContainer) throws {
        try container.encode(extra)
    }
}

