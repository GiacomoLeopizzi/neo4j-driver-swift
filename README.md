# Neo4J Swift Driver

> [!WARNING]
> This library is currently under active development. It may contain bugs, and its API is subject to change until the first stable release is published. Please use with caution and expect potential breaking changes in future updates.


This is a Swift Package that provides a convenient way to communicate with [Neo4J](https://neo4j.com) servers using the Bolt protocol v5.4.

## Features

:rocket: **Concurrency**: Built with Swift 6, leveraging async/await for efficient concurrency.

:lock: **SSL**: Supports secure connections to the database.

:gear: **Flexibility**: Allows for both high-level automation and low-level control of the Bolt connection.

:cloud: **AuraDB**: Compatible with [Neo4J AuraDB](https://neo4j.com/cloud/platform/aura-graph-database/).

## Getting Started

### Overview

The package includes three libraries:

- **PackStream**: Handles encoding and decoding binary data using the PackStream protocol. Typically, users of this library won't need to interact with it directly.
- **Bolt**: Facilitates communication using the Bolt protocol. This library exposes types that allow developers to interact with a Neo4J database using the raw Bolt protocol.
- **Neo4J**: This is the primary library most developers will use. It wraps the Bolt library, providing a more "Swifty" API for database interaction. This library is recommended for most use cases, though it also exposes the underlying Bolt connection for more specific scenarios.


> [!TIP]
> Use the Neo4J library to start and, only if really needed, use the Bolt library.

### Adding the Dependency

To add this package as a dependency, include it in your `Package.swift`:

```swift
.package(url: "https://github.com/GiacomoLeopizzi/neo4j-driver-swift.git", from: "0.0.0"),
```

Add `Neo4J` to your application's target dependencies:

```swift
.product(name: "Neo4J", package: "neo4j-driver-swift")
```

### Example

Here's an example of how to use `Neo4JConnection` in a program:

```swift
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
```

The driver also supports connections to [Neo4J AuraDB](https://neo4j.com/cloud/platform/aura-graph-database/). To make the previous example work with AuraDB, the only change needed is in the configuration object, which can be easily created using the `connectionURI` initializer parameter. An example of this is:

```swift
let configuration = try Neo4JConfiguration(connectionURI: "neo4j+s://xxxxxxxx.databases.neo4j.io", userAgent: "Example/0.0.0", auth: .basic(password: "the provided password"), logger: logger)
```


### Neo4J Connection API

The `Neo4JConnection` actor provides a concurrency-safe and efficient way to interact with a Neo4J database, leveraging the underlying `BoltConnection` for executing various protocol requests. This actor includes several methods designed to ensure the connection is properly prepared and managed throughout its lifecycle, making it ideal for asynchronous operations in a concurrent environment.

- **prepareIfNeeded(function: String = #function)**: Prepares the underlying connection by automatically sending `hello`, `logon`, and `reset` requests based on the server's current state. This method ensures the connection is ready for subsequent operations. It is automatically invoked by other methods in the actor, so manual invocation is typically unnecessary unless you plan to interact with the `underlyingConnection` directly.

- **withinTransaction(extra: BeginExtra = .none, _ closure: (TransactionConnection) async throws -> Void)**: Executes a set of operations within a transaction. This method initiates a transaction, runs the provided closure, and either commits the transaction if successful or rolls it back if an error occurs. The `prepareIfNeeded` method is called automatically to ensure the connection is in the appropriate state before beginning the transaction.

- **run<each T: Decodable & Sendable>(query: String, parameters: [String: any Encodable & Sendable] = [:], extra: RunExtra = .none, decodingResultsAs types: (repeat each T).Type) async throws -> [(repeat each T)]**: Executes a Cypher query and automatically retrieves and decodes all results into an array of tuples, where each tuple represents a row of data. This method is ideal for queries that return data, ensuring each result is correctly decoded into the specified types. The `prepareIfNeeded` method is invoked to guarantee that the connection is prepared before executing the query.

- **run(query: String, parameters: [String: any Encodable & Sendable] = [:], extra: RunExtra = .none) async throws -> SuccessMetadata**: Executes a Cypher query that does not return data, such as data manipulation operations. This method automatically discards all records and returns only the metadata generated by the query. Like other methods, it calls `prepareIfNeeded` to ensure the connection is properly initialized.

### Bolt Connection API

The `BoltConnection` extension provides a comprehensive set of supported Bolt protocol requests, enabling seamless interaction with the Bolt server. These requests include:

- **hello(extra: HelloExtra)**: Initiates a connection with the server, sending additional metadata and returning a `SuccessMetadata` object upon successful execution.
- **logon(auth: Auth)**: Authenticates the connection using the provided credentials, returning a `SuccessMetadata` object.
- **logoff()**: Logs off the current session, returning a `SuccessMetadata` object.
- **telemetry(api: TelemetryAPI)**: Sends telemetry data to the server, returning a `SuccessMetadata` object.
- **goodbye()**: Gracefully closes the connection with the server. The function handles expected errors related to connection closure.
- **reset()**: Resets the current session, returning a `SuccessMetadata` object.
- **run(query: String, parameters: [String: PackStreamValue], extra: RunExtra)**: Executes a Cypher query with optional parameters and additional metadata, returning a `SuccessMetadata` object.
- **discard(n: DiscardExtra.Amount, qid: Int64?)**: Discards the result of a previously executed query, returning a `SuccessMetadata` object.
- **pull(n: PullExtra.Amount, qid: Int64?)**: Pulls the result of a previously executed query, returning the result as a tuple containing a list of `PackStreamValue` arrays and a `SuccessMetadata` object.
- **begin(extra: BeginExtra)**: Begins a new transaction, returning a `SuccessMetadata` object.
- **commit()**: Commits the current transaction, returning a `SuccessMetadata` object.
- **rollback()**: Rolls back the current transaction, returning a `SuccessMetadata` object.
- **route(routing: [String: PackStreamValue], bookmarks: [String], extra: RouteExtra)**: Executes a routing procedure using the provided routing information and bookmarks, returning a `SuccessMetadata` object.

## Supported Data Types

The `Bolt` library includes the following data types that can be used when running queries:

* **Bolt.Date**
* **Bolt.DateTime**
* **Bolt.DateTimeZoneId**
* **Bolt.Duration**
* **Bolt.LocalDateTime**
* **Bolt.LocalTime**
* **Bolt.Node**
* **Bolt.Path**
* **Bolt.Point2D**
* **Bolt.Point3D**
* **Bolt.Relationship**
* **Bolt.Time**
* **Bolt.UnboundRelationship**

The `Neo4J` library, in addition to the types included in the `Bolt` library, also supports:

* **Node**: A generic type that allows the developer to provide a custom type (as a generic parameter) for the properties. In contrast, `Bolt.Node` returns properties as a dictionary.
* **Relationship**: A generic type that allows the developer to provide a custom type (as a generic parameter) for the properties. In contrast, `Bolt.Relationship` returns properties as a dictionary.


## Contributing

Contributions are highly encouraged as the library is still under development. Some of the pending features include:

- Completing the documentation and improving the examples;
- Extending and finishing the test suite using the Swift Testing library;
- Reviewing the Neo4J API to make it easier to work with Node and Relationship types, including methods to create and fetch them without manually writing Cypher queries;
- Creating a declarative syntax for expressing Cypher queries that allows for runtime and compile-time checks;
- Fixing bugs that may exist and addressing issues reported on GitHub;
- Develop a ConnectionPool actor.

Special thanks to [@SMartorelli](https://github.com/SMartorelli) and [@ndPPPhz](https://github.com/ndPPPhz) for their contributions to this project!
