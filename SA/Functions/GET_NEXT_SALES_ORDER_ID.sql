CREATE OR REPLACE FUNCTION sa.get_next_sales_order_id RETURN NUMBER IS

   next_order number;

BEGIN

   select max(order_id)+1
   into next_order
   from sa.x_sales_orders;

   return next_order;

end;
/