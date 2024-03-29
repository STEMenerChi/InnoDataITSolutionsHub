USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspUpdateGrantNumberBaseSerialNo]    Script Date: 11/29/2012 15:24:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date:  11/29/2012
-- Description:	1.  Add the GrantNumber field the specified table
--              2.  Updated the newly created GrantNumber and the CenterID with values in the Center table base on the SerialNo
--          
-- Required Parameter:   Target Table Name
-- =============================================
CREATE PROCEDURE  [dbo].[uspUpdateGrantNumberBaseInst] 
(@TableName VARCHAR(30)) 

AS
BEGIN
	
	DECLARE @myCur			 CURSOR, 
	        @GrantNumber	 INT,
	        @CenterID        INT,
	        @InstitutionName VARCHAR(255),
	        @SQL             NVARCHAR(MAX),
	        @pGrantNumber	 NVARCHAR(MAX),
	        @pCenterID       NVARCHAR(MAX),
	        @pInst           NVARCHAR(MAX);
	 

	
	-- if PK
	-- ALTER TABLE CenterDetail Add CenterID [int] IDENTITY(1,1) NOT NULL;
	-- if FK 
	--ALTER TABLE CenterDetail Add [CenterId] [int]  NULL;
	
	
	SET @myCur = CURSOR FOR
	SELECT distinct CenterID, GrantNumber,InstitutionName 
	FROM   Center
	
	
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @CenterID, @GrantNumber, @InstitutionName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SELECT @pCenterID = @CenterID;
		SET @pGrantNumber = @GrantNumber;
		SET @pInst        = @InstitutionName;
		
	    SELECT @SQL = N' UPDATE ' + @TableName +
		N' SET    CenterID    =  ' + @pCenterID +
		N' ,      GrantNUmber =  ' + @pGrantNumber +
		N' WHERE  GrantNumber is null' +
		N' AND    INSTITUTION    =  ' + @pInst
		
		print (@SQL);
	    EXEC(@SQL);


		FETCH NEXT
		FROM @myCur INTO @CenterID, @GrantNumber, @InstitutionName
		
	END 
	CLOSE @myCur
	DEALLOCATE @myCur

END
