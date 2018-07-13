CREATE TABLE sa.table_x_tracking_position (
  objid NUMBER,
  x_position_id VARCHAR2(20 BYTE),
  x_position_desc VARCHAR2(50 BYTE)
);
ALTER TABLE sa.table_x_tracking_position ADD SUPPLEMENTAL LOG GROUP dmtsora2039285350_0 (objid, x_position_desc, x_position_id) ALWAYS;
COMMENT ON TABLE sa.table_x_tracking_position IS 'Contains the position records for online tracking';
COMMENT ON COLUMN sa.table_x_tracking_position.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_tracking_position.x_position_id IS 'Position ID';
COMMENT ON COLUMN sa.table_x_tracking_position.x_position_desc IS 'Position Description';