CREATE TABLE sa.migration_campaign_msgs (
  campaign_name VARCHAR2(200 BYTE),
  display_in_brands VARCHAR2(800 BYTE),
  display_in_channels VARCHAR2(800 BYTE),
  language VARCHAR2(30 BYTE),
  migration_status VARCHAR2(800 BYTE),
  updated_by VARCHAR2(30 BYTE),
  update_date DATE,
  message_title VARCHAR2(80 BYTE),
  message_text VARCHAR2(2000 BYTE)
);