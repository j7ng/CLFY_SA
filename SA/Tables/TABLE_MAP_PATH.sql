CREATE TABLE sa.table_map_path (
  objid NUMBER,
  fm_focus_type NUMBER,
  to_focus_type NUMBER,
  "PATH" VARCHAR2(255 BYTE),
  branch_no NUMBER,
  dev NUMBER,
  map_path2trans_map NUMBER(*,0)
);
ALTER TABLE sa.table_map_path ADD SUPPLEMENTAL LOG GROUP dmtsora2017949444_0 (branch_no, dev, fm_focus_type, map_path2trans_map, objid, "PATH", to_focus_type) ALWAYS;