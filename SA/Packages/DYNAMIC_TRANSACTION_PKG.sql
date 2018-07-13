CREATE OR REPLACE PACKAGE sa.dynamic_transaction_pkg
AS
/*************************************************************************************************/
/*    Copyright   2014 Tracfone  Wireless Inc. All rights reserved                            	 */
/*                                                                                            	 */
/* NAME:         dynamic_transaction_pkg                                                         */
/* PURPOSE:      Package to get dynamic transaction summary for given set of records             */
/* FREQUENCY:                                                                                 	 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                             	 */
/*                                                                                            	 */
/* REVISIONS:                                                                                 	 */
/* VERSION  DATE        WHO        PURPOSE                                                       */
/* -------  ---------- -----       --------------------------------------------------------------*/
/*  1.0     01/23/2017 sgangineni  CR47564 - Package to ge the dynamic transactions summary for  */
/*                                 given set of records                                          */
/*************************************************************************************************/

   /**********************************************************************************************/
   /*    Copyright   2014 Tracfone  Wireless Inc. All rights reserved                            */
   /*                                                                                            */
   /* NAME:         DYNAMIC_TRANSACTION_SUMMARY                                                  */
   /* PURPOSE:      To return dynamic transaction summary details for a single record input      */
   /* FREQUENCY:                                                                                 */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                             */
   /*                                                                                            */
   /* REVISIONS:                                                                                 */
   /* VERSION  DATE       WHO         PURPOSE                                                    */
   /* -------  ---------- -----       -----------------------------------------------------------*/
   /*  1.0     02/02/2017 sgangineni  CR47564 - To return dynamic transaction summary details for*/
   /*                                 a single record input                                      */
   /**********************************************************************************************/
   PROCEDURE DYNAMIC_TRANSACTION_SUMMARY (p_source_system               IN    dynamic_trans_sum_params.source_system%TYPE,
                                          p_brand                       IN    dynamic_trans_sum_params.brand_name%TYPE,
                                          p_language                    IN    dynamic_trans_sum_params.language%TYPE DEFAULT 'ENG',
                                          p_esn                         IN    table_part_inst.part_serial_no%TYPE,
                                          p_transaction_type            IN    dynamic_trans_sum_params.transaction_type%TYPE,
                                          p_retention_type              IN    dynamic_trans_sum_params.retention_type%TYPE,
                                          p_program_id                  IN    x_program_enrolled.pgm_enroll2pgm_parameter%TYPE,
                                          p_acc_num_name_reg_name       IN    dynamic_trans_sum_params.param_name%TYPE,
                                          p_acc_num_name_10_dollar_name IN    dynamic_trans_sum_params.param_name%TYPE,
                                          p_reactivation_flag           IN    VARCHAR2 DEFAULT 'FALSE',
                                          p_confirmation_message        OUT   dynamic_trans_sum_params.param_value%TYPE,
                                          p_transaction_script          OUT   dynamic_trans_sum_params.param_value%TYPE,
                                          p_expire_dt                   OUT   DATE,
                                          p_next_refill_date            OUT   DATE,
                                          p_acc_num_name_reg            OUT   dynamic_trans_sum_params.param_value%TYPE,
                                          p_acc_num_name_10_dollar      OUT   dynamic_trans_sum_params.param_value%TYPE,
                                          p_cards_in_reserve            OUT   INTEGER,
                                          p_more_info                   OUT   dynamic_trans_sum_params.param_value%TYPE,
                                          p_device_name                 OUT   table_x_contact_part_inst.x_esn_nick_name%TYPE,
                                          p_group_id                    OUT   x_account_group_member.account_group_id%TYPE,
                                          p_group_name                  OUT   x_account_group.account_group_name%TYPE,
                                          p_err_code                    OUT   NUMBER,
                                          p_err_msg                     OUT   VARCHAR2
                                         );

   /*****************************************************************************************************/
   /*    Copyright  2014 Tracfone  Wireless Inc. All rights reserved                                    */
   /*                                                                                                   */
   /* NAME:         GET_DYNAMIC_TRANS_SUMMARY                                                           */
   /* PURPOSE:      To return dynamic transaction summary details in array                              */
   /* FREQUENCY:                                                                                        */
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                                    */
   /*                                                                                                   */
   /* REVISIONS:                                                                                        */
   /* VERSION  DATE        WHO         PURPOSE                                                          */
   /* -------  ----------  -----       -----------------------------------------------------------------*/
   /*  1.0     01/23/2017  sgangineni  CR47564 - To return dynamic transaction summary details in array */
   /*****************************************************************************************************/
   PROCEDURE get_dynamic_trans_summary (io_dynamic_trans_sum_tbl  IN OUT GET_DYNAMIC_TRANS_SUMMARY_TAB,
                                       o_err_code                 OUT VARCHAR2,
                                       o_err_msg                  OUT VARCHAR2);

  /***************************************************************************************************/
  /*   Copyright   2014 Tracfone  Wireless Inc. All rights reserved                                  */
  /*                                                                                                 */
  /* NAME:         GET_ESN_QUEUED_CARD_DAYS                                                          */
  /* PURPOSE:      To return the total no of days for all the queued cards of given ESN/MINs         */
  /* FREQUENCY:                                                                                      */
  /* PLATFORMS:    Oracle 8.0.6 AND newer versions.                                                  */
  /*                                                                                                 */
  /* REVISIONS:                                                                                      */
  /* VERSION  DATE       WHO         PURPOSE                                                         */
  /* -------  ---------- -----       ----------------------------------------------------------------*/
  /*  1.0     05/04/2017 sgangineni  CR49721 To return queued card days of multiple ESNs in array    */
  /***************************************************************************************************/
  PROCEDURE GET_ESN_QUEUED_CARD_DAYS (io_esn_min_queue_card_det_tbl  IN OUT   esn_min_queue_card_det_tab,
                                      o_err_code                        OUT   VARCHAR2,
                                      o_err_msg                         OUT   VARCHAR2);

PROCEDURE get_dynamic_transaction(
    i_source_system               IN dynamic_trans_sum_params.source_system%TYPE,
    i_brand                       IN dynamic_trans_sum_params.brand_name%TYPE,
    i_language                    IN dynamic_trans_sum_params.language%TYPE DEFAULT 'ENG',
    i_esn                         IN table_part_inst.part_serial_no%TYPE,
    i_transaction_type            IN dynamic_trans_sum_params.transaction_type%TYPE,
    i_retention_type              IN dynamic_trans_sum_params.retention_type%TYPE,
    i_program_id                  IN x_program_enrolled.pgm_enroll2pgm_parameter%TYPE,
    i_acc_num_name_reg_name       IN dynamic_trans_sum_params.param_name%TYPE,
    i_acc_num_name_10_dollar_name IN dynamic_trans_sum_params.param_name%TYPE,
    i_reactivation_flag           IN VARCHAR2 DEFAULT 'FALSE',
    o_confirmation_message OUT dynamic_trans_sum_params.param_value%TYPE,
    o_transaction_script OUT dynamic_trans_sum_params.param_value%TYPE,
    o_expire_dt OUT DATE,
    o_next_refill_date OUT DATE,
    o_acc_num_name_reg OUT dynamic_trans_sum_params.param_value%TYPE,
    o_acc_num_name_10_dollar OUT dynamic_trans_sum_params.param_value%TYPE,
    o_cards_in_reserve OUT INTEGER,
    o_more_info OUT dynamic_trans_sum_params.param_value%TYPE,
    o_device_name OUT table_x_contact_part_inst.x_esn_nick_name%TYPE,
    o_group_id OUT x_account_group_member.account_group_id%TYPE,
    o_group_name OUT x_account_group.account_group_name%TYPE,
    o_forecast_date OUT DATE,
    o_next_refill_date_hpp OUT DATE);
END dynamic_transaction_pkg;
-- ANTHILL_TEST PLSQL/SA/Packages/DYNAMIC_TRANSACTION_PKG.sql 	CR53217: 1.6

-- ANTHILL_TEST PLSQL/SA/Packages/DYNAMIC_TRANSACTION_PKG.sql 	CR53217: 1.7
/