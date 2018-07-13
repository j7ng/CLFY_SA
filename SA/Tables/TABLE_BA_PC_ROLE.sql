CREATE TABLE sa.table_ba_pc_role (
  objid NUMBER,
  role_name VARCHAR2(80 BYTE),
  focus_type NUMBER,
  "ACTIVE" NUMBER,
  dev NUMBER,
  last_update DATE,
  ba_pc_role2blg_argmnt NUMBER,
  ba_pc_role2pay_channel NUMBER
);
ALTER TABLE sa.table_ba_pc_role ADD SUPPLEMENTAL LOG GROUP dmtsora1471257040_0 ("ACTIVE", ba_pc_role2blg_argmnt, ba_pc_role2pay_channel, dev, focus_type, last_update, objid, role_name) ALWAYS;