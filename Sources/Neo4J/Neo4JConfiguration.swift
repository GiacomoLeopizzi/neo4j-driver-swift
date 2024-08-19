//
//  Neo4JConfiguration.swift
//
//
//  Created by Giacomo Leopizzi on 09/07/24.
//

import Bolt
import Logging
#if canImport(Foundation)
import Foundation
#endif

public struct Neo4JConfiguration: Sendable {
    
    public typealias SSL = BoltConfiguration.SSL
    
    public static var defaultPort: Int {
        7687
    }
    
    static var schema: String {
        "neo4j"
    }
    
    static var secureSchema: String {
        "neo4j+s"
    }
    
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
    public init(host: String, port: Int = defaultPort, ssl: SSL? = nil, hello: HelloExtra, auth: Auth, logger: Logger? = nil) {
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
    public init(host: String, port: Int = defaultPort, ssl: SSL? = nil, userAgent: String, auth: Auth, logger: Logger? = nil) {
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

// Foundation extension
#if canImport(Foundation)
extension Neo4JConfiguration {
    
    /// Initializes a new instance of the connection with the given parameters.
    ///
    /// This initializer sets up a connection to a Neo4j database using the provided connection URI, user agent string,
    /// authentication details, and an optional logger. The initializer also performs several checks to ensure the
    /// validity of the connection URI and configures SSL if required by the schema.
    ///
    /// - Parameters:
    ///   - connectionURI: The URI for connecting to the Neo4j database. It must include a valid scheme and host.
    ///   - userAgent: A string representing the user agent that will be sent to the Neo4j server.
    ///   - auth: An instance of `Auth` containing the authentication details (e.g., username and password).
    ///   - logger: An optional instance of `Logger` for logging connection details and events. If no logger is provided, logging is disabled.
    ///
    /// - Throws:
    ///   - `Neo4JError`: Thrown when the connection URI is invalid, such as missing a host, scheme, or if the scheme is unsupported.
    ///
    /// - Notes:
    ///   - The method first parses the `connectionURI` to extract components such as the host and scheme.
    ///   - The scheme must be either `bolt` or `bolt+s`, corresponding to standard and secure (SSL) connections, respectively.
    ///   - If the schema is `bolt+s`, an SSL connection is initialized with the provided hostname.
    ///   - If the port is not specified in the `connectionURI`, a default port is used.
    ///   - The `HelloExtra` instance is initialized with the provided `userAgent`.
    public init(connectionURI: String, userAgent: String, auth: Auth, logger: Logger? = nil) throws {
        guard let components = URLComponents(string: connectionURI) else {
            throw Neo4JError(.invalidConnectionURI, location: .here())
        }
        guard let host = components.host, let schema = components.scheme else {
            throw Neo4JError(.invalidConnectionURI, location: .here())
        }
        guard schema == Self.schema || schema == Self.secureSchema else {
            throw Neo4JError(.invalidConnectionURI, location: .here())
        }
        
        self.host = host
        self.port = components.port ?? Self.defaultPort
        if schema == Self.secureSchema {
            self.ssl = try .init(serverHostname: host)
        }
        self.hello = HelloExtra(userAgent: userAgent)
        self.auth = auth
        self.logger = logger
    }
}
#endif
