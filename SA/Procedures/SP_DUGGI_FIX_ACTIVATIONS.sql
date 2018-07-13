CREATE OR REPLACE PROCEDURE sa."SP_DUGGI_FIX_ACTIVATIONS"
AS
   CURSOR c_dup
   IS
      SELECT   /*+ FULL(SP) */
               x_service_id
          FROM table_site_part sp
         WHERE 1 = 1 AND part_status = 'Active'
      GROUP BY x_service_id
        HAVING COUNT (*) > 1;

/*
      select x_service_id
      from table_site_part
      where 1=1
      and part_status = 'Active'
      group by x_service_id
      having count(1) > 1;
*/

   CURSOR c_sp (c_esn VARCHAR2)
   IS
      SELECT   *
          FROM table_site_part
         WHERE 1 = 1 AND x_service_id = c_esn
               AND part_status || '' = 'Active'
      ORDER BY install_date;

   CURSOR c_ct_act (c_esn VARCHAR2, c_site_objid NUMBER)
   IS
      SELECT   *
          FROM table_x_call_trans
         WHERE 1 = 1
           AND call_trans2site_part = c_site_objid
           AND x_service_id = c_esn
           AND x_result = 'Completed'
           AND x_action_type IN ('1', '3')
      ORDER BY x_transact_date;

   CURSOR c_min_pi (c_min VARCHAR2)
   IS
      SELECT *
        FROM table_part_inst
       WHERE part_serial_no = c_min;

   l_upd     NUMBER := 0;
   l_error   NUMBER := 0;
BEGIN
   COMMIT;

   EXECUTE IMMEDIATE 'alter session set workarea_size_policy = manual';

   EXECUTE IMMEDIATE 'alter session set sort_area_size = 40000000';

   EXECUTE IMMEDIATE 'alter session set sort_area_retained_size = 40000000';

   EXECUTE IMMEDIATE 'alter session set db_file_multiblock_read_count = 128';

   FOR c_dup_rec IN c_dup
   LOOP
      BEGIN
         FOR c_sp_rec IN c_sp (c_dup_rec.x_service_id)
         LOOP
            -- Set site part to 'Inactive'
            UPDATE table_site_part sp
               SET part_status = 'Inactive',
                   x_deact_reason = 'WN-CUST REQD CHG MIN',
                   service_end_dt = SYSDATE
             WHERE sp.objid = c_sp_rec.objid;

            FOR c_min_pi_rec IN c_min_pi (c_sp_rec.x_min)
            LOOP
               -- update min to 'USED'
               UPDATE table_part_inst
                  SET x_part_inst_status = '12',
                      status2x_code_table = 959,
                      part_to_esn2part_inst = NULL
                WHERE part_serial_no = c_min_pi_rec.part_serial_no;

               INSERT INTO table_x_pi_hist
                           (objid,
                            status_hist2x_code_table, x_change_date,
                            x_change_reason,
                            x_cool_end_date,
                            x_creation_date,
                            x_deactivation_flag,
                            x_domain, x_ext,
                            x_insert_date, x_npa,
                            x_nxx, x_old_ext,
                            x_old_npa, x_old_nxx,
                            x_part_bin,
                            x_part_inst_status,
                            x_part_mod,
                            x_part_serial_no,
                            x_part_status,
                            x_pi_hist2carrier_mkt,
                            x_pi_hist2inv_bin,
                            x_pi_hist2part_inst,
                            x_pi_hist2part_mod,
                            x_pi_hist2user,
                            x_pi_hist2x_new_pers,
                            x_pi_hist2x_pers,
                            x_po_num,
                            x_reactivation_flag,
                            x_red_code, x_sequence,
                            x_warr_end_date, dev,
                            fulfill_hist2demand_dtl,
                            part_to_esn_hist2part_inst,
                            x_bad_res_qty,
                            x_date_in_serv,
                            x_good_res_qty,
                            x_last_cycle_ct,
                            x_last_mod_time,
                            x_last_pi_date,
                            x_last_trans_time,
                            x_next_cycle_ct,
                            x_order_number,
                            x_part_bad_qty,
                            x_part_good_qty,
                            x_pi_tag_no,
                            x_pick_request,
                            x_repair_date,
                            x_transaction_id,
                            x_pi_hist2site_part,
                            x_msid,
                            x_pi_hist2contact
                           )
                    VALUES (sa.seq ('X_PI_HIST'),
                            c_min_pi_rec.status2x_code_table, SYSDATE,
                            'WN-CUST REQD CHG MIN',
                            c_min_pi_rec.x_cool_end_date,
                            c_min_pi_rec.x_creation_date,
                            c_min_pi_rec.x_deactivation_flag,
                            c_min_pi_rec.x_domain, c_min_pi_rec.x_ext,
                            c_min_pi_rec.x_insert_date, c_min_pi_rec.x_npa,
                            c_min_pi_rec.x_nxx, c_min_pi_rec.x_ext,
                            c_min_pi_rec.x_npa, c_min_pi_rec.x_nxx,
                            c_min_pi_rec.part_bin,
                            c_min_pi_rec.x_part_inst_status,
                            c_min_pi_rec.part_mod,
                            c_min_pi_rec.part_serial_no,
                            c_min_pi_rec.part_status,
                            c_min_pi_rec.part_inst2carrier_mkt,
                            c_min_pi_rec.part_inst2inv_bin,
                            c_min_pi_rec.objid,
                            c_min_pi_rec.n_part_inst2part_mod,
                            c_min_pi_rec.created_by2user,
                            c_min_pi_rec.part_inst2x_new_pers,
                            c_min_pi_rec.part_inst2x_pers,
                            c_min_pi_rec.x_po_num,
                            c_min_pi_rec.x_reactivation_flag,
                            c_min_pi_rec.x_red_code, c_min_pi_rec.x_sequence,
                            c_min_pi_rec.warr_end_date, c_min_pi_rec.dev,
                            c_min_pi_rec.fulfill2demand_dtl,
                            c_min_pi_rec.part_to_esn2part_inst,
                            c_min_pi_rec.bad_res_qty,
                            c_min_pi_rec.date_in_serv,
                            c_min_pi_rec.good_res_qty,
                            c_min_pi_rec.last_cycle_ct,
                            c_min_pi_rec.last_mod_time,
                            c_min_pi_rec.last_pi_date,
                            c_min_pi_rec.last_trans_time,
                            c_min_pi_rec.next_cycle_ct,
                            c_min_pi_rec.x_order_number,
                            c_min_pi_rec.part_bad_qty,
                            c_min_pi_rec.part_good_qty,
                            c_min_pi_rec.pi_tag_no,
                            c_min_pi_rec.pick_request,
                            c_min_pi_rec.repair_date,
                            c_min_pi_rec.transaction_id,
                            c_min_pi_rec.x_part_inst2site_part,
                            c_min_pi_rec.x_msid,
                            c_min_pi_rec.x_part_inst2contact
                           );
            END LOOP;

            FOR c_ct_act_rec IN c_ct_act (c_sp_rec.x_service_id,
                                          c_sp_rec.objid
                                         )
            LOOP
               INSERT INTO table_x_call_trans
                           (objid,
                            call_trans2site_part, x_action_type,
                            x_call_trans2carrier,
                            x_call_trans2dealer, x_call_trans2user,
                            x_line_status, x_min,
                            x_service_id, x_sourcesystem,
                            x_transact_date, x_total_units, x_action_text,
                            x_reason, x_result, x_sub_sourcesystem
                           )
                    VALUES (sa.seq ('X_CALL_TRANS'),
                            c_ct_act_rec.call_trans2site_part, '2',
                            c_ct_act_rec.x_call_trans2carrier,
                            c_ct_act_rec.x_call_trans2dealer, 268435556,
                            c_ct_act_rec.x_line_status, c_ct_act_rec.x_min,
                            c_ct_act_rec.x_service_id, 'ONE_TIME_DEACT',
                            SYSDATE, 0, 'DEACTIVATION',
                            'WN-CUST REQD CHG MIN', 'Completed', '202'
                           );
            END LOOP;

            EXIT;
         END LOOP;

         l_upd := l_upd + 1;

         IF MOD (l_upd, 100) = 0
         THEN
            COMMIT;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_error := l_error + 1;
      END;

      <<next_rec>>
      NULL;
   END LOOP;

   COMMIT;
   DBMS_OUTPUT.put_line ('Total update: ' || l_upd);
   DBMS_OUTPUT.put_line ('Total error: ' || l_error);
END sp_duggi_fix_activations;
/