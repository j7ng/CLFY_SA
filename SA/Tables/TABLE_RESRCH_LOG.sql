CREATE TABLE sa.table_resrch_log (
  objid NUMBER,
  creation_time DATE,
  elapsed_time NUMBER,
  notes LONG,
  internal VARCHAR2(255 BYTE),
  commitment VARCHAR2(80 BYTE),
  due_date DATE,
  action_type VARCHAR2(20 BYTE),
  dev NUMBER,
  case_resrch2case NUMBER(*,0),
  subc_resrch2subcase NUMBER(*,0),
  resrch_owner2user NUMBER(*,0),
  old_resrch_stat2gbst_elm NUMBER(*,0),
  new_resrch_stat2gbst_elm NUMBER(*,0)
);
ALTER TABLE sa.table_resrch_log ADD SUPPLEMENTAL LOG GROUP dmtsora1798069819_0 (action_type, case_resrch2case, commitment, creation_time, dev, due_date, elapsed_time, internal, new_resrch_stat2gbst_elm, objid, old_resrch_stat2gbst_elm, resrch_owner2user, subc_resrch2subcase) ALWAYS;
COMMENT ON TABLE sa.table_resrch_log IS 'Object which contains the details of research done for a case or subcase';
COMMENT ON COLUMN sa.table_resrch_log.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_resrch_log.creation_time IS 'Date and time the research log was created';
COMMENT ON COLUMN sa.table_resrch_log.elapsed_time IS 'Total elapsed time spent doing research in seconds';
COMMENT ON COLUMN sa.table_resrch_log.notes IS 'Research notes text';
COMMENT ON COLUMN sa.table_resrch_log.internal IS 'For-internal-use-only research notes text';
COMMENT ON COLUMN sa.table_resrch_log.commitment IS 'Title of commitment made during the activity';
COMMENT ON COLUMN sa.table_resrch_log.due_date IS 'Date and time commitment made on the research log is due';
COMMENT ON COLUMN sa.table_resrch_log.action_type IS 'Action type for the log: This is a user-defined pop up';
COMMENT ON COLUMN sa.table_resrch_log.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_resrch_log.case_resrch2case IS 'Case for the research log';
COMMENT ON COLUMN sa.table_resrch_log.subc_resrch2subcase IS 'Subcase for the research log';
COMMENT ON COLUMN sa.table_resrch_log.resrch_owner2user IS 'User that logged the research time';
COMMENT ON COLUMN sa.table_resrch_log.old_resrch_stat2gbst_elm IS 'Case status prior to changes made for the activity';
COMMENT ON COLUMN sa.table_resrch_log.new_resrch_stat2gbst_elm IS 'New case status based on changes made in the activity';