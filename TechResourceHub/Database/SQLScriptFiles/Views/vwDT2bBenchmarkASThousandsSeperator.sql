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
      ,replace( convert( varchar(32), cast( '$' + cast( [BasicNCIHigh] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [BasicNCIHigh]
      ,replace( convert( varchar(32), cast( '$' + cast( [BasicNCILow] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [BasicNCILow]
      ,replace( convert( varchar(32), cast( '$' + cast( [BasicNCIAvg] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [BasicNCIAvg]
      ,replace( convert( varchar(32), cast( '$' + cast( [BasicNCIMedian] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [BasicNCIMedian]
      ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalNCIHigh] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [ClinicalNCIHigh]
      ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalNCILow] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [ClinicalNCILow]
      ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalNCIAvg] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [ClinicalNCIAvg]
      ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalNCIMedian] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [ClinicalNCIMedian]
      ,replace( convert( varchar(32), cast( '$' + cast( [CompNCIHigh] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [CompNCIHigh]
      ,replace( convert( varchar(32), cast( '$' + cast( [CompNCILow] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [CompNCILow]
      ,replace( convert( varchar(32), cast( '$' + cast( [CompNCIAvg] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [CompNCIAvg]
      ,replace( convert( varchar(32), cast( '$' + cast( [CompNCIMedian] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [CompNCIMedian]
      ,replace( convert( varchar(32), cast( '$' + cast( [BasicCount] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [BasicCount]
      ,replace( convert( varchar(32), cast( '$' + cast( [BasicNIHHigh] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [BasicNIHHigh]
      ,replace( convert( varchar(32), cast( '$' + cast( [BasicNIHLow] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [BasicNIHLow]
      ,replace( convert( varchar(32), cast( '$' + cast( [BasicNIHAvg] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [BasicNIHAvg]
      ,replace( convert( varchar(32), cast( '$' + cast( [BasicNIHMedian] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [BasicNIHMedian]
      ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalCount] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [ClinicalCount]
      ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalNIHHigh] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [ClinicalNIHHigh]
      ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalNIHLow] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [ClinicalNIHLow]
      ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalNIHAvg] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [ClinicalNIHAvg]
      ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalNIHMedian] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [ClinicalNIHMedian]
      ,replace( convert( varchar(32), cast( '$' + cast( [CompCount] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [CompCount]
      ,replace( convert( varchar(32), cast( '$' + cast( [CompNIHHigh] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [CompNIHHigh]
      ,replace( convert( varchar(32), cast( '$' + cast( [CompNIHLow] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [CompNIHLow]
      ,replace( convert( varchar(32), cast( '$' + cast( [CompNIHAvg] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [CompNIHAvg]
      ,replace( convert( varchar(32), cast( '$' + cast( [CompNIHMedian] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [CompNIHMedian]
	FROM   DT2BBenchMark; 

GO


