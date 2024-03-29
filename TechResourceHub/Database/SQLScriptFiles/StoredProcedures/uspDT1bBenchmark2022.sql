USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT1bBenchmark]    Script Date: 2/11/2022 3:18:34 PM ******/
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
   12/16/2020  Chi          Updated fy16-19, fillered out 'ZY' - non-progammatic programs. 
   02/11/2022  Chi          Removed DISTINCT from COUNT(DISTINCT s.ProgName)  and added OR 
                            AND    (s.ProgCode     <> 'ZY'
							OR      s.ProgCode IS NULL)


   Note: to calculate the median, get the middle values, add them up and divide by 2.
   Param:  FY 
   
           
-- ===============================================================================================*/

/*  Manually run the following:

-- 1. backup:
select *
Into DT1bBenchmarkBU20220211
from DT1bBenchmark;

select * from DT1bBenchmark
		
select fy, count(*) 
from dt1bProgram
group by fy
order by fy

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
DBCC CHECKIDENT('DT1bBenchMark', RESEED, 10);

4.

        
		INSERT INTO DT1bBenchmark (FY, BasicCount, ClinicalCount, CompCount)
		 Values (2016, 7, 17, 45);

        INSERT INTO DT1bBenchmark (FY, BasicCount, ClinicalCount, CompCount)
		 Values (2017, 7, 15, 45);

		 INSERT INTO DT1bBenchmark (FY, BasicCount, ClinicalCount, CompCount)
		 Values (2019, 7, 14, 49);

		 INSERT INTO DT1bBenchmark (FY, BasicCount, ClinicalCount, CompCount)
		 Values (2020, 7, 13, 51);

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

UPDATE DT1bBenchmark
SET   ClinicalCount = 15,
      CompCount = 47
WHERE FY = 2016;

UPDATE DT1bBenchmark
SET   ClinicalCount = 13,
      CompCount = 49
WHERE FY = 2017;

UPDATE DT1bBenchmark
SET   ClinicalCount = 13,
      CompCount = 51
WHERE FY = 2019;


select * from DT1bBenchMark
order by fy;


*/

ALTER PROCEDURE [dbo].[uspDT1bBenchmark] 
@FY INT
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
	        @rc1 INT, @rc2 INT, @rc3 INT, 	
			@basicSubtotal    INT = 0, 
			@clinicalSubtotal INT = 0, 
			@compSubtotal     INT = 0,
			@grandTotal       INT = 0; 
    
    --SET @FY = 2017;
  

	--================ get high/MAX numbers of leaders============================
	UPDATE DT1bBenchmark

	SET BasicHigh = (select  MAX(cnt)  as DT1bMaxBasic

					 from ( SELECT c.CenterTypeID, s.GrantNumber,  COUNT( s.ProgName) AS CNT
							FROM   dt1bProgram s,
								   Center c
							WHERE  s.centerID     = c.CenterID
							AND    c.CenterTypeID = 1
							AND    c.isActive     = 1
							AND    s.FY           = @FY
							AND    (s.ProgCode     <> 'ZY'
							OR      s.ProgCode IS NULL)
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
    WHERE  FY = @FY;
    
		UPDATE DT1bBenchmark
		SET ClinicalHigh = (SELECT  MAX(cnt)  as DT1bMaxClinical
							fROM 
							(   SELECT c.CenterTypeID, s.GrantNumber,  COUNT( s.ProgName) AS CNT
								FROM   dt1bProgram s,
									   Center c
								WHERE  s.centerID     = c.CenterID
								AND    c.CenterTypeID = 2
								AND    c.isActive     = 1
								AND    s.FY           = @FY
							    AND    (s.ProgCode     <> 'ZY'
								OR      s.ProgCode IS NULL) 
								GROUP BY c.CenterTypeID, s.GrantNumber
								) sys)
        WHERE  FY = @FY;
        
		UPDATE DT1bBenchmark
		SET CompHigh = (SELECT  MAX(cnt)  as DT1bMaxClinical
							fROM 
							(   SELECT c.CenterTypeID, s.GrantNumber,  COUNT( s.ProgName) AS CNT
								FROM   dt1bProgram s,
									   Center c
								WHERE  s.centerID     = c.CenterID
								AND    c.CenterTypeID = 3
								AND    c.isActive     = 1
								AND    s.FY           = @FY
							    AND    (s.ProgCode     <> 'ZY'
								OR      s.ProgCode IS NULL) 
								GROUP BY c.CenterTypeID, s.GrantNumber
								) sys)
		WHERE  FY = @FY;

--================get low/MIN numbers of leaders==========================

		UPDATE DT1bBenchmark
		SET BasicLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT( s.ProgName) AS CNT
							FROM   dt1bProgram s,
								   Center c
							WHERE  s.centerID     = c.CenterID
							AND    c.CenterTypeID = 1
							AND    c.isActive     = 1
							AND    s.FY           = @FY
							AND    (s.ProgCode     <> 'ZY'
						    OR      s.ProgCode IS NULL) 
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		WHERE  FY = @FY;

		UPDATE DT1bBenchmark
		SET ClinicalLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT( s.ProgName) AS CNT
							FROM   dt1bProgram s,
								   Center c
							WHERE  s.centerID     = c.CenterID
							AND    c.CenterTypeID = 2
							AND    c.isActive     = 1
							AND    s.FY           = @FY
							AND    (s.ProgCode     <> 'ZY'
						    OR      s.ProgCode IS NULL) 
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
	    WHERE  FY = @FY;
	    		
		UPDATE DT1bBenchmark
		SET CompLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT( s.ProgName) AS CNT
							FROM   dt1bProgram s,
								   Center c
							WHERE  s.centerID     = c.CenterID
							AND    c.CenterTypeID = 3
							AND    c.isActive     = 1
							AND    s.FY           = @FY
							AND    (s.ProgCode     <> 'ZY'
						    OR      s.ProgCode IS NULL) 
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		WHERE  FY = @FY;
		
		--========= Get the median number of the program =====================
	    -- Basic Median
		SELECT @BasicCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT(DISTINCT s.ProgName) AS IDCount 
				FROM   dt1bProgram s,
					   Center c
				WHERE  s.centerID     = c.CenterID
				AND    c.CenterTypeID = 1
				AND    c.isActive     = 1
				AND    s.FY           = @FY
				AND    (s.ProgCode     <> 'ZY'
				OR      s.ProgCode IS NULL) 
				GROUP BY s.GrantNumber
				)AB
				
		SELECT @BasicMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT( s.ProgName)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT( s.ProgName))AS ROW 
		FROM   dt1bProgram s,
			   Center c
		WHERE  s.centerID     = c.CenterID
		AND    c.CenterTypeID = 1
		AND    c.isActive     = 1
		AND    s.FY           = @FY
		AND    (s.ProgCode     <> 'ZY'
		OR      s.ProgCode IS NULL) 
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@BasicCount/2),(@BasicCount/2)+1)

		UPDATE DT1bBenchmark
		SET BasicMedian = (SELECT CEILING(@BasicMedian))
		WHERE  FY = @FY;
		    
		--Clinical Median
		SELECT @ClinicalCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT( s.ProgName) AS IDCount 
				FROM   dt1bProgram s,
					   Center c
				WHERE  s.centerID     = c.CenterID
				AND    c.CenterTypeID = 2
				AND    c.isActive     = 1
				AND    s.FY           = @FY
				AND    (s.ProgCode     <> 'ZY'
				OR      s.ProgCode IS NULL) 
				GROUP BY s.GrantNumber
				)AB
				
		SELECT @ClinicalMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT( s.ProgName)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT( s.ProgName))AS ROW 
		FROM   dt1bProgram s,
			   Center c
		WHERE  s.centerID     = c.CenterID
		AND    c.CenterTypeID = 2
		AND    c.isActive     = 1
		AND    s.FY           = @FY
		AND    (s.ProgCode     <> 'ZY'
		OR      s.ProgCode IS NULL) 
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@ClinicalCount/2),(@ClinicalCount/2)+1)

		UPDATE DT1bBenchmark
		SET ClinicalMedian = (SELECT CEILING(@ClinicalMedian))
		WHERE  FY = @FY;
		
        -- for Comp Median
		SELECT @CompCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT( s.ProgName) AS IDCount 
				FROM   dt1bProgram s,
					   Center c
				WHERE c.CenterTypeID = 3
				AND   c.isActive     = 1
		        AND   s.centerID     = c.CenterID
		        AND    (s.ProgCode     <> 'ZY'
				OR      s.ProgCode IS NULL) 
				AND   s.FY           = @FY
				GROUP BY s.GrantNumber
				)AB
				
		SELECT @CompMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT( s.ProgName)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT( s.ProgName))AS ROW 
		FROM   dt1bProgram s,
			   Center c
		WHERE c.CenterTypeID = 3
		AND   c.isActive     = 1
		AND   s.centerID     = c.CenterID
		AND    (s.ProgCode     <> 'ZY'
		OR      s.ProgCode IS NULL) 
	    AND   s.FY             = @FY
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@CompCount/2),(@CompCount/2)+1)

		UPDATE DT1bBenchmark
		SET    CompMedian = (SELECT CEILING(@CompMedian))
		WHERE  FY = @FY;

--========= Get the Subtotal for Basic, Clinical and Comp ==========================================
       
		select  @basicSubtotal = SubTotal
		                         from 
								(SELECT  COUNT(*) as SubTotal 
								 FROM    [dt1bProgram] s,
										 Center c
								 WHERE   s.centerID     = c.CenterID
								 AND     c.CenterTypeID = 1 --basic
								 and     c.isActive     = 1
								 AND     s.FY             = @FY							
								 AND    (s.ProgCode     <> 'ZY'
								 OR      s.ProgCode IS NULL) ) basicSub; 
     
		print 'basicSubtotal' + CONVERT(VARCHAR(10), @basicSubtotal);

		UPDATE DT1bBenchmark
		SET    BasicSubtotal = @basicSubtotal
		WHERE FY = @FY; 

		
		select  @clinicalSubtotal = SubTotal
		                         from 
								(SELECT  COUNT(*) as SubTotal 
								 FROM    [dt1bProgram] s,
										 Center c
								 WHERE   s.centerID     = c.CenterID
								 AND     c.CenterTypeID = 2 --clinical
								 and     c.isActive     = 1
								 AND     s.FY             = @FY							
								 AND    (s.ProgCode     <> 'ZY'
								 OR      s.ProgCode IS NULL) ) clinicalSub; 
     
		print 'clinicalSubtotal ' + CONVERT(VARCHAR(10),@clinicalSubtotal);

		UPDATE DT1bBenchmark
		SET    ClinicalSubtotal = @clinicalSubtotal
		WHERE FY = @FY;

		select  @compSubtotal = SubTotal
		                         from 
								(SELECT  COUNT(*) as SubTotal 
								 FROM    [dt1bProgram] s,
										 Center c
								 WHERE   s.centerID     = c.CenterID
								 AND     c.CenterTypeID = 3 -- comp
								 AND     c.isActive     = 1
								 AND     s.FY             = @FY								
								 AND    (s.ProgCode     <> 'ZY'
								 OR      s.ProgCode IS NULL) ) compSub; 
     
		print 'compSubtotal ' + CONVERT(VARCHAR(10),@compSubtotal);

		UPDATE DT1bBenchmark
		SET    CompSubtotal = @compSubtotal
		WHERE FY = @FY;
--========= Get a grand ToTal  ===================================================================

	   
	   SET    @grandTotal = @basicSubtotal + @clinicalSubtotal + @compSubtotal 
	   
	   UPDATE DT1bBenchmark
	   SET    Total = @grandTotal
       WHERE  FY    = @FY;
	   print 'total ' + CONVERT(VARCHAR(10), @grandTotal);

END
