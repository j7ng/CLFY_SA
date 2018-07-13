CREATE OR REPLACE FORCE VIEW sa.table_sfa_bus_rol (objid,path_type,rollup_objid,rollup_name,s_rollup_name,rollup_type,parent_objid,parent_name,s_parent_name,parent_id,s_parent_id,child_objid,child_name,s_child_name,child_id,s_child_id) AS
select table_bus_rol_itm.objid, table_bus_rol_itm.path_type,
 table_rollup.objid, table_rollup.name, table_rollup.S_name,
 table_rollup.rollup_type, table_parent.objid,
 table_parent.name, table_parent.S_name, table_parent.org_id, table_parent.S_org_id,
 table_child.objid, table_child.name, table_child.S_name,
 table_child.org_id, table_child.S_org_id
 from table_bus_org table_child, table_bus_org table_parent, table_bus_rol_itm, table_rollup
 where table_parent.objid = table_bus_rol_itm.parent2bus_org
 AND table_child.objid = table_bus_rol_itm.child2bus_org
 AND table_rollup.objid = table_bus_rol_itm.bus_itm2rollup
 ;
COMMENT ON TABLE sa.table_sfa_bus_rol IS 'Displays Account rollup items. Used by form Account Mgr (11650)';
COMMENT ON COLUMN sa.table_sfa_bus_rol.objid IS 'Roll Item internal objid';
COMMENT ON COLUMN sa.table_sfa_bus_rol.path_type IS 'Parent/Child path type, 0=direct relation, 1=indirect relation';
COMMENT ON COLUMN sa.table_sfa_bus_rol.rollup_objid IS 'Rollup internal record number';
COMMENT ON COLUMN sa.table_sfa_bus_rol.rollup_name IS 'Rollup name';
COMMENT ON COLUMN sa.table_sfa_bus_rol.rollup_type IS 'Rollup type, 1=single parent, 2=multiple parents allowed, 3=duplicated indirect children allowed';
COMMENT ON COLUMN sa.table_sfa_bus_rol.parent_objid IS 'Parent business organization s internal record number';
COMMENT ON COLUMN sa.table_sfa_bus_rol.parent_name IS 'Parent business organization s name';
COMMENT ON COLUMN sa.table_sfa_bus_rol.parent_id IS 'Parent business organization s ID number';
COMMENT ON COLUMN sa.table_sfa_bus_rol.child_objid IS 'Child business organization s internal record number';
COMMENT ON COLUMN sa.table_sfa_bus_rol.child_name IS 'Child business organization s name';
COMMENT ON COLUMN sa.table_sfa_bus_rol.child_id IS ' Child business organization s ID';