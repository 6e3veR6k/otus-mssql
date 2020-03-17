use application;

with IntCTE(x) as (select x from (values(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) f(x))
select cast(cast(a.x as varchar(2)) + cast(b.x as varchar(2)) + cast(c.x as varchar(2)) as int) as ints 
from IntCTE as a
cross join IntCTE as b
cross join IntCTE as c
order by ints
