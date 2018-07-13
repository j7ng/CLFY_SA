CREATE OR REPLACE TYPE sa.rtr_order_detail_type AS OBJECT
/*************************************************************************************************************************************
--$RCSfile: RTR_ORDER_DETAIL_TAB.sql,v $
--$ $Log: RTR_ORDER_DETAIL_TAB.sql,v $
--$ Revision 1.1  2018/04/23 16:20:21  sgangineni
--$ CR49520 - New type to return order line level status
--$
--$
--$
*
* CR49520 - rtr_order_detail_type.
*
*************************************************************************************************************************************/

( order_detail_objid  NUMBER,
  part_serial_no      VARCHAR2(100),
  order_detail_status VARCHAR2(100)
);
/