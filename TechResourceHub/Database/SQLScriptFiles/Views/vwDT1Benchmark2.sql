USE [OCC]
GO

/****** Object:  View [dbo].[vwDT1Benchmark]    Script Date: 12/16/2014 1:36:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER VIEW [dbo].[vwDT1Benchmark]
AS
 /* 
  DATE         		 DESC
  12/13/2014        Created for OCC WebApp

  a = leaders
  b = programs
  c = members
  d = SRs
  select * from dt1aBenchmark;
  select * from dt1bBenchmark;
  select * from dt1cBenchmark;
  select * from dt1dBenchmark;
 */ 
   
  select
   FY,	BasicCount,	ClinicalCount,	CompCount, 
   BasicHighLeader, BasicLowLeader,	BasicMedianLeader,	BasicSubLeader,	
   ClinicalHighLeader,	ClinicalLowLeader, ClinicalMedianLeader,ClinicalSubLeader,	
   CompHighLeader,	CompLowLeader,	CompMedianLeader,	CompSubLeader,	
   BasicHighProg,	BasicLowProg,	BasicMedianProg,	BasicSubProg,	
   ClinicalHighProg,	ClinicalLowProg,	ClinicalMedianProg,	ClinicalSubProg,	
   CompHighProg,	CompLowProg,	CompMedianProg,	CompSubProg,	
   BasicHighAlign,	BasicLowAlign,	BasicMedianAlign,	BasicSubAlign,	
   ClinicalHighAlign,	ClinicalLowAlign,	ClinicalMedianAlign,	ClinicalSubAlign,	
   CompHighAlign,	CompLowAlign,	CompMedianAlign,	CompSubAlign,	
   BasicHighNon,	BasicLowNon,	BasicMedianNon,	BasicSubNon,	
   ClinicalHighNon,	ClinicalLowNon,	ClinicalMedianNon,	ClinicalSubNon,	
   CompHighNon,	CompLowNon,	CompMedianNon,	CompSubNon,	
   BasicHighSR,	BasicLowSR,	BasicMedianSR,	BasicSubSR,	
   ClinicalHighSR,	ClinicalLowSR,	ClinicalMedianSR,	ClinicalSubSR,	
   CompHighSR,	CompLowSR,	CompMedianSR,	CompSubSR
   ,SUM(BasicSubLeader + ClinicalSubLeader + CompSubLeader) as TotalLeader
   ,SUM(BasicSubProg + ClinicalSubProg + CompSubProg) AS TotalProg
   ,SUM(BasicSubSR + ClinicalSubSR + CompSubSR) AS TotalSR
   ,SUM(BasicSubAlign + ClinicalSubAlign + CompSubAlign) AS TotalAlign
   ,SUM(BasicSubNon +  ClinicalSubNon + CompSubNon) AS TotalNon

   from 
   (SELECT  a.FY, a.BasicCount, a.ClinicalCount, a.CompCount,
           a.BasicHigh AS BasicHighLeader,a.BasicLow AS BasicLowLeader, a.BasicMedian AS BasicMedianLeader, a.BasicSubtotal as BasicSubLeader, 
		   a.ClinicalHigh AS ClinicalHighLeader,a.ClinicalLow AS ClinicalLowLeader, a.ClinicalMedian AS ClinicalMedianLeader, a.ClinicalSubtotal as ClinicalSubLeader, 
		   a.CompHigh AS CompHighLeader,a.CompLow AS CompLowLeader, a.CompMedian AS CompMedianLeader, a.CompSubtotal as CompSubLeader,

		   b.BasicHigh AS BasicHighProg,b.BasicLow AS BasicLowProg, b.BasicMedian AS BasicMedianProg, b.BasicSubtotal as BasicSubProg, 
		   b.ClinicalHigh AS ClinicalHighProg,b.ClinicalLow AS ClinicalLowProg, b.ClinicalMedian AS ClinicalMedianProg, b.ClinicalSubtotal as ClinicalSubProg, 
		   b.CompHigh AS CompHighProg ,b.CompLow AS CompLowProg, b.CompMedian AS CompMedianProg, b.CompSubtotal as CompSubProg,

		   c.AlignBasicHigh AS BasicHighAlign,c.AlignBasicLow AS BasicLowAlign, c.AlignBasicMedian AS BasicMedianAlign, c.AlignBasicSubtotal as BasicSubAlign, 
		   c.AlignClinicalHigh AS ClinicalHighAlign,c.AlignClinicalLow AS ClinicalLowAlign, c.AlignClinicalMedian AS ClinicalMedianAlign, c.AlignClinicalSubtotal as ClinicalSubAlign, 
		   c.AlignCompHigh AS CompHighAlign ,c.AlignCompLow AS CompLowAlign, c.AlignCompMedian AS CompMedianAlign, c.AlignCompSubtotal as CompSubAlign,

		   c.NonBasicHigh AS BasicHighNon,c.NonBasicLow AS BasicLowNon, c.NonBasicMedian AS BasicMedianNon, c.NonBasicSubtotal as BasicSubNon, 
		   c.NonClinicalHigh AS ClinicalHighNon,c.NonClinicalLow AS ClinicalLowNon, c.NonClinicalMedian AS ClinicalMedianNon, c.NonClinicalSubtotal as ClinicalSubNon, 
		   c.NonCompHigh AS CompHighNon ,c.NonCompLow AS CompLowNon, c.NonCompMedian AS CompMedianNon, c.NonCompSubtotal as CompSubNon,

		   
           d.BasicHigh AS BasicHighSR,d.BasicLow AS BasicLowSR, d.BasicMedian AS BasicMedianSR, d.BasicSubtotal as BasicSubSR, 
		   d.ClinicalHigh AS ClinicalHighSR,d.ClinicalLow AS ClinicalLowSR, d.ClinicalMedian AS ClinicalMedianSR, d.ClinicalSubtotal as ClinicalSubSR, 
		   d.CompHigh AS CompHighSR,d.CompLow AS CompLowSR, d.CompMedian AS CompMedianSR, d.CompSubtotal as CompSubSR

	FROM   DT1aBenchMark a,
	       DT1bBenchmark b, 
		   DT1cBenchmark c,
		   DT1dBenchmark d
	WHERE  a.FY = b.FY
	AND    b.FY = c.FY
	AND    c.FY = d.FY
	--AND    a.fy in (2013)
	) x
	
	Group by FY,	BasicCount,	ClinicalCount,	CompCount
	,BasicHighLeader, BasicLowLeader,	BasicMedianLeader,	BasicSubLeader,	
	 ClinicalHighLeader,	ClinicalLowLeader, 	 ClinicalMedianLeader,	ClinicalSubLeader,	
	 CompHighLeader,	CompLowLeader,	CompMedianLeader,	CompSubLeader,	
	 BasicHighProg,	BasicLowProg,	BasicMedianProg,	BasicSubProg,	
	 ClinicalHighProg,	ClinicalLowProg,	ClinicalMedianProg,	ClinicalSubProg,	
	 CompHighProg,	CompLowProg,	CompMedianProg,	CompSubProg,	
	 BasicHighAlign,	BasicLowAlign,	BasicMedianAlign,	BasicSubAlign,	
	 ClinicalHighAlign,	ClinicalLowAlign,	ClinicalMedianAlign,	ClinicalSubAlign,	
	 CompHighAlign,	CompLowAlign,	CompMedianAlign,	CompSubAlign,	
	 BasicHighNon,	BasicLowNon,	BasicMedianNon,	BasicSubNon,	
	 ClinicalHighNon,	ClinicalLowNon,	ClinicalMedianNon,	ClinicalSubNon,	
	 CompHighNon,	CompLowNon,	CompMedianNon,	CompSubNon,	
	 BasicHighSR,	BasicLowSR,	BasicMedianSR,	BasicSubSR,	
	 ClinicalHighSR,	ClinicalLowSR,	ClinicalMedianSR,	ClinicalSubSR,	
	 CompHighSR,	CompLowSR,	CompMedianSR,	CompSubSR

GO


