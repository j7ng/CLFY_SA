CREATE TABLE sa.table_x_campaign (
  objid NUMBER,
  x_campaign_id NUMBER,
  x_campain_title VARCHAR2(30 BYTE),
  x_campaign_single_use NUMBER,
  x_html_doc_location VARCHAR2(100 BYTE),
  x_text_doc_location VARCHAR2(100 BYTE),
  x_campaign_description VARCHAR2(255 BYTE),
  x_create_date DATE,
  x_campaign2x_promotion NUMBER
);
ALTER TABLE sa.table_x_campaign ADD SUPPLEMENTAL LOG GROUP dmtsora1355570762_0 (objid, x_campaign2x_promotion, x_campaign_description, x_campaign_id, x_campaign_single_use, x_campain_title, x_create_date, x_html_doc_location, x_text_doc_location) ALWAYS;
COMMENT ON TABLE sa.table_x_campaign IS 'Added for campaign';
COMMENT ON COLUMN sa.table_x_campaign.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_campaign.x_campaign_id IS 'Campaign Identification Number';
COMMENT ON COLUMN sa.table_x_campaign.x_campain_title IS 'Description used by Web.';
COMMENT ON COLUMN sa.table_x_campaign.x_campaign_single_use IS 'Identifies number of times a campaign can be redeeemed';
COMMENT ON COLUMN sa.table_x_campaign.x_html_doc_location IS 'Location of Web Document';
COMMENT ON COLUMN sa.table_x_campaign.x_text_doc_location IS 'Location of Text document';
COMMENT ON COLUMN sa.table_x_campaign.x_campaign_description IS 'Description used by Web.';
COMMENT ON COLUMN sa.table_x_campaign.x_create_date IS 'Create date for the campaign';
COMMENT ON COLUMN sa.table_x_campaign.x_campaign2x_promotion IS 'relation to promotion';