

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date: 04/16/2012
-- Description:	Change the Center's FK from GrantNumber to Centerid
--              Update newly created CenterID (in the current working table, in case it's Person)
--              with Center's based on the GrantNumber.
-- Parameters: TableName, (P)rimary Key, (F)oreign Key.
-- =============================================
ALTER PROCEDURE  [dbo].[uspUpdateCenterID] 
   @TableName NVARCHAR(1024)

AS
BEGIN
	
	DECLARE @SQL             NVARCHAR(MAX),
	        @SET	         NVARCHAR(MAX),
	        @WHERE           NVARCHAR(MAX),
			@myCur			 CURSOR, 
	        @GrantNumber	 INT,
	        @CenterID        INT;

	
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
	    SET @SQL =  N' UPDATE ' + @TableName  + 
	                N' SET    CenterID   =  ' + @CenterID + 
					N' WHERE  GrantNumber = ' + @GrantNumber;
	    SET @SET = N'@CenterID';
	    SET @WHERE = N'@GrantNumber';  
		PRINT @SQL 
		EXEC sp_executesql @SQL, @SET, @WHERE;
		
		FETCH NEXT
		FROM @myCur INTO @CenterID, @GrantNumber
		
	END 
	CLOSE @myCur
	DEALLOCATE @myCur

END
GO

--ALTER TABLE centerperson DROP COLUMN GrantNumber;