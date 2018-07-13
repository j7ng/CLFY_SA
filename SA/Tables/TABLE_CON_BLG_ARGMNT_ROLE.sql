CREATE TABLE sa.table_con_blg_argmnt_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  last_update DATE,
  ba_role2blg_argmnt NUMBER,
  con_role2contact NUMBER
);
ALTER TABLE sa.table_con_blg_argmnt_role ADD SUPPLEMENTAL LOG GROUP dmtsora1040687782_0 ("ACTIVE", ba_role2blg_argmnt, con_role2contact, dev, focus_type, last_update, objid, role_name) ALWAYS;