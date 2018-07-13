CREATE TABLE sa.table_xfilter (
  objid NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  type_name VARCHAR2(30 BYTE),
  field_list LONG,
  dev NUMBER,
  addnl_info VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_xfilter ADD SUPPLEMENTAL LOG GROUP dmtsora175699521_0 (addnl_info, dev, "NAME", objid, type_name) ALWAYS;