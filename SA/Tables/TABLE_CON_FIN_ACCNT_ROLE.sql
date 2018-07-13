CREATE TABLE sa.table_con_fin_accnt_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  last_update DATE,
  fin_accnt_role2fin_accnt NUMBER,
  con_accnt_role2contact NUMBER
);
ALTER TABLE sa.table_con_fin_accnt_role ADD SUPPLEMENTAL LOG GROUP dmtsora1389944974_0 ("ACTIVE", con_accnt_role2contact, dev, fin_accnt_role2fin_accnt, focus_type, last_update, objid, role_name) ALWAYS;