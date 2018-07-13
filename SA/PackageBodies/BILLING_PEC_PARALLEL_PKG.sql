CREATE OR REPLACE PACKAGE BODY sa."BILLING_PEC_PARALLEL_PKG"
IS
   PROCEDURE de_enroll_old_prog (
      p_esn       IN       VARCHAR2,
      op_result   OUT      NUMBER,
      op_msg      OUT      VARCHAR2
   )

  IS
      v_date             DATE                     DEFAULT SYSDATE;
      v_call_trans_seq   NUMBER;

      CURSOR site_part_curs (c_esn IN VARCHAR2)
      IS
         SELECT   *
             FROM table_site_part
            WHERE x_service_id = c_esn
              AND part_status IN ('Active', 'Inactive')
         ORDER BY install_date DESC;

      site_part_rec      site_part_curs%ROWTYPE;
------------------------------------------------------------
      CURSOR user_curs (c_login_name IN VARCHAR2)
      IS
         SELECT objid
           FROM table_user
          WHERE s_login_name = UPPER (c_login_name);

      user_rec           user_curs%ROWTYPE;
------------------------------------------------------------
      CURSOR carrier_curs (c_min IN VARCHAR2)
      IS
         SELECT part_inst2carrier_mkt
           FROM table_part_inst
          WHERE part_serial_no = c_min;

      carrier_rec        carrier_curs%ROWTYPE;
------------------------------------------------------------
   BEGIN
      op_result := 1;
      op_msg := 'Success';

      ---- Loop through all the enrollments for a given ESN.
      FOR idx IN  (SELECT *
                     FROM table_x_autopay_details
                    WHERE x_esn = p_esn
                      AND x_status = 'A'
                      AND (   x_end_date IS NULL
                           OR x_end_date = TO_DATE ('01-jan-1753', 'dd-mon-yyyy')
                          )
                   )
      LOOP
         OPEN site_part_curs (p_esn);
         FETCH site_part_curs INTO site_part_rec;
         CLOSE site_part_curs;

         OPEN carrier_curs (site_part_rec.x_min);
         FETCH carrier_curs INTO carrier_rec;
         CLOSE carrier_curs;

         OPEN user_curs ('SA');
         FETCH user_curs INTO user_rec;
         CLOSE user_curs;

         UPDATE table_x_autopay_details
            SET x_status = 'I',
                x_end_date = SYSDATE,
                x_account_status = 9
          WHERE objid = idx.objid;

         sp_seq ('x_call_trans', v_call_trans_seq);

         INSERT INTO table_x_call_trans
                     (objid, call_trans2site_part, x_action_type,
                      x_call_trans2carrier,
                      x_call_trans2dealer, x_call_trans2user, x_line_status,
                      x_min, x_service_id,
                      x_sourcesystem, x_transact_date, x_total_units,
                      x_action_text, x_reason,
                      x_result, x_sub_sourcesystem)
              VALUES (v_call_trans_seq, site_part_rec.objid, '83',
                      carrier_rec.part_inst2carrier_mkt,
                      site_part_rec.site_part2site, user_rec.objid, '13',
                      site_part_rec.x_min, site_part_rec.x_service_id,
                      'BILLING_PLATFORM', v_date, 0,
                      'STAYACT UNSUBSCRIBE', 'Billing Enrollment',
                      'Completed', '202');

            --insert into send_ftp table
            INSERT
            INTO X_SEND_FTP_AUTO(
               send_seq_no,
               file_type_ind,
               esn,
               program_type,
               account_status,
               amount_due
            )VALUES(
               seq_x_send_ftp_auto.NEXTVAL,
               'D',
               p_esn,
               idx.x_program_type,
               'D',
               0
            );

      END LOOP;

      commit;

   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -900;
         op_msg :=    SQLCODE
                   || SUBSTR (SQLERRM, 1, 100);
   END de_enroll_old_prog;


END billing_pec_parallel_pkg;
/