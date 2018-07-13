CREATE MATERIALIZED VIEW sa.partnum_dealer_matview (price_list_name,price_list_id,part_number,part_description,list_price,retail_price,item_cost,start_date_active,end_date_active,cust_account_id,customer_name)
ORGANIZATION HEAP 
REFRESH COMPLETE START WITH TO_DATE('2018-7-14 1:0:0', 'yyyy-mm-dd hh24:mi:ss') NEXT TRUNC(SYSDATE)+ 1 + 01/24 
AS SELECT                                            /*+ USE_INVISIBLE_INDEXES */
      pl.*
  FROM Tf.tf_pl_to_cust_v@ofsprd pl
 WHERE END_DATE_ACTIVE IS NULL OR TRUNC (END_DATE_ACTIVE) >= TRUNC (SYSDATE);