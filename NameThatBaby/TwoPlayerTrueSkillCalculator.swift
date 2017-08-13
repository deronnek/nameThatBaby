//
//  TwoPlayerTrueSkillCalculator.swift
//  NameThatBaby
//
//  Created by Kevin DeRonne on 7/27/17.
//  Copyright © 2017 Kevin DeRonne. All rights reserved.
//

import Foundation

enum PairwiseComparison {
    case Win
    case Draw
    case Lose
}

    /// <summary>
    /// Calculates the new ratings for only two players.
    /// </summary>
    /// <remarks>
    /// When you only have two players, a lot of the math simplifies. The main purpose of this class
    /// is to show the bare minimum of what a TrueSkill implementation should have.
    /// </remarks>
class TwoPlayerTrueSkillCalculator : NSObject {


    func CalculateNewRatings(gameInfo: GameInfo, winningTeam: (Int, Rating), losingTeam: (Int, Rating), teamRanks: [Int]) -> [Int: Rating] {
            
            // Make sure things are in order
            //RankSorter.Sort(teams, teamRanks)
            
            // Since we verified that each team has one player, we know the player is the first one
            let winner = winningTeam.0
            let winnerPreviousRating = winningTeam.1
        
            let loser = losingTeam.0
            let loserPreviousRating = losingTeam.1
            
            let wasDraw = (teamRanks[0] == teamRanks[1])
        
            var results = [Int: Rating]()
            results[winner] = CalculateNewRating(gameInfo: gameInfo, selfRating: winnerPreviousRating, opponentRating: loserPreviousRating, comparison: wasDraw ? PairwiseComparison.Draw : PairwiseComparison.Win)
            results[loser]  = CalculateNewRating(gameInfo: gameInfo, selfRating: loserPreviousRating, opponentRating: winnerPreviousRating, comparison: wasDraw ? PairwiseComparison.Draw : PairwiseComparison.Lose)
            
            // And we're done!
            return results;
    }
        
    func CalculateNewRating(gameInfo:GameInfo, selfRating:Rating, opponentRating:Rating,
                            comparison:PairwiseComparison) -> Rating
        {
            let drawMargin = GaussianDistribution().getDrawMarginFromDrawProbability(drawProbability: gameInfo.drawProbability, beta: gameInfo.beta);
            
            let c =
            sqrt(
            selfRating.StandardDeviation()*selfRating.StandardDeviation()
            +
            opponentRating.StandardDeviation()*opponentRating.StandardDeviation()
            +
            2*gameInfo.beta*gameInfo.beta)
            
            var winningMean = selfRating.Mean()
            var losingMean  = opponentRating.Mean()
                
            switch (comparison)
            {
                case .Win:
                    break
                case .Draw:
                    // NOP
                    break
                case .Lose:
                    winningMean = opponentRating.Mean()
                    losingMean  = selfRating.Mean()
                break
            }
            
            let meanDelta = winningMean - losingMean
            var v = Double()
            var w = Double()
            var rankMultiplier = Int()
            if (comparison != .Draw)
            {
            // non-draw case
                v = TruncatedGaussianCorrectionFunctions().vExceedsMargin(teamPerformanceDifference: meanDelta, drawMargin: drawMargin, c: c)
                w = TruncatedGaussianCorrectionFunctions().wExceedsMargin(teamPerformanceDifference: meanDelta, drawMargin: drawMargin, c: c)
                rankMultiplier = (comparison == .Win ? 1 : -1)
            }
            else
            {
                v = TruncatedGaussianCorrectionFunctions().vWithinMargin(teamPerformanceDifference: meanDelta, drawMargin: drawMargin, c: c)
                w = TruncatedGaussianCorrectionFunctions().wWithinMargin(teamPerformanceDifference: meanDelta, drawMargin: drawMargin, c: c)
                rankMultiplier = 1
            }
            
            let meanMultiplier = (selfRating.StandardDeviation()*selfRating.StandardDeviation() + gameInfo.dynamicsFactor*gameInfo.dynamicsFactor)/c;
            
            let varianceWithDynamics = selfRating.StandardDeviation()*selfRating.StandardDeviation() + gameInfo.dynamicsFactor*gameInfo.dynamicsFactor
            let stdDevMultiplier = varianceWithDynamics/(c*c);
            
            let newMean = selfRating.Mean() + Double(rankMultiplier)*meanMultiplier*v
            let newStdDev = sqrt(varianceWithDynamics*(1 - w*stdDevMultiplier))
            
            return Rating(mean: newMean, standardDeviation: newStdDev)
        }
        
        /// <inheritdoc/>
    func CalculateMatchQuality(gameInfo:GameInfo, player1Rating:Rating, player2Rating:Rating) -> Double {
            
            // We just use equation 4.1 found on page 8 of the TrueSkill 2006 paper:
            let betaSquared = gameInfo.beta*gameInfo.beta
            let player1SigmaSquared = player1Rating.StandardDeviation()*player1Rating.StandardDeviation()

            let player2SigmaSquared = player2Rating.StandardDeviation()*player2Rating.StandardDeviation()
            
            // This is the square root part of the equation:
            let sqrtPart =
            sqrt((2*betaSquared)/(2*betaSquared + player1SigmaSquared + player2SigmaSquared))
            
            // This is the exponent part of the equation:
            let expNum   = -1*pow((player1Rating.Mean() - player2Rating.Mean()), 2)
            let expDenom = 2*(2*betaSquared + player1SigmaSquared + player2SigmaSquared)
            let expPart  = exp(expNum / expDenom)
            
        return sqrtPart*expPart;
    }
}
