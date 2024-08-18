//
//  Neo4JConfiguration.swift
//
//
//  Created by Giacomo Leopizzi on 09/07/24.
//

import Bolt
import Logging

public struct Neo4JConfiguration: Sendable {
    
    /// The host address of the Neo4J server.
    public var host: String
    /// The port number of the Neo4J server.
    public var port: Int
    
    /// Additional parameters for the hello request.
    public var hello: HelloExtra
    /// Authentication credentials.
    public var auth: Auth
    
    /// An optional logger. Default is nil.
    public var logger: Logger?
    
    /// Initializes a new Neo4JConfiguration with the specified parameters.
    /// - Parameters:
    ///   - host: The host address of the Neo4J server.
    ///   - port: The port number of the Neo4J server.
    ///   - hello: Additional parameters for the hello request.
    ///   - auth: Authentication credentials.
    ///   - logger: An optional logger. Default is nil.
    public init(host: String, port: Int, hello: HelloExtra, auth: Auth, logger: Logger? = nil) {
        self.host = host
        self.port = port
        self.hello = hello
        self.auth = auth
        self.logger = logger
    }
    
    /// Initializes a new Neo4JConfiguration with the specified parameters, including a user agent.
    /// - Parameters:
    ///   - host: The host address of the Neo4J server.
    ///   - port: The port number of the Neo4J server.
    ///   - userAgent: The user agent for the hello request. The user_agent should conform to "Name/Version" for example "Example/4.1.0".
    ///   - auth: Authentication credentials.
    ///   - logger: An optional logger. Default is nil.
    public init(host: String, port: Int, userAgent: String, auth: Auth, logger: Logger? = nil) {
        self.host = host
        self.port = port
        self.hello = HelloExtra(userAgent: userAgent)
        self.auth = auth
        self.logger = logger
    }
}
