USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT1bBenchmark]    Script Date: 4/25/2017 1:10:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =======================================================================================
   DATE			DEV			DESC
   06/03/2015   Chi T. Dinh Created
                            Calculated the High, Median, and Low, and Subottal number of the Sr. Leadership 
                            for each of the Center Type (Basic, Clinical, and Comprehensive)
   11/04/2013	Chi			Modified sum1B to dt1b, 
							uspGetDT1bBenchmark to uspDT1bBenchmark
   11/20/2013	Chi			Modified by adding another of SUM(SubTotalPerGrant) SubTotal 
							in order to factor in that there are some programs with multiple leaders (still count as one program).
   03/09/2017   Chi			Updated with FY15 data
   04/25/2017	Chi			Updated with FY14 data


   Note: to calculate the median, get the middle values, add them up and divide by 2.
   Param:  FY 
   
           
-- ===============================================================================================*/

/*  Manually run the following:

-- 1. backup:
select *
Into DT1bBenchmark20170309
from DT1bBenchmark;

-- 2. Exam dt1bProgram
select grantnumber, progname 
from dt1bProgram 
where fy = 2015;

select distinct grantnumber
from dt1bProgram 
where fy = 2015;
--68 :-)
		
Get this from Nga

FY14:
Basic =    7
Clinical = 20
Comp = 41

FY15:
45 Comp
17 Clinical
 7 Basic

FY16:
47 Comp
15 Clinical
 7 Basic

--3. reset the PK
select max(DT1bBenchMarkID) from DT1bBenchMark;
DBCC CHECKIDENT('DT1bBenchMark', RESEED, 4);

4. calculate and insert the subtotal numbers for 1. basic, 2. clinical, and 3. comp centers
SELECT c.CenterTypeID,  COUNT(*) as SubTotal 
		 FROM   [dt1bProgram] s,
			    Center c
		 WHERE  s.centerID = c.CenterID
		 AND    FY = 2014
		 GROUP BY c.CenterTypeID;

		 
INSERT INTO DT1bBenchMark(FY, bAsicCount, BasicSubtotal, ClinicalCount, ClinicalSubtotal, CompCount, CompSubtotal)
VALUES (2014, 7, 21,  20, 62, 41, 355);

select * from DT1bBenchMark
order by fy;

5. 

*/

ALTER PROCEDURE [dbo].[uspDT1bBenchmark] 

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
	    
    
    SET @FY = 2014;
  
     

	--================ get high/MAX numbers of leaders============================
	UPDATE DT1bBenchmark

	SET BasicHigh = (SELECT  MAX(cnt)  as DT1bMaxBasic

					 FROM ( SELECT c.CenterTypeID, s.GrantNumber,  COUNT(DISTINCT s.ProgName) AS CNT
							FROM   dt1bProgram s,
								   Center c
							WHERE c.CenterTypeID = 1
							AND s.FY = @FY
							AND  s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
    WHERE  FY = @FY;
    
		UPDATE DT1bBenchmark
		SET ClinicalHigh = (SELECT  MAX(cnt)  as DT1bMaxClinical
							fROM 
							(   SELECT c.CenterTypeID, s.GrantNumber,  COUNT(DISTINCT s.ProgName) AS CNT
								FROM   dt1bProgram s,
									   Center c
								WHERE c.CenterTypeID = 2
								AND   s.centerID = c.CenterID
								AND s.FY = @FY  
								GROUP BY c.CenterTypeID, s.GrantNumber
								) sys)
        WHERE  FY = @FY;
        
		UPDATE DT1bBenchmark
		SET CompHigh = (SELECT  MAX(cnt)  as DT1bMaxClinical
							fROM 
							(   SELECT c.CenterTypeID, s.GrantNumber,  COUNT(DISTINCT s.ProgName) AS CNT
								FROM   dt1bProgram s,
									   Center c
								WHERE c.CenterTypeID = 3
								AND   s.centerID = c.CenterID
								AND   s.FY = @FY  
								GROUP BY c.CenterTypeID, s.GrantNumber
								) sys)
		WHERE  FY = @FY;

--================get low/MIN numbers of leaders==========================

		UPDATE DT1bBenchmark
		SET BasicLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT(DISTINCT s.ProgName) AS CNT
							FROM   dt1bProgram s,
								   Center c
							WHERE  c.CenterTypeID = 1
						    AND    s.FY = @FY 
						    AND    s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		WHERE  FY = @FY;

		UPDATE DT1bBenchmark
		SET ClinicalLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT(DISTINCT s.ProgName) AS CNT
							FROM   dt1bProgram s,
								   Center c
							WHERE  c.CenterTypeID = 2
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
	    WHERE  FY = @FY;
	    		
		UPDATE DT1bBenchmark
		SET CompLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT(DISTINCT s.ProgName) AS CNT
							FROM   dt1bProgram s,
								   Center c
							WHERE  c.CenterTypeID = 3
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		WHERE  FY = @FY;
		
		--========= Get the median number of the program =====================
	    -- Basic Median
		SELECT @BasicCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT(DISTINCT s.ProgName) AS IDCount 
				FROM   dt1bProgram s,
					   Center c
				WHERE c.CenterTypeID = 1
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
				
		SELECT @BasicMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(DISTINCT s.ProgName)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(DISTINCT s.ProgName))AS ROW 
		FROM   dt1bProgram s,
			   Center c
		WHERE c.CenterTypeID = 1
		AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@BasicCount/2),(@BasicCount/2)+1)

		UPDATE DT1bBenchmark
		SET BasicMedian = (SELECT CEILING(@BasicMedian))
		WHERE  FY = @FY;
		    
		--Clinical Median
		SELECT @ClinicalCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT(DISTINCT s.ProgName) AS IDCount 
				FROM   dt1bProgram s,
					   Center c
				WHERE c.CenterTypeID = 2
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
				
		SELECT @ClinicalMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(DISTINCT s.ProgName)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(DISTINCT s.ProgName))AS ROW 
		FROM   dt1bProgram s,
			   Center c
		WHERE c.CenterTypeID = 2
				AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@ClinicalCount/2),(@ClinicalCount/2)+1)

		UPDATE DT1bBenchmark
		SET ClinicalMedian = (SELECT CEILING(@ClinicalMedian))
		WHERE  FY = @FY;
		
-- for Comp Median
	
		SELECT @CompCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT(DISTINCT s.ProgName) AS IDCount 
				FROM   dt1bProgram s,
					   Center c
				WHERE c.CenterTypeID = 3
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
				
		SELECT @CompMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(DISTINCT s.ProgName)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(DISTINCT s.ProgName))AS ROW 
		FROM   dt1bProgram s,
			   Center c
		WHERE c.CenterTypeID = 3
	    AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@CompCount/2),(@CompCount/2)+1)

		UPDATE DT1bBenchmark
		SET CompMedian = (SELECT CEILING(@CompMedian))
		WHERE  FY = @FY;

END
