CREATE TABLE sa.curtis (
  col1 DATE,
  proc VARCHAR2(2 BYTE)
);
ALTER TABLE sa.curtis ADD SUPPLEMENTAL LOG GROUP dmtsora1278912714_0 (col1, proc) ALWAYS;