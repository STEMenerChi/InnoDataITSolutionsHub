USE [OCC]
GO

/****** Object:  View [dbo].[vwSRCat]    Script Date: 05/21/2012 12:10:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[vwSRCat]
AS
	
/*
  Date: 5/20/2012
  Developer: C.Dinh
  Objective: To create a list of Shared Resource Categories and sub-Categories to display on the Website.
*/

SELECT   
          CASE ParentID 
               WHEN  1 THEN '1. Laboratory Science'
               WHEN   2 THEN '2. Laboratory Support'
               WHEN  3 THEN '3. Epidemiology, Cancer Control'
                WHEN  4 THEN '4. Clinical Research'
               WHEN   5 THEN '5. Administrative'
               WHEN  6 THEN '6. Biostatistics'
              WHEN   7 THEN '7. Informatics'
               WHEN  8 THEN '8. Miscellaneous'
          
          END AS SharedResourceCat,
          SubSharedCode, SubSharedCat
FROM     SharedResourceCat SR
where SubSharedCode is not null
GROUP BY  ParentID,
          SubSharedCode, SubSharedCat;
      

GO


