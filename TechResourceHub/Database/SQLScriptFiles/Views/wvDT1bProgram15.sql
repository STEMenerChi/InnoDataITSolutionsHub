USE [OCC]
GO

/****** Object:  View [dbo].[vwDT1bProgram]    Script Date: 1/20/2016 6:38:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [dbo].[vwDT1bProgram]
AS
 /* 
  DATE         		 DESC
  05/15/2014         Created this view for Research Program report (QlikView)
  11/22/2014		 Modified for SR report to be posted on the web.
  12/07/2015         Added FY = 2014
 */ 

 
    -- 10 Records per FY. 
   SELECT  d.FY, d.ProgCode, d.ProgName, NoOfMembers,  isNewProg, isDevProg, isNew as isNewLeader,
		   d.GrantNumber, c.InstitutionName, 
		   d.LastName + ', ' + d.FirstName AS FullName, d.Degree1 + ', ' + d.Degree2 AS Degree, d.DT1bProgramID as ID
	FROM   DT1bProgram d,
	       Center c 
	WHERE  d.CenterID = c.CenterId
	AND    c.CenterTypeID in (1,2,3)
	AND    d.isActive = 1
	AND    d.fy = 2014
	GROUP BY d.fy , d.GrantNumber, c.InstitutionName,  d.ProgCode, d.ProgName,  d.LastName, d.FirstName, d.Degree1, d.Degree2,
	         NoOfMembers,  isNewProg, isDevProg, isNew, d.DT1bProgramID
	





GO


