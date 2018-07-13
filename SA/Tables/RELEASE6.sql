CREATE TABLE sa.release6 (
  objid NUMBER,
  flag NUMBER
);
ALTER TABLE sa.release6 ADD SUPPLEMENTAL LOG GROUP dmtsora377059281_0 (flag, objid) ALWAYS;