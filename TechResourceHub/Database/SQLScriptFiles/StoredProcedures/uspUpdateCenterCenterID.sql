SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date: 03/09/2012
-- Description:	Update the grantNumber in P30RatioFy2011 according to the grantnumber in the Center table.
-- =============================================
ALTER PROCEDURE  [dbo].[uspUpdateCenterCenterID]


AS
BEGIN
	
	DECLARE @myCur			 CURSOR, 
	        @GrantNumber	 INT,
	        @Cnt             INT;

	
	SET @Cnt = 1
	
	SET @myCur = CURSOR FOR
	SELECT GrantNumber
	FROM   center;
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @GrantNumber
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE Center
		SET    CenterID    = @Cnt
		WHERE  GrantNumber = @GrantNumber
		FETCH NEXT
		FROM @myCur INTO @GrantNumber
		SET @Cnt = @Cnt + 1;
	END
	CLOSE @myCur
	DEALLOCATE @myCur

END
GO
