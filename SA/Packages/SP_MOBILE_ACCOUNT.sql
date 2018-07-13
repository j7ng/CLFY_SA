CREATE OR REPLACE PACKAGE sa.SP_MOBILE_ACCOUNT
AS
/*******************************************************************************************************
 * --$RCSfile: SP_MOBILE_ACCOUNT_SPEC.sql,v $
  --$Revision: 1.41 $
  --$Author: sgangineni $
  --$Date: 2018/01/04 00:48:18 $
  --$ $Log: SP_MOBILE_ACCOUNT_SPEC.sql,v $
  --$ Revision 1.41  2018/01/04 00:48:18  sgangineni
  --$ CR48260 - Added new function is_device_verified
  --$
  --$ Revision 1.40  2017/12/11 19:42:52  skambhammettu
  --$ CR53217
  --$
  --$ Revision 1.39  2017/08/15 20:12:26  tpathare
  --$ Added procedures for device recovery code.
  --$
  --$ Revision 1.36  2017/04/25 16:05:31  vlaad
  --$ Added error_code to get rebranding attributes
  --$
  --$ Revision 1.33  2017/04/19 19:36:27  vlaad
  --$ Added new overloaded procedure for Costco
  --$
  --$ Revision 1.24  2017/03/02 16:15:46  smeganathan
  --$ CR47608 Costco Activation added new attribute sim_partclass
  --$
  --$ Revision 1.18  2016/10/28 23:05:57  nmuthukkaruppan
  --$ CR45378 - New proc get_partnumber_by_pin added
  --$
  --$ Revision 1.17  2016/10/10 19:12:31  nmuthukkaruppan
  --$ CR43248 - My Accounts - TW release changes only
  --$
  --$ Revision 1.16  2016/10/03 20:57:32  vnainar
  --$ CR45378 new procedure p_get_sim_info added
  --$
  --$ Revision 1.15  2016/09/28 22:26:28  nmuthukkaruppan
  --$ CR43248 and CR44680 Changes Merged with PROD release 09/27
  --$
  --$ Revision 1.14  2016/09/02 21:38:08  smeganathan
  --$ CR43248 changes in ma_getesnattributes and added new proc validate_esn_sp_rules_wrp
  --$
  --$ Revision 1.13  2016/08/05 16:04:35  pamistry
  --$ CR41473 - LRP2 production merge with LRP phase 2 changes
  --$
  --$ Revision 1.11  2016/06/07 18:48:52  smeganathan
  --$ Changes in parameters for new procedures for Push notifications
  --$
  --$ Revision 1.10  2016/06/03 16:20:35  smeganathan
  --$ removed client app id
  --$
  --$ Revision 1.9  2016/06/03 10:53:24  usivaraman
  --$ CR 42489 - changes for push notifications added new procedures and tables
  --$
  --$
  --$ Revision 1.9  2016/06/03 10:53:24  usivaraman
  --$ CR 42489 - changes for push notifications added new procedures and tables
  --$  * -----------------------------------------------------------------------------------------------------
*********************************************************************************************************/
--
PROCEDURE get_acct_detls_by_acctid ( i_accountid         IN  TABLE_WEB_USER.OBJID%TYPE,
      OP_ERR_NUM          OUT   NUMBER,
      OP_ERR_STRING       OUT   VARCHAR2,
      OP_RESULT           OUT   VARCHAR2,
      OP_accountDetails   OUT   sys_refcursor);
--
-- CR47564 Added overloaded procedure to get account detail by Min,Esn,email,etc.
PROCEDURE get_acct_detls ( i_webuserid       IN NUMBER,
                           i_hash_webuserid  IN VARCHAR2,
                           i_esn             IN VARCHAR2,
                           i_min             IN VARCHAR2,
                           i_emailid         IN VARCHAR2,
                           i_brand           IN VARCHAR2,
                           op_err_num        OUT NUMBER,
                           op_err_string     OUT VARCHAR2,
                           op_result         OUT VARCHAR2,
                           op_accountdetails OUT sys_refcursor);

PROCEDURE log_default_device ( i_min                IN    VARCHAR2 ,
	     i_esn                IN    VARCHAR2,
	     i_brand              IN    VARCHAR2,
	     i_clinetappname      IN    VARCHAR2,
	     i_clinetappversion   IN    VARCHAR2,
	     i_devicemodel        IN    VARCHAR2,
	     i_osversion          IN    VARCHAR2,
	     i_sourcesystem       IN    VARCHAR2,
	     i_language           IN    VARCHAR2,
             i_clientapptype      IN    VARCHAR2, --Modified for CR 41768
	     i_web_account_id     IN    VARCHAR2, --Modified for CR 42489
	     i_channelid	        IN 	  VARCHAR2, --Modified for CR 42489
	     i_deviceid		        IN    VARCHAR2, --Modified for CR 42489
	     OP_ERR_NUM           OUT   NUMBER,
	     OP_ERR_STRING        OUT   VARCHAR2,
                               op_result            OUT   VARCHAR2 );
--
  PROCEDURE GET_PART_NUM_FACTORS
    (IO_PART_NUM_INFO_TABLE IN OUT  TYP_PART_NUM_INFO_TABLE
    , O_ERR_NUM             OUT     NUMBER
    , O_ERR_STRING          OUT     VARCHAR2
    ,i_esn                  IN      sa.TABLE_PART_INST.PART_SERIAL_NO%type default null -- CR48383, a new parameter from Spring Farm call
    ) ;
--
  PROCEDURE ma_getesnattributes ( in_esn     IN     table_part_inst.part_serial_no%TYPE ,
      io_key_tbl IN OUT sa.typ_mobileapp_keys_tbl);
--Modified for CR 42489 starts
PROCEDURE p_get_nameduserid ( i_web_account_id 	IN  VARCHAR2,
      i_nameduserid 	  IN  	VARCHAR2,
      o_nameduserid 	  OUT  	VARCHAR2,
      O_ERR_NUM       	OUT   NUMBER,
                              o_err_string      OUT VARCHAR2);
--
PROCEDURE p_log_device_pref ( i_web_account_id  IN  VARCHAR2,
				i_channelid       IN  VARCHAR2,
				i_deviceid        IN  VARCHAR2,
				i_brand	          IN  VARCHAR2,
				i_pref_det        IN  sa.TAB_DEVICE_PREF,
				o_err_num         OUT NUMBER,
                              o_err_string      OUT VARCHAR2 );

PROCEDURE p_log_msg_status ( i_web_account_id 	IN  VARCHAR2 ,
      i_Channel_id     	    IN    VARCHAR2,
      i_Device_id      	    IN    VARCHAR2,
      i_ESN            	    IN    VARCHAR2,
      i_MIN            	    IN    VARCHAR2,
      i_preference_id  	    IN    VARCHAR2,
      i_campaign_id         IN    VARCHAR2,
      i_cust_trans_id       IN    VARCHAR2,
      i_push_date           IN    DATE,
      i_vendor_id           IN    VARCHAR2,
      i_response_date  	    IN    DATE,
      i_Opt_out_req    	    IN    VARCHAR2,
      i_brand 		          IN    VARCHAR2,
      i_Record_Load_Date    IN    DATE,
      i_Receipt_Request     IN    VARCHAR2,
      o_err_num 	          OUT   NUMBER,
                             o_err_string 	    OUT VARCHAR2 );
--Modified for CR 42489 ends
--
  -- PMistry 07/19/2016 CR41473 Added new procedure to get named user id from web objid or vise versa
PROCEDURE p_get_web_account_ids ( io_web_account_id  IN OUT NUMBER   ,
      io_nameduserid 	    IN OUT 	  VARCHAR2,
      O_ERR_NUM       	OUT       NUMBER,
                                  o_err_string       OUT    VARCHAR2 );

-- CR43248 changes starts..
PROCEDURE validate_esn_sp_rules_wrp ( ip_esn                   IN  VARCHAR2              ,
                    ip_bus_org_id             IN  VARCHAR2 ,
                    op_esn_sp_validation_tab  OUT esn_sp_validation_tab ,
                    op_err_code               OUT NUMBER ,
                    op_err_msg                OUT VARCHAR2);
-- CR45378 changes Ends
PROCEDURE  p_get_sim_info ( i_sim           IN  VARCHAR2 ,
                            o_sim_serial_no OUT VARCHAR2 ,
                            o_sim_status    OUT VARCHAR2 ,
                            o_phone_carrier OUT VARCHAR2 ,
                            o_err_num       OUT NUMBER   ,
                            o_err_msg       OUT VARCHAR2 );

--CR47564 WFM
PROCEDURE  p_get_sim_info ( i_sim           IN  VARCHAR2 ,
                            o_sim_serial_no OUT VARCHAR2 ,
                            o_sim_status    OUT VARCHAR2 ,
                            o_phone_carrier OUT VARCHAR2 ,
                            o_err_num       OUT NUMBER   ,
                            o_err_msg       OUT VARCHAR2,
                            o_legacy_flag   OUT VARCHAR2);

PROCEDURE get_partnumber_by_pin ( i_pin         IN  VARCHAR2 ,
	o_part_number   OUT VARCHAR2,
	o_err_num       OUT NUMBER,
	o_err_msg       OUT VARCHAR2);
-- CR45378 changes ends

--CR47608 added new overloaded procedure
PROCEDURE  p_get_sim_info ( i_sim             IN  VARCHAR2,
                            o_sim_serial_no   OUT VARCHAR2,
                            o_sim_part_class  OUT VARCHAR2,  -- CR47608
                            o_sim_partnumber  OUT VARCHAR2,  -- CR47608
                            o_legacy_flag     OUT VARCHAR2,
                            o_sim_status      OUT VARCHAR2,
                            o_phone_carrier   OUT VARCHAR2,
                            o_err_num         OUT NUMBER,
                            o_err_msg         OUT VARCHAR2);

--CR47608 adding new procedure to return rebranding related attribute
PROCEDURE  get_rebranding_attributes ( i_esn                IN VARCHAR2,
                                      i_target_brand        IN VARCHAR2,
                                      o_rebrand_equi_phone  OUT VARCHAR2,
                                      o_err_code            OUT NUMBER,
                                      o_err_msg             OUT VARCHAR2);

--CR48846 Adding new procedures for device recovery code processing
PROCEDURE insert_device_recovery_code (i_esn                    IN  VARCHAR2,
                                       i_min                    IN  VARCHAR2,
                                       i_security_code          IN  VARCHAR2,
                                       i_communication_channel  IN  VARCHAR2,
                                       o_err_num                OUT NUMBER,
                                       o_err_msg                OUT VARCHAR2);

PROCEDURE verify_device_recovery_code(i_esn                    IN  VARCHAR2,
                                      i_min                    IN  VARCHAR2,
                                      i_security_code          IN  VARCHAR2,
                                      i_communication_channel  IN  VARCHAR2,
                                      o_result                 OUT NUMBER,
                                      o_err_num                OUT NUMBER,
                                      o_err_msg                OUT VARCHAR2);
 --CR48846 end

 PROCEDURE GET_INQUIRY_TYPE(i_Esn     IN Table_Part_Inst.Part_Serial_No%Type,
                            i_brand   IN  VARCHAR2,
                            i_inquiry_type OUT VARCHAR2);
  --CR48260 start
  FUNCTION is_device_verified (i_device_id       IN    VARCHAR2) RETURN VARCHAR2;
  --CR48260 end

END SP_MOBILE_ACCOUNT;
/