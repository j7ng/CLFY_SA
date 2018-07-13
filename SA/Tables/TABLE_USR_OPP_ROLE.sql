CREATE TABLE sa.table_usr_opp_role (
  objid NUMBER,
  "ACTIVE" NUMBER,
  role_name VARCHAR2(80 BYTE),
  s_role_name VARCHAR2(80 BYTE),
  comments VARCHAR2(255 BYTE),
  focus_type NUMBER,
  dev NUMBER,
  usr_role2opportunity NUMBER,
  opp_role2user NUMBER
);
ALTER TABLE sa.table_usr_opp_role ADD SUPPLEMENTAL LOG GROUP dmtsora1163423389_0 ("ACTIVE", comments, dev, focus_type, objid, opp_role2user, role_name, s_role_name, usr_role2opportunity) ALWAYS;