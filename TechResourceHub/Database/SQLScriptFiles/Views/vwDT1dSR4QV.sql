USE [OCC]
GO

/****** Object:  View [dbo].[vwDT1dSR4QV]    Script Date: 3/26/2014 4:23:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].vwDT1dSR4QV
AS
 /* 
  DATE      Name		 Desc
  3/25/2014 L.K. Weise   Number of shared resources by category for over time (FY2010-2012)
                         
  NOTE:
  Omitting Kansas and Kentucky (168524, 177558) since they just become NCI-desinated in 2013 
  Omitting SharedResourceCat 5 - Administrative, it's deleted from the list since 2012.

-- to see details:
SELECT  d.FY, d.dt1dSRID, s.SubSRCat,  
	    d.subcat1, d.subcat2, d.subcat3, s.SubSRCode  
FROM   DT1dSR d,
	       Center c, 
		   [SRCat] s
WHERE  d.CenterID = c.CenterId
AND    d.GrantNumber NOT IN  (168524, 177558)
AND    d.isActive = 1
AND    (d.subcat1 = s.SubSRCode
OR     d.subcat2 = s.SubSRCode
OR     d.subcat3 = s.SubSRCode)
order by  d.fy, d.dt1dSRID, s.SubSRCat

 SELECT 
	    SubSRCode,
		CASE SUBSTRING(SubSRCode,1,1)
			  WHEN '1' THEN 'Laboratory Science'
			  WHEN '2' THEN 'Laboratory Support'
			  WHEN '3' THEN 'Epidemiology, Cancer Control'
			  WHEN '4' THEN 'Clinical Research'
			  WHEN '6' THEN 'Biostatistics'
			  WHEN '7' THEN 'Informatics'
			  WHEN '8' THEN 'Miscellaneous'
			  ELSE 'N/A'
		  END
		  FROM  [SRCat] 
		  WHERE subSRCAT IS NOT NULL
		  AND   SUBSTRING(SubSRCode,1,1) <> '5'

 */ 

 
    -- 10 Records per FY. 
	 SELECT   d.FY, 
	          SRCat = 
		CASE SUBSTRING(S.SubSRCode,1,1)
			  WHEN '1' THEN 'Laboratory Science'
			  WHEN '2' THEN 'Laboratory Support'
			  WHEN '3' THEN 'Epidemiology, Cancer Control'
			  WHEN '4' THEN 'Clinical Research'
			  WHEN '6' THEN 'Biostatistics'
			  WHEN '7' THEN 'Informatics'
			  WHEN '8' THEN 'Miscellaneous'
			  ELSE 'N/A'
		 END, 

	       s.SubSRCat, S.SubSRCode,  Count(d.grantNumber) AS srCount
	FROM   DT1dSR d,
	       Center c, 
		   [SRCat] s
	WHERE  d.CenterID = c.CenterId
	AND    d.GrantNumber NOT IN  (168524, 177558)
	AND    d.isActive = 1
    AND    s.SubSRCAT IS NOT NULL
	AND    SUBSTRING(s.SubSRCode,1,1) <> '5'
	AND    (d.subcat1 = s.SubSRCode
	OR     d.subcat2 = s.SubSRCode
	OR     d.subcat3 = s.SubSRCode)
	GROUP BY  d.FY, SRCat, s.SubSRCat, S.SubSRCode


GO
--- select * from vwDT1dSR4QV


		  
	


		  