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
-- Description:	uspSelectSrLeaders is created for the Sum1A- Sr. Leaders.  
--              Concatenate Degrees together into a string only if Degree1, D
-- =============================================
ALTER PROCEDURE  [dbo].[uspSelectSrLeaders]
AS
BEGIN
	
	DECLARE @myCur				 CURSOR, 
	        @GrantNumber		INT,
	        @NoOfMembers		INT,
	        @InstitutionName	NVARCHAR(255), 
	        @Title				NVARCHAR(255), 
	        @Name				NVARCHAR(255),
	        @Degree				NVARCHAR(100), 
	        @Degree1			NVARCHAR(100),
	        @Degree2			NVARCHAR(100),
	        @Degree3			NVARCHAR(100);
	       
	SET @myCur = CURSOR FOR
	SELECT m.GRANTNUMB AS GrantNumber, m.ALIGNED + m.NONALIGNED AS NumOfMembers, 
	       c.InstitutionName AS Institution, 
	       l.Title, l.LastName + ', ' + l.FirstName AS Name, 
           Degree1,  Degree2, Degree3 
	FROM   dbo.Lead2011 AS l INNER JOIN
           dbo.Center AS c ON l.GrantNum = c.GrantNumber INNER JOIN
           dbo.Membership2011 AS m ON l.GrantNum = m.GRANTNUMB
	GROUP BY m.ALIGNED + m.NONALIGNED, c.InstitutionName, l.Title, l.LastName, l.FirstName, l.Degree1, l.Degree2, l.Degree3
	ORDER BY NumOfMembers, Institution, l.Title;
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @GrantNumber, @InstitutionName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE P30RatioFY2011
		SET    GrantNumber = @GrantNumber
		WHERE  institution = @InstitutionName
		FETCH NEXT
		FROM @myCur INTO @GrantNumber, @InstitutionName
	END
	CLOSE @myCur
	DEALLOCATE @myCur

END
