USE [OCC]
GO

/****** Object:  View [dbo].[vwDT4ResearchCatBenchmark]    Script Date: 1/4/2015 9:25:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[vwDT4ResearchCatBenchmark]
AS
 /* 
  DATE         		 DESC
  01/04/2014         Created for OCC webapp 

  NOTE to get the cummulative total,  do the recursive join on FY on the same table.

  select * from dt4ResearchCatBenchmark;
  select * from dt4PrimaryPurposebenchmark;
  select * from dt4Phasebenchmark;
  select * from dt4StudySourcebenchmark;

  Study Source was known as Sponsor
 */ 
   
   SELECT TOP 500
           dt4ResearchCatBenchmarkID AS ID, FY,  
		   ClinicalResearchCat, 
		   OpenTrialTotal, OpenTrialMedian, AccruedTotal, AccruedMedian
	FROM   dt4ResearchCatBenchmark d
	ORDER BY  FY DESC, ClinicalResearchCat 




GO


