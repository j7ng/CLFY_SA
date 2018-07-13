CREATE OR REPLACE PACKAGE sa."BILLING_RULE_ADMIN_PKG"
IS
   PROCEDURE billing_rule_version
   (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_rule_version													 	 */
/*                                                                                          	 */
/* Purpose      :   Rule version																			 */
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
   p_user in NUMBER, op_result OUT NUMBER, op_msg OUT VARCHAR2);

   PROCEDURE billing_version_rollback (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_version_rollback											 	 	 */
/*                                                                                          	 */
/* Purpose      :   Rule rollback																			 */
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
      p_version_no   IN       NUMBER,
	  p_user         in       NUMBER,
      op_result      OUT      NUMBER,
      op_msg         OUT      VARCHAR2
   );

   PROCEDURE billing_rule_clean
   (
/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   billing_rule_clean													 	 	 */
/*                                                                                          	 */
/* Purpose      :   Cleaning production																			 */
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
   op_result OUT NUMBER, op_msg OUT VARCHAR2);
END billing_rule_admin_pkg;
/