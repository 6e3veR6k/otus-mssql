# Nested Loops Join

SQL Server supports three physical join operators: nested loops join, merge join, and hash join.  In this post, I’ll describe nested loops join (or NL join for short).

## The basic algorithm

In its simplest form, a nested loops join compares each row from one table (known as the outer table) to each row from the other table (known as the inner table) looking for rows that satisfy the join predicate.  (Note that the terms “inner” and “outer” are overloaded; their meaning must be inferred from context.  “Inner table” and “outer table” refer to the inputs to the join.  “Inner join” and “outer join” refer to the logical operations.)

We can express the algorithm in pseudo-code as:

```
for each row R1 in the outer table
    for each row R2 in the inner table
        if R1 joins with R2
            return (R1, R2)
```

It’s the nesting of the for loops in this algorithm that gives nested loops join its name.

The total number of rows compared and, thus, the cost of this algorithm is proportional to the size of the outer table multiplied by the size of the inner table.  Since this cost grows quickly as the size of the input tables grow, in practice we try to minimize the cost by reducing the number of inner rows that we must consider for each outer row.
The cost that I describe above refers to a naive nested loops join in which we have no indexes and in which every outer row is compared to every inner row.  Below, I describe how SQL Server can use an index on the inner table to reduce this cost so that it is proportional to the size of the outer table multiplied by the log of the size of the inner table.  A more precise statement is that for any nested loops join, the cost is proportional to the cost of producing the outer rows multipled by the cost of producing the inner rows for each outer row.

For example, using the same schema from my prior post:

```sql
create table Customers (Cust_Id int, Cust_Name varchar(10))

insert Customers values (1, 'Craig')
insert Customers values (2, 'John Doe')
insert Customers values (3, 'Jane Doe')

 

create table Sales (Cust_Id int, Item varchar(10))

insert Sales values (2, 'Camera')
insert Sales values (3, 'Computer')
insert Sales values (3, 'Monitor')
insert Sales values (4, 'Printer')
```

Consider this query:
```sql

select *
from Sales S 
inner join Customers C on S.Cust_Id = C.Cust_Id option(loop join)
```

I’ve added a “loop join” hint to force the optimizer to use a nested loops join.  We get this plan which I captured by running the query with “set statistics profile on”:

| rows | executes | plan |
| ---- | -------- | ---- |
| 3| 1 |  ```|--Nested Loops(Inner Join, WHERE:([C].[Cust_Id]=[S].[Cust_Id]))``` |
| 3| 1 |  ```|--Table Scan(OBJECT:([Customers] AS [C]))``` |
| 12| 3 |  ```|--Table Scan(OBJECT:([Sales] AS [S]))``` |

The outer table in this plan is Customers while the inner table is Sales.  Thus, we begin by scanning the Customers table.  We take one customer at a time and, for each customer, we scan the Sales table.  Since there are 3 customers, we execute the scan of the Sales table 3 times.  Each scan of the Sales table returns 4 rows.  We compare each sale to the current customer and evaluate whether the two rows have the same Cust_Id.  If they do, we return the pair of rows.  We have 3 customers and 4 sales so we perform this comparison a total of 3*4 or 12 times.  Only 3 of these comparisons result in a match.

Now consider what happens if we create an index on Sales:
```sql
create clustered index CI on Sales(Cust_Id)
```

Now we get this plan:

| rows | executes | plan |
| ---- | -------- | ---- |
| 3| 1 |  ``` |--Nested Loops(Inner Join, OUTER REFERENCES:([C].[Cust_Id]))``` |
| 3| 1 |  ```|--Table Scan(OBJECT:([Customers] AS [C]))``` |
| 3| 3 |  ``` |--Clustered Index Seek(OBJECT:([Sales].[CI] AS [S]), SEEK:([S].[Cust_Id]=[C].[Cust_Id]) ORDERED FORWARD)``` |

This time, instead of doing a table scan of Sales, we do an index seek.  We still do the index seek 3 times – once for each customer, but each index seek returns only those rows that match the current Cust_Id and qualify for the join predicate.  Thus, the seek returns a total of only 3 rows as compared to the 12 rows returned by the table scan.

Notice that the index seek depends on C.CustId which comes from the outer table of the join – the table scan of Customers.  Each time we execute the index seek (recall that we execute it 3 times – once for each customer), C.CustId has a different value.  We refer to C.CustId as a “correlated parameter.”  If a nested loops join has correlated parameters, we output them in the showplan as “OUTER REFERENCES.”  We often refer to this type of nested loops join where we have an index seek that depends on a correlated parameter as an “index join.”  This is a common scenario.

_What types of join predicates does the nested loops join support?_

The nested loops join supports all join predicate including equijoin (equality) predicates and inequality predicates.

_Which logical join operators does the nested loops join support?_

The nested loops join supports the following logical join operators:
 - Inner join
 - Left outer join
 - Cross join
 - Cross apply and outer apply
 - Left semi-join and left anti-semi-join

The nested loops join does not support the following logical join operators:
- Right and full outer join
- Right semi-join and right anti-semi-join

_Why does the nested loops join only support left joins?_

We can easily extend the nested loops join algorithm to support left outer and semi-joins.  For instance, here is pseudo-code for left outer join.  We can write similar pseudo-code for left semi-join and left anti-semi-join.

```
for each row R1 in the outer table
    begin
        for each row R2 in the inner table
            if R1 joins with R2
                return (R1, R2)
        if R1 did not join
            return (R1, NULL)
    end
```

This algorithm keeps track of whether we joined a particular outer row.  If after exhausting all inner rows, we find that a particular inner row did not join, we output it as a NULL extended row.
 
Now consider how we might support right outer join.  In this case, we want to return pairs (R1, R2) for rows that join and pairs (NULL, R2) for rows of the inner table that do not join.  The problem is that we scan the inner table multiple times – once for each row of the outer join.  We may encounter the same inner rows multiple times during these multiple scans.  At what point can we conclude that a particular inner row has not or will not join?  Moreover, if we are using an index join, we might not encounter some inner rows at all.  Yet these rows should also be returned for an outer join.

Fortunately, since right outer join commutes into left outer join and right semi-join commutes into left semi-join, we can use the nested loops join for right outer and semi-joins.  However, while these transformations are valid, they may affect performance.   For example, the join “Customer left outer join Sales” using the above schema with the clustered index on Sales, could use an index seek on Sales just as in the inner join example.  On the other hand, the join “Customer right outer join Sales” can be transformed into “Sales left outer join Customer,” but now we need an index on Customer.

_What about full outer joins?_

The nested loops join cannot directly support full outer join.  However, we can transform “T1 full outer join T2” into “T1 left outer join T2 UNION T2 left anti-semi-join T1.”  Basically, this transforms the full outer join into a left outer join – which includes all pairs of rows from T1 and T2 that join and all rows of T1 that do not join – then adds back the rows of T2 that do not join using an anti-semi-join.  Here is the transformation in action:

```sql
select *
from Customers C 
full outer join Sales S on C.Cust_Id = S.Cust_Id
```


| rows | executes | plan |
| ---- | -------- | ---- |
| 5| 1 |  ``` |--Concatenation``` |
| 4| 1 |  ```|--Nested Loops(Left Outer Join, WHERE:([C].[Cust_Id]=[S].[Cust_Id]))``` |
| 3| 1 |  ``` |    |--Table Scan(OBJECT:([Customers] AS [C]))``` |
| 12| 3| ```|    |--Clustered Index Scan(OBJECT:([Sales].[Sales_ci] AS [S])) ```|
| 0| 0| ```|--Compute Scalar(DEFINE:([C].[Cust_Id]=NULL, [C].[Cust_Name]=NULL)) ```|
| 1| 1| ```|--Nested Loops(Left Anti Semi Join, OUTER REFERENCES:([S].[Cust_Id])) ```|
| 4| 1| ```|--Clustered Index Scan(OBJECT:([Sales].[Sales_ci] AS [S])) ```|
| 3| 4| ```|--Top(TOP EXPRESSION:((1))) ```|
| 3| 4| ```|--Table Scan(OBJECT:([Customers] AS [C]), WHERE:([C].[Cust_Id]=[S].[Cust_Id])) ```|

Note:  In the above example, the optimizer chooses a clustered index scan even though it could use a seek.  This is merely a costing decision.  The table is so small (its fits on one
page) that there is really no difference between the scan and seek performance.

_Is NL join good or bad?_

Neither actually.  There is no “best” join algorithm and no join algorithm is inherently good or bad.  Each join algorithm performs well in the right circumstances and poorly in the wrong circumstances.  Because the complexity of a nested loops join is proportional to the size of the outer input multiplied by the size of the inner input, a nested loops join generally performs best for relatively small input sets.  The inner input need not be small, but, if it is large, it helps to include an index on a highly selective join key.

In some cases, a nested loops join is the only join algorithm that SQL Server can use.  SQL Server must use a nested loops join for cross join as well as some complex cross applies and outer applies.  Moreover, with one exception (for full outer join), a nested loops join is the only join algorithm that SQL Server can use without at least one equijoin predicate.