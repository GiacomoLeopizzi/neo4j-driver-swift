//
//  File.swift
//
//
//  Created by Giacomo Leopizzi on 11/11/23.
//

import Foundation

struct Version: Comparable, RawRepresentable, CustomStringConvertible, Sendable {
    
    static let zero = Version(major: 0, minor: 0)
    static let v5_4 = Version(major: 5, minor: 4)
    
    let major: UInt8
    let minor: UInt8
    
    static var size: Int {
        MemoryLayout<RawValue>.size
    }
    
    var rawValue: UInt32 {
        return UInt32(minor) << 8 | UInt32(major)
    }
    
    var description: String {
        "major: \(major), minor: \(minor)"
    }
    
    init(rawValue: UInt32) {
        self.major = UInt8(rawValue & 0xFF)
        self.minor = UInt8((rawValue >> 8) & 0xFF)
    }
    
    init(major: UInt8, minor: UInt8) {
        self.major = major
        self.minor = minor
    }
    
    static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major < rhs.major {
            return true
        } else if lhs.major == rhs.major {
            return lhs.minor < rhs.minor
        } else {
            return false
        }
    }
    
}
