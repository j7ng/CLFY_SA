CREATE OR REPLACE FUNCTION sa."ADFCRM_EXCHANGE2CASE_CONF" (ip_exch_message in varchar2)
return varchar2 is

   cursor c1 is
   select * from sa.adfcrm_exch_message2case_conf
   where upper(Exch_Message) = upper(substr(ip_exch_message,1,100));

   r1 c1%rowtype;
   v_case_conf varchar2(10);

begin

   if ip_exch_message is null then
      return '-1';
   end if;

   open c1;
   fetch c1 into r1;
   if c1%found then
      v_case_conf:= r1.CASE_CONF_OBJID;
   else
      v_case_conf:= '0';
      insert into sa.adfcrm_exch_message2case_conf
      (Exch_Message,Case_Conf_Objid) values (substr(ip_exch_message,1,100),'0');
      commit;
   end if;
   close c1;

   return v_case_conf;

end ADFCRM_EXCHANGE2CASE_CONF;
/