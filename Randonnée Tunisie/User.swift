//
//  User.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 12/9/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import ObjectMapper

class User: Mappable {
    
    var id: Int!
    var idFacebook: IntMax!
    var email: String!
    var password: String!
    var name: String!
    var photo: String!
    var thumbnail: String!
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        id          <- map["id"]
        idFacebook  <- map["id_facebook"]
        email       <- map["email"]
        password    <- map["password"]
        name        <- map["name"]
        photo       <- map["photo"]
        thumbnail   <- map["thumbnail"]
    }
}
