CREATE TABLE sa.wex_bp_open_orders (
  bp_order VARCHAR2(250 BYTE),
  tf_order_num VARCHAR2(250 BYTE),
  cust_po_number VARCHAR2(250 BYTE),
  items VARCHAR2(250 BYTE),
  qty VARCHAR2(250 BYTE),
  bko_qty VARCHAR2(250 BYTE),
  order_date VARCHAR2(250 BYTE),
  delivery_date VARCHAR2(250 BYTE),
  hold VARCHAR2(250 BYTE),
  ship_to_name VARCHAR2(250 BYTE),
  city VARCHAR2(250 BYTE),
  "STATE" VARCHAR2(250 BYTE),
  comments VARCHAR2(250 BYTE),
  creation_date DATE
);