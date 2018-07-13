CREATE OR REPLACE PACKAGE BODY sa."INBOUND_ELOCKNOTE_PKG"
AS
/*****************************************************************
  * Package Name: sp_elocknote (BODY)
  * Purpose     : The package is called by java program to give free
  *               access days for Autopay,Bonus and Deactivation Registered Customers.
  *
  * Platform    : Oracle 8.0.6 and newer versions.
  * Created by  : Rama krishna Raju K.V.S, TATA
  * Date        : 05/30/2002
  *
  * Frequency   : All weekdays
  * History
  * REVISIONS    VERSION  DATE        WHO               PURPOSE
  * -------------------------------------------------------------
  *                1.0                                   Initial Revision
  *                1.1    10/17/02    Raju               Owing to CR 1071
  *                1.2    12/03/02    CWL                rewrite DoElockNote_prc
  *                                   SL                 Convert republik option A TO B
  *                1.3    12/12/02    CWL                Add autopay pending
                   1.4    04/07/03    Suganthi      CR 1386 Change of Funding.
  *                1.5    04/10/03    SL                 Clarify Upgrade - sequence
                   1.5    05/10/03    Suganthi           CR 1157 Correct Autopay Details table
                   1.6    09/09/03    VAdapa             CR1898 Swap input values to x_autopay_pending
                   1.7    10/24/03    Gpintado           CR2079 When P_status <> 'A' and If
                                                         DPP then reverse back only 22 days
  *                1.8    04/21/04    Raju               CR 2158 - Correct data in table_x_call_trans
  *                1.8    04/21/04    Raju               CR 2821 - Giving 20 days for DPP Change of funding customers.
  *                1.9    08/03/04    Raju               CR 3120 -i) Not to back track Service_END_DT OF THE CUSTOMER
  *                                                      if the payment is REV, Since the ESN will have a different Service_end_dt
  *                                                      and the database will have service_end_dt  customer ESN
  *                                                      will be De-activated, which will result in customer confusion
  *                                                      ii) stacking has been increased from 90 days to 120 days
  *                                                      iii) Modified logic for change of funding so that the customer will
  *                                                      not be De-activated
  *            1.13      06/08/07   VAdapa             CR6318 - Autopay Fix
  *                                             use X_SERVICE_ID in the where clause instead of s_serial_no
                                          as sometimes this field doesn not get populated
  ************************************************************************/
/*************************************************************************
 * Procedure: main
 * Purpose  : To give free access days for Autopay,Bonus and Deactivation Registered
 *            Customers. If qualified and Process Successfully
 *            then commit else rollback;
 **************************************************************************/
   PROCEDURE main_prc (
      p_cyclenumber               VARCHAR2,
      p_type_i                    VARCHAR2,
      p_creationdate              VARCHAR2,
      p_transactionamount         NUMBER,
      p_accountnumber             VARCHAR2,
      p_firstname                 VARCHAR2 DEFAULT NULL,
      p_lastname                  VARCHAR2 DEFAULT NULL,
      p_accountstatus             VARCHAR2,
      p_paymentmode               NUMBER,
      p_uniquerecord              NUMBER,
      p_status                    VARCHAR2 DEFAULT NULL,
      p_enrollfeeflag             VARCHAR2 DEFAULT NULL,
      p_promocode                 VARCHAR2 DEFAULT NULL,
      p_msg                 OUT   VARCHAR2,
      c_p_status            OUT   VARCHAR2
   )
   IS
------------------------------------------------------------------
      CURSOR expire_dt_c
      IS
         SELECT x_expire_dt, objid                                 --12/03/02
           FROM table_site_part
          WHERE part_status = 'Active' AND x_service_id = p_accountnumber;

      expire_dt_rec             expire_dt_c%ROWTYPE;

------------------------------------------------------------------
      CURSOR cur_ph_c
      IS
         SELECT *
           FROM table_part_inst
          WHERE part_serial_no = p_accountnumber AND x_domain = 'PHONES';

      rec_ph                    cur_ph_c%ROWTYPE;

------------------------------------------------------------------
      CURSOR pending_call_trans_curs (
         c_esn             IN   VARCHAR2,
         c_enrollfeeflag   IN   VARCHAR2
      )
      IS
         SELECT objid
           FROM table_x_call_trans
          WHERE x_action_type = DECODE (c_enrollfeeflag, 'Y', '82', '84')
            AND x_service_id = c_esn
            AND x_result = 'Pending';

      pending_call_trans_rec    pending_call_trans_curs%ROWTYPE;

------------------------------------------------------------------
      CURSOR promo_code_curs (c_promocode IN VARCHAR2)
      IS
         SELECT objid
           FROM table_x_promotion
          WHERE x_promo_code = c_promocode;

      promo_code_rec            promo_code_curs%ROWTYPE;

------------------------------------------------------------------
      CURSOR cur_x_autopay_contact_c (c_esn IN VARCHAR2)
      IS
         SELECT *
           FROM x_autopay_contact
          WHERE esn = c_esn;

      rec_x_autopay_contact     cur_x_autopay_contact_c%ROWTYPE;

------------------------------------------------------------------
      CURSOR cur_contact_info (c_esn IN VARCHAR)
      IS
         SELECT cr.contact_role2contact, s.cust_billaddr2address,
                s.objid site_objid
           FROM table_contact_role cr, table_site s, table_site_part sp
          WHERE cr.contact_role2site = sp.site_part2site
            AND s.objid = sp.site_part2site
            AND sp.x_service_id = c_esn
            AND sp.part_status = 'Active';

      rec_contact_info          cur_contact_info%ROWTYPE;

------------------------------------------------------------------
      CURSOR state_curs (c_state IN VARCHAR2)
      IS
         SELECT objid, state_prov2country
           FROM table_state_prov
          WHERE NAME = c_state;

      state_rec                 state_curs%ROWTYPE;

------------------------------------------------------------------
      CURSOR expire_dt_d_c
      IS
         SELECT x_expire_dt, x_expire_dt - SYSDATE
           FROM table_site_part
          WHERE part_status = 'Active' AND x_service_id = p_accountnumber;

      expire_dt_d_rec           expire_dt_d_c%ROWTYPE;

----------------------------------------------------------------
      CURSOR cur_ph_d_c
      IS
         SELECT *
           FROM table_part_inst
          WHERE x_part_inst_status = '52'
            AND part_serial_no = p_accountnumber
            AND x_domain = 'PHONES';

      rec_ph_d                  cur_ph_d_c%ROWTYPE;

----------------------------------------------------------------
      CURSOR change_date_curs (
         c_paymentmode      IN   VARCHAR2,
         c_part_serial_no   IN   VARCHAR2
      )
      IS
         SELECT   x_warr_end_date - x_change_date diff, x_warr_end_date,
                  x_change_date
             FROM table_x_pi_hist
            WHERE x_change_reason =
                     DECODE (c_paymentmode,
                             2, 'Autopay Plan Batch',
                             3, 'Bonus Plan Batch',
                             4, 'Deact Plan Batch'
                            )
              AND x_part_serial_no = c_part_serial_no
         ORDER BY x_change_date DESC;

      change_date_rec           change_date_curs%ROWTYPE;

----------------------------------------------------------------
      CURSOR active_autopay_curs (c_paymentmode IN NUMBER, c_esn IN VARCHAR2)
      IS
         SELECT *                                      --x_program_type CR1386
           FROM table_x_autopay_details
          WHERE x_esn = c_esn
            AND x_status = 'A'
            AND x_program_type = c_paymentmode;

      active_autopay_rec        active_autopay_curs%ROWTYPE;

----------------------------------------------------------------
      CURSOR max_send_ftp_auto_curs
      IS
         SELECT MAX (send_seq_no) + 1 max_send_seq_no
           FROM x_send_ftp_auto;

      max_send_ftp_auto_rec     max_send_ftp_auto_curs%ROWTYPE;

----------------------------------------------------------------
      CURSOR max_call_trans_curs (
         c_esn             IN   VARCHAR2,
         c_enrollfeeflag   IN   VARCHAR2
      )
      IS
         SELECT   objid
             FROM table_x_call_trans
            WHERE x_action_type = DECODE (c_enrollfeeflag, 'Y', '82', '84')
              AND x_service_id = c_esn
--       and x_result ='Completed'
         ORDER BY x_transact_date DESC;

      max_call_trans_rec        max_call_trans_curs%ROWTYPE;

----------------------------------------------------------------
      CURSOR check_pending_curs (c_esn IN VARCHAR2)
      IS
         SELECT   *
             FROM x_autopay_pending
            WHERE x_esn = c_esn AND x_source_flag = 'B'
         ORDER BY x_start_date ASC;

      check_pending_rec         check_pending_curs%ROWTYPE;

----------------------------------------------------------------
      CURSOR check_autopay_curs (c_esn IN VARCHAR2)
      IS
         SELECT objid
           FROM table_x_autopay_details
          WHERE x_esn = c_esn;

      check_autopay_rec         check_autopay_curs%ROWTYPE;
----------------------------------------------------------------
      v_part_inst_objid         NUMBER;
      v_msg                     VARCHAR2 (1000);
      v_p_status                VARCHAR2 (100);
      v_hold_seq_num            NUMBER;                            -- 04/10/03

----------------------------------------------------------------
-- 12/03/02
      CURSOR cur_rpka_promo (c_pi_objid NUMBER)
      IS
         SELECT ge.ROWID, ge.*, pg.group_name
           FROM table_x_promotion_group pg, table_x_group2esn ge
          WHERE pg.group_name = 'REPUBLIK_A2'
            AND groupesn2x_promo_group + 0 = pg.objid
            AND groupesn2part_inst = c_pi_objid;

      rec_group2esn             cur_rpka_promo%ROWTYPE;

      CURSOR cur_rpkb_promo_group
      IS
         SELECT *
           FROM table_x_promotion_group
          WHERE group_name = 'REPUBLIK_B'
            AND SYSDATE BETWEEN x_start_date AND x_end_date;

      rec_rpkb_promo_group      cur_rpkb_promo_group%ROWTYPE;

      CURSOR cur_rpk_promo
      IS
         SELECT *
           FROM table_x_promotion
          WHERE x_promo_code = 'REDRPK'
            AND SYSDATE BETWEEN x_start_date AND x_end_date;

------------------------------------------------------------
      CURSOR check3_curs (c_esn IN VARCHAR2)
      IS
         SELECT objid
           FROM x_autopay_pending
          WHERE x_esn = c_esn
            AND x_source_flag = 'R'
            AND x_receive_status = 'Y'
            AND x_status = 'A';

      check3_rec                check3_curs%ROWTYPE;

------------------------------------------------------------
      CURSOR check4_curs (c_esn IN VARCHAR2, c_program_type IN NUMBER)
      IS
         SELECT objid
           FROM table_x_autopay_details
          WHERE x_esn = c_esn
            AND x_program_type = c_program_type
            AND x_account_status = 3
            AND x_first_name IS NOT NULL
            AND x_last_name IS NOT NULL
            AND x_cycle_number IS NOT NULL
            AND x_promocode IS NOT NULL
            AND x_enroll_amount IS NOT NULL
            AND x_source IS NOT NULL
            AND x_payment_type IS NOT NULL
            AND x_receive_status = 'Y'
            AND x_status = 'A';

      check4_rec                check4_curs%ROWTYPE;
      check4_boolean            BOOLEAN;

------------------------------------------------------------
      CURSOR check_ftp_curs
      IS
         SELECT 1
           FROM x_receive_ftp_auto
          WHERE cycle_number = p_cyclenumber
            AND pay_type_ind = p_type_i
            AND date_received = TO_DATE (p_creationdate, 'yyyymmdd')
            AND trans_amount = p_transactionamount
            AND esn = p_accountnumber
            AND first_name = p_firstname
            AND last_name = p_lastname
            AND return_code = p_accountstatus
            AND program_type = p_paymentmode
            AND unique_rec_no = p_uniquerecord
            AND enroll_flag = p_enrollfeeflag
            AND promo_code = p_promocode;

      check_ftp_rec             check_ftp_curs%ROWTYPE;

--Start CR 1386
--------------------------------------------------------------
      CURSOR check_funding_curs (c_esn IN VARCHAR2)
      IS
         SELECT   *
             FROM x_autopay_pending
            WHERE x_esn = c_esn
              AND x_source_flag IN ('U', 'B')
              AND x_account_status = 5
         ORDER BY x_start_date ASC;

      check_funding_rec         check_funding_curs%ROWTYPE;

--------------------------------------------------------------
      CURSOR check_pending2_curs (c_esn IN VARCHAR2)
      IS
         SELECT   *
             FROM x_autopay_pending
            WHERE x_esn = c_esn
              AND x_source_flag != 'U'
              AND x_account_status != 5
         ORDER BY x_start_date ASC;

      check_pending2_rec        check_pending2_curs%ROWTYPE;

---------------------------------------------------------------  --end CR 1386
-- start CR 1157
------------------------------------------------------------
      CURSOR sp_curs_c (c_site_part_objid IN NUMBER)
      IS
         SELECT sp.objid site_part_objid, sp.x_min x_min,
                ca.objid carrier_objid, ir.inv_role2site site_objid,
                ca.x_carrier_id x_carrier_id, sp.site_objid cust_site_objid,
                sp.state_code v_state_code
           FROM table_x_carrier ca,
                table_part_inst pi2,                          ---x_Domain=Line
                table_inv_role ir,
                table_inv_bin ib,
                table_part_inst pi,                          ---x_Domain=Phone
                table_site_part sp
          WHERE ca.objid = pi2.part_inst2carrier_mkt
            AND INITCAP (pi2.x_domain) = 'Lines'
            AND pi2.part_serial_no = sp.x_min
            AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
            AND ib.objid = pi.part_inst2inv_bin
            AND pi.x_part_inst2site_part = sp.objid
            AND sp.objid = c_site_part_objid;

      sp_curs_rec               sp_curs_c%ROWTYPE;

--------------------------------------------------
      CURSOR user_curs (c_login_name IN VARCHAR2)
      IS
         SELECT objid
           FROM table_user
          WHERE s_login_name = UPPER (c_login_name);

      user_rec                  user_curs%ROWTYPE;

--------------------------------------------------
--end CR 1157
--start CR 2821
--------------------------------------------------
      CURSOR change_funding_dpp_curs (c_esn IN VARCHAR2)
      IS
         SELECT *
           FROM table_x_autopay_details
          WHERE x_account_status = '5'
            AND x_program_type = '4'
            AND x_status = 'E'
            AND x_creation_date >= SYSDATE - 15
            AND x_esn = c_esn;

      change_funding_dpp_rec    change_funding_dpp_curs%ROWTYPE;

--------------------------------------------------
--end CR 2821
--------------start CR 3120 (1)---------------------
      CURSOR change_funding_rev_curs (c_esn IN VARCHAR2)
      IS
         SELECT   MAX (a.objid), a.x_esn
             FROM table_x_autopay_details a, sa.x_receive_ftp_auto b
            WHERE b.date_received >= TRUNC (SYSDATE - 7)
              AND b.pay_type_ind = 'REV'
              AND b.esn = a.x_esn
              AND a.x_account_status = '5'
              AND a.x_status = 'E'
              AND a.x_esn = c_esn
         GROUP BY a.objid, a.x_esn;

      change_funding_rev_rec    change_funding_rev_curs%ROWTYPE;

      CURSOR change_funding_rev1_curs (c_esn IN VARCHAR2)
      IS
         SELECT *
           FROM table_x_autopay_details
          WHERE x_account_status = '5' AND x_status = 'E' AND x_esn = c_esn;

      change_funding_rev1_rec   change_funding_rev1_curs%ROWTYPE;
      --------------end CR 3120 (1) ---------------------
      rec_rpk_promo             cur_rpk_promo%ROWTYPE;
      v_procedure_name          VARCHAR2 (100)
                           := 'INBOUND_ELOCKNOTE_PKG.ACTIVE_PROGRAM_ELOCK_prc';
      l_expire_date_changed     BOOLEAN                            := FALSE;
------------------------------------------------------------
   BEGIN
------------------------------------------------------------
      OPEN check4_curs (p_accountnumber, p_paymentmode);

      FETCH check4_curs
       INTO check4_rec;

      IF check4_curs%FOUND
      THEN
         check4_boolean := TRUE;
      ELSE
         check4_boolean := FALSE;
      END IF;

      CLOSE check4_curs;

------------------------------------------------------------
      OPEN expire_dt_c;

      FETCH expire_dt_c
       INTO expire_dt_rec;

      IF expire_dt_c%NOTFOUND
      THEN
         OPEN check3_curs (p_accountnumber);

         FETCH check3_curs
          INTO check3_rec;

         IF check3_curs%FOUND
         THEN
            UPDATE x_autopay_pending
               SET x_receive_status = 'Y',
                   x_cycle_number = p_cyclenumber,
                   x_creation_date = TO_DATE (p_creationdate, 'yyyymmdd'),
                   x_program_type = p_paymentmode,
                   x_account_status = 3,
                   x_status = p_status,
                   x_first_name = p_firstname,
                   x_last_name = p_lastname,
                   x_transaction_amount = p_transactionamount,
                   x_uniquerecord = p_uniquerecord,
                   x_enroll_fee_flag = p_enrollfeeflag,
                   x_promocode = p_promocode
             WHERE objid = check3_rec.objid;

            CLOSE check3_curs;

            RETURN;
         END IF;

         CLOSE check3_curs;
      END IF;

      CLOSE expire_dt_c;

------------------------------------------------------------------
      DBMS_OUTPUT.put_line ('p_enrollFeeFlag:' || p_enrollfeeflag);
      c_p_status := 'S';
      p_msg := 'Successful';

      IF (p_status = 'A')
      THEN
         DBMS_OUTPUT.put_line ('p_status = A');

------------------------------------------------------------------------------------------
         OPEN cur_ph_c;

         FETCH cur_ph_c
          INTO rec_ph;

         CLOSE cur_ph_c;

         DBMS_OUTPUT.put_line ('cnt:1');
------------------------------------------------------------------------------------------
         v_part_inst_objid :=
                   sp_runtime_promo.get_esn_part_inst_objid (p_accountnumber);

------------------------------------------------------------------------------------------
         OPEN expire_dt_c;

         DBMS_OUTPUT.put_line ('cnt:1:1');

         FETCH expire_dt_c
          INTO expire_dt_rec;

         DBMS_OUTPUT.put_line ('cnt:1:2');

         IF expire_dt_c%NOTFOUND
         THEN
            OPEN check_pending_curs (p_accountnumber);

            FETCH check_pending_curs
             INTO check_pending_rec;

            DBMS_OUTPUT.put_line ('cnt:1:3');

            IF check_pending_curs%NOTFOUND
            THEN
               DBMS_OUTPUT.put_line ('cnt:1:4');
               DBMS_OUTPUT.put_line ('p_cycleNumber:' || p_cyclenumber);
               DBMS_OUTPUT.put_line ('p_creationDate:' || p_creationdate);
               DBMS_OUTPUT.put_line ('p_accountNumber:' || p_accountnumber);
               DBMS_OUTPUT.put_line ('p_paymentMode:' || p_paymentmode);
               DBMS_OUTPUT.put_line ('p_accountStatus:' || p_accountstatus);
               DBMS_OUTPUT.put_line ('p_status:' || p_status);
               DBMS_OUTPUT.put_line ('p_firstName:' || p_firstname);
               DBMS_OUTPUT.put_line ('p_lastName:' || p_lastname);
               DBMS_OUTPUT.put_line ('p_paymentmode:' || p_paymentmode);

               INSERT INTO x_autopay_pending
                           (objid, x_cycle_number,
                            x_creation_date,
                            x_esn, x_program_type, x_account_status,
                            x_status, x_start_date, x_first_name,
                            x_last_name,
--             X_ENROLL_DATE                  ,
                            x_program_name,
                            x_autopay_details2site_part,
                            x_autopay_details2x_part_inst,
                            x_autopay_details2contact, x_receive_status,
                            x_address1, x_city, x_state, x_zipcode,
                            x_contact_phone, x_end_date, x_agent_id,
                            x_transaction_type, x_source_flag,
                            x_transaction_amount, x_promocode,
                            x_enroll_fee_flag, x_uniquerecord
                           )
                    VALUES (
                            -- 04/10/03 SEQ_X_AUTOPAY_DETAILS.nextval + power(2,28),
                            seq ('x_autopay_details'), p_cyclenumber,
                            (TO_DATE (p_creationdate, 'yyyymmdd')
                            ),
                            p_accountnumber, p_paymentmode, 3,
                            p_status, SYSDATE, p_firstname,
                            p_lastname,

                            --         sysdate, --(TO_DATE(p_createiondate,'yyyy mm dd')),
                            (DECODE (p_paymentmode,
                                     2, 'AutoPay',
                                     3, 'Bonus Plan',
                                     4, 'Deactivation Protection'
                                    )
                            ),
                            NULL,
                            NULL,
                            NULL,
--CR1898 Vadapa 09/09/03
--             null,
--             'Y',
                            'Y',
                            NULL,
--End CR1898
                            NULL, NULL, NULL,
                            NULL, NULL, NULL,
                            NULL, 'E',
                            p_transactionamount,                    --sl null,
                                                p_promocode,        --sl null,
                            p_enrollfeeflag, p_uniquerecord
                           );

               DBMS_OUTPUT.put_line ('cnt:1:5');
            ELSE
               UPDATE x_autopay_pending
                  SET x_status = 'A',
                      x_source_flag = 'B',
                      x_uniquerecord = p_uniquerecord,
                      x_enroll_fee_flag = p_enrollfeeflag,
                      x_promocode = p_promocode,                          --sl
                      x_transaction_amount = p_transactionamount          --sl
                WHERE objid = check_pending_rec.objid;
            END IF;

            CLOSE check_pending_curs;

            CLOSE expire_dt_c;

            c_p_status := 'S';
            p_msg := 'Successful';
            DBMS_OUTPUT.put_line ('c_p_status:' || c_p_status);
            DBMS_OUTPUT.put_line ('p_msg:' || p_msg);
            RETURN;
            DBMS_OUTPUT.put_line ('cnt:2');
         ELSE
            DBMS_OUTPUT.put_line ('cnt:3');

            OPEN check_autopay_curs (p_accountnumber);

            FETCH check_autopay_curs
             INTO check_autopay_rec;

            IF check_autopay_curs%NOTFOUND
            THEN
               DBMS_OUTPUT.put_line ('cnt:3:1');

               OPEN check_pending_curs (p_accountnumber);

               FETCH check_pending_curs
                INTO check_pending_rec;

               IF check_pending_curs%FOUND
               THEN
                  DBMS_OUTPUT.put_line ('cnt:3:2');

                  UPDATE x_autopay_pending
                     SET x_status = 'A',
                         x_enroll_fee_flag = p_enrollfeeflag,
                         x_source_flag = 'B',
                         x_uniquerecord = p_uniquerecord,
                         x_promocode = p_promocode,                       --sl
                         x_transaction_amount = p_transactionamount       --sl
                   WHERE objid = check_pending_rec.objid;

                  CLOSE expire_dt_c;

                  CLOSE check_pending_curs;

                  CLOSE check_autopay_curs;

                  c_p_status := 'S';
                  p_msg := 'Successful';
                  DBMS_OUTPUT.put_line ('c_p_status:' || c_p_status);
                  DBMS_OUTPUT.put_line ('p_msg:' || p_msg);
                  RETURN;
               END IF;

               CLOSE check_pending_curs;
            END IF;

            CLOSE check_autopay_curs;
         END IF;

         CLOSE expire_dt_c;

------------------------------------------------------------------------------------------
         IF NOT check4_boolean
         THEN
            --start CR 2821
            OPEN change_funding_dpp_curs (p_accountnumber);

            FETCH change_funding_dpp_curs
             INTO change_funding_dpp_rec;

            --end CR 2821
            DBMS_OUTPUT.put_line ('cnt:4');

      --- start CR 3120 (2) ----------------
--      IF p_paymentmode in( 2,3,4) and( expire_dt_rec.x_expire_dt-sysdate ) < 90 THEN          --Check for 90 Days
            IF     p_paymentmode IN (2, 3, 4)
               AND (expire_dt_rec.x_expire_dt - SYSDATE) < 120
            THEN
               IF p_paymentmode IN (2, 3)
               THEN
--          IF (expire_dt_rec.x_expire_dt-sysdate) < 58 then  --Check for 58 days
                  IF (expire_dt_rec.x_expire_dt - SYSDATE) < 88
                  THEN                                    --Check for 88 days
                     expire_dt_rec.x_expire_dt :=
                                               expire_dt_rec.x_expire_dt + 32;
                  --32 Free Days
                  ELSE
--            expire_dt_rec.x_expire_dt := expire_dt_rec.x_expire_dt + 90-(expire_dt_rec.x_expire_dt-sysdate);
                     expire_dt_rec.x_expire_dt :=
                          expire_dt_rec.x_expire_dt
                        + 120
                        - (expire_dt_rec.x_expire_dt - SYSDATE);
                  END IF;
               ELSIF p_paymentmode IN (4) AND p_enrollfeeflag != 'Y'
               THEN
--          IF (expire_dt_rec.x_expire_dt-sysdate) < 68 then   --Check for 68 days
                  IF (expire_dt_rec.x_expire_dt - SYSDATE) < 98
                  THEN                                    --Check for 98 days
                     expire_dt_rec.x_expire_dt :=
                                               expire_dt_rec.x_expire_dt + 22;
                  --   Max 22 Days
                  ELSE
--            expire_dt_rec.x_expire_dt := expire_dt_rec.x_expire_dt + 90-(expire_dt_rec.x_expire_dt-sysdate);
                     expire_dt_rec.x_expire_dt :=
                          expire_dt_rec.x_expire_dt
                        + 120
                        - (expire_dt_rec.x_expire_dt - SYSDATE);
                  END IF;
               --start CR 2821
               ELSIF     p_paymentmode IN (4)
                     AND p_enrollfeeflag = 'Y'
                     AND change_funding_dpp_curs%FOUND
               THEN
--          IF (expire_dt_rec.x_expire_dt-sysdate) < 70 then   --Check for 68 days
                  IF (expire_dt_rec.x_expire_dt - SYSDATE) < 100
                  THEN                                   --Check for 100 days
                     expire_dt_rec.x_expire_dt :=
                                               expire_dt_rec.x_expire_dt + 20;
                  --   Max 20 Days
                  ELSE
--            expire_dt_rec.x_expire_dt := expire_dt_rec.x_expire_dt + 90-(expire_dt_rec.x_expire_dt-sysdate);
                     expire_dt_rec.x_expire_dt :=
                          expire_dt_rec.x_expire_dt
                        + 120
                        - (expire_dt_rec.x_expire_dt - SYSDATE);
                  END IF;

                  CLOSE change_funding_dpp_curs;
               --end CR 2821
               END IF;

        -- end CR 3120 (2) ----------------
------------------------------------------------------------------------------------------
               DBMS_OUTPUT.put_line ('cnt:5');

--CR6318
--                UPDATE table_site_part
--                   SET x_expire_dt = expire_dt_rec.x_expire_dt,
--                       warranty_date = expire_dt_rec.x_expire_dt
--                 WHERE s_serial_no = p_accountnumber AND part_status = 'Active';
               UPDATE table_site_part
                  SET x_expire_dt = expire_dt_rec.x_expire_dt,
                      warranty_date = expire_dt_rec.x_expire_dt
                WHERE x_service_id = p_accountnumber
                      AND part_status = 'Active';

--CR6318
------------------------------------------------------------------------------------------
               DBMS_OUTPUT.put_line ('cnt:6');

               UPDATE table_part_inst
                  SET warr_end_date = expire_dt_rec.x_expire_dt
                WHERE x_domain = 'PHONES' AND part_serial_no = p_accountnumber;

------------------------------------------------------------------------------------------
               DBMS_OUTPUT.put_line ('cnt:7');

               INSERT INTO table_x_pi_hist
                           (objid, status_hist2x_code_table,
                            x_change_date,
                            x_change_reason,
                            x_cool_end_date, x_creation_date,
                            x_deactivation_flag, x_domain,
                            x_ext, x_insert_date, x_npa,
                            x_nxx, x_old_ext, x_old_npa, x_old_nxx,
                            x_part_bin,
                            x_part_inst_status,
                            x_part_mod, x_part_serial_no,
                            x_part_status, x_pi_hist2carrier_mkt,
                            x_pi_hist2inv_bin, x_pi_hist2part_inst,
                            x_pi_hist2part_mod,
                            x_pi_hist2user,
                            x_pi_hist2x_new_pers,
                            x_pi_hist2x_pers, x_po_num,
                            x_reactivation_flag, x_red_code,
                            x_sequence, x_warr_end_date,
                            dev, fulfill_hist2demand_dtl,
                            part_to_esn_hist2part_inst, x_bad_res_qty,
                            x_date_in_serv, x_good_res_qty,
                            x_last_cycle_ct, x_last_mod_time,
                            x_last_pi_date, x_last_trans_time,
                            x_next_cycle_ct, x_order_number,
                            x_part_bad_qty, x_part_good_qty,
                            x_pi_tag_no, x_pick_request,
                            x_repair_date, x_transaction_id
                           )
                    VALUES ( -- 04/10/03seq_x_pi_hist.NEXTVAL + POWER (2, 28),
                            seq ('x_pi_hist'), rec_ph.status2x_code_table,
                            SYSDATE,
                            (DECODE (p_paymentmode,
                                     2, 'Autopay Plan Batch',
                                     3, 'Bonus Plan Batch',
                                     4, 'Deact Plan Batch'
                                    )
                            ),
                            rec_ph.x_cool_end_date, rec_ph.x_creation_date,
                            rec_ph.x_deactivation_flag, rec_ph.x_domain,
                            rec_ph.x_ext, rec_ph.x_insert_date, rec_ph.x_npa,
                            rec_ph.x_nxx, NULL, NULL, NULL,
                            rec_ph.part_bin,
                            (DECODE (p_enrollfeeflag, 'Y', 82, 84)
                            ),
                            rec_ph.part_mod, rec_ph.part_serial_no,
                            rec_ph.part_status, rec_ph.part_inst2carrier_mkt,
                            rec_ph.part_inst2inv_bin, rec_ph.objid,
                            rec_ph.n_part_inst2part_mod,
                            rec_ph.created_by2user,
                            rec_ph.part_inst2x_new_pers,
                            rec_ph.part_inst2x_pers, rec_ph.x_po_num,
                            rec_ph.x_reactivation_flag, rec_ph.x_red_code,
                            rec_ph.x_sequence, rec_ph.warr_end_date,
                            rec_ph.dev, rec_ph.fulfill2demand_dtl,
                            rec_ph.part_to_esn2part_inst, rec_ph.bad_res_qty,
                            rec_ph.date_in_serv, rec_ph.good_res_qty,
                            rec_ph.last_cycle_ct, rec_ph.last_mod_time,
                            rec_ph.last_pi_date, rec_ph.last_trans_time,
                            rec_ph.next_cycle_ct, rec_ph.x_order_number,
                            rec_ph.part_bad_qty, rec_ph.part_good_qty,
                            rec_ph.pi_tag_no, rec_ph.pick_request,
                            rec_ph.repair_date, rec_ph.transaction_id
                           );
            END IF;                                             ---CR 1071 End

------------------------------------------------------------------------------------------
            DBMS_OUTPUT.put_line ('cnt:8');

            OPEN pending_call_trans_curs (p_accountnumber, p_enrollfeeflag);

            FETCH pending_call_trans_curs
             INTO pending_call_trans_rec;

            IF (p_promocode != '00000') AND (p_enrollfeeflag = 'Y')
            THEN
               DBMS_OUTPUT.put_line ('cnt:9');

               OPEN promo_code_curs (p_promocode);

               FETCH promo_code_curs
                INTO promo_code_rec;

               CLOSE promo_code_curs;

               INSERT INTO table_x_promo_hist
                           (objid,
                            promo_hist2x_call_trans,
                            promo_hist2x_promotion
                           )
                    VALUES (
                            -- 04/10/03 (seq_x_promo_hist.NEXTVAL + POWER (2, 28)),
                            seq ('x_promo_hist'),
                            pending_call_trans_rec.objid,
                            promo_code_rec.objid
                           );
            END IF;

            CLOSE pending_call_trans_curs;

            UPDATE table_x_call_trans
               SET x_result = 'Completed',
                   x_transact_date = SYSDATE
             WHERE objid = pending_call_trans_rec.objid;
         END IF;

         OPEN check_ftp_curs;

         FETCH check_ftp_curs
          INTO check_ftp_rec;

         IF check_ftp_curs%NOTFOUND
         THEN
            INSERT INTO x_receive_ftp_auto
                        (rec_seq_no,
                         cycle_number, pay_type_ind,
                         date_received,
                         trans_amount, esn, first_name,
                         last_name, return_code, program_type,
                         unique_rec_no, enroll_flag, promo_code
                        )
                 VALUES (seq_x_receive_ftp_auto.NEXTVAL + POWER (2, 28),
                         p_cyclenumber, p_type_i,
                         TO_DATE (p_creationdate, 'yyyymmdd'),
                         p_transactionamount, p_accountnumber, p_firstname,
                         p_lastname, p_accountstatus, p_paymentmode,
                         p_uniquerecord, p_enrollfeeflag, p_promocode
                        );
         END IF;

         CLOSE check_ftp_curs;

--/*
         IF p_enrollfeeflag = 'Y'
         THEN
            IF (p_paymentmode = 3)
            THEN
               BEGIN
                  OPEN cur_rpkb_promo_group;

                  FETCH cur_rpkb_promo_group
                   INTO rec_rpkb_promo_group;

                  IF cur_rpkb_promo_group%NOTFOUND
                  THEN
                     CLOSE cur_rpkb_promo_group;
                  ELSE
                     CLOSE cur_rpkb_promo_group;

                     OPEN cur_rpka_promo (rec_ph.objid);

                     FETCH cur_rpka_promo
                      INTO rec_group2esn;

                     IF cur_rpka_promo%NOTFOUND
                     THEN
                        CLOSE cur_rpka_promo;
                     ELSE
                        CLOSE cur_rpka_promo;

                        INSERT INTO table_x_group_hist
                                    (objid,
                                     x_start_date,
                                     x_end_date, x_action_date,
                                     x_action_type,
                                     x_annual_plan,
                                     grouphist2part_inst,
                                     grouphist2x_promo_group,
                                     x_old_esn
                                    )
                             VALUES (
                                     -- 04/10/03 seq_x_group_hist.nextval + power(2,28),
                                     seq ('x_group_hist'),
                                     rec_group2esn.x_start_date,
                                     rec_group2esn.x_end_date, SYSDATE,
                                     'REPUBLIK',
                                     rec_group2esn.x_annual_plan,
                                     rec_group2esn.groupesn2part_inst,
                                     rec_group2esn.groupesn2x_promo_group,
                                     NULL
                                    );

                        UPDATE table_x_group2esn ge
                           SET groupesn2x_promo_group =
                                                    rec_rpkb_promo_group.objid,
                               groupesn2x_promotion = NULL
                         WHERE ge.ROWID = rec_group2esn.ROWID;

                        OPEN cur_rpk_promo;

                        FETCH cur_rpk_promo
                         INTO rec_rpk_promo;

                        IF cur_rpk_promo%NOTFOUND
                        THEN
                           CLOSE cur_rpk_promo;
                        ELSE
                           CLOSE cur_rpk_promo;

                           IF get_promo_usage_fun (p_accountnumber,
                                                   expire_dt_rec.objid,
                                                   rec_rpk_promo.x_promo_code
                                                  ) = 0
                           THEN
                              INSERT INTO table_x_pending_redemption
                                          (objid,
                                           pend_red2x_promotion,
                                           x_pend_red2site_part, x_pend_type
                                          )
                                   VALUES (
                                           -- 04/10/03 SEQ_X_PENDING_REDEMPTION.nextval + power(2,28),
                                           seq ('x_pending_redemption'),
                                           rec_rpk_promo.objid,
                                           expire_dt_rec.objid, 'FREE'
                                          );
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     ROLLBACK;
                     c_p_status := 'F';
                     p_msg :=
                           'Error ocurred when transfering republik option A to B for this esn '
                        || p_accountnumber;
                     RETURN;
               END;
            END IF;

            OPEN cur_x_autopay_contact_c (p_accountnumber);

            FETCH cur_x_autopay_contact_c
             INTO rec_x_autopay_contact;

            CLOSE cur_x_autopay_contact_c;

            OPEN cur_contact_info (p_accountnumber);

            FETCH cur_contact_info
             INTO rec_contact_info;

            CLOSE cur_contact_info;

            OPEN state_curs (rec_x_autopay_contact.state);

            FETCH state_curs
             INTO state_rec;

            CLOSE state_curs;

            UPDATE table_contact
               SET address_1 = rec_x_autopay_contact.address,
                   city = rec_x_autopay_contact.city,
                   state = rec_x_autopay_contact.state,
                   zipcode = rec_x_autopay_contact.zip,
                   x_autopay_update_flag = 1
             WHERE objid = rec_contact_info.contact_role2contact;

            UPDATE table_contact
               SET phone = rec_x_autopay_contact.phone
             WHERE objid = rec_contact_info.contact_role2contact
               AND phone || '' != rec_x_autopay_contact.phone;

            -- 12/03/02 IF rec_contact_info.CUST_billaddr2ADDRESS!=NULL THEN
            IF rec_contact_info.cust_billaddr2address IS NOT NULL
            THEN
               UPDATE table_address
                  SET address = rec_x_autopay_contact.address,
                      s_address = UPPER (rec_x_autopay_contact.address),
                      s_city = UPPER (rec_x_autopay_contact.city),
                      s_state = UPPER (rec_x_autopay_contact.state),
                      city = rec_x_autopay_contact.city,
                      state = rec_x_autopay_contact.state,
                      zipcode = rec_x_autopay_contact.zip
                WHERE objid = rec_contact_info.contact_role2contact;
            ELSE
               -- 04/10/03
               SELECT seq ('address')
                 INTO v_hold_seq_num
                 FROM DUAL;

               INSERT INTO table_address
                           (objid, address,
                            s_address,
                            city,
                            s_city,
                            state,
                            s_state,
                            zipcode, address_2, dev, address2time_zone,
                            address2country, address2state_prov,
                            update_stamp
                           )
                    VALUES (  -- 04/10/03 seq_address.NEXTVAL + POWER (2, 28),
                            v_hold_seq_num, rec_x_autopay_contact.address,
                            UPPER (rec_x_autopay_contact.address),
                            rec_x_autopay_contact.city,
                            UPPER (rec_x_autopay_contact.city),
                            rec_x_autopay_contact.state,
                            UPPER (rec_x_autopay_contact.state),
                            rec_x_autopay_contact.zip, NULL, NULL, NULL,
                            state_rec.state_prov2country, state_rec.objid,
                            NULL
                           );

               UPDATE table_site
                  -- 4/10/03     set CUST_BILLADDR2ADDRESS=seq_address.currVAL + POWER (2, 28)
               SET cust_billaddr2address = v_hold_seq_num
                WHERE objid = rec_contact_info.site_objid;

               DELETE FROM x_autopay_contact
                     WHERE esn = p_accountnumber;
            END IF;

            UPDATE table_x_autopay_details
               SET x_status = p_status,
                   x_receive_status = 'Y',
                   x_start_date = SYSDATE                            --CR 1157
             WHERE x_esn = p_accountnumber
               AND x_status = 'E'
               AND x_program_type = p_paymentmode;

            --added as a correction-Suganthi.
            DELETE FROM x_autopay_contact
                  WHERE esn = p_accountnumber;
         ELSE
            UPDATE table_x_autopay_details
               SET
                   -- x_status = p_status ,--to fix double 'A' records --Suganthi03072003
                   x_receive_status = 'Y'
             WHERE x_esn = p_accountnumber
               AND x_program_type = p_paymentmode
               AND x_status = p_status;                             --03072003
         END IF;
--*/
      ELSE                                           -- p_status not equal 'A'
         DBMS_OUTPUT.put_line ('p_status not equal A');

----------------------------------------------------------------------
         OPEN cur_ph_d_c;

         FETCH cur_ph_d_c
          INTO rec_ph_d;

         CLOSE cur_ph_d_c;

----------------------------------------------------------------
         OPEN expire_dt_d_c;

         FETCH expire_dt_d_c
          INTO expire_dt_d_rec;

         CLOSE expire_dt_d_c;

----------------------------------------------------------------
      --start CR1386
         OPEN active_autopay_curs (p_paymentmode, p_accountnumber);

         FETCH active_autopay_curs
          INTO active_autopay_rec;

         CLOSE active_autopay_curs;

      --end CR1386
----------------start CR CR 3120 (1) ------------------
         OPEN change_funding_rev_curs (p_accountnumber);

         FETCH change_funding_rev_curs
          INTO change_funding_rev_rec;

         OPEN change_funding_rev1_curs (p_accountnumber);

         FETCH change_funding_rev1_curs
          INTO change_funding_rev1_rec;

         IF change_funding_rev_curs%NOTFOUND
         THEN
            IF change_funding_rev1_curs%FOUND
            THEN
               INSERT INTO x_receive_ftp_auto
                           (rec_seq_no,
                            cycle_number, pay_type_ind,
                            date_received,
                            trans_amount, esn,
                            first_name, last_name, return_code,
                            program_type, unique_rec_no, enroll_flag,
                            promo_code
                           )
                    VALUES (seq_x_receive_ftp_auto.NEXTVAL + POWER (2, 28),
                            p_cyclenumber, p_type_i,
                            TO_DATE (p_creationdate, 'yyyymmdd'),
                            p_transactionamount, p_accountnumber,
                            p_firstname, p_lastname, p_accountstatus,
                            p_paymentmode, p_uniquerecord, p_enrollfeeflag,
                            p_promocode
                           );

               RETURN;

               CLOSE change_funding_rev_curs;

               CLOSE change_funding_rev1_curs;
            END IF;
         END IF;

         CLOSE change_funding_rev1_curs;

         CLOSE change_funding_rev_curs;

--------------- end CR 3120 (1) --------------------
-------start CR 3120 (3) -----------------------
--    open change_date_curs(p_paymentmode,p_accountnumber);
--     fetch change_date_curs into change_date_rec;
--    if change_date_curs%found then
--      dbms_output.put_line('change_date_curs%found');
--    IF change_date_rec.diff < 90 THEN     --Check for 90 Days
           /* CR2079 GP 10/24/2003; */
--         IF p_paymentmode = 4 THEN -- Deactivation Protection Plan
--              IF change_date_rec.diff < 68 THEN  --Check for 68 days
--                 change_date_rec.diff := 22; --22 Free Days
--              ELSE
--                 change_date_rec.diff :=90-change_date_rec.diff;
--              END IF;
--           ELSE
--              IF change_date_rec.diff < 58 THEN   --Check for 58 days
--                 change_date_rec.diff := 32; --32 Free Days
--              ELSE
--                 change_date_rec.diff :=90-change_date_rec.diff;
--              END IF;
--           END IF;
            /* CR2079 End ************/
--          IF expire_dt_d_rec.x_expire_dt-sysdate > change_date_rec.diff THEN
--            change_date_rec.x_warr_end_date := expire_dt_d_rec.x_expire_dt-change_date_rec.diff;
--          ELSE
--            change_date_rec.x_warr_end_date := sysdate;
--          END IF;
--
--          UPDATE table_site_part
--             SET X_EXPIRE_DT = change_date_rec.x_warr_end_date,
--                 WARRANTY_DATE = change_date_rec.x_warr_end_date
--           where S_SERIAL_NO = p_accountNumber
--             and part_status = 'Active';
--          UPDATE table_part_inst
--             SET warr_end_date = change_date_rec.x_warr_end_date
--           WHERE x_domain= 'PHONES'
--             AND part_serial_no = p_accountNumber;
--          INSERT INTO TABLE_X_PI_HIST
--          (objid,
--           status_hist2x_code_table,
--           x_change_date,
--           x_change_reason,
--           x_cool_end_date,
--           x_creation_date,
--          x_deactivation_flag,
--           x_domain,
--           x_ext,
--           x_insert_date,
--           x_npa,
--           x_nxx,
--           x_old_ext,
--           x_old_npa,
--           x_old_nxx,
--           x_part_bin,
--           x_part_inst_status,
--           x_part_mod,
--           x_part_serial_no,
--           x_part_status,
--           x_pi_hist2carrier_mkt,
--           x_pi_hist2inv_bin,
--           x_pi_hist2part_inst,
--           x_pi_hist2part_mod,
--           x_pi_hist2user,
--           x_pi_hist2x_new_pers,
--           x_pi_hist2x_pers,
--           x_po_num,
--           x_reactivation_flag,
--           x_red_code,
--           x_sequence,
--           x_warr_end_date,
--           dev,
--           fulfill_hist2demand_dtl,
--           part_to_esn_hist2part_inst,
--           x_bad_res_qty,
--           x_date_in_serv,
--          x_good_res_qty,
--           x_last_cycle_ct,
--           x_last_mod_time,
--           x_last_pi_date,
--           x_last_trans_time,
--           x_next_cycle_ct,
--           x_order_number,
--          x_part_bad_qty,
--           x_part_good_qty,
--           x_pi_tag_no,
--           x_pick_request,
--           x_repair_date,
--           x_transaction_id)
--          VALUES
--          ( -- 04/10/03 seq_x_pi_hist.NEXTVAL + POWER (2, 28),
--           seq('x_pi_hist'),
--           rec_ph_d.status2x_code_table,
--           SYSDATE,
--           (decode(p_paymentmode,2,'Autopay Plan Batch',
--                                 3,'Bonus Plan Batch',
--                                 4,'Deact Plan Batch')),
--           rec_ph_d.x_cool_end_date,
--           rec_ph_d.x_creation_date,
--           rec_ph_d.x_deactivation_flag,
--           rec_ph_d.x_domain,
--           rec_ph_d.x_ext,
--           rec_ph_d.x_insert_date,
--           rec_ph_d.x_npa,
--           rec_ph_d.x_nxx,
--           NULL,
--           NULL,
--           NULL,
--           rec_ph_d.part_bin,
--           decode(p_enrollFeeFlag ,'Y',82,84),
--           rec_ph_d.part_mod,
--           rec_ph_d.part_serial_no,
--           rec_ph_d.part_status,
--           rec_ph_d.part_inst2carrier_mkt,
--           rec_ph_d.part_inst2inv_bin,
--           rec_ph_d.objid,
--           rec_ph_d.n_part_inst2part_mod,
--           rec_ph_d.created_by2user,
--           rec_ph_d.part_inst2x_new_pers,
--           rec_ph_d.part_inst2x_pers,
--           rec_ph_d.x_po_num,
--           rec_ph_d.x_reactivation_flag,
--           rec_ph_d.x_red_code,
--           rec_ph_d.x_sequence,
--           rec_ph_d.warr_end_date,
--           rec_ph_d.dev,
--           rec_ph_d.fulfill2demand_dtl,
--           rec_ph_d.part_to_esn2part_inst,
--           rec_ph_d.bad_res_qty,
--           rec_ph_d.date_in_serv,
--          rec_ph_d.good_res_qty,
--           rec_ph_d.last_cycle_ct,
--           rec_ph_d.last_mod_time,
--           rec_ph_d.last_pi_date,
--           rec_ph_d.last_trans_time,
--           rec_ph_d.next_cycle_ct,
--           rec_ph_d.x_order_number,
--           rec_ph_d.part_bad_qty,
--           rec_ph_d.part_good_qty,
--           rec_ph_d.pi_tag_no,
--           rec_ph_d.pick_request,
--           rec_ph_d.repair_date,
--           rec_ph_d.transaction_id);
--        END IF;
--      end if;
--    close change_date_curs;
---- End CR 3120 (3) ----
         IF (p_enrollfeeflag != 'Y')
         THEN
                    /*
                    open active_autopay_curs(p_paymentMode,p_accountnumber);
                    fetch active_autopay_curs into active_autopay_rec;
                    --if active_autopay_curs%notfound then
                    if active_autopay_curs%found then -- fixed by Suganthi
            dbms_output.Put_line('active_autopay_curs%notfound');
                      open max_send_ftp_auto_curs;
                        fetch max_send_ftp_auto_curs into max_send_ftp_auto_rec;
                      close max_send_ftp_auto_curs;
                      INSERT INTO X_SEND_FTP_AUTO
                      (SEND_SEQ_NO,
                       FILE_TYPE_IND,
                       ESN,
                       PROGRAM_TYPE,
                       ACCOUNT_STATUS,
                       AMOUNT_DUE)
                      VALUES
                      (max_send_ftp_auto_rec.max_send_seq_no,
                       'D',
                       p_accountnumber,
                       active_autopay_rec.x_program_type,
                       'D',
                       0);
                        end if;   */ --CR 1386
            UPDATE table_x_autopay_details
               SET x_status = p_status,
                   x_end_date = SYSDATE,
                   x_account_status = 9,
                   x_receive_status = 'Y'
             WHERE x_esn = p_accountnumber
               AND x_status = 'A'
               AND x_program_type = p_paymentmode;
         --close active_autopay_curs;
         ELSE
            DBMS_OUTPUT.put_line ('p_enrollFeeFlag =Y');

            /*--CR 1157
            delete from TABLE_X_AUTOPAY_DETAILS
            where X_ESN=p_accountNumber
            and  X_STATUS='E'
            and  x_program_type=p_paymentmode;
            */
            DELETE FROM x_autopay_contact
                  WHERE esn = p_accountnumber;

            UPDATE table_x_autopay_details
               SET x_status = p_status,
                   x_end_date = SYSDATE,
                   x_account_status = 9,
                   x_receive_status = 'Y'
             WHERE x_esn = p_accountnumber
               AND x_status IN ('A', 'E')                            --CR 1157
               AND x_program_type = p_paymentmode;
         END IF;

         OPEN max_call_trans_curs (p_accountnumber, p_enrollfeeflag);

         FETCH max_call_trans_curs
          INTO max_call_trans_rec;

         IF max_call_trans_curs%FOUND
         THEN
            DBMS_OUTPUT.put_line (   'max_call_trans_curs%found:'
                                  || max_call_trans_rec.objid
                                 );

            IF (p_promocode != '00000') AND (p_enrollfeeflag = 'Y')
            THEN
               OPEN promo_code_curs (p_promocode);

               FETCH promo_code_curs
                INTO promo_code_rec;

               CLOSE promo_code_curs;

               INSERT INTO table_x_promo_hist
                           (objid,
                            promo_hist2x_call_trans,
                            promo_hist2x_promotion
                           )
                    VALUES (
                            -- 04/10/03 (seq_x_promo_hist.NEXTVAL + POWER (2, 28)),
                            seq ('x_promo_hist'),
                            pending_call_trans_rec.objid,
                            promo_code_rec.objid
                           );
            END IF;

            UPDATE table_x_call_trans
               SET x_result = 'Failed',
                   x_transact_date = SYSDATE
             WHERE objid = max_call_trans_rec.objid;
         END IF;

         CLOSE max_call_trans_curs;

         DBMS_OUTPUT.put_line ('INSERT INTO X_RECEIVE_FTP_AUTO');

         --start CR 1157
         OPEN sp_curs_c (expire_dt_rec.objid);

         FETCH sp_curs_c
          INTO sp_curs_rec;

         CLOSE sp_curs_c;

         OPEN user_curs ('SA');

         FETCH user_curs
          INTO user_rec;

         CLOSE user_curs;

         INSERT INTO table_x_call_trans
                     (objid, call_trans2site_part,
                      x_action_type,
                      x_call_trans2carrier, x_call_trans2dealer,
                      x_call_trans2user, x_line_status, x_min,
                      x_service_id, x_sourcesystem,
                      x_transact_date, x_total_units, x_action_text,
                      x_reason, x_result, x_sub_sourcesystem
                     )
              VALUES (seq ('x_call_trans'), sp_curs_rec.site_part_objid,
                      (DECODE (p_status, 'E', '82', 'I', '83')
                      ),
                      sp_curs_rec.carrier_objid, sp_curs_rec.site_objid,
                      user_rec.objid, '13', sp_curs_rec.x_min,
                      p_accountnumber, 'AUTOPAY_BATCH',
                      (SYSDATE + (1 / 86400)
                      ), 0, 'STAYACT UNSUBSCRIBE',
                      'Payment Failure-Rev', 'Pending', '202'
                     );

         --end CR 1157
         INSERT INTO x_receive_ftp_auto
                     (rec_seq_no,
                      cycle_number, pay_type_ind,
                      date_received,
                      trans_amount, esn, first_name,
                      last_name, return_code, program_type,
                      unique_rec_no, enroll_flag, promo_code
                     )
              VALUES (seq_x_receive_ftp_auto.NEXTVAL + POWER (2, 28),
                      p_cyclenumber, p_type_i,
                      TO_DATE (p_creationdate, 'yyyymmdd'),
                      p_transactionamount, p_accountnumber, p_firstname,
                      p_lastname, p_accountstatus, p_paymentmode,
                      p_uniquerecord, p_enrollfeeflag, p_promocode
                     );

         DBMS_OUTPUT.put_line ('INSERTED INTO X_RECEIVE_FTP_AUTO');

         --open check_pending_curs(p_accountnumber);
         -- fetch check_pending_curs into check_pending_rec;
         --  if check_pending_curs%found then
         OPEN check_pending2_curs (p_accountnumber);

         FETCH check_pending2_curs
          INTO check_pending2_rec;

         IF check_pending2_curs%FOUND
         THEN
            UPDATE x_autopay_pending
               SET x_status = p_status
             WHERE objid = check_pending2_rec.objid;
         END IF;

         --start CR 1386
         IF active_autopay_rec.x_account_status = 5
         THEN
            OPEN max_send_ftp_auto_curs;

            FETCH max_send_ftp_auto_curs
             INTO max_send_ftp_auto_rec;

            CLOSE max_send_ftp_auto_curs;

            INSERT INTO x_send_ftp_auto
                        (send_seq_no, file_type_ind,
                         esn, program_type,
                         account_status, amount_due
                        )
                 VALUES (max_send_ftp_auto_rec.max_send_seq_no, 'D',
                         p_accountnumber, active_autopay_rec.x_program_type,
                         'D', 0
                        );

            RETURN;
         END IF;

         --end CR 1386
         OPEN check_funding_curs (p_accountnumber);

         FETCH check_funding_curs
          INTO check_funding_rec;

         IF check_funding_curs%FOUND
         THEN
            inbound_biller_pkg.main_prc
                                (check_funding_rec.x_cycle_number,
                                 TO_CHAR (check_funding_rec.x_creation_date,
                                          'yyyymmdd'
                                         ),
                                 --check_pending_rec.X_CREATION_DATE,--CR1386
                                 check_funding_rec.x_esn,
                                 TO_CHAR (check_funding_rec.x_enroll_date,
                                          'yyyymmdd'
                                         ),
                                 --check_pending_rec.X_ENROLL_DATE,
                                 check_funding_rec.x_program_type,
                                 check_funding_rec.x_account_status,
                                 check_funding_rec.x_status,
                                 check_funding_rec.x_first_name,
                                 check_funding_rec.x_last_name,
                                 check_funding_rec.x_address1,
                                 check_funding_rec.x_city,
                                 check_funding_rec.x_state,
                                 check_funding_rec.x_zipcode,
                                 check_funding_rec.x_contact_phone,
                                 v_msg,
                                 v_p_status
                                );

            INSERT INTO x_autopay_pending_hist
                        (objid,
                         x_creation_date,
                         x_esn,
                         x_program_type,
                         x_account_status,
                         x_status,
                         x_start_date,
                         x_end_date,
                         x_cycle_number,
                         x_program_name,
                         x_enroll_date,
                         x_first_name,
                         x_last_name,
                         x_receive_status,
                         x_agent_id,
                         x_autopay_details2site_part,
                         x_autopay_details2x_part_inst,
                         x_autopay_details2contact,
                         x_transaction_type,
                         x_source_flag,
                         x_address1,
                         x_city, x_state,
                         x_zipcode,
                         x_contact_phone,
                         x_transaction_amount,
                         x_promocode,
                         x_enroll_fee_flag, x_insert_date,
                         x_uniquerecord
                        )
                 VALUES (check_funding_rec.objid,
                         check_funding_rec.x_creation_date,
                         check_funding_rec.x_esn,
                         check_funding_rec.x_program_type,
                         check_funding_rec.x_account_status,
                         check_funding_rec.x_status,
                         check_funding_rec.x_start_date,
                         check_funding_rec.x_end_date,
                         check_funding_rec.x_cycle_number,
                         check_funding_rec.x_program_name,
                         check_funding_rec.x_enroll_date,
                         check_funding_rec.x_first_name,
                         check_funding_rec.x_last_name,
                         check_funding_rec.x_receive_status,
                         check_funding_rec.x_agent_id,
                         check_funding_rec.x_autopay_details2site_part,
                         check_funding_rec.x_autopay_details2x_part_inst,
                         check_funding_rec.x_autopay_details2contact,
                         check_funding_rec.x_transaction_type,
                         check_funding_rec.x_source_flag,
                         check_funding_rec.x_address1,
                         check_funding_rec.x_city, check_funding_rec.x_state,
                         check_funding_rec.x_zipcode,
                         check_funding_rec.x_contact_phone,
                         check_funding_rec.x_transaction_amount,
                         check_funding_rec.x_promocode,
                         check_funding_rec.x_enroll_fee_flag, SYSDATE,
                         check_funding_rec.x_uniquerecord
                        );

            DELETE FROM x_autopay_pending
                  WHERE objid = check_funding_rec.objid;
         END IF;

         --close check_pending_curs;
         CLOSE check_funding_curs;
      END IF;

      DBMS_OUTPUT.put_line ('c_p_status:' || c_p_status);
      DBMS_OUTPUT.put_line ('p_msg:' || p_msg);
------------------------------------------------------------------------------------------
   EXCEPTION
      WHEN OTHERS
      THEN
         c_p_status := 'F';
         p_msg := 'Failure >> ' || SUBSTR (SQLERRM, 1, 100);
   END main_prc;
END inbound_elocknote_pkg;
/