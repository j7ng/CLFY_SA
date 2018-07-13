CREATE TABLE sa.table_ctx_obj_db (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  "TYPE" NUMBER,
  idx NUMBER,
  behavior NUMBER,
  str_size NUMBER,
  dev NUMBER,
  ctx_obj2window_db NUMBER(*,0),
  caption VARCHAR2(80 BYTE),
  subtype VARCHAR2(32 BYTE)
);
ALTER TABLE sa.table_ctx_obj_db ADD SUPPLEMENTAL LOG GROUP dmtsora1180296810_0 (behavior, caption, ctx_obj2window_db, dev, idx, objid, str_size, subtype, title, "TYPE") ALWAYS;