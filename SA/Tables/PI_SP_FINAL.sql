CREATE TABLE sa.pi_sp_final (
  objid NUMBER,
  x_part_inst2site_part NUMBER,
  part_serial_no VARCHAR2(30 BYTE)
);
ALTER TABLE sa.pi_sp_final ADD SUPPLEMENTAL LOG GROUP dmtsora866764586_0 (objid, part_serial_no, x_part_inst2site_part) ALWAYS;