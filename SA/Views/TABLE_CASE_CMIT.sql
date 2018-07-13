CREATE OR REPLACE FORCE VIEW sa.table_case_cmit (elm_objid,user_objid,id_number,due_date,first_name,s_first_name,last_name,s_last_name,description,"CONDITION",owner_objid) AS
select table_commit_log.objid, table_commit_log.commit_owner2user,
 table_case.id_number, table_commit_log.sched_cmpltime,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
 table_commit_log.title, table_commit_log.condition,
 table_case.case_owner2user
 from table_commit_log, table_case, table_contact
 where table_case.case_owner2user IS NOT NULL
 AND table_commit_log.commit_owner2user IS NOT NULL
 AND table_case.objid = table_commit_log.case_commit2case
 AND table_contact.objid = table_commit_log.commit_cust2contact
 ;
COMMENT ON TABLE sa.table_case_cmit IS 'Used in form My Commitment (498) to show users case commitments';
COMMENT ON COLUMN sa.table_case_cmit.elm_objid IS 'Commit log internal record number';
COMMENT ON COLUMN sa.table_case_cmit.user_objid IS 'Originator internal record number';
COMMENT ON COLUMN sa.table_case_cmit.id_number IS 'Unique ID number for the case';
COMMENT ON COLUMN sa.table_case_cmit.due_date IS 'Date and time the task must be completed';
COMMENT ON COLUMN sa.table_case_cmit.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_case_cmit.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_case_cmit.description IS 'Commitment title';
COMMENT ON COLUMN sa.table_case_cmit."CONDITION" IS 'Commitment condition';
COMMENT ON COLUMN sa.table_case_cmit.owner_objid IS 'Owner internal record number';