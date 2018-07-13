CREATE OR REPLACE FUNCTION sa."ISBEFOREENROLLMENTWINDOW" (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   isbeforeenrollmentwindow					 	 	 	 	 		 		 */
/*                                                                                          	 */
/* Purpose      :   validation for enrollment													 */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   01-19-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
   p_program_enrolled_id   IN   NUMBER
)
   RETURN NUMBER
IS
   l_enrollment_window   NUMBER;
   l_next_charge_date    DATE;
   l_prev_charge_date    DATE;
   l_program_param_id    NUMBER;

   l_charge_frq_code     VARCHAR2(30);
   l_prev_cycle_date    DATE;
BEGIN
   /* Return values:
       1   : Before the enrollment window
       2   : After the enrollment window
       0   : Not in the enrollment window / data error
   */
   -- If no data found, data is incorrect. return -100
   /*
   SELECT x_add_ph_window, X_CHARGE_FRQ_CODE
     INTO l_enrollment_window, l_charge_frq_code
     FROM x_program_parameters
    WHERE objid = l_program_param_id;
   */
   SELECT a.x_charge_date, a.x_next_charge_date, a.pgm_enroll2pgm_parameter,
                     decode ( b.X_CHARGE_FRQ_CODE, 'MONTHLY', ADD_MONTHS(a.x_next_charge_date, -1),
                                                 'PASTDUE', null,
                                                 'LOWBALANCE',null,
                                                 a.x_next_charge_date - to_number(b.X_CHARGE_FRQ_CODE)
                            ), b.x_add_ph_window
     INTO l_prev_charge_date, l_next_charge_date, l_program_param_id, l_prev_cycle_date, l_enrollment_window
     FROM x_program_enrolled a, x_program_parameters b
    WHERE a.PGM_ENROLL2PGM_PARAMETER = b.objid
      and a.objid = p_program_enrolled_id
      and ( a.X_WAIT_EXP_DATE is null or a.X_WAIT_EXP_DATE < sysdate );     -- Bug 309


   DBMS_OUTPUT.put_line (
         'Next cycle date'
      || l_next_charge_date
      || 'Prev Cycle Date'
      || l_prev_charge_date
      || 'Enrollment Date '
      || l_enrollment_window
      || 'Previous computed cycle date '
      || l_prev_cycle_date
   );
   DBMS_OUTPUT.put_line (  l_next_charge_date
                         - l_enrollment_window);

   IF (l_enrollment_window IS NOT NULL)
   THEN
      -- Check with the next enrollment date
      IF ((  l_next_charge_date
           - l_enrollment_window
          ) < SYSDATE
         )
      THEN
         -- Before the next cycle date. OK
         RETURN 1;
      ELSE
         IF (l_prev_charge_date < SYSDATE)
         THEN -- Sanity check for data inconsistencies
            IF ((  l_prev_charge_date
                 + l_enrollment_window
                ) > SYSDATE
               )
            THEN
               ---------------------- Cover for situations where previous_charge_date greater then computed previous cycle date ----------
               if ( l_prev_charge_date >  l_prev_cycle_date ) then
                  l_prev_charge_date := l_prev_cycle_date;
               end if;
               ----------------------------------------------------------------------------------------------------------------------------

               -- Prev cycle has just passed. Allow enrollment
               -- Additional check: If the customer has made a future payment, disallow this enrollment.
               if ( ( l_prev_cycle_date - l_prev_charge_date) > 1 ) then
                    return 0;       -- Advance payment is made. Additional phone enrollment not permitted.
               end if;

               RETURN 2;
            ELSE
               RETURN 0; -- Not in enrollment window
            END IF;
         END IF;
      END IF;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS
   THEN
      dbms_output.put_line(SQLERRM);
      RETURN 0;                         -- Incase of Error return 0
END; -- Function ISBEFOREENROLLMENTWINDOW
/