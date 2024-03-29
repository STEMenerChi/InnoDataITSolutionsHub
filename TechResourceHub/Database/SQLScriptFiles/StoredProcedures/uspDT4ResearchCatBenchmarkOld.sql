USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT4ResearchCatBenchmark]    Script Date: 09/17/2013 14:52:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================
-- Author:		Chi T. Dinh
-- Create date: July 31, 2012
-- Description:	Get the  Median,  and Subtotal number of the open trials
                for each of the Clinical Research Category (INT, OBS, ANC/COR)
                Previously known Section 1,2,3,4)
                1. Agent and Device
                2. Other Intervention
                3. Epi/Obs/Out
                4. Anc/Cor
   
   Note: To calculate the median, find the total number, add 1 and divide by 2.
         Mean = AVG
   Param:  FY 
   DATE			DESC
   09/12/2013   Modified sum4 to dt4
   09/17/2013   Added the field Section, CenterP12, OthP12 to Calulated DT4PhaseBenchMark table
                Calculated the sum of the CenterP12 and OthP12 seperately, AccruedTotal = CenterP12 + OtherP12.
                
             
-- =============================================*/


ALTER PROCEDURE [dbo].[uspDT4ResearchCatBenchmark] 

AS
BEGIN

	DECLARE 
			
			@ClinicalResearchCat VARCHAR(25),
			@Section int,
			@OpenTrialTotal int,
			@OpenTrialMedian int,
			@AccruedTotal int,
			@AccruedMedian int,
			@FY int,
	        @myCur CURSOR;
	       
    SET @FY = 2012;
 ----================ get Total count  ============================

	
	-- SELECT * INTO DT4ResearchCatBenchMarkBackUp from DT4ResearchCatBenchMark;
	
    -- reset the Entity PK to 0
    --DBCC CHECKIDENT('DT4ResearchCatBenchMark', RESEED, 5);
	--(1) Manually run the fillowing stmt:
	
/*
    --INSERT INTO DT4ResearchCatBenchMark(FY, Section, ClinicalResearchCat, OpenTrialTotal, AccruedTotal)

	SELECT FY, section, ClinicalResearchCat, OpenTrialTotal,  CenterP12 + OthP12 AS AccruedTotal
	FROM (
		SELECT 2012 AS FY, COALESCE(s.Section, 0) as Section,
			   CASE section
				   WHEN 1 then 'Agent/Device'
				   WHEN 2 then 'Other Intervention'
				   WHEN 3 then 'Epi/Obs/Out'
				   WHEN 4 then 'Anc/Comp/Cor'
				   ELSE 'Unspecified'
			   END AS ClinicalResearchCat,
			   Count(s.DT4ID) AS OpenTrialTotal, SUM(CenterP12) AS CenterP12, SUM(OthP12) AS OthP12
		FROM   DT4 s,
			   Center c
		WHERE  s.FY = 2012 
		AND    s.centerID = c.CenterID
		GROUP BY s.Section ) A;
*/
		
	/*
	select * from DT4ResearchCatBenchMark
	set fy = 2011
	where DT4ResearchCatBenchMarkID = 10;
	*/
	
-- ==================== Get the Median ==============================
-- For , # of open trials
	SET @myCur = CURSOR FOR

		select  x.Section, CEILING(AVG(OpenTrialTotal)) as OpenTrialMedian
		from 
		(
			SELECT s.section, s.GrantNumber,  COUNT(s.GrantNumber) as OpenTrialTotal,
				ROW_NUMBER() over (partition by s.Section order by COUNT(s.GrantNumber) ASC) as rowRank,
				COUNT(*) over (partition by s.Section) as cnt
		 
		FROM    Center C,
				DT4 s
		WHERE s.FY = 2012
		AND   C.CenterId  = s.CenterId
		GROUP by s.Section, s.GrantNumber

		) x
		where
			x.rowRank in (x.cnt/2+1, (x.cnt+1)/2)    
		group by
			x.Section;

	OPEN @myCur
		FETCH NEXT
		FROM @myCur INTO @Section, @OpenTrialMedian
		WHILE @@FETCH_STATUS = 0
		BEGIN
		    -- NOTE, null <> null
			IF @Section IS NULL 
			BEGIN
				UPDATE DT4ResearchCatBenchMark 
				SET    OpenTrialMedian = @OpenTrialMedian
				WHERE FY = @FY
				AND   Section = 0;
			END
			
			ELSE 
			
			BEGIN 
				UPDATE DT4ResearchCatBenchMark 
				SET    OpenTrialMedian = @OpenTrialMedian
				WHERE FY = @FY
				AND   Section = @Section;
			END 
			
			FETCH NEXT
			FROM @myCur INTO @Section, @OpenTrialMedian;
		END
		CLOSE @myCur
		DEALLOCATE @myCur
		
-- For  # of Patients Accrued
	SET @myCur = CURSOR FOR

		select  x.Section, CEILING(AVG(AccruedTotal)) as AccruedMedian
		FROM
		
		(
			SELECT s.Section, s.grantNumber,   SUM(s.CenterP12 + s.OthP12) AS AccruedTotal,
				ROW_NUMBER() over (partition by s.Section order by SUM(s.CenterP12+s.OthP12) ASC) as rowRank,
				COUNT(*) over (partition by s.Section) as cnt
		 
		FROM    Center C,
				Dt4 s
		WHERE s.FY = 2012
		AND   C.CenterId  = s.CenterId
		GROUP by s.Section, s.grantNumber

		) x
		where
			x.rowRank in (x.cnt/2+1, (x.cnt+1)/2)    
		group by
			x.Section

	OPEN @myCur
		FETCH NEXT
		FROM @myCur INTO @ClinicalResearchCat, @AccruedMedian
		WHILE @@FETCH_STATUS = 0
		BEGIN
		    IF @ClinicalResearchCat IS NULL 
		    BEGIN 
				UPDATE DT4ResearchCatBenchMark 
				SET    AccruedMedian = @AccruedMedian
				WHERE FY = @FY
				AND   ClinicalResearchCat IS NULL
		    END
		    
		    ELSE 
		    
		    BEGIN 
				UPDATE DT4ResearchCatBenchMark 
				SET    AccruedMedian = @AccruedMedian
				WHERE FY = @FY
				AND   ClinicalResearchCat = @ClinicalResearchCat;
			END
			
			FETCH NEXT
			FROM @myCur INTO @ClinicalResearchCat, @AccruedMedian;
		END
		CLOSE @myCur
		DEALLOCATE @myCur

END


--- 3 manually run the followng updates:
	--Update sum4ResearchCatBenchMark
	--set ClinicalResearchCat = 'Agent/Device'
	--where ClinicalResearchCat = '1';
	
	--Update sum4ResearchCatBenchMark
	--set ClinicalResearchCat = 'Other Intervention'
	--where ClinicalResearchCat = '2';
	
	--Update sum4ResearchCatBenchMark
	--set ClinicalResearchCat = 'Epi/Obs/Out'
	--where ClinicalResearchCat = '3';
	
	--Update sum4ResearchCatBenchMark
	--set ClinicalResearchCat = 'Anc/Comp/Cor'
	--where ClinicalResearchCat = '4';
	
	--Update sum4ResearchCatBenchMark
	--set ClinicalResearchCat = 'Unknown'
	--where ClinicalResearchCat  IS NULL;