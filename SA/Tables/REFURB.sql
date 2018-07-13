CREATE TABLE sa.refurb (
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  n_part_inst2part_mod NUMBER,
  part_inst2inv_bin NUMBER
);
ALTER TABLE sa.refurb ADD SUPPLEMENTAL LOG GROUP dmtsora1741146765_0 (n_part_inst2part_mod, part_inst2inv_bin, part_serial_no, x_part_inst_status) ALWAYS;