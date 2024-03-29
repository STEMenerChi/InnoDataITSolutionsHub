USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT1cBenchMark]    Script Date: 3/21/2017 2:25:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[uspDT1cBenchMark] 

/*-- =========================================================================================================
-- Author:		Chi T. Dinh
-- Create date: June 3, 2012
-- Description:	Get the High, Median, and Low, and Subtotal number of the Membership 
                for each of the Center Type (Basic, Clinical, and Comprehensive)
   
   Note: to calculate the median, find the total number, add 1 and divide by 2.
   Param:  FY 
   
   DATE			DESC
   11/05/2013	Modified sum1c to dt1c
   03/02/2017   Updated DT1cBenchmark with FY15 data
   NOTES:
                Follow & execute step 1-n manually
				Median: get the middle number
				        In the case of having two middle numbers then get the avg (or add them up then div by 2).


-- ============================================================================================================*/

/*
Execute the following sql statments manually: 

1.  Verify that there are 68 centers for fy15 
    SELECT COUNT(*) FROM DT1cMember WHERE FY = 2015; 

2.  Backup:    
    SELECT * 
    INTO dt1cBenchmarkBU20170302
    from  dt1cBenchmark;

3.  reset the Entity PK to [max ID]
    DBCC CHECKIDENT('dt1cBenchmark', RESEED, 5);

4.  Get the number of center that are (1) Basic, (2) Clinical, and (3) Comprehensive Centers

select * from dt1cBenchmark
order by fy; 

Get this from Nga (FY15):
45 Comp
17 Clinical
 7 Basic

get this from Nga (FY16):
47 Comp
15 Clinical
 7 Basic

    as well as the number of aligned and non-aligned members:
 
   SELECT c.CenterTypeID,  Sum(AlignedNumber) as AlignSubTotal 
		 FROM   DT1cMember m,
			    Center c
		 WHERE  m.centerID = c.CenterID
		 AND    FY = 2015
		 GROUP BY c.CenterTypeID

	SELECT c.CenterTypeID,  Sum(NonAlignedNumber) as NonSubTotal 
		 FROM   DT1cMember m,
			    Center c
		 WHERE  m.centerID = c.CenterID
		 AND    FY = 2015
		 GROUP BY c.CenterTypeID

    INSERT INTO DT1cBenchmark(FY, BasicCount, AlignBasicSubtotal, ClinicalCount, AlignClinicalSubtotal,  CompCount, AlignCompSubtotal,  NonBasicSubtotal, NonClinicalSubtotal, NonCompSubtotal)
    VALUES (2015, 7, 309, 15, 2021, 47, 12907, 7, 131, 1306);

5. To Verify for Basic aligned member: (1 =basic, 2=clinical, 3=comp)

	SELECT c.CenterTypeID, m.GrantNumber,  SUM(m.ALIGNEDNumber) AS CNT
	FROM   DT1cMember m,
		   Center c
	WHERE c.CenterTypeID = 1
	AND m.FY = 2015
	AND  m.centerID = c.CenterID
	GROUP BY c.CenterTypeID, m.GrantNumber
	ORDER BY CNT
		 
	SELECT * from DT1cBenchMark

6. 

*/


AS
BEGIN

	DECLARE @Subtotal INT,
	        @CenterTypeID INT,
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
	        @curSubtotal CURSOR,
	        @rc1 INT, @rc2 INT, @rc3 INT,
	        @FY INT;
	    
    
    SET @FY = 2015;
    
 
		
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

END
