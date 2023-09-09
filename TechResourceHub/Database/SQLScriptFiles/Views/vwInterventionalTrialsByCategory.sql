USE [OCC]
GO

/****** Object:  View [dbo].[vwInterventioanlTrials]    Script Date: 05/21/2012 08:18:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[vwInterventioanlTrials]
AS
	
/*
Date			Developer	
 May 16, 2012	C. Dinh
 
 Report Name: Intervetnional Trials by Catergoy and Center
 
 Description: A summary of the number of interventional studies/trials (not accrual) reported in summary 4 by category, center, and tril type. 
			  The sponsor category: (N)ational, (E)xternal peer-reviewed, (I)nstitutional, and in(D)ustry)
 Objective  : To compare OCC's Summary 4 data with CTRP.
 Request by : Gene Kraus
 
 Note: 
 Only the data in Clinical Research Cateroy (1) Agent or Device, and (2) Trials Involving other Intervetnions are included in this report.
 
 The National (they come into CTRP from external sources), Other or N/A category; and  ancillary/correlative or observational studies are 
 excluded from the this report.
 
 Category is knows as Sponsor in the new Summary Format document or Trial Sponsor in the 2006.
 */

SELECT  
 CASE S.category 
       WHEN 'D' THEN 'Industrial'
       WHEN 'E' THEN 'Peer-Reviewed'
       WHEN 'I' THEN 'Institutional'
  END AS TrialSponsor, 
  c.CenterName, S.type as TrialType, COUNT(S.TYPE) AS NoOfStudies 
FROM  sum4 s,
     Center c
WHERE section in (1,2)
AND category IN ('E', 'I', 'D')
AND type NOT LIKE '%Anc%'
AND type NOT LIKE '%Obs%'
AND type NOT like 'n /%'
AND type NOT like 'Misc%'
AND type NOT in ('6', 'Other', 'Registry', 'Survey', 'Type', 'Tissue Banking')
--AND s.FY = 2011  for now we only have fy11, there is not pt of including this filter.
AND s.CenterID = c.CenterId
GROUP BY  S.category,c.CenterName, s.type;





GO


