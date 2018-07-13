CREATE OR REPLACE FORCE VIEW sa.table_dfe_view (usr_objid,elm_objid,id_number,dspch_age,total_age,"CONDITION",s_condition,response,s_response,contact_lname,s_contact_lname,contact_fname,s_contact_fname,parent_objid) AS
select table_user.objid, table_disptchfe.objid,
 table_disptchfe.work_order, table_condition.dispatch_time,
 table_disptchfe.disptime, table_condition.title, table_condition.S_title,
 table_gbst_elm.title, table_gbst_elm.S_title, table_contact.last_name, table_contact.S_last_name,
 table_contact.first_name, table_contact.S_first_name, table_case.objid
 from mtm_user20_monitor0, table_user, table_disptchfe, table_condition,
  table_gbst_elm, table_contact, table_case,
  table_monitor
 where table_contact.objid = table_case.case_reporter2contact
 AND table_user.objid = mtm_user20_monitor0.user_access2monitor
 AND mtm_user20_monitor0.monitor2user = table_monitor.objid 
 AND table_case.objid = table_disptchfe.disptchfe2case
 ;
COMMENT ON TABLE sa.table_dfe_view IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_dfe_view.usr_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_dfe_view.elm_objid IS 'Disptchfe internal record number';
COMMENT ON COLUMN sa.table_dfe_view.id_number IS 'Work order number entered by the user';
COMMENT ON COLUMN sa.table_dfe_view.dspch_age IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_dfe_view.total_age IS 'Date and time the dispatch engineer object was created';
COMMENT ON COLUMN sa.table_dfe_view."CONDITION" IS 'Title of condition';
COMMENT ON COLUMN sa.table_dfe_view.response IS 'Response priority of the dispatch; from a Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_dfe_view.contact_lname IS 'Contact last name';
COMMENT ON COLUMN sa.table_dfe_view.contact_fname IS 'Contact first name';
COMMENT ON COLUMN sa.table_dfe_view.parent_objid IS 'Case internal record number';