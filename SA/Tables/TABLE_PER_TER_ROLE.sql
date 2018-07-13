CREATE TABLE sa.table_per_ter_role (
  objid NUMBER,
  dev NUMBER,
  per_role2territory NUMBER(*,0),
  terr_role2person NUMBER(*,0)
);
ALTER TABLE sa.table_per_ter_role ADD SUPPLEMENTAL LOG GROUP dmtsora1272234415_0 (dev, objid, per_role2territory, terr_role2person) ALWAYS;