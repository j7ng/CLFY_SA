CREATE TABLE sa.adfcrm_sui_rules_engine (
  rule_objid NUMBER NOT NULL,
  rule_name VARCHAR2(200 BYTE),
  "ACTIVE" VARCHAR2(20 BYTE),
  created_by VARCHAR2(50 BYTE),
  modified_by VARCHAR2(50 BYTE),
  created_on TIMESTAMP,
  modified_on TIMESTAMP,
  CONSTRAINT adfcrm_sui_rules_engine_pk PRIMARY KEY (rule_objid)
);