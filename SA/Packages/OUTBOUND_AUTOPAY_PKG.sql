CREATE OR REPLACE PACKAGE sa."OUTBOUND_AUTOPAY_PKG" AS
/******************************************************************************/
/*    Copyright  2002 Tracfone  Wireless Inc. All rights reserved             */
/*                                                                            */
/* NAME:         OUTBOUND_AUTOPAY_PKG (SPECIFICATION)                         */
/* PURPOSE:      This package picks up the ESN subscribed for Autopay and     */
/*		 Hybrid Pre/Post Paid Program and send it to Princeton eCom           */
/*		 for deducting monthly fee                                            */
/* FREQUENCY:    Every Day                                              */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/*                                                                            */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO          PURPOSE                                  */
/* -------  ---------- -----  ---------------------------------------------   */
/*  1.0     06/14/2002 TCS           Initial  Revision                        */
/*                                                                            */
/******************************************************************************/
/******************************************************************************/
/*                                                                            */
/* Name:    FETCH AHP_ESN_PRC                                                 */
/* Objective  : get the APP/HPP subscribed ESN from TABLE_X_AUTOPAY_DETAILS   */
/*                                                                            */
/* In Parameters : p_date default sysdate                                    */
/* Out Parameters :                                                           */
/*                                                                            */
/*                                                                            */
/* Assumption:                                                                */
/******************************************************************************/
  PROCEDURE FETCH_AHP_ESN_PRC(p_date IN DATE);
/******************************************************************************/
/*                                                                            */
/* Name:    get_amount_fun                                                    */
/* Objective  : To get the monthly fee for the Autopay program and            */
/*               Hybrid Pre/Post paid program                                 */
/* In Parameters :  p_prg_type NUMBER                                        */
/* Out Parameters :                                                           */
/*                                                                            */
/*                                                                            */
/* Assumption:                                                                */
/******************************************************************************/
  FUNCTION get_amount_fun(p_prg_type NUMBER) RETURN NUMBER;
/******************************************************************************/
/*                                                                            */
/* Name:    validateESN_fun                                                   */
/* Objective  : check whether the ESN is active                               */
/*                                                                            */
/* In Parameters : p_esn VARCHAR2                                            */
/* Out Parameters :  TRUE -- valid ESN                                        */
/*		     	  	 FALSE -- Invalid ESN                                     */
/*                                                                            */
/*                                                                            */
/* Assumption:                                                                */
/******************************************************************************/
  FUNCTION validateESN_fun(p_esn VARCHAR2) RETURN BOOLEAN;
/******************************************************************************/
/*                                                                             */
/* Name:    INSERT_CALL_TRANS_PRC                                              */
/* Objective : To insert a record into table_x_call_trans for Monthly Payments */
/*                                                                             */
/* In Parameters : p_esn ESN                                                   */
/*   	  		   p_action_type (84) monthly Payments                 */
/*  			   p_source                                            */
/*			       p_action_text ,monthly Payments							   */
/*			       p_reason,	  		   									   */
/*			       p_result PENDING										   */
/* Out Parameters :                                                           */
/*                                                                            */
/*                                                                            */
/* Assumption:                                                                */
/******************************************************************************/
  PROCEDURE   INSERT_CALL_TRANS_PRC(
  			  p_esn VARCHAR2,
			  p_action_type VARCHAR2,
			  p_source VARCHAR2,
			  p_action_text VARCHAR2,
			  p_reason VARCHAR2,
			  p_result VARCHAR2);
/******************************************
 * Function : get_user_objid
 * Purpose  : get user Object Id
 * IN: varchar2
 * OUT: number  -- objid
 *******************************************/
FUNCTION get_user_objid_fun(p_login_name varchar2) return number;
  /*************************************************************************
   * Procedure: INSERT_CALL_TRANS
   * Purpose  : To Insert Record into TABLE_X_CALL_TRANS
   **************************************************************************/
   PROCEDURE INSERT_CALL_TRANS_prc(
  			    p_accountNumber Varchar2,
  			    p_act_type Varchar2,
  			    p_ls Varchar2,
  			    p_action_t Varchar2,
  			    p_Reason Varchar2,
  			    p_res   Varchar2,
  			    p_msgs OUT Varchar2,
  			    c_p_statusss OUT Varchar2
  			    );
/*************************************************************************
 * Procedure: DEACTIVE_PROGRAM
 * Purpose  : Scan through all the autopay promotions for the ESN,
 *            If Payment Not Success then DoBillerNote Procedure call this
 *            Procedure to remove from Program.
 **************************************************************************/
PROCEDURE DEACTIVE_PROGRAM_prc
  			   (
  			     p_accountNumber varchar2,
  			     p_name varchar2,
  			     p_msgs OUT varchar2,
  			     c_p_statuss OUT varchar2
  			   );
END Outbound_Autopay_Pkg;

/