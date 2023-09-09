USE [OCC]
GO

/****** Object:  View [dbo].[vwDT1dSR4QV]    Script Date: 3/26/2014 7:43:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[vwDT1cMember]
AS
 /* 
  DATE      Name		 Desc
  3/25/2014 L.K. Weise   Trend data on NCI funding for 66 centers (excluding Kentucky and Kansas since they just become NCI-desinated in 2013)
                          FY2010- 2012
                         
  */ 

 
    -- 10 Records per FY. 
	 SELECT  d.FY, d.GrantNumber, c.InstitutionName,
	         d.AlignedNumber, d.NonAlignedNumber
	          
	FROM   DT1cMember d,
	       Center c

	WHERE  d.CenterID = c.CenterId
	AND    d.GrantNumber NOT IN  (168524, 177558)
	AND    d.isActive = 1
	GROUP BY  d.FY, d.GrantNumber, c.InstitutionName,
	         d.AlignedNumber, d.NonAlignedNumber
	          
GO

-- select * from vwDT1cMember;
