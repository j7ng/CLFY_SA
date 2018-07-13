CREATE OR REPLACE TRIGGER sa.table_user_trig_last_login
  before update of WEB_LAST_LOGIN on sa.table_user

  for each row
declare

begin

       if :NEW.WEB_LAST_LOGIN <> to_date('1/1/1753', 'mm/dd/yyyy')  then


        :NEW.WEB_LAST_LOGIN := sysdate;

       end if;

end;
/