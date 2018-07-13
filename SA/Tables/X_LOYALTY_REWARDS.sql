CREATE TABLE sa.x_loyalty_rewards (
  objid NUMBER NOT NULL,
  esn VARCHAR2(100 BYTE),
  "MIN" VARCHAR2(100 BYTE),
  campaign_cd VARCHAR2(100 BYTE),
  cust_id VARCHAR2(80 BYTE),
  load_date DATE,
  CONSTRAINT llt_rew_objid_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_loyalty_rewards IS 'Table contains the information provided by Campaign Management Team about customer enrollment';
COMMENT ON COLUMN sa.x_loyalty_rewards.objid IS 'Unique row identifier';
COMMENT ON COLUMN sa.x_loyalty_rewards.esn IS 'ESN of the customer';
COMMENT ON COLUMN sa.x_loyalty_rewards."MIN" IS 'MIN of the customer';
COMMENT ON COLUMN sa.x_loyalty_rewards.campaign_cd IS 'Campaign code for the enrollment of customer';
COMMENT ON COLUMN sa.x_loyalty_rewards.cust_id IS 'Unique customer number (populated from site_id for customers)';
COMMENT ON COLUMN sa.x_loyalty_rewards.load_date IS 'Date of enrollment';