USE [TMS3_1_CHI]
GO
/****** Object:  StoredProcedure [dbo].[usp_chartCreateViewDynamically]    Script Date: 10/28/2010 11:15:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================================================
-- Date			Developer	Description		
-- 10/28/2010	C. Dinh		
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
create PROC [dbo].[usp_chartCreateViewDynamically]

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @SQL NVARCHAR(MAX),
	        @NUM_ROWS INT,
            @COL_NAME NVARCHAR(15), 
            @CUST_TYPE NVARCHAR(15)
    

	--DECLARE PRODUCT_LIST CURSOR
	--FOR SELECT ProdName, ModifiedProdName AS TName FROM ProductList

	DECLARE custCursor CURSOR
	FOR SELECT [description] FROM Customer WHERE parent_id IS NULL

	SET @NUM_ROWS = 0
	SET @SQL = 'SELECT * INTO ' + @TABLE_NAME + ' FROM Products WHERE ProdName = ''' + @PRODUCT + ''' ORDER BY Col1, Col2'

    
	OPEN custCursor

	WHILE @NUM_ROWS < @@CURSOR_ROWS
	BEGIN

		FETCH custCursor INTO @CUST_TYPE
		DECLARE @COL_NAME + CONVERT(VARCHAR(2),@NUM_ROWS) VARCHAR(15)   -- @COL_NAME1, @COL_NAME2, ETC
		SET @COL_NAME + + CONVERT(VARCHAR(2),@NUM_ROWS) = @CUST_TYPE

        
		/* Increment counter */
		SET @NUM_ROWS = @NUM_ROWS + 1
	END
	/* Drop old view */
	--SET @SQL = 'DROP VIEW uvw_Customer' 
	--EXEC(@SQL)

	/* Generate new view with dynamic colname */
	SET @SQL = 'SELECT * INTO ' + @TABLE_NAME + ' FROM Products WHERE ProdName = ''' + @PRODUCT + ''' ORDER BY Col1, Col2'
	EXEC(@SQL)

	CLOSE PRODUCT_LIST
	DEALLOCATE PRODUCT_LIST

	SET NOCOUNT OFF

END
