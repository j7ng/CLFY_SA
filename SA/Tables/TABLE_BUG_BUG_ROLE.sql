CREATE TABLE sa.table_bug_bug_role (
  objid NUMBER,
  dev NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  role_for2bug NUMBER,
  player2bug NUMBER
);
ALTER TABLE sa.table_bug_bug_role ADD SUPPLEMENTAL LOG GROUP dmtsora1814639918_0 ("ACTIVE", dev, objid, player2bug, role_for2bug, role_name) ALWAYS;