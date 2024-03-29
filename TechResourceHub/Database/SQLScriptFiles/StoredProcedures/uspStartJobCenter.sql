USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[Start_OCCRefresh_Center_Prod]    Script Date: 1/22/2019 2:17:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Start_OCCRefresh_Center_Prod] 
AS
BEGIN

DECLARE @job_name Varchar(50) = 'OCC_Refresh_Center_Prod'

--Count number of rows in the table before the refresh incase interested to know
select Count(*) AS [Number of Records in Prod Before Refresh] from  [SQLPRDAG04LSNR,49005].[OCC].[dbo].[Center]

--When this Stored procedure is executed, it will execute a system stored procedure on Dev that will start the Stage Refresh job. The job will delete rows on Stage and insert
-- them again from Dev Center_POC table.


EXEC msdb.dbo.sp_start_job 
@job_name = @job_name

WAITFOR DELAY '00:00:10'


--Count number of rows in the table After the refresh incase interested to know
select Count(*) [Number of Records in Prod After Refresh] from  [SQLPRDAG04LSNR,49005].[OCC].[dbo].[Center]

END


 --[dbo].[Start_OCCRefresh_Stage] 


 --grant execute on sp_start_job to occrefresh

 --grant execute on sp_start_job to [NIH\dinhct]

--grant execute on sp_start_job to [NIH\martinezad]