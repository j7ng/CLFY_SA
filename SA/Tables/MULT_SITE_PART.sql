CREATE TABLE sa.mult_site_part (
  part_serial_no VARCHAR2(30 BYTE),
  cnt NUMBER
);
ALTER TABLE sa.mult_site_part ADD SUPPLEMENTAL LOG GROUP dmtsora55082967_0 (cnt, part_serial_no) ALWAYS;