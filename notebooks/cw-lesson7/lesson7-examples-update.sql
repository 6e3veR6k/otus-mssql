
select PhoneNumber,FaxNumber,* 
from [Application].People
WHERE PersonId = 3;

--simple
SELECT 
	PhoneNumber = '(495) 555-1111',
	FaxNumber = '(495) 555-3333', PhoneNumber, FaxNumber, *
from  [Application].People
WHERE PersonId = 3;

Update [Application].People
SET 
	PhoneNumber = '(495) 555-1111',
	FaxNumber = '(495) 555-3333'
WHERE PersonId = 3;

Update [Application].People
SET 
	PhoneNumber = '(415) 555-0102',
	FaxNumber = '(415) 555-0103'
OUTPUT inserted.*, deleted.*
WHERE PersonId = 3;

--PhoneNumber	FaxNumber
--(415) 555-0102	(415) 555-0103


ALTER TABLE [Application].People ADD FirstSale DATETIME;
ALTER TABLE [Application].People ADD FirstSale2 DATETIME;

/*
ALTER TABLE [Application].People DROP COLUMN FirstSale;
ALTER TABLE [Application].People DROP COLUMN FirstSale2;
*/
select firstSale, FullName From [Application].People;

UPDATE [Application].People
SET FirstSale = (SELECT MIN(InvoiceDate)
	FROM Sales.Invoices AS I
	WHERE [Application].People.PersonID = I.SalespersonPersonID);
	
SELECT FirstSale,FirstSale2,* 
FROM [Application].People
WHERE FirstSale IS NOT NULL;

UPDATE P
SET FirstSale2 = I.MinInvoiceDate
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, MIN(InvoiceDate) AS MinInvoiceDate
	FROM Sales.Invoices
	GROUP BY SalespersonPersonID) AS I
		ON P.PersonID = I.SalespersonPersonID;

Select P.FirstSale2,  I.MinInvoiceDate
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, MIN(InvoiceDate) AS MinInvoiceDate
	FROM Sales.Invoices
	GROUP BY SalespersonPersonID) AS I
		ON P.PersonID = I.SalespersonPersonID;

UPDATE [Application].People
SET FirstSale = NULL,
	FirstSale2 = NULL;

ALTER TABLE [Application].People DROP COLUMN FirstSale;
ALTER TABLE [Application].People DROP COLUMN FirstSale2;
ALTER TABLE [Application].People DROP COLUMN TotalSaleCount;

ALTER TABLE [Application].People DROP DF__People__TotalSal__6F357288;

ALTER TABLE [Application].People ADD TotalSaleCount INT NOT NULL Default 0;

SELECT p.TotalSaleCount, p.TotalSaleCount + I.SalesCount, I.SalesCount
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate < '20140101'
	GROUP BY SalespersonPersonID) AS I
		ON P.PersonID = I.SalespersonPersonID;

UPDATE P
SET TotalSaleCount = TotalSaleCount + I.SalesCount
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate < '20140101'
	GROUP BY SalespersonPersonID) AS I
		ON P.PersonID = I.SalespersonPersonID;

ALTER TABLE Application.People DROP COLUMN TotalDryItems;
ALTER TABLE Application.People ADD TotalDryItems INT;

UPDATE I
SET TotalDryItems = TotalSaleCount + I.SalesCount
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount, TotalDryItems
	FROM Sales.Invoices_Q12016
	WHERE InvoiceDate < '20140101'
	GROUP BY SalespersonPersonID, TotalDryItems) AS I
		ON P.PersonID = I.SalespersonPersonID;

SELECT TotalSaleCount,* 
FROM [Application].People 
WHERE TotalSaleCount > 0

UPDATE P
SET TotalSaleCount += I.SalesCount --TotalSaleCount = TotalSaleCount + I.SalesCount
OUTPUT inserted.PersonId, inserted.FullName,inserted.TotalSaleCount
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101'
		AND InvoiceDate < '20150101' 
	GROUP BY SalespersonPersonID) AS I
		ON P.PersonID = I.SalespersonPersonID;

UPDATE [Application].People
SET TotalSaleCount = 0;
 
UPDATE TOP (5) P
SET TotalSaleCount += I.SalesCount 
OUTPUT inserted.PersonId, inserted.FullName,inserted.TotalSaleCount
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20150401'
		AND InvoiceDate < '20150801' 
	GROUP BY SalespersonPersonID, CustomerId) AS I
		ON P.PersonID = I.SalespersonPersonID;

UPDATE TOP (5) P
SET TotalSaleCount += I.SalesCount 
OUTPUT inserted.PersonId, inserted.FullName,inserted.TotalSaleCount
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20150401'
		AND InvoiceDate < '20150801' 
	GROUP BY SalespersonPersonID) AS I
		ON P.PersonID = I.SalespersonPersonID;

ALTER TABLE [Application].[People] DROP CONSTRAINT [DF__People__TotalSal__06A2E7C5];
ALTER TABLE [Application].People DROP COLUMN TotalSaleCount;


UPDATE TOP (100) Website.Customers
SET CustomerName = 'New Great Shop for something!!!!'--Biju Deb
WHERE CustomerID = 842;

SELECT *
FROM Website.Customers
WHERE CustomerID = 842

SELECT *
FROM Sales.Customers
WHERE CustomerID = 842

ALTER TABLE Sales.Customers DROP COLUMN CustomerCategoryName;
ALTER TABLE Sales.Customers ADD CustomerCategoryName NVARCHAR(50);

WITH UpdEx AS 
(
	SELECT 
		TOP (100) 
	   s.CustomerID,
       s.CustomerName,
       sc.CustomerCategoryName AS sourceCustomerCategoryName,
	   s.CustomerCategoryName
	FROM Sales.Customers AS s
		LEFT JOIN Sales.CustomerCategories AS sc
		ON s.CustomerCategoryID = sc.CustomerCategoryID
	ORDER BY CustomerID
)
UPDATE UpdEx
SET CustomerCategoryName = sourceCustomerCategoryName;

SELECT CustomerCategoryName,*
FROM Sales.Customers;

ALTER TABLE Sales.Customers DROP COLUMN CustomerCategoryName;

DROP TABLE IF EXISTS Sales.TotalSalesForDay;
DROP TABLE IF EXISTS Sales.InvoiceBucket;

create table Sales.TotalSalesForDay (SalesDate DATE, SalesSum DECIMAL(18,2));

create table Sales.InvoiceBucket (InvoiceDate DATE, UnitPrice DECIMAL(18,2));

	INSERT INTO Sales.InvoiceBucket 
	(InvoiceDate, UnitPrice)
	SELECT I.InvoiceDate, IL.UnitPrice
	FROM Sales.InvoiceLines AS IL
		join Sales.Invoices AS I
			ON I.InvoiceID = IL.InvoiceID
	WHERE I.InvoiceDate >= '20130103'
		AND I.InvoiceDate < '20130105'
	ORDER BY InvoiceDate ---!!!!!!! Будет ли соблюден порядок?

	SELECT InvoiceDate, Sum(UnitPrice)
	FROM Sales.InvoiceBucket
	GROUP BY InvoiceDate
	ORDER BY InvoiceDate

	select * 
	from Sales.InvoiceBucket

	select * 
	from Sales.TotalSalesForDay;

	SELECT InvoiceDate, Sum(UnitPrice) AS TotalSumm
	FROM Sales.InvoiceBucket
	GROUP BY InvoiceDate

	insert into Sales.TotalSalesForDay (SalesDate, SalesSum) 
	VALUES (DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0),0)

	select * from Sales.TotalSalesForDay;

	UPDATE T
	SET SalesSum = B.TotalSumm
	FROM Sales.TotalSalesForDay AS T
		JOIN 
			(SELECT InvoiceDate, Sum(UnitPrice) AS TotalSumm
			FROM Sales.InvoiceBucket
			GROUP BY InvoiceDate) AS B
			ON T.SalesDate = DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0)

	select * 
	from Sales.TotalSalesForDay;

	UPDATE T
	SET SalesSum = B.TotalSumm
	FROM Sales.TotalSalesForDay AS T
		JOIN 
			(SELECT InvoiceDate, Sum(UnitPrice) AS TotalSumm
			FROM Sales.InvoiceBucket
			GROUP BY CustomerId, InvoiceDate
			) AS B
			ON T.CustomerId = B.CustomerId