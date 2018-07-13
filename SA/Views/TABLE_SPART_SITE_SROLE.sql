CREATE OR REPLACE FORCE VIEW sa.table_spart_site_srole (site_objid,spart_objid,objid,site_id,site_name,s_site_name,serial_no,s_serial_no,instance_name,role_name,xref_id) AS
select table_site.objid, table_site_part.objid,
 table_sit_prt_role.objid, table_site.site_id,
 table_site.name, table_site.S_name, table_site_part.serial_no, table_site_part.S_serial_no,
 table_site_part.instance_name, table_sit_prt_role.role_name,
 table_sit_prt_role.vendor_part_no
 from table_site, table_site_part, table_sit_prt_role
 where table_site.objid = table_sit_prt_role.prt_role2site
 AND table_site_part.objid = table_sit_prt_role.prt_role2site_part
 ;
COMMENT ON TABLE sa.table_spart_site_srole IS 'View provider site and xref information';
COMMENT ON COLUMN sa.table_spart_site_srole.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_spart_site_srole.spart_objid IS 'Site_part internal record number';
COMMENT ON COLUMN sa.table_spart_site_srole.objid IS 'Sit_prt_role internal record number';
COMMENT ON COLUMN sa.table_spart_site_srole.site_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_spart_site_srole.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_spart_site_srole.serial_no IS 'Installed part serial number';
COMMENT ON COLUMN sa.table_spart_site_srole.instance_name IS 'Default is the concatination of part name, part number, and part revision. May be customized';
COMMENT ON COLUMN sa.table_spart_site_srole.role_name IS 'Name of the role. This is a user-defined popup with default name SERVICE_ROLE';
COMMENT ON COLUMN sa.table_spart_site_srole.xref_id IS 'Vendor s part number';