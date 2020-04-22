USE WideWorldImporters;

INSERT INTO Warehouse.Colors
	(ColorId, ColorName, LastEditedBy)
VALUES
	(NEXT VALUE FOR Sequences.ColorID, 'Ohra', 1);

INSERT INTO Warehouse.Colors
	(ColorId, ColorName, LastEditedBy)
VALUES
	(NEXT VALUE FOR Sequences.ColorID, 'Ohra3', 1),
	(NEXT VALUE FOR Sequences.ColorID, 'Ohra4', 1);

select *
FROM Warehouse.Colors
ORDER BY ColorName;

Declare 
	@colorId INT, 
	@LastEditedBySystemUser INT,
	@SystemUserName NVARCHAR(50) = 'Data Conversion Only'
		
SET @colorId = NEXT VALUE FOR Sequences.ColorID;

SELECT @LastEditedBySystemUser = PersonID
FROM [Application].People
WHERE FullName = @SystemUserName

INSERT INTO Warehouse.Colors
	(ColorId, ColorName, LastEditedBy)
VALUES
	(@colorId, 'Ohra2', @LastEditedBySystemUser);

select TOP 1 ColorId, ColorName, LastEditedBy into Warehouse.Color_Copy2
from Warehouse.Colors;
--DROP TABLE Warehouse.Color_Copy

INSERT INTO Warehouse.Colors
		(ColorId, ColorName, LastEditedBy)
	OUTPUT inserted.ColorId, inserted.ColorName, inserted.LastEditedBy 
		INTO Warehouse.Color_Copy (ColorId, ColorName, LastEditedBy)
	OUTPUT inserted.ColorId
	VALUES
		(NEXT VALUE FOR Sequences.ColorID,'Dark Blue', 1), 
		(NEXT VALUE FOR Sequences.ColorID,'Light Blue', 1);

SELECT @@ROWCOUNT;

SELECT *
FROM Warehouse.Color_Copy
WHERE ColorId IN (82,83);

USE AdventureWorks2017;

begin tran
INSERT INTO person.address
(addressline1, addressline2, city, stateprovinceid, postalcode)
VALUES('67231224qwe Kingsway', '', 'Burnaby', 7, 'V5H 327');

SELECT @@IDENTITY, SCOPE_IDENTITY();
commit tran


SELECT top 1 * into Sales.Invoices_Q12016
FROM Sales.Invoices
WHERE InvoiceDate >= '2016-01-01' 
	AND InvoiceDate < '2016-04-01';

-- delete from Warehouse.Colors where ColorName = 'Ohra';
-- delete from Warehouse.Colors where ColorName = 'Ohra2';
-- delete from Warehouse.Colors where ColorName = 'Dark Blue';
-- delete from Warehouse.Colors where ColorName = 'Light Blue';
-- delete from person.address where AddressId = 
-- drop table Sales.Invoices_Q12016;
--Alter table Sales.Invoices DROP COLUMN [InvoiceConfirmedForProcessing];

TRUNCATE TABLE Sales.Invoices_Q12016;


INSERT INTO Sales.Invoices_Q12016
SELECT TOP (5) 
	InvoiceID
	,CustomerID
	,BillToCustomerID 
	,OrderID + 1000 AS OrderId
	,DeliveryMethodID
	,ContactPersonID
	,AccountsPersonID
	,SalespersonPersonID
	,PackedByPersonID
	,InvoiceDate
	,CustomerPurchaseOrderNumber
	,IsCreditNote
	,CreditNoteReason
	,Comments
	,DeliveryInstructions
	,InternalComments
	,TotalDryItems
	,TotalChillerItems
	,DeliveryRun
	,RunPosition
	,ReturnedDeliveryData
	,[ConfirmedDeliveryTime]
	,[ConfirmedReceivedBy]
	,LastEditedBy
	,GETDATE()
FROM Sales.Invoices
WHERE InvoiceDate >= '2016-01-01' 
	AND InvoiceDate < '2016-04-01'
ORDER BY InvoiceID;
 
INSERT INTO Sales.Invoices_Q12016
	(InvoiceID
	,CustomerID
	,BillToCustomerID
	,OrderID 
	,DeliveryMethodID
	,ContactPersonID
	,AccountsPersonID
	,SalespersonPersonID
	,PackedByPersonID
	,InvoiceDate
	,CustomerPurchaseOrderNumber
	,IsCreditNote
	,CreditNoteReason
	,Comments
	,DeliveryInstructions
	,InternalComments
	,TotalDryItems
	,TotalChillerItems
	,DeliveryRun
	,RunPosition
	,ReturnedDeliveryData
	,[ConfirmedDeliveryTime]
	,[ConfirmedReceivedBy]
	,LastEditedBy
	,LastEditedWhen)
SELECT TOP (5) 
	InvoiceID
	,CustomerID
	,BillToCustomerID
	,OrderID + 1000 
	,DeliveryMethodID
	,ContactPersonID
	,AccountsPersonID
	,SalespersonPersonID
	,PackedByPersonID
	,InvoiceDate
	,CustomerPurchaseOrderNumber
	,IsCreditNote
	,CreditNoteReason
	,Comments
	,DeliveryInstructions
	,InternalComments
	,TotalDryItems
	,TotalChillerItems
	,DeliveryRun
	,RunPosition
	,ReturnedDeliveryData
	,[ConfirmedDeliveryTime]
	,[ConfirmedReceivedBy]
	,LastEditedBy
	,GETDATE()
FROM Sales.Invoices
WHERE InvoiceDate >= '2016-01-01' 
	AND InvoiceDate < '2016-04-01'
ORDER BY InvoiceID;


INSERT INTO Sales.Invoices_Q12016
	(InvoiceID
	,CustomerID
	,BillToCustomerID
	,OrderID 
	,DeliveryMethodID
	,ContactPersonID
	,AccountsPersonID
	,SalespersonPersonID
	,PackedByPersonID
	,InvoiceDate
	,CustomerPurchaseOrderNumber
	,IsCreditNote
	,CreditNoteReason
	,Comments
	,DeliveryInstructions
	,InternalComments
	,TotalDryItems
	,TotalChillerItems
	,DeliveryRun
	,RunPosition
	,ReturnedDeliveryData
	,[ConfirmedDeliveryTime]
	,[ConfirmedReceivedBy]
	,LastEditedBy
	,LastEditedWhen)
EXEC Sales.GetNewInvoices @batchsize = 10


SELECT *
FROM Sales.Invoices_Q12016
ORDER BY LastEditedWhen DESC;