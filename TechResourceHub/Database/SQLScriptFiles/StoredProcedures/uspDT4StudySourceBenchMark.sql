USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspGetDT4StudySourceBenchMark]    Script Date: 09/16/2013 09:51:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================
-- Author:		Chi T. Dinh
-- Create date: July 31, 2012
-- Description:	Get the  Median,  and Subtotal number of the open trila
                for each of the Source of Support (previously known as sposor category) (NEID)
   
   Note: To calculate the median, find the total number, add 1 and divide by 2.
         Mean = AVG
   Param:  FY 
   
   DATE			DESC
   09/12/2013	Modified sum4 to dt4
-- =============================================*/
/*


CREATE TABLE DT4StudySourceBenchMark(
DT4StudySourceBenchMarkID [int] IDENTITY(1,1) NOT NULL, 
FY int not null,
StudySourceCode	VARCHAR(50),
OpenTrialTotal int,
OpenTrialMedian int,
AccruedTotal int,
AccruedMedian int,
LastUpdatedDate Datetime default getdate(),
LastUpdatedUserName Varchar(25) default 'dinhct');
GO

alter table DT4StudySourceBenchMark 
Add CONSTRAINT [PKDT4StudySourceBenchMark] PRIMARY KEY CLUSTERED 
(
	[DT4StudySourceBenchMarkID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

*/


ALTER PROCEDURE [dbo].[uspDT4StudySourceBenchMark] 

AS
BEGIN

	DECLARE 
			
			@StudySourceCode VARCHAR(25),
			@OpenTrialTotal int,
			@OpenTrialMedian int,
			@AccruedTotal int,
			@AccruedMedian int,
			@FY int,
	        @myCur CURSOR;
	       
    SET @FY = 2012;
 ----================ get Total count  ============================
	---- For sponosor type/Source of Support/Study Source:
	
	-- (1)  manually ran the following statmt

    -- reset the Entity PK to 0
    --DBCC CHECKIDENT('DT4StudySourceBenchMark', RESEED, 5);
 
 /*   


 select * 
 INTO DT4StudySourceBenchMarkBackUP
 from DT4StudySourceBenchMark;
 
    INSERT INTO DT4StudySourceBenchMark(FY, StudySourceCode, OpenTrialTotal, AccruedTotal)

	SELECT 2012, StudySource,  StudySourceCnt,  SUM(CenterP12 + OthP12) as Total
    FROM 
        (SELECT   s.Category as StudySource, Count(s.DT4ID) as StudySourceCnt, coalesce(Sum(CenterP12), 0) as CenterP12,     coalesce( Sum(OthP12 ), 0) as OthP12
		FROM   DT4 s,
		   Center c
		WHERE  s.FY = 2012
		AND    s.centerID = c.CenterID
		GROUP BY   s.Category ) A
	
	GROUP BY StudySource, StudySourceCnt
	GO
	



    to verify:
    select GrantNumber, StudySource, SUM(CenterP12 + OthP12) as Total
from (
SELECT   s.GrantNumber, s.Category as StudySource, Count(s.DT4ID) as StudySourceCnt, coalesce(Sum(CenterP12), 0) as CenterP12,     coalesce( Sum(OthP12 ), 0) as OthP12
	FROM   DT4 s,
		   Center c
	WHERE  s.FY = 2012
	AND    s.centerID = c.CenterID
	GROUP BY  s.GrantNumber, s.Category ) A
	
	GROUP BY GrantNumber, StudySource;
	

    select * from DT4StudySourceBenchMark
	where fy = 2011;
	
	*/
	
-- ==================== Get the Median ==============================
-- For Study Source , # of open trials
	SET @myCur = CURSOR FOR

		select  x.Category, CEILING(AVG(OpenTrialTotal)) as OpenTrialMedian
		from 
		(
			SELECT s.Category, s.GrantNumber,  COUNT(s.GrantNumber) as OpenTrialTotal,
				ROW_NUMBER() over (partition by s.Category order by COUNT(s.GrantNumber) ASC) as rowRank,
				COUNT(*) over (partition by s.Category) as cnt
		 
		FROM    Center C,
				DT4 s
		WHERE s.FY = 2012
		AND   C.CenterId  = s.CenterId
		GROUP by s.Category, s.GrantNumber

		) x
		where
			x.rowRank in (x.cnt/2+1, (x.cnt+1)/2)    
		group by
			x.Category;

	OPEN @myCur
		FETCH NEXT
		FROM @myCur INTO @StudySourceCode, @OpenTrialMedian
		WHILE @@FETCH_STATUS = 0
		BEGIN
		    -- NOTE, null <> null
			IF @StudySourceCode IS NULL 
			BEGIN
				UPDATE DT4StudySourceBenchMark 
				SET    OpenTrialMedian = @OpenTrialMedian
				WHERE FY = @FY
				AND   StudySourceCode IS NULL;
			END
			
			ELSE 
			
			BEGIN 
				UPDATE DT4StudySourceBenchMark 
				SET    OpenTrialMedian = @OpenTrialMedian
				WHERE FY = @FY
				AND   StudySourceCode = @StudySourceCode;
			END 
			
			FETCH NEXT
			FROM @myCur INTO @StudySourceCode, @OpenTrialMedian;
		END
		CLOSE @myCur
		DEALLOCATE @myCur
		
-- For Source of Support, # of Patients Accrued
	SET @myCur = CURSOR FOR

		select  x.Category,CEILING(AVG(AccruedTotal)) as AccruedMedian
		from 
		(
			SELECT s.Category, s.GrantNumber,  SUM(s.CenterP12+s.OthP12) as AccruedTotal,
				ROW_NUMBER() over (partition by s.Category order by SUM(s.CenterP12+s.OthP12) ASC) as rowRank,
				COUNT(*) over (partition by s.Category) as cnt
		 
		FROM    Center C,
				DT4 s
		WHERE s.FY = 2012
		AND   C.CenterId  = s.CenterId
		GROUP by s.Category, s.GrantNumber

		) x
		where
			x.rowRank in (x.cnt/2+1, (x.cnt+1)/2)    
		group by
			x.Category;

	OPEN @myCur
		FETCH NEXT
		FROM @myCur INTO @StudySourceCode, @AccruedMedian
		WHILE @@FETCH_STATUS = 0
		BEGIN
		    IF @StudySourceCode IS NULL 
		    BEGIN 
				UPDATE DT4StudySourceBenchMark 
				SET    AccruedMedian = @AccruedMedian
				WHERE FY = @FY
				AND   StudySourceCode IS NULL
		    END
		    
		    ELSE 
		    
		    BEGIN 
				UPDATE DT4StudySourceBenchMark 
				SET    AccruedMedian = @AccruedMedian
				WHERE FY = @FY
				AND   StudySourceCode = @StudySourceCode;
			END
			
			FETCH NEXT
			FROM @myCur INTO @StudySourceCode, @AccruedMedian;
		END
		CLOSE @myCur
		DEALLOCATE @myCur

END


/* verification process

  select * from center
  Yale = 16359
  Gtown = 51008


select  SUM(CenterP12+ OthP12) as AccruedTotalFY11
from dt4
where fy = 2011
and GrantNumber = 6516;

select  SUM(CenterP12+ OthP12) as AccruedTotalFY12
from dt4
where fy = 2012
and GrantNumber = 6516;

select  SUM(CenterP12+ OthP12) as AccruedTotalFY11
from dt4
where fy = 2011
and GrantNumber = 16359;

select  SUM(CenterP12+ OthP12) as AccruedTotalFY12
from dt4
where fy = 2012
and GrantNumber = 16359;

select  SUM(CenterP12+ OthP12) as AccruedTotalFY11
from dt4
where fy = 2011
and GrantNumber = 51008;

select  SUM(CenterP12+ OthP12) as AccruedTotalFY12
from dt4
where fy = 2012
and GrantNumber = 51008;

*/

/*
Lastly, Run the following statement manually

update DT4StudySourceBenchMark
set StudySourceCode = 'Unknown'
where StudySource IS NULL;


    select * from DT4StudySourceBenchMark
	where fy = 2011;
	
	select * from DT4StudySourceBenchMark
	where fy = 2012;
	
*/


