CREATE OR REPLACE PACKAGE sa."BILLING_INSERTS_PKG"
IS
/*************************************************************************************************/
/* 	 */
/* Name : SA.billing_inserts_pkg 	 	 */
/* 	 */
/* Purpose : Inserts into tables (Auto Refill flow)			 		 */
/* 	 */
/* 	 */
/* Platforms : Oracle 10g 				 */
/* 	 */
/* Author : SKuthadi 	 			 */
/* 	 */
/* Date : 10-27-2009									 */
/* REVISIONS: 		 */
/* VERSION DATE WHO PURPOSE 					 */
/* ------- ---------- 	----- 	 -------------------------------------------- 		 */
/* 1.0 11/02/09 SKuthadi Initial Revision 		 */
/*
* Description: New procedure added for CR22623
* Created by: cpannala
* Date: 12/03/2013
-----------------------------------------------------------------------------------------------------
* 12/03/2013 cpannala CR22623

/*************************************************************************************************/
PROCEDURE inserts_billing_proc (
 ip_esn IN VARCHAR2,
 ip_pgm_param_objid IN NUMBER,
 ip_web_user_objid IN NUMBER,
 ip_payment_src_objid IN NUMBER,
 ip_next_charge_date IN DATE,
 ip_sourcesystem IN VARCHAR2,
 op_result OUT NUMBER, -- Output Result
 op_msg OUT VARCHAR2, -- Output Message
 ip_enrollment_status IN VARCHAR2 default null,
 --CR43498 DATA CLUB
 ip_dataclub_flag IN VARCHAR2 DEFAULT 'N',
 ip_dealer_id IN VARCHAR2 DEFAULT NULL, --CR 44929
 ip_partner_name IN VARCHAR2 DEFAULT NULL --- CR48480 Partner name ex: AMAZON WEB ORDERS, Best Buy, Ebay
 );
 --CR49058 Overloading inserts_billing_proc procedure to add the o_program_enrol_objid output variable.
 PROCEDURE inserts_billing_proc ( ip_esn                 IN  VARCHAR2                  ,
                                  ip_pgm_param_objid     IN  NUMBER                    ,
                                  ip_web_user_objid      IN  NUMBER                    ,
                                  ip_payment_src_objid   IN  NUMBER                    ,
                                  ip_next_charge_date    IN  DATE                      ,
                                  ip_sourcesystem        IN  VARCHAR2                  ,
                                  op_result              OUT NUMBER                    ,
                                  op_msg                 OUT VARCHAR2                  ,
                                  ip_enrollment_status   IN  VARCHAR2 DEFAULT NULL     ,
                                  ip_dataclub_flag       IN  VARCHAR2 DEFAULT 'N'      ,
                                  ip_dealer_id           IN  VARCHAR2 DEFAULT NULL     ,
                                  ip_partner_name        IN  VARCHAR2 DEFAULT NULL     ,
								                  o_program_enroll_objid OUT NUMBER                    );



 --CR48643
FUNCTION get_purch_history_for_device(
  i_esn  IN  VARCHAR2
 ,i_min  IN  VARCHAR2
)
RETURN sys_refcursor;
END billing_inserts_pkg;
/