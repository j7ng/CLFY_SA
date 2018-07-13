CREATE OR REPLACE FORCE VIEW sa.table_demand_vue (demand_hdr,demand_dtl,part_mod,part_number,s_part_number,mod_level,s_mod_level,detail_number,details_date,details_status,demand_qty,shipped_qty,movement_type) AS
select table_demand_dtl.demand_dtl2demand_hdr, table_demand_dtl.objid,
 table_mod_level.objid, table_part_num.part_number, table_part_num.S_part_number,
 table_mod_level.mod_level, table_mod_level.S_mod_level, table_demand_dtl.detail_number,
 table_demand_dtl.details_date, table_demand_dtl.details_status,
 table_demand_dtl.demand_qty, table_demand_dtl.shipped_qty,
 table_demand_dtl.movement_type
 from table_demand_dtl, table_mod_level, table_part_num
 where table_demand_dtl.demand_dtl2demand_hdr IS NOT NULL
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_mod_level.objid = table_demand_dtl.demand_dtl2part_info
 ;