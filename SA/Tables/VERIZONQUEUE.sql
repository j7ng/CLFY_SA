CREATE TABLE sa.verizonqueue (
  esn VARCHAR2(30 BYTE),
  line VARCHAR2(30 BYTE),
  line_status VARCHAR2(20 BYTE),
  task_id VARCHAR2(25 BYTE),
  call_trans_objid NUMBER,
  processed NUMBER,
  stamp_date DATE
);
ALTER TABLE sa.verizonqueue ADD SUPPLEMENTAL LOG GROUP dmtsora285140189_0 (call_trans_objid, esn, line, line_status, processed, stamp_date, task_id) ALWAYS;