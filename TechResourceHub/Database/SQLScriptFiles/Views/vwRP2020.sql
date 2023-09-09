USE [OCC]
GO

/****** Object:  View [dbo].[vwRP]    Script Date: 7/11/2020 2:35:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










ALTER VIEW [dbo].[vwRP]
AS
 /* 
  DATE         		DESC
  11/11/2014        Created for OCC webapp 
  03/31/2016        Modified DT1BFY13 to DT1BProgram and FY = 2013
  09/26/2018        Added AND d.LastName IS NOT NULL - Not displaying nonaligned members. 

 */ 

   SELECT  TOP 5000
           d.fy,
           CASE c.CenterTypeID
		   WHEN '1' then 'Basic'
		   WHEN '2' then 'Clinical'
		   WHEN '3' then 'Comp'
		   END as CenterType,
		   c.InstitutionName, c.CenterName,  
		   d.ProgName, 
		   ISNULL(d.LastName + ', ' + d.FirstName, '') + ISNULL('; ' + d.lastname2 + ',' + d.Firstname2, '') + ISNULL('; ' + d.lastname3 + ',' + d.Firstname3, '') + ISNULL('; ' + d.lastname4 + ',' + d.Firstname4, '') + ISNULL('; ' + d.lastname5 + ',' + d.Firstname5, '') AS FullNname,
		   d.DT1BProgramID
	FROM   DT1BProgram d,
	       Center c 
	WHERE  c.isActive = 1
	AND    d.fy = 2019
	AND    d.CenterID = c.CenterId
	AND    c.CenterTypeID in (1,2,3)
	AND    d.fy IS NOT NULL
	AND    d.LastName IS NOT NULL
	Group by d.FY, c.CenterTypeID, c.InstitutionName, c.CenterName,   d.ProgName, d.LastName, d.FirstName, d.LastName2, d.FirstName2, d.LastName3, d.FirstName3, d.LastName4, d.FirstName4, d.LastName5, d.FirstName5, d.DT1BProgramID
	ORDER BY D.FY, c.InstitutionName,  d.ProgName, d.LastName, d.LastName5, d.FirstName5

GO


