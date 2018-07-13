CREATE OR REPLACE PROCEDURE sa."BILLING_ISBEFOREENROLLMENTWIN"
   (


/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_ISBEFOREENROLLMENTWIN                     							 */
/*                                                                                          	 */
/* Purpose      :   To get enrollment window													 */
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

   p_program_enrolled_id   IN  NUMBER,
   p_before_flag        OUT NUMBER
   )
   IS
BEGIN
    /* Return values:
        1   : Before the enrollment window
        2   : After the enrollment window
        0   : Not in the enrollment window / data error
    */
    p_before_flag := IsBeforeEnrollmentWindow(p_program_enrolled_id);
EXCEPTION
    WHEN OTHERS THEN
        p_before_flag := -100 ;   -- Either program_parameters / program_enrolled does not have the data for the given inputs


END; -- Procedure BILLING_ISBEFOREENROLLMENTWIN
/