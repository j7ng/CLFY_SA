CREATE OR REPLACE FORCE VIEW sa.table_web_usrcas (user_objid,elm_objid,clarify_state,id_number,title,s_title,age,"CONDITION",s_condition,status,s_status,login_name,s_login_name,creation_time) AS
select table_user.objid, table_case.objid,
 table_condition.condition, table_case.id_number,
 table_case.title, table_case.S_title, table_condition.wipbin_time,
 table_condition.title, table_condition.S_title, table_gbst_elm.title, table_gbst_elm.S_title,
 table_user.login_name, table_user.S_login_name, table_case.creation_time
 from table_user, table_case, table_condition,
  table_gbst_elm
 where table_user.objid = table_case.case_owner2user
 AND table_gbst_elm.objid = table_case.casests2gbst_elm
 AND table_condition.objid = table_case.case_state2condition
 ;
COMMENT ON TABLE sa.table_web_usrcas IS 'Used internally to select Cases (open/closed) owned by a User';
COMMENT ON COLUMN sa.table_web_usrcas.user_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_web_usrcas.elm_objid IS 'Case internal record nubmer';
COMMENT ON COLUMN sa.table_web_usrcas.clarify_state IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_web_usrcas.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_web_usrcas.title IS 'Case or service call title; summary of case details';
COMMENT ON COLUMN sa.table_web_usrcas.age IS 'Date and time task was accepted into WipBin';
COMMENT ON COLUMN sa.table_web_usrcas."CONDITION" IS 'Title of condition';
COMMENT ON COLUMN sa.table_web_usrcas.status IS 'Reserved - not used';
COMMENT ON COLUMN sa.table_web_usrcas.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_web_usrcas.creation_time IS 'The date and time that the case was created';