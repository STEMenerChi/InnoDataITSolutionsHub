USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspDT1aBenchMark]    Script Date: 3/21/2017 1:46:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*===========================================================================================================
 DATE		PROGRAMMER			DESC
 06/032012	Chi Dinh            Created.
                                Get the High, Median, and Low, and Subottal number of the Sr. Leadership 
                                for each of the Center Type (Basic, Clinical, and Comprehensive)
  Note: to calculate the median : get the middle value(s),  add them up and divide by 2.
  Param:  FY 
 
  11/04/2013 C. Dinh			Modified from sum4 to dt4.
  03/08/2016 C. Dinh            Updated the data with FY14
  03/21/2017 Chi				Updated for FY15 data
   
==========================================================================================================*/

ALTER PROCEDURE [dbo].[uspDT1aBenchMark] 

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
	        @FY INT;
	    
    
    SET @FY = 2015;
    
   
    
/* 
(1)  backup
     
Select *
into DT1aBenchmark20170321
from DT1aBenchmark;

select * from DT1aBenchmark
order by FY;

select fy, count(*)
 from dt1aLeadership
group by fy
order by fy;

(2) reset the PK:
select max(DT1aBenchMarkID) from DT1aBenchMark;
DBCC CHECKIDENT('DT1aBenchMark', RESEED, 4);

(3) get this from Nga (FY15):
 Basic    = 7
 Clinical = 17
 Comp     = 45

 (FY16):
 Basic    = 7
 Clinical = 15
 Comp     = 47


(4) get subTotal number of leaders for (1) Basic, (2) Clinical, and (3) Comprehensive Centers:
    
	 
		 SELECT c.CenterTypeID,  COUNT(*) as SubTotal 
		 FROM   dt1aLeadership s,
			    Center c
		 WHERE  FY = 2015
		 AND    s.centerID = c.CenterID
		 and    C.CenterTypeID in (1,2, 3)
		 GROUP BY c.CenterTypeID;


		 INSERT INTO DT1aBenchmark (FY, BasicCount, BasicSubtotal, ClinicalCount, ClinicalSubtotal, CompCount, CompSubtotal)
		 Values (2015, 7, 26, 17, 117, 45, 414); 
	
select * from DT1aBenchmark
order by FY;					
*/	

	--================ get high/MAX numbers of leaders============================
	UPDATE DT1aBenchMark
	
	SET BasicHigh = (SELECT  MAX(cnt)  as DT1aMaxBasic
					 FROM ( SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
							FROM   dt1aLeadership s,
								   Center c
							WHERE c.CenterTypeID = 1
							AND s.FY = @FY
							AND  s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
	WHERE FY = @FY;
	
		UPDATE DT1aBenchMark
		SET ClinicalHigh = (SELECT  MAX(cnt)  as DT1aMaxClinical
							FROM 
							   (SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
								FROM   dt1aLeadership s,
									   Center c
								WHERE c.CenterTypeID = 2
								AND   s.centerID = c.CenterID 
								AND   s.FY = @FY  
								GROUP BY c.CenterTypeID, s.GrantNumber
								)       sys )
        WHERE FY = @FY;
        
		UPDATE DT1aBenchMark
		SET CompHigh = (SELECT  MAX(cnt)  as DT1aMaxClinical
					    FROM 
							(SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
						     FROM   dt1aLeadership s,
									   Center c
							 WHERE c.CenterTypeID = 3
							 AND   s.centerID = c.CenterID
							 AND s.FY = @FY  
							 GROUP BY c.CenterTypeID, s.GrantNumber
							 )
					    sys)
	  WHERE FY = @FY;

--================get low/MIN numbers of leaders==========================

		UPDATE DT1aBenchMark
		SET BasicLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
							FROM   dt1aLeadership s,
								   Center c
							WHERE  c.CenterTypeID = 1
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
        WHERE FY = @FY;
        
		UPDATE DT1aBenchMark
		SET ClinicalLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
							FROM   dt1aLeadership s,
								   Center c
							WHERE  c.CenterTypeID = 2
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		WHERE FY = @FY;
							
		UPDATE DT1aBenchMark
		SET CompLow = (SELECT  MIN(cnt)  
						FROM 
						(	SELECT c.CenterTypeID, s.GrantNumber,  COUNT(s.GrantNumber) AS CNT
							FROM   dt1aLeadership s,
								   Center c
							WHERE  c.CenterTypeID = 3
						    AND s.FY = @FY  
						    AND   s.centerID = c.CenterID
							GROUP BY c.CenterTypeID, s.GrantNumber
							) sys)
		WHERE FY = @FY;
		
		--========= Get the median number of the Sr. Leaders=====================
	    -- Basic Median
		SELECT @BasicCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT(s.GrantNumber) AS IDCount 
				FROM   dt1aLeadership s,
					   Center c
				WHERE c.CenterTypeID = 1
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @BasicMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(s.GrantNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(s.GrantNumber))AS ROW 
		FROM   dt1aLeadership s,
			   Center c
		WHERE c.CenterTypeID = 1
		AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@BasicCount/2),(@BasicCount/2)+1)

		UPDATE DT1aBenchMark
		SET BasicMedian = (SELECT CEILING(@BasicMedian))
		WHERE FY = @FY;
		    
		--Clinical Median
		SELECT @ClinicalCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT(s.GrantNumber) AS IDCount 
				FROM   dt1aLeadership s,
					   Center c
				WHERE c.CenterTypeID = 2
				AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @ClinicalMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(s.GrantNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(s.GrantNumber))AS ROW 
		FROM   dt1aLeadership s,
			   Center c
		WHERE c.CenterTypeID = 2
		AND   FY = 2012
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@ClinicalCount/2),(@ClinicalCount/2)+1)

		UPDATE DT1aBenchMark
		SET ClinicalMedian = (SELECT CEILING(@ClinicalMedian))	   
		WHERE FY = @FY;

-- for Comp Median
	
	    
		SELECT @CompCount=COUNT(*) 
		FROM (  SELECT s.GrantNumber,COUNT(s.GrantNumber) AS IDCount 
				FROM   dt1aLeadership s,
					   Center c
				WHERE c.CenterTypeID = 3
			    AND   FY = @FY
				AND   s.centerID = c.CenterID
				GROUP BY s.GrantNumber
				)AB
		SELECT @CompMedian=(SUM(Convert(float,IDCount))/2) 
		FROM(SELECT s.GrantNumber,COUNT(s.GrantNumber)AS IDCount,ROW_NUMBER() OVER(ORDER BY COUNT(s.GrantNumber))AS ROW 
		FROM   dt1aLeadership s,
			   Center c
		WHERE c.CenterTypeID = 3
		AND   FY = @FY
		AND   s.centerID = c.CenterID
		GROUP BY s.GrantNumber)AB
		WHERE AB.Row IN ((@CompCount/2),(@CompCount/2)+1)

		UPDATE DT1aBenchMark
		SET CompMedian = (SELECT CEILING(@CompMedian))   
		WHERE FY = @FY;

END
