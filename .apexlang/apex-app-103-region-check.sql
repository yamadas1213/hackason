set sqlformat ansiconsole
set pagesize 100
set linesize 240

select a.application_id
     , a.alias
     , a.application_name
     , a.workspace
from apex_applications a
where a.workspace_id = 9209874252257327
  and a.application_id in (103, 106)
order by a.application_id;

select r.application_id
     , r.page_id
     , r.region_name
     , r.display_sequence
from apex_application_page_regions r
where r.application_id = 103
  and r.page_id = 1
order by r.display_sequence, r.region_name;

exit
