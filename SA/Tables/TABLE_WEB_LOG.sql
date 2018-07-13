CREATE TABLE sa.table_web_log (
  objid NUMBER,
  code NUMBER,
  entry_time DATE,
  addnl_info VARCHAR2(255 BYTE),
  dev NUMBER,
  web_log2web_user NUMBER(*,0)
);
ALTER TABLE sa.table_web_log ADD SUPPLEMENTAL LOG GROUP dmtsora695174424_0 (addnl_info, code, dev, entry_time, objid, web_log2web_user) ALWAYS;