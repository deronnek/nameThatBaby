//
//  TruncatedGaussianCorrectionFunctions.swift
//  NameThatBaby
//
//  Created by Kevin DeRonne on 7/27/17.
//  Copyright © 2017 Kevin DeRonne. All rights reserved.
//

import Foundation

class TruncatedGaussianCorrectionFunctions: NSObject
{
    // These functions from the bottom of page 4 of the TrueSkill paper.
    
    /// <summary>
    /// The "V" function where the team performance difference is greater than the draw margin.
    /// </summary>
    /// <remarks>In the reference F# implementation, this is referred to as "the additive
    /// correction of a single-sided truncated Gaussian with unit variance."</remarks>
    /// <param name="teamPerformanceDifference"></param>
    /// <param name="drawMargin">In the paper, it's referred to as just "ε".</param>
    /// <returns></returns>
    func vExceedsMargin(teamPerformanceDifference:Double, drawMargin:Double, c:Double) -> Double {
        return vExceedsMargin(teamPerformanceDifference:teamPerformanceDifference/c, drawMargin:drawMargin/c)
        //return GaussianDistribution.At((teamPerformanceDifference - drawMargin) / c) / GaussianDistribution.CumulativeTo((teamPerformanceDifference - drawMargin) / c);
    }
    
    func vExceedsMargin(teamPerformanceDifference:Double, drawMargin:Double) -> Double {
        let denominator = GaussianDistribution().cumulativeTo(x: teamPerformanceDifference - drawMargin)
    
        if (denominator < 2.222758749e-162) {
            return -teamPerformanceDifference + drawMargin
        }
        
        return GaussianDistribution().at(x: teamPerformanceDifference - drawMargin)/denominator
        }
    
    /// <summary>
    /// The "W" function where the team performance difference is greater than the draw margin.
    /// </summary>
    /// <remarks>In the reference F# implementation, this is referred to as "the multiplicative
    /// correction of a single-sided truncated Gaussian with unit variance."</remarks>
    /// <param name="teamPerformanceDifference"></param>
    /// <param name="drawMargin"></param>
    /// <param name="c"></param>
    /// <returns></returns>
    func wExceedsMargin(teamPerformanceDifference:Double, drawMargin:Double, c:Double) -> Double {
    
        return self.wExceedsMargin(teamPerformanceDifference: teamPerformanceDifference/c, drawMargin: drawMargin/c)
    //var vWin = VExceedsMargin(teamPerformanceDifference, drawMargin, c);
    //return vWin * (vWin + (teamPerformanceDifference - drawMargin) / c);
    }
    
    func wExceedsMargin(teamPerformanceDifference:Double, drawMargin:Double) -> Double {
    
        let denominator = GaussianDistribution().cumulativeTo(x: teamPerformanceDifference - drawMargin)
    
        if (denominator < 2.222758749e-162)
        {
            if (teamPerformanceDifference < 0.0)
            {
                return 1.0;
            }
            return 0.0;
        }
    
        let vWin = self.vExceedsMargin(teamPerformanceDifference: teamPerformanceDifference, drawMargin: drawMargin);
        return vWin*(vWin + teamPerformanceDifference - drawMargin)
    }
    
    // the additive correction of a double-sided truncated Gaussian with unit variance
    func vWithinMargin(teamPerformanceDifference:Double, drawMargin:Double, c:Double) -> Double
    {
        return self.vWithinMargin(teamPerformanceDifference: teamPerformanceDifference/c, drawMargin: drawMargin/c)
    }
    
    // from F#:
    func vWithinMargin(teamPerformanceDifference:Double, drawMargin:Double) -> Double {
        let teamPerformanceDifferenceAbsoluteValue = abs(teamPerformanceDifference)
        let denominator =
            GaussianDistribution().cumulativeTo(x: drawMargin - teamPerformanceDifferenceAbsoluteValue) -
                GaussianDistribution().cumulativeTo(x: -drawMargin - teamPerformanceDifferenceAbsoluteValue)
        
        if (denominator < 2.222758749e-162)
        {
            if (teamPerformanceDifference < 0.0)
            {
                return -teamPerformanceDifference - drawMargin
            }
        
            return -teamPerformanceDifference + drawMargin
        }
        
        let numerator = GaussianDistribution().at(x: -drawMargin - teamPerformanceDifferenceAbsoluteValue) -
        GaussianDistribution().at(x: drawMargin - teamPerformanceDifferenceAbsoluteValue);
        
        if (teamPerformanceDifference < 0.0)
        {
            return -numerator/denominator
        }
        
        return numerator/denominator
    }
    
    // the multiplicative correction of a double-sided truncated Gaussian with unit variance
    func  wWithinMargin(teamPerformanceDifference:Double, drawMargin:Double, c:Double) -> Double {
        return self.wWithinMargin(teamPerformanceDifference: teamPerformanceDifference/c, drawMargin: drawMargin/c)
    }

    func wWithinMargin(teamPerformanceDifference:Double, drawMargin:Double) -> Double {
        let teamPerformanceDifferenceAbsoluteValue = abs(teamPerformanceDifference)
        let denominator = GaussianDistribution().cumulativeTo(x: drawMargin - teamPerformanceDifferenceAbsoluteValue) -
            GaussianDistribution().cumulativeTo(x: -drawMargin - teamPerformanceDifferenceAbsoluteValue)
    
    if (denominator < 2.222758749e-162)
    {
        return 1.0;
    }
    
    let vt = self.vWithinMargin(teamPerformanceDifference: teamPerformanceDifferenceAbsoluteValue, drawMargin: drawMargin);
    
        return vt*vt +
    (
        (drawMargin - teamPerformanceDifferenceAbsoluteValue)
            *
            GaussianDistribution().at(x: drawMargin - teamPerformanceDifferenceAbsoluteValue) - (-drawMargin - teamPerformanceDifferenceAbsoluteValue)
            *
            GaussianDistribution().at(x: -drawMargin - teamPerformanceDifferenceAbsoluteValue)
    )/denominator;
    }
}
