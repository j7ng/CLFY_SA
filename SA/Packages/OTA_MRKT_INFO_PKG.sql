CREATE OR REPLACE PACKAGE sa."OTA_MRKT_INFO_PKG" IS
  /************************************************************************************************
  |    Copyright   Tracfone  Wireless Inc. All rights reserved
  |
  | NAME     :     ota_mrkt_info_pkg
  | PURPOSE  :
  | FREQUENCY:
  | PLATFORMS:     Oracle 8.1.7 and above
  |
  | REVISIONS:
  | VERSION  DATE        WHO              PURPOSE
  | -------  ---------- -----             ------------------------------------------------------
  | 1.0      12/01/04   Novak Lalovic     Initial creation
  | 1.1      06/27/05   Shaowei Luo       Added new OUT parameter p_ota_trans_objid to the procedures
  |                                       send_psms and send_psms_inq
  | 1.2      08/08/05  Novak Lalovic      Modification:
  |                                       Procedure: send_psms_inq
  |                                       Added optional numeric parameter p_x_counter to the procedure.
  |                                       It defaults to NULL if the value is not passed from the calling program.
  | 1.3      09/26/06  Vani Adapa        CR5613 OTA Enhancements
  | 1.4      11/08/06  Vani Adapa        CR5613
  | 1.5      03/08/13  Yrielis millan     CR22452
  ************************************************************************************************/
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: OTA_MRKT_INFO_PKG.sql,v $
  --$Revision: 1.12 $
  --$Author: smacha $
  --$Date: 2017/07/19 18:18:13 $
  --$ $Log: OTA_MRKT_INFO_PKG.sql,v $
  --$ Revision 1.12  2017/07/19 18:18:13  smacha
  --$ Added procedure to get the next BYOP SMS staging for Bulk processing.
  --$
  --$ Revision 1.10  2016/10/31 18:40:52  rpednekar
  --$ CR42899 - New parameter added to procedure get_next_byop_sms_stg. Merged.
  --$
  --$ Revision 1.7  2016/10/19 15:02:25  ddudhankar
  --$ CR44787 - added p_forecast_date OUT parameter to PROCEDURE get_next_byop_sms_stg
  --$
  --$ Revision 1.6  2016/09/06 18:53:14  ddudhankar
  --$ CR44652 - NT-BOGO related changes
  --$
  --$ Revision 1.5  2013/03/08 22:46:07  ymillan
  --$ CR22452 Simple mobile
  --$
  --$ Revision 1.4  2012/08/01 14:32:09  kacosta
  --$ CR20545 NT10_ST BYOP Welcome SMS with MIN
  --$
  --$ Revision 1.3  2012/07/31 16:39:04  kacosta
  --$ CR20546 NT10_ST BYOP Welcome SMS with MIN
  --$
  --$ Revision 1.2  2012/07/31 14:13:28  kacosta
  --$ CR20546 NT10_ST BYOP Welcome SMS with MIN
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  -- Global Package Variables
  --
  l_b_debug BOOLEAN := FALSE;
  --
  /********************************************************
  | send_psms_batch procedure will be called by DBMS_JOB   |
  | and executed on scheduled time and day     |
  | to send psms marketing messages to the phones.   |
  | ESN and PART_NUMBER parameters are optional      |
  | If not provided, procedure will grab first 1000 ESNs   |
  | from the TABLE_PART_INST table, filter them through    |
  | the validation routines and send the message          |
  ********************************************************/
  PROCEDURE send_psms_batch
  (
    p_part_number     IN table_part_num.part_number%TYPE DEFAULT NULL
   ,p_esn             IN table_part_inst.part_serial_no%TYPE DEFAULT NULL
   ,p_ota_mrkt_number IN table_x_ota_mrkt_info.x_mrkt_number%TYPE
   ,p_ota_mrkt_type   IN table_x_ota_mrkt_info.x_mrkt_type%TYPE
  );

  /********************************************************
  | send_psms procedure will be called by CBO     |
  | to send psms marketing messages to the phone     |
  ********************************************************/
  PROCEDURE send_psms
  (
    p_esn                       IN VARCHAR2 -- ESN
   ,p_min                       IN VARCHAR2 -- MIN
   ,p_mode                      IN VARCHAR2 -- WEB, BATCH
   ,p_text                      IN VARCHAR2 -- message text
   ,p_int_dll_to_use            IN NUMBER -- DLL number
   ,p_psms_message              OUT VARCHAR2
   ,p_ota_trans2x_ota_mrkt_info IN VARCHAR2 DEFAULT NULL
   ,p_ota_trans_reason          IN VARCHAR2 DEFAULT NULL
   ,p_x_ota_trans2x_call_trans  IN NUMBER DEFAULT NULL
   ,p_cbo_error_message         IN VARCHAR2 DEFAULT NULL -- error message passed from CBO
   ,p_mobile365_id              IN VARCHAR2 DEFAULT NULL
   ,
    --OTA Enhancements
    p_ota_trans_objid OUT NUMBER -- 06/27/05 CR4169
  );

  /********************************************************
  | send_psms_inq procedure will be called by CBO    |
  | to send psms inquiry messages to the phone    |
  ********************************************************/
  PROCEDURE send_psms_inq
  (
    p_esn             IN VARCHAR2 -- ESN
   ,p_min             IN VARCHAR2 -- MIN
   ,p_mode            IN VARCHAR2 -- WEB, BATCH
   ,p_psms_message    IN VARCHAR2
   ,p_reason          IN VARCHAR2
   ,p_x_counter       IN NUMBER DEFAULT NULL
   ,p_mobile365_id    IN VARCHAR2 DEFAULT NULL
   , --OTA Enhancements
    p_ota_trans_objid OUT NUMBER -- 06/27/05  CR4169
  );
  /*******************************************************/
  /* new procedure CR13375  */
  /*********************************************************/
  PROCEDURE send_psms_pre_dll
  (
    p_esn                       IN VARCHAR2
   ,p_min                       IN VARCHAR2
   ,p_mode                      IN VARCHAR2
   ,p_text                      IN VARCHAR2
   ,p_int_dll_to_use            IN NUMBER
   ,p_psms_message              OUT VARCHAR2
   ,p_ota_trans2x_ota_mrkt_info IN VARCHAR2 DEFAULT NULL
   ,p_ota_trans_reason          IN VARCHAR2 DEFAULT NULL
   ,p_x_ota_trans2x_call_trans  IN NUMBER DEFAULT NULL
   ,p_cbo_error_message         IN VARCHAR2 DEFAULT NULL
   , -- error message passed from CBO
    p_mobile365_id              IN VARCHAR2 DEFAULT NULL
   ,
    --OTA Enhancements
    p_ota_trans_objid OUT NUMBER
   , -- 06/27/05 CR4169
    --OUT
    p_sequence_in       OUT NUMBER
   ,p_technology_in     OUT NUMBER
   ,p_transid_in        OUT NUMBER
   ,p_int_dll_to_use_in OUT NUMBER
   ,p_x_carrier_id_in   OUT NUMBER
  );
  --
  --CR20545 Start kacosta 07/31/2012
  --********************************************************************************
  -- Procedure to get the next BYOP SMS staging record
  --********************************************************************************
  --
  PROCEDURE get_next_byop_sms_stg
  (
    p_esn              OUT byop_sms_stg.esn%TYPE
   ,p_min              OUT byop_sms_stg.min%TYPE
   ,p_ota_psms_address OUT table_x_parent.x_ota_psms_address%TYPE
   ,p_agg_carr_code    OUT table_x_parent.x_agg_carr_code%TYPE
   ,p_transaction_type OUT byop_sms_stg.transaction_type%TYPE
   ,p_brand            OUT table_bus_org.org_id%TYPE
   ,p_error_code       OUT PLS_INTEGER
   ,P_ERROR_MESSAGE    OUT VARCHAR2
   ,p_expire_dt        OUT date --cr22452 simple mobile
   ,p_x_msg_script_id  OUT byop_sms_stg.x_msg_script_id%TYPE
   ,p_forecast_date    OUT DATE -- CR44787
   ,p_x_msg_script_variables		OUT	byop_sms_stg.x_msg_script_variables%TYPE	-- CR42899
  );
  --
  --********************************************************************************
  -- Procedure to purge BYOP SMS staging records
  --********************************************************************************
  --
  PROCEDURE purge_byop_sms_stg
  (
    p_days_back     IN INTEGER DEFAULT 7
   ,p_error_code    OUT PLS_INTEGER
   ,p_error_message OUT VARCHAR2
  );
  --CR20545 End kacosta 07/31/2012

  --********************************************************************************
  -- CR 52112 Procedure to get the next BYOP SMS staging for Bulk processing.
  --********************************************************************************
  PROCEDURE get_next_byop_sms_stg_blk
  (
    p_return_limit     IN  NUMBER DEFAULT 500,
    p_cursor           OUT SYS_REFCURSOR
  ) ;

END;
/