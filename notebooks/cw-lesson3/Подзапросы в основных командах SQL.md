# Подзапросы в основных командах SQL

## Подзапросы в SELECT
В выражении SELECT мы можем вводить подзапросы четырьмя способами:

- Использовать в условии в выражении WHERE
- Использовать в условии в выражении HAVING
- Использовать в качестве таблицы для выборки в выражении FROM
- Использовать в качестве спецификации столбца в выражении SELECT

Рассмотрим некоторые из этих случаев. Например, получим все товары, у которых цена выше средней:
```sql
SELECT *
FROM Products
WHERE Price > (SELECT AVG(Price) FROM Products)
```

Чтобы получить нужные товары, нам вначале надо выполнить подзапрос на получение средней цены товара: SELECT AVG(Price) FROM Products.

Или выберем всех покупателей из таблицы Customers, у которых нет заказов в таблице Orders:

```sql
SELECT * FROM CUSTOMERS
WHERE Id NOT IN (SELECT CustomerId FROM Orders)
```

Хотя в данном случае подзапросы прекрасно справляются со своей задачей, стоит отметить, что это не самый эффективный способ для извлечения данных из других таблиц, так как в рамках T-SQL для сведения данных из разных таблиц можно использовать оператор JOIN, который рассматривается в следующей теме.

## Получение набора значений

При использовании в операторах сравнения подзапросы должны возвращать одно скалярное значение. Но иногда возникает необходимость получить набор значений. Чтобы при использовании в операторах сравнения подзапрос мог возвращать набор значений, перед ним необходимо использовать один из операторов: ALL, SOME или ANY.

При использовании ключевого слова ALL условие в операции сравнения должно быть верно для всех значений, которые возвращаются подзапросом. Например, найдем все товары, цена которых меньше чем у любого товара фирмы Apple:

```sql
SELECT * FROM Products
WHERE Price < ALL(SELECT Price FROM Products WHERE Manufacturer='Apple')
```

Если бы мы в данном случае опустили бы ключевое слово ALL, то мы бы столкнулись с ошибкой.

Допустим, если подзапрос возвращает значения vl1, val2 и val3, то условие фильтрации фактически было бы аналогично объединению этих значений через оператор AND:

```sql 
WHERE Price < val1 AND Price < val2 AND Price < val3
```

В тоже время подобный запрос гораздо проще переписать другим образом:

```sql
SELECT * FROM Products
WHERE Price < (SELECT MIN(Price) FROM Products WHERE Manufacturer='Apple')
```

При применении ключевых слов ANY и SOME условие в операции сравнения должно быть истинным для хотя бы одного из значений, возвращаемых подзапросом. По действию оба этих оператора аналогичны, поэтому можно применять любое из них. Например, в следующем случае получим товары, которые стоят меньше самого дорого товара компании Apple:

```sql
SELECT * FROM Products
WHERE Price < ANY(SELECT Price FROM Products WHERE Manufacturer='Apple')
```

И также стоит отметить, что данный запрос можно сделать проще, переписав следующим образом:


```sql
SELECT * FROM Products
WHERE Price < (SELECT MAX(Price) FROM Products WHERE Manufacturer='Apple')
```

## Подзапрос как спецификация столбца

Результат подзапроса может представлять отдельный столбец в выборке. Например, выберем все заказы и добавим к ним информацию о названии товара:

```sql
SELECT *, 
(SELECT ProductName FROM Products WHERE Id=Orders.ProductId) AS Product 
FROM Orders
```

## Подзапросы в команде INSERT
В команде INSERT подзапросы могут применяться для определения значения, которое вставляется в один из столбцов:

```sql
INSERT INTO Orders (ProductId, CustomerId, CreatedAt, ProductCount, Price)
VALUES
( 
    (SELECT Id FROM Products WHERE ProductName='Galaxy S8'), 
    (SELECT Id FROM Customers WHERE FirstName='Tom'),
    '2017-07-11',  
    2, 
    (SELECT Price FROM Products WHERE ProductName='Galaxy S8')
)
```

## Подзапросы в команде UPDATE
В команде UPDATE подзапросы могут применяться:

- В качестве устанавливаемого значения после оператора SET
- Как часть условия в выражении WHERE

Так, увеличим количество купленных товаров на 2 в тех заказах, где покупатель Тоm:
```sql
UPDATE Orders
SET ProductCount = ProductCount + 2
WHERE CustomerId=(SELECT Id FROM Customers WHERE FirstName='Tom')
```

Или установим для заказа цену товара, полученную в результате подзапроса:

```sql
UPDATE Orders
SET Price = (SELECT Price FROM Products WHERE Id=Orders.ProductId) + 2000
WHERE Id=1
```
## Подзапросы в команде DELETE
В команде DELETE подзапросы также применяются как часть условия. Так, удалим все заказы на Galaxy S8, которые сделал Bob:

```sql
DELETE FROM Orders
WHERE ProductId=(SELECT Id FROM Products WHERE ProductName='Galaxy S8')
AND CustomerId=(SELECT Id FROM Customers WHERE FirstName='Bob')
```