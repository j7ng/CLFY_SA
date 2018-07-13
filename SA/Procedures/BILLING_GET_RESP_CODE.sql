CREATE OR REPLACE PROCEDURE sa."BILLING_GET_RESP_CODE" (

/*************************************************************************************************/
/*                                                                                            */
/* Name         :   billing_get_resp_code                                               */
/*                                                                                            */
/* Purpose      :   Gets the Payment Response Code                                   */
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
/*************************************************************************************************/


   p_enroll_objid       IN       x_program_enrolled.objid%TYPE,
--   p_paynow_cat         IN       NUMBER, -- 2- Paynow, 0- Others  // Not used
   p_attempt_no         OUT      NUMBER,
   p_first_resp_code    OUT      VARCHAR2,
   p_second_resp_code   OUT      VARCHAR2,
   p_third_resp_code    OUT      VARCHAR2,
   p_first_resp_flag    OUT      VARCHAR2,
   p_second_resp_flag   OUT      VARCHAR2,
   p_third_resp_flag    OUT      VARCHAR2,
   op_result            OUT      NUMBER,
   op_msg               OUT      VARCHAR2
)
IS
   kk       NUMBER DEFAULT 0;
   l_date   DATE   DEFAULT TRUNC (SYSDATE);
   v_payment_type   x_program_purch_hdr.x_payment_type%TYPE;

BEGIN
   op_result := 0;
   op_msg := 'Success';
   p_attempt_no := kk;


/*
   IF p_paynow_cat = 2
   THEN
      FOR idx2 IN
          (SELECT   c.x_ics_rflag
               FROM x_program_enrolled a,
                    x_program_purch_dtl b,
                    x_program_purch_hdr c
              WHERE a.objid = b.pgm_purch_dtl2pgm_enrolled
                AND b.pgm_purch_dtl2prog_hdr = c.objid
                AND c.x_rqst_date BETWEEN b.x_cycle_start_date
                                      AND b.x_cycle_end_date
--                AND a.x_next_charge_date BETWEEN b.x_cycle_start_date  AND   b.x_cycle_end_date + 1
                AND c.x_ics_rcode != 1 -- Do not include Success (100) records
                AND a.objid = p_enroll_objid
           ORDER BY c.x_rqst_date)
      LOOP
         kk :=  kk + 1;

         IF (kk = 1)
         THEN
            p_first_resp_code := idx2.x_ics_rflag;
         ELSIF (kk = 2)
         THEN
            p_second_resp_code := idx2.x_ics_rflag;
         ELSIF (kk = 3)
         THEN
            p_third_resp_code := idx2.x_ics_rflag;
         END IF;
      END LOOP;
   ELSE
*/
      -------- For the last transaction, get the type of payment attempted ( Recurring / PayNow )
      select x_payment_type
      into   v_payment_type
      from (
              select  decode(a.x_payment_type,'REDEBIT','RECURRING',a.x_payment_type) x_payment_type
               from   x_program_purch_hdr a,
                      x_program_purch_dtl b,
                      x_program_enrolled c
              where   a.objid                      = b.pgm_purch_dtl2prog_hdr
                and   b.pgm_purch_dtl2pgm_enrolled = c.objid
                and   c.objid                      = p_enroll_objid
--                and   a.x_payment_type            != 'REDEBIT'
             order by a.objid desc
             )
      where rownum < 2;


      --------- For the selected transaction type, bring in the number of attempts.
      --------- It should suffice, if we check that the rqst_date <= cycle_start_date.
      --------- In case in the future, if we need to call the rules engine for Pre-Paynow,
      --------- this check will work.
      FOR idx2 IN
          (SELECT   c.x_ics_rcode, c.x_ics_rflag
               FROM x_program_enrolled a,
                    x_program_purch_dtl b,
                    x_program_purch_hdr c
              WHERE a.objid = b.pgm_purch_dtl2pgm_enrolled
                AND b.pgm_purch_dtl2prog_hdr = c.objid
                /*
                AND trunc(c.x_rqst_date) <= b.x_cycle_start_date
                AND c.x_rqst_date BETWEEN b.x_cycle_start_date
                                      AND NVL(b.x_cycle_end_date,c.x_rqst_date)  -- Incase of non-recurring programs, this value will be null
                                                                                 -- Assume that the cycle end date is the charge date.
--                AND a.x_next_charge_date BETWEEN b.x_cycle_start_date   AND   b.x_cycle_end_date + 1
                */
                AND ( c.x_ics_rcode != '100' AND c.x_ics_rcode !='1' ) -- Do not include Success (1-RealTime, 100Batch) records
   --             AND ( c.x_payment_type != 'REDEBIT' )
                AND a.objid = p_enroll_objid
                AND decode(c.x_payment_type,'REDEBIT','RECURRING',c.x_payment_type) = v_payment_type
                AND c.x_rqst_date >= NVL(a.x_charge_date,c.x_rqst_date)
				AND PGM_PURCH_DTL2PENAL_PEND IS NULL
           ORDER BY c.objid)
      LOOP
         kk :=   kk + 1;

         IF (kk = 1)
         THEN
            p_first_resp_code := idx2.x_ics_rcode;
            p_first_resp_flag := idx2.x_ics_rflag;
         ELSIF (kk = 2)
         THEN
            p_second_resp_code := idx2.x_ics_rcode;
            p_second_resp_flag := idx2.x_ics_rflag;
         ELSIF (kk = 3)
         THEN
            p_third_resp_code := idx2.x_ics_rcode;
            p_third_resp_flag := idx2.x_ics_rflag;
         END IF;
      END LOOP;

--   END IF;

  p_attempt_no := kk;    --- There is a possibility that kk can hold value greater than 3.
  p_first_resp_code  := NVL(p_first_resp_code,0);
  p_second_resp_code := NVL(p_second_resp_code, 0);
  p_third_resp_code  := NVL(p_third_resp_code, 0);


EXCEPTION
   WHEN OTHERS
   THEN
      op_result := -100;
      op_msg :=    SQLCODE
                || SUBSTR (SQLERRM, 1, 100);
END billing_get_resp_code;
/