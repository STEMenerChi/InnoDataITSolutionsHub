/*
  3/19/2015:
  this produces accurate results;however, MCV 5 EF6 doesn't pull data correctly. 
*/

SELECT c.InstitutionName,
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
			 d.SRName as SRName,
			 d.LastName + ', ' + d.FirstName AS FullName, d.Degree1 + ', ' + d.Degree2 AS Degree, d.dt1dSRID   
		FROM   DT1dSR d,
			   Center c, 
			   [SRCat] s
		WHERE  d.fy = 2013	
		--and    D.grantnumber = 138292
       and    D.grantnumber = 43703
		AND    d.CenterID = c.CenterId
		AND    d.isActive = 1
		AND    d.cat = s.SRCatID
    
		UNION

		SELECT c.InstitutionName,
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
			   d.SRName as SRName,
			   l.LastName + ', ' + l.FirstName AS FullName, l.Degree1 + ', ' + l.Degree2 AS Degree, d.dt1dSRID
		FROM   DT1dSR d, 
			   MultiLeader l,
			   Center c, 
			   [SRCat] s
		WHERE  d.fy = 2013	
		--and    D.grantnumber = 138292
       and    D.grantnumber = 43703	
		AND    d.CenterID = c.CenterId
		AND    d.isActive = 1
		AND    d.cat = s.SRCatID
		AND  d.dt1dsrID = l.dt1dsrID


GO

--select * from vwDT1dSR where institutionName like '%winship%';
