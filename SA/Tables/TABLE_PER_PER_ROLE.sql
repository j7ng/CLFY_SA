CREATE TABLE sa.table_per_per_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  dev NUMBER,
  role_for2person NUMBER(*,0),
  player2person NUMBER(*,0)
);
ALTER TABLE sa.table_per_per_role ADD SUPPLEMENTAL LOG GROUP dmtsora744028477_0 ("ACTIVE", dev, objid, player2person, role_for2person, role_name) ALWAYS;