//
//  TelemetryAPI.swift
//  
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream

public enum TelemetryAPI: Int64, Encodable, Sendable {
    case managedTransaction = 0
    case explicitTransaction = 1
    case implicitTransaction = 2
    case driverLevel = 3
}
