CREATE OR REPLACE FORCE VIEW sa.table_case_view (usr_objid,elm_objid,id_number,dspch_age,total_age,"CONDITION",s_condition,response,s_response,contact_lname,s_contact_lname,contact_fname,s_contact_fname) AS
select table_user.objid, table_case.objid,
 table_case.id_number, table_condition.dispatch_time,
 table_case.creation_time, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_contact.last_name, table_contact.S_last_name,
 table_contact.first_name, table_contact.S_first_name
 from mtm_case34_monitor6, mtm_user20_monitor0, table_user, table_case, table_condition,
  table_gbst_elm, table_contact, table_monitor
 where table_condition.objid = table_case.case_state2condition
 AND table_gbst_elm.objid = table_case.respsvrty2gbst_elm
 AND table_case.objid = mtm_case34_monitor6.case_view2monitor
 AND mtm_case34_monitor6.monitor2case = table_monitor.objid 
 AND table_contact.objid = table_case.case_reporter2contact
 AND table_user.objid = mtm_user20_monitor0.user_access2monitor
 AND mtm_user20_monitor0.monitor2user = table_monitor.objid 
 ;
COMMENT ON TABLE sa.table_case_view IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_case_view.usr_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_case_view.elm_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_case_view.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_case_view.dspch_age IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_case_view.total_age IS 'Date and time the case was created';
COMMENT ON COLUMN sa.table_case_view."CONDITION" IS 'Title of condition';
COMMENT ON COLUMN sa.table_case_view.response IS 'Response priority of case; from a Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_case_view.contact_lname IS 'Contact last name';
COMMENT ON COLUMN sa.table_case_view.contact_fname IS 'Contact first name';