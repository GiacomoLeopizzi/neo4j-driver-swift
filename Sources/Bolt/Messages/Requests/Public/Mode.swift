//
//  Mode.swift
//  
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream

public enum Mode: String, CaseIterable, Encodable, Sendable {
    case write = "w"
    case read = "r"
}
