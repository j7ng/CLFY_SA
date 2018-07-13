CREATE TABLE sa.x_usage_host (
  propagate_flag_value NUMBER(4) NOT NULL,
  usage_host_name VARCHAR2(50 BYTE),
  request_carrier_inquiry_flag VARCHAR2(1 BYTE),
  short_name VARCHAR2(20 BYTE),
  insert_timestamp DATE NOT NULL,
  update_timestamp DATE NOT NULL,
  carrier_mtg_id NUMBER(22),
  timeout_minutes_threshold NUMBER(22),
  daily_attempts_threshold NUMBER(22),
  host_short_name VARCHAR2(20 BYTE),
  throttling_delay_minutes NUMBER,
  dummy_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  tton_by_red_date_flag VARCHAR2(1 BYTE),
  ubi_info_storage_location VARCHAR2(30 BYTE),
  CONSTRAINT x_usage_host_pk PRIMARY KEY (propagate_flag_value)
);
COMMENT ON TABLE sa.x_usage_host IS 'Stores the different hosts a subscribers data is being managed from.';
COMMENT ON COLUMN sa.x_usage_host.propagate_flag_value IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.x_usage_host.usage_host_name IS 'Name of the host the subscriber belongs to.';
COMMENT ON COLUMN sa.x_usage_host.request_carrier_inquiry_flag IS 'Flag to determine when to send carrier inquiry.';
COMMENT ON COLUMN sa.x_usage_host.short_name IS 'Short name of the host the subscriber belongs to.';
COMMENT ON COLUMN sa.x_usage_host.insert_timestamp IS 'Date when the record was created';
COMMENT ON COLUMN sa.x_usage_host.update_timestamp IS 'Last date when the record was modified';
COMMENT ON COLUMN sa.x_usage_host.carrier_mtg_id IS 'Carrier Metering ID for voice,sms,Data';
COMMENT ON COLUMN sa.x_usage_host.timeout_minutes_threshold IS 'Thereshold for time out';
COMMENT ON COLUMN sa.x_usage_host.daily_attempts_threshold IS 'Thereshold for daily attempts';
COMMENT ON COLUMN sa.x_usage_host.host_short_name IS 'short name for the source of the transaction';
COMMENT ON COLUMN sa.x_usage_host.throttling_delay_minutes IS 'throttling transaction window in minutes';
COMMENT ON COLUMN sa.x_usage_host.dummy_flag IS 'To identify the value is dummy or not';
COMMENT ON COLUMN sa.x_usage_host.tton_by_red_date_flag IS 'Throttling window rule based on redemption date sending by 3ci while throttling';