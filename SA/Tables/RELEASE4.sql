CREATE TABLE sa.release4 (
  objid NUMBER,
  flag NUMBER
);
ALTER TABLE sa.release4 ADD SUPPLEMENTAL LOG GROUP dmtsora1829668367_0 (flag, objid) ALWAYS;