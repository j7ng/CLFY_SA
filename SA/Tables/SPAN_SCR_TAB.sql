CREATE TABLE sa.span_scr_tab (
  eng_objid NUMBER(38),
  span_text LONG,
  dup_status VARCHAR2(50 BYTE),
  span_objid NUMBER(38),
  script_type VARCHAR2(20 BYTE),
  "SOURCE" VARCHAR2(20 BYTE),
  scr_status VARCHAR2(50 BYTE),
  mtm_status VARCHAR2(50 BYTE)
);
ALTER TABLE sa.span_scr_tab ADD SUPPLEMENTAL LOG GROUP dmtsora645944939_0 (dup_status, eng_objid, mtm_status, script_type, scr_status, "SOURCE", span_objid) ALWAYS;