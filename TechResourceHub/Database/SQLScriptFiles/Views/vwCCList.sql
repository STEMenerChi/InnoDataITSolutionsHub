USE [OCC]
GO

/****** Object:  View [dbo].[vwCCList]    Script Date: 12/30/2014 6:35:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER  VIEW [dbo].[vwCCList]
/*    
 *    DATE			Developer		Desc
 *    11/29/2014    Chi             Create for the OCC Web Application
 *    12/19/2014    Chi             Updated the MiddleName concatenation, NOTE that concate anything string with null will result to null.
 *
 *  select * from CenterPOC
    where isActive = 1;
 */
AS
	select TOP 200   CenterType =
	       CASE c.CenterTypeID 
		     WHEN '1' THEN 'Basic'
			 WHEN '2' THEN 'Clinical'
			 WHEN '3' THEN 'Comp'
		   END, 
	        c.profileURL,   c.InstitutionName, c.CenterName, 
		    p.PIFirstName + ' ' + ISNULL(p.PIMiddleName, '') + ' ' +  p.PILastName as FullName,			
			p.PIDegree,
			p.PITitle,
		   c.StreetAddress + ' ' + + ISNULL(c.StreetAddress2, '') + ''+  c.City + ', ' +  C.StateCode + ' ' + C.zipcode AS Address,  
		   p.Phone, c.CenterId
	from  Center c,
		  CenterPOC p
	where p.isActive = 1
	AND   p.CenterID = c.CenterID
	and   c.CenterTypeID in (1,2,3)
	order by  c.CenterTypeID, c.InstitutionName;

GO


