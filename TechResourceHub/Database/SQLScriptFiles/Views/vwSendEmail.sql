USE [OCC]
GO

/****** Object:  View [dbo].[vw2B]    Script Date: 8/28/2014 10:31:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 --select * from dtTracking
 --select * from CenterDetail
 --select * from CenterPOC
 --select * from person


CREATE VIEW [dbo].[vwSendEmail]
AS
 /*
    DATE		DESC
	08/28/2014	The windows servcie OCCutil  accesses this view
	             this view checks the Center's CenterDetail.EdataDueDate and the DTtracking.IsSubmitted flag, 
				 if Data Tables are due, then sends out email to correspnding Center's admin & OCC Program Director (CenterPOC table)
				                         updates the DTtracking.EmailedDate 
  
  
 */ 
   
	SELECT CONVERT (VARCHAR (15), detail.EdataDueDate, 107) AS eDataDueDate,  
	       poc.AdminFullName, poc.AdminEmail
		   ,p.LastName, P.FirstName, p.email
	   
	FROM   DTtracking    Track,
	       CenterDetail  detail,
		   CenterPOC     poc, 
		   person        p
	WHERE  Track.CenterID = Detail.CenterId
	AND    Detail.CenterID = poc.CenterID
	AND    p.PersonID = detail.PDPersonID
	AND    track.isSubmitted IS NULL

GO









