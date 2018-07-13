CREATE TABLE sa.table_config_mgr (
  objid NUMBER,
  platform VARCHAR2(80 BYTE),
  command VARCHAR2(80 BYTE),
  "TYPE" VARCHAR2(80 BYTE),
  add_info VARCHAR2(80 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_config_mgr ADD SUPPLEMENTAL LOG GROUP dmtsora28171930_0 (add_info, command, dev, objid, platform, "TYPE") ALWAYS;