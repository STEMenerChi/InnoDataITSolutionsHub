USE [OCC]
GO

/****** Object:  View [dbo].[vwDView]    Script Date: 04/24/2014 13:42:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vwDView]
AS
 /*
  DESC			DESC
  04/24/2014    created for qlikview demo
   
  To Generate the following reports:
  1. 
  Compare the BaseFund to  DT2B (active funded project) from 2001 - 2013 for the following Centers:
  MSKCC (8748), Dana Farber (6516), UCSF (82103), UCSD (23100), UNC(16086), Duke(14236), UPenn (16520), U. of Chicago (14599), 
  MD Anderson (16672) and Mayo Clinic (15083).
  2. 
  Number of shared resources by category for over time (FY2010-2012)
  Omitting Kansas and Kentucky (168524, 177558) since they just become NCI-desinated in 2013 
  Omitting SharedResourceCat 5 - Administrative, it's deleted from the list since 2012.
  3. 
  Trend data on NCI funding for 66 centers (excluding Kentucky and Kansas since they just become NCI-desinated in 2013)
  FY2010- 2012
  
  05/05/2014    added DT1dSR
                Number of shared resources by category for over time (FY2010-2012), requested by L. K. Weiss
                         
				NOTE:
				Omitting Kansas and Kentucky (168524, 177558) since they just become NCI-desinated in 2013 
				Omitting SharedResourceCat 5 - Administrative, it's deleted from the list since 2012.
  
 */ 
    	
	SELECT  c.GrantNumber, c.InstitutionName, c.CenterId,
	       bf.FY, bf.Institution as P30Partner, bf.FullProjNo, bf.ProjTitle, 
	       bf.BudgetStartDate, bf.BudgetEndDate, bf.PILastName + ',' + SUBSTRING(bf.PIFirstName, 1,1) as PIname, bf.TotalCost, 
		   dt2B.[NCITotalNo],dt2B.[NCIDC],dt2B.[NCITC],dt2B.[OthNIHTotalNo],dt2B.[OthNIHDC],dt2B.[OthNIHTC],dt2B.[OthPRTotalNo]
          ,dt2B.[OthPRDC],dt2B.[OthPRTC],dt2B.[IndNonPRTotalNo],dt2B.[IndNonPRDC] ,dt2B.[IndNonPRTC],dt2B.[OthNonPRTotalNo] ,dt2B.[OthNonPRDC]
          ,dt2B.[OthNonPRTC],
           dt1c.AlignedNumber, dt1c.NonAlignedNumber, 
           SRCategory = 
           CASE SUBSTRING(SRCat.SubSRCode,1,1)
			  WHEN '1' THEN 'Laboratory Science'
			  WHEN '2' THEN 'Laboratory Support'
			  WHEN '3' THEN 'Epidemiology, Cancer Control'
			  WHEN '4' THEN 'Clinical Research'
			  WHEN '6' THEN 'Biostatistics'
			  WHEN '7' THEN 'Informatics'
			  WHEN '8' THEN 'Miscellaneous'
			  ELSE 'N/A'
		  END, 
	      SRCat.SubSRCat, SRCat.SubSRCode,  Count(DT1dSR.grantNumber) AS srCount
	FROM   dt2B,       
	       BaseFund   bf,
	       DT1cMember dt1c,
	       Center     c, 
	       DT1dSR,
	       SRCat
	WHERE  dt2B.CenterID = c.CenterId
    AND    bf.CenterID = C.CenterId
    AND    bf.isActive = 1
    AND    dt1c.CenterID = c.CenterId
	AND    dt1c.GrantNumber NOT IN  (168524, 177558)
	AND    dt1c.isActive = 1
	AND    DT1dSR.CenterID = c.CenterId
	AND    DT1dSR.GrantNumber NOT IN  (168524, 177558)
	AND    DT1dSR.isActive = 1
    AND    SRCat.SubSRCAT IS NOT NULL
	AND    SUBSTRING(SRCat.SubSRCode,1,1) <> '5'
	AND   (DT1dSR.subcat1 = SRCat.SubSRCode
	OR     DT1dSR.subcat2 = SRCat.SubSRCode
	OR     DT1dSR.subcat3 = SRCat.SubSRCode)
	GROUP BY  Bf.FY, SRCat.SubSRCat, SRCat.SubSRCode,  c.GrantNumber, c.InstitutionName, c.CenterId, bf.Institution, bf.FullProjNo, bf.ProjTitle,
	          bf.BudgetStartDate, bf.BudgetEndDate,  bf.PILastName, bf.PIFirstName, bf.TotalCost, 
		      dt2B.[NCITotalNo],dt2B.[NCIDC],dt2B.[NCITC],dt2B.[OthNIHTotalNo],dt2B.[OthNIHDC],dt2B.[OthNIHTC],dt2B.[OthPRTotalNo]
             ,dt2B.[OthPRDC],dt2B.[OthPRTC],dt2B.[IndNonPRTotalNo],dt2B.[IndNonPRDC] ,dt2B.[IndNonPRTC],dt2B.[OthNonPRTotalNo] ,dt2B.[OthNonPRDC]
             ,dt2B.[OthNonPRTC],
           dt1c.AlignedNumber, dt1c.NonAlignedNumber
	--AND    bf.GrantNumber in (8748, 6516, 82103, 23100, 16086, 14236, 16520, 14599, 16672, 15083)
	
	