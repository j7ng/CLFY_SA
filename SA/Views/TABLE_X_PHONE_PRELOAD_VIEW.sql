CREATE OR REPLACE FORCE VIEW sa.table_x_phone_preload_view (part_num_objid,part_num_description,s_part_num_description,part_num_part_number,s_part_num_part_number,part_num_active,x_default_preload_objid,x_plan_id,x_home_ld_click,x_roam_local_click,x_roam_ld_click,x_grace_period,x_restrict_ld,x_restrict_callop,x_restrict_intl,x_restrict_roam,part_num_domain,s_part_num_domain) AS
select table_part_num.objid, table_part_num.description, table_part_num.S_description,
 table_part_num.part_number, table_part_num.S_part_number, table_part_num.active,
 table_x_default_preload.objid, table_x_default_preload.x_plan_id,
 table_x_default_preload.x_home_LD_click, table_x_default_preload.x_roam_local_click,
 table_x_default_preload.x_roam_ld_click, table_x_default_preload.x_grace_period,
 table_x_default_preload.x_home_intl_click, table_x_default_preload.x_roam_intl_click,
 table_x_default_preload.x_in_sms_click, table_x_default_preload.x_out_sms_click,
 table_part_num.domain, table_part_num.S_domain
 from table_part_num, table_x_default_preload
 where table_x_default_preload.objid (+) = table_part_num.part_num2default_preload
 ;