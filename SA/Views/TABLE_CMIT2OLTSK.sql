CREATE OR REPLACE FORCE VIEW sa.table_cmit2oltsk (objid,title,sched_cmpltime,creation_time,cmit_txt,originator,s_originator,first_name,s_first_name,last_name,s_last_name) AS
select table_commit_log.objid, table_commit_log.title,
 table_commit_log.sched_cmpltime, table_commit_log.creation_time,
 table_commit_log.cmit_history, table_user.login_name, table_user.S_login_name,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name
 from table_commit_log, table_user, table_contact
 where table_user.objid = table_commit_log.commit_owner2user
 AND table_contact.objid = table_commit_log.commit_cust2contact
 ;
COMMENT ON TABLE sa.table_cmit2oltsk IS 'Used by forms Edit Commitments(396), My Commitments(498) for Outlook Integration. Reserved;future';
COMMENT ON COLUMN sa.table_cmit2oltsk.objid IS 'Commitment object ID number';
COMMENT ON COLUMN sa.table_cmit2oltsk.title IS 'Commitment title';
COMMENT ON COLUMN sa.table_cmit2oltsk.sched_cmpltime IS 'Scheduled completion time';
COMMENT ON COLUMN sa.table_cmit2oltsk.creation_time IS 'Date and time the commitment was created';
COMMENT ON COLUMN sa.table_cmit2oltsk.cmit_txt IS 'Commitment details';
COMMENT ON COLUMN sa.table_cmit2oltsk.originator IS 'Commitment originator';
COMMENT ON COLUMN sa.table_cmit2oltsk.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_cmit2oltsk.last_name IS 'Contact last name';