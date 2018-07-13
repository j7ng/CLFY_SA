CREATE OR REPLACE FORCE VIEW sa.table_addrsitepmhpml (objid,pmlobjid,"NAME",s_name,"FAMILY",line,part_type,s_part_type,prd_inst_name,"ACTIVE",pmh_objid,serial_no,s_serial_no,invoice_no,part_number,s_part_number,mod_level,s_mod_level,site_name,s_site_name,sn_track,model_num,s_model_num,site_objid,site_id,city,s_city,"STATE",s_state,inst_objid) AS
select table_site_part.objid, table_mod_level.objid,
 table_part_num.description, table_part_num.S_description, table_part_num.family,
 table_part_num.line, table_part_num.domain, table_part_num.S_domain,
 table_site_part.instance_name, table_mod_level.active,
 table_part_num.objid, table_site_part.serial_no, table_site_part.S_serial_no,
 table_site_part.invoice_no, table_part_num.part_number, table_part_num.S_part_number,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_site.name, table_site.S_name,
 table_part_num.sn_track, table_part_num.model_num, table_part_num.S_model_num,
 table_site.objid, table_site.site_id,
 table_address.city, table_address.S_city, table_address.state, table_address.S_state,
 table_site_part.inst_objid
 from table_site_part, table_mod_level, table_part_num,
  table_site, table_address
 where table_mod_level.objid = table_site_part.site_part2part_info
 AND table_address.objid = table_site.cust_primaddr2address
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_site.objid = table_site_part.all_site_part2site
 ;
COMMENT ON TABLE sa.table_addrsitepmhpml IS 'Report for which the parameter set is used. Used by form Select [Installed Parts (689), Contact Quoted (9661), Contact Installed (9662), Contact (9663), Contact for Campaign (9664), Contact by Industry (9667)';
COMMENT ON COLUMN sa.table_addrsitepmhpml.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_addrsitepmhpml.pmlobjid IS 'Internal record number';
COMMENT ON COLUMN sa.table_addrsitepmhpml."NAME" IS 'Maps to sales and manufacturing systems';
COMMENT ON COLUMN sa.table_addrsitepmhpml."FAMILY" IS 'Marketing product family the user belongs to; new user-defined pop up replaces relation to gbst_elm';
COMMENT ON COLUMN sa.table_addrsitepmhpml.line IS 'Marketing product line, within family, of the part; new user-defined pop up replaces relation to gbst_elm';
COMMENT ON COLUMN sa.table_addrsitepmhpml.part_type IS 'User-defined type of part';
COMMENT ON COLUMN sa.table_addrsitepmhpml.prd_inst_name IS 'Part name';
COMMENT ON COLUMN sa.table_addrsitepmhpml."ACTIVE" IS 'Active/inactive/obsolete';
COMMENT ON COLUMN sa.table_addrsitepmhpml.pmh_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_addrsitepmhpml.serial_no IS 'Part serial number';
COMMENT ON COLUMN sa.table_addrsitepmhpml.invoice_no IS 'Part invoice number';
COMMENT ON COLUMN sa.table_addrsitepmhpml.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_addrsitepmhpml.mod_level IS 'Revision level';
COMMENT ON COLUMN sa.table_addrsitepmhpml.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_addrsitepmhpml.sn_track IS 'Track part for serialization; i.e., 0=by quantity, 1=by serial number';
COMMENT ON COLUMN sa.table_addrsitepmhpml.model_num IS 'Marketing model number of the part; within family and line';
COMMENT ON COLUMN sa.table_addrsitepmhpml.site_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_addrsitepmhpml.site_id IS 'Site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_addrsitepmhpml.city IS 'The city for the specified address';
COMMENT ON COLUMN sa.table_addrsitepmhpml."STATE" IS 'The state for the specified address';
COMMENT ON COLUMN sa.table_addrsitepmhpml.inst_objid IS 'Objid of parent installed part in the installed part s BOM. Zero if the part is not a child part';