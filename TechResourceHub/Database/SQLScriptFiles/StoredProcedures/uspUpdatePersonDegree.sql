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
-- (2) Export into MS-Access OCCDB.accdb 
-- (3) Extract the data into SQL-Server database OCC by executing this stored procedure.
-- =============================================
CREATE PROCEDURE  [dbo].[uspPersonDegree]
AS
BEGIN
	
	DECLARE @curDegree	CURSOR, 
	        @curPerson  CURSOR,
	        @Degree1	NVARCHAR(100),
	        @Degree2	NVARCHAR(100),
		    @Degree3	NVARCHAR(100),
	        @LastName   NVARCHAR(100),
	        @FirstName  NVARCHAR(100), 
	        @PersonID	INT,
	        @DegreeID	INT
	       
	SET @curDegree = CURSOR FOR
	SELECT 
	
	OPEN @curDegree
	FETCH NEXT
	FROM @myCur INTO @Degree1, @Degree2, @Degree3, @LastName, @FirstName, @PersonID
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
	    
		UPDATE 
		SET    
		WHERE  
		FETCH NEXT
		FROM @myCur INTO @Degree1, @Degree2, @Degree3, @LastName, @FirstName, @PersonID
		
		
	END
	CLOSE @myCur
	DEALLOCATE @myCur

END
GO