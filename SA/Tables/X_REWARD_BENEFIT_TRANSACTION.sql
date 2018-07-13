CREATE TABLE sa.x_reward_benefit_transaction (
  objid NUMBER NOT NULL,
  trans_date DATE,
  web_account_id VARCHAR2(100 BYTE),
  subscriber_id VARCHAR2(100 BYTE),
  "MIN" VARCHAR2(100 BYTE),
  esn VARCHAR2(100 BYTE),
  old_min VARCHAR2(100 BYTE),
  old_esn VARCHAR2(100 BYTE),
  trans_type VARCHAR2(100 BYTE),
  trans_desc VARCHAR2(100 BYTE),
  amount NUMBER(12,2),
  benefit_type_code VARCHAR2(100 BYTE),
  "ACTION" VARCHAR2(100 BYTE),
  action_type VARCHAR2(100 BYTE),
  action_reason VARCHAR2(100 BYTE),
  action_notes VARCHAR2(300 BYTE),
  benefit_trans2benefit_trans NUMBER,
  svc_plan_pin VARCHAR2(100 BYTE),
  svc_plan_id VARCHAR2(100 BYTE),
  brand VARCHAR2(100 BYTE),
  benefit_trans2benefit NUMBER,
  agent_login_name VARCHAR2(100 BYTE),
  transaction_status VARCHAR2(30 BYTE),
  maturity_date DATE,
  expiration_date DATE,
  "SOURCE" VARCHAR2(30 BYTE),
  source_trans_id VARCHAR2(30 BYTE),
  CONSTRAINT ben_trans_objid_pk PRIMARY KEY (objid),
  CONSTRAINT ben_trans_uk UNIQUE (web_account_id,"MIN",esn,trans_date,trans_type,amount,"ACTION",action_reason,svc_plan_pin,svc_plan_id)
);
COMMENT ON TABLE sa.x_reward_benefit_transaction IS 'Table will contain an entry for every reward/benefit related a??eventa?? performed in the system.';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.objid IS 'Unique record identifier';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.trans_date IS ' Transaction Date';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.web_account_id IS 'ACCOUNT ID of the customer';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.subscriber_id IS 'SUBSCRIBER ID of the customer';
COMMENT ON COLUMN sa.x_reward_benefit_transaction."MIN" IS 'MIN of the customer';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.esn IS 'ESN of the customer';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.old_min IS 'OLD_MIN of the customer';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.old_esn IS 'OLD_ESN of the customer';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.trans_type IS 'TRANSACTION TYPE';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.trans_desc IS 'TRANSACTION DESC';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.amount IS 'number of points added or deducted';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.benefit_type_code IS 'Type of Benefit : UPGRADE_BENEFITS / UPGRADE_POINTS / LOYALTY_POINTS';
COMMENT ON COLUMN sa.x_reward_benefit_transaction."ACTION" IS 'Action Code Used for TAS Displays';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.action_type IS 'Action Type used for Reporting ';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.action_reason IS 'Description of Action Taken ';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.action_notes IS 'Action notes';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.benefit_trans2benefit_trans IS 'Links this record with another point trans(if applicable) ';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.svc_plan_pin IS 'PIN associated with this transaction (if applicable) ';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.svc_plan_id IS 'Service plan associated with this transaction (if applicable) String ID not OBJID.';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.brand IS 'NET10 / SIMPLEMOBILE / STRAIGHTTALK / TRACFONE / TELCEL / TOTALWIRELESS';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.benefit_trans2benefit IS 'OBJID of the benefit that this transaction is associated with.';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.agent_login_name IS 'agent login name';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.transaction_status IS 'Status for the points transaction. Values: PENDING,COMPLETE,FAILED';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.maturity_date IS 'Time when the loyalty points mature';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.expiration_date IS 'Time when the points will get expired';
COMMENT ON COLUMN sa.x_reward_benefit_transaction."SOURCE" IS 'Source from where the transaction was initiated. Values: BATCH,WEB,EXT_EVENT';
COMMENT ON COLUMN sa.x_reward_benefit_transaction.source_trans_id IS 'Transaction id generated from the source';