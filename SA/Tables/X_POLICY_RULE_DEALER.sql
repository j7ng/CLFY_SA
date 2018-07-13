CREATE TABLE sa.x_policy_rule_dealer (
  objid NUMBER(22) NOT NULL,
  policy_rule_config_objid NUMBER(22),
  site_id VARCHAR2(80 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  inactive_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  card_dealer_applicable_flag VARCHAR2(1 BYTE),
  CONSTRAINT pk_policy_rule_dealer PRIMARY KEY (objid),
  CONSTRAINT fk_policy_rule_dealer FOREIGN KEY (policy_rule_config_objid) REFERENCES sa.x_policy_rule_config (objid) DISABLE NOVALIDATE
);
COMMENT ON TABLE sa.x_policy_rule_dealer IS 'Stores the Policy rule part class details';
COMMENT ON COLUMN sa.x_policy_rule_dealer.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_policy_rule_dealer.policy_rule_config_objid IS 'Stores objid of policy_rules_config table';
COMMENT ON COLUMN sa.x_policy_rule_dealer.site_id IS 'Stores site_id table';
COMMENT ON COLUMN sa.x_policy_rule_dealer.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_policy_rule_dealer.update_timestamp IS 'Last date when the record was last modified';
COMMENT ON COLUMN sa.x_policy_rule_dealer.inactive_flag IS 'Stores whether this policy is inactive';