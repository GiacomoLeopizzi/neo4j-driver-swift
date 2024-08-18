//
//  TestStructure.swift
//  
//
//  Created by Giacomo Leopizzi on 08/07/24.
//

import PackStream
import NIOCore

final class TestStructure: _PackStreamStructure, Codable, Hashable {
    
    static let signature: Byte = Byte.random(in: Byte.min...Byte.max)
    
    var value: PackStreamValue
    var boolean: Bool
    var int: Int64
    var float: Double
    var bytes: ByteBuffer
    var string: String
    var list: [PackStreamValue]
    var dictionary: [String : PackStreamValue]
    var structure: TestStructure?
    
    init(value: PackStreamValue = .null,
         boolean: Bool = true,
         int: Int64 = Int64.random(in: Int64.min...Int64.max),
         float: Double = 1.23456,
         bytes: ByteBuffer = .init(bytes: [1, 2, 3]),
         string: String = "Hello, world!",
         list: [PackStreamValue] = [.null, "Ciao", 50, 0.34, true],
         dictionary: [String : PackStreamValue] = ["A" : 1, "B" : 2, "C" : 3],
         structure: TestStructure? = nil
    ) {
        self.value = value
        self.boolean = boolean
        self.int = int
        self.float = float
        self.bytes = bytes
        self.string = string
        self.list = list
        self.dictionary = dictionary
        self.structure = structure
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        self.value = try container.decode(PackStreamValue.self)
        self.boolean = try container.decode(Bool.self)
        self.int = try container.decode(Int64.self)
        self.float = try container.decode(Double.self)
        self.bytes = try container.decode(ByteBuffer.self)
        self.string = try container.decode(String.self)
        self.list = try container.decode([PackStreamValue].self)
        self.dictionary = try container.decode([String : PackStreamValue].self)
        self.structure = try container.decodeIfPresent(TestStructure.self)
    }
    
    static func == (lhs: TestStructure, rhs: TestStructure) -> Bool {
        return lhs.value == rhs.value &&
        lhs.boolean == rhs.boolean &&
        lhs.int == rhs.int &&
        lhs.float == rhs.float &&
        lhs.bytes == rhs.bytes &&
        lhs.string == rhs.string &&
        lhs.list == rhs.list &&
        lhs.dictionary == rhs.dictionary &&
        lhs.structure == rhs.structure
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.value)
        hasher.combine(self.boolean)
        hasher.combine(self.int)
        hasher.combine(self.float)
        hasher.combine(self.bytes)
        hasher.combine(self.string)
        hasher.combine(self.list)
        hasher.combine(self.dictionary)
        hasher.combine(self.structure)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(self.value)
        try container.encode(self.boolean)
        try container.encode(self.int)
        try container.encode(self.float)
        try container.encode(self.bytes)
        try container.encode(self.string)
        try container.encode(self.list)
        try container.encode(self.dictionary)
        try container.encode(self.structure)
    }
}
