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
    (NEXT VALUE FOR [Sequences].[CustomerID] ,N'Perseus Coleman' ,@MainCustomerId ,5 ,2 ,20 ,19 ,2 ,33 ,33 ,NULL ,CONVERT(date, '20200401') ,0 ,0 ,0 ,3 ,'(333) 555-0101' ,'(333) 555-0101' ,'' ,'' ,'http://www.morgantoys.com/PerseusColeman' ,'Perseus Coleman 101' ,'70 Kasesalu Street' ,90129 ,geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326) ,'PO Box 9101' ,'Abilene' ,90129 ,1),
    (NEXT VALUE FOR [Sequences].[CustomerID] ,N'Nelson Gray' ,@MainCustomerId ,5 ,2 ,20 ,19 ,2 ,33 ,33 ,NULL ,CONVERT(date, '20200401') ,0 ,0 ,0 ,3 ,'(333) 555-0102' ,'(333) 555-0102' ,'' ,'' ,'http://www.morgantoys.com/PerseusColeman' ,'Nelson Gray 102' ,'70 Nelson Street' ,90129 ,geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326) ,'PO Box 10101' ,'Abilene' ,90129 ,1),
    (NEXT VALUE FOR [Sequences].[CustomerID] ,N'Caden Wilson' ,@MainCustomerId ,5 ,2 ,18 ,19 ,2 ,33 ,33 ,NULL ,CONVERT(date, '20200401') ,0 ,0 ,0 ,7 ,'(333) 555-0103' ,'(333) 555-0105' ,'' ,'' ,'http://www.morgantoys.com/CadenWilson' ,'Caden Wilson 103' ,'70 Wilson Street' ,90129 ,geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326) ,'PO Box 10603' ,'Abilene' ,90129 ,1),
    (NEXT VALUE FOR [Sequences].[CustomerID] ,N'David Richardson' ,@MainCustomerId ,5 ,2 ,18 ,19 ,2 ,33 ,33 ,NULL ,CONVERT(date, '20200401') ,0 ,0 ,0 ,10 ,'(333) 555-0501' ,'(333) 555-0501' ,'' ,'' ,'http://www.morgantoys.com/DavidRichardson' ,'David Richardson 777' ,'34 Richardson Street' ,90129 ,geography::STGeomFromText('LINESTRING(-122.360 47.656, -122.343 47.656 )', 4326) ,'PO Box 3401' ,'Abilene' ,90129 ,1)



/*
	 2. удалите 1 запись из Customers, которая была вами добавлена
*/



GO
DELETE FROM [Sales].[Customers]
WHERE CustomerName = 'David Richardson' -- уникальное

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
        (SELECT CustomerID FROM Sales.Customers WHERE CustomerName = 'Nelson Gray') AS BillToCustomerID,
        (SELECT CustomerCategoryID FROM Sales.CustomerCategories WHERE CustomerCategoryName = 'Agent') AS CustomerCategoryID,
        (SELECT BuyingGroupID FROM [Sales].[BuyingGroups] WHERE BuyingGroupName = 'Wingtip Toys') AS BuyingGroupID,
        (SELECT PersonID FROM Application.People WHERE FullName = 'Jai Shand' ) AS PrimaryContactPersonID
    ) AS Data 
WHERE CustomerName = 'Caden Wilson'

/*
    4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE Sales.Customers AS [target]
USING(
    SELECT
    'Xanthos Washington' AS CustomerName
    ,(SELECT CustomerID FROM Sales.Customers WHERE CustomerName = 'Nelson Gray') AS BillToCustomerID
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
    [target].[CreditLimit] = [source]. ,
    [target].[AccountOpenedDate] = [source]. ,
    [target].[StandardDiscountPercentage] = [source]. ,
    [target].[IsStatementSent] = [source]. ,
    [target].[IsOnCreditHold] = [source]. ,
    [target].[PaymentDays] = [source]. ,
    [target].[PhoneNumber] = [source]. ,
    [target].[FaxNumber] = [source]. ,
    [target].[DeliveryRun] = [source]. ,
    [target].[RunPosition] = [source]. ,
    [target].[WebsiteURL] = [source]. ,
    [target].[DeliveryAddressLine1] = [source]. ,
    [target].[DeliveryAddressLine2] = [source]. ,
    [target].[DeliveryPostalCode] = [source]. ,
    [target].[DeliveryLocation] = [source]. ,
    [target].[PostalAddressLine1] = [source]. ,
    [target].[PostalAddressLine2] = [source]. ,
    [target].[PostalPostalCode] = [source]. ,
    [target].[LastEditedBy] = [source]. ,


WHEN NOT MATCHED BY TARGET
THEN INSERT
(
	   Id
	  ,[sagr]
      ,[nagr]
      ,[compl]
      ,[d_beg]
      ,[d_end]
      ,[c_term]
      ,[d_distr]
      ,[is_active1]
      ,[is_active2]
      ,[is_active3]
      ,[is_active4]
      ,[is_active5]
      ,[is_active6]
      ,[is_active7]
      ,[is_active8]
      ,[is_active9]
      ,[is_active10]
      ,[is_active11]
      ,[is_active12]
      ,[c_privileg]
      ,[c_discount]
      ,[zone]
      ,[b_m]
      ,[K1]
      ,[K2]
      ,[K3]
      ,[K4]
      ,[K5]
      ,[K6]
      ,[K7]
      ,[K8]
      ,[limit_life]
      ,[limit_prop]
      ,[franchise]
      ,[payment]
      ,[paym_bal]
      ,[note]
      ,[d_abort]
      ,[retpayment]
      ,[chng_sagr]
      ,[chng_nagr]
      ,[resident]
      ,[status_prs]
      ,[numb_ins]
      ,[f_name]
      ,[s_name]
      ,[p_name]
      ,[birth_date]
      ,[doc_name]
      ,[doc_series]
      ,[doc_no]
      ,[person_s]
      ,[c_city]
      ,[city_name]
      ,[ser_ins]
      ,[num_ins]
      ,[exprn_ins]
      ,[auto]
      ,[reg_no]
      ,[vin]
      ,[c_type]
      ,[c_mark]
      ,[mark_txt]
      ,[c_model]
      ,[model_txt]
      ,[prod_year]
      ,[sphere_use]
      ,[need_to]
      ,[date_next_to]
      ,[c_exp]
      ,[ErrorFlag]
      ,[LastModifiedDate]
	  ,[LoadedDate]
)
VALUES
(
[source].ProductId
,[source].[sagr]
,[source].[nagr]
,[source].[compl]
,[source].[d_beg]
,[source].[d_end]
,[source].[c_term]
,[source].[d_distr]
,[source].[is_active1]
,[source].[is_active2]
,[source].[is_active3]
,[source].[is_active4]
,[source].[is_active5]
,[source].[is_active6]
,[source].[is_active7]
,[source].[is_active8]
,[source].[is_active9]
,[source].[is_active10]
,[source].[is_active11]
,[source].[is_active12]
,[source].[c_privileg]
,[source].[c_discount]
,[source].[zone]
,[source].[b_m]
,[source].[K1]
,[source].[K2]
,[source].[K3]
,[source].[K4]
,[source].[K5]
,[source].[K6]
,[source].[K7]
,[source].[K8]
,[source].[limit_life]
,[source].[limit_prop]
,[source].[franchise]
,[source].[payment]
,[source].[paym_bal]
,[source].[note]
,[source].[d_abort]
,[source].[retpayment]
,[source].[chng_sagr]
,[source].[chng_nagr]
,[source].[resident]
,[source].[status_prs]
,[source].[numb_ins]
,[source].[f_name]
,[source].[s_name]
,[source].[p_name]
,[source].[birth_date]
,[source].[doc_name]
,[source].[doc_series]
,[source].[doc_no]
,[source].[person_s]
,[source].[c_city]
,[source].[city_name]
,[source].[ser_ins]
,[source].[num_ins]
,[source].[exprn_ins]
,[source].[auto]
,[source].[reg_no]
,[source].[vin]
,[source].[c_type]
,[source].[c_mark]
,[source].[mark_txt]
,[source].[c_model]
,[source].[model_txt]
,[source].[prod_year]
,[source].[sphere_use]
,[source].[need_to]
,[source].[date_next_to]
,[source].[c_exp]
,[source].[ErrorFlag]
,[source].[LastModifiedDate]
,current_timestamp
);


