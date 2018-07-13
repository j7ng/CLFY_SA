CREATE TABLE sa.century_reserved_ac (
  objid NUMBER,
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  status2x_code_table NUMBER,
  part_to_esn2part_inst NUMBER,
  part_inst2x_pers NUMBER,
  x_msid VARCHAR2(30 BYTE),
  "TIMESTAMP" DATE
);
ALTER TABLE sa.century_reserved_ac ADD SUPPLEMENTAL LOG GROUP dmtsora570739894_0 (objid, part_inst2x_pers, part_serial_no, part_to_esn2part_inst, status2x_code_table, "TIMESTAMP", x_msid, x_part_inst_status) ALWAYS;