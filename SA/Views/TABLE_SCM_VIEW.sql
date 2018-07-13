CREATE OR REPLACE FORCE VIEW sa.table_scm_view (objid,partnum_objid,mod_objid,part_number,s_part_number,mod_level,s_mod_level,description,s_description,serial_no,s_serial_no,quantity,domain,s_domain,dom_serialno,dom_uniquesn,dom_catalogs,dom_boms,dom_at_site,dom_at_parts,dom_at_domain,dom_pt_used_bom,dom_pt_used_dom,level_to_part,selected_prd,level_to_bin,bin_objid,site_objid,inst_objid,instance_name,model_num,s_model_num,warranty_date,dir_site_objid,sn_track,incl_domain,dom_literature,dom_is_service,"FAMILY",line,part_type,invoice_no,ship_date,install_date,part_status,comments) AS
select table_site_part.objid, table_part_num.objid,
 table_mod_level.objid, table_part_num.part_number, table_part_num.S_part_number,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_part_num.description, table_part_num.S_description,
 table_site_part.serial_no, table_site_part.S_serial_no, table_site_part.quantity,
 table_part_num.domain, table_part_num.S_domain, table_part_num.dom_serialno,
 table_part_num.dom_uniquesn, table_part_num.dom_catalogs,
 table_part_num.dom_boms, table_part_num.dom_at_site,
 table_part_num.dom_at_parts, table_part_num.dom_at_domain,
 table_part_num.dom_pt_used_bom, table_part_num.dom_pt_used_dom,
 table_site_part.level_to_part, table_site_part.selected_prd,
 table_site_part.level_to_bin, table_site_part.bin_objid,
 table_site_part.site_objid, table_site_part.inst_objid,
 table_site_part.instance_name, table_part_num.model_num, table_part_num.S_model_num,
 table_site_part.warranty_date, table_site_part.dir_site_objid,
 table_part_num.sn_track, table_part_num.incl_domain,
 table_part_num.dom_literature, table_part_num.dom_is_service,
 table_part_num.family, table_part_num.line,
 table_part_num.part_type, table_site_part.invoice_no,
 table_site_part.ship_date, table_site_part.install_date,
 table_site_part.part_status, table_site_part.comments
 from table_site_part, table_part_num, table_mod_level
 where table_mod_level.objid = table_site_part.site_part2part_info
 AND table_part_num.objid = table_mod_level.part_info2part_num
 ;
COMMENT ON TABLE sa.table_scm_view IS 'Used by form Site Configuration Mgr (683), Reinstall Parts (687), Contract <ID> (731), Contract Details (732), Contract Service (777), New Parent Case (423), Incoming Call (8110), Part Used (690) and others';
COMMENT ON COLUMN sa.table_scm_view.objid IS 'Part internal record number';
COMMENT ON COLUMN sa.table_scm_view.partnum_objid IS 'Part num internal record number';
COMMENT ON COLUMN sa.table_scm_view.mod_objid IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_scm_view.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_scm_view.mod_level IS 'Revision level';
COMMENT ON COLUMN sa.table_scm_view.description IS 'Part maps to sales and mfg systems';
COMMENT ON COLUMN sa.table_scm_view.serial_no IS 'Installed part serial number';
COMMENT ON COLUMN sa.table_scm_view.quantity IS 'Installed part quantity; equal to 1 for serialized parts';
COMMENT ON COLUMN sa.table_scm_view.domain IS 'Name of the domain for the part num';
COMMENT ON COLUMN sa.table_scm_view.dom_serialno IS 'Domain s degree of uniqueness of part serial number; i.e., 0=no serial numbers, tracked only by quantity, 1=unique serial numbers across all part numbers, 2=unique serial numbers only within a part number, 3=serial numbers don"t need to be unique';
COMMENT ON COLUMN sa.table_scm_view.dom_uniquesn IS 'For any given site, serial number must be unique for all part numbers; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_scm_view.dom_catalogs IS 'Allow part to be included in BOMs; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_scm_view.dom_boms IS 'Allow part to be included in BOMs; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_scm_view.dom_at_site IS 'Part may be installed at either site or under another part.  0=no, 1=yes';
COMMENT ON COLUMN sa.table_scm_view.dom_at_parts IS 'Domain allows parts to be installed under other parts in the Site Configuration Manager; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_scm_view.dom_at_domain IS 'Bin must be included in another domain?  0=no, 1=yes';
COMMENT ON COLUMN sa.table_scm_view.dom_pt_used_bom IS 'During parts-used transactions, force part installation to conform to BOM; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_scm_view.dom_pt_used_dom IS 'Apply domain rules during parts-used transactions; i.e., 0=no, 1=yes';
COMMENT ON COLUMN sa.table_scm_view.level_to_part IS 'Relative level to a part in an installed part hierarchy';
COMMENT ON COLUMN sa.table_scm_view.selected_prd IS 'Selected product';
COMMENT ON COLUMN sa.table_scm_view.level_to_bin IS 'Relative level to a bin';
COMMENT ON COLUMN sa.table_scm_view.bin_objid IS 'Locally stored product bin ID';
COMMENT ON COLUMN sa.table_scm_view.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_scm_view.inst_objid IS 'Installed part internal record number';
COMMENT ON COLUMN sa.table_scm_view.instance_name IS 'Part name';
COMMENT ON COLUMN sa.table_scm_view.model_num IS 'Marketing model number of the part; within family and line';
COMMENT ON COLUMN sa.table_scm_view.warranty_date IS 'Part warranty end date';
COMMENT ON COLUMN sa.table_scm_view.dir_site_objid IS 'Site at which the part is installed. Derived from all_site_part2site. Not applicable to parts installed at more than one site';
COMMENT ON COLUMN sa.table_scm_view.sn_track IS 'Track part for serialization; i.e., 0=by quantity, 1=by serial number';
COMMENT ON COLUMN sa.table_scm_view.incl_domain IS 'Name of included domain';
COMMENT ON COLUMN sa.table_scm_view.dom_literature IS 'Indicates the part is a literature part; 0=no, 1=yes. Marketing collateral is an example of a literature part';
COMMENT ON COLUMN sa.table_scm_view.dom_is_service IS 'Indicates the part is a service part, if selected, sit_prt_role will be set when installed; i.e., 0=not a service, 1=a service';
COMMENT ON COLUMN sa.table_scm_view."FAMILY" IS 'Marketing product family the part belongs to. This is a user-defined popup with default name FAMILY and level name lev1';
COMMENT ON COLUMN sa.table_scm_view.line IS 'Marketing product line, within family, of the part. This is a user-defined popup with default name FAMILY and level name lev2';
COMMENT ON COLUMN sa.table_scm_view.part_type IS 'Assigns a part type (separate from a domain). This is from a user-defined popup with default name PART_TYPE';
COMMENT ON COLUMN sa.table_scm_view.invoice_no IS 'Installed part invoice number';
COMMENT ON COLUMN sa.table_scm_view.ship_date IS 'Installed part ship date';
COMMENT ON COLUMN sa.table_scm_view.install_date IS 'Part installation date';
COMMENT ON COLUMN sa.table_scm_view.part_status IS 'Site Configuration installed part status. This is a user-defined popup with default name PART_STATUS';
COMMENT ON COLUMN sa.table_scm_view.comments IS 'Installed part comment';