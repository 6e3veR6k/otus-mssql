/*** Напишите выборки для того, чтобы получить:  ***/
-- 1. Все товары, в которых в название есть пометка urgent или название начинается с Animal
go
select 
    StockItemID, 
    StockItemName
from Warehouse.StockItems
where 
    StockItemName like '%urgent%' 
    or 
    StockItemName like 'Animal%'


-- 2. Поставщиков, у которых не было сделано ни одного заказа (потом покажем как это делать 
--    через подзапрос, сейчас сделайте через JOIN)
go
select 
    S.SupplierID,
    S.SupplierName 
from Purchasing.Suppliers as S
left join Purchasing.PurchaseOrders as PO on PO.SupplierID = S.SupplierID
where PO.SupplierID is null


-- 3. Продажи с названием месяца, в котором была продажа, номером квартала, к которому относится 
--    продажа, включите также к какой трети года относится дата - каждая треть по 4 месяца, дата 
--    забора заказа должна быть задана, с ценой товара более 100$ либо количество единиц товара 
--    более 20. Добавьте вариант этого запроса с постраничной выборкой пропустив первую 1000 и 
--    отобразив следующие 100 записей. Соритровка должна быть по номеру квартала, трети года, дате продажи.
go
select 
    O.OrderID,
    O.OrderDate as SaleDate, 
    DATEPART(QUARTER, O.OrderDate) as Quarter,
    case
        when DATEPART(MONTH, O.OrderDate) >= 8 then 3
        when DATEPART(MONTH, O.OrderDate) >= 4 then 2
    else 1 
    end as Third,
    sum(OL.UnitPrice) as OrderPrice,
    sum(OL.Quantity) as ItemsQuantity
from Sales.Orders as O
inner join Sales.OrderLines as OL on OL.OrderID = O.OrderID
where OL.UnitPrice > 100
group by O.OrderID, O.OrderDate, DATEPART(QUARTER, O.OrderDate)
having sum(OL.Quantity) > 20
order by Quarter, Third, SaleDate
offset 1000 rows fetch next 100 rows only

-- 4. Заказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post,
--    добавьте название поставщика, имя контактного лица принимавшего заказ
go
select
    PO.PurchaseOrderID,  
    S.SupplierName, 
    P.FullName
from Purchasing.PurchaseOrders as PO
inner join Purchasing.Suppliers as S on S.SupplierID = PO.SupplierID
inner join Application.People as P on P.PersonID = S.PrimaryContactPersonID 
where 
    datepart(year, PO.OrderDate) = 2014
    and
    (PO.DeliveryMethodID = 7 or PO.DeliveryMethodID = 1)


-- 5. 10 последних по дате продаж с именем клиента и именем сотрудника, который оформил заказ.
go
select
    top 10 OrderID, 
    C.CustomerName, 
    P.FullName as SalesPersonName
from Sales.Orders as O
inner join Sales.Customers as C on C.CustomerID = O.CustomerID
inner join Application.People as P on P.PersonID = O.SalespersonPersonID
order by OrderDate desc


-- 6. Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g
go
select
    C.CustomerID,
    C.CustomerName,
    C.PhoneNumber
from Sales.Customers as C
inner join Sales.Orders as O on O.CustomerID = C.CustomerID
inner join Sales.OrderLines as OL on OL.OrderID = O.OrderID
where [Description] like 'Chocolate frogs 250g'
