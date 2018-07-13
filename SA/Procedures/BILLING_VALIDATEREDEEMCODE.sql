CREATE OR REPLACE PROCEDURE sa."BILLING_VALIDATEREDEEMCODE" (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_validateredeemcode													 */
/*                                                                                          	 */
/* Purpose      :   Used during enrollment and subsequent charges made to the customer			 */
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

   p_redeem_objid    IN       VARCHAR2, -- Redemption Objid
   p_redeem_type     OUT      VARCHAR2, -- Whether the promotion is onetime/recurring
   p_redeem_amount   OUT      NUMBER, -- Dollar Discount given
   p_redeem_units    OUT      NUMBER, -- Units given
   p_redeem_days     OUT      NUMBER, -- Days given
   p_error_code      OUT      NUMBER, -- Error Code
   p_error_message   OUT      VARCHAR2 -- Error Message
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

   CURSOR promotion_c
   IS
      SELECT *
        FROM table_x_promotion
       WHERE objid = p_redeem_objid
         AND x_promo_type = 'BPRedemption';

   v_promo_rec          promotion_c%ROWTYPE;
BEGIN
   p_error_code := 0;
   -- Fetch the record. Only one record will be available.
   -- If no records found, then the promocode is invalid
   OPEN promotion_c;
   FETCH promotion_c INTO v_promo_rec;

   IF promotion_c%NOTFOUND
   THEN
      p_error_code := 9001;
      p_error_message := 'Promo code is invalid';
      ------FOR CR33218
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
            'BILLING_VALIDATEREDEEMCODE',
            p_error_code,
            p_error_message,
            sysdate,
            'p_redeem_objid ' || p_redeem_objid,
            2 -- MEDIUM
       );
      RETURN;
   END IF;

   CLOSE promotion_c;

   -- Record is found. Check if the promotion is valid.
   IF SYSDATE NOT BETWEEN v_promo_rec.x_start_date AND v_promo_rec.x_end_date
   THEN
      p_error_code := 9002;
      p_error_message := 'Promotion not valid at this time';
      ------FOR CR33218
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
            'BILLING_VALIDATEREDEEMCODE',
            p_error_code,
            p_error_message,
            sysdate,
            'p_redeem_objid ' || p_redeem_objid,
            2 -- MEDIUM
       );
      RETURN;
   END IF;

   /* No need to do a source system check, since the customer would have already been enrolled and
      all the necessary validations would have been done at that time */
   /*
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
   */
   p_redeem_units := v_promo_rec.x_units;
   p_redeem_days := v_promo_rec.x_access_days;
   p_redeem_amount := v_promo_rec.x_discount_amount;
   p_redeem_type := v_promo_rec.x_transaction_type;
   RETURN;
EXCEPTION
   WHEN OTHERS
   THEN
      p_error_code := -100;
      p_error_message :=    SQLCODE
                         || SUBSTR (SQLERRM, 1, 100); -- 'Database error';
------FOR CR33218
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
            'BILLING_VALIDATEREDEEMCODE',
            p_error_code,
            p_error_message,
            sysdate,
            'p_redeem_objid ' || p_redeem_objid,
            2 -- MEDIUM
       );
END; -- Procedure BILLING_VALIDATEREDEEMCODE
/