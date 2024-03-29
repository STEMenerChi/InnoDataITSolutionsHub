USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspUpdateP30GrantNumber]    Script Date: 12/12/2013 10:16:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************************
DATE			DESC
----			-----
12/12/2013		Created this [uspUpdateP30GrantNumber] to update the P30GrantNumber in a given table. 


**************************************************************************************************************/
ALTER PROCEDURE  [dbo].[uspUpdateP30GrantNumber] 
 

AS
BEGIN
	
	DECLARE @myCur			 CURSOR, 
	        @GrantNumber	 INT,
	        @P30GrantNumber  VARCHAR(50);

	
	-- if PK
	-- ALTER TABLE CenterDetail Add CenterID [int] IDENTITY(1,1) NOT NULL;
	-- if FK 
	--ALTER TABLE CenterDetail Add [CenterId] [int]  NULL;
	
	
	SET @myCur = CURSOR FOR
	SELECT  GrantNumber, P30GrantNumber
	FROM   P30GrantNumberFY12;

		
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO  @GrantNumber, @P30GrantNumber
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
	    UPDATE DT2B
		SET    p30GrantNumber  =  @P30GrantNumber
		WHERE  GrantNumber     =  @GrantNumber
		AND    FY              =  2012; 
		    


		FETCH NEXT
		FROM @myCur INTO @GrantNumber, @P30GrantNumber
		
	END 
	CLOSE @myCur
	DEALLOCATE @myCur

END
