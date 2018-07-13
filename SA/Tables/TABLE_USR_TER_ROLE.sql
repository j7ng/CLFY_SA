CREATE TABLE sa.table_usr_ter_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  s_role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  user_role2territory NUMBER,
  usr_ter_role2user NUMBER
);
ALTER TABLE sa.table_usr_ter_role ADD SUPPLEMENTAL LOG GROUP dmtsora429609616_0 ("ACTIVE", dev, focus_type, objid, role_name, s_role_name, user_role2territory, usr_ter_role2user) ALWAYS;