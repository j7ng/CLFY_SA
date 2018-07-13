CREATE OR REPLACE FORCE VIEW sa.table_dem_part_v (objid,part_number,s_part_number,mod_level,s_mod_level,demand_qty,shipped_qty,details_date,detail_number,details_status) AS
select table_demand_dtl.objid, table_part_num.part_number, table_part_num.S_part_number,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_demand_dtl.demand_qty,
 table_demand_dtl.shipped_qty, table_demand_dtl.details_date,
 table_demand_dtl.detail_number, table_demand_dtl.details_status
 from table_demand_dtl, table_part_num, table_mod_level,
  table_demand_hdr
 where table_demand_hdr.objid = table_demand_dtl.demand_dtl2demand_hdr
 AND table_mod_level.objid = table_demand_dtl.demand_dtl2part_info
 AND table_part_num.objid = table_mod_level.part_info2part_num
 ;