CREATE OR REPLACE PROCEDURE sa."BILLING_VALIDATEENROLLCODE" (

/*************************************************************************************************/
/* 	 */
/* Name : SA.billing_validateenrollcode													 */
/* 	 */
/* Purpose : Validates the promocode used during Enrollment.                 			 */
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

   p_esn                IN       VARCHAR2, -- ESN
   p_program_param_id   IN       VARCHAR2, -- Program parameter id
   p_enroll_code        IN       VARCHAR2, -- Enrollment Promocode
   p_source_system      IN       VARCHAR2, -- Promocodes for a given source system
   p_language           IN       VARCHAR2 DEFAULT 'English', -- Language
   p_promo_code_objid   OUT      VARCHAR2, -- Promocode objid
   p_enroll_type        OUT      VARCHAR2, -- Whether the promotion is onetime/recurring
   p_enroll_amount      OUT      NUMBER, -- Dollar Discount given
   p_enroll_units       OUT      NUMBER, -- Units given
   p_enroll_days        OUT      NUMBER, -- Days given
   p_error_code         OUT      NUMBER, -- Error Code
   p_error_message      OUT      VARCHAR2 -- Error Message
)
IS
   /*
        This procedure is used during enrollment and subsequent charges made to the customer
        based on the ONETIME and RECURRING flags set in the TABLE_X_PROMOTION

        Error Return values:
            0           -  Success
            9000        -  ESN is not active
            9001        -  Promo code is not valid
            9002        -  Promo code not available at this time
            9003        -  Promotion is not valid for the given source system
            9004        -  Promocode is not valid for the given program
			9005		-  Promocode usage for the given ESN reached the maximum usage count
            -100        -  Any database exception
   */

   l_count              NUMBER;
   l_start_date         DATE;
   l_end_date           DATE;
   l_transaction_type   table_x_promotion.x_transaction_type%TYPE;
   l_esn_promo_count   Number := 0 ;
   l_result            number;  --CR49229

   CURSOR promotion_c
   IS
      SELECT *
        FROM table_x_promotion
       WHERE x_promo_code = LTRIM (RTRIM (p_enroll_code))
         AND x_promo_type = 'BPEnrollment';

   v_promo_rec          promotion_c%ROWTYPE;
BEGIN
   p_error_code := 0;
   -- Verify that the ESN is active. This check may not be required,
   -- since before enrollment all the ESN status is verified.
   /*
   select count(*) into l_count from table_site_part
   where serial_no = p_esn
   and   part_status = 'Active';


   -- We use count(*). No exception raised.
   if ( l_count = 0 ) then
       p_error_code := 9000;
       p_error_message := 'ESN ' || p_esn || ' is not active / not fount' ;
       return;
   end if;
   */ -- TODO: To be checked



   -- Fetch the record. Only one record will be available.
   -- If no records found, then the promocode is invalid
   OPEN promotion_c;
   FETCH promotion_c INTO v_promo_rec;

   IF promotion_c%NOTFOUND
   THEN
      p_error_code := 9001;
      p_error_message := 'Promo code is invalid';
      RETURN;
   END IF;

   CLOSE promotion_c;

   -- Record is found. Check if the promotion is valid.
   IF SYSDATE NOT BETWEEN v_promo_rec.x_start_date AND v_promo_rec.x_end_date
   THEN
      p_error_code := 9002;
      p_error_message := 'Promotion not valid at this time';
      RETURN;
   END IF;

   -- Check if the promotion is valid for the source system
   -- If the source system is NULL, then the promo is allowed for all sources
   IF (v_promo_rec.x_source_system IS NOT NULL)
   THEN
      -- Check for the source system match
      IF (v_promo_rec.x_source_system != p_source_system)
      THEN
         p_error_code := 9003;
         p_error_message :=
                              'Promotion is not valid for '
                           || p_source_system;
         RETURN;
      END IF;
   END IF;

   -- Check if the promocode is valid for the given program
   IF (v_promo_rec.x_sql_statement IS NOT NULL)
   THEN
      BEGIN
         EXECUTE IMMEDIATE v_promo_rec.x_sql_statement
            INTO l_count
            USING p_program_param_id, p_esn;

         IF (l_count = 0)
         THEN
            -- This promocode does not qualify for the promotion.
            p_error_code := 9003;
            p_error_message := 'Promocode is not valid for the given program';
            RETURN;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_error_code := -100;
            p_error_message :=    SQLCODE
                               || SUBSTR (SQLERRM, 1, 100); --'Database error';
			dbms_output.put_line(p_error_message);
      END;
   END IF;

   p_promo_code_objid := v_promo_rec.objid;
   p_enroll_units := v_promo_rec.x_units;
   p_enroll_days := v_promo_rec.x_access_days;
   --p_enroll_amount := v_promo_rec.x_discount_amount;
   p_enroll_type := v_promo_rec.x_transaction_type;

 -- START CR49229

      enroll_promo_pkg.get_discount_amount(p_esn,
                             p_promo_code_objid,
                             null,
                             p_enroll_amount,
                             l_result);
-- END CR49229

   IF (p_language = 'English')
   THEN
      p_error_message := v_promo_rec.x_promotion_text;
   ELSE
      p_error_message := v_promo_rec.x_spanish_promo_text;
   END IF;

   --Added by Narasimha for checking the maximum usage of promo code for the given ESN.Added on September 13 2006.
   select count(PGM_ENROLL2X_PROMOTION)
   into l_esn_promo_count
   from x_program_enrolled
   where x_esn = p_esn
   and PGM_ENROLL2X_PROMOTION = v_promo_rec.objid;

   if( l_esn_promo_count > 0 and l_esn_promo_count >= v_promo_rec.X_USAGE ) then
   		 p_error_code := 9005;
   end if;
   --End Added by Narasimha.

   RETURN;
EXCEPTION
   WHEN OTHERS
   THEN
      p_error_code := -100;
      p_error_message :=    SQLCODE
                         || SUBSTR (SQLERRM, 1, 100); -- 'Database error';
      DBMS_OUTPUT.put_line ('Exception');
      RETURN;
END; -- Procedure BILLING_VALIDATEENROLLCODE
/