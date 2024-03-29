USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT3BenchMark]    Script Date: 4/25/2017 12:56:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- ================================================================================================================================
	DATE			DEV			DESC
	06/13/2012		Chi T. Dinh Get the High, Median, and Low, and Subtotal number of the Newly Registeredand Newly Enrolled Patients in CT
								group by Clinical and Comprehensive study type.
								The 2nd calcuation is group by the Disease Site
								
    10/23/2013		Chi         Modified Sum3 to DT3
	04/25/2017		Chi			Updated with FY14, FY15.
    
   
   Note: The data should only include clinical (center type 2), and comprehensive (center type 1) Centers only. 
   
   To calculate the median, find the total number, add 1 and divide by 2.
         Mean = AVG or take the Avg.
          
-- ====================================================================================================================================*/
ALTER PROCEDURE [dbo].[uspDT3BenchMark] 

 /*  execute this manually
    
1. Backup:
select * into dt3Benchmark20170419
from dt3Benchmark;

2. Clean up the data into proper format:
 
    select registeredpatient 
	from dt3 
	where fy = 2015
	and registeredpatient is null
    
    A. 
    UPDATE dt3
    SET    RegisteredPatient = 0
    WHERE  registeredPatient IS NULL;
    
	B.
    UPDATE dt3
    SET    EnrolledPatient = 0
    WHERE  EnrolledPatient IS NULL;
       
3. -- reset the Entity PK to [n]
select max(dt3BenchmarkID) from dt3Benchmark;
DBCC CHECKIDENT('DT3BenchMark', RESEED, 553);
  
	2014:
    INSERT INTO DT3BenchMark (FY, ClinicalCount, CompCount) 
    VALUES (2014, 20,41)

    2015:
    INSERT INTO DT3BenchMark (FY, ClinicalCount, CompCount) 
    VALUES (2015, 17, 45);

    2016:
    INSERT INTO DT3BenchMark (FY, ClinicalCount, CompCount) 
    VALUES (2016, 15, 47);


Play:
SELECT  c.CenterTypeID, C.InstitutionName, S.GrantNumber, SUM(s.RegisteredPatient) as RegTotal,   SUM(s.EnrolledPatient) as EnrollTotal
			FROM   DT3 s,
				   Center c
			WHERE S.FY = 2014
			AND   c.CenterTypeID in (2)
			AND   s.centerID = c.CenterID
			GROUP BY c.CenterTypeID,C.InstitutionName,s.grantNumber
			ORDER BY SUM(s.RegisteredPatient) desc, SUM(s.EnrolledPatient) desc
*/  
   
/*    --================ get MAX/MIN number ============================  */
AS
BEGIN

	DECLARE 
	        @CenterTypeID INT,
	        @Site VARCHAR(255),
	        @RegHigh INT,
			@RegLow INT,
			@RegSubtotal INT,
			@RegMedian INT,
			@EnrollHigh INT,
			@EnrollLow INT,
			@EnrollSubtotal INT,
			@EnrollMedian INT,
			@FY INT,
	        @myCur CURSOR,
	        @myCur2 CURSOR,
	        @myCur3 CURSOR,
	        @myCur4 CURSOR,
	        @myCur5 CURSOR,
	        @myCur6 CURSOR
	    
            SET @FY = 2015;
    
   
	SET @myCur = CURSOR FOR
	SELECT  CenterTypeID,  
	        MAX(RegTotal)  AS MaxReg, MAX(EnrollTotal) as MaxEnroll, 
	        MIN(RegTotal)  AS MinReg, MIN(EnrollTotal) as MinEnroll
	FROM ( SELECT  c.CenterTypeID, s.GrantNumber, SUM(s.RegisteredPatient) as RegTotal,   SUM(s.EnrolledPatient) as EnrollTotal
			FROM   DT3 s,
				   Center c
			WHERE S.FY = @FY
			AND   c.CenterTypeID in (2,3)
			AND   s.centerID = c.CenterID
			GROUP BY c.CenterTypeID,s.grantNumber
			) sys
	GROUP BY CenterTypeID
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @CenterTypeID, @RegHigh, @EnrollHigh,  @RegLow, @EnrollLow
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		IF  @CenterTypeID = 2 -- Clinical Centers
		BEGIN
			UPDATE DT3BenchMark
			SET    ClinicalRegHigh = @RegHigh,
				   ClinicalEnrollHigh = @EnrollHigh,
				   ClinicalRegLow = @RegLow,
				   ClinicalEnrollLow = @EnrollLow
			WHERE  DT3BenchMarkID = (Select MAX(DT3BenchMarkID) from DT3BenchMark)
			AND    FY = @FY;
		END
		ELSE -- for Comprehensive Centers
			UPDATE DT3BenchMark
			SET    CompRegHigh = @RegHigh,
				   CompEnrollHigh = @EnrollHigh,
				   CompRegLow = @RegLow,
				   CompEnrollLow = @EnrollLow
			 WHERE DT3BenchMarkID = (Select MAX(DT3BenchMarkID) from DT3BenchMark)
			 AND   FY = @FY;
		FETCH NEXT
		FROM @myCur INTO @CenterTypeID, @RegHigh, @EnrollHigh,  @RegLow, @EnrollLow
	END
	CLOSE @myCur
	DEALLOCATE @myCur
	--=========================== get median for (Registered Patients) ==============================
	/*
		The median is the middle value, so I'll have to rewrite the list in order:

		13, 13, 13, 13, 14, 14, 16, 18, 21

		There are nine numbers in the list, so the middle one will be the (9 + 1) ÷ 2 = 10 ÷ 2 = 5th number:

		13, 13, 13, 13, 14, 14, 16, 18, 21

		So the median is 14.   Copyright © Elizabeth Stapel 2
	
	*/
	
	SET @myCur5 = CURSOR FOR
	
		select  centertypeID,  AVG(TotalReg) as MedianReg
		from 
		(
			SELECT c.centertypeID, s.grantNumber,  SUM(s.RegisteredPatient) as TotalReg,
				ROW_NUMBER() over (partition by c.centertypeID order by SUM(s.RegisteredPatient) ASC) as RegRank,
				COUNT(*) over (partition by c.centertypeID) as CenterTypeCount
			FROM    Center C,
				    DT3 s
			WHERE  s.FY = @FY
			AND    C.CenterId  = s.CenterId
			GROUP by c.centertypeID, s.grantNumber

		) x
		where
			x.RegRank in (x.CenterTypeCount/2+1, (x.CenterTypeCount+1)/2)    
		group by
			x.centertypeID;
	    
	    OPEN @myCur5
		FETCH NEXT
		FROM @myCur5 INTO @CenterTypeID, @RegMedian
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			
		    IF @CenterTypeID = 2 -- Clinical
				UPDATE DT3BenchMark
				SET    ClinicalRegMedian = @RegMedian
				WHERE  FY = @FY
				AND    PrimarySite IS NULL;
			ELSE -- comprehensive
				UPDATE DT3BenchMark
				SET    CompRegMedian = @RegMedian
				WHERE  FY = @FY
				AND    PrimarySite IS NULL;	 
					      
			FETCH NEXT
			FROM @myCur5 INTO @CenterTypeID,@RegMedian
		END
		CLOSE @myCur5
		DEALLOCATE @myCur5
		
			--=========================== get median for (newly Enrolled Patients) ==============================
	
	SET @myCur6 = CURSOR FOR
	
		select  centertypeID,  AVG(TotalEnroll) as MedianEnroll
		from 
		(
			SELECT c.centertypeID, s.GrantNumber,  SUM(s.EnrolledPatient) as TotalEnroll, 
				ROW_NUMBER() over (partition by c.centertypeID order by SUM(s.EnrolledPatient) ASC) as EnrollRank,
				COUNT(*) over (partition by c.centertypeID) as CenterTypeCount
		 
			FROM    Center C,
				    DT3 s
			WHERE   FY = @FY
			AND     C.CenterId  = s.CenterId
			GROUP BY c.centertypeID, s.GrantNumber

		) x
		where
			x.EnrollRank in (x.CenterTypeCount/2+1, (x.CenterTypeCount+1)/2)    
		group by
			x.centertypeID;
	    
	    OPEN @myCur6
		FETCH NEXT
		FROM @myCur6 INTO @CenterTypeID, @EnrollMedian
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			
		    IF @CenterTypeID = 2 -- Clinical
				UPDATE DT3BenchMark
				SET    ClinicalEnrollMedian = @EnrollMedian
				WHERE  FY = @FY
				AND    PrimarySite IS NULL;
			ELSE -- comprehensive
				UPDATE DT3BenchMark
				SET    CompEnrollMedian = @EnrollMedian
				WHERE  FY = @FY
				AND    PrimarySite IS NULL;	 
					      
			FETCH NEXT
			FROM @myCur6 INTO @CenterTypeID,@EnrollMedian
		END
		CLOSE @myCur6
		DEALLOCATE @myCur6
	
	--================ get Subtotal number ============================
	SET @myCur2 = CURSOR FOR
	SELECT  c.CenterTypeID,  SUM(s.RegisteredPatient) as RegTotal,   SUM(s.EnrolledPatient) as EnrollTotal
	FROM   DT3 s,
		   Center c
	WHERE  s.centerID = c.CenterID
	AND    s.FY = @FY
	GROUP BY c.CenterTypeID;
			
	OPEN @myCur2
	FETCH NEXT
	FROM @myCur2 INTO @CenterTypeID, @RegSubtotal, @EnrollSubtotal
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		IF  @CenterTypeID = 2 -- Clinical Centers
		BEGIN
			UPDATE DT3BenchMark
			SET    ClinicalRegSubTotal = @RegSubtotal,
			       ClinicalEnroLlSubtotal = @EnrollSubtotal
			WHERE  DT3BenchMarkID = (Select MAX(DT3BenchMarkID) from DT3BenchMark)
			AND    FY = @FY;
		END
		ELSE -- for Comprehensive Centers
			UPDATE DT3BenchMark
			SET    CompRegSubtotal = @RegSubtotal,
			       CompEnroLlSubtotal = @EnrollSubtotal 
			 WHERE DT3BenchMarkID = (Select MAX(DT3BenchMarkID) from DT3BenchMark)
			 AND   FY = @FY;;
			 
		FETCH NEXT
		FROM @myCur2 INTO  @CenterTypeID, @RegSubtotal, @EnrollSubtotal
	END
	CLOSE @myCur2
	DEALLOCATE @myCur2
		 

	
--	----------------------------------Top 20 RegisteredPatients----------------------------
	INSERT INTO DT3BenchMark(FY, PrimarySite,RegisteredPatient)
	
	SELECT TOP 20 FY, PrimarySite, MAX(RegTotal) as MaxReg 
	FROM ( SELECT TOP 95  s.FY, s.PrimarySite, SUM(s.RegisteredPatient) as RegTotal
			FROM   DT3  s
			WHERE s.FY = @FY
			and PrimarySite <> 'Multiple'
			GROUP BY s.FY, s.PrimarySite
			order by SUM(s.RegisteredPatient) DESC
			
			) sys
	GROUP BY FY, PrimarySite
	ORDER BY MaxReg Desc;
	
	------------------------------------Top 20 EnrolledPatients---------------------------- 
    INSERT INTO DT3BenchMark(FY, PrimarySite,EnrolledPatient)
	SELECT TOP 20  FY, PrimarySite, 
        MAX(EnrollTotal) as MaxEnroll 
        
	FROM ( SELECT TOP 57 s.FY, s.PrimarySite, SUM(s.EnrolledPatient) as EnrollTotal
			FROM   DT3  s,
				   Center c
			WHERE  s.centerID = c.CenterID
			AND s.FY = @FY
			and PrimarySite <> 'Multiple'
			GROUP BY s.fy, s.PrimarySite
			ORDER BY SUM(s.EnrolledPatient) DESC
			) sys
	GROUP BY FY, PrimarySite
	ORDER BY MaxEnroll Desc;
	
END
