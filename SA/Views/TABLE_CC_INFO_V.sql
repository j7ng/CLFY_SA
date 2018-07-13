CREATE OR REPLACE FORCE VIEW sa.table_cc_info_v (objid,ct_name,s_ct_name,cc_status,cc_start_date,cc_end_date,ct_days,dflt_pct_ind,dflt_turn_ind,dflt_abc_ind,rollup_objid,rollup_name,s_rollup_name,biz_cal_objid) AS
select table_cycle_count.objid, table_cycle_count.ct_name, table_cycle_count.S_ct_name,
 table_cycle_count.status, table_cycle_count.ct_start_date,
 table_cycle_count.ct_end_date, table_cycle_count.ct_days,
 table_cycle_count.dflt_pct_ind, table_cycle_count.dflt_turn_ind,
 table_cycle_count.dflt_abc_ind, table_rollup.objid,
 table_rollup.name, table_rollup.S_name, table_cycle_count.ccount2biz_cal_hdr
 from table_cycle_count, table_rollup
 where table_rollup.objid = table_cycle_count.ccount2rollup
 ;
COMMENT ON TABLE sa.table_cc_info_v IS 'Displays Cycle Count Information. Used by Cycle Count Parameters form (8432)';
COMMENT ON COLUMN sa.table_cc_info_v.objid IS 'Internal objid';
COMMENT ON COLUMN sa.table_cc_info_v.ct_name IS 'Name of the cycle count';
COMMENT ON COLUMN sa.table_cc_info_v.cc_status IS 'Status of Cycle count';
COMMENT ON COLUMN sa.table_cc_info_v.cc_start_date IS 'Date the cycle count is effective';
COMMENT ON COLUMN sa.table_cc_info_v.cc_end_date IS 'Date Cycle count ends';
COMMENT ON COLUMN sa.table_cc_info_v.ct_days IS 'Counting days used in cycle count for a location rollup';
COMMENT ON COLUMN sa.table_cc_info_v.dflt_pct_ind IS 'Identifies if system-wide ABC code default will be used when determining stratification value parameters';
COMMENT ON COLUMN sa.table_cc_info_v.dflt_turn_ind IS 'Identifies if mod-level turn ratio will be used when determining stratification value parameters';
COMMENT ON COLUMN sa.table_cc_info_v.dflt_abc_ind IS 'Identifies if mod-level ABC Code default will be used when determining stratification value parameters';
COMMENT ON COLUMN sa.table_cc_info_v.rollup_objid IS 'Rollup internal record number';
COMMENT ON COLUMN sa.table_cc_info_v.rollup_name IS 'Name of the rollup';
COMMENT ON COLUMN sa.table_cc_info_v.biz_cal_objid IS 'Business Calendar internal record number';