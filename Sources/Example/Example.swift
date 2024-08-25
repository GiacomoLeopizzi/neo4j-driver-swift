import Neo4J
import Logging
import NIOPosix
import ServiceLifecycle

@main
struct Example {
    // Use the shared singleton instance of MultiThreadedEventLoopGroup.
    static let eventLoopGroup = MultiThreadedEventLoopGroup.singleton
    // Initialize the logger.
    static let logger = Logger(label: "neo4j")
    
    static func main() async throws {
        let configuration = Neo4JConfiguration(
            host: "127.0.0.1",
            userAgent: "Example/0.0.0",
            auth: .basic(password: "12345678"),
            logger: logger)
        
        // Instantiate a new Neo4JConnection actor.
        let neo4jConnection = Neo4JConnection(configuration: configuration, eventLoopGroup: eventLoopGroup)
        
        // Initialize the service group.
        let serviceGroup = ServiceGroup(services: [neo4jConnection], logger: self.logger)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            // Add the connection actor's run function to the task group.
            // This opens the connection and handles requests until the task is canceled or the connection is closed.
            group.addTask { try await serviceGroup.run() }
            
            // Execute a query with parameters.
            try await neo4jConnection.run(query: #"CREATE (r:Person {name: $name, born: $born})"#, parameters: [
                "name" : "Robert Zemeckis",
                "born" : 1952
            ])
            
            // Execute a query without parameters.
            try await neo4jConnection.run(query: """
                CREATE (bttf:Movie {title: "Back to the Future", released: 1985,
                tagline: "He's the only kid ever to get into trouble before he was born."})
                """)
            
            // Create a relationship between the two nodes.
            try await neo4jConnection.run(query: """
                MATCH (director:Person {name: "Robert Zemeckis"}), (movie:Movie {title: "Back to the Future"})
                CREATE (director)-[:DIRECTED]->(movie)
                """)
            
            // Use the run method to return data. The `decodingResultsAs` parameter
            // allows decoding the data already cast to the correct Swift type.
            
            // For example, in this case, only the node is returned.
            let result = try await neo4jConnection.run(
                query: "MATCH (m: Movie) WHERE m.released = $year RETURN m",
                parameters: ["year" : 1985],
                decodingResultsAs: Node<Movie>.self)
            if let bttf = result.first {
                print(bttf.properties.tagline ?? "")
            }
            
            // In this case, two nodes and a relationship are returned.
            // The first is the movie; for the other parameters, the generic Bolt types are used.
            let result2 = try await neo4jConnection.run(
                query: "MATCH (m: Movie)<-[r:DIRECTED]-(p:Person) WHERE m.released = $year RETURN m, r, p",
                parameters: ["year" : 1985],
                decodingResultsAs: (Node<Movie>, Bolt.Relationship, Bolt.Node).self)
            if let data = result2.first {
                // Because of the generic parameter pack, the type of `data` is: (Node<Movie>, Bolt.Relationship, Bolt.Node)
                print(data.0.properties.title, data.1.type, data.2.properties)
            }
            
            // Delete the nodes and the relationship.
            let metadata = try await neo4jConnection.run(query: """
                MATCH (director:Person {name: "Robert Zemeckis"}), (movie:Movie {title: "Back to the Future"})
                DETACH DELETE director, movie
                """)
            print(metadata.stats?.description ?? "")
            
            // Cancel all tasks in the task group.
            // This also results in the connection to Neo4J being closed.
            group.cancelAll()
        }
    }
}
