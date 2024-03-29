SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date: 02/09/2012
-- Description:	Updates PersonDegree
-- =============================================
CREATE PROCEDURE  [dbo].[uspPersonDegree]
AS
BEGIN
	
	DECLARE @myCur		CURSOR, 
	        @Degree1	NVARCHAR(100),
	        @Degree2	NVARCHAR(100),
		    @Degree3	NVARCHAR(100),
	        @LastName   NVARCHAR(100),
	        @FirstName  NVARCHAR(100), 
	        @PersonID	INT
	       
	SET @myCur = CURSOR FOR
	SELECT Degree1, Degree2, Degree3, l.LastName, l.FirstName, 
	       p.PersonID
	FROM   Lead2011 l,
	       Person p
	WHERE  UPPER(l.lastname) = upper(p.lastName)
	AND    UPPER(L.FirstName) = UPPER(p.FirstName) 
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @Degree1, @Degree2, @Degree3, @LastName, @FirstName, @PersonID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE vwP30RatioFY2011
		SET    CenterID = @CenterID
		WHERE  institution = @InstitutionName
		FETCH NEXT
		FROM @myCur INTO @CenterID, @InstitutionName
	END
	CLOSE @myCur
	DEALLOCATE @myCur

END
GO