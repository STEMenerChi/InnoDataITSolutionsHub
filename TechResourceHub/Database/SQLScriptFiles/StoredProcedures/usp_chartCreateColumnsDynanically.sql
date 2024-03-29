USE [TMS3_1_CHI]
GO
/****** Object:  StoredProcedure [dbo].[usp_chartPerCustFYQTRDynamically]    Script Date: 11/01/2010 09:21:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================================
-- Date			Developer	Description		
-- 10/28/2010	C. Dinh		1. create table PerCustFYQTR with columns ID, FY, QTR
--                          2. create additonal columns bassed on the values in the @CUST_TYPE field
--                          4. Populate temporary table #tempCust with data from the query
--                          3. Manupulate the data in #tempCust and insert/update them into PerCustFYQTR.
-- Note: 
--    have to prefix the string literals with N to denote that they are Unicode strings. 
--    As @sql and @params are declared as nvarchar, technically this is not necessary 
--    (as long as you stick to your 8-bit character set). However, when you provide any of the strings 
--    directly in the call to sp_executesql, 
--    you must specify the N, as in this fairly silly example:
--    EXEC sp_executesql N'SELECT @x', N'@x int', @x = 2
--    If you remove any of the Ns, you will get an error message. Since sp_executesql is a built-in stored procedure, 
--    there is no implicit conversion from varchar.
--    Ref: http://www.sommarskog.se/dynamic_sql.html#Introducing
--
-- ===================================================================================
CREATE PROC [dbo].[usp_chartPerCustFYQTRDynamically]

AS
BEGIN

	SET NOCOUNT ON;

	CREATE TABLE PerCustFYQTR (ID int IDENTITY(1,1), FY int, QTR varchar(10))

	DECLARE @SQL NVARCHAR(MAX),
            @SQL2 NVARCHAR(MAX),
            @SQL3 NVARCHAR(MAX),
            @COL_NAME NVARCHAR(15), 
            @CUST_TYPE VARCHAR(15),
            @I INT,
		    @numRows int, 
            @counter int, 
            @fy nvarchar(10),
            @qtr varchar(15),
            @col varchar(15)
  
    /*  select the data into #tempCust */
    SELECT C.DESCRIPTION AS CUST_TYPE, COUNT(T.TMS_ID) as TASK_COUNT, 
		  -- Determine which FY year 
		  CASE 
				WHEN MONTH(T.CREATED_DATE) BETWEEN 10 AND 12 THEN YEAR(T.CREATED_DATE) + 1 
				ELSE YEAR(T.CREATED_DATE)
		  END AS FY,
	      -- Determine  FY Quarters     
		  CASE 
				WHEN MONTH(T.CREATED_DATE) BETWEEN 10 AND 12 THEN '1st'
				WHEN MONTH(T.CREATED_DATE) BETWEEN 1 AND 3 THEN   '2nd'
				WHEN MONTH(T.CREATED_DATE) BETWEEN 4 AND 6 THEN   '3rd'
				WHEN MONTH(T.CREATED_DATE) BETWEEN 7 AND 9 THEN   '4th'
				ELSE 'ERROR'
		  END AS QTR
	INTO #tempCust	  
	FROM   TASK T,
		   CUSTOMER C
	WHERE T.CUSTOMER_ID = C.CUSTOMER_ID
	AND T.CREATED_DATE IS NOT NULL
	GROUP BY  
          C.DESCRIPTION,
		  CASE 
				WHEN MONTH(T.CREATED_DATE) BETWEEN 10 AND 12 THEN  '1st'
				WHEN MONTH(T.CREATED_DATE) BETWEEN 1 AND 3 THEN   '2nd'
				WHEN MONTH(T.CREATED_DATE) BETWEEN 4 AND 6 THEN   '3rd'
				WHEN MONTH(T.CREATED_DATE) BETWEEN 7 AND 9 THEN   '4th'
				ELSE 'ERROR'
		  END, 
		  CASE 
				WHEN MONTH(T.CREATED_DATE) BETWEEN 10 AND 12 THEN YEAR(T.CREATED_DATE) + 1 
				ELSE  YEAR(T.CREATED_DATE)  
		  END
    ORDER BY QTR, FY;
    -- select * from #tempCust

	DECLARE custCursor CURSOR
	FOR SELECT [description] FROM Customer WHERE parent_id IS NULL;
    OPEN custCursor
    FETCH NEXT FROM custCursor INTO @CUST_TYPE   
    WHILE @@FETCH_STATUS = 0   
	BEGIN
		 SET @COL_NAME = @CUST_TYPE
         --dynamically create columns based on the value in @CUST_TYPE
		 SELECT @SQL = N'ALTER TABLE PerCustFYQTR ADD ' + @COL_NAME + N' INT '
		 PRINT  @SQL  -- debug
		 EXEC sp_executesql @SQL

		 FETCH NEXT FROM custCursor INTO @CUST_TYPE   
	END

	
		/* select specific column names from the newly created table   */
	    SET @counter = 1
		DECLARE  colCursor CURSOR FOR
		SELECT column_name FROM information_schema.columns WHERE table_name = 'PerCustFYQTR' AND column_name NOT IN ( 'ID', 'FY', 'QTR');
		OPEN colCursor
		FETCH NEXT FROM colCursor INTO @COL_NAME   
		WHILE @@FETCH_STATUS = 0   
	    BEGIN

            print @COL_NAME -- debug
			--update one cust_type at a time
                                                               
            SELECT @SQL2 = N'DECLARE myCursor CURSOR FOR SELECT task_count, fy, qtr FROM #tempCust WHERE CUST_TYPE = '''  +  @COL_NAME  + ''''
            PRINT @SQL2 -- debug
			EXEC sp_executesql @SQL2
			OPEN myCursor
			FETCH NEXT FROM myCursor INTO @col, @fy, @qtr
			WHILE @@fetch_Status = 0 
		    BEGIN 
				IF (@counter = 1) -- first counter do insert
				BEGIN 
					SELECT @SQL3 = N'INSERT INTO PerCustFYQTR (' + @COL_NAME + ', FY, QTR)  VALUES (' + @col + N',' + @fy + N',''' + @qtr + N''')' 
					PRINT @SQL3 --debug
					EXEC sp_executesql @SQL3
				END
                ELSE -- next counter do update
				BEGIN
					SELECT @SQL3 = N'UPDATE PerCustFYQTR SET ' + @COL_NAME + N' = ' + @col + N', FY = ' + @fy + N', QTR = ' +  N'''' + @qtr + N''' WHERE QTR = ' + N'''' + @qtr + N'''' 
					PRINT @SQL3 --debug
					EXEC sp_executesql @SQL3
				END 
				FETCH NEXT FROM myCursor INTO @col, @fy, @qtr
		    
            END
			CLOSE myCursor
			DEALLOCATE myCursor
            FETCH NEXT FROM colCursor INTO @COL_NAME
            SET @counter = @counter + 1  
		END	
        
    /* closer cursors */
    CLOSE custCursor
	DEALLOCATE custCursor
    CLOSE colCursor
	DEALLOCATE colCursor
	SET NOCOUNT OFF

END
