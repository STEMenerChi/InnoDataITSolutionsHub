USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspUpdateBaseFund]    Script Date: 11/5/2019 3:15:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =============================================
   StoredProcedure: uspUpdateDT1Program

   Date              Programmer			Desc
   11/05/2019        Chi Dinh			Update the 2nd to 5th names & degrees in DT1Bprogram based on grantNumber, FY, and progName.
                                        will update this table w/ MultiLeader data (and eliminate MultiLeaders table)



 Note1: The SQL Server ISNULL() function lets you return an alternative value when an expression is NULL: 
        If the returned value is NULL, then assign NULL to the column name. 

 Note2: The number of variables declared in teh INTO list must match that of selected columns; hence the @columnCount and if statement. 

 Note3: use the print statement for debug purposes only - this way we can see the display of the SQL statement when we execute the stored procedure.

 Note2: NVARCHAR stores UNICODE data, VARCHAR stores ASCII data.  
        UNICODE is a superset of ASCII. 
        NVARCHAR allows software to be localized much more easily, since new translations will not require a new encoding. 
		UTF-8 is an efficient encoding for storing and transmitting Unicode characters. 

 CTE: the common table expression (CTE) is a temporary named result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement. 

   ref: https://www.codeproject.com/Articles/489617/CreateplusaplusCursorplususingplusDynamicplusSQLpl	
        dynamicquery with unknown number of columns in the cursor: https://stackoverflow.com/questions/29204699/sql-server-unable-to-run-cursor-fetch-statement-dynamically-stored-in-variable


	backup: select * into DT1BProgamTemp  from DT1BProgram;	
	verifying process:
	select * from dt1bprogram 
	where  grantnumber = 91842
	and    FY = 2015;


-- ============================================= */
 

ALTER PROCEDURE  [dbo].uspUpdateDT1Program (@ImportedTableName AS VARCHAR(255)) 

AS
BEGIN
	
	DECLARE 
	       

	        @GrantNumber	 INT,
	        @FY              INT,
	        @ProgName        VARCHAR(255) = NULL, 
			@LastName2       VARCHAR(50) = NULL,
			@FirstName2      VARCHAR(50) = NULL,
			@MiddleName2     VARCHAR(50) = NULL,
			@Degree21        VARCHAR(50) = NULL,
			@Degree22        VARCHAR(50) = NULL,
			@Degree23        VARCHAR(50) = NULL, 

			@LastName3       VARCHAR(50) = NULL, 
			@FirstName3      VARCHAR(50) = NULL,
			@MiddleName3     VARCHAR(50) = NULL,
			@Degree31        VARCHAR(50) = NULL,
			@Degree32        VARCHAR(50) = NULL,
			@Degree33        VARCHAR(50) = NULL, 

			@LastName4       VARCHAR(50)  = NULL,
			@FirstName4      VARCHAR(50) = NULL,
			@MiddleName4     VARCHAR(50) = NULL,
			@Degree41        VARCHAR(50) = NULL,
			@Degree42        VARCHAR(50) = NULL,
			@Degree43        VARCHAR(50) = NULL, 

			@LastName5       VARCHAR(50) = NULL,
			@FirstName5      VARCHAR(50) = NULL,
			@MiddleName5     VARCHAR(50) = NULL,
			@Degree51        VARCHAR(50) = NULL,
			@Degree52        VARCHAR(50) = NULL,
			@Degree53        VARCHAR(50) = NULL,

			@sql NVARCHAR(MAX), 
			@sql2 NVARCHAR(MAX),
			@myCursor   CURSOR, 
			@mainCursor CURSOR,
			@columnCount INT;

			--count the number of columns in a table. If 31 then lastname3, 37 has lastname4, 44 has lastname5
			SELECT @columnCount = COUNT(*) FROM  INFORMATION_SCHEMA.COLUMNS where table_name = @importedTableName; 
			Print @columnCount

			IF (@columnCount > 40) 
			BEGIN
				SET  @sql = 'SELECT FY, GrantNumber, Progname, 
	                  LastName2, FirstName2, MiddleName2, Degree21, Degree22, Degree23, 
					  LastName3, FirstName3, MiddleName3, Degree31, Degree32, Degree33, 
					  LastName4, FirstName4, MiddleName4, Degree41, Degree42, Degree43, 
					  LastName5, FirstName5, MiddleName5, Degree51, Degree52, Degree53 FROM ' + QUOTENAME(@importedTableName)
		    END
			ELSE IF @columnCount BETWEEN 35 AND 40 
			BEGIN
				SET  @sql = 'SELECT FY, GrantNumber, Progname, 
	                  LastName2, FirstName2, MiddleName2, Degree21, Degree22, Degree23, 
					  LastName3, FirstName3, MiddleName3, Degree31, Degree32, Degree33, 
					  LastName4, FirstName4, MiddleName4, Degree41, Degree42, Degree43 FROM ' + QUOTENAME(@importedTableName)
			END
			ELSE  
			BEGIN
				SET  @sql = 'SELECT FY, GrantNumber, Progname, 
	                  LastName2, FirstName2, MiddleName2, Degree21, Degree22, Degree23, 
					  LastName3, FirstName3, MiddleName3, Degree31, Degree32, Degree33  FROM ' + QUOTENAME(@importedTableName)
			END	
			--debug puroses
			PRINT(@sql);

			SET  @sql2 = 'SET @myCursor = CURSOR FORWARD_ONLY FOR ' + @sql + ' OPEN @myCursor'
			print (@sql2);
        
	EXEC sys.sp_executesql @sql2
	,N'@myCursor CURSOR OUTPUT'
	,@mainCursor OUTPUT

	IF 	@columnCount > 40 
	BEGIN
		FETCH NEXT
		FROM @mainCursor INTO  @FY, @GrantNumber, @Progname, 
	                  @LastName2, @FirstName2, @MiddleName2, @Degree21, @Degree22, @Degree23, 
					  @LastName3, @FirstName3, @MiddleName3, @Degree31, @Degree32, @Degree33, 
					  @LastName4, @FirstName4, @MiddleName4, @Degree41, @Degree42, @Degree43, 
					  @LastName5, @FirstName5, @MiddleName5, @Degree51, @Degree52, @Degree53
	END
	ELSE IF @columnCount BETWEEN 35 AND 40 
	BEGIN
		FETCH NEXT
		FROM @mainCursor INTO  @FY, @GrantNumber, @Progname, 
	                  @LastName2, @FirstName2, @MiddleName2, @Degree21, @Degree22, @Degree23, 
					  @LastName3, @FirstName3, @MiddleName3, @Degree31, @Degree32, @Degree33, 
					  @LastName4, @FirstName4, @MiddleName4, @Degree41, @Degree42, @Degree43 
					 
	END
	ELSE
	BEGIN
		FETCH NEXT
		FROM @mainCursor INTO  @FY, @GrantNumber, @Progname, 
	                  @LastName2, @FirstName2, @MiddleName2, @Degree21, @Degree22, @Degree23, 
					  @LastName3, @FirstName3, @MiddleName3, @Degree31, @Degree32, @Degree33 
				
	END

	WHILE @@FETCH_STATUS = 0
	BEGIN	
	    UPDATE DT1BProgram
	    SET    LastName2    = @LastName2,
	           FirstName2   = @FirstName2,
			   MiddleName2  = @Middlename2,
			   Degree21     = @Degree21,
			   Degree22     = @Degree22,
			   Degree23     = @Degree23,

			   LastName3    = @LastName3,
	           FirstName3   = @FirstName3,
			   MiddleName3  = @Middlename3,
			   Degree31     = @Degree31,
			   Degree32     = @Degree32,
			   Degree33     = @Degree33,

			   LastName4    = @LastName4,
	           FirstName4   = @FirstName4,
			   MiddleName4  = @Middlename4,
			   Degree41     = @Degree41,
			   Degree42     = @Degree42,
			   Degree43     = @Degree43,

			   LastName5    = @LastName5,
	           FirstName5   = @FirstName5,
			   MiddleName5  = @Middlename5,
			   Degree51     = @Degree51,
			   Degree52     = @Degree52,
			   Degree53     = @Degree53
	    WHERE  FY = @FY
		AND    GrantNumber = @GrantNumber
		AND    Progname    = @ProgName;

		IF 	@columnCount > 40 
		BEGIN
			FETCH NEXT
			FROM @mainCursor INTO  @FY, @GrantNumber, @Progname, 
					  @LastName2, @FirstName2, @MiddleName2, @Degree21, @Degree22, @Degree23, 
					  @LastName3, @FirstName3, @MiddleName3, @Degree31, @Degree32, @Degree33, 
					  @LastName4, @FirstName4, @MiddleName4, @Degree41, @Degree42, @Degree43, 
					  @LastName5, @FirstName5, @MiddleName5, @Degree51, @Degree52, @Degree53
		END
		ELSE IF @columnCount BETWEEN 35 AND 40 
		BEGIN
			FETCH NEXT
			FROM @mainCursor INTO  @FY, @GrantNumber, @Progname, 
						  @LastName2, @FirstName2, @MiddleName2, @Degree21, @Degree22, @Degree23, 
						  @LastName3, @FirstName3, @MiddleName3, @Degree31, @Degree32, @Degree33, 
						  @LastName4, @FirstName4, @MiddleName4, @Degree41, @Degree42, @Degree43 
					 
		END
		ELSE
		BEGIN
			FETCH NEXT
			FROM @mainCursor INTO  @FY, @GrantNumber, @Progname, 
						  @LastName2, @FirstName2, @MiddleName2, @Degree21, @Degree22, @Degree23, 
						  @LastName3, @FirstName3, @MiddleName3, @Degree31, @Degree32, @Degree33 
				
		END
		
	END 
	CLOSE @myCursor;
	DEALLOCATE @myCursor;
	CLOSE @mainCursor;
	DEALLOCATE @mainCursor;
END
