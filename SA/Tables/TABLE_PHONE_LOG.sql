CREATE TABLE sa.table_phone_log (
  objid NUMBER,
  creation_time DATE,
  stop_time DATE,
  notes LONG,
  site_time DATE,
  internal VARCHAR2(255 BYTE),
  commitment VARCHAR2(80 BYTE),
  due_date DATE,
  action_type VARCHAR2(20 BYTE),
  dev NUMBER,
  case_phone2case NUMBER(*,0),
  subc_phone2subcase NUMBER(*,0),
  phone_custmr2contact NUMBER(*,0),
  phone_owner2user NUMBER(*,0),
  phone_empl2employee NUMBER(*,0),
  old_phone_stat2gbst_elm NUMBER(*,0),
  new_phone_stat2gbst_elm NUMBER(*,0),
  opp_phone2opportunity NUMBER(*,0),
  task_phone2task NUMBER(*,0),
  contr_phone2contract NUMBER(*,0)
);
ALTER TABLE sa.table_phone_log ADD SUPPLEMENTAL LOG GROUP dmtsora1013700782_0 (action_type, case_phone2case, commitment, contr_phone2contract, creation_time, dev, due_date, internal, new_phone_stat2gbst_elm, objid, old_phone_stat2gbst_elm, opp_phone2opportunity, phone_custmr2contact, phone_empl2employee, phone_owner2user, site_time, stop_time, subc_phone2subcase, task_phone2task) ALWAYS;
COMMENT ON TABLE sa.table_phone_log IS 'Object which contains the details of a phone call for a case or subcase';
COMMENT ON COLUMN sa.table_phone_log.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_phone_log.creation_time IS 'Date and time the phone conversation began';
COMMENT ON COLUMN sa.table_phone_log.stop_time IS 'Date and time user hung up the phone';
COMMENT ON COLUMN sa.table_phone_log.notes IS 'Text of phone notes';
COMMENT ON COLUMN sa.table_phone_log.site_time IS 'Local date and time at customer site location';
COMMENT ON COLUMN sa.table_phone_log.internal IS 'For-internal-use-only phone notes';
COMMENT ON COLUMN sa.table_phone_log.commitment IS 'Title of commitment made during the activity';
COMMENT ON COLUMN sa.table_phone_log.due_date IS 'Date and time commitment made on the phone log is due';
COMMENT ON COLUMN sa.table_phone_log.action_type IS 'Action type for the log: This is a user-defined pop up';
COMMENT ON COLUMN sa.table_phone_log.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_phone_log.case_phone2case IS 'Case for the phone log entry';
COMMENT ON COLUMN sa.table_phone_log.subc_phone2subcase IS 'Subcase for the phone log entry';
COMMENT ON COLUMN sa.table_phone_log.phone_custmr2contact IS 'Customer contact for the phone log entry';
COMMENT ON COLUMN sa.table_phone_log.phone_owner2user IS 'User that initiated the phone log entry';
COMMENT ON COLUMN sa.table_phone_log.phone_empl2employee IS 'Employee who initiated the phone log entry';
COMMENT ON COLUMN sa.table_phone_log.old_phone_stat2gbst_elm IS 'Old status prior to changes made for the activity';
COMMENT ON COLUMN sa.table_phone_log.new_phone_stat2gbst_elm IS 'New status based on changes made in the activity';
COMMENT ON COLUMN sa.table_phone_log.opp_phone2opportunity IS 'Opportunity for the phone log entry';
COMMENT ON COLUMN sa.table_phone_log.task_phone2task IS 'Task for the phone log entry';
COMMENT ON COLUMN sa.table_phone_log.contr_phone2contract IS 'Contract for the phone log entry';