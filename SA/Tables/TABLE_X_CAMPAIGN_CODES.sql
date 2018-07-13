CREATE TABLE sa.table_x_campaign_codes (
  objid NUMBER,
  x_campaign_type VARCHAR2(100 BYTE),
  x_document_id VARCHAR2(30 BYTE),
  x_target_url VARCHAR2(100 BYTE),
  x_campaign_desc VARCHAR2(200 BYTE),
  x_expire_dt DATE
);
ALTER TABLE sa.table_x_campaign_codes ADD SUPPLEMENTAL LOG GROUP dmtsora141079621_0 (objid, x_campaign_desc, x_campaign_type, x_document_id, x_expire_dt, x_target_url) ALWAYS;
COMMENT ON TABLE sa.table_x_campaign_codes IS 'Campaign codes to link to the campaign lists';
COMMENT ON COLUMN sa.table_x_campaign_codes.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_campaign_codes.x_campaign_type IS 'Campaign type';
COMMENT ON COLUMN sa.table_x_campaign_codes.x_document_id IS 'TBD';
COMMENT ON COLUMN sa.table_x_campaign_codes.x_target_url IS 'TBD';
COMMENT ON COLUMN sa.table_x_campaign_codes.x_campaign_desc IS 'TBD';
COMMENT ON COLUMN sa.table_x_campaign_codes.x_expire_dt IS 'TBD';