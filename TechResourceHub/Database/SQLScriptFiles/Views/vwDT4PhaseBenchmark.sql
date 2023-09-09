USE [OCC]
GO

/****** Object:  View [dbo].[vwDT4PhaseBenchmark]    Script Date: 1/4/2015 9:15:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vwDT4PhaseBenchmark]
AS
 /* 
  DATE         		 DESC
  01/04/2014         Created for OCC webapp 

  Note to get the cummulative total,  do the recursive join on FY of the same table.

  Study Source was known as Sponsor
  select * from dt4StudySourcebenchmark;

  select * from dt4ResearchCatBenchmark;
  select * from dt4PrimaryPurposebenchmark;
  select * from dt4Phasebenchmark;

 */ 
   
   SELECT TOP 500
           d1.dt4PhasebenchmarkID AS ID, d1.FY,  
		   d1.Phase,
		   CASE d1.phase
		        WHEN '0' then '0' 
				WHEN 'I' then 'I'
				WHEN 'II' then 'II'
				WHEN 'I/II' then 'I/II' 
				WHEN 'II/III' then 'II/III'
				WHEN 'III' then 'III'
				WHEN 'III/IV' then 'III/IV' 
				WHEN 'IV' then 'IV'
				WHEN 'IV/V' then 'IV/V'
				WHEN 'V' then 'V' 
				WHEN 'Pilot/Feasibility' then 'Y'
				ELSE 'Z' 
			END AS SortOrder,
		    d1.OpenTrialTotal, d1.OpenTrialMedian, d1.AccruedTotal, d1.AccruedMedian,
			SUM(d2.OpenTrialTotal) as OpenTrialCumTotal,
			SUM(d2.AccruedTotal) as AccruCumTotal
	FROM   dt4Phasebenchmark d1,
	       dt4Phasebenchmark d2
    WHERE d1.fy = d2.fy
	GROUP BY d1.FY, d1.Phase, d1.OpenTrialTotal, d1.OpenTrialMedian, d1.AccruedTotal, d1.AccruedMedian, d1.dt4PhasebenchmarkID
	ORDER BY  d1.FY DESC, SortOrder

GO


