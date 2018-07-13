CREATE OR REPLACE PACKAGE sa."BILLING_LIFELINE_MONTHLY_PKG"
  IS

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_LIFELINE_MONTHLY_PKG.IS_LIFELINE_CUSTOMER		                    	 	 */
/*                                                                                          	 */
/* Purpose      :   To return the enrollment status of Lifeline Custoemr						 */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 10g                                                    				 */
/*                                                                                          	 */
/* Author       :   Ymillan                                                           	  		 */
/*                                                                                          	 */
/* Date         :   12-16-2009																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0     12-16-2009  YM  		 Initial  Revision                               			 */
/*                                                                                            	 */
/*                                                                                          	 */
/*************************************************************************************************/
  FUNCTION IS_LIFELINE_CUSTOMER
     ( p_esn	            IN VARCHAR2
     )
     RETURN  NUMBER;

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_LIFELINE_MONTHLY_PKG.DELIVER_RECURRING_MINUTES                    	 	 	 */
/*                                                                                          	 */
/* Purpose      :   To Deliver the recurring Minutes for Lifeline Customers						 */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 10g                                                    				 */
/*                                                                                          	 */
/* Author       :   Ymillan                                                           	  		 */
/*                                                                                          	 */
/* Date         :   12-09-2009																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0     12-16-2009  YM  		 Initial  Revision                               			 */
/*                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
 PROCEDURE    DELIVER_RECURRING_MINUTES_M(
      ip_x_ota_trans_id IN   NUMBER,
      future_days       in   number,
      l_batch_id        in   Number, -- input batch id procces for month
      batch_id          OUT  VARCHAR2,  -- output batch_id processed
      op_result         OUT  VARCHAR2,  -- Output Result
      op_msg	        OUT  VARCHAR2   -- Output Message
    );

END BILLING_LIFELINE_MONTHLY_PKG; -- Package Specification BILLING_LIFELINE_PKG
/