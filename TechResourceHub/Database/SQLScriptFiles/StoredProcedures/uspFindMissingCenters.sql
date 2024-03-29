USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspFindMissingCenters]    Script Date: 11/27/2013 11:33:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
-- =============================================
	DATE		DESC
	11/27/2013  This stored procedure finds the missing Centers (GrantNumber) for the given table name. 
	    
	    
	            
    NOTE
    Required Param: Table Name. 
    
    DT2A : There are multip records per Center (based on GrantNumber)
           Use the Temp Table to weed out any dup, then find the missing Centers.
           otherwise,  NOT IN query would be sufficient.
          
Select GrantNumber, InstitutionName
from Center 
where GrantNumber not in (69, 70, 71, 73, 74)
and CenterTypeID not in  ( 1, 4)
And GrantNumber NOT IN (
select grantnumber 
from dt4
where FY = 2012)
    
-- =============================================
*/
CREATE PROCEDURE  [dbo].uspFindMissingCenters 
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
		N' WHERE  GrantNumber =  ' + @Param2 +
		N' AND    GrantNumber IS NOT NULL'
		
		print (@SQL2);
	    EXEC(@SQL2);


		FETCH NEXT
		FROM @myCur INTO @CenterID, @GrantNumber
		
	END 
	CLOSE @myCur
	DEALLOCATE @myCur

END
