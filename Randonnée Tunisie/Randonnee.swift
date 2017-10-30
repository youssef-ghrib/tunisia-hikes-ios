//
//  Randonnee.swift
//  Randonnée Tunisie
//
//  Created by Youssef Ghrib on 12/8/16.
//  Copyright © 2016 ESPRIT. All rights reserved.
//

import ObjectMapper

class Randonnee: Mappable {

    var id: Int!
    var title: String!
    var location: String!
    var longitude: Double!
    var latitude: Double!
    var date: String!
    var startTime: String!
    var endTime: String!
    var description: String!
    var type: String!
    var photo: String!
    var availability: Int!
    var cost: Float!
    var validation: Bool!
    var status: String!
    var userId: Int!
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        id              <- map["id"]
        title           <- map["title"]
        location        <- map["location"]
        longitude       <- map["longitude"]
        latitude        <- map["latitude"]
        date            <- map["date"]
        startTime       <- map["start_time"]
        endTime         <- map["end_time"]
        description     <- map["description"]
        type            <- map["type"]
        photo           <- map["photo"]
        availability    <- map["availability"]
        cost            <- map["cost"]
        validation      <- map["validation"]
        status          <- map["status"]
        userId          <- map["user_id"]
    }
}
