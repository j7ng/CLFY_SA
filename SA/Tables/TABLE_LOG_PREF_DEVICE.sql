CREATE TABLE sa.table_log_pref_device (
  objid NUMBER NOT NULL,
  web_account_id VARCHAR2(255 BYTE),
  channel_id VARCHAR2(255 BYTE),
  device_id VARCHAR2(255 BYTE),
  esn VARCHAR2(50 BYTE),
  "MIN" VARCHAR2(50 BYTE),
  preference_flag VARCHAR2(1 BYTE),
  brand VARCHAR2(100 BYTE),
  created_date DATE,
  modified_date DATE,
  CONSTRAINT pk_log_pref_device PRIMARY KEY (objid),
  CONSTRAINT uq_log_pref_device UNIQUE (web_account_id,channel_id,device_id,esn)
);
COMMENT ON TABLE sa.table_log_pref_device IS 'To store the preference obtained from a device for all the Devices associated with the account';
COMMENT ON COLUMN sa.table_log_pref_device.objid IS 'Unique Identifier';
COMMENT ON COLUMN sa.table_log_pref_device.web_account_id IS 'Web User Account Id';
COMMENT ON COLUMN sa.table_log_pref_device.channel_id IS 'Channel Id';
COMMENT ON COLUMN sa.table_log_pref_device.device_id IS 'Device Id';
COMMENT ON COLUMN sa.table_log_pref_device.esn IS 'ESN';
COMMENT ON COLUMN sa.table_log_pref_device."MIN" IS 'MIN';
COMMENT ON COLUMN sa.table_log_pref_device.preference_flag IS 'Preference';
COMMENT ON COLUMN sa.table_log_pref_device.brand IS 'Brand';
COMMENT ON COLUMN sa.table_log_pref_device.created_date IS 'Audit Columns';
COMMENT ON COLUMN sa.table_log_pref_device.modified_date IS 'Audit Columns';