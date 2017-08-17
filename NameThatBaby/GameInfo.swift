//
//  GameInfo.swift
//  NameThatBaby
//
//  Created by Kevin DeRonne on 7/27/17.
//  Copyright © 2017 Kevin DeRonne. All rights reserved.
//

import Foundation

class GameInfo
{
    var initialMean = Double()
    var beta = Double()
    var drawProbability = Double()
    var dynamicsFactor = Double()
    var initialStandardDeviation = Double()
    
    init()
    {
        self.initialMean = 25.0;
        self.beta = self.initialMean/6.0;
        self.drawProbability = 0.00;
        self.dynamicsFactor = self.initialMean/300.0;
        self.initialStandardDeviation = self.initialMean/3.0;
    }
    
    convenience init(initialMean:Double, initialStandardDeviation:Double, beta:Double, dynamicFactor:Double, drawProbability:Double)
    {
        self.init()
        self.initialMean = initialMean;
        self.initialStandardDeviation = initialStandardDeviation;
        self.beta = beta;
        self.dynamicsFactor = dynamicFactor;
        self.drawProbability = drawProbability;
    }
}
