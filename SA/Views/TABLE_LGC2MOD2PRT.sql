CREATE OR REPLACE FORCE VIEW sa.table_lgc2mod2prt (objid,lgc_number,lgc_desc,lgc_is_cmn,mod_objid,"NAME","FAMILY",line,part_number,s_part_number,mod_level,s_mod_level,model_num,s_model_num,part_type,"ACTIVE",pmh_objid,description,s_description,quantity,partnum_objid,part_active,domain,s_domain) AS
select table_prog_logic.objid, table_prog_logic.id_number,
 table_prog_logic.description, table_prog_logic.is_cmn,
 table_mod_level.objid, table_part_class.name,
 table_part_num.family, table_part_num.line,
 table_part_num.part_number, table_part_num.S_part_number, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_part_num.model_num, table_part_num.S_model_num, table_part_num.part_type,
 table_mod_level.active, table_part_class.objid,
 table_part_num.description, table_part_num.S_description, table_part_num.sn_track,
 table_part_num.objid, table_part_num.active,
 table_part_num.domain, table_part_num.S_domain
 from table_prog_logic, table_mod_level, table_part_class,
  table_part_num
 where table_part_class.objid = table_prog_logic.prog_logic2part_class
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_mod_level.objid = table_prog_logic.prog_logic2part_info
 ;