//
//  ViewController.swift
//  NameThatBaby
//
//  Created by Kevin DeRonne on 7/25/17.
//  Copyright © 2017 Kevin DeRonne. All rights reserved.
//
// TODO:
/*
// Most of this needs to be moved out of ViewController, as it's really model stuff.
// Load top n names from a given decade based on census data
// Enter your own names
// Enter your last name
// Persistance of ranked list
// Communication with a partner's app (concurrency will be fun here)
// Swipe left/right to choose a name
// Swipe up to show ranking
// Colorball changes as confidence of list grows
// Adding a new name after having ranked names a while gives that new name the
// meta mean and meta standard deviation so the
// p-value immediately tanks and that name comes up a bunch
// Implement p-value based selection of pairs (see Andrew's code)
 // Implement team-based trueskill and find a way to determine name similarities within teams so 
 // large groups of names can be eliminated in one stroke
 // Ability to have two lists (what if you don't know the gender)
 */

import UIKit

class ViewController: UIViewController {
    

    let model = Model(useRandomNames: false)
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        
        // Set initial match
        self.model.nextMatch()
        self.updateButtonLabelsWithNewNames()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Left name responder
    @IBAction func leftWinner(_ sender: UIButton) {
        self.model.matchOver(winningTeam: ((self.model.currentLeft?.id)!, (self.model.currentLeft?.rating)!), losingTeam: ((self.model.currentRight?.id)!, (self.model.currentRight?.rating)!), wasDraw: false)
        self.updateButtonLabelsWithNewNames()
        
    }
    
    @IBAction func rightWinner(_ sender: UIButton) {
        self.model.matchOver(winningTeam: ((self.model.currentRight?.id)!, (self.model.currentRight?.rating)!), losingTeam: ((self.model.currentLeft?.id)!, (self.model.currentLeft?.rating)!), wasDraw: false)
        self.updateButtonLabelsWithNewNames()
    }
    
    @IBAction func noWinner(_ sender: UIButton) {
        // Show ladder
        for player in self.model.players.sorted(by: {$0.rating.Mean() > $1.rating.Mean()}) {
            print(player.name, player.rating.Mean(), player.rounds)
        }
        //let _ = self.model.getLadder()
    }
    @IBAction func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        self.leftWinner(self.leftButton)
    }

    @IBAction func swipeRight(_ sender: UISwipeGestureRecognizer) {
        self.rightWinner(self.rightButton)
    }
    
    @IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
        self.noWinner(self.middleButton)
    }
    // there's a way to have the buttons monitor the values of variables and update accordingly
    // Can't remember what it is at the moment though
    func updateButtonLabelsWithNewNames() {
        self.leftButton.setTitle(self.model.currentLeft?.name, for: .normal)
        self.rightButton.setTitle(self.model.currentRight?.name, for: .normal)
    }
}

