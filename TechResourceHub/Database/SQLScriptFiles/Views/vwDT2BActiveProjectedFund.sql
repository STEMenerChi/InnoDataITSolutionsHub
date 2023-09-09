USE [OCC]
GO

/****** Object:  View [dbo].[vwBaseFund]    Script Date: 3/21/2014 3:40:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw2B4QlikView]
AS
 /*
  Purpose: for qlikview demo
  date: 3/21/2014
  Requestor: Hasnaa

  Compare the BaseFund (2001-2013) to  DT2B (active funded project from 2010-2013)) for the 10 following Centers:
  MSKCC (8748), Dana Farber (6516), UCSF (82103), UCSD (23100), UNC(16086), Duke(14236), UPenn (16520), U. of Chicago (14599), 
  MD Anderson (16672) and Mayo Clinic (15083).

  
 */ 
    -- 10 Records per FY. 
	SELECT  B.FY,  c.GrantNumber, c.InstitutionName, c.CenterId
	  ,[NCITotalNo]
      ,[NCIDC]
      ,[NCITC]
      ,[OthNIHTotalNo]
      ,[OthNIHDC]
      ,[OthNIHTC]
      ,[ACSPRTotalNo]
      ,[ACSPRDC]
      ,[ACSPRTC]
      ,[NSFTotalNo]
      ,[NSFPRDC]
      ,[NSFPRTC]
      ,[OthPRTotalNo]
      ,[OthPRDC]
      ,[OthPRTC]
      ,[IndNonPRTotalNo]
      ,[IndNonPRDC]
      ,[IndNonPRTC]
      ,[OthNonPRTotalNo]
      ,[OthNonPRDC]
      ,[OthNonPRTC]
	FROM   dt2B b,
	       Center   c
	WHERE  b.CenterID = c.CenterId
	AND    b.GrantNumber in (8748, 6516, 82103, 23100, 16086, 14236, 16520, 14599, 16672, 15083)
	AND    B.isActive = 'Y'
	--order by  b.fy, c.InstitutionName;


GO


