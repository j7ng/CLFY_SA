CREATE TABLE sa.adfcrm_comp_threshold (
  privclass_objid NUMBER NOT NULL,
  comp_level VARCHAR2(30 BYTE) NOT NULL,
  comp_type VARCHAR2(30 BYTE) NOT NULL,
  comp_units VARCHAR2(10 BYTE) NOT NULL,
  comp_value NUMBER NOT NULL
);