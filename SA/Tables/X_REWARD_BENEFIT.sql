CREATE TABLE sa.x_reward_benefit (
  objid NUMBER NOT NULL,
  web_account_id VARCHAR2(100 BYTE),
  subscriber_id VARCHAR2(100 BYTE),
  "MIN" VARCHAR2(100 BYTE),
  esn VARCHAR2(100 BYTE),
  benefit_owner VARCHAR2(100 BYTE),
  created_date DATE,
  status VARCHAR2(50 BYTE),
  notes VARCHAR2(1000 BYTE),
  benefit_type_code VARCHAR2(100 BYTE),
  update_date DATE,
  expiry_date DATE,
  brand VARCHAR2(100 BYTE),
  quantity NUMBER,
  "VALUE" NUMBER,
  program_name VARCHAR2(100 BYTE),
  account_status VARCHAR2(30 BYTE),
  pending_quantity NUMBER(22),
  expired_quantity NUMBER(22),
  total_quantity NUMBER(22),
  loyalty_tier NUMBER DEFAULT 1,
  CONSTRAINT benifit_objid_pk PRIMARY KEY (objid),
  CONSTRAINT x_reward_benefit_unique UNIQUE (web_account_id,brand)
);
COMMENT ON TABLE sa.x_reward_benefit IS 'Table will contain an entry for every reward/benefit related a??eventa?? performed in the system.';
COMMENT ON COLUMN sa.x_reward_benefit.objid IS 'Unique record identifier';
COMMENT ON COLUMN sa.x_reward_benefit.web_account_id IS 'ACCOUNT ID of the customer';
COMMENT ON COLUMN sa.x_reward_benefit.subscriber_id IS 'SUBSCRIBER ID of the customer';
COMMENT ON COLUMN sa.x_reward_benefit."MIN" IS 'MIN of the customer';
COMMENT ON COLUMN sa.x_reward_benefit.esn IS 'ESN of the customer';
COMMENT ON COLUMN sa.x_reward_benefit.benefit_owner IS 'Who owns the benefit { ESN | MIN | SID | ACCOUNT }';
COMMENT ON COLUMN sa.x_reward_benefit.created_date IS 'Date when this record is created (ie benefit is created )';
COMMENT ON COLUMN sa.x_reward_benefit.status IS 'The status of benefits (eg AVAILABLE | USED | EXPIRED etc)';
COMMENT ON COLUMN sa.x_reward_benefit.notes IS 'Descriptive info about the benefits';
COMMENT ON COLUMN sa.x_reward_benefit.benefit_type_code IS 'Type of Benefit : UPGRADE_BENEFITS / UPGRADE_POINTS / LOYALTY_POINTS';
COMMENT ON COLUMN sa.x_reward_benefit.update_date IS 'Date when the record is last updated';
COMMENT ON COLUMN sa.x_reward_benefit.expiry_date IS 'Date when the benefits will expire and cannot be used; this date will be populated as deactivation date + X days';
COMMENT ON COLUMN sa.x_reward_benefit.brand IS 'NET10(NT) / SIMPLEMOBILE(SM) / STRAIGHTTALK(ST) / TRACFONE(TF) / TELCEL(TC) / TOTALWIRELESS(TW) / SAFELINK (SL)';
COMMENT ON COLUMN sa.x_reward_benefit.quantity IS 'Total number of benefits';
COMMENT ON COLUMN sa.x_reward_benefit."VALUE" IS 'Total ($) value of benefit';
COMMENT ON COLUMN sa.x_reward_benefit.program_name IS 'UPGRADE_PLANS/UPGRADE_PROGRAM/LOYALTY_PROGRAM';
COMMENT ON COLUMN sa.x_reward_benefit.account_status IS 'Account Status one of ENROLLED,DEENROLLED,SUSPENDED,RISK ASSESSMENT and EXPIRED';
COMMENT ON COLUMN sa.x_reward_benefit.pending_quantity IS 'Sum of points which are in pending status';
COMMENT ON COLUMN sa.x_reward_benefit.expired_quantity IS 'Number of points being expired';
COMMENT ON COLUMN sa.x_reward_benefit.total_quantity IS 'Total number of points (pending_quantity+quantity)';
COMMENT ON COLUMN sa.x_reward_benefit.loyalty_tier IS 'To store the customer loyalty tier based on their loyalty i.e. 1,2,3 etc  . Default 1';