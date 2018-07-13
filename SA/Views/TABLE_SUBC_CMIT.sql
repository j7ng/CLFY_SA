CREATE OR REPLACE FORCE VIEW sa.table_subc_cmit (elm_objid,user_objid,id_number,due_date,first_name,s_first_name,last_name,s_last_name,description,"CONDITION",owner_objid) AS
select table_commit_log.objid, table_commit_log.commit_owner2user,
 table_subcase.id_number, table_commit_log.sched_cmpltime,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
 table_commit_log.title, table_commit_log.condition,
 table_subcase.subc_owner2user
 from table_commit_log, table_subcase, table_contact
 where table_subcase.objid = table_commit_log.subc_commit2subcase
 AND table_subcase.subc_owner2user IS NOT NULL
 AND table_contact.objid = table_commit_log.commit_cust2contact
 AND table_commit_log.commit_owner2user IS NOT NULL
 ;
COMMENT ON TABLE sa.table_subc_cmit IS 'Use in My Commitment to show user subcase commitments';
COMMENT ON COLUMN sa.table_subc_cmit.elm_objid IS 'Commit log internal record number';
COMMENT ON COLUMN sa.table_subc_cmit.user_objid IS 'Originator internal record number';
COMMENT ON COLUMN sa.table_subc_cmit.id_number IS 'Unique ID number for the subcase';
COMMENT ON COLUMN sa.table_subc_cmit.due_date IS 'Date and time the task must be completed';
COMMENT ON COLUMN sa.table_subc_cmit.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_subc_cmit.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_subc_cmit.description IS 'Commitment title';
COMMENT ON COLUMN sa.table_subc_cmit."CONDITION" IS 'Commitment condition';
COMMENT ON COLUMN sa.table_subc_cmit.owner_objid IS 'Owner internal record number';