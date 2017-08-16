//
//  Player.swift
//  NameThatBaby
//
//  Created by Kevin DeRonne on 8/15/17.
//  Copyright © 2017 Kevin DeRonne. All rights reserved.
//

import Foundation

class Player: NSObject {
    var id = Int()
    var name = String()
    // Not sure if this should be sqrt(8.333333) instead.  
    var rating = Rating(mean:25.0,  standardDeviation: 8.333333333333)
    var rounds = Int()
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.rounds = 0
    }
}
