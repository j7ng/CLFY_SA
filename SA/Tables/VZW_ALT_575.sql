CREATE TABLE sa.vzw_alt_575 (
  objid NUMBER,
  part_serial_no VARCHAR2(30 BYTE),
  new_part_serial_no VARCHAR2(10 BYTE),
  x_npa VARCHAR2(10 BYTE),
  new_npa CHAR(3 BYTE)
);
ALTER TABLE sa.vzw_alt_575 ADD SUPPLEMENTAL LOG GROUP dmtsora373661792_0 (new_npa, new_part_serial_no, objid, part_serial_no, x_npa) ALWAYS;