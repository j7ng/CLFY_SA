CREATE TABLE sa.release5 (
  objid NUMBER,
  flag NUMBER
);
ALTER TABLE sa.release5 ADD SUPPLEMENTAL LOG GROUP dmtsora657116422_0 (flag, objid) ALWAYS;