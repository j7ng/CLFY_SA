CREATE OR REPLACE PROCEDURE sa."BILLING_DELIVERSERVICEDAYS" (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   BILLING_DELIVERSERVICEDAYS                                             */
/*                                                                                            */
/* Purpose      :   Delivers the service days.                                       */
/*                                                                                            */
/*                                                                                            */
/* Platforms    :   Oracle 9i                                                                 */
/*                                                                                            */
/* Author       :   RSI                                                                       */
/*                                                                                            */
/* Date         :   01-19-2006                                                    */
/* REVISIONS:                                                                              */
/* VERSION  DATE        WHO          PURPOSE                                                  */
/* -------  ----------  -----        --------------------------------------------             */
/*  1.0                              Initial  Revision                                        */
/*  1.1     05/21/2009 CR8663        Changes for Straight Talk project                     */
/*                                                                                            */
/*************************************************************************************************/
   p_enroll_objid     IN       x_program_enrolled.objid%TYPE,
   p_return_code      OUT      NUMBER,
   p_return_message   OUT      VARCHAR2
)
IS
   CURSOR v_enrollment_c (c_enroll_objid NUMBER)
   IS
      SELECT a.objid, a.x_esn, b.x_type, a.x_delivery_cycle_number,
             a.x_enrollment_status, a.x_is_grp_primary, a.x_next_charge_date,
             a.x_next_delivery_date, a.x_service_days,
             a.pgm_enroll2pgm_parameter, b.x_program_name,
             b.x_incl_service_days, b.x_delivery_frq_code,
             b.x_promo_incl_min_at, b.x_promo_incr_min_at, a.x_wait_exp_date,
             b.x_promo_incl_grpmin_at, b.x_promo_incr_grpmin_at,
             b.x_incr_minutes_dlv_cyl, b.x_incr_minutes_dlv_days,
             b.x_incr_grp_minutes_dlv_cyl, b.x_incr_grp_minutes_dlv_days,
             b.x_stack_dur_enroll, (SELECT MAX(SP.OBJID)
						 FROM sa.TABLE_SITE_PART SP
						 WHERE 1=1
						 and SP.X_SERVICE_ID = a.x_esn
						 AND SP.PART_STATUS||''= 'Active') as pgm_enroll2site_part,
             a.pgm_enroll2x_promotion, b.prog_param2bus_org,
             a.pgm_enroll2web_user, b.x_prog_class, -- STRAIGHT TALK .. CR8663
             bo.org_id -- CR23513 TFSurepay
        FROM x_program_enrolled a, x_program_parameters b, table_bus_org bo
       where a.pgm_enroll2pgm_parameter = b.objid
             AND b.prog_param2bus_org = bo.objid
             AND a.objid = c_enroll_objid;

   v_enrollment_rec         v_enrollment_c%ROWTYPE;

   -- Cursor for retrieving the ESN status from the site part table.
   CURSOR esn_status_c (c_esn x_program_enrolled.x_esn%TYPE)
   IS
      --
      -- Start CR13082 Kacosta 01/21/2011
      --SELECT x_expire_dt
      --  FROM table_site_part
      -- WHERE x_service_id IN (c_esn) AND part_status = 'Active';
      SELECT tsp.x_expire_dt
        FROM table_part_inst tpi
            ,table_site_part tsp
       WHERE tsp.x_service_id IN (c_esn)
         AND tsp.part_status = 'Active'
         AND tsp.objid = tpi.x_part_inst2site_part
         AND tpi.x_part_inst_status = '52'
         AND tpi.x_domain = 'PHONES';
      -- End CR13082 Kacosta 01/21/2011
      --
     CURSOR c_prog_purch_priority (c_objid x_program_purch_hdr.objid%TYPE)          --CR25625
     IS
     SELECT purch.x_priority
       FROM x_program_purch_hdr purch
      WHERE purch.objid = c_objid;
       rec_prog_purch_priority  c_prog_purch_priority%ROWTYPE;


   v_esn_status_rec         esn_status_c%ROWTYPE;
   l_enroll_type            VARCHAR2 (30);
                                -- Whether the promotion is onetime/recurring
   l_enroll_amount          NUMBER                   DEFAULT 0;
                                                     -- Dollar Discount given
   l_enroll_units           NUMBER                   DEFAULT 0;
                                                               -- Units given
   l_enroll_days            NUMBER                   DEFAULT 0; -- Days given
   l_error_code             NUMBER;                             -- Error Code
   l_error_message          VARCHAR2 (255);                  -- Error Message
   l_service_days_given     NUMBER;
   l_service_exp_date       DATE;
   l_enrollment_benefits    NUMBER;
   l_program_service_days   NUMBER;
   l_prog_purch_objid       NUMBER;
   l_surepay_andriod        BOOLEAN := FALSE; -- CR23513 TFSurepay
   l_priority               x_program_purch_dtl.x_priority%TYPE;  -- CR25625
-- Added for CR7265 .. Ramu
BEGIN
   p_return_code := 0;
   p_return_message := 'Success';

   ----------- Get the enrollment record ------------------------------------------------------
   OPEN v_enrollment_c (p_enroll_objid);

   FETCH v_enrollment_c
    INTO v_enrollment_rec;

   IF v_enrollment_c%NOTFOUND
   THEN
   ------FOR CR33218
      p_return_code := 6550;
      p_return_message :=
                'Unable to retrive the enrollment record for the given input';
                INSERT INTO x_program_error_log
                  (x_source, x_error_code,
                   x_error_msg, x_date,
                   x_description,
                   x_severity
                  )
           VALUES ('BILLING_DELIVERSERVICEDAYS', p_return_code,
                   p_return_message, SYSDATE,
                      'ESN '
                   || (SELECT x_esn
                         FROM x_program_enrolled
                        WHERE objid = p_enroll_objid)
                   || ' Enrollment ID '
                   || TO_CHAR (p_enroll_objid),
                   1                                                   -- HIGH
                  );

      RETURN;
   END IF;

   CLOSE v_enrollment_c;

   --- Check for statuses
   IF (v_enrollment_rec.x_enrollment_status != 'ENROLLED')
   THEN
      p_return_code := 6551;
      p_return_message :=
         'Cannot deliver benefits since the ESN is not enrolled into the program';
         ------FOR CR33218
         INSERT INTO x_program_error_log
                  (x_source, x_error_code,
                   x_error_msg, x_date,
                   x_description,
                   x_severity
                  )
           VALUES ('BILLING_DELIVERSERVICEDAYS', p_return_code,
                   p_return_message, SYSDATE,
                      'ESN '
                   || (SELECT x_esn
                         FROM x_program_enrolled
                        WHERE objid = p_enroll_objid)
                   || ' Enrollment ID '
                   || TO_CHAR (p_enroll_objid),
                   1                                                   -- HIGH
                  );

      RETURN;
   END IF;

   IF (v_enrollment_rec.x_wait_exp_date IS NOT NULL)
   THEN
      p_return_code := 6552;
      p_return_message :=
                    'Cannot deliver benefits since the ESN is in wait period';
                    ------FOR CR33218
                    INSERT INTO x_program_error_log
                  (x_source, x_error_code,
                   x_error_msg, x_date,
                   x_description,
                   x_severity
                  )
           VALUES ('BILLING_DELIVERSERVICEDAYS', p_return_code,
                   p_return_message, SYSDATE,
                      'ESN '
                   || (SELECT x_esn
                         FROM x_program_enrolled
                        WHERE objid = p_enroll_objid)
                   || ' Enrollment ID '
                   || TO_CHAR (p_enroll_objid),
                   1                                                   -- HIGH
                  );

      RETURN;
   END IF;

   ---------- Get the ESN Status --------------------------------------------------------------
   OPEN esn_status_c (v_enrollment_rec.x_esn);

   FETCH esn_status_c
    INTO v_esn_status_rec;

   IF esn_status_c%NOTFOUND
   THEN
      p_return_code := 6553;
      p_return_message :=
             'ESN ' || v_enrollment_rec.x_esn || ' is not active / not found';
             ------FOR CR33218
             INSERT INTO x_program_error_log
                  (x_source, x_error_code,
                   x_error_msg, x_date,
                   x_description,
                   x_severity
                  )
           VALUES ('BILLING_DELIVERSERVICEDAYS', p_return_code,
                   p_return_message, SYSDATE,
                      'ESN '
                   || (SELECT x_esn
                         FROM x_program_enrolled
                        WHERE objid = p_enroll_objid)
                   || ' Enrollment ID '
                   || TO_CHAR (p_enroll_objid),
                   1                                                   -- HIGH
                  );

      RETURN;
   END IF;

   CLOSE esn_status_c;

---------------------------------------------------------------------------------------------
-- Get the Service days for the program.
   DBMS_OUTPUT.put_line ('Service Days processing ');
   billing_validateredeemcode (v_enrollment_rec.x_incl_service_days,
                               l_enroll_type,
                               l_enroll_amount,
                               l_enroll_units,
                               l_enroll_days,
                               l_error_code,
                               l_error_message
                              );

   IF (l_error_code = 0)
   THEN
-- Success
      l_service_days_given := l_enroll_days;
                       -- Ignoring the service days provided by the promocode
      l_program_service_days := l_enroll_days;
                                      -- For stacking rules, store the values
      DBMS_OUTPUT.put_line (   'Got promocode included service days '
                            || TO_CHAR (v_enrollment_rec.x_incl_service_days)
                            || ' with '
                            || l_service_days_given
                            || ' service days '
                           );
   ELSE
      p_return_code := 6556;
      p_return_message :=
                 l_error_message || '. PromoCode for Service Days is invalid';
                 ------FOR CR33218
                 INSERT INTO x_program_error_log
                  (x_source, x_error_code,
                   x_error_msg, x_date,
                   x_description,
                   x_severity
                  )
           VALUES ('BILLING_DELIVERSERVICEDAYS', p_return_code,
                   p_return_message, SYSDATE,
                      'ESN '
                   || (SELECT x_esn
                         FROM x_program_enrolled
                        WHERE objid = p_enroll_objid)
                   || ' Enrollment ID '
                   || TO_CHAR (p_enroll_objid),
                   1                                                   -- HIGH
                  );

      RETURN;
   END IF;

------------------------------------------------------------------------------------------------
-- Added for CR7265 .. Ramu
   SELECT MAX (purch.objid)
     INTO l_prog_purch_objid
     FROM x_program_purch_hdr purch,
          x_program_enrolled enroll,
          x_program_purch_dtl dtl
    WHERE 1 = 1
      AND purch.x_ics_rcode IN ('1', '100')
      AND purch.objid = dtl.pgm_purch_dtl2prog_hdr
      AND enroll.objid = p_enroll_objid
      AND dtl.pgm_purch_dtl2pgm_enrolled = enroll.objid;

-- End of CR7265 Changes .. Ramu
---------------------------------------------------------------------------------------------------
------------------------ PromoCode Processing -----------------------------------------------------
-- Check the enrollment promocode. If it gives dollar discount, ignore days/units.
   IF (v_enrollment_rec.pgm_enroll2x_promotion IS NOT NULL)
   THEN
      billing_validateenrollid (v_enrollment_rec.x_esn,
                                v_enrollment_rec.pgm_enroll2x_promotion,
                                v_enrollment_rec.prog_param2bus_org,
                                l_enroll_type,
                                l_enroll_amount,
                                l_enroll_units,
                                l_enroll_days,
                                l_error_code,
                                l_error_message
                               );

      IF (l_error_code <> 0)
      THEN
-- Promocode validation failes.
         DBMS_OUTPUT.put_line ('Promocode invalid ');
      --  RETURN;
      -- Modified for SEP project.. Ramu
      -- Do not Return if promo is Invalid
      END IF;

      ---- Check if it gives a dollar discount. Incase a dollar discount is given, ignore servicedays/minutes parameters
      IF (l_enroll_amount = 0)
      THEN
-- Does not have any money discount
         IF (l_enroll_type = 'RECURRING')
         THEN
            -- Delivery benefits for minutes/service days
            l_service_days_given := l_service_days_given + l_enroll_days;
            l_enrollment_benefits := 1;
         ELSE
            -- Benefits need not be given
            l_enrollment_benefits := 0;
         END IF;
      ELSE
         -- Dollar discount given, ignore benefits given by this promocode.
         DBMS_OUTPUT.put_line
            ('This promo code gives dollar discount. Minutes / Service benefits not eligible '
            );
      END IF;
-----------------------------------------------------------------------------------------------------------------
   END IF;

   -- If any previous floats given for the program, deduct it from the total service days to be given
   l_service_days_given :=
               l_service_days_given - NVL (v_enrollment_rec.x_service_days, 0);

------------------------------------------------------------------------------------------
-- Sample data contains service_end_date as NULL. Temporarily, if service_end_date is NULL , set the service end date to sysdate.
   IF (v_enrollment_rec.x_stack_dur_enroll = 'FULL')
   THEN
      l_service_exp_date :=
            NVL (v_esn_status_rec.x_expire_dt, SYSDATE)
            + l_service_days_given;
   ELSIF (v_enrollment_rec.x_stack_dur_enroll = 'GAP')
   THEN
      IF (  SYSDATE
          + l_service_days_given
          + NVL (v_enrollment_rec.x_service_days, 0) >
                                   NVL (v_esn_status_rec.x_expire_dt, SYSDATE)
         )
      THEN
         l_service_exp_date :=
              SYSDATE
            + l_service_days_given
            + NVL (v_enrollment_rec.x_service_days, 0);
      ELSE
         l_service_exp_date := v_esn_status_rec.x_expire_dt;
      END IF;
   ELSE
      --l_service_exp_date :=   SYSDATE + l_service_days_given;   -- No Stacking
      l_service_exp_date := v_esn_status_rec.x_expire_dt;
-- No Stacking
   END IF;

   -------- Ensure that the service days exist at least upto the next cycle date -------------------------
   IF (l_service_exp_date < NVL (v_enrollment_rec.x_next_charge_date, SYSDATE)
      )
   THEN
      l_service_exp_date := v_enrollment_rec.x_next_charge_date;
   END IF;

-------------------------------------------------------------------------------------------------------
-- Debug
   DBMS_OUTPUT.put_line (   'New computed expiry for '
                         || v_enrollment_rec.x_stack_dur_enroll
                         || ' Stacking is '
                         || l_service_exp_date
                        );

   DBMS_OUTPUT.put_line ('For Andriod NOT PPE phones, the updating of above computed date will be skipped.');

   -- Error handling
   IF (l_service_exp_date IS NULL)
   THEN
      DBMS_OUTPUT.put_line
           ('6510 : Error Computing Service End Date. Please check the data ');
      RETURN;
   END IF;

   -- Apply the max. service days rule
   /*
     Logic implementation as per discussion with Daniel:
        If program gives 365 days,           give service days upto a max of 730 days.
        if program gives less than 365 days, give service days upto a max of 120 days.
   */
   -- AS PER NEW STACKING POLICY THIS CHECK SHOULD BE TURNED OFF ..
   -- CR6799 -- RAMU
   /*
   if ( l_program_service_days >= 365 ) then
       l_service_exp_date := GREATEST ( v_esn_status_rec.X_EXPIRE_DT,
                                        LEAST (l_service_exp_date, SYSDATE + 730)
                                       );    -- From the existing procedures.
   else
       l_service_exp_date := GREATEST ( v_esn_status_rec.X_EXPIRE_DT,
                               LEAST (l_service_exp_date, SYSDATE+120)
                               );    -- From the existing procedures.
   end if;
   */
   -- Service ID
   /* ---------------------- Update the site part table --------------------------------- */
   --
   -- Start CR13082 Kacosta 01/21/2011
   --UPDATE table_site_part
   --   SET x_expire_dt = l_service_exp_date
   -- WHERE x_service_id IN (v_enrollment_rec.x_esn) AND part_status = 'Active';

   -- CR23513 TFSurepay
   -- After discussion with Ramu and Ugender
   -- it was decided that this needs to be skipped for TFSurepay
   IF v_enrollment_rec.org_id = 'TRACFONE' THEN
       l_surepay_andriod := (sa.device_util_pkg.get_smartphone_fun(v_enrollment_rec.x_esn) = 0);
   END IF;

   IF (NOT l_surepay_andriod) THEN
      --
      UPDATE table_site_part tsp
        SET tsp.x_expire_dt = l_service_exp_date
      WHERE tsp.x_service_id IN (v_enrollment_rec.x_esn)
        AND tsp.part_status = 'Active'
        AND EXISTS (SELECT 1
                      FROM table_part_inst tpi
                     WHERE tpi.x_part_inst2site_part = tsp.objid
                       AND tpi.x_part_inst_status = '52'
                       AND tpi.x_domain = 'PHONES');
      -- End CR13082 Kacosta 01/21/2011
      --

      UPDATE table_part_inst
        SET warr_end_date = l_service_exp_date
      WHERE part_serial_no IN (v_enrollment_rec.x_esn)
            AND part_status = 'Active';

      DBMS_OUTPUT.PUT_LINE ('Updated Site Part / Part Inst');
      --
   END IF;
/* ------------------------------------------------------------------------------------ */
-- If the customer has used a valid promocode, then put the promocode into the pending redemption table.
   IF (l_enrollment_benefits = 1)
   THEN
      DBMS_OUTPUT.put_line ('Service Days promocode Benefits ');

      INSERT INTO table_x_pending_redemption
                  (objid,
                   pend_red2x_promotion,
                   x_pend_red2site_part, x_pend_type,
                   pend_redemption2esn, x_case_id,
                   x_granted_from2x_call_trans, pend_red2prog_purch_hdr
                  )                                -- Added for CR7265 .. Ramu
           VALUES (seq ('x_pending_redemption'),
                   v_enrollment_rec.pgm_enroll2x_promotion,
                   v_enrollment_rec.pgm_enroll2site_part, 'BPDelivery',
                   NULL, NULL,
                   NULL, l_prog_purch_objid
                  );                               -- Added for CR7265 .. Ramu

      INSERT INTO table_x_promo_hist
                  (objid,
                   promo_hist2x_promotion
                  )
           VALUES (seq ('x_promo_hist'),
                   v_enrollment_rec.pgm_enroll2x_promotion
                  );
   END IF;

   DBMS_OUTPUT.put_line ('Updating Pending Redemption ');

   IF (   v_enrollment_rec.x_prog_class IS NULL
       OR v_enrollment_rec.x_prog_class <> 'SWITCHBASE'
      )
   THEN
-- STRAIGHT TALK .. CR8663
        INSERT INTO table_x_pending_redemption
                    (objid,
                     pend_red2x_promotion,
                     x_pend_red2site_part, x_pend_type,
                     pend_redemption2esn, x_case_id,
                     x_granted_from2x_call_trans, pend_red2prog_purch_hdr
                    )                                -- Added for CR7265 .. Ramu
             VALUES (seq ('x_pending_redemption'),
                     v_enrollment_rec.x_incl_service_days,
                     v_enrollment_rec.pgm_enroll2site_part, 'BPDelivery',
                     NULL, NULL,
                     NULL, l_prog_purch_objid
                    );                               -- Added for CR7265 .. Ramu

        INSERT INTO table_x_promo_hist
                    (objid, promo_hist2x_promotion
                    )
             VALUES (seq ('x_promo_hist'), v_enrollment_rec.x_incl_service_days
                    );
   END IF;                                          -- STRAIGHT TALK .. CR8663

   IF (billing_isotaenabled (v_enrollment_rec.x_esn) = 1)
   THEN
    OPEN c_prog_purch_priority(l_prog_purch_objid);
    FETCH c_prog_purch_priority INTO rec_prog_purch_priority;
    CLOSE c_prog_purch_priority;

      INSERT INTO x_program_gencode
                  (objid,
                   x_esn, x_insert_date, x_status,
                   gencode2prog_purch_hdr,
                   x_priority       --CR25625
                  )                             -- Modified for CR7265 .. Ramu
           VALUES (billing_seq ('x_program_gencode'),
                   v_enrollment_rec.x_esn, SYSDATE, 'INSERTED',
                   l_prog_purch_objid,
                   rec_prog_purch_priority.x_priority   --CR25625
                  );
-- Modified for CR7265 .. Ramu
   ELSE
      DBMS_OUTPUT.put_line (   'Phone/Carrier is not OTA Enabled for : '
                            || v_enrollment_rec.x_esn
                           );
   END IF;

   ----------------- Insert Records into x_program_trans -------------------------------------------------
   DBMS_OUTPUT.put_line ('Before program trans');

   INSERT INTO x_program_trans
               (objid,
                x_enrollment_status,
                x_enroll_status_reason,
                x_float_given, x_cooling_given, x_trans_date,
                x_action_text, x_action_type,
                x_reason,
                x_sourcesystem, x_esn, x_exp_date, x_cooling_exp_date,
                x_update_status, x_update_user, pgm_tran2pgm_entrolled,
                pgm_trans2web_user,
                pgm_trans2site_part
               )
        VALUES (billing_seq ('X_PROGRAM_TRANS'),
                v_enrollment_rec.x_enrollment_status,
                   'Service Days Delivery - New Expiry '
                || TO_CHAR (l_service_exp_date, 'mm/dd/yyyy'),
                v_enrollment_rec.x_service_days, NULL, SYSDATE,
                'Benefits Delivery', 'BENEFITS',
                   /* BUG: 902
                             v_enrollment_rec.x_program_name || '    ' || to_char(NVL(l_service_days_given,0)) || ' days ',
                             */
                   v_enrollment_rec.x_program_name
                || '    '
                || TO_CHAR (  NVL (l_service_days_given, 0)
                            + NVL (v_enrollment_rec.x_service_days, 0)
                           )
                || ' days ',

                /*
                          'Service Days=>'
                          || l_service_exp_date
                          || ' PromoUsed => '
                          || l_enroll_days
                          || ':'
                          || l_enroll_type,
                          */
                'SYSTEM', v_enrollment_rec.x_esn, NULL, NULL,
                'I', 'System', v_enrollment_rec.objid,
                v_enrollment_rec.pgm_enroll2web_user,
                v_enrollment_rec.pgm_enroll2site_part
               );

   UPDATE x_program_enrolled
      SET x_service_days = NULL
    WHERE objid = v_enrollment_rec.objid;

--------------------------------------------------------------------------------------------------------
   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      p_return_code := -100;
      p_return_message := SQLERRM;

------------------------ Exception Logging --------------------------------------------------------------------
---  Incase of any Exceptions, Log the data in the Error Log table for debugging purposes.
      INSERT INTO x_program_error_log
                  (x_source, x_error_code,
                   x_error_msg, x_date,
                   x_description,
                   x_severity
                  )
           VALUES ('BILLING_DELIVERSERVICEDAYS', p_return_code,
                   p_return_message, SYSDATE,
                      'ESN '
                   || (SELECT x_esn
                         FROM x_program_enrolled
                        WHERE objid = p_enroll_objid)
                   || ' Enrollment ID '
                   || TO_CHAR (p_enroll_objid),
                   1                                                   -- HIGH
                  );

------------------------ Exception Logging --------------------------------------------------------------------
--      ROLLBACK;
      RETURN;
END;                                   -- Procedure BILLING_DELIVERSERVICEDAYS
/