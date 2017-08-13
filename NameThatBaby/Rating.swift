//
//  Rating.swift
//  NameThatBaby
//
//  Created by Kevin DeRonne on 7/27/17.
//  Copyright © 2017 Kevin DeRonne. All rights reserved.
//

import Foundation

class Rating: NSObject
{
    let ConservativeStandardDeviationMultiplier = 3.0
    var _ConservativeStandardDeviationMultiplier = Double()
    var _Mean = Double()
    var _StandardDeviation = Double()
    
  
    
    /// <summary>
    /// Constructs a rating.
    /// </summary>
    /// <param name="mean">The statistical mean value of the rating (also known as μ).</param>
    /// <param name="standardDeviation">The standard deviation (the spread) of the rating (also known as σ).</param>
    /// <param name="conservativeStandardDeviationMultiplier">The number of <paramref name="standardDeviation"/>s to subtract from the <paramref name="mean"/> to achieve a conservative rating.</param>
    init(mean:Double, standardDeviation:Double, conservativeStandardDeviationMultiplier:Double) {
        self._Mean = mean
        self._StandardDeviation = standardDeviation
        self._ConservativeStandardDeviationMultiplier = conservativeStandardDeviationMultiplier
    }
    
    /// <summary>
    /// Constructs a rating.
    /// </summary>
    /// <param name="mean">The statistical mean value of the rating (also known as μ).</param>
    /// <param name="standardDeviation">The standard deviation of the rating (also known as σ).</param>
    convenience init(mean:Double, standardDeviation:Double) {
        self.init(mean:mean, standardDeviation:standardDeviation, conservativeStandardDeviationMultiplier: self.ConservativeStandardDeviationMultiplier)
    }
    
    /// <summary>
    /// The statistical mean value of the rating (also known as μ).
    /// </summary>
    func Mean() -> Double {
        return self._Mean
    }
    
    /// <summary>
    /// The standard deviation (the spread) of the rating. This is also known as σ.
    /// </summary>
    func StandardDeviation() -> Double {
        return self._StandardDeviation
    }
    
    /// <summary>
    /// A conservative estimate of skill based on the mean and standard deviation.
    /// </summary>
    func ConservativeRating() -> Double {
        return self._Mean - self._ConservativeStandardDeviationMultiplier*self._StandardDeviation
    }
    
    func GetPartialUpdate(prior:Rating, fullPosterior:Rating, updatePercentage:Double) -> Rating
    {
        let priorGaussian     = GaussianDistribution(mean: prior.Mean(),         standardDeviation: prior.StandardDeviation())
        let posteriorGaussian = GaussianDistribution(mean: fullPosterior.Mean(), standardDeviation: fullPosterior.StandardDeviation())
        
        // From a clarification email from Ralf Herbrich:
        // "the idea is to compute a linear interpolation between the prior and posterior skills of each player
        //  ... in the canonical space of parameters"
        
        let precisionDifference        = posteriorGaussian.precision - priorGaussian.precision
        let partialPrecisionDifference = updatePercentage*precisionDifference
        
        let precisionMeanDifference        = posteriorGaussian.precisionMean - priorGaussian.precisionMean
        let partialPrecisionMeanDifference = updatePercentage*precisionMeanDifference
        
        let partialPosteriorGaussion = GaussianDistribution().fromPrecisionMean(
            precisionMean: priorGaussian.precisionMean + partialPrecisionMeanDifference,
            precision: priorGaussian.precision + partialPrecisionDifference);
        
        return Rating(mean: partialPosteriorGaussion.mean, standardDeviation: partialPosteriorGaussion.standardDeviation,
                      conservativeStandardDeviationMultiplier: prior._ConservativeStandardDeviationMultiplier);
    }

}
