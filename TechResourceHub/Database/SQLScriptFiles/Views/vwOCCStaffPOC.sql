USE [OCC]
GO

/****** Object:  View [dbo].[vwOCCAnnouncement]    Script Date: 11/14/2019 11:19:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*  THIS WORKS: 

DECLARE @userTypeId BIGINT;
SET @userTypeId = 9;
WITH tblChild AS
(
    SELECT *
        FROM OCCStaffPOC WHERE RelatedPersonID = @userTypeId
    UNION ALL
    SELECT OCCStaffPOC.* FROM OCCStaffPOC  JOIN tblChild  ON OCCStaffPOC.RelatedPersonID = tblChild.OCCStaffPOCID
)
SELECT *
    FROM tblChild
OPTION(MAXRECURSION 32767)



ref: https://community.spiceworks.com/topic/1556698-sql-parent-child-recursive-query

SELECT y.OCCStaffPOCID, y.FirstName, y.LastName, y.Relationship, y.RelatedPersonID FROM OCCStaffPOC y;
----------------

with cteReports (FirstName, LastName, Relationship,  OCCStaffPOCID, RelatedPersonID, steps, id)
AS
(
SELECT FirstName, LastName, Relationship,  OCCStaffPOCID, RelatedPersonID, [Steps] = 0, [id] = ROW_NUMBER() OVER (ORDER BY [OCCStaffPOCID] ASC)
FROM OCCStaffPOC
where RelatedPersonID is null

UNION ALL

select e.FirstName, e.LastName, e.Relationship, e.OCCStaffPOCID, e.RelatedPersonID, r.steps + 1, id
from OCCStaffPOC e
inner join cteReports r
on e.RelatedPersonID = r.OCCStaffPOCID
)
select DISTINCT FirstName, LastName, Relationship,  OCCStaffPOCID, RelatedPersonID, steps, id
from cteReports cte
ORDER BY id asc, steps asc;

    Date		Programmer		Desc
	12/05/2019  C. Dinh			need steps, and id to sort but do not display

*/


ALTER VIEW [dbo].[vwOCCStaffPOC]
AS

WITH cteReports (FirstName, LastName, Cellphone, HomePhone, PersonalEmail,  Relationship, Comments,   OCCStaffPOCID, RelatedPersonID, steps, id)
AS
(
SELECT FirstName, LastName, Cellphone, HomePhone, PersonalEmail, Relationship, Comments,  OCCStaffPOCID, RelatedPersonID, [Steps] = 0, [id] = ROW_NUMBER() OVER (ORDER BY [OCCStaffPOCID] ASC)
FROM OCCStaffPOC
WHERE RelatedPersonID is null
AND   isActive = 1

UNION ALL

select e.FirstName, e.LastName, e.Cellphone, e.HomePhone, e.PersonalEmail, e.Relationship, e.Comments, e.OCCStaffPOCID, e.RelatedPersonID, r.steps + 1, id
from OCCStaffPOC e
inner join cteReports r
on e.RelatedPersonID = r.OCCStaffPOCID
AND e.isActive = 1
)
SELECT DISTINCT TOP 50 FirstName, LastName, Cellphone, HomePhone, PersonalEmail, Relationship, Comments, steps, id
FROM cteReports cte
ORDER BY id asc, steps asc;


GO





