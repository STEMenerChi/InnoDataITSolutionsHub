USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT2bBenchmark]    Script Date: 2/14/2022 1:23:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- ====================================================================================================================================
-- Author:		Chi T. Dinh
-- Create date: June 8, 2012
-- Description:	Get the High, Median, and Low, and Subtotal number of the Active Funded Projects
                for each of the Center Type (Basic, Clinical, and Comprehensive)
   
   Note: To calculate the median, find the total number, add 1 and divide by 2.
         Mean = AVG
   Param:  FY 
   
   DATE			DESC
   11/07/2013   Modified DT2 to dt2, ran fy2012 data
   12/30/2013   Added the CAST int value to BIGINT to the AVG calculation. 
   For For some reason the SQL team decided to use the native type of the column for computations, and so when the values are SUMmed, 
   it obviously exceeds the value of INT.
   11/29/2017    Updated with FY14
   12/15/2020    Updated w/ FY15-19 - NOTE after 2015, we no longer keep track of TC, just DC
                 Updated TC to DC
-- ===================================================================================================================================*/

/* to see which institution has the most or the least funds.
 SELECT  c.CenterTypeID, c.InstitutionName,  s.grantNumber, SUM( s.NCIDC) as NCItotal,   SUM(s.OthNIHDC) as NIHtotal
			FROM   [DT2B] s,
				   Center c
			WHERE  s.centerID = c.CenterID
			AND    s.FY = 2015
			and    c.CenterTypeID = 3
			GROUP BY c.CenterTypeID, c.InstitutionName, s.grantNumber
			order by SUM( s.NCIDC) DESC, SUM(s.OthNIHDC)  DESC
			

			
	-- to get the actual #basic, clinical, and comp in DB:
	select FY, CenterTypeID, count(d.grantNumber)
	from dt2b d, 
	     Center c
	where d.centerId = c.CenterID
	and   c.centerTypeID in (1,2,3)
	and   fy = 2015
	group by fy, CenterTypeID
	order by  fy, CenterTypeID
------
1. first backup always :
Select * 
into DT2bBenchmarkBU2022Feb14
from DT2bBenchmark; 

select * from dt2bBenchmark
order by fy;

2. check to ensure the data are available:
select FY, Count(*)
from dt2B
group by fy
order by fy; 

3. reset the PK:
select max(DT2bbenchmarkID) from dt2bBenchmark; 

DBCC CHECKIDENT('DT2bBenchMark', RESEED, 11);

-- ensure the #basic #clinical #comp are the same in other benchmark table:
select FY, basiccount, clinicalcount, compcount 
from dt1Dbenchmark
order by fy

4. Got these data from Nga:

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

UPDATE DT2bBenchmark
SET   ClinicalCount = 15,
      CompCount = 47
WHERE FY = 2016;

UPDATE DT2bBenchmark
SET   ClinicalCount = 13,
      CompCount = 49
WHERE FY = 2017;

UPDATE DT2bBenchmark
SET   ClinicalCount = 13,
      CompCount = 51
WHERE FY = 2019;

					
Insert into DT2bBenchmark (FY, BasicCount, ClinicalCount, CompCount)
VALUES (2020, 7, 13, 51);

    
select * from DT2bBenchmark 
order by FY;
*/


ALTER PROCEDURE [dbo].[uspDT2bBenchmark] 
@FY INT
AS
BEGIN

	DECLARE 
	        @CenterTypeID INT,
			@Median INT,
	        @NCIHigh INT,
			@NCILow INT,
			@NCIAvg INT,
			@NIHHigh INT,
			@NIHLow INT,
			@NIHAvg INT,
	        --@FY INT,
	        @myCur CURSOR,
	        @myCur2 CURSOR,
	        @myCur3 CURSOR;
	    
    --SET @FY = 2014;
    
    --================ get MAX/MIN/AVG amount ============================
	-- round to zero decimal 
	SET @myCur = CURSOR FOR
	
	SELECT  CenterTypeID,  
	        MAX(NCIdc)  AS MaxNCIdc, MAX(OthNIHdc) as MaxNIHdc, 
	        MIN(NCIdc)  AS MinNCIdc, MIN(OthNIHdc) as MinNIHdc,
	        AVG(CAST (NCIdc AS BIGINT))  AS AvgNCIdc, AVG(CAST (OthNIHdc AS BIGINT)) as AvgNIHdc 
	FROM ( SELECT  c.CenterTypeID, s.grantNumber, ROUND(s.NCIDC, 0) as NCIDC ,  ROUND(s.OthNIHDC, 0) as OthNIHDC
			FROM   [DT2B] s,
				   Center c
			WHERE  s.centerID = c.CenterID
			AND s.FY = @FY
			GROUP BY c.CenterTypeID,  s.grantNumber, s.NCIDC ,   s.OthNIHDC 
			) sys
	GROUP BY CenterTypeID;
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @CenterTypeID, @NCIHigh, @NIHHigh,  @NCILow, @NIHLow, @NCIAvg, @NIHAvg
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		IF @CenterTypeID = 1 -- Basic, update the latest row
		BEGIN
			UPDATE DT2bBenchMark
			SET    BasicNCIHigh = @NCIHigh,
				   BasicNIHHigh = @NIHHigh,
				   BasicNCILow  = @NCILow,
				   BasicNIHLow  = @NIHLow,
				   BasicNCIAvg  = @NCIAvg,
				   BasicNIHAvg  = @NIHAvg
		   --WHERE   DT2bBenchMarkID = (Select MAX(DT2bBenchMarkID) from DT2bBenchMark)
		   WHERE      [FY] = @FY
		   
		END		   
		ELSE IF  @CenterTypeID = 2 -- Clinical 
		BEGIN
			UPDATE DT2bBenchMark
			SET    ClinicalNCIHigh = @NCIHigh,
				   ClinicalNIHHigh = @NIHHigh,
				   ClinicalNCILow = @NCILow,
				   ClinicalNIHLow = @NIHLow,
				   ClinicalNCIAvg = @NCIAvg,
				   ClinicalNIHAvg = @NIHAvg			
			WHERE   [FY] = @FY
		END
		ELSE 
			UPDATE DT2bBenchMark
			SET    CompNCIHigh = @NCIHigh,
				   CompNIHHigh = @NIHHigh,
				   CompNCILow = @NCILow,
				   CompNIHLow = @NIHLow,
				   CompNCIAvg = @NCIAvg,
				   CompNIHAvg = @NIHAvg
			 --WHERE DT2bBenchMarkID = (Select MAX(DT2bBenchMarkID) from DT2bBenchMark)
			 WHERE   [FY] = @FY
		FETCH NEXT
		FROM @myCur INTO @CenterTypeID, @NCIHigh, @NIHHigh,  @NCILow, @NIHLow, @NCIAvg,@NIHAvg
	END
	CLOSE @myCur
	DEALLOCATE @myCur
		

-- ==================== Get the Median ==============================
--NCI
	SET @myCur2 = CURSOR FOR

		select  centertypeID,CEILING(AVG(TotalAward)) as MedianNCITotalAward
		from 
		(
			SELECT c.centertypeID, s.GrantNumber,  ROUND(s.NCIDC, 0) as TotalAward, 
				ROW_NUMBER() over (partition by c.centertypeID order by s.NCIDC ASC) as AwardRank,
				COUNT(*) over (partition by c.centertypeID) as CenterTypeCount
			FROM    Center C,
					[DT2B] s
			WHERE   C.CenterId  = s.CenterId
			AND     s.FY = @FY
			GROUP BY c.centertypeID, s.GrantNumber, s.NCIDC

		) x
		where
			x.AwardRank in (x.CenterTypeCount/2+1, (x.CenterTypeCount+1)/2)    
		group by
			x.centertypeID;
	    
	    OPEN @myCur2
		FETCH NEXT
		FROM @myCur2 INTO @CenterTypeID, @Median
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			IF @CenterTypeID = 1 -- Basic
				UPDATE DT2bBenchMark
				SET    BasicNCIMedian = @Median
				--WHERE  DT2bBenchMarkID = (Select MAX(DT2bBenchMarkID) from DT2bBenchMark)
				WHERE    [FY] = @FY;
		    ELSE IF @CenterTypeID = 2 -- Clinical
				UPDATE DT2bBenchMark
				SET    ClinicalNCIMedian = @Median
				--WHERE  DT2bBenchMarkID = (Select MAX(DT2bBenchMarkID) from DT2bBenchMark)
				WHERE    [FY] = @FY;
			ELSE
				UPDATE DT2bBenchMark
				SET    CompNCIMedian = @Median
				--WHERE  DT2bBenchMarkID = (Select MAX(DT2bBenchMarkID) from DT2bBenchMark)
				WHERE    [FY] = @FY;	 
					      
			FETCH NEXT
			FROM @myCur2 INTO @CenterTypeID,@Median
		END
		CLOSE @myCur2
		DEALLOCATE @myCur2
----------------NIH
    SET @myCur3 = CURSOR FOR
		select  centertypeID, CEILING(AVG(TotalAward)) as MedianNIHTotalAward
		from 
		(
			SELECT c.centertypeID, s.grantNumber,  ROUND(s.OthNIHDC, 0) as TotalAward, 
				ROW_NUMBER() over (partition by c.centertypeID order by  SUM(s.OthNIHDC) ASC) as AwardRank,
				COUNT(*) over (partition by c.centertypeID) as CenterTypeCount
			FROM    Center C,
					[DT2B] s
			WHERE   C.CenterId  = s.CenterId
			AND   [FY] = @FY
			GROUP by c.centertypeID, s.grantNumber, s.OthNIHDC

		) x
		where
			x.AwardRank in (x.CenterTypeCount/2+1, (x.CenterTypeCount+1)/2)    
		group by
			x.centertypeID;
			
		OPEN @myCur3
		FETCH NEXT
		FROM @myCur3 INTO @CenterTypeID, @Median
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			IF @CenterTypeID = 1 -- Basic
				UPDATE DT2bBenchMark
				SET    BasicNIHMedian = @Median
				--WHERE  DT2bBenchMarkID = (Select MAX(DT2bBenchMarkID) from DT2bBenchMark)
				WHERE    [FY] = @FY;
		    ELSE IF @CenterTypeID = 2 -- Clinical
				UPDATE DT2bBenchMark
				SET    ClinicalNIHMedian = @Median
				--WHERE  DT2bBenchMarkID = (Select MAX(DT2bBenchMarkID) from DT2bBenchMark)
				WHERE    [FY] = @FY;
			ELSE
				UPDATE DT2bBenchMark
				SET    CompNIHMedian = @Median
				--WHERE  DT2bBenchMarkID = (Select MAX(DT2bBenchMarkID) from DT2bBenchMark)
				WHERE    [FY] = @FY; 
					      
			FETCH NEXT
			FROM @myCur3 INTO @CenterTypeID,@Median
		END
		CLOSE @myCur3
		DEALLOCATE @myCur3
	    
    
END
