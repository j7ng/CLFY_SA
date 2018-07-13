CREATE TABLE sa.fix0215 (
  x_min VARCHAR2(100 BYTE),
  x_insert_date DATE
);
ALTER TABLE sa.fix0215 ADD SUPPLEMENTAL LOG GROUP dmtsora788851541_0 (x_insert_date, x_min) ALWAYS;