USE [OCC]
GO

/****** Object:  View [dbo].[vwDT2bBenchmark]    Script Date: 12/21/2014 6:52:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vwDT3Benchmark]
AS
 /* 
  DATE         		 DESC
  12/21/2014        Created for OCC WebApp, 
   12/31/2014        Format number with Thousands separator? 10000 --> 10,000 
                    SELECT replace( convert( varchar(32), cast( '$' + cast( @MyValue AS varchar(32) ) AS money ), 1 ), '.00', '' )

  NOTE: in order to perform ORDER BY in view, SELECT TOP is required.

  -- 4 Records, one per fy
  select * from dt3Benchmark
  where primarySite is null;

  --164 rows
  select * from dt3Benchmark
  where primarySite is not null;

  select FY, PrimarySite, RegisteredPatient, EnrolledPatient
  from dt3benchmark 
  where primarySite is not null
  order by FY, PrimarySite, RegisteredPatient, EnrolledPatient;
 */ 
  
   SELECT  Top 1000
	  [FY]
           ,[PrimarySite]
           ,replace( convert( varchar(32), cast( '$' + cast( [RegisteredPatient] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [RegisteredPatient]
           ,replace( convert( varchar(32), cast( '$' + cast( [EnrolledPatient] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [EnrolledPatient]
           ,[ClinicalCount]
		   ,replace( convert( varchar(32), cast( '$' + cast( ClinicalRegHigh AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS ClinicalRegHigh
           ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalRegLow] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [ClinicalRegLow]
           ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalRegMedian] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [ClinicalRegMedian]
           ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalRegSubtotal] AS varchar(32) ) AS money ), 1 ), '.00', '' )  AS [ClinicalRegSubtotal]
           ,[CompCount]
           ,replace( convert( varchar(32), cast( '$' + cast( [CompRegHigh] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [CompRegHigh]
           ,replace( convert( varchar(32), cast( '$' + cast( [CompRegLow] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [CompRegLow]
           ,replace( convert( varchar(32), cast( '$' + cast( [CompRegMedian] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [CompRegMedian]
           ,replace( convert( varchar(32), cast( '$' + cast( [CompRegSubtotal] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [CompRegSubtotal]
           ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalEnrollHigh] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [ClinicalEnrollHigh]
           ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalEnrollLow] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [ClinicalEnrollLow]
           ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalEnrollMedian] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [ClinicalEnrollMedian]
           ,replace( convert( varchar(32), cast( '$' + cast( [ClinicalEnrollSubtotal] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [ClinicalEnrollSubtotal]
           ,replace( convert( varchar(32), cast( '$' + cast( [CompEnrollHigh] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [CompEnrollHigh]
           ,replace( convert( varchar(32), cast( '$' + cast( [CompEnrollLow] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [CompEnrollLow]
           ,replace( convert( varchar(32), cast( '$' + cast( [CompEnrollMedian] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [CompEnrollMedian]
           ,replace( convert( varchar(32), cast( '$' + cast( [CompEnrollSubtotal] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [CompEnrollSubtotal]
           ,replace( convert( varchar(32), cast( '$' + cast( SUM(ClinicalRegSubtotal + CompRegSubtotal  ) AS varchar(32) ) AS money ), 1 ), '.00', '' )   AS TotalReg
		   ,replace( convert( varchar(32), cast( '$' + cast( SUM(ClinicalEnrollSubtotal + CompEnrollSubtotal) AS varchar(32) ) AS money ), 1 ), '.00', '' )   as TotalEnroll
	FROM ( SELECT
           [FY]
           ,[PrimarySite]
           ,[RegisteredPatient]
           ,[EnrolledPatient]
           ,[ClinicalCount]
           ,[ClinicalRegHigh]
           ,[ClinicalRegLow]
           ,[ClinicalRegMedian]
           ,[ClinicalRegSubtotal]
           ,[CompCount]
           ,[CompRegHigh]
           ,[CompRegLow]
           ,[CompRegMedian]
           ,[CompRegSubtotal]
           ,[ClinicalEnrollHigh]
           ,[ClinicalEnrollLow]
           ,[ClinicalEnrollMedian]
           ,[ClinicalEnrollSubtotal]
           ,[CompEnrollHigh]
           ,[CompEnrollLow]
           ,[CompEnrollMedian]
           ,[CompEnrollSubtotal]
	FROM   DT3BenchMark
	) X
	  GROUP BY [FY]
           ,[PrimarySite]
           ,[RegisteredPatient]
           ,[EnrolledPatient]
           ,[ClinicalCount]
           ,[ClinicalRegHigh]
           ,[ClinicalRegLow]
           ,[ClinicalRegMedian]
           ,[ClinicalRegSubtotal]
           ,[CompCount]
           ,[CompRegHigh]
           ,[CompRegLow]
           ,[CompRegMedian]
           ,[CompRegSubtotal]
           ,[ClinicalEnrollHigh]
           ,[ClinicalEnrollLow]
           ,[ClinicalEnrollMedian]
           ,[ClinicalEnrollSubtotal]
           ,[CompEnrollHigh]
           ,[CompEnrollLow]
           ,[CompEnrollMedian]
           ,[CompEnrollSubtotal]
	ORDER BY FY DESC
GO


