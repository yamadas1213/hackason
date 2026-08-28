set sqlformat ansiconsole
set pagesize 500
set linesize 240
set timing on

prompt === SESSION ===
select sys_context('USERENV', 'SESSION_USER') as current_user
     , sys_context('USERENV', 'DB_NAME') as db_name
     , sys_context('USERENV', 'CON_NAME') as container_name
from dual;

prompt === TABLE STATS ===
select t.table_name
     , t.num_rows
     , t.last_analyzed
     , t.partitioned
from user_tables t
where t.table_name in ('CUSTOMER', 'CUSTSALES', 'GENRE', 'WEATHER')
order by t.table_name;

prompt === COLUMNS ===
select c.table_name
     , c.column_id
     , c.column_name
     , c.data_type
     , c.data_length
     , c.data_precision
     , c.data_scale
     , c.nullable
from user_tab_columns c
where c.table_name in ('CUSTOMER', 'CUSTSALES', 'GENRE', 'WEATHER')
order by c.table_name, c.column_id;

prompt === CONSTRAINTS ===
select c.table_name
     , c.constraint_name
     , c.constraint_type
     , cc.column_name
     , cc.position
     , rc.table_name as referenced_table
     , rcc.column_name as referenced_column
from user_constraints c
join user_cons_columns cc
  on cc.constraint_name = c.constraint_name
left join user_constraints rc
  on rc.constraint_name = c.r_constraint_name
left join user_cons_columns rcc
  on rcc.constraint_name = rc.constraint_name
 and rcc.position = cc.position
where c.table_name in ('CUSTOMER', 'CUSTSALES', 'GENRE', 'WEATHER')
  and c.constraint_type in ('P', 'R', 'U')
order by c.table_name, c.constraint_type, c.constraint_name, cc.position;

prompt === INDEXES ===
select i.table_name
     , i.index_name
     , i.uniqueness
     , listagg(ic.column_name, ', ') within group (order by ic.column_position) as columns
from user_indexes i
join user_ind_columns ic
  on ic.index_name = i.index_name
where i.table_name in ('CUSTOMER', 'CUSTSALES', 'GENRE', 'WEATHER')
group by i.table_name, i.index_name, i.uniqueness
order by i.table_name, i.index_name;

prompt === CUSTOMER DIMENSIONS ===
select 'GENDER' as dimension
     , c.gender as dimension_value
     , count(*) as customer_count
from customer c
group by c.gender
union all
select 'COUNTRY' as dimension
     , c.country as dimension_value
     , count(*) as customer_count
from customer c
group by c.country
union all
select 'INCOME_LEVEL' as dimension
     , c.income_level as dimension_value
     , count(*) as customer_count
from customer c
group by c.income_level
order by dimension, customer_count desc;

prompt === PAYMENT METHODS ===
select s.payment_method
     , count(*) as transaction_count
from custsales s
group by s.payment_method
order by transaction_count desc;

prompt === CUSTSALES DATE RANGE ===
select min(s.day_id) as min_day_id
     , max(s.day_id) as max_day_id
     , count(distinct s.day_id) as distinct_days
from custsales s;

prompt === WEATHER SAMPLE AND WIND DISTRIBUTION ===
select *
from weather w
fetch first 5 rows only;

exit
