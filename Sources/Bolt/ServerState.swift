//
//  ServerState.swift
//
//
//  Created by Giacomo Leopizzi on 04/07/24.
//

public enum ServerState: Hashable, Sendable {
    /// No socket connection.
    case disconnected
    /// The socket connection is permanently closed.
    case defunct
    
    /// Protocol handshake is completed successfully; ready to accept a hello message.
    case negotiation
    ///  Hello or logoff message accepted; ready to accept a logon message.
    case authentication
    /// Ready to accept a run message.
    case ready
    /// Auto-commit transaction, a result is available for streaming from the server.
    case streaming
    /// Explicit transaction, ready to accept a run message.
    case txReady
    /// Explicit transaction, a result is available for streaming from the server.
    case txStreaming
    /// A connection is in a temporarily unusable state.
    case failed
    /// The server got an <interrupt> signal.
    case interrupted
}
