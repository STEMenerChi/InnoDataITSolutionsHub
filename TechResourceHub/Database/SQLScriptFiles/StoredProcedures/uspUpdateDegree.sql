USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspPersonDegree]    Script Date: 05/10/2012 11:04:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date: May 10, 2012
-- Description:	uspUpdateDegree
--              Concate Degrees into one field, ignore the blank ones.
--              (1) imported the Lead2011 from Excel--> MS-ACCESS --> here (OCC)
--              (2) ALTER TABLE Lead2011 add  degree nvarchar(255);
--              (3) Execute this stored procedure uspUpdateDegree
-- =============================================
ALTER PROCEDURE  [dbo].[uspSelectSrLeaders]
AS
BEGIN
	
	DECLARE @myCur				CURSOR, 
	        @GrantNumber		INT,
	        @Degree				NVARCHAR(100), 
	        @Degree1			NVARCHAR(100),
	        @Degree2			NVARCHAR(100),
	        @Degree3			NVARCHAR(100);
	       
	SET @Degree = '';
	
	SET @myCur = CURSOR FOR
	SELECT GrantNum, Degree1, Degree2, Degree3, 
			CASE
			WHEN (Degree2 IS NULL) AND (Degree3 is NULL) THEN Degree1
			WHEN (Degree2 IS NOT NULL) AND (Degree3 is NULL) THEN Degree1 + ', ' + Degree2
			ELSE Degree1 + ', ' + Degree2 + ', ' + Degree3
			END AS Degree 
	FROM   dbo.Lead2011 
	WHERE  Degree1 is not null
	ORDER BY 1;
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @GrantNumber,  @Degree1, @Degree2, @Degree3
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    IF @Degree1 IS NULL then @Degree = ''
	    ELSE 
	       @Degree = @Degree1 + ', ';
	       
	    IF @Degree2 IS NULL then @Degree = ''
	    ELSE 
	       @Degree = @Degree1 + ', ';
	       
	       
		UPDATE Lead2011
		SET    GrantNumber = @GrantNumber
		WHERE  institution = @InstitutionName
		FETCH NEXT
		FROM @myCur INTO @GrantNumber, @InstitutionName
	END
	CLOSE @myCur
	DEALLOCATE @myCur

END
