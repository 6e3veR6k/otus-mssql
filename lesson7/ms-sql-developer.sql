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
    ([CustomerName]
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
    ( N'Nixins Morgan'
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
, 'Nixins Morgan 102'
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
where CustomerName = 'Nixins Morgan'


INSERT INTO [Sales].[Customers]
    ([CustomerName]
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
    (N'Perseusis Coleman' ,@MainCustomerId ,5 ,2 ,20 ,19 ,2 ,33 ,33 ,NULL ,CONVERT(date, '20200401') ,0 ,0 ,0 ,3 ,'(333) 555-0101' ,'(333) 555-0101' ,'' ,'' ,'http://www.morgantoys.com/PerseusColeman' ,'Perseus Coleman 101' ,'70 Kasesalu Street' ,90129 ,geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326) ,'PO Box 9101' ,'Abilene' ,90129 ,1),
    (N'Nelsonis Gray' ,@MainCustomerId ,5 ,2 ,20 ,19 ,2 ,33 ,33 ,NULL ,CONVERT(date, '20200401') ,0 ,0 ,0 ,3 ,'(333) 555-0102' ,'(333) 555-0102' ,'' ,'' ,'http://www.morgantoys.com/PerseusColeman' ,'Nelson Gray 102' ,'70 Nelson Street' ,90129 ,geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326) ,'PO Box 10101' ,'Abilene' ,90129 ,1),
    (N'Cadenis Wilson' ,@MainCustomerId ,5 ,2 ,18 ,19 ,2 ,33 ,33 ,NULL ,CONVERT(date, '20200401') ,0 ,0 ,0 ,7 ,'(333) 555-0103' ,'(333) 555-0105' ,'' ,'' ,'http://www.morgantoys.com/CadenWilson' ,'Caden Wilson 103' ,'70 Wilson Street' ,90129 ,geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326) ,'PO Box 10603' ,'Abilene' ,90129 ,1),
    (N'Davidus Richardson' ,@MainCustomerId ,5 ,2 ,18 ,19 ,2 ,33 ,33 ,NULL ,CONVERT(date, '20200401') ,0 ,0 ,0 ,10 ,'(333) 555-0501' ,'(333) 555-0501' ,'' ,'' ,'http://www.morgantoys.com/DavidRichardson' ,'David Richardson 777' ,'34 Richardson Street' ,90129 ,geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326) ,'PO Box 3401' ,'Abilene' ,90129 ,1)



/*
	 2. удалите 1 запись из Customers, которая была вами добавлена
*/



GO
DELETE FROM [Sales].[Customers]
WHERE CustomerName = 'Davidus Richardson' -- уникальное

/*
	3. изменить одну запись, из добавленных через UPDATE
*/

UPDATE Sales.Customers
SET
    BillToCustomerID = Data.BillToCustomerID,
    CustomerCategoryID = Data.CustomerCategoryID,
    BuyingGroupID = Data.BuyingGroupID,
    PrimaryContactPersonID = Data.PrimaryContactPersonID
FROM
    (SELECT 
        (SELECT CustomerID FROM Sales.Customers WHERE CustomerName = 'Nelsonis Gray') AS BillToCustomerID,
        (SELECT CustomerCategoryID FROM Sales.CustomerCategories WHERE CustomerCategoryName = 'Agent') AS CustomerCategoryID,
        (SELECT BuyingGroupID FROM [Sales].[BuyingGroups] WHERE BuyingGroupName = 'Wingtip Toys') AS BuyingGroupID,
        (SELECT PersonID FROM Application.People WHERE FullName = 'Jai Shand' ) AS PrimaryContactPersonID
    ) AS Data 
WHERE CustomerName = 'Cadenis Wilson'

/*
    4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE Sales.Customers AS [target]
USING(
    SELECT
        'Xanthos Washingtons' AS CustomerName
        ,(SELECT CustomerID FROM Sales.Customers WHERE CustomerName = 'Nelsonis Gray') AS BillToCustomerID
        ,(SELECT CustomerCategoryID FROM Sales.CustomerCategories WHERE CustomerCategoryName = 'Agent') AS CustomerCategoryID
        ,(SELECT BuyingGroupID FROM [Sales].[BuyingGroups] WHERE BuyingGroupName = 'Wingtip Toys') AS BuyingGroupID
        ,(SELECT PersonID FROM Application.People WHERE FullName = 'Jai Shand' ) AS PrimaryContactPersonID
        ,(SELECT PersonID FROM Application.People WHERE FullName = 'Stella Rosenhain' ) AS AlternateContactPersonID
        ,(SELECT DeliveryMethodID FROM Application.DeliveryMethods WHERE [DeliveryMethodName] = 'Courier' ) AS DeliveryMethodID
        ,(SELECT CityID FROM Application.Cities WHERE CityName = 'Abbeville' AND StateProvinceID = 42 ) AS DeliveryCityID
        ,(SELECT CityID FROM Application.Cities WHERE CityName = 'Abbeville' AND StateProvinceID = 42 ) AS PostalCityID
        ,NULL AS CreditLimit
        ,CURRENT_TIMESTAMP AccountOpenedDate
        ,0 AS StandardDiscountPercentage
        ,0 AS IsStatementSent
        ,0 AS IsOnCreditHold
        ,7 AS PaymentDays
        ,'(316) 555-0100' AS PhoneNumber
        ,'(316) 555-0101' AS FaxNumber
        ,'' AS DeliveryRun
        ,'' AS RunPosition
        ,'http://www.morgantoys.com/XanthosWashington' AS WebsiteURL
        ,'XanthosWashingtonShop' AS DeliveryAddressLine1
        ,'967 Xanthos Washington' AS DeliveryAddressLine2
        ,'90152' AS DeliveryPostalCode
        ,geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326) AS DeliveryLocation
        ,'PO Box 967' AS PostalAddressLine1
        ,'Abbeville' AS PostalAddressLine2
        ,'90216' AS PostalPostalCode

) AS [source]
ON ([source].CustomerName = [target].CustomerName)
WHEN MATCHED
THEN UPDATE
SET
    [target].[BillToCustomerID] = [source].[BillToCustomerID],
    [target].[CustomerCategoryID] = [source].[CustomerCategoryID] ,
    [target].[BuyingGroupID] = [source].[BuyingGroupID] ,
    [target].[PrimaryContactPersonID] = [source].[PrimaryContactPersonID],
    [target].[AlternateContactPersonID] = [source].[AlternateContactPersonID] ,
    [target].[DeliveryMethodID] = [source].[DeliveryMethodID] ,
    [target].[DeliveryCityID] = [source].[DeliveryCityID] ,
    [target].[PostalCityID] = [source].[PostalCityID] ,
    [target].[CreditLimit] = [source].[CreditLimit] ,
    [target].[AccountOpenedDate] = [source].[AccountOpenedDate] ,
    [target].[StandardDiscountPercentage] = [source].[StandardDiscountPercentage] ,
    [target].[IsStatementSent] = [source].[IsStatementSent] ,
    [target].[IsOnCreditHold] = [source].[IsOnCreditHold] ,
    [target].[PaymentDays] = [source].[PaymentDays] ,
    [target].[PhoneNumber] = [source].[PhoneNumber] ,
    [target].[FaxNumber] = [source].[FaxNumber] ,
    [target].[DeliveryRun] = [source].[DeliveryRun] ,
    [target].[RunPosition] = [source].[RunPosition] ,
    [target].[WebsiteURL] = [source].[WebsiteURL] ,
    [target].[DeliveryAddressLine1] = [source].[DeliveryAddressLine1] ,
    [target].[DeliveryAddressLine2] = [source].[DeliveryAddressLine2] ,
    [target].[DeliveryPostalCode] = [source].[DeliveryPostalCode] ,
    [target].[DeliveryLocation] = [source].[DeliveryLocation] ,
    [target].[PostalAddressLine1] = [source].[PostalAddressLine1] ,
    [target].[PostalAddressLine2] = [source].[PostalAddressLine2] ,
    [target].[PostalPostalCode] = [source].[PostalPostalCode] ,
    [target].[LastEditedBy] = 1


WHEN NOT MATCHED BY TARGET
THEN INSERT
(
    
    [CustomerName]
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
    ,[LastEditedBy]
)
VALUES
(
    [source].[CustomerName],
    [source].[BillToCustomerID],
    [source].[CustomerCategoryID] ,
    [source].[BuyingGroupID] ,
    [source].[PrimaryContactPersonID],
    [source].[AlternateContactPersonID] ,
    [source].[DeliveryMethodID] ,
    [source].[DeliveryCityID] ,
    [source].[PostalCityID] ,
    [source].[CreditLimit] ,
    [source].[AccountOpenedDate] ,
    [source].[StandardDiscountPercentage] ,
    [source].[IsStatementSent] ,
    [source].[IsOnCreditHold] ,
    [source].[PaymentDays] ,
    [source].[PhoneNumber] ,
    [source].[FaxNumber] ,
    [source].[DeliveryRun] ,
    [source].[RunPosition] ,
    [source].[WebsiteURL] ,
    [source].[DeliveryAddressLine1] ,
    [source].[DeliveryAddressLine2] ,
    [source].[DeliveryPostalCode] ,
    [source].[DeliveryLocation] ,
    [source].[PostalAddressLine1] ,
    [source].[PostalAddressLine2] ,
    [source].[PostalPostalCode] ,
    1
);


