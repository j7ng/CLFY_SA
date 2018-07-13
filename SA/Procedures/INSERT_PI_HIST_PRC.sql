CREATE OR REPLACE PROCEDURE sa."INSERT_PI_HIST_PRC" (
   ip_user_objid   IN       NUMBER,
   ip_min          IN       VARCHAR2,
   ip_old_npa      IN       VARCHAR2,
   ip_old_nxx      IN       VARCHAR2,
   ip_old_ext      IN       VARCHAR2,
   ip_reason       IN       VARCHAR2,
   ip_out_val      OUT      NUMBER
)
IS
/*****************************************************************************************/
   /*    Copyright ) 2006 Tracfone  Wireless Inc. All rights reserved                    */
   /*                                                                                    */
   /* NAME:         insert_pi_hist_prc.sql                                               */
   /* PURPOSE:                                                                           */
   /* FREQUENCY:                                                                         */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                     */
   /* REVISIONS:    VERSION  DATE        WHO               PURPOSE                       */
   /*               -------  ----------  ---------------   -------------------           */
   /*               1.0      07/10/06    VA               Initial Revision              */
   /*               1.1/1.2      07/10/06    VA               Changed the grants        */
   /*                                                                                 */
   /**************************************************************************************/
   CURSOR get_line_info_cur
   IS
      SELECT *
        FROM table_part_inst
       WHERE part_serial_no = ip_min;

   get_line_info_rec           get_line_info_cur%ROWTYPE;
   v_procedure_name   CONSTANT VARCHAR2 (200)         := 'insert_pi_hist_prc';
   v_pi_hist_seq               NUMBER;
   e_notfound                  EXCEPTION;
BEGIN
   OPEN get_line_info_cur;

   FETCH get_line_info_cur
    INTO get_line_info_rec;

   IF get_line_info_cur%NOTFOUND
   THEN
      RAISE e_notfound;

      CLOSE get_line_info_cur;
   ELSE
      sa.sp_seq ('x_pi_hist', v_pi_hist_seq);

      INSERT INTO table_x_pi_hist
                  (objid, status_hist2x_code_table,
                   x_change_date, x_change_reason, x_cool_end_date,
                   x_creation_date,
                   x_deactivation_flag,
                   x_domain, x_ext,
                   x_insert_date, x_npa,
                   x_nxx, x_old_ext, x_old_npa,
                   x_old_nxx, x_part_bin,
                   x_part_inst_status,
                   x_part_mod,
                   x_part_serial_no,
                   x_part_status,
                   x_pi_hist2carrier_mkt,
                   x_pi_hist2inv_bin,
                   x_pi_hist2part_inst,
                   x_pi_hist2part_mod, x_pi_hist2user,
                   x_pi_hist2x_new_pers,
                   x_pi_hist2x_pers,
                   x_po_num,
                   x_reactivation_flag,
                   x_red_code,
                   x_sequence,
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
                   x_transaction_id, x_msid
                  )
           VALUES (v_pi_hist_seq, get_line_info_rec.status2x_code_table,
                   SYSDATE, ip_reason, get_line_info_rec.x_cool_end_date,
                   get_line_info_rec.x_creation_date,
                   get_line_info_rec.x_deactivation_flag,
                   get_line_info_rec.x_domain, get_line_info_rec.x_ext,
                   get_line_info_rec.x_insert_date, get_line_info_rec.x_npa,
                   get_line_info_rec.x_nxx, ip_old_ext, ip_old_npa,
                   ip_old_nxx, get_line_info_rec.part_bin,
                   get_line_info_rec.x_part_inst_status,
                   get_line_info_rec.part_mod,
                   get_line_info_rec.part_serial_no,
                   get_line_info_rec.part_status,
                   get_line_info_rec.part_inst2carrier_mkt,
                   get_line_info_rec.part_inst2inv_bin,
                   get_line_info_rec.objid,
                   get_line_info_rec.n_part_inst2part_mod, ip_user_objid,
                   get_line_info_rec.part_inst2x_new_pers,
                   get_line_info_rec.part_inst2x_pers,
                   get_line_info_rec.x_po_num,
                   get_line_info_rec.x_reactivation_flag,
                   get_line_info_rec.x_red_code,
                   get_line_info_rec.x_sequence,
                   get_line_info_rec.warr_end_date, get_line_info_rec.dev,
                   get_line_info_rec.fulfill2demand_dtl,
                   get_line_info_rec.part_to_esn2part_inst,
                   get_line_info_rec.bad_res_qty,
                   get_line_info_rec.date_in_serv,
                   get_line_info_rec.good_res_qty,
                   get_line_info_rec.last_cycle_ct,
                   get_line_info_rec.last_mod_time,
                   get_line_info_rec.last_pi_date,
                   get_line_info_rec.last_trans_time,
                   get_line_info_rec.next_cycle_ct,
                   get_line_info_rec.x_order_number,
                   get_line_info_rec.part_bad_qty,
                   get_line_info_rec.part_good_qty,
                   get_line_info_rec.pi_tag_no,
                   get_line_info_rec.pick_request,
                   get_line_info_rec.repair_date,
                   get_line_info_rec.transaction_id, get_line_info_rec.x_msid
                  );
   END IF;

   IF get_line_info_cur%ISOPEN
   THEN
      CLOSE get_line_info_cur;
   END IF;

   -- Commit only when the global variable is set to TRUE (default is TRUE)
   IF sa.globals_pkg.g_perform_commit THEN
     COMMIT;
   END IF;

   ip_out_val := 0;
EXCEPTION
   WHEN e_notfound
   THEN
      IF get_line_info_cur%ISOPEN
      THEN
         CLOSE get_line_info_cur;
      END IF;

      toss_util_pkg.insert_error_tab_proc ('Failed inserting line',
                                           ip_min,
                                           v_procedure_name,
                                           'Line Not Found'
                                          );
   WHEN OTHERS
   THEN
      IF get_line_info_cur%ISOPEN
      THEN
         CLOSE get_line_info_cur;
      END IF;

      toss_util_pkg.insert_error_tab_proc ('Failed inserting line',
                                           ip_min,
                                           v_procedure_name,
                                           SUBSTR (SQLERRM, 1, 200)
                                          );
END;
/