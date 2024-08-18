//
//  Neo4JConfiguration.swift
//
//
//  Created by Giacomo Leopizzi on 09/07/24.
//

import Bolt
import Logging

public struct Neo4JConfiguration: Sendable {
    
    public typealias SSL = BoltConfiguration.SSL
    
    /// The host address of the Neo4J server.
    public var host: String
    /// The port number of the Neo4J server.
    public var port: Int
    
    /// Additional parameters for the hello request.
    public var hello: HelloExtra
    /// Authentication credentials.
    public var auth: Auth
    
    /// The SSL configuration. If nil, SSL is not used, and the channel is not encrypted.
    public var ssl: SSL?
    
    /// An optional logger. Default is nil.
    public var logger: Logger?
    
    /// Initializes a new Neo4JConfiguration with the specified parameters.
    /// - Parameters:
    ///   - host: The host address of the Neo4J server.
    ///   - port: The port number of the Neo4J server.
    ///   - ssl: The SSL configuration. If nil, SSL is not used, and the channel is not encrypted.
    ///   - hello: Additional parameters for the hello request.
    ///   - auth: Authentication credentials.
    ///   - logger: An optional logger. Default is nil.
    public init(host: String, port: Int, ssl: SSL? = nil, hello: HelloExtra, auth: Auth, logger: Logger? = nil) {
        self.host = host
        self.port = port
        self.ssl = ssl
        self.hello = hello
        self.auth = auth
        self.logger = logger
    }
    
    /// Initializes a new Neo4JConfiguration with the specified parameters, including a user agent.
    /// - Parameters:
    ///   - host: The host address of the Neo4J server.
    ///   - port: The port number of the Neo4J server.
    ///   - ssl: The SSL configuration. If nil, SSL is not used, and the channel is not encrypted.
    ///   - userAgent: The user agent for the hello request. The user_agent should conform to "Name/Version" for example "Example/4.1.0".
    ///   - auth: Authentication credentials.
    ///   - logger: An optional logger. Default is nil.
    public init(host: String, port: Int, ssl: SSL? = nil, userAgent: String, auth: Auth, logger: Logger? = nil) {
        self.host = host
        self.port = port
        self.ssl = ssl
        self.hello = HelloExtra(userAgent: userAgent)
        self.auth = auth
        self.logger = logger
    }
}

// Bolt configuration

extension Neo4JConfiguration {
    
    var boltConfiguration: BoltConfiguration {
        BoltConfiguration(host: host, port: port, ssl: ssl, logger: logger)
    }
    
}
