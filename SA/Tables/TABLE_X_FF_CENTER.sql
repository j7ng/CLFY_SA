CREATE TABLE sa.table_x_ff_center (
  dev NUMBER,
  objid NUMBER,
  x_ff_name VARCHAR2(30 BYTE),
  x_ff_code VARCHAR2(30 BYTE),
  x_ranking NUMBER,
  x_status_exception VARCHAR2(80 BYTE)
);
ALTER TABLE sa.table_x_ff_center ADD SUPPLEMENTAL LOG GROUP dmtsora2042040415_0 (dev, objid, x_ff_code, x_ff_name, x_ranking, x_status_exception) ALWAYS;
COMMENT ON TABLE sa.table_x_ff_center IS 'Fulfillment Center';
COMMENT ON COLUMN sa.table_x_ff_center.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_ff_center.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ff_center.x_ff_name IS 'fulfillment center name';
COMMENT ON COLUMN sa.table_x_ff_center.x_ff_code IS 'fulfillment center code';
COMMENT ON COLUMN sa.table_x_ff_center.x_ranking IS 'FF Center Preference when shipping cost the same 1 > 5';
COMMENT ON COLUMN sa.table_x_ff_center.x_status_exception IS 'Is the case status matches, the FF center will be used';