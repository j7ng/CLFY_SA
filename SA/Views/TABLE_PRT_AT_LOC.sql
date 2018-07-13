CREATE OR REPLACE FORCE VIEW sa.table_prt_at_loc (objid,locatn_objid,part_num_objid,part_mod_objid,bin_objid,"LOCATION",description,part_number,s_part_number,part_descr,s_part_descr,authorized,status,opn_ord_qty,allocate_exch,allocate_repln,allocate_other,part_rol,part_roq,part_maximum,part_minimum,hard_salelimit,hard_exchlimit,hard_repllimit,binname,part_num,s_part_num,repl_queue,mod_level,s_mod_level,primary_ind,turn_ratio,abc_cd_cls,part_good_qoh,part_bad_qoh,"ACTIVE",active_cc_ind) AS
select table_part_auth.objid, table_inv_locatn.objid,
 table_part_num.objid, table_mod_level.objid,
 table_inv_bin.objid, table_inv_locatn.location_name,
 table_inv_locatn.location_descr, table_part_num.part_number, table_part_num.S_part_number,
 table_part_num.description, table_part_num.S_description, table_inv_locatn.trans_auth,
 table_mod_level.active, table_part_auth.opn_ord_qty,
 table_part_auth.allocate_exch, table_part_auth.allocate_repln,
 table_part_auth.allocate_other, table_part_auth.part_rol,
 table_part_auth.part_roq, table_part_auth.part_maximum,
 table_part_auth.part_minimum, table_part_auth.hard_salelimit,
 table_part_auth.hard_exchlimit, table_part_auth.hard_repllimit,
 table_inv_bin.bin_name, table_part_num.description, table_part_num.S_description,
 table_part_auth.repl_queue, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_part_auth.primary_ind, table_part_auth.turn_ratio,
 table_part_auth.abc_cd_cls, table_part_auth.part_good_qoh,
 table_part_auth.part_bad_qoh, table_part_auth.active,
 table_part_auth.active_cc_ind
 from table_part_auth, table_inv_locatn, table_part_num,
  table_mod_level, table_inv_bin
 where table_inv_bin.objid = table_part_auth.part_auth2inv_bin
 AND table_inv_locatn.objid = table_inv_bin.inv_bin2inv_locatn
 AND table_mod_level.objid = table_part_auth.n_auth_parts2part_mod
 AND table_part_num.objid = table_mod_level.part_info2part_num
 ;