CREATE TABLE sa.table_notes_log (
  objid NUMBER,
  creation_time DATE,
  description LONG,
  internal VARCHAR2(255 BYTE),
  commitment VARCHAR2(80 BYTE),
  due_date DATE,
  action_type VARCHAR2(20 BYTE),
  dev NUMBER,
  case_notes2case NUMBER(*,0),
  subc_notes2subcase NUMBER(*,0),
  notes_owner2user NUMBER(*,0),
  bug_notes2bug NUMBER(*,0),
  old_notes_stat2gbst_elm NUMBER(*,0),
  new_notes_stat2gbst_elm NUMBER(*,0),
  opp_notes2opportunity NUMBER(*,0),
  contr_notes2contract NUMBER(*,0),
  job_notes2job NUMBER(*,0),
  task_notes2task NUMBER(*,0),
  qq_notes2quick_quote NUMBER(*,0)
);
ALTER TABLE sa.table_notes_log ADD SUPPLEMENTAL LOG GROUP dmtsora2075947713_0 (action_type, bug_notes2bug, case_notes2case, commitment, contr_notes2contract, creation_time, dev, due_date, internal, job_notes2job, new_notes_stat2gbst_elm, notes_owner2user, objid, old_notes_stat2gbst_elm, opp_notes2opportunity, qq_notes2quick_quote, subc_notes2subcase, task_notes2task) ALWAYS;
COMMENT ON TABLE sa.table_notes_log IS 'Object which contains notes logged to a queueable object; e.g., case, opportunity, change request, etc';
COMMENT ON COLUMN sa.table_notes_log.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_notes_log.creation_time IS 'Date and time the notes log entry was created';
COMMENT ON COLUMN sa.table_notes_log.description IS 'Text of the note';
COMMENT ON COLUMN sa.table_notes_log.internal IS 'For-internal-use-only text';
COMMENT ON COLUMN sa.table_notes_log.commitment IS 'Title of commitment made during the activity. This is a user-defined popup with default name COMMITMENT';
COMMENT ON COLUMN sa.table_notes_log.due_date IS 'Date and time commitment made on the notes log is due';
COMMENT ON COLUMN sa.table_notes_log.action_type IS 'Action type for the log: This is a user-defined pop up with default name Note Log Action Type';
COMMENT ON COLUMN sa.table_notes_log.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_notes_log.case_notes2case IS 'Related case';
COMMENT ON COLUMN sa.table_notes_log.subc_notes2subcase IS 'Related subcase';
COMMENT ON COLUMN sa.table_notes_log.notes_owner2user IS 'User that created notes log';
COMMENT ON COLUMN sa.table_notes_log.bug_notes2bug IS 'Related change request';
COMMENT ON COLUMN sa.table_notes_log.old_notes_stat2gbst_elm IS 'Old status prior to changes made for the activity';
COMMENT ON COLUMN sa.table_notes_log.new_notes_stat2gbst_elm IS 'New status based on changes made in the activity';
COMMENT ON COLUMN sa.table_notes_log.opp_notes2opportunity IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_notes_log.contr_notes2contract IS 'Related contract';
COMMENT ON COLUMN sa.table_notes_log.job_notes2job IS 'Related job';
COMMENT ON COLUMN sa.table_notes_log.task_notes2task IS 'Related task';
COMMENT ON COLUMN sa.table_notes_log.qq_notes2quick_quote IS 'Related quick quote';