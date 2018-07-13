CREATE TABLE sa.bk_x_policy_mapping_config (
  objid NUMBER(22),
  parent_name VARCHAR2(30 BYTE) NOT NULL,
  "COS" VARCHAR2(30 BYTE) NOT NULL,
  threshold NUMBER(12,2) NOT NULL,
  syniverse_policy VARCHAR2(1 BYTE),
  usage_tier_id NUMBER(2) NOT NULL,
  entitlement VARCHAR2(30 BYTE) NOT NULL,
  policy_objid NUMBER(22),
  inactive_flag VARCHAR2(1 BYTE) NOT NULL,
  insert_timestamp DATE,
  update_timestamp DATE,
  throttle_transact_type VARCHAR2(30 BYTE),
  throttle_transact_status VARCHAR2(20 BYTE)
);