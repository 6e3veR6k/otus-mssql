Declare @maxId INT = 20;

WITH GenId (Id) AS 
(	
	SELECT 1 

	UNION ALL
	
	SELECT GenId.Id + 1
	FROM GenId 
	WHERE GenId.Id < @maxId
)
Select * 
from GenId
OPTION (MAXRECURSION 20);


DROP TABLE IF EXISTS Employee;

CREATE TABLE Employee (
	EmployeeID INT PRIMARY KEY,
	FullName VARCHAR(256),
	Title VARCHAR(256),
	ManagerID INT
);

INSERT INTO Employee
	(EmployeeID, FullName, Title, ManagerID)
VALUES 
	(1, 'John Mann', 'CEO', NULL),
	(2, 'Irvin Bow', 'CEO Deputy', 1), 
	(3, 'Abby Gold', 'HR', 1), 
	(4, 'Mary Wang', 'HR', 3),
	(5, 'Jim Johnson', 'HR', 4),
	(6, 'Linda Smith', 'HR', 3);

WITH CTE AS (
SELECT EmployeeID, FullName, Title, ManagerID
FROM Employee
WHERE ManagerID IS NULL
UNION ALL
SELECT e.EmployeeID, e.FullName, e.Title, e.ManagerID
FROM Employee e
INNER JOIN CTE ecte ON ecte.EmployeeID = e.ManagerID
)
SELECT *
FROM CTE;

DECLARE @employeeId INT = 5;

WITH CTEParent AS (
SELECT EmployeeID, FullName, Title, ManagerID
FROM Employee
WHERE EmployeeID = @employeeId
UNION ALL
SELECT e.EmployeeID, e.FullName, e.Title, e.ManagerID
FROM Employee e
INNER JOIN CTEParent ecte ON ecte.ManagerID = e.EmployeeID
)
SELECT *
FROM CTEParent;