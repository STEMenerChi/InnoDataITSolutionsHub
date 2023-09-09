USE [OCC]
GO

/****** Object:  View [dbo].[vSeniorLeaders]    Script Date: 05/10/2012 11:10:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--drop view [vSeniorLeaders]

ALTER VIEW [dbo].[vSeniorLeaders]
AS
SELECT  Top 100 Percent m.ALIGNED + m.NONALIGNED AS NumOfMembers, c.InstitutionName AS Institution, l.Title, l.LastName + ', ' + l.FirstName AS Name, 
			CASE
				WHEN (Degree1 IS NULL) then ' '
				WHEN (Degree2 IS NULL) AND (Degree3 is NULL) THEN Degree1
				WHEN (Degree2 IS NOT NULL) AND (Degree3 is NULL) THEN Degree1 + ', ' + Degree2
				ELSE Degree1 + ', ' + Degree2 + ', ' + Degree3
			END AS Degree 
FROM  dbo.Lead2011 AS l INNER JOIN
      dbo.Center AS c ON l.GrantNum = c.GrantNumber INNER JOIN
      dbo.Membership2011 AS m ON l.GrantNum = m.GRANTNUMB
GROUP BY m.ALIGNED + m.NONALIGNED, c.InstitutionName, l.Title, l.LastName, l.FirstName, l.Degree1, l.Degree2, l.Degree3
ORDER BY NumOfMembers, Institution, l.Title



GO

