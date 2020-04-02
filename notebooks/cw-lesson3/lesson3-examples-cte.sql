SELECT P.PersonID, P.FullName, I.SalesCount
FROM [Application].People AS P
	JOIN
	(SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101'
		AND InvoiceDate < '20150101' 
	GROUP BY SalespersonPersonID) AS I
		ON P.PersonID = I.SalespersonPersonID;
		
WITH InvoicesCTE (SalespersonPersonID, SalesCount) AS 
(
	SELECT SalespersonPersonID, Count(InvoiceId) 
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101'
		AND InvoiceDate < '20150101' 
	GROUP BY SalespersonPersonID
)
SELECT P.PersonID, P.FullName, I.SalesCount
FROM [Application].People AS P
	JOIN InvoicesCTE AS I
		ON P.PersonID = I.SalespersonPersonID;


WITH InvoicesCTE AS 
(
	SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101'
		AND InvoiceDate < '20150101' 
	GROUP BY SalespersonPersonID
),
InvoicesLinesCTE AS 
(
	SELECT Invoices.SalespersonPersonID, SUM(Lines.Quantity) AS TotalQuantity, SUM(Lines.Quantity*Lines.UnitPrice) AS TotalSumm
	FROM Sales.Invoices	
		JOIN Sales.InvoiceLines AS Lines
			ON Invoices.InvoiceID = Lines.InvoiceID
	GROUP BY Invoices.SalespersonPersonID
)
SELECT P.PersonID, P.FullName, I.SalesCount, L.TotalQuantity, L.TotalSumm
FROM [Application].People AS P
	JOIN InvoicesCTE AS I
		ON P.PersonID = I.SalespersonPersonID
	JOIN InvoicesLinesCTE AS L
		ON P.PersonID = L.SalespersonPersonID
ORDER BY L.TotalSumm DESC, I.SalesCount DESC;

WITH InvoicesCTE AS 
(
	SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101'
		AND InvoiceDate < '20150101' 
	GROUP BY SalespersonPersonID
),
InvoicesLinesCTE AS 
(
	SELECT Invoices.SalespersonPersonID, SUM(Lines.Quantity) AS TotalQuantity, SUM(Lines.Quantity*Lines.UnitPrice) AS TotalSumm
	FROM Sales.Invoices	
		JOIN Sales.InvoiceLines AS Lines
			ON Invoices.InvoiceID = Lines.InvoiceID
		JOIN InvoicesCTE AS sls
			ON sls.SalespersonPersonID = Invoices.SalespersonPersonID
	GROUP BY Invoices.SalespersonPersonID
)
SELECT P.PersonID, P.FullName, I.SalesCount, L.TotalQuantity, L.TotalSumm
FROM [Application].People AS P
	JOIN InvoicesCTE AS I
		ON P.PersonID = I.SalespersonPersonID
	JOIN InvoicesLinesCTE AS L
		ON P.PersonID = L.SalespersonPersonID
ORDER BY L.TotalSumm DESC, I.SalesCount DESC;

--delete CTE

DROP TABLE IF EXISTS Sales.Invoices_DeleteDemo;

select top 300 * into Sales.Invoices_DeleteDemo from Sales.Invoices;

SELECT TOP 10 InvoiceId
	FROM Sales.Invoices_DeleteDemo
	ORDER BY InvoiceID;

WITH OrdDelete AS
(	
	SELECT TOP 10 InvoiceId
	FROM Sales.Invoices_DeleteDemo
	ORDER BY InvoiceID
)
DELETE FROM OrdDelete;

SELECT TOP 10 InvoiceId
	FROM Sales.Invoices_DeleteDemo
	ORDER BY InvoiceID;
