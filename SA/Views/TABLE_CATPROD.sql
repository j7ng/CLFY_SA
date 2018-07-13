CREATE OR REPLACE FORCE VIEW sa.table_catprod (objid,description,s_description,part_no,s_part_no,mod_level,s_mod_level,model_num,s_model_num,domain,s_domain,pmh_objid,"ACTIVE",cat_objid,line,"FAMILY",dom_is_service) AS
select table_mod_level.objid, table_part_num.description, table_part_num.S_description,
 table_part_num.part_number, table_part_num.S_part_number, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_part_num.model_num, table_part_num.S_model_num, table_part_num.domain, table_part_num.S_domain,
 table_part_num.objid, table_mod_level.active,
 table_catalog.objid, table_part_num.line,
 table_part_num.family, table_part_num.dom_is_service
 from mtm_catalog0_mod_level3, table_mod_level, table_part_num, table_catalog
 where table_part_num.objid = table_mod_level.part_info2part_num
 AND table_catalog.objid = mtm_catalog0_mod_level3.catalog2part_info
 AND mtm_catalog0_mod_level3.part_info2catalog = table_mod_level.objid
 ;