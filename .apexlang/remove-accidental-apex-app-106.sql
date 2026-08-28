set serveroutput on
set sqlformat ansiconsole
set pagesize 100
set linesize 240
whenever sqlerror exit failure rollback

declare
    l_duplicate_count number;
begin
    select count(*)
      into l_duplicate_count
      from apex_applications a
     where a.workspace_id = 9209874252257327
       and a.workspace = 'CUSTOMER_INSIGHTS'
       and a.application_id = 106
       and a.alias = 'CUSTOMER-INSIGHTS106'
       and a.application_name = 'Customer Insights';

    if l_duplicate_count != 1 then
        raise_application_error(-20001, 'Accidental duplicate App ID 106 was not identified exactly; deletion stopped.');
    end if;

    apex_application_install.set_workspace('CUSTOMER_INSIGHTS');
    apex_application_install.set_keep_sessions(false);
    apex_application_install.remove_application(106);
    commit;
    dbms_output.put_line('Removed accidental duplicate App ID 106.');
end;
/

select a.application_id
     , a.alias
     , a.application_name
     , a.workspace
from apex_applications a
where a.workspace_id = 9209874252257327
  and a.application_id in (103, 106)
order by a.application_id;

exit
