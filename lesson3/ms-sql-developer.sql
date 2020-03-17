/*
    Для всех заданий где возможно, сделайте 2 варианта запросов:
    1) через вложенный запрос
    2) через WITH (для производных таблиц)
*/
-- 1. Выберите сотрудников, которые являются продажниками, и еще не сделали ни одной продажи.

select *
from Application.People as P
where P.IsSalesperson = 1


select *
from Sales.Orders as O
inner join Sales.Invoices as I on I.OrderID = O.OrderID
inner join Sales.CustomerTransactions as CT on CT.InvoiceID = I.InvoiceID
inner join Application.TransactionTypes as TT on TT.TransactionTypeID = CT.TransactionTypeID

-- 2. Выберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса.
-- 3. Выберите информацию по клиентам, которые перевели компании 5 максимальных платежей из [Sales].[CustomerTransactions] представьте 3 способа (в том числе с CTE)
-- 4. Выберите города (ид и название), в которые были доставлены товары, входящие в тройку самых дорогих товаров, а также Имя сотрудника, который осуществлял упаковку заказов
/* 5. Объясните, что делает и оптимизируйте
запрос:
SELECT
    Invoices.InvoiceID,
    Invoices.InvoiceDate,
    (SELECT People.FullName
    FROM Application.People
    WHERE People.PersonID = Invoices.SalespersonPersonID
) AS SalesPersonName,
    SalesTotals.TotalSumm AS TotalSummByInvoice,
    (SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
    FROM Sales.OrderLines
    WHERE OrderLines.OrderId = (SELECT Orders.OrderId
    FROM Sales.Orders
    WHERE Orders.PickingCompletedWhen IS NOT NULL
        AND Orders.OrderId = Invoices.OrderId)
) AS TotalSummForPickedItems
FROM Sales.Invoices
    JOIN
    (SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
    FROM Sales.InvoiceLines
    GROUP BY InvoiceId
    HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
    ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

Приложите план запроса
и его анализ, а также ход ваших рассуждений по поводу оптимизации.
Можно двигаться как в сторону улучшения читабельности запроса
(что уже было в материале лекций), так и в сторону упрощения плана\ускорения. */