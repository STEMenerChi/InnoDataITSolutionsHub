USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT4ResearchCatBenchmark]    Script Date: 09/17/2013 15:29:20 ******/
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
   09/17/2013   Added the field Section,
                calculated the SUM of the CenterP12 and OthP12 seperately first, then performed AccruedTotal = CenterP12 + OtherP12, 
                introduced COALESCE function which evaluates NULL to zero to correctly calculate the SUM of CenterP12 and OtherP12.
                             
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
	
    -- reset the Entity PK to 0, 5, 10
    --DBCC CHECKIDENT('DT4ResearchCatBenchmark', RESEED, 10);
	--(1) Manually run the following stmt:
	
/*
	update DT4ResearchCatBenchMark
	set Section = 1
	where ClinicalResearchCat = 'Agent/Device';
	update DT4ResearchCatBenchMark
	set Section = 2
	where ClinicalResearchCat = 'Other Intervention';
	update DT4ResearchCatBenchMark
	set Section = 3
	where ClinicalResearchCat = 'Epi/Obs/Out';
	update DT4ResearchCatBenchMark
	set Section = 4
	where ClinicalResearchCat = 'Anc/Comp/Cor';
	update DT4ResearchCatBenchMark
	set Section = 0
	where ClinicalResearchCat = 'Unspecified';

    --INSERT INTO DT4ResearchCatBenchMark(FY, Section, ClinicalResearchCat, OpenTrialTotal, AccruedTotal)

	SELECT FY, section, ClinicalResearchCat, OpenTrialTotal,  z.CenterP12 + z.OthP12 AS AccruedTotal
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
		GROUP BY s.Section ) z;
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

		SELECT  x.Section, CEILING(AVG(AccruedTotal)) as AccruedMedian
		FROM
		
		(
			SELECT z.Section, z.GrantNumber, (z.CenterP12Total + z.OthP12Total) AS AccruedTotal,
			       ROW_NUMBER() over (partition by z.Section order by SUM(z.CenterP12Total + z.OthP12Total) ASC) as rowRank,
				   COUNT(*) over (partition by z.Section) as cnt
			FROM
			(SELECT s.Section, s.grantNumber,   SUM(s.CenterP12) AS CenterP12Total, COALESCE(SUM(s.OthP12), 0) AS OthP12Total	
			 FROM   Center C,
					Dt4 s
			 WHERE s.FY = 2012
			 AND   C.CenterId  = s.CenterId
			 GROUP by s.Section, s.grantNumber ) z
			 GROUP by z.Section, z.GrantNumber, z.CenterP12Total + z.OthP12Total

		) x
		where
			x.rowRank in (x.cnt/2+1, (x.cnt+1)/2)    
		group by
			x.Section; 

	OPEN @myCur
		FETCH NEXT
		FROM @myCur INTO @Section, @AccruedMedian
		WHILE @@FETCH_STATUS = 0
		BEGIN
		    IF @Section IS NULL 
		    BEGIN 
				UPDATE DT4ResearchCatBenchMark 
				SET    AccruedMedian = @AccruedMedian
				WHERE FY = @FY
				AND   Section = 0
		    END
		    
		    ELSE 
		    
		    BEGIN 
				UPDATE DT4ResearchCatBenchMark 
				SET    AccruedMedian = @AccruedMedian
				WHERE FY = @FY
				AND   Section = @Section;
			END
			
			FETCH NEXT
			FROM @myCur INTO @Section, @AccruedMedian;
		END
		CLOSE @myCur
		DEALLOCATE @myCur

END

