USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspPersonDegree]    Script Date: 11/27/2012 14:31:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date: 03/09/2012
-- Description:	Update the grantNumber in P30RatioFy2011 according to the grantnumber in the Center table.
-- =============================================
CREATE PROCEDURE  [dbo].[uspGetTotalMedianMemberProgSR]
AS
BEGIN

SELECT 
      [BasicCount]
      ,[BasicHigh]
      ,[BasicLow]
      ,[BasicMedian]
      ,[BasicSubtotal]
      ,[ClinicalCount]
      ,[ClinicalHigh]
      ,[ClinicalLow]
      ,[ClinicalMedian]
      ,[ClinicalSubtotal]
      ,[CompCount]
      ,[CompHigh]
      ,[CompLow]
      ,[CompMedian]
      ,[CompSubtotal]
  FROM [OCC].[dbo].[DT1bBenchMark]
  where FY = 2011
  union
  SELECT [AlignBasicCount]
      ,[AlignBasicHigh]
      ,[AlignBasicLow]
      ,[AlignBasicMedian]
      ,[AlignBasicSubtotal]
      ,[AlignClinicalCount]
      ,[AlignClinicalHigh]
      ,[AlignClinicalLow]
      ,[AlignClinicalMedian]
      ,[AlignClinicalSubtotal]
      ,[AlignCompCount]
      ,[AlignCompHigh]
      ,[AlignCompLow]
      ,[AlignCompMedian]
      ,[AlignCompSubtotal]
  FROM [OCC].[dbo].[DT1cBenchMark]
  where FY = 2011
  union
    SELECT   
      [NonBasicCount]
      ,[NonBasicHigh]
      ,[NonBasicLow]
      ,[NonBasicMedian]
      ,[NonBasicSubtotal]
      ,[NonClinicalCount]
      ,[NonClinicalHigh]
      ,[NonClinicalLow]
      ,[NonClinicalMedian]
      ,[NonClinicalSubtotal]
      ,[NonCompCount]
      ,[NonCompHigh]
      ,[NonCompLow]
      ,[NonCompMedian]
      ,[NonCompSubtotal]
  FROM [OCC].[dbo].[DT1cBenchMark]
  where FY = 2011
  union
  SELECT 
      [BasicCount]
      ,[BasicHigh]
      ,[BasicLow]
      ,[BasicMedian]
      ,[BasicSubtotal]
      ,[ClinicalCount]
      ,[ClinicalHigh]
      ,[ClinicalLow]
      ,[ClinicalMedian]
      ,[ClinicalSubtotal]
      ,[CompCount]
      ,[CompHigh]
      ,[CompLow]
      ,[CompMedian]
      ,[CompSubtotal]
  FROM [OCC].[dbo].[DT1dBenchMark]
  where FY = 2011;
  
  END