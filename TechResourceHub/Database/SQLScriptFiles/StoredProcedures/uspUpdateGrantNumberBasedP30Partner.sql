USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspUpdateGrantNumberBaseInst]    Script Date: 11/30/2012 08:17:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Chi T. Dinh
-- Create date:  11/30/2012
-- Description:	1.  Add the GrantNumber field the specified table
--              2.  Updated the newly created GrantNumber and the CenterID with values in the Center table base on the SerialNo
--          
-- Required Parameter:   Target Table Name
-- =============================================
CREATE PROCEDURE  [dbo].[uspUpdateGrantNumberBaseP30Partner] 
(@TableName VARCHAR(30)) 

AS
BEGIN
	
	DECLARE @myCur			 CURSOR, 
	        @GrantNumber	 INT,
	        @CenterID        INT,
	        @P30Partner      VARCHAR(255),
	        @SQL             NVARCHAR(MAX),
	        @pGrantNumber	 NVARCHAR(MAX),
	        @pCenterID       NVARCHAR(MAX),
	        @pP30Partner     NVARCHAR(MAX);
	 


	
	
	SET @myCur = CURSOR FOR
	SELECT distinct  CenterID, GrantNumber, P30Partner 
	FROM   P30Partner
	
	
	
	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @CenterID, @GrantNumber, @P30Partner
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SELECT @pCenterID    = @CenterID;
		SET    @pGrantNumber = @GrantNumber;
		SET    @pP30Partner  = @P30Partner;
		
	    SELECT @SQL = N' UPDATE ' + @TableName +
		N' SET    CenterID    =  ' + @pCenterID +
		N' ,      GrantNUmber =  ' + @pGrantNumber +
		N' WHERE  GrantNumber is null' +
		N' AND    INSTITUTION    =  ''' + @pP30Partner + ''''
		
		print (@SQL);
	    EXEC(@SQL);


		FETCH NEXT
		FROM @myCur INTO @CenterID, @GrantNumber, @P30Partner
		
	END 
	CLOSE @myCur
	DEALLOCATE @myCur

END


-- manual process

 UPDATE basefund2010 SET    CenterID    =  27 ,      GrantNUmber =  21765 WHERE   INSTITUTION    like  'ST. JUDE CHILDREN% RESEARCH HOSPITAL';
 
 UPDATE basefund2010 SET    CenterID    =  27 ,      GrantNUmber =  21765 WHERE    INSTITUTION    like  'St Jude Children% Research Ho';

 UPDATE basefund2010 SET    CenterID    =  25 ,      GrantNUmber =  16520 WHERE     INSTITUTION    like  'CHILDREN% HOSPITAL OF PHILADELPHIA';

 UPDATE basefund2010 SET    CenterID    =  11 ,      GrantNUmber =  14089 WHERE    INSTITUTION    like  'CHILDREN% HOSPITAL LOS ANGELES';

  UPDATE basefund2010 SET    CenterID    =  1 ,      GrantNUmber =  6516 WHERE      INSTITUTION    like  'CHILDREN% HOSPITAL (BOSTON)';
  


select * from basefund2010
WHERE      INSTITUTION    like  '%(BOSTON)%';

where INSTITUTION    like  'CHILDREN% HOSPITAL LOS ANGELES';
WHERE   INSTITUTION    like  'ST. JUDE CHILDREN% RESEARCH HOSPITAL';