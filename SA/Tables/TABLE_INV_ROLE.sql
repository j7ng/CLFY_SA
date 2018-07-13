CREATE TABLE sa.table_inv_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  "RANK" NUMBER,
  dev NUMBER,
  inv_role2inv_locatn NUMBER(*,0),
  inv_role2site NUMBER(*,0)
);
ALTER TABLE sa.table_inv_role ADD SUPPLEMENTAL LOG GROUP dmtsora232940373_0 ("ACTIVE", dev, focus_type, inv_role2inv_locatn, inv_role2site, objid, "RANK", role_name) ALWAYS;