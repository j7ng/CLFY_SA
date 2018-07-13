CREATE TABLE sa.table_x_tracking_campaign (
  objid NUMBER,
  x_campaign_id VARCHAR2(20 BYTE),
  x_campaign_desc VARCHAR2(50 BYTE)
);
ALTER TABLE sa.table_x_tracking_campaign ADD SUPPLEMENTAL LOG GROUP dmtsora122549471_0 (objid, x_campaign_desc, x_campaign_id) ALWAYS;
COMMENT ON TABLE sa.table_x_tracking_campaign IS 'Contains the Campaign records for online tracking';
COMMENT ON COLUMN sa.table_x_tracking_campaign.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_tracking_campaign.x_campaign_id IS 'Site ID';
COMMENT ON COLUMN sa.table_x_tracking_campaign.x_campaign_desc IS 'Site Description';