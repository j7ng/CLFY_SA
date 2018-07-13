CREATE OR REPLACE FORCE VIEW sa.table_view_vpt (objid,vendor_part_no,s_vendor_part_no,site_id,site_obj,site_name,s_site_name,description,s_description,mod_lev_obj,mod_level,s_mod_level,vendor_rev,s_vendor_rev,vendor_part_objid,role_name,warranty,avg_cost,part_number,s_part_number,part_num_description,s_part_num_description,lead_time,avg_lead_time,preference,part_status) AS
select table_vendor_part.objid, table_vendor_part.vendor_part_no, table_vendor_part.S_vendor_part_no,
 table_site.site_id, table_site.objid,
 table_site.name, table_site.S_name, table_part_num.description, table_part_num.S_description,
 table_mod_level.objid, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_vendor_part.vendor_rev, table_vendor_part.S_vendor_rev, table_vendor_part.objid,
 table_vendor_part.role_name, table_vendor_part.warranty,
 table_vendor_part.avg_cost, table_part_num.part_number, table_part_num.S_part_number,
 table_part_num.description, table_part_num.S_description, table_vendor_part.lead_time,
 table_vendor_part.avg_lead_time, table_vendor_part.preference,
 table_vendor_part.part_status
 from table_vendor_part, table_site, table_part_num,
  table_mod_level
 where table_site.objid = table_vendor_part.vendor_part2site
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_mod_level.objid = table_vendor_part.vendor_part2mod_level
 ;
COMMENT ON TABLE sa.table_view_vpt IS 'Reserved; future';
COMMENT ON COLUMN sa.table_view_vpt.objid IS 'Vendor part internal record number';
COMMENT ON COLUMN sa.table_view_vpt.vendor_part_no IS 'Vendor s part number';
COMMENT ON COLUMN sa.table_view_vpt.site_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_view_vpt.site_obj IS 'Site internal record number';
COMMENT ON COLUMN sa.table_view_vpt.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_view_vpt.description IS 'Description of the product';
COMMENT ON COLUMN sa.table_view_vpt.mod_lev_obj IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_view_vpt.mod_level IS 'Name of the part revision';
COMMENT ON COLUMN sa.table_view_vpt.vendor_rev IS 'Vendor site s part number revision level';
COMMENT ON COLUMN sa.table_view_vpt.vendor_part_objid IS 'Vendor part internal record number';
COMMENT ON COLUMN sa.table_view_vpt.role_name IS 'Role played by the vendor for the part, e.g., supplier, repair vendor, exchange vendor etc';
COMMENT ON COLUMN sa.table_view_vpt.warranty IS 'Warranty length in days for the role';
COMMENT ON COLUMN sa.table_view_vpt.avg_cost IS 'Part s average cost';
COMMENT ON COLUMN sa.table_view_vpt.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_view_vpt.part_num_description IS 'Description of the product';
COMMENT ON COLUMN sa.table_view_vpt.lead_time IS 'Lead time for the role in seconds';
COMMENT ON COLUMN sa.table_view_vpt.avg_lead_time IS 'Part s average lead time for the role in seconds';
COMMENT ON COLUMN sa.table_view_vpt.preference IS 'Vender preference';
COMMENT ON COLUMN sa.table_view_vpt.part_status IS 'Vendor part status';