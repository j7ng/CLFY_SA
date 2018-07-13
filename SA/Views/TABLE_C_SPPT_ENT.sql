CREATE OR REPLACE FORCE VIEW sa.table_c_sppt_ent (sp_objid,mod_objid,sp_id,s_sp_id,sp_notes,sp_desc,s_sp_desc,prog_type,is_sppt_prog,p_standalone,p_as_parent,p_as_child,mod_active,mod_eff_date,mod_end_date,ent_type,delivery_type,"CATEGORY",resp_time,cov_hr_title,s_cov_hr_title,cov_hr_desc,objid,ctgry_name) AS
select table_part_num.objid, table_mod_level.objid,
 table_part_num.part_number, table_part_num.S_part_number, table_part_num.notes,
 table_part_num.description, table_part_num.S_description, table_part_num.prog_type,
 table_part_num.is_sppt_prog, table_part_num.p_standalone,
 table_part_num.p_as_parent, table_part_num.p_as_child,
 table_mod_level.active, table_mod_level.eff_date,
 table_mod_level.end_date, table_entitlement.type,
 table_entitlement.delivery_type, table_entitlement.category,
 table_entitlement.response_time, table_wk_work_hr.title, table_wk_work_hr.S_title,
 table_wk_work_hr.description, table_entitlement.objid,
 table_entitlement.ctgry_name
 from table_part_num, table_mod_level, table_entitlement,
  table_wk_work_hr
 where table_part_num.objid = table_mod_level.part_info2part_num
 AND table_mod_level.objid = table_entitlement.service2mod_level
 AND table_wk_work_hr.objid (+) = table_entitlement.entitlement2wk_work_hr
 ;