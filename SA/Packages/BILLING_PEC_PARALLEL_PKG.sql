CREATE OR REPLACE PACKAGE sa."BILLING_PEC_PARALLEL_PKG"
IS
   PROCEDURE de_enroll_old_prog (

/*************************************************************************************************/
/*                                                                                               */
/* Name         :   de_enroll_old_prog                                                           */
/*                                                                                               */
/* Purpose      :   De-enroll old programs                                                       */
/*                                                                                               */
/*                                                                                               */
/* Platforms    :   Oracle 9i                                                                    */
/*                                                                                               */
/* Author       :   RSI                                                                          */
/*                                                                                               */
/* Date         :   01-19-2006                                                                   */
/*                                                                                               */
/* REVISIONS:                                                                                    */
/* VERSION  DATE        WHO          PURPOSE                                                     */
/* -------  ---------- 	-----  		 --------------------------------------------                */
/*  1.0                       		 Initial  Revision                                           */
/*                                                                                               */
/*                                                                                               */
/*************************************************************************************************/
      p_esn       IN       VARCHAR2,
      op_result   OUT      NUMBER,
      op_msg      OUT      VARCHAR2
   );
END billing_pec_parallel_pkg;
/