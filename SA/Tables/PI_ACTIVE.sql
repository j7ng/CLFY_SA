CREATE TABLE sa.pi_active (
  objid NUMBER,
  x_part_inst2site_part NUMBER,
  part_serial_no VARCHAR2(30 BYTE)
);
ALTER TABLE sa.pi_active ADD SUPPLEMENTAL LOG GROUP dmtsora767409137_0 (objid, part_serial_no, x_part_inst2site_part) ALWAYS;