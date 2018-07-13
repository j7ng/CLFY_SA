CREATE TABLE sa.table_condition (
  objid NUMBER,
  "CONDITION" NUMBER,
  wipbin_time DATE,
  queue_time DATE,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  sequence_num NUMBER,
  dispatch_time DATE,
  first_resp_time DATE,
  dev NUMBER,
  condition2phone_log NUMBER(*,0),
  cond_custsts2gbst_elm NUMBER(*,0)
);
ALTER TABLE sa.table_condition ADD SUPPLEMENTAL LOG GROUP dmtsora697304904_0 ("CONDITION", condition2phone_log, cond_custsts2gbst_elm, dev, dispatch_time, first_resp_time, objid, queue_time, sequence_num, s_title, title, wipbin_time) ALWAYS;
COMMENT ON TABLE sa.table_condition IS 'Used to specify the current state of a task';
COMMENT ON COLUMN sa.table_condition.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_condition."CONDITION" IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_condition.wipbin_time IS 'Date and time task was accepted into WIPbin';
COMMENT ON COLUMN sa.table_condition.queue_time IS 'Date and time task was dispatched to queue';
COMMENT ON COLUMN sa.table_condition.title IS 'Title of condition';
COMMENT ON COLUMN sa.table_condition.sequence_num IS 'Tracks sequence number of a subcase';
COMMENT ON COLUMN sa.table_condition.dispatch_time IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_condition.first_resp_time IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_condition.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_condition.condition2phone_log IS 'Phone entry for the condition. Only the initial phone log is related to the condition object';
COMMENT ON COLUMN sa.table_condition.cond_custsts2gbst_elm IS 'Reserved; not used';