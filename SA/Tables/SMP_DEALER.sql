CREATE TABLE sa.smp_dealer (
  part_serial_no VARCHAR2(30 BYTE),
  site_id VARCHAR2(80 BYTE)
);
ALTER TABLE sa.smp_dealer ADD SUPPLEMENTAL LOG GROUP dmtsora124792732_0 (part_serial_no, site_id) ALWAYS;