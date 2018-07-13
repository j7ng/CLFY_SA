CREATE TABLE sa.t2 (
  x_min VARCHAR2(30 BYTE),
  install_date DATE
);
ALTER TABLE sa.t2 ADD SUPPLEMENTAL LOG GROUP dmtsora2029924547_0 (install_date, x_min) ALWAYS;