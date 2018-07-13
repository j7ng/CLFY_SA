CREATE OR REPLACE trigger sa.last_update_BUS_ACCOUNTS_trg
before update on sa.X_BUSINESS_ACCOUNTS for each row
begin

  :new.last_update_date:=sysdate;

end;
/