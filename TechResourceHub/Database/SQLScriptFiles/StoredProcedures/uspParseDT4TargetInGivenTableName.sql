USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspUpdateCenterIDGivenTable]    Script Date: 11/01/2012 08:51:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date: 11/01/2012
-- Description:	Given target = (50)20
--              Parse the value in Taget and store 50 in EntireStudy and 20 in YourCenterTotal 
--              by locating ')' and find its position.
-- Input Paramerter: DT4 name, such as 'DT4FY10'
-- =============================================
ALTER PROCEDURE  [dbo].[uspParseDT4TargetGivenTableName] 
(@TableName VARCHAR(30)) 

AS
BEGIN
	
	DECLARE @myCur			 CURSOR,
			@myCur2			 CURSOR, 
	        @ID				 INT,
	        @PoS		     INT,
	        @YourCenterTotal INT,
	        
	        @SQL1            NVARCHAR(MAX),
	        @SQL2            NVARCHAR(MAX), 
	        @Param1			 NVARCHAR(MAX),
	        @Param2          NVARCHAR(MAX);

    
	--- Locate the ')' in the Target field and add 1 more space the the found position
	SET @myCur = CURSOR FOR
	
    SELECT  dt4fy10ID AS ID, CHARINDEX(')', [target]) + 1 as StartPos 
    FROM dt4fy10
    WHERE [Target] is not null
    AND [Target] like '(%'
    AND CenterP12 > 0
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @ID, @Pos
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		--- get the position
		SET @myCur2 = CURSOR FOR
		
			SELECT   SUBSTRING([target], @Pos, 10) as YourCenterTotal    
			FROM dt4fy10
			WHERE [Target] is not null
			AND [Target] like '(%'
			AND CenterP12 > 0;
		
		OPEN @myCur2
		FETCH NEXT
		FROM @myCur2 INTO @YourCenterTotal
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			-- update the YourCenterTotal field
			FETCH NEXT
			FROM @myCur2 INTO @YourCenterTotal
			
		END 
		
	
	FETCH NEXT
	FROM @myCur INTO @ID, @Pos
	
	END 
	
	CLOSE @myCur
	DEALLOCATE @myCur
	CLOSE @myCur2
	DEALLOCATE @myCur2
/*	 

SELECT @Param1 = @CenterID;
		SET @Param2 = @GrantNumber;
		
	    SELECT @SQL2 = N' UPDATE ' + @TableName +
		N' SET    CenterID    =  ' + @Param1 + 
		N' WHERE  GrantNumber =  ' + @Param2
		
 	print (@SQL2);
	    EXEC(@SQL2);
	    */
  
  
	

END
