CREATE TABLE sa.release3 (
  x_min VARCHAR2(30 BYTE)
);
ALTER TABLE sa.release3 ADD SUPPLEMENTAL LOG GROUP dmtsora1901826298_0 (x_min) ALWAYS;