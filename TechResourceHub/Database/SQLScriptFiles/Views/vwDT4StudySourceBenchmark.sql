USE [OCC]
GO

/****** Object:  View [dbo].[vwDT4StudySourceBenchmark]    Script Date: 1/5/2015 10:01:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER VIEW [dbo].[vwDT4StudySourceBenchmark]
AS
 /* 
  DATE         		 DESC
  01/04/2014         Created for OCC webapp 

  Note to get the cummulative total,  do the recursive join on FY of the same table.

  select * from dt4ResearchCatBenchmark;
  select * from dt4PrimaryPurposebenchmark;
  select * from dt4Phasebenchmark;
  select * from dt4StudySourcebenchmark;

  Study Source was known as Sponsor
 */ 

   
   SELECT TOP 50
           d1.dt4StudySourcebenchmarkID AS ID, d1.FY,  
		   CASE d1.StudySourceCode
		        WHEN 'N' THEN 'National Cooperative Group' 
				WHEN 'E' THEN 'External Peer Reviewed'
				WHEN 'I' THEN 'Institutional'
				WHEN 'D' THEN 'Industry'
				ELSE 'Other/Unknown'
			END StudySource, 
			CASE d1.StudySourceCode
		        WHEN 'N' THEN 'N' 
				WHEN 'E' THEN 'E'
				WHEN 'I' THEN 'I'
				WHEN 'D' THEN 'D'
				ELSE 'Z'
			END AS SortOrder, 
			d1.OpenTrialTotal, d1.OpenTrialMedian, d1.AccruedTotal, d1.AccruedMedian, 
			SUM( d2.OpenTrialTotal) OpenTrialCumTotal,
			SUM( d2.AccruedTotal) AccruCumTotal
	FROM   dt4StudySourcebenchmark d1,
	       dt4StudySourcebenchmark d2
    WHERE  d1.FY = d2.FY
	GROUP BY d1.fy, d1.StudySourceCode, d1.OpenTrialTotal, d1.OpenTrialMedian, d1.AccruedTotal, d1.AccruedMedian, d1.dt4StudySourcebenchmarkID
	ORDER BY  d1.FY DESC, SortOrder

GO


