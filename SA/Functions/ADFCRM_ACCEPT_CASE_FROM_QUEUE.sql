CREATE OR REPLACE FUNCTION sa."ADFCRM_ACCEPT_CASE_FROM_QUEUE" (ip_queue_objid number,
                                                             ip_user_objid number) return varchar2 is

cursor c1 is
select ca.creation_time,ca.objid,ca.id_number
from table_case ca,table_condition con,table_user u
where ca.case_state2condition =con.objid
and con.title like 'Open-%'
and ca.case_currq2queue = ip_queue_objid
and u.objid = ip_user_objid
and rownum <= 100;

v_return varchar2(100):='QUEUE_EMPTY';
v_error_no varchar2(100);
v_error_str varchar2(200);

begin

   for r1 in c1 loop
       sa.clarify_case_pkg.accept_case(
       p_case_objid => r1.objid,
       p_user_objid => ip_user_objid,
       p_error_no => v_error_no ,
       p_error_str => v_error_str);

       if v_error_no = '0' then
          v_return:=r1.id_number;
          exit;
       end if;
   end loop;
   return v_return;
end;
/