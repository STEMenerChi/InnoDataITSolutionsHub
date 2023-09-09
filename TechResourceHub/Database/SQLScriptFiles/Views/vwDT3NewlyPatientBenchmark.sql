USE [OCC]
GO

/****** Object:  View [dbo].[vwDT3NewlyPatientBenchmark]    Script Date: 7/14/2023 9:51:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER VIEW [dbo].[vwDT3NewlyPatientBenchmark]
AS
 /* 
  DATE         		DESC
  12/21/2014        Created for OCC WebApp, 
  12/31/2014        Format number with Thousands separator? 10000 --> 10,000 
                    SELECT replace( convert( varchar(32), cast( '$' + cast( @MyValue AS varchar(32) ) AS money ), 1 ), '.00', '' )
  01/02/2014        Modified to return the  newly registered & enrolled patient numbers only, exclucing the top 20 data.
  07/14/2023        Removed enrolled patient info from the view

  NOTE: 
  1. Basic Centers are not required to report DT3.
  2. In order to perform ORDER BY in view, SELECT TOP is required.

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
            ID
	       ,[FY]       
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
           --,replace( convert( varchar(32), cast( '$' + cast( [ClinicalEnrollHigh] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [ClinicalEnrollHigh]
           --,replace( convert( varchar(32), cast( '$' + cast( [ClinicalEnrollLow] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [ClinicalEnrollLow]
           --,replace( convert( varchar(32), cast( '$' + cast( [ClinicalEnrollMedian] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [ClinicalEnrollMedian]
           --,replace( convert( varchar(32), cast( '$' + cast( [ClinicalEnrollSubtotal] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [ClinicalEnrollSubtotal]
           --,replace( convert( varchar(32), cast( '$' + cast( [CompEnrollHigh] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [CompEnrollHigh]
           --,replace( convert( varchar(32), cast( '$' + cast( [CompEnrollLow] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [CompEnrollLow]
           --,replace( convert( varchar(32), cast( '$' + cast( [CompEnrollMedian] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [CompEnrollMedian]
           --,replace( convert( varchar(32), cast( '$' + cast( [CompEnrollSubtotal] AS varchar(32) ) AS money ), 1 ), '.00', '' ) AS [CompEnrollSubtotal]
           ,replace( convert( varchar(32), cast( '$' + cast( SUM(ClinicalRegSubtotal + CompRegSubtotal  ) AS varchar(32) ) AS money ), 1 ), '.00', '' )   AS TotalReg
		   --,replace( convert( varchar(32), cast( '$' + cast( SUM(ClinicalEnrollSubtotal + CompEnrollSubtotal) AS varchar(32) ) AS money ), 1 ), '.00', '' )   as TotalEnroll
	FROM ( SELECT
	        DT3BenchMarkID AS ID
           ,[FY]
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
           --,[ClinicalEnrollHigh]
           --,[ClinicalEnrollLow]
           --,[ClinicalEnrollMedian]
           --,[ClinicalEnrollSubtotal]
           --,[CompEnrollHigh]
           --,[CompEnrollLow]
           --,[CompEnrollMedian]
           --,[CompEnrollSubtotal]
	FROM   DT3BenchMark
	WHERE  PrimarySite IS NULL
	) X
	  GROUP BY 
	       ID
	       ,[FY]         
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
           --,[ClinicalEnrollHigh]
           --,[ClinicalEnrollLow]
           --,[ClinicalEnrollMedian]
           --,[ClinicalEnrollSubtotal]
           --,[CompEnrollHigh]
           --,[CompEnrollLow]
           --,[CompEnrollMedian]
           --,[CompEnrollSubtotal]
	ORDER BY FY DESC;

	


GO


