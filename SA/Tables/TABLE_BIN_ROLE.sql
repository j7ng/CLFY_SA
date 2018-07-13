CREATE TABLE sa.table_bin_role (
  objid NUMBER,
  staged_as NUMBER,
  dev NUMBER,
  bin_role2part_used NUMBER(*,0),
  bin_role2inv_bin NUMBER(*,0)
);
ALTER TABLE sa.table_bin_role ADD SUPPLEMENTAL LOG GROUP dmtsora1363973959_0 (bin_role2inv_bin, bin_role2part_used, dev, objid, staged_as) ALWAYS;