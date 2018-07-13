CREATE OR REPLACE PACKAGE sa."WALMART_MONTHLY_PLANS_PKG" AS
/******************************************************************************/
/*    Copyright   2009 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         WALMART_MONTHLY_PLANS_PKG                                          */
/* PURPOSE:      WALMART_MONTHLY_PLANS Straight Talk SUREPAY                                       */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 9.2.0.7 AND newer versions.                             */
/*                                                                            */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO          PURPOSE                                  */
/* -------  ---------- -----  ---------------------------------------------   */
/*  1.0   04/24/2009   CLindner    Initial  Revision                               */

PROCEDURE run_all_no_ap
   (p_div IN NUMBER DEFAULT 1 ,
    p_rem IN NUMBER DEFAULT 0);

PROCEDURE run_single ( p_transaction_id        IN NUMBER ,
                       i_skip_pcrf_update_flag IN VARCHAR2 DEFAULT 'N' );

PROCEDURE sp_set_zero_out_max ( in_call_trans_objid IN  table_x_call_trans.objid%TYPE,
                                in_esn              IN  ig_transaction.esn%TYPE,
                                in_order_type       IN  ig_transaction.order_type%TYPE,
                                in_ig_trans_id      IN  ig_transaction.transaction_id%TYPE,
                                in_ig_rate_plan     IN  ig_transaction.rate_plan%TYPE,
                                out_errorcode       OUT NUMBER,
                                out_errormsg        OUT VARCHAR2);

FUNCTION Isnumber (p_num VARCHAR2)  RETURN NUMBER;

END;
/