CREATE TABLE sa.x_policy_rule_activation_sp (
  objid NUMBER(22) NOT NULL,
  policy_rule_config_objid NUMBER(22),
  service_plan_objid NUMBER(22),
  insert_timestamp DATE DEFAULT sysdate,
  update_timestamp DATE DEFAULT sysdate,
  inactive_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  CONSTRAINT pk_x_policy_rule_activation_sp PRIMARY KEY (objid),
  CONSTRAINT fk_x_policy_rule_activation_sp FOREIGN KEY (policy_rule_config_objid) REFERENCES sa.x_policy_rule_config (objid)
);