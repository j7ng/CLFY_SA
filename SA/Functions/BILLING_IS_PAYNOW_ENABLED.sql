CREATE OR REPLACE FUNCTION sa."BILLING_IS_PAYNOW_ENABLED" (
/*************************************************************************************************/
/*                                                                                            */
/* Name         :   BILLING_IS_PAYNOW_ENABLED                                        */
/*                                                                                            */
/* Purpose      :   Validates for pay now eligibility                                */
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
/*                                                                                            */
/*                                                                                            */
/*  CR29079   25-sept-2014      vkashmire
    WARRANTY programs are eligible for PAYNOW option in SUSPENDED status only
    So, return 0 if warranty program and status is enrolled                                    */
/*************************************************************************************************/
                                       p_enrolled_objid IN NUMBER)
   RETURN NUMBER
IS
   v_cycle_day_count         DATE;
   v_is_recurring            NUMBER;
   v_program_enroll_status   x_program_enrolled.x_enrollment_status%TYPE;
   v_program_param_objid     x_program_parameters.objid%TYPE;
   v_next_cycle_date         x_program_enrolled.x_next_charge_date%TYPE;
   v_wait_exp_date           x_program_enrolled.x_wait_exp_date%TYPE;
   v_payment_status          VARCHAR2 (30);
   v_bill_trans_ref_no       x_program_purch_hdr.x_bill_trans_ref_no%TYPE;
   v_amount                  x_program_enrolled.x_amount%TYPE;
   v_ics_rcode               x_program_purch_hdr.x_ics_rcode%TYPE;
   v_count                   NUMBER;
   p_return_message          VARCHAR2 (300);
   p_return_code             NUMBER (10);
   lv_prog_class             x_program_parameters.x_prog_class%type;
BEGIN
   /* Return Values
       0 : Cannot do a PayNow
       1 : Can do a PayNow. This is advance cycle payment.
       2 : Can do a PayNow. Status is Suspended.
       3 : Cannot do a PayNow - Chargeback is pending.
       4 : Can do a PayNow - However do not deliver benefits
    -100 : Database Error.
   */
   -- Get the enrollment status and the program id
   SELECT pgm_enroll2pgm_parameter, x_enrollment_status, x_next_charge_date,
          x_wait_exp_date, x_amount
     INTO v_program_param_objid, v_program_enroll_status, v_next_cycle_date,
          v_wait_exp_date, v_amount
     FROM x_program_enrolled
    WHERE objid = p_enrolled_objid;

   IF (v_amount <= 0)
   THEN
      RETURN 0;
   END IF;

   -- Get the cycle code
   SELECT DECODE (x_charge_frq_code,
                  'MONTHLY', ADD_MONTHS (SYSDATE, 1),               -- Monthly
                  --'LOWBALANCE', NULL,
                  'PASTDUE', NULL,
                    SYSDATE
                  + TO_NUMBER (DECODE (x_charge_frq_code,
                                       'null', 0,
                                       x_charge_frq_code
                                      )
                              )
                 ),                                            -- every x days
          x_is_recurring,
          x_prog_class
     INTO v_cycle_day_count,
          v_is_recurring,
          lv_prog_class
     FROM x_program_parameters
    WHERE objid = v_program_param_objid;

   IF (v_is_recurring = 0)
   THEN
      RETURN 0;                                  --- Not a recurring program.
   END IF;

   -- Charge frequency can be a postive number - indicating every 'x' days, or
   -- a mnemonic specifying 'MONTHLY','LOWBALANCE','PASTDUE'
   /*
   if ( v_cycle_day_count is null ) then
       --dbms_output.put_line ('Program does not permit paynow (DeAct Protection/Low Balance)');
       return 0;
   end if;
   */ -- Allow Paynow for DeActivation and LowBalance programs

   -- Check if the ESN is in Wait Period. Bug 309
   IF (v_wait_exp_date IS NOT NULL AND v_wait_exp_date > TRUNC (SYSDATE))
   THEN
      -- System is in Wait State. Do not allow PayNow.
      RETURN 0;
   END IF;

   --- Check if any of the additional phones are in wait period.
   SELECT COUNT (*)
     INTO v_count
     FROM x_program_enrolled
    WHERE pgm_enroll2pgm_group = p_enrolled_objid
      AND x_wait_exp_date > TRUNC (SYSDATE);

   IF (v_count > 0)
   THEN                    -- At least one additional phone is in wait period.
      RETURN 0;
   END IF;

   --

   --dbms_output.put_line ( 'Cycle days : ' || to_char(v_cycle_day_count) || 'Ideal next payment date' );
   --dbms_output.put_line ( sysdate + v_cycle_day_count );
   IF (   v_program_enroll_status = 'SUSPENDED'
       OR v_program_enroll_status = 'ENROLLED'
      )
   THEN
      /* CR29079 changes starts  */
      --for warranty program, paynow is available only in SUSPENDED status
      if lv_prog_class = 'WARRANTY' and v_program_enroll_status = 'ENROLLED' then
        return 0;
      end if;
      /* CR29079 changes ends */

      -- dbms_output.put_line ('PayNow can be enabled, since the status of the program is in suspended mode');
      -- There is a possibility that the customer has made an ACH Payment and that is waiting to be cleared.
      -- In such case disable paynow.

      /* Logic:
              Get the unique payment headers for the given enrollment from x_program_purch_dtl.
              Pick all the orders order by date. We need to get the status of the last order placed.
              Check its status. If the status is 'PAYNOWACHPENDING', dont allow paynow.
      */
      SELECT NVL (z.x_status, ' '), z.x_bill_trans_ref_no, x_ics_rcode
        INTO v_payment_status, v_bill_trans_ref_no, v_ics_rcode
        FROM (SELECT   x.objid, x.x_rqst_date, x.x_status,
                       x.x_bill_trans_ref_no, x.x_ics_rcode
                  FROM x_program_purch_hdr x,
                       (
                        --- Gives the distinct purchases for a given enrollment.
                        SELECT DISTINCT (a.pgm_purch_dtl2prog_hdr) proghdr
                                   FROM x_program_purch_dtl a,
                                        x_program_enrolled b
                                  WHERE a.pgm_purch_dtl2pgm_enrolled = b.objid
                                    AND b.objid = p_enrolled_objid) b
                 WHERE x.objid = b.proghdr
              ORDER BY x.x_rqst_date DESC) z
       WHERE ROWNUM < 2;

      DBMS_OUTPUT.put_line (v_payment_status || ' - '
                            || v_program_enroll_status
                           );

      IF (   v_payment_status = 'RECURINCOMPLETE'
          OR v_payment_status = 'INCOMPLETE'
          OR v_payment_status = 'RECURACHPENDING'
          OR v_payment_status = 'PAYNOWACHPENDING'
          OR v_payment_status = 'SUBMITTED'
         )
      THEN
         RETURN 0;
      END IF;

      IF (v_program_enroll_status = 'ENROLLED')
      THEN
         -- Check if there are any additional phones that are in ENROLLMENTSCHEDULED.
         -- Do not allow PayNow in these situations
         SELECT COUNT (*)
           INTO v_count
           FROM x_program_enrolled
          WHERE pgm_enroll2pgm_group = p_enrolled_objid
            AND x_enrollment_status IN
                                 ('ENROLLMENTSCHEDULED', 'ENROLLMENTPENDING');

         IF (v_count > 0)
         THEN
            RETURN 0;
                 -- Cannot do a paynow. Additional phone in Scheduled status.
         END IF;
      ELSE
         --------- Check if there is a CC or ACH Chargeback Pending Investigation ----------------------------
         SELECT COUNT (*)
           INTO v_count
           FROM (SELECT objid
                   FROM x_cc_chargeback_trans
                  WHERE x_merch_order_number = v_bill_trans_ref_no
                    AND x_processed = 'PENDINGINVESTIGATION'
                 UNION
                 SELECT objid
                   FROM x_ach_chargeback_trans
                  WHERE x_merch_order_number = v_bill_trans_ref_no
                    AND x_processed = 'PENDINGINVESTIGATION');

         IF (v_count = 0)
         THEN
            ---------------- No chargeback pending investigations. Check if this is an ACH Reject (failed payment)
            SELECT COUNT (*)
              INTO v_count
              FROM x_billing_code_table
             WHERE x_code_type = 'CB_ECP_RCODES' AND x_code = v_ics_rcode;

            IF (v_count > 0)
            THEN
               RETURN 4;
            END IF;

------------------------------------------------------------------------------------------------------
            RETURN 2;
         ELSE
            RETURN 3;
         END IF;
      END IF;
   --return 2;       -- PayNow Enabled. Status in suspended state. /* BUG: Show flow ahead, do not return from here */
   END IF;

   IF (v_program_enroll_status != 'ENROLLED')
   THEN
      RETURN 0;
              -- Future payment is only available for ESNs in Enrolled status
   END IF;

---------------------------------------------------------------------------------------------------
-- Defect 412 fix.
   IF (v_cycle_day_count IS NULL)
   THEN
      --dbms_output.put_line ('Program does not permit advance paynow (DeAct Protection/Low Balance)');
      RETURN 0;
   END IF;

---------------------------------------------------------------------------------------------------
   IF (v_cycle_day_count < v_next_cycle_date)
   THEN
      --dbms_output.put_line('PayNow cannot be done since the advance payment is already received');
      RETURN 0;                               -- Advance PayNow already done.
   ELSE
      --dbms_output.put_line('PayNow can be done for the next cycle');
      IF (v_is_recurring = 0)
      THEN
         RETURN 0;
      -- Program is not a recurring program. Advance payments cannot be made.
      END IF;

      IF (v_next_cycle_date < SYSDATE)
      THEN
-- In case of special situations where recurring jobs has not picked up the record.
         RETURN 2;
      END IF;

      RETURN 1;                          -- PayNow enabled for the next cycle.
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      /*
      p_return_code := SQLCODE;
      p_return_message := SQLERRM;

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
            'BILLING_IS_PAYNOW_ENABLED',
            p_return_code,
            to_char(p_return_message),
            sysdate,
            to_char(p_enrolled_objid) ,
            3 -- HIGH
      );
      ------------------------ Exception Logging --------------------------------------------------------------------
      commit;
      */
      DBMS_OUTPUT.put_line (SQLERRM);
      RETURN -100;
END BILLING_IS_PAYNOW_ENABLED;
/