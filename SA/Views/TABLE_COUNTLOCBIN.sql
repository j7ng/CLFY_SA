CREATE OR REPLACE FORCE VIEW sa.table_countlocbin (objid,count_name,loc_objid,location_name,location_descr,location_type,site_id,site_name,s_site_name,site_objid,bin_name,bin_objid,role_name,count_id,cc_ct_date) AS
select table_count_setup.objid, table_count_setup.count_name,
 table_inv_locatn.objid, table_inv_locatn.location_name,
 table_inv_locatn.location_descr, table_inv_locatn.location_type,
 table_site.site_id, table_site.name, table_site.S_name,
 table_site.objid, table_inv_bin.bin_name,
 table_inv_bin.objid, table_inv_role.role_name,
 table_count_setup.count_id, table_count_setup.cc_ct_date
 from mtm_inv_bin7_count_setup0, table_count_setup, table_inv_locatn, table_site,
  table_inv_bin, table_inv_role
 where table_inv_bin.objid = mtm_inv_bin7_count_setup0.setup2count_setup
 AND mtm_inv_bin7_count_setup0.setup2inv_bin = table_count_setup.objid
 AND table_inv_locatn.objid = table_inv_role.inv_role2inv_locatn
 AND table_inv_locatn.objid = table_inv_bin.inv_bin2inv_locatn
 AND table_site.objid = table_inv_role.inv_role2site
 ;
COMMENT ON TABLE sa.table_countlocbin IS 'Used by the Inventory Count form (8411) to show all locations and bins associated with this inventory count';
COMMENT ON COLUMN sa.table_countlocbin.objid IS 'Count_setup internal record number';
COMMENT ON COLUMN sa.table_countlocbin.count_name IS 'The name of this inventory reconciliation count profile';
COMMENT ON COLUMN sa.table_countlocbin.loc_objid IS 'Inventory location internal record number';
COMMENT ON COLUMN sa.table_countlocbin.location_name IS 'For physical inventory locations, the name of the location. For GL accounts, the account number';
COMMENT ON COLUMN sa.table_countlocbin.location_descr IS 'Description of the inventory location or GL account';
COMMENT ON COLUMN sa.table_countlocbin.location_type IS 'User-defined types of physical inventory location';
COMMENT ON COLUMN sa.table_countlocbin.site_id IS 'Site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_countlocbin.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_countlocbin.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_countlocbin.bin_name IS 'Unique name of the inventory bin within an inventory location';
COMMENT ON COLUMN sa.table_countlocbin.bin_objid IS 'Inventory bin internal record number';
COMMENT ON COLUMN sa.table_countlocbin.role_name IS 'Role being played by the inventory location or the site';
COMMENT ON COLUMN sa.table_countlocbin.count_id IS 'The unique identifier for this inventory reconciliation count profile';
COMMENT ON COLUMN sa.table_countlocbin.cc_ct_date IS 'The scheduled date for this count profile';