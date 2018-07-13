CREATE OR REPLACE TRIGGER sa.table_user_trig

  after update of password, passwd_chg ON sa.TABLE_USER
  for each row
DISABLE declare

      sql_stmt varchar2(200) := '';

pragma AUTONOMOUS_TRANSACTION;

begin

       if :NEW.passwd_chg = to_date('1/1/1753', 'mm/dd/yyyy') AND :new.password = '[ScBhozpV1nkzzNPrE/' then



       sql_stmt := 'grant connect to '||:old.s_login_name ||' identified by "efg4563456"';

       execute immediate sql_stmt;

       end if;

end;
/