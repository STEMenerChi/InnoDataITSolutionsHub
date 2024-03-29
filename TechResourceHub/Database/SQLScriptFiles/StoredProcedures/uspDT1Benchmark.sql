USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT1aBenchMark]    Script Date: 11/04/2013 12:34:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================
-- Author:		Chi T. Dinh
-- Create date: June 3, 2012
-- Description:	Get the High, Median, and Low, and Subottal number of the Sr. Leadership 
                for each of the Center Type (Basic, Clinical, and Comprehensive)
   
   Note: to calculate the median, find the total number, add 1 and divide by 2.
   Param:  FY 
   
  
    
  
  DATE         DESC
  11/04/2013   Modified sum4 to dt4
  
-- =============================================*/
/*
--Drop table DT1aBenchMark;
CREATE TABLE DT1aBenchMark(
DT1aBenchMarkID [int] IDENTITY(1,1) NOT NULL, 
FY int not null,
BasicCount Int,
BasicHigh int,
BasicLow int,
BasicMedian int,
BasicSubtotal int,
ClinicalCount Int,
ClinicalHigh int,
ClinicalLow int,
ClinicalMedian int,
ClinicalSubtotal int,
CompCount Int,
CompHigh int,
CompLow int,
CompMedian int,
CompSubtotal int);
GO

alter table DT1aBenchMark 
Add CONSTRAINT [PKDT1aBenchMark] PRIMARY KEY CLUSTERED 
(
	[DT1aBenchMarkID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


*/

ALTER PROCEDURE [dbo].[uspDT1aBenchMark] 

AS
BEGIN

	DECLARE @Subtotal INT,
	        @CenterTypeID INT,
			@BasicCount INT,
	        @BasicHigh INT,
			@BasicLow INT,
			@BasicMedian FLOAT,
			@ClinicalCount Int,
			@ClinicalHigh int,
			@ClinicalLow int,
			@ClinicalMedian FLOAT,
			@CompCount Int,
			@CompHigh int,
			@CompLow int,
			@CompMedian FLOAT,
	        @curSubtotal CURSOR,
	        @rc1 INT, @rc2 INT, @rc3 INT,
	        @FY INT;
	    
    
    SET @FY = 2012;
    
     /* 1.  run the following query manually 
    
    INSERT INTO DT1aBenchMark(FY, BasicCount, ClinicalCount, CompCount)
    VALUES (2012, 7, 20, 41);

    */

     --  2. get subTotal number of leaders for (1) Basic, (2) Clinical, and (3) Comprehensive Centers
	 SET @curSubtotal = CURSOR FOR
	 
		 SELECT c.CenterTypeID,  COUNT(*) as SubTotal 
		 FROM   [DT1A-2012] s,
			    Center c
		 WHERE  FY = 2012
		 AND    s.centerID = c.CenterID
		 and    C.CenterTypeID in (1,2, 3)
		 GROUP BY c.CenterTypeID
						
		OPEN @curSubtotal
		FETCH NEXT
		FROM @curSubtotal INTO @CenterTypeID, @Subtotal
		WHILE @@FETCH_STATUS = 0
		BEGIN
		    
		    print '@CenterTypeID is ' + + RTRIM(CAST(@CenterTypeID AS nvarchar(5)))
		    IF @CenterTypeID = 1
		    BEGIN
				UPDATE DT1aBenchMark
				SET BasicSubtotal = @Subtotal
				WHERE FY = @FY
				-- get @@RowCount.  It returns the number of rows affected by the last statement.  Type = INT.
			    SELECT  @rc1 = @@ROWCOUNT
                print 'basic, @@RowCount is ' + + RTRIM(CAST(@rc1 AS nvarchar(5))) 
			END
			ELSE IF @CenterTypeID = 2
			BEGIN
				UPDATE DT1aBenchMark
				SET ClinicalSubtotal = @Subtotal
				WHERE FY = @FY
			END
			ELSE
			BEGIN
			    UPDATE DT1aBenchMark
				SET CompSubtotal = @Subtotal
				WHERE FY = @FY;
		    END
			FETCH NEXT
			FROM @curSubtotal INTO  @CenterTypeID, @Subtotal
		END
		CLOSE @curSubtotal
		DEALLOCATE @curSubtotal

	--================ get high/MAX numbers of leaders============================
	UPDATE DT1aBenchMark
	
	SET BasicHigh = (SELECT  MAX(cnt)  as DT1aMaxBasic
					 FROM ( SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
							FROM   [DT1A-2012] s,
								   Center c
							WHERE c.CenterTypeID = 1
							AND s.FY = 2012
							AND  s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)

		UPDATE DT1aBenchMark
		SET ClinicalHigh = (SELECT  MAX(cnt)  as DT1aMaxClinical
							FROM 
							   (SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
								FROM   [DT1A-2012] s,
									   Center c
								WHERE c.CenterTypeID = 2
								AND   s.centerID = c.CenterID 
								AND   s.FY = @FY  
								GROUP BY c.CenterTypeID, s.GrantNumber
								)       sys )
        WHERE FY = @FY;
        
		UPDATE DT1aBenchMark
		SET CompHigh = (SELECT  MAX(cnt)  as DT1aMaxClinical
					    FROM 
							(SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
						     FROM   [DT1A-2012] s,
									   Center c
							 WHERE c.CenterTypeID = 3
							 AND   s.centerID = c.CenterID
							 AND s.FY = @FY  
							 GROUP BY c.CenterTypeID, s.GrantNumber
							 )
					    sys)
	  WHERE FY = @FY;

--================get low/MIN numbers of leaders==========================

		UPDATE DT1aBenchMark
		SET BasicLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
							FROM   [DT1A-2012] s,
								   Center c
							WHERE  c.CenterTypeID = 1
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
        WHERE FY = @FY;
        
		UPDATE DT1aBenchMark
		SET ClinicalLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
							FROM   [DT1A-2012] s,
								   Center c
							WHERE  c.CenterTypeID = 2
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		WHERE FY = @FY;
							
		UPDATE DT1aBenchMark
		SET CompLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
							FROM   [DT1A-2012] s,
								   Center c
							WHERE  c.CenterTypeID = 3
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		WHERE FY = @FY;
		
		--========= Get the median number of the Sr. Leaders=====================
	    -- Basic Median
		SELECT @BasicCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT(s.GrantNumber) AS IDCount 
				FROM   [DT1A-2012] s,
					   Center c
				WHERE c.CenterTypeID = 1
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @BasicMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(s.GrantNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(s.GrantNumber))AS ROW 
		FROM   [DT1A-2012] s,
			   Center c
		WHERE c.CenterTypeID = 1
		AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@BasicCount/2),(@BasicCount/2)+1)

		UPDATE DT1aBenchMark
		SET BasicMedian = (SELECT CEILING(@BasicMedian)),
		    BasicCount = (SELECT @BasicCount)
		WHERE FY = @FY;
		    
		--Clinical Median
		SELECT @ClinicalCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT(s.GrantNumber) AS IDCount 
				FROM   [DT1A-2012] s,
					   Center c
				WHERE c.CenterTypeID = 2
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @ClinicalMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(s.GrantNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(s.GrantNumber))AS ROW 
		FROM   [DT1A-2012] s,
			   Center c
		WHERE c.CenterTypeID = 2
		AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@ClinicalCount/2),(@ClinicalCount/2)+1)

		UPDATE DT1aBenchMark
		SET ClinicalMedian = (SELECT CEILING(@ClinicalMedian)),
		    ClinicalCount = (SELECT @ClinicalCount)
		WHERE FY = @FY;

-- for Comp Median
	
	    
		SELECT @CompCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT(s.GrantNumber) AS IDCount 
				FROM   [DT1A-2012] s,
					   Center c
				WHERE c.CenterTypeID = 3
			    AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @CompMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(s.GrantNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(s.GrantNumber))AS ROW 
		FROM   [DT1A-2012] s,
			   Center c
		WHERE c.CenterTypeID = 3
		AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@CompCount/2),(@CompCount/2)+1)

		UPDATE DT1aBenchMark
		SET CompMedian = (SELECT CEILING(@CompMedian)),
		    CompCount = (SELECT @CompCount)
		WHERE FY = @FY;

END
