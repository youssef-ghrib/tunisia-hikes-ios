//
//  Post.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 12/9/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import ObjectMapper

class Post: Mappable {
    
    var id: Int!
    var text: String!
    var randonneeId: Int!
    var userId: Int!
    var medias: [Media]!
    var user: User!
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        id          <- map["id"]
        text        <- map["text"]
        randonneeId <- map["randonnee_id"]
        userId      <- map["user_id"]
    }
}
