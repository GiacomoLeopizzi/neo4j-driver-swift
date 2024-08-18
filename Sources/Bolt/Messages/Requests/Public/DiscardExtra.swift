//
//  DiscardExtra.swift
//
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream

public struct DiscardExtra: Equatable, Encodable, Sendable {
    
    var n: Amount
    var qid: Int64?
    
    public init(n: Amount, qid: Int64? = nil) {
        self.n = n
        self.qid = qid
    }
}

extension DiscardExtra {
    
    public enum Amount: RawRepresentable, Encodable, Equatable, ExpressibleByIntegerLiteral, Sendable {
        case custom(Int64)
        
        public static let all = Amount(rawValue: -1)
        
        public var rawValue: Int64 {
            switch self {
            case .custom(let amount): return amount
            }
        }
        
        public init(rawValue: Int64) {
            self = .custom(rawValue)
        }
        
        public init(integerLiteral value: Int64) {
            self = .custom(value)
        }
        
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }
    }
    
}
