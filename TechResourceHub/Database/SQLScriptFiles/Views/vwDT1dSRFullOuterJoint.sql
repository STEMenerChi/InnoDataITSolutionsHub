USE [OCC]
GO

/****** Object:  View [dbo].[vwDT1dSR]    Script Date: 3/19/2015 11:48:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[vwDT1dSR]
AS
 /* 
  DATE       Name		 Desc
  03/25/2014 L.K. Weise  Number of shared resources by category for over time (FY2010-2012)
  05/06/2014             Made each fieldname uniqu, this way QlikView wouldn't auto link them to other fieldname in other views.
  11/22/2014 Chi         Modified for jQuery dataTable Row Grouping to be posted on OCC website
                         Included TOP 1000 in order to do ORDER BY in view.
  03/11/2015 Chi         Modified the query based on the request of Dr. Kimberly F. Kerstann, Ph.D.
                         Associate Director For Cancer Research Administration Winship Cancer Institute | Woodruff Health Sciences Center Emory University 
						 (grantnumber = 138292)
						 by using the SRName from the submitted dt1 instead of NIH SubCat. 
  03/19/2014 Chi         Modified: dont' use the UNION (since MVC 5 EF6 won't display correct data), 
  There is a parent (DT1dSR) and child table (MultiLeader) and I want to create a select statement that, given a parent id, returns a row for that parent and additional rows for every child. 
  Doing a left join is not giving me a row for the parent by itself (it gives me multiple rows of the parent) when one or more children exist. 
  I know this can be done with a UNION but I'm looking for a solution that does not use a union statement.
  http://stackoverflow.com/questions/1494353/how-do-i-select-one-parent-row-and-additional-rows-for-its-children-without-a-un
             
  Verify the view with big gigs Centers: dana-farber(GrantNumber = 6516), MD Anderson (16672), Fred Hutch (15704), and MSKI (8748)
  Basic Center: Winship (138292)
  So So Center: Case Western (43703)	
  Centers w/o multiDirector: fox chase (6927), wistar (10815)		         
 
  NOTE:
  Omitting Kansas and Kentucky (168524, 177558) since they just become NCI-desinated in 2013 
  Omitting SharedResourceCat 5 - Administrative, it's deleted from the list since 2012.

  Select * from srCat;
  */

SELECT  ROW_NUMBER() OVER (order by d.DT1dSRID) AS ID,  c.InstitutionName,
		SRCat = 
			CASE S.SRCatID
					WHEN '1' THEN 'Cat 1: Laboratory Science'
					WHEN '2' THEN 'Cat 2: Laboratory Support'
					WHEN '3' THEN 'Cat 3: Epidemiology, Cancer Control'
					WHEN '4' THEN 'Cat 4: Clinical Research'
					WHEN '6' THEN 'Cat 6: Biostatistics'
					WHEN '7' THEN 'Cat 7: Informatics'
					WHEN '8' THEN 'Cat 8: Miscellaneous'
					ELSE 'N/A'
				END, 
        d.SRName,
		CASE d.LastName 
			WHEN NULL THEN ''
			ELSE d.LastName + ', ' + d.FirstName 
		END AS FullName1,
		 
		CASE l.LastName
			WHEN null then ''
			ELSE l.LastName + ', ' + l.FirstName 
		END AS FullName2
FROM   DT1dSR d
		FULL OUTER JOIN  MultiLeader l ON 1=0
		INNER JOIN DT1dSR d2 ON  IsNull( d.DT1dSRID,  l.DT1dSRID) = d2.DT1dSRID, 
		Center c, 
		[SRCat] s
WHERE  d2.fy = 2013
--and    d2.grantnumber = 138292
--and    d2.grantnumber = 43703	
AND    d2.CenterID = c.CenterId
AND    d2.isActive = 1
AND    d2.cat = s.SRCatID
GROUP BY c.InstitutionName, S.SRCatID, d.SRName, d.LastName,  d.FirstName, L.LastName,  L.FirstName, d.DT1dSRID


GO


