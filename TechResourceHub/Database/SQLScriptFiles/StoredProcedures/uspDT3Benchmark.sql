USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT3BenchMark]    Script Date: 6/12/2023 12:57:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- ================================================================================================================================
	DATE			DEV			DESC
	06/13/2012		Chi T. Dinh Get the High, Median, and Low, and Subtotal number of the Newly Registeredand Newly Enrolled Patients in CT
								group by Clinical and Comprehensive study type.
								The 2nd calcuation is group by the Disease Site
								
    06/12/2023      Updated FY21 per Min's request
   
   NOTE NOTE NOTE NOTE: 
   1. please clean the data for specific year (i.e fy = 2020) , the last time ICD list code changed was in 2016 or 2017
   2. this stored procedure can only be ran ONCE for each year - it has an INSERT stmt. 
   3. The data should only include clinical (center type 2), and comprehensive (center type 1) Centers only. 
   4. Only the first row of record contains ClinicalCount and CompCount, the rest of the rows ClinicalCount IS NULL and CompCount IS NULL
   
   To calculate the median, find the total number, add 1 and divide by 2.
   Mean = AVG or take the Avg.
          
-- ====================================================================================================================================*/
ALTER PROCEDURE [dbo].[uspDT3BenchMark] 
@FY INT
 /*  execute thses manually
------------------------------------    
Backup:
--------------------------------------
select * into dt3BenchmarkBU2022Jun12
from dt3Benchmark;

select * into dt3BU2022Jun12
from dt3;
--------------------------------------------------------------------------------
figure out how many Clinical or Comp Centers are currently in the database:
update 2 for clinical and 3 for comp per FY
-------------------------------------------------------------------------------
select distinct d.GrantNumber, c.InstitutionName 
from dt3 d, 
     center c
where c.CenterTypeID = 2
and C.CenterId = d.centerid
AND c.isActive = 1
and d.fy = 2020
order by d.GrantNumber;

---------------------------------------
Clean up the data into proper format:
---------------------------------------- 
    select registeredpatient 
	from   dt3 
	WHERE registeredpatient IS NULL
    
    A. 
    UPDATE dt3
    SET    RegisteredPatient = 0
    WHERE  registeredPatient IS NULL;
    
	B.
    UPDATE dt3
    SET    EnrolledPatient = 0
    WHERE  EnrolledPatient IS NULL;
------------------------------------------ 
  OPTIONAL
 --reset the Entity PK to [n]
 ------------------------------------------
select max(dt3BenchmarkID) as MAXID from dt3Benchmark;
DBCC CHECKIDENT('DT3BenchMark', RESEED, 1661);
  
  select * from dt3benchmark
  where fy = 2021;

-----------------------------------------------------------------------------------------------
hardcode # of clinical and comp for each FY based on the StaffAssignment compiled by Nga Nguyen
-----------------------------------------------------------------------------------------------
Values (2011, 7, 19, 40);    --confirmed by Nga 2/11/2022 up to FY2021
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
Values (2021, 7, 13, 51); -- confirmed based on staff assignment list
Values (2022, 7, 11, 53);
Values (2023, 7, 11, 54); -- on 5/30/2023: new Clinical The University of Florida Health Cancer Center, and VCU from clinical to comp 


UPDATE DT3BenchMark
SET   ClinicalCount = 13,
      CompCount = 51
WHERE FY = 2019;

	--for FY2023 starting Oct 1, 2022 to Sept 30,2023
	--There is  a NEW clinical cancer center: The University of Florida Health Cancer Center. The NOA was released today (5/30/2023)
	 INSERT INTO DT3BenchMark (FY, ClinicalCount, CompCount) 
     VALUES (2023, 11, 54);


	--2020:
    INSERT INTO DT3BenchMark (FY, ClinicalCount, CompCount) 
    VALUES (2020, 13, 51);

	--2021:
    INSERT INTO DT3BenchMark (FY, ClinicalCount, CompCount) 
    VALUES (2021, 13, 51);

	select * from DT3BenchMark
	order by fy; 
--------------------------------------------------------------------------------------------------
--Verify there are  17 clinical centers for fy2016; however there are only 11 centers in the DB :-(
---------------------------------------------------------------------------------------------------
SELECT  c.CenterTypeID, C.InstitutionName, S.GrantNumber, SUM(s.RegisteredPatient) as RegTotal,   SUM(s.EnrolledPatient) as EnrollTotal
			FROM   DT3 s,
				   Center c
			WHERE S.FY = 2016
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
	        @myCur CURSOR,
	        @myCur2 CURSOR,
	        @myCur3 CURSOR,
	        @myCur4 CURSOR,
	        @myCur5 CURSOR,
	        @myCur6 CURSOR
	    
            --SET @FY = 2015;
    
   -- Get the high and low 
   -- AND s.RegisteredPatient <> 0, so the sp won't pick up 0 as min
   -- start in FY17 OCC was no longer tract EnrolledPatient

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
			AND   s.RegisteredPatient > 0
			--AND   s.EnrolledPatient > 0
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
			SET    ClinicalRegHigh    = @RegHigh,
				   ClinicalEnrollHigh = @EnrollHigh,
				   ClinicalRegLow     = @RegLow,
				   ClinicalEnrollLow  = @EnrollLow
			--WHERE  DT3BenchMarkID = (Select MAX(DT3BenchMarkID) from DT3BenchMark)
			WHERE    FY = @FY;
		END
		ELSE -- for Comprehensive Centers
			UPDATE DT3BenchMark
			SET    CompRegHigh    = @RegHigh,
				   CompEnrollHigh = @EnrollHigh,
				   CompRegLow     = @RegLow,
				   CompEnrollLow  = @EnrollLow
			 --WHERE DT3BenchMarkID = (Select MAX(DT3BenchMarkID) from DT3BenchMark)
			 WHERE   FY = @FY;
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
			FROM   Center C,
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
	SELECT c.CenterTypeID,  SUM(CAST(s.RegisteredPatient AS bigint)) as RegTotal,   SUM(CAST(s.EnrolledPatient AS bigint)) as EnrollTotal
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
			SET    ClinicalRegSubTotal    = @RegSubtotal,
			       ClinicalEnroLlSubtotal = @EnrollSubtotal
			--WHERE  DT3BenchMarkID = (Select MAX(DT3BenchMarkID) from DT3BenchMark)
			WHERE    FY = @FY;
		END
		ELSE -- for Comprehensive Centers
			UPDATE DT3BenchMark
			SET    CompRegSubtotal    = @RegSubtotal,
			       CompEnroLlSubtotal = @EnrollSubtotal 
			 --WHERE DT3BenchMarkID = (Select MAX(DT3BenchMarkID) from DT3BenchMark)
			 WHERE   FY = @FY;;
			 
		FETCH NEXT
		FROM @myCur2 INTO  @CenterTypeID, @RegSubtotal, @EnrollSubtotal
	END
	CLOSE @myCur2
	DEALLOCATE @myCur2
		 

--INSERT stmt Can only run ONCE:----------------------------------Top 20 RegisteredPatients----------------------------
	INSERT INTO DT3BenchMark(FY, PrimarySite,RegisteredPatient)
	
	SELECT TOP 20 FY, PrimarySite, MAX(RegTotal) as MaxReg 
	FROM (  select top 95  FY, PrimarySite, SUM(CAST(RegisteredPatient AS bigint)) as RegTotal
			from  DT3  
			where FY = @FY
			group by FY, PrimarySite
			order by SUM(RegisteredPatient) desc			
			) sys
	GROUP BY FY, PrimarySite
	ORDER BY MaxReg DESC;
	
-- Since 2017 We no longer track EnrolledPatients - INSERT stmt can only run ONCE----------------------------------Top 20 EnrolledPatients---------------------------- 
    INSERT INTO DT3BenchMark(FY, PrimarySite,EnrolledPatient)
	SELECT TOP 20  FY, PrimarySite, 
        MAX(EnrollTotal) as MaxEnroll 
        
	FROM ( SELECT TOP 57 FY, PrimarySite, SUM(EnrolledPatient) as EnrollTotal
			FROM   DT3 
			WHERE FY = @FY
			GROUP BY fy, PrimarySite
			ORDER BY SUM(EnrolledPatient) DESC
			) sys
	GROUP BY FY, PrimarySite
	ORDER BY MaxEnroll Desc;

---------------------------------------------------------------------
--to remove dup - see DT3CleanupDup.sql file
---------------------------------------------------------------------

END
