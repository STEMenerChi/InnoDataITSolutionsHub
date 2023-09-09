

ALTER PROCEDURE dbo.uspNoOfTreatmentTrials
	
AS
/*
April 15, 2013
Requested by Linda

To follow up on a query from the wg, I would like 2 tables from DT 4 (just for internal use for now) as follows:

FY 11 by center

1. # of Clinical trial accrual by study source (I,D, N, E) and total across all sources, sorted by total accrual, high to low
Number of clinical trial accrual by study source (I,D, N, E) and total across all sources is the sum of CenterP12 + Center2Date + OtherP12 + Other2Date?

2. # of clinical trials by  study source (I,D,N,E), and total across all sources, sorted by total # of trials, high to low


Use therapeutic (treatment) studies only.
Eliminate those with NULL info.
Format as shown below for both accrual and # of trials, sort highest to lowest based on total column.

Cancer Center Name   Industry    Ext. Peer  Instit  National   Total 

Baylor              xxxx        xxxx         xxxx   xxxx      xxxx


*/

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE 	
		@Inst VARCHAR(255),
		@StudySource varchar(1),
		@StudySourceCode Varchar(1),
		@D INT,
		@E INT,
		@I INT,
		@N INT,
		@NoOfAccrual INT,
		@GrantNumber INT,
		@GrantNo     INT,
		@Total       INT,
		@myCur1 CURSOR,
		@myCur2 CURSOR;
		
  
        /*
     	CREATE  TABLE TreatmentTrial
		(InstitutionName varchar(255), 
		 GrantNumber int, 
		 D int, 
		 E int,
		 I  int,
		 N int,
		 Total int );
		 */

    --- DELETE FROM TreatmentTrial;
   
    INSERT INTO TreatmentTrial(InstitutionName, GrantNumber ) 	
    SELECT  DISTINCT c.InstitutionName, c.GrantNumber  
	FROM    DT4 d,
			Center c
	WHERE    FY = 2011
	AND      d.StudySourceCode IS NOT NULL
	AND      d.CenterID = c.CenterId
	GROUP BY c.InstitutionName, c.grantNumber,  d.StudySourceCode 
	

SET @myCur1 = CURSOR FOR
	SELECT  c.grantNumber,  
			d.StudySourceCode, count(d.dt4ID) as NoOfTrial 
	FROM    DT4 d,
			Center c
	WHERE    FY = 2011
	AND      d.StudySourceCode IS NOT NULL
	AND      d.CenterID = c.CenterId
	GROUP BY c.grantNumber,  d.StudySourceCode ;
 
 OPEN @myCur1
	FETCH NEXT
	FROM @myCur1 INTO @GrantNumber, @StudySource, @NoOfAccrual
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    IF @StudySource = 'D' 
	       UPDATE TreatmentTrial
	       SET D = @NoOfAccrual
	       WHERE GrantNumber = @GrantNumber;
	    ELSE IF  @StudySource = 'E' 
	       UPDATE TreatmentTrial
	       SET  E = @NoOfAccrual
	       WHERE GrantNumber = @GrantNumber;
		ELSE IF  @StudySource = 'I' 
		   UPDATE TreatmentTrial
		   SET  I = @NoOfAccrual
		   WHERE GrantNumber = @GrantNumber;
        ELSE IF  @StudySource = 'N' 
			UPDATE TreatmentTrial
	        SET  N = @NoOfAccrual
		    WHERE GrantNumber = @GrantNumber;
		
		FETCH NEXT
			FROM @myCur1 INTO @GrantNumber, @StudySource, @NoOfAccrual
	END
	CLOSE @myCur1
	DEALLOCATE @myCur1
--------------------------
SET @myCur2 = CURSOR FOR

	SELECT  c.grantNumber,
			d.StudySourceCode, Count(d.dt4ID) as Total 
	FROM    DT4 d,
			Center c
	WHERE    FY = 2011
	AND      d.StudySourceCode IS NOT NULL
	AND      d.CenterID = c.CenterId
	GROUP BY GROUPING SETS ( c.grantNumber, d.StudySourceCode )



OPEN @myCur2
	FETCH NEXT
	FROM @myCur2 INTO @GrantNo,  @StudySourceCode, @Total
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE TreatmentTrial 
		SET    Total = @Total
		WHERE  GrantNumber = @GrantNo;
		
		FETCH NEXT
			FROM @myCur2 INTO @GrantNo,  @StudySourceCode, @Total
	END
	CLOSE @myCur2
	DEALLOCATE @myCur2
			
END