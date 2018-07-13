CREATE TABLE sa.table_rpn (
  objid NUMBER,
  creation_time DATE,
  received_time DATE,
  error_num NUMBER,
  site_num VARCHAR2(6 BYTE),
  error_msg VARCHAR2(38 BYTE),
  severity VARCHAR2(20 BYTE),
  label_1 VARCHAR2(20 BYTE),
  label_2 VARCHAR2(20 BYTE),
  label_3 VARCHAR2(20 BYTE),
  label_4 VARCHAR2(20 BYTE),
  rpn_queue NUMBER,
  "PRIORITY" VARCHAR2(20 BYTE),
  site_name VARCHAR2(80 BYTE),
  extra_info VARCHAR2(255 BYTE),
  err_count NUMBER,
  dev NUMBER,
  rpn2case_info NUMBER(*,0)
);
ALTER TABLE sa.table_rpn ADD SUPPLEMENTAL LOG GROUP dmtsora158027005_0 (creation_time, dev, error_msg, error_num, err_count, extra_info, label_1, label_2, label_3, label_4, objid, "PRIORITY", received_time, rpn2case_info, rpn_queue, severity, site_name, site_num) ALWAYS;