//
//  Telemetry.swift
//  
//
//  Created by Giacomo Leopizzi on 06/07/24.
//

import PackStream

struct Telemetry: Equatable {

    var api: TelemetryAPI
    
    init(api: TelemetryAPI) {
        self.api = api
    }
}

extension Telemetry: Request {
        
    static let allowedStates: [ServerState] = [.ready]
    static let signature: Byte = 0x54
    
    static func nextState(from currentState: ServerState, afterReceiving response: Response) -> ServerState {
        switch response.summary {
        case .success:
            return .ready
        case .failure, .ignored:
            return .failed
        }
    }
    
    func encode(to container: inout any UnkeyedEncodingContainer) throws {
        try container.encode(api)
    }
}
