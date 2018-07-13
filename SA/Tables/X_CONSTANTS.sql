CREATE TABLE sa.x_constants (
  x_type VARCHAR2(10 BYTE),
  x_value VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_constants ADD SUPPLEMENTAL LOG GROUP dmtsora1612964227_0 (x_type, x_value) ALWAYS;