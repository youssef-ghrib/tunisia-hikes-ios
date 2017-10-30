//
//  Media.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 12/9/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import ObjectMapper

class Media: Mappable {
    
    var id: Int!
    var url: String!
    var thumbnail: String!
    var type: String!
    var postId: Int!
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        id          <- map["id"]
        url         <- map["url"]
        thumbnail   <- map["thumbnail"]
        type        <- map["type"]
        postId      <- map["post_id"]
    }
}
