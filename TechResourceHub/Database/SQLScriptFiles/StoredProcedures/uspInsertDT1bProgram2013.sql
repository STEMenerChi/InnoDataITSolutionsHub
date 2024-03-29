USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspInsertDT1bProgram2013]    Script Date: 11/16/2015 2:50:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
    DATE			DESC
    10/26/2015      Created
	                If program has more than one leader, insert the 1st record in  DT1bProgram table, and insert 2nd+ into the MultiLeader table. 
					
    backup MultiLeader 
	select * 
	into MultiLeader2015Nov16
	from Multileader; 

select FY, count(*)
from dt1bProgram
group by fy
order by fy;

-- backup 
select * 
into dt1bProgram2015Oct26
from dt1bProgram;

select max(dt1bProgramID) from dt1bProgram;				
-- reset the Entity PK to the max ID
DBCC CHECKIDENT('[DT1BProgram]', RESEED, 1698);

--verification: 789 total from dt1bFY13,  1st 446 rows, 2nd+ rows = 343. 
select count(*) from DT1BFY13;

--verified  446 rows :-)
select * from DT1bProgram
where fy = 2013;
*/ 

ALTER PROCEDURE  [dbo].[uspInsertDT1bProgram2013]
AS
BEGIN

DECLARE @myCur			CURSOR, 
	    @FY             INT,
	    @GrantNumber    INT,
	    @CenterID       INT,			
		@DT1bID		INT,
		@LastName	NVARCHAR(25),
		@FirstName	NVARCHAR(25),
		@MiddleName	NVARCHAR(25),
		@Degree1	NVARCHAR(25),
		@Degree2	NVARCHAR(25),
		@Degree3	NVARCHAR(25),
		@isNew      Char(1),
		@Comments	NVARCHAR(255);


-- insert the 1st row into dt1bProgram
INSERT INTO [OCC].[dbo].[DT1BProgram]
           (FY
           ,[GrantNumber]
           ,CenterID
           ,[ReportingDate]
           ,[ProgName]
           ,[NoOfMembers]
           ,[MeritLevel]
           ,[ProgCode]
           ,[LastName]
           ,[FirstName]
           ,[Middlename]
           ,[Degree1]
           ,[Degree2]
           ,[Degree3]
           ,isMultiLeader
           ,isNew
           ,isNewProg
           ,isDevProg
		   ,comments)

SELECT FY
           ,[GrantNumber]
           ,CenterID
           ,[ReportingDate]
           ,[ProgName]
           ,[NoOfMember]
           ,[MeritLevel]
           ,[ProgCode]
           ,[LastName]
           ,[FirstName]
           ,[Middlename]
           ,[Degree1]
           ,[Degree2]
           ,[Degree3]
           ,isMultiLeader
           ,isNew
           ,isNewProg
           ,isDevProg
		   ,comments
FROM  
(SELECT     2013 AS FY
           ,d.GrantNumber 
           ,c.CenterID
           ,[ReportingDate]
           ,ProgName
           ,NoOfMember
           ,MeritLevel
           ,ProgCode
           ,LastName
           ,FirstName
           ,Middlename
           ,Degree1
           ,Degree2
           ,Degree3
           ,isMultiLeader
           ,isNew
           ,isNewProg
           ,isDevProg
		   ,d.Comments
		   ,ROW_NUMBER() OVER (partition by	d.grantnumber, progName order by d.grantnumber, progName) rowID
           from DT1BFY13 d, 
                center c
           where d.CenterID = c.CenterID) X
WHERE rowID = 1;


/*                  
--reset the entity PK/ID
select max(multileaderID) from multileader;
DBCC CHECKIDENT('MultiLeader', RESEED, 848);
*/
-- 2nd + rows which will be inserted into the MultiLeader table row by row.
SET @myCur = CURSOR FOR

SELECT  FY,GrantNumber,CenterID, DT1BProgramID,[LastName],[FirstName],[Middlename],[Degree1],[Degree2],[Degree3], isNew, Comments 
FROM 
(SELECT     2013 AS FY
           ,d.GrantNumber 
           ,d.CenterID
		   ,d2.DT1BProgramID
           ,d.LastName
           ,d.FirstName
           ,d.Middlename
           ,d.Degree1
           ,d.Degree2
           ,d.Degree3
           ,d.isNew
		   ,d.Comments
		   ,ROW_NUMBER() OVER (partition by	FY, d.grantnumber, d.progName  order by d.grantnumber, d.progName) rowID
           from DT1BFY13 d, 
		        DT1bProgram d2
		   WHERE d2.centerID = d.CenterID
		   AND   d2.ProgName = d.ProgName
		   AND   d2.fy = 2013) Y
WHERE rowID > 1; 

	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @FY, @GrantNumber, @CenterID, @DT1bID,   
			         @LastName, @FirstName,@MiddleName,@Degree1,@Degree2,@Degree3,	
					 @isNew, @Comments	
			
	WHILE @@FETCH_STATUS = 0
	BEGIN

			INSERT INTO [dbo].[MultiLeader]
			       (FY,GrantNumber,CenterID, DT1bID,[LastName],[FirstName],[Middlename],[Degree1],[Degree2],[Degree3], isNew, Comments)
            VALUES (@FY, @GrantNumber, @CenterID, @DT1bID, @LastName, @FirstName,@Middlename,@Degree1,@Degree2,@Degree3, @isNew, @Comments)

			FETCH NEXT
			FROM @myCur INTO @FY, @GrantNumber, @CenterID, @DT1bID,   
			                 @LastName, @FirstName,@MiddleName,@Degree1,@Degree2,@Degree3,	
					         @isNew, @Comments	
	END 
	CLOSE @myCur;
	DEALLOCATE @myCur;

  END

  /* verified
  select * from multileader where fy = 2013 and dt1bID is not null;
  -- 343 rows inserted :-)
  */
  
