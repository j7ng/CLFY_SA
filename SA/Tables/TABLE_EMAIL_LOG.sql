CREATE TABLE sa.table_email_log (
  objid NUMBER,
  creation_time DATE,
  sender VARCHAR2(255 BYTE),
  recipient VARCHAR2(255 BYTE),
  cc_list VARCHAR2(255 BYTE),
  message LONG,
  commitment VARCHAR2(80 BYTE),
  due_date DATE,
  stop_time DATE,
  action_type VARCHAR2(20 BYTE),
  dev NUMBER,
  case_email2case NUMBER(*,0),
  subc_email2subcase NUMBER(*,0),
  bug_email2bug NUMBER(*,0),
  old_email_stat2gbst_elm NUMBER(*,0),
  new_email_stat2gbst_elm NUMBER(*,0),
  contr_email2contract NUMBER(*,0),
  opp_email2opportunity NUMBER(*,0),
  cont_email2contact NUMBER(*,0),
  task_email2task NUMBER(*,0)
);
ALTER TABLE sa.table_email_log ADD SUPPLEMENTAL LOG GROUP dmtsora1810382906_0 (action_type, bug_email2bug, case_email2case, cc_list, commitment, contr_email2contract, cont_email2contact, creation_time, dev, due_date, new_email_stat2gbst_elm, objid, old_email_stat2gbst_elm, opp_email2opportunity, recipient, sender, stop_time, subc_email2subcase, task_email2task) ALWAYS;
COMMENT ON TABLE sa.table_email_log IS 'Email object for recording emails sent for a queueable object; e.g., bug, case, or subcase';
COMMENT ON COLUMN sa.table_email_log.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_email_log.creation_time IS 'The date and time the email_log was created';
COMMENT ON COLUMN sa.table_email_log.sender IS 'User name of originator of email message';
COMMENT ON COLUMN sa.table_email_log.recipient IS 'Email addresse(s) for recipient(s) of email';
COMMENT ON COLUMN sa.table_email_log.cc_list IS 'Email addresses for those copied on the email message';
COMMENT ON COLUMN sa.table_email_log.message IS 'Email message text';
COMMENT ON COLUMN sa.table_email_log.commitment IS 'Title of commitment made during the activity. This is a user-defined popup with default name COMMITMENT';
COMMENT ON COLUMN sa.table_email_log.due_date IS 'Date and time commitment made in the email log is due';
COMMENT ON COLUMN sa.table_email_log.stop_time IS 'Date and time email log activity was completed';
COMMENT ON COLUMN sa.table_email_log.action_type IS 'Action type for the log: This is a user-defined pop up with default name Mail Log Action Type';
COMMENT ON COLUMN sa.table_email_log.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_email_log.case_email2case IS 'Case for the email log entry';
COMMENT ON COLUMN sa.table_email_log.subc_email2subcase IS 'Subcase for the email log entry';
COMMENT ON COLUMN sa.table_email_log.bug_email2bug IS 'Related change request';
COMMENT ON COLUMN sa.table_email_log.old_email_stat2gbst_elm IS 'Case status before the email log entry';
COMMENT ON COLUMN sa.table_email_log.new_email_stat2gbst_elm IS 'Case status after the email log entry';
COMMENT ON COLUMN sa.table_email_log.contr_email2contract IS 'Contract for the email log entry';
COMMENT ON COLUMN sa.table_email_log.opp_email2opportunity IS 'Opportunity for the email log entry';
COMMENT ON COLUMN sa.table_email_log.cont_email2contact IS 'Contact for the email log entry';
COMMENT ON COLUMN sa.table_email_log.task_email2task IS 'Task for the email log entry';