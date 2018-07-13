CREATE OR REPLACE FORCE VIEW sa.table_demand_site (demand_hdr,demand_dtl,part_mod,part_number,s_part_number,mod_level,s_mod_level,detail_number,details_date,details_status,demand_qty,shipped_qty,movement_type,site_objid,part_domain,s_part_domain,status,s_status) AS
select table_demand_hdr.objid, table_demand_dtl.objid,
 table_mod_level.objid, table_part_num.part_number, table_part_num.S_part_number,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_demand_dtl.detail_number,
 table_demand_dtl.details_date, table_demand_dtl.details_status,
 table_demand_dtl.demand_qty, table_demand_dtl.shipped_qty,
 table_demand_dtl.movement_type, table_demand_hdr.open_reqst2site,
 table_part_num.domain, table_part_num.S_domain, table_gse_status.title, table_gse_status.S_title
 from table_gbst_elm table_gse_status, table_demand_hdr, table_demand_dtl, table_mod_level,
  table_part_num
 where table_gse_status.objid = table_demand_dtl.dmnd_dtl_sts2gbst_elm
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_demand_hdr.open_reqst2site IS NOT NULL
 AND table_demand_hdr.objid = table_demand_dtl.demand_dtl2demand_hdr
 AND table_mod_level.objid = table_demand_dtl.demand_dtl2part_info
 ;