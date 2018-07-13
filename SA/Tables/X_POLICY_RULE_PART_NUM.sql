CREATE TABLE sa.x_policy_rule_part_num (
  objid NUMBER(22) NOT NULL,
  esn_part_number VARCHAR2(40 BYTE),
  red_card_part_number VARCHAR2(40 BYTE),
  policy_rule_config_objid NUMBER(22),
  insert_timestamp DATE,
  update_timestamp DATE,
  inactive_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL
);
COMMENT ON TABLE sa.x_policy_rule_part_num IS 'TO ENABLE RULE ENGINE BY PART NUMBER LEVEL OF PHONE OR REDEMPTION CARD';
COMMENT ON COLUMN sa.x_policy_rule_part_num.esn_part_number IS 'PHONE PART NUMBER INFO';
COMMENT ON COLUMN sa.x_policy_rule_part_num.red_card_part_number IS 'REDEMPTION CARD PART NUMBER INFO';
COMMENT ON COLUMN sa.x_policy_rule_part_num.policy_rule_config_objid IS 'X_POLICY_RULE_CONFIG OBJID';
COMMENT ON COLUMN sa.x_policy_rule_part_num.insert_timestamp IS 'INSERT_TIMESTAMP';
COMMENT ON COLUMN sa.x_policy_rule_part_num.update_timestamp IS 'UPDATE_TIMESTAMP';
COMMENT ON COLUMN sa.x_policy_rule_part_num.inactive_flag IS 'TO ENABLE OR DISABLE THE PART NUMBER';