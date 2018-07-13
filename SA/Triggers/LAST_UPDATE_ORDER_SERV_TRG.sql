CREATE OR REPLACE trigger sa.last_update_order_serv_trg
before update on sa.X_sales_order_services for each row
begin

  :new.last_update_date:=sysdate;

end;
/