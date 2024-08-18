//
//  Run.swift
//  
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream

/*
 query::String,
 parameters::Dictionary,
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

struct Run: Equatable {
    
    var query: String
    var parameters: [String : PackStreamValue]
    var extra: RunExtra?
    
    init(query: String, parameters: [String : PackStreamValue], extra: RunExtra? = nil) {
        self.query = query
        self.parameters = parameters
        self.extra = extra
    }
}

extension Run: Request {
        
    static let allowedStates: [ServerState] = [.ready, .txReady, .txStreaming, .failed, .interrupted]
    static let signature: Byte = 0x10
    
    static func nextState(from currentState: ServerState, afterReceiving response: Response) -> ServerState {        
        switch (currentState, response.summary) {
        case (.ready, .success):
            return .streaming
        case (.ready, .failure):
            return .failed
        case (.txReady, .success(metadata: let metadata)) where metadata.qid != nil:
            return .txStreaming
        case (.txReady, .failure):
            return .failed
        case (.txStreaming, .success(metadata: let metadata)) where metadata.qid != nil:
            return .txStreaming
        case (.txStreaming, .failure):
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
        try container.encode(query)
        try container.encode(parameters)
        try container.encode(extra)
    }
}
