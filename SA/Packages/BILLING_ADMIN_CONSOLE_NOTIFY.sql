CREATE OR REPLACE PACKAGE sa."BILLING_ADMIN_CONSOLE_NOTIFY"
IS
   FUNCTION billing_payment_received (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_GLOBAL_INSERT_PKG.insert_action_params                       	 	 */
/*                                                                                          	 */
/* Purpose      :   Validate payment recived				                					 */
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

      p_enroll_objid   IN   NUMBER,
      p_last_trans_date   IN   DATE
   )
      RETURN NUMBER;

   FUNCTION billing_paynow_activity (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_GLOBAL_INSERT_PKG.insert_action_params                       	 	 */
/*                                                                                          	 */
/* Purpose      :   IValidate paynow activity               									 */
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

      p_enroll_objid      IN   NUMBER,
      p_last_trans_date   IN   DATE
   )
      RETURN NUMBER;

   PROCEDURE billing_cc_expiry (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_GLOBAL_INSERT_PKG.insert_action_params                       	 	 */
/*                                                                                          	 */
/* Purpose      :   Validate credit card expiry             									 */
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

      p_payment_source_objid   IN       NUMBER,
      p_month                  OUT      table_x_credit_card.x_customer_cc_expmo%TYPE,
      p_year                   OUT      table_x_credit_card.x_customer_cc_expyr%TYPE,
      op_result                OUT      NUMBER,
      op_msg                   OUT      VARCHAR2
   );

   PROCEDURE billing_programs_status (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_GLOBAL_INSERT_PKG.insert_action_params                       	 	 */
/*                                                                                          	 */
/* Purpose      :   IGet Program status                      									 */
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

      p_enroll_objid     IN       NUMBER,
      p_program_status   OUT      VARCHAR2,
      op_result          OUT      NUMBER,
      op_msg             OUT      VARCHAR2
   );

   PROCEDURE billing_esn_status (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   BILLING_GLOBAL_INSERT_PKG.insert_action_params                       	 	 */
/*                                                                                          	 */
/* Purpose      :   Get ESN status                              								 */
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

      p_esn           IN       VARCHAR2,
      p_part_status   OUT      VARCHAR2,
      op_result       OUT      NUMBER,
      op_msg          OUT      VARCHAR2
   );

   PROCEDURE billing_remove_suspension (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_remove_suspension                                              	 	 */
/*                                                                                          	 */
/* Purpose      :   Used from AdminConsole Reports to remove suspension from a given ESN         */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   03-23-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/

      p_enrolled_objid    IN       VARCHAR2,
      p_merchant_ref_no   IN       VARCHAR2,
      p_user              IN       VARCHAR2,
      op_result           OUT      NUMBER,
      op_msg              OUT      VARCHAR2,
      op_case_number      OUT table_case.id_number%TYPE
   );


   PROCEDURE billing_de_enroll (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_de_enroll                                                     	 	 */
/*                                                                                          	 */
/* Purpose      :   Used from AdminConsole Reports to deenroll suspension from a given program   */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   03-23-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
      p_enrolled_objid    IN       VARCHAR2,
      p_merchant_ref_no   IN       VARCHAR2,
      p_user              IN       VARCHAR2,
      op_result           OUT      NUMBER,
      op_msg              OUT      VARCHAR2,
      op_case_number      OUT table_case.id_number%TYPE
   );


   PROCEDURE billing_close_case (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_close_case                                                   	 	 */
/*                                                                                          	 */
/* Purpose      :   Used from AdminConsole Reports to close case          from a given program   */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   03-23-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
      p_enrolled_objid    IN       VARCHAR2,
      p_merchant_ref_no   IN       VARCHAR2,
      p_user              IN       VARCHAR2,
      op_result           OUT      NUMBER,
      op_msg              OUT      VARCHAR2,
      op_case_number      OUT table_case.id_number%TYPE
   );


   FUNCTION billing_getnearestdeliverydate(
                       p_program_id        NUMBER,
                       p_delivery_date     DATE
                   )
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_de_enroll                                                     	 	 */
/*                                                                                          	 */
/* Purpose      :   Used from AdminConsole Reports to deenroll suspension from a given program   */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   03-23-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
   RETURN   DATE;


  FUNCTION billing_isvalidfundingSource (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_isvalidfundingSource                                             	 */
/*                                                                                          	 */
/* Purpose      :   Verifies if the funding source is still valid                                */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   03-23-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
      p_enroll_objid   IN       NUMBER,
      p_date_notified   IN       DATE               --- Date when the last notification was issued

   )
  RETURN  NUMBER;


  FUNCTION billing_ccActivity (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_ccActivity                                                       	 */
/*                                                                                          	 */
/* Purpose      :   Verifies if there has been any credit card activity                          */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   03-23-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
      p_enroll_objid            IN       NUMBER,
      p_last_trans_date         IN       DATE
   )
   RETURN NUMBER;

END billing_admin_console_notify;
/