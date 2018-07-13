CREATE OR REPLACE function sa.delete_test_user
                 (ip_login_name in varchar2)
                  return varchar2 is

begin

   delete from table_contact
   where objid in (select web_user2contact from table_web_user
                   where login_name = ip_login_name);


   delete from table_web_user
   where login_name = ip_login_name;

   commit;

   return '1';

Exception

   when others then
      return '0';

end;
/