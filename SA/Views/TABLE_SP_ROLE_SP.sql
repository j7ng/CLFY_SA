CREATE OR REPLACE FORCE VIEW sa.table_sp_role_sp (objid,pmlobjid,"NAME",s_name,"FAMILY",line,part_type,s_part_type,prd_inst_name,"ACTIVE",pmh_objid,serial_no,s_serial_no,invoice_no,part_number,s_part_number,mod_level,s_mod_level,site_name,s_site_name,sn_track,model_num,s_model_num,site_objid,site_id,city,s_city,"STATE",s_state,inst_objid,svc_part_objid,role_name,role_objid) AS
select table_connect_part.objid, table_mod_level.objid,
 table_part_num.description, table_part_num.S_description, table_part_num.family,
 table_part_num.line, table_part_num.domain, table_part_num.S_domain,
 table_connect_part.instance_name, table_mod_level.active,
 table_part_num.objid, table_connect_part.serial_no, table_connect_part.S_serial_no,
 table_connect_part.invoice_no, table_part_num.part_number, table_part_num.S_part_number,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_site.name, table_site.S_name,
 table_part_num.sn_track, table_part_num.model_num, table_part_num.S_model_num,
 table_site.objid, table_site.site_id,
 table_address.city, table_address.S_city, table_address.state, table_address.S_state,
 table_connect_part.inst_objid, table_prt_prt_role.role_for2site_part,
 table_prt_prt_role.role_name, table_prt_prt_role.objid
 from table_site_part table_connect_part, table_mod_level, table_part_num, table_site,
  table_address, table_prt_prt_role
 where table_mod_level.objid = table_connect_part.site_part2part_info
 AND table_prt_prt_role.role_for2site_part IS NOT NULL
 AND table_connect_part.objid = table_prt_prt_role.player2site_part
 AND table_address.objid = table_site.cust_primaddr2address
 AND table_site.objid = table_connect_part.all_site_part2site
 AND table_part_num.objid = table_mod_level.part_info2part_num
 ;
COMMENT ON TABLE sa.table_sp_role_sp IS 'Report for site_part role to site_part. Used by forms Service Part (624) and Service Details (626) and Related Hardware (627)';
COMMENT ON COLUMN sa.table_sp_role_sp.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_sp_role_sp.pmlobjid IS 'Internal record number';
COMMENT ON COLUMN sa.table_sp_role_sp."NAME" IS 'Maps to sales and manufacturing systems';
COMMENT ON COLUMN sa.table_sp_role_sp."FAMILY" IS 'Marketing product family the user belongs to; new user-defined pop up replaces relation to gbst_elm';
COMMENT ON COLUMN sa.table_sp_role_sp.line IS 'Marketing product line, within family, of the part; new user-defined pop up replaces relation to gbst_elm';
COMMENT ON COLUMN sa.table_sp_role_sp.part_type IS 'User-defined type of part';
COMMENT ON COLUMN sa.table_sp_role_sp.prd_inst_name IS 'Part name';
COMMENT ON COLUMN sa.table_sp_role_sp."ACTIVE" IS 'Active/inactive/obsolete';
COMMENT ON COLUMN sa.table_sp_role_sp.pmh_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_sp_role_sp.serial_no IS 'Part serial number';
COMMENT ON COLUMN sa.table_sp_role_sp.invoice_no IS 'Part invoice number';
COMMENT ON COLUMN sa.table_sp_role_sp.part_number IS 'Part number/name';
COMMENT ON COLUMN sa.table_sp_role_sp.mod_level IS 'Revision level';
COMMENT ON COLUMN sa.table_sp_role_sp.site_name IS 'Site name';
COMMENT ON COLUMN sa.table_sp_role_sp.sn_track IS 'Track part for serialization; i.e., 0=by quantity, 1=by serial number';
COMMENT ON COLUMN sa.table_sp_role_sp.model_num IS 'Marketing model number of the part; within family and line';
COMMENT ON COLUMN sa.table_sp_role_sp.site_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_sp_role_sp.site_id IS 'Site ID number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_sp_role_sp.city IS 'The city for the specified address';
COMMENT ON COLUMN sa.table_sp_role_sp."STATE" IS 'The state for the specified address';
COMMENT ON COLUMN sa.table_sp_role_sp.inst_objid IS 'Objid of parent installed part in the installed part s BOM. Zero if the part is not a child part';
COMMENT ON COLUMN sa.table_sp_role_sp.svc_part_objid IS 'Objid of service part serving this site_part';
COMMENT ON COLUMN sa.table_sp_role_sp.role_name IS 'Servicing role';
COMMENT ON COLUMN sa.table_sp_role_sp.role_objid IS 'Servicing role objid';