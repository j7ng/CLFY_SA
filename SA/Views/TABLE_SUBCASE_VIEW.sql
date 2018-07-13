CREATE OR REPLACE FORCE VIEW sa.table_subcase_view (usr_objid,elm_objid,id_number,dspch_age,total_age,"CONDITION",s_condition,response,s_response,contact_lname,s_contact_lname,contact_fname,s_contact_fname,parent_objid) AS
select table_user.objid, table_subcase.objid,
 table_subcase.id_number, table_condition.dispatch_time,
 table_subcase.creation_time, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_contact.last_name, table_contact.S_last_name,
 table_contact.first_name, table_contact.S_first_name, table_case.objid
 from mtm_subcase21_monitor7, mtm_user20_monitor0, table_user, table_subcase, table_condition,
  table_gbst_elm, table_contact, table_case,
  table_monitor
 where table_gbst_elm.objid = table_subcase.subc_priorty2gbst_elm
 AND table_condition.objid = table_subcase.subc_state2condition
 AND table_subcase.objid = mtm_subcase21_monitor7.subc_view2monitor
 AND mtm_subcase21_monitor7.monitor2subcase = table_monitor.objid 
 AND table_user.objid = mtm_user20_monitor0.user_access2monitor
 AND mtm_user20_monitor0.monitor2user = table_monitor.objid 
 AND table_case.objid = table_subcase.subcase2case
 AND table_contact.objid = table_case.case_reporter2contact
 ;
COMMENT ON TABLE sa.table_subcase_view IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_subcase_view.usr_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_subcase_view.elm_objid IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_subcase_view.id_number IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_subcase_view.dspch_age IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_subcase_view.total_age IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_subcase_view."CONDITION" IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_subcase_view.response IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_subcase_view.contact_lname IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_subcase_view.contact_fname IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_subcase_view.parent_objid IS 'Reserved; obsolete';