CREATE TABLE sa.table_commit_log (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  creation_time DATE,
  sched_cmpltime DATE,
  act_cmpltime DATE,
  cmit_history LONG,
  made_to NUMBER,
  "CONDITION" NUMBER,
  site_time DATE,
  action_type VARCHAR2(20 BYTE),
  warning_time DATE,
  elapsed_time NUMBER,
  dev NUMBER,
  case_commit2case NUMBER(*,0),
  subc_commit2subcase NUMBER(*,0),
  commit_owner2user NUMBER(*,0),
  cmit_prirty2gbst_elm NUMBER(*,0),
  commit_cust2contact NUMBER(*,0),
  cmit_solver2employee NUMBER(*,0),
  bug_commit2bug NUMBER(*,0),
  commit_empl2employee NUMBER(*,0),
  cmit_name2gbst_elm NUMBER(*,0),
  opp_commit2opportunity NUMBER(*,0),
  job_commit2job NUMBER(*,0)
);
ALTER TABLE sa.table_commit_log ADD SUPPLEMENTAL LOG GROUP dmtsora1228985411_0 (action_type, act_cmpltime, bug_commit2bug, case_commit2case, cmit_name2gbst_elm, cmit_prirty2gbst_elm, cmit_solver2employee, commit_cust2contact, commit_empl2employee, commit_owner2user, "CONDITION", creation_time, dev, elapsed_time, job_commit2job, made_to, objid, opp_commit2opportunity, sched_cmpltime, site_time, subc_commit2subcase, title, warning_time) ALWAYS;
COMMENT ON TABLE sa.table_commit_log IS 'Object which contains the details of a commitment made for a case, subcase, or job';
COMMENT ON COLUMN sa.table_commit_log.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_commit_log.title IS 'Commitment log title';
COMMENT ON COLUMN sa.table_commit_log.creation_time IS 'Date and time the commitment was created';
COMMENT ON COLUMN sa.table_commit_log.sched_cmpltime IS 'Date and time of scheduled completion; date/time completion is required/requested';
COMMENT ON COLUMN sa.table_commit_log.act_cmpltime IS 'Date and time of actual completion';
COMMENT ON COLUMN sa.table_commit_log.cmit_history IS 'Commitment history; text appended as activities occur';
COMMENT ON COLUMN sa.table_commit_log.made_to IS 'Whether the commitment was made to or made by the customer';
COMMENT ON COLUMN sa.table_commit_log."CONDITION" IS 'Commitment condition; open or closed';
COMMENT ON COLUMN sa.table_commit_log.site_time IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_commit_log.action_type IS 'Action type for the log; from user-defined pop up with default name Commitment Log Action Type';
COMMENT ON COLUMN sa.table_commit_log.warning_time IS 'Date and time of commitment warning';
COMMENT ON COLUMN sa.table_commit_log.elapsed_time IS 'Prior warning elapsed time in seconds';
COMMENT ON COLUMN sa.table_commit_log.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_commit_log.case_commit2case IS 'Related case';
COMMENT ON COLUMN sa.table_commit_log.subc_commit2subcase IS 'Related subcase';
COMMENT ON COLUMN sa.table_commit_log.commit_owner2user IS 'User that entered the commitment';
COMMENT ON COLUMN sa.table_commit_log.cmit_prirty2gbst_elm IS 'Reserved; to be used to log priority of commitment';
COMMENT ON COLUMN sa.table_commit_log.commit_cust2contact IS 'Contact the commitment was made to or who made commitment';
COMMENT ON COLUMN sa.table_commit_log.cmit_solver2employee IS 'Employee who completed commitment';
COMMENT ON COLUMN sa.table_commit_log.bug_commit2bug IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_commit_log.commit_empl2employee IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_commit_log.cmit_name2gbst_elm IS 'Condition of commitment; e.g., open, closed; uses Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_commit_log.opp_commit2opportunity IS 'Related opportunity; reserved future';
COMMENT ON COLUMN sa.table_commit_log.job_commit2job IS 'Related job';