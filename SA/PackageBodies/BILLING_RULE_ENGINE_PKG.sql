CREATE OR REPLACE PACKAGE BODY sa."BILLING_RULE_ENGINE_PKG"
IS
/********************************************************************************/
   /*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved
   /*
   /********************************************************************************/

   /********************************************************************************/
   /*
   /* NAME:         billing_rule_engine_pkg (BODY)
   /* PURPOSE:      This package evaluate rules conditions
   /*				on the Billing Platform
   /* FREQUENCY:
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.
   /*
   /* REVISIONS:
   /* VERSION  DATE        WHO     PURPOSE
   /* -------  ---------- ----- ---------------------------------------------
   /*  1.0                      Initial  Revision
   /*  1.1    5/23/08 rvurimi  Fixes for CR7136
/********************************************************************************/
/********************************************************************************/
/*
/* Name:    attempt_resp_code
/* Description : Available in the specification part of package
/********************************************************************************/
   PROCEDURE attempt_resp_code (
      p_cond_objid         IN       NUMBER,
      p_mrchnt_rf_id       IN       VARCHAR2,
      p_esn                IN       VARCHAR2,
      p_attempt_no         IN       NUMBER,
      p_first_resp_code    IN       x_program_purch_hdr.x_ics_rcode%TYPE,
      p_second_resp_code   IN       x_program_purch_hdr.x_ics_rcode%TYPE,
      p_third_resp_code    IN       x_program_purch_hdr.x_ics_rcode%TYPE,
      p_first_resp_flag    IN       x_program_purch_hdr.x_ics_rflag%TYPE,
      p_second_resp_flag   IN       x_program_purch_hdr.x_ics_rflag%TYPE,
      p_third_resp_flag    IN       x_program_purch_hdr.x_ics_rflag%TYPE,
      o_result             OUT      NUMBER,
      o_err_num            OUT      VARCHAR2,
      o_err_msg            OUT      VARCHAR2
   )
   IS

--    resp_code   x_program_purch_hdr.x_ics_rcode%TYPE;
      resp_code   x_rule_cond_trans.X_RULE_EVAL_1%TYPE;


       /* Bring all the records for the given cond_trans objid.
          Check with the condition values for First Attempt, Second Attempt, Third Attempt
       */

      CURSOR c1_cur
      IS
            select a.*, b.SET_TRANS2RULE_CAT_MAS
            from   x_rule_cond_trans a, x_rule_create_trans b
            where  a.COND_TRANS2CREATE_TRANS = b.objid
              and  a.objid = p_cond_objid
            ORDER BY a.x_rule_cond_1;

      c1_rec      c1_cur%ROWTYPE;

   BEGIN


     /* Logic:
            Bring all the records in order from the given rule.
            if the cond is first attempt, compare with the first attempt code,
                        is second attempt, compare with the second attempt code,
                        is third attempt, compare with the third attempt code.
     */

     OPEN      c1_cur;
     LOOP
         FETCH     c1_cur  into c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;
         ---------------- Check for First Attempt values ---------------------------------------------
         --IF ( instr(c1_rec.x_rule_cond_1,'First') > 0 and c1_rec.SET_TRANS2RULE_CAT_MAS = 1 ) THEN        -- First Attempt for Recurring
		 IF ( instr(c1_rec.x_rule_cond_1,'First') > 0 and instr(c1_rec.x_rule_cond_1,'Recurring' ) > 0  ) THEN       -- First Attempt for Recurring
            IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
            THEN
               IF to_char( p_first_resp_code ) = c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
            THEN
               IF to_char( p_first_resp_code ) != c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            END IF;
         --ELSIF ( instr(c1_rec.x_rule_cond_1,'First') > 0  and c1_rec.SET_TRANS2RULE_CAT_MAS = 2 ) THEN        -- First Attempt for PayNow
		   ELSIF ( instr(c1_rec.x_rule_cond_1,'First') > 0  and instr(c1_rec.x_rule_cond_1,'Recurring' ) = 0 ) THEN       -- First Attempt for PayNow
            IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
            THEN
               IF to_char(p_first_resp_flag) = c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
            THEN
               IF to_char(p_first_resp_flag) != c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            END IF;
         ---------------- Check for Second Attempt values ---------------------------------------------
         ELSIF ( instr(c1_rec.x_rule_cond_1,'Second') > 0  and instr(c1_rec.x_rule_cond_1,'Recurring' ) > 0 ) THEN     -- Second Attempt for Recurring Payment
            IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
            THEN
               IF to_char( p_second_resp_code ) = c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
            THEN
               IF to_char( p_second_resp_code ) != c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            END IF;
         ELSIF ( instr(c1_rec.x_rule_cond_1,'Second') > 0  and instr(c1_rec.x_rule_cond_1,'Recurring' ) = 0 ) THEN     -- Second Attempt for PayNow
            IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
            THEN
               IF p_second_resp_flag  = c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
            THEN
               IF  p_second_resp_flag != c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            END IF;

         ---------------- Check for Third Attempt values ---------------------------------------------
         ELSIF ( instr(c1_rec.x_rule_cond_1,'Third') > 0  and instr(c1_rec.x_rule_cond_1,'Recurring' ) > 0 ) THEN     -- THIRD ATTEMPT for Recurring
            IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
            THEN
               IF to_char( p_third_resp_code ) = c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
            THEN
               IF to_char( p_third_resp_code ) != c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            END IF;
         ELSIF ( instr(c1_rec.x_rule_cond_1,'Third') > 0  and instr(c1_rec.x_rule_cond_1,'Recurring' ) = 0 ) THEN     -- THIRD ATTEMPT for PayNow
            IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
            THEN
               IF to_char(p_third_resp_flag) = c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
            THEN
               IF to_char(p_third_resp_flag) != c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            END IF;

        ELSE
         ---------------- Invalid Condition. Should not be here. ---------------------------------------------

            dbms_output.put_line( ' Error Condition : ' || c1_rec.x_rule_cond_1);
            o_result := 0; --Flag an error and exit out of the loop.
        END IF;


        IF ( o_result = 0 ) THEN
            EXIT;
        END IF;
     END LOOP;

     CLOSE      c1_cur;

/*
      IF p_attempt_no = 1
      THEN
         resp_code := to_char (p_first_resp_code);
         OPEN c1_cur;

         LOOP
            FETCH c1_cur INTO c1_rec;
            EXIT WHEN c1_cur%NOTFOUND;

            IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
            THEN
               IF resp_code = c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
            THEN
               IF resp_code != c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            END IF;
         END LOOP;

         CLOSE c1_cur;
      -- if attempt code is second value
      ELSIF p_attempt_no = 2
      THEN
         resp_code := to_char (p_first_resp_code);
         OPEN c1_cur;

         LOOP
            FETCH c1_cur INTO c1_rec;
            EXIT WHEN c1_cur%NOTFOUND;

            IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
            THEN
               IF resp_code = c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
            THEN
               IF resp_code != c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            END IF;
         END LOOP;

         CLOSE c1_cur;
         resp_code := to_char (p_second_resp_code);
         OPEN c1_cur;

         LOOP
            FETCH c1_cur INTO c1_rec;
            EXIT WHEN c1_cur%NOTFOUND;

            IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
            THEN
               IF resp_code = c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
            THEN
               IF resp_code != c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            END IF;
         END LOOP;

         CLOSE c1_cur;
      ELSIF p_attempt_no = 3
      THEN
         resp_code := to_char (p_first_resp_code);
         OPEN c1_cur;

         LOOP
            FETCH c1_cur INTO c1_rec;
            EXIT WHEN c1_cur%NOTFOUND;

            IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
            THEN
               IF resp_code = c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
            THEN
               IF resp_code != c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            END IF;
         END LOOP;

         CLOSE c1_cur;
         resp_code := to_char (p_second_resp_code);
         OPEN c1_cur;

         LOOP
            FETCH c1_cur INTO c1_rec;
            EXIT WHEN c1_cur%NOTFOUND;

            IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
            THEN
               IF resp_code = c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
            THEN
               IF resp_code != c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            END IF;
         END LOOP;

         CLOSE c1_cur;
         resp_code := to_char (p_third_resp_code);
         OPEN c1_cur;

         LOOP
            FETCH c1_cur INTO c1_rec;
            EXIT WHEN c1_cur%NOTFOUND;

            IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
            THEN
               IF resp_code = c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
            THEN
               IF resp_code != c1_rec.x_rule_param_1
               THEN
                  o_result := 1;
               ELSE
                  o_result := 0;
               END IF;
            END IF;
         END LOOP;

         CLOSE c1_cur;
      END IF;
*/
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
   END attempt_resp_code;

   PROCEDURE tot_num_dec_cust (
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
      l_count   x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM x_program_purch_hdr
          WHERE prog_hdr2web_user = p_web_user_objid
            and  X_ICS_RCODE!='100' and  X_ICS_RCODE!='1';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END tot_num_dec_cust;

   PROCEDURE tot_num_dec_esn (
      p_cond_objid   IN       NUMBER,
      p_esn          IN       VARCHAR2,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   )
   IS
      l_count   x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM x_program_purch_hdr
          WHERE objid in ( select PGM_PURCH_DTL2PROG_HDR from x_program_purch_dtl where x_esn = p_esn)
            and  X_ICS_RCODE!='100' and  X_ICS_RCODE!='1';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END tot_num_dec_esn;

   PROCEDURE tot_num_rev_cust (
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
      l_count   x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM X_METRICS_REVERSAL
          WHERE REVERSAL2WEB_USER = p_web_user_objid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END tot_num_rev_cust;

   PROCEDURE tot_num_rev_esn (
      p_cond_objid   IN       NUMBER,
      p_esn          IN       VARCHAR2,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   )
   IS
      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      l_count   x_rule_cond_trans.x_rule_param_1%TYPE;
      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO l_count
          FROM X_METRICS_REVERSAL
          WHERE x_esn = p_esn;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END tot_num_rev_esn;

   PROCEDURE tot_redebit_attmt_esn (
      p_cond_objid   IN       NUMBER,
      p_esn          IN       VARCHAR2,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   )
   IS
      l_count   x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM x_metrics_redebits
          WHERE x_esn = p_esn;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END tot_redebit_attmt_esn;

   PROCEDURE auto_num_payment_resp_esn (
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      p_mrchnt_rf_id     IN       VARCHAR2,
      p_esn              IN       VARCHAR2,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
     resp_code   x_rule_cond_trans.X_RULE_EVAL_1%TYPE;
      l_count     x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec      c1_cur%ROWTYPE;
   BEGIN
      /*
      BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM x_program_purch_hdr
          WHERE x_esn = p_esn
            and  X_ICS_RCODE!=100 and  X_ICS_RCODE!=1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      BEGIN
         SELECT x_ics_rcode
           INTO resp_code
           FROM x_program_purch_hdr
          WHERE x_esn = p_esn
            AND x_merchant_ref_number = p_mrchnt_rf_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;
      */
      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;
         SELECT COUNT (*)
           INTO l_count
           FROM x_program_purch_hdr
          WHERE objid in ( select PGM_PURCH_DTL2PROG_HDR from x_program_purch_dtl where x_esn = p_esn)
            AND x_ics_rcode = c1_rec.x_rule_param_2;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)

--                AND resp_code = c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)

--                AND resp_code != c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)

--                AND resp_code < c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)

--                AND resp_code <= c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)

--                AND resp_code > c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)

--                AND resp_code >= c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END auto_num_payment_resp_esn;

   PROCEDURE auto_num_payment_resp_cust (
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      p_mrchnt_rf_id     IN       VARCHAR2,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
     resp_code   x_rule_cond_trans.X_RULE_EVAL_1%TYPE;
      l_count     x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec      c1_cur%ROWTYPE;
   BEGIN
        --- Pick up the record with the given response code available from the cond_tran table
        --- select count(*) from program_purch_hdr
/*
      BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM x_program_purch_hdr
          WHERE prog_hdr2web_user = p_web_user_objid
            and  X_ICS_RCODE!=100 and  X_ICS_RCODE!=1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      BEGIN
         SELECT x_ics_rcode
           INTO resp_code
           FROM x_program_purch_hdr
          WHERE x_merchant_ref_number = p_mrchnt_rf_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;
*/
      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;
         SELECT COUNT (*)
           INTO l_count
           FROM x_program_purch_hdr
          WHERE prog_hdr2web_user = p_web_user_objid
            AND x_ics_rcode = c1_rec.x_rule_param_2;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)

--                AND resp_code = c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)

--                AND resp_code != c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)

--                AND resp_code < c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)

--                AND resp_code <= c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)

--                AND resp_code > c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)

--                AND resp_code >= c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END auto_num_payment_resp_cust;

   PROCEDURE auto_tot_redebit_attmt_cust (
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
      l_count   x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM x_metrics_redebits
          WHERE redebit2web_user = p_web_user_objid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END auto_tot_redebit_attmt_cust;

   PROCEDURE auto_tot_redebit_attmt_esn (
      p_cond_objid   IN       NUMBER,
      p_esn          IN       VARCHAR2,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   )
   IS
      l_count   x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM x_metrics_redebits
          WHERE x_esn = p_esn;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END auto_tot_redebit_attmt_esn;

   PROCEDURE auto_tot_num_rev_esn (
      p_cond_objid   IN       NUMBER,
      p_esn          IN       VARCHAR2,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   )
   IS
      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      l_count   x_rule_cond_trans.x_rule_param_1%TYPE;
      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO l_count
          FROM X_METRICS_REVERSAL
          WHERE X_ESN = p_esn;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END auto_tot_num_rev_esn;

   PROCEDURE auto_tot_num_rev_cust (
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
      l_count   x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO l_count
          FROM X_METRICS_REVERSAL
          WHERE REVERSAL2WEB_USER = p_web_user_objid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END auto_tot_num_rev_cust;

   PROCEDURE auto_num_dec_cust (
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
      l_count   x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM x_program_purch_hdr
          WHERE prog_hdr2web_user = p_web_user_objid
            and  X_ICS_RCODE!='100' and  X_ICS_RCODE!='1';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END auto_num_dec_cust;

   PROCEDURE num_payment_resp_esn (
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      p_esn              IN       VARCHAR2,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
      resp_code   x_rule_cond_trans.X_RULE_EVAL_1%TYPE;
      l_count     x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec      c1_cur%ROWTYPE;
   BEGIN
	  /*
      BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM x_program_purch_hdr
          WHERE x_esn = p_esn
            and  X_ICS_RCODE!=100 and  X_ICS_RCODE!=1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      BEGIN
         SELECT x_ics_rcode
           INTO resp_code
           FROM x_program_purch_hdr
          WHERE x_esn = p_esn;
      --         AND x_merchant_ref_number = p_mrchnt_rf_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;
	  */

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         dbms_output.put_line('Rule Param 2 ' ||  c1_rec.x_rule_param_2 || ' ... Count ' || c1_rec.x_rule_param_1 );
         -- Get the number of records available for the given response code.
         select count(*) into l_count
         from x_program_purch_hdr where objid in ( select PGM_PURCH_DTL2PROG_HDR from x_program_purch_dtl where x_esn = p_esn)
         and  x_ics_rcode = c1_rec.x_rule_param_2;

         dbms_output.put_line('Total records for the given ESN with response code ' || c1_rec.x_rule_param_2 || ' is ' || to_char(l_count) );

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF      to_number(l_count) = to_number(c1_rec.x_rule_param_1)
                --AND resp_code = c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF      to_number(l_count) != to_number(c1_rec.x_rule_param_1)
                --AND resp_code != c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF      l_count < c1_rec.x_rule_param_1
                --AND resp_code < c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF      to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
                --AND resp_code <= c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF      to_number(l_count) > to_number(c1_rec.x_rule_param_1)
                --AND resp_code > c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF      to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
                --AND resp_code >= c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END num_payment_resp_esn;

   PROCEDURE num_payment_resp_cust (
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
      resp_code   x_program_purch_hdr.x_ics_rcode%TYPE;
      l_count     x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec      c1_cur%ROWTYPE;
   BEGIN
      /*BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM x_program_purch_hdr
          WHERE prog_hdr2web_user = p_web_user_objid
            and  X_ICS_RCODE!='100' and  X_ICS_RCODE!='1';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      BEGIN
         SELECT x_ics_rcode
           INTO resp_code
           FROM x_program_purch_hdr
          WHERE prog_hdr2web_user = p_web_user_objid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;
	  */

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

		 dbms_output.put_line('Rule Param 2 ' ||  c1_rec.x_rule_param_2 || ' ... Count ' || c1_rec.x_rule_param_1 );
         -- Get the number of records available for the given response code.
         select count(*) into l_count
         from x_program_purch_hdr where prog_hdr2web_user = p_web_user_objid
         and  x_ics_rcode = c1_rec.x_rule_param_2;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF      to_number(l_count) = to_number(c1_rec.x_rule_param_1)
                --AND resp_code = c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF      to_number(l_count) != to_number(c1_rec.x_rule_param_1)
                --AND resp_code != c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF      to_number(l_count) < to_number(c1_rec.x_rule_param_1)
                --AND resp_code < c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF      to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
                --AND resp_code <= c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF      to_number(l_count) > to_number(c1_rec.x_rule_param_1)
                --AND resp_code > c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF      to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
                --AND resp_code >= c1_rec.x_rule_param_2
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END num_payment_resp_cust;

   PROCEDURE tot_amt_added_aft_enroll (
      p_cond_objid       IN       NUMBER,
      p_esn              IN       VARCHAR2,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec           c1_cur%ROWTYPE;
      l_total_amount   NUMBER;
   BEGIN
      BEGIN
         FOR idx IN  (SELECT objid, x_enrolled_date
                        FROM x_program_enrolled
                       WHERE x_esn = p_esn
                         AND pgm_enroll2web_user = p_web_user_objid)
         LOOP
            FOR idx_sub IN  (SELECT x_credit_amt
                               FROM x_data_services_funds
                              WHERE data_ser2pgm_enroll = idx.objid
                                AND (x_date BETWEEN (idx.x_enrolled_date)
                                                AND SYSDATE
                                    ))
            LOOP
               l_total_amount :=
                        NVL (l_total_amount, 0)
                      + NVL (idx_sub.x_credit_amt, 0);
            END LOOP;
         END LOOP;
      EXCEPTION
         WHEN INVALID_CURSOR
         THEN
            raise_application_error (
               -20001,
               'The  objid Is invalid..Try to give correct value'
            );
         WHEN NO_DATA_FOUND
         THEN
            o_err_num := SQLCODE;
            o_err_msg := SUBSTR (SQLERRM, 1, 100);
         WHEN OTHERS
         THEN
            o_err_num := -100;
            o_err_msg :=    SQLCODE
                         || SUBSTR (SQLERRM, 1, 100);
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF l_total_amount = c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF l_total_amount != c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF l_total_amount < c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF l_total_amount <= c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF l_total_amount > c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF l_total_amount >= c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
      DBMS_OUTPUT.put_line (   'Total amount is..'
                            || l_total_amount);
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END tot_amt_added_aft_enroll;

   PROCEDURE tot_amt_added_last30day (
      p_cond_objid       IN       NUMBER,
      p_esn              IN       VARCHAR2,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec           c1_cur%ROWTYPE;
      l_total_amount   NUMBER;
   BEGIN
      BEGIN
         FOR idx IN  (SELECT objid
                        FROM x_program_enrolled
                       WHERE x_esn = p_esn
                         AND pgm_enroll2web_user = p_web_user_objid)
         LOOP
            FOR idx_sub IN  (SELECT x_credit_amt
                               FROM x_data_services_funds
                              WHERE data_ser2pgm_enroll = idx.objid
                                AND (x_date BETWEEN (  SYSDATE
                                                     - 30
                                                    )
                                                AND SYSDATE
                                    ))
            LOOP
               l_total_amount :=
                        NVL (l_total_amount, 0)
                      + NVL (idx_sub.x_credit_amt, 0);
            END LOOP;
         END LOOP;
      EXCEPTION
         WHEN INVALID_CURSOR
         THEN
            raise_application_error (
               -20001,
               'Hi, The  objid Is invalid..Try to give correct value'
            );
         WHEN NO_DATA_FOUND
         THEN
            o_err_num := SQLCODE;
            o_err_msg := SUBSTR (SQLERRM, 1, 100);
         WHEN OTHERS
         THEN
            o_err_num := -100;
            o_err_msg :=    SQLCODE
                         || SUBSTR (SQLERRM, 1, 100);
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF l_total_amount = c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF l_total_amount != c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF l_total_amount < c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF l_total_amount <= c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF l_total_amount > c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF l_total_amount >= c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
      DBMS_OUTPUT.put_line (   'Total amount is..'
                            || l_total_amount);
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'Hi, The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END tot_amt_added_last30day;

   PROCEDURE tot_amt_added_session (
      p_cond_objid   IN       NUMBER,
      p_session_id   IN       VARCHAR2,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   )
   IS
      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec           c1_cur%ROWTYPE;
      l_total_amount   NUMBER;
   BEGIN
      BEGIN
         FOR idx IN  (SELECT enroll_atp2purch_hdr
                        FROM x_metrics_enroll_attempt
                       WHERE x_session_id = p_session_id)
         LOOP
            FOR idx_sub IN  (SELECT x_amount
                               FROM x_program_purch_hdr
                              WHERE objid = idx.enroll_atp2purch_hdr)
            LOOP
               l_total_amount :=
                            NVL (l_total_amount, 0)
                          + NVL (idx_sub.x_amount, 0);
            END LOOP;
         END LOOP;
      EXCEPTION
         WHEN INVALID_CURSOR
         THEN
            raise_application_error (
               -20001,
               'Hi, The  objid Is invalid..Try to give correct value'
            );
         WHEN NO_DATA_FOUND
         THEN
            o_err_num := SQLCODE;
            o_err_msg := SUBSTR (SQLERRM, 1, 100);
         WHEN OTHERS
         THEN
            o_err_num := -100;
            o_err_msg :=    SQLCODE
                         || SUBSTR (SQLERRM, 1, 100);
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF l_total_amount = c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF l_total_amount != c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF l_total_amount < c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF l_total_amount <= c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF l_total_amount > c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF l_total_amount >= c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
      DBMS_OUTPUT.put_line (   'Total amount is..'
                            || l_total_amount);
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'Hi, The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END tot_amt_added_session;

   PROCEDURE tot_redebit_attmt_cust (
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
      l_count   x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM x_metrics_redebits
          WHERE redebit2web_user = p_web_user_objid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'Hi, The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END tot_redebit_attmt_cust;

   PROCEDURE auto_fail_enroll_attmt_prog (
      p_cond_objid       IN       NUMBER,
      p_prog_id          IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
      l_count   x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM x_metrics_enroll_attempt
          WHERE enroll_atp2web_user = p_web_user_objid
            AND enroll_atp2prog_param = p_prog_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END auto_fail_enroll_attmt_prog;

   PROCEDURE auto_fail_enroll_attmt_day (
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
      l_count   x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM x_metrics_enroll_attempt
          WHERE enroll_atp2web_user = p_web_user_objid
            AND trunc(x_attempt_date) = trunc(SYSDATE);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
		    IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END auto_fail_enroll_attmt_day;

   PROCEDURE auto_fail_enroll_attmt_cust (
      p_cond_objid       IN       NUMBER,
      p_web_user_objid   IN       NUMBER,
      o_result           OUT      NUMBER,
      o_err_num          OUT      VARCHAR2,
      o_err_msg          OUT      VARCHAR2
   )
   IS
      l_count   x_rule_cond_trans.x_rule_param_1%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      BEGIN
         SELECT COUNT (*)
           INTO l_count
           FROM x_metrics_enroll_attempt
          WHERE enroll_atp2web_user = p_web_user_objid;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF to_number(l_count) = to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF to_number(l_count) != to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF to_number(l_count) < to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) <= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF to_number(l_count) > to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF to_number(l_count) >= to_number(c1_rec.x_rule_param_1)
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'Hi, The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END auto_fail_enroll_attmt_cust;

   PROCEDURE payment_method (
      p_cond_objid   IN       NUMBER,
      p_pay_type     IN       VARCHAR2,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   )
   IS
      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec   c1_cur%ROWTYPE;
   BEGIN
      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF p_pay_type = c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF p_pay_type != c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'Hi, The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END payment_method;

   PROCEDURE name_autopay_pgm_enroll (
      p_cond_objid   IN       NUMBER,
      p_enroll_id    IN       NUMBER,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   )
   IS
      --     l_prog_name   x_program_parameters.X_PROGRAM_NAME%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec      c1_cur%ROWTYPE;
      l_prog_id   x_program_enrolled.pgm_enroll2pgm_parameter%TYPE;
   BEGIN
      SELECT pgm_enroll2pgm_parameter
        INTO l_prog_id
        FROM x_program_enrolled
       WHERE objid = p_enroll_id;
      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF l_prog_id = c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF l_prog_id != c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'Hi, The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END name_autopay_pgm_enroll;

   PROCEDURE cc_blocked_ftr_enroll (
      p_cc_objid   IN       NUMBER, --program purchase header
      o_result     OUT      NUMBER,
      o_err_num    OUT      VARCHAR2,
      o_err_msg    OUT      VARCHAR2
   )
   IS
      cc_objid   X_PAYMENT_SOURCE.PYMT_SRC2X_CREDIT_CARD%TYPE;
      v_count   NUMBER (1) := 0;
   BEGIN

      SELECT PYMT_SRC2X_CREDIT_CARD
	  INTO cc_objid
	  FROM X_PAYMENT_SOURCE
	  WHERE OBJID=p_cc_objid;

      SELECT COUNT (*)
        INTO v_count
        FROM x_metrics_cc_block
       WHERE X_CREDIT_CARD_NUMBER = cc_objid;

      IF SQL%NOTFOUND
      THEN
         raise_application_error (-20001, 'no data found');
      END IF;

      IF v_count = 0
      THEN -- no credit card blocked
         o_result := 0; -- 0- not blocked for future enrollment
      ELSE
         o_result := 1; -- 1- blocked for future enrollment
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLCODE, 1, 100);
   END cc_blocked_ftr_enroll;

   PROCEDURE esn_blocked_ftr_enroll (
      p_esn   IN       NUMBER,
      o_result     OUT      NUMBER,
      o_err_num    OUT      VARCHAR2,
      o_err_msg    OUT      VARCHAR2
   )
   IS
      v_count   NUMBER (1) := 0;
   BEGIN
      SELECT COUNT (*)
        INTO v_count
       FROM x_metrics_block_status
       WHERE X_ESN = p_esn;

      IF SQL%NOTFOUND
      THEN
         raise_application_error (-20001, 'no data found');
      END IF;

      IF v_count = 0
      THEN -- no esn blocked
         o_result := 0; -- 0- not blocked for future enrollment
      ELSE
         o_result := 1; -- 1- blocked for future enrollment
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLCODE, 1, 100);
   END esn_blocked_ftr_enroll;

  PROCEDURE customer_blocked_ftr_enroll (
      p_web_user_objid   IN       NUMBER,
      o_result     OUT      NUMBER,
      o_err_num    OUT      VARCHAR2,
      o_err_msg    OUT      VARCHAR2
   )
   IS
      v_count   NUMBER (1) := 0;
   BEGIN
      SELECT COUNT (*)
        INTO v_count
       FROM X_METRICS_BLOCK_STATUS
       WHERE BLOCK_STATUS2WEB_USER = p_web_user_objid;

      IF SQL%NOTFOUND
      THEN
         raise_application_error (-20001, 'no data found');
      END IF;

      IF v_count = 0
      THEN -- no customer blocked
         o_result := 0; -- 0- not blocked for future enrollment
      ELSE
         o_result := 1; -- 1- blocked for future enrollment
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLCODE, 1, 100);
   END customer_blocked_ftr_enroll;

   PROCEDURE esn_in_cooling_prd (
      p_enroll_objid   IN       NUMBER, --program purchase header
      p_esn            IN       VARCHAR2, --program purchase header
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   )
   IS
      v_cooling_date   DATE;
   BEGIN
      SELECT x_cooling_exp_date
        INTO v_cooling_date
        FROM x_program_enrolled
       WHERE objid = p_enroll_objid
         AND x_esn = p_esn;

      IF SQL%NOTFOUND
      THEN
         raise_application_error (-20001, 'no data found');
      END IF;

      IF v_cooling_date > SYSDATE
      THEN
         o_result := 1; -- 1- in cooling period
      ELSE
         o_result := 0; -- 0- not in cooling period
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
   END esn_in_cooling_prd;

   PROCEDURE esn_prog_length (
      p_cond_objid     IN       NUMBER,
      p_enroll_objid   IN       NUMBER, --program purchase header
      p_esn            IN       VARCHAR2, --program purchase header
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   )
   IS
      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec            c1_cur%ROWTYPE;
      v_enroll_length   NUMBER;
      v_sysdate         DATE;
   BEGIN
      BEGIN
         SELECT   TO_DATE (SYSDATE)
                - TO_DATE (x_enrolled_date)
           INTO v_enroll_length
           FROM x_program_enrolled
          WHERE objid = p_enroll_objid
            AND x_esn = p_esn;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;

      SELECT TO_DATE (SYSDATE)
        INTO v_sysdate
        FROM DUAL;
      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF v_enroll_length = c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF v_enroll_length != c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF v_enroll_length < c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF v_enroll_length <= c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF v_enroll_length > c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF v_enroll_length >= c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'Hi, The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END esn_prog_length;

   PROCEDURE cc_black_listed (
      p_cc_objid   IN       NUMBER, --program purchase header
      o_result     OUT      NUMBER,
      o_err_num    OUT      VARCHAR2,
      o_err_msg    OUT      VARCHAR2
   )
   IS
      v_max_purch_amt   NUMBER;
   BEGIN
      SELECT x_max_purch_amt
        INTO v_max_purch_amt
        FROM table_x_credit_card
       WHERE objid = p_cc_objid;

      IF SQL%NOTFOUND
      THEN
         raise_application_error (-20001, 'no data exist');
      END IF;

      IF v_max_purch_amt = .01
      THEN
         o_result := 1; -- 1- credit card blacklisted
      ELSE
         o_result := 0; -- 0- credit not card blacklisted
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLCODE, 1, 100);
   END cc_black_listed;

   PROCEDURE cc_not_blocked_ftr_enroll (
      p_cc_objid   IN       NUMBER, --program purchase header
      o_result     OUT      NUMBER,
      o_err_num    OUT      VARCHAR2,
      o_err_msg    OUT      VARCHAR2
   )
   IS
      v_count   NUMBER (1) := 0;
   BEGIN
      SELECT COUNT (*)
        INTO v_count
        FROM x_metrics_cc_block
       WHERE objid = p_cc_objid;

      IF SQL%NOTFOUND
      THEN
         raise_application_error (-20001, 'no data found');
      END IF;

      IF v_count = 0
      THEN
         o_result := 1; -- 1-  blocked for future enrollment
      ELSE
         o_result := 0; -- 0-  not blocked for future enrollment
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLCODE, 1, 100);
   END cc_not_blocked_ftr_enroll;

   PROCEDURE esn_not_in_cooling_prd (
      p_enroll_objid   IN       NUMBER, --program purchase header
      p_esn            IN       VARCHAR2, --program purchase header
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   )
   IS
      v_cooling_date   DATE;
   BEGIN
      SELECT x_cooling_exp_date
        INTO v_cooling_date
        FROM x_program_enrolled
       WHERE objid = p_enroll_objid
         AND x_esn = p_esn;

      IF SQL%NOTFOUND
      THEN
         raise_application_error (-20001, 'no data found');
      END IF;

      IF v_cooling_date > SYSDATE
      THEN
         o_result := 0; -- 0- not in cooling period
      ELSE
         o_result := 1; -- 1-  in cooling period
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
   END esn_not_in_cooling_prd;

   PROCEDURE cc_not_black_listed (
      p_cc_objid   IN       NUMBER, --program purchase header
      o_result     OUT      NUMBER,
      o_err_num    OUT      VARCHAR2,
      o_err_msg    OUT      VARCHAR2
   )
   IS
      v_max_purch_amt   NUMBER;
   BEGIN
      SELECT x_max_purch_amt
        INTO v_max_purch_amt
        FROM table_x_credit_card
       WHERE objid = p_cc_objid;

      IF SQL%NOTFOUND
      THEN
         raise_application_error (-20001, 'no data exist');
      END IF;

      IF v_max_purch_amt = .01
      THEN
         o_result := 0; -- 0- credit not card blacklisted
      ELSE
         o_result := 1; -- 1- credit card blacklisted
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLCODE, 1, 100);
   END cc_not_black_listed;

   PROCEDURE pnow_payment_attempt_reversal (
      --- to find out payment attempt reversal

      p_enroll_objid   IN       NUMBER,
      p_cond_objid     IN       NUMBER,
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   )
   IS
      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec          c1_cur%ROWTYPE;
      l_life_status   x_program_enrolled.x_enrollment_status%TYPE;
   BEGIN
      SELECT x_enrollment_status
        INTO l_life_status
        FROM x_program_enrolled
       WHERE objid = p_enroll_objid;
      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;
      END LOOP;

      IF l_life_status = 'SUSPEND'
      THEN
         o_result := 1;
      ELSE
         o_result := 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END pnow_payment_attempt_reversal;

   PROCEDURE auto_name_prog_trying (
      -- to find out the name of the autopay program trying to enroll
      p_prog_objid   IN       NUMBER,
      p_cond_objid   IN       NUMBER,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   )
   IS
      resp_code   x_program_purch_hdr.x_ics_rcode%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec      c1_cur%ROWTYPE;
   BEGIN
      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF p_prog_objid = c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF p_prog_objid != c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END auto_name_prog_trying;

   PROCEDURE web_csr_is_enroll_group (
      p_prog_objid   IN       NUMBER,
      p_esn          IN       VARCHAR2,
      p_cond_objid   IN       NUMBER,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   )
   -- WEB_CSR_IS_ENROLL_GROUP ( 800, 111111111111111, 101 )
   IS
      l_type    x_program_parameters.x_type%TYPE;
      l_count   NUMBER;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec    c1_cur%ROWTYPE;
   BEGIN
      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         BEGIN
            SELECT x_type
              INTO l_type
              FROM x_program_parameters
             WHERE objid = p_prog_objid;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               o_result := 0;
               o_err_num := -20001;
               o_err_msg := ' NO PROGRAM FOUND';
         END;

         IF l_type = 'INDIVIDUAL'
         THEN
            o_result := 0;
         ELSIF l_type = 'GROUP'
         THEN
            SELECT COUNT (ROWID)
              INTO l_count
              FROM x_program_enrolled
             WHERE x_esn = p_esn
               AND pgm_enroll2pgm_parameter = p_prog_objid;

            IF l_count > 0
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END web_csr_is_enroll_group;

   PROCEDURE charge_back_reason_code (
      p_reason_code   IN       VARCHAR2,
      p_cond_objid    IN       NUMBER,
      o_result        OUT      NUMBER,
      o_err_num       OUT      VARCHAR2,
      o_err_msg       OUT      VARCHAR2
   )
   IS
      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec   c1_cur%ROWTYPE;
   BEGIN
      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF p_reason_code = c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF p_reason_code != c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END charge_back_reason_code;

   PROCEDURE charge_back_fund_src_type (
      p_source_type   IN       VARCHAR2,
      p_cond_objid    IN       NUMBER,
      o_result        OUT      NUMBER,
      o_err_num       OUT      VARCHAR2,
      o_err_msg       OUT      VARCHAR2
   )
   IS
      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec   c1_cur%ROWTYPE;
   BEGIN
      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF p_source_type = c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF p_source_type != c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END charge_back_fund_src_type;

   PROCEDURE web_csr_deactivation_reason (
      p_reason       IN       VARCHAR2,
      p_cond_objid   IN       NUMBER,
      o_result       OUT      NUMBER,
      o_err_num      OUT      VARCHAR2,
      o_err_msg      OUT      VARCHAR2
   )
   IS
      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec   c1_cur%ROWTYPE;
   BEGIN
      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF p_reason = c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF p_reason != c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END web_csr_deactivation_reason;

   PROCEDURE current_autopay_status (
      p_enroll_objid   IN       NUMBER,
      p_cond_objid     IN       NUMBER,
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   )
   IS
      l_enrollment_status   x_program_enrolled.x_enrollment_status%TYPE;

      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec                c1_cur%ROWTYPE;
   BEGIN
      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         BEGIN
            SELECT x_enrollment_status
              INTO l_enrollment_status
              FROM x_program_enrolled
             WHERE objid = p_enroll_objid;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               o_result := 0;
               o_err_num := -20001;
               o_err_msg := ' ESN NOT ENROLLED ';
         END;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF l_enrollment_status = c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF l_enrollment_status != c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END current_autopay_status;

   PROCEDURE pnow_for_past_due (
      p_enroll_objid   IN       NUMBER,
      p_cond_objid     IN       NUMBER,
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   )
   IS
      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec         c1_cur%ROWTYPE;
      pay_now_flag   NUMBER           DEFAULT 0;
   BEGIN
      pay_now_flag := billing_is_paynow_enabled (p_enroll_objid);
      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;
      END LOOP;

      IF pay_now_flag = 2
      THEN
         o_result := 1;
      ELSE
         o_result := 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END pnow_for_past_due;

   PROCEDURE pnow_for_ftr_cyl (
      p_enroll_objid   IN       NUMBER,
      p_cond_objid     IN       NUMBER,
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   )
   IS
      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec         c1_cur%ROWTYPE;
      pay_now_flag   NUMBER           DEFAULT 0;
   BEGIN
      pay_now_flag := billing_is_paynow_enabled (p_enroll_objid);
      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;
      END LOOP;

      IF pay_now_flag = 1
      THEN
         o_result := 1;
      ELSE
         o_result := 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END pnow_for_ftr_cyl;



PROCEDURE current_response_code (
   p_cond_objid     IN       NUMBER,
   p_mrchnt_rf_id   IN       VARCHAR2,
   o_result         OUT      NUMBER,
   o_err_num        OUT      VARCHAR2,
   o_err_msg        OUT      VARCHAR2
)
IS
   CURSOR c1_cur
   IS
      SELECT *
        FROM x_rule_cond_trans
       WHERE objid = p_cond_objid;

   c1_rec        c1_cur%ROWTYPE;

   CURSOR resp_code
   IS
      SELECT to_char(x_ics_rcode) x_ics_rcode
        FROM x_program_purch_hdr
       WHERE x_merchant_ref_number = p_mrchnt_rf_id;

   l_resp_code   resp_code%ROWTYPE;
 --  l_resp_code   x_rule_cond_trans.x_rule_param_1%TYPE;

BEGIN
   OPEN resp_code;
   FETCH resp_code INTO l_resp_code;
   if resp_code%notfound then
   return;
   end if;
  -- l_resp_code := to_char(v_resp_code);
   OPEN c1_cur;
   LOOP
      FETCH c1_cur INTO c1_rec;
      EXIT WHEN c1_cur%NOTFOUND;

      IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
      THEN
         IF l_resp_code.x_ics_rcode = c1_rec.x_rule_param_1
         THEN
            o_result := 1;
         ELSE
            o_result := 0;
         END IF;
      ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
      THEN
         IF l_resp_code.x_ics_rcode != c1_rec.x_rule_param_1
         THEN
            o_result := 1;
         ELSE
            o_result := 0;
         END IF;
      END IF;
   END LOOP;

   CLOSE c1_cur;
   CLOSE resp_code;
EXCEPTION
   WHEN INVALID_CURSOR
   THEN
      raise_application_error (
         -20001,
         'Hi, The  objid Is invalid..Try to give correct value'
      );
   WHEN NO_DATA_FOUND
   THEN
      o_err_num := SQLCODE;
      o_err_msg := SUBSTR (SQLERRM, 1, 100);
   WHEN OTHERS
   THEN
      o_err_num := -100;
      o_err_msg :=    SQLCODE
                   || SUBSTR (SQLERRM, 1, 100);
END current_response_code;

PROCEDURE TOT_NUM_FAIL_RESP_IN_CYL (
      p_cond_objid     IN       NUMBER,
      p_enroll_objid   IN       NUMBER,
      o_result         OUT      NUMBER,
      o_err_num        OUT      VARCHAR2,
      o_err_msg        OUT      VARCHAR2
   )
   IS
      CURSOR c1_cur
      IS
         SELECT *
           FROM x_rule_cond_trans
          WHERE objid = p_cond_objid;

      c1_rec            c1_cur%ROWTYPE;
      v_COUNT   NUMBER;
      v_sysdate         DATE;
   BEGIN
      BEGIN
         SELECT   COUNT (*) INTO v_COUNT
                     FROM x_program_enrolled a,
                          x_program_purch_dtl b,
                          x_program_purch_hdr c
                    WHERE a.objid = b.pgm_purch_dtl2pgm_enrolled
                      AND b.pgm_purch_dtl2prog_hdr = c.objid
                      AND c.x_rqst_date BETWEEN b.x_cycle_start_date
                                            AND b.x_cycle_end_date
                      AND a.x_charge_date BETWEEN b.x_cycle_start_date
                                              AND b.x_cycle_end_date
                      AND c.x_ics_rcode !=
                                   '100' -- Do not include Success (100) records
                      AND a.objid = p_enroll_objid
                 ORDER BY c.x_rqst_date;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            raise_application_error (-20001, 'Record not found ');
      END;


      OPEN c1_cur;

      LOOP
         FETCH c1_cur INTO c1_rec;
         EXIT WHEN c1_cur%NOTFOUND;

         IF c1_rec.x_rule_eval_1 = 'IS_EQ_TO'
         THEN
            IF v_COUNT  = c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_NOT_EQ_TO'
         THEN
            IF v_COUNT  != c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN'
         THEN
            IF v_COUNT  < c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_LESS_THAN_OR_EQ_TO'
         THEN
            IF v_COUNT  <= c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN'
         THEN
            IF v_COUNT  > c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         ELSIF c1_rec.x_rule_eval_1 = 'IS_GET_THAN_OR_EQ_TO'
         THEN
            IF v_COUNT  >= c1_rec.x_rule_param_1
            THEN
               o_result := 1;
            ELSE
               o_result := 0;
            END IF;
         END IF;
      END LOOP;

      CLOSE c1_cur;
   EXCEPTION
      WHEN INVALID_CURSOR
      THEN
         raise_application_error (
            -20001,
            'Hi, The  objid Is invalid..Try to give correct value'
         );
      WHEN NO_DATA_FOUND
      THEN
         o_err_num := SQLCODE;
         o_err_msg := SUBSTR (SQLERRM, 1, 100);
      WHEN OTHERS
      THEN
         o_err_num := -100;
         o_err_msg :=    SQLCODE
                      || SUBSTR (SQLERRM, 1, 100);
   END TOT_NUM_FAIL_RESP_IN_CYL;


END billing_rule_engine_pkg;
/