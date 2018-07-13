CREATE OR REPLACE FORCE VIEW sa.table_list_drmatl (detail_objid,onsite_objid,objid,"LOCATION",failure_code,repair_code,standard_cost,billable,bill_to,wrk_center,notes,part_mod,part_number,s_part_number,mod_level,s_mod_level,technician,total_cost,disposition,transaction_id) AS
select table_onsite_log.detail_onsite2demand_dtl, table_onsite_log.objid,
 table_mtl_log.objid, table_mtl_log.ref_designator,
 table_mtl_log.failure_code, table_mtl_log.repair_code,
 table_mtl_log.standard_cost, table_mtl_log.billable,
 table_mtl_log.bill_to, table_mtl_log.wrk_center,
 table_mtl_log.notes, table_mod_level.objid,
 table_part_num.part_number, table_part_num.S_part_number, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_onsite_log.perf_by, table_onsite_log.total_mtl,
 table_mtl_log.disposition, table_mtl_log.transaction_id
 from table_onsite_log, table_mtl_log, table_mod_level,
  table_part_num
 where table_part_num.objid = table_mod_level.part_info2part_num
 AND table_mod_level.objid = table_mtl_log.mtl_log2mod_level
 AND table_onsite_log.objid = table_mtl_log.mtl_log2onsite_log
 AND table_onsite_log.detail_onsite2demand_dtl IS NOT NULL
 ;