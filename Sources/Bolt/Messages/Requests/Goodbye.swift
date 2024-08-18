//
//  Goodbye.swift
//  
//
//  Created by Giacomo Leopizzi on 29/06/24.
//

import PackStream

struct Goodbye: Equatable {

}

extension Goodbye: Request {

    typealias SuccessResponse = Void
    
    static let signature: Byte = 0x02
    static let allowedStates: [ServerState] = [.ready, .streaming, .txReady, .txStreaming, .failed, .interrupted]
    
    static func nextState(from currentState: ServerState, afterReceiving response: Response) -> ServerState {
        return .defunct
    }
    
    func encode(to container: inout any UnkeyedEncodingContainer) throws {
        
    }
}
