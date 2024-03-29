USE [OCC]
GO
/****** Object:  UserDefinedFunction [dbo].[ufGetLoginName]    Script Date: 4/27/2017 12:27:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 ALTER FUNCTION [dbo].[ufGetLoginName]()
  RETURNS VARCHAR(50)
  
  /*******************************************************************************************
	DATE		DEV				DESC
	04/27/2017	Chi T. Dinh		Modified this user function to return the current system user.
	                            Not using this function.   
					            [LastUpdatedUserName] [varchar](15) NULL DEFAULT (suser_sname()),
  Note: 
   -- returns current database user name: dbo
  SELECT CURRENT_USER

  -- return every database users
  SELECT  sp.name 
  FROM sys.server_principals sp
  JOIN sys.database_principals dp ON (sp.sid = dp.sid)
  --to test, execute the following stmt:
  Declare @loginName varchar(50);

  SELECT @loginName = sp.name 
  FROM sys.server_principals sp
  JOIN sys.database_principals dp ON (sp.sid = dp.sid)

  Select @loginName 

  -- return current logged windwos user name: NIH\dinhct
  SELECT system_USER; 

  ---return current logged windwos user name: NIH\dinhct
  [LastUpdatedUserName] [varchar](15) NULL DEFAULT (suser_sname()),

  select suser_sname();
  *******************************************************************************************/
  AS
  BEGIN
  Declare @loginName varchar(50);

  SELECT @loginName = sp.name 
  FROM sys.server_principals sp
  JOIN sys.database_principals dp ON (sp.sid = dp.sid)

  RETURN @loginName
  END



