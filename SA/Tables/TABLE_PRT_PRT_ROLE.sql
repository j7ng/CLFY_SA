CREATE TABLE sa.table_prt_prt_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  dev NUMBER,
  role_for2site_part NUMBER(*,0),
  player2site_part NUMBER(*,0)
);
ALTER TABLE sa.table_prt_prt_role ADD SUPPLEMENTAL LOG GROUP dmtsora2069891474_0 ("ACTIVE", dev, objid, player2site_part, role_for2site_part, role_name) ALWAYS;