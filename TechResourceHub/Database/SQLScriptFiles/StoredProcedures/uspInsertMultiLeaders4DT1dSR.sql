
/*
  DATE			DESC
  10/22/2015    Created
                Insert into MultiLeader table for each of the DT1dSR that has more than two or more PIs.
     
*/

USE [OCC]
GO

/* reset the entity PK/ID
select max(multileaderID) from multileader;

DBCC CHECKIDENT('MultiLeader', RESEED, 848);
*/

------------------------------------------------------dt1dSR  run the Insert stmt then execute the uspUpdateMultiLeaderFK sp-------------------------------------------------------
--------------------For LastName2
ALTER PROCEDURE  [dbo].[uspInsertMultiLeader4DT1dSR] 

AS
BEGIN
	
	DECLARE @myCur			CURSOR, 
	        @FY             INT,
	        @GrantNumber    INT,
	        @CenterID       INT,			
		    @DT1dSRID		INT,
		    @SRName			NVARCHAR(255),
		    @SubCat1        FLOAT,

			@LastName2		NVARCHAR(25),
			@FirstName2		NVARCHAR(25),
			@MiddleName2	NVARCHAR(25),
			@Degree21		NVARCHAR(25),
			@Degree22		NVARCHAR(25),
			@Degree23		NVARCHAR(25),

			@LastName3		NVARCHAR(25),
			@FirstName3		NVARCHAR(25),
			@MiddleName3	NVARCHAR(25),
			@Degree31		NVARCHAR(25),
			@Degree32		NVARCHAR(25),
			@Degree33		NVARCHAR(25),

			@LastName4		NVARCHAR(25),
			@FirstName4		NVARCHAR(25),
			@MiddleName4	NVARCHAR(25),
			@Degree41		NVARCHAR(25),
			@Degree42		NVARCHAR(25),
			@Degree43		NVARCHAR(25),

			@LastName5		NVARCHAR(25),
			@FirstName5		NVARCHAR(25),
			@MiddleName5	NVARCHAR(25),
			@Degree51		NVARCHAR(25),
			@Degree52		NVARCHAR(25),
			@Degree53		NVARCHAR(25),

			@LastName6		NVARCHAR(25),
			@FirstName6		NVARCHAR(25),
			@MiddleName6	NVARCHAR(25),
			@Degree61		NVARCHAR(25),
			@Degree62		NVARCHAR(25),
			@Degree63		NVARCHAR(25);
	       

	 
	SET @myCur = CURSOR FOR
	SELECT 2014
       ,d.GrantNumber
       ,d.CenterID
       ,d.DT1dSRID
	   ,d.SRName
	   ,d2.SubCat1   

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

	  ,d2.[LastName6]
      ,d2.[FirstName6]
      ,d2.[MiddleName6]
      ,d2.[Degree61]
      ,d2.[Degree62]
      ,d2.[Degree63]
    
  FROM  dT1dSR d, 
        dT1dFY14 d2
  WHERE d.GrantNumber = d2.grantNumber
  AND   d.SRName = d2.SRName
  ANd   d.SubCat1 = d2.SubCat1
  AND   d.IsMultiDirector = 'Y'
  and   d.FY = 2014
  

	OPEN @myCur
	FETCH NEXT
	FROM @myCur INTO @FY, @GrantNumber, @CenterID, @DT1dSRID, @SRName, @SubCat1,       
			@LastName2, @FirstName2,@MiddleName2,@Degree21,@Degree22,@Degree23,		
			@LastName3, @FirstName3,@MiddleName3,@Degree31,@Degree32,@Degree33,		
			@LastName4,	@FirstName4,@MiddleName4,@Degree41,@Degree42,@Degree43,		
			@LastName5,	@FirstName5,@MiddleName5,@Degree51,@Degree52,@Degree53,		
			@LastName6,	@FirstName6,@MiddleName6,@Degree61,@Degree62,@Degree63;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		IF @LastName2 IS NOT NULL
		BEGIN
			INSERT INTO [dbo].[MultiLeader]
				(FY,GrantNumber,CenterID,[DT1DSRID],SRName,SubCat1,[LastName],[FirstName],[Middlename],[Degree1],[Degree2],[Degree3])
			VALUES (2014, @GrantNumber,@CenterID,@DT1DSRID,@SRName,@SubCat1,@LastName2,@FirstName2,@Middlename2,@Degree21,@Degree22,@Degree23);
		END

		IF @LastName3 IS NOT NULL
		BEGIN
			INSERT INTO [dbo].[MultiLeader]
				(FY,GrantNumber,CenterID,[DT1DSRID],SRName,SubCat1,[LastName],[FirstName],[Middlename],[Degree1],[Degree2],[Degree3])
			VALUES (2014, @GrantNumber,@CenterID,@DT1DSRID,@SRName,@SubCat1,@LastName3,@FirstName3,@Middlename3,@Degree31,@Degree32,@Degree33);
		END

		IF @LastName4 IS NOT NULL
		BEGIN
			INSERT INTO [dbo].[MultiLeader]
				(FY,GrantNumber,CenterID,[DT1DSRID],SRName,SubCat1,[LastName],[FirstName],[Middlename],[Degree1],[Degree2],[Degree3])
			VALUES (2014, @GrantNumber,@CenterID,@DT1DSRID,@SRName,@SubCat1,@LastName4,@FirstName4,@Middlename4,@Degree41,@Degree42,@Degree43);
		END

		IF @LastName5 IS NOT NULL
		BEGIN
			INSERT INTO [dbo].[MultiLeader]
				(FY,GrantNumber,CenterID,[DT1DSRID],SRName,SubCat1,[LastName],[FirstName],[Middlename],[Degree1],[Degree2],[Degree3])
			VALUES (2014, @GrantNumber,@CenterID,@DT1DSRID,@SRName,@SubCat1,@LastName5,@FirstName5,@Middlename5,@Degree51,@Degree52,@Degree53);
		END

		
		IF @LastName6 IS NOT NULL
		BEGIN
			INSERT INTO [dbo].[MultiLeader]
				(FY,GrantNumber,CenterID,[DT1DSRID],SRName,SubCat1,[LastName],[FirstName],[Middlename],[Degree1],[Degree2],[Degree3])
			VALUES (2014, @GrantNumber,@CenterID,@DT1DSRID,@SRName,@SubCat1,@LastName6,@FirstName6,@Middlename6,@Degree61,@Degree62,@Degree63);
		END
		

		FETCH NEXT
		FROM @myCur 
		INTO @FY, @GrantNumber, @CenterID, @DT1dSRID, @SRName, @SubCat1,       
			@LastName2, @FirstName2,@MiddleName2,@Degree21,@Degree22,@Degree23,		
			@LastName3, @FirstName3,@MiddleName3,@Degree31,@Degree32,@Degree33,		
			@LastName4,	@FirstName4,@MiddleName4,@Degree41,@Degree42,@Degree43,		
			@LastName5,	@FirstName5,@MiddleName5,@Degree51,@Degree52,@Degree53,		
			@LastName6,	@FirstName6,@MiddleName6,@Degree61,@Degree62,@Degree63;
		
	END 
	CLOSE @myCur;
	DEALLOCATE @myCur;

  END
