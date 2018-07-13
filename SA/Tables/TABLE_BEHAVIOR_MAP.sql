CREATE TABLE sa.table_behavior_map (
  objid NUMBER,
  inh_level NUMBER,
  map_fields VARCHAR2(255 BYTE),
  type_id NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_behavior_map ADD SUPPLEMENTAL LOG GROUP dmtsora2093973671_0 (dev, inh_level, map_fields, objid, type_id) ALWAYS;