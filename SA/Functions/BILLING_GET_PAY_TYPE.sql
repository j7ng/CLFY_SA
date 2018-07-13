CREATE OR REPLACE FUNCTION sa.billing_get_pay_type (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_get_pay_type										 	 	 	 	 */
/*                                                                                          	 */
/* Purpose      :   Returns pay type CC/ACH for given pay_source 								 */
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
   p_payment_objid   X_PAYMENT_SOURCE.objid%TYPE
)
   RETURN VARCHAR2
IS
   /*  This function returns pay type CC/ACH for given pay_source */
   l_type   VARCHAR2 (30);
BEGIN

select X_PYMT_TYPE into l_type from X_PAYMENT_SOURCE where objid=  p_payment_objid;

RETURN  l_type;

EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL; -- No records found,
END;
/