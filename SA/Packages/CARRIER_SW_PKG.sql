CREATE OR REPLACE PACKAGE sa.carrier_sw_pkg
AS
/*******************************************************************************************************
  * --$RCSfile: carrier_sw_pkg.sql,v $
  --$Revision: 1.37 $
  --$Author: skota $
  --$Date: 2018/05/09 18:24:09 $
  --$ $Log: carrier_sw_pkg.sql,v $
  --$ Revision 1.37  2018/05/09 18:24:09  skota
  --$ Modified for the TF SL BI
  --$
  --$ Revision 1.36  2018/02/12 15:06:25  jcheruvathoor
  --$ CR52654	Short code for TMOBILE WFM
  --$
  --$ Revision 1.34  2017/10/16 18:55:18  mdave
  --$ CR54118 EME changes
  --$
  --$ Revision 1.33  2017/08/18 16:16:49  tpathare
  --$ New procedure to get the last bi trans.
  --$
  --$ Revision 1.32  2017/04/14 18:33:33  nsurapaneni
  --$ Merge with CR49101
  --$
  --$ Revision 1.29  2017/04/11 16:48:00  nsurapaneni
  --$ Added new function get_bucket_group to get the bucket group information
  --$
  --$ Revision 1.28  2017/01/12 17:17:08  smeganathan
  --$ CR46581 code changes to restrict bucket ids from BI result if the customer didnt purchase it
  --$
  --$ Revision 1.27  2017/01/12 16:06:20  smeganathan
  --$ CR46581 code changes to restrict bucket ids from BI result if the customer didnt purchase it
  --$
  --$ Revision 1.26  2017/01/05 19:37:52  smeganathan
  --$ CR46581 Merged with 1/5 prod release
  --$
  --$ Revision 1.25  2016/12/27 18:53:14  smeganathan
  --$ CR44729 code changes to get bucket usage and add inquiry type
  --$
  --$ Revision 1.22  2016/12/15 18:21:24  smeganathan
  --$ CR44729 merged with 12/15 prod release
  --$
  --$ Revision 1.17  2016/11/29 22:50:56  smeganathan
  --$ CR44729 Go smart Migration added new procs to overload Create Search Get BI transactions
  --$
  --$ Revision 1.16  2016/08/19 23:05:57  tbaney
  --$ CR40903 - Added new procedure to return balance usage.
  --$  * -------------------------------------------------------------------------------------------------
*********************************************************************************************************/
--
  PROCEDURE SP_GET_CURRENT_MTG(
      IP_ESN IN VARCHAR2 ,
      --, IP_BRAND IN VARCHAR2  ,
      out_cur OUT RETURN_MET_SOURCE_TBL,
      OP_ERR_CODE OUT VARCHAR2,
      OP_ERR_MSG OUT VARCHAR2 );
  PROCEDURE SP_GET_BALANCE(
      IP_TRANS_ID IN NUMBER,
      out_cur OUT RETURN_BUCKET_BAL_TBL,
      OP_ERR_CODE OUT VARCHAR2,
      OP_ERR_MSG OUT VARCHAR2 );
  PROCEDURE SP_GET_OP_SW_METERING(
      IP_ESN        IN VARCHAR2,
      IP_BRAND      IN VARCHAR2,
      IP_CARRIER_ID IN VARCHAR2,
      OP_SW_METERING OUT VARCHAR2 ,
      OP_MIGR_FLAG OUT VARCHAR2 ,
      OP_ERROR_CODE OUT INTEGER,
      OP_ERROR_MESSAGE OUT VARCHAR2);
  PROCEDURE SP_GET_BI_REQUIRED(
      IP_FROM_ESN IN VARCHAR2 ,
      IP_FROM_MIN IN VARCHAR2 ,
      IP_TO_ESN   IN VARCHAR2 ,
      IP_TO_SIM   IN VARCHAR2 ,
      IP_ACTION   IN VARCHAR2 ,
      IP_BRAND    IN VARCHAR2 ,
      IP_ZIP_CODE IN VARCHAR2 ,
      IP_SOURCE   IN VARCHAR2 ,
      OP_BI_REQUIRED OUT VARCHAR2 ,
      OP_GET_BAL_INFO OUT VARCHAR2,
      OP_CARRIER_TYPE OUT VARCHAR2,
      OP_ERR_CODE OUT VARCHAR2 ,
      OP_ERR_MSG OUT VARCHAR2,
	  IP_IS_UNIT_TRANSFER VARCHAR2 DEFAULT NULL); --CR54118, mdave 10/13/2017
  PROCEDURE CREATE_BI_TRANS(
      IP_ESN                         IN VARCHAR2 ,
      ip_voice_mtg_source            IN VARCHAR2 ,
      ip_voice_trans_id              IN VARCHAR2 ,
      ip_text_mtg_source             IN VARCHAR2 ,
      ip_text_trans_id               IN VARCHAR2 ,
      ip_data_mtg_source             IN VARCHAR2 ,
      ip_data_trans_id               IN VARCHAR2 ,
      ip_ild_mtg_source              IN VARCHAR2 ,
      ip_ild_trans_id                IN VARCHAR2 ,
      ip_trans_creation_date         IN DATE ,
      ip_X_TIMEOUT_MINUTES_THRESHOLD IN NUMBER ,
      ip_X_DAILY_ATTEMPTS_THRESHOLD  IN NUMBER ,
      OP_OBJID OUT NUMBER ,
      OP_ERR_CODE OUT VARCHAR2 ,
      OP_ERR_MSG OUT VARCHAR2 );
  PROCEDURE SEARCH_BI_TRANS(
      IP_ESN IN VARCHAR2 ,
      OP_LAST_TRANS_FLAG OUT VARCHAR2 ,
      OP_BI_COUNT OUT VARCHAR2 ,
      OP_TRANS_REC OUT typ_bi_trans_tbl ,
      OP_ERR_CODE OUT VARCHAR2 ,
      OP_ERR_MSG OUT VARCHAR2 ) ;
  PROCEDURE GET_BI_TRANS(
      IP_OBJID IN NUMBER ,
      OP_TRANS_REC OUT typ_bi_trans_tbl ,
      OP_ERR_CODE OUT VARCHAR2 ,
      OP_ERR_MSG OUT VARCHAR2 ) ;
  PROCEDURE SP_GET_BAL_CFG_ID(
      IP_ESN   IN VARCHAR2,
      IP_BRAND IN VARCHAR2,
      IP_CHL   IN VARCHAR2,
      OP_FLOW_ID OUT VARCHAR2,
      OP_SCRIPT_ID OUT VARCHAR2,
      OP_ERR_CODE OUT NUMBER,
      OP_ERR_MSG OUT VARCHAR2) ;
  PROCEDURE SP_GET_TARGET_MTG(
      IP_ESN            IN VARCHAR2,
      IP_BRAND          IN VARCHAR2 ,
      IP_DEVICE_GROUP   IN VARCHAR2 DEFAULT NULL,
      IP_DEVICE_TECH    IN VARCHAR2 DEFAULT NULL,
      IP_PART_CLASS     IN VARCHAR2 DEFAULT NULL,
      IP_CARRIER_ID     IN NUMBER ,
      IP_SER_PLAN_GROUP IN VARCHAR2 DEFAULT NULL,
      out_cur OUT return_tgt_mtg_src_tbl,
      op_error_code OUT VARCHAR2 ,
      op_error_message OUT VARCHAR2 );
PROCEDURE SP_GET_CURRENT_MTG_WRAPPER(
      IP_ESN              IN VARCHAR2 ,
      OP_VOICE_MTG_SOURCE OUT VARCHAR2,
      OP_SMS_MTG_SOURCE   OUT VARCHAR2,
      OP_DATA_MTG_SOURCE  OUT VARCHAR2,
      OP_ILD_MTG_SOURCE   OUT VARCHAR2,
      OP_ERR_CODE OUT NUMBER,
      OP_ERR_MSG OUT VARCHAR2);
PROCEDURE CREATE_BI_NOTIFICATION(
      IP_CLIENT_TRANS_ID  IN VARCHAR2,
      IP_CLIENT_ID        IN VARCHAR2,
      IP_ESN                IN VARCHAR2,
      IP_MIN                IN VARCHAR2,
     IP_BRAND              IN VARCHAR2,
      IP_SOURCE_SYSTEM      IN VARCHAR2,
      IP_BALANCE_TRANS_ID  IN VARCHAR2,
      IP_BALANCE_TRANS_DATE IN DATE,
      IP_NOTIFICATION_TYPE IN VARCHAR2,
      IP_RETRY_COUNT IN NUMBER,
      IP_STATUS IN VARCHAR2,
     IP_language  IN VARCHAR2,
      OP_OBJID  OUT NUMBER,
      OP_ERR_CODE OUT NUMBER,
      OP_ERR_MSG  OUT VARCHAR2
        );
PROCEDURE UPDATE_BI_NOTIFICATION(
      IP_OBJID       IN  NUMBER,
      IP_RETRY_COUNT  IN NUMBER,
      IP_STATUS       IN VARCHAR2,
      OP_ERR_CODE OUT NUMBER,
      OP_ERR_MSG  OUT VARCHAR2
    ) ;
PROCEDURE SEARCH_BI_NOTIFICATION(
       IP_CLIENT_TRANS_ID  IN VARCHAR2,
      IP_CLIENT_ID        IN VARCHAR2,
      IP_ESN      IN VARCHAR2,
      IP_BALANCE_TRANS_ID  IN VARCHAR2,
      IP_BALANCE_TRANS_DATE IN DATE,
      IP_NOTIFICATION_TYPE IN VARCHAR2,
       OP_OBJID  OUT NUMBER,
      OP_ERR_CODE OUT NUMBER,
      OP_ERR_MSG  OUT VARCHAR2
      ) ;
PROCEDURE CREATE_SWB_TRANSACTION (
  IP_CALL_TRANS       IN   VARCHAR2,
  IP_STATUS          IN VARCHAR2,
  IP_X_TYPE             IN VARCHAR2,
  IP_X_VALUE            IN VARCHAR2,
  IP_EXP_DATE           IN DATE,
  IP_RSID            IN VARCHAR2,
  OP_ERR_CODE        OUT NUMBER,
  OP_ERR_MSG         OUT VARCHAR2
  )  ;
PROCEDURE SP_GET_TARGET_MTG_WRAPPER(
    IP_ESN            IN VARCHAR2 ,
    IP_BRAND          IN VARCHAR2 ,
    IP_DEVICE_GROUP   IN VARCHAR2 DEFAULT NULL,
    IP_DEVICE_TECH    IN VARCHAR2 DEFAULT NULL,
    IP_PART_CLASS     IN VARCHAR2 DEFAULT NULL,
    IP_CARRIER_ID     IN NUMBER ,
    IP_SER_PLAN_GROUP IN VARCHAR2 DEFAULT NULL,
    OP_VOICE_MTG_SOURCE OUT NUMBER,
    OP_SMS_MTG_SOURCE OUT NUMBER,
    OP_DATA_MTG_SOURCE OUT NUMBER,
    OP_ILD_MTG_SOURCE OUT NUMBER,
    OP_ERR_CODE OUT NUMBER,
    OP_ERR_MSG OUT VARCHAR2);

PROCEDURE get_meter_sources ( i_esn               IN  VARCHAR2 ,
                              o_meter_sources     OUT meter_source_tab,
                              o_err_code          OUT VARCHAR2,
                              o_err_msg           OUT VARCHAR2,
                              i_source_system     IN  VARCHAR2 DEFAULT NULL); -- CR46475
--
PROCEDURE get_meter_sources ( i_esn               IN  VARCHAR2      ,
                              o_meter_sources_rc  OUT SYS_REFCURSOR ,
                              o_err_code          OUT VARCHAR2      ,
                              o_err_msg           OUT VARCHAR2 );
--
-- overloaded method to return the metering sources in a ref cursor
PROCEDURE get_meter_sources ( i_esn               IN  VARCHAR2      ,
                              i_source_system     IN  VARCHAR2      , -- CR46475
                              o_meter_sources_rc  OUT SYS_REFCURSOR ,
                              o_err_code          OUT VARCHAR2      ,
                              o_err_msg           OUT VARCHAR2      );
--
PROCEDURE SP_GET_USAGE_BY_TRANS(
    IP_TRANS_ID IN NUMBER,
    out_cur OUT RETURN_BUCKET_BAL_TBL,
    OP_ERR_CODE OUT VARCHAR2,
    OP_ERR_MSG OUT VARCHAR2 );
--
PROCEDURE SP_GET_SL_PPE_SW (
   ip_esn              IN     VARCHAR2,
   ip_brand            IN     VARCHAR2,
   ip_device_group     IN     VARCHAR2 DEFAULT NULL,
   ip_device_tech      IN     VARCHAR2 DEFAULT NULL,
   ip_part_class       IN     VARCHAR2 DEFAULT NULL,
   ip_carrier_id       IN     NUMBER,
   ip_ser_plan_group   IN     VARCHAR2 DEFAULT NULL,
   v_voice_mtg_source     OUT VARCHAR2,
   op_error_code          OUT VARCHAR2,
   op_error_message       OUT VARCHAR2);
-- CR44729 changes starts..
-- Overloaded method to store the BI transactions
PROCEDURE create_bi_trans (
                    ip_esn                         IN   VARCHAR2 ,
                    ip_inquiry_type                IN   VARCHAR2 ,
                    ip_bi_mtg_src_tab              IN   bi_mtg_src_tab,
                    ip_trans_creation_date         IN   DATE ,
                    op_objid                       OUT  NUMBER ,
                    op_err_code                    OUT  VARCHAR2 ,
                    op_err_msg                     OUT  VARCHAR2 );
--
-- Overloaded method to search the BI transactions
PROCEDURE search_bi_trans (
                    ip_esn              IN  VARCHAR2 ,
                    op_last_trans_flag  OUT VARCHAR2 ,
                    op_bi_count         OUT VARCHAR2 ,
                    op_trans_tab        OUT bi_mtg_trans_tab ,
                    op_err_code         OUT VARCHAR2 ,
                    op_err_msg          OUT VARCHAR2);
--
-- Overloaded method to get the BI transactions
PROCEDURE get_bi_trans(
                    ip_objid        IN    NUMBER ,
                    op_trans_tab    OUT   bi_mtg_trans_tab ,
                    op_err_code     OUT   VARCHAR2 ,
                    op_err_msg      OUT   VARCHAR2 );
-- Overloaded method to get the Bucket balance and usage
PROCEDURE sp_get_balance_usage(
                    ip_trans_id     IN    NUMBER,
                    out_cur         OUT   bucket_balance_usage_tab,
                    op_err_code     OUT   VARCHAR2,
                    op_err_msg      OUT   VARCHAR2 );
-- function to get bucket ids that are not needed to return the balance / usage
FUNCTION f_skip_bucket_ids  (i_calltrans_id    IN  NUMBER)
RETURN  bucket_id_tab DETERMINISTIC;
-- CR44729 changes ends.
-- CR47564 WFM changes start
FUNCTION get_bucket_group ( i_bucket_id        IN VARCHAR2 ,
                            i_call_trans_objid IN NUMBER   ) RETURN VARCHAR2 DETERMINISTIC;
-- CR47564 WFM changes end

FUNCTION calculate_usage ( i_call_trans_id  IN NUMBER   ,
                           i_bucket_value   IN VARCHAR2 ,
                           i_bucket_balance IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC;

-- CR48846 - get the last bi transaction log row for a given esn or min
PROCEDURE get_last_bi_trans ( i_esn               IN  VARCHAR2 ,
                              i_min               IN  VARCHAR2 ,
                              o_bi_transaction_id OUT NUMBER   ,
                              o_response          OUT VARCHAR2 );
--CR52654
PROCEDURE UPDATE_CUSTOMER_COMM_STG( IP_OBJID        IN  NUMBER,
                                    IP_RETRY_COUNT  IN NUMBER,
                                    IP_STATUS       IN VARCHAR2,
	                                  IP_ERROR_MSG    IN VARCHAR2,
                                    OP_ERR_CODE     OUT NUMBER,
                                    OP_ERR_MSG      OUT VARCHAR2 ) ;
-- CR55583
FUNCTION tf_sl_service_end_dt ( i_esn IN VARCHAR2) RETURN DATE;
END carrier_sw_pkg;
/