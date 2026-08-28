set sqlformat ansiconsole
set pagesize 500
set linesize 240
set timing on

with genre_income as (
    select c.income_level as series_name
         , g.name as label
         , count(*) as value
    from custsales s
    join customer c
      on c.cust_id = s.cust_id
    join genre g
      on g.genre_id = s.genre_id
    group by c.income_level, g.name
), genre_totals as (
    select gi.series_name
         , gi.label
         , gi.value
         , sum(gi.value) over (partition by gi.series_name) as income_total
         , sum(gi.value) over (partition by gi.label) as genre_total
    from genre_income gi
), ranked as (
    select gt.series_name
         , gt.label
         , gt.value
         , gt.income_total
         , dense_rank() over (order by gt.genre_total desc) as genre_rank
    from genre_totals gt
)
select r.series_name
     , r.label
     , round(100 * r.value / r.income_total, 2) as value
from ranked r
where r.genre_rank <= 10
order by r.genre_rank, r.series_name;

prompt === TOP THREE GENRES PER REGION ===
with region_genre as (
    select c.state_province as label
         , g.name as series_name
         , count(*) as value
    from custsales s
    join customer c
      on c.cust_id = s.cust_id
    join genre g
      on g.genre_id = s.genre_id
    group by c.state_province, g.name
), ranked as (
    select rg.label
         , rg.series_name
         , rg.value
         , dense_rank() over (
               partition by rg.label
               order by rg.value desc
           ) as genre_rank
    from region_genre rg
)
select r.series_name
     , r.label
     , r.value
from ranked r
where r.genre_rank <= 3
order by r.label, r.genre_rank;

exit
