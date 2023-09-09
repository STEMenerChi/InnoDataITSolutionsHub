USE [OCC]
GO

/****** Object:  View [dbo].[vwET]    Script Date: 3/1/2022 2:03:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [dbo].[vwET]
AS
 /* 
  DATE         		DESC
  04/21/2021        Created vwET, 
                    MUST include EDID (Primary Key) otherwise, (in the code) the Entity Framework DB first will  ignore your view if you don't have a primary key defined. 
 */ 

   SELECT  TOP 5000
           d.ETID,
           d.fy,
		   d.grantnumber, 
           CASE c.CenterTypeID
		   WHEN '1' then 'Basic'
		   WHEN '2' then 'Clinical'
		   WHEN '3' then 'Comp'
		   END as CenterType,
		   c.InstitutionName, 
		   ISNULL(d.LastName + ', ' + d.FirstName, '') + ISNULL('; ' + d.lastname2 + ',' + d.Firstname2, '') AS FullName, 
		   ISNULL(d.title, '') + ISNULL('; ' + d.Title2, '') AS Titles,
		   ISNULL(d.email, '') + ISNULL('; ' + d.Email2, '') AS Emails
	FROM   ET d,
	       Center c 
	WHERE  c.isActive = 1
	--AND    d.fy = 2021
	AND    d.CenterID = c.CenterID
	AND    c.CenterTypeID in (1,2,3)
	AND    d.fy IS NOT NULL
	AND    d.LastName IS NOT NULL
	
	GROUP BY d.FY, c.CenterTypeID, c.InstitutionName, d.GrantNumber,  d.LastName, d.FirstName, d.LastName2, d.FirstName2, d.title, d.title2, d.Email, d.email2, d.ETID
	ORDER BY d.FY, c.CenterTypeID, c.InstitutionName,  d.LastName, d.LastName2

GO


