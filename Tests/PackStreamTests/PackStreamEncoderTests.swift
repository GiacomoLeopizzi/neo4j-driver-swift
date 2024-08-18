//
//  PackStreamEncoderTests.swift
//
//
//  Created by Giacomo Leopizzi on 08/07/24.
//

import Testing
import NIOCore
@testable import PackStream

@Suite
struct PackStreamEncoderTests {
    
    let encoder = PackStreamEncoder()
    
    @Test(arguments: [
        Optional<PackStreamValue>.none,
        Optional<Bool>.none,
        Optional<Int>.none,
        Optional<Int8>.none,
        Optional<Int16>.none,
        Optional<Int32>.none,
        Optional<Int64>.none,
        Optional<UInt>.none,
        Optional<UInt8>.none,
        Optional<UInt16>.none,
        Optional<UInt32>.none,
        Optional<UInt64>.none,
        Optional<String>.none,
        Optional<ByteBuffer>.none,
    ] as [Encodable])
    func null(value: Encodable) throws {
        let encoded = try encoder.encode(value)
        #expect(encoded == .null)
    }
    
    @Test(arguments: [true, false])
    func bool(value: Bool) throws {
        let encoded = try encoder.encode(value)
        #expect(encoded == .boolean(value))
    }
    
    @Test(arguments: [
        Int.random(in: Int.min...Int.max),
        Int8.random(in: Int8.min...Int8.max),
        Int16.random(in: Int16.min...Int16.max),
        Int32.random(in: Int32.min...Int32.max),
        Int64.random(in: Int64.min...Int64.max),
        UInt.random(in: UInt.min...UInt(Int64.max)),
        UInt8.random(in: UInt8.min...UInt8.max),
        UInt16.random(in: UInt16.min...UInt16.max),
        UInt32.random(in: UInt32.min...UInt32.max),
        UInt64.random(in: UInt64.min...UInt64(Int64.max)),
    ] as [Encodable])
    func integers(value: Encodable) throws {
        let encoded = try encoder.encode(value)
        let integer = value as! any FixedWidthInteger
        #expect(encoded == .integer(Int64(integer)))
    }
    
    @Test(arguments: [
        Double(1.23456),
        Float.zero,
    ] as [Encodable])
    func floatingPoints(value: Encodable) throws {
        let encoded = try encoder.encode(value)
        let floatingPoint = value as! any BinaryFloatingPoint
        #expect(encoded == .float(Double(floatingPoint)))
    }
    
    @Test(arguments: [
        ByteBuffer(bytes: []).slice(),
        ByteBuffer(bytes: [1, 2, 3]).slice(),
        ByteBuffer(bytes: Array(repeating: 50, count: Int.random(in: 0...100)))
    ])
    func bytes(value: ByteBuffer) throws {
        let encoded = try encoder.encode(value)
        #expect(encoded == .bytes(value))
    }
    
    @Test(arguments: [
        "",
        "A",
        "ABC",
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    ])
    func string(value: String) throws {
        let encoded = try encoder.encode(value)
        #expect(encoded == .string(value))
    }
    
    @Test(arguments: [
        [],
        [1, 2, 3],
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        [.integer(0), .string("50"), .null, .boolean(false)],
        [.dictionary(["A" : .float(0)])]
        ] as [[PackStreamValue]])
    func list(value: [PackStreamValue]) throws {
        let encoded = try encoder.encode(value)
        #expect(encoded == .list(value))
    }
    
    @Test(arguments: [
        [:],
        ["1" : 1, "2" : 2, "3" : .list([1, 2, 3])],
        ["" : .integer(0), ";" : .string("50"), "null" : .null, "false" : .boolean(false)],
        ["dict" : .dictionary(["A" : .float(0)])]
    ] as [[String : PackStreamValue]])
    func dictionary(value: [String : PackStreamValue]) throws {
        let encoded = try encoder.encode(value)
        #expect(encoded == .dictionary(value))
    }
    
    @Test
    func structure() throws {
        let value = TestStructure()
        let encoded = try encoder.encode(value)
        #expect(encoded == .structure(signature: TestStructure.signature, fields: [
            value.value,
            .boolean(value.boolean),
            .integer(value.int),
            .float(value.float),
            .bytes(value.bytes),
            .string(value.string),
            .list(value.list),
            .dictionary(value.dictionary),
            .null,
        ]))
    }
    
}
