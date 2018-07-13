CREATE TABLE sa.table_x_tiers (
  objid NUMBER,
  tier_type VARCHAR2(50 BYTE),
  tier_min_value NUMBER(12,2),
  tier_max_value NUMBER(12,2),
  x_amount NUMBER(20,2),
  start_date DATE,
  end_date DATE
);
COMMENT ON COLUMN sa.table_x_tiers.objid IS 'UNIQUE RECORD IDENTIFIER';
COMMENT ON COLUMN sa.table_x_tiers.tier_type IS 'TIER TYPE';
COMMENT ON COLUMN sa.table_x_tiers.tier_min_value IS 'THE MINIMUM VALUE OF TIER';
COMMENT ON COLUMN sa.table_x_tiers.tier_max_value IS 'THE MAXIMUM VALUE OF TIER';
COMMENT ON COLUMN sa.table_x_tiers.x_amount IS 'THE AMOUNT THAT CAN BE PAID FOR THIS TIER';
COMMENT ON COLUMN sa.table_x_tiers.start_date IS 'EFFECTIVE START DATE OF TIER';
COMMENT ON COLUMN sa.table_x_tiers.end_date IS 'EFFECTIVE END DATE OF TIER';