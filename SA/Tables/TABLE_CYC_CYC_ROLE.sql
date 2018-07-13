CREATE TABLE sa.table_cyc_cyc_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  dev NUMBER,
  role_for2life_cycle NUMBER(*,0),
  player2life_cycle NUMBER(*,0)
);
ALTER TABLE sa.table_cyc_cyc_role ADD SUPPLEMENTAL LOG GROUP dmtsora266735646_0 ("ACTIVE", dev, objid, player2life_cycle, role_for2life_cycle, role_name) ALWAYS;