/*
 Генерация временной таблицы для опционального задания
*/
DECLARE @StartDate DATE;
DECLARE @ToDate DATE;

SELECT @StartDate = MIN(InvoiceDate), @ToDate=MAX(InvoiceDate)
FROM Sales.Invoices


;WITH 
IntCte AS
    (
    SELECT 0 AS Digit
        UNION ALL
    SELECT Digit + 1
    FROM IntCte
    WHERE Digit < DATEDIFF(DAY, @StartDate, @ToDate)
    ),
DatesCTE AS
    (
    SELECT DATEADD(DAY, Digit, @StartDate) AS [Date] FROM IntCTE
    )

SELECT 
    [Date], 
    DATEFROMPARTS(YEAR([Date]), MONTH([Date]), 1) AS FirstDayOfMonth, 
    EOMONTH([Date]) AS LastDayOfMonth
INTO #Dates
FROM DatesCTE
OPTION (MAXRECURSION 0);

/*
    Группировки и агрегатные функции
    1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
*/

SELECT
    AVG(IL.UnitPrice) AS AvgPrice,
    SUM(IL.UnitPrice*IL.Quantity) AS Sum,
    FORMAT(I.InvoiceDate, 'yyyy-MM-01') AS Month
FROM Sales.Invoices AS I
INNER JOIN Sales.InvoiceLines AS IL ON IL.InvoiceID = I.InvoiceID
GROUP BY FORMAT(I.InvoiceDate, 'yyyy-MM-01')
ORDER BY Month


--1.1
SELECT
    AVG(IL.UnitPrice) AS AvgPrice,
    SUM(IL.UnitPrice*IL.Quantity) AS Sum,
    D.FirstDayOfMonth AS Month
FROM #Dates AS D
LEFT JOIN Sales.Invoices AS I ON I.InvoiceDate = D.[Date]
INNER JOIN Sales.InvoiceLines AS IL ON IL.InvoiceID = I.InvoiceID
GROUP BY D.FirstDayOfMonth
ORDER BY Month


/*
    2. Отобразить все месяцы, где общая сумма продаж превысила 10 000
*/
 
SELECT 
    DATEFROMPARTS(YEAR(I.InvoiceDate), MONTH(I.InvoiceDate), 1) AS Period,
    SUM(IL.UnitPrice * IL.Quantity) AS SumInvoices
FROM Sales.Invoices AS I
INNER JOIN Sales.InvoiceLines AS IL ON IL.InvoiceID = I.InvoiceID
GROUP BY DATEFROMPARTS(YEAR(I.InvoiceDate), MONTH(I.InvoiceDate), 1)
HAVING SUM(IL.UnitPrice * IL.Quantity) > 10000
ORDER BY Period DESC


-- 2.1
SELECT
    D.FirstDayOfMonth AS Period,
    SUM(IL.UnitPrice * IL.Quantity) AS SumInvoices
FROM #Dates AS D 
LEFT JOIN Sales.Invoices AS I ON I.InvoiceDate = D.[Date]
INNER JOIN Sales.InvoiceLines AS IL ON IL.InvoiceID = I.InvoiceID
GROUP BY D.FirstDayOfMonth
HAVING SUM(IL.UnitPrice * IL.Quantity) > 10000
ORDER BY Period DESC


/*
    3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.
    Группировка должна быть по году и месяцу.
*/

SELECT
    DATEFROMPARTS( YEAR(I.InvoiceDate), MONTH(I.InvoiceDate), 1) AS IPeriod,
    SUM(IL.UnitPrice * IL.Quantity) AS SumInvoices,
    MIN(I.InvoiceDate) AS FirstInvoiceDate,
    SUM(IL.Quantity) AS CountOfUnits,
    WI.StockItemName
FROM Sales.InvoiceLines AS IL
INNER JOIN Sales.Invoices AS I ON I.InvoiceID = IL.InvoiceID
INNER JOIN Warehouse.StockItems AS WI ON WI.StockItemID = IL.StockItemID
GROUP BY YEAR(I.InvoiceDate), MONTH(I.InvoiceDate), WI.StockItemName
HAVING SUM(IL.Quantity) < 50
ORDER BY IPeriod, FirstInvoiceDate


--3.1

SELECT
    D.FirstDayOfMonth AS IPeriod,
    SUM(IL.UnitPrice * IL.Quantity) AS SumInvoices,
    MIN(I.InvoiceDate) AS FirstInvoiceDate,
    SUM(IL.Quantity) AS CountOfUnits,
    WI.StockItemName
FROM #Dates AS D
LEFT JOIN Sales.Invoices AS I ON I.InvoiceDate = D.[Date]
INNER JOIN Sales.InvoiceLines AS IL ON I.InvoiceID = IL.InvoiceID
INNER JOIN Warehouse.StockItems AS WI ON WI.StockItemID = IL.StockItemID
GROUP BY D.FirstDayOfMonth, WI.StockItemName
HAVING SUM(IL.Quantity) < 50
ORDER BY IPeriod, FirstInvoiceDate


/*
4. Написать рекурсивный CTE sql запрос и заполнить им временную таблицу и табличную переменную
Дано :
CREATE TABLE dbo.MyEmployees
(
EmployeeID smallint NOT NULL,
FirstName nvarchar(30) NOT NULL,
LastName nvarchar(40) NOT NULL,
Title nvarchar(50) NOT NULL,
DeptID smallint NOT NULL,
ManagerID int NULL,
CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC)
);
INSERT INTO dbo.MyEmployees VALUES
(1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL)
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1)
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273)
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274)
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274)
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273)
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285)
,(16, N'David',N'Bradley', N'Marketing Manager', 4, 273)
,(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);

Результат вывода рекурсивного CTE:
EmployeeID   Name               Title                           EmployeeLevel
1            Ken Sánchez        Chief Executive Officer         1
273          Brian Welcker      Vice President of Sales         2
16           David Bradley      Marketing Manager               3
23           Mary Gibson        Marketing Specialist            4
274          Stephen Jiang      North American Sales Manager    3
276          Linda Mitchell     Sales Representative            4
275          Michael Blythe     Sales Representative            4
285          Syed Abbas         Pacific Sales Manager           3
286          Lynn Tsoflias      Sales Representative            4


Опционально:
Написать все эти же запросы, но, если за какой-то месяц не было продаж, то этот месяц тоже должен быть в результате и там должны быть нули.
*/

CREATE TABLE dbo.MyEmployees
(
    EmployeeID      smallint        NOT NULL,
    FirstName       nvarchar(30)    NOT NULL,
    LastName        varchar(40)     NOT NULL,
    Title           nvarchar(50)    NOT NULL,
    DeptID          smallint        NOT NULL,
    ManagerID       int             NULL,

    CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC)
);

INSERT INTO dbo.MyEmployees VALUES
 (1,   N'Ken',     N'Sánchez',  N'Chief Executive Officer',     16, NULL)
,(273, N'Brian',   N'Welcker',  N'Vice President of Sales',     3,  1   )
,(274, N'Stephen', N'Jiang',    N'North American Sales Manager',3,  273 )
,(275, N'Michael', N'Blythe',   N'Sales Representative',        3,  274 )
,(276, N'Linda',   N'Mitchell', N'Sales Representative',        3,  274 )
,(285, N'Syed',    N'Abbas',    N'Pacific Sales Manager',       3,  273 )
,(286, N'Lynn',    N'Tsoflias', N'Sales Representative',        3,  285 )
,(16,  N'David',   N'Bradley',  N'Marketing Manager',           4,  273 )
,(23,  N'Mary',    N'Gibson',   N'Marketing Specialist',        4,  16  );


DECLARE @TEmployee TABLE (
    EmployeeID      SMALLINT        NOT NULL, 
    Name            NVARCHAR(80)    NOT NULL, 
    Title           NVARCHAR(50)    NOT NULL, 
    EmployeeLevel   INT             NOT NULL
)

CREATE TABLE #TempEmployee (
    EmployeeID      SMALLINT        NOT NULL, 
    Name            NVARCHAR(80)    NOT NULL, 
    Title           NVARCHAR(50)    NOT NULL, 
    EmployeeLevel   INT             NOT NULL
)


;WITH EmployeeCTE AS (
    SELECT E.EmployeeID, E.FirstName + ' ' + E.LastName AS Name, E.Title, 1 AS EmployeeLevel
    FROM dbo.MyEmployees AS E
    WHERE E.ManagerID IS NULL
        UNION ALL
    SELECT E2.EmployeeID, E2.FirstName + ' ' + E2.LastName AS Name, E2.Title, C2.EmployeeLevel + 1 AS EmployeeLevel
    FROM dbo.MyEmployees AS E2
    INNER JOIN EmployeeCTE AS C2 ON C2.EmployeeID = E2.ManagerID
)
INSERT INTO @TEmployee (EmployeeID, Name, Title, EmployeeLevel)
OUTPUT inserted.EmployeeID, inserted.Name, inserted.Title, inserted.EmployeeLevel
INTO #TempEmployee
SELECT
    EmployeeID, Name, Title, EmployeeLevel
FROM EmployeeCTE