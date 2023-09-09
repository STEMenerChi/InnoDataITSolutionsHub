USE [OCC]
GO

/****** Object:  View [dbo].[vwDT4PrimaryPurposeBenchmark]    Script Date: 1/4/2015 9:21:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[vwDT4PrimaryPurposeBenchmark]
AS
 /* 
  DATE         		 DESC
  01/04/2014         Created for OCC webapp 

  NOTE to get the cummulative total,  do the recursive join on FY on the same table.

  Study Source was known as Sponsor
  select * from dt4StudySourcebenchmark;

  select * from dt4ResearchCatBenchmark;
  select * from dt4PrimaryPurposebenchmark;
  select * from dt4Phasebenchmark;

 */ 
   
   SELECT TOP 500
           d1.dt4PrimaryPurposebenchmarkID AS ID, d1.FY,  
		   d1.PrimaryPurpose, 		  
		   CASE d1.PrimaryPurpose
		        WHEN 'Anc/Comp/Cor' then 'A' 
				WHEN 'Epi/Obs/Out' then 'E'
				WHEN 'Pre' then 'P'
				WHEN 'Scr/Det/Dia' then 'S' 
				WHEN 'Sup/QOL' then 'Su'
				WHEN 'The' then 'T'
				ELSE 'Z' 
			END AS SortOrder,
		   d1.OpenTrialTotal, d1.OpenTrialMedian, d1.AccruedTotal, d1.AccruedMedian,
		   SUM(d2.OpenTrialTotal) AS OpenTrialCumTotal, 
		   SUM(d2.AccruedTotal) AS AccruCumTotal
	FROM   dt4PrimaryPurposebenchmark d1,
	       dt4PrimaryPurposebenchmark d2
	WHERE  d1.fy = d2.fy
	GROUP BY d1.FY, d1.PrimaryPurpose, 	d1.OpenTrialTotal, d1.OpenTrialMedian, d1.AccruedTotal, d1.AccruedMedian, d1.dt4PrimaryPurposebenchmarkID  	  
	ORDER BY d1.FY DESC, SortOrder


GO


