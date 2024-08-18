//
//  Logon.swift
//  
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream

/*
 auth::Dictionary(
   scheme::String,
   ...
 )
 */

struct Logon: Equatable {
        
    var auth: Auth
    
    init(auth: Auth) {
        self.auth = auth
    }
}

extension Logon: Request {
    
    static let signature: Byte = 0x6A
    static let allowedStates: [ServerState] = [.authentication]
    
    static func nextState(from currentState: ServerState, afterReceiving response: Response) -> ServerState {
        switch response.summary {
        case .success:
            return .ready
        case .failure, .ignored:
            return .defunct
        }
    }
    
    func encode(to container: inout any UnkeyedEncodingContainer) throws {
        try container.encode(auth)
    }
}

