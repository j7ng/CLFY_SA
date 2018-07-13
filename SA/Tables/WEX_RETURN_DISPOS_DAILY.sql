CREATE TABLE sa.wex_return_dispos_daily (
  rcpt_date DATE,
  bp_ra VARCHAR2(50 BYTE),
  ship_to_name VARCHAR2(100 BYTE),
  customer_code VARCHAR2(60 BYTE),
  retailer_po VARCHAR2(50 BYTE),
  tracfone_po VARCHAR2(50 BYTE),
  bp_order VARCHAR2(100 BYTE),
  warehouse VARCHAR2(100 BYTE),
  serail_no VARCHAR2(100 BYTE),
  item_code VARCHAR2(50 BYTE),
  qty VARCHAR2(30 BYTE),
  stage VARCHAR2(100 BYTE),
  service_type VARCHAR2(100 BYTE),
  attribute_name VARCHAR2(100 BYTE),
  grade VARCHAR2(100 BYTE),
  dist_channel VARCHAR2(90 BYTE),
  order_type VARCHAR2(20 BYTE),
  tracking_number VARCHAR2(70 BYTE),
  origin_ra_id VARCHAR2(100 BYTE),
  origin_customer_id VARCHAR2(50 BYTE),
  receipt_number VARCHAR2(50 BYTE),
  inbound_tracking VARCHAR2(50 BYTE),
  creation_date DATE
);