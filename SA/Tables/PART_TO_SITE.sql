CREATE TABLE sa.part_to_site (
  objid NUMBER,
  inst_rowid ROWID,
  max_data DATE
);
ALTER TABLE sa.part_to_site ADD SUPPLEMENTAL LOG GROUP dmtsora324801125_0 (inst_rowid, max_data, objid) ALWAYS;