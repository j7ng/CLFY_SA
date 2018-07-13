CREATE TABLE sa.x_policy_rule_part_class (
  objid NUMBER(22) NOT NULL,
  part_class_objid NUMBER(22),
  policy_rule_config_objid NUMBER(22),
  insert_timestamp DATE DEFAULT sysdate,
  update_timestamp DATE DEFAULT sysdate,
  inactive_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  CONSTRAINT pk_policy_rule_part_class PRIMARY KEY (objid),
  CONSTRAINT fk_policy_rule_class FOREIGN KEY (policy_rule_config_objid) REFERENCES sa.x_policy_rule_config (objid) DISABLE NOVALIDATE
);
COMMENT ON TABLE sa.x_policy_rule_part_class IS 'Stores the Policy rule part class details';
COMMENT ON COLUMN sa.x_policy_rule_part_class.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_policy_rule_part_class.part_class_objid IS 'Stores part class table objid  ';
COMMENT ON COLUMN sa.x_policy_rule_part_class.policy_rule_config_objid IS 'Stores objid of policy_rules_config table';
COMMENT ON COLUMN sa.x_policy_rule_part_class.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_policy_rule_part_class.update_timestamp IS 'Last date when the record was last modified';
COMMENT ON COLUMN sa.x_policy_rule_part_class.inactive_flag IS 'Stores whether this policy is inactive';