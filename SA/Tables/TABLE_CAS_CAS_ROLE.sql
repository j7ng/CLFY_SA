CREATE TABLE sa.table_cas_cas_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  dev NUMBER,
  role_for2case NUMBER(*,0),
  player2case NUMBER(*,0)
);
ALTER TABLE sa.table_cas_cas_role ADD SUPPLEMENTAL LOG GROUP dmtsora190349146_0 ("ACTIVE", dev, objid, player2case, role_for2case, role_name) ALWAYS;