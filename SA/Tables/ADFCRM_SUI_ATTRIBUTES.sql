CREATE TABLE sa.adfcrm_sui_attributes (
  attr_objid NUMBER NOT NULL,
  attr_name VARCHAR2(50 BYTE),
  display_label VARCHAR2(50 BYTE),
  parent_attr_id NUMBER,
  clarify_sql VARCHAR2(2000 BYTE),
  carrier_value VARCHAR2(2000 BYTE),
  CONSTRAINT adfcrm_sui_attributes_pk PRIMARY KEY (attr_objid)
);