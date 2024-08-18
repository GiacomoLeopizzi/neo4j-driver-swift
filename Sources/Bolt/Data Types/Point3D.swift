//
//  Point3D.swift
//  
//
//  Created by Giacomo Leopizzi on 27/06/24.
//

import PackStream

/*
 tag byte: 59
 Number of fields: 4
 Point3D::Structure(
     srid::Integer,
     x::Float,
     y::Float,
     z::Float,
 )
 */

extension Bolt {
    
    public struct Point3D: Hashable, StructureCodable, Sendable {
        
        public static let signature: Byte = 0x59
        
        public let srid: Int64
        public let x: Double
        public let y: Double
        public let z: Double
        
        public init(srid: Int64, x: Double, y: Double, z: Double) {
            self.srid = srid
            self.x = x
            self.y = y
            self.z = z
        }
        
        public init(from container: inout UnkeyedDecodingContainer) throws {
            self.srid = try container.decode(Int64.self)
            self.x = try container.decode(Double.self)
            self.y = try container.decode(Double.self)
            self.z = try container.decode(Double.self)
        }

        public func encode(to container: inout UnkeyedEncodingContainer) throws {
            try container.encode(self.srid)
            try container.encode(self.x)
            try container.encode(self.y)
            try container.encode(self.z)
        }
    }
}
