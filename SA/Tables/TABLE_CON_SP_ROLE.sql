CREATE TABLE sa.table_con_sp_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  last_update DATE,
  con_sp_role2contact NUMBER,
  con_sp_role2site_part NUMBER
);
ALTER TABLE sa.table_con_sp_role ADD SUPPLEMENTAL LOG GROUP dmtsora761354028_0 ("ACTIVE", con_sp_role2contact, con_sp_role2site_part, dev, focus_type, last_update, objid, role_name) ALWAYS;