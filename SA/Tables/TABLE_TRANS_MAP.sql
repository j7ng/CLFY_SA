CREATE TABLE sa.table_trans_map (
  objid NUMBER,
  detail_level NUMBER,
  map_id NUMBER,
  subtotal_cat VARCHAR2(10 BYTE),
  focus_type NUMBER,
  dev NUMBER,
  map2dataset NUMBER(*,0)
);
ALTER TABLE sa.table_trans_map ADD SUPPLEMENTAL LOG GROUP dmtsora1991038407_0 (detail_level, dev, focus_type, map2dataset, map_id, objid, subtotal_cat) ALWAYS;