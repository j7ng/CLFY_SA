CREATE TABLE sa.x_policy_rule_config (
  objid NUMBER(22) NOT NULL,
  rule_name VARCHAR2(100 BYTE),
  activation_date_from DATE,
  activation_date_to DATE,
  start_date DATE,
  end_date DATE,
  inactive_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  "PRIORITY" NUMBER DEFAULT 1,
  active_days_from NUMBER(10),
  active_days_to NUMBER(10),
  part_class_applicable_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  parent_applicable_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  service_plan_applicable_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  brand_applicable_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  dealer_applicable_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  install_date_applicable_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  auto_refill_applicable_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  active_days_applicable_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  "COS" VARCHAR2(50 BYTE) NOT NULL,
  insert_timestamp DATE DEFAULT sysdate,
  update_timestamp DATE DEFAULT sysdate,
  activation_carrier_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  part_number_applicable_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  activate_date_applicable_flag VARCHAR2(2 BYTE) DEFAULT 'N',
  latest_activation_date_flag VARCHAR2(2 BYTE) DEFAULT 'N',
  activation_service_plan_flag VARCHAR2(2 BYTE) DEFAULT 'N',
  install_date_by_min VARCHAR2(2 BYTE) DEFAULT 'N',
  CONSTRAINT pk_policy_rules_config PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_policy_rule_config IS 'Stores the Policy mapping configuration';
COMMENT ON COLUMN sa.x_policy_rule_config.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_policy_rule_config.rule_name IS 'rule name is stored';
COMMENT ON COLUMN sa.x_policy_rule_config.activation_date_from IS 'From when this rule will be active';
COMMENT ON COLUMN sa.x_policy_rule_config.activation_date_to IS 'date till when rule will be active';
COMMENT ON COLUMN sa.x_policy_rule_config.start_date IS 'start date of the rule';
COMMENT ON COLUMN sa.x_policy_rule_config.end_date IS 'end date if the rule';
COMMENT ON COLUMN sa.x_policy_rule_config.inactive_flag IS 'Stores whether this policy is inactive';
COMMENT ON COLUMN sa.x_policy_rule_config."PRIORITY" IS 'Stores Priority of the rule';
COMMENT ON COLUMN sa.x_policy_rule_config.active_days_from IS 'customer active from date';
COMMENT ON COLUMN sa.x_policy_rule_config.active_days_to IS 'customer active to date';
COMMENT ON COLUMN sa.x_policy_rule_config.part_class_applicable_flag IS 'Stores whether rule is applicable to part class';
COMMENT ON COLUMN sa.x_policy_rule_config.parent_applicable_flag IS 'Stores whether rule is applicable to parent ';
COMMENT ON COLUMN sa.x_policy_rule_config.service_plan_applicable_flag IS 'Stores whether rule is applicable to service plan';
COMMENT ON COLUMN sa.x_policy_rule_config.brand_applicable_flag IS 'Stores whether rule is applicable to Brand name';
COMMENT ON COLUMN sa.x_policy_rule_config.dealer_applicable_flag IS 'Stores whether rule is applicable to dealer';
COMMENT ON COLUMN sa.x_policy_rule_config.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_policy_rule_config.update_timestamp IS 'Last date when the record was last modified';
COMMENT ON COLUMN sa.x_policy_rule_config.activation_carrier_flag IS 'ENABLE RULE ENGINE BASED ON CARRIER AT THE TIME OF ACTIVATION';
COMMENT ON COLUMN sa.x_policy_rule_config.part_number_applicable_flag IS 'ENABLE RULE ENGINE BASED ON PHONE PART NUMBER';