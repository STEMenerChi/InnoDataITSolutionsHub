

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
-- 
-- =============================================
ALTER PROCEDURE  [dbo].[uspUpdateCenterID] 
 

AS
BEGIN
	
	DECLARE @myCur			 CURSOR, 
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
	
	    UPDATE CenterDetail
		SET    CenterID    =  @CenterID
		WHERE  GrantNumber =  @GrantNumber
		    


		FETCH NEXT
		FROM @myCur INTO @CenterID, @GrantNumber
		
	END 
	CLOSE @myCur
	DEALLOCATE @myCur

END
GO

--ALTER TABLE centerperson DROP COLUMN GrantNumber;