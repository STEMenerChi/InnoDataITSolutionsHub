USE [OCC]
GO

/****** Object:  View [dbo].[vwNoOfAccrualOfTreatmentStudies]    Script Date: 04/18/2013 09:26:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vwNoOfTreatmentAccrual]
AS
/*
April 15, 2013
Requested by Linda

To follow up on a query from the wg, I would like 2 tables from DT 4 (just for internal use for now) as follows:

FY 11 by center

1. # of Clinical trial accrual by study source (I,D, N, E) and total across all sources, sorted by total accrual, high to low
Number of clinical trial accrual by study source (I,D, N, E) and total across all sources is the sum of CenterP12 + Center2Date + OtherP12 + Other2Date?

2. # of clinical trials by  study source (I,D,N,E), and total across all sources, sorted by total # of trials, high to low


Use therapeutic (treatment) studies only.
Eliminate those with NULL info.
Format as shown below for both accrual and # of trials, sort highest to lowest based on total column.

Cancer Center Name   Industry    Ext. Peer  Instit  National   Total 

Baylor              xxxx        xxxx         xxxx   xxxx      xxxx


*/

-------------------1. # of Clinical trial accrual-----------------------------
SELECT  c.InstitutionName, 
        d.StudySourceCode, SUM(d.CenterP12 + d.OthP12 ) as NoOfAccrual 
FROM    DT4 d,
        Center c
WHERE    FY = 2011
AND      d.StudySourceCode IS NOT NULL
ANd      d.Section in (1,2)
AND      d.CenterID = c.CenterId
group by c.InstitutionName, d.StudySourceCode
--ORDER by d.StudySourceCode, NoOfAccrual DESC


GO

