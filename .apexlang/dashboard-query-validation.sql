set sqlformat ansiconsole
set pagesize 500
set linesize 240
set timing on

prompt === JOIN COVERAGE ===
select count(*) as matched_transactions
     , count(distinct s.cust_id) as matched_customers
from custsales s
join customer c
  on c.cust_id = s.cust_id;

prompt === GENRE VIEWS BY GENDER ===
select c.gender as series_name
     , g.name as label
     , count(*) as value
from custsales s
join customer c
  on c.cust_id = s.cust_id
join genre g
  on g.genre_id = s.genre_id
group by c.gender, g.name
order by g.name, c.gender;

prompt === TOP 10 REGION AND GENRE COMBINATIONS ===
select label
     , value
from (
    select c.state_province || ' / ' || g.name as label
         , count(*) as value
    from custsales s
    join customer c
      on c.cust_id = s.cust_id
    join genre g
      on g.genre_id = s.genre_id
    group by c.state_province, g.name
    order by value desc
)
fetch first 10 rows only;

prompt === TOP 10 GENRES VIEWED BY MEN ===
select g.name as label
     , count(*) as value
from custsales s
join customer c
  on c.cust_id = s.cust_id
join genre g
  on g.genre_id = s.genre_id
where c.gender = 'Male'
group by g.name
order by value desc
fetch first 10 rows only;

prompt === PAYMENT METHOD SHARE ===
select initcap(s.payment_method) as label
     , count(*) as value
from custsales s
group by s.payment_method
order by value desc;

prompt === TOP 10 GENRES BY INCOME LEVEL ===
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
         , sum(gi.value) over (partition by gi.label) as genre_total
    from genre_income gi
), ranked as (
    select gt.series_name
         , gt.label
         , gt.value
         , dense_rank() over (order by gt.genre_total desc) as genre_rank
    from genre_totals gt
)
select r.series_name
     , r.label
     , r.value
from ranked r
where r.genre_rank <= 10
order by r.genre_rank, r.series_name;

exit
