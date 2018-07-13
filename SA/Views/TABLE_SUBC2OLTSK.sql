CREATE OR REPLACE FORCE VIEW sa.table_subc2oltsk (objid,id_number,"OWNER",s_owner,status,s_status,status_rank,title,s_title,description,first_name,s_first_name,last_name,s_last_name,"PRIORITY",s_priority,priority_rank,creation_time,required_date,status_objid,priority_objid) AS
select table_subcase.objid, table_subcase.id_number,
 table_owner.login_name, table_owner.S_login_name, table_gse_status.title, table_gse_status.S_title,
 table_gse_status.rank, table_subcase.title, table_subcase.S_title,
 table_subcase.description, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_gse_priority.title, table_gse_priority.S_title,
 table_gse_priority.rank, table_subcase.creation_time,
 table_subcase.required_date, table_gse_status.objid,
 table_gse_priority.objid
 from table_gbst_elm table_gse_priority, table_gbst_elm table_gse_status, table_user table_owner, table_subcase, table_contact, table_case
 where table_gse_status.objid = table_subcase.subc_casests2gbst_elm
 AND table_owner.objid = table_subcase.subc_owner2user
 AND table_contact.objid = table_case.case_reporter2contact
 AND table_gse_priority.objid = table_subcase.subc_priorty2gbst_elm
 AND table_case.objid = table_subcase.subcase2case
 ;
COMMENT ON TABLE sa.table_subc2oltsk IS 'Reserved; future';
COMMENT ON COLUMN sa.table_subc2oltsk.objid IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_subc2oltsk.id_number IS 'Unique ID number for the subcase; consists of case number-#';
COMMENT ON COLUMN sa.table_subc2oltsk."OWNER" IS 'Subcase owner user login name';
COMMENT ON COLUMN sa.table_subc2oltsk.status IS 'Status of the subcase';
COMMENT ON COLUMN sa.table_subc2oltsk.status_rank IS 'Rank order of the status in its list';
COMMENT ON COLUMN sa.table_subc2oltsk.title IS 'Subcase title';
COMMENT ON COLUMN sa.table_subc2oltsk.description IS 'Subcase description';
COMMENT ON COLUMN sa.table_subc2oltsk.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_subc2oltsk.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_subc2oltsk."PRIORITY" IS 'Priority of the subcase';
COMMENT ON COLUMN sa.table_subc2oltsk.priority_rank IS 'Rank order of the priority in its list';
COMMENT ON COLUMN sa.table_subc2oltsk.creation_time IS 'Date and time the subcase was created';
COMMENT ON COLUMN sa.table_subc2oltsk.required_date IS 'Date and time task must be completed';
COMMENT ON COLUMN sa.table_subc2oltsk.status_objid IS 'Status internal record number';
COMMENT ON COLUMN sa.table_subc2oltsk.priority_objid IS 'Priority internal record number';