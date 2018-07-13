CREATE TABLE sa.table_fts_index_status (
  objid NUMBER,
  "TYPE" NUMBER,
  col_name VARCHAR2(255 BYTE),
  attch_col_name VARCHAR2(255 BYTE),
  lastid NUMBER,
  index_time DATE,
  is_init NUMBER,
  view_id NUMBER,
  parent_fld_id NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_fts_index_status ADD SUPPLEMENTAL LOG GROUP dmtsora1583729598_0 (attch_col_name, col_name, dev, index_time, is_init, lastid, objid, parent_fld_id, "TYPE", view_id) ALWAYS;