CREATE TABLE sa.table_con_pc_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  last_update DATE,
  con_pc_role2contact NUMBER,
  con_pc_role2pay_channel NUMBER
);
ALTER TABLE sa.table_con_pc_role ADD SUPPLEMENTAL LOG GROUP dmtsora138637397_0 ("ACTIVE", con_pc_role2contact, con_pc_role2pay_channel, dev, focus_type, last_update, objid, role_name) ALWAYS;