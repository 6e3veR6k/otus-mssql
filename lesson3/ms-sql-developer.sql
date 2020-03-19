use WideWorldImporters
/*
    Для всех заданий где возможно, сделайте 2 варианта запросов:
    1) через вложенный запрос
    2) через WITH (для производных таблиц)
*/
-- 1. Выберите сотрудников, которые являются продажниками, и еще не сделали ни одной продажи.

select P.PersonID, P.FullName
from Application.People as P
left join (select distinct I.SalespersonPersonID from Sales.Invoices as I ) as T on T.SalespersonPersonID = P.PersonID
where P.IsSalesperson = 1
and T.SalespersonPersonID is null


select P.PersonID, P.FullName
from Application.People as P
where P.IsSalesperson = 1
and not exists (select 1 from Sales.Invoices as I where I.SalespersonPersonID = P.PersonID )


;with SalesPersonFromInvoices as
(
    select distinct I.SalespersonPersonID from Sales.Invoices as I
)
select P.PersonID, P.FullName
from Application.People as P
left join SalesPersonFromInvoices as T on T.SalespersonPersonID = P.PersonID
where P.IsSalesperson = 1




-- 2. Выберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса.
select 
    I.StockItemID, 
    I.StockItemName,
    I.UnitPrice
from Warehouse.StockItems as I
where I.UnitPrice = (select min(SI.UnitPrice) from Warehouse.StockItems as SI)


select 
    I.StockItemID, 
    I.StockItemName,
    I.UnitPrice
from Warehouse.StockItems as I
where I.UnitPrice <= ALL (select SI.UnitPrice from Warehouse.StockItems as SI)


;with MinPriceCTE
as
(
    select min(SI.UnitPrice) as MinPrice from Warehouse.StockItems as SI
)
select
    I.StockItemID,
    I.StockItemName,
    I.UnitPrice
from Warehouse.StockItems as I
inner join MinPriceCTE as M on M.MinPrice = I.UnitPrice

-- 3. Выберите информацию по клиентам, которые перевели компании 5 максимальных платежей из [Sales].[CustomerTransactions] представьте 3 способа (в том числе с CTE)
select distinct C.CustomerID,
    C.CustomerName
from Sales.Customers as C
inner join
    (select
        top 5 CT.CustomerID, CT.TransactionAmount
    from Sales.CustomerTransactions as CT
    order by CT.TransactionAmount desc
    ) as CT on CT.CustomerID = C.CustomerID


select C.CustomerID,
    C.CustomerName
from Sales.Customers as C
where C.CustomerID in (select
        top 5 CT.CustomerID
    from Sales.CustomerTransactions as CT
    order by CT.TransactionAmount desc)


;with Top5CTE as 
(
    select
        top 5 CT.CustomerID
    from Sales.CustomerTransactions as CT
    order by CT.TransactionAmount desc
)
select
    distinct C.CustomerID,
    C.CustomerName
from Sales.Customers as C
inner join Top5CTE as T on T.CustomerID = C.CustomerID


-- 4. Выберите города (ид и название), в которые были доставлены товары, входящие в тройку самых дорогих товаров, а также Имя сотрудника, который осуществлял упаковку заказов
-- входящие в тройку самых дорогих товаров

select 
    distinct C.DeliveryCityID,
    AC.CityName,
    P.PersonID,
    P.FullName
from Sales.Invoices as I
inner join Sales.Customers as C on C.CustomerID = I.CustomerID
inner join Sales.InvoiceLines as L on L.InvoiceID = I.InvoiceID
inner join Application.Cities as AC on AC.CityID = C.DeliveryCityID
inner join Application.People as P on P.PersonID = I.PackedByPersonID
where L.StockItemID in (select top 3 StockItemID from Warehouse.StockItems order by UnitPrice desc)


;with Top3CTE as
(
    select top 3 StockItemID from Warehouse.StockItems order by UnitPrice desc
)
select 
    distinct C.DeliveryCityID,
    AC.CityName,
    P.PersonID,
    P.FullName
from Sales.Invoices as I
inner join Sales.Customers as C on C.CustomerID = I.CustomerID
inner join Sales.InvoiceLines as L on L.InvoiceID = I.InvoiceID
inner join Application.Cities as AC on AC.CityID = C.DeliveryCityID
inner join Application.People as P on P.PersonID = I.PackedByPersonID
inner join Top3CTE on Top3CTE.StockItemID = L.StockItemID


/* 5. Объясните, что делает и оптимизируйте запрос:
Приложите план запроса
и его анализ, а также ход ваших рассуждений по поводу оптимизации.
Можно двигаться как в сторону улучшения читабельности запроса
(что уже было в материале лекций), так и в сторону упрощения плана\ускорения. */

SELECT
    Invoices.InvoiceID,
    Invoices.InvoiceDate,
    (SELECT People.FullName FROM Application.People WHERE People.PersonID = Invoices.SalespersonPersonID) AS SalesPersonName, -- продавец
    SalesTotals.TotalSumm AS TotalSummByInvoice,
    (SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) --общая сума заказа (кол-ство * цену за штуку)
    FROM Sales.OrderLines
    WHERE OrderLines.OrderId = (SELECT Orders.OrderId
                                FROM Sales.Orders
                                WHERE Orders.PickingCompletedWhen IS NOT NULL -- все собраные заказы
                                    AND Orders.OrderId = Invoices.OrderId)
                                ) AS TotalSummForPickedItems
FROM Sales.Invoices
JOIN(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
    FROM Sales.InvoiceLines
    GROUP BY InvoiceId
    HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
    ON Invoices.InvoiceID = SalesTotals.InvoiceID -- все инвойсы у которых сума заказа больше 27000
ORDER BY TotalSumm DESC

-- запрос выбирает invoice и имя продавца который продал товара на общую суму invoice больше 27000, и отображает суму по уже собраным заказам из инвойса
-- выбирает все платежки по продавцам у которых сума по платежке больше 27000, и показываем общую сумму по платежке и суму по уже собраному заказу из которого сделали платежку.
 
-- set STATISTICS IO, time on
;with SalesTotalCTE as (
    SELECT 
        InvoiceId, 
        SUM(Quantity*UnitPrice) AS TotalSumm
    FROM Sales.InvoiceLines
    GROUP BY InvoiceId
    HAVING SUM(Quantity*UnitPrice) > 27000
),
OrderSumCTE as (
    SELECT 
        SUM(OL.PickedQuantity*OL.UnitPrice) AS TotalSummForPickedItems,
        OL.OrderID
    FROM Sales.OrderLines AS OL
    INNER JOIN Sales.Orders as O ON O.OrderID = OL.OrderID
    WHERE O.PickingCompletedWhen IS NOT NULL
    GROUP by OL.OrderID
)
SELECT
    I.InvoiceID,
    I.InvoiceDate,
    P.FullName AS SalesPersonName,
    SalesTotals.TotalSumm AS TotalSummByInvoice,
    OrderSumCTE.TotalSummForPickedItems AS TotalSummForPickedItems
FROM Sales.Invoices AS I
INNER JOIN Application.People AS P ON P.PersonID = I.SalespersonPersonID
INNER JOIN SalesTotalCTE AS SalesTotals ON I.InvoiceID = SalesTotals.InvoiceID
INNER JOIN OrderSumCTE ON OrderSumCTE.OrderID = I.OrderID
ORDER BY TotalSumm DESC
