USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspUpdateCenterIDOfTheGivenTable]    Script Date: 05/16/2012 11:48:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date: 05/13/2012
-- Description:	1.  Add the CenterID field the specified table
--              2.  Updated the newly created CenterID with Center's ID value based on the GrantNumber.
--              3.  Create a Nonclused index on the CenterID
--              3.   Change the Center's FK from GrantNumber to Centerid
-- Required Parameter:   TableName
-- =============================================
ALTER PROCEDURE  [dbo].[uspUpdateCenterIDOfTheGivenTable] 
(@TableName VARCHAR(30)) 

AS
BEGIN
	
	DECLARE @myCur			 CURSOR, 
	        @GrantNumber	 INT,
	        @CenterID        INT,
	        @SQL1            NVARCHAR(MAX),
	        @SQL2            NVARCHAR(MAX), 
	        @Param1			 NVARCHAR(MAX),
	        @Param2          NVARCHAR(MAX);

	/*
	SELECT @SQL1 = N' ALTER TABLE ' + @TableName + 
	               N' Add CenterID Int; '
	Print (@SQL1);
	EXEC (@SQL1);
	*/
	
	-- if PK
	-- ALTER TABLE CenterDetail Add CenterID [int] IDENTITY(1,1) NOT NULL;
	-- if FK 
	--ALTER TABLE CenterDetail Add [CenterId] [int]  NULL;
	
	
	SET @myCur = CURSOR FOR
	SELECT CenterID, GrantNumber
	FROM   center;
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @CenterID, @GrantNumber
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SELECT @Param1 = @CenterID;
		SET @Param2 = @GrantNumber;
		
	    SELECT @SQL2 = N' UPDATE ' + @TableName +
		N' SET    CenterID    =  ' + @Param1 + 
		N' WHERE  GrantNumber =  ' + @Param2
		
		print (@SQL2);
	    EXEC(@SQL2);


		FETCH NEXT
		FROM @myCur INTO @CenterID, @GrantNumber
		
	END 
	CLOSE @myCur
	DEALLOCATE @myCur

END
