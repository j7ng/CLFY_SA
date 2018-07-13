CREATE OR REPLACE FORCE VIEW sa.table_loc_rollup_v (objid,path_type,rollup_objid,rollup_name,s_rollup_name,rollup_type,usage_type,parent_objid,parent_name,parent_active,child_objid,child_name,child_active,"DEPTH") AS
select table_loc_rol_itm.objid, table_loc_rol_itm.path_type,
 table_rollup.objid, table_rollup.name, table_rollup.S_name,
 table_rollup.rollup_type, table_rollup.use_type,
 table_parent.objid, table_parent.location_name,
 table_parent.active, table_child.objid,
 table_child.location_name, table_child.active,
 table_loc_rol_itm.depth
 from table_inv_locatn table_child, table_inv_locatn table_parent, table_loc_rol_itm, table_rollup
 where table_parent.objid = table_loc_rol_itm.parent2inv_locatn
 AND table_child.objid = table_loc_rol_itm.child2inv_locatn
 AND table_rollup.objid = table_loc_rol_itm.loc_itm2rollup
 ;
COMMENT ON TABLE sa.table_loc_rollup_v IS 'Displays location hierarchies. Used by Inventory Location Rollup form (8431)';
COMMENT ON COLUMN sa.table_loc_rollup_v.objid IS 'Rollup item internal record number';
COMMENT ON COLUMN sa.table_loc_rollup_v.path_type IS 'Parent/Child path type, 0=directly related, 1=indirectly related';
COMMENT ON COLUMN sa.table_loc_rollup_v.rollup_objid IS 'Rollup internal record number';
COMMENT ON COLUMN sa.table_loc_rollup_v.rollup_name IS 'Name of the rollup';
COMMENT ON COLUMN sa.table_loc_rollup_v.rollup_type IS 'Contraints on the rollup, i.e., 1=only single parent allowed, 2=multiple parents allowed, 3=duplicate indirect children allowed';
COMMENT ON COLUMN sa.table_loc_rollup_v.usage_type IS 'Used within focus_type to signal how a rollup on a particular object is used by the application; e.g., for inventory locations (228) 1=Counting for inventory counts, 2=physical - for zone management, 3=reporting for reporting operational metrics';
COMMENT ON COLUMN sa.table_loc_rollup_v.parent_objid IS 'Parent location internal record number';
COMMENT ON COLUMN sa.table_loc_rollup_v.parent_name IS 'Name of the parent location';
COMMENT ON COLUMN sa.table_loc_rollup_v.parent_active IS 'Status of the parent location';
COMMENT ON COLUMN sa.table_loc_rollup_v.child_objid IS 'Child location internal record number';
COMMENT ON COLUMN sa.table_loc_rollup_v.child_name IS 'Name of the child location';
COMMENT ON COLUMN sa.table_loc_rollup_v.child_active IS 'Status of the child location';
COMMENT ON COLUMN sa.table_loc_rollup_v."DEPTH" IS 'Depth of the item from the top-level item; e.g., 0=top-level item, 1=item that reports directly to top level item, etc., default=-1 (unknown)';