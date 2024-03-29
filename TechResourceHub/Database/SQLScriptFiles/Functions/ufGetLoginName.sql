USE [OCC]
GO


 CREATE FUNCTION [ufGetLoginName]()
  RETURNS VARCHAR(50)
  
  AS
  BEGIN
  Declare @loginName varchar(50);

  SELECT @loginName = sp.name 
  FROM sys.server_principals sp
  JOIN sys.database_principals dp ON (sp.sid = dp.sid)

  Select @loginName 
  RETURN @loginName
  END
  GO

  select dbo.ufGetloginName();

  /* to test, execute the following stmt:


  Declare @loginName varchar(50);

  SELECT @loginName = sp.name 
  FROM sys.server_principals sp
  JOIN sys.database_principals dp ON (sp.sid = dp.sid)

  Select @loginName 

  */


