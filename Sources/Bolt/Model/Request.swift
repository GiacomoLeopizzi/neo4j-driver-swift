//
//  Operation.swift
//
//
//  Created by Giacomo Leopizzi on 06/07/24.
//

import PackStream

protocol Request: StructureEncodable, Sendable {
    
    associatedtype SuccessResponse = SuccessMetadata
    
    static var allowedStates: [ServerState] { get }
    
    static func convert(response: Response) throws(BoltError) -> SuccessResponse
    static func nextState(from currentState: ServerState, afterReceiving response: Response) -> ServerState
}

extension Request {
        
    public static func isAllowed(for state: ServerState) -> Bool {
        return Self.allowedStates.contains(state)
    }
}

extension Request where SuccessResponse == SuccessMetadata {
    
    @inlinable
    static func convert(response: Response) throws(BoltError) -> SuccessResponse {
        switch response.summary {
        case .success(let metadata):
            return metadata
        case .failure(let metadata):
            throw BoltError(.failed, detail: metadata.description, location: .here())
        case .ignored:
            throw BoltError(.ignored, location: .here())
        }
    }
}

extension Request where SuccessResponse == ([[PackStreamValue]], SuccessMetadata) {
    
    @inlinable
    static func convert(response: Response) throws(BoltError) -> SuccessResponse {
        switch response.summary {
        case .success(let metadata):
            return (response.records, metadata)
        case .failure(let metadata):
            throw BoltError(.failed, detail: metadata.description, location: .here())
        case .ignored:
            throw BoltError(.ignored, location: .here())
        }
    }
}

extension Request where SuccessResponse == Void {
    
    @inlinable
    static func convert(response: Response) throws(BoltError) -> SuccessResponse {
        switch response.summary {
        case .success:
            return
        case .failure(let metadata):
            throw BoltError(.failed, detail: metadata.description, location: .here())
        case .ignored:
            throw BoltError(.ignored, location: .here())
        }
    }
}
