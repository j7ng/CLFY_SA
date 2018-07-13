CREATE OR REPLACE FORCE VIEW sa.table_part_mod_v (objid,part_num_objid,part_number,s_part_number,part_num,s_part_num,part_mod_l,s_part_mod_l,domain,s_domain,"ACTIVE") AS
select table_mod_level.objid, table_part_num.objid,
 table_part_num.part_number, table_part_num.S_part_number, table_part_num.description, table_part_num.S_description,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_part_num.domain, table_part_num.S_domain,
 table_mod_level.active
 from table_mod_level, table_part_num
 where table_part_num.objid = table_mod_level.part_info2part_num
 ;