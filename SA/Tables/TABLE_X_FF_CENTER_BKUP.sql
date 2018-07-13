CREATE TABLE sa.table_x_ff_center_bkup (
  dev NUMBER,
  objid NUMBER,
  x_ff_name VARCHAR2(30 BYTE),
  x_ff_code VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_ff_center_bkup ADD SUPPLEMENTAL LOG GROUP dmtsora384108611_0 (dev, objid, x_ff_code, x_ff_name) ALWAYS;