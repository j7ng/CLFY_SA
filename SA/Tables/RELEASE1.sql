CREATE TABLE sa.release1 (
  objid NUMBER,
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  last_cycle_ct DATE,
  part_to_esn2part_inst NUMBER
);
ALTER TABLE sa.release1 ADD SUPPLEMENTAL LOG GROUP dmtsora316673161_0 (last_cycle_ct, objid, part_serial_no, part_to_esn2part_inst, x_part_inst_status) ALWAYS;