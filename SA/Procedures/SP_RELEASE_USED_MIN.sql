CREATE OR REPLACE PROCEDURE sa."SP_RELEASE_USED_MIN"
IS
/******************************************************************************/
   /*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved            */
   /*                                                                            */
   /* NAME:         SP_RELEASE_USED_MIN                                          */
   /* PURPOSE:                                                                   */
   /* FREQUENCY:                                                                 */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
   /*                                                                            */
   /* REVISIONS:                                                                 */
   /* VERSION  DATE        WHO          PURPOSE                                  */
   /* -------  ---------- -----  ---------------------------------------------   */
   /*  1.0     03/13/02   ???    Initial  Revision                               */
   /*  ????????                                                                  */
   /*  2.1     10/18/02   VA     Number Pooling Changes                          */
   /*  2.2    03/13/03    JR     Main Select of used lines                       */
   /*  2.3     04/10/03   SL     Clarify Upgrade - sequence                      */
   /*  2.4    08/02/05    VA     CR4371 - Modified to commit for every record  (PVCS revision 1.3)
   /******************************************************************************/
   var_11 NUMBER := 0;
   fh UTL_FILE.file_type;
   /* pick needed part_inst records */
   CURSOR cur_pi
   IS
   SELECT *
   FROM table_part_inst a
   WHERE warr_end_date <> TO_DATE('01/01/1753', 'mm/dd/yyyy')
   AND warr_end_date < TRUNC(SYSDATE + 1)
   AND UPPER (x_domain) = 'LINES'
   AND x_part_inst_status = '12';
   pi_rec cur_pi%ROWTYPE;
   /* get manufacturer */
   CURSOR cur_manuf(
      c_objid IN NUMBER
   )
   IS
   SELECT x_manufacturer
   FROM table_part_num a, table_mod_level b, table_part_inst c
   WHERE c_objid = c.objid
   AND c.n_part_inst2part_mod = b.objid
   AND b.part_info2part_num = a.objid;
   manuf_rec cur_manuf%ROWTYPE;
   /* get carrier id */
   CURSOR cur_cid(
      c_objid IN NUMBER
   )
   IS
   SELECT x_carrier_id
   FROM table_x_carrier a, table_part_inst b
   WHERE a.objid = b.part_inst2carrier_mkt
   AND c_objid = b.objid
   AND ROWNUM = 1;
   cid_rec cur_cid%ROWTYPE;
   /* get site id from inv_bin for dealer id*/
   CURSOR cur_did(
      c_objid IN NUMBER
   )
   IS
   SELECT bin_name
   FROM table_inv_bin a, table_part_inst b
   WHERE a.objid = b.part_inst2inv_bin
   AND c_objid = b.objid;
   did_rec cur_did%ROWTYPE;
   /* get site_id for cust_id */
   CURSOR cur_si(
      c_objid IN NUMBER
   )
   IS
   SELECT site_id
   FROM table_site s, table_site_part sp, table_part_inst pi
   WHERE s.objid = sp.site_part2site
   AND sp.x_min = pi.part_serial_no
   AND pi.objid = c_objid
   AND ROWNUM = 1;
   si_rec cur_si%ROWTYPE;
BEGIN
   OPEN cur_pi;
   LOOP
      FETCH cur_pi
      INTO pi_rec;
      EXIT
      WHEN cur_pi%NOTFOUND;
      OPEN cur_cid (pi_rec.objid);
      FETCH cur_cid
      INTO cid_rec;
      CLOSE cur_cid;
      OPEN cur_manuf (pi_rec.objid);
      FETCH cur_manuf
      INTO manuf_rec;
      CLOSE cur_manuf;
      OPEN cur_did (pi_rec.objid);
      FETCH cur_did
      INTO did_rec;
      CLOSE cur_did;
      OPEN cur_si (pi_rec.objid);
      FETCH cur_si
      INTO si_rec;
      CLOSE cur_si;
      INSERT
      INTO table_x_pi_hist(
         objid,
         status_hist2x_code_table,
         x_change_date,
         x_change_reason,
         x_cool_end_date,
         x_creation_date,
         x_deactivation_flag,
         x_domain,
         x_ext,
         x_insert_date,
         x_npa,
         x_nxx,
         x_old_ext,
         x_old_npa,
         x_old_nxx,
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
         x_red_code,
         x_sequence,
         x_warr_end_date,
         dev,
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
         x_msid --Number Pooling 10/18/02
      ) VALUES(
         -- 04/10/03 seq_x_pi_hist.nextval + POWER (2, 28),
         sa.seq('x_pi_hist'),
         pi_rec.status2x_code_table,
         SYSDATE,
         'RELEASE USED LINE',
         pi_rec.x_cool_end_date,
         pi_rec.x_creation_date,
         pi_rec.x_deactivation_flag,
         pi_rec.x_domain,
         pi_rec.x_ext,
         pi_rec.x_insert_date,
         pi_rec.x_npa,
         pi_rec.x_nxx,
         NULL,
         NULL,
         NULL,
         pi_rec.part_bin,
         '18',
         pi_rec.part_mod,
         pi_rec.part_serial_no,
         pi_rec.part_status,
         pi_rec.part_inst2carrier_mkt,
         pi_rec.part_inst2inv_bin,
         pi_rec.objid,
         pi_rec.n_part_inst2part_mod,
         pi_rec.created_by2user,
         pi_rec.part_inst2x_new_pers,
         pi_rec.part_inst2x_pers,
         pi_rec.x_po_num,
         pi_rec.x_reactivation_flag,
         pi_rec.x_red_code,
         pi_rec.x_sequence,
         pi_rec.warr_end_date,
         pi_rec.dev,
         pi_rec.fulfill2demand_dtl,
         pi_rec.part_to_esn2part_inst,
         pi_rec.bad_res_qty,
         pi_rec.date_in_serv,
         pi_rec.good_res_qty,
         pi_rec.last_cycle_ct,
         pi_rec.last_mod_time,
         pi_rec.last_pi_date,
         pi_rec.last_trans_time,
         pi_rec.next_cycle_ct,
         pi_rec.x_order_number,
         pi_rec.part_bad_qty,
         pi_rec.part_good_qty,
         pi_rec.pi_tag_no,
         pi_rec.pick_request,
         pi_rec.repair_date,
         pi_rec.transaction_id,
         pi_rec.x_msid --Number Pooling 10/18/02
      );
      INSERT
      INTO x_monitor(
         x_monitor_id,
         x_date_mvt,
         x_phone,
         x_esn,
         x_cust_id,
         x_carrier_id,
         x_dealer_id,
         x_action,
         x_action_type_id,
         x_reason_code,
         x_ig_status,
         x_ig_error,
         x_pin,
         x_manufacturer,
         x_initial_act_date,
         x_end_user,
         x_islocked,
         x_locked_by,
         x_line_worked,
         x_line_worked_by,
         x_line_worked_date,
         x_fax_filename,
         x_msid --Number Pooling 10/18/02
      ) VALUES(
         (seq_x_monitor_id.nextval + (POWER (2, 28))),
         SYSDATE,
         pi_rec.part_serial_no,
         NULL,
         --     si_rec.site_id,
         'na',
         --     concat('1',lpad(cid_rec.x_carrier_id,9,'0')),
         TO_CHAR (cid_rec.x_carrier_id),
         did_rec.bin_name,
         'X',
         0,
         '22',
         NULL,
         NULL,
         NULL,
         manuf_rec.x_manufacturer,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         pi_rec.x_msid --Number Pooling 10/18/02
      );
      UPDATE table_part_inst SET x_part_inst_status = '18', status2x_code_table
      = 964
      WHERE objid = pi_rec.objid;
      var_11 := var_11 + 1;
      UPDATE table_x_account_hist SET x_end_date = SYSDATE
      WHERE account_hist2part_inst = pi_rec.objid;
      COMMIT;
--CR4371
   END LOOP;
   CLOSE cur_pi;
   --   COMMIT; --CR4371
   /* -------write number of inserted and updated records along with a timestamp to a logfile */
   fh := UTL_FILE.fopen ('/f01/invfile', 'release_logfile', 'A');
   UTL_FILE.putf ( fh,
   'FOR %s
     inserted monitor and part instance history records for status NEW: %s\n\n'
     , TO_CHAR (SYSDATE, 'MM-DD-YYYY-HH-MI-SS'), TO_CHAR (var_11) );
   UTL_FILE.fclose (fh);
   EXCEPTION
   WHEN OTHERS
   THEN
      DECLARE
         sql_code NUMBER;
         sql_err VARCHAR2 (30);
         file_handle UTL_FILE.file_type;
      BEGIN
         sql_code := SQLCODE;
         sql_err := SQLERRM;
         file_handle := UTL_FILE.fopen ('/f01/invfile', 'release_exceptions',
         'A');
         UTL_FILE.putf ( file_handle, '%s\n%s\n%s\n', TO_CHAR (SYSDATE,
         'MM-DD-YYYY-HH-MI-SS'), TO_CHAR (sql_code), sql_err );
         UTL_FILE.fclose (file_handle);
         DBMS_OUTPUT.put_line (sql_code || '  ' || sql_err);
      END;
END sp_release_used_min;
/