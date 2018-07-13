CREATE TABLE sa.table_per_addr_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  per_addr_role2address NUMBER(*,0),
  per_addr_role2person NUMBER(*,0)
);
ALTER TABLE sa.table_per_addr_role ADD SUPPLEMENTAL LOG GROUP dmtsora472499251_0 ("ACTIVE", dev, focus_type, objid, per_addr_role2address, per_addr_role2person, role_name) ALWAYS;