set sqlformat ansiconsole
set pagesize 100
set linesize 240

select a.application_id
     , a.alias
     , a.application_name
     , a.workspace
     , a.owner
     , a.last_updated_on
from apex_applications a
where a.workspace_id = 9209874252257327
  and a.application_id in (103, 106)
order by a.application_id;

exit
