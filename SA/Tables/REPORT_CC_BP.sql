CREATE TABLE sa.report_cc_bp (
  db CHAR(8 BYTE),
  "COUNT" NUMBER,
  x_rqst_source VARCHAR2(20 BYTE),
  x_rqst_type VARCHAR2(20 BYTE),
  x_payment_type VARCHAR2(30 BYTE),
  x_status VARCHAR2(20 BYTE),
  hour_date DATE
);