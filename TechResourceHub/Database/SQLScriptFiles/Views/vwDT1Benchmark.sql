USE [OCC]
GO

/****** Object:  View [dbo].[vwDT1Benchmark]    Script Date: 2/15/2022 5:38:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER  VIEW [dbo].[vwDT1Benchmark]
AS
 /* 
  DATE         		 DESC
  12/17/2020
  02/15/2022         Remeber to insert FY, basic, clinical and comp count in dt1cbenchmark in order for this view to work

  NOTE, in order to perform ORDER BY FY DESC, SELECT TOP # statement is required.

  a = leaders
  b = programs
  c = members
  d = SRs
  select * from dt1aBenchmark;
  select * from dt1bBenchmark;
  select * from dt1cBenchmark;
  select * from dt1dBenchmark;
 */ 
   SELECT TOP 100
           a.FY, a.BasicCount, a.ClinicalCount, a.CompCount,
           a.BasicHigh AS BasicHighLeader,a.BasicLow AS BasicLowLeader, a.BasicMedian AS BasicMedianLeader, a.BasicSubtotal as BasicSubLeader, 
		   a.ClinicalHigh AS ClinicalHighLeader,a.ClinicalLow AS ClinicalLowLeader, a.ClinicalMedian AS ClinicalMedianLeader, a.ClinicalSubtotal as ClinicalSubLeader, 
		   a.CompHigh AS CompHighLeader,a.CompLow AS CompLowLeader, a.CompMedian AS CompMedianLeader, a.CompSubtotal as CompSubLeader,
		   a.Total as TotalLeader,
  
		
		   b.BasicHigh AS BasicHighProg,b.BasicLow AS BasicLowProg, b.BasicMedian AS BasicMedianProg, b.BasicSubtotal as BasicSubProg, 
		   b.ClinicalHigh AS ClinicalHighProg,b.ClinicalLow AS ClinicalLowProg, b.ClinicalMedian AS ClinicalMedianProg, b.ClinicalSubtotal as ClinicalSubProg, 
		   b.CompHigh AS CompHighProg ,b.CompLow AS CompLowProg, b.CompMedian AS CompMedianProg, b.CompSubtotal as CompSubProg,
		   b.Total AS TotalProg,
  

		   c.AlignBasicHigh AS BasicHighAlign,c.AlignBasicLow AS BasicLowAlign, c.AlignBasicMedian AS BasicMedianAlign, c.AlignBasicSubtotal as BasicSubAlign, 
		   c.AlignClinicalHigh AS ClinicalHighAlign,c.AlignClinicalLow AS ClinicalLowAlign, c.AlignClinicalMedian AS ClinicalMedianAlign, c.AlignClinicalSubtotal as ClinicalSubAlign, 
		   c.AlignCompHigh AS CompHighAlign ,c.AlignCompLow AS CompLowAlign, c.AlignCompMedian AS CompMedianAlign, c.AlignCompSubtotal as CompSubAlign,
		   c.alignTotal AS TotalAlign,
 

		   c.NonBasicHigh AS BasicHighNon,c.NonBasicLow AS BasicLowNon, c.NonBasicMedian AS BasicMedianNon, c.NonBasicSubtotal as BasicSubNon, 
		   c.NonClinicalHigh AS ClinicalHighNon,c.NonClinicalLow AS ClinicalLowNon, c.NonClinicalMedian AS ClinicalMedianNon, c.NonClinicalSubtotal as ClinicalSubNon, 
		   c.NonCompHigh AS CompHighNon ,c.NonCompLow AS CompLowNon, c.NonCompMedian AS CompMedianNon, c.NonCompSubtotal as CompSubNon,
		   c.nonAlignTotal AS TotalNon,

  	   
		   d.BasicHigh AS BasicHighSR,d.BasicLow AS BasicLowSR, d.BasicMedian AS BasicMedianSR, d.BasicSubtotal as BasicSubSR, 
		   d.ClinicalHigh AS ClinicalHighSR,d.ClinicalLow AS ClinicalLowSR, d.ClinicalMedian AS ClinicalMedianSR, d.ClinicalSubtotal as ClinicalSubSR, 
		   d.CompHigh AS CompHighSR,d.CompLow AS CompLowSR, d.CompMedian AS CompMedianSR, d.CompSubtotal as CompSubSR,
		   d.total AS TotalSR 
   FROM 
   DT1aBenchmark a,
   DT1bBenchmark b,
   DT1cBenchmark c,
   DT1dBenchmark d
   WHERE a.fy = b.fy
   AND   b.fy = d.fy
   AND   c.fy = d.fy
GO


