CREATE OR REPLACE FORCE VIEW sa.table_v_cls_dfe (dfe_id,id_number,site_name,s_site_name,contact_f_name,s_contact_f_name,contact_l_name,s_contact_l_name,"CONDITION",s_condition,case_id) AS
select table_disptchfe.objid, table_disptchfe.work_order,
 table_site.name, table_site.S_name, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_condition.title, table_condition.S_title,
 table_case.objid
 from table_disptchfe, table_site, table_contact,
  table_condition, table_case
 where table_site.objid = table_case.case_reporter2site
 AND table_contact.objid = table_case.case_reporter2contact
 AND table_case.objid = table_disptchfe.disptchfe2case
 ;
COMMENT ON TABLE sa.table_v_cls_dfe IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_v_cls_dfe.dfe_id IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_v_cls_dfe.id_number IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_v_cls_dfe.site_name IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_v_cls_dfe.contact_f_name IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_v_cls_dfe.contact_l_name IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_v_cls_dfe."CONDITION" IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_v_cls_dfe.case_id IS 'Reserved; not used';