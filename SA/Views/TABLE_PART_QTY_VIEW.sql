CREATE OR REPLACE FORCE VIEW sa.table_part_qty_view (objid,quantity,parent_objid,child_objid,bom_type) AS
select table_part_qty.objid, table_part_qty.quantity,
 table_part_mod_parent.objid, table_part_mod_child.objid,
 table_part_qty.bom_type
 from mtm_mod_level4_mod_level5, table_mod_level table_part_mod_child, table_mod_level table_part_mod_parent, table_part_qty
 where table_part_mod_parent.objid = table_part_qty.part_qty2part_info
 AND table_part_mod_parent.objid = mtm_mod_level4_mod_level5.part_num_incl2part_num
 AND mtm_mod_level4_mod_level5.incl_part_num2part_num = table_part_mod_child.objid 
 AND table_part_mod_child.objid = table_part_qty.part_qty2part_incl
 ;
COMMENT ON TABLE sa.table_part_qty_view IS 'Quantity of a part within a part BOM';
COMMENT ON COLUMN sa.table_part_qty_view.objid IS 'Part quantity internal record number';
COMMENT ON COLUMN sa.table_part_qty_view.quantity IS 'Quantity of the part used in a BOM';
COMMENT ON COLUMN sa.table_part_qty_view.parent_objid IS 'Parent part revision internal record number';
COMMENT ON COLUMN sa.table_part_qty_view.child_objid IS 'Child part revision internal record number';
COMMENT ON COLUMN sa.table_part_qty_view.bom_type IS 'Type designation of the BOM; i.e., 0=a standard part BOM, 1=a literature/documentation BOM, default=0. A type=1 BOM is normally one that contains documentation or marketing collateral';