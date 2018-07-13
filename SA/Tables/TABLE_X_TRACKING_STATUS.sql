CREATE TABLE sa.table_x_tracking_status (
  objid NUMBER,
  x_status_id VARCHAR2(20 BYTE),
  x_status_desc VARCHAR2(50 BYTE)
);
ALTER TABLE sa.table_x_tracking_status ADD SUPPLEMENTAL LOG GROUP dmtsora2127806953_0 (objid, x_status_desc, x_status_id) ALWAYS;
COMMENT ON TABLE sa.table_x_tracking_status IS 'Contains the Status records for online tracking';
COMMENT ON COLUMN sa.table_x_tracking_status.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_tracking_status.x_status_id IS 'Site ID';
COMMENT ON COLUMN sa.table_x_tracking_status.x_status_desc IS 'Site Description';