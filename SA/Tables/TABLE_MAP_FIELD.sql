CREATE TABLE sa.table_map_field (
  objid NUMBER,
  focus_trans_id VARCHAR2(20 BYTE),
  focus_fldname VARCHAR2(32 BYTE),
  trans_fldname VARCHAR2(32 BYTE),
  comments VARCHAR2(255 BYTE),
  unit_type VARCHAR2(30 BYTE),
  dev NUMBER,
  map_field2map_path NUMBER(*,0)
);
ALTER TABLE sa.table_map_field ADD SUPPLEMENTAL LOG GROUP dmtsora852591590_0 (comments, dev, focus_fldname, focus_trans_id, map_field2map_path, objid, trans_fldname, unit_type) ALWAYS;