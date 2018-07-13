CREATE TABLE sa.x_reward_benefit_usage (
  objid NUMBER NOT NULL,
  benefit_type_code VARCHAR2(100 BYTE) NOT NULL,
  benefit_usage VARCHAR2(100 BYTE),
  start_date DATE DEFAULT SYSDATE,
  end_date DATE DEFAULT SYSDATE,
  CONSTRAINT ben_use_objid_pk PRIMARY KEY (objid),
  CONSTRAINT ben_use_uq UNIQUE (benefit_type_code,benefit_usage)
);
COMMENT ON TABLE sa.x_reward_benefit_usage IS 'Defines benefit_usage for a given benefit type ';
COMMENT ON COLUMN sa.x_reward_benefit_usage.objid IS 'Unique record identifier';
COMMENT ON COLUMN sa.x_reward_benefit_usage.benefit_type_code IS 'Type of Benefit : UPGRADE_BENEFITS / UPGRADE_POINTS / LOYALTY_POINTS';
COMMENT ON COLUMN sa.x_reward_benefit_usage.benefit_usage IS 'Usage for a particular Benefit Type : PHONE, DEVICE, AIRTIME, ACCESSORY ETC.';
COMMENT ON COLUMN sa.x_reward_benefit_usage.start_date IS 'Start date when the rule is effective ';
COMMENT ON COLUMN sa.x_reward_benefit_usage.end_date IS 'End date when the rule is no longer effective';