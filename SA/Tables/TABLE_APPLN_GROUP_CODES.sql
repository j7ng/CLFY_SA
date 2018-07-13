CREATE TABLE sa.table_appln_group_codes (
  objid NUMBER,
  dev NUMBER,
  int_val VARCHAR2(40 BYTE),
  ext_val VARCHAR2(40 BYTE),
  ext_src VARCHAR2(30 BYTE),
  code_group VARCHAR2(30 BYTE),
  description VARCHAR2(80 BYTE)
);
ALTER TABLE sa.table_appln_group_codes ADD SUPPLEMENTAL LOG GROUP dmtsora225823777_0 (code_group, description, dev, ext_src, ext_val, int_val, objid) ALWAYS;