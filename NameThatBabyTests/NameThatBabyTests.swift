//
//  NameThatBabyTests.swift
//  NameThatBabyTests
//
//  Created by Kevin DeRonne on 7/25/17.
//  Copyright © 2017 Kevin DeRonne. All rights reserved.
//

import XCTest
@testable import NameThatBaby

class NameThatBabyTests: XCTestCase {
    var viewController: ViewController!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "Main",
                                      bundle: Bundle.main)
        self.viewController = storyboard.instantiateInitialViewController() as! ViewController
        
        UIApplication.shared.keyWindow!.rootViewController = self.viewController
        
        // Test and Load the View at the Same Time!
        XCTAssertNotNil(viewController.view)
        
        self.viewController.allNames = ["Kevin", "Jane", "Paul"]
        self.viewController.useRandomNames = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // Kevin loses
        self.viewController.rightWinner(self.viewController.rightButton)
        // Kevin wins
        self.viewController.rightWinner(self.viewController.rightButton)
        let result = self.viewController.getLadder()
        print(result)
        // Verified to three decimal places against Andrew's python code
        XCTAssert(result["Jane"]  == 29.205641392120402)
        XCTAssert(result["Kevin"] == 25.039490749065116)
        XCTAssert(result["Paul"]  == 19.30509717714812)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
