//
//  PackStreamDecoderTests.swift
//  
//
//  Created by Giacomo Leopizzi on 08/07/24.
//

import Testing
import NIOCore
@testable import PackStream

@Suite
struct PackStreamDecoderTests {
    
    let decoder = PackStreamDecoder()
    
    @Test
    func null() throws {
        #expect(try decoder.decode(value: .null, Optional<PackStreamValue>.self) == .none)
        #expect(try decoder.decode(value: .null, Optional<Bool>.self) == .none)
        #expect(try decoder.decode(value: .null, Optional<Int>.self) == .none)
        #expect(try decoder.decode(value: .null, Optional<Int8>.self) == .none)
        #expect(try decoder.decode(value: .null, Optional<Int16>.self) == .none)
        #expect(try decoder.decode(value: .null, Optional<Int32>.self) == .none)
        #expect(try decoder.decode(value: .null, Optional<Int64>.self) == .none)
        #expect(try decoder.decode(value: .null, Optional<UInt>.self) == .none)
        #expect(try decoder.decode(value: .null, Optional<UInt8>.self) == .none)
        #expect(try decoder.decode(value: .null, Optional<UInt16>.self) == .none)
        #expect(try decoder.decode(value: .null, Optional<UInt32>.self) == .none)
        #expect(try decoder.decode(value: .null, Optional<UInt64>.self) == .none)
        #expect(try decoder.decode(value: .null, Optional<String>.self) == .none)
        #expect(try decoder.decode(value: .null, Optional<ByteBuffer>.self) == .none)
    }
    
    @Test(arguments: [
        Int64.zero,
        Int64(50),
    ])
    func integer(value: Int64) throws {
        #expect(try decoder.decode(value: .integer(value), Int.self) == Int(value))
        #expect(try decoder.decode(value: .integer(value), Int8.self) == Int8(value))
        #expect(try decoder.decode(value: .integer(value), Int16.self) == Int16(value))
        #expect(try decoder.decode(value: .integer(value), Int32.self) == Int32(value))
        #expect(try decoder.decode(value: .integer(value), Int64.self) == Int64(value))
        #expect(try decoder.decode(value: .integer(value), UInt.self) == UInt(value))
        #expect(try decoder.decode(value: .integer(value), UInt8.self) == UInt8(value))
        #expect(try decoder.decode(value: .integer(value), UInt16.self) == UInt16(value))
        #expect(try decoder.decode(value: .integer(value), UInt32.self) == UInt32(value))
        #expect(try decoder.decode(value: .integer(value), UInt64.self) == UInt64(value))
    }
    
    @Test(arguments: [
        Double.zero,
        Double(50),
    ])
    func floatingPoint(value: Double) throws {
        #expect(try decoder.decode(value: .float(value), Double.self) == Double(value))
        #expect(try decoder.decode(value: .float(value), Float.self) == Float(value))
    }
    
    @Test(arguments: [
        ByteBuffer(bytes: []).slice(),
        ByteBuffer(bytes: [1, 2, 3]).slice(),
        ByteBuffer(bytes: Array(repeating: 50, count: Int.random(in: 0...100)))
    ])
    func bytes(value: ByteBuffer) throws {
        #expect(try decoder.decode(value: .bytes(value), ByteBuffer.self) == value)
    }
    
    @Test(arguments: [
        "",
        "A",
        "ABC",
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    ])
    func string(value: String) throws {
        #expect(try decoder.decode(value: .string(value), String.self) == value)
    }
    
    @Test(arguments: [
        [],
        [1, 2, 3],
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        [.integer(0), .string("50"), .null, .boolean(false)],
        [.dictionary(["A" : .float(0)])]
        ] as [[PackStreamValue]])
    func list(value: [PackStreamValue]) throws {
        #expect(try decoder.decode(value: .list(value), [PackStreamValue].self) == value)
    }
    
    @Test(arguments: [
        [:],
        ["1" : 1, "2" : 2, "3" : .list([1, 2, 3])],
        ["" : .integer(0), ";" : .string("50"), "null" : .null, "false" : .boolean(false)],
        ["dict" : .dictionary(["A" : .float(0)])]
    ] as [[String : PackStreamValue]])
    func dictionary(value: [String : PackStreamValue]) throws {
        #expect(try decoder.decode(value: .dictionary(value), [String : PackStreamValue].self) == value)
    }
    
    @Test
    func structure() throws {
        let value = TestStructure()        
        #expect(try decoder.decode(value: .structure(signature: TestStructure.signature, fields: [
            value.value,
            .boolean(value.boolean),
            .integer(value.int),
            .float(value.float),
            .bytes(value.bytes),
            .string(value.string),
            .list(value.list),
            .dictionary(value.dictionary),
            .null,
        ]), TestStructure.self) == value)
    }
}
