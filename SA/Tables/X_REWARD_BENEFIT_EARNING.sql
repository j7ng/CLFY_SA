CREATE TABLE sa.x_reward_benefit_earning (
  objid NUMBER NOT NULL,
  program_name VARCHAR2(100 BYTE),
  benefit_type_code VARCHAR2(100 BYTE) NOT NULL,
  transaction_type VARCHAR2(100 BYTE),
  benefits_earned NUMBER,
  start_date DATE DEFAULT SYSDATE,
  end_date DATE DEFAULT SYSDATE,
  "CATEGORY" VARCHAR2(30 BYTE),
  sub_category VARCHAR2(30 BYTE),
  individual_action_count NUMBER(22),
  transaction_description VARCHAR2(255 BYTE),
  event_class VARCHAR2(30 BYTE),
  max_usage NUMBER(22),
  max_usage_freq_days NUMBER(22),
  point_cooldown_days NUMBER(22),
  point_expiration_days NUMBER(22),
  revenue_direction VARCHAR2(20 BYTE),
  transaction_revenue_direction VARCHAR2(20 BYTE),
  CONSTRAINT ben_earn_objid_pk PRIMARY KEY (objid),
  CONSTRAINT reward_benefit_unique UNIQUE (program_name,benefit_type_code,transaction_type,start_date,end_date)
);
COMMENT ON TABLE sa.x_reward_benefit_earning IS 'Defines benefit earnings for a given benefit type and program name';
COMMENT ON COLUMN sa.x_reward_benefit_earning.objid IS 'Unique record identifier';
COMMENT ON COLUMN sa.x_reward_benefit_earning.program_name IS 'Type of Program : UPGRADE_PLANS / LOYALTY_PROGRAM';
COMMENT ON COLUMN sa.x_reward_benefit_earning.benefit_type_code IS 'Type of Benefit : UPGRADE_BENEFITS / UPGRADE_POINTS / LOYALTY_POINTS';
COMMENT ON COLUMN sa.x_reward_benefit_earning.transaction_type IS 'Type of Transaction : PROGRAM_ENROLLMENT / AUTO_REFILL_ENROLLMENT';
COMMENT ON COLUMN sa.x_reward_benefit_earning.benefits_earned IS 'Number of points (benefits) earned for this transaction type';
COMMENT ON COLUMN sa.x_reward_benefit_earning.start_date IS 'Start date when the rule is effective ';
COMMENT ON COLUMN sa.x_reward_benefit_earning.end_date IS 'End date when the rule is no longer effective';
COMMENT ON COLUMN sa.x_reward_benefit_earning."CATEGORY" IS 'Type of loyalty event. Values: GAME,SURVEY';
COMMENT ON COLUMN sa.x_reward_benefit_earning.sub_category IS 'More detail on type of loyalty event. Values: MEMORY,EDUCATIONAL';
COMMENT ON COLUMN sa.x_reward_benefit_earning.individual_action_count IS 'Number of sub-divisions under this loyalty event';
COMMENT ON COLUMN sa.x_reward_benefit_earning.transaction_description IS 'Description of the offer OR event';
COMMENT ON COLUMN sa.x_reward_benefit_earning.event_class IS 'Class of offer. Values: TANGIBLE, INTANGIBLE';
COMMENT ON COLUMN sa.x_reward_benefit_earning.max_usage IS 'How many times a customer can do this event';
COMMENT ON COLUMN sa.x_reward_benefit_earning.max_usage_freq_days IS 'How often does the max_usage gets reset for a customer';
COMMENT ON COLUMN sa.x_reward_benefit_earning.point_cooldown_days IS 'Number of days required to mature the points';
COMMENT ON COLUMN sa.x_reward_benefit_earning.point_expiration_days IS 'Number of days after which the points expire';
COMMENT ON COLUMN sa.x_reward_benefit_earning.revenue_direction IS 'Signifies if this offer credits or debits any revenue to Tracfone. Values: CREDIT,DEBIT';
COMMENT ON COLUMN sa.x_reward_benefit_earning.transaction_revenue_direction IS 'Direct of transaction, used to signify if the points will be credited or debited. Values: CREDIT,DEBIT';