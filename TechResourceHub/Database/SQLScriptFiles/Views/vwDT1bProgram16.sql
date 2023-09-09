USE [OCC]
GO

/****** Object:  View [dbo].[vwDT1bProgram]    Script Date: 1/22/2016 4:40:47 PM ******/
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
  01/20/2016         Modified for 2014 Research Programs on the web , eliminated vwRP and used this view instead (saved as vwDT1bProgram16.sql)
                     ISSUE:   Unable to add the view into the Entify Framework Model or EF displayed dup PI names
					 To Resolve: PK must be included in each select list

 */ 

   select top 1000
	   --row_number() over (order by FullName, ProgName) as ID, 
	   x.ID,
	   x.CenterType, 
	   x.InstitutionName, x.ProgName, x.FullName
   from
   (
		SELECT d.DT1BProgramID as ID,  
			CASE c.CenterTypeID
			WHEN '1' then 'Basic'
			WHEN '2' then 'Clinical'
			WHEN '3' then 'Comp'
			END as CenterType,
			c.InstitutionName,  
			d.ProgName, d.LastName + ', ' + d.FirstName AS FullName			
		FROM   DT1bProgram d,
			   Center c 
		WHERE  d.fy = 2014
		AND    d.CenterID = c.CenterId  
	
		UNION

		SELECT l.MultiLeaderID as ID,
			   CASE c.CenterTypeID
			   WHEN '1' then 'Basic'
			   WHEN '2' then 'Clinical'
			   WHEN '3' then 'Comp'
			   END as CenterType,
			   c.InstitutionName, 
			   d.ProgName, 
			   l.LastName + ', ' + l.FirstName AS FullName
			FROM   DT1BProgram d, 
				   MultiLeader l,
				   Center c 
			WHERE  d.fy = 2014
			AND    d.CenterID = c.CenterId
			AND    d.DT1BProgramID = l.DT1BID) X 
  order by x.InstitutionName,  x.ProgName, x.FullName;




GO


