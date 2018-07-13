CREATE OR REPLACE PACKAGE BODY sa."BILLING_ADMIN_CONSOLE_NOTIFY"
IS
   FUNCTION billing_payment_received (
      p_enroll_objid      IN   NUMBER,
      p_last_trans_date   IN   DATE
   )
      RETURN NUMBER
   IS
      exp_null        EXCEPTION;
      l_next_date     DATE;
      l_sysdate       DATE           DEFAULT TRUNC (SYSDATE);
      l_err           NUMBER;
      l_err_message   VARCHAR2 (255);
      v_count         NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO v_count
        FROM x_program_purch_hdr a,
             x_program_purch_dtl b,
             x_program_enrolled c
       WHERE a.objid = b.pgm_purch_dtl2prog_hdr
         AND b.pgm_purch_dtl2pgm_enrolled = c.objid
         AND c.objid = p_enroll_objid
         AND a.x_ics_rcode IN
                ('1', '100')
                            -- Success records for RealTime and Batch Payments
         AND a.x_rqst_date >= p_last_trans_date;

      IF (v_count > 0)
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   /* ------------- Old Logic : will not work for deactivation protection program -----------------------
   BEGIN
      SELECT TRUNC (x_next_charge_date)
        INTO l_next_date
        FROM x_program_enrolled
       WHERE objid = p_enroll_objid;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN -1;
   END;

   IF l_next_date IS NULL
   THEN
      RAISE exp_null;
   END IF;

   IF l_next_date >= l_sysdate
   THEN
      RETURN 1;
   ELSE
      RETURN -1;
   END IF;
      ------------------------------------------------------------------------------------------------------ */
   EXCEPTION
      /*
      WHEN exp_null
      THEN
         raise_application_error (-20001, 'Next Charge Date is Null');
      */
      WHEN OTHERS
      THEN
         -- Put in the values into the output variables.
         l_err := SQLCODE;
         l_err_message := SUBSTR (SQLERRM, 1, 255);
          /*
          ------------------------ Exception Logging --------------------------------------------------------------------
          ---  Incase of any Exceptions, Log the data in the Error Log table for debugging purposes.

          insert into x_program_error_log
          (
             x_source,
             x_error_code,
             x_error_msg,
             x_date,
             x_description,
             x_severity
          )
          values
         (
             'billing_admin_console_notify.billing_payment_received',
             l_err,
             l_err_message,
             sysdate,
             'Program Enrolled ' || to_char(p_enroll_objid),
             3 -- LOW
          );
         ------------------------ Exception Logging --------------------------------------------------------------------
         */
         RETURN -1;
   END billing_payment_received;

   FUNCTION billing_paynow_activity (
      p_enroll_objid      IN   NUMBER,
      p_last_trans_date   IN   DATE
   )
      RETURN NUMBER
   IS
      exp_null      EXCEPTION;
      l_next_date   DATE;
      l_sysdate     DATE      DEFAULT TRUNC (SYSDATE);
      v_count       NUMBER;
   BEGIN
      /*
            Fetch all the records from the purchase header records from the last_transaction_date.
            If any one of the records is a success, then return 1: Payment Received.
      */
      SELECT COUNT (*)
        INTO v_count
        FROM x_program_purch_hdr a,
             x_program_purch_dtl b,
             x_program_enrolled c
       WHERE a.objid = b.pgm_purch_dtl2prog_hdr
         AND b.pgm_purch_dtl2pgm_enrolled = c.objid
         AND c.objid = p_enroll_objid
         --and a.x_ics_rcode in ( '1','100')      -- Success records for RealTime and Batch Payments
         AND a.x_rqst_date >= p_last_trans_date;

      IF (v_count > 0)
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   /*
   BEGIN
      SELECT TRUNC (x_next_charge_date)
        INTO l_next_date
        FROM x_program_enrolled
       WHERE objid = p_enroll_objid;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN -1;
   END;

   IF l_next_date IS NULL
   THEN
      RAISE exp_null;
   END IF;

   IF l_next_date >= l_sysdate
   THEN
      RETURN 1;
   ELSE
      RETURN -1;
   END IF;

   RETURN 1;
   */
   EXCEPTION
      WHEN exp_null
      THEN
         raise_application_error (-20001, 'Next Charge Date is Null');
      WHEN OTHERS
      THEN
         RETURN -1;
   END billing_paynow_activity;

   /*
        This procedure returns the credit-card expiry, given any funding source.
        This is deprecated as of 02-May-2006.
   */
   PROCEDURE billing_cc_expiry (
      p_payment_source_objid   IN       NUMBER,
      p_month                  OUT      table_x_credit_card.x_customer_cc_expmo%TYPE,
      p_year                   OUT      table_x_credit_card.x_customer_cc_expyr%TYPE,
      op_result                OUT      NUMBER,
      op_msg                   OUT      VARCHAR2
   )
   IS
   /*
        Return:
                -1      :    'No record found for the credit card'
                 1      :    Success
               -900     :    Database Exception
   */
   BEGIN
      BEGIN
         SELECT x_customer_cc_expmo, x_customer_cc_expyr
           INTO p_month, p_year
           FROM table_x_credit_card
          WHERE objid = (SELECT pymt_src2x_credit_card
                           FROM x_payment_source
                          WHERE objid = p_payment_source_objid);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            op_result := -1;
            op_msg := ' No Record Found in Credit Card / Payment Source';
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -900;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
   /*
   ------------------------ Exception Logging --------------------------------------------------------------------
   ---  Incase of any Exceptions, Log the data in the Error Log table for debugging purposes.
   insert into x_program_error_log
    (
      x_source,
      x_error_code,
      x_error_msg,
      x_date,
      x_description,
      x_severity
    )
    values
    (
      'billing_cc_expiry',
      op_result,
      op_msg,
      sysdate,
      'Payment source objid ' || to_char(p_payment_source_objid),
      3 -- LOW
    );
    ------------------------ Exception Logging --------------------------------------------------------------------
    */
   END billing_cc_expiry;

   /*
        This procedure returns if there has been any credit card activity from the given input date.
   */
   FUNCTION billing_ccactivity (
      p_enroll_objid      IN   NUMBER,
      p_last_trans_date   IN   DATE
   )
      RETURN NUMBER
    /*
                -1       -   Either the payment type is ACH / No credit card record exists(data inconsistency)
                 1       -   Account activity has happened.
                 0       -   No Account activity has happened.
   */
   IS
      l_changedate             DATE;
      l_payment_source_objid   x_payment_source.objid%TYPE;
   BEGIN
      ---------- Get the payment source associated with the enrollment --------------------------------
      SELECT pgm_enroll2x_pymt_src
        INTO l_payment_source_objid
        FROM x_program_enrolled
       WHERE objid = p_enroll_objid;

      BEGIN
         SELECT x_changedate
           INTO l_changedate
           FROM table_x_credit_card
          WHERE objid = (SELECT pymt_src2x_credit_card
                           FROM x_payment_source
                          WHERE objid = l_payment_source_objid);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ----' No Record Found in Credit Card / Payment Source';
            RETURN -1;
      END;

---------------------------------------------------------------------------------------------------
      IF (l_changedate > p_last_trans_date)
      THEN
         RETURN 1;              -- Credit Card account activity has happened.
      ELSE
         RETURN 0;           -- No Credit Card account activity has happened.
      END IF;
---------------------------------------------------------------------------------------------------
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN -1;                               -- No payment source exists
   END;

   /*
        This procedure returns the credit-card expiry, given any funding source.
        Utility function - Currently not used by front-end.
   */
   FUNCTION billing_isvalidfundingsource (
      p_enroll_objid    IN   NUMBER,                      --- Enrollment objid
      p_date_notified   IN   DATE
                                --- Date when the last notification was issued
   )
      RETURN NUMBER
   IS
      /*
           Return:
                    0      :    Funding source has expired / invalid
                    1      :    Funding Source is valid
                    -1     :    No funding source / ACH funding
                  -900     :    Database Exception
      */
      /*
           If the date in the database is greater than the date on record for the notification system,

      */
      l_payment_source_objid   x_payment_source.objid%TYPE;
      l_mod_date               table_x_credit_card.x_changedate%TYPE;
      l_month                  table_x_credit_card.x_customer_cc_expmo%TYPE;
      l_year                   table_x_credit_card.x_customer_cc_expyr%TYPE;
      l_date                   DATE;
      op_result                NUMBER;
      op_msg                   VARCHAR2 (255);
   BEGIN
      ---------- Get the payment source associated with the enrollment --------------------------------
      SELECT pgm_enroll2x_pymt_src
        INTO l_payment_source_objid
        FROM x_program_enrolled
       WHERE objid = p_enroll_objid;

      BEGIN
         SELECT x_customer_cc_expmo, x_customer_cc_expyr, x_changedate
           INTO l_month, l_year, l_mod_date
           FROM table_x_credit_card
          WHERE objid = (SELECT pymt_src2x_credit_card
                           FROM x_payment_source
                          WHERE objid = l_payment_source_objid);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            ----' No Record Found in Credit Card / Payment Source';
            RETURN -1;
      END;

      ----------------------- Check if the date was modified -------------------------------------------
      IF (l_mod_date > p_date_notified)
      THEN
         RETURN 1;
                  -- Do not send any more notification. The date was changed.
      END IF;

      ----------- Check if the month/year is greater than today -----------------------------------------
      SELECT LAST_DAY (TO_DATE ('01/' || l_month || '/' || l_year,
                                'dd/mm/yyyy'
                               )
                      )
        INTO l_date
        FROM DUAL;

      ------ If the credit card is expiring this month, or has already expired,
      ------ return false
      ----------- Checking for expired card    ----------------------------------------------------------
      IF (l_date < SYSDATE)
      THEN
         RETURN 0;
      ELSE
         ---- Check if the credit card is expiring this month
         IF (TO_CHAR (l_date, 'MM/YYYY') = TO_CHAR (SYSDATE, 'MM/YYYY'))
         THEN
            RETURN 0;
         END IF;

         RETURN 1;
      END IF;
---------------------------------------------------------------------------------------------------
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -900;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
         DBMS_OUTPUT.put_line (op_msg);
         /*
         ------------------------ Exception Logging ----------------------------------------------------
         ---  Incase of any Exceptions, Log the data in the Error Log table for debugging purposes.
         insert into x_program_error_log
          (
            x_source,
            x_error_code,
            x_error_msg,
            x_date,
            x_description,
            x_severity
          )
          values
          (
            'billing_isvalidfundingSource',
            op_result,
            op_msg,
            sysdate,
            'Enrollment objid ' || to_char(p_enroll_objid),
            3 -- LOW
          );
          ------------------------ Exception Logging ---------------------------------------------------
          */
         RETURN 0;
   END billing_isvalidfundingsource;

   /*
       This procedure returns the current enrollment status of the program given the enrollment objid
   */
   PROCEDURE billing_programs_status (
      p_enroll_objid     IN       NUMBER,
      p_program_status   OUT      VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   )
   IS
   BEGIN
      BEGIN
         SELECT x_enrollment_status
           INTO p_program_status
           FROM x_program_enrolled
          WHERE objid = p_enroll_objid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            op_result := -1;
            op_msg := ' No Enrollment Record Found';
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -900;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
   /*
   ------------------------ Exception Logging --------------------------------------------------------------------
   ---  Incase of any Exceptions, Log the data in the Error Log table for debugging purposes.
   insert into x_program_error_log
    (
      x_source,
      x_error_code,
      x_error_msg,
      x_date,
      x_description,
      x_severity
    )
    values
    (
      'billing_programs_status',
      op_result,
      op_msg,
      sysdate,
      'Enrollment objid ' || to_char(p_enroll_objid),
      3 -- LOW
    );
    ------------------------ Exception Logging --------------------------------------------------------------------
    */
   END billing_programs_status;

   /*
       This procedure returns the current status of the ESN
   */
   PROCEDURE billing_esn_status (
      p_esn           IN       VARCHAR2,
      p_part_status   OUT      VARCHAR2,
      op_result       OUT      NUMBER,
      op_msg          OUT      VARCHAR2
   )
   IS
   BEGIN
      BEGIN
         SELECT a.part_status
           INTO p_part_status
           FROM table_site_part a, table_part_inst b
          WHERE a.x_service_id = p_esn AND a.objid = b.x_part_inst2site_part;

         op_result := 0;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            op_result := -1;
            op_msg := ' No Enrollment Record Found';
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -900;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
   /*
   ------------------------ Exception Logging --------------------------------------------------------------------
   ---  Incase of any Exceptions, Log the data in the Error Log table for debugging purposes.
   insert into x_program_error_log
    (
      x_source,
      x_error_code,
      x_error_msg,
      x_date,
      x_description,
      x_severity
    )
    values
    (
      'billing_esn_status',
      op_result,
      op_msg,
      sysdate,
      'ESN ' || p_esn,
      3 -- LOW
    );
    ------------------------ Exception Logging --------------------------------------------------------------------
    */
   END billing_esn_status;

   /*
       This procedure is used from the Chargeback Reports, to remove a suspension on the given ESN.
   */
   PROCEDURE billing_remove_suspension (
      p_enrolled_objid    IN       VARCHAR2,
      p_merchant_ref_no   IN       VARCHAR2,
      p_user              IN       VARCHAR2,
      op_result           OUT      NUMBER,
      op_msg              OUT      VARCHAR2,
      op_case_number      OUT      table_case.id_number%TYPE
   )
   IS
      CURSOR program_enroll_cur (c_enroll_objid NUMBER)
      IS
         SELECT *
           FROM x_program_enrolled
          WHERE (   objid = c_enroll_objid
                 OR pgm_enroll2pgm_group = c_enroll_objid
                )
            AND x_enrollment_status = 'SUSPENDED';

      l_program_enroll_rec   program_enroll_cur%ROWTYPE;
      l_first_name           table_contact.first_name%TYPE;
      l_last_name            table_contact.last_name%TYPE;
      l_count                NUMBER;
      l_service_end_dt       DATE;
      l_case_number          table_case.id_number%TYPE;
      l_status               VARCHAR2 (255);
      l_message              VARCHAR2 (255);
   BEGIN
      OPEN program_enroll_cur (p_enrolled_objid);

      LOOP
         FETCH program_enroll_cur
          INTO l_program_enroll_rec;

         EXIT WHEN program_enroll_cur%NOTFOUND;

         ------------------------------ Check if the ESN is still active --------------------------------
         BEGIN
            --
            -- Start CR13082 Kacosta 01/21/2011
            --SELECT service_end_dt
            --  INTO l_service_end_dt
            --  FROM table_site_part
            -- WHERE x_service_id IN (l_program_enroll_rec.x_esn)
            --   AND part_status = 'Active';
            SELECT tsp.service_end_dt
              INTO l_service_end_dt
              FROM table_part_inst tpi
                  ,table_site_part tsp
             WHERE tsp.x_service_id IN (l_program_enroll_rec.x_esn)
               AND tsp.part_status = 'Active'
               AND tsp.objid = tpi.x_part_inst2site_part
               AND tpi.x_part_inst_status = '52'
               AND tpi.x_domain = 'PHONES';
            -- End CR13082 Kacosta 01/21/2011
            --
-------------------------------------------------------
--- Kludge: Lots of records have service_end_date less than today,
---         but are still active.
---         Commenting this out temporarily.
/*
IF ( l_service_end_dt < sysdate ) THEN
           op_result := -1;
           op_msg    := 'ESN is not in Active';
           RETURN;
END IF;
*/
         EXCEPTION
            WHEN OTHERS
            THEN
               op_result := -1;
               op_msg := 'ESN is not in Active';
               RETURN;
         END;

------------------------------------------------------------------------------------------------
         INSERT INTO x_program_trans
                     (objid,
                      x_enrollment_status,
                      x_enroll_status_reason, x_float_given, x_cooling_given,
                      x_grace_period_given, x_trans_date, x_action_text,
                      x_action_type,
                      x_reason,
                      x_sourcesystem,
                      x_esn,
                      x_exp_date, x_cooling_exp_date, x_update_status,
                      x_update_user, pgm_tran2pgm_entrolled,
                      pgm_trans2web_user,
                      pgm_trans2site_part
                     )
              VALUES (billing_seq ('X_PROGRAM_TRANS'),
                      l_program_enroll_rec.x_enrollment_status,
                      l_program_enroll_rec.x_reason, NULL, NULL,
                      NULL, SYSDATE, 'Remove Suspension',
                      'ENROLLMENT',                     --'REMOVE_SUSPENSION',
                         (SELECT x_program_name
                            FROM x_program_parameters
                           WHERE objid =
                                    l_program_enroll_rec.pgm_enroll2pgm_parameter)
                      || '    - Suspension Removed',
                      l_program_enroll_rec.x_sourcesystem,
                      l_program_enroll_rec.x_esn,
                      l_program_enroll_rec.x_exp_date, NULL, 'I',
                      NVL (p_user, 'System'), l_program_enroll_rec.objid,
                      l_program_enroll_rec.pgm_enroll2web_user,
                      l_program_enroll_rec.pgm_enroll2site_part
                     );

         UPDATE x_program_enrolled
            SET x_enrollment_status = 'ENROLLED',
                x_reason = 'Chargeback Resolution',
                -- x_next_charge_date  = null,  -- -What do we do for this?
                x_next_charge_date =
                   CASE
                      WHEN x_next_charge_date > SYSDATE
                         THEN x_next_charge_date
                      ELSE billing_payment_recon_pkg.get_next_cycle_date
                               (l_program_enroll_rec.pgm_enroll2pgm_parameter,
                                x_next_charge_date
                               )
                   END,
                -- Assumption: Chargeback will be resolved within one additional cycle.
                x_next_delivery_date =
                   CASE
                      WHEN x_next_delivery_date > SYSDATE
                         THEN x_next_delivery_date
                      ELSE billing_getnearestdeliverydate
                               (l_program_enroll_rec.pgm_enroll2pgm_parameter,
                                x_next_delivery_date
                               )
                   END,
                x_wait_exp_date = NULL,
                x_update_stamp = SYSDATE
          WHERE objid = l_program_enroll_rec.objid;

         ------------- Get the details required for logging -----------------------------------------------
         SELECT first_name, last_name
           INTO l_first_name, l_last_name
           FROM table_contact
          WHERE objid =
                     (SELECT web_user2contact
                        FROM table_web_user
                       WHERE objid = l_program_enroll_rec.pgm_enroll2web_user);

         INSERT INTO x_billing_log
                     (objid, x_log_category,
                      x_log_title, x_log_date,
                      x_details,
                      x_nickname,
                      x_esn, x_originator,
                      x_contact_first_name, x_contact_last_name,
                      x_agent_name,
                      x_sourcesystem,
                      billing_log2web_user
                     )
              VALUES (billing_seq ('X_BILLING_LOG'), 'Program',
                      'Chargeback Resolution', SYSDATE,
                         (SELECT x_program_name
                            FROM x_program_parameters
                           WHERE objid =
                                    l_program_enroll_rec.pgm_enroll2pgm_parameter)
                      || '    - Suspension Removed',
                      billing_getnickname (l_program_enroll_rec.x_esn),
                      l_program_enroll_rec.x_esn, NVL (p_user, 'System'),
                      l_first_name, l_last_name,
                      NVL (p_user, 'System'),
                      l_program_enroll_rec.x_sourcesystem,
                      l_program_enroll_rec.pgm_enroll2web_user
                     );
      END LOOP;

      CLOSE program_enroll_cur;

      ---------------- Find if there are more records associated with the given merchant ref number that are not processed ---------------------------
      SELECT COUNT (*)
        INTO l_count
        FROM x_program_enrolled a,
             x_program_purch_dtl b,
             x_program_purch_hdr c
       WHERE a.x_enrollment_status = 'SUSPENDED'
         AND a.x_reason != 'Chargeback Resolution'
         AND a.objid = b.pgm_purch_dtl2pgm_enrolled
         AND b.pgm_purch_dtl2prog_hdr = c.objid
         AND c.x_merchant_ref_number = p_merchant_ref_no;

      ----------------- Update the chargeback pending record.
      IF (l_count = 0)
      THEN
         UPDATE    x_cc_chargeback_trans
               SET x_processed = 'PROCESSED'
             WHERE x_processed = 'PENDINGINVESTIGATION'
               AND x_merch_order_number =
                            (SELECT x_bill_trans_ref_no
                               FROM x_program_purch_hdr
                              WHERE x_merchant_ref_number = p_merchant_ref_no)
         RETURNING x_case_number
              INTO l_case_number;

         -------------------- Since there are no more pending cases, close the case ------------------------
         BEGIN
            IF (l_case_number IS NOT NULL AND l_case_number != 0)
            THEN
                             /*CREATE_CASE_PKG.sp_close_case(
                                                            l_case_number,
                                                            p_user,
                                                            null,
                                                            null,
                                                            l_status,
                                                            l_message
                                                           );
               */
               clarify_case_pkg.close_case
                                (l_case_number,       -- p_case_objid  NUMBER,
                                 p_user, --  p_user_objid              NUMBER,
                                 NULL,                 --   p_source VARCHAR2,
                                 NULL,             --   p_resolution VARCHAR2,
                                 NULL,                --- p_status   VARCHAR2,
                                 l_status,      ---  P_error_no OUT  VARCHAR2,
                                 l_message    ---  P_error_str OUT  VARCHAR2);
                                );
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;     -- Supress any exception that is raised by this call
         END;

---------------------------------------------------------------------------------------------------
         op_result := 1;                 -- Success - No chargebacks remaining
         op_msg := 'Success';                                      --- Success
         op_case_number := l_case_number;
         COMMIT;
         RETURN;
      END IF;

      COMMIT;
      op_result := 0;                                               -- Success
      op_msg := 'Success';                                          -- Success
      op_case_number := l_case_number;
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
     /*
     ------------------------ Exception Logging --------------------------------------------------------------------
     ---  Incase of any Exceptions, Log the data in the Error Log table for debugging purposes.

     insert into x_program_error_log
       (
         x_source,
         x_error_code,
         x_error_msg,
         x_date,
         x_description,
         x_severity
       )
     values
      (
         'billing_remove_suspension',
         op_result,
         op_msg,
         sysdate,
         ' Enrolled Objid ' || to_char(p_enrolled_objid) || ' Merchant Ref Number ' || p_merchant_ref_no,
         2 -- LOW
        );
   ------------------------ Exception Logging --------------------------------------------------------------------
   */
   END billing_remove_suspension;

   /*
       This procedure executes a de-enroll action as part of the chargeback investigation
   */
   PROCEDURE billing_de_enroll (
      p_enrolled_objid    IN       VARCHAR2,
      p_merchant_ref_no   IN       VARCHAR2,
      p_user              IN       VARCHAR2,
      op_result           OUT      NUMBER,
      op_msg              OUT      VARCHAR2,
      op_case_number      OUT      table_case.id_number%TYPE
   )
   IS
      CURSOR program_enroll_cur (c_enroll_objid NUMBER)
      IS
         SELECT *
           FROM x_program_enrolled
          WHERE objid = c_enroll_objid;

      l_program_enroll_rec   program_enroll_cur%ROWTYPE;
      l_first_name           table_contact.first_name%TYPE;
      l_last_name            table_contact.last_name%TYPE;
      l_count                NUMBER;
      l_status               VARCHAR2 (255);
      l_message              VARCHAR2 (255);
      l_case_number          table_case.id_number%TYPE;
   BEGIN
      OPEN program_enroll_cur (p_enrolled_objid);

      LOOP
         FETCH program_enroll_cur
          INTO l_program_enroll_rec;

         EXIT WHEN program_enroll_cur%NOTFOUND;
         billing_rule_engine_action_pkg.de_enroll_rule_action
                                                 (l_program_enroll_rec.x_esn,
                                                  l_program_enroll_rec.objid,
                                                  NULL,
                                                  NULL,
                                                  NULL,
                                                  'Chargeback Resolution',
                                                  NULL,
                                                  op_result,
                                                  op_msg
                                                 );

         ------------------ Log into Billing_log table ------------------------------------------------------------
         SELECT first_name, last_name
           INTO l_first_name, l_last_name
           FROM table_contact
          WHERE objid =
                     (SELECT web_user2contact
                        FROM table_web_user
                       WHERE objid = l_program_enroll_rec.pgm_enroll2web_user);

         INSERT INTO x_billing_log
                     (objid, x_log_category,
                      x_log_title,
                      x_details,
                      x_program_name,
                      x_nickname,
                      x_esn, x_originator,
                      x_contact_first_name, x_contact_last_name,
                      x_agent_name,
                      x_sourcesystem,
                      billing_log2web_user
                     )
              VALUES (billing_seq ('X_BILLING_LOG'), 'Program',
                      'Program De-enrolled',
                      'Chargeback Resolution - DeEnroll Action',
                      (SELECT x_program_name
                         FROM x_program_parameters
                        WHERE objid =
                                 l_program_enroll_rec.pgm_enroll2pgm_parameter),
                      billing_getnickname (l_program_enroll_rec.x_esn),
                      l_program_enroll_rec.x_esn, NVL (p_user, 'System'),
                      l_first_name, l_last_name,
                      NVL (p_user, 'System'),
                      l_program_enroll_rec.x_sourcesystem,
                      l_program_enroll_rec.pgm_enroll2web_user
                     );
----------------------------------------------------------------------------------------------------------
      END LOOP;

      CLOSE program_enroll_cur;

      ---------------- Find if there are more records associated with the given merchant ref number that are not processed ---------------------------
      SELECT COUNT (*)
        INTO l_count
        FROM x_program_enrolled a,
             x_program_purch_dtl b,
             x_program_purch_hdr c
       WHERE a.x_enrollment_status = 'SUSPENDED'
         AND a.x_reason != 'Chargeback Resolution'
         AND a.objid = b.pgm_purch_dtl2pgm_enrolled
         AND b.pgm_purch_dtl2prog_hdr = c.objid
         AND c.x_merchant_ref_number = p_merchant_ref_no;

      ----------------- Update the chargeback pending record.
      IF (l_count = 0)
      THEN
         UPDATE    x_cc_chargeback_trans
               SET x_processed = 'PROCESSED'
             WHERE x_processed = 'PENDINGINVESTIGATION'
               AND x_merch_order_number =
                            (SELECT x_bill_trans_ref_no
                               FROM x_program_purch_hdr
                              WHERE x_merchant_ref_number = p_merchant_ref_no)
         RETURNING x_case_number
              INTO l_case_number;

         -------------------- Since there are no more pending cases, close the case ------------------------
         BEGIN
            IF (l_case_number IS NOT NULL AND l_case_number != 0)
            THEN
                  /*CREATE_CASE_PKG.sp_close_case(
                                                 l_case_number,
                                                 p_user,
                                                 null,
                                                 null,
                                                 l_status,
                                                 l_message
                                                );
               */
               clarify_case_pkg.close_case
                                (l_case_number,       -- p_case_objid  NUMBER,
                                 p_user, --  p_user_objid              NUMBER,
                                 NULL,                 --   p_source VARCHAR2,
                                 NULL,             --   p_resolution VARCHAR2,
                                 NULL,                --- p_status   VARCHAR2,
                                 l_status,      ---  P_error_no OUT  VARCHAR2,
                                 l_message    ---  P_error_str OUT  VARCHAR2);
                                );
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;     -- Supress any exception that is raised by this call
         END;

---------------------------------------------------------------------------------------------------
         op_result := 1;                 -- Success - No chargebacks remaining
         op_msg := 'Success';                                      --- Success
      END IF;

      IF (op_result = NULL OR op_result = 0)
      THEN
         ---Success
         op_result := 0;
         op_msg := 'Success';
      END IF;

      op_case_number := l_case_number;
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
     /*
     ------------------------ Exception Logging --------------------------------------------------------------------
     ---  Incase of any Exceptions, Log the data in the Error Log table for debugging purposes.

     insert into x_program_error_log
       (
         x_source,
         x_error_code,
         x_error_msg,
         x_date,
         x_description,
         x_severity
       )
    values
      (
         'billing_de_enroll',
         op_result,
         op_msg,
         sysdate,
         ' Enrolled Objid ' || to_char(p_enrolled_objid) || ' Merchant Ref Number ' || p_merchant_ref_no,
         2 -- LOW
       );
   ------------------------ Exception Logging --------------------------------------------------------------------
   */
   END billing_de_enroll;

   /*
       This function closes a chargeback case that is created.

   */
   PROCEDURE billing_close_case (
      p_enrolled_objid    IN       VARCHAR2,
      p_merchant_ref_no   IN       VARCHAR2,
      p_user              IN       VARCHAR2,
      op_result           OUT      NUMBER,
      op_msg              OUT      VARCHAR2,
      op_case_number      OUT      table_case.id_number%TYPE
   )
   IS
      CURSOR program_enroll_cur (c_enroll_objid NUMBER)
      IS
         SELECT *
           FROM x_program_enrolled
          WHERE (   objid = c_enroll_objid
                 OR pgm_enroll2pgm_group = c_enroll_objid
                );

      l_program_enroll_rec   program_enroll_cur%ROWTYPE;
      l_first_name           table_contact.first_name%TYPE;
      l_last_name            table_contact.last_name%TYPE;
      l_case_number          table_case.id_number%TYPE;
      l_objid                x_cc_chargeback_trans.objid%TYPE;
      l_count                NUMBER;
      l_status               VARCHAR2 (255);
      l_message              VARCHAR2 (255);
   BEGIN
      OPEN program_enroll_cur (p_enrolled_objid);

      LOOP
         FETCH program_enroll_cur
          INTO l_program_enroll_rec;

         EXIT WHEN program_enroll_cur%NOTFOUND;

 ---- Insert a record into Service History Table
 /* When we close the case, don't create a record for service history
 INSERT INTO x_program_trans
                (objid,
                 x_enrollment_status, x_enroll_status_reason,
                 x_float_given, x_cooling_given, x_grace_period_given,
                 x_trans_date, x_action_text, x_action_type,
                 x_reason,
                 x_sourcesystem,
                 x_esn, x_exp_date, x_cooling_exp_date,
                 x_update_status, x_update_user,
                 pgm_tran2pgm_entrolled,
                 pgm_trans2web_user,
                 pgm_trans2site_part
                 )
         VALUES (billing_seq ('X_PROGRAM_TRANS'),
                 l_program_enroll_rec.x_enrollment_status, l_program_enroll_rec.x_reason,
                 NULL, NULL, NULL,
                 sysdate, 'Payment DeEnrollment', 'DE_ENROLL',
                 ( select x_program_name from x_program_parameters where objid=l_program_enroll_rec.pgm_enroll2pgm_parameter)
                  || '    - Case Closed',
                 l_program_enroll_rec.x_sourcesystem,
                 l_program_enroll_rec.x_esn, l_program_enroll_rec.x_exp_date,
                 null,
                 'I', NVL(p_user,'System'),
                 l_program_enroll_rec.objid,
                 l_program_enroll_rec.pgm_enroll2web_user,
                 l_program_enroll_rec.pgm_enroll2site_part
                );
 */
-------------------------------------------------------------------------------------------------------------------
                -- Update the record to chargeback resolution.
         UPDATE x_program_enrolled
            SET x_reason = 'Chargeback Resolution'
          WHERE objid = l_program_enroll_rec.objid;

         ------------------ Insert a record into the billing log table ----------------------------------------------------
         ------------------ Log into Billing_log table ------------------------------------------------------------
         SELECT first_name, last_name
           INTO l_first_name, l_last_name
           FROM table_contact
          WHERE objid =
                     (SELECT web_user2contact
                        FROM table_web_user
                       WHERE objid = l_program_enroll_rec.pgm_enroll2web_user);

         INSERT INTO x_billing_log
                     (objid, x_log_category,
                      x_log_title,
                      x_details,
                      x_program_name,
                      x_nickname,
                      x_esn, x_originator,
                      x_contact_first_name, x_contact_last_name,
                      x_agent_name,
                      x_sourcesystem,
                      billing_log2web_user
                     )
              VALUES (billing_seq ('X_BILLING_LOG'), 'Program',
                      'Program De-enrolled',
                      'Chargeback Resolution - Case Closed',
                      (SELECT x_program_name
                         FROM x_program_parameters
                        WHERE objid =
                                 l_program_enroll_rec.pgm_enroll2pgm_parameter),
                      billing_getnickname (l_program_enroll_rec.x_esn),
                      l_program_enroll_rec.x_esn, NVL (p_user, 'System'),
                      l_first_name, l_last_name,
                      NVL (p_user, 'System'),
                      l_program_enroll_rec.x_sourcesystem,
                      l_program_enroll_rec.pgm_enroll2web_user
                     );
----------------------------------------------------------------------------------------------------------
      END LOOP;

      CLOSE program_enroll_cur;

      --- For the given merchant ref number, check if there are any more pending issues
      SELECT COUNT (*)
        INTO l_count
        FROM x_program_enrolled a,
             x_program_purch_dtl b,
             x_program_purch_hdr c
       WHERE a.x_enrollment_status IN ('SUSPENDED', 'DEENROLLED')
         AND a.x_reason != 'Chargeback Resolution'
         AND a.objid = b.pgm_purch_dtl2pgm_enrolled
         AND b.pgm_purch_dtl2prog_hdr = c.objid
         AND c.x_merchant_ref_number = p_merchant_ref_no;

      IF (l_count = 0)
      THEN
         SELECT objid, x_case_number
           INTO l_objid, l_case_number
           FROM x_cc_chargeback_trans
          WHERE x_merch_order_number =
                            (SELECT x_bill_trans_ref_no
                               FROM x_program_purch_hdr
                              WHERE x_merchant_ref_number = p_merchant_ref_no)
            AND x_processed = 'PENDINGINVESTIGATION';

         UPDATE x_cc_chargeback_trans
            SET x_processed = 'PROCESSED'
          WHERE objid = l_objid;

         /*SELECT CREATED_BY2USER into l_user_objid
            from table_part_inst where PART_SERIAL_NO=(SELECT X_ESN FROM
            X_PROGRAM_ENROLLED WHERE OBJID=p_enrolled_objid );*/

         -------------------- Since there are no more pending cases, close the case ------------------------
         BEGIN
            IF (l_case_number IS NOT NULL AND l_case_number != 0)
            THEN
               clarify_case_pkg.close_case
                                (l_case_number,       -- p_case_objid  NUMBER,
                                 p_user, --  p_user_objid              NUMBER,
                                 NULL,                 --   p_source VARCHAR2,
                                 NULL,             --   p_resolution VARCHAR2,
                                 NULL,                --- p_status   VARCHAR2,
                                 l_status,      ---  P_error_no OUT  VARCHAR2,
                                 l_message    ---  P_error_str OUT  VARCHAR2);
                                );
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;     -- Supress any exception that is raised by this call
         END;

         op_result := 1;
         op_msg := 'Success';
      ELSE
         op_result := 0;
         op_msg := 'Success';
      END IF;

      op_case_number := l_case_number;
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         op_result := -100;
         op_msg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
   END billing_close_case;

   /*
        This function is a utility function that moves the next_delivery_date to the nearest date to sysdate.
        This is to be used in situations where the chargeback suspension is removed to avoid giving benefits
        from the date chargeback is raised, till the date chargeback is resolved.
   */
   FUNCTION billing_getnearestdeliverydate (
      p_program_id      NUMBER,
      p_delivery_date   DATE
   )
      RETURN DATE
   IS
      l_new_delivery_date   DATE;
      l_delivery_frq_code   x_program_parameters.x_delivery_frq_code%TYPE;
      l_err_num             NUMBER;
      l_err_message         VARCHAR2 (255);
   BEGIN
      l_new_delivery_date := p_delivery_date;

      IF (p_delivery_date IS NOT NULL)
      THEN
         -- Get the delivery frequency code
         SELECT UPPER (x_delivery_frq_code)
           INTO l_delivery_frq_code
           FROM x_program_parameters
          WHERE objid = p_program_id;

         LOOP
            EXIT WHEN (   (l_new_delivery_date > SYSDATE)
                       OR (l_new_delivery_date = NULL)
                      );

            IF (l_delivery_frq_code = 'MONTHLY')
            THEN
               l_new_delivery_date := ADD_MONTHS (l_new_delivery_date, 1);
            ELSIF (l_delivery_frq_code = 'MON')
            THEN
               l_new_delivery_date := NEXT_DAY (l_new_delivery_date, 'MON');
            ELSIF (l_delivery_frq_code = 'TUE')
            THEN
               l_new_delivery_date := NEXT_DAY (l_new_delivery_date, 'TUE');
            ELSIF (l_delivery_frq_code = 'WED')
            THEN
               l_new_delivery_date := NEXT_DAY (l_new_delivery_date, 'WED');
            ELSIF (l_delivery_frq_code = 'THU')
            THEN
               l_new_delivery_date := NEXT_DAY (l_new_delivery_date, 'THU');
            ELSIF (l_delivery_frq_code = 'FRI')
            THEN
               l_new_delivery_date := NEXT_DAY (l_new_delivery_date, 'FRI');
            ELSIF (l_delivery_frq_code = 'SAT')
            THEN
               l_new_delivery_date := NEXT_DAY (l_new_delivery_date, 'SAT');
            ELSIF (l_delivery_frq_code = 'SUN')
            THEN
               l_new_delivery_date := NEXT_DAY (l_new_delivery_date, 'SUN');
            ELSIF (l_delivery_frq_code = 'AFTERCHARGE')
            THEN
               l_new_delivery_date := NULL;
            ELSE
               l_new_delivery_date :=
                        l_new_delivery_date + TO_NUMBER (l_delivery_frq_code);
            END IF;
         END LOOP;
      END IF;

      RETURN l_new_delivery_date;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Put in the values into the output variables.
         l_err_num := SQLCODE;
         l_err_message := SUBSTR (SQLERRM, 1, 255);
          /*
          ------------------------ Exception Logging --------------------------------------------------------------------
          ---  Incase of any Exceptions, Log the data in the Error Log table for debugging purposes.

          insert into x_program_error_log
            (
              x_source,
              x_error_code,
              x_error_msg,
              x_date,
              x_description,
              x_severity
            )
            values
            (
              'billing_getnearestdeliverydate',
              l_err_num,
              l_err_message,
              sysdate,
              ' Program ' || to_char(p_program_id) || ' Delivery Date ' || to_char(p_delivery_date,'mm/dd/yyyy'),
              3 -- LOW
             );
         ------------------------ Exception Logging --------------------------------------------------------------------
         */
         RETURN p_delivery_date;
   END;
END billing_admin_console_notify;
/