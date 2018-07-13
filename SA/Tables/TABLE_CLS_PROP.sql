CREATE TABLE sa.table_cls_prop (
  objid NUMBER,
  destn_path VARCHAR2(245 BYTE),
  source_type NUMBER,
  source_path VARCHAR2(255 BYTE),
  source_value LONG,
  expression VARCHAR2(255 BYTE),
  userdef_ind NUMBER,
  mand_ind NUMBER,
  display_name VARCHAR2(80 BYTE),
  db_data_type NUMBER,
  db_data_dsply VARCHAR2(20 BYTE),
  src_typ_dsply VARCHAR2(20 BYTE),
  list_name VARCHAR2(255 BYTE),
  dev NUMBER,
  cls_prop2cls_ref NUMBER(*,0)
);
ALTER TABLE sa.table_cls_prop ADD SUPPLEMENTAL LOG GROUP dmtsora2131035796_0 (cls_prop2cls_ref, db_data_dsply, db_data_type, destn_path, dev, display_name, expression, list_name, mand_ind, objid, source_path, source_type, src_typ_dsply, userdef_ind) ALWAYS;