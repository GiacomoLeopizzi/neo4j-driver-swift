//
//  Summary.swift
//  
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream

enum Summary: Sendable {
    case success(metadata: SuccessMetadata)
    case failure(metadata: FailureMetadata)
    case ignored
}
