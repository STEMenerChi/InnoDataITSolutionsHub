USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT1dBenchMark]    Script Date: 2/11/2022 6:36:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- ====================================================================================================================================	  
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
   04/25/2017   Chi			Updated with FY14 data
-- ==========================================================================================================================================*/
ALTER PROCEDURE [dbo].[uspDT1dBenchMark] 
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
	        @curSubtotal CURSOR,
	        @rc1 INT, @rc2 INT, @rc3 INT,
		    @basicSubtotal    INT = 0, 
			@clinicalSubtotal INT = 0, 
			@compSubtotal     INT = 0,
			@grandTotal       INT = 0; 
	    
    
    
    --select COUNT(*) from DT1dSR
    
   
/* Execute the folowing statements manually: 
     
1. backup:

     select *
     into dt1dBenchmark20170321
     FROM dt1dBenchmark;

2. reset the PK
select max(DT1dBenchMarkID) from DT1dBenchMark;
DBCC CHECKIDENT('DT1dBenchMark', RESEED, 8);

3. Get this from Nga

FY14:
7 basic
20 clinical
41 comp


FY15:
45 Comp
17 Clinical
 7 Basic

FY16:
47 Comp
15 Clinical
 7 Basic

4.  get the number of (1) Basic, (2) Clinical, and (3) Comprehensive Centers

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

UPDATE dt1dBenchmark
SET   ClinicalCount = 15,
      CompCount = 47
WHERE FY = 2016;

UPDATE dt1dBenchmark
SET   ClinicalCount = 13,
      CompCount = 49
WHERE FY = 2017;

UPDATE dt1dBenchmark
SET   ClinicalCount = 13,
      CompCount = 51
WHERE FY = 2019;


		 INSERT INTO DT1dBenchmark (FY, BasicCount, ClinicalCount, CompCount)
		 Values (2020, 7, 13, 51);
    
    select * from dt1dBenchmark 
	order by FY;
						
	*/

	--================ get high/MAX numbers of leaders============================
	UPDATE DT1dBenchMark
	SET BasicHigh = (SELECT  MAX(cnt)  as DT1dMaxBasic
					 FROM ( SELECT c.CenterTypeID, s.GrantNumber,  COUNT( s.SRname) AS CNT
							FROM   DT1dSR s,
								   Center c
							WHERE  s.centerID     = c.CenterID
							AND    c.CenterTypeID = 1
							AND    c.isActive     = 1
							AND    s.FY           = @FY
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
	 WHERE   FY = @FY;
	 
		UPDATE DT1dBenchMark
		SET ClinicalHigh = (SELECT  MAX(cnt)  as DT1dMaxClinical
							fROM 
							(   SELECT c.CenterTypeID, s.GrantNumber,  COUNT( s.SRname) AS CNT
								FROM   DT1dSR s,
									   Center c
								WHERE  s.centerID     = c.CenterID
								AND    c.CenterTypeID = 2
								AND    c.isActive     = 1
								AND    s.FY           = @FY
								GROUP BY c.CenterTypeID, s.GrantNumber
								) sys)
		 WHERE   FY = @FY;
		 
		UPDATE DT1dBenchMark
		SET CompHigh = (SELECT  MAX(cnt)  as DT1dMaxClinical
							fROM 
							(   SELECT c.CenterTypeID, s.GrantNumber,  COUNT( s.SRname) AS CNT
								FROM   DT1dSR s,
									   Center c
								WHERE  s.centerID     = c.CenterID
								AND    c.CenterTypeID = 3
								AND    c.isActive     = 1
								AND    s.FY           = @FY
								GROUP BY c.CenterTypeID, s.GrantNumber
								) sys)
		 WHERE   FY = @FY;
		 
--================get low/MIN numbers of leaders==========================

		UPDATE DT1dBenchMark
		SET BasicLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT( s.SRname) AS CNT
							FROM   DT1dSR s,
								   Center c
							WHERE  s.centerID     = c.CenterID
							AND    c.CenterTypeID = 1
							AND    c.isActive     = 1
							AND    s.FY           = @FY
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		 WHERE   FY = @FY;
		 
		UPDATE DT1dBenchMark
		SET ClinicalLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
							FROM   DT1dSR s,
								   Center c
							WHERE  s.centerID     = c.CenterID
							AND    c.CenterTypeID = 2
							AND    c.isActive     = 1
							AND    s.FY           = @FY
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		 WHERE   FY = @FY;
		 			
		UPDATE DT1dBenchMark
		SET CompLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
							FROM   DT1dSR s,
								   Center c
							WHERE  s.centerID     = c.CenterID
							AND    c.CenterTypeID = 3
							AND    c.isActive     = 1
							AND    s.FY           = @FY
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		 WHERE   FY = @FY;
		 
		--========= Get the median number of the Sr. Leaders=====================
	    -- Basic Median
		SELECT @BasicCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT(s.GrantNumber) AS IDCount 
				FROM   DT1dSR s,
					   Center c
				WHERE  s.centerID     = c.CenterID
				AND    c.CenterTypeID = 1
				AND    c.isActive     = 1
				AND    s.FY           = @FY
				GROUP BY s.GrantNumber
				)AB
		SELECT @BasicMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(s.GrantNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(s.GrantNumber))AS ROW 
		FROM   DT1dSR s,
			   Center c
		WHERE  s.centerID     = c.CenterID
		AND    c.CenterTypeID = 1
		AND    c.isActive     = 1
		AND    s.FY           = @FY
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
				WHERE  s.centerID     = c.CenterID
				AND    c.CenterTypeID = 2
				AND    c.isActive     = 1
				AND    s.FY           = @FY
				GROUP BY s.GrantNumber
				)AB
		SELECT @ClinicalMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(s.GrantNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(s.GrantNumber))AS ROW 
		FROM   DT1dSR s,
			   Center c
		WHERE  s.centerID     = c.CenterID
		AND    c.CenterTypeID = 2
		AND    c.isActive     = 1
		AND    s.FY           = @FY
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
				WHERE  s.centerID     = c.CenterID
				AND    c.CenterTypeID = 3
				AND    c.isActive     = 1
				AND    s.FY           = @FY
				GROUP BY s.GrantNumber
				)AB
		SELECT @CompMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(s.GrantNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(s.GrantNumber))AS ROW 
		FROM   DT1dSR s,
			   Center c
		WHERE  s.centerID     = c.CenterID
		AND    c.CenterTypeID = 3
		AND    c.isActive     = 1
		AND    s.FY           = @FY
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@CompCount/2),(@CompCount/2)+1)

		UPDATE DT1dBenchMark
		SET CompMedian = (SELECT CEILING(@CompMedian))
	    WHERE   FY = @FY;

--========= Get the Subtotal for Basic, Clinical and Comp ==========================================      
		select  @basicSubtotal = SubTotal
		                         from 
								(SELECT  COUNT(*) as SubTotal 
								 FROM    DT1dSR s,
										 Center c
								 WHERE   s.centerID     = c.CenterID
								 AND     c.CenterTypeID = 1 --basic
								 and     c.isActive     = 1
								 AND     s.FY           = @FY) DD; 
     
		print 'basicSubtotal' + CONVERT(VARCHAR(10), @basicSubtotal);

		UPDATE DT1dBenchmark
		SET    BasicSubtotal = @basicSubtotal
		WHERE  FY = @FY; 

		
		select  @clinicalSubtotal = SubTotal
		                         from 
								(SELECT  COUNT(*) as SubTotal 
								 FROM    DT1dSR s,
										 Center c
								 WHERE   s.centerID     = c.CenterID
								 AND     c.CenterTypeID = 2 --clinical
								 and     c.isActive     = 1
								 AND     s.FY           = @FY) DD; 
     
		print 'clinicalSubtotal ' + CONVERT(VARCHAR(10),@clinicalSubtotal);

		UPDATE DT1dBenchmark
		SET    ClinicalSubtotal = @clinicalSubtotal
		WHERE  FY = @FY;

		select  @compSubtotal = SubTotal
		                         from 
								(SELECT  COUNT(*) as SubTotal 
								 FROM    DT1dSR s,
										 Center c
								 WHERE   s.centerID     = c.CenterID
								 AND     c.CenterTypeID = 3 -- comp
								 AND     c.isActive     = 1
								 AND     s.FY           = @FY) DD; 
     
		print 'compSubtotal ' + CONVERT(VARCHAR(10),@compSubtotal);

		UPDATE DT1dBenchmark
		SET    CompSubtotal = @compSubtotal
		WHERE FY = @FY;
--========= Get a grand ToTal  ===================================================================

	   SET    @grandTotal = @basicSubtotal + @clinicalSubtotal + @compSubtotal 
	   
	   UPDATE DT1dBenchmark
	   SET    Total = @grandTotal
       WHERE  FY    = @FY;
	   print 'total ' + CONVERT(VARCHAR(10), @grandTotal);
END

