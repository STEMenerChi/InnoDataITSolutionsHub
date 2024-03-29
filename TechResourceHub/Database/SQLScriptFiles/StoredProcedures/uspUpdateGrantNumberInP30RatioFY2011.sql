SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date: 03/09/2012
-- Description:	Update the grantNumber in P30RatioFy2011 according to the grantnumber in the Center table.
-- =============================================
ALTER PROCEDURE  [dbo].[uspUpdateGrantNumberInP30]
AS
BEGIN
	
	DECLARE @myCur			 CURSOR, 
	        @GrantNumber	 INT,
	        @CenterID        INT;
	       
	SET @myCur = CURSOR FOR
	SELECT GrantNumber, CenterID
	FROM   center
	
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @GrantNumber, @CenterID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE P30RatioFY2011
		SET    GrantNumber = @GrantNumber
		WHERE  CenterID = @CenterId
		FETCH NEXT
		FROM @myCur INTO @GrantNumber, @CenterID
	END
	CLOSE @myCur
	DEALLOCATE @myCur

END
GO

