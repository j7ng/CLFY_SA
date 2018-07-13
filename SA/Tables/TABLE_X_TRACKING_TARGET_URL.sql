CREATE TABLE sa.table_x_tracking_target_url (
  objid NUMBER,
  x_target_url_id VARCHAR2(20 BYTE),
  x_target_url VARCHAR2(100 BYTE)
);
ALTER TABLE sa.table_x_tracking_target_url ADD SUPPLEMENTAL LOG GROUP dmtsora1465037953_0 (objid, x_target_url, x_target_url_id) ALWAYS;
COMMENT ON TABLE sa.table_x_tracking_target_url IS 'Contains the Target URL records for online tracking';
COMMENT ON COLUMN sa.table_x_tracking_target_url.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_tracking_target_url.x_target_url_id IS 'Target URL ID';
COMMENT ON COLUMN sa.table_x_tracking_target_url.x_target_url IS 'Target URL Description';