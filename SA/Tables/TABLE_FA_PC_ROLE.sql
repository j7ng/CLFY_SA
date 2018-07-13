CREATE TABLE sa.table_fa_pc_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  last_update DATE,
  fa_pc_role2fin_accnt NUMBER,
  fa_pc_role2pay_channel NUMBER
);
ALTER TABLE sa.table_fa_pc_role ADD SUPPLEMENTAL LOG GROUP dmtsora1651535168_0 ("ACTIVE", dev, fa_pc_role2fin_accnt, fa_pc_role2pay_channel, focus_type, last_update, objid, role_name) ALWAYS;