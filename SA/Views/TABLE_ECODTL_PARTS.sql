CREATE OR REPLACE FORCE VIEW sa.table_ecodtl_parts (objid,hdr_objid,detail_type,"REQUIRED",status,labor_type,"TIME","LOCATION",description,part_mod,part_number,s_part_number,mod_level,s_mod_level,part_desc,s_part_desc) AS
select table_eco_dtl.objid, table_eco_dtl.eco_details2eco_hdr,
 table_eco_dtl.detail_type, table_eco_dtl.required,
 table_eco_dtl.status, table_eco_dtl.labor_type,
 table_eco_dtl.time, table_eco_dtl.location,
 table_eco_dtl.description, table_mod_level.objid,
 table_part_num.part_number, table_part_num.S_part_number, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_part_num.description, table_part_num.S_description
 from table_eco_dtl, table_mod_level, table_part_num
 where table_eco_dtl.eco_details2eco_hdr IS NOT NULL
 AND table_mod_level.objid = table_eco_dtl.eco_dtl2mod_level
 AND table_part_num.objid = table_mod_level.part_info2part_num
 ;