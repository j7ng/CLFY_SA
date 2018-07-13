CREATE TABLE sa.table_report_info (
  objid NUMBER,
  report_name VARCHAR2(100 BYTE),
  report_alias VARCHAR2(100 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_report_info ADD SUPPLEMENTAL LOG GROUP dmtsora1624624131_0 (dev, objid, report_alias, report_name) ALWAYS;