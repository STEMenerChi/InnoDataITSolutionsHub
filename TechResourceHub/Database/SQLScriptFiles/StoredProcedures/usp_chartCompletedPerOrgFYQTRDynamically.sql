USE [TMS3_1_CHI]
GO
/****** Object:  StoredProcedure [dbo].[usp_chartCompletedPerOrgFYQTRDynamically]    Script Date: 11/01/2010 10:14:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================================
-- Date			Developer	Description		
-- 11/01/2010	C. Dinh		1. to create columns dynamically bassed on the values in the @CUST_TYPE field
--                          2. populate the table CUSTFYQTR with data from usp_chartTaskCountPerCustomerFYQTR.
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
ALTER PROC [dbo].[usp_chartCompletedPerOrgFYQTRDynamically]

AS
BEGIN

	SET NOCOUNT ON;

	CREATE TABLE chartCompletedPerOrgFYQTR(ID int IDENTITY(1,1), FY int, QTR int );

	DECLARE @SQL NVARCHAR(MAX),
            @SQL2 NVARCHAR(MAX),
            @SQL3 NVARCHAR(MAX),
            @COL_NAME NVARCHAR(15), 
            @ORG VARCHAR(15),
            @I INT,
		    @numRows int, 
            @counter int, 
            @fy nvarchar(10),
            @qtr nvarchar(10),
            @col varchar(15)

   
    /*  select the data into #tempOrg */
    SELECT ORG, TASK_COUNT, FY, QTR
    INTO #tempOrg
    FROM 
	(SELECT  
			T.ASSIGNED_TO_ORG AS ORG, 
			COUNT(T.TMS_ID) AS TASK_COUNT,  
            dbo.uf_GetFiscalYear(COMPLETED_DATE) AS FY, 
			dbo.uf_GetFYQuarter(COMPLETED_DATE) AS QTR
	FROM  TASK T
	WHERE T.ASSIGNED_TO_ORG IS NOT NULL
    AND   T.COMPLETED_DATE IS NOT NULL
    AND   T.STATUS_ID = 5
	--AND   dbo.uf_GetFYQuarter(CREATED_DATE)= dbo.uf_GetFYQuarter(GETDATE()) 
	GROUP BY  dbo.uf_GetFiscalYear(COMPLETED_DATE), dbo.uf_GetFYQuarter(COMPLETED_DATE), T.ASSIGNED_TO_ORG  

	UNION ALL

	SELECT  
         T.CUSTOMER_POC AS ORG,
		 COUNT(T.TMS_ID) AS TASK_COUNT, 
        dbo.uf_GetFiscalYear(COMPLETED_DATE) AS FY,
		dbo.uf_GetFYQuarter(COMPLETED_DATE) AS QTR
	FROM  TASK T
	WHERE T.CUSTOMER_POC IS NOT NULL
    AND   T.COMPLETED_DATE IS NOT NULL
    AND   T.STATUS_ID = 5
	GROUP BY   dbo.uf_GetFiscalYear(COMPLETED_DATE), dbo.uf_GetFYQuarter(COMPLETED_DATE), T.CUSTOMER_POC
    ) A
    -- select * from #tempOrg

	DECLARE orgCursor CURSOR
	FOR SELECT ASSIGNED_TO_ORG AS ORG  FROM TASK  WHERE ASSIGNED_TO_ORG IS NOT NULL UNION  SELECT CUSTOMER_POC AS ORG  FROM TASK WHERE CUSTOMER_POC IS NOT NULL;
    OPEN orgCursor
    FETCH NEXT FROM orgCursor INTO @ORG   
    WHILE @@FETCH_STATUS = 0   
	BEGIN
		 SET @COL_NAME = @ORG
         --dynamically create columns based on the value in @ORG
		 SELECT @SQL = N'ALTER TABLE chartCompletedPerOrgFYQTR ADD ' + @COL_NAME + N' INT '
		 PRINT  @SQL  -- debug
		 EXEC sp_executesql @SQL

		 FETCH NEXT FROM orgCursor INTO @ORG
	END

	
		/* select the column names from the newly created table   */
	    SET @counter = 1
		DECLARE  colCursor CURSOR FOR
		SELECT column_name FROM information_schema.columns WHERE table_name = 'chartCompletedPerOrgFYQTR' AND column_name NOT IN ( 'ID', 'FY', 'QTR');
		OPEN colCursor
		FETCH NEXT FROM colCursor INTO @COL_NAME   
		WHILE @@FETCH_STATUS = 0   
	    BEGIN

            print @COL_NAME -- debug
			--update one cust_type at a time
                                                               
            SELECT @SQL2 = N'DECLARE myCursor CURSOR FOR SELECT task_count, fy, qtr FROM #tempCust WHERE ORG = '''  +  @COL_NAME  + ''''
            PRINT @SQL2 -- debug
			EXEC sp_executesql @SQL2
			OPEN myCursor
			FETCH NEXT FROM myCursor INTO @col, @fy, @qtr
			WHILE @@fetch_Status = 0 
		    BEGIN 
				IF (@counter = 1) -- first time insert
				BEGIN 
					SELECT @SQL3 = N'INSERT INTO chartCompletedPerOrgFYQTR (' + @COL_NAME + ', FY, QTR)  VALUES (' + @col + N',' + @fy + N',' + @qtr + N')' 
					PRINT @SQL3 --debug
					EXEC sp_executesql @SQL3
				END
                ELSE -- update the table
				BEGIN
					SELECT @SQL3 = N'UPDATE chartCompletedPerOrgFYQTR SET ' + @COL_NAME + N' = ' + @col + N', FY = ' + @fy + N', QTR = '  + @qtr + N' WHERE QTR = '  + @qtr  
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
	CLOSE orgCursor
	DEALLOCATE orgCursor
    CLOSE colCursor
	DEALLOCATE colCursor
	SET NOCOUNT OFF

END
