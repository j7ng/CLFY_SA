CREATE TABLE sa.x_policy_mapping_config (
  objid NUMBER(22) NOT NULL,
  parent_name VARCHAR2(30 BYTE) NOT NULL,
  "COS" VARCHAR2(30 BYTE) NOT NULL,
  threshold NUMBER(12,2) NOT NULL,
  syniverse_policy VARCHAR2(1 BYTE),
  usage_tier_id NUMBER(2) NOT NULL,
  entitlement VARCHAR2(30 BYTE) NOT NULL,
  policy_objid NUMBER(22),
  inactive_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  insert_timestamp DATE DEFAULT sysdate,
  update_timestamp DATE DEFAULT sysdate,
  throttle_transact_type VARCHAR2(30 BYTE),
  throttle_transact_status VARCHAR2(20 BYTE),
  start_date DATE DEFAULT sysdate,
  end_date DATE DEFAULT (to_date('31-12-2055', 'dd-mm-yyyy')),
  update_cos VARCHAR2(20 BYTE),
  rcs_flag VARCHAR2(1 BYTE),
  tmo_threshold_flag VARCHAR2(1 BYTE) DEFAULT 'N' NOT NULL,
  metering_source VARCHAR2(10 BYTE),
  offering_name VARCHAR2(100 BYTE),
  CONSTRAINT pk_policy_mapping_config PRIMARY KEY (objid),
  CONSTRAINT uk_x_policy_mapping_config UNIQUE (parent_name,"COS",threshold,usage_tier_id,entitlement),
  CONSTRAINT fk_policy_mapping_config FOREIGN KEY (usage_tier_id) REFERENCES sa.x_usage_tier (usage_tier_id)
);
COMMENT ON TABLE sa.x_policy_mapping_config IS 'Stores the Policy mapping configuration';
COMMENT ON COLUMN sa.x_policy_mapping_config.objid IS 'Stores the unique identifier for each record';
COMMENT ON COLUMN sa.x_policy_mapping_config.parent_name IS 'carrier Parent name is stored';
COMMENT ON COLUMN sa.x_policy_mapping_config."COS" IS 'Class of service.';
COMMENT ON COLUMN sa.x_policy_mapping_config.threshold IS 'Threshold of the data on subscriber service';
COMMENT ON COLUMN sa.x_policy_mapping_config.syniverse_policy IS 'Stores Synverse policy';
COMMENT ON COLUMN sa.x_policy_mapping_config.usage_tier_id IS 'This stores tier id mapped to table x_usage_tier ';
COMMENT ON COLUMN sa.x_policy_mapping_config.entitlement IS 'Stores ENTITLEMENT';
COMMENT ON COLUMN sa.x_policy_mapping_config.policy_objid IS 'Stores objid of table policy table objid';
COMMENT ON COLUMN sa.x_policy_mapping_config.inactive_flag IS 'Stores whether this policy is inactive';
COMMENT ON COLUMN sa.x_policy_mapping_config.insert_timestamp IS 'Time and date when the row was entered.';
COMMENT ON COLUMN sa.x_policy_mapping_config.update_timestamp IS 'Last date when the record was last modified';
COMMENT ON COLUMN sa.x_policy_mapping_config.tmo_threshold_flag IS 'Sending threshold buckets to TMO based on offer id';
COMMENT ON COLUMN sa.x_policy_mapping_config.metering_source IS 'Identifies the appropriate metering source for each COS value';
COMMENT ON COLUMN sa.x_policy_mapping_config.offering_name IS 'Service plan description';