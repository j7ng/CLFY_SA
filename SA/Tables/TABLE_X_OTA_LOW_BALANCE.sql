CREATE TABLE sa.table_x_ota_low_balance (
  x_created_date DATE,
  x_esn VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_units NUMBER
);
ALTER TABLE sa.table_x_ota_low_balance ADD SUPPLEMENTAL LOG GROUP dmtsora779352586_0 (x_created_date, x_esn, x_min, x_units) ALWAYS;