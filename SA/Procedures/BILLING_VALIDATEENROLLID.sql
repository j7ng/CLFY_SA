CREATE OR REPLACE PROCEDURE sa."BILLING_VALIDATEENROLLID" (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_validateenrollid													 */
/*                                                                                          	 */
/* Purpose      :   Procedure to validate the Enrollment Promocode.                 			 */
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

   p_esn             IN       VARCHAR2, -- ESN
   p_promo_objid     IN       NUMBER, -- Enrollment Promocode objid
   p_source_system   IN       VARCHAR2, -- Promocodes for a given source system
   p_enroll_type     OUT      VARCHAR2, -- Whether the promotion is onetime/recurring
   p_enroll_amount   OUT      NUMBER, -- Dollar Discount given
   p_enroll_units    OUT      NUMBER, -- Units given
   p_enroll_days     OUT      NUMBER, -- Days given
   p_error_code      OUT      NUMBER, -- Error Code
   p_message   OUT      VARCHAR2 -- Error Message
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
            -100        -  Any database exception
   */

   l_count              NUMBER;
   l_start_date         DATE;
   l_end_date           DATE;
   l_transaction_type   table_x_promotion.x_transaction_type%TYPE;
   l_result             number; --CR49229

   CURSOR promotion_c
   IS
      SELECT *
        FROM table_x_promotion
       WHERE objid = p_promo_objid;

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
      p_message := 'Promo code is invalid';
      RETURN;
   END IF;

   CLOSE promotion_c;

   -- Record is found. Check if the promotion is valid.
   IF SYSDATE NOT BETWEEN v_promo_rec.x_start_date AND v_promo_rec.x_end_date
   THEN
      p_error_code := 9002;
      p_message := 'Promotion not valid at this time';
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
         p_message :=
                              'Promotion is not valid for '
                           || p_source_system;
         RETURN;
      END IF;
   END IF;

   p_enroll_units := v_promo_rec.x_units;
   p_enroll_days := v_promo_rec.x_access_days;
  -- p_enroll_amount := v_promo_rec.X_DISCOUNT_AMOUNT;
   p_enroll_type := v_promo_rec.x_transaction_type;

-- START CR49229

      enroll_promo_pkg.get_discount_amount(p_esn,
                             p_promo_objid,
                             null,
                             p_enroll_amount,
                             l_result);
-- END CR49229

   RETURN;
EXCEPTION
   WHEN OTHERS
   THEN
      p_error_code := -100;
      p_message := sqlcode || substr(sqlerrm,1,100);--'Database error';
END; -- Procedure BILLING_VALIDATEENROLLCODE
/