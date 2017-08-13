//
//  GaussianDistribution.swift
//  NameThatBaby
//
//  Created by Kevin DeRonne on 7/25/17.
//  Copyright © 2017 Kevin DeRonne. All rights reserved.
// TruncatedGaussianCorrectionFunctions.VExceedsMargin
// TruncatedGaussianCorrectionFunctions.WExceedsMargin
// TruncatedGaussianCorrectionFunctions.VWithinMargin
// TruncatedGaussianCorrectionFunctions.WWithinMargin

import Foundation

class GaussianDistribution: NSObject
{
    var mean              = Double()
    var standardDeviation = Double()
    var variance          = Double()
    var precision         = Double()
    var precisionMean     = Double()
    
    override init() {
        
    }
    
    init(mean:Double, standardDeviation:Double) {
        self.mean = mean
        self.standardDeviation = standardDeviation
        self.variance = standardDeviation*standardDeviation
        self.precision = 1.0/self.variance
        self.precisionMean = precision*mean
    }
    
    func errorFunctionCumulativeTo(x:Double) -> Double {
        // Derived from page 265 of Numerical Recipes 3rd Edition
        let z  = abs(x)
        let t  = 2.0/(2.0 + z)
        let ty = 4*t - 2
        
        let coefficients = [
            -1.3026537197817094, 6.4196979235649026e-1,
            1.9476473204185836e-2, -9.561514786808631e-3, -9.46595344482036e-4,
            3.66839497852761e-4, 4.2523324806907e-5, -2.0278578112534e-5,
            -1.624290004647e-6, 1.303655835580e-6, 1.5626441722e-8, -8.5238095915e-8,
            6.529054439e-9, 5.059343495e-9, -9.91364156e-10, -2.27365122e-10,
            9.6467911e-11, 2.394038e-12, -6.886027e-12, 8.94487e-13, 3.13092e-13,
            -1.12708e-13, 3.81e-16, 7.106e-15, -1.523e-15, -9.4e-17, 1.21e-16, -2.8e-17
        ]
        
        let ncof = coefficients.count
        var d    = 0.0
        var dd   = 0.0
        
        
        for j in (1...(ncof - 1)).reversed() {
            let tmp = d
            d = ty*d - dd + coefficients[j]
            dd = tmp
        }
        
        let ans = t*exp(-z*z + 0.5*(coefficients[0] + ty*d) - dd)
        
        return x >= 0.0 ? ans : (2.0 - ans)
    }
    
    func cumulativeTo(x:Double) -> Double {
        return self.cumulativeTo(x: x, mean: 0.0, standardDeviation: 1.0)
    }
    
    func cumulativeTo(x:Double, mean:Double, standardDeviation: Double) -> Double {
        
        let invsqrt2 = -0.707106781186547524400844362104
        let result = errorFunctionCumulativeTo(x: invsqrt2*x)
        
        return 0.5*result
    }
    
    func at(x:Double) -> Double {
        return self.at(x:x, mean: 0.0, standardDeviation: 1.0)
    }
    
    func at(x:Double, mean:Double, standardDeviation:Double) -> Double {
        // See http://mathworld.wolfram.com/NormalDistribution.html
        //                1              -(x-mean)^2 / (2*stdDev^2)
        // P(x) = ------------------- * e
        //        stdDev * sqrt(2*pi)
        
        let multiplier = 1.0/(standardDeviation*sqrt(2*Double.pi))
        let expPart    = exp((-1.0*pow(x - mean, 2.0))/(2*(standardDeviation*standardDeviation)))
        let result     = multiplier*expPart
        
        return result
    }
    
    func inverseErrorFunctionCumulativeTo(p:Double) -> Double {
        // From page 265 of numerical recipes
        
        if (p >= 2.0)
        {
            return -100
        }
        if (p <= 0.0)
        {
            return 100
        }
        
        let pp = (p < 1.0) ? p : 2 - p
        let t = sqrt(-2*log(pp/2.0)); // Initial guess
        var x = -0.70711*((2.30753 + t*0.27061)/(1.0 + t*(0.99229 + t*0.04481)) - t)
        
        for _ in 0...2
        {
            let err = self.errorFunctionCumulativeTo(x: x) - pp
            x += err/(1.12837916709551257*exp(-(x*x)) - x*err) // Halley
        }
        
        return p < 1.0 ? x : -x
    }
    
    func inverseCumulativeTo(x:Double, mean:Double, standardDeviation:Double) -> Double {
        // From numerical recipes, page 320
        return mean - sqrt(2)*standardDeviation*inverseErrorFunctionCumulativeTo(p: 2*x)
    }
    
    func getDrawMarginFromDrawProbability(drawProbability:Double, beta:Double) -> Double {
        // Derived from TrueSkill technical report (MSR-TR-2006-80), page 6
        
        // draw probability = 2 * CDF(margin/(sqrt(n1+n2)*beta))-1
        
        // implies
        //
        // margin = inversecdf((draw probability + 1)/2) * sqrt(n1+n2) * beta
        // n1 and n2 are the number of players on each team
        let margin = self.inverseCumulativeTo(x: 0.5*(drawProbability + 1), mean: 0, standardDeviation: 1)*sqrt(1 + 1)*beta
        
        return margin;
    }
    
    func fromPrecisionMean(precisionMean:Double, precision:Double) -> GaussianDistribution
    {
        let mean = precisionMean/precision
        let gaussianDistribution = GaussianDistribution(mean:mean, standardDeviation:sqrt(1.0/precision))
        gaussianDistribution.precision = precision
        gaussianDistribution.precisionMean = precisionMean
        gaussianDistribution.variance = 1.0/precision

        return gaussianDistribution
    }

}
