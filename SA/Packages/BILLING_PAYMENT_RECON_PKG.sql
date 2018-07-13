CREATE OR REPLACE PACKAGE sa."BILLING_PAYMENT_RECON_PKG"
IS
   PROCEDURE payment_hdr_update (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   payment_hdr_update													 	 	 */
/*                                                                                          	 */
/* Purpose      :   Payment header update														 */
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
      p_batch_objid            IN       NUMBER, --
      p_merchant_ref_number    IN       VARCHAR2, --
      p_ics_rcode              IN       VARCHAR2, --
      p_ics_rflag              IN       VARCHAR2, --
      p_ics_rmsg               IN       VARCHAR2, --
      p_request_id             IN       VARCHAR2, --
      p_auth_avs               IN       VARCHAR2, -- CC
      p_auth_response          IN       VARCHAR2, --
      p_auth_time              IN       VARCHAR2, --
      p_auth_rcode             IN       NUMBER, --
      p_auth_rflag             IN       VARCHAR2, --
      p_auth_rmsg              IN       VARCHAR2, --
      p_bill_request_time      IN       VARCHAR2, --
      p_bill_rcode             IN       NUMBER, --
      p_bill_rflag             IN       VARCHAR2, --
      p_bill_rmsg              IN       VARCHAR2, --
      p_bill_trans_ref_no      IN       VARCHAR2, --
      p_auth_amount            IN       NUMBER, --
      p_bill_amount            IN       NUMBER, --
      p_ecp_debit_request_id   IN       VARCHAR2, -- ACH
      p_ecp_debit_avs          IN       X_ACH_PROG_TRANS.x_ecp_debit_avs%TYPE, -- ACH
      p_ecp_debit_avs_raw      IN       X_ACH_PROG_TRANS.x_ecp_debit_avs_raw%TYPE, -- ACH
      p_ecp_rcode              IN       X_ACH_PROG_TRANS.x_ecp_rcode%TYPE, -- ACH
      p_ecp_trans_id           IN       X_ACH_PROG_TRANS.x_ecp_trans_id%TYPE, -- ACH
      p_ecp_result_code        IN       X_ACH_PROG_TRANS.x_ecp_result_code%TYPE, -- ACH
      p_ecp_rflag              IN       X_ACH_PROG_TRANS.x_ecp_rflag%TYPE, -- ACH
      p_ecp_rmsg               IN       X_ACH_PROG_TRANS.x_ecp_rmsg%TYPE, -- ACH
      p_auth_cv_result         IN       VARCHAR2, -- cc
      p_ecpdebit_ref_number    IN       X_ACH_PROG_TRANS.x_ecp_debit_ref_number%TYPE, -- ACH   this input need to be updated in purchase hdr
      p_auth_code              IN       VARCHAR2, -- CC Auth Code
      op_result                OUT      NUMBER, --
      op_msg                   OUT      VARCHAR2 --

   );

 Procedure Payment_Hdr_Success(
 /*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   payment_hdr_success												 	 		 */
/*                                                                                          	 */
/* Purpose      :   payment successful job														 */
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
/*                                       SOA PROJECT                                                   	 */
/*************************************************************************************************/
      p_batch_objid IN NUMBER,
      p_hdr_objid IN NUMBER,
      op_result OUT NUMBER,
      op_msg OUT VARCHAR2
   );

   PROCEDURE payment_hdr_success (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   payment_hdr_success												 	 		 */
/*                                                                                          	 */
/* Purpose      :   payment successful job														 */
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
/*  1.0                       		 Initial  Revision                              			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
     p_batch_objid   IN       NUMBER,
     op_result       OUT      NUMBER,
     op_msg          OUT      VARCHAR2
  );

   FUNCTION get_next_cycle_date (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   get_next_cycle_date													 	 	 */
/*                                                                                          	 */
/* Purpose      :   Get next payment cycle date													 */
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
      p_prog_param_objid     IN   NUMBER,
      p_current_cycle_date   IN   DATE
   )
      RETURN DATE;

   PROCEDURE ach_recon
   (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   ach_recon													 	 			 */
/*                                                                                          	 */
/* Purpose      :   ACH reconciliation job														 */
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
   op_code OUT NUMBER, op_result OUT VARCHAR2);




   FUNCTION payment_log (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   payment_log													 	 			 */
/*                                                                                          	 */
/* Purpose      :   Logging function for payment    											 */
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
      p_purch_hdr_objid      IN   x_program_purch_hdr.objid%TYPE,
      p_submission_flag      IN   NUMBER default 0
     )
      RETURN VARCHAR2;

   PROCEDURE computeDeliveryPendEnrollment(
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   computeDeliveryPendEnrollment												 */
/*                                                                                          	 */
/* Purpose      :   Computes the next delivery date, expiry date for pending enrollments         */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   08-26-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
                p_enrollObjid           NUMBER,
                p_delivery_frq_code     VARCHAR2,
                p_is_recurring          NUMBER,
                p_benefit_days          NUMBER
  );


FUNCTION get_primary_cycle_date (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   get_primary_cycle_date      											     */
/*                                                                                          	 */
/* Purpose      :   Computes the next cycle date for primary enrollment                          */
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
      p_prog_enroll_objid     IN   NUMBER
   )
   RETURN DATE;

   FUNCTION get_next_cycle_date_deact (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   get_next_cycle_date_deact      											     */
/*                                                                                          	 */
/* Purpose      :   Used for deactivation protection/low balance programs.                       */
/*                        Only for ACH                                                           */
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
      p_prog_param_objid     IN   NUMBER,
      p_current_cycle_date   IN   DATE
   )
      RETURN DATE;


   FUNCTION haveBenefitsAlreadyDelivered (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   haveBenefitsAlreadyDelivered      							       		     */
/*                                                                                           	 */
/* Purpose      :   Check if the benefits have already been delivered as part of the ACH         */
/*                   Verification and Validation Success.                                        */
/*                        Only for ACH                                                           */
/*                                                                                          	 */
/*                                                                                          	 */
/* Platforms    :   Oracle 9i                                                    				 */
/*                                                                                          	 */
/* Author       :   RSI                                                            	  			 */
/*                                                                                          	 */
/* Date         :   05-24-2006																	 */
/* REVISIONS:                                                         							 */
/* VERSION  DATE        WHO          PURPOSE                                  					 */
/* -------  ---------- 	-----  		 --------------------------------------------   			 */
/*  1.0                       		 Initial  Revision                               			 */
/*                                                                                          	 */
/*                                                                                          	 */
/*************************************************************************************************/
      p_enroll_objid      IN   x_program_enrolled.objid%TYPE
   )
      RETURN NUMBER;         -- Return the benefits status
END billing_payment_recon_pkg;
/