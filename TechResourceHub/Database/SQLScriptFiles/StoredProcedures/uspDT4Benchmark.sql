USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspGetSum4BenchMark]    Script Date: 09/09/2013 12:13:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================
-- Author:		Chi T. Dinh
-- Date         Desc
-- 07/05/2012	Created. 
   Get the  Median,  and Subtotal number of the open trila
   for each of the sposor category (NEID)
   
   Note: To calculate the median, find the total number, add 1 and divide by 2.
         Mean = AVG
   Param:  FY 
   09/09/2013   Modifed SUM4 to DT4
   
-- =============================================*/
/*
--Drop table Sum4SourceOfSupportBenchMark;

CREATE TABLE Sum4SourceOfSupportBenchMark(
Sum4SourceOfSupportBenchMarkID [int] IDENTITY(1,1) NOT NULL, 
FY int not null,
SourceOfSupportCode	VARCHAR(50),
OpenTrialTotal int,
OpenTrialMedian int,
AccruedTotal int,
AccruedMedian int,
LastUpdatedDate Datetime default getdate(),
LastUpdatedUserName Varchar(25) default 'dinhct');
GO

alter table Sum4SourceOfSupportBenchMark 
Add CONSTRAINT [PKSum4SourceOfSupportBenchMark] PRIMARY KEY CLUSTERED 
(
	[Sum4SourceOfSupportBenchMarkID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

-- drop table Sum4ResearchCatBenchMark;
CREATE TABLE Sum4ResearchCatBenchMark(
Sum4ResearchCatBenchMarkID [int] IDENTITY(1,1) NOT NULL, 
FY int not null,
ClinicalResearchCat VARCHAR(255),
OpenTrialTotal int,
OpenTrialMedian int,
AccruedTotal int,
AccruedMedian int,
LastUpdatedDate Datetime default getdate(),
LastUpdatedUserName Varchar(25) default 'dinhct');

GO
alter table Sum4ResearchCatBenchMark
Add CONSTRAINT [PKSum4ResearchCatBenchMark] PRIMARY KEY CLUSTERED 
(
	[Sum4ResearchCatBenchMarkID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

-- DROP TABLE Sum4PhaseBenchMark
CREATE TABLE Sum4PhaseBenchMark(
Sum4PhaseBenchMarkID [int] IDENTITY(1,1) NOT NULL, 
FY int not null,
Phase VARCHAR(25),
OpenTrialTotal int,
OpenTrialMedian int,
AccruedTotal int,
AccruedMedian int,
LastUpdatedDate Datetime default getdate(),
LastUpdatedUserName Varchar(25) default 'dinhct');

GO
alter table Sum4PhaseBenchMark
Add CONSTRAINT [PKSum4PhaseBenchMark] PRIMARY KEY CLUSTERED 
(
	[Sum4PhaseBenchMarkID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

--drop table Sum4StudyTypeBenchMark;

CREATE TABLE Sum4StudyTypeBenchMark(
Sum4StudyTypeBenchMarkID [int] IDENTITY(1,1) NOT NULL, 
FY int not null,
StudyType	VARCHAR(255),
OpenTrialTotal int,
OpenTrialMedian int,
AccruedTotal int,
AccruedMedian int,
LastUpdatedDate Datetime default getdate(),
LastUpdatedUserName Varchar(25) default 'dinhct');
GO

alter table Sum4StudyTypeBenchMark
Add CONSTRAINT [PKSum4StudyTypeBenchMark] PRIMARY KEY CLUSTERED 
(
	[Sum4StudyTypeBenchMarkID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


insert into Sum4Benchmark(FY, BasicCount, ClinicalCount, CompCount)
Values (2011, 7, 19, 40)
*/

ALTER PROCEDURE [dbo].[uspGetDT4BenchMark] 
(@FY INT) 
AS
BEGIN

	DECLARE 
			
			@SourceOfSupportCode VARCHAR(25),
			@OpenTrialTotal int,
			@OpenTrialMedian int,
			@AccruedTotal int,
			@AccruedMedian int,
	        @myCur CURSOR,
	        @myCur2 CURSOR,
	        @myCur3 CURSOR,
	        @myCur4 CURSOR;
    
 --   --================ get Total count  ============================
	---- For sponosor type or Source of Support:
	
	--    --delete from Sum4SourceOfSupportBenchMark where FY =2011;
	 --   INSERT INTO sum4SourceOfSupportBenchMark(FY, SourceOfSupportCode, OpenTrialTotal,AccruedTotal)
		--SELECT 2011, s.Category as SourceOfSupport, Count(s.Sum4ID) as SourceOfSupportCnt, CEILING(Sum(CenterP12 + OthP12)) as AccruedTotal
		--FROM   Sum4 s,
		--	   Center c
		--WHERE  s.centerID = c.CenterID
		----AND s.FY = @FY
		--GROUP BY s.Category
		--ORDER BY s.Category
		--GO
		
	--	select * from sum4sourceOfsupportBenchMark
	--	where fy = 2011;
	
-- ==================== Get the Median ==============================
-- For Source of Support, # of open trials
	SET @myCur = CURSOR FOR

		select  x.Category, CEILING(AVG(OpenTrialTotal)) as OpenTrialMedian
		from 
		(
			SELECT s.Category, s.GrantNumber,  COUNT(s.GrantNumber) as OpenTrialTotal,
				ROW_NUMBER() over (partition by s.Category order by COUNT(s.GrantNumber) ASC) as rowRank,
				COUNT(*) over (partition by s.Category) as cnt
		 
		FROM    Center C,
				Sum4 s
		WHERE   C.CenterId  = s.CenterId
		GROUP by s.Category, s.GrantNumber

		) x
		where
			x.rowRank in (x.cnt/2+1, (x.cnt+1)/2)    
		group by
			x.Category;

	OPEN @myCur
		FETCH NEXT
		FROM @myCur INTO @SourceOfSupportCode, @OpenTrialMedian
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			UPDATE Sum4SourceOfSupportBenchMark 
			SET    OpenTrialMedian = @OpenTrialMedian
			WHERE FY = @FY
			AND   SourceOfSupportCode = @SourceOfSupportCode;
			 
			FETCH NEXT
			FROM @myCur INTO @SourceOfSupportCode, @OpenTrialMedian;
		END
		CLOSE @myCur
		DEALLOCATE @myCur
		
-- For Source of Support, # of Patients Accrued
	--SET @myCur = CURSOR FOR

	--	select  x.Category,CEILING(AVG(AccruedTotal)) as AccruedMedian
	--	from 
	--	(
	--		SELECT s.Category, s.GrantNumber,  SUM(s.CenterP12+s.OthP12) as AccruedTotal,
	--			ROW_NUMBER() over (partition by s.Category order by SUM(s.CenterP12+s.OthP12) ASC) as rowRank,
	--			COUNT(*) over (partition by s.Category) as cnt
		 
	--	FROM    Center C,
	--			Sum4 s
	--	WHERE   C.CenterId  = s.CenterId
	--	GROUP by s.Category, s.GrantNumber

	--	) x
	--	where
	--		x.rowRank in (x.cnt/2+1, (x.cnt+1)/2)    
	--	group by
	--		x.Category;

	--OPEN @myCur
	--	FETCH NEXT
	--	FROM @myCur INTO @SourceOfSupportCode, @AccruedMedian
	--	WHILE @@FETCH_STATUS = 0
	--	BEGIN
		
	--		UPDATE Sum4SourceOfSupportBenchMark 
	--		SET    AccruedMedian = @AccruedMedian
	--		WHERE FY = @FY
	--		AND   SourceOfSupportCode = @SourceOfSupportCode;
			 
	--		FETCH NEXT
	--		FROM @myCur INTO @SourceOfSupportCode, @AccruedMedian;
	--	END
	--	CLOSE @myCur
	--	DEALLOCATE @myCur

END
