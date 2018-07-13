CREATE OR REPLACE FORCE VIEW sa.table_eco_products (hdr_objid,eff_start_date,eff_end_date,eco_status,apply_mod_level,s_apply_mod_level,apply_mod_objid,apply_part_num,s_apply_part_num,result_mod_level,s_result_mod_level,result_mod_objid,result_part_num,s_result_part_num,objid,role_name,eco_code) AS
select table_eco_hdr.objid, table_eco_hdr.start_date,
 table_eco_hdr.end_date, table_eco_hdr.status,
 table_apply_mod.mod_level, table_apply_mod.S_mod_level, table_apply_mod.objid,
 table_apply_part.part_number, table_apply_part.S_part_number, table_result_mod.mod_level, table_result_mod.S_mod_level,
 table_result_mod.objid, table_result_part.part_number, table_result_part.S_part_number,
 table_eco_mod_role.objid, table_eco_mod_role.role_name,
 table_eco_hdr.eco_code
 from table_mod_level table_apply_mod, table_mod_level table_result_mod, table_part_num table_apply_part, table_part_num table_result_part, table_eco_hdr, table_eco_mod_role
 where table_apply_mod.objid = table_eco_mod_role.applies2mod_level
 AND table_eco_hdr.objid = table_eco_mod_role.eco_mod_role2eco_hdr
 AND table_result_part.objid = table_result_mod.part_info2part_num
 AND table_apply_part.objid = table_apply_mod.part_info2part_num
 AND table_result_mod.objid = table_eco_mod_role.result2mod_level
 ;