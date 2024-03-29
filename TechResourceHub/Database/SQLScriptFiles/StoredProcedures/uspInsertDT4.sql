USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspInsertDT4]    Script Date: 5/2/2014 11:27:46 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================
-- DATE 		DESC
-- 07/01/2013   Created
-- 05/012/2014  Performed backup (48,951 rows) and cosolidated FY2013 GT (51008) and NYU (16087) data into DT4.


    To run the uspINsertDT2A stored procedure, enter the GrantNumber as shown on the DT2A-FY##-######.

select * 
into DT4backup
from dt4;
-- 
-- =============================================  */
ALTER PROCEDURE  [dbo].[uspInsertDT4] (@pGrantNumber VARCHAR(15)) 

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
	    */
	
	DECLARE @myCur					CURSOR,
	        @SQL					NVARCHAR(MAX)

	        
	         
	SELECT @SQL = N' INSERT INTO [OCC].[dbo].[DT4]
			(FY, [CenterID], [Grantnumber], P30GrantNumber , ReportingStartDate, ReportingEndDate, 
			 ,[ClinicalResearchCat], [Section]
			 , StudySourceCode, [Category]
			 ,[PrimaryPurpose],  [StudyType]
			 ,FundingSource, [PrimarySite] ,[ProtocolID] , isMultiINst 
			 ,[PILastName]  ,[PIFirstName] ,piMiddleName
			 ,[PILastName2] ,[PIFirstName2] , [PIMiddleName2], 
			 ,[ProgCode]  ,[OpenDate]  ,[CloseDate]
			 ,[Phase]
			 [Title] , [EntireStudy], [Target] ,[YourCenterTotal]
			 [CenterP12] ,[Center2Date] ,[OthP12] ,[Oth2Date]  
			,[Totp12]  ,[Tot2Date], Comments )' + 
        
	N' SELECT 
	   2013 as FY
	   ,c.CenterID
      ,16087 as grantnumber 
      ,NULL AS P30GrantNumber
      ,ReportingStartDate 
	  ,ReportingEndDate
	      
      ,ClinicalResearchCat
	  ,NULL AS section
	  
	  ,StudySource
      ,NULL as [Category]

      ,PrimaryPurpose
	  ,NULL AS [StudyType]

      ,[FundingSource]
      ,[PrimarySite]
      ,[ProtocolID]
	  ,isMultiInst
       --,SUBSTRING(PI, 1, CHARINDEX('','', PIName) - 1) AS LastName 
	   --,SUBSTRING(PI, CHARINDEX('','', PIName) + 1, 25) AS FirstName
       ,PILastName
       ,PIFirstName
	   ,PIMiddleName
	   ,NULL AS [PILastName2]  
	   ,NULL AS [PIFirstName2] 
	   ,null as PIMiddleName2

      ,[ProgCode]
      ,[OpenDate]
      ,[CloseDate]
      ,[Phase]
   
      ,[Title]
	  ,[EntireStudy]
      ,[Target]
	  ,YourCenterTotal

      ,[CenterP12]
      ,[Center2Date]
      ,[OthP12] 
      ,[Oth2Date]

      ,NULL as comments
    
  FROM [OCC].[dbo].[DT4-16087-FY13NYU]' +
  N' d ,Center c ' + 
  --N' WHERE d.GrantNumber = c.GrantNumber ' +
  N' WHERE c.GrantNumber = 16087' 
  --N' AND FY IS NOT NULL ' ;
  
  PRINT (@SQL);
  EXEC(@SQL);
  
END
