USE [DBName]
GO
/****** Object:  StoredProcedure [dbo].[Start_OCCRefresh_Stage]    Script Date: 1/17/2019 3:09:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

cREATE PROCEDURE [dbo].[Start_OCCRefresh_Center_Stage] 
AS
BEGIN

DECLARE @job_name Varchar(50) = 'OCC_Refresh_Center_Stage'

--Count number of rows in the table before the refresh incase interested to know
select Count(*) AS [Number of Records in Stage Before Refresh] from  [SERVERNAME,PORT#].[dbName].[dbo].[Center]

--When this Stored procedure is executed, it will execute a system stored procedure on Dev that will start the Stage Refresh job. The job will delete rows on Stage and insert
-- them again from Dev Center_POC table.


EXEC msdb.dbo.sp_start_job 
@job_name = @job_name

WAITFOR DELAY '00:00:10'


--Count number of rows in the table After the refresh incase interested to know
select Count(*) [Number of Records in Stage After Refresh] from  [SERVERNAME,PORT#].[dbName].[dbo].[Center]

END


 --[dbo].[Start_OCCRefresh_Stage] 


 --grant execute on sp_start_job to occrefresh

 --grant execute on sp_start_job to [DOMAIN\userName]

 --grant execute on sp_start_job to [DOMAIN\userName]