//
//  ViewController.swift
//  NameThatBaby
//
//  Created by Kevin DeRonne on 7/25/17.
//  Copyright © 2017 Kevin DeRonne. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let gameInfo     = GameInfo()
    //let allNames     = ["Kevin", "Jane", "Paul", "Beth", "Chris", "Amy", "Andrew", "Becky", "Oliver"]
    let allNames     = ["Kevin", "Jane", "Paul"]
    var players      = [Player]()
    var currentLeft  = Player(id: -1, name:"Null")
    var currentRight = Player(id: -1, name:"Null")
    let skillCalculator = TwoPlayerTrueSkillCalculator()
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Populate players list
        for name in allNames {
            let lastId = players.count
            self.players.append(Player(id:lastId+1, name:name))
        }
        
        // Set initial match
        self.nextMatch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Left name responder
    @IBAction func leftWinner(_ sender: UIButton) {
        print("LeftName wins")
        self.matchOver(winningTeam: (currentLeft.id, currentLeft.rating), losingTeam: (currentRight.id, currentRight.rating), wasDraw: false)
        
    }
    
    @IBAction func rightWinner(_ sender: UIButton) {
        print("RightName wins")
        self.matchOver(winningTeam: (currentRight.id, currentRight.rating), losingTeam: (currentLeft.id, currentLeft.rating), wasDraw: false)
    }
    
    @IBAction func noWinner(_ sender: UIButton) {
        // Show ladder
        for player in self.players.sorted(by: {$0.rating.Mean() > $1.rating.Mean()}) {
            print(player.name, player.rating.Mean(), player.rounds)
        }
    }
    
    func nextMatch() {
        // Pick two random names from the set of names with minumum number of rounds
        // --This amounts to: select from order by asc, random() limit 2
        // first, sort list by rounds in ascending order
        let sortedPlayers = players.sorted(by: {$0.rounds < $1.rounds})
        
        // second, filter list to just include those with at most the second-least number of rounds
        // (we have to make sure we get at least two players so we look at index 1 for the max number of rounds we will accept)
        let minRounds = sortedPlayers[1].rounds
        let filteredSortedPlayers = sortedPlayers.filter({$0.rounds <= minRounds})
        
        // third, pick two random names from the filtered list (and make sure they aren't the same)
        let first  = Int(arc4random_uniform(UInt32(filteredSortedPlayers.count)))
        var second = Int(arc4random_uniform(UInt32(filteredSortedPlayers.count)))
        while first == second {
            second = Int(arc4random_uniform(UInt32(filteredSortedPlayers.count)))
        }
        
        // First and second work as indexes into sortedPlayers because the filtered list will always be <= the full list
        self.currentLeft  = sortedPlayers[first]
        self.currentRight = sortedPlayers[second]
        self.updateButtonLabelsWithNewNames(newLeftName: self.currentLeft.name, newRightName: self.currentRight.name)
        sortedPlayers[first].rounds  += 1
        sortedPlayers[second].rounds += 1
    }
    
    func matchOver(winningTeam: (Int, Rating), losingTeam: (Int,Rating), wasDraw: Bool) {
        let res = skillCalculator.CalculateNewRatings(gameInfo: gameInfo, winningTeam: winningTeam, losingTeam: losingTeam, wasDraw: wasDraw)
        // Assign new ratings.  Super inefficient but whatever; the results are always n=2 and there just can't be that many names.
        for x in res {
            for player in self.players {
                if player.id == x.0 {
                    player.rating = x.1
                    break
                }
            }
        }
        nextMatch()
    }
    
    // there's a way to have the buttons monitor the values of variables and update accordingly
    // Can't remember what it is at the moment though
    func updateButtonLabelsWithNewNames(newLeftName: String, newRightName: String) {
        self.leftButton.setTitle(newLeftName, for: .normal)
        self.rightButton.setTitle(newRightName, for: .normal)
    }
}

