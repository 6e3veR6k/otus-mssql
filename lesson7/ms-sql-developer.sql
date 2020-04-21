/*
1. Довставлять в базу 5 записей используя insert в таблицу Customers или Suppliers
2. удалите 1 запись из Customers, которая была вами добавлена
3. изменить одну запись, из добавленных через UPDATE
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/


USE [WideWorldImporters]

GO
/*
	1. Довставлять в базу 5 записей используя insert в таблицу Customers или Suppliers
*/

INSERT INTO [Sales].[Customers]
    ([CustomerID]
    ,[CustomerName]
    ,[BillToCustomerID]
    ,[CustomerCategoryID]
    ,[BuyingGroupID]
    ,[PrimaryContactPersonID]
    ,[AlternateContactPersonID]
    ,[DeliveryMethodID]
    ,[DeliveryCityID]
    ,[PostalCityID]
    ,[CreditLimit]
    ,[AccountOpenedDate]
    ,[StandardDiscountPercentage]
    ,[IsStatementSent]
    ,[IsOnCreditHold]
    ,[PaymentDays]
    ,[PhoneNumber]
    ,[FaxNumber]
    ,[DeliveryRun]
    ,[RunPosition]
    ,[WebsiteURL]
    ,[DeliveryAddressLine1]
    ,[DeliveryAddressLine2]
    ,[DeliveryPostalCode]
    ,[DeliveryLocation]
    ,[PostalAddressLine1]
    ,[PostalAddressLine2]
    ,[PostalPostalCode]
    ,[LastEditedBy])
VALUES
    (NEXT VALUE FOR [Sequences].[CustomerID]
, N'Nixon Morgan'
, NEXT VALUE FOR [Sequences].[CustomerID]
, 5
, 2
, 20
, 19
, 2
, 33
, 33
, NULL
, CONVERT(date, '20200401')
, 0
, 0
, 0
, 3
, '(333) 555-0100'
, '(333) 555-0100'
, ''
, ''
, 'http://www.morgantoys.com/NixonMorgan'
, 'Nixon Morgan 102'
, '25 Kasesalu Street'
, 90129
, geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326)
, 'PO Box 8102'
, 'Abilene'
, 90129
, 1)
GO

declare @MainCustomerId int;
select @MainCustomerId = CustomerID
from [Sales].[Customers]
where CustomerName = 'Nixon Morgan'


INSERT INTO [Sales].[Customers]
    ([CustomerID]
    ,[CustomerName]
    ,[BillToCustomerID]
    ,[CustomerCategoryID]
    ,[BuyingGroupID]
    ,[PrimaryContactPersonID]
    ,[AlternateContactPersonID]
    ,[DeliveryMethodID]
    ,[DeliveryCityID]
    ,[PostalCityID]
    ,[CreditLimit]
    ,[AccountOpenedDate]
    ,[StandardDiscountPercentage]
    ,[IsStatementSent]
    ,[IsOnCreditHold]
    ,[PaymentDays]
    ,[PhoneNumber]
    ,[FaxNumber]
    ,[DeliveryRun]
    ,[RunPosition]
    ,[WebsiteURL]
    ,[DeliveryAddressLine1]
    ,[DeliveryAddressLine2]
    ,[DeliveryPostalCode]
    ,[DeliveryLocation]
    ,[PostalAddressLine1]
    ,[PostalAddressLine2]
    ,[PostalPostalCode]
    ,[LastEditedBy])
VALUES
    (NEXT VALUE FOR [Sequences].[CustomerID]
, N'Perseus Coleman'
, @MainCustomerId
, 5
, 2
, 20
, 19
, 2
, 33
, 33
, NULL
, CONVERT(date, '20200401')
, 0
, 0
, 0
, 3
, '(333) 555-0101'
, '(333) 555-0101'
, ''
, ''
, 'http://www.morgantoys.com/PerseusColeman'
, 'Perseus Coleman 101'
, '70 Kasesalu Street'
, 90129
, geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326)
, 'PO Box 9101'
, 'Abilene'
, 90129
, 1),
    (NEXT VALUE FOR [Sequences].[CustomerID]
, N'Nelson Gray'
, @MainCustomerId
, 5
, 2
, 20
, 19
, 2
, 33
, 33
, NULL
, CONVERT(date, '20200401')
, 0
, 0
, 0
, 3
, '(333) 555-0102'
, '(333) 555-0102'
, ''
, ''
, 'http://www.morgantoys.com/PerseusColeman'
, 'Nelson Gray 102'
, '70 Nelson Street'
, 90129
, geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326)
, 'PO Box 10101'
, 'Abilene'
, 90129
, 1),
    (NEXT VALUE FOR [Sequences].[CustomerID]
, N'Caden Wilson'
, @MainCustomerId
, 5
, 2
, 18
, 19
, 2
, 33
, 33
, NULL
, CONVERT(date, '20200401')
, 0
, 0
, 0
, 7
, '(333) 555-0103'
, '(333) 555-0105'
, ''
, ''
, 'http://www.morgantoys.com/CadenWilson'
, 'Caden Wilson 103'
, '70 Wilson Street'
, 90129
, geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326)
, 'PO Box 10603'
, 'Abilene'
, 90129
, 1),
    (NEXT VALUE FOR [Sequences].[CustomerID]
, N'David Richardson'
, @MainCustomerId
, 5
, 2
, 18
, 19
, 2
, 33
, 33
, NULL
, CONVERT(date, '20200401')
, 0
, 0
, 0
, 10
, '(333) 555-0501'
, '(333) 555-0501'
, ''
, ''
, 'http://www.morgantoys.com/DavidRichardson'
, 'David Richardson 777'
, '34 Richardson Street'
, 90129
, geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326)
, 'PO Box 3401'
, 'Abilene'
, 90129
, 1)



/*
	 2. удалите 1 запись из Customers, которая была вами добавлена
*/



GO
DELETE FROM [Sales].[Customers]
WHERE CustomerName LIKE 'David Richardson'

/*
	3. изменить одну запись, из добавленных через UPDATE
*/

UPDATE Sales.Customers
SET BillToCustomerID = ''
FROM