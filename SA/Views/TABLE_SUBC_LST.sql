CREATE OR REPLACE FORCE VIEW sa.table_subc_lst (elm_objid,user_objid,id_number,due_date,first_name,s_first_name,last_name,s_last_name,description,s_description,"CONDITION") AS
select table_subcase.objid, table_subcase.subc_owner2user,
 table_subcase.id_number, table_subcase.required_date,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
 table_subcase.title, table_subcase.S_title, table_condition.condition
 from table_subcase, table_contact, table_condition,
  table_case
 where table_subcase.subc_owner2user IS NOT NULL
 AND table_contact.objid = table_case.case_reporter2contact
 AND table_case.objid = table_subcase.subcase2case
 AND table_condition.objid = table_subcase.subc_state2condition
 ;
COMMENT ON TABLE sa.table_subc_lst IS 'Use in My Commitment to show user subcases';
COMMENT ON COLUMN sa.table_subc_lst.elm_objid IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_subc_lst.user_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_subc_lst.id_number IS 'Unique ID number for the subcase';
COMMENT ON COLUMN sa.table_subc_lst.due_date IS 'Date and time the task must be completed';
COMMENT ON COLUMN sa.table_subc_lst.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_subc_lst.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_subc_lst.description IS 'Subcase title';
COMMENT ON COLUMN sa.table_subc_lst."CONDITION" IS 'Subcase condition';