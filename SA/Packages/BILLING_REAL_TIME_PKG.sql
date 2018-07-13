CREATE OR REPLACE PACKAGE sa."BILLING_REAL_TIME_PKG"
AS
   PROCEDURE realtime_create_proc (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   realtime_create_proc												 	 	 */
/*                                                                                          	 */
/* Purpose      :   Realtime xml creation 														 */
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
      i_process_date   IN       DATE,
      i_input_xml      IN       VARCHAR2,
      i_output_xml     IN       VARCHAR2,
      i_status         IN       VARCHAR2,
      i_last_updated   IN       DATE,
      o_seq_id1        OUT      NUMBER,
      o_err_num        OUT      NUMBER,
      o_err_msg        OUT      VARCHAR2
   );

   l_seq_num   x_payment_real_time.seq_id%TYPE;

   PROCEDURE realtime_update_proc (

/*************************************************************************************************/
/*                                                                                          	 */
/* Name         :   realtime_update_proc												 	 	 */
/*                                                                                          	 */
/* Purpose      :   Realtime xml update															 */
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
      i_seq_id         IN       NUMBER,
      i_output_xml     IN       VARCHAR2,
      i_status         IN       VARCHAR2,
      i_last_updated   IN       DATE,
      o_err_num        OUT      NUMBER,
      o_err_msg        OUT      VARCHAR2
   );
END billing_real_time_pkg;
/