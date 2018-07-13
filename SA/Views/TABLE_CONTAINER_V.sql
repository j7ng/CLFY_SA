CREATE OR REPLACE FORCE VIEW sa.table_container_v (objid,"ID","NAME",status,locname,parent_objid,bin_name,fixbin_objid,fixbin_name,loc_objid,loc_name,site_id,site_name,s_site_name,site_objid,role_name,role_objid,loc_turn_ratio) AS
select table_container.objid, table_container.id_number,
 table_container.bin_name, table_container.opened_ind,
 table_container.location_name, table_parent.objid,
 table_parent.bin_name, table_fixbin.objid,
 table_fixbin.bin_name, table_inv_locatn.objid,
 table_inv_locatn.location_name, table_site.site_id,
 table_site.name, table_site.S_name, table_site.objid,
 table_inv_role.role_name, table_inv_role.objid,
 table_inv_locatn.loc_turn_ratio
 from table_inv_bin table_container, table_inv_bin table_fixbin, table_inv_bin table_parent, table_inv_locatn, table_site, table_inv_role
 where table_parent.objid = table_container.child2inv_bin
 AND table_site.objid = table_inv_role.inv_role2site
 AND table_fixbin.objid = table_container.movable_bin2inv_bin
 AND table_inv_locatn.objid = table_container.inv_bin2inv_locatn
 AND table_inv_locatn.objid = table_inv_role.inv_role2inv_locatn
 ;
COMMENT ON TABLE sa.table_container_v IS 'Used by the forms Container Tracking (8470) and Move Container (8471)';
COMMENT ON COLUMN sa.table_container_v.objid IS 'Container inventory bin internal record number';
COMMENT ON COLUMN sa.table_container_v."ID" IS 'Container unique bin number assigned by auto-numbering definition';
COMMENT ON COLUMN sa.table_container_v."NAME" IS 'Unique name of the container within an inventory bin';
COMMENT ON COLUMN sa.table_container_v.status IS 'Indicates whether the container bin allows parts to be moved in/out or not';
COMMENT ON COLUMN sa.table_container_v.locname IS 'For display only of the container s inventory location name';
COMMENT ON COLUMN sa.table_container_v.parent_objid IS 'Parent inventory bin internal record number';
COMMENT ON COLUMN sa.table_container_v.bin_name IS 'Parent inventory bin unique name within an inventory location';
COMMENT ON COLUMN sa.table_container_v.fixbin_objid IS 'Fixed inventory bin internal record number';
COMMENT ON COLUMN sa.table_container_v.fixbin_name IS 'Fixed inventory bin unique name within an inventory location';
COMMENT ON COLUMN sa.table_container_v.loc_objid IS 'Inventory location internal record number';
COMMENT ON COLUMN sa.table_container_v.loc_name IS 'For physical inventory locations, the name of the location. For GL accounts, the account number';
COMMENT ON COLUMN sa.table_container_v.site_id IS 'Site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_container_v.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_container_v.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_container_v.role_name IS 'Name of role played by the focus type; e.g., site s default-bad parts inventory location, inventory locations located-at site';
COMMENT ON COLUMN sa.table_container_v.role_objid IS 'Inv_role internal record number';
COMMENT ON COLUMN sa.table_container_v.loc_turn_ratio IS 'Reserved; future';