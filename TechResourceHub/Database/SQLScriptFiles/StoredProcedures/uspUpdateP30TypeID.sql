USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspUpdateP30TypeID]    Script Date: 07/01/2013 13:08:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date: 07/01/2013

-- 
-- =============================================
ALTER PROCEDURE  [dbo].[uspUpdateP30TypeID] 
 

AS
BEGIN
	
	DECLARE @myCur			 CURSOR, 
	        @GrantNumber	 INT,
	        @P30TypeID        INT;

	
	-- if PK
	-- ALTER TABLE CenterDetail Add CenterID [int] IDENTITY(1,1) NOT NULL;
	-- if FK 
	--ALTER TABLE CenterDetail Add [CenterId] [int]  NULL;
	
	
	SET @myCur = CURSOR FOR
	SELECT P30Type, GrantNumber
	FROM   CCSGTC12;
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @P30TypeID, @GrantNumber
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
	    UPDATE CCSGFund
		SET    P30TypeID    =  @P30TypeID
		WHERE  GrantNumber =  @GrantNumber
		AND    FY = 2012;
		    


		FETCH NEXT
		FROM @myCur INTO @P30TypeID, @GrantNumber
		
	END 
	CLOSE @myCur
	DEALLOCATE @myCur

END
