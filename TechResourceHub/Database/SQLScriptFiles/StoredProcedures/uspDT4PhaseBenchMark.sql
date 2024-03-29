USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT4PhaseBenchmark]    Script Date: 1/11/2015 3:34:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================
-- Author:		Chi T. Dinh
-- Create date: July 31, 2012
-- Description:	Manually run the SQL Stamt to get the OpenTrialTotal and AccruedTotal.
                Execute the this stored procedure to get the OpenTrialMedian. 
                
                Get the  Median,  and Subtotal number of the open trials
                for each of the Clinical Research Category  (previously known Section 1,2,3,4)
                1. Agent and Device
                2. Other Intervention
                3. Epi/Obs/Out
                4. Anc/Cor
   
   Note: To calculate the median, find the total number, add 1 and divide by 2.
         Mean = AVG
   Param:  FY 
   Date			Desc
   09/10/2013   Modified sum4 to dt4
   09/17/2013   Get the sum of the CenterP12 and OthP12 seperately, then add them later.
   12/12/2013   rerun the sp.  some data in dt4 have been modified.
   01/11/2015   Added FY as the SP input parameter
-- =============================================*/

ALTER PROCEDURE [dbo].[uspDT4PhaseBenchmark] 
@FY int
 
AS
BEGIN

	DECLARE 
			
			@Phase VARCHAR(25),
			@OpenTrialTotal int,
			@OpenTrialMedian int,
			@AccruedTotal int,
			@AccruedMedian int,
	        @myCur CURSOR;
	       
    
     --set @FY = 2013; 
 ----================ get Total count for open trials and accrual  ============================
	/* --- backup
	select *
	into dt4phaseBenchmarkBackup
	from dt4PhaseBenchmark;
	*/

    -- delete from DT4PhaseBenchMark where fy = 2013;
	-- reset the Entity PK to [n]
    --DBCC CHECKIDENT('DT4PhaseBenchMark', RESEED, 1046);

	-- get # of open trilas & accruals
	INSERT INTO DT4PhaseBenchMark(FY, Phase, OpenTrialTotal, AccruedTotal)
    SELECT FY, Phase, OpentrialTotal, Sum(Center12MosTotal + Other12MosTotal) AS AccruedTotal
	FROM
		 (SELECT FY, Phase,  Count(dt4ID) AS OpenTrialTotal,  Sum(Center12Mos) AS Center12MosTotal,  Sum(Other12Mos) AS Other12MosTotal  
		 FROM  dt4 
		 WHERE FY = @FY
		 GROUP BY  FY, Phase) X
   GROUP BY FY, Phase, OpenTrialTotal
   Order by Phase


	/* to verify: make sure the two statments provide the same # of open trials & accruals 
	   Use small # of phase such as '0', 'V', or 'IV/V'

	 SELECT dt4ID, Phase,  Center12Mos,  Other12Mos
	 FROM  dt4 
	 WHERE FY = 2013
	 and Phase = '0';

	 SELECT  Phase, OpentrialTotal, Sum(Center12MosTotal + Other12MosTotal) AS AccruedTotal
	 FROM
		 (SELECT Phase,  Count(dt4ID) AS OpenTrialTotal,  Sum(Center12Mos) AS Center12MosTotal,  Sum(Other12Mos) AS Other12MosTotal  
		 FROM  dt4 
		 WHERE FY = 2013
		 and Phase = '0'
		 GROUP BY Phase) X
   GROUP BY Phase, OpenTrialTotal
   Order by Phase
   */
	
-- ==================== Get the Median ==============================

   
-- For , # of open trials
	SET @myCur = CURSOR FOR

		select   x.Phase, CEILING(AVG(OpenTrialTotal)) as OpenTrialMedian
		from 
		(
			SELECT s.Phase, s.GrantNumber,  COUNT(s.GrantNumber) as OpenTrialTotal,
				ROW_NUMBER() over (partition by s.Phase order by COUNT(s.GrantNumber) ASC) as rowRank,
				COUNT(*) over (partition by s.Phase) as cnt
		 
		FROM    Center C,
				DT4 s
		WHERE s.FY = @FY
		AND   C.CenterId  = s.CenterId
		GROUP by s.Phase, s.GrantNumber

		) x
		where
			x.rowRank in (x.cnt/2+1, (x.cnt+1)/2)    
		group by
			x.Phase;

	OPEN @myCur
		FETCH NEXT
		FROM @myCur INTO @Phase, @OpenTrialMedian
		WHILE @@FETCH_STATUS = 0
		BEGIN
		    -- NOTE, null <> null
			IF @Phase IS NULL 
			BEGIN
				UPDATE DT4PhaseBenchMark 
				SET    OpenTrialMedian = @OpenTrialMedian
				WHERE  FY = @FY
				AND   Phase IS NULL;
			END
			
			ELSE 
			
			BEGIN 
				UPDATE DT4PhaseBenchMark 
				SET    OpenTrialMedian = @OpenTrialMedian
				WHERE FY = @FY
				AND   Phase = @Phase;
			END 
			
			FETCH NEXT
			FROM @myCur INTO @Phase, @OpenTrialMedian;
		END
		CLOSE @myCur
		DEALLOCATE @myCur
		
-- For  # of Patients Accrued
	SET @myCur = CURSOR FOR

		select  x.Phase,CEILING(AVG(AccruedTotal)) as AccruedMedian
		from 
		(
			SELECT s.Phase, s.GrantNumber,  SUM(s.Center12mos +s.Other12mos) as AccruedTotal,
				ROW_NUMBER() over (partition by s.Phase order by SUM(s.Center12mos + s.Other12Mos) ASC) as rowRank,
				COUNT(*) over (partition by s.Phase  ) as cnt
		 
		FROM    Center C,
				DT4 s
		WHERE S.FY = @FY
		AND   C.CenterId  = s.CenterId
		GROUP by s.Phase, s.GrantNumber

		) x
		where
			x.rowRank in (x.cnt/2+1, (x.cnt+1)/2)    
		group by
			x.Phase;

	OPEN @myCur
		FETCH NEXT
		FROM @myCur INTO @Phase, @AccruedMedian
		WHILE @@FETCH_STATUS = 0
		BEGIN
		    IF @Phase IS NULL 
		    BEGIN 
				UPDATE DT4PhaseBenchMark 
				SET    AccruedMedian = @AccruedMedian
				WHERE FY = @FY
				AND   Phase IS NULL
		    END
		    
		    ELSE 
		    
		    BEGIN 
				UPDATE DT4PhaseBenchMark 
				SET    AccruedMedian = @AccruedMedian
				WHERE FY = @FY
				AND   Phase = @Phase;
			END
			
			FETCH NEXT
			FROM @myCur INTO @Phase, @AccruedMedian;
		END
		CLOSE @myCur
		DEALLOCATE @myCur

END
