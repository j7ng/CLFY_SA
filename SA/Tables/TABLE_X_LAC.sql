CREATE TABLE sa.table_x_lac (
  objid NUMBER,
  lac2personality NUMBER,
  x_local_area_code NUMBER
);
ALTER TABLE sa.table_x_lac ADD SUPPLEMENTAL LOG GROUP dmtsora1256329811_0 (lac2personality, objid, x_local_area_code) ALWAYS;
COMMENT ON TABLE sa.table_x_lac IS 'Contains local areas code numbers';
COMMENT ON COLUMN sa.table_x_lac.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_lac.lac2personality IS 'Personality Relation to Local Area Codes';
COMMENT ON COLUMN sa.table_x_lac.x_local_area_code IS 'Local Area Codes';