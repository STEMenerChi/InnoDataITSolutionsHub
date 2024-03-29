USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspInsertMultiLeader4DT1dSR]    Script Date: 11/16/2015 2:25:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =====================================================================================================================
---Date			Dev			Desc
-- 11/16/2015	Chi         Created the SP 
--                          DT1bBFY14 may have more than 1 leader per SR, insert the first row into DT1bProgram, and the rest in MultiLeader (see uspInsertMultiLeader4DT1B)  
--  1. always perform the backup

    select *
	into MultiLeader2015Nov16
	from MultiLeader;


	Verification number of rows inserted: 365
	--2nd leader in Multileader = 328
	SELECT	count(*)
	FROM DT1BFY14 d, 
		 center c
	WHERE d.CenterID = c.CenterID
	AND   d.lastname2 is not null;

	--3rd leader in Multileader = 26
	SELECT	count(*)
	FROM DT1BFY14 d, 
		 center c
	WHERE d.CenterID = c.CenterID
	AND   d.lastname3 is not null;

    --4th leader in Multileader = 7
	SELECT	count(*)
	FROM DT1BFY14 d, 
		 center c
	WHERE d.CenterID = c.CenterID
	AND   d.lastname4 is not null;

    --5th leader in Multileader = 3 
	SELECT	count(*)
	FROM DT1BFY14 d, 
		 center c
	WHERE d.CenterID = c.CenterID
	AND   d.lastname5 is not null;

--reset the entity PK/ID
select max(multileaderID) from multileader;
DBCC CHECKIDENT('MultiLeader', RESEED, 1191);

select * from multiLeader
where fy = 2014;

-- =============================================*/

ALTER PROCEDURE  [dbo].[uspInsertMultiLeader4DT1B] 

AS
BEGIN
	
	DECLARE @myCur			CURSOR, 
	        @FY             INT,
	        @GrantNumber    INT,
	        @CenterID       INT,			
		    @DT1bProgramID	INT,
	

			@LastName2		NVARCHAR(25),
			@FirstName2		NVARCHAR(25),
			@MiddleName2	NVARCHAR(25),
			@Degree21		NVARCHAR(25),
			@Degree22		NVARCHAR(25),
			@Degree23		NVARCHAR(25), 
			@isNew2         Char(1),

			@LastName3		NVARCHAR(25),
			@FirstName3		NVARCHAR(25),
			@MiddleName3	NVARCHAR(25),
			@Degree31		NVARCHAR(25),
			@Degree32		NVARCHAR(25),
			@Degree33		NVARCHAR(25),
			@isNew3         Char(1),

			@LastName4		NVARCHAR(25),
			@FirstName4		NVARCHAR(25),
			@MiddleName4	NVARCHAR(25),
			@Degree41		NVARCHAR(25),
			@Degree42		NVARCHAR(25),
			@Degree43		NVARCHAR(25),
			@isNew4         Char(1),

			@LastName5		NVARCHAR(25),
			@FirstName5		NVARCHAR(25),
			@MiddleName5	NVARCHAR(25),
			@Degree51		NVARCHAR(25),
			@Degree52		NVARCHAR(25),
			@Degree53		NVARCHAR(25),
			@isNew5         Char(1)
	       

	 
	SET @myCur = CURSOR FOR

	SELECT 2014
       ,d.GrantNumber
       ,d.CenterID
       ,d.dT1bProgramID

      ,d2.[LastName2]
      ,d2.[FirstName2]
      ,d2.[MiddleName2]
      ,d2.[Degree21]
      ,d2.[Degree22]
      ,d2.[Degree23]

	  ,d2.[LastName3]
      ,d2.[FirstName3]
      ,d2.[MiddleName3]
      ,d2.[Degree31]
      ,d2.[Degree32]
      ,d2.[Degree33]

	  ,d2.[LastName4]
      ,d2.[FirstName4]
      ,d2.[MiddleName4]
      ,d2.[Degree41]
      ,d2.[Degree42]
      ,d2.[Degree43]

	  ,d2.[LastName5]
      ,d2.[FirstName5]
      ,d2.[MiddleName5]
      ,d2.[Degree51]
      ,d2.[Degree52]
      ,d2.[Degree53]

  FROM  dT1bProgram d, 
        dT1BFY14 d2
  WHERE d.CenterID = d2.CenterID
  AND   d.ProgCode = d2.ProgCode
  AND   d.ProgName = d2.ProgName
  AND   d.IsMultiLeader = 'Y'
  and   d.FY = 2014
  

	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @FY, @GrantNumber, @CenterID, @dT1bProgramID,       
			@LastName2, @FirstName2,@MiddleName2,@Degree21,@Degree22,@Degree23,		
			@LastName3, @FirstName3,@MiddleName3,@Degree31,@Degree32,@Degree33,		
			@LastName4,	@FirstName4,@MiddleName4,@Degree41,@Degree42,@Degree43,		
			@LastName5,	@FirstName5,@MiddleName5,@Degree51,@Degree52,@Degree53;	


	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		IF @LastName2 IS NOT NULL
		BEGIN
			INSERT INTO [dbo].[MultiLeader]
				(FY,GrantNumber,CenterID,DT1bID,[LastName],[FirstName],[Middlename],[Degree1],[Degree2],[Degree3])
			VALUES (2014, @GrantNumber,@CenterID,@DT1bProgramID,@LastName2,@FirstName2,@Middlename2,@Degree21,@Degree22,@Degree23);
		END

		IF @LastName3 IS NOT NULL
		BEGIN
			INSERT INTO [dbo].[MultiLeader]
				(FY,GrantNumber,CenterID,DT1bID,[LastName],[FirstName],[Middlename],[Degree1],[Degree2],[Degree3])
			VALUES (2014, @GrantNumber,@CenterID,@DT1bProgramID,@LastName3,@FirstName3,@Middlename3,@Degree31,@Degree32,@Degree33);
		END

		IF @LastName4 IS NOT NULL
		BEGIN
			INSERT INTO [dbo].[MultiLeader]
				(FY,GrantNumber,CenterID,DT1bID,[LastName],[FirstName],[Middlename],[Degree1],[Degree2],[Degree3])
			VALUES (2014, @GrantNumber,@CenterID,@DT1bProgramID,@LastName4,@FirstName4,@Middlename4,@Degree41,@Degree42,@Degree43);
		END

		IF @LastName5 IS NOT NULL
		BEGIN
			INSERT INTO [dbo].[MultiLeader]
				(FY,GrantNumber,CenterID,DT1bID,[LastName],[FirstName],[Middlename],[Degree1],[Degree2],[Degree3])
			VALUES (2014, @GrantNumber,@CenterID,@DT1bProgramID,@LastName5,@FirstName5,@Middlename5,@Degree51,@Degree52,@Degree53);
		END
		
		FETCH NEXT
		FROM @myCur 
		INTO @FY, @GrantNumber, @CenterID, @DT1bProgramID,       
			@LastName2, @FirstName2,@MiddleName2,@Degree21,@Degree22,@Degree23,		
			@LastName3, @FirstName3,@MiddleName3,@Degree31,@Degree32,@Degree33,		
			@LastName4,	@FirstName4,@MiddleName4,@Degree41,@Degree42,@Degree43,		
			@LastName5,	@FirstName5,@MiddleName5,@Degree51,@Degree52,@Degree53;		
		
	END 
	CLOSE @myCur;
	DEALLOCATE @myCur;

	/*


	SELECT	*
	FROM MultiLeader  
	where fy = 2014
	and dt1bID is not null;

	delete from multileader
	where multileaderID in (1561, 1548, 1545, 1543, 1533, 1535, 1537, 1539, 1541)

	*/
  END
