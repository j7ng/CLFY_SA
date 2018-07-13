CREATE TABLE sa.table_cls_prop_map (
  objid NUMBER,
  db_data_type NUMBER,
  display_name VARCHAR2(80 BYTE),
  sch_name VARCHAR2(255 BYTE),
  flag NUMBER,
  context_map VARCHAR2(255 BYTE),
  src_typ_dsply VARCHAR2(20 BYTE),
  source_value VARCHAR2(255 BYTE),
  focus_type NUMBER,
  appl_id VARCHAR2(20 BYTE),
  db_data_dsply VARCHAR2(20 BYTE),
  list_name VARCHAR2(255 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_cls_prop_map ADD SUPPLEMENTAL LOG GROUP dmtsora544435556_0 (appl_id, context_map, db_data_dsply, db_data_type, dev, display_name, flag, focus_type, list_name, objid, sch_name, source_value, src_typ_dsply) ALWAYS;