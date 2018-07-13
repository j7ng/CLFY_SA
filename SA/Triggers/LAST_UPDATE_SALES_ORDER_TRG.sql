CREATE OR REPLACE trigger sa.last_update_sales_order_trg
before update on sa.x_sales_orders for each row
begin

  :new.last_update_date:=sysdate;

end;
/