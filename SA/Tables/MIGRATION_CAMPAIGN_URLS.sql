CREATE TABLE sa.migration_campaign_urls (
  campaign_name VARCHAR2(200 BYTE),
  display_url VARCHAR2(100 BYTE) NOT NULL,
  campaign_url VARCHAR2(200 BYTE) NOT NULL
);
COMMENT ON COLUMN sa.migration_campaign_urls.campaign_name IS 'The offer this url belongs to';
COMMENT ON COLUMN sa.migration_campaign_urls.display_url IS 'Where to display the URL';
COMMENT ON COLUMN sa.migration_campaign_urls.campaign_url IS 'Actual Url';