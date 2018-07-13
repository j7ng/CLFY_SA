CREATE TABLE sa.att_tmo_575 (
  part_serial_no VARCHAR2(30 BYTE),
  new_part_serial_no VARCHAR2(10 BYTE),
  x_npa VARCHAR2(10 BYTE),
  new_npa CHAR(3 BYTE)
);
ALTER TABLE sa.att_tmo_575 ADD SUPPLEMENTAL LOG GROUP dmtsora1971238064_0 (new_npa, new_part_serial_no, part_serial_no, x_npa) ALWAYS;