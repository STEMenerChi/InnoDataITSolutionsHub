


ALTER PROCEDURE uspP30RatioFY2011
(
    @InstitutionName varchar(50) = NULL,
    @GrantNumber int = NULL
)
AS
SELECT c.InstitutionName, 
       p.Institution, p.SerialNum, p.FullProjectNum, p.ProjectTitle, p.BudgetStartDate, p.BudgetEndDate, p.PILastName + ',' + p.PIFirstName as [PI], p.Dollars
FROM   Center c, 
       vwP30RatioFY2011 p
WHERE  p.CenterID = c.CenterID
AND  ((@InstitutionName IS NULL) OR (c.InstitutionName = @InstitutionName))
AND  ((@GrantNumber IS NULL) OR (c.GrantNumber = @GrantNumber))    
    
GROUP BY c.InstitutionName, 
         p.Institution, p.SerialNum, p.FullProjectNum, p.ProjectTitle, p.BudgetStartDate, p.BudgetEndDate, p.PILastName,  p.PIFirstName, p.Dollars



