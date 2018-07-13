CREATE TABLE sa.x_policy_rule_parent (
  objid NUMBER(22) NOT NULL,
  policy_rule_config_objid NUMBER(22),
  parent_name VARCHAR2(30 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  inactive_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  CONSTRAINT pk_policy_rule_parent PRIMARY KEY (objid),
  CONSTRAINT fk_policy_rule_parent FOREIGN KEY (policy_rule_config_objid) REFERENCES sa.x_policy_rule_config (objid) DISABLE NOVALIDATE
);
COMMENT ON TABLE sa.x_policy_rule_parent IS 'Stores the Policy rule part class details';
COMMENT ON COLUMN sa.x_policy_rule_parent.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_policy_rule_parent.policy_rule_config_objid IS 'Stores objid of policy_rules_config table';
COMMENT ON COLUMN sa.x_policy_rule_parent.parent_name IS 'Stores parent name';
COMMENT ON COLUMN sa.x_policy_rule_parent.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_policy_rule_parent.update_timestamp IS 'Last date when the record was last modified';
COMMENT ON COLUMN sa.x_policy_rule_parent.inactive_flag IS 'Stores whether this policy is inactive';