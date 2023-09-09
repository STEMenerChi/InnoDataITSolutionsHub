USE [OCC]
GO

/****** Object:  View [dbo].[vwRP]    Script Date: 12/12/2014 11:49:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [dbo].[vwOCCMessageBoard]
AS
 /* 
  DATE         		 DESC
  12/12/2014         Created for OCCWebApp  
  
  Ref date format:http://www.codeproject.com/Articles/576178/cast-convert-format-try-parse-date-and-time-sql  
  use 101 for mm/dd/yyyy
 */ 

   SELECT  OCCMessageBoardID, Title, CONVERT ( VARCHAR, EffectiveDate, 107) + ' - ' + [Message] AS Message
	FROM   OCCMessageBoard
	WHERE  isActive = 1;
	
GO


