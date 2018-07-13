CREATE TABLE sa.table_con_lsc_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  s_role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  con_lsc2contact NUMBER,
  con_lsc2lead_source NUMBER
);
ALTER TABLE sa.table_con_lsc_role ADD SUPPLEMENTAL LOG GROUP dmtsora1164086774_0 ("ACTIVE", con_lsc2contact, con_lsc2lead_source, dev, focus_type, objid, role_name, s_role_name) ALWAYS;