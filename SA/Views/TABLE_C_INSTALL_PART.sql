CREATE OR REPLACE FORCE VIEW sa.table_c_install_part (site_part_objid,site_objid,site_id,site_name,s_site_name,serial_no,s_serial_no,warranty_end,part_num_objid,part_number,s_part_number,part_desc,s_part_desc,part_domain,s_part_domain,model_num,s_model_num,mod_level_objid,mod_level,s_mod_level,"ACTIVE",part_line,part_family,part_type,part_status,p_standalone,p_as_parent,p_as_child,install_date,is_sppt_prog,site_part_qty,mod_eff_dt,mod_exp_dt,sn_track) AS
select table_site_part.objid, table_site.objid,
 table_site.site_id, table_site.name, table_site.S_name,
 table_site_part.serial_no, table_site_part.S_serial_no, table_site_part.warranty_date,
 table_part_num.objid, table_part_num.part_number, table_part_num.S_part_number,
 table_part_num.description, table_part_num.S_description, table_part_num.domain, table_part_num.S_domain,
 table_part_num.model_num, table_part_num.S_model_num, table_mod_level.objid,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_mod_level.active,
 table_part_num.line, table_part_num.family,
 table_part_num.part_type, table_part_num.active,
 table_part_num.p_standalone, table_part_num.p_as_parent,
 table_part_num.p_as_child, table_site_part.install_date,
 table_part_num.is_sppt_prog, table_site_part.quantity,
 table_mod_level.eff_date, table_mod_level.end_date,
 table_part_num.sn_track
 from table_site_part, table_site, table_part_num,
  table_mod_level
 where table_part_num.objid = table_mod_level.part_info2part_num
 AND table_mod_level.objid = table_site_part.site_part2part_info
 AND table_site.objid = table_site_part.all_site_part2site
 ;
COMMENT ON TABLE sa.table_c_install_part IS 'Used in service pricing by forms Select Installed Part (9145), Select Part Number (9146), Select Part Number (SFA version) (9669) and Account (11650)';
COMMENT ON COLUMN sa.table_c_install_part.site_part_objid IS 'Installed part internal record nubmer';
COMMENT ON COLUMN sa.table_c_install_part.site_objid IS 'Site internal record number';
COMMENT ON COLUMN sa.table_c_install_part.site_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_c_install_part.site_name IS 'site name';
COMMENT ON COLUMN sa.table_c_install_part.serial_no IS 'Installed part serial number';
COMMENT ON COLUMN sa.table_c_install_part.warranty_end IS 'Installed part warranty ending date';
COMMENT ON COLUMN sa.table_c_install_part.part_num_objid IS 'Generic part internal record number';
COMMENT ON COLUMN sa.table_c_install_part.part_number IS 'Generic part number/name';
COMMENT ON COLUMN sa.table_c_install_part.part_desc IS 'Generic part description';
COMMENT ON COLUMN sa.table_c_install_part.part_domain IS 'Name of the domain for the part num. See object prt_domain';
COMMENT ON COLUMN sa.table_c_install_part.model_num IS 'Marketing model number of the part; within family and line';
COMMENT ON COLUMN sa.table_c_install_part.mod_level_objid IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_c_install_part.mod_level IS 'Name of the part revision';
COMMENT ON COLUMN sa.table_c_install_part."ACTIVE" IS 'Part revision status; i.e., Active/inactive/obsolete';
COMMENT ON COLUMN sa.table_c_install_part.part_line IS 'Marketing product line, within family, of the part; new user-defined pop up replaces relation to gbst_elm';
COMMENT ON COLUMN sa.table_c_install_part.part_family IS 'Marketing product family the part belongs to; new user-defined pop up replaces relation to gbst_elm';
COMMENT ON COLUMN sa.table_c_install_part.part_type IS 'User-defined pop up to denote a part type separate from the domain';
COMMENT ON COLUMN sa.table_c_install_part.part_status IS 'Generic part status; i.e., active/inactive/obsolete';
COMMENT ON COLUMN sa.table_c_install_part.p_standalone IS 'Indicates whether the part MAY receive standalone pricing;  i.e. 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_c_install_part.p_as_parent IS 'Indicates whether the part MAY be priced with options under it;  i.e. 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_c_install_part.p_as_child IS 'Indicates whether the part MAY be priced as an option;  i.e. 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_c_install_part.install_date IS 'Part installation date';
COMMENT ON COLUMN sa.table_c_install_part.is_sppt_prog IS 'Indicates application category of the part: i.e., 0=physical part, 1=service part, 2=product literature';
COMMENT ON COLUMN sa.table_c_install_part.site_part_qty IS 'Installed part quantity; equal to 1 for serialized parts';
COMMENT ON COLUMN sa.table_c_install_part.mod_eff_dt IS 'The date the support program version becomes effective';
COMMENT ON COLUMN sa.table_c_install_part.mod_exp_dt IS 'The date the support program version expires';
COMMENT ON COLUMN sa.table_c_install_part.sn_track IS 'Track part for serialization; i.e., 0=by quantity, 1=by serial number';