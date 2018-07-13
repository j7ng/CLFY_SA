CREATE TABLE sa.table_per_sce_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  dev NUMBER,
  per_role2lead_source NUMBER(*,0),
  sce_role2person NUMBER(*,0)
);
ALTER TABLE sa.table_per_sce_role ADD SUPPLEMENTAL LOG GROUP dmtsora812942512_0 ("ACTIVE", dev, objid, per_role2lead_source, role_name, sce_role2person) ALWAYS;