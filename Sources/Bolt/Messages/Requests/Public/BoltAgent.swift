//
//  BoltAgent.swift
//  
//
//  Created by Giacomo Leopizzi on 07/07/24.
//

import PackStream
import NIOPosix

public struct BoltAgent: Equatable, Encodable, Sendable {
    
    fileprivate enum CodingKeys: String, CodingKey {
        case product
        case platform
        case language
        case languageDetails = "language_details"
    }
    
    public static let current = BoltAgent(product: "neo4j-driver/0.0.0", platform: getPlatformString(), language: "Swift/6")
    
    public var product: String
    public var platform: String?
    public var language: String?
    public var languageDetails: String?
     
    private init(product: String, platform: String? = nil, language: String? = nil, languageDetails: String? = nil) {
        self.product = product
        self.platform = platform
        self.language = language
        self.languageDetails = languageDetails
    }
    
    static func getPlatformString() -> String? {
        var utsnameInstance = utsname()
        uname(&utsnameInstance)

        let sysname: String = withUnsafePointer(to: utsnameInstance.sysname.0, { pointer in
            return String(cString: pointer)
        })
        let release = withUnsafePointer(to: utsnameInstance.release.0, { pointer in
            return String(cString: pointer)
        })
        let machine = withUnsafePointer(to: utsnameInstance.machine.0, { pointer in
            return String(cString: pointer)
        })
        
        return "\(sysname) \(release); \(machine)"
    }
}
