//
//  Model.swift
//  NameThatBaby
//
//  Created by Kevin DeRonne on 8/24/17.
//  Copyright © 2017 Kevin DeRonne. All rights reserved.
//

import Foundation

class Model: NSObject {
    var gameInfo: GameInfo
    var allNames: [String]
    var players: [Player]
    var currentLeft: Player?
    var currentRight: Player?
    var skillCalculator: TwoPlayerTrueSkillCalculator
    var useRandomNames: Bool
    
    init(useRandomNames: Bool) {
        self.gameInfo = GameInfo()
        self.allNames = ["Kevin", "Jane", "Paul"]
        //let allNames     = ["Kevin", "Jane", "Paul", "Beth", "Chris", "Amy", "Andrew", "Becky", "Oliver"]
        self.players = [Player]()
        self.currentLeft = nil
        self.currentRight = nil
        self.skillCalculator = TwoPlayerTrueSkillCalculator()
        self.useRandomNames = useRandomNames
        
        // Populate players list
        for name in allNames {
            let lastId = players.count
            self.players.append(Player(id:lastId+1, name:name))
        }
    }
    
    func nextMatch() {
        // Pick two random names from the set of names with minumum number of rounds
        // --This amounts to: select from order by asc, random() limit 2
        // first, sort list by rounds in ascending order
        let sortedPlayers = self.players.sorted(by: {$0.rounds < $1.rounds})
        
        // second, filter list to just include those with at most the second-least number of rounds
        // (we have to make sure we get at least two players so we look at index 1 for the max number of rounds we will accept)
        let minRounds = sortedPlayers[1].rounds
        let filteredSortedPlayers = sortedPlayers.filter({$0.rounds <= minRounds})
        
        var first  = 0
        var second = 1
        if self.useRandomNames {
            // third, pick two random names from the filtered list (and make sure they aren't the same)
            first  = Int(arc4random_uniform(UInt32(filteredSortedPlayers.count)))
            second = Int(arc4random_uniform(UInt32(filteredSortedPlayers.count)))
            while first == second {
                second = Int(arc4random_uniform(UInt32(filteredSortedPlayers.count)))
            }
        }
        
        // First and second work as indexes into sortedPlayers because the filtered list will always be <= the full list
        self.currentLeft  = sortedPlayers[first]
        self.currentRight = sortedPlayers[second]
        sortedPlayers[first].rounds  += 1
        sortedPlayers[second].rounds += 1
    }
    
    func matchOver(winningTeam: (Int, Rating), losingTeam: (Int,Rating), wasDraw: Bool) {
        let res = skillCalculator.CalculateNewRatings(gameInfo: gameInfo, winningTeam: winningTeam, losingTeam: losingTeam, wasDraw: wasDraw)
        // Assign new ratings.  Super inefficient but the results are always n=2 and there just can't be that many names.
        for x in res {
            for player in self.players {
                if player.id == x.0 {
                    player.rating = x.1
                    break
                }
            }
        }
        self.nextMatch()
    }
    
    func getLadder() -> [String:Double] {
        var ret = [String:Double]()
        for player in self.players.sorted(by: {$0.rating.Mean() > $1.rating.Mean()}) {
            //print(player.name, player.rating.Mean(), player.rounds)
            ret[player.name] = player.rating.Mean()
        }
        //print(ret)
        return ret
        
    }

}
