//
//  Hints.swift
//  
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream

public struct Hints: Equatable, Decodable, Sendable {
    
    fileprivate enum CodingKeys: String, CodingKey {
        case telemetryEnabled = "telemetry.enabled"
        case connectionRecvTimeoutSeconds = "connection.recv_timeout_seconds"
    }
    
    public let telemetryEnabled: Bool?
    public let connectionRecvTimeoutSeconds: Int64?
}

extension Hints: CustomStringConvertible {
    
    public var description: String {
        var description = [String]()

        if let telemetryEnabled = telemetryEnabled {
            description.append("\(CodingKeys.telemetryEnabled.rawValue): \(telemetryEnabled)")
        }
        if let connectionRecvTimeoutSeconds = connectionRecvTimeoutSeconds {
            description.append("\(CodingKeys.connectionRecvTimeoutSeconds.rawValue): \(connectionRecvTimeoutSeconds)")
        }

        return description.joined(separator: ", ")
    }
    
}
