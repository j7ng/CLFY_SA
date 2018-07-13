CREATE OR REPLACE FORCE VIEW sa.table_pmhpml_view (objid,"NAME","FAMILY",line,part_number,s_part_number,mod_level,s_mod_level,model_num,s_model_num,part_type,"ACTIVE",pmh_objid,description,s_description,quantity,partnum_objid,part_active,domain,s_domain,std_warranty,dom_is_service) AS
select table_mod_level.objid, table_part_class.name,
 table_part_num.family, table_part_num.line,
 table_part_num.part_number, table_part_num.S_part_number, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_part_num.model_num, table_part_num.S_model_num, table_part_num.part_type,
 table_mod_level.active, table_part_class.objid,
 table_part_num.description, table_part_num.S_description, table_part_num.sn_track,
 table_part_num.objid, table_part_num.active,
 table_part_num.domain, table_part_num.S_domain, table_part_num.std_warranty,
 table_part_num.dom_is_service
 from table_mod_level, table_part_class, table_part_num
 where table_part_num.objid = table_mod_level.part_info2part_num
 AND table_part_class.objid = table_part_num.part_num2part_class
 ;