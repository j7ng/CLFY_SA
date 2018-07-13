CREATE TABLE sa.adfcrm_sui_attr_mtm (
  attr_mtm_objid NUMBER NOT NULL,
  rule_objid NUMBER,
  attr_objid NUMBER,
  is_updatable VARCHAR2(1 BYTE),
  winner VARCHAR2(20 BYTE),
  display_sequence NUMBER,
  CONSTRAINT adfcrm_sui_attr_mtm_pk PRIMARY KEY (attr_mtm_objid)
);