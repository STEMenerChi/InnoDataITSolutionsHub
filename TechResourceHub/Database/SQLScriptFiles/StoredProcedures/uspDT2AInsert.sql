USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspInsertDT2A]    Script Date: 12/04/2013 13:54:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date: 07/01/2013
-- To run the uspINsertDT2A stored procedure, enter the GrantNumber as shown on the DT2A-FY##-######.
-- 
-- =============================================
ALTER PROCEDURE  [dbo].[uspInsertDT2A] (@pGrantNumber VARCHAR(15)) 

AS
BEGIN
	
	/*
	    SELECT @Param1 = @CenterID;
		SET @Param2 = @GrantNumber;
		
	    SELECT @SQL2 = N' UPDATE ' + @TableName +
		N' SET    CenterID    =  ' + @Param1 + 
		N' WHERE  GrantNumber =  ' + @Param2S
		
 		print (@SQL2);
	    EXEC(@SQL2);
	    
	    --,SUBSTRING(PIName, 1, CHARINDEX(',', PIName) - 1) AS LastName 
	     --,SUBSTRING(PIName, CHARINDEX(',', PIName) + 1, 25) AS FirstName
	     
	     SUBSTRING([SpecificFundingAgency], 1, 499) AS SpecificFundingAgency
	     CAST( Ceiling([AnnualProjDC]) as INT)
	     substring([isSubContract],1,1)
	     
	     -- 29 columns
	    */
	
	DECLARE @myCur					CURSOR,
	        @SQL					NVARCHAR(MAX),
	        @Param					NVARCHAR(MAX), 
	        @LastUpdatedUserName	NVARCHAR(25)
	        
	        SET @LastUpdatedUserName =  'dinhct';
	         
	SELECT @SQL = N' INSERT INTO [OCC].[dbo].[DT2A]
           ([FY] 
           ,[CenterID]
           ,[GrantNumber]
           ,[P30GrantNumber]  
           ,[SpecificFundingAgency]
           ,[ProjNumber]
           ,[ProjStartDate]
           ,[ProjEnddate]
           ,[ProjTitle]
           ,[ProgCode]
           ,[ProgPercent]
           ,[AnnualProjDC]
           ,[AnnualProjTC]
           ,[AnnualProgDC]
           ,[AnnualProgTC]
           ,[isSubContract]
           ,[isPeerRev]
           ,[PILastName]
           ,[PIFirstName]
           ,[PIMiddleName]
           ,[PIFirstName2]
           ,[PILastName2]
           ,[PIMiddleName2]
           ,[ReportingStartDate]
           ,[Comments]
           ,[LastUpdatedUserName]
           ,[isActive]
           ,[isMultiPI]
           ,[isMultiInvst]) ' + 
    
	N' SELECT 
	       2012 as [FY] 
           ,25 AS CenterID
           ,16520 as GrantNumber
           ,P30GrantNumber
           ,SpecificFundingAgency
           ,[ProjNo]
           ,NULL As [ProjStartDate]
           ,NULL AS [ProjEnddate]
           ,projTitle
           ,ProgCode
           ,[ProgPercent]
           , [AnnualProjDC]
           , [AnnualProjTC] 
           , [AnnualProgDC]
           , [AnnualProgTC]
           ,NULL AS [isSubContract]
           ,NULL AS [isPeerRev]
           ,PILastName 
	       ,PIFirstName
           ,[PIMiddleName]
           ,[PIFirstName2]
           ,[PILastName2]
           ,[PIMiddleName2]
           ,NULL AS [ReportingDate]
           ,NULL AS Comments
           ,''dinhct''
           ,''Y'' AS [isActive]
           ,NULL AS [isMultiPI]
           ,NULL AS [isMultiInvst]
  FROM [OCC].[dbo].[DT2A-FY12-' + @pGrantNumber + '] ';
  -- +  N' ,Center c ' + 
  --N' WHERE d.GrantNumber = 16520; ';
  
  PRINT (@SQL);
  EXEC(@SQL);
  
END
