CREATE TABLE sa.x_null_pers (
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  part_inst2x_pers NUMBER,
  part_inst2carrier_mkt NUMBER,
  status VARCHAR2(10 BYTE)
);
ALTER TABLE sa.x_null_pers ADD SUPPLEMENTAL LOG GROUP dmtsora391157940_0 (part_inst2carrier_mkt, part_inst2x_pers, part_serial_no, status, x_part_inst_status) ALWAYS;