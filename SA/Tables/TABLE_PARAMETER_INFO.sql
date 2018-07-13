CREATE TABLE sa.table_parameter_info (
  objid NUMBER,
  parameter_name VARCHAR2(100 BYTE),
  parameter_type NUMBER,
  parameter_label VARCHAR2(100 BYTE),
  dependency VARCHAR2(100 BYTE),
  "REQUIRED" NUMBER,
  default_value VARCHAR2(100 BYTE),
  sql_table VARCHAR2(30 BYTE),
  sql_column VARCHAR2(30 BYTE),
  dev NUMBER,
  parameter_info2report_info NUMBER
);
ALTER TABLE sa.table_parameter_info ADD SUPPLEMENTAL LOG GROUP dmtsora236880072_0 (default_value, dependency, dev, objid, parameter_info2report_info, parameter_label, parameter_name, parameter_type, "REQUIRED", sql_column, sql_table) ALWAYS;