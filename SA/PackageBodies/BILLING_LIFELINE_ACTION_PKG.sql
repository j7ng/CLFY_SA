CREATE OR REPLACE PACKAGE BODY sa."BILLING_LIFELINE_ACTION_PKG" IS
--------------------------------------------------------------------------------------------
--$RCSfile: BILLING_LIFELINE_ACTION_PKG.sql,v $
--$Revision: 1.8 $
--$Author: arijal $
--$Date: 2015/08/25 15:55:50 $
--$ $Log: BILLING_LIFELINE_ACTION_PKG.sql,v $
--$ Revision 1.8  2015/08/25 15:55:50  arijal
--$ CR37553 SAFELINK DEENROLL FLAX FIXES
--$
--$ Revision 1.7  2014/06/24 21:38:23  jarza
--$ CR29111 Changes - Flash and interaction records are inserted irrespective of ESN's enrollment status.
--$
--$ Revision 1.6  2014/04/21 21:04:56  ymillan
--$ CR27714
--$
--$ Revision 1.5  2014/04/03 12:58:51  ymillan
--$ CR27714
--$
--$ Revision 1.3  2012/11/02 19:08:01  mmunoz
--$ CR22380: Updated in order to have the same signature in the SP_TAXES's functions
--$
--------------------------------------------------------------------------------------------

-------------------- Function Validate_Action --------------------
   FUNCTION validate_action (p_action_type IN VARCHAR2)
      RETURN NUMBER
   IS
      l_count   NUMBER := 0;
   BEGIN
      IF p_action_type IS NULL
      THEN
         DBMS_OUTPUT.put_line ('Action type is NULL. Fix it ...');
         RETURN l_count;                             -- Action type not found
      END IF;

      -- Just see if any records on x_program_enrolled
      SELECT COUNT (1)
        INTO l_count
        FROM x_billing_code_table code
       WHERE 1 = 1
         AND code.x_code_type = 'LIFELINE'
         AND code.x_update_status = 'I'
         AND code.x_code = p_action_type;

      RETURN l_count;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;                                           -- Returns FALSE
   END validate_action;

-------------------- Function Validate_Action ends -----------------

   -------------------- Procedure pending action starts -----------------
   PROCEDURE process_pending_actions (
      op_result   OUT   VARCHAR2,                             -- Output Result
      op_msg      OUT   VARCHAR2                             -- Output Message
   )
   IS
      -- Variable Declarations
      l_valid_action      NUMBER                       := 0;
      l_site_part_objid   table_site_part.objid%TYPE;

-----------------------------------------------------------------------------------------------
-- Cursor Declarations
-- Cursor # 1
-- Fetch all Pending Lifeline Actions
      CURSOR lifeline_pending_action
      IS
         SELECT *
           FROM x_lifeline_action_trans
          WHERE 1 = 1
            AND x_action_date < TRUNC (SYSDATE + 1)
            -- Since this job runs every day
            AND x_action_status = 'PENDING'       -- Take only Pending records
            AND x_esn IS NOT NULL;

-----------------------------------------------------------------------------------------------
-- Cursor # 2
-- Fetch the Program parameters (This may not be needed)
      CURSOR pgm_param_cur (param_objid NUMBER)
      IS
         SELECT *
           FROM x_program_parameters param
          WHERE 1 = 1
            AND param.objid = param_objid
            AND x_end_date >= TRUNC (SYSDATE);

      pgm_param_rec       pgm_param_cur%ROWTYPE;

-----------------------------------------------------------------------------------------------
-- Cursor # 3
-- Fetch the Enrollment Record
      CURSOR pgm_enroll_cur (p_enrolled_objid NUMBER)
      IS
         SELECT *
           FROM x_program_enrolled enroll  -- Not sure if we need all 3 tables
          WHERE 1 = 1 AND enroll.objid = p_enrolled_objid;

      pgm_enroll_rec      pgm_enroll_cur%ROWTYPE;
-----------------------------------------------------------------------------------------------
-- End of Cursors
   BEGIN
      FOR rec1 IN lifeline_pending_action
      LOOP
         -- 1. Check the Action Type
         -- If it is an INVALID or DELETED Action, return
         l_valid_action := validate_action (rec1.x_action_type);

         IF (l_valid_action > 0)
         THEN
            -- 1a. Write Case statement..
            -- If Action is Enrollment, call Enrollment Procedure with ReEnroll flag as 0
            -- If Action is Re-Enrollment, Call Enrollment Procedure with ReEnroll flag as 1
            -- If Action is De-Enrollment, call De-Enrollment Procedure
            -- If Action is De-Activation, call service deactivation procedure.deactivateany()
            -- If Action is Transfer Plan, call Upgrade procedure
            -- If Action is BrightPoint Return, call Returns Procedure
            CASE rec1.x_action_type
               WHEN 'ENROLLMENT'
               THEN
                  process_lifeline_enrollment (rec1.objid,
                                               0,
                                               op_result,
                                               op_msg
                                              );
               WHEN 'DE_ENROLL'
               THEN
                  process_lifeline_deenrollment (rec1.objid,
                                                 op_result,
                                                 op_msg
                                                );
               WHEN 'RE_ENROLL'
               THEN
                  process_lifeline_enrollment (rec1.objid,
                                               1,
                                               op_result,
                                               op_msg
                                              );
               WHEN 'DE_REGISTER'
               THEN
                  process_lifeline_deregister (rec1.objid, op_result, op_msg);
               WHEN 'REMOVE_ESN'
               THEN
                  process_lifeline_remove_esn (rec1.objid, op_result, op_msg);
               WHEN 'UPGRADE'
               THEN
                  process_lifeline_upgrade (rec1.objid, op_result, op_msg);
               WHEN 'DEACTIVATE'
               THEN
                  process_lifeline_deactivation (rec1.objid,
                                                 op_result,
                                                 op_msg
                                                );
               WHEN 'BRIGHTPOINT_RETURN'
               THEN
                  process_lifeline_returns (rec1.objid, op_result, op_msg);
               ELSE
                  UPDATE x_lifeline_action_trans
                     SET x_action_status = 'FAILED',
                         x_reason = 'No Action process defined'
                   WHERE objid = rec1.objid;
            END CASE;

            -- Update the record with the result values from the procedures
            UPDATE x_lifeline_action_trans
               SET x_action_status = op_result,
                   x_reason = op_msg
             WHERE objid = rec1.objid;

            -- 1b. Update the record status as COMPLETED on lifeline action trans table.
            -- Insert on x_billing_log (if needed) for the Manual Action completed
            INSERT INTO x_billing_log
                        (objid, x_log_category,
                         x_log_title, x_log_date,
                         x_details,
                         x_nickname, x_esn,
                         x_originator, x_contact_first_name,
                         x_contact_last_name, x_agent_name, x_sourcesystem,
                         billing_log2web_user
                        )
                 VALUES (billing_seq ('X_BILLING_LOG'), 'MyAccount',
                         'Manual Lifeline Action', SYSDATE,
                            'Lifeline Action - '
                         || rec1.x_action_type
                         || ' is executed',
                         billing_getnickname (rec1.x_esn), rec1.x_esn,
                         'System', 'N/A',
                         'N/A', 'System', 'System',
                         rec1.x_action2web_user
                        );
         ELSE
            -- 2. UPDATE lifeline action trans table as FAILED with reason Invalid action type
            UPDATE x_lifeline_action_trans
               SET x_action_status = 'FAILED',
                   x_reason = 'Invalid Action type'
             WHERE objid = rec1.objid;

            COMMIT;
         END IF;
      END LOOP;

      op_result := 0;
      op_msg := 'Success';
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Error ' || TO_CHAR (SQLCODE) || ': '
                               || SQLERRM
                              );
         op_result := SQLCODE;
         op_msg := SQLERRM;
   END process_pending_actions;

   -------------------- Procedure pending action ends -------------------------

   ------------------------ Lifeline Enrollment starts ------------------------
   PROCEDURE process_lifeline_enrollment (
      lifeline_action_objid   IN       NUMBER,
      re_enroll_flag          IN       NUMBER,
      op_result               OUT      VARCHAR2,              -- Output Result
      op_msg                  OUT      VARCHAR2              -- Output Message
   )
   IS
      v_date                DATE          DEFAULT SYSDATE;
      l_enroll_seq          NUMBER;
      l_purch_hdr_seq       NUMBER;
      l_enroll_fee          NUMBER;
      l_esn                 VARCHAR2 (40);
      l_program_name        VARCHAR2 (50);
      l_program_objid       NUMBER;
      l_web_user_objid      NUMBER;
      l_tax                 NUMBER;
      l_e911_tax            NUMBER;
      l_sales_tax_percent   NUMBER;
      l_e911_tax_percent    NUMBER;
      l_enroll_objid        NUMBER;
      l_usf_tax             NUMBER;  --CR11553
      l_usf_tax_percent     NUMBER; --CR11553
      l_rcrf_tax            NUMBER;  --CR11553
      l_rcrf_tax_percent    NUMBER;  --CR11553
   BEGIN
      SELECT x_esn, x_action2pgm_parameter, x_action2web_user,
             x_action2pgm_enroll
        INTO l_esn, l_program_objid, l_web_user_objid,
             l_enroll_objid
        FROM x_lifeline_action_trans
       WHERE 1 = 1 AND objid = lifeline_action_objid;

-----------------------------------------------------------------------------------------------
      l_enroll_seq := billing_seq ('X_PROGRAM_ENROLLED');
      -- Get the Enrollment NEXT VAL for Objid
      l_purch_hdr_seq := billing_seq ('X_PROGRAM_PURCH_HDR');
      -- Get the Purch hdr NEXT VAL for Objid
      l_tax := 0;
      l_e911_tax := 0;
      l_usf_tax := 0; --CR11553
      l_rcrf_tax := 0; --CR11553

      SELECT param.x_program_name,
             (price1.x_retail_price + price2.x_retail_price
             ) enroll_fee
        INTO l_program_name,
             l_enroll_fee
        FROM x_program_parameters param,
             table_x_pricing price1,
             table_x_pricing price2
       WHERE 1 = 1
         AND param.objid = l_program_objid
         AND param.prog_param2prtnum_monfee = price1.x_pricing2part_num
         AND param.prog_param2prtnum_enrlfee = price2.x_pricing2part_num;

      ------- Get the sales tax percent for the given enrollment record
      ------- Charge the sales tax only if tax to customer flag is set in the program definition.
      l_sales_tax_percent :=
             sa.sp_taxes.computetax(l_web_user_objid, l_program_objid, l_esn); --CR11553
      l_e911_tax_percent :=
             sa.sp_taxes.computee911tax(l_web_user_objid, l_program_objid /*,l_esn CR22380 removing ESN */ ); --CR11553
      l_usf_tax_percent :=
             sa.sp_taxes.computeusftax(l_web_user_objid, l_program_objid /*,l_esn CR22380 removing ESN */ ); --CR11553
      l_rcrf_tax_percent :=
             sa.sp_taxes.computemisctax(l_web_user_objid, l_program_objid /*,l_esn CR22380 removing ESN*/ ); --CR11553
      sa.sp_taxes.GetTax_BILL(l_enroll_fee,l_sales_tax_percent,l_e911_tax_percent,l_tax,l_e911_tax );  --CR115533
      sa.sp_taxes.GetTax2_BILL(l_enroll_fee,l_usf_tax_percent,l_rcrf_tax_percent,l_usf_tax,l_rcrf_tax); --CR115533

      -- Insert a record in x_program_enrolled
      IF (re_enroll_flag <> 1)
      THEN
         INSERT INTO x_program_enrolled
                     (objid, x_esn, x_amount, x_type,
                      x_sourcesystem, x_insert_date, x_charge_date,
                      x_enrolled_date, x_start_date,
                      x_reason, x_delivery_cycle_number, x_enroll_amount,
                      x_language, x_enrollment_status, x_is_grp_primary,
                      x_next_delivery_date,
                      x_update_stamp, x_update_user,
                      pgm_enroll2pgm_parameter,
                      pgm_enroll2site_part,
                      pgm_enroll2part_inst,
                      pgm_enroll2contact,
                      pgm_enroll2web_user, x_termscond_accepted
                     )
              VALUES (l_enroll_seq, l_esn, l_enroll_fee, 'INDIVIDUAL',
                      'VMBC', SYSDATE, SYSDATE,
                      SYSDATE, SYSDATE,
                      'Safe Link Wireless Manual Enrollment', 1, 0,
                      'English', 'ENROLLED', 1,
                      (LAST_DAY (ADD_MONTHS (TRUNC (SYSDATE), 0)) + 1
                      ),
                      SYSDATE, 'operations',
                      l_program_objid,
                      (SELECT objid
                         FROM table_site_part
                        WHERE x_service_id = l_esn
                          AND part_status || '' = 'Active'),
                      (SELECT objid
                         FROM table_part_inst
                        WHERE part_serial_no = l_esn
                              AND part_status = 'Active'),
                      (SELECT x_contact_part_inst2contact
                         FROM table_x_contact_part_inst
                        WHERE x_contact_part_inst2part_inst =
                                 (SELECT objid
                                    FROM table_part_inst
                                   WHERE part_serial_no = l_esn
                                     AND part_status = 'Active')),
                      l_web_user_objid, 1
                     );
      ELSE
         UPDATE x_program_enrolled
            SET x_enrollment_status = 'ENROLLED',
                x_enrolled_date = SYSDATE,
                x_reason = 'Safe Link Wireless Manual Reenrollment',
                x_next_delivery_date =
                              (LAST_DAY (ADD_MONTHS (TRUNC (SYSDATE), 0)) + 1
                              ),
                x_update_stamp = SYSDATE,
                x_update_user = 'operations',
                pgm_enroll2pgm_parameter = l_program_objid,
                pgm_enroll2site_part =
                   (SELECT objid
                      FROM table_site_part
                     WHERE x_service_id = l_esn
                       AND part_status || '' = 'Active'),
                pgm_enroll2part_inst =
                    (SELECT objid
                       FROM table_part_inst
                      WHERE part_serial_no = l_esn AND part_status = 'Active'),
                pgm_enroll2contact =
                   (SELECT x_contact_part_inst2contact
                      FROM table_x_contact_part_inst
                     WHERE x_contact_part_inst2part_inst =
                              (SELECT objid
                                 FROM table_part_inst
                                WHERE part_serial_no = l_esn
                                  AND part_status = 'Active')),
                pgm_enroll2web_user = l_web_user_objid
          WHERE objid = l_enroll_objid;

         l_enroll_seq := l_enroll_objid;
      END IF;

      -- Insert a record in x_program_purch_hdr
      INSERT INTO x_program_purch_hdr
                  (objid, x_rqst_source, x_rqst_type, x_rqst_date,
                   x_ics_applications, x_merchant_id, x_merchant_ref_number,
                   x_offer_num, x_quantity, x_merchant_product_sku,
                   x_payment_line2program, x_product_code, x_ignore_avs,
                   x_user_po, x_avs, x_disable_avs, x_customer_hostname,
                   x_customer_ipaddress, x_auth_request_id, x_auth_code,
                   x_auth_type, x_ics_rcode, x_ics_rflag, x_ics_rmsg,
                   x_request_id, x_auth_avs, x_auth_response, x_auth_time,
                   x_auth_rcode, x_auth_rflag, x_auth_rmsg,
                   x_bill_request_time, x_bill_rcode, x_bill_rflag,
                   x_bill_rmsg, x_bill_trans_ref_no, x_customer_firstname,
                   x_customer_lastname, x_customer_phone, x_customer_email,
                   x_status, x_bill_address1, x_bill_address2, x_bill_city,
                   x_bill_state, x_bill_zip, x_bill_country, x_amount,
                   x_tax_amount, x_e911_tax_amount, x_usf_taxamount, x_rcrf_tax_amount, --add usf and rcrf CR11553
                   x_auth_amount, x_bill_amount, x_user, x_credit_code,
                   purch_hdr2creditcard, purch_hdr2bank_acct, purch_hdr2user,
                   purch_hdr2esn, purch_hdr2rmsg_codes, purch_hdr2cr_purch,
                   prog_hdr2x_pymt_src, prog_hdr2web_user,
                   prog_hdr2prog_batch, x_payment_type
                  )
           VALUES (l_purch_hdr_seq, 'VMBC', 'LIFELINE_PURCH', SYSDATE,
                   NULL, NULL, sa.merchant_ref_number,
                   NULL, NULL, NULL,
                   NULL, NULL, 'Yes',
                   NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL,
                   NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL, NULL,
                   NULL, NULL, NULL,
                   NULL, NULL, NULL,
                   NULL, NULL, NULL,
                   NULL, NULL, 'null@cybersource.com',
                   'LIFELINEPROCESSED', NULL, NULL, NULL,
                   NULL, NULL, 'USA', l_enroll_fee,
                   l_tax, l_e911_tax, l_usf_tax, l_rcrf_tax, --add usf and rcrf CR11553
                   NULL,NULL, 'System', NULL,
                   NULL, NULL, NULL,
                   NULL, NULL, NULL,
                   NULL, l_web_user_objid,
                   NULL, 'LL_ENROLL'
                  );

      -- Insert a record in x_program_purch_dtl
      INSERT INTO x_program_purch_dtl
                  (objid, x_esn, x_amount,
                   x_tax_amount, x_e911_tax_amount,  x_usf_taxamount, x_rcrf_tax_amount, --add usf and rcrf CR11553
                   x_charge_desc,
                   x_cycle_start_date, x_cycle_end_date,
                   pgm_purch_dtl2pgm_enrolled, pgm_purch_dtl2prog_hdr
                  )
           VALUES (billing_seq ('X_PROGRAM_PURCH_DTL'), l_esn, l_enroll_fee,
                   l_tax, l_e911_tax, l_usf_tax, l_rcrf_tax, --add usf and rcrf CR11553
                   'Charges for Safe Link Wireless Customers',
                   TRUNC (SYSDATE), TRUNC (SYSDATE) + 30,
                   l_enroll_seq, l_purch_hdr_seq
                  );

      -- Insert a record in x_program_trans
      INSERT INTO x_program_trans
                  (objid, x_enrollment_status,
                   x_enroll_status_reason, x_trans_date,
                   x_action_text,
                   x_action_type,
                   x_reason, x_sourcesystem, x_esn,
                   x_update_user, pgm_tran2pgm_entrolled, pgm_trans2web_user,
                   pgm_trans2site_part
                  )
           VALUES (billing_seq ('x_program_trans'), 'ENROLLED',
                   'First Time Enrollment', SYSDATE,
                   (CASE re_enroll_flag
                       WHEN 1
                          THEN 'Trying to Re Enroll'
                       ELSE 'Enrollment Attempt'
                    END
                   ),
                   (CASE re_enroll_flag
                       WHEN 1
                          THEN 'RE_ENROLL'
                       ELSE 'ENROLLMENT'
                    END
                   ),
                   'Safe Link Wireless Customer Enrollment', 'System', l_esn,
                   'operations', l_enroll_seq, (SELECT pgm_enroll2web_user
                                                  FROM x_program_enrolled
                                                 WHERE objid = l_enroll_seq),
                   (SELECT objid
                      FROM table_site_part
                     WHERE x_service_id = l_esn
                       AND part_status || '' = 'Active')
                  );

      -- Insert a record in x_program_gencode

      -- Insert a record in table_x_pending_redemption
      COMMIT;
      op_result := 'PROCESSED';
      op_msg := 'Enrolled Successfully';
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Error ' || TO_CHAR (SQLCODE) || ': '
                               || SQLERRM
                              );
         op_result := 'FAILED';
         op_msg := SQLERRM;
   --  END;
   END process_lifeline_enrollment;

   ------------------------ Lifeline Enrollment ends ------------------------

   ------------------------ Lifeline DeEnrollment starts --------------------
   PROCEDURE process_lifeline_deenrollment (
      lifeline_action_objid   IN       NUMBER,
      op_result               OUT      VARCHAR2,              -- Output Result
      op_msg                  OUT      VARCHAR2              -- Output Message
   )
   IS
      v_date             DATE          DEFAULT SYSDATE;
      l_enroll_objid     NUMBER;
      l_enroll_counter   NUMBER;
      l_esn              VARCHAR2 (40);


   ---CR27714
   counter         NUMBER          := 0;
   str_title       VARCHAR2 (80);
   str_webcsr      VARCHAR2 (4000);
   str_webeng      VARCHAR2 (1000);
   str_webspa      VARCHAR2 (1000);
   str_ivr         VARCHAR2 (10);
   v_interact_id   NUMBER;
   v_x_chardate    VARCHAR2 (30);
   v_objid         NUMBER;
   v_message       VARCHAR (4000);

   cursor c1 (c_esn varchar2) is
   SELECT objid, x_part_inst2contact, part_serial_no
   FROM table_part_inst
   where part_serial_no =c_esn;

   ---CR27714
   CURSOR l_action_trans_curs   IS
   SELECT x_esn, x_action2pgm_enroll, x_deenroll_reason , X_FLASH_TEXT , X_INTERACT_TEXT, X_INTERACT_TITLE
   FROM x_lifeline_action_trans
   WHERE 1 = 1 AND objid = lifeline_action_objid;

    l_action_trans_rec   l_action_trans_curs%rowtype;

   ---  CR27714
   --   SELECT x_esn, x_action2pgm_enroll
   --     INTO l_esn, l_enroll_objid
   --     FROM x_lifeline_action_trans
   --    WHERE 1 = 1 AND objid = lifeline_action_objid;

BEGIN
  --DBMS_OUTPUT.PUT_LINE('Entered into process_lifeline_deenrollment');
  --CR27714
  OPEN l_action_trans_curs;
  FETCH l_action_trans_curs INTO l_action_trans_rec;
   IF l_action_trans_curs%NOTFOUND THEN
        close l_action_trans_curs;
            op_result := 'FAILED';
            op_msg   := 'Not exist lifeline_action_objid into table x_lifeline_action_transs. Fix Manually';
			--DBMS_OUTPUT.PUT_LINE('op_result:'||op_result);
			--DBMS_OUTPUT.PUT_LINE('op_msg:'||op_msg);
          return;  --Procedure stops here
   ELSE
       close l_action_trans_curs;
-----------------------------------------------------------------------------------------------
      SELECT COUNT (*)
        INTO l_enroll_counter
        FROM x_program_enrolled
       WHERE objid = l_action_trans_rec.x_action2pgm_enroll
         AND x_enrollment_status = 'ENROLLED';

-----------------------------------------------------------------------------------------------
      IF (l_enroll_counter <> 0)
      THEN
		--DBMS_OUTPUT.PUT_LINE('Deenrolling');
         UPDATE x_program_enrolled
            SET x_enrollment_status = 'READYTOREENROLL',
                x_next_delivery_date = NULL
          WHERE objid = l_action_trans_rec.x_action2pgm_enroll
            AND x_esn = l_action_trans_rec.x_esn
            AND x_enrollment_status = 'ENROLLED';

         INSERT INTO x_program_trans
                     (objid, x_enrollment_status,
                      x_enroll_status_reason, x_trans_date,
                      x_action_text, x_action_type,
                      x_reason,
                      x_sourcesystem, x_esn, x_update_user,
                      pgm_tran2pgm_entrolled, pgm_trans2web_user,
                      pgm_trans2site_part
                     )
              VALUES (billing_seq ('x_program_trans'), 'ENROLLED',
                      'DeEnrollment Scheduled', SYSDATE,
                      'Voluntary DeEnrollment', 'DE_ENROLL',
                      'Safe Link Wireless Customer Voluntary DeEnrollment',
                      'System', l_action_trans_rec.x_esn, 'operations',
                      l_action_trans_rec.x_action2pgm_enroll, (SELECT pgm_enroll2web_user
                                         FROM x_program_enrolled
                                        WHERE objid = l_action_trans_rec.x_action2pgm_enroll),
                      (SELECT objid
                         FROM table_site_part
                        WHERE x_service_id = l_action_trans_rec.x_esn
                          AND part_status || '' = 'Active')
                     );
	  END IF; --CR29111
		--CR29111 -- Business wants flash and interactions to be inserted irrespective of its enrolled or not.
          ---CR27714
			IF l_action_trans_rec.x_deenroll_reason IS NOT NULL THEN
				--DBMS_OUTPUT.PUT_LINE('l_action_trans_rec.x_deenroll_reason:'||l_action_trans_rec.x_deenroll_reason);
                update x_sl_currentvals
                   set x_deenroll_reason = l_action_trans_rec.x_deenroll_reason
               where x_current_esn = l_action_trans_rec.x_esn;
			END IF;
         ---CR27714
         ---FLASH INSERT statement

         FOR r1 in c1(l_action_trans_rec.x_esn) LOOP
         str_title := 'SafeLink Enrollment Cancelled';
         str_webcsr := l_action_trans_rec.X_FLASH_TEXT;
         str_webeng := NULL;
         str_webspa := NULL;
         str_ivr:= 9991;  --CR9991

		IF l_action_trans_rec.X_FLASH_TEXT IS NOT NULL THEN
			--DBMS_OUTPUT.PUT_LINE('FLASH INSERT ');
			--DBMS_OUTPUT.PUT_LINE('str_webcsr:'||str_webcsr);
           DELETE FROM sa.table_alert
                WHERE 1 = 1
                 AND title = 'SafeLink Enrollment Cancelled'
                 AND alert2contract = r1.objid;

           INSERT INTO sa.table_alert
                  (objid, alert_text, x_web_text_english, x_web_text_spanish,
                   start_date, end_date, active, title, x_ivr_script_id,
                   last_update2user, alert2contract, hot, TYPE,
                   x_cancel_sql,
                   alert2contact
                  )
           VALUES (sa.seq ('alert'), str_webcsr, str_webeng, str_webspa,
                   SYSDATE, SYSDATE + 730, 1, str_title, str_ivr,
                   268435556, r1.objid, 0, 'SQL',
                   'select count(*) from sa.x_program_enrolled where X_ESN = :esn and x_enrolled_date between :start_date and :end_date and x_enrollment_status =''ENROLLED''',
                   r1.x_part_inst2contact
                  );
		END IF;
       ---CR27714
       ---FLASH INTERACTION INSERT statement

      v_objid := sa.seq ('interact');
    --  v_x_chardate := TO_CHAR(r1.x_date);
      v_message := l_action_trans_rec.X_INTERACT_TEXT;

		IF l_action_trans_rec.X_INTERACT_TEXT IS NOT NULL THEN
		--DBMS_OUTPUT.PUT_LINE('FLASH INTERACTION INSERT ');
		--DBMS_OUTPUT.PUT_LINE('l_action_trans_rec.X_INTERACT_TEXT:'||l_action_trans_rec.X_INTERACT_TEXT);
         INSERT INTO sa.table_interact
                  (objid, interact_id, create_date, inserted_by,
                   direction, TYPE, s_type, origin, product, s_product,
                   reason_1, s_reason_1,
                   reason_2,
                   s_reason_2, RESULT, done_in_one,
                   fee_based, wait_time, system_time, entered_time,
                   pay_option, start_date, end_date, arch_ind, AGENT,
                   s_agent, interact2user, interact2contact, x_service_type
                  )
           VALUES (v_objid, sa.sequ_interaction_id.NEXTVAL, SYSDATE, 'sa',
                   'Inbound', 'Call', 'CALL', 'None', 'None', 'NONE',
                   l_action_trans_rec.X_INTERACT_TITLE,UPPER(l_action_trans_rec.X_INTERACT_TITLE),
				   --'SafeLink Non-Usage', 'SAFELINK NON-USAGE',
                   'Program Enrollment Cancelled',
                   'PROGRAM ENROLLMENT CANCELLED', 'SafeLink Cancelled', 0,
                   0, 0, 4, 0,
                   'None', SYSDATE, SYSDATE, 0, 'sa',
                   'SA', 268435556, r1.x_part_inst2contact, 'Wireless'
                  );

         INSERT INTO sa.table_interact_txt
                  (objid, notes, interact_txt2interact
                  )
          VALUES (sa.seq('interact_txt'), v_message, v_objid
                  );
		END IF;

      End loop; --end of part inst loop
         op_result := 'PROCESSED';
         op_msg := 'Successful';
	/*     --29111 Commenting
	 ELSE
         op_result := 'FAILED';
         op_msg := 'This is not in ENROLLED status. Fix Manually';

      END IF;
	  */
      COMMIT;
  END IF;
  --DBMS_OUTPUT.PUT_LINE('End of process_lifeline_deenrollment');
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Error ' || TO_CHAR (SQLCODE) || ': '
                               || SQLERRM
                              );
         op_result := SQLCODE;
         op_msg := SQLERRM;
   END process_lifeline_deenrollment;

------------------------ Lifeline DeEnrollment ends ------------------------

   ------------------------ Lifeline De Register starts ----------------------
   PROCEDURE process_lifeline_deregister (
      lifeline_action_objid   IN       NUMBER,
      op_result               OUT      VARCHAR2,              -- Output Result
      op_msg                  OUT      VARCHAR2              -- Output Message
   )
   IS
      l_esn           VARCHAR2 (40);
      l_web_user_id   NUMBER;
      l_error_num     NUMBER;
   BEGIN
      SELECT x_esn, x_action2web_user
        INTO l_esn, l_web_user_id
        FROM x_lifeline_action_trans
       WHERE 1 = 1 AND objid = lifeline_action_objid;

-----------------------------------------------------------------------------------------------
      billing_de_register (l_web_user_id, l_error_num, op_msg);
      op_result := 'SUCCESS';
      op_msg := 'My Account de-registered successfully';
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Error ' || TO_CHAR (SQLCODE) || ': '
                               || SQLERRM
                              );
         op_result := 'FAILED';
         op_msg := SQLERRM;
   END process_lifeline_deregister;

------------------------ Lifeline De Register ends ----------------------

   ------------------------ Lifeline Remove ESN starts ----------------------
   PROCEDURE process_lifeline_remove_esn (
      lifeline_action_objid   IN       NUMBER,
      op_result               OUT      VARCHAR2,              -- Output Result
      op_msg                  OUT      VARCHAR2              -- Output Message
   )
   IS
      l_esn           VARCHAR2 (40);
      l_web_user_id   NUMBER;
      l_error_num     NUMBER;
   BEGIN
      SELECT x_esn, x_action2web_user
        INTO l_esn, l_web_user_id
        FROM x_lifeline_action_trans
       WHERE 1 = 1 AND objid = lifeline_action_objid;

-----------------------------------------------------------------------------------------------
      DELETE FROM table_x_contact_part_inst
            WHERE 1 = 1
              AND x_contact_part_inst2part_inst IN (
                          SELECT objid
                            FROM table_part_inst
                           WHERE part_serial_no = l_esn
                                 AND x_domain = 'PHONES')
              AND x_contact_part_inst2contact IN (SELECT web_user2contact
                                                    FROM table_web_user
                                                   WHERE objid = l_web_user_id);

      COMMIT;
      op_result := 'SUCCESS';
      op_msg := 'Removed ESN Successfully';
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Error ' || TO_CHAR (SQLCODE) || ': '
                               || SQLERRM
                              );
         op_result := 'FAILED';
         op_msg := SQLERRM;
   END process_lifeline_remove_esn;

------------------------ Lifeline Remove ESN ends ----------------------

   ------------------------ Lifeline Upgrade starts -----------------------
   PROCEDURE process_lifeline_upgrade (
      lifeline_action_objid   IN       NUMBER,
      op_result               OUT      VARCHAR2,              -- Output Result
      op_msg                  OUT      VARCHAR2              -- Output Message
   )
   IS
      v_date   DATE DEFAULT SYSDATE;
   BEGIN
      DBMS_OUTPUT.put_line ('Inside PROCESS_LIFELINE_UPGRADE ');
      op_result := 'SUCCESS';
      op_msg := 'Success';
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Error ' || TO_CHAR (SQLCODE) || ': '
                               || SQLERRM
                              );
         op_result := 'FAILED';
         op_msg := SQLERRM;
   END process_lifeline_upgrade;

------------------------ Lifeline Upgrade ends -----------------------

   ------------------------ Lifeline Deactivation starts -----------------
   PROCEDURE process_lifeline_deactivation (
      lifeline_action_objid   IN       NUMBER,
      op_result               OUT      VARCHAR2,              -- Output Result
      op_msg                  OUT      VARCHAR2              -- Output Message
   )
   IS
      l_esn           VARCHAR2 (40);
      l_web_user_id   NUMBER;
      l_error_num     NUMBER;
   BEGIN
      SELECT x_esn, x_action2web_user
        INTO l_esn, l_web_user_id
        FROM x_lifeline_action_trans
       WHERE 1 = 1 AND objid = lifeline_action_objid;

-----------------------------------------------------------------------------------------------
     -- Just call the deactivation procedures
      sa.service_deactivation_code.deactivate_any (l_esn,
                                                   'CUSTOMER REQD',
                                                   NULL,
                                                   op_result
                                                  );

      IF (op_result = 0)
      THEN
         --- There was an error processing deactivation.
         op_result := 'FAILED';
         op_msg := 'Unable to deactivate esn due to technical problems.';
      ELSE
         op_result := 'SUCCESS';
         op_msg := 'Deactivated Successfully';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Error ' || TO_CHAR (SQLCODE) || ': '
                               || SQLERRM
                              );
         op_result := 'FAILED';
         op_msg := SQLERRM;
   END process_lifeline_deactivation;

------------------------ Lifeline Deactivation ends -----------------

   ------------------------ Lifeline returns starts --------------------
   PROCEDURE process_lifeline_returns (
      lifeline_action_objid   IN       NUMBER,
      op_result               OUT      VARCHAR2,              -- Output Result
      op_msg                  OUT      VARCHAR2              -- Output Message
   )
   IS
      l_esn           VARCHAR2 (40);
      l_web_user_id   NUMBER;
      l_error_num     NUMBER;
   BEGIN
      SELECT x_esn, x_action2web_user
        INTO l_esn, l_web_user_id
        FROM x_lifeline_action_trans
       WHERE 1 = 1 AND objid = lifeline_action_objid;

-----------------------------------------------------------------------------------------------
     -- Just call the deactivation procedures
      sa.service_deactivation_code.deactivate_any (l_esn,
                                                   'NO NEED OF PHONE',
                                                   NULL,
                                                   op_result
                                                  );

      IF (op_result = 0)
      THEN
         --- There was an error processing deactivation.
         op_result := 'FAILED';
         op_msg := 'Unable to deactivate esn due to technical problems.';
      ELSE
         op_result := 'SUCCESS';
         op_msg := 'Deactivated Successfully';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('Error ' || TO_CHAR (SQLCODE) || ': '
                               || SQLERRM
                              );
         op_result := 'FAILED';
         op_msg := SQLERRM;
   END process_lifeline_returns;
------------------------ Lifeline returns ends --------------------
END billing_lifeline_action_pkg;   -- Package Body BILLING_LIFELINE_ACTION_PKG
/