CREATE OR REPLACE FORCE VIEW sa.table_v_cls_case (case_id,id_number,site_name,s_site_name,contact_f_name,s_contact_f_name,contact_l_name,s_contact_l_name,"CONDITION",s_condition) AS
select table_case.objid, table_case.id_number,
 table_site.name, table_site.S_name, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_condition.title, table_condition.S_title
 from table_case, table_site, table_contact,
  table_condition
 where table_condition.objid = table_case.case_state2condition
 AND table_contact.objid = table_case.case_reporter2contact
 AND table_site.objid = table_case.case_reporter2site
 ;
COMMENT ON TABLE sa.table_v_cls_case IS 'Used by form Case Close (340), SubCase Close (404), 2 of 2 (405)';
COMMENT ON COLUMN sa.table_v_cls_case.case_id IS 'Case internal record number';
COMMENT ON COLUMN sa.table_v_cls_case.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_v_cls_case.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_v_cls_case.contact_f_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_v_cls_case.contact_l_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_v_cls_case."CONDITION" IS 'Condition title of the object';