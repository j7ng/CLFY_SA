CREATE OR REPLACE FORCE VIEW sa.table_svc_part_view (objid,partnum_objid,mod_objid,part_number,s_part_number,mod_level,s_mod_level,description,s_description,serial_no,s_serial_no,quantity,domain,s_domain,dom_serialno,dom_uniquesn,dom_catalogs,dom_boms,dom_at_site,dom_at_parts,dom_at_domain,dom_pt_used_bom,dom_pt_used_dom,selected_prd,instance_name,model_num,s_model_num,warranty_date,dir_site_objid,sn_track,incl_domain,role_objid,role_name,role_focus_type,role_active,site_name,s_site_name,site_id,site_objid,instance_id,config_type,invoice_no,part_status,"FAMILY",part_type,struct_type) AS
select table_site_part.objid, table_part_num.objid,
 table_mod_level.objid, table_part_num.part_number, table_part_num.S_part_number,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_part_num.description, table_part_num.S_description,
 table_site_part.serial_no, table_site_part.S_serial_no, table_site_part.quantity,
 table_part_num.domain, table_part_num.S_domain, table_part_num.dom_serialno,
 table_part_num.dom_uniquesn, table_part_num.dom_catalogs,
 table_part_num.dom_boms, table_part_num.dom_at_site,
 table_part_num.dom_at_parts, table_part_num.dom_at_domain,
 table_part_num.dom_pt_used_bom, table_part_num.dom_pt_used_dom,
 table_site_part.selected_prd, table_site_part.instance_name,
 table_part_num.model_num, table_part_num.S_model_num, table_site_part.warranty_date,
 table_site_part.dir_site_objid, table_part_num.sn_track,
 table_part_num.incl_domain, table_sit_prt_role.objid,
 table_sit_prt_role.role_name, table_sit_prt_role.focus_type,
 table_sit_prt_role.active, table_site.name, table_site.S_name,
 table_site.site_id, table_site.objid,
 table_site_part.instance_id, table_mod_level.config_type,
 table_site_part.invoice_no, table_site_part.part_status,
 table_part_num.family, table_part_num.part_type,
 table_part_num.struct_type
 from table_site_part, table_part_num, table_mod_level,
  table_sit_prt_role, table_site
 where table_mod_level.objid = table_site_part.site_part2part_info
 AND table_site_part.objid = table_sit_prt_role.prt_role2site_part
 AND table_site.objid = table_sit_prt_role.prt_role2site
 AND table_part_num.objid = table_mod_level.part_info2part_num
 ;
COMMENT ON TABLE sa.table_svc_part_view IS 'Part number and rev for the installed Service part; used by form Installed Services (620)';
COMMENT ON COLUMN sa.table_svc_part_view.objid IS 'Part internal record number';
COMMENT ON COLUMN sa.table_svc_part_view.partnum_objid IS 'Part num internal record number';
COMMENT ON COLUMN sa.table_svc_part_view.mod_objid IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_svc_part_view.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_svc_part_view.mod_level IS 'Revision level';
COMMENT ON COLUMN sa.table_svc_part_view.description IS 'Part maps to sales and mfg systems';
COMMENT ON COLUMN sa.table_svc_part_view.serial_no IS 'Installed part serial number';
COMMENT ON COLUMN sa.table_svc_part_view.quantity IS 'Installed part quantity; equal to 1 for serialized parts';
COMMENT ON COLUMN sa.table_svc_part_view.domain IS 'Name of the domain for the part num';
COMMENT ON COLUMN sa.table_svc_part_view.dom_serialno IS 'Domain s degree of uniqueness of part serial number; i.e., 0=no serial numbers, tracked only by quantity, 1=unique serial numbers across all part numbers, 2=unique serial numbers only within a part number, 3=serial numbers don"t need to be unique';
COMMENT ON COLUMN sa.table_svc_part_view.dom_uniquesn IS 'For any given site, serial number must be unique for all part numbers; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_svc_part_view.dom_catalogs IS 'Allow part to be included in BOMs; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_svc_part_view.dom_boms IS 'Allow part to be included in BOMs; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_svc_part_view.dom_at_site IS 'Part may be installed at either site or under another part.  0=no, 1=yes';
COMMENT ON COLUMN sa.table_svc_part_view.dom_at_parts IS 'Domain allows parts to be installed under other parts in the Site Configuration Manager; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_svc_part_view.dom_at_domain IS 'Bin must be included in another domain?  0=no, 1=yes';
COMMENT ON COLUMN sa.table_svc_part_view.dom_pt_used_bom IS 'During parts-used transactions, force part installation to conform to BOM; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_svc_part_view.dom_pt_used_dom IS 'Apply domain rules during parts-used transactions; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_svc_part_view.selected_prd IS 'Selected product';
COMMENT ON COLUMN sa.table_svc_part_view.instance_name IS 'Part name';
COMMENT ON COLUMN sa.table_svc_part_view.model_num IS 'Marketing model number of the part; within family and line';
COMMENT ON COLUMN sa.table_svc_part_view.warranty_date IS 'Part warranty end date';
COMMENT ON COLUMN sa.table_svc_part_view.dir_site_objid IS 'Site at which the part is installed. Derived from all_site_part2site. Not applicable to parts installed at more than one site';
COMMENT ON COLUMN sa.table_svc_part_view.sn_track IS 'Track part for serialization; i.e., 0=by quantity, 1=by serial number';
COMMENT ON COLUMN sa.table_svc_part_view.incl_domain IS 'Name of the part s included domain';
COMMENT ON COLUMN sa.table_svc_part_view.role_objid IS 'Internal record number of the sit_prt_role';
COMMENT ON COLUMN sa.table_svc_part_view.role_name IS 'Name of the role';
COMMENT ON COLUMN sa.table_svc_part_view.role_focus_type IS 'Object type ID of the role-player; i.e., 15=an installed part s role, 52=a site s role';
COMMENT ON COLUMN sa.table_svc_part_view.role_active IS 'Indicates whether the site part role is active; i.e., 0=inactive, 1=active';
COMMENT ON COLUMN sa.table_svc_part_view.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_svc_part_view.site_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_svc_part_view.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_svc_part_view.instance_id IS 'Installed part unique instnace id';
COMMENT ON COLUMN sa.table_svc_part_view.config_type IS 'Declares Configurator constraints for the part: i.e., 0=not to be configured, 1=configure as a product, 2=configure as an option, default=0';
COMMENT ON COLUMN sa.table_svc_part_view.invoice_no IS 'Installed part invoice number';
COMMENT ON COLUMN sa.table_svc_part_view.part_status IS 'Site Configuration installed part status. This is a user-defined popup with default name PART_STATUS';
COMMENT ON COLUMN sa.table_svc_part_view."FAMILY" IS 'Marketing product family the part belongs to. This is a user-defined popup with default name FAMILY and level name lev1';
COMMENT ON COLUMN sa.table_svc_part_view.part_type IS 'Assigns a part type (separate from a domain). This is from a user-defined popup with default name PART_TYPE';
COMMENT ON COLUMN sa.table_svc_part_view.struct_type IS 'The record type of the object; i.e., 0=service contract, 1=sales item, 2=eOrder, 3=shopping list';