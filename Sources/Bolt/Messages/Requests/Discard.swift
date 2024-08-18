//
//  Discard.swift
//  
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream
    
    struct Discard: Equatable {
        
        var extra: DiscardExtra
        
        init(extra: DiscardExtra) {
            self.extra = extra
        }
    }

extension Discard: Request {
    
    static let signature: Byte = 0x2F
    static let allowedStates: [ServerState] = [.streaming, .txStreaming, .failed, .interrupted]

    static func nextState(from currentState: ServerState, afterReceiving response: Response) -> ServerState {        
        switch (currentState, response.summary) {
        case (.streaming, .success(metadata: let metadata)) where metadata.hasMore == true:
            return .streaming
        case (.streaming, .success):
            return .ready
        case (.streaming, .failure):
            return .failed
        case (.txStreaming, .success(metadata: let metadata)) where metadata.hasMore == true:
            return .txStreaming
        case (.txStreaming, .success):
            return .txReady
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
        try container.encode(extra)
    }
}

