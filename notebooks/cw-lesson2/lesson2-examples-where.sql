-- equals
SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemName = 'Chocolate sharks 250g';

SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemID = 225;

SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemID != 225;

SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE NOT StockItemID = 225;

SELECT o.OrderID,
       o.OrderDate,
       o.PickingCompletedWhen
FROM Sales.Orders o
WHERE o.OrderDate > '2013-10-01';

SELECT o.OrderID,
       o.OrderDate,
       o.PickingCompletedWhen
FROM Sales.Orders o
WHERE o.OrderDate > '2013-10-01';

SELECT o.OrderID,
       o.OrderDate,
       o.PickingCompletedWhen
FROM Sales.Orders o
WHERE o.OrderDate > CAST('2013-10-01' AS DATE);

SELECT o.OrderID,
       o.OrderDate,
       o.PickingCompletedWhen, CONVERT(DATE,'2013-10-01',121)
FROM Sales.Orders o
WHERE o.OrderDate > CONVERT(DATE,'2013-10-01',121);

SELECT o.OrderID,
       o.OrderDate,
       o.PickingCompletedWhen,
       DATEDIFF(mm, o.OrderDate, o.PickingCompletedWhen) AS MonthsDiff
FROM Sales.Orders o
WHERE DATEDIFF(mm, o.OrderDate, o.PickingCompletedWhen) > 0;

-- like
SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemName like 'Chocolate%';

-- like
SELECT StockItemId, StockItemName, UnitPrice
FROM Warehouse.StockItems
WHERE StockItemName like '%25[0-6]%'

-- index scan
SELECT *
FROM Warehouse.StockItems
WHERE StockItemName like '%250%';

-- index scan
SELECT *
FROM Warehouse.StockItems
WHERE StockItemName like '%250g';
-- как сделать, чтобы использовалс¤ индекс, если нужно часто делать такие запросы?

SELECT *
FROM Warehouse.StockItems
WHERE StockItemName like 'Chocolate%250g';

-- AND, OR
SELECT RecommendedRetailPrice, *
FROM Warehouse.StockItems
WHERE
    (RecommendedRetailPrice > 350) 
	AND (RecommendedRetailPrice < 500);

	
SELECT RecommendedRetailPrice, *
FROM Warehouse.StockItems
WHERE
    RecommendedRetailPrice = 358.80  
	OR RecommendedRetailPrice = 426.08; 

SELECT RecommendedRetailPrice, *
FROM Warehouse.StockItems
WHERE
    RecommendedRetailPrice BETWEEN 358.80 AND 500;

-- AND, OR
-- нужно вывести StockItems, где цена 350-500 и
-- название начинаетс¤ с USB или Ride.
-- все правильно?
SELECT RecommendedRetailPrice, *
FROM Warehouse.StockItems
WHERE
    RecommendedRetailPrice BETWEEN 350 AND 500
    AND StockItemName like 'USB%' 
    OR StockItemName like 'Ride%';

SELECT RecommendedRetailPrice, *
FROM Warehouse.StockItems
WHERE
    (RecommendedRetailPrice BETWEEN 350 AND 500) 
    AND (
		(StockItemName like 'USB%') 
    OR (StockItemName like 'Ride%')
		);


SELECT RecommendedRetailPrice, *
FROM Warehouse.StockItems
WHERE
    RecommendedRetailPrice BETWEEN 350 AND 500
    AND (StockItemName like 'USB%' 
    OR StockItemName like 'Ride%');


-- Функции в WHERE
DROP INDEX IF EXISTS IX_Sales_Orders_OrderDate ON Sales.Orders;

SELECT OrderDate, OrderID
FROM Sales.Orders o
WHERE year(OrderDate) = 2013;

SELECT *
FROM Sales.Orders o
WHERE OrderDate = '2013-01-01';

CREATE INDEX IX_Sales_Orders_OrderDate ON Sales.Orders(OrderDate);

SELECT OrderDate, OrderID
FROM Sales.Orders o
WHERE year(OrderDate) = 2013;

SELECT OrderDate, OrderID
FROM Sales.Orders o
WHERE OrderDate BETWEEN '2013-01-01' AND '2013-12-31';

DROP INDEX IX_Sales_Orders_OrderDate ON Sales.Orders;


SELECT  OrderLineID as [Order Line ID],
        Quantity,
        UnitPrice,
        (Quantity * UnitPrice) AS [TotalCost]
FROM Sales.OrderLines
WHERE (Quantity * UnitPrice) > 1000;

-- ---------

SELECT  OrderLineID as [Order Line ID],
        Quantity,
        UnitPrice,
        (Quantity * UnitPrice) AS [TotalCost]
FROM Sales.OrderLines
ORDER BY [TotalCost];

-- IS NULL, IS NOT NULL
SELECT OrderID, PickingCompletedWhen
FROM Sales.Orders
WHERE PickingCompletedWhen = null;
GO

SELECT OrderID, PickingCompletedWhen
FROM Sales.Orders
WHERE PickingCompletedWhen != null;
GO

SELECT OrderID, PickingCompletedWhen
FROM Sales.Orders
WHERE PickingCompletedWhen is null;
GO

SELECT OrderID, PickingCompletedWhen
FROM Sales.Orders
WHERE PickingCompletedWhen is not null;
GO

SET ANSI_NULLS OFF
SELECT OrderID, PickingCompletedWhen
FROM Sales.Orders
WHERE PickingCompletedWhen = null;
GO
SET ANSI_NULLS ON

-- Конкатенация с NULL
SELECT 'abc' + null;

SET CONCAT_NULL_YIELDS_NULL OFF;
SELECT 'abc' + null;
SET CONCAT_NULL_YIELDS_NULL ON;

-- Арифметические операции с NULL
SELECT 3 + null;

-- ISNULL()

--   Conversion failed 
SELECT 
    OrderId,    
    ISNULL(PickingCompletedWhen, 'Unknown') AS PickingCompletedWhen
FROM Sales.Orders;

DECLARE @dt DATETIME = '2001-01-01';

SELECT 
    OrderId,    
    ISNULL(PickingCompletedWhen,'1900-01-01'),	
    ISNULL(CONVERT(nvarchar(10), PickingCompletedWhen, 104), 'Unknown') AS PickingCompletedWhen,
	COALESCE(PickingCompletedWhen, @dt, '1900-01-01')
FROM Sales.Orders;


-- COALESCE()
DECLARE @val1 int = NULL;
DECLARE @val2 int = NULL;
DECLARE @val3 int = 2;
DECLARE @val4 int = 5;

SELECT COALESCE(@val1, @val2, @val3, @val4)
   AS FirstNonNull;
   
-- Здесь есть NULL
SELECT DISTINCT PickingCompletedWhen
FROM Sales.Orders
ORDER BY PickingCompletedWhen;

-- Здесь NULL не учитывается
SELECT COUNT(DISTINCT PickingCompletedWhen)
FROM Sales.Orders;

select *
from Sales.Orders
where PickedByPersonID IN
(3,null)
order by PickedByPersonID;

select *
from Sales.Orders
where PickedByPersonID IN
(null)
order by PickedByPersonID;












select * 
from Sales.Orders
where PickedByPersonID in
(4, 3, null)
order by PickedByPersonID

