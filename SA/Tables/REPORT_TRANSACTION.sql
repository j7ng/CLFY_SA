CREATE TABLE sa.report_transaction (
  db CHAR(8 BYTE),
  "COUNT" NUMBER,
  channel VARCHAR2(30 BYTE),
  trans_type VARCHAR2(12 BYTE),
  result VARCHAR2(20 BYTE),
  hour_date DATE
);