CREATE OR REPLACE FORCE VIEW sa.table_partbom_view (objid,part_no,s_part_no,description,s_description,mod_level,s_mod_level,qty,part_type,domain,s_domain,"ACTIVE",part_num_objid,parent_objid,qty_objid,bom_type,sn_track) AS
select table_part_mod_child.objid, table_part_num.part_number, table_part_num.S_part_number,
 table_part_num.description, table_part_num.S_description, table_part_mod_child.mod_level, table_part_mod_child.S_mod_level,
 table_part_qty.quantity, table_part_num.part_type,
 table_part_num.domain, table_part_num.S_domain, table_part_num.active,
 table_part_num.objid, table_part_mod_parent.objid,
 table_part_qty.objid, table_part_qty.bom_type,
 table_part_num.sn_track
 from mtm_mod_level4_mod_level5, table_mod_level table_part_mod_child, table_mod_level table_part_mod_parent, table_part_num, table_part_qty
 where table_part_mod_parent.objid = table_part_qty.part_qty2part_info
 AND table_part_mod_child.objid = table_part_qty.part_qty2part_incl
 AND table_part_mod_parent.objid = mtm_mod_level4_mod_level5.part_num_incl2part_num
 AND mtm_mod_level4_mod_level5.incl_part_num2part_num = table_part_mod_child.objid
 AND table_part_num.objid = table_part_mod_child.part_info2part_num
 ;