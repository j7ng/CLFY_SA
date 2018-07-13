CREATE OR REPLACE PACKAGE sa.FOTA_SERVICE_PKG
AS
/*************************************************************************************************************************************
  * $Revision: 1.5 $
  * $Author: oimana $
  * $Date: 2017/07/10 15:59:18 $
  * $Log: FOTA_SERVICE_PKG.SQL,v $
  * Revision 1.5  2017/07/10 15:59:18  oimana
  * CR48183 - FOTA Campaign Model - Change in Package criteria to use new table ADFCRM_FOTA_PC_PARAMS
  *
  * Revision 1.4  2016/10/18 19:48:31  rpednekar
  * CR43254 - Initial version
  *
  *************************************************************************************************************************************/

 PROCEDURE PROCESS_FOTA_CAMP_TRANS (ip_transaction_id   IN VARCHAR2
                                   ,ip_call_trans_objid IN NUMBER
                                   ,op_err_code         OUT VARCHAR2
                                   ,op_err_msg          OUT VARCHAR2);

 PROCEDURE CREATE_IG_FOR_FOTA (p_action_item_objid IN NUMBER
                              ,ip_fota_camp_name   IN VARCHAR2
                              ,op_error_code       OUT VARCHAR2
                              ,op_error_msg        OUT VARCHAR2);

/*
 PROCEDURE get_make_model (pi_esn    IN VARCHAR2,
                           po_make   OUT VARCHAR2,
                           po_model  OUT VARCHAR2,
                           po_tech   OUT VARCHAR2,
                           po_found  OUT BOOLEAN);
*/

END FOTA_SERVICE_PKG;
/