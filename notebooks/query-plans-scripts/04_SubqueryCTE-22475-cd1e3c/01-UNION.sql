-- Задачка вывести в одном столбце
select 'a' as Col1
union
select 'b' as Col2
union
select 'b' as Col1
union
select 'c' as Col3

-- Значения null считаются одинаковыми
select null 
union 
select null

select null 
union all
select null


-- а в WHERE нет !
select 1 
where null = null

-- Что быстрее UNION или UNION ALL?
select 'a'
union all
select 'a'
union all
select 'b'

select 'a'
union
select 'a'
union
select 'b'

 
-- Совместимость по типам 
-- ошибка
select 'a'
union 
select 123


select 'a'
union 
select cast(1 as nchar(1))


select 'a'
union
select 'b'
except
select 'a'

--intersect
declare @t1 table (id int);
declare @t2 table (id int);

INSERT INTO @t1
(id)
VALUES 
(1),
(1),
(2),
(3)

INSERT INTO @t2
(id)
VALUES 
(1),
(3)

SELECT id
FROM @t1
INTERSECT 
SELECT id
FROM @t2;

SELECT t1.id--, t2.id
FROM @t1 as t1
	JOIN @t2 as t2 
		ON t1.id = t2.id;

SELECT id
FROM @t1
EXCEPT 
SELECT id
FROM @t2;

SELECT id
FROM @t1
UNION ALL 
SELECT id
FROM @t2
ORDER BY id;