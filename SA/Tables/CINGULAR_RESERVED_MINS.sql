CREATE TABLE sa.cingular_reserved_mins (
  part_serial_no VARCHAR2(30 BYTE),
  part_to_esn2part_inst NUMBER
);
ALTER TABLE sa.cingular_reserved_mins ADD SUPPLEMENTAL LOG GROUP dmtsora747783099_0 (part_serial_no, part_to_esn2part_inst) ALWAYS;