CREATE OR REPLACE FORCE VIEW sa.table_user_case_load (elm_objid,user_objid,clarify_state,status,s_status,case_type,s_case_type) AS
select table_case.objid, table_case.case_owner2user,
 table_condition.condition, table_gse_status.title, table_gse_status.S_title,
 table_gse_cas_type.title, table_gse_cas_type.S_title
 from table_gbst_elm table_gse_cas_type, table_gbst_elm table_gse_status, table_case, table_condition
 where table_gse_cas_type.objid = table_case.calltype2gbst_elm
 AND table_case.case_owner2user IS NOT NULL
 AND table_condition.objid = table_case.case_state2condition
 AND table_gse_status.objid = table_case.casests2gbst_elm
 ;
COMMENT ON TABLE sa.table_user_case_load IS 'Used to determine case load (number of open cases owned) for a user';
COMMENT ON COLUMN sa.table_user_case_load.elm_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_user_case_load.user_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_user_case_load.clarify_state IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_user_case_load.status IS 'Name of the item/element status';
COMMENT ON COLUMN sa.table_user_case_load.case_type IS 'Name of the item/element type';