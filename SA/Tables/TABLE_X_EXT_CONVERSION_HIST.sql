CREATE TABLE sa.table_x_ext_conversion_hist (
  objid NUMBER,
  dev NUMBER,
  x_start_date DATE,
  x_end_date DATE,
  x_conversion NUMBER(19,4),
  x_bus_org VARCHAR2(20 BYTE),
  x_card_type VARCHAR2(30 BYTE),
  x_units NUMBER,
  conv_hist2part_num NUMBER
);
ALTER TABLE sa.table_x_ext_conversion_hist ADD SUPPLEMENTAL LOG GROUP dmtsora2097138398_0 (conv_hist2part_num, dev, objid, x_bus_org, x_card_type, x_conversion, x_end_date, x_start_date, x_units) ALWAYS;