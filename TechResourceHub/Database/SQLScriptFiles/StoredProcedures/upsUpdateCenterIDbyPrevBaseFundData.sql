USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspUpdateCenterIDBasedOnName]    Script Date: 8/23/2016 2:17:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================
-- Author:		Chi T. Dinh
-- Create date: 08/23/2016
-- Description:	Update the CenterID based on the previous year basefund data
--              Notice that if the serial or the externalOrg ID coincides w/ the GrantNumber
-- =====================================================*/
ALTER PROCEDURE  [dbo].[uspUpdateCenterIDbyPrevBaseFundData]


AS
BEGIN
	
	DECLARE @myCur			 CURSOR, 
			@CenterID        int,
			@GrantNumber     int, 
			@SerialNo        INT, 
			@ExternalOrgID   FLOAT;
	
	SET @myCur = CURSOR FOR
	SELECT DISTINCT SerialNo, ExternalOrgID, CenterID, GrantNumber
	FROM   BaseFund
	WHERE  FY = 2014
	AND    CenterID IS NOT NULL;

	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO  @SerialNo, @ExternalOrgID, @CenterID, @GrantNumber
	WHILE @@FETCH_STATUS = 0
	BEGIN

		--UPDATE CCcontactList
		--SET    CenterID    = @CenterID, 
		--       GrantNumber = @GrantNumber
		--WHERE  CenterName  = @CenterName;

		UPDATE BaseFund2015
		SET    CenterID        = @CenterID, 
		       GrantNumber     = @GrantNumber
		WHERE  CenterID IS NOT NULL
		AND    SerialNo = @SerialNo
		OR     ExternalOrgID = @ExternalOrgID
	

		FETCH NEXT
		FROM @myCur INTO @SerialNo, @ExternalOrgID, @CenterID, @GrantNumber

	END
	CLOSE @myCur
	DEALLOCATE @myCur

END
