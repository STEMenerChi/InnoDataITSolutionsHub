USE [OCC]
GO

/****** Object:  View [dbo].[vwOCCAnnoucement]    Script Date: 1/7/2015 12:22:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vwOCCAnnoucement]
AS
 /* 
  DATE         		 DESC
  12/12/2014         Created for OCCWebApp  
  01/07/2015         Changed the table name from OCCMessageBoard to OCCAnnoucement per Linda Weiss.
  
  Ref date format:http://www.codeproject.com/Articles/576178/cast-convert-format-try-parse-date-and-time-sql  
  use 101 for mm/dd/yyyy
 */ 

    SELECT Top 10 
	       OCCAnnoucementID, Title, CONVERT ( VARCHAR, EffectiveDate, 107) + ' - ' + [Message] AS Message
	FROM   OCCAnnoucement
	WHERE  isActive = 1
	ORDER BY EffectiveDate;
	


GO


