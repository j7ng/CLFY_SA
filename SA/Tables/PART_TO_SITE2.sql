CREATE TABLE sa.part_to_site2 (
  objid NUMBER,
  inst_rowid ROWID
);
ALTER TABLE sa.part_to_site2 ADD SUPPLEMENTAL LOG GROUP dmtsora1312031929_0 (inst_rowid, objid) ALWAYS;