USE [OCC]
GO

/****** Object:  View [dbo].[vwBaseFund]    Script Date: 4/3/2015 10:39:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
/*--------------------------------------------------------------------------------------------------------------------------------------
   Date			Developer		DESC
   04/03/2015   Chi Dinh		BaseFund lists  every NCI funded grant at each of cancer centers that was active during Calendar year ####; 
                                regardless whether they're NCI-designated Cancer Centers or not. 
								The data inlcude all active grants within specific project start and end dates. 
								These data derived from RAEB


------------------------------------------------------------------------------------------------------------------------------------------*/

ALTER VIEW [dbo].[vwBaseFund]
AS
	SELECT c.GrantNumber, c.InstitutionName,
	       b.FY, b.Institution as P30Partner, b.FullProjNo, b.ProjTitle, 
	       b.BudgetStartDate, b.BudgetEndDate, b.PILastName + ',' + SUBSTRING(b.PIFirstName, 1,1) as PIname, b.TotalCost
	FROM   BaseFund b,
	       Center   c
	WHERE  b.CenterID = c.CenterId
	
	--AND    b.GrantNumber is not null
	--AND    c.GrantNumber NOT IN (67, 68, 69, 70, 71, 72, 73, 74, 75)
	AND    FY IN (2011, 2012, 2013, 2014)

GO


