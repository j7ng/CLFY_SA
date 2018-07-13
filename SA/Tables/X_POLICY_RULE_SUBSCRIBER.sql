CREATE TABLE sa.x_policy_rule_subscriber (
  objid NUMBER(22) NOT NULL,
  "MIN" VARCHAR2(30 BYTE) NOT NULL,
  esn VARCHAR2(30 BYTE) NOT NULL,
  "COS" VARCHAR2(50 BYTE),
  start_date DATE NOT NULL,
  end_date DATE,
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  inactive_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  CONSTRAINT pk_policy_rule_subscriber PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_policy_rule_subscriber IS 'Stores the st winback subscriber list';
COMMENT ON COLUMN sa.x_policy_rule_subscriber.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_policy_rule_subscriber."MIN" IS 'Stores min number';
COMMENT ON COLUMN sa.x_policy_rule_subscriber.esn IS 'Stores ESN';
COMMENT ON COLUMN sa.x_policy_rule_subscriber."COS" IS 'Stores the cos value the subscriber will use';
COMMENT ON COLUMN sa.x_policy_rule_subscriber.start_date IS 'Stores the effective date';
COMMENT ON COLUMN sa.x_policy_rule_subscriber.end_date IS 'Stores the date when the rule ends';
COMMENT ON COLUMN sa.x_policy_rule_subscriber.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_policy_rule_subscriber.update_timestamp IS 'Last date when the record was last modified';
COMMENT ON COLUMN sa.x_policy_rule_subscriber.inactive_flag IS 'Stores whether this policy is inactive';