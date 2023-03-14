module Main (main) where

import Auctions.Analytics
import Auctions.Parameterization
import Auctions.Strategies


main :: IO ()
main = do
--  putStrLn "Current Auction: "
--  printEquilibriumCurrentAuction parametersCurrentAuction (currentAuctionShareOfValueStrategy 0.75)
--  putStrLn "First Price Auction: "
--  printEquilibriumSimultaneousBidAuction parametersFPAuction (bidShareOfValueStrategyTuple 0.75)
--  putStrLn "Second Price Auction: "
--  printEquilibriumSimultaneousBidAuction parameters2ndPAuction truthTellingStrategyTuple
--  putStrLn "All pay Auction: "
--  printEquilibriumAllPayAuction parametersAllPayAuction (bidShareOfValueStrategyTuple 0.6)
  putStrLn "Simulate current auction outcome"
  printSimulationCurrentAuction parametersCurrentAuction (currentAuctionShareOfValueStrategy 0.75) 
