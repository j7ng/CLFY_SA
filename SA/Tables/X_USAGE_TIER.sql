CREATE TABLE sa.x_usage_tier (
  usage_tier_id NUMBER(2) NOT NULL,
  usage_percentage NUMBER(5,2) NOT NULL,
  insert_timestamp DATE,
  update_timestamp DATE,
  CONSTRAINT pk_x_usage_tier PRIMARY KEY (usage_tier_id)
);
COMMENT ON TABLE sa.x_usage_tier IS 'Stores the mapping of Tier with percentage';
COMMENT ON COLUMN sa.x_usage_tier.usage_tier_id IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_usage_tier.usage_percentage IS 'Percentage value will be stored';
COMMENT ON COLUMN sa.x_usage_tier.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_usage_tier.update_timestamp IS 'Last date when the record was last modified';