CREATE TABLE sa.table_per_prt_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  per_prt_role2person NUMBER(*,0),
  pprt_role2site_part NUMBER(*,0)
);
ALTER TABLE sa.table_per_prt_role ADD SUPPLEMENTAL LOG GROUP dmtsora1183712812_0 ("ACTIVE", dev, focus_type, objid, per_prt_role2person, pprt_role2site_part, role_name) ALWAYS;