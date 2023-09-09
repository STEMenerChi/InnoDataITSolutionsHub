USE [OCC]
GO

/****** Object:  View [dbo].[vwOCCAnnouncement]    Script Date: 3/28/2015 4:35:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[vwOCCAnnouncement]
AS
 /* 
  DATE         		 DESC
  12/12/2014         Created for OCCWebApp  
  01/07/2015         Changed the table name from OCCMessageBoard to OCCAnnoucement per Linda Weiss.
  02/16/2015         Added OrderOfDisplay, 
                     Unconcatenated the EffectiveDate and Message
					 CONVERT ( VARCHAR, EffectiveDate, 107) + ' - ' + [Message] AS Message
  
  Ref date format:http://www.codeproject.com/Articles/576178/cast-convert-format-try-parse-date-and-time-sql  
  use 101 for mm/dd/yyyy

   SELECT  OCCAnnouncementID, OrderOfDisplay,  
           Title, 
		   CONVERT ( VARCHAR, EffectiveDate, 107) as EffectiveDate, 
		   [Message]
	FROM   OCCAnnouncement
	WHERE  isActive = 1
	order by  CONVERT(DateTime, [EffectiveDate],101)  DESC;
 */ 

    SELECT Top 20 
	       OCCAnnouncementID, Title, 
		   CONVERT ( VARCHAR, EffectiveDate, 107) as EffectiveDate, 
		   [Message]
	FROM   OCCAnnouncement
	WHERE  isActive = 1
	ORDER BY OrderOfDisplay;
	







GO


