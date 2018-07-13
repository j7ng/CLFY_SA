CREATE OR REPLACE FORCE VIEW sa.table_reconcilecnt (count_objid,count_name,count_status,objid,count_part_no,gen_date,count_date,recount_date,reconcile_date,tag_count,tag_recount,rev_perpetual,rev_counted,sn_perpetual,sn_counted,qty_good_perp,qty_good_count,qty_bad_perp,qty_bad_count,inv_loc_perp,inv_loc_count,inv_bin_perp,inv_bin_count,std_cost_perp,std_cost_count,ext_cost_perp,ext_cost_count,counted_by,s_counted_by,entered_by,s_entered_by,recounted_by,s_recounted_by,init_by,s_init_by,status,trial_by,s_trial_by,qty_good_final,qty_bad_final,std_cost_final,ext_cost_final,reinit_date,trial_date,bin_objid_perp,id_number,opened_ind,bin_type,mv_bin_perp,mv_objid_perp,count_id,comments,blank_tag,vi_trans_in,vi_trans_out,abc_cd_cls) AS
select table_count_setup.objid, table_count_setup.count_name,
 table_count_setup.status, table_inv_count.objid,
 table_inv_count.count_part_no, table_inv_count.gen_date,
 table_inv_count.count_date, table_inv_count.recount_date,
 table_inv_count.reconcile_date, table_inv_count.tag_count,
 table_inv_count.tag_recount, table_inv_count.rev_perpetual,
 table_inv_count.rev_counted, table_inv_count.sn_perpetual,
 table_inv_count.sn_counted, table_inv_count.qty_good_perp,
 table_inv_count.qty_good_count, table_inv_count.qty_bad_perp,
 table_inv_count.qty_bad_count, table_inv_count.inv_loc_perp,
 table_inv_count.inv_loc_count, table_inv_count.inv_bin_perp,
 table_inv_count.inv_bin_count, table_inv_count.std_cost_perp,
 table_inv_count.std_cost_count, table_inv_count.ext_cost_perp,
 table_inv_count.ext_cost_count, table_counted_by.login_name, table_counted_by.S_login_name,
 table_entered_by.login_name, table_entered_by.S_login_name, table_recounted_by.login_name, table_recounted_by.S_login_name,
 table_init_by.login_name, table_init_by.S_login_name, table_inv_count.status,
 table_trial_by.login_name, table_trial_by.S_login_name, table_inv_count.qty_good_final,
 table_inv_count.qty_bad_final, table_inv_count.std_cost_final,
 table_inv_count.ext_cost_final, table_inv_count.reinit_date,
 table_inv_count.trial_date, table_inv_count.bin_objid_perp,
 table_inv_count.id_number, table_inv_count.opened_ind,
 table_inv_count.bin_type, table_inv_count.mv_bin_perp,
 table_inv_count.mv_objid_perp, table_count_setup.count_id,
 table_inv_count.comments, table_inv_count.blank_tag,
 table_inv_count.vi_trans_in, table_inv_count.vi_trans_out,
 table_inv_count.abc_cd_cls
 from table_user table_counted_by, table_user table_entered_by, table_user table_init_by, table_user table_recounted_by, table_user table_trial_by, table_count_setup, table_inv_count
 where table_count_setup.objid = table_inv_count.count2count_setup
 AND table_init_by.objid = table_inv_count.init_by2user
 AND table_recounted_by.objid (+) = table_inv_count.recounted_by2user
 AND table_entered_by.objid (+) = table_inv_count.entered_by2user
 AND table_trial_by.objid (+) = table_inv_count.trial_by2user
 AND table_counted_by.objid (+) = table_inv_count.counted_by2user
 ;
COMMENT ON TABLE sa.table_reconcilecnt IS 'Used by the inventory Reconcile Count form (8412)';
COMMENT ON COLUMN sa.table_reconcilecnt.count_objid IS 'Count setup internal record number';
COMMENT ON COLUMN sa.table_reconcilecnt.count_name IS 'The name of this inventory reconciliation count profile';
COMMENT ON COLUMN sa.table_reconcilecnt.count_status IS 'The status of this reconciliation count profile';
COMMENT ON COLUMN sa.table_reconcilecnt.objid IS 'Inventory count internal record number';
COMMENT ON COLUMN sa.table_reconcilecnt.count_part_no IS 'Tag ID for the recount';
COMMENT ON COLUMN sa.table_reconcilecnt.gen_date IS 'The date this count was initialized';
COMMENT ON COLUMN sa.table_reconcilecnt.count_date IS 'The date this count was counted';
COMMENT ON COLUMN sa.table_reconcilecnt.recount_date IS 'The date this count was recounted';
COMMENT ON COLUMN sa.table_reconcilecnt.reconcile_date IS 'The date this count was reconciled';
COMMENT ON COLUMN sa.table_reconcilecnt.tag_count IS 'Tag ID for the initial count';
COMMENT ON COLUMN sa.table_reconcilecnt.tag_recount IS 'Tag ID for the recount';
COMMENT ON COLUMN sa.table_reconcilecnt.rev_perpetual IS 'The part revision number in the system';
COMMENT ON COLUMN sa.table_reconcilecnt.rev_counted IS 'The part revision number physically counted';
COMMENT ON COLUMN sa.table_reconcilecnt.sn_perpetual IS 'For parts tracked by serial number, the part serial number in the system';
COMMENT ON COLUMN sa.table_reconcilecnt.sn_counted IS 'For parts tracked by serial number, the part serial number physically counted';
COMMENT ON COLUMN sa.table_reconcilecnt.qty_good_perp IS 'For parts tracked by quantity, the good quantity currently in the system';
COMMENT ON COLUMN sa.table_reconcilecnt.qty_good_count IS 'For parts tracked by quantity, the good quantity physically counted';
COMMENT ON COLUMN sa.table_reconcilecnt.qty_bad_perp IS 'For parts tracked by quantity, the bad quantity currently in the system';
COMMENT ON COLUMN sa.table_reconcilecnt.qty_bad_count IS 'For parts tracked by quantity, the bad quantity physically counted';
COMMENT ON COLUMN sa.table_reconcilecnt.inv_loc_perp IS 'The inventory location currently in the system';
COMMENT ON COLUMN sa.table_reconcilecnt.inv_loc_count IS 'The inventory location the part was counted in';
COMMENT ON COLUMN sa.table_reconcilecnt.inv_bin_perp IS 'The inventory bin the part is in according to the system';
COMMENT ON COLUMN sa.table_reconcilecnt.inv_bin_count IS 'The inventory bin the part was counted in';
COMMENT ON COLUMN sa.table_reconcilecnt.std_cost_perp IS 'Active Std Cost of the mod_level from part_inst';
COMMENT ON COLUMN sa.table_reconcilecnt.std_cost_count IS 'Active Std Cost of the mod_level that was counted';
COMMENT ON COLUMN sa.table_reconcilecnt.ext_cost_perp IS 'Extended cost of the original quantity of parts';
COMMENT ON COLUMN sa.table_reconcilecnt.ext_cost_count IS 'Extended cost of the counted quantity of parts';
COMMENT ON COLUMN sa.table_reconcilecnt.counted_by IS 'Login name of the user who did the count';
COMMENT ON COLUMN sa.table_reconcilecnt.entered_by IS 'Login name of the user who entered the count in the system';
COMMENT ON COLUMN sa.table_reconcilecnt.recounted_by IS 'Login name of the user who did the recount';
COMMENT ON COLUMN sa.table_reconcilecnt.init_by IS 'Login name of the user who initialized the count';
COMMENT ON COLUMN sa.table_reconcilecnt.status IS 'Internal status of this count';
COMMENT ON COLUMN sa.table_reconcilecnt.trial_by IS 'Login name of the user who did the last trial reconciliation';
COMMENT ON COLUMN sa.table_reconcilecnt.qty_good_final IS 'The good quantity reconciled';
COMMENT ON COLUMN sa.table_reconcilecnt.qty_bad_final IS 'The bad quantity reconciled';
COMMENT ON COLUMN sa.table_reconcilecnt.std_cost_final IS 'Active Std Cost of the mod_level that was reconciled';
COMMENT ON COLUMN sa.table_reconcilecnt.ext_cost_final IS 'Extended Std Cost of the mod_level that was reconciled';
COMMENT ON COLUMN sa.table_reconcilecnt.reinit_date IS 'Date the inv_count was re-initialized';
COMMENT ON COLUMN sa.table_reconcilecnt.trial_date IS 'Last date the inv_count had trial reconciliation done';
COMMENT ON COLUMN sa.table_reconcilecnt.bin_objid_perp IS 'Objid of perpetual inv bin';
COMMENT ON COLUMN sa.table_reconcilecnt.id_number IS 'Unique bin number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_reconcilecnt.opened_ind IS 'Indicates whether the bin allows parts to be moved in/out or not; i.e, 0=no, it s sealed, 1=yes it is opened, default=1';
COMMENT ON COLUMN sa.table_reconcilecnt.bin_type IS 'User-defined type of bins; i.e., 0=fixed bin, 1=container, 2=pallet, default=0';
COMMENT ON COLUMN sa.table_reconcilecnt.mv_bin_perp IS 'The movable inventory bin the part is in according to the system';
COMMENT ON COLUMN sa.table_reconcilecnt.mv_objid_perp IS 'Objid of perpetual movable inv bin';
COMMENT ON COLUMN sa.table_reconcilecnt.count_id IS 'The unique identifier for this inventory reconciliation count profile';
COMMENT ON COLUMN sa.table_reconcilecnt.comments IS 'Notes about count transaction';
COMMENT ON COLUMN sa.table_reconcilecnt.blank_tag IS 'Identifies whether this tag was generated for a blank tag';
COMMENT ON COLUMN sa.table_reconcilecnt.vi_trans_in IS 'Virtual transactions INTO bin/container';
COMMENT ON COLUMN sa.table_reconcilecnt.vi_trans_out IS 'Virtual transactions OUT OF bin/container';
COMMENT ON COLUMN sa.table_reconcilecnt.abc_cd_cls IS 'ABC classification assigned to the part';