//
//  Reset.swift
//  
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream

struct Reset: Equatable {
    
}

extension Reset: Request {
        
    static let allowedStates: [ServerState] = [.ready, .streaming, .txReady, .txStreaming, .failed, .interrupted]
    static let signature: Byte = 0x0F
    
    static func nextState(from currentState: ServerState, afterReceiving response: Response) -> ServerState {
        switch response.summary {
        case .success:
            return .ready
        case .failure, .ignored:
            return .defunct
        }
    }
    
    func encode(to container: inout any UnkeyedEncodingContainer) throws {
        
    }
}
