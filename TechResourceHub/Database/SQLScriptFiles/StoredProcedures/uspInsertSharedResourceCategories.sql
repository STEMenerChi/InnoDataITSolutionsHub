USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspInsertSharedResourceCategories]    Script Date: 03/15/2012 13:24:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date: 3/14/2012
-- Description:	Insert the Shared Resource Categories
-- Data migrations steps: Using the Resource Categories list in the Formatting for Standard Cancer Center Summaries
-- (1) Shared Resource Categories Excel (created by A. Martinez), 
-- (2) Export into MS-Access OCCDB.accdb SRCategories
-- (3) Extract the data into SQL-Server database OCC by executing this stored procedure.
-- =============================================
ALTER PROCEDURE  [dbo].[uspInsertSharedResourceCategories]
AS
BEGIN
	
	DECLARE @myCur			CURSOR, 
		    @SubSharedCat	NVARCHAR(255),
	        @SubSharedCode  NVARCHAR(10),
	        @Counter        INT, 
	        @ParentID		INT;
	       
	SET @Counter = 1;      
	
	SET     @myCur = CURSOR FOR
	SELECT  CAST (SUBSTRING(Code,1,1) AS INT) AS ParentID, Code,  SharedResource 
	FROM    SRCategories
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @ParentID, @SubSharedCode, @SubSharedCat
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    
		INSERT INTO SharedResourceCat(ParentID, SubSharedCatID, SubSharedCode, SubSharedCat, LastUpdatedDate)
		VALUES ( @ParentID , @Counter, @SubSharedCode,  @SubSharedCat,  GETDATE());
				
		FETCH NEXT
		FROM @myCur INTO @ParentID, @SubSharedCode, @SubSharedCat
		SET @Counter = @Counter + 1;
		
		
	END
	CLOSE @myCur
	DEALLOCATE @myCur

END
