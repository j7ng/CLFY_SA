CREATE OR REPLACE PROCEDURE sa."ENROLL_NONREAL_AUTOPAY_PRC" (
   ip_program_type IN NUMBER,
   ip_promocode IN VARCHAR2
)
IS
/************************************************************************************
   * Procedure Name: enroll_nonreal_autopay_prc
   * Purpose       : This procedure enrolls autopay non-realtime customers manually
   * Platform      : Oracle 8.0.6 and newer versions.
   * Created by    : Vanisri Adapa
   * Date          : 09/09/03
   * Frequency     : All weekdays till 12/31/2003
   * History
   * Revisions     :
   * VERSION     DATE        WHO             PURPOSE
   * -------------------------------------------------------------
   * 1.0         09/09/03    VAdapa          Initial Revision
   * 1.1         08/31/04    VAdapa          CR3160 - Fix to close the cursor
   /************************************************************************************/
   CURSOR get_non_realtime_cust_cur
   IS
     SELECT *
        FROM table_x_autopay_details
       WHERE x_program_type = NVL (ip_program_type, 0)
         AND x_status = 'E'
         AND x_account_status = 3
         AND x_receive_status = 'Y'
         ;

   ----
   CURSOR chk_expire_esn_cur(
      c_ip1_esn IN VARCHAR2
   )
   IS
   SELECT objid,
      x_expire_dt
   FROM TABLE_SITE_PART
   WHERE x_service_id = c_ip1_esn
   AND part_status = 'Active';
   chk_expire_esn_rec chk_expire_esn_cur%ROWTYPE;
   ----
   CURSOR pending_call_trans_cur(
      c_ip2_esn IN VARCHAR2
   )
   IS
   SELECT objid
   FROM TABLE_X_CALL_TRANS
   WHERE x_service_id = c_ip2_esn
   AND x_action_type = '82'
   AND x_result = 'Pending';
   pending_call_trans_rec pending_call_trans_cur%ROWTYPE;
   ----
   CURSOR promo_cur(
      c_ip_pcode IN VARCHAR2
   )
   IS
   SELECT objid
   FROM TABLE_X_PROMOTION
   WHERE x_promo_code = c_ip_pcode
   AND SYSDATE BETWEEN x_start_date
   AND x_end_date;
   promo_rec promo_cur%ROWTYPE;
   ----
   CURSOR chk_ftp_cur(
      c_ip3_esn IN VARCHAR2
   )
   IS
   SELECT 'X'
   FROM X_RECEIVE_FTP_AUTO
   WHERE esn = c_ip3_esn
   AND program_type = ip_program_type
   AND enroll_flag = 'Y';
   chk_ftp_rec chk_ftp_cur%ROWTYPE;
   ----
   CURSOR tmp_contact_cur(
      c_ip4_esn IN VARCHAR2
   )
   IS
   SELECT *
   FROM X_AUTOPAY_CONTACT
   WHERE esn = c_ip4_esn;
   tmp_contact_rec tmp_contact_cur%ROWTYPE;
   ----
   CURSOR contact_info_cur(
      c_ip5_esn IN VARCHAR2
   )
   IS
   SELECT cr.contact_role2contact,
      s.cust_billaddr2address,
      s.objid site_objid
   FROM TABLE_CONTACT_ROLE cr, TABLE_SITE s, TABLE_SITE_PART sp
   WHERE cr.contact_role2site = sp.site_part2site
   AND s.objid = sp.site_part2site
   AND sp.x_service_id = c_ip5_esn
   AND sp.part_status = 'Active';
   contact_info_rec contact_info_cur%ROWTYPE;
   ----
   CURSOR state_cur(
      c_ip_state IN VARCHAR2
   )
   IS
   SELECT objid,
      state_prov2country
   FROM TABLE_STATE_PROV
   WHERE name = c_ip_state;
   state_rec state_cur%ROWTYPE;
   ----
   l_hold_seq_num NUMBER;
   l_procedure_name VARCHAR2 (100) := 'ENROLL_NONREAL_AUTOPAY_PRC';
   l_serial_num VARCHAR2 (20);
   l_action VARCHAR2 (255);
   --Exception Declarations
   l_exp_promo_notfound EXCEPTION
;
   l_exp_no_transtn EXCEPTION
;
   l_exp_no_srvc EXCEPTION
;
   --CR3160 Changes
   /********* CLEAN up routine (PRIVATE PROCEDURE)**************************************************/
   PROCEDURE clean_up_prc
   IS
   BEGIN
      IF chk_expire_esn_cur%ISOPEN
      THEN
         CLOSE chk_expire_esn_cur;
      END IF;
      IF pending_call_trans_cur%ISOPEN
      THEN
         CLOSE pending_call_trans_cur;
      END IF;
      IF promo_cur%ISOPEN
      THEN
         CLOSE promo_cur;
      END IF;
      IF chk_ftp_cur%ISOPEN
      THEN
         CLOSE chk_ftp_cur;
      END IF;
      IF tmp_contact_cur%ISOPEN
      THEN
         CLOSE tmp_contact_cur;
      END IF;
      IF contact_info_cur%ISOPEN
      THEN
         CLOSE contact_info_cur;
      END IF;
      IF state_cur%ISOPEN
      THEN
         CLOSE state_cur;
      END IF;
   END clean_up_prc;
/*****************************************************************************/
--End CR3160 Changes
BEGIN
   FOR get_non_realtime_cust_rec IN get_non_realtime_cust_cur
   LOOP
      BEGIN
         l_serial_num := get_non_realtime_cust_rec.x_esn;
         OPEN chk_expire_esn_cur (get_non_realtime_cust_rec.x_esn);
         FETCH chk_expire_esn_cur
         INTO chk_expire_esn_rec;
         l_action := 'Active Service Check';
         IF chk_expire_esn_cur%FOUND --Active Service Check
         THEN
            OPEN pending_call_trans_cur (get_non_realtime_cust_rec.x_esn);
            FETCH pending_call_trans_cur
            INTO pending_call_trans_rec;
            l_action := 'Transaction Record Check';
            IF pending_call_trans_cur%FOUND --Transaction Record Check
            THEN
               l_action := 'Valid Promo Check';
               IF ip_promocode != '00000'
               OR ip_promocode
               IS
               NOT NULL --Valid Promo Check
               THEN
                  OPEN promo_cur (ip_promocode);
                  FETCH promo_cur
                  INTO promo_rec;
                  l_action := 'Promo Exist Check';
                  IF promo_cur%FOUND --Promo Exist Check
                  THEN
                     INSERT
                     INTO TABLE_X_PROMO_HIST(
                        objid,
                        promo_hist2x_call_trans,
                        promo_hist2x_promotion
                     )VALUES(
                        Seq ('x_promo_hist'),
                        pending_call_trans_rec.objid,
                        promo_rec.objid
                     );
                  ELSE
                     RAISE l_exp_promo_notfound;
                  END IF;
--End of Promo Exist Check
               END IF; --End of Valid Promo Check
               CLOSE promo_cur;
               l_action := 'Update TABLE_X_CALL_TRANS';
               UPDATE TABLE_X_CALL_TRANS SET x_result = 'Completed',
               x_transact_date = SYSDATE
               WHERE objid = pending_call_trans_rec.objid;
               OPEN chk_ftp_cur (get_non_realtime_cust_rec.x_esn);
               FETCH chk_ftp_cur
               INTO chk_ftp_rec;
               l_action := 'Receive FTP Check';
               IF chk_ftp_cur%NOTFOUND --Receive FTP Check
               THEN
                  INSERT
                  INTO X_RECEIVE_FTP_AUTO(
                     rec_seq_no,
                     cycle_number,
                     pay_type_ind,
                     date_received,
                     trans_amount,
                     esn,
                     first_name,
                     last_name,
                     return_code,
                     program_type,
                     enroll_flag,
                     promo_code,
                     unique_rec_no,
                     qualified_date
                  )VALUES(
                     seq_x_receive_ftp_auto.NEXTVAL + POWER (2, 28),
                     NULL,
                     'PAY',
                     SYSDATE,
                     0.00,
                     get_non_realtime_cust_rec.x_esn,
                     get_non_realtime_cust_rec.x_first_name,
                     get_non_realtime_cust_rec.x_last_name,
                     0,
                     ip_program_type,
                     'Y',
                     ip_promocode,
                     NULL,
                     NULL
                  );
               END IF; --End of Receive FTP Check
               CLOSE chk_ftp_cur;
               OPEN tmp_contact_cur (get_non_realtime_cust_rec.x_esn);
               FETCH tmp_contact_cur
               INTO tmp_contact_rec;
               CLOSE tmp_contact_cur;
               OPEN contact_info_cur (get_non_realtime_cust_rec.x_esn);
               FETCH contact_info_cur
               INTO contact_info_rec;
               CLOSE contact_info_cur;
               OPEN state_cur (tmp_contact_rec.state);
               FETCH state_cur
               INTO state_rec;
               CLOSE state_cur;
               l_action := 'Update TABLE_CONTACT 1';
               UPDATE TABLE_CONTACT SET address_1 = tmp_contact_rec.address,
               city = tmp_contact_rec.city, state = tmp_contact_rec.state,
               zipcode = tmp_contact_rec.zip, x_autopay_update_flag = 1
               WHERE objid = contact_info_rec.contact_role2contact;
               l_action := 'Update TABLE_CONTACT 2';
               UPDATE TABLE_CONTACT SET phone = tmp_contact_rec.phone
               WHERE objid = contact_info_rec.contact_role2contact
               AND phone || '' = tmp_contact_rec.phone;
               l_action := 'Address update check';
               IF contact_info_rec.cust_billaddr2address
               IS
               NOT NULL --Address update check
               THEN
                  UPDATE TABLE_ADDRESS SET address = tmp_contact_rec.address,
                  s_address = UPPER (tmp_contact_rec.address), s_city = UPPER (
                  tmp_contact_rec.city), s_state = UPPER (tmp_contact_rec.state
                  ), city = tmp_contact_rec.city, state = tmp_contact_rec.state
                  , zipcode = tmp_contact_rec.zip
                  WHERE objid = contact_info_rec.contact_role2contact;
               ELSE
                  SELECT Seq ('address')
                  INTO l_hold_seq_num
                  FROM dual;
                  l_action := 'Insert TABLE_ADDRESS';
                  INSERT
                  INTO TABLE_ADDRESS(
                     objid,
                     address,
                     s_address,
                     city,
                     s_city,
                     state,
                     s_state,
                     zipcode,
                     address_2,
                     dev,
                     address2time_zone,
                     address2country,
                     address2state_prov,
                     update_stamp
                  )VALUES(
                     l_hold_seq_num,
                     tmp_contact_rec.address,
                     UPPER (tmp_contact_rec.address),
                     tmp_contact_rec.city,
                     UPPER (tmp_contact_rec.city),
                     tmp_contact_rec.state,
                     UPPER (tmp_contact_rec.state),
                     tmp_contact_rec.zip,
                     NULL,
                     NULL,
                     NULL,
                     state_rec.state_prov2country,
                     state_rec.objid,
                     NULL
                  );
                  l_action := 'Update TABLE_SITE';
                  UPDATE TABLE_SITE SET cust_billaddr2address = l_hold_seq_num
                  WHERE objid = contact_info_rec.site_objid;
                  DELETE
                  FROM X_AUTOPAY_CONTACT
                  WHERE esn = get_non_realtime_cust_rec.x_esn;
               END IF; --End of Address update check
               l_action := 'Update TABLE_X_AUTOPAY_DETAILS';
               UPDATE TABLE_X_AUTOPAY_DETAILS SET x_status = 'A',
               x_receive_status = 'Y', x_start_date = SYSDATE
               WHERE objid = get_non_realtime_cust_rec.objid;
               DELETE
               FROM X_AUTOPAY_CONTACT
               WHERE esn = get_non_realtime_cust_rec.x_esn;
               COMMIT;
            ELSE
               RAISE l_exp_no_transtn;
            END IF; --End of Transaction Record Check
            CLOSE pending_call_trans_cur;
         ELSE
            RAISE l_exp_no_srvc;
         END IF; --End of Active Service Check
         CLOSE chk_expire_esn_cur;
         EXCEPTION
         WHEN l_exp_promo_notfound
         THEN
            Toss_util_pkg.Insert_error_tab_proc ( l_action ||
            ': Promo Not Found', l_serial_num, l_procedure_name );
            COMMIT;
         WHEN l_exp_no_transtn
         THEN
            Toss_util_pkg.Insert_error_tab_proc ( l_action ||
            ': No Transaction Record', l_serial_num, l_procedure_name );
            COMMIT;
         WHEN l_exp_no_srvc
         THEN
            Toss_util_pkg.Insert_error_tab_proc ( l_action || ': No Service',
            l_serial_num, l_procedure_name );
            COMMIT;
         WHEN OTHERS
         THEN
            Toss_util_pkg.Insert_error_tab_proc ( 'Inner Loop ' || l_action,
            l_serial_num, l_procedure_name );
            COMMIT;
      END;
      clean_up_prc;
--CR3160 Changes
   END LOOP;
   COMMIT;
   EXCEPTION
   WHEN OTHERS
   THEN
      Toss_util_pkg.Insert_error_tab_proc ( l_action, l_serial_num,
      l_procedure_name );
      COMMIT;
END Enroll_nonreal_autopay_prc;
/