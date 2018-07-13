CREATE TABLE sa.scripts_export_log (
  objid NUMBER NOT NULL,
  script_rev_id VARCHAR2(30 BYTE),
  "LABEL" VARCHAR2(30 BYTE),
  export_summary VARCHAR2(200 BYTE),
  sourcedb VARCHAR2(20 BYTE),
  insert_date DATE,
  CONSTRAINT pk_objid PRIMARY KEY (objid)
);