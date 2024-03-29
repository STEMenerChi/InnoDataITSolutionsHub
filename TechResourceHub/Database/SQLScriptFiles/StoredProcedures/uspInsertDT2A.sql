USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspUpdateP30TypeID]    Script Date: 07/01/2013 13:19:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date: 07/01/2013

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
		N' WHERE  GrantNumber =  ' + @Param2
		
 		print (@SQL2);
	    EXEC(@SQL2);
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
           ,[SpecificFundingAgency]
           ,[ProjNumber]
           ,[ProjStartDate]
           ,[ProjEnddate]
           ,[ProjTitle]
           ,[ProgCode]
           ,[ProgPercent]
           ,[AnnualProjDirectCost]
           ,[AnnualProjTotalCost]
           ,[AnnualProgDirectCost]
           ,[AnnualProgTotalCost]
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
           ,[FullP30GrantNumber]  
           ,[LastUpdatedUserName]
           ,[isActive]
           ,[isMultiPI]
           ,[isMultiInvst]) ' + 
    
	N' SELECT 
	       [FY] 
           ,c.CenterID
           ,d.GrantNumber
           ,[SpecificFundingAgency]
           ,[ProjNo]
           ,[ProjStartDate]
           ,[ProjEnddate]
           ,[ProjTitle]
           ,[ProgCode]
           ,[ProgPercent]
           ,[AnnualProjDirectCost]
           ,[AnnualProjTotalCost]
           ,[AnnualProgDirectCost]
           ,[AnnualProgTotalCost]
           ,''N'' as [isSubContract]
           ,''N'' as [isPeerRev]
           ,[PI1LastName]
           ,[PI1FirstName]
           ,null as [PI2MiddleName]
           ,[PI2FirstName]
           ,[PI2LastName]
           ,null as [PIMiddleName2]
           ,null as [ReportingStartDate]
           ,null as [Comments]
           ,null as [FullP30GrantNumber]
           ,''dinhct''
           , ''N'' as [isActive]
           , ''N'' as [isMultiPI]
           , ''N'' as [isMultiInvst]
  FROM [OCC].[dbo].[DT2A-FY12-' + @pGrantNumber + ']' +
  N' d ,Center c ' + 
  N' WHERE d.GrantNumber = c.GrantNumber;'
  
  PRINT (@SQL);
  EXEC(@SQL);
  
END

