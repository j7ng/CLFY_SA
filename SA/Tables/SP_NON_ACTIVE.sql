CREATE TABLE sa.sp_non_active (
  objid NUMBER
);
ALTER TABLE sa.sp_non_active ADD SUPPLEMENTAL LOG GROUP dmtsora161774652_0 (objid) ALWAYS;