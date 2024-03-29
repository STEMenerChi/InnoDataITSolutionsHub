USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT4PrimaryPurposeBenchmark]    Script Date: 1/11/2015 3:40:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- ====================================================================================
-- Author:		Chi T. Dinh
-- Create date: August 27, 2012
-- Description:	Get the  Median and Subtotal number of the open trials
                for each of the Primary Purpose, previously known as Study Type.
   
   Note: To calculate the median, find the total number, add 1 and divide by 2.
         Mean = AVG
   Param:  FY 
   
   INSTRUCTIIONS: 
   1. For FY13 and prior, make sure the StudyType is clean and not null
   2. For FY14 and forward, make sure that the PrimaryPurpose is clean and not null
   3. execute stored procedure [uspGetDT4PrimaryPurposeBenchMark] and enter 2013 as the parameter
   
   DATE			DESC
   09/11/2013	Modified the sp from sum4 to dt4
   12/12/2013   reran the sp.  some of the data in dt4 have been changed.
   01/11/2015   Added FY as the parameter           
-- =============================================*/


ALTER PROCEDURE [dbo].[uspDT4PrimaryPurposeBenchmark]  
@FY int
AS
BEGIN

	DECLARE 
			
			@PrimaryPurpose VARCHAR(25),
			@OpenTrialTotal int,
			@OpenTrialMedian int,
			@AccruedTotal int,
			@AccruedMedian int,
	        @myCur CURSOR;
	       
 /*----================ get Total count  ============================
  
   //make sure the primary purpose (previously known as StudyType) is clean

	select * 
	into DT4PrimaryPurposeBenchmarkBackup
	from DT4PrimaryPurposeBenchMark;

	--delete from DT4PrimaryPurposeBenchMark where FY =2013;
	 --select * from DT4PrimaryPurposeBenchMark order by DT4PrimaryPurposeBenchMarkID DESC;
    --reset the Entity PK to [n]
    --DBCC CHECKIDENT('DT4PrimaryPurposeBenchMark', RESEED, 37);

*/
  
	--get the total open trials and accruals
	INSERT INTO DT4PrimaryPurposeBenchMark(FY, PrimaryPurpose, OpenTrialTotal,AccruedTotal)
	SELECT FY, StudyType, Count(DT4ID) AS OpenTrialTotal, (Sum(Center12mos) + SUM(Other12mos)) AS AccruedTotal
	FROM   DT4 
	WHERE  FY = @FY 
	GROUP  BY FY, StudyType;

	/*  to verify run the following statement for phase '0', 'V', 'IV/V' individually, the result should be the same 

	SELECT FY,  StudyType, Count(DT4ID) AS OpenTrialTotal, Sum(Center12mos) as Center12MosTotal, Sum(Other12mos) as other12mostotal 
	FROM   DT4 
	WHERE  FY = 2012 
	and studytype = 'Pre'
	GROUP  BY FY, StudyType
	

	SELECT 2012 AS fy, s.StudyType, Count(s.DT4ID) AS OpenTrialTotal, (Sum(Center12mos) + SUM(Other12mos)) AS AccruedTotal
	FROM   DT4 s
	WHERE  S.FY = 2012 
	and    studytype = 'Pre'
	GROUP  BY s.StudyType;

	*/
	

	
-- ==================== Get the Median ==============================
-- For , # of open trials
	SET @myCur = CURSOR FOR

		select  x.PrimaryPurpose, CEILING(AVG(OpenTrialTotal)) as OpenTrialMedian
		from 
		(
			SELECT s.StudyType as PrimaryPurpose, s.GrantNumber,  COUNT(s.GrantNumber) as OpenTrialTotal,
				ROW_NUMBER() over (partition by s.StudyType order by COUNT(s.GrantNumber) ASC) as rowRank,
				COUNT(*) over (partition by s.StudyType) as cnt
		 
		FROM    Center C,
				DT4 s
		WHERE s.FY = @FY
		AND   C.CenterId  = s.CenterId
		GROUP by s.StudyType, s.GrantNumber

		) x
		where
			x.rowRank in (x.cnt/2+1, (x.cnt+1)/2)    
		group by
			x.PrimaryPurpose;

	OPEN @myCur
		FETCH NEXT
		FROM @myCur INTO @PrimaryPurpose, @OpenTrialMedian
		WHILE @@FETCH_STATUS = 0
		BEGIN
		    -- NOTE, null <> null
			IF @PrimaryPurpose IS NULL 
			BEGIN
				UPDATE DT4PrimaryPurposeBenchMark 
				SET    OpenTrialMedian = @OpenTrialMedian
				WHERE FY = @FY
				AND   PrimaryPurpose IS NULL;
			END
			
			ELSE 
			
			BEGIN 
				UPDATE DT4PrimaryPurposeBenchMark 
				SET    OpenTrialMedian = @OpenTrialMedian
				WHERE FY = @FY
				AND   PrimaryPurpose = @PrimaryPurpose;
			END 
			
			FETCH NEXT
			FROM @myCur INTO @PrimaryPurpose, @OpenTrialMedian;
		END
		CLOSE @myCur
		DEALLOCATE @myCur
		
-- For  # of Patients Accrued
	SET @myCur = CURSOR FOR

		select  x.PrimaryPurpose,CEILING(AVG(AccruedTotal)) as AccruedMedian
		from 
		(
			SELECT s.StudyType AS PrimaryPurpose, s.GrantNumber,  SUM(s.Center12mos +s.Other12mos) as AccruedTotal,
				ROW_NUMBER() over (partition by s.StudyType order by SUM(s.Center12mos+s.Other12mos) ASC) as rowRank,
				COUNT(*) over (partition by s.StudyType) as cnt
		 
		FROM    Center C,
				DT4 s
		WHERE   s.FY = @FY
		AND     C.CenterId  = s.CenterId
		GROUP by s.StudyType, s.GrantNumber

		) x
		where
			x.rowRank in (x.cnt/2+1, (x.cnt+1)/2)    
		group by
			x.PrimaryPurpose;

	OPEN @myCur
		FETCH NEXT
		FROM @myCur INTO @PrimaryPurpose, @AccruedMedian
		WHILE @@FETCH_STATUS = 0
		BEGIN
		    IF @PrimaryPurpose IS NULL 
		    BEGIN 
				UPDATE DT4PrimaryPurposeBenchMark 
				SET    AccruedMedian = @AccruedMedian
				WHERE FY = @FY
				AND   PrimaryPurpose IS NULL
		    END
		    
		    ELSE 
		    
		    BEGIN 
				UPDATE DT4PrimaryPurposeBenchMark 
				SET    AccruedMedian = @AccruedMedian
				WHERE FY = @FY
				AND   PrimaryPurpose = @PrimaryPurpose;
			END
			
			FETCH NEXT
			FROM @myCur INTO @PrimaryPurpose, @AccruedMedian;
		END
		CLOSE @myCur
		DEALLOCATE @myCur

END
