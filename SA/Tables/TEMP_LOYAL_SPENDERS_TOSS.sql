CREATE TABLE sa.temp_loyal_spenders_toss (
  customer_id NUMBER NOT NULL,
  phone_id NUMBER NOT NULL,
  esn VARCHAR2(20 BYTE) NOT NULL,
  rev_seg VARCHAR2(20 BYTE),
  product_line VARCHAR2(20 BYTE),
  toss_customer_id VARCHAR2(80 BYTE) NOT NULL
);