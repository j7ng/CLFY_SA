CREATE TABLE sa.adfcrm_carrier_switch_coverage (
  source_parent VARCHAR2(30 BYTE),
  target_parent VARCHAR2(30 BYTE),
  warning VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.adfcrm_carrier_switch_coverage IS 'This table is used to hold upgrade combinations source phone''s carrier and target phone''s carrier that would impact the existing service coverage.';
COMMENT ON COLUMN sa.adfcrm_carrier_switch_coverage.source_parent IS 'Reference to table_x_parent.x_parent_name to store the source phone''s parent.';
COMMENT ON COLUMN sa.adfcrm_carrier_switch_coverage.target_parent IS 'Reference to table_x_parent.x_parent_name to store the target phone''s parent. ';
COMMENT ON COLUMN sa.adfcrm_carrier_switch_coverage.warning IS 'holds yes or no values on warning for upgrades ';