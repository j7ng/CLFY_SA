CREATE TABLE sa.table_log_default_device (
  esn VARCHAR2(30 BYTE) NOT NULL,
  "MIN" VARCHAR2(30 BYTE) DEFAULT 'INACTIVE' NOT NULL,
  brand VARCHAR2(30 BYTE),
  app_name VARCHAR2(250 BYTE),
  app_version VARCHAR2(30 BYTE),
  device_model VARCHAR2(250 BYTE),
  os_version VARCHAR2(30 BYTE),
  source_system VARCHAR2(30 BYTE),
  language VARCHAR2(30 BYTE),
  creation_date DATE,
  modified_date DATE,
  client_app_type VARCHAR2(10 BYTE) NOT NULL,
  web_account_id VARCHAR2(255 BYTE) DEFAULT 'INACTIVE' NOT NULL,
  channel_id VARCHAR2(255 BYTE) DEFAULT 'INACTIVE' NOT NULL,
  device_id VARCHAR2(255 BYTE) DEFAULT 'INACTIVE' NOT NULL,
  CONSTRAINT pk_log_default_dev PRIMARY KEY (esn,"MIN",client_app_type,web_account_id,channel_id,device_id)
);
COMMENT ON COLUMN sa.table_log_default_device.web_account_id IS 'Web User Account Id';
COMMENT ON COLUMN sa.table_log_default_device.channel_id IS 'Channel Id';
COMMENT ON COLUMN sa.table_log_default_device.device_id IS 'Device Id';