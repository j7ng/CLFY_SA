CREATE TABLE sa.x_policy_rule_service_plan (
  objid NUMBER(22) NOT NULL,
  policy_rule_config_objid NUMBER(22),
  service_plan_objid NUMBER(22),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  inactive_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  reactivation_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  nt_35_promo_flag VARCHAR2(1 BYTE),
  nt_40_promo_flag VARCHAR2(1 BYTE),
  CONSTRAINT pk_policy_rule_service_plan PRIMARY KEY (objid),
  CONSTRAINT fk_policy_rule_service_plan FOREIGN KEY (policy_rule_config_objid) REFERENCES sa.x_policy_rule_config (objid) DISABLE NOVALIDATE
);
COMMENT ON TABLE sa.x_policy_rule_service_plan IS 'Stores the Policy rule part class details';
COMMENT ON COLUMN sa.x_policy_rule_service_plan.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_policy_rule_service_plan.policy_rule_config_objid IS 'Stores objid of policy_rules_config table';
COMMENT ON COLUMN sa.x_policy_rule_service_plan.service_plan_objid IS 'Stores service plan objid';
COMMENT ON COLUMN sa.x_policy_rule_service_plan.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_policy_rule_service_plan.update_timestamp IS 'Last date when the record was last modified';
COMMENT ON COLUMN sa.x_policy_rule_service_plan.inactive_flag IS 'Stores whether this policy is inactive';