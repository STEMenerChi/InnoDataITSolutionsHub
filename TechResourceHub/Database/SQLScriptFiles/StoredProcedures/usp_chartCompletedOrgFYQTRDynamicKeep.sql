USE [TMS3_1_CHI]
GO
/****** Object:  StoredProcedure [dbo].[usp_chartCompletedOrgFYQTRDynamic]    Script Date: 12/20/2010 11:02:06 ******/
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
ALTER PROC [dbo].[usp_chartCompletedOrgFYQTRDynamic]


AS
BEGIN

	SET NOCOUNT ON;

    IF NOT EXISTS (select * from dbo.sysobjects where id = object_id(N'ChartOrgFYQTR') and type = 'U')
     	CREATE TABLE ChartOrgFYQTR (ID int IDENTITY(1,1), FY int, QTR varchar(50));
    ELSE 
        BEGIN
			DROP TABLE ChartOrgFYQTR;
			CREATE TABLE ChartOrgFYQTR (ID int IDENTITY(1,1), FY int, QTR varchar(50));
        END 

	DECLARE @SQL NVARCHAR(MAX),
            @SQL2 NVARCHAR(MAX),
            @SQL3 NVARCHAR(MAX),
            @SQL4 NVARCHAR(MAX),
            @COL_NAME NVARCHAR(15), 
            @ORG VARCHAR(15),
            @I INT,
		    @numRows int, 
            @counter int, 
            @fy nvarchar(10),
            @qtr varchar(50),
            @col varchar(15)
  
    IF OBJECT_ID('tempdb..##tempTable') IS NOT NULL
		BEGIN
			DROP TABLE ##tempTable
		END

    /*  select the data into ##tempTable */
    SET @SQL4 = 
    'SELECT ORG, TASK_COUNT, FY, QTR INTO ##tempTable  FROM 
     (SELECT T.ASSIGNED_TO_ORG AS ORG, COUNT(T.TMS_ID) as TASK_COUNT, 
		  CASE 
				WHEN MONTH(T.COMPLETED_DATE) BETWEEN 10 AND 12 THEN SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) + 1 AS VARCHAR(4)), 3, 2)
				ELSE SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR(4)), 3,2)
		  END AS FY,
	     
		  CASE 
				WHEN MONTH(T.COMPLETED_DATE) BETWEEN 10 AND 12 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) + 1 AS VARCHAR), 3,2) + ' + N''' 1st QTR <br>(1 OCT - 31 DEC)''' +
				N'WHEN MONTH(T.COMPLETED_DATE) BETWEEN 1 AND 3 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR), 3,2) + ' + N''' 2nd QTR <br>(1 JAN - 31 MAR)''' +
				N'WHEN MONTH(T.COMPLETED_DATE) BETWEEN 4 AND 6 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR), 3,2) + ' + N''' 3rd QTR <br>(1 APR - 30 JUN)''' +
				N'WHEN MONTH(T.COMPLETED_DATE) BETWEEN 7 AND 9 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR), 3,2) + ' + N''' 4th QTR <br>(1 JUL - 30 SEP)''' +
				N'ELSE ''' + N'ERROR'''+
		   N'END AS QTR 
	FROM  TASK T
	WHERE T.ASSIGNED_TO_ORG IS NOT NULL
    AND   T.COMPLETED_DATE IS NOT NULL
    AND   T.STATUS_ID = 5
	GROUP BY  
          T.ASSIGNED_TO_ORG,
		  CASE 
				WHEN MONTH(T.COMPLETED_DATE) BETWEEN 10 AND 12 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) + 1 AS VARCHAR), 3,2) +' + N''' 1st QTR <br>(1 OCT - 31 DEC)''' +
				N'WHEN MONTH(T.COMPLETED_DATE) BETWEEN 1 AND 3 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR), 3,2) + ' + N''' 2nd QTR <br>(1 JAN - 31 MAR)''' +
				N'WHEN MONTH(T.COMPLETED_DATE) BETWEEN 4 AND 6 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR), 3,2) + ' + N''' 3rd QTR <br>(1 APR - 30 JUN)''' +
				N'WHEN MONTH(T.COMPLETED_DATE) BETWEEN 7 AND 9 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR), 3,2) + ' + N''' 4th QTR <br>(1 JUL - 30 SEP)''' +
				N'ELSE ''' + N'ERROR''' +
		  N'END, 
		  CASE 
				WHEN MONTH(T.COMPLETED_DATE) BETWEEN 10 AND 12 THEN SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) + 1 AS VARCHAR(4)), 3,2)
				ELSE SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR(4)), 3,2)
		  END

     UNION ALL

	 SELECT T.CUSTOMER_POC AS ORG, COUNT(T.TMS_ID) as TASK_COUNT, 
		  CASE 
				WHEN MONTH(T.COMPLETED_DATE) BETWEEN 10 AND 12 THEN SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) + 1 AS VARCHAR(4)), 3, 2)
				ELSE SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR(4)), 3,2)
		  END AS FY,
	     
		  CASE 
				WHEN MONTH(T.COMPLETED_DATE) BETWEEN 10 AND 12 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) + 1 AS VARCHAR), 3,2) + ' + N''' 1st QTR <br>(1 OCT - 31 DEC)''' +
				N'WHEN MONTH(T.COMPLETED_DATE) BETWEEN 1 AND 3 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR), 3,2) + ' + N''' 2nd QTR <br>(1 JAN - 31 MAR)''' +
				N'WHEN MONTH(T.COMPLETED_DATE) BETWEEN 4 AND 6 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR), 3,2) + ' + N''' 3rd QTR <br>(1 APR - 30 JUN)''' +
				N'WHEN MONTH(T.COMPLETED_DATE) BETWEEN 7 AND 9 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR), 3,2) + ' + N''' 4th QTR <br>(1 JUL - 30 SEP)''' +
				N'ELSE ''' + N'ERROR'''+
		   N'END AS QTR 
	FROM  TASK T
	WHERE T.CUSTOMER_POC IS NOT NULL
    AND   T.COMPLETED_DATE IS NOT NULL
    AND   T.STATUS_ID = 5
	GROUP BY  
          T.CUSTOMER_POC,
		  CASE 
				WHEN MONTH(T.COMPLETED_DATE) BETWEEN 10 AND 12 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) + 1 AS VARCHAR), 3,2) +' + N''' 1st QTR <br>(1 OCT - 31 DEC)''' +
				N'WHEN MONTH(T.COMPLETED_DATE) BETWEEN 1 AND 3 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR), 3,2) + ' + N''' 2nd QTR <br>(1 JAN - 31 MAR)''' +
				N'WHEN MONTH(T.COMPLETED_DATE) BETWEEN 4 AND 6 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR), 3,2) + ' + N''' 3rd QTR <br>(1 APR - 30 JUN)''' +
				N'WHEN MONTH(T.COMPLETED_DATE) BETWEEN 7 AND 9 THEN' + N'''FY''' + N'+ SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR), 3,2) + ' + N''' 4th QTR <br>(1 JUL - 30 SEP)''' +
				N'ELSE ''' + N'ERROR''' +
		  N'END, 
		  CASE 
				WHEN MONTH(T.COMPLETED_DATE) BETWEEN 10 AND 12 THEN SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) + 1 AS VARCHAR(4)), 3,2)
				ELSE SUBSTRING(CAST(YEAR(T.COMPLETED_DATE) AS VARCHAR(4)), 3,2)
		  END) A
    ORDER BY QTR, FY;'
  

	EXECUTE (@SQL4);

    -- select * from ##tempTable

	DECLARE theCursor CURSOR
	FOR SELECT DISTINCT ASSIGNED_TO_ORG FROM TASK;
    OPEN theCursor
    FETCH NEXT FROM theCursor INTO @ORG   
    WHILE @@FETCH_STATUS = 0   
	BEGIN
         -- append the underscore to the column name since SQL SERVER won't allow numeric column name
		 SET @COL_NAME = '_' + @ORG
         --dynamically create columns based on the value in @ORG
		 SELECT @SQL = N'ALTER TABLE ChartOrgFYQTR ADD ' + @COL_NAME + N' INT '
		 PRINT  @SQL  -- debug
		 EXEC sp_executesql @SQL

		 FETCH NEXT FROM theCursor INTO @ORG   
	END

	
		/* select specific column names from the newly created table   */
	    SET @counter = 1
		DECLARE  colCursor CURSOR FOR
		SELECT column_name FROM information_schema.columns WHERE table_name = 'ChartOrgFYQTR' AND column_name NOT IN ( 'ID', 'FY', 'QTR');
		OPEN colCursor
		FETCH NEXT FROM colCursor INTO @COL_NAME   
		WHILE @@FETCH_STATUS = 0   
	    BEGIN

            print @COL_NAME -- debug
			--update one org at a time based on the retrieved values from the select statement.
            -- select org minus the prefix _.   
                                                               
            SELECT @SQL2 = N'DECLARE myCursor CURSOR FOR SELECT task_count, fy, qtr FROM ##tempTable WHERE ORG = '''  +  SUBSTRING(@COL_NAME, 2, LEN(@COL_NAME) -1)  + ''''
            PRINT 'SQL2 = ' + @SQL2 -- debug
			EXEC sp_executesql @SQL2
			OPEN myCursor
			FETCH NEXT FROM myCursor INTO @col, @fy, @qtr
			WHILE @@fetch_Status = 0 
		    BEGIN 
				IF (@counter = 1) -- first counter do insert
				BEGIN 
					SELECT @SQL3 = N'INSERT INTO ChartOrgFYQTR (' + @COL_NAME + ', FY, QTR)  VALUES (' + @col + N',' + @fy + N',''' + @qtr + N''')' 
					PRINT 'INSERT SQL 3 = ' + @SQL3 --debug
					EXEC sp_executesql @SQL3
				END
                ELSE -- next counter do update
				BEGIN
					SELECT @SQL3 = N'UPDATE ChartOrgFYQTR SET ' + @COL_NAME + N' = ' + @col + N', FY = ' + @fy + N', QTR = ' +  N'''' + @qtr + N''' WHERE QTR = ' + N'''' + @qtr + N'''' 
					PRINT 'UPDATE SQL 3 = ' + @SQL3 --debug
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
    CLOSE theCursor
	DEALLOCATE theCursor
    CLOSE colCursor
	DEALLOCATE colCursor
	SET NOCOUNT OFF

END
