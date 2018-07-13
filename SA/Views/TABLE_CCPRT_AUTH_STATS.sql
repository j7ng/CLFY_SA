CREATE OR REPLACE FORCE VIEW sa.table_ccprt_auth_stats (objid,invest_val,as_of_date,auth_objid,locatn_objid,part_num_objid,part_mod_objid,bin_objid,"LOCATION",part_number,s_part_number,binname,mod_level,s_mod_level,cc_objid,cc_name,s_cc_name) AS
select table_auth_stats.objid, table_auth_stats.invest_val,
 table_auth_stats.as_of_date, table_part_auth.objid,
 table_inv_locatn.objid, table_part_num.objid,
 table_mod_level.objid, table_inv_bin.objid,
 table_inv_locatn.location_name, table_part_num.part_number, table_part_num.S_part_number,
 table_inv_bin.bin_name, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_cycle_count.objid, table_cycle_count.ct_name, table_cycle_count.S_ct_name
 from table_auth_stats, table_part_auth, table_inv_locatn,
  table_part_num, table_mod_level, table_inv_bin,
  table_cycle_count
 where table_part_num.objid = table_mod_level.part_info2part_num
 AND table_inv_bin.objid = table_part_auth.part_auth2inv_bin
 AND table_cycle_count.objid = table_part_auth.part_auth2cycle_count
 AND table_inv_locatn.objid = table_inv_bin.inv_bin2inv_locatn
 AND table_mod_level.objid = table_part_auth.n_auth_parts2part_mod
 AND table_part_auth.objid = table_auth_stats.auth_stats2part_auth
 ;