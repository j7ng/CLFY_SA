CREATE TABLE sa.pill101 (
  esn VARCHAR2(30 BYTE),
  activation_date DATE,
  install_date DATE,
  service_end_dt DATE,
  part_status VARCHAR2(40 BYTE)
);
ALTER TABLE sa.pill101 ADD SUPPLEMENTAL LOG GROUP dmtsora526321325_0 (activation_date, esn, install_date, part_status, service_end_dt) ALWAYS;