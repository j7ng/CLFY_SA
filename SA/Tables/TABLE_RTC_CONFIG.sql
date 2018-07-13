CREATE TABLE sa.table_rtc_config (
  event_type VARCHAR2(30 BYTE),
  brand_name VARCHAR2(30 BYTE),
  phone_model VARCHAR2(30 BYTE),
  service_plan VARCHAR2(400 BYTE),
  short_code VARCHAR2(50 BYTE),
  sms_text_template VARCHAR2(1000 BYTE),
  comm_channel VARCHAR2(20 BYTE),
  campaign_cd VARCHAR2(40 BYTE),
  seg1 VARCHAR2(50 BYTE),
  seg2 VARCHAR2(50 BYTE),
  seg3 VARCHAR2(50 BYTE),
  udf1 VARCHAR2(50 BYTE),
  udf2 VARCHAR2(50 BYTE),
  udf3 VARCHAR2(50 BYTE)
);
COMMENT ON COLUMN sa.table_rtc_config.event_type IS 'Type of event that triggered the communication';
COMMENT ON COLUMN sa.table_rtc_config.brand_name IS 'Brand name';
COMMENT ON COLUMN sa.table_rtc_config.phone_model IS 'isBYOP or NOT (BYOP, NOT_BYOP)';
COMMENT ON COLUMN sa.table_rtc_config.service_plan IS 'Market name from service plan table';
COMMENT ON COLUMN sa.table_rtc_config.short_code IS 'Short code for SMS provided by business';
COMMENT ON COLUMN sa.table_rtc_config.sms_text_template IS 'SMS message template';
COMMENT ON COLUMN sa.table_rtc_config.comm_channel IS 'EMAIL or SMS or ALL';
COMMENT ON COLUMN sa.table_rtc_config.campaign_cd IS 'campaign identifier to be passed to Email partner';
COMMENT ON COLUMN sa.table_rtc_config.seg1 IS 'Placeholder for addl data';
COMMENT ON COLUMN sa.table_rtc_config.seg2 IS 'Placeholder for addl data';
COMMENT ON COLUMN sa.table_rtc_config.seg3 IS 'Placeholder for addl data';
COMMENT ON COLUMN sa.table_rtc_config.udf1 IS 'Placeholder for addl data';
COMMENT ON COLUMN sa.table_rtc_config.udf2 IS 'Placeholder for addl data';
COMMENT ON COLUMN sa.table_rtc_config.udf3 IS 'Placeholder for addl data';