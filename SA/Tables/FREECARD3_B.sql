CREATE TABLE sa.freecard3_b (
  smp_type CHAR(14 BYTE),
  smp VARCHAR2(30 BYTE),
  install_date DATE,
  smp_status VARCHAR2(20 BYTE),
  part_number VARCHAR2(30 BYTE),
  dealer_name VARCHAR2(80 BYTE)
);
ALTER TABLE sa.freecard3_b ADD SUPPLEMENTAL LOG GROUP dmtsora2031875054_0 (dealer_name, install_date, part_number, smp, smp_status, smp_type) ALWAYS;