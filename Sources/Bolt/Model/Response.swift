//
//  Response.swift
//  
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream

final class Response: CustomStringConvertible, Sendable {
    let records: [[PackStreamValue]]
    let summary: Summary
    
    var description: String {
        var strings: [String] = ["CompleteResponse. Summary: \(summary); Records: \(records.count)."]
        
        for (index, record) in records.enumerated() {
            strings.append("Index \(index): \(record)")
        }
        
        return strings.joined(separator: "\n")
    }
    
    init(records: [[PackStreamValue]], summary: Summary) {
        self.records = records
        self.summary = summary
    }
}
