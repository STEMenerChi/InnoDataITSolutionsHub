USE [OCC]
GO

/****** Object:  View [dbo].[vwCCSGFundCTcompoments1]    Script Date: 05/22/2012 14:31:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[vwCCSGFundCTcompoments2]
AS

/*
Requestor: Gail Pitts of RAEB
Date: May 18, 2012
Objective: to accurately present Clinical Research funded by CCSG
Description: Total cost for three Clinical Compoments (Basic Science, Clinical, and Populations) by Center

Two views [vwCCSGFundCTcompoments1] and [vwCCSGFundCTcompoments2] were created to support this busines rules.

CCSG CT Compoments Funds are derived from three different sources:

View #1: 
From CenterDetail table, the CCSGAwardAmt which is the total cost.  This figure can be verified via QVR prt Nga Nguyen.
From the FY11 Finance, the direct cost for DSM, PRMS, Pro_Spec, and SharedRes.  These were pulled from OGA by Adriana.  
They can also  be retrieved via eGrant per Adriana Martinez.

View #2:
From  Sum1dSR,  the direct cost for the Shared Resources:
4 - Clinical Research, select 4.02 Clinical Trial PMDM, 4.05 Parmacology (lab Test), 4.07 Gene Therapy/Vector
6 - Biostatistics, get  50% of the data only
7 - Informatics, 7.01 Clinical Research Informatics

Note that in Sum4dSR, the Centers provide the list of SRs and Adrians included the $ amount from OGA (eGrant).

*/

SELECT c.CenterName, c.GrantNumber, 

       S.SHAR_CAT, S.RES_NAME,  
       CASE S.SHAR_CAT
            WHEN '6.01' THEN DirectCost/2
            ELSE
                s.DirectCost
        END as DirectCost, 
         CASE S.SHAR_CAT
            WHEN '6.01' THEN '* only 50% of the Biostatistics Fund is listed.'
            ELSE
                ''
        END as Comment
FROM Center c, 
     Sum1dSR  s
WHERE s.SHAR_CAT in ('4.02', '4.05', '4.07', '6.01',  '7.01')
AND   s.CenterID = c.CenterId

GO


