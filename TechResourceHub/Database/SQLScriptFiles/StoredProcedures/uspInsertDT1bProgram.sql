USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspInsertDT1bProgram]    Script Date: 11/16/2015 2:11:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*-- =============================================
---Date			Dev			Desc
-- 11/16/2015	Chi         Created the SP 
--                          DT1bBFY14 may have more than 1 leader per SR, insert the first row into DT1bProgram, and the rest in MultiLeader (see uspInsertMultiLeader4DT1B)  
--  1. always perform the backup
    select *
	into DT1bProgram2015Nov16
	from DT1bProgram;

	Verification number of rows inserted:
	-- # row that should be inserted into DT1BProgram = 434  
	SELECT	count(*)
	FROM DT1BFY14 d, 
		 center c
	WHERE d.CenterID = c.CenterID;
-- =============================================*/
ALTER PROCEDURE  [dbo].[uspInsertDT1bProgram]

AS
BEGIN

INSERT INTO [OCC].[dbo].[DT1BProgram]
           (FY
           ,[GrantNumber]
           ,CenterID
           ,[ReportingDate]
           ,[ProgName]
           ,[NoOfMembers]
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

SELECT	FY
		,d.GrantNumber
		,d.CenterID
		,[ReportingDate]
		,[ProgName]
		,[NoOfMember]	
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
		,d.comments
FROM DT1BFY14 d, 
	 center c
WHERE d.CenterID = c.CenterID;

/*  verify:

 select * from dt1bProgram
 where fy = 2014
 
 ====> 434 rows :-)
*/

END


