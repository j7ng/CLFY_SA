CREATE TABLE sa.table_rqst_fld_role (
  objid NUMBER,
  dev NUMBER,
  "TYPE" NUMBER,
  type_alpha VARCHAR2(20 BYTE),
  optional VARCHAR2(20 BYTE),
  rqst_fld_role2fld_def NUMBER,
  rqst_fld_role2rqst_def NUMBER
);
ALTER TABLE sa.table_rqst_fld_role ADD SUPPLEMENTAL LOG GROUP dmtsora498470266_0 (dev, objid, optional, rqst_fld_role2fld_def, rqst_fld_role2rqst_def, "TYPE", type_alpha) ALWAYS;