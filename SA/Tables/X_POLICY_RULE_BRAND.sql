CREATE TABLE sa.x_policy_rule_brand (
  objid NUMBER(22) NOT NULL,
  policy_rule_config_objid NUMBER(22),
  bus_org_objid NUMBER(22),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  inactive_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  CONSTRAINT pk_policy_rule_brand PRIMARY KEY (objid),
  CONSTRAINT fk_policy_rule_brand FOREIGN KEY (policy_rule_config_objid) REFERENCES sa.x_policy_rule_config (objid)
);
COMMENT ON TABLE sa.x_policy_rule_brand IS 'Stores the Policy rule part class details';
COMMENT ON COLUMN sa.x_policy_rule_brand.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_policy_rule_brand.policy_rule_config_objid IS 'Stores objid of policy_rules_config table';
COMMENT ON COLUMN sa.x_policy_rule_brand.bus_org_objid IS 'Stores bus org objid';
COMMENT ON COLUMN sa.x_policy_rule_brand.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_policy_rule_brand.update_timestamp IS 'Last date when the record was last modified';
COMMENT ON COLUMN sa.x_policy_rule_brand.inactive_flag IS 'Stores whether this policy is inactive';