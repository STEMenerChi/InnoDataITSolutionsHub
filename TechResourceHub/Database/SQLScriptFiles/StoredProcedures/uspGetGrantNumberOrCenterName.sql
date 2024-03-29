USE [OCC]
GO
/****** Object:  StoredProcedure [dbo].[uspGetOCCStaffPOC]    Script Date: 1/20/2016 7:12:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[uspGetGrantNumberORCenterName]
(@GrantNumber int = NULL, 
 @CenterName NVARCHAR(255) = NULL, 
 @InstitutionName NVARCHAR(255) = NULL)

AS
/*
    DATE		DESC
	09/23/2014	Retrieve data to display on the web
*/

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	
	
	IF (@GrantNumber IS NOT NULL)
       Begin
		   SELECT CenterName, InstitutionName 
		   FROM   Center
		   WHERE  GrantNumber = @GrantNumber
	   End
	ELSE IF (@CenterName IS NOT NULL)
	   Begin
		   SELECT GrantNumber, InstitutionName
		   FROM   Center
		   WHERE  CenterName LIKE '%' + @CenterName +'%'
	   End
	ELSE IF (@InstitutionName IS NOT NULL)
	   Begin
		   SELECT GrantNumber, CenterName
		   FROM   Center
		   WHERE  InstitutionName LIKE '%' + @InstitutionName +'%'
	   End
END
