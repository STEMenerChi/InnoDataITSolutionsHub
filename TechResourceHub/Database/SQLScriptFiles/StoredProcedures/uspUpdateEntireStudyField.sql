USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspUpdateCenterCenterID]    Script Date: 06/05/2014 11:20:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- DATE        DESC
-- 06/05/2014  Update the EntireStudy field given the ProtocolID & PI's LastName
-- =============================================
CREATE PROCEDURE  [dbo].[uspUpdateEntireStudy]


AS
BEGIN
	
	DECLARE @myCur			 CURSOR, 
	        @GrantNumber	 INT,
	        @ProtocolID      VARCHAR(50), 
	        @PILastName      VARCHAR(50), 
	        @EntireStudy     INT;

	
	
	
	SET @myCur = CURSOR FOR
	SELECT GrantNumber, ProtocolID, PILastName, EntireStudy
	FROM   [DT4-93373-FY13done]
	WHERE  EntireStudy IS NOT NULL;
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @GrantNumber, @ProtocolID, @PILastName, @EntireStudy
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE dt4fy13
		SET    EntireStudy = @EntireStudy
		WHERE  GrantNumber = @GrantNumber
		AND    ProtocolID  = @ProtocolID
		AND    PILastName  = @PILastName;
		
		FETCH NEXT
		FROM @myCur INTO @GrantNumber, @ProtocolID, @PILastName, @EntireStudy

	END
	CLOSE @myCur
	DEALLOCATE @myCur

END
