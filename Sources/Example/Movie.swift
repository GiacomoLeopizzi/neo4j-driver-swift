//
//  Movie.swift
//
//
//  Created by Giacomo Leopizzi on 09/07/24.
//

import Neo4J

struct Movie: NodeProperties {

    enum CodingKeys: String, CodingKey {
        case released
        case title
        case tagline
    }
        
    var released: Int
    var title: String
    var tagline: String?
    
    init(released: Int, title: String, tagline: String) {
        self.released = released
        self.title = title
        self.tagline = tagline
    }
    
}
