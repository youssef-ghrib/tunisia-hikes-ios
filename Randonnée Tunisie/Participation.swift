//
//  Participation.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 12/26/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import ObjectMapper

class Participation: Mappable {
    
    var userId: Int!
    var randonneeId: Int!
    var status: String!
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        userId      <- map["user_id"]
        randonneeId <- map["randonnee_id"]
        status      <- map["status"]
    }
}
