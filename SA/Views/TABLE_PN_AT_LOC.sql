CREATE OR REPLACE FORCE VIEW sa.table_pn_at_loc (objid,"NAME",s_name,"FAMILY",line,part_number,s_part_number,mod_level,s_mod_level,model_num,s_model_num,part_type,s_part_type,"ACTIVE",pmh_objid,locname,locdesc,bin_name,part_desc,s_part_desc,part_auth_objid,part_minimum,part_maximum,part_rol,part_roq,part_mod_objid) AS
select table_part_auth.objid, table_part_num.description, table_part_num.S_description,
 table_part_num.family, table_part_num.line,
 table_part_num.part_number, table_part_num.S_part_number, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_part_num.model_num, table_part_num.S_model_num, table_part_num.domain, table_part_num.S_domain,
 table_mod_level.active, table_part_num.objid,
 table_inv_locatn.location_name, table_inv_locatn.location_descr,
 table_inv_bin.bin_name, table_part_num.description, table_part_num.S_description,
 table_part_auth.objid, table_part_auth.part_minimum,
 table_part_auth.part_maximum, table_part_auth.part_rol,
 table_part_auth.part_roq, table_mod_level.objid
 from table_part_auth, table_part_num, table_mod_level,
  table_inv_locatn, table_inv_bin
 where table_inv_bin.objid = table_part_auth.part_auth2inv_bin
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_mod_level.objid = table_part_auth.n_auth_parts2part_mod
 AND table_inv_locatn.objid = table_inv_bin.inv_bin2inv_locatn
 ;