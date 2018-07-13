CREATE TABLE sa.x_reward_benefit_conversion (
  objid NUMBER NOT NULL,
  brand VARCHAR2(100 BYTE),
  from_benefit_type VARCHAR2(100 BYTE),
  from_amount NUMBER,
  to_benefit_type VARCHAR2(100 BYTE),
  to_amount NUMBER,
  "PRIORITY" NUMBER,
  start_date DATE,
  end_date DATE,
  is_reversable VARCHAR2(3 BYTE),
  CONSTRAINT ben_conv_objid_pk PRIMARY KEY (objid),
  CONSTRAINT ben_con_uq UNIQUE (brand,from_benefit_type,to_benefit_type)
);
COMMENT ON TABLE sa.x_reward_benefit_conversion IS 'This new table defines dynamic benefit to benefit conversion rules.';
COMMENT ON COLUMN sa.x_reward_benefit_conversion.objid IS 'Unique record identifier';
COMMENT ON COLUMN sa.x_reward_benefit_conversion.brand IS 'Brand Name : NET10/SIMPLE MOBILE/STRAIGHT TALK/TRACFONE';
COMMENT ON COLUMN sa.x_reward_benefit_conversion.from_benefit_type IS 'Type of Benefit : UPGRADE_BENEFITS / UPGRADE_POINTS / LOYALTY_POINTS';
COMMENT ON COLUMN sa.x_reward_benefit_conversion.from_amount IS 'Unit / Quantity Need for Conversion';
COMMENT ON COLUMN sa.x_reward_benefit_conversion.to_benefit_type IS 'Type of Benefit : UPGRADE_BENEFITS / UPGRADE_POINTS / LOYALTY_POINTS';
COMMENT ON COLUMN sa.x_reward_benefit_conversion.to_amount IS 'Unit / Quantity received from Conversion ';
COMMENT ON COLUMN sa.x_reward_benefit_conversion."PRIORITY" IS 'Priority of this rule compared to others';
COMMENT ON COLUMN sa.x_reward_benefit_conversion.start_date IS 'Start Date when rule is effective';
COMMENT ON COLUMN sa.x_reward_benefit_conversion.end_date IS 'End date when the rule is no longer effective';
COMMENT ON COLUMN sa.x_reward_benefit_conversion.is_reversable IS 'States if the conversion can be reversed (Y/N)';