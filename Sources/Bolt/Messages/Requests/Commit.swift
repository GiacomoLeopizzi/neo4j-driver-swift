//
//  Commit.swift
//  
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream
    
    struct Commit: Equatable {

    }

extension Commit: Request {
            
    static let signature: Byte = 0x12
    static let allowedStates: [ServerState] = [.txReady, .failed, .interrupted]
    
    static func nextState(from currentState: ServerState, afterReceiving response: Response) -> ServerState {
        switch (currentState, response.summary) {
        case (.txReady, .success):
            return .ready
        case (.txReady, .failure):
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
        
    }
}
