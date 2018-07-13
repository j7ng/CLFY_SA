CREATE TABLE sa.report_ild (
  db CHAR(8 BYTE),
  "COUNT" NUMBER,
  channel VARCHAR2(30 BYTE),
  brand VARCHAR2(30 BYTE),
  "ACTION" VARCHAR2(20 BYTE),
  result VARCHAR2(10 BYTE),
  x_product_id VARCHAR2(30 BYTE),
  rate_plan VARCHAR2(60 BYTE),
  "TEMPLATE" VARCHAR2(30 BYTE),
  status VARCHAR2(30 BYTE),
  hour_date DATE
);