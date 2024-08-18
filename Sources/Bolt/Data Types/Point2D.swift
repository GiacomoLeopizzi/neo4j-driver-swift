//
//  Point2D.swift
//  
//
//  Created by Giacomo Leopizzi on 27/06/24.
//

import PackStream

/*
 tag byte: 58
 Number of fields: 3
 Point2D::Structure(
     srid::Integer,
     x::Float,
     y::Float,
 )
 */

extension Bolt {
    
    public struct Point2D: Hashable, StructureCodable, Sendable {
        
        public static let signature: Byte = 0x58
        
        public let srid: Int64
        public let x: Double
        public let y: Double
        
        public init(srid: Int64, x: Double, y: Double) {
            self.srid = srid
            self.x = x
            self.y = y
        }
        
        public init(from container: inout UnkeyedDecodingContainer) throws {
            self.srid = try container.decode(Int64.self)
            self.x = try container.decode(Double.self)
            self.y = try container.decode(Double.self)
        }

        public func encode(to container: inout UnkeyedEncodingContainer) throws {
            try container.encode(self.srid)
            try container.encode(self.x)
            try container.encode(self.y)
        }
    }
}
