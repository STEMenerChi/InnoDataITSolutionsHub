USE [OCC]
GO

/****** Object:  View [dbo].[vwDT2bBenchmark]    Script Date: 12/31/2014 1:38:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vwDT2bBenchmark]
AS
 /* 
  DATE         		DESC
  12/20/2014        Created for OCC WebApp
  12/31/2014        Format number with Thousands separator? 10000 --> 10,000 
                    SELECT replace( convert( varchar(32), cast( '$' + cast( @MyValue AS varchar(32) ) AS money ), 1 ), '.00', '' )

  NOTE this is the total cost (TC)
 */ 
  
   SELECT  
       [FY]
      ,[BasicNCIHigh]
      ,[BasicNCILow]
      , [BasicNCIAvg]
      , [BasicNCIMedian]
      , [ClinicalNCIHigh]
      , [ClinicalNCILow]
      , [ClinicalNCIAvg]
      , [ClinicalNCIMedian]
      , [CompNCIHigh]
      , [CompNCILow]
      , [CompNCIAvg]
      , [CompNCIMedian]
      , [BasicCount]
      , [BasicNIHHigh]
      , [BasicNIHLow]
      , [BasicNIHAvg]
      , [BasicNIHMedian]
      , [ClinicalCount]
      , [ClinicalNIHHigh]
      , [ClinicalNIHLow]
      , [ClinicalNIHAvg]
      , [ClinicalNIHMedian]
      , [CompCount]
      , [CompNIHHigh]
      ,[CompNIHLow]
      , [CompNIHAvg]
      , [CompNIHMedian]
	FROM   DT2BBenchMark; 

GO


