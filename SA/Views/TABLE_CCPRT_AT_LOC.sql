CREATE OR REPLACE FORCE VIEW sa.table_ccprt_at_loc (objid,locatn_objid,part_num_objid,part_mod_objid,bin_objid,"LOCATION",description,part_number,s_part_number,part_descr,s_part_descr,active_cc_ind,abc_cd_cls,turn_ratio,last_cycle_ct,average_usage,last_calc_val,opn_ord_qty,binname,mod_level,s_mod_level,cc_objid,cc_name,s_cc_name,part_good_qoh,part_bad_qoh,sn_track,times_cc_ct) AS
select table_part_auth.objid, table_inv_locatn.objid,
 table_part_num.objid, table_mod_level.objid,
 table_inv_bin.objid, table_inv_locatn.location_name,
 table_inv_locatn.location_descr, table_part_num.part_number, table_part_num.S_part_number,
 table_part_num.description, table_part_num.S_description, table_part_auth.active_cc_ind,
 table_part_auth.abc_cd_cls, table_part_auth.turn_ratio,
 table_part_auth.last_cycle_ct, table_part_auth.average_usage,
 table_part_auth.last_calc_val, table_part_auth.opn_ord_qty,
 table_inv_bin.bin_name, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_cycle_count.objid, table_cycle_count.ct_name, table_cycle_count.S_ct_name,
 table_part_auth.part_good_qoh, table_part_auth.part_bad_qoh,
 table_part_num.sn_track, table_part_auth.times_cc_ct
 from table_part_auth, table_inv_locatn, table_part_num,
  table_mod_level, table_inv_bin, table_cycle_count
 where table_mod_level.objid = table_part_auth.n_auth_parts2part_mod
 AND table_part_num.objid = table_mod_level.part_info2part_num
 AND table_cycle_count.objid = table_part_auth.part_auth2cycle_count
 AND table_inv_locatn.objid = table_inv_bin.inv_bin2inv_locatn
 AND table_inv_bin.objid = table_part_auth.part_auth2inv_bin
 ;