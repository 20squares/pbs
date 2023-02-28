{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE MultiParamTypeClasses, FlexibleInstances, FlexibleContexts, TemplateHaskell #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE QuasiQuotes #-}


module Auctions.SimultaneousBidAuction
  where


import OpenGames.Engine.Engine
import OpenGames.Preprocessor
import Auctions.AuctionSupportFunctions

----------
-- A Model
----------

---------------
-- 0 Parameters

-- tbd

---------------
-- 1 Components

-- Draws a value and creates a pair of _value_ _name_
natureDrawsTypeStage name valueSpace = [opengame|

    inputs    :   ;
    feedback  :   ;

    :-----:
    inputs    :   ;
    feedback  :   ;
    operation : nature (uniformDist valueSpace) ;
    outputs   : value ;
    returns   :  ;
    :-----:

    outputs   :  (name,value) ;
    returns   :    ;
  |]

-- Individual bidding stage
biddingStage name actionSpace = [opengame|

    inputs    :  nameValuePair  ;
    feedback  :   ;

    :---------------------------:
    inputs    :  nameValuePair  ;
    feedback  :   ;
    operation :  dependentDecision name (const actionSpace) ;
    outputs   :  bid ;
    returns   :  setPayoff nameValuePair payments  ;
    :---------------------------:

    outputs   :  bid ;
    returns   :  payments  ;
  |]


-- Transforms the bids and the relevant reservePrice into the payments by players
transformPaymentsReservePrice winningPrice  = [opengame|

   inputs    : (bids,reservePrice) ;
   feedback  :      ;

   :-----------------:
   inputs    : (bids,reservePrice) ;
   feedback  :      ;
   operation : forwardFunction (auctionPaymentResPrice paymentReservePrice winningPrice) ;
   outputs   : payments ;
   returns   :      ;
   :-----------------:

   outputs   : payments ;
   returns   :      ;
  |]

-- Transforms the bids into a random reshuffling
transformPayments winningPrice reservePrice = [opengame|

   inputs    : bids ;
   feedback  :      ;

   :-----------------:
   inputs    : (bids, reservePrice) ;
   feedback  :      ;
   operation : forwardFunction (auctionPaymentResPrice paymentReservePrice winningPrice) ;
   outputs   : payments ;
   returns   :      ;
   :-----------------:

   outputs   : payments ;
   returns   :      ;
  |]

-- Transforms the bids into a random reshuffling
transformAllPayPayments  = [opengame|

   inputs    : bids ;
   feedback  :      ;

   :-----------------:
   inputs    : bids ;
   feedback  :      ;
   operation : forwardFunction auctionPaymentAllPay ;
   outputs   : payments ;
   returns   :      ;
   :-----------------:

   outputs   : payments ;
   returns   :      ;
  |]


  
-----------------------
-- 2 Assembled auctions

-- 2 players with reserve price
-- NOTE this format allows for first price, second price w/o reserve price
bidding2ReservePrice winningPrice valueSpace1 valueSpace2 actionSpace1 actionSpace2 = [opengame| 

   inputs    : reservePrice    ;
   feedback  :      ;

   :-----------------:
   inputs    :      ;
   feedback  :      ;
   operation : natureDrawsTypeStage "Relayn" valueSpace1 ;
   outputs   :  aliceValue ;
   returns   :      ;

   inputs    :      ;
   feedback  :      ;
   operation : natureDrawsTypeStage "Builderm" valueSpace2;
   outputs   :  bobValue ;
   returns   :      ;

   inputs    :  aliceValue    ;
   feedback  :      ;
   operation :  biddingStage "Relayn" actionSpace1 ;
   outputs   :  aliceDec ;
   returns   :  payments  ;

   inputs    :  bobValue    ;
   feedback  :      ;
   operation :  biddingStage "Builderm" actionSpace2 ;
   outputs   :  bobDec ;
   returns   :  payments  ;

   inputs    :  ([("Relayn",aliceDec),("Builderm",bobDec)],reservePrice)  ;
   feedback  :      ;
   operation :  transformPaymentsReservePrice winningPrice  ;
   outputs   :  payments ;
   returns   :      ;
   :-----------------:

   outputs   :  payments    ;
   returns   :      ;
   |]



-- 2 players with exogenous reserve price
-- NOTE this format allows for first price, second price w/o reserve price
bidding2ReservePriceExogenous winningPrice reservePrice valueSpace1 valueSpace2 actionSpace1 actionSpace2  = [opengame| 

   inputs    :      ;
   feedback  :      ;

   :-----------------:
   inputs    :      ;
   feedback  :      ;
   operation : natureDrawsTypeStage "Relayn" valueSpace1 ;
   outputs   :  aliceValue ;
   returns   :      ;

   inputs    :      ;
   feedback  :      ;
   operation : natureDrawsTypeStage "Builderm" valueSpace2 ;
   outputs   :  bobValue ;
   returns   :      ;

   inputs    :  aliceValue    ;
   feedback  :      ;
   operation :  biddingStage "Relayn" actionSpace1 ;
   outputs   :  aliceDec ;
   returns   :  payments  ;

   inputs    :  bobValue    ;
   feedback  :      ;
   operation :  biddingStage "Builderm" actionSpace2 ;
   outputs   :  bobDec ;
   returns   :  payments  ;

   inputs    :  [("Relayn",aliceDec),("Builderm",bobDec)]  ;
   feedback  :      ;
   operation :   transformPayments winningPrice reservePrice ;
   outputs   :  payments ;
   returns   :      ;
   :-----------------:

   outputs   :      ;
   returns   :      ;
   |]

-- 3 allpay auction with 2 players
bidding2AllPay  valueSpace1 valueSpace2 actionSpace1 actionSpace2  = [opengame| 

   inputs    :      ;
   feedback  :      ;

   :-----------------:
   inputs    :      ;
   feedback  :      ;
   operation : natureDrawsTypeStage "Relayn" valueSpace1 ;
   outputs   :  aliceValue ;
   returns   :      ;

   inputs    :      ;
   feedback  :      ;
   operation : natureDrawsTypeStage "Builderm" valueSpace2 ;
   outputs   :  bobValue ;
   returns   :      ;

   inputs    :  aliceValue    ;
   feedback  :      ;
   operation :  biddingStage "Relayn" actionSpace1 ;
   outputs   :  aliceDec ;
   returns   :  payments  ;

   inputs    :  bobValue    ;
   feedback  :      ;
   operation :  biddingStage "Builderm" actionSpace2 ;
   outputs   :  bobDec ;
   returns   :  payments  ;

   inputs    :  [("Relayn",aliceDec),("Builderm",bobDec)]  ;
   feedback  :      ;
   operation :  transformAllPayPayments ;
   outputs   :  payments ;
   returns   :      ;
   :-----------------:

   outputs   :      ;
   returns   :      ;
   |]

