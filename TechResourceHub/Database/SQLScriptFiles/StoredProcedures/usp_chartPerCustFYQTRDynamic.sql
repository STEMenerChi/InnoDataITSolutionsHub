USE [TMS]
GO
/****** Object:  StoredProcedure [dbo].[usp_chartPerCustFYQTRDynamic]    Script Date: 12/06/2010 16:42:59 ******/
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
ALTER PROC [dbo].[usp_chartPerCustFYQTRDynamic]
( 
	@inputFY VARCHAR(50)
)

AS
BEGIN

	SET NOCOUNT ON;

    IF NOT EXISTS (select * from dbo.sysobjects where id = object_id(N'ChartPerCustFYQTR') and type = 'U')
     	CREATE TABLE ChartPerCustFYQTR (ID int IDENTITY(1,1), FY int, QTR varchar(50));
    ELSE 
        BEGIN
			DROP TABLE ChartPerCustFYQTR;
			CREATE TABLE ChartPerCustFYQTR (ID int IDENTITY(1,1), FY int, QTR varchar(50));
        END 

	DECLARE @SQL NVARCHAR(MAX),
            @SQL2 NVARCHAR(MAX),
            @SQL3 NVARCHAR(MAX),
            @SQL4 NVARCHAR(MAX),
            @COL_NAME NVARCHAR(15), 
            @CUST_TYPE VARCHAR(15),
            @I INT,
		    @numRows int, 
            @counter int, 
            @fy nvarchar(10),
            @qtr varchar(50),
            @col varchar(15)
  
   

--    IF EXISTS (select * from dbo.sysobjects where id = object_id(N'tempdb.dbo.##tempCust') )
--       DROP TABLE ##tempCust;
		IF OBJECT_ID('tempdb..##tempCust') IS NOT NULL
		BEGIN
			DROP TABLE ##tempCust
		END




	 /*  select the data into ##tempCust */

    SET @SQL4 = 
    'SELECT C.DESCRIPTION AS CUST_TYPE, COUNT(T.TMS_ID) as TASK_COUNT, 
		  CASE 
				WHEN MONTH(T.CREATED_DATE) BETWEEN 10 AND 12 THEN SUBSTRING(CAST(YEAR(T.CREATED_DATE) + 1 AS VARCHAR(4)), 3, 2)
				ELSE SUBSTRING(CAST(YEAR(T.CREATED_DATE) AS VARCHAR(4)), 3,2)
		  END AS FY,
	     
		 CASE 
				WHEN MONTH(T.CREATED_DATE) BETWEEN 10 AND 12 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.CREATED_DATE) + 1 AS VARCHAR), 3,2) + ' + N''' 1st QTR <br>(1 OCT - 31 DEC)''' +
				N'WHEN MONTH(T.CREATED_DATE) BETWEEN 1 AND 3 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.CREATED_DATE) AS VARCHAR), 3,2) + ' + N''' 2nd QTR <br>(1 JAN - 31 MAR)''' +
				N'WHEN MONTH(T.CREATED_DATE) BETWEEN 4 AND 6 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.CREATED_DATE) AS VARCHAR), 3,2) + ' + N''' 3rd QTR <br>(1 APR - 30 JUN)''' +
				N'WHEN MONTH(T.CREATED_DATE) BETWEEN 7 AND 9 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.CREATED_DATE) AS VARCHAR), 3,2) + ' + N''' 4th QTR <br>(1 JUL - 30 SEP)''' +
				N'ELSE ''' + N'ERROR'''+
		  N'END AS QTR 
		 
	INTO ##tempCust	  
	FROM   TASK T,
		   CUSTOMER C
	WHERE dbo.uf_GetFiscalYear(T.CREATED_DATE) IN (' + @inputFY + ')
    AND T.CUSTOMER_ID = C.CUSTOMER_ID
	AND T.CREATED_DATE IS NOT NULL
	GROUP BY  
          C.DESCRIPTION,
		  CASE 
				WHEN MONTH(T.CREATED_DATE) BETWEEN 10 AND 12 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.CREATED_DATE) + 1 AS VARCHAR), 3,2) +' + N''' 1st QTR <br>(1 OCT - 31 DEC)''' +
				N'WHEN MONTH(T.CREATED_DATE) BETWEEN 1 AND 3 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.CREATED_DATE) AS VARCHAR), 3,2) + ' + N''' 2nd QTR <br>(1 JAN - 31 MAR)''' +
				N'WHEN MONTH(T.CREATED_DATE) BETWEEN 4 AND 6 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.CREATED_DATE) AS VARCHAR), 3,2) + ' + N''' 3rd QTR <br>(1 APR - 30 JUN)''' +
				N'WHEN MONTH(T.CREATED_DATE) BETWEEN 7 AND 9 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.CREATED_DATE) AS VARCHAR), 3,2) + ' + N''' 4th QTR <br>(1 JUL - 30 SEP)''' +
				N'ELSE ''' + N'ERROR''' +
		  N'END, 
		  CASE 
				WHEN MONTH(T.CREATED_DATE) BETWEEN 10 AND 12 THEN SUBSTRING(CAST(YEAR(T.CREATED_DATE) + 1 AS VARCHAR(4)), 3,2)
				ELSE SUBSTRING(CAST(YEAR(T.CREATED_DATE) AS VARCHAR(4)), 3,2)
		  END
    ORDER BY QTR, FY;'

	EXECUTE (@SQL4);

    -- select * from ##tempCust

	DECLARE custCursor CURSOR
	FOR SELECT [description] FROM Customer WHERE parent_id IS NULL;
    OPEN custCursor
    FETCH NEXT FROM custCursor INTO @CUST_TYPE   
    WHILE @@FETCH_STATUS = 0   
	BEGIN
		 SET @COL_NAME = @CUST_TYPE
         --dynamically create columns based on the value in @CUST_TYPE
		 SELECT @SQL = N'ALTER TABLE ChartPerCustFYQTR ADD ' + @COL_NAME + N' INT '
		 PRINT  @SQL  -- debug
		 EXEC sp_executesql @SQL

		 FETCH NEXT FROM custCursor INTO @CUST_TYPE   
	END

	
		/* select specific column names from the newly created table   */
	    SET @counter = 1
		DECLARE  colCursor CURSOR FOR
		SELECT column_name FROM information_schema.columns WHERE table_name = 'ChartPerCustFYQTR' AND column_name NOT IN ( 'ID', 'FY', 'QTR');
		OPEN colCursor
		FETCH NEXT FROM colCursor INTO @COL_NAME   
		WHILE @@FETCH_STATUS = 0   
	    BEGIN

            print @COL_NAME -- debug
			--update one cust_type at a time
                                                               
            SELECT @SQL2 = N'DECLARE myCursor CURSOR FOR SELECT task_count, fy, qtr FROM ##tempCust WHERE CUST_TYPE = '''  +  @COL_NAME  + ''''
            PRINT @SQL2 -- debug
			EXEC sp_executesql @SQL2
			OPEN myCursor
			FETCH NEXT FROM myCursor INTO @col, @fy, @qtr
			WHILE @@fetch_Status = 0 
		    BEGIN 
				IF (@counter = 1) -- first counter do insert
				BEGIN 
					SELECT @SQL3 = N'INSERT INTO ChartPerCustFYQTR (' + @COL_NAME + ', FY, QTR)  VALUES (' + @col + N',' + @fy + N',''' + @qtr + N''')' 
					PRINT @SQL3 --debug
					EXEC sp_executesql @SQL3
				END
                ELSE -- next counter do update
				BEGIN
					SELECT @SQL3 = N'UPDATE ChartPerCustFYQTR SET ' + @COL_NAME + N' = ' + @col + N', FY = ' + @fy + N', QTR = ' +  N'''' + @qtr + N''' WHERE QTR = ' + N'''' + @qtr + N'''' 
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
