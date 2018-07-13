CREATE OR REPLACE FUNCTION sa."MERCHANT_REF_NUMBER"
/*****************************************************************************************************************/
/*                                                                                                      	 */
/* Name         :   merchant_ref_number				 		 		 		 */
/*                                                                                                       	 */
/* Purpose      :   To generate merchant reference number	                                		 */
/*                                                                                                      	 */
/*                                                                                                      	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                                      	 */
/* Author       :   RSI                                                               	  			 */
/*                                                                                                       	 */
/* Date         :   01-19-2006					                                                 */
/* REVISIONS:                                                           					 */
/* VERSION  DATE        WHO           PURPOSE                                  					 */
/* -------  ---------- 	--------      --------------------------------------------           			 */
/*  1.0                       	      Initial  Revision                                    			 */
/*  1.1/2   09/18/09    CLINDER       create the merchant ref number from new sequence                           */
/*  1.3     09/23/09    ICANAVAN      CR10902 remove variables                              	                 */
/*****************************************************************************************************************/
   RETURN VARCHAR2
IS
   v_seq_name          VARCHAR2 (100) := trim ('X_MERCHANT_REF_NUMBER');
   -- v_get_current_rec   get_current%ROWTYPE;  -- CR10902
   v_next_value        NUMBER;
   v_dummy             NUMBER;
   v_max_attempts      NUMBER                := 10;
   v_program_name      VARCHAR2 (50)         := 'billing_seq1';
   v_error             VARCHAR2 (1000);
   v_sysdate           DATE                  DEFAULT TRUNC (SYSDATE);
   -- l_seq_rec           x_seq_table%ROWTYPE; -- CR10902
BEGIN
  select sequ_merchant_ref_number.nextval
    into v_next_value
    from dual;
  RETURN    'BP'|| trunc(TO_CHAR (v_sysdate, 'YYYYMMDD'))||  ''|| v_next_value;
EXCEPTION
      WHEN OTHERS
      THEN
         INSERT INTO error_table
                     (error_text,
                      error_date, action,
                      key, program_name)
              VALUES (   'Error occured when updating sequence '
                      || v_seq_name
                      || ' - '
                      || v_error,
                      v_sysdate,    'Updating sequence '
                               || v_seq_name,
                      v_seq_name, v_program_name);

         COMMIT;
         raise_application_error (
            -20004,
               'Error occured when updating sequence '
            || v_seq_name
            || v_error
         );
END merchant_ref_number;
/