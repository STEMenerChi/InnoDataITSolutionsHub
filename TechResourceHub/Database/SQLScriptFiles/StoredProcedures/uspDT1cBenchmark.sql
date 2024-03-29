USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT1cBenchMarkOBSOLETE]    Script Date: 2/15/2022 5:42:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[uspDT1cBenchMark] 
@FY INT

/*-- =========================================================================================================
   DATE			DEV			DESC
   06/03/2012	Chi T. Dinh	Created, Get the High, Median, and Low, and Subtotal number of the Membership for each of the Center Type (1)Basic, (2)Clinical, and (3)Comprehensive
   12/17/2020   Chi         Updated to filter out inactive 
   01/15/2022   Chi         Even though, OCC stopped tracking membership since FY2017
                            It's necesary to continue add FY, Basic, Clinical, and comp count in order for the vwBenchmark1 to work. 
   NOTES:
   to calculate the median, find the total number, add 1 and divide by 2.
   Param:  FY 
                	
	Follow & execute step 1-n manually
	Median: get the middle number
    In the case of having two middle numbers then get the avg (or add them up then div by 2).
-- ============================================================================================================*/

/*
Execute the following sql statments manually: 

1.  -- Ensure data are in the table, UP to 2016 only, after that the Centers were not required to send in these data. 
    SELECT COUNT(*), FY 
	FROM DT1cMember 
	GROUP BY FY 
	ORDER BY FY;

2.  Backup 1st AWLAYS:    
    SELECT * 
    INTO dt1cBenchmarkBU2022Feb
    from  dt1cBenchmark;

3.  reset the Entity PK to [max ID]
    select MAX(dt1cBenchmarkID) from dt1cBenchmark;
    DBCC CHECKIDENT('dt1cBenchmark', RESEED,12);

4.  Get the number of center that are of  (1) Basic, (2) Clinical, and (3) Comprehensive Centers
Values (2011, 7, 19, 40);
Values (2012, 7, 19, 41);
Values (2013, 7, 20, 41);  

Values (2014, 7, 20, 41);
Huge change 
Values (2015, 7, 17, 45);
Values (2016, 7, 15, 47);


Values (2017, 7, 13, 49);
Values (2018, 7, 14, 49);  
Values (2019, 7, 13, 51);

Values (2020, 7, 13, 51);

Values (2021, 7, 13, 51);

UPDATE DT1cBenchmark
SET   ClinicalCount = 15,
      CompCount = 47
WHERE FY = 2016;

UPDATE DT1cBenchmark
SET   ClinicalCount = 13,
      CompCount = 49
WHERE FY = 2017;

UPDATE DT1cBenchmark
SET   ClinicalCount = 13,
      CompCount = 51
WHERE FY = 2019;


select * from DT1cBenchMark
order by fy;


		 INSERT INTO DT1cBenchmark (FY, BasicCount, ClinicalCount, CompCount)
		 Values (2020, 7, 13, 51);

5. To Verify for Basic aligned member: (1 =basic, 2=clinical, 3=comp)

	SELECT c.CenterTypeID, m.GrantNumber,  SUM(m.ALIGNEDNumber) AS CNT
	FROM   DT1cMember m,
		   Center c
	WHERE c.CenterTypeID = 1
	AND m.FY = 2015
	AND  m.centerID = c.CenterID
	GROUP BY c.CenterTypeID, m.GrantNumber
	ORDER BY CNT
		 
SELECT * from DT1cBenchMark ORDER BY FY;

*/
AS
BEGIN

	DECLARE @Subtotal INT,
			@AlignBasicCount INT,
	        @AlignBasicHigh INT,
			@AlignBasicLow INT,
			@AlignBasicMedian FLOAT,
			@AlignClinicalCount Int,
			@AlignClinicalHigh int,
			@AlignClinicalLow int,
			@AlignClinicalMedian FLOAT,
			@AlignCompCount Int,
			@AlignCompHigh int,
			@AlignCompLow int,
			@AlignCompMedian FLOAT,
			@NonBasicCount INT,
	        @NonBasicHigh INT,
			@NonBasicLow INT,
			@NonBasicMedian FLOAT,
			@NonClinicalCount Int,
			@NonClinicalHigh int,
			@NonClinicalLow int,
			@NonClinicalMedian FLOAT,
			@NonCompCount Int,
			@NonCompHigh int,
			@NonCompLow int,
			@NonCompMedian FLOAT,

	       
	        @rc1 INT, @rc2 INT, @rc3 INT,

			@myNonAlignCur  CURSOR,
			@myCur          CURSOR, 
			@AlignBasicSubtotal       INT = 0, 
			@NonAlignBasicSubtotal    INT = 0, 
			@AlignClinicalSubtotal    INT = 0, 
			@NonAlignClinicalSubtotal INT = 0, 
			@AlignCompSubtotal        INT = 0,
			@NonAlignCompSubtotal     INT = 0,
			@CenterTypeID             INT, 

			@AlignSubtotal            INT = 0, 
			@NonAlignSubtotal         INT = 0,

			@AlignGrandtotal          INT = 0, 
			@NonAlignGrandtotal       INT = 0; 
	      
    --SET @FY = 2016;
    
	--================ get BAsIC high & MAX numbers of Aligns============================
	UPDATE DT1cBenchMark
	SET AlignBasicHigh = (SELECT  MAX(cnt)  as DT1cMaxBasic
						  FROM (SELECT c.CenterTypeID, s.GrantNumber,  SUM(s.AlignedNumber) AS CNT
								FROM   DT1cMember s,
									   Center c
								WHERE c.CenterTypeID = 1
								AND s.FY = @FY
								AND  s.centerID = c.CenterID
								GROUP BY c.CenterTypeID, s.GrantNumber
								) sys)
    WHERE FY = @FY;
   
		UPDATE DT1cBenchMark
		SET AlignClinicalHigh = (SELECT  MAX(cnt)  as DT1cMaxClinical
							fROM 
							(   SELECT c.CenterTypeID, s.GrantNumber,  SUM(s.AlignedNumber) AS CNT
								FROM   DT1cMember s,
									   Center c
								WHERE c.CenterTypeID = 2
								AND   s.centerID = c.CenterID
								AND s.FY = @FY  
								GROUP BY c.CenterTypeID, s.GrantNumber
								) sys)
		WHERE FY = @FY;
		
		UPDATE DT1cBenchMark
		SET AlignCompHigh = (SELECT  MAX(cnt)  as DT1cMaxClinical
							fROM 
							(   SELECT c.CenterTypeID, s.GrantNumber,  SUM(s.AlignedNumber) AS CNT
								FROM   DT1cMember s,
									   Center c
								WHERE c.CenterTypeID = 3
								AND   s.centerID = c.CenterID
								AND s.FY = @FY  
								GROUP BY c.CenterTypeID, s.GrantNumber
								) sys)
		WHERE FY = @FY;
--================ get high/MAX numbers of NonAligns============================
	UPDATE DT1cBenchMark
	SET NonBasicHigh = (SELECT  MAX(cnt)  as DT1cMaxBasic
					 fROM ( SELECT c.CenterTypeID, s.GrantNumber,  SUM(s.NonAlignedNumber) AS CNT
							FROM   DT1cMember s,
								   Center c
							WHERE c.CenterTypeID = 1
							AND s.FY = @FY
							AND  s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
	WHERE FY = @FY;

		UPDATE DT1cBenchMark
		SET NonClinicalHigh = (SELECT  MAX(cnt)  as DT1cMaxClinical
							fROM 
							(   SELECT c.CenterTypeID, s.GrantNumber,  SUM(s.NonAlignedNumber) AS CNT
								FROM   DT1cMember s,
									   Center c
								WHERE c.CenterTypeID = 2
								AND   s.centerID = c.CenterID
								AND s.FY = @FY  
								GROUP BY c.CenterTypeID, s.GrantNumber
								) sys)
		WHERE FY = @FY;
		
		UPDATE DT1cBenchMark
		SET NonCompHigh = (SELECT  MAX(cnt)  as DT1cMaxClinical
							fROM 
							(   SELECT c.CenterTypeID, s.GrantNumber,  SUM(s.NonAlignedNumber) AS CNT
								FROM   DT1cMember s,
									   Center c
								WHERE c.CenterTypeID = 3
								AND   s.centerID = c.CenterID
								AND s.FY = @FY  
								GROUP BY c.CenterTypeID, s.GrantNumber
								) sys)								
		WHERE FY = @FY;
--================get low/MIN numbers of Aligned Members==========================

		UPDATE DT1cBenchMark
		SET AlignBasicLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  SUM(s.AlignedNumber) AS CNT
							FROM   DT1cMember s,
								   Center c
							WHERE  c.CenterTypeID = 1
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		WHERE FY = @FY;
		
		UPDATE DT1cBenchMark
		SET AlignClinicalLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  SUM(s.AlignedNumber) AS CNT
							FROM   DT1cMember s,
								   Center c
							WHERE  c.CenterTypeID = 2
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		WHERE FY = @FY;
			
		UPDATE DT1cBenchMark
		SET AlignCompLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  SUM(s.AlignedNumber) AS CNT
							FROM   DT1cMember s,
								   Center c
							WHERE  c.CenterTypeID = 3
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		WHERE FY = @FY;
--================get low/MIN numbers of NonAlligned Members==========================

		UPDATE DT1cBenchMark
		SET NonBasicLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  SUM(s.NonAlignedNumber) AS CNT
							FROM   DT1cMember s,
								   Center c
							WHERE  c.CenterTypeID = 1
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		WHERE FY = @FY;
		
		UPDATE DT1cBenchMark
		SET NonClinicalLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  SUM(s.NonAlignedNumber) AS CNT
							FROM   DT1cMember s,
								   Center c
							WHERE  c.CenterTypeID = 2
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		WHERE FY = @FY;
			
		UPDATE DT1cBenchMark
		SET NonCompLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  SUM(s.NonAlignedNumber) AS CNT
							FROM   DT1cMember s,
								   Center c
							WHERE  c.CenterTypeID = 3
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		WHERE FY = @FY;
		--========= Get the median number of Aligned members=====================
	    -- Basic Median
		SELECT @AlignBasicCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber, SUM(s.AlignedNumber) AS IDCount 
				FROM   DT1cMember s,
					   Center c
				WHERE c.CenterTypeID = 1
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @AlignBasicMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,SUM(s.AlignedNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY SUM(s.AlignedNumber))AS ROW 
		FROM   DT1cMember s,
			   Center c
		WHERE c.CenterTypeID = 1
		AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@AlignBasicCount/2),(@AlignBasicCount/2)+1)

		UPDATE DT1cBenchMark
		SET AlignBasicMedian = (SELECT CEILING(@AlignBasicMedian))
		WHERE FY = @FY;
		
		--Clinical Median
		SELECT @AlignClinicalCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,SUM(s.AlignedNumber) AS IDCount 
				FROM   DT1cMember s,
					   Center c
				WHERE c.CenterTypeID = 2
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @AlignClinicalMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,SUM(s.AlignedNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY SUM(s.AlignedNumber))AS ROW 
		FROM   DT1cMember s,
			   Center c
		WHERE c.CenterTypeID = 2
				AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@AlignClinicalCount/2),(@AlignClinicalCount/2)+1)

		UPDATE DT1cBenchMark
		SET AlignClinicalMedian = (SELECT CEILING(@AlignClinicalMedian))
		WHERE FY = @FY;

-- for Comp Median
	
	    
		SELECT @AlignCompCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,SUM(s.AlignedNumber) AS IDCount 
				FROM   DT1cMember s,
					   Center c
				WHERE c.CenterTypeID = 3
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @AlignCompMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,SUM(s.AlignedNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY SUM(s.AlignedNumber))AS ROW 
		FROM   DT1cMember s,
			   Center c
		WHERE c.CenterTypeID = 3
				AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@AlignCompCount/2),(@AlignCompCount/2)+1)

		UPDATE DT1cBenchMark
		SET AlignCompMedian = (SELECT CEILING(@AlignCompMedian))
		WHERE FY = @FY;
		
		---NonAligned
		-- Basic Median
		SELECT @NonBasicCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber, SUM(s.NonAlignedNumber) AS IDCount 
				FROM   DT1cMember s,
					   Center c
				WHERE c.CenterTypeID = 1
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @NonBasicMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,SUM(s.NonAlignedNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY SUM(s.NonAlignedNumber))AS ROW 
		FROM   DT1cMember s,
			   Center c
		WHERE c.CenterTypeID = 1
		AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@NonBasicCount/2),(@NonBasicCount/2)+1)

		UPDATE DT1cBenchMark
		SET NonBasicMedian = (SELECT CEILING(@NonBasicMedian))
		WHERE FY = @FY;
		
		--Clinical Median
		SELECT @NonClinicalCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,SUM(s.NonAlignedNumber) AS IDCount 
				FROM   DT1cMember s,
					   Center c
				WHERE c.CenterTypeID = 2
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @NonClinicalMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,SUM(s.NonAlignedNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY SUM(s.NonAlignedNumber))AS ROW 
		FROM   DT1cMember s,
			   Center c
		WHERE c.CenterTypeID = 2
				AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@NonClinicalCount/2),(@NonClinicalCount/2)+1)

		UPDATE DT1cBenchMark
		SET NonClinicalMedian = (SELECT CEILING(@NonClinicalMedian))
		WHERE FY = @FY;

       -- for Comp Median  
		SELECT @NonCompCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,SUM(s.NonAlignedNumber) AS IDCount 
				FROM   DT1cMember s,
					   Center c
				WHERE c.CenterTypeID = 3
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @NonCompMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,SUM(s.NonAlignedNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY SUM(s.NonAlignedNumber))AS ROW 
		FROM   DT1cMember s,
			   Center c
		WHERE c.CenterTypeID = 3
				AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@NonCompCount/2),(@NonCompCount/2)+1)

		UPDATE DT1cBenchMark
		SET NonCompMedian = (SELECT CEILING(@NonCompMedian))
		WHERE FY = @FY;

		--========= Get the Subtotal for Align Basic, Clinical and Comp ==========================================
		SET @myCur = CURSOR FOR
			 SELECT s.FY, c.CenterTypeID,  Sum(AlignedNumber) as AlignSubTotal 
			 FROM   DT1cMember s,
					Center c
			 WHERE  s.centerID = c.CenterID
			 AND    c.isActive = 1
			 AND    s.FY = @FY
			 GROUP BY s.FY, c.CenterTypeID; 

	    OPEN @myCur
		FETCH NEXT
		FROM @myCur INTO @FY, @CenterTypeID, @AlignSubtotal
		WHILE @@FETCH_STATUS = 0
		BEGIN 
			IF @CenterTypeID = 1 
			BEGIN
				UPDATE DT1cBenchmark
				SET    AlignBasicSubtotal = @AlignSubtotal
				WHERE FY = @FY; 
				
			END			
			ELSE 			
			IF @CenterTypeID = 2
			BEGIN
				UPDATE DT1cBenchmark
				SET    AlignClinicalSubtotal = @AlignSubtotal
				WHERE FY = @FY; 
			END	
			ELSE 
			BEGIN
				UPDATE DT1cBenchmark
				SET    AlignCompSubtotal = @AlignSubtotal
				WHERE FY = @FY; 
			END	
			
			--Acucumulating the Align grandtotal from subtotals:  
			SET @AlignGrandTotal = @AlignGrandTotal + @AlignSubtotal
			print 'align grant total ' + CONVERT(VARCHAR(10), @AlignGrandTotal);

			FETCH NEXT
			FROM @myCur INTO @FY, @CenterTypeID, @AlignSubtotal

		    UPDATE DT1cBenchmark
	        SET    alignTotal = @AlignGrandTotal
            WHERE  FY    = @FY;

		END
		CLOSE @myCur
		DEALLOCATE @myCur
--============ Get the Subtotal for NON-Align Basic, Clinical and Comp ==========================================
 
	   SET @myNonAlignCur = CURSOR FOR
			 SELECT s.FY, c.CenterTypeID,  Sum(NonAlignedNumber) as NonAlignSubTotal 
			 FROM   DT1cMember s,
					Center c
			 WHERE  s.centerID = c.CenterID
			 AND    c.isActive = 1
			 AND    s.FY = @FY
			 GROUP BY s.FY, c.CenterTypeID; 

	    OPEN @myNonAlignCur
		FETCH NEXT
		FROM @myNonAlignCur INTO @FY, @CenterTypeID, @NonAlignSubtotal
		WHILE @@FETCH_STATUS = 0
		BEGIN 
			IF @CenterTypeID = 1 
			BEGIN
				UPDATE DT1cBenchmark
				SET    NonBasicSubtotal = @NonAlignSubtotal
				WHERE FY = @FY; 
			END			
			ELSE IF @CenterTypeID = 2
			BEGIN
				UPDATE DT1cBenchmark
				SET    NonClinicalSubtotal = @NonAlignSubtotal
				WHERE FY = @FY; 
			END	
			ELSE 
			BEGIN
				UPDATE DT1cBenchmark
				SET    NonCompSubtotal = @NonAlignSubtotal
				WHERE FY = @FY; 		
			END	

			-- gaccumulating the grandtotal from the subtotal 
			SET @NonAlignGrandtotal = @NonAlignGrandtotal + @NonAlignSubtotal
			print 'NON-align grandtotal ' + CONVERT(VARCHAR(10), @NonAlignGrandtotal);
			
			FETCH NEXT
			FROM @myNonAlignCur INTO @FY, @CenterTypeID, @NonAlignSubtotal
			--========= Update the NON-align grand ToTal  ===================================================================
		    UPDATE DT1cBenchmark
	        SET    nonAlignTotal = @NonAlignGrandtotal
            WHERE  FY    = @FY;
			
		END
		CLOSE @myNonAlignCur
		DEALLOCATE @myNonAlignCur

END
