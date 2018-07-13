CREATE OR REPLACE FUNCTION sa."ADFCRM_WRITE_SOLUTION_HISTORY" (ip_solution_id in varchar2,ip_user_name in varchar2) return varchar2
as

cursor c1 is
select * from sa.adfcrm_solution
where solution_id = ip_solution_id;
r1 c1%rowtype;
v_out_msg varchar2(200):='SUCCESS';

begin

   open c1;
   fetch c1 into r1;
   if c1%found then
      insert into sa.adfcrm_solution_history (
            SOLUTION_ID
          , SOLUTION_NAME
          , SOLUTION_DESCRIPTION
          , KEYWORDS
          , ACCESS_TYPE
          , PHONE_STATUS
          , SCRIPT_TYPE
          , SCRIPT_ID
          , PARENT_ID
          , CASE_CONF_HDR_ID
          , CARRRIER_PARENTS
          , SEND_BY_EMAIL
          , CHANGED_BY
          , CHANGED_DATE) values (
            r1.SOLUTION_ID
          , r1.SOLUTION_NAME
          , r1.SOLUTION_DESCRIPTION
          , r1.KEYWORDS
          , r1.ACCESS_TYPE
          , r1.PHONE_STATUS
          , r1.SCRIPT_TYPE
          , r1.SCRIPT_ID
          , r1.PARENT_ID
          , r1.CASE_CONF_HDR_ID
          , r1.CARRRIER_PARENTS
          , r1.SEND_BY_EMAIL
          , ip_user_name
          , sysdate);


      commit;
   else

      v_out_msg:='ERROR - Solution record not found';
   end if;
   close c1;

   return v_out_msg;

exception

   when others then
      v_out_msg:='ERROR - '||sqlerrm;
      return v_out_msg;

end ADFCRM_WRITE_SOLUTION_HISTORY;
/