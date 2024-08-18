//
//  BoltConfiguration.swift
//  neo4j-driver-swift
//
//  Created by Giacomo Leopizzi on 18/08/24.
//

import Logging
import NIOSSL
import NIOCore

public struct BoltConfiguration: Sendable {
    
    public struct SSL: Sendable {
        
        public typealias VerificationCallback = @Sendable ([NIOSSLCertificate], EventLoopPromise<NIOSSLVerificationResult>) -> Void
        
        public var context: NIOSSLContext
        public var serverHostname: String?
        public var customVerificationCallback: VerificationCallback?
        
        public init(context: NIOSSLContext, serverHostname: String? = nil, customVerificationCallback: VerificationCallback? = nil) {
            self.context = context
            self.serverHostname = serverHostname
            self.customVerificationCallback = customVerificationCallback
        }
        
        public init(configuration: TLSConfiguration = .makeClientConfiguration(), serverHostname: String? = nil, customVerificationCallback: VerificationCallback? = nil) throws {
            self.context = try NIOSSLContext(configuration: configuration)
            self.serverHostname = serverHostname
            self.customVerificationCallback = customVerificationCallback
        }
    }
    
    /// The host address of the Neo4J server.
    public var host: String
    /// The port number of the Neo4J server.
    public var port: Int
    
    /// The SSL configuration. If nil, SSL is not used, and the channel is not encrypted.
    public var ssl: SSL?
    
    /// An optional logger. Default is nil.
    public var logger: Logger?
    
    /// Initializes a new Neo4JConfiguration with the specified parameters.
    /// - Parameters:
    ///   - host: The host address of the Neo4J server.
    ///   - port: The port number of the Neo4J server.
    ///   - ssl: The SSL configuration. If nil, SSL is not used, and the channel is not encrypted.
    ///   - logger: An optional logger. Default is nil.
    public init(host: String, port: Int, ssl: SSL?, logger: Logger? = nil) {
        self.host = host
        self.port = port
        self.ssl = ssl
        self.logger = logger
    }
    
    
}
