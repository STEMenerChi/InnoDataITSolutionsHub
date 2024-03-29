USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT1dBenchMark]    Script Date: 3/21/2017 2:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- ====================================================================================================================================	 
   DATE			DESC
   
	DATE		DEV			DESC
	06/03/2012  Chi Dinh	Created
							Get the High, Median, and Low, and Subtotal number of the Shared Resources 
                            for each of the Center Type (Basic, Clinical, and Comprehensive)
   
   Note: to calculate the median, find the total number, add 1 and divide by 2.
   Param:  FY 

   11/04/2013   Chi			Modified sum1d to dt1d,
							uspGetDT1dBenchMark to uspDT1dBenchmark.
   11/21/2013   Chi			Modified COUNT(s.GrantNumber) to COUNT(DISTINCT s.SRName)
							in order to factor in that a SR may have more than one director (multiple records) but should be count as 1 SR.
   03/21/2017   Chi         Modified using FY15 Data
-- ==========================================================================================================================================*/
ALTER PROCEDURE [dbo].[uspDT1dBenchMark] 

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
	    
    
    SET @FY = 2015;
    
    --select COUNT(*) from DT1dSR
    
   
/* Execute the folowing statements manually: 
     
1. backup:

     select *
     into dt1dBenchmark20170321
     FROM dt1dBenchmark;

2. reset the PK
select max(DT1dBenchMarkID) from DT1dBenchMark;
DBCC CHECKIDENT('DT1dBenchMark', RESEED, 8);

3. Get this from Nga (FY15):
45 Comp
17 Clinical
 7 Basic

(FY16):
47 Comp
15 Clinical
 7 Basic



4.  get subTotal number of Shared Resources for (1) Basic, (2) Clinical, and (3) Comprehensive Centers

	SELECT  c.CenterTypeID,  count(s.SRName) as CNT 
	FROM   DT1dSR s,
		Center c
	WHERE  s.centerID = c.CenterID
	AND    FY = 2015
	GROUP BY c.CenterTypeID
	ORDER BY C.CenterTypeID;


		 
	INSERT INTO DT1dBenchMark(FY, BasicCount, BasicSubtotal, ClinicalCount, ClinicalSubtotal, CompCount, CompSubtotal)
	VALUES (2015, 7, 50, 17, 111, 45, 542);
     
    
    select * from dt1dBenchmark 
	order by FY;
						
	*/

	--================ get high/MAX numbers of leaders============================
	UPDATE DT1dBenchMark
	SET BasicHigh = (SELECT  MAX(cnt)  as DT1dMaxBasic
					 FROM ( SELECT c.CenterTypeID, s.GrantNumber,  COUNT(DISTINCT s.SRname) AS CNT
							FROM   DT1dSR s,
								   Center c
							WHERE c.CenterTypeID = 1
							AND s.FY = @FY
							AND  s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
	 WHERE   FY = @FY;
	 
		UPDATE DT1dBenchMark
		SET ClinicalHigh = (SELECT  MAX(cnt)  as DT1dMaxClinical
							fROM 
							(   SELECT c.CenterTypeID, s.GrantNumber,  COUNT(DISTINCT s.SRname) AS CNT
								FROM   DT1dSR s,
									   Center c
								WHERE c.CenterTypeID = 2
								AND   s.centerID = c.CenterID
								AND s.FY = 2012  
								GROUP BY c.CenterTypeID, s.GrantNumber
								) sys)
		 WHERE   FY = @FY;
		 
		UPDATE DT1dBenchMark
		SET CompHigh = (SELECT  MAX(cnt)  as DT1dMaxClinical
							fROM 
							(   SELECT c.CenterTypeID, s.GrantNumber,  COUNT(DISTINCT s.SRname) AS CNT
								FROM   DT1dSR s,
									   Center c
								WHERE c.CenterTypeID = 3
								AND   s.centerID = c.CenterID
								AND s.FY = @FY  
								GROUP BY c.CenterTypeID, s.GrantNumber
								) sys)
		 WHERE   FY = @FY;
		 
--================get low/MIN numbers of leaders==========================

		UPDATE DT1dBenchMark
		SET BasicLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT(DISTINCT s.SRname) AS CNT
							FROM   DT1dSR s,
								   Center c
							WHERE  c.CenterTypeID = 1
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		 WHERE   FY = @FY;
		 
		UPDATE DT1dBenchMark
		SET ClinicalLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
							FROM   DT1dSR s,
								   Center c
							WHERE  c.CenterTypeID = 2
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		 WHERE   FY = @FY;
		 			
		UPDATE DT1dBenchMark
		SET CompLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
							FROM   DT1dSR s,
								   Center c
							WHERE  c.CenterTypeID = 3
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		 WHERE   FY = @FY;
		 
		--========= Get the median number of the Sr. Leaders=====================
	    -- Basic Median
		SELECT @BasicCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT(s.GrantNumber) AS IDCount 
				FROM   DT1dSR s,
					   Center c
				WHERE c.CenterTypeID = 1
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @BasicMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(s.GrantNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(s.GrantNumber))AS ROW 
		FROM   DT1dSR s,
			   Center c
		WHERE c.CenterTypeID = 1
		AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@BasicCount/2),(@BasicCount/2)+1)

		UPDATE DT1dBenchMark
		SET BasicMedian = (SELECT CEILING(@BasicMedian))
		WHERE   FY = @FY;
		    
		--Clinical Median
		SELECT @ClinicalCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT(s.GrantNumber) AS IDCount 
				FROM   DT1dSR s,
					   Center c
				WHERE c.CenterTypeID = 2
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @ClinicalMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(s.GrantNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(s.GrantNumber))AS ROW 
		FROM   DT1dSR s,
			   Center c
		WHERE c.CenterTypeID = 2
	    AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@ClinicalCount/2),(@ClinicalCount/2)+1)

		UPDATE DT1dBenchMark
		SET ClinicalMedian = (SELECT CEILING(@ClinicalMedian))
		WHERE   FY = @FY;

-- for Comp Median
	
	    
		SELECT @CompCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT(s.GrantNumber) AS IDCount 
				FROM   DT1dSR s,
					   Center c
				WHERE c.CenterTypeID = 3
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @CompMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(s.GrantNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(s.GrantNumber))AS ROW 
		FROM   DT1dSR s,
			   Center c
		WHERE c.CenterTypeID = 3
		AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@CompCount/2),(@CompCount/2)+1)

		UPDATE DT1dBenchMark
		SET CompMedian = (SELECT CEILING(@CompMedian))
	    WHERE   FY = @FY;

END
