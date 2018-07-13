CREATE TABLE sa.x_carrier_switch_mapping (
  source_parent VARCHAR2(30 BYTE),
  target_parent VARCHAR2(30 BYTE),
  warning_flag VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_carrier_switch_mapping IS 'This table is used to hold upgrade combinations source phone''s carrier and target phone''s carrier that would impact the existing service coverage.';
COMMENT ON COLUMN sa.x_carrier_switch_mapping.source_parent IS 'Reference to table_x_parent.x_parent_name to store the source phone''s parent.';
COMMENT ON COLUMN sa.x_carrier_switch_mapping.target_parent IS 'Reference to table_x_parent.x_parent_name to store the target phone''s parent. ';
COMMENT ON COLUMN sa.x_carrier_switch_mapping.warning_flag IS 'holds yes or no values on WARNING_FLAG for upgrades ';