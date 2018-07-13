CREATE OR REPLACE PROCEDURE sa."SP_DUGGI_IGATE" AS

      --
      CURSOR ig_trans_curs
      IS
         SELECT a.*, a.ROWID
           FROM gw1.ig_transaction a
         WHERE  action_item_id = '52988457'
         and status IN ('E', 'W');

      --    ig_trans_rec ig_trans_curs%rowtype;
      --
      CURSOR ig_wi_detail_curs (c_transaction_id IN NUMBER)
      IS
         SELECT *
           FROM gw1.ig_wi_detail
          WHERE wi_id = c_transaction_id;

      ig_wi_detail_rec            ig_wi_detail_curs%ROWTYPE;

      --
      CURSOR task_curs (c_task_id IN VARCHAR2)
      IS
         SELECT *
           FROM table_task
          WHERE task_id = c_task_id;

      task_rec                    task_curs%ROWTYPE;

      --
      CURSOR user_curs (c_objid IN NUMBER)
      IS
         SELECT *
           FROM table_user
          WHERE objid = c_objid;

      user_rec                    user_curs%ROWTYPE;

      --
      CURSOR call_trans_curs (c_objid IN NUMBER)
      IS
         SELECT *
           FROM table_x_call_trans
          WHERE objid = c_objid;

      call_trans_rec              call_trans_curs%ROWTYPE;

      --
      -- OTA
      --
      CURSOR ota_call_trans_curs (c_part_serial_no IN VARCHAR2)
      IS
         SELECT   *
             FROM table_x_call_trans
            WHERE x_service_id = c_part_serial_no
         ORDER BY objid DESC;

      ota_call_trans_rec          ota_call_trans_curs%ROWTYPE;

      --
      CURSOR condition_curs (c_objid IN NUMBER)
      IS
         SELECT *
           FROM table_condition
          WHERE objid = c_objid AND title LIKE 'Closed%';

      condition_rec               condition_curs%ROWTYPE;

      --
      CURSOR queue_curs (c_objid IN NUMBER)
      IS
         SELECT *
           FROM table_queue
          WHERE objid = c_objid AND title LIKE 'Intergate%';

      queue_rec                   queue_curs%ROWTYPE;

      --
      CURSOR order_type_curs (c_objid IN NUMBER)
      IS
         SELECT *
           FROM table_x_order_type
          WHERE objid = c_objid;

      order_type_rec              order_type_curs%ROWTYPE;

      --
      CURSOR trans_profile_curs (c_objid IN NUMBER)
      IS
         SELECT *
           FROM table_x_trans_profile
          WHERE objid = c_objid;

      trans_profile_rec           trans_profile_curs%ROWTYPE;

      --
      CURSOR site_part_curs (c_objid IN NUMBER)
      IS
         SELECT *
           FROM table_site_part
          WHERE objid = c_objid;

      site_part_rec               site_part_curs%ROWTYPE;

      --
      CURSOR part_num_curs (c_objid IN NUMBER)
      IS
         SELECT pn.*
           FROM table_part_num pn, table_mod_level ml
          WHERE pn.objid = ml.part_info2part_num AND ml.objid = c_objid;

      part_num_rec                part_num_curs%ROWTYPE;

      --
      CURSOR carrier_curs (c_objid IN NUMBER)
      IS
         SELECT *
           FROM table_x_carrier
          WHERE objid = c_objid;

      carrier_rec                 carrier_curs%ROWTYPE;

      --
      CURSOR retail_esn_curs
      IS
         SELECT ge.objid
           FROM table_gbst_elm ge, table_gbst_lst gl
          WHERE ge.gbst_elm2gbst_lst = gl.objid
            AND ge.title = 'Failed - Retail ESN'
            AND gl.title = 'Closed Action Item';

      retail_esn_rec              retail_esn_curs%ROWTYPE;

      --
      CURSOR failed_open_curs
      IS
         SELECT ge.objid
           FROM table_gbst_elm ge, table_gbst_lst gl
          WHERE ge.gbst_elm2gbst_lst = gl.objid
            AND ge.title = 'Failed - Open'
            AND gl.title = 'Open Action Item';

      failed_open_rec             failed_open_curs%ROWTYPE;

      --
      CURSOR queued_curs
      IS
         SELECT ge.objid
           FROM table_gbst_elm ge, table_gbst_lst gl
          WHERE ge.gbst_elm2gbst_lst = gl.objid
            AND ge.title = 'Queued'
            AND gl.title = 'Open Action Item';

      queued_rec                  queued_curs%ROWTYPE;

      --
      CURSOR failed_ntn_curs
      IS
         SELECT *
           FROM table_x_code_table
          WHERE x_code_name = 'FAILED NTN';

      failed_ntn_rec              failed_ntn_curs%ROWTYPE;

      --
      CURSOR topp_err_curs (c_carrier_objid IN NUMBER, c_message IN VARCHAR2)
      IS
         SELECT tec.*
           FROM table_x_topp_err_codes tec, table_x_carrier_err_codes cec
          WHERE tec.objid = cec.ccodes2x_topp_err_codes
            AND cec.x_code_name LIKE '%' || c_message || '%'
            AND cec.x_car_er2x_carrier = c_carrier_objid;

      topp_err_rec                topp_err_curs%ROWTYPE;

      --
      CURSOR gen_err_curs
      IS
         SELECT tec.*
           FROM table_x_topp_err_codes tec
          WHERE tec.x_code_name = 'System Malfunction';

      gen_err_rec                 gen_err_curs%ROWTYPE;

      --
      CURSOR min_curs (c_min IN VARCHAR2)
      IS
         SELECT a.*, a.ROWID
           FROM table_part_inst a
          WHERE part_serial_no = c_min;

      min_rec                     min_curs%ROWTYPE;

      --CR3440 Start
      --CR3153 - T-Mobile begin
      --     CURSOR part_inst_curs1 (c_esn VARCHAR2) IS
      --      SELECT objid, x_part_inst_status
      --       FROM TABLE_PART_INST
      --       WHERE PART_SERIAL_NO = c_esn;
      --      part_inst_rec1 part_inst_curs1%ROWTYPE;
      --
      --     CURSOR part_inst_curs2 (c_esn_objid NUMBER) IS
      --      SELECT *
      --       FROM TABLE_PART_INST
      --       WHERE part_to_esn2part_inst = c_esn_objid
      --       AND x_domain = 'LINES';
      --       --AND part_serial_no LIKE 'T%';
      --      part_inst_rec2 part_inst_curs2%ROWTYPE;
      CURSOR part_inst_curs (c_esn VARCHAR2, c_min VARCHAR2)
      IS
         SELECT line.*, esn.x_part_inst_status esn_status,
                esn.objid esn_objid
           FROM table_part_inst esn, table_part_inst line
          WHERE line.part_to_esn2part_inst = esn.objid
            AND esn.part_serial_no = c_esn
            AND line.x_domain = 'LINES'
            AND esn.x_domain = 'PHONES'
            AND line.part_serial_no = c_min;

      part_inst_rec               part_inst_curs%ROWTYPE;

      --CR3440 End
      CURSOR code_curs (c_code_number VARCHAR)
      IS
         SELECT *
           FROM table_x_code_table
          WHERE x_code_number = c_code_number;

      code_rec                    code_curs%ROWTYPE;

      --CR 3153 - T-Mobile end
      --
      -- 01/17/03
      --
      -- Start CR3918 Mchinta ver1.20 06/15/2005
      CURSOR case_curs (case_objid IN NUMBER)
      IS
         SELECT *
           FROM table_case
          WHERE objid = case_objid;

      case_rec                    case_curs%ROWTYPE;

      -- End CR3918 Mchinta ver1.20 06/15/2005
      CURSOR opened_case_curs (c_esn VARCHAR2, c_min VARCHAR2)
      IS
         SELECT c.ROWID, c.id_number, c.title, c.x_case_type, c.case_history
           FROM table_condition cd, table_case c
          WHERE cd.title LIKE 'Open%'
            AND c.case_state2condition = cd.objid
            AND c.x_esn = c_esn
            AND c.x_min = c_min;

      opened_case_rec             opened_case_curs%ROWTYPE;
      l_status                    VARCHAR2 (10);
      l_msg                       VARCHAR2 (200);

      --end 01/17/03
      --CR3327 GP
      CURSOR parent_curs (c_objid NUMBER)
      IS
         SELECT a.*
           FROM table_x_parent a, table_x_carrier_group b, table_x_carrier c
          WHERE a.objid = b.x_carrier_group2x_parent
            AND b.objid = c.carrier2carrier_group
            AND c.objid = c_objid;

      parent_rec                  parent_curs%ROWTYPE;

-- CR 5008
      CURSOR min_still_exists_curs (c_min_objid IN NUMBER)
      IS
         SELECT 1 hold
           FROM table_part_inst
          WHERE objid = c_min_objid;

      min_still_exists_rec        min_still_exists_curs%ROWTYPE;

-- End CR 5008

      -- Cingular Next Available Project:
      -- Get Closed case to reopen it
      CURSOR closed_case_cur (c_esn VARCHAR2)
      IS
         SELECT table_case.objid case_objid
           FROM table_case, table_condition
          WHERE table_condition.objid = table_case.case_state2condition
            AND table_condition.s_title LIKE 'CLOSE%'
            AND table_case.title = 'No Line Available'
            AND table_case.x_case_type = 'Line Management'
            AND table_case.x_esn = c_esn;

      closed_case_rec             closed_case_cur%ROWTYPE;
      -- Cingular Next Available Project:
      -- This error message will eventually be populated by igate.reopen_case_proc
      c_reopen_case_err_msg       VARCHAR2 (250);
-----------------------------------------------------------
-- Process status messages received from TMOBILE carrier --
-- CR4947 START                                          --
-----------------------------------------------------------
      l_b_tmobile_msg_processed   BOOLEAN                         := FALSE;

-----------------------------------------------------------
-- CR4947 END                                            --
-----------------------------------------------------------

      --Next Available
      CURSOR c_is_npanxx_exist (ip_msid IN VARCHAR2, ip_zip IN VARCHAR2)
      IS
         SELECT 'X'
           FROM carrierzones a, npanxx2carrierzones b
          WHERE b.nxx = SUBSTR (ip_msid, 4, 3)
            -- This is from ig_transaction.msid
            AND b.npa = SUBSTR (ip_msid, 1, 3)
            -- This is from ig_transaction.msid
            AND a.st = b.state
            AND a.ZONE = b.ZONE
            AND a.zip = ip_zip;

      -- This is from ig_transaction.zip_code
      c_is_npanxx_exist_rec       c_is_npanxx_exist%ROWTYPE;

      CURSOR c_get_npa_nxx (ip_zip IN VARCHAR2)
      IS
         SELECT DISTINCT b.*
                    FROM carrierzones a, npanxx2carrierzones b
                   WHERE a.st = b.state
                     AND a.ZONE = b.ZONE
                     AND a.zip = ip_zip
                     -- This is from ig_transaction.zip_code
                     AND b.carrier_name = 'CINGULAR WIRELESS'
                     AND ROWNUM < 2;

      c_get_npa_nxx_rec           c_get_npa_nxx%ROWTYPE;
--Next Available
      str_reworkq                 VARCHAR2 (100);
--      rtain_notesstr          VARCHAR2 (23768); --CR5008
      rtain_notesstr              LONG;                       --CR5008, CR4947
      fax_filename                VARCHAR2 (100);
      l_notes_log_seq             NUMBER;
      hold                        NUMBER;
      hold2                       VARCHAR2 (100);
      lcaseobjid                  NUMBER;
      rtain_strqueue              VARCHAR2 (100);
      cnt                         NUMBER                          := 0;
      l_program_name              VARCHAR2 (100)          := 'IGATE_IN.RTA_IN';
      blnresult                   BOOLEAN;
      --blnUpdated BOOLEAN := false; --Commented for CR3440
      intportinq                  NUMBER;
      itobeauth                   NUMBER;
      l_phonetech                 VARCHAR2 (10)                   := '';
      l_statupdate                VARCHAR2 (5);
      l_ins_pihist_flag           BOOLEAN;
      --CR3327-1 Variable declarations starts
      v_order_type                VARCHAR2 (30);
      v_ordertype_objid           NUMBER;
      v_action_item_id_ipa        NUMBER;
      v_black_out_code            NUMBER;
      v_dest_queue                NUMBER;
      v_dummy                     NUMBER;
      v_contact_objid             NUMBER;
      v_status_out                NUMBER;
      v_case_id                   table_case.id_number%TYPE;
      v_case_history              table_case.case_history%TYPE;
      v_task_id                   table_task.task_id%TYPE;
      v_task_objid                table_task.objid%TYPE;
      --CR3327-1 Variable declarations ends
      --
      -- OTA
      --
      cntcase                     NUMBER; --CR3918 ver1.20  Mchinta 06/15/2005
      cntclosedcase               NUMBER;
      piobjid                     NUMBER; --CR3918 ver1.20  Mchinta 06/15/2005

      FUNCTION ota_activation_pending (p_part_serial_no IN VARCHAR2)
         RETURN BOOLEAN
      IS
         b_return_value   BOOLEAN := FALSE;
      BEGIN
         OPEN ota_call_trans_curs (p_part_serial_no);

         FETCH ota_call_trans_curs
          INTO ota_call_trans_rec;

         IF     ota_call_trans_rec.x_action_type = '1'
            AND ota_call_trans_rec.x_result = 'OTA PENDING'
         THEN
            b_return_value := TRUE;
         END IF;

         CLOSE ota_call_trans_curs;

         RETURN b_return_value;
      END ota_activation_pending;

-----------------------------------------------------------
-- Process status messages received from TMOBILE carrier --
-- CR4947 START                                            --
-----------------------------------------------------------
--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
      PROCEDURE sp_close_task (
         p_ig_trans_rec   IN   ig_trans_curs%ROWTYPE,
         p_task_rec       IN   task_curs%ROWTYPE,
         p_task_status    IN   NUMBER,
         p_trans_status   IN   gw1.ig_transaction.status%TYPE
      )
      IS
      BEGIN
-----------------------------------------------
-- Closes the task which is associated       --
-- with the current IGATE transaction record --
-----------------------------------------------
----------------------------
-- *** Close the task *** --
----------------------------
         igate.sp_close_action_item (p_task_objid      => p_task_rec.objid,
                                     p_status          => p_task_status
                                                                    -- 0, 2, 3
                                                                       ,
                                     p_dummy_out       => hold
                                    );

         UPDATE gw1.ig_transaction
            SET status = p_trans_status         -- 'S' = Success 'F' = Failure
          WHERE ROWID = p_ig_trans_rec.ROWID;

         COMMIT;
      END sp_close_task;

--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
      PROCEDURE sp_create_sim_exchange_case (
         p_ig_trans_rec   IN   ig_trans_curs%ROWTYPE
      )
      IS
         -------
         -- * --
         -------
         CURSOR esn_curs (c_esn IN VARCHAR2)
         IS
            SELECT x_part_inst2contact
              FROM table_part_inst
             WHERE part_serial_no = c_esn AND x_domain = 'PHONES';

         esn_rec           esn_curs%ROWTYPE;
         l_c_case_id_out   VARCHAR2 (255);
      BEGIN
         OPEN esn_curs (p_ig_trans_rec.esn);

         FETCH esn_curs
          INTO esn_rec;

         CLOSE esn_curs;

         create_case_clarify_pkg.sp_create_case
             (p_esn                    => p_ig_trans_rec.esn,
              p_contact_objid          => esn_rec.x_part_inst2contact,
              p_queue_name             => 'Warehouse',
              p_type                   => 'Technology Exchange',
              p_title                  => 'SIM Card Exchange',
              p_history                =>    'Technology Exchange Case: SIM Card Exchange '
                                          || 'Originated from IGATE ESN: '
                                          || p_ig_trans_rec.esn,
              p_status                 => 'BadAddress',
              p_repl_part              => 'TFSIMT5',
              p_replacement_units      => 0,
              p_case2task              => 0,
              p_case_type_lvl2         => 'Tracfone',
              p_issue                  => 'Carrier Requested',
              p_inbound                => NULL,
              p_outbound               => NULL,
              p_signal                 => NULL,
              p_scan                   => NULL,
              p_promo_code             => NULL,
              p_master_sid             => NULL,
              p_prl_soc                => NULL,
              p_time_tank              => NULL,
              p_tt_units               => 0,
              p_fraud_id               => NULL,
              p_wrong_esn              => NULL,
              p_ttest_seq              => 0,
              p_sys_seq                => 0,
              p_channel                => NULL,
              p_phone_due_date         => '1-jan-1753',
              p_sys_phone_date         => '1-jan-1753',
              p_super_login            => NULL,
              p_cust_units_claim       => 0,
              p_fraud_units            => 0,
              p_vm_password            => NULL,
              p_courier                => NULL,
              p_stock_type             => NULL,
              p_reason                 => NULL,
              p_problem_source         => NULL,
              p_case_id                => l_c_case_id_out
             );
      END sp_create_sim_exchange_case;

--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
      PROCEDURE sp_remove_mdn_from_imei (
         p_ig_trans_rec   IN   ig_trans_curs%ROWTYPE
      )
      IS
      BEGIN
         UPDATE table_part_inst
            SET part_to_esn2part_inst = NULL
          WHERE part_serial_no = p_ig_trans_rec.esn AND x_domain = 'PHONES';

         COMMIT;
      END sp_remove_mdn_from_imei;

--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
      PROCEDURE sp_process_esn_change (
         p_ig_trans_rec   IN   ig_trans_curs%ROWTYPE
      )
      IS
      BEGIN
         UPDATE gw1.ig_transaction
            SET order_type = 'E'
          WHERE ROWID = p_ig_trans_rec.ROWID;

         COMMIT;
      END sp_process_esn_change;

--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
      PROCEDURE sp_tmobile_activation_msg (
         p_ig_trans_rec   IN   ig_trans_curs%ROWTYPE
      )
      IS
      BEGIN
---------------------------------
-- Order type 'A' = Activation --
---------------------------------
         IF RTRIM (p_ig_trans_rec.status_message) IN
                                    ('MSISDN Not Found', 'SIM is not valid')
         THEN
--------------------------------------------
-- *** Close action item with success *** --
--------------------------------------------
            sp_close_task (p_ig_trans_rec      => p_ig_trans_rec,
                           p_task_rec          => task_rec,
                           p_task_status       => 0,
                           p_trans_status      => 'S'
                          );
--------------------------------------
-- *** Create SIM Exchange case *** --
--------------------------------------
            sp_create_sim_exchange_case (p_ig_trans_rec => p_ig_trans_rec);
-----------------------------------------------------------
-- *** Disassociate the MDN (min)from the IMEI (esn) *** --
-----------------------------------------------------------
            sp_remove_mdn_from_imei (p_ig_trans_rec => p_ig_trans_rec);
         ELSIF RTRIM (p_ig_trans_rec.status_message) =
                                    'TracFone: SIM active with different IMEI'
         THEN
--------------------------------
-- *** Process ESN change *** --
--------------------------------
            sp_process_esn_change (p_ig_trans_rec => p_ig_trans_rec);
         ELSIF RTRIM (p_ig_trans_rec.status_message) =
                                    'TracFone: Unable to process Reactivation'
         THEN
            -- further investigation required with Tracfone
            NULL;
         END IF;
      END sp_tmobile_activation_msg;

--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
      PROCEDURE sp_tmobile_esn_chng_msg (
         p_ig_trans_rec   IN   ig_trans_curs%ROWTYPE
      )
      IS
      BEGIN
-----------------------------------
-- Order type 'E' = ESN Change   --
-----------------------------------
         IF RTRIM (p_ig_trans_rec.status_message) =
                                             'ReActivating Active Subscriber'
         THEN
            -- further investigation required with Tracfone
            NULL;
         ELSIF RTRIM (p_ig_trans_rec.status_message) IN
                                ('SIM is already active', 'SIM is not valid')
         THEN
--------------------------------------------
-- *** Close action item with success *** --
--------------------------------------------
            sp_close_task (p_ig_trans_rec      => p_ig_trans_rec,
                           p_task_rec          => task_rec,
                           p_task_status       => 0,
                           p_trans_status      => 'S'
                          );
--------------------------------------
-- *** Create SIM Exchange case *** --
--------------------------------------
            sp_create_sim_exchange_case (p_ig_trans_rec => p_ig_trans_rec);
------------------------------------------------------------
-- *** Disassociate the MDN (min) from the IMEI (esn) *** --
------------------------------------------------------------
            sp_remove_mdn_from_imei (p_ig_trans_rec => p_ig_trans_rec);
         END IF;
      END sp_tmobile_esn_chng_msg;

--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
      PROCEDURE sp_tmobile_minc_msg (p_ig_trans_rec IN ig_trans_curs%ROWTYPE)
      IS
      BEGIN
------------------------------------
-- Order type 'MINC' = MIN Change --
------------------------------------
         IF RTRIM (p_ig_trans_rec.status_message) = 'Invalid Subscriber'
         THEN
--------------------------------------------
-- *** Close action item with success *** --
--------------------------------------------
            sp_close_task (p_ig_trans_rec      => p_ig_trans_rec,
                           p_task_rec          => task_rec,
                           p_task_status       => 0,
                           p_trans_status      => 'S'
                          );
--------------------------------------
-- *** Create SIM Exchange case *** --
--------------------------------------
            sp_create_sim_exchange_case (p_ig_trans_rec => p_ig_trans_rec);
---------------------------------------------------------
-- *** Associate the MDN (min) to the IMEI (esn)***    --
---------------------------------------------------------
-- Test and see if we need to code this step.
-- Maybe it's not neccesary...
            NULL;
         ELSIF RTRIM (p_ig_trans_rec.status_message) = 'MSISDN Not Found'
         THEN
            -- further investigation required with Tracfone
            NULL;
         ELSIF RTRIM (p_ig_trans_rec.status_message) =
                               'MSISDN is not associated with SIM and/or IMEI'
         THEN
--------------------------------------------
-- *** Close action item with success *** --
--------------------------------------------
            sp_close_task (p_ig_trans_rec      => p_ig_trans_rec,
                           p_task_rec          => task_rec,
                           p_task_status       => 0,
                           p_trans_status      => 'S'
                          );
--------------------------------------
-- *** Create SIM Exchange case *** --
--------------------------------------
            sp_create_sim_exchange_case (p_ig_trans_rec => p_ig_trans_rec);
------------------------------------------------------------
-- *** Disassociate the MDN (min) from the IMEI (esn) *** --
------------------------------------------------------------
            sp_remove_mdn_from_imei (p_ig_trans_rec => p_ig_trans_rec);
         ELSIF RTRIM (p_ig_trans_rec.status_message) =
                                              'ReActivating active subscriber'
         THEN
            -- further investigation required with TMOBILE
            NULL;
         ELSIF RTRIM (p_ig_trans_rec.status_message) = 'SIM is already active'
         THEN
--------------------------------------------
-- *** Close action item with success *** --
--------------------------------------------
            sp_close_task (p_ig_trans_rec      => p_ig_trans_rec,
                           p_task_rec          => task_rec,
                           p_task_status       => 0,
                           p_trans_status      => 'S'
                          );
--------------------------------------
-- *** Create SIM Exchange case *** --
--------------------------------------
            sp_create_sim_exchange_case (p_ig_trans_rec => p_ig_trans_rec);
------------------------------------------------
-- *** Assign customer old number back ***    --
------------------------------------------------
-- Test and see if we need to code this step.
-- Maybe it's not neccesary...
            NULL;
         END IF;
      END sp_tmobile_minc_msg;

--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
      PROCEDURE sp_tmobile_deact_msg (p_ig_trans_rec IN ig_trans_curs%ROWTYPE)
      IS
      BEGIN
-----------------------------------
-- Order type 'D' = Deactivation --
-----------------------------------
         IF RTRIM (p_ig_trans_rec.status_message) =
                              'MSISDN is not associated with SIM and/or IMEI'
         THEN
--------------------------------------------
-- *** Close action item with success *** --
--------------------------------------------
            sp_close_task (p_ig_trans_rec      => p_ig_trans_rec,
                           p_task_rec          => task_rec,
                           p_task_status       => 0,
                           p_trans_status      => 'S'
                          );
         END IF;
      END sp_tmobile_deact_msg;

--------------------------------------------------------------
-- INNER MODULE inside of RTA_IN                      ***** --
--------------------------------------------------------------
      PROCEDURE sp_tmobile_suspend_msg (
         p_ig_trans_rec   IN   ig_trans_curs%ROWTYPE
      )
      IS
      BEGIN
------------------------------
-- Order type 'S' = Suspend --
------------------------------
         IF RTRIM (p_ig_trans_rec.status_message) =
                              'MSISDN is not associated with SIM and/or IMEI'
         THEN
--------------------------------------------
-- *** Close action item with success *** --
--------------------------------------------
            sp_close_task (p_ig_trans_rec      => p_ig_trans_rec,
                           p_task_rec          => task_rec,
                           p_task_status       => 0,
                           p_trans_status      => 'S'
                          );
         END IF;
      END sp_tmobile_suspend_msg;
-----------------------------------------------------------
-- Process status messages received from TMOBILE carrier --
-- CR4947 END                                            --
-----------------------------------------------------------
   BEGIN
      FOR ig_trans_rec IN ig_trans_curs
      LOOP
         DBMS_OUTPUT.put_line (   '--start new trans_id:'
                               || ig_trans_rec.transaction_id
                              );                                    -- CR 5008

         /* Start of CR4264: Line Status change for old MIN */
         BEGIN
            IF     (ig_trans_rec.TEMPLATE <> 'TMOBILE')
               AND (ig_trans_rec.order_type = 'MINC')
               AND (ig_trans_rec.old_min IS NOT NULL)
            THEN
               UPDATE table_part_inst
                  SET x_part_inst_status =
                         DECODE (x_part_inst_status,
                                 '13', x_part_inst_status,
                                 '33', x_part_inst_status,
                                 '17'
                                ),
                      status2x_code_table =
                         DECODE (status2x_code_table,
                                 960, status2x_code_table,
                                 965, status2x_code_table,
                                 963
                                )
                WHERE part_serial_no = ig_trans_rec.old_min;

               COMMIT;

               IF sa.toss_util_pkg.insert_pi_hist_fun (ig_trans_rec.old_min,
                                                       'LINES',
                                                       'RETURNED MINC',
                                                       'IGATE_IN3'
                                                      )
               THEN
                  NULL;
               END IF;
            END IF;

            /* End of CR4264 */

            --01/29/03
            OPEN ig_wi_detail_curs (ig_trans_rec.transaction_id);

            FETCH ig_wi_detail_curs
             INTO ig_wi_detail_rec;

            CLOSE ig_wi_detail_curs;

            OPEN task_curs (ig_trans_rec.action_item_id);

            FETCH task_curs
             INTO task_rec;

            IF task_curs%NOTFOUND
            THEN
               CLOSE task_curs;

               toss_util_pkg.insert_error_tab_proc
                                              ('Retrieve task record',
                                               ig_trans_rec.action_item_id,
                                               l_program_name,
                                                  'Task record for task id '
                                               || ig_trans_rec.action_item_id
                                               || ' not found.'
                                              );
               GOTO next_action_item;
            END IF;

            CLOSE task_curs;

            OPEN user_curs (task_rec.task_originator2user);

            FETCH user_curs
             INTO user_rec;

            IF user_curs%NOTFOUND
            THEN
               CLOSE user_curs;

               toss_util_pkg.insert_error_tab_proc
                               ('Retrieve originator info of an action item',
                                ig_trans_rec.action_item_id,
                                l_program_name,
                                   'No user record found for user objid '
                                || NVL
                                      (TO_CHAR (task_rec.task_originator2user),
                                       'N/A'
                                      )
                               );
               GOTO next_action_item;
            END IF;

            CLOSE user_curs;

            OPEN call_trans_curs (task_rec.x_task2x_call_trans);

            FETCH call_trans_curs
             INTO call_trans_rec;

            IF call_trans_curs%NOTFOUND
            THEN
               CLOSE call_trans_curs;

               toss_util_pkg.insert_error_tab_proc
                      ('Retrieve call trans record',
                       ig_trans_rec.action_item_id,
                       l_program_name,
                          'No calltran record found for this calltran objid '
                       || NVL (TO_CHAR (task_rec.x_task2x_call_trans), 'N/A')
                      );
               GOTO next_action_item;
            END IF;

            CLOSE call_trans_curs;

            OPEN site_part_curs (call_trans_rec.call_trans2site_part);

            FETCH site_part_curs
             INTO site_part_rec;

            IF site_part_curs%NOTFOUND
            THEN
               CLOSE site_part_curs;

               toss_util_pkg.insert_error_tab_proc
                    ('Retrieve site part record',
                     ig_trans_rec.action_item_id,
                     l_program_name,
                        'No site part record found for this site part objid '
                     || NVL (TO_CHAR (call_trans_rec.call_trans2site_part),
                             'N/A'
                            )
                    );
               GOTO next_action_item;
            END IF;

            CLOSE site_part_curs;

            OPEN queue_curs (task_rec.task_currq2queue);

            OPEN condition_curs (task_rec.task_state2condition);

            FETCH queue_curs
             INTO queue_rec;

            FETCH condition_curs
             INTO condition_rec;

            IF queue_curs%NOTFOUND AND condition_curs%FOUND
            THEN
               UPDATE gw1.ig_transaction
                  SET status =
                              DECODE (ig_trans_rec.status,
                                      'E', 'F',
                                      'W', 'S'
                                     )
                WHERE ROWID = ig_trans_rec.ROWID;

               COMMIT;

               CLOSE queue_curs;

               CLOSE condition_curs;

               GOTO next_action_item;
            END IF;

            CLOSE queue_curs;

            CLOSE condition_curs;

            OPEN queue_curs (task_rec.task_currq2queue);

            FETCH queue_curs
             INTO queue_rec;

            IF queue_curs%NOTFOUND
            THEN
               IF ig_trans_rec.status IN ('W')
               THEN
                  IF task_rec.x_queued_flag <> ' '
                  THEN
                     UPDATE table_task
                        SET x_queued_flag = '0'
                      WHERE objid = task_rec.objid;
                  END IF;

                  igate.sp_close_action_item (task_rec.objid, 0, hold);

                  UPDATE gw1.ig_transaction
                     SET status = 'S'
                   WHERE ROWID = ig_trans_rec.ROWID;

                  COMMIT;

                  -- 01/17/03 close case
                  IF task_rec.x_current_method IN ('ICI', 'AOL')
                  THEN
                     IF RTRIM (call_trans_rec.x_service_id) IS NOT NULL
                     THEN
                        FOR opened_case_rec IN
                           opened_case_curs (call_trans_rec.x_service_id,
                                             call_trans_rec.x_min
                                            )
                        LOOP
                           -- CR3154 - Added new titles and case types
                           IF (    opened_case_rec.title IN
                                      ('Line Inactive',
                                       'Line Inactive WEB',
                                       'Line Inactive IVR',
                                       'Inactive Features',
                                       'Voicemail not active',
                                       'Unable to Make / Unable to Receive Calls',
                                       'Caller ID not active',
                                       'Callwait not active',
                                       'Voicemail',
                                       'Caller ID',
                                       'Call Waiting',
                                       'SMS'
                                      )
                               AND opened_case_rec.x_case_type IN
                                      ('Carrier LA',
                                       'Carrier LA Features',
                                       'Features',
                                       'Line Activation'
                                      )
                              )
                           THEN
                              igate.sp_close_case (opened_case_rec.id_number,
                                                   USER,
                                                   'IGATE_IN',
                                                   'Resolution Given',
                                                   l_status,
                                                   l_msg
                                                  );
                           END IF;
                        END LOOP;
                     END IF;
                  END IF;
               --01/17/03
               ELSIF ig_trans_rec.status IN ('E')
               THEN
                  OPEN part_num_curs (site_part_rec.site_part2part_info);

                  FETCH part_num_curs
                   INTO part_num_rec;

                  IF part_num_curs%NOTFOUND
                  THEN
--               close part_num_curs;
                     str_reworkq := 'Action Re-Work';
                  ELSE
                     --CR3327-1 For order type IPI,IPS and IPA use internal port in rework queue.
                     IF    ig_trans_rec.order_type = 'IPA'
                        OR ig_trans_rec.order_type = 'IPI'
                        OR ig_trans_rec.order_type = 'IPS'
                     THEN
                        str_reworkq := trans_profile_rec.x_int_port_in_rework;
                     ELSE
                        --CR3327-1 Ends
                        OPEN trans_profile_curs
                                 (order_type_rec.x_order_type2x_trans_profile);

                        FETCH trans_profile_curs
                         INTO trans_profile_rec;

                        IF trans_profile_curs%NOTFOUND
                        THEN
                           str_reworkq := 'Action Re-Work';
                        ELSE
                           IF part_num_rec.x_technology = 'ANALOG'
                           THEN
                              str_reworkq :=
                                            trans_profile_rec.x_analog_rework;
                           ELSIF part_num_rec.x_technology IN
                                                             ('CDMA', 'TDMA')
                           THEN
                              str_reworkq :=
                                           trans_profile_rec.x_digital_rework;
                           ELSIF part_num_rec.x_technology IN ('GSM')
                           THEN
                              str_reworkq := trans_profile_rec.x_gsm_rework;
                           ELSE
                              str_reworkq := 'Action Re-Work';
                           END IF;
                        END IF;

                        CLOSE trans_profile_curs;                   -- CR 5008
                     END IF;
                  --   CLOSE trans_profile_curs; -- Commented for CR 5008
                  END IF;

                  CLOSE part_num_curs;

                  IF ig_trans_rec.order_type IN ('A', 'E')
                  THEN
                     rtain_strqueue := str_reworkq;
                  ELSIF ig_trans_rec.order_type IN ('D', 'S')
                  THEN
                     rtain_strqueue := 'Line Management Re-work';
                  ELSE
                     rtain_strqueue := str_reworkq;
                  END IF;

                  igate.sp_dispatch_task (task_rec.objid, rtain_strqueue,
                                          hold);
                  DBMS_OUTPUT.put_line ('start upd transaction');

                  UPDATE gw1.ig_transaction
                     SET status = 'F'
                   WHERE ROWID = ig_trans_rec.ROWID;

                  COMMIT;
                  DBMS_OUTPUT.put_line ('end upd transaction');
               END IF;

               CLOSE queue_curs;

               GOTO next_action_item;
            END IF;

            CLOSE queue_curs;

            --
            DBMS_OUTPUT.put_line ('Taks Id...' || task_rec.task_id);
            DBMS_OUTPUT.put_line ('opening condition cur');

            OPEN condition_curs (task_rec.task_state2condition);

            FETCH condition_curs
             INTO condition_rec;

            IF condition_curs%FOUND
            THEN
               CLOSE condition_curs;

               DBMS_OUTPUT.put_line ('before inserting error --cond');

               BEGIN
                  DBMS_OUTPUT.put_line ('Before Updating...');

                  --CR3153 - Do not make this change for status CP
                  IF (ig_trans_rec.status != 'CP')
                  THEN
                     UPDATE table_task
                        SET task_currq2queue = NULL
                      WHERE task_state2condition = condition_rec.objid;
                  END IF;

                  DBMS_OUTPUT.put_line ('After Updating...');
                  /*

                               toss_util_pkg.insert_error_tab_proc ('Error Updating task_currq2queue=null',
                                               ig_trans_rec.action_item_id,
                                               l_program_name,
                                               'For Object Id  '||
                                              nvl(to_char(task_rec.task_state2condition),'N/A'));
                  */
                  COMMIT;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     NULL;
                  WHEN OTHERS
                  THEN
                     toss_util_pkg.insert_error_tab_proc
                                ('Error in Updating Table_Task Table',
                                 ig_trans_rec.action_item_id,
                                 l_program_name,
                                    'For Object Id  '
                                 || NVL
                                       (TO_CHAR (task_rec.task_state2condition),
                                        'N/A'
                                       )
                                );
               END;

               /* Code Stop on 01/04/2004 by MHANIF

               toss_util_pkg.insert_error_tab_proc ('Retrieve condition record',
                                               ig_trans_rec.action_item_id,
                                               l_program_name,
                                               'No condition record found for this condition objid '||
                                               nvl(to_char(task_rec.task_state2condition),'N/A'));
                        dbms_output.put_line('before inserting error --cond');
               */
               GOTO next_action_item;
            END IF;

            CLOSE condition_curs;

            DBMS_OUTPUT.put_line ('closing condition cur');
            DBMS_OUTPUT.put_line ('openning  order_type_curs cur');

            OPEN order_type_curs (task_rec.x_task2x_order_type);

            FETCH order_type_curs
             INTO order_type_rec;

            IF order_type_curs%NOTFOUND
            THEN
               DBMS_OUTPUT.put_line
                       ('updating ig_transaction inside  order_type_curs cur');

               UPDATE gw1.ig_transaction
                  SET status = DECODE (status, 'E', 'HE', 'W', 'HW')
                WHERE transaction_id = ig_trans_rec.transaction_id;

               COMMIT;
               DBMS_OUTPUT.put_line
                        ('updating ig_transaction inside  order_type_curs cur');

               CLOSE order_type_curs;

               GOTO next_action_item;
            END IF;

            CLOSE order_type_curs;

            DBMS_OUTPUT.put_line ('openning  order_type_curs cur');
--      open site_part_curs(call_trans_rec.call_trans2site_part);
--        fetch site_part_curs into site_part_rec;
--        if site_part_curs%notfound then
--          close site_part_curs;
--          goto next_action_item;
--        end if;
--      close site_part_curs;
-----------------------------------------------------------
            DBMS_OUTPUT.put_line ('opening part_num_curs cur');

            OPEN part_num_curs (site_part_rec.site_part2part_info);

            FETCH part_num_curs
             INTO part_num_rec;

            IF part_num_curs%NOTFOUND
            THEN
--          close part_num_curs;
               str_reworkq := 'Action Re-Work';
            ELSE
               l_phonetech := part_num_rec.x_technology;
               DBMS_OUTPUT.put_line ('opening trans_profile_curs cur');

               OPEN trans_profile_curs
                                 (order_type_rec.x_order_type2x_trans_profile);

               FETCH trans_profile_curs
                INTO trans_profile_rec;

               IF trans_profile_curs%NOTFOUND
               THEN
--              close trans_profile_curs;
                  str_reworkq := 'Action Re-Work';
               ELSE
                  --CR3327-1 For order type IPI, IPA, IPS use internal port in rework queue.
                  IF    ig_trans_rec.order_type = 'IPI'
                     OR ig_trans_rec.order_type = 'IPA'
                     OR ig_trans_rec.order_type = 'IPS'
                  THEN
                     str_reworkq := trans_profile_rec.x_int_port_in_rework;
                  ELSE
                     --CR3327-1 Ends
                     IF part_num_rec.x_technology = 'ANALOG'
                     THEN
                        str_reworkq := trans_profile_rec.x_analog_rework;
                     ELSIF part_num_rec.x_technology IN ('CDMA', 'TDMA')
                     THEN
                        str_reworkq := trans_profile_rec.x_digital_rework;
                     ELSIF part_num_rec.x_technology IN ('GSM')
                     THEN
                        str_reworkq := trans_profile_rec.x_gsm_rework;
                     ELSE
                        str_reworkq := 'Action Re-Work';
                     END IF;
                  END IF;
               END IF;

               CLOSE trans_profile_curs;

               DBMS_OUTPUT.put_line ('closing trans_profile_curs cur');
            END IF;

            CLOSE part_num_curs;

            DBMS_OUTPUT.put_line ('closing part_num_curs cur');
-----------------------------------------------------------
            DBMS_OUTPUT.put_line ('opening  carrier_curs cur');

            OPEN carrier_curs (order_type_rec.x_order_type2x_carrier);

            FETCH carrier_curs
             INTO carrier_rec;

            IF carrier_curs%NOTFOUND
            THEN
               CLOSE carrier_curs;

               DBMS_OUTPUT.put_line ('inserting error retribe ccarrier rec');
               -- dbms_output.put_line('ig_trans_rec.action_item_id:'||to_char(NVL(ig_trans_rec.action_item_id,0)));
               DBMS_OUTPUT.put_line
                        (   'order tyep to carrier: '
                         || TO_CHAR
                                  (NVL (order_type_rec.x_order_type2x_carrier,
                                        0
                                       )
                                  )
                        );
               toss_util_pkg.insert_error_tab_proc
                         ('Retrieve carrier record',
                          ig_trans_rec.action_item_id,
                          l_program_name,
                             'No carrier record found for this carrier objid '
                          || TO_CHAR
                                  (NVL (order_type_rec.x_order_type2x_carrier,
                                        0
                                       )
                                  )
                         );
               GOTO next_action_item;
            END IF;

            CLOSE carrier_curs;

            /*** Getting Parent for carrier_id ***/
            OPEN parent_curs (carrier_rec.objid);

            FETCH parent_curs
             INTO parent_rec;

            CLOSE parent_curs;

            DBMS_OUTPUT.put_line ('closing  carrier_curs cur');
            DBMS_OUTPUT.put_line
                             ('entering rtain_NotesStr,  TRANSMISSION_METHOD ');
            DBMS_OUTPUT.put_line (   'Length of Notes: '
                                  || TO_CHAR (LENGTH (task_rec.notes))
                                 );
            DBMS_OUTPUT.put_line (   'Length of status_message: '
                                  || TO_CHAR
                                          (LENGTH (ig_trans_rec.status_message)
                                          )
                                 );
            rtain_notesstr :=
                  task_rec.notes
               || CHR (10)
               || CHR (13)
               || ' '
               || TO_CHAR (SYSDATE, 'DD-MON-YYYY')
               || '  ---  '
               || ig_trans_rec.status_message;
            DBMS_OUTPUT.put_line
                              ('exiting rtain_NotesStr,  TRANSMISSION_METHOD ');

            --
            IF (ig_trans_rec.transmission_method = 'AOL')
            THEN
               fax_filename := 'not found';
            ELSIF ig_wi_detail_rec.batch_id IS NOT NULL
            THEN
               fax_filename := 'f' || ig_wi_detail_rec.batch_id || '.fmf';
            ELSE
               fax_filename := 'not found';
            END IF;

            DBMS_OUTPUT.put_line ('exit rtain_NotesStr,  TRANSMISSION_METHOD ');
            DBMS_OUTPUT.put_line ('entering update table task ');

            UPDATE table_task
               SET notes = rtain_notesstr,
                   x_fax_file = fax_filename
             WHERE task_id = ig_trans_rec.action_item_id;

            DBMS_OUTPUT.put_line ('exiting update table task ');

            --
            -- Add a Notes Log entry ------
            --04/10/03 select SEQ_NOTES_LOG.nextval + POWER (2, 28) into l_notes_log_seq from dual;
            SELECT seq ('notes_log')
              INTO l_notes_log_seq
              FROM DUAL;

            --
            DBMS_OUTPUT.put_line ('enter - insert table notes log  ');

            INSERT INTO table_notes_log
                        (objid, creation_time,
                         description,
                         action_type, task_notes2task
                        )
                 VALUES (l_notes_log_seq, SYSDATE,
                            ' AOL Retur n Message: '
                         || ig_trans_rec.status_message,
                         'AOL', task_rec.objid
                        );

            DBMS_OUTPUT.put_line ('exit - insert table notes log  ');

            --CR3440 Start
            --      -- CR 3153 T-Mobile begin
            --       OPEN part_inst_curs1(ig_trans_rec.ESN);
            --         FETCH part_inst_curs1 INTO part_inst_rec1;
            --         IF part_inst_curs1%NOTFOUND THEN
            --           CLOSE part_inst_curs1;
            --         END IF;
            --       CLOSE part_inst_curs1;
            --       OPEN part_inst_curs2(part_inst_rec1.objid);
            --       FETCH part_inst_curs2 INTO part_inst_rec2;
            --       --Commented for version 1.5
            --       --IF part_inst_curs2%NOTFOUND THEN
            --       --   blnUpdated := true;
            --       --    CLOSE part_inst_curs2;
            --       --END IF;
            --       --End Comments for version 1.5
            --       CLOSE part_inst_curs2;
            --       -- CR3153 - T-Mobile end
            --

            --------------------------------------------
-- CINGULAR "NEXT AVAILABLE" CHANGES      --
-- Insert Cingular assigned line into     --
-- Clarify tables, like: TABLE_PART_INST, --
-- TABLE_SITE_PART etc.                   --
-- Only if the cerrier is CINGULAR and    --
-- OLD_MIN ia a "T" Number                --
--------------------------------------------
            IF    (ig_trans_rec.MIN LIKE 'T%'
                   AND ig_trans_rec.order_type = 'A'
                  )
               OR (ig_trans_rec.order_type = 'MINC')
            THEN
               OPEN part_inst_curs (ig_trans_rec.esn, ig_trans_rec.MIN);

               FETCH part_inst_curs
                INTO part_inst_rec;

               IF part_inst_curs%NOTFOUND
               THEN
                  CLOSE part_inst_curs;

                  toss_util_pkg.insert_error_tab_proc
                                   ('Retrieve esn_min record from part inst',
                                    ig_trans_rec.action_item_id,
                                    l_program_name,
                                       'No esn_min record found '
                                    || NVL (LTRIM (ig_trans_rec.MIN), 'N/A')
                                   );
                  DBMS_OUTPUT.put_line
                                  ('exit part_inst_curs not found log error  ');

                  UPDATE gw1.ig_transaction
                     SET status =
                            DECODE (status,
                                    'E', 'HE',
                                    'W', 'HW',
                                    'CP', 'HCP',
                                    'HH'
                                   )
                   WHERE transaction_id = ig_trans_rec.transaction_id;

                  COMMIT;
                  GOTO next_action_item;
               END IF;

               CLOSE part_inst_curs;
            --CR3440 End
            END IF;                               -- only check if tmobile min

            IF ig_trans_rec.new_msid_flag = 'Y'
            THEN
               DBMS_OUTPUT.put_line ('opening min_curs  ');

               --CR3918 Starts
               --                IF ig_trans_rec.TEMPLATE = 'TMOBILE'
               --                AND (ig_trans_rec.order_type = 'A' OR ig_trans_rec.order_type = 'MINC')
               IF    (    ig_trans_rec.MIN LIKE 'T%'
                      AND ig_trans_rec.order_type = 'A'
                     )
                  OR (ig_trans_rec.order_type = 'MINC')
               THEN
                  OPEN min_curs (ig_trans_rec.msid);
               ELSE
                  OPEN min_curs (ig_trans_rec.MIN);
               END IF;

               FETCH min_curs
                INTO min_rec;

               IF min_curs%NOTFOUND
               THEN
                  -- CR3153 - T-Mobile begin
                  --CR3918 Starts
                  --                IF ig_trans_rec.TEMPLATE = 'TMOBILE'
                  --                AND (ig_trans_rec.order_type = 'A' OR ig_trans_rec.order_type = 'MINC')
                  IF    (    ig_trans_rec.MIN LIKE 'T%'
                         AND ig_trans_rec.order_type = 'A'
                        )
                     OR (ig_trans_rec.order_type = 'MINC')
                  --CR3918 Ends
                  THEN
--and blnUpdated = false THEN  --CR3440
                     -- Insert a new line
                     blnresult :=
                        toppapp.line_insert_pkg.insert_line_rec
                                        (ig_trans_rec.msid,
                                         ig_trans_rec.msid,
                                         SUBSTR (ig_trans_rec.msid, 1, 3),
                                         SUBSTR (ig_trans_rec.msid, 4, 3),
                                         SUBSTR (ig_trans_rec.msid, 7),
                                         ig_trans_rec.TEMPLATE || '_'
                                         || SYSDATE,
                                         --      'TMOBILE_' || SYSDATE, --CR3918
                                         part_inst_rec.warr_end_date,
                                         part_inst_rec.x_cool_end_date,
                                         part_inst_rec.x_part_inst_status,
                                         part_inst_rec.n_part_inst2part_mod,
                                         part_inst_rec.part_inst2x_pers,
                                         part_inst_rec.part_inst2carrier_mkt,
                                         part_inst_rec.status2x_code_table,
                                         part_inst_rec.created_by2user
                                        );
                     --CR3440 Start
                     l_ins_pihist_flag :=
                        toss_util_pkg.insert_pi_hist_fun (ig_trans_rec.msid,
                                                          'LINES',
                                                          'LINE_BATCH',
                                                          l_program_name
                                                         );
                     l_ins_pihist_flag :=
                        toss_util_pkg.insert_pi_hist_fun (ig_trans_rec.msid,
                                                          'LINES',
                                                          'ACTIVATE',
                                                          l_program_name
                                                         );
                  --CR3440 End
                  ELSE
                     -- CR3153 - T-Mobile end
                     ROLLBACK;

                     CLOSE min_curs;

                     DBMS_OUTPUT.put_line (' min_curs not found log error  ');
                     toss_util_pkg.insert_error_tab_proc
                                     ('Retrieve min record from part inst',
                                      ig_trans_rec.action_item_id,
                                      l_program_name,
                                         'No min record found for this min  '
                                      || NVL (LTRIM (ig_trans_rec.MIN), 'N/A')
                                     );
                     DBMS_OUTPUT.put_line
                                        ('exit min_curs not found log error  ');

                     UPDATE gw1.ig_transaction
                        SET status =
                               DECODE (status,
                                       'E', 'HE',
                                       'W', 'HW',
                                       'CP', 'HCP',
                                       'HH'
                                      )
                      WHERE transaction_id = ig_trans_rec.transaction_id;

                     COMMIT;
                     GOTO next_action_item;
                  END IF;
               --Change to update the line with call trans carrier.-- Chinta
               ELSE
                  UPDATE table_part_inst
                     SET part_inst2carrier_mkt =
                                           call_trans_rec.x_call_trans2carrier,
                         part_inst2x_pers = carrier_rec.carrier2personality
                   WHERE objid = min_rec.objid;

                  -- Inseting a new record into Pi Hist
                  l_ins_pihist_flag :=
                     toss_util_pkg.insert_pi_hist_fun (ig_trans_rec.msid,
                                                       'LINES',
                                                       'CARRIER_CHANGE',
                                                       l_program_name
                                                      );
                  COMMIT;
               --End Changes by Mchinta
               END IF;

               CLOSE min_curs;

               DBMS_OUTPUT.put_line ('opening min_curs  ');

------------------------------------------
-- CR3153 - T-Mobile begin              --
------------------------------------------
               IF    (    ig_trans_rec.MIN LIKE 'T%'
                      AND ig_trans_rec.order_type = 'A'
                     )
                  OR (ig_trans_rec.order_type = 'MINC')
               THEN
---------------------------------------------
-- CR4960: Update any Hold ild_transaction --
---------------------------------------------
                  UPDATE table_x_ild_transaction
                     SET x_ild_status = 'Pending',
                         x_min = ig_trans_rec.msid,
                         x_last_update = SYSDATE
                   WHERE x_esn = ig_trans_rec.esn
                     AND x_ild_status = 'Hold'
                     AND x_min = ig_trans_rec.MIN;

------------------------------------------
-- CINGULAR "T" NUMBER - NEXT AVAILABLE --
--                CHANGES               --
------------------------------------------
                  OPEN min_curs (ig_trans_rec.msid);

                  FETCH min_curs
                   INTO min_rec;

                  CLOSE min_curs;

----------------------------------------------
--  Set the relation between line and phone --
----------------------------------------------
                  DBMS_OUTPUT.put_line ('opening min_curs 2:2 ');   -- CR 5008

                  UPDATE table_part_inst
                     SET part_to_esn2part_inst = part_inst_rec.esn_objid
                   WHERE objid = min_rec.objid;

----------------------------------------------------------------------
-- If the ESN is not active, set the status of the line to Reserved --
-- so that we give this line to the customer when he reactivates.   --
----------------------------------------------------------------------
                  DBMS_OUTPUT.put_line ('opening min_curs 2:3 ');   -- CR 5008

                  IF part_inst_rec.esn_status != '52'
                  THEN
                     DBMS_OUTPUT.put_line ('opening min_curs 2:4 ');

                     -- CR 5008
                     OPEN code_curs ('37');

                     FETCH code_curs
                      INTO code_rec;

                     CLOSE code_curs;

                     UPDATE table_part_inst
                        SET x_part_inst_status = '37',
                            status2x_code_table = code_rec.objid
                      WHERE objid = min_rec.objid;
                  END IF;

----------------------------
--  Delete the dummy line --
----------------------------
                  DBMS_OUTPUT.put_line ('opening min_curs 2:5 ');   -- CR 5008

                  IF part_inst_rec.part_serial_no LIKE 'T%'
                  THEN
                     DBMS_OUTPUT.put_line ('opening min_curs 2:6 ');

                     -- CR 5008
                     DELETE FROM table_part_inst
                           WHERE objid = part_inst_rec.objid;

                     DELETE FROM table_x_pi_hist
                           WHERE x_part_serial_no =
                                                 part_inst_rec.part_serial_no;
                  END IF;

-----------------------------------------------
-- Update Site_part and Call Trans with Line --
-----------------------------------------------
                  UPDATE table_site_part
                     SET x_min = ig_trans_rec.msid
                   WHERE objid = call_trans_rec.call_trans2site_part;

                  UPDATE table_x_call_trans
                     SET x_min = ig_trans_rec.msid
                   WHERE call_trans2site_part =
                                           call_trans_rec.call_trans2site_part;

---------------------------------------------------
-- Set the part_inst2x_pers relation for the ESN --
---------------------------------------------------
                  UPDATE table_part_inst
                     SET part_inst2x_pers = min_rec.part_inst2x_pers
                   WHERE part_serial_no = ig_trans_rec.esn;
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                  -- COMMENTED OUT UNTIL SOLUTION IS FOUND TO FIX THE ISSUE
                  -- This change goes together with CR4960-1 (Data Services)
                  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                  -->>>>> --Next Available
                  -->>>>> OPEN c_is_npanxx_exist (ig_trans_rec.msid,
                  -->>>>>                         ig_trans_rec.zip_code
                  -->>>>>                        );
                  -->>>>>
                  -->>>>> FETCH c_is_npanxx_exist
                  -->>>>>  INTO c_is_npanxx_exist_rec;
                  -->>>>>
                  -->>>>> IF c_is_npanxx_exist%NOTFOUND
                  -->>>>> THEN
                  -->>>>>    OPEN c_get_npa_nxx (ig_trans_rec.zip_code);
                  -->>>>>
                  -->>>>>    FETCH c_get_npa_nxx
                  -->>>>>     INTO c_get_npa_nxx_rec;
                  -->>>>>
                  -->>>>>    CLOSE c_get_npa_nxx;
                  -->>>>>
                  -->>>>>    INSERT INTO sa.npanxx2carrierzones
                  -->>>>>                (npa,
                  -->>>>>                 nxx,
                  -->>>>>                 carrier_id,
                  -->>>>>                 carrier_name,
                  -->>>>>                 lead_time,
                  -->>>>>                 target_level,
                  -->>>>>                 ratecenter,
                  -->>>>>                 state,
                  -->>>>>                 carrier_id_description,
                  -->>>>>                 ZONE,
                  -->>>>>                 county,
                  -->>>>>                 marketid,
                  -->>>>>                 mrkt_area,
                  -->>>>>                 SID,
                  -->>>>>                 technology,
                  -->>>>>                 frequency1,
                  -->>>>>                 frequency2,
                  -->>>>>                 bta_mkt_number,
                  -->>>>>                 bta_mkt_name,
                  -->>>>>                 gsm_tech,
                  -->>>>>                 cdma_tech,
                  -->>>>>                 tdma_tech,
                  -->>>>>                 mnc
                  -->>>>>                )
                  -->>>>>         VALUES (SUBSTR (ig_trans_rec.msid, 1, 3),
                  -->>>>>                 SUBSTR (ig_trans_rec.msid, 4, 3),
                  -->>>>>                 c_get_npa_nxx_rec.carrier_id,
                  -->>>>>                 c_get_npa_nxx_rec.carrier_name,
                  -->>>>>                 c_get_npa_nxx_rec.lead_time,
                  -->>>>>                 c_get_npa_nxx_rec.target_level,
                  -->>>>>                 c_get_npa_nxx_rec.ratecenter,
                  -->>>>>                 c_get_npa_nxx_rec.state,
                  -->>>>>                 c_get_npa_nxx_rec.carrier_id_description,
                  -->>>>>                 c_get_npa_nxx_rec.ZONE,
                  -->>>>>                 c_get_npa_nxx_rec.county,
                  -->>>>>                 c_get_npa_nxx_rec.marketid,
                  -->>>>>                 c_get_npa_nxx_rec.mrkt_area,
                  -->>>>>                 c_get_npa_nxx_rec.SID,
                  -->>>>>                 c_get_npa_nxx_rec.technology,
                  -->>>>>                 c_get_npa_nxx_rec.frequency1,
                  -->>>>>                 c_get_npa_nxx_rec.frequency2,
                  -->>>>>                 c_get_npa_nxx_rec.bta_mkt_number,
                  -->>>>>                 c_get_npa_nxx_rec.bta_mkt_name,
                  -->>>>>                 c_get_npa_nxx_rec.gsm_tech,
                  -->>>>>                 c_get_npa_nxx_rec.cdma_tech,
                  -->>>>>                 c_get_npa_nxx_rec.tdma_tech,
                  -->>>>>                 c_get_npa_nxx_rec.mnc
                  -->>>>>                );
                  -->>>>>
                  -->>>>>    COMMIT;
                  -->>>>> END IF;
                  -->>>>>
                  -->>>>> CLOSE c_is_npanxx_exist;
                  -->>>>> --Next Available
                  -->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
               END IF;

---------------------------
-- CR3153 - T-Mobile end --
---------------------------

               --
               -- update OTA tables with new MIN number
               --
               DBMS_OUTPUT.put_line ('opening min_curs 2:7 ');      -- CR 5008

               IF call_trans_rec.x_ota_type = ota_util_pkg.ota_activation
               THEN
                  DBMS_OUTPUT.put_line ('opening min_curs 2:8 ');  -- CR 5008

                  UPDATE table_x_ota_transaction
                     SET x_min = ig_trans_rec.msid
                   WHERE x_ota_trans2x_call_trans = call_trans_rec.objid;
               END IF;

               UPDATE gw1.ig_transaction
                  SET new_msid_flag = 'PROCESSED'
                WHERE ROWID = ig_trans_rec.ROWID;

               --CR3153 - Do not update for MSID update if carrier is T-Mobile and ESN is no longer active. Added if statement
               --CR3440 Start
               --IF (ig_trans_rec.TEMPLATE != 'TMOBILE') or (ig_trans_rec.TEMPLATE = 'TMOBILE' --and blnUpdated = false)) THEN
               DBMS_OUTPUT.put_line ('opening min_curs 2:9 ');      -- CR 5008

               IF    ig_trans_rec.TEMPLATE != 'TMOBILE'
                  OR (    ig_trans_rec.TEMPLATE = 'TMOBILE'
                      AND (   part_inst_rec.esn_status = '52'
                           -- OTA:
                           -- For OTA Activation the ESN status will be 50 since the code accepted logic will not be executed
                           -- until the codes are sent through the OTA and MO acknowledgment is received.
                           OR ota_activation_pending (ig_trans_rec.esn)
                          )
                     )
               THEN
                  DBMS_OUTPUT.put_line ('opening min_curs 2:10 '); -- CR 5008

                  OPEN min_still_exists_curs (min_rec.objid);

                  FETCH min_still_exists_curs
                   INTO min_still_exists_rec;

                  IF min_still_exists_curs%FOUND
                  THEN
                       -- CR 5008 End
                     --CR3440 End
                     --CR3327 GP Logic to determine line status
                     l_statupdate := 'YES';

                     IF     l_phonetech = 'GSM'
                        AND parent_rec.x_no_inventory = 0
                        AND parent_rec.x_next_available = 0
                        AND ig_trans_rec.order_type <> 'MINC'         --CR3918
                     THEN
                        l_statupdate := 'NO';
                     END IF;

                     DBMS_OUTPUT.put_line (   'opening min_curs 2:10 :'
                                           || ig_trans_rec.msid
                                          );                        -- CR 5008
                     DBMS_OUTPUT.put_line
                                   (   'opening min_curs 2:10:min_rec.rowid: '
                                    || min_rec.ROWID
                                   );                               -- CR 5008
                     DBMS_OUTPUT.put_line ('opening min_curs 2:10 ');

                     -- CR 5008
                     UPDATE table_part_inst
                        --CR3327 GP Added decode not to change current status if phone is GSM
                     SET x_part_inst_status =
                            DECODE (l_statupdate,
                                    'YES', '110',
                                    x_part_inst_status
                                   ),
                         status2x_code_table =
                            DECODE (l_statupdate,
                                    'YES', 268438300,
                                    status2x_code_table
                                   ),      -- Nitin: Added for Number Pooling.
                         x_msid = ig_trans_rec.msid
                      WHERE ROWID = min_rec.ROWID;
                  END IF;

                  CLOSE min_still_exists_curs;                        --CR5008
               END IF;                                                --CR5008

               DBMS_OUTPUT.put_line ('opening min_curs 2:11 ');     -- CR 5008

               UPDATE table_site_part
                  SET x_msid = ig_trans_rec.msid
                WHERE objid = call_trans_rec.call_trans2site_part;

               INSERT INTO table_x_pi_hist
                           (objid, status_hist2x_code_table,
                            x_change_date, x_change_reason, x_cool_end_date,
                            x_creation_date,
                            x_deactivation_flag, x_domain,
                            x_ext, x_insert_date,
                            x_npa, x_nxx,
                            x_old_ext,
                            x_old_npa,
                            x_old_nxx,
                            x_part_bin, x_part_inst_status, x_part_mod,
                            x_part_serial_no, x_part_status,
                            x_pi_hist2carrier_mkt,
                            x_pi_hist2inv_bin, x_pi_hist2part_inst,
                            x_pi_hist2part_mod,
                            x_pi_hist2user,
                            x_pi_hist2x_new_pers,
                            x_pi_hist2x_pers, x_po_num,
                            x_reactivation_flag, x_red_code,
                            x_sequence, x_warr_end_date,
                            dev, fulfill_hist2demand_dtl,
                            part_to_esn_hist2part_inst,
                            x_bad_res_qty, x_date_in_serv,
                            x_good_res_qty, x_last_cycle_ct,
                            x_last_mod_time, x_last_pi_date,
                            x_last_trans_time, x_next_cycle_ct,
                            x_order_number, x_part_bad_qty,
                            x_part_good_qty, x_pi_tag_no,
                            x_pick_request, x_repair_date,
                            x_transaction_id,
                            x_msid         -- Nitin: Added for Number Pooling.
                           )
                    VALUES (
                            -- 04/10/03 seq_x_pi_hist.NEXTVAL + POWER (2, 28),
                            seq ('x_pi_hist'), min_rec.status2x_code_table,
                            SYSDATE, 'MSID UPDATE', min_rec.x_cool_end_date,
                            min_rec.x_creation_date,
                            min_rec.x_deactivation_flag, min_rec.x_domain,
                            min_rec.x_ext, min_rec.x_insert_date,
                            min_rec.x_npa, min_rec.x_nxx,
                            SUBSTR (min_rec.part_serial_no, 7, 4),
                            SUBSTR (min_rec.part_serial_no, 1, 3),
                            SUBSTR (min_rec.part_serial_no, 4, 3),
                            min_rec.part_bin, '110', min_rec.part_mod,
                            min_rec.part_serial_no, min_rec.part_status,
                            min_rec.part_inst2carrier_mkt,
                            min_rec.part_inst2inv_bin, min_rec.objid,
                            min_rec.n_part_inst2part_mod,
                            min_rec.created_by2user,
                            min_rec.part_inst2x_new_pers,
                            min_rec.part_inst2x_pers, min_rec.x_po_num,
                            min_rec.x_reactivation_flag, min_rec.x_red_code,
                            min_rec.x_sequence, min_rec.warr_end_date,
                            min_rec.dev, min_rec.fulfill2demand_dtl,
                            min_rec.part_to_esn2part_inst,
                            min_rec.bad_res_qty, min_rec.date_in_serv,
                            min_rec.good_res_qty, min_rec.last_cycle_ct,
                            min_rec.last_mod_time, min_rec.last_pi_date,
                            min_rec.last_trans_time, min_rec.next_cycle_ct,
                            min_rec.x_order_number, min_rec.part_bad_qty,
                            min_rec.part_good_qty, min_rec.pi_tag_no,
                            min_rec.pick_request, min_rec.repair_date,
                            min_rec.transaction_id,
                            min_rec.part_serial_no
                           -- Nitin: Added for Number Pooling.
                           );
            END IF;

            DBMS_OUTPUT.put_line ('opening min_curs 2:12 ');        -- CR 5008

--
--Now, determine whether this is a success, fail, or queue message*/
--************************************************************************/
--*** If successful then:
--***   Close the item
--***      Update the condition to closed
--***      Update the status to "succeeded".
--***   Append the f200message to the action item notes
--***   If this is an automated online request (AOL) Then
--***      If the task wasn't previously queued then
--***         check to see if the user is logged on
--***         if so then add an act_entry to perform a screen pop.
--***      If the item was previously queued, reset queue flag
--************************************************************************/
            IF ig_trans_rec.status IN ('W')
            THEN
               --*** If this is an online request, then notify user if logged into Clarify
               --    reset the queue flag for the task if needed
               IF task_rec.x_queued_flag <> ' '
               THEN
                  UPDATE table_task
                     SET x_queued_flag = '0'
                   WHERE objid = task_rec.objid;
               --ALR 4/25/2001 10:32AM -- Digital -- Clear BulkSave
               --SET Bulks = Nothing
               --SET Bulks = NEW BulkSave
               END IF;

               -- Start Changes for CR3918 by Mchinta on 06/15/2005 Ver 1.20
               IF (    ig_trans_rec.status_message = 'Operation MINC failed'
                   AND ig_trans_rec.order_type = 'MINC'
                  )
               THEN
                  lcaseobjid :=
                     igate.f_create_case (call_trans_rec.objid,
                                          task_rec.objid,
                                          'Bad Address',
                                          'Technology Exchange',
                                          'SIM Card Exchange'
                                         );

                  --to remove the shipping address and set the status to bad address
                  UPDATE table_case
                     SET alt_first_name = '',
                         alt_last_name = '',
                         alt_address = '',
                         alt_city = '',
                         alt_state = '',
                         alt_zipcode = '',
                         x_replacement_units = 0,
                         casests2gbst_elm = (SELECT MAX (objid)
                                               FROM table_gbst_elm
                                              WHERE s_title = 'BADADDRESS')
                   WHERE objid = lcaseobjid;

                  OPEN case_curs (lcaseobjid);

                  FETCH case_curs
                   INTO case_rec;

                  CLOSE case_curs;

                  v_case_history := case_rec.case_history;
                  v_case_history :=
                        v_case_history
                     || CHR (10)
                     || CHR (13)
                     || '*** Notes '
                     || SYSDATE
                     || ' '
                     || 'IMPORTANT:  In order to process the customer''s phone number change request, we will have to send the customer a new SIM card.
                                                                                                                Document the customer''s shipping information, then change the case status to Address Updated.';

                  UPDATE table_case
                     SET case_history = v_case_history
                   WHERE objid = lcaseobjid;

                  COMMIT;
               END IF;

               -- End Changes for CR3918 by Mchinta on 06/15/2005 Ver1.20
                 --//*** close the task*/
               igate.sp_close_action_item (task_rec.objid, 0, hold);

               UPDATE gw1.ig_transaction
                  SET status = 'S'
                WHERE ROWID = ig_trans_rec.ROWID;

               --CR3327 - Starts
               --If a case of type Port In/Internal exists, dispatch to Int Port Approval queue and set its status to To Be Authorized
               IF ig_trans_rec.order_type = 'IPI'
               THEN
                  FOR opened_case_rec IN
                     opened_case_curs (call_trans_rec.x_service_id,
                                       call_trans_rec.x_min
                                      )
                  LOOP
                     IF (    opened_case_rec.title = 'Internal'
                         AND opened_case_rec.x_case_type = 'Port In'
                        )
                     THEN
                        SELECT objid
                          INTO intportinq
                          FROM table_queue
                         WHERE title = 'Internal Port Approval';

                        UPDATE table_case
                           SET case_currq2queue = intportinq,
                               case_type_lvl3 = 'To Be Authorized'
                         WHERE id_number = opened_case_rec.id_number;

                        COMMIT;
                        v_case_history := opened_case_rec.case_history;
                        v_case_id := opened_case_rec.id_number;
                     END IF;
                  END LOOP;

                  --CR3327-1 Starts - Create a Port Approval action item.
                  v_order_type := 'Int Port Approval';

                  SELECT x_part_inst2contact
                    INTO v_contact_objid
                    FROM table_part_inst
                   WHERE part_serial_no = call_trans_rec.x_service_id;

                  igate.sp_create_action_item (v_contact_objid,
                                               call_trans_rec.objid,
                                               v_order_type,
                                               1,
                                               0,
                                               v_status_out,
                                               v_action_item_id_ipa
                                              );
                  --Get order type objid
                  igate.sp_get_ordertype (call_trans_rec.x_min,
                                          v_order_type,
                                          call_trans_rec.x_call_trans2carrier,
                                          l_phonetech,
                                          v_ordertype_objid
                                         );        -- CR4579: Added Technology
                  igate.sp_check_blackout (v_action_item_id_ipa,
                                           v_ordertype_objid,
                                           v_black_out_code
                                          );

                  IF (v_black_out_code = 0)
                  THEN
                     igate.sp_determine_trans_method (v_action_item_id_ipa,
                                                      v_order_type,
                                                      NULL,
                                                      v_dest_queue
                                                     );
                  ELSIF (v_black_out_code = 1)
                  THEN
                     igate.sp_dispatch_task (v_action_item_id_ipa,
                                             'BlackOut',
                                             v_dummy
                                            );
                  ELSE
                     igate.sp_dispatch_task (v_action_item_id_ipa,
                                             'Line Management Re-work',
                                             v_dummy
                                            );
                  END IF;

                  SELECT objid, task_id
                    INTO v_task_objid, v_task_id
                    FROM table_task
                   WHERE objid = v_action_item_id_ipa;

                  v_case_history :=
                        v_case_history
                     || CHR (10)
                     || CHR (13)
                     || '*** Notes '
                     || SYSDATE
                     || ' '
                     || 'igate_in3';
                  v_case_history :=
                        v_case_history
                     || CHR (10)
                     || CHR (13)
                     || 'Internal Port Request Action item  '
                     || task_rec.task_id
                     || ' closed successfully.';
                  v_case_history :=
                        v_case_history
                     || CHR (10)
                     || CHR (13)
                     || ' Sent for Port Approval Action item '
                     || v_task_id;

                  UPDATE table_case
                     SET case_history = v_case_history,
                         x_case2task = v_task_objid
                   WHERE id_number = v_case_id;

                  COMMIT;
               ELSIF ig_trans_rec.order_type = 'IPA'
               THEN
                  FOR opened_case_rec IN
                     opened_case_curs (call_trans_rec.x_service_id,
                                       call_trans_rec.x_min
                                      )
                  LOOP
                     IF (    opened_case_rec.title = 'Internal'
                         AND opened_case_rec.x_case_type = 'Port In'
                        )
                     THEN
                        SELECT objid
                          INTO intportinq
                          FROM table_queue
                         WHERE title = 'Internal Port Status';

                        UPDATE table_case
                           SET case_currq2queue = intportinq,
                               case_type_lvl3 = 'Approved OSP'
                         WHERE id_number = opened_case_rec.id_number;

                        COMMIT;
                        v_case_history := opened_case_rec.case_history;
                        v_case_id := opened_case_rec.id_number;
                     END IF;
                  END LOOP;

                  v_order_type := 'Internal Port Status';

                  SELECT x_part_inst2contact
                    INTO v_contact_objid
                    FROM table_part_inst
                   WHERE part_serial_no = call_trans_rec.x_service_id;

                  igate.sp_create_action_item (v_contact_objid,
                                               call_trans_rec.objid,
                                               v_order_type,
                                               1,
                                               0,
                                               v_status_out,
                                               v_action_item_id_ipa
                                              );
                  --Get order type objid
                  igate.sp_get_ordertype (call_trans_rec.x_min,
                                          v_order_type,
                                          call_trans_rec.x_call_trans2carrier,
                                          l_phonetech,
                                          v_ordertype_objid
                                         );        -- CR4579: Added Technology
                  igate.sp_check_blackout (v_action_item_id_ipa,
                                           v_ordertype_objid,
                                           v_black_out_code
                                          );

                  IF (v_black_out_code = 0)
                  THEN
                     igate.sp_determine_trans_method (v_action_item_id_ipa,
                                                      v_order_type,
                                                      NULL,
                                                      v_dest_queue
                                                     );
                  ELSIF (v_black_out_code = 1)
                  THEN
                     igate.sp_dispatch_task (v_action_item_id_ipa,
                                             'BlackOut',
                                             v_dummy
                                            );
                  ELSE
                     igate.sp_dispatch_task (v_action_item_id_ipa,
                                             'Line Management Re-work',
                                             v_dummy
                                            );
                  END IF;

                  SELECT objid, task_id
                    INTO v_task_objid, v_task_id
                    FROM table_task
                   WHERE objid = v_action_item_id_ipa;

                  v_case_history :=
                        v_case_history
                     || CHR (10)
                     || CHR (13)
                     || '*** Notes '
                     || SYSDATE
                     || ' '
                     || 'igate_in3';
                  v_case_history :=
                        v_case_history
                     || CHR (10)
                     || CHR (13)
                     || 'Internal Port Approval Action item '
                     || task_rec.task_id
                     || ' closed successfully.';
                  v_case_history :=
                        v_case_history
                     || CHR (10)
                     || CHR (13)
                     || ' Sent for Port Status Action item '
                     || v_task_id;

                  UPDATE table_case
                     SET case_history = v_case_history,
                         x_case2task = v_task_objid
                   WHERE id_number = v_case_id;

                  COMMIT;
               ELSIF ig_trans_rec.order_type = 'IPS'
               THEN
                  FOR opened_case_rec IN
                     opened_case_curs (call_trans_rec.x_service_id,
                                       call_trans_rec.x_min
                                      )
                  LOOP
                     IF (    opened_case_rec.title = 'Internal'
                         AND opened_case_rec.x_case_type = 'Port In'
                        )
                     THEN
                        v_case_history := opened_case_rec.case_history;
                        v_case_history :=
                              v_case_history
                           || CHR (10)
                           || CHR (13)
                           || '*** Notes '
                           || SYSDATE
                           || ' '
                           || 'igate_in3';
                        v_case_history :=
                              v_case_history
                           || CHR (10)
                           || CHR (13)
                           || 'Internal Port Status Action item '
                           || task_rec.task_id
                           || ' closed successfully.';

                        UPDATE table_case
                           SET case_currq2queue = intportinq,
                               case_type_lvl3 = 'Port Successful',
                               case_history = v_case_history
                         WHERE id_number = opened_case_rec.id_number;

                        COMMIT;
                        v_case_history := opened_case_rec.case_history;
                        v_case_id := opened_case_rec.id_number;
                        igate.sp_close_case (opened_case_rec.id_number,
                                             USER,
                                             'IGATE_IN',
                                             'Resolution Given',
                                             l_status,
                                             l_msg
                                            );
                     END IF;
                  END LOOP;
               --CR3327-1 Ends
               END IF;

               --CR3327 - Ends
               COMMIT;

               --ALR 4/25/2001 9:41AM -- Digital -- Added for feature failure
               -- 01/17/03
               --
               IF task_rec.x_current_method IN ('ICI', 'AOL')
               THEN
                  IF RTRIM (call_trans_rec.x_service_id) IS NOT NULL
                  THEN
                     FOR opened_case_rec IN
                        opened_case_curs (call_trans_rec.x_service_id,
                                          call_trans_rec.x_min
                                         )
                     LOOP
                        -- CR3154 - Added new titles and case types
                        IF (    opened_case_rec.title IN
                                   ('Line Inactive',
                                    'Line Inactive WEB',
                                    'Line Inactive IVR',
                                    'Inactive Features',
                                    'Voicemail not active',
                                    'Unable to Make / Unable to Receive Calls',
                                    'Caller ID not active',
                                    'Callwait not active',
                                    'Voicemail',
                                    'Caller ID',
                                    'Call Waiting',
                                    'SMS'
                                   )
                            AND opened_case_rec.x_case_type IN
                                   ('Carrier LA',
                                    'Carrier LA Features',
                                    'Features',
                                    'Line Activation'
                                   )
                           )
                        THEN
                           igate.sp_close_case (opened_case_rec.id_number,
                                                USER,
                                                'IGATE_IN',
                                                'Resolution Given',
                                                l_status,
                                                l_msg
                                               );
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
-- end 01/17/03
-- no longer call with status 'A' ra oct 21 02
--        If ig_trans_rec.status = 'A' Then
--          lCaseObjid := igate.f_Create_Case (call_Trans_Rec.objid,
--                                             Task_Rec.objid,
--                                             'Feature Failures',
--                                             'Line Activation',
--                                             'Inactive Features');
--          update table_case
--             set x_case2task = task_rec.objid
--           where objid = lCaseObjid;
--        End If;
--      End If;
--
--************************************************************************/
--*** If failure then:
--***
--***   Look for one of four types of error:
--***      1.  RETAIL ESN error
--***      2.  Failure to contact Intergate
--***      3.  Non-Topp Number (NTN) error
--***      4.  Non NTN error
--***   Map the Intergate error code to a Topp error code.
--***   If it is an NTN error:
--***      close the task
--***      Set the status to failed
--***      Create a new case
--***      dispatch new case to the re-work queue.
--***   Otherwise
--***      leave current task open
--***      change the status to failed
--***      dispatch to the Action Re-Work queue
--***      if the user is logged in then do a screen pop.
--************************************************************************/
            ELSIF ig_trans_rec.status = 'E'
            THEN
--01/17/03
--//***********************************************************************
--// if action item is created by case and action item is failed,
--//   close action item
--//***********************************************************************
               IF SUBSTR (task_rec.s_title, LENGTH (task_rec.s_title) - 4) =
                                                                      ':CASE'
               THEN
                  igate.sp_close_action_item (task_rec.objid, 0, hold);

                  UPDATE gw1.ig_transaction
                     SET status = 'F'
                   WHERE ROWID = ig_trans_rec.ROWID;

                  COMMIT;
                  GOTO next_action_item;
               END IF;

--end 01/17/03
--//***********************************************************************
--//M004 For connection failure messages, simply resend to the
--//Intergate queue for resending back to intergate
--//***********************************************************************

               -----------------------------------------------------------
-- Process status messages received from TMOBILE carrier --
-- CR4947 START                                          --
-----------------------------------------------------------
               l_b_tmobile_msg_processed := FALSE;

               IF ig_trans_rec.TEMPLATE = 'TMOBILE'
               THEN
-----------------------------
-- TMOBILE Status Messages --
-----------------------------
                  l_b_tmobile_msg_processed := TRUE;

                  IF ig_trans_rec.order_type = 'A'              -- Activation
                  THEN
---------------------------
-- *** DONE
---------------------------
                     sp_tmobile_activation_msg
                                              (p_ig_trans_rec      => ig_trans_rec);
                  ELSIF ig_trans_rec.order_type = 'E'            -- ESN Change
                  THEN
---------------------------
-- *** DONE
---------------------------
                     sp_tmobile_esn_chng_msg (p_ig_trans_rec      => ig_trans_rec);
                  ELSIF ig_trans_rec.order_type = 'MINC'         -- MIN Change
                  THEN
---------------------------
-- ***
---------------------------
                     sp_tmobile_minc_msg (p_ig_trans_rec => ig_trans_rec);
                  ELSIF ig_trans_rec.order_type = 'D'          -- Deactivation
                  THEN
---------------------------
-- ***
---------------------------
                     sp_tmobile_deact_msg (p_ig_trans_rec => ig_trans_rec);
                  ELSIF ig_trans_rec.order_type = 'S'               -- Suspend
                  THEN
---------------------------
-- ***
---------------------------
                     sp_tmobile_suspend_msg (p_ig_trans_rec => ig_trans_rec);
                  ELSE
                     -- continue with processing this transaction record
                     l_b_tmobile_msg_processed := FALSE;
                  END IF;
               END IF;

               IF l_b_tmobile_msg_processed
               THEN
                  ---------
                  -- *** --
                  ---------
                  GOTO next_action_item;
               END IF;

-----------------------------------------------------------
-- Process status messages received from TMOBILE carrier --
-- CR4947 END                                            --
-----------------------------------------------------------
               IF RTRIM (ig_trans_rec.status_message) =
                                                'Failure to contact Intergate'
               THEN
                  igate.sp_dispatch_task (task_rec.objid, 'Intergate', hold);
--//************************************************************************/
--//*** Look for a Retail ESN failure, if found:
--//*** 1.  close the task
--//*** 2.  set the status to failed esn failure
--//*** 3.  perform a createactionstatus
--//************************************************************************/
               ELSIF ig_trans_rec.status_message = 'RETAIL ESN'
               THEN
                  OPEN retail_esn_curs;

                  FETCH retail_esn_curs
                   INTO retail_esn_rec;

                  CLOSE retail_esn_curs;

                  UPDATE table_task
                     SET task_sts2gbst_elm = retail_esn_rec.objid
                   WHERE objid = task_rec.objid;

                  igate.sp_close_action_item (task_rec.objid, 2, hold);
               --CR 3153- Check for T-Mobile No Lines Available failure
               ELSIF (   ig_trans_rec.status_message =
                                      'There are no MSISDNs available for zip'
                      OR ig_trans_rec.status_message = 'W000017'
                      OR ig_trans_rec.status_message =
                                                'No Subscribers are available'
                     )
               --CR3918 (Revision 1.14)
               --Added the 3rd condition for Telegence by Mchinta on 05/20
               THEN
                  -- CR3918 to create only one case ver 1.20 Mchinta on 06/15/2005
                  SELECT COUNT (*)
                    INTO cntcase
                    FROM table_case, table_condition
                   WHERE table_condition.objid =
                                               table_case.case_state2condition
                     AND table_condition.s_title LIKE 'OPEN%'
                     AND table_case.title = 'No Line Available'
                     AND table_case.x_case_type = 'Line Management'
                     AND table_case.x_esn = call_trans_rec.x_service_id;

                  IF (cntcase = 0)
                  THEN
                     OPEN closed_case_cur (call_trans_rec.x_service_id);

                     FETCH closed_case_cur
                      INTO closed_case_rec;

                     IF closed_case_cur%NOTFOUND
                     THEN
                        lcaseobjid :=
                           igate.f_create_case (call_trans_rec.objid,
                                                task_rec.objid,
                                                'Line Management',
                                                'Line Management',
                                                'No Line Available'
                                               );
                     ELSE
                        -- Cingular Next Available project:
                        -- reopen the case
                        lcaseobjid := closed_case_rec.case_objid;
                        c_reopen_case_err_msg := NULL;
                        igate.reopen_case_proc
                           (p_case_objid           => lcaseobjid,
                            p_queue_name           => 'LINE MANAGEMENT',
                            p_notes                => 'AGENT:  This case has been re-opened and sent to the appropriate department.  Please advise the customer that lines should be available in 24 - 48 hours.',
                            p_user_login_name      => USER,
                            p_error_message        => c_reopen_case_err_msg
                           );

                        IF c_reopen_case_err_msg IS NOT NULL
                        THEN
                           toss_util_pkg.insert_error_tab_proc
                              ('Reopen case: calling stored proc igate.reopen_case_proc',
                               lcaseobjid,
                               l_program_name,
                                  'ESN = '
                               || call_trans_rec.x_service_id
                               || ' '
                               || c_reopen_case_err_msg
                              );

                           CLOSE closed_case_cur;

                           GOTO next_action_item;
                        END IF;
                     END IF;

                     CLOSE closed_case_cur;
                  END IF;

                  -- CR3918 End ver 1.20 Mchinta on 06/15/2005
                  igate.sp_dispatch_task (task_rec.objid,
                                          'GSM Action Re-Work',
                                          hold
                                         );     --CR3918 mchinta on 05/27/2005
   --igate.sp_Close_Action_Item(task_rec.Objid, 3, hold);
--CR 3153 Ends
--//***********************************************************************
--//*** Check for an NTN or NON-NTN error
--//***********************************************************************
               ELSE
                  OPEN topp_err_curs (carrier_rec.objid,
                                      ig_trans_rec.status_message
                                     );

                  FETCH topp_err_curs
                   INTO topp_err_rec;

                  IF topp_err_curs%NOTFOUND
                  THEN
                     OPEN gen_err_curs;

                     FETCH gen_err_curs
                      INTO topp_err_rec;

                     IF gen_err_curs%NOTFOUND
                     THEN
                        ROLLBACK;

                        CLOSE topp_err_curs;               --Fix OPEN_CURSORS

                        CLOSE gen_err_curs;

                        toss_util_pkg.insert_error_tab_proc
                           ('Retrieve "System Malfunction"
    error record
    from table_x_topp_err_codes',
                            ig_trans_rec.action_item_id,
                            l_program_name,
                            'No "System Malfunction"
    record found.'
                           );
                        GOTO next_action_item;
                     END IF;

                     CLOSE gen_err_curs;
                  END IF;

                  CLOSE topp_err_curs;

                  --we have found either the default or a specific error
                  --//*** Is it a NTN (non Topp Number) error? If so then close the task,
                  --//*** set the status to 'failed', create a new case, and dispatch to*/
                  --//*** the re-work queue*/
                  --If InStr (ErrorRec.GetField("x_code_name"), "NON-TOPP MIN", 1) <> 0 Then
                  IF topp_err_rec.x_code_name = 'Non Tracfone #'
                  THEN
                     OPEN failed_ntn_curs;

                     FETCH failed_ntn_curs
                      INTO failed_ntn_rec;

                     IF failed_ntn_curs%NOTFOUND
                     THEN
                        failed_ntn_rec.x_text := 'Line Activation';
                     END IF;

                     CLOSE failed_ntn_curs;

                     -- 01/17/03 close case
                     DBMS_OUTPUT.put_line (   'current method: '
                                           || task_rec.x_current_method
                                          );

                     IF task_rec.x_current_method IN ('ICI', 'AOL')
                     THEN
                        IF RTRIM (call_trans_rec.x_service_id) IS NOT NULL
                        THEN
                           FOR opened_case_rec IN
                              opened_case_curs (call_trans_rec.x_service_id,
                                                call_trans_rec.x_min
                                               )
                           LOOP
                              igate.sp_close_case (opened_case_rec.id_number,
                                                   USER,
                                                   'IGATE_IN',
                                                   'Resolution Given',
                                                   l_status,
                                                   l_msg
                                                  );
                           END LOOP;
                        END IF;
                     END IF;

                     --end 01/17/03
                     lcaseobjid :=
                        igate.f_create_case (call_trans_rec.objid,
                                             task_rec.objid,
                                             failed_ntn_rec.x_text,
                                             'Line Activation',
                                             'Non Tracfone #'
                                            );
                     igate.sp_close_action_item (task_rec.objid, 3, hold);

                     -- 'Added by EJM 10/11/00 5:17 PM.

                     -- Deactive ntn line only when the min from IG  is the same min as the active
                     -- one for the esn at the moment
                     -- CR 1001      12/09/02
                     IF (    ig_trans_rec.MIN = site_part_rec.x_min
                         AND site_part_rec.part_status = 'Active'
                        )
                     THEN
                        sp_deactivate_ntn.deactivate_ntn
                                                (call_trans_rec.x_service_id,
                                                 hold2
                                                );
                     END IF;
                  -- CR 1001
                  --//*** must be a known Topp error, change the status, dispatch, and notify user*/
                  ELSE
                     OPEN failed_open_curs;

                     FETCH failed_open_curs
                      INTO failed_open_rec;

                     IF failed_open_curs%NOTFOUND
                     THEN
                        ROLLBACK;

                        CLOSE failed_open_curs;

                        toss_util_pkg.insert_error_tab_proc
                           ('Retrieve "Failed - Open"
    record
    from
    table gbst_elm
    and gbst_lst',
                            ig_trans_rec.action_item_id,
                            l_program_name,
                            'No "Failed - Open"
    record found.'
                           );
                        GOTO next_action_item;
                     END IF;

                     CLOSE failed_open_curs;

                     UPDATE table_task
                        SET task_sts2gbst_elm = failed_open_rec.objid
                      WHERE objid = task_rec.objid;

                     --//*** now we are ready to dispatch. Map the queue based on
                     --//*** the order type
                     IF ig_trans_rec.order_type IN ('A', 'E')
                     THEN
                        rtain_strqueue := str_reworkq;
                     ELSIF ig_trans_rec.order_type IN ('D', 'S')
                     THEN
                        rtain_strqueue := 'Line Management Re-work';
                     ELSE
                        rtain_strqueue := str_reworkq;
                     END IF;

                     igate.sp_dispatch_task (task_rec.objid,
                                             rtain_strqueue,
                                             hold
                                            );
                  END IF;

                  --Now, relate the Topp error to the task
                  UPDATE table_task
                     SET x_task2x_topp_err_codes = topp_err_rec.objid
                   WHERE objid = task_rec.objid;

                  UPDATE gw1.ig_transaction
                     SET status = 'F'
                   WHERE ROWID = ig_trans_rec.ROWID;

                  COMMIT;
               END IF;
----------------------------------------------------
-- CR3153 - For status 'CP' update the min in all --
-- tables for T-Mobile and flag the               --
-- line for MSID update                           --
-- CR3918 Starts                                  --
----------------------------------------------------
--------------------------------------------
-- CINGULAR "NEXT AVAILABLE" CHANGES      --
-- Flag the number coming back from       --
-- Cingular for MSID (personality) update --
--------------------------------------------
            ELSIF     ig_trans_rec.status = 'CP'
                  AND (   (    ig_trans_rec.MIN LIKE 'T%'
                           AND ig_trans_rec.order_type = 'A'
                          )
                       OR (ig_trans_rec.order_type = 'MINC')
                      )
            --CR3918 Ends
            THEN
               UPDATE gw1.ig_transaction
                  SET status = 'CPU'
                WHERE ROWID = ig_trans_rec.ROWID;

               COMMIT;
            --CR 3153 - Ends
            END IF;
--------------------------------------------------------------------------------------
-- no longer called with status 'Q' ra oct 21 02
--      If ig_trans_rec.status = 'Q' Then
--        --//*** Set the task status to 'Queued'
--        open queued_curs;
--          fetch queued_curs into queued_rec;
--        close queued_curs;
--        update table_task
--          set task_sts2gbst_elm = queued_rec.objid,
--              x_queued_flag = '1'
--         where objid = task_rec.objid;
--       igate.sp_Dispatch_Task(Task_Rec.objid,'Intergate-Queued',hold);
--      End If;
--01/29/03
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK;
               toss_util_pkg.insert_error_tab_proc
                                          (   'Process ig transaction id:  '
                                           || ig_trans_rec.action_item_id,
                                           ig_trans_rec.action_item_id,
                                           l_program_name,
                                           SUBSTR (SQLERRM, 1, 255)
                                          );
         END;

         <<next_action_item>>
         --blnUpdated :=false; --CR3440
         NULL;
      END LOOP;

END SP_DUGGI_IGATE;
/