CREATE TABLE sa.phone_upgrade_scenarios (
  brand VARCHAR2(100 BYTE),
  from_phone_short_parent VARCHAR2(100 BYTE),
  from_phone_device_type VARCHAR2(100 BYTE),
  to_phone_short_parent VARCHAR2(100 BYTE),
  to_phone_device_type VARCHAR2(100 BYTE),
  billing_plan VARCHAR2(100 BYTE),
  channel VARCHAR2(100 BYTE),
  block_flag VARCHAR2(1 BYTE),
  warning_code VARCHAR2(100 BYTE),
  error_code VARCHAR2(100 BYTE),
  error_message VARCHAR2(200 BYTE)
);
COMMENT ON TABLE sa.phone_upgrade_scenarios IS 'Phone Upgrade Scenarios table to determine block scenarios';
COMMENT ON COLUMN sa.phone_upgrade_scenarios.brand IS 'Brand';
COMMENT ON COLUMN sa.phone_upgrade_scenarios.from_phone_short_parent IS 'from phone short parent name';
COMMENT ON COLUMN sa.phone_upgrade_scenarios.from_phone_device_type IS 'from phone device type';
COMMENT ON COLUMN sa.phone_upgrade_scenarios.to_phone_short_parent IS 'to phone short parent name';
COMMENT ON COLUMN sa.phone_upgrade_scenarios.to_phone_device_type IS 'to phone device_type';
COMMENT ON COLUMN sa.phone_upgrade_scenarios.billing_plan IS 'billing plan';
COMMENT ON COLUMN sa.phone_upgrade_scenarios.channel IS 'channel WEB/IVR';
COMMENT ON COLUMN sa.phone_upgrade_scenarios.block_flag IS 'block flag Y/N ';
COMMENT ON COLUMN sa.phone_upgrade_scenarios.warning_code IS ' warning code ';
COMMENT ON COLUMN sa.phone_upgrade_scenarios.error_code IS 'error code';
COMMENT ON COLUMN sa.phone_upgrade_scenarios.error_message IS 'error message';