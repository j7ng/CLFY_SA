CREATE OR REPLACE FORCE VIEW sa.table_sfa_ter_rol (objid,path_type,rollup_objid,rollup_name,s_rollup_name,rollup_type,parent_objid,parent_name,s_parent_name,parent_id,child_objid,child_name,s_child_name,child_id) AS
select table_ter_rol_itm.objid, table_ter_rol_itm.path_type,
 table_rollup.objid, table_rollup.name, table_rollup.S_name,
 table_rollup.rollup_type, table_parent.objid,
 table_parent.name, table_parent.S_name, table_parent.terr_id,
 table_child.objid, table_child.name, table_child.S_name,
 table_child.terr_id
 from table_territory table_child, table_territory table_parent, table_ter_rol_itm, table_rollup
 where table_parent.objid = table_ter_rol_itm.rol_parent2territory
 AND table_child.objid = table_ter_rol_itm.rol_child2territory
 AND table_rollup.objid = table_ter_rol_itm.ter_itm2rollup
 ;
COMMENT ON TABLE sa.table_sfa_ter_rol IS 'Displays a territory rollup. Used by form Console-sales (12000)';
COMMENT ON COLUMN sa.table_sfa_ter_rol.objid IS 'Roll Item internal objid';
COMMENT ON COLUMN sa.table_sfa_ter_rol.path_type IS 'Parent/Child path type, 0=direct relation, 1=indirect relation';
COMMENT ON COLUMN sa.table_sfa_ter_rol.rollup_objid IS 'Rollup internal record number';
COMMENT ON COLUMN sa.table_sfa_ter_rol.rollup_name IS 'Rollup name';
COMMENT ON COLUMN sa.table_sfa_ter_rol.rollup_type IS 'Rollup type, 1=only single parent, 2=multiple parents allowed, 3=duplicated indirect children allowed';
COMMENT ON COLUMN sa.table_sfa_ter_rol.parent_objid IS 'Parent territory s internal record number';
COMMENT ON COLUMN sa.table_sfa_ter_rol.parent_name IS 'Parent territory s name';
COMMENT ON COLUMN sa.table_sfa_ter_rol.parent_id IS 'Parent territory s id';
COMMENT ON COLUMN sa.table_sfa_ter_rol.child_objid IS 'Child territory s internal record number';
COMMENT ON COLUMN sa.table_sfa_ter_rol.child_name IS 'Child territory s name';
COMMENT ON COLUMN sa.table_sfa_ter_rol.child_id IS 'Child territory s ID';