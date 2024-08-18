//
//  Logoff.swift
//  
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream

struct Logoff: Equatable {

}

extension Logoff: Request {
        
    static let signature: Byte = 0x6B
    static let allowedStates: [ServerState] = [.ready, .failed]
    
    static func nextState(from currentState: ServerState, afterReceiving response: Response) -> ServerState {        
        switch response.summary {
        case .success:
            return .authentication
        case .failure, .ignored:
            return .defunct
        }
    }
    
    func encode(to container: inout any UnkeyedEncodingContainer) throws {
        
    }
}
