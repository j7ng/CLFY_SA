CREATE TABLE sa.x_lease_scoring_rules (
  score_code VARCHAR2(40 BYTE),
  score_desc VARCHAR2(2000 BYTE),
  time_unit VARCHAR2(20 BYTE),
  range_start NUMBER,
  range_stop NUMBER,
  insert_date TIMESTAMP,
  update_date TIMESTAMP
);
COMMENT ON COLUMN sa.x_lease_scoring_rules.score_code IS 'Current Score code';
COMMENT ON COLUMN sa.x_lease_scoring_rules.score_desc IS 'Current Score description';
COMMENT ON COLUMN sa.x_lease_scoring_rules.time_unit IS 'Current Time unit';
COMMENT ON COLUMN sa.x_lease_scoring_rules.range_start IS 'Current Starting Range';
COMMENT ON COLUMN sa.x_lease_scoring_rules.range_stop IS 'Current Stopping Range';
COMMENT ON COLUMN sa.x_lease_scoring_rules.insert_date IS 'Date record inserted';
COMMENT ON COLUMN sa.x_lease_scoring_rules.update_date IS 'Date record last updated';