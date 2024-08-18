//
//  Pull.swift
//
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream

struct Pull: Equatable {
        
    var extra: PullExtra
    
    init(extra: PullExtra) {
        self.extra = extra
    }
}

extension Pull: Request {
    
    typealias SuccessResponse = ([[PackStreamValue]], SuccessMetadata)
    
    static let allowedStates: [ServerState] = [.streaming, .txStreaming, .failed, .interrupted]
    static let signature: Byte = 0x3F
    
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
            fatalError("Should not happen")
        }
    }
    
    func encode(to container: inout any UnkeyedEncodingContainer) throws {
        try container.encode(extra)
    }
}
