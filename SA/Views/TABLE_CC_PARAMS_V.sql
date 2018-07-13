CREATE OR REPLACE FORCE VIEW sa.table_cc_params_v (objid,abc_cd_cls,abc_cd_desc,s_abc_cd_desc,abc_cd_rank,abc_pct,frequency,pct_tolerance,cost_tolerance,ct_days,ct_per_day,last_ct_per_day,val_from,val_to,val_freq,dflt_pct_ind,dflt_turn_ind,dflt_abc_ind,cc_objid,cc_name,s_cc_name,rollup_objid,rollup_name,s_rollup_name,num_cc_parts) AS
select table_cycle_setup.objid, table_cycle_setup.abc_cd_cls,
 table_cycle_setup.abc_cd_desc, table_cycle_setup.S_abc_cd_desc, table_cycle_setup.abc_cd_rank,
 table_cycle_setup.abc_pct, table_cycle_setup.frequency,
 table_cycle_setup.pct_tolerance, table_cycle_setup.cost_tolerance,
 table_cycle_count.ct_days, table_cycle_setup.ct_per_day,
 table_cycle_setup.last_ct_per_day, table_cycle_setup.val_from,
 table_cycle_setup.val_to, table_cycle_setup.val_freq,
 table_cycle_count.dflt_pct_ind, table_cycle_count.dflt_turn_ind,
 table_cycle_count.dflt_abc_ind, table_cycle_count.objid,
 table_cycle_count.ct_name, table_cycle_count.S_ct_name, table_rollup.objid,
 table_rollup.name, table_rollup.S_name, table_cycle_setup.num_cc_parts
 from table_cycle_setup, table_cycle_count, table_rollup
 where table_cycle_count.objid = table_cycle_setup.csetup2cycle_count
 AND table_rollup.objid = table_cycle_count.ccount2rollup
 ;
COMMENT ON TABLE sa.table_cc_params_v IS 'Displays Cycle Count Parameters. Used by Cycle Count Parameters form (8432)';
COMMENT ON COLUMN sa.table_cc_params_v.objid IS 'Internal objid';
COMMENT ON COLUMN sa.table_cc_params_v.abc_cd_cls IS 'ABC Code Classification';
COMMENT ON COLUMN sa.table_cc_params_v.abc_cd_desc IS 'Description for this ABC Code Classification';
COMMENT ON COLUMN sa.table_cc_params_v.abc_cd_rank IS 'Valuation ranking of ABC Code class';
COMMENT ON COLUMN sa.table_cc_params_v.abc_pct IS 'ABC Code percentage of parts';
COMMENT ON COLUMN sa.table_cc_params_v.frequency IS 'Cycle count frequency parameter for counts per year';
COMMENT ON COLUMN sa.table_cc_params_v.pct_tolerance IS 'Cycle count accuracy tolerance based on percent';
COMMENT ON COLUMN sa.table_cc_params_v.cost_tolerance IS 'Cycle count accuracy tolerance based on cost';
COMMENT ON COLUMN sa.table_cc_params_v.ct_days IS 'Counting days used in cycle count for a location rollup';
COMMENT ON COLUMN sa.table_cc_params_v.ct_per_day IS 'Calculated ABC Code counts per day for a location rollup';
COMMENT ON COLUMN sa.table_cc_params_v.last_ct_per_day IS 'Calculated ABC Code counts per day for a location rollup';
COMMENT ON COLUMN sa.table_cc_params_v.val_from IS 'Low value of monetary units for stratification value';
COMMENT ON COLUMN sa.table_cc_params_v.val_to IS 'High value of monetary units for stratification value';
COMMENT ON COLUMN sa.table_cc_params_v.val_freq IS 'Valuation frequency for ABC Classification';
COMMENT ON COLUMN sa.table_cc_params_v.dflt_pct_ind IS 'Identifies if system-wide ABC code default will be used when determining stratification value parameters';
COMMENT ON COLUMN sa.table_cc_params_v.dflt_turn_ind IS 'Identifies if mod-level turn ratio will be used when determining stratification value parameters';
COMMENT ON COLUMN sa.table_cc_params_v.dflt_abc_ind IS 'Identifies if mod-level ABC Code default will be used when determining stratification value parameters';
COMMENT ON COLUMN sa.table_cc_params_v.cc_objid IS 'Cycle count internal record number';
COMMENT ON COLUMN sa.table_cc_params_v.cc_name IS 'Name of the rollup';
COMMENT ON COLUMN sa.table_cc_params_v.rollup_objid IS 'Rollup internal record number';
COMMENT ON COLUMN sa.table_cc_params_v.rollup_name IS 'Name of the rollup';
COMMENT ON COLUMN sa.table_cc_params_v.num_cc_parts IS 'Number of Cycle Count parts assigned to the code class';