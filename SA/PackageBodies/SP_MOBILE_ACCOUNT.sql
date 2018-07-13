CREATE OR REPLACE PACKAGE body sa.SP_MOBILE_ACCOUNT
AS
/*******************************************************************************************************
 * --$RCSfile: SP_MOBILE_ACCOUNT_BODY.sql,v $
 --$Revision: 1.187 $
 --$Author: skambhammettu $
 --$Date: 2018/03/15 19:31:44 $
 --$ $Log: SP_MOBILE_ACCOUNT_BODY.sql,v $
 --$ Revision 1.187  2018/03/15 19:31:44  skambhammettu
 --$ For OTATRANSACTION STATUS add action_type 7
 --$
 --$ Revision 1.186  2018/03/14 14:01:55  skambhammettu
 --$ CR55236--isautorefill change for shared group brands
 --$
 --$ Revision 1.183  2018/02/07 21:26:01  jcheruvathoor
 --$ CR56041	WebCommunication Preferences opted in by default
 --$
 --$ Revision 1.181  2018/01/04 00:50:19  sgangineni
 --$ CR48260 - Added new function is_device_verified
 --$
 --$ Revision 1.180  2017/12/12 15:12:02  sraman
 --$ Merged with prod code released on 12/12 Fix
 --$
 --$ Revision 1.179  2017/12/11 20:15:45  jpena
 --$ changes to restrict inquiry type for Net10
 --$
 --$ Revision 1.178  2017/12/11 19:54:07  skambhammettu
 --$ New Procedure get_inquiry_type
 --$
 --$ Revision 1.176  2017/12/07 14:24:16  skambhammettu
 --$ cr53217--PROD MERGE
 --$
 --$ Revision 1.167  2017/11/09 16:40:00  sinturi
 --$ Adding condition for CR49058
 --$
 --$ Revision 1.164  2017/10/25 20:18:44  abustos
 --$ CR51182 Merge with Production
 --$
 --$ Revision 1.160  2017/10/20 14:16:24  mshah
 --$ CR52423 - Merging
 --$
 --$ Revision 1.159  2017/10/19 23:07:17  tbaney
 --$ Changes for CR52423 tas universal branding
 --$
 --$ Revision 1.149  2017/10/03 21:33:22  mshah
 --$ CR51860 - Data Manager My Account App
 --$ Remove add_on from displaying the total data in Data manager
 --$
  --$ Revision 1.144  2017/08/15 20:01:25  tpathare
  --$ Added procedures for device recovery code.
  --$
  --$ Revision 1.140  2017/07/19 21:13:01  vlaad
  --$ Merged with 7/19 BAU release
  --$
  --$ Revision 1.104  2017/04/19 19:37:31  vlaad
  --$ Added new overloaded p_get_sim_info
  --$
  --$ Revision 1.99  2017/04/11 16:16:58  vlaad
  --$ Added sim part number in p_get_siminfo
  --$
  --$ Revision 1.81  2017/03/02 16:16:58  smeganathan
  --$ CR47608 Costco Activation added new attribute sim_partclass
  --$
  --$ Revision 1.61  2017/01/17 21:03:16  smeganathan
  --$ CR47023 changed error logging table
  --$
  --$ Revision 1.60  2017/01/12 19:48:57  smeganathan
  --$ CR45378 changed error codes in p_get_sim_info and get_partnumber_by_pin_num procedures
  --$
  --$ Revision 1.58  2017/01/10 18:57:29  smeganathan
  --$ CR45378 changes for carrier pending
  --$
  --$ Revision 1.57  2017/01/10 18:53:39  smeganathan
  --$ CR45378 changes for carrier pending
  --$
  --$ Revision 1.56  2016/12/30 17:20:30  smeganathan
  --$ CR45378 changes for port in progress
  --$
  --$ Revision 1.55  2016/11/15 20:03:55  smeganathan
  --$ CR44680 added logic to check for VAS enrollment
  --$
  --$ Revision 1.54  2016/11/08 19:59:45  smeganathan
  --$ Merged CR46350 changes with CR45378 and CR44680
  --$
  --$ Revision 1.53  2016/11/08 16:53:28  smeganathan
  --$ Merged CR46350 changes with CR45378 and CR44680
  --$
  --$ Revision 1.51  2016/10/28 23:05:27  nmuthukkaruppan
  --$ CR45378 - New proc get_partnumber_by_pin added
  --$
  --$ Revision 1.50  2016/10/25 15:46:23  nmuthukkaruppan
  --$ CR44680 -  Fetching X_DATEOFBIRTH from TABLE_X_CONTACT_ADD_INFO
  --$
  --$ Revision 1.49  2016/10/24 22:30:57  smeganathan
  --$ changed the attribute name from sim_status to simstatus
  --$
  --$ Revision 1.48  2016/10/24 19:42:41  smeganathan
  --$ CR45378 added pymt_src_avlbl
  --$
  --$ Revision 1.47  2016/10/21 21:45:50  nmuthukkaruppan
  --$ CR45378 -  Changing the Attribute Name to SIM_STATUS
  --$
  --$ Revision 1.46  2016/10/13 19:07:57  nmuthukkaruppan
  --$ CR45378 - New Attributes added that includes Account Id, Is Sim required ,ICCID,SIM_STATUS,CARRIER, OTA Pending, Carrier Pending
  --$
  --$ Revision 1.44  2016/10/03 20:56:28  vnainar
  --$ CR45378 new procedure p_get_sim_info added
  --$
  --$ Revision 1.43  2016/09/28 22:29:24  nmuthukkaruppan
  --$ CR43248 , CR44680 Changes Merged with PROD release 09/27
  --$
  --$ Revision 1.42  2016/09/27 18:41:52  nmuthukkaruppan
  --$ CR44680 - Adding ZIPCODE attribute
  --$
  --$ Revision 1.41  2016/09/16 22:43:37  nmuthukkaruppan
  --$ CR43248  -  repalced with l_err_code to avoid exception
  --$
  --$ Revision 1.40  2016/09/14 17:57:41  nmuthukkaruppan
  --$ CR43248 - prefixed sa to alert_package.
  --$
  --$ Revision 1.39  2016/09/14 14:01:17  nmuthukkaruppan
  --$ CR43248 -  Added Condition to include PAST DUE - LINE RESERVED
  --$
  --$ Revision 1.38  2016/09/13 16:01:25  pamistry
  --$ CR41473 - Modify GET_ACCT_DETLS_BY_ACCTID procedure to set the default value for email and sms opt values
  --$
  --$ Revision 1.37  2016/09/06 18:47:01  smeganathan
  --$ CR43248 removed no of lines condition while getting group id
  --$
  --$ Revision 1.36  2016/09/02 21:40:56  smeganathan
  --$ CR43248 changes in ma_getesnattributes and added new proc validate_esn_sp_rules_wrp
  --$
  --$ Revision 1.35  2016/09/01 20:17:16  pamistry
  --$ CR41473 - Modified Get_Acct_Detls_By_Acctid procedure to include addition column in resultset cursor.
   --$
  --$ Revision 1.34  2016/08/18 22:39:21  nmuthukkaruppan
  --$ CR44680 - Added two columns in the Output Refcursor in get_acct_detls_by_acctid proc for TF Redesign
  --$
  --$ Revision 1.33  2016/08/08 18:28:37  pamistry
  --$ CR41473 - LRP2 corrected the join condition for table bus org in GET_ACCT_DETLS_BY_ACCTID procedure
  --$
  --$ Revision 1.32  2016/08/08 17:40:27  pamistry
  --$ CR41473 - LRP2 Modify GET_ACCT_DETLS_BY_ACCTID procedure to include Brand Name into resultset.
  --$
  --$ Revision 1.29  2016/07/25 15:59:48  smeganathan
  --$ changes in p_log_pref_device removed min from where clause and added it in SET clause
  --$
  --$ Revision 1.28  2016/07/07 16:09:55  smeganathan
  --$ Added validation in p_log_msg_status
  --$
  --$ Revision 1.27  2016/06/20 19:34:46  smeganathan
  --$ changed attribute name in log pref device
  --$
  --$ Revision 1.26  2016/06/20 16:18:04  smeganathan
  --$ removed input parameter validations in p_log_msg_status
  --$
  --$ Revision 1.25  2016/06/08 22:20:54  smeganathan
  --$ web account id  null check is removed in p_log_msg_status
  --$
  --$ Revision 1.24  2016/06/07 19:39:08  smeganathan
  --$ added modified while updating preference
  --$
  --$ Revision 1.23  2016/06/07 18:51:10  smeganathan
  --$ changed parameters in new procs for push notifications
  --$
  --$ Revision 1.22  2016/06/03 16:21:42  smeganathan
  --$ removed client app id and removed commit
  --$
  --$ Revision 1.21  2016/06/03 10:53:24  usivaraman
  --$ CR 42489
  --$
  --$
  --$ Revision 1.21  2016/06/02 12:00:00  usivaraman
  --$ CR42489 added new parameters webuser id, channel id and device id to procedure LOG_DEFAULT_DEVICE
  --$
  --$ Revision 1.20  2016/05/09 09:43:17  sethiraj
  --$ CR37756 - Changes for Simple Mobile SDP Project
  --$
  --$ Revision 1.19  2016/04/28 14:14:16  smeganathan
  --$ CR41768 modifications done for client app id in LOG_DEFAULT_DEVICE
  --$
  --$ Revision 1.18  2016/04/26 21:25:21  smeganathan
  --$ CR41768 added new parameters i_clientapptype and i_clientappid to procedure LOG_DEFAULT_DEVICE
  --$  * -----------------------------------------------------------------------------------------------------
*********************************************************************************************************/
PROCEDURE GET_ACCT_DETLS_BY_ACCTID
	(
	    i_accountid IN TABLE_WEB_USER.OBJID%TYPE,
	    op_err_num OUT NUMBER,
	    op_err_string OUT VARCHAR2,
	    op_result OUT VARCHAR2,
	    op_accountdetails OUT sys_refcursor
    ) IS

	BEGIN
	  OPEN op_accountdetails FOR SELECT CT.FIRST_NAME,
										CT.LAST_NAME,
										AD.ADDRESS ADDRESS_1,
										AD.ADDRESS_2,
										AD.CITY,
										AD.STATE,
										AD.ZIPCODE,
										CT.PHONE,
										TXCI.X_DATEOFBIRTH,
										CT.OBJID CONTACT_ID,
										TXCI.X_PIN,
										WB.X_SECRET_QUESTN X_SECRET_QUESTN,
										WB.X_SECRET_ANS X_SECRET_ANS,
										WB.LOGIN_NAME E_MAIL,
                    BO.ORG_ID    ORG_ID,                                                        -- CR41473 PMistry 08/01/2016 Added for LRP phase2
                    wb.insert_timestamp account_creation_date,		                              -- CR41473 PMistry 09/01/2016 Added for LRP phase2
                    nvl(TXCI.x_do_not_loyalty_email,0) x_do_not_loyalty_email,					        -- CR41473 PMistry 09/01/2016 Added for LRP phase2
                    nvl(TXCI.x_do_not_loyalty_sms,0) x_do_not_loyalty_sms,						            -- CR41473 PMistry 09/01/2016 Added for LRP phase2
					--CR56041 starts
					(CASE WHEN nvl(TXCI.x_prerecorded_consent,0) = 1
			         THEN
						'true'
					 else
						'false'
                     END
					) x_prerecorded_consent,
					(CASE WHEN nvl(TXCI.x_do_not_mobile_ads,0) = 1
			          THEN
						'true'
					 else
						'false'
                     END
					) x_do_not_mobile_ads, --CR56041 ends
                    CT.X_SPL_OFFER_FLG, --  CR44680
                    CT.X_SPL_PROG_FLG   --  CR44680
		 --CR49048 changes starts
		 ,/*(SELECT min(tsp.install_date)
		 FROM table_site_part tsp
		 WHERE tsp.site_part2site = ts.objid) plan_activation_date*/
 (SELECT MIN(tsp.install_date)
 FROM table_contact tc,
 table_x_contact_part_inst txcpi,
 table_part_inst tpi,
 table_site_part tsp
 WHERE txcpi.x_contact_part_inst2part_inst = tpi.objid
 AND txcpi.x_contact_part_inst2contact = tc.objid
 AND tc.objid = wb.web_user2contact
 AND tpi.part_serial_no = tsp.x_service_id
 AND tsp.part_status IN ('Active', 'Inactive')
 ) plan_activation_date
		 ,/*(SELECT CASE WHEN SUM(CASE WHEN tsp.part_status = 'Active' THEN 1
 ELSE 0
 END) > 0 THEN 'Active'
 ELSE 'Inactive'
 END
		 FROM table_site_part tsp
 WHERE tsp.site_part2site = ts.objid) customer_status */
 (SELECT CASE WHEN SUM(CASE WHEN tsp.part_status = 'Active' THEN 1
 ELSE 0
 END) > 0 THEN 'Active'
 ELSE 'Inactive'
 END
 FROM table_contact tc,
 table_x_contact_part_inst txcpi,
 table_part_inst tpi,
 table_site_part tsp
 WHERE txcpi.x_contact_part_inst2part_inst = tpi.objid
 AND txcpi.x_contact_part_inst2contact = tc.objid
 AND tc.objid = wb.web_user2contact
 AND tsp.part_status IN ('Active', 'Inactive')
 AND tpi.part_serial_no = tsp.x_service_id) customer_status
		 ,/*(SELECT COUNT(tsp.objid)
 FROM table_x_call_trans tct,
 table_site_part tsp
 WHERE tsp.x_service_id = tct.x_service_id
 AND tsp.site_part2site = ts.objid
 AND tct.X_ACTION_TYPE = '6'
 AND tct.x_result = 'Completed'
 AND EXISTS (SELECT 1 FROM x_reward_program_enrollment rpe WHERE rpe.web_account_id = wb.objid
 AND tct.x_transact_date >= rpe.enroll_date
 AND rpe.deenroll_date IS NULL)) Redemptions_count */
 (SELECT COUNT(DISTINCT tct.objid)
 FROM table_contact tc,
 table_x_contact_part_inst txcpi,
 table_part_inst tpi,
 table_x_call_trans tct
 --table_web_user twu
 WHERE txcpi.x_contact_part_inst2part_inst = tpi.objid
 AND txcpi.x_contact_part_inst2contact = tc.objid
 AND tc.objid = wb.web_user2contact
 --AND tpi.part_serial_no = tsp.x_service_id
 AND tct.x_service_id = tpi.part_serial_no
 AND tct.X_ACTION_TYPE = '6'
 AND tct.x_result = 'Completed'
 AND EXISTS (SELECT 1
 FROM x_reward_program_enrollment rpe
 WHERE rpe.web_account_id = to_char(wb.objid)
 AND tct.x_transact_date >= rpe.enroll_date
 AND rpe.deenroll_date IS NULL)) Redemptions_count
		 --CR49048 changes ends
									FROM TABLE_WEB_USER WB
										INNER JOIN TABLE_CONTACT CT
										ON WB.WEB_USER2CONTACT = CT.OBJID
										INNER JOIN TABLE_CONTACT_ROLE TR
										ON TR.CONTACT_ROLE2CONTACT = CT.OBJID
										LEFT OUTER JOIN TABLE_SITE TS
										ON TS.OBJID = TR.CONTACT_ROLE2SITE
										LEFT OUTER JOIN TABLE_ADDRESS AD
										ON TS.CUST_PRIMADDR2ADDRESS = AD.OBJID
										INNER JOIN TABLE_X_CONTACT_ADD_INFO TXCI
										ON TXCI.ADD_INFO2CONTACT = CT.OBJID
                    LEFT OUTER JOIN TABLE_BUS_ORG BO
                    on BO.OBJID = WB.WEB_USER2BUS_ORG 			-- CR41473 PMistry 08/01/2016 Added for LRP phase2
										WHERE 1=1 AND
										WB.OBJID = i_accountid;

	  op_err_num   	:= 0;
	  op_err_string := 'SUCCESS';
	  op_result 	:= 'SUCCESS';

	EXCEPTION
	WHEN OTHERS THEN
	  op_result     := 'ERROR';
	  op_err_num    := SQLCODE;
	  op_err_string := SQLCODE || SUBSTR (SQLERRM, 1, 100);

END GET_ACCT_DETLS_BY_ACCTID;

-- overloaded procedure to get the web account details based on optional parameters
PROCEDURE get_acct_detls ( i_webuserid       IN  NUMBER,
                           i_hash_webuserid  IN  VARCHAR2,
                           i_esn             IN  VARCHAR2,
                           i_min             IN  VARCHAR2,
                           i_emailid         IN  VARCHAR2,
                           i_brand           IN  VARCHAR2,
                           op_err_num        OUT NUMBER,
                           op_err_string     OUT VARCHAR2,
                           op_result         OUT VARCHAR2,
                           OP_accountDetails OUT sys_refcursor) IS
  c customer_type := customer_type();
BEGIN
  op_err_num    := 0;
  op_err_string := 'SUCCESS';
  op_result     := 'SUCCESS';
  -- initial validation
  IF i_webuserid      is NULL AND
     i_hash_webuserid IS NULL AND
     i_esn            IS NULL AND
     i_min            is NULL AND
     i_emailid        IS NULL
  THEN
    --
    op_result     := 'FAILURE';
    op_err_num    := 10222;
    op_err_string := 'INPUTS CANNOT BE BLANK, PLEASE PROVIDE AT LEAST ONE INPUT';
    RETURN;
  END IF;
  -- To retrieve the webuserid from the given inputs
  IF i_webuserid is NOT NULL THEN
    --
    c.web_user_objid := i_webuserid;
  ELSIF i_hash_webuserid IS NOT NULL THEN
    --
    c.web_user_objid := sa.customer_info.get_web_user_id ( i_hash_webuserid => i_hash_webuserid );
    --
	  IF c.web_user_objid IS NULL THEN
	    --
      op_result     := 'FAILURE';
		  op_err_num    := 10223;
		  op_err_string := 'WEBUSERID NOT FOUND BY HASH WEBUSERID';
		  RETURN;
    END IF;
  ELSIF i_esn IS NOT NULL THEN
    --
    c.esn := i_esn;
	  c := c.get_web_user_attributes;
	  IF c.web_user_objid IS NULL THEN
	    --
      op_result     := 'FAILURE';
		  op_err_num    := 10223;
		  op_err_string := 'WEBUSERID NOT FOUND BY ESN';
		  RETURN;
    END IF;
  ELSIF i_min IS NOT NULL THEN
    --
	  c.esn := c.get_esn ( i_min => i_min );
	  c := c.get_web_user_attributes;
    --
	  IF c.web_user_objid IS NULL THEN
	    --
      op_result     := 'FAILURE';
		  op_err_num    := 10223;
		  op_err_string := 'WEBUSERID NOT FOUND BY MIN';
		  RETURN;
    END IF;
    --
  ELSIF i_emailid IS NOT NULL  THEN
	  --
 	  IF i_brand IS NULL THEN
	    --
		  op_result     := 'FAILURE';
		  op_err_num    := 10221;
		  op_err_string := 'BRAND CANNOT BE BLANK';
		  RETURN;
    END IF;
    --
    c := c.retrieve_login ( i_login_name => i_emailid ,
                            i_bus_org_id => i_brand   );
    --
    IF c.web_user_objid IS NULL THEN
      op_result     := 'FAILURE';
      op_err_num    := 10223;
      op_err_string := 'WEBUSERID NOT FOUND BY EMAILID';
    END IF;
    --
	  --
  END IF;
  --
  DBMS_OUTPUT.PUT_LINE ('c.web_user_objid: '||c.web_user_objid);
  -- Calling the BAU proc by acct_id
  get_acct_detls_by_acctid ( i_accountid       => c.web_user_objid,
                             op_err_num        => op_err_num,
                             op_err_string     => op_err_string,
                             op_result         => op_result,
                             op_accountdetails => op_accountdetails );
 EXCEPTION
   WHEN OTHERS THEN
     op_result     := 'ERROR';
     op_err_num    := SQLCODE;
     op_err_string := SQLCODE ||' '|| SQLERRM;
END get_acct_detls;
-- CR47564 Added overloaded procedure to get account detail by Min.

PROCEDURE LOG_DEFAULT_DEVICE
	(
	     i_min                IN    VARCHAR2,
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
	     OP_RESULT            OUT   VARCHAR2
    ) IS

    v_min VARCHAR2(30);
    v_esn VARCHAR2(30);
    l_min VARCHAR2(30);
    l_def_clientapptype   VARCHAR2(10)  :='FULL'; --Modified for CR 41768
    --
	BEGIN
	  	l_min :='INACTIVE';
      --
	  	BEGIN
	  	--CHECK WHETHER ESN OR MIN COMBINATION EXIST OR NOT
      SELECT  ESN,
              MIN
      INTO    v_esn,
              v_min
      FROM  TABLE_LOG_DEFAULT_DEVICE
      WHERE ESN             = i_esn
      AND   MIN             = (NVL(i_min, l_min))
      AND   CLIENT_APP_TYPE = NVL(i_clientapptype,l_def_clientapptype) --Modified for CR 41768
      AND   web_account_id   = i_web_account_id  --Modified for CR42489
      AND   channel_id	     = i_channelid  --Modified for CR42489
      AND   device_id        = i_deviceid;  --Modified for CR42489
      --
		  --IF data found then update data with MIN (It will take care of of min is inactive)
      UPDATE  TABLE_LOG_DEFAULT_DEVICE
      SET     min           = NVL(i_min, l_min),
              brand         = i_brand,
              app_name      = i_clinetappname,
              app_version   = i_clinetappversion,
              device_model   = i_devicemodel,
              os_version     = i_osversion,
              source_system  = i_sourcesystem,
              language       = i_language,
              modified_date  = sysdate
      WHERE ESN           = i_esn
      AND MIN             = NVL(i_min, l_min)
      AND CLIENT_APP_TYPE = NVL(i_clientapptype,l_def_clientapptype) --Modified for CR 41768
      AND  web_account_id   = i_web_account_id  --Modified for CR42489
      AND  channel_id	      = i_channelid  --Modified for CR42489
      AND  device_id        = i_deviceid;  --Modified for CR42489
      --
      EXCEPTION
				WHEN NO_DATA_FOUND THEN
				--INSERT NEW RECORD
				INSERT INTO TABLE_LOG_DEFAULT_DEVICE (
					esn,
					min,
					brand,
					app_name,
					app_version,
					device_model,
					os_version,
					source_system,
					language,
					creation_date,
					modified_date,
					CLIENT_APP_TYPE, --Modified for CR 41768
					web_account_id, --Modified for CR42489
					channel_id, --Modified for CR42489
					device_id --Modified for CR42489
					)
            VALUES
            (
					i_esn,
					NVL(i_min, l_min),
					i_brand,
					i_clinetappname,
					i_clinetappversion,
					i_devicemodel,
					i_osversion,
					i_sourcesystem,
					i_language,
					sysdate,
					sysdate,
					NVL(i_clientapptype,l_def_clientapptype), --Modified for CR 41768
					i_web_account_id, --Modified for CR42489
					i_channelid, --Modified for CR42489
					i_deviceid --Modified for CR42489
			);
		END;
    --
	  OP_ERR_NUM   	:= 0;
	  OP_ERR_STRING := 'SUCCESS';
	  OP_RESULT 	:= 'SUCCESS';
    --
	  commit;
    --
	EXCEPTION
	WHEN OTHERS THEN
	  OP_RESULT     := 'ERROR';
	  OP_ERR_NUM    := SQLCODE;
	  OP_ERR_STRING := SQLCODE || SUBSTR (SQLERRM, 1, 100);
	  rollback;

END LOG_DEFAULT_DEVICE;
----------------------------------------------
-------------Start of CR33035 Changes---------
----------------------------------------------
PROCEDURE GET_PART_NUM_FACTORS
	(IO_PART_NUM_INFO_TABLE IN OUT TYP_PART_NUM_INFO_TABLE
	, O_ERR_NUM       		  OUT NUMBER
	, O_ERR_STRING    		  OUT VARCHAR2
	,i_esn IN sa.TABLE_PART_INST.PART_SERIAL_NO%type default null -- CR48383 new parameter for Spring Farm call
	)
IS
	LV_PART_NUM_INFO_TABLE 					TYP_PART_NUM_INFO_TABLE := TYP_PART_NUM_INFO_TABLE();
  -- CR48383 Changes
  -- mdave 03/14/2017
  l_block_flag VARCHAR2(1);
 l_safelinkassist_flag VARCHAR2(1) := 'N';
  --End CR48383
BEGIN
	IF (IO_PART_NUM_INFO_TABLE.COUNT = 0) THEN
		O_ERR_NUM  := 1;
		O_ERR_STRING := 'Empty input array. Please provide part numbers.';
		sa.OTA_UTIL_PKG.ERR_LOG
			(
				'Error while retrieving part number factors',   --p_action
				SYSDATE,                                        --p_error_date
				NULL,                                   		--p_key
				'SA.SP_MOBILE_ACCOUNT.GET_PART_NUM_FACTORS',   --p_program_name
				O_ERR_NUM||' - '||O_ERR_STRING					--p_error_text
			);
		RETURN;
	END IF;
  -- CR48383 start
  l_block_flag := NULL;
    l_block_flag := sa.BLOCK_TRIPLE_BENEFITS(i_esn);
	l_safelinkassist_flag := sa.get_safelinkassist_flag (i_esn);
    DBMS_OUTPUT.PUT_LINE('ESN - '||i_esn );
    DBMS_OUTPUT.PUT_LINE('block_flag - '||l_block_flag );
	DBMS_OUTPUT.PUT_LINE('l_safelinkassist_flag - '||l_safelinkassist_flag );
 -- End CR48383 mdave 03292017
	FOR I IN IO_PART_NUM_INFO_TABLE.FIRST..IO_PART_NUM_INFO_TABLE.LAST
    LOOP
    --DBMS_OUTPUT.PUT_LINE('IO_PART_NUM_INFO_TABLE(I).PART_NUM_OBJID: '||IO_PART_NUM_INFO_TABLE(I).PART_NUM_OBJID);
    --DBMS_OUTPUT.PUT_LINE('IO_PART_NUM_INFO_TABLE(I).PART_NUMBER: '||IO_PART_NUM_INFO_TABLE(I).PART_NUMBER);
		FOR PART_NUM_INFO IN (SELECT	PN.OBJID AS PART_NUM_OBJID
										,PN.S_PART_NUMBER
										,PN.S_DESCRIPTION
										,PN.S_DOMAIN
										,CONV.UNIT_VOICE
										,CONV.UNIT_DAYS
										-- CR48383
										,DECODE(l_safelinkassist_flag,'Y',CONV1.TRANS_VOICE,DECODE(l_block_flag, 'Y',1,CONV.TRANS_VOICE)) TRANS_VOICE
										,DECODE(l_safelinkassist_flag,'Y',CONV1.TRANS_TEXT,DECODE(l_block_flag, 'Y',1,CONV.TRANS_TEXT)) TRANS_TEXT
										,DECODE(l_safelinkassist_flag,'Y',CONV1.TRANS_DATA,DECODE(l_block_flag, 'Y',1,CONV.TRANS_DATA)) TRANS_DATA
										-- end CR48383
										,CONV.TRANS_DAYS
										,SERV_PLAN_CLASS.SP_OBJID
										,SERV_PLAN_CLASS.SP_MKT_NAME
										,SERV_PLAN_CLASS.PART_CLASS_OBJID
										,SERV_PLAN_CLASS.PART_CLASS_NAME
								FROM
										(
											SELECT 	DISTINCT SP.OBJID SP_OBJID,
													SP.MKT_NAME SP_MKT_NAME,
													PART_CLASS_OBJID,
													PART_CLASS_NAME
											FROM 	X_SERVICE_PLAN SP,
													(
														SELECT 	SP.OBJID SERV_OBJID,
																PC.OBJID PART_CLASS_OBJID,
																PC.NAME PART_CLASS_NAME
														FROM 	X_SERVICEPLANFEATUREVALUE_DEF SPFVDEF,
																X_SERVICEPLANFEATURE_VALUE SPFV,
																X_SERVICE_PLAN_FEATURE SPF,
																X_SERVICEPLANFEATUREVALUE_DEF SPFVDEF2,
																X_SERVICEPLANFEATUREVALUE_DEF SPFVDEF3,
																X_SERVICE_PLAN SP,
																MTM_PARTCLASS_X_SPF_VALUE_DEF MTM,
																TABLE_PART_CLASS PC
														WHERE SPF.SP_FEATURE2REST_VALUE_DEF = SPFVDEF.OBJID
														AND SPF.OBJID                       = SPFV.SPF_VALUE2SPF
														AND SPFVDEF2.OBJID                  = SPFV.VALUE_REF
														AND SPFVDEF3.OBJID (+)              = SPFV.CHILD_VALUE_REF
														AND SPFVDEF.VALUE_NAME              = 'SUPPORTED PART CLASS'
														AND SP.OBJID                        = SPF.SP_FEATURE2SERVICE_PLAN
														AND SPFVDEF2.OBJID                  = MTM.SPFEATUREVALUE_DEF_ID
														AND PC.OBJID                        = MTM.PART_CLASS_ID
													) SP_PC_TABLE
												WHERE 	SP.OBJID = SP_PC_TABLE.SERV_OBJID
										) SERV_PLAN_CLASS ,
										sa.TABLE_PART_NUM PN ,
										sa.SP_MTM_SUREPAY MTM ,
										sa.X_SUREPAY_CONV CONV,
										sa.X_SUREPAY_CONV CONV1
								WHERE 	SERV_PLAN_CLASS.PART_CLASS_OBJID = PN.PART_NUM2PART_CLASS
								AND		PN.OBJID = IO_PART_NUM_INFO_TABLE(I).PART_NUM_OBJID
								AND 	PN.PART_NUMBER = UPPER(IO_PART_NUM_INFO_TABLE(I).PART_NUMBER)
								AND 	PN.PART_NUMBER = CONV1.X_PART_NUMBER (+)
								AND 	MTM.SERVICE_PLAN_OBJID =SERV_PLAN_CLASS.SP_OBJID
								AND 	MTM.SUREPAY_CONV_OBJID =CONV.OBJID
								)
		LOOP
			LV_PART_NUM_INFO_TABLE.EXTEND();
	        LV_PART_NUM_INFO_TABLE(LV_PART_NUM_INFO_TABLE.LAST) := sa.TYP_PART_NUM_INFO_OBJ(PART_NUM_INFO.PART_NUM_OBJID
                                                                                          ,PART_NUM_INFO.S_PART_NUMBER
                                                                                          ,PART_NUM_INFO.S_DESCRIPTION
                                                                                          ,PART_NUM_INFO.S_DOMAIN
                                                                                          ,PART_NUM_INFO.UNIT_VOICE
                                                                                          ,PART_NUM_INFO.UNIT_DAYS
                                                                                          ,PART_NUM_INFO.TRANS_VOICE
                                                                                          ,PART_NUM_INFO.TRANS_TEXT
                                                                                          ,PART_NUM_INFO.TRANS_DATA
                                                                                          ,PART_NUM_INFO.TRANS_DAYS
                                                                                          ,PART_NUM_INFO.SP_OBJID
                                                                                          ,PART_NUM_INFO.SP_MKT_NAME
                                                                                          ,PART_NUM_INFO.PART_CLASS_OBJID
                                                                                          ,PART_NUM_INFO.PART_CLASS_NAME);
		END LOOP;
	END LOOP;
	IO_PART_NUM_INFO_TABLE := LV_PART_NUM_INFO_TABLE;
	O_ERR_NUM  := 0;
	O_ERR_STRING := 'Success';
EXCEPTION
	WHEN OTHERS THEN
		O_ERR_NUM  := 2;
		O_ERR_STRING := 'Unexpected error, please check sa.error_table';
		sa.OTA_UTIL_PKG.ERR_LOG
			(
				O_ERR_NUM||' - '||O_ERR_STRING,                 --p_action
				SYSDATE,                                        --p_error_date
				NULL,                                   		    --p_key
				'SA.SP_MOBILE_ACCOUNT.GET_PART_NUM_FACTORS',   --p_program_name
				'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
			);
END GET_PART_NUM_FACTORS;
----------------------------------------------
-------------End of CR33035 Changes---------
----------------------------------------------
----------------------------------------------
-------------Start of CR33035 Changes---------
----------------------------------------------
PROCEDURE MA_Getesnattributes ( In_Esn     IN Table_Part_Inst.Part_Serial_No%Type,
                                Io_Key_Tbl IN OUT sa.TYP_MOBILEAPP_KEYS_TBL)
IS

    V_KEY_TBL sa.TYP_MOBILEAPP_KEYS_TBL := sa.TYP_MOBILEAPP_KEYS_TBL();
    V_ERR_NUM       INTEGER;
    V_ERR_STRING    VARCHAR2(4000);
    L_SERVICEPLANID NUMBER;
    L_SERVICEPLANNAME sa.X_SERVICE_PLAN.DESCRIPTION%TYPE;
    L_SERVICEPLANUNLIMITED NUMBER ; --1 if true and 0 if false
    L_AUTOREFILL           NUMBER ; --1 if true and 0 if false
    L_SERVICE_END_DT       DATE;
    l_Forecast_date        DATE;
    L_CREDITCARDREG        NUMBER; --1 if true and 0 if false
    L_REDEMPCARDQUEUE      NUMBER;
    L_CREDITCARDSCH        NUMBER ; --1 if true and 0 if false
    L_STATUSID             VARCHAR2(50);
    L_STATUSDESC           VARCHAR2(80);
    L_EMAIL                VARCHAR2(50);
    L_PART_NUM             VARCHAR2(40);
    ESN_exist              NUMBER;
    l_service_part_num     VARCHAR2(40);
    l_carier               VARCHAR2(40);
    l_billing_part_num     VARCHAR2(40);
    l_enrl_status          VARCHAR2(40);
    L_ENROLLMENT_STATUS    VARCHAR2(40);
    l_device_type          VARCHAR2(50);
    l_device_type_derived  VARCHAR2(50);
    l_device_family        VARCHAR2(50);
    l_manufacturer         VARCHAR2(50);
    l_operating_system     VARCHAR2(50);
    l_flash_text           VARCHAR2(2000);
    l_is_flash_hot         VARCHAR2(10);
    l_title		             VARCHAR2(80);
    l_csr_text             VARCHAR2(2000);
    l_spa_text             VARCHAR2(2000);
    l_ivr_script_id        VARCHAR2(10);
    l_tts_spanish          VARCHAR2(2000);
    l_tts_english          VARCHAR2(2000);
    -- CR35913 changes Starts..
    l_cos_value            x_serviceplanfeaturevalue_def.value_name%TYPE;
    l_threshold_value      x_policy_mapping_config.threshold%TYPE;
    l_rec_count            NUMBER;
    l_min_value            table_site_part.x_min%TYPE;
    l_hpp_eligible_cnt     NUMBER;
    l_hpp_enrolled_cnt     NUMBER;
    l_min_status           table_part_inst.x_part_inst_status%TYPE;
    l_is_line_reserved     VARCHAR2(10);
    l_account_group_id     x_account_group_member.account_group_id%TYPE;
    l_account_group_name   x_account_group.account_group_name%TYPE;
    l_service_plan_id      x_account_group.service_plan_id%TYPE;
    l_grp_no_of_lines      NUMBER;
    l_inquiry_type         VARCHAR2(20);

    -- CR35913 changes Ends.
    -- CR43248 Changes Starts..
    l_total_points         NUMBER;
    l_subscriber_id        VARCHAR2 (50);
    l_reward_total         NUMBER;
    l_lease_app_no         x_customer_lease.application_req_num%TYPE;
    l_master_esn_status    table_x_code_table.x_code_name%TYPE;
  	l_err_code             VARCHAR2(500);
    l_err_loc	             VARCHAR2(200);
    -- CR43248 Changes Ends
    -- CR44680 changes starts..
    l_url                  table_alert.url%TYPE;
    l_url_text_en          table_alert.url_text_en%TYPE;
    l_url_text_es          table_alert.url_text_es%TYPE;
    l_sms_text             table_alert.SMS_MESSAGE%TYPE;
    l_zip_code             table_site_part.x_zipcode%TYPE;
    l_vas_enrolled         VARCHAR2(2);
    -- CR44680 changes ends
    --
	  --CR45378 Starts
    o_sim_serial_no VARCHAR2(100);
    o_sim_status VARCHAR2(100);
    o_phone_carrier VARCHAR2(100);
    l_ota_pending          VARCHAR2(3);
    l_carrier_pending      VARCHAR2(3);
    l_pymt_src_avlbl       VARCHAR2(1);
	  --CR45378 Ends
    --CR47564 start
    o_pin                  VARCHAR2(6);
    i_min                  VARCHAR2(30);
    o_legacy_flag          VARCHAr2(1);
    --CR47564 end
    l_sim_part_class       VARCHAR2(100); -- CR47608
    l_sim_partnumber       VARCHAR2(100); -- CR47608
-- CR48383 Changes to block triple benefits for TF smartphones released after 4/4/17.
  -- mdave 03/27/2017
  l_block_triple_benefits_flag VARCHAR2(1);
   -- End CR48383
  l_safelink_esn VARCHAR2(1); -- CR51182
  l_master_esn   varchar2(100); --cr55236
  c_esn VARCHAR2(100);
    c_service_plan_part_class   VARCHAR2(40); --CR49696 WFM
    CURSOR get_esn_info_cur(In_Esn table_part_inst.part_serial_no%TYPE)
    IS
      SELECT esn.part_serial_no esn ,
        cpi.X_Esn_Nick_Name NICKNAME,
        ESN.X_PART_INST_STATUS STATUS,
        tpn.x_technology technology ,
        TBO.ORG_ID BRAND ,
        WU.LOGIN_NAME EMAIL,
		    WU.OBJID ACCOUNTID,  --CR45378
        ESN.X_ICCID SIM,
        line.part_serial_no MIN,
        CASE swa.objid
          WHEN NULL
          THEN 0
          WHEN swa.objid
          THEN 1
        END b2b,
        tpn.part_number part_num,
        pc.name part_class,
        cpi.x_is_default,  -- CR43248 added
        decode(ESN.X_PORT_IN,1,'Y','N') port_in_progress,     --  CR45378
        esn.objid esn_partinst_objid --CR #  47564 for WFM
      FROM TABLE_PART_INST ESN,
        table_part_inst line,
        TABLE_MOD_LEVEL TML,
        TABLE_PART_NUM TPN,
        TABLE_PART_Class pc,
        TABLE_BUS_ORG TBO,
        TABLE_X_CONTACT_PART_INST CPI,
        table_web_user wu,
        x_site_web_accounts swa
      WHERE 1                             = 1
      AND ESN.N_PART_INST2PART_MOD        = TML.OBJID
      AND TML.PART_INFO2PART_NUM          = TPN.OBJID
      AND TPN.PART_NUM2BUS_ORG            = TBO.OBJID
      AND tpn.part_num2part_class         = pc.objid
      AND ESN.OBJID                       = CPI.X_CONTACT_PART_INST2PART_INST(+)
      AND CPI.X_CONTACT_PART_INST2CONTACT = wu.WEB_USER2CONTACT(+)
      AND Wu.OBJID                        = SWA.SITE_WEB_ACCT2WEB_USER(+)
      AND ESN.PART_SERIAL_NO              = in_esn
      AND ESN.X_DOMAIN                    = 'PHONES'
      AND LINE.PART_TO_ESN2PART_INST(+)   = ESN.OBJID
      AND line.x_domain(+)                = 'LINES';
    GET_ESN_INFO_REC GET_ESN_INFO_CUR%ROWTYPE;
    CURSOR esn_plan_cur (enrl_status VARCHAR2,c_esn VARCHAR2)
    IS
      SELECT
        CASE
          WHEN pp.x_charge_frq_code IS NOT NULL
          THEN 1
          ELSE 0
        END autorefill,
        CASE INSTR(upper(pp.x_program_name) ,'UNLIMITED' ,1 ,1)
          WHEN 0
          THEN 0
          ELSE 1
        END ISUNLIMITED,
        sp.mkt_name sp_name,
        sp.objid sp_id,
        x_source_part_num service_partnum,
        x_target_part_num1 billing_partnum
      FROM sa.x_program_parameters pp,
        sa.x_program_enrolled pe,
        x_service_plan sp,
        mtm_sp_x_program_param mtm,
        x_ff_part_num_mapping fm
      WHERE 1                      = 1
      AND pp.objid                 = pe.pgm_enroll2pgm_parameter
      AND pgm_enroll2pgm_parameter = fm.x_ff_objid
      AND mtm.x_sp2program_param   = pp.objid
      AND mtm.program_para2x_sp    = sp.objid--find latest objid
      AND x_esn                    = c_esn
      AND pe.x_enrollment_status   = NVL(enrl_status,pe.x_enrollment_status);
    esn_plan_rec esn_plan_cur%rowtype;
    LV_SCRIPT_TEXT    VARCHAR2(2000);
    --
    -- CR35913 changes Starts..
    CURSOR get_service_days_ref_cur(C_PLAN_ID X_SERVICE_PLAN_FEATURE.SP_FEATURE2SERVICE_PLAN%TYPE) IS
    SELECT  SPFV.VALUE_REF
          FROM   X_SERVICEPLANFEATUREVALUE_DEF SPFVDEF, X_SERVICEPLANFEATURE_VALUE SPFV, X_SERVICE_PLAN_FEATURE SPF
              WHERE SPF.SP_FEATURE2SERVICE_PLAN = C_PLAN_ID
              AND SPF.SP_FEATURE2REST_VALUE_DEF = SPFVDEF.OBJID
              AND SPF.OBJID = SPFV.SPF_VALUE2SPF
              AND SPFVDEF.VALUE_NAME ='SERVICE DAYS';

    get_service_days_ref_rec get_service_days_ref_cur%rowtype;
    --
    CURSOR get_threshold_cur(c_cos_value x_serviceplanfeaturevalue_def.value_name%TYPE)
    IS
    SELECT threshold
    FROM   x_policy_mapping_config
    WHERE  cos            =  c_cos_value
    AND    usage_tier_id  = 2
    AND    ROWNUM         = 1;

    CURSOR pi_min_cur(c_min IN VARCHAR2)
     IS
     SELECT *
     FROM table_part_inst
     WHERE part_serial_no = c_min
     AND x_domain = 'LINES';
     --
     pi_min_rec pi_min_cur%ROWTYPE;

    CURSOR get_min_status_curs(c_esn table_part_inst.part_serial_no%TYPE)
     IS
     SELECT tpi_min.x_part_inst_status
     FROM table_part_inst tpi_esn
     JOIN table_part_inst tpi_min
     ON tpi_esn.objid = tpi_min.part_to_esn2part_inst
     WHERE tpi_esn.part_serial_no = c_esn
     AND tpi_esn.x_domain = 'PHONES'
     AND tpi_min.x_domain = 'LINES';
     --
     get_min_status_rec get_min_status_curs%ROWTYPE;
    -- CR35913 changes Ends.
    -- CR43248 commented below cursors
    -- Addd for CR37756 BY sethiraj 3/14/2016
   /* CURSOR account_group_id_cur IS
      SELECT account_group_id
        INTO l_account_group_id
        FROM x_account_group_member
       WHERE esn = in_esn; */
    -- Addd for CR37756 BY sethiraj 3/14/2016
   /* CURSOR account_group_name_cur(p_account_group_id IN x_account_group_member.account_group_id%TYPE) IS
      SELECT account_group_name,service_plan_id
        INTO l_account_group_name,l_service_plan_id
        FROM x_account_group
       WHERE objid = p_account_group_id;*/
    --
    -- CR46350 changes starts.
    gao    sa.customer_type  := customer_type ();
    --
    -- type to hold retrieved attributes
    cstg   sa.customer_type := customer_type ();
    -- CR46350 changes ends
    --
  BEGIN
    -- determine if the esn exists
    SELECT COUNT(1) --CR47564 change
    INTO ESN_exist
    FROM table_part_inst
    WHERE  part_serial_no = in_esn
    AND    x_domain = 'PHONES'; --CR47564 change
    IF ESN_exist                  = 0 THEN
      v_err_num                  := -1;
      V_ERR_STRING               := 'ESN DOES NOT EXIST'; --CR47564 change
      io_KEY_TBL(1).RESULT_VALUE := V_ERR_STRING;
      RETURN;
    END IF;
    IF (Io_Key_Tbl.Count          = 0) THEN
      V_ERR_NUM                  := 134; ---Input Key Value List Required.
      V_ERR_STRING               := sa.GET_CODE_FUN('PHONE_PKG', V_ERR_NUM, 'ENGLISH');
      io_KEY_TBL(1).RESULT_VALUE := V_ERR_STRING;
      RETURN;
    END IF;
    IF (Io_Key_Tbl.Count > 0) THEN
      V_Key_Tbl         := IO_KEY_TBL;
    END IF;


    OPEN get_esn_info_cur(In_Esn);
    FETCH get_esn_info_cur INTO get_esn_info_rec;
    IF get_esn_info_cur%notfound THEN
      CLOSE get_esn_info_cur;
    ELSE
      --

      OPEN get_min_status_curs(in_esn);  --CR43248
      FETCH get_min_status_curs INTO get_min_status_rec;  --CR43248
      -- only get the master esn for shared group brands (TW)
      IF customer_info.get_shared_group_flag ( i_bus_org_id => get_esn_info_rec.brand ) = 'Y' -- CR55236 get autorefill status of the master esn
      THEN
        l_master_esn := sa.brand_x_pkg.get_master_esn ( ip_account_group_id => sa.brand_x_pkg.get_account_group_id ( ip_esn            => in_esn ,
                                                                                                                     ip_effective_date => null   ) );
      END IF;
      --CR43248  - Condition added to include PAST DUE - LINE RESERVED
      --CR47564 WFM - Added status 51 (USED) to below condition
      IF GET_ESN_INFO_REC.STATUS IN('52', '50') OR ( GET_ESN_INFO_REC.STATUS IN ('54','51') AND get_min_status_rec.x_part_inst_status IN (37,38,39,73)) THEN
            SERVICE_PLAN.GET_SERVICE_PLAN_PRC( IP_ESN => IN_ESN, OP_SERVICEPLANID => l_SERVICEPLANID, OP_SERVICEPLANNAME => l_SERVICEPLANNAME, OP_SERVICEPLANUNLIMITED => l_SERVICEPLANUNLIMITED, OP_AUTOREFILL => l_AUTOREFILL, OP_SERVICE_END_DT => l_SERVICE_END_DT, OP_FORECAST_DATE => L_FORECAST_DATE, OP_CREDITCARDREG =>l_CREDITCARDREG, OP_REDEMPCARDQUEUE => l_REDEMPCARDQUEUE, OP_CREDITCARDSCH => l_CREDITCARDSCH, OP_STATUSID => l_STATUSID, OP_STATUSDESC => l_STATUSDESC, OP_EMAIL => L_EMAIL, OP_PART_NUM => L_PART_NUM, OP_ERR_NUM => V_ERR_NUM, OP_ERR_STRING => v_ERR_STRING );
      END IF;
      CLOSE get_min_status_curs;  --CR43248
      --
      -- CR43248 added the below call to get reward point attributes as requested
      -- CR43248 changes starts..
      sa.reward_points_pkg.p_get_reward_summary (  in_key            =>  'ESN',
                                                in_value          =>  in_esn,
                                                in_point_category =>  'REWARD_POINTS',
                                                out_total_points  =>  l_total_points,
                                                out_subscriber_id =>  l_subscriber_id,
                                                out_reward_total  =>  l_reward_total,
                                                out_err_code      =>  v_err_num,
                                                out_err_msg       =>  v_err_string);
      --
      -- Get lease application number
      BEGIN
        SELECT application_req_num
        INTO   l_lease_app_no
        FROM   x_customer_lease
        WHERE  x_esn        =   in_esn
        AND    lease_status IN  ('1001','1002','1005')
        AND    ROWNUM = 1;
      EXCEPTION
        WHEN OTHERS THEN
          l_lease_app_no  := NULL;
      END;
      --
       -- Get Account Group details
      BEGIN
        SELECT xagm.account_group_id,xag.account_group_name,xag.service_plan_id
        INTO   l_account_group_id,l_account_group_name,l_service_plan_id
        FROM   x_account_group_member xagm,
               x_account_group        xag,
               (SELECT MAX(agm.objid) objid
                FROM   x_account_group_member agm
                WHERE  agm.esn      = In_Esn
                AND    agm.status   <>  'EXPIRED'
                AND SYSDATE BETWEEN agm.start_date AND NVL(agm.end_date,SYSDATE)
                GROUP BY agm.esn) agm1
        WHERE agm1.objid    =   xagm.objid
        AND   xag.objid     =   xagm.account_group_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_account_group_id    :=  NULL;
          l_account_group_name  :=  NULL;
          l_service_plan_id     :=  NULL;
      END;
      --
	    -- Get status of Master ESN of the Group
      BEGIN
        SELECT  tc.x_code_name
        INTO    l_master_esn_status
        FROM    x_account_group_member  agm,
                table_part_inst         pi,
                table_x_code_table      tc
        WHERE   agm.account_group_id  =   l_account_group_id
        AND     pi.part_serial_no     =   agm.esn
        AND     tc.objid              =   pi.status2x_code_table
        AND     agm.master_flag       =   'Y'
        AND     agm.status            <>  'EXPIRED'
        AND     ROWNUM = 1;
      EXCEPTION
        WHEN OTHERS THEN
          l_master_esn_status    :=  NULL;
      END;
      -- CR43248 changes ends
      --
      -- CR44680 changes starts
      BEGIN
         SELECT  sp.x_zipcode
         INTO    l_zip_code
         FROM    table_part_inst pi,
                table_site_part sp
         WHERE   1 = 1
         AND    pi.part_serial_no =  in_esn
         AND    pi.x_domain = 'PHONES'
         AND    pi.part_serial_no = sp.x_service_id
         And    install_date  =  (SELECT MAX (SP.install_date)
                                 FROM table_site_part sp
                                 WHERE sp.x_service_id = in_esn);
      EXCEPTION
        WHEN OTHERS THEN
          l_zip_code    :=  NULL;
      END;
      --
      -- Get l_vas_enrolled flag
      BEGIN
        SELECT  DECODE(COUNT(*),0,'N','Y')
        INTO    l_vas_enrolled
        FROM    x_program_enrolled pe,
                x_program_parameters xpp
        WHERE   pe.x_esn                    = in_esn
        AND     pe.x_enrollment_status      = 'ENROLLED'
        AND     pe.pgm_enroll2pgm_parameter = xpp.objid
        AND     xpp.x_prog_class            = 'LOWBALANCE'
        AND     xpp.x_program_desc          LIKE '%ILD%';
      EXCEPTION
        WHEN OTHERS THEN
          l_vas_enrolled    :=  NULL;
      END;
	    --
      --CR44680 changes ends
      --CR45378 changes starts
      BEGIN
        IF GET_ESN_INFO_REC.STATUS  = '52' THEN
           SELECT 'Y'
           INTO   l_ota_pending
           FROM   table_part_inst pi
           WHERE  1 = 1
           AND    pi.part_serial_no    = in_esn
           AND    pi.x_domain          = 'PHONES'
           AND    EXISTS  (SELECT 1
                           FROM   table_x_ota_transaction      ot,
                                  table_x_call_trans           ct
                                  WHERE  pi.part_serial_no           = ot.x_esn
                                  AND    ot.x_ota_trans2x_call_trans = ct.objid
                                  AND    ot.x_status                 = 'OTA PENDING'
                                  AND    ot.x_action_type            IN (1,3,6,7));--CR55236 added 7
         END IF;
      EXCEPTION
          WHEN OTHERS THEN
            l_ota_pending := 'N';
      END;
	    --
      BEGIN
        IF GET_ESN_INFO_REC.STATUS  = '52'
        THEN
          SELECT   DISTINCT 'Y'
          INTO   l_carrier_pending
          FROM  (
                SELECT 'Y'
                FROM   table_part_inst           pi,
                       table_site_part           sp,
                       table_x_call_trans        ct,
                       x_switchbased_transaction sbt
                WHERE  ct.call_trans2site_part = sp.objid
                AND    ct.x_action_type        IN (1,3,6)
                AND    pi.part_serial_no       = sp.x_service_id
                AND    pi.x_domain             = 'PHONES'
                AND    pi.part_serial_no       = in_esn
                AND    sp.part_status||''      = 'CarrierPending'
                AND    ct.objid                = sbt.x_sb_trans2x_call_trans
                AND    ct.x_transact_date      =   (SELECT MAX(x_transact_date)
                                                   FROM   table_x_call_trans
                                                   WHERE  x_action_type IN (1,3,6)
                                                   AND    x_service_id  = in_esn)
                UNION
                SELECT 'Y'
                FROM   table_x_call_trans        ct,
                       x_switchbased_transaction sbt
                WHERE  ct.objid                =  sbt.x_sb_trans2x_call_trans
                AND    sbt.status              =  'CarrierPending'
                AND    ct.x_action_type        IN (1,3,6)
                AND    ct.x_service_id         =  in_esn
                AND    ct.x_transact_date      =  (SELECT MAX(x_transact_date)
                                                   FROM   table_x_call_trans
                                                   WHERE  x_action_type IN (1,3,6)
                                                   AND    x_service_id  = in_esn));
        END IF;
      EXCEPTION
          WHEN OTHERS THEN
             l_carrier_pending := 'N';
      END;
      --

      SELECT DECODE (COUNT(*), 0, 'N', 'Y')
      INTO  l_pymt_src_avlbl
      FROM  x_payment_source ps
      WHERE ps.pymt_src2web_user  = get_esn_info_rec.ACCOUNTID
      AND   ps.x_status           = 'ACTIVE';
      --CR45378 changes ends
 --
-- CR48383 Changes to block triple benefits for TF smartphones released after 4/4/17.
-- mdave 03/13/2017
BEGIN
 l_block_triple_benefits_flag := NULL;
l_block_triple_benefits_flag := sa.BLOCK_TRIPLE_BENEFITS(in_esn);
DBMS_OUTPUT.PUT_LINE('ESN - '||in_esn );
DBMS_OUTPUT.PUT_LINE('block_flag - '||l_block_triple_benefits_flag );
 END;
 -- CR48383 END
      --
      FOR i IN V_Key_Tbl.FIRST..V_Key_Tbl.LAST
      LOOP
        --CR#47564 for WFM -Added below key type ESN_PARTINST_OBJID
        IF (V_Key_Tbl(i).Key_Type IN ('ESN_PARTINST_OBJID')) THEN
          V_Key_tbl(i).key_Value := get_esn_info_rec.esn_partinst_objid;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_Key_Tbl(i).Key_Type IN ('NICKNAME')) THEN
          V_Key_tbl(i).key_Value := get_esn_info_rec.NICKNAME;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_Key_Tbl(i).Key_Type IN ('BRAND')) THEN
          V_Key_tbl(i).key_Value := get_esn_info_rec.BRAND;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_Key_Tbl(i).Key_Type IN ('SIM')) THEN
          V_Key_tbl(i).key_Value := get_esn_info_rec.SIM;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_Key_Tbl(i).Key_Type IN ('EMAIL')) THEN
          V_Key_tbl(i).key_Value := get_esn_info_rec.EMAIL;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_KEY_TBL(I).KEY_TYPE IN ('STATUS')) THEN
          V_KEY_TBL(i).KEY_VALUE := GET_ESN_INFO_REC.STATUS;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_KEY_TBL(I).KEY_TYPE IN ('TECHNOLOGY')) THEN
          V_KEY_TBL(i).KEY_VALUE := GET_ESN_INFO_REC.TECHNOLOGY;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_KEY_TBL(i).KEY_TYPE IN ('MIN')) THEN
          -- CR35913 changes Starts..
          -- Before getting the MIN value for the given ESN check for the for cases where multiple records are returned
          l_rec_count := 0;
          --
          SELECT COUNT(1)
          INTO   l_rec_count
          FROM   table_part_inst
          WHERE  x_domain              = 'LINES'
          AND    part_to_esn2part_inst = (SELECT objid FROM table_part_inst WHERE part_serial_no = in_esn);
          -- Incase of multiple records, get the MIN value as given below
          IF  l_rec_count > 1 THEN
            SELECT MIN
            INTO   l_min_value
            FROM
              (SELECT TABLE_SITE_PART.X_MIN MIN
              FROM    sa.table_site_part
              WHERE   sa.table_site_part.x_service_id = in_esn
              ORDER BY install_date DESC
              )
            WHERE  ROWNUM < 2;
            --
            V_Key_tbl(i).key_Value := l_min_value;
          ELSE
            -- CR35913 changes Ends.
            V_Key_tbl(i).key_Value := GET_ESN_INFO_REC.MIN;
          END IF;
          --
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_KEY_TBL(i).KEY_TYPE IN ('ISB2B')) THEN
          V_KEY_TBL(i).KEY_VALUE := '1';
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_KEY_TBL(i).KEY_TYPE IN ('HASREGEDPAYMENTSOURCES')) THEN
          V_KEY_TBL(i).KEY_VALUE := l_CREDITCARDREG;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_KEY_TBL(i).KEY_TYPE IN ('QUEUESIZE')) THEN
 --start
 IF NVL(l_REDEMPCARDQUEUE,0) = 0
 AND GET_ESN_INFO_REC.STATUS IN ('51','54')
 AND NVL(get_min_status_rec.x_part_inst_status, 'X') = 'X' --MIN not present or removed
 THEN --{
 SELECT COUNT(1)
 INTO l_REDEMPCARDQUEUE
 FROM table_part_inst pi_esn,
 table_part_inst pi_card,
 table_mod_level ml,
 table_part_num pn
 WHERE 1 = 1
 AND pi_esn.part_serial_no = in_esn
 AND pi_esn.x_domain = 'PHONES'
 AND pi_card.part_to_esn2part_inst = pi_esn.objid
 AND pi_card.x_part_inst_status||'' = '400'
 AND pi_card.x_domain||'' = 'REDEMPTION CARDS'
 AND pi_card.n_part_inst2part_mod = ml.objid
 AND ml.part_info2part_num = pn.objid;
 END IF; --}
 --end
          V_KEY_TBL(i).KEY_VALUE := l_REDEMPCARDQUEUE;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_KEY_TBL(i).KEY_TYPE IN ('ENDOFSERVICEDATE')) THEN
          V_KEY_TBL(I).KEY_VALUE := L_SERVICE_END_DT;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_KEY_TBL(i).KEY_TYPE IN ('SERVICE_END_DATE')) THEN --WFM added as requested by SOA to send in YYYYMMDD
          V_KEY_TBL(I).KEY_VALUE := TO_CHAR(L_SERVICE_END_DT,'YYYYMMDD');
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_KEY_TBL(i).KEY_TYPE IN ('FORECASTDATE')) THEN
          V_KEY_TBL(i).KEY_VALUE := l_FORECAST_DATE;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        --START OF CR32032
        IF (V_KEY_TBL(i).KEY_TYPE IN ('ESN')) THEN
          V_KEY_TBL(i).KEY_VALUE := in_esn;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_KEY_TBL(i).KEY_TYPE IN ('CURRENT_SERV_PLAN_ID')) THEN
          DBMS_OUTPUT.PUT_LINE('Inside CURRENT_SERV_PLAN_ID with l_SERVICEPLANID:'||l_SERVICEPLANID);
          V_KEY_TBL(i).KEY_VALUE := l_SERVICEPLANID;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
          /*IF (V_KEY_TBL(i).KEY_TYPE IN ('CURRENT_SERV_PLAN_NAME')) THEN
          DBMS_OUTPUT.PUT_LINE('Inside CURRENT_SERV_PLAN_NAME with l_SERVICEPLANID:'||l_SERVICEPLANID||'; l_SERVICEPLANNAME:'||l_SERVICEPLANNAME);
          V_KEY_TBL(i).KEY_VALUE := l_SERVICEPLANNAME;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;*/

        IF (V_KEY_TBL(i).KEY_TYPE IN ('ISAUTOREFILL'))
        THEN
          DBMS_OUTPUT.PUT_LINE('Inside ISAUTOREFILL with l_AUTOREFILL:'||l_AUTOREFILL);
          V_KEY_TBL(i).KEY_VALUE := CASE
                                      WHEN l_master_esn IS NOT NULL THEN customer_info.isautorefill ( i_esn => l_master_esn )
                                    ELSE
                                      l_autorefill
                                    END; --CR55236 For the shared group brands autorefill status needs to be based on the master esn

          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        -- CR51182 Return plan_type for SL
        IF (V_KEY_TBL(i).KEY_TYPE IN ('PLAN_TYPE')) THEN
          DBMS_OUTPUT.PUT_LINE('Inside PLAN_TYPE with l_SERVICEPLANID:'||L_SERVICEPLANID);
          V_KEY_TBL(i).KEY_VALUE := sa.get_serv_plan_value(L_SERVICEPLANID,'PLAN TYPE');
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
            INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        --CR51182
        IF (V_Key_Tbl(i).Key_Type IN ('CURRENT_SP_MOBILE_DESC1')) THEN
          DBMS_OUTPUT.PUT_LINE('Inside MOBILE_DESCRIPTION1 with l_SERVICEPLANID:'||l_SERVICEPLANID);
          BEGIN
            LV_SCRIPT_TEXT:= NULL;
            LV_SCRIPT_TEXT := sa.QUEUE_CARD_PKG.FN_GET_SCRIPT_TEXT_BY_SP_DESC(l_SERVICEPLANID,'MOBILE_DESCRIPTION1', get_esn_info_rec.BRAND );
            SELECT  LV_SCRIPT_TEXT
            INTO    V_Key_tbl(i).key_Value
            FROM    DUAL;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              DBMS_OUTPUT.PUT_LINE('l_SERVICEPLANID: '||l_SERVICEPLANID||' DOES NOT EXIST');
          END;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_Key_Tbl(i).Key_Type IN ('CURRENT_SP_MOBILE_DESC2')) THEN
          DBMS_OUTPUT.PUT_LINE('Inside MOBILE_DESCRIPTION2 with l_SERVICEPLANID:'||l_SERVICEPLANID);
          LV_SCRIPT_TEXT:= NULL;
          LV_SCRIPT_TEXT := sa.QUEUE_CARD_PKG.FN_GET_SCRIPT_TEXT_BY_SP_DESC(l_SERVICEPLANID,'MOBILE_DESCRIPTION2', get_esn_info_rec.BRAND );
          BEGIN
            SELECT  LV_SCRIPT_TEXT
            INTO    V_Key_tbl(i).key_Value
            FROM    DUAL;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              DBMS_OUTPUT.PUT_LINE('l_SERVICEPLANID: '||l_SERVICEPLANID||' DOES NOT EXIST');
          END;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        --END OF CR32032
        --Start of CR33035
        IF (V_Key_Tbl(i).Key_Type IN ('CURRENT_SP_MOBILE_DESC3')) THEN
          DBMS_OUTPUT.PUT_LINE('Inside MOBILE_DESCRIPTION3 with l_SERVICEPLANID:'||l_SERVICEPLANID);
          LV_SCRIPT_TEXT:= NULL;
          LV_SCRIPT_TEXT := sa.QUEUE_CARD_PKG.FN_GET_SCRIPT_TEXT_BY_SP_DESC(l_SERVICEPLANID,'MOBILE_DESCRIPTION3', get_esn_info_rec.BRAND );
          BEGIN
            SELECT  LV_SCRIPT_TEXT
            INTO    V_Key_tbl(i).key_Value
            FROM    DUAL;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              DBMS_OUTPUT.PUT_LINE('l_SERVICEPLANID: '||l_SERVICEPLANID||' DOES NOT EXIST');
          END;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_Key_Tbl(i).Key_Type IN ('CURRENT_SP_MOBILE_DESC4')) THEN
          DBMS_OUTPUT.PUT_LINE('Inside MOBILE_DESCRIPTION4 with l_SERVICEPLANID:'||l_SERVICEPLANID);
          DBMS_OUTPUT.PUT_LINE('get_esn_info_rec.BRAND: '||get_esn_info_rec.BRAND);
          LV_SCRIPT_TEXT:= NULL;
          LV_SCRIPT_TEXT := sa.QUEUE_CARD_PKG.FN_GET_SCRIPT_TEXT_BY_SP_DESC(l_SERVICEPLANID,'MOBILE_DESCRIPTION4', get_esn_info_rec.BRAND );
          DBMS_OUTPUT.PUT_LINE('LV_SCRIPT_TEXT: '||LV_SCRIPT_TEXT);
          BEGIN
            SELECT  LV_SCRIPT_TEXT
            INTO    V_Key_tbl(i).key_Value
            FROM    DUAL;
            DBMS_OUTPUT.PUT_LINE('V_Key_tbl(i).key_Value: '||V_Key_tbl(i).key_Value);
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              DBMS_OUTPUT.PUT_LINE('l_SERVICEPLANID: '||l_SERVICEPLANID||' DOES NOT EXIST');
          END;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        --End of CR33035
        IF (V_KEY_TBL(i).KEY_TYPE IN ('DEVICE_PARTNUMBER')) THEN
          V_KEY_TBL(i).KEY_VALUE := GET_ESN_INFO_REC.part_num;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_KEY_TBL(i).KEY_TYPE IN ('DEVICE_PARTCLASS')) THEN
          V_KEY_TBL(i).KEY_VALUE := GET_ESN_INFO_REC.part_class;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (V_KEY_TBL(i).KEY_TYPE IN ('ENROLLMENT_STATUS')) THEN
          BEGIN
            SELECT X_ENROLLMENT_STATUS
            INTO l_ENROLLMENT_STATUS
            FROM x_program_enrolled
            WHERE objid =
              (SELECT MAX(objid) FROM x_program_enrolled WHERE x_esn = in_esn
              );
          EXCEPTION
          WHEN OTHERS THEN
            V_Key_Tbl(i).Key_Type     := 'ENROLLMENT_STATUS';
            V_Key_tbl(i).key_Value    := 0;
            V_KEY_TBL(i).RESULT_VALUE := 'Fail';
          END;
          V_KEY_TBL(i).KEY_VALUE := l_ENROLLMENT_STATUS;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        IF (GET_ESN_INFO_REC.STATUS = '52') THEN
          l_enrl_status            := 'ENROLLED';
        ELSE
          l_enrl_status := 'ENROLLMENTPENDING';
        END IF ;
        IF (V_KEY_TBL(i).KEY_TYPE IN ('ISUNLIMITED')) OR (V_KEY_TBL(I).KEY_TYPE IN ('SERVICEPLANNAME')) OR (V_KEY_TBL(i).KEY_TYPE IN ('SERVICEPLANID')) OR (V_KEY_TBL(i).KEY_TYPE IN ('ISAUTOREFILL')) OR (V_KEY_TBL(i).KEY_TYPE IN ('SERVICE_PARTNUMBER')) OR (V_KEY_TBL(i).KEY_TYPE IN ('BILLING_PARTNUMBER')) THEN
          OPEN esn_plan_cur(l_enrl_status,NVL(l_master_esn,in_esn)) ; --CR55236 for shared groups get the autorefill status of master esn
          FETCH esn_plan_cur INTO esn_plan_rec;
          IF esn_plan_cur%notfound THEN
            CLOSE esn_plan_cur;
          ELSE
            IF (V_KEY_TBL(i).KEY_TYPE IN ('ISUNLIMITED')) THEN
              V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.ISUNLIMITED;
              SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
              INTO V_KEY_TBL(i).RESULT_VALUE
              FROM dual;
            END IF;
            IF (V_KEY_TBL(I).KEY_TYPE IN ('SERVICEPLANNAME')) THEN
              V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.sp_name;
              SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
              INTO V_KEY_TBL(i).RESULT_VALUE
              FROM dual;
            END IF;
            IF (V_KEY_TBL(i).KEY_TYPE IN ('SERVICEPLANID')) THEN
              V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.sp_id;
              SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
              INTO V_KEY_TBL(i).RESULT_VALUE
              FROM dual;
            END IF;
            IF (V_KEY_TBL(i).KEY_TYPE IN ('ISAUTOREFILL')) THEN
              V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.AUTOREFILL;
              SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
              INTO V_KEY_TBL(i).RESULT_VALUE
              FROM dual;
            END IF;
            IF (V_KEY_TBL(i).KEY_TYPE IN ('SERVICE_PARTNUMBER')) THEN
              V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.service_partnum;
              SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
              INTO V_KEY_TBL(i).RESULT_VALUE
              FROM dual;
            END IF;
            IF (V_KEY_TBL(i).KEY_TYPE IN ('BILLING_PARTNUMBER')) THEN
              V_KEY_TBL(i).KEY_VALUE := esn_plan_rec.billing_partnum;
              SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
              INTO V_KEY_TBL(i).RESULT_VALUE
              FROM dual;
            END IF;
            CLOSE esn_plan_cur;
          END IF;
        END IF;
        IF (GET_ESN_INFO_REC.STATUS = '52') THEN
          IF (V_KEY_TBL(i).KEY_TYPE IN ('CARRIER')) THEN
            BEGIN
              SELECT p.x_parent_name
              INTO l_carier
              FROM table_site_part sp,
                table_part_inst pi,
                table_x_carrier ca,
                table_x_carrier_group cg,
                table_x_parent p
              WHERE 1               =1
              AND sp.x_service_id   = in_esn
              AND pi.part_serial_no = sp.x_min
              AND pi.x_domain       = 'LINES'
              AND sp.part_status    = 'Active'
              AND ca.objid          = pi.part_inst2carrier_mkt
              AND cg.objid          = ca.CARRIER2CARRIER_GROUP
              AND p.objid           = cg.X_CARRIER_GROUP2X_PARENT;
            EXCEPTION
            WHEN OTHERS THEN
              V_Key_Tbl(i).Key_Type     := 'CARRIER';
              V_Key_tbl(i).key_Value    := 0;
              V_KEY_TBL(i).RESULT_VALUE := 'Fail';
            END;
            V_KEY_TBL(i).KEY_VALUE    := l_carier;
            V_KEY_TBL(i).RESULT_VALUE := 'success';
          END IF;
        END IF;
        /* -- New logic is implemented. Please refer the code after this comment.
        IF (v_key_tbl(i).key_type IN ('DEVICE_TYPE')) THEN -- Added for My Account Phase II: CR35913
          sa.sp_get_esn_parameter_value(in_esn,'DEVICE_TYPE',0, p_parameter_value => l_device_type,p_error_code =>v_err_num, p_error_message=>v_err_string);
          v_key_tbl(i).key_value := l_device_type;
          SELECT nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO v_key_tbl(i).result_value
          FROM dual;
        END IF;
        */
        IF (v_key_tbl(i).key_type IN ('DEVICE_TYPE')) THEN -- Added for My Account Phase II: CR35913
          --
          -- Get the values for DEVICE_TYPE,MANUFACTURER,OPERATING_SYSTEM
          sa.sp_get_esn_parameter_value(in_esn,'DEVICE_TYPE',     0, p_parameter_value => l_device_type,     p_error_code =>v_err_num, p_error_message=>v_err_string);
          sa.sp_get_esn_parameter_value(in_esn,'MANUFACTURER',    0, p_parameter_value => l_manufacturer,    p_error_code =>v_err_num, p_error_message=>v_err_string);
          sa.sp_get_esn_parameter_value(in_esn,'OPERATING_SYSTEM',0, p_parameter_value => l_operating_system,p_error_code =>v_err_num, p_error_message=>v_err_string);
          --
          IF l_manufacturer IN ('BYOP','BYOT') THEN
            l_device_type_derived := l_manufacturer;
          ELSIF l_device_type = 'MOBILE_BROADBAND' THEN
            l_device_type_derived := 'HOTSPOT';
          ELSIF l_device_type = 'SMARTPHONE' AND l_operating_system = 'ANDROID' THEN
            l_device_type_derived := 'SMARTPHONE';
          ELSIF l_device_type = 'WIRELESS_HOME_PHONE' THEN
            l_device_type_derived := 'HOMEPHONE';
          ELSIF l_device_type = 'M2M' THEN
            --
            SELECT sa.sp_metadata.model_taxes(in_esn)
            INTO   l_device_family
            FROM   dual;
            --
            IF l_device_family = 'HOME ALERT' THEN
              l_device_type_derived := 'HOME_ALERT';
            ELSIF l_device_family = 'CAR CONNECT' THEN
              l_device_type_derived := 'CAR_CONNECT';
            ELSIF l_device_family = 'HOME_CENTER' THEN
              l_device_type_derived :=  'HOME_CENTER';
            ELSE
              l_device_type_derived := l_device_type;
            END IF;
          ELSE
            l_device_type_derived   := l_device_type;
          END IF;
          -- Assign the l_device_type_derived value to the key value (device type)
          v_key_tbl(i).key_value := l_device_type_derived;
          SELECT nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO v_key_tbl(i).result_value
          FROM dual;
        END IF;

       IF (v_key_tbl(i).key_type = 'SAFELINK_ASSIST_FLAG') --{ 51056 start
       THEN
       BEGIN --{
        SELECT NVL(sa.get_safelinkassist_flag (in_esn), 'N')
        INTO   v_key_tbl(i).key_value
        FROM   dual;
        v_key_tbl(i).result_value := 'success';
       EXCEPTION
       WHEN OTHERS THEN
        v_key_tbl(i).key_value := 'N';
        v_key_tbl(i).result_value := 'fail';
       END; --}
       END IF; --} 51056 end

 -- CR#50134 WFM Changes --Start
 IF (v_key_tbl(i).key_type IN ('FLASH_TEXT','IS_FLASH_HOT','FLASH_URL','FLASH_URL_TEXT','FLASH_SPAN_TEXT')) THEN
	 --
 BEGIN
 alert_pkg.get_alert (esn => in_esn ,
 step => 0 ,
 channel => 'WEB' ,
 title => l_title ,
 csr_text => l_csr_text ,
 eng_text => l_flash_text ,
 spa_text => l_spa_text ,
 ivr_scr_id => l_ivr_script_id,
 tts_english => l_tts_english ,
 tts_spanish => l_tts_spanish ,
 hot => l_is_flash_hot ,
 err => l_err_code ,
 msg => v_err_string ,
 op_url => l_url ,
 op_url_text_en => l_url_text_en ,
 op_url_text_es => l_url_text_es ,
 op_sms_text => l_sms_text );
	 EXCEPTION
 WHEN OTHERS THEN
	 l_err_loc := CASE v_key_tbl(i).key_type
	 WHEN 'FLASH_TEXT' THEN 'Error in getting FLASH_TEXT'
	 WHEN 'IS_FLASH_HOT' THEN 'Error in getting IS_FLASH_HOT'
	 WHEN 'FLASH_URL' THEN 'Error in getting FLASH_URL'
	 WHEN 'FLASH_URL_TEXT' THEN 'Error in getting FLASH_URL_TEXT'
	 WHEN 'FLASH_SPAN_TEXT' THEN 'Error in getting FLASH_SPAN_TEXT'
	 ELSE NULL
 	 END;
 v_err_num := SQLCODE;
 v_err_string := l_err_loc || SUBSTR(SQLERRM,1, 300);
 util_pkg.insert_error_tab_proc ( ip_action => NULL,
 ip_key => SUBSTR(in_esn||';', 1, 50),
					 ip_program_name => 'SA.SP_MOBILE_ACCOUNT.ma_getesnattributes',
					 ip_error_text => v_err_string		 );
 END;

	 --Assignment to key value variable based on key type
 v_key_tbl(i).key_value := CASE v_key_tbl(i).key_type
	 WHEN 'FLASH_TEXT' THEN l_flash_text
	 WHEN 'IS_FLASH_HOT' THEN l_is_flash_hot
	 WHEN 'FLASH_URL' THEN l_url
	 WHEN 'FLASH_URL_TEXT' THEN l_url_text_en
	 WHEN 'FLASH_SPAN_TEXT' THEN l_spa_text
	 ELSE NULL
 	 END;

 --
	 SELECT NVL2(v_key_tbl(i).key_value ,'success','Fail')
 INTO v_key_tbl(i).result_value
 FROM dual;

 END IF;
 --CR#50134 WFM Changes --End
        -- CR44680 added below attributes, changes ends
        IF (v_key_tbl(i).key_type IN ('SERVICEDAYS')) THEN -- Added for My Account Phase II: CR35913
             OPEN get_service_days_ref_cur(l_serviceplanid);
             fetch get_service_days_ref_cur INTO get_service_days_ref_rec;
             IF get_service_days_ref_cur%found AND get_service_days_ref_rec.value_ref IS NOT NULL THEN
                SELECT regexp_replace(display_name, '[^0-9]+', '') AS display_name INTO v_key_tbl(i).key_value FROM x_serviceplanfeaturevalue_def    WHERE objid = get_service_days_ref_rec.value_ref;
             END IF;
             CLOSE get_service_days_ref_cur;
          SELECT nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO v_key_tbl(i).result_value
          FROM dual;
        END IF;
        IF (v_key_tbl(i).key_type IN ('DOM_DATA_THRESHOLD')) THEN -- Added for My Account Phase II: CR35913
          dbms_output.put_line('Inside DOM_DATA_THRESHOLD with l_SERVICEPLANID:'||l_serviceplanid);
          --
          cstg.add_ons_cos := gao.get_add_ons (i_esn  =>  in_esn);  -- CR46350
          -- Get the COS value
 --l_cos_value := sa.adfcrm_scripts.get_feature_value(l_serviceplanid,'COS');
 l_cos_value := sa.get_cos(in_esn);
          --
          OPEN get_threshold_cur(l_cos_value);
          FETCH get_threshold_cur INTO l_threshold_value;
          CLOSE get_threshold_cur;
          --
          lv_script_text:= NULL;
          --lv_script_text := l_threshold_value + NVL(cstg.add_ons_cos,0);  -- CR46350
          lv_script_text   := l_threshold_value;  -- CR51860 removing add_on from calculation.
          dbms_output.put_line('l_threshold_value: '||lv_script_text);
          BEGIN
            SELECT  lv_script_text
            INTO    v_key_tbl(i).key_value
            FROM    dual;
            dbms_output.put_line('V_Key_tbl(i).key_Value: '||v_key_tbl(i).key_value);
          EXCEPTION
            WHEN no_data_found THEN
              dbms_output.put_line('l_SERVICEPLANID: '||l_serviceplanid||' DOES NOT EXIST');
          END;
          SELECT nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO v_key_tbl(i).result_value
          FROM dual;
        END IF;
        --  CR47564 WFM changes starts..
        IF (v_key_tbl(i).key_type IN ('BASE_DATA_THRESHOLD'))
        THEN
          dbms_output.put_line('Inside BASE_DATA_THRESHOLD with l_SERVICEPLANID:'||l_serviceplanid);
          -- Get the COS value
          l_cos_value := sa.adfcrm_scripts.get_feature_value(l_serviceplanid,'COS');
          --
          OPEN get_threshold_cur(l_cos_value);
          FETCH get_threshold_cur INTO l_threshold_value;
          CLOSE get_threshold_cur;
          --
          lv_script_text  := NULL;
          lv_script_text  := l_threshold_value;
          dbms_output.put_line('l_threshold_value: '||lv_script_text);
          BEGIN
            SELECT  lv_script_text
            INTO    v_key_tbl(i).key_value
            FROM    dual;
            dbms_output.put_line('V_Key_tbl(i).key_Value: '||v_key_tbl(i).key_value);
          EXCEPTION
            WHEN no_data_found THEN
              dbms_output.put_line('l_SERVICEPLANID: '||l_serviceplanid||' DOES NOT EXIST');
          END;
          SELECT nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO v_key_tbl(i).result_value
          FROM dual;
        END IF;
        --
        IF (v_key_tbl(i).key_type IN ('ADD_ON_THRESHOLD'))
        THEN
          dbms_output.put_line('Inside ADD_ON_THRESHOLD with l_SERVICEPLANID:'||l_serviceplanid);
          --
          cstg.add_ons_cos := gao.get_add_ons (i_esn  =>  in_esn);
          --
          lv_script_text  := NULL;
          lv_script_text  := NVL(cstg.add_ons_cos,0);
          dbms_output.put_line('l_threshold_value: '||lv_script_text);
          BEGIN
            SELECT  lv_script_text
            INTO    v_key_tbl(i).key_value
            FROM    dual;
            dbms_output.put_line('V_Key_tbl(i).key_Value: '||v_key_tbl(i).key_value);
          EXCEPTION
            WHEN no_data_found THEN
              dbms_output.put_line('NO ADD ONS');
          END;
          SELECT nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO v_key_tbl(i).result_value
          FROM dual;
        END IF;
        --  CR47564 WFM changes ends.
        IF (v_key_tbl(i).key_type IN ('IS_HPP_ELIGIBLE')) THEN -- Added for My Account Phase II: CR35913
          SELECT  COUNT(1)
          INTO    l_hpp_eligible_cnt
          FROM    TABLE(value_addedprg.geteligiblewtyprograms(in_esn));
          --
          IF l_hpp_eligible_cnt > 0
          THEN
            v_key_tbl(i).key_value := 'TRUE';
          ELSE
            v_key_tbl(i).key_value := 'FALSE';
          END IF;
          --
          SELECT  nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO    v_key_tbl(i).result_value
          FROM    dual;
        END IF;
        IF (v_key_tbl(i).key_type IN ('IS_HPP_ENROLLED')) THEN -- Added for My Account Phase II: CR35913
          SELECT count(pe.objid)
          INTO   l_hpp_enrolled_cnt
          FROM   sa.x_program_enrolled pe,
                 sa.x_program_parameters pp,
                 sa.table_part_num pn,
                 sa.table_handset_msrp_tiers tr,
                 sa.x_mtm_program_msrp protr
          WHERE  pe.x_esn                   = in_esn
          AND    pe.x_enrollment_status NOT  IN('DEENROLLED','ENROLLMENTFAILED','READYTOREENROLL')
          AND    pp.objid                     = pe.pgm_enroll2pgm_parameter
          AND    pp.x_prog_class              = 'WARRANTY'
          AND    pn.objid                     = pp.prog_param2prtnum_monfee
          AND    tr.objid                     = protr.pgm_msrp2handset_msrp_tier
          AND    protr.pgm_msrp2pgm_parameter = pp.objid
		  AND    pp.objid NOT IN  ( SELECT program_parameters_objid
								    FROM   vas_programs_view
								    WHERE  program_parameters_objid IS NOT NULL
								    AND    vas_product_type      = 'HANDSET PROTECTION'
								    UNION
								    SELECT auto_pay_program_objid
								    FROM   vas_programs_view
								    WHERE  auto_pay_program_objid IS NOT NULL
								    AND    vas_product_type      = 'HANDSET PROTECTION'
								  ); -- CR49058 to restrict new warranty programs
          --
          IF l_hpp_enrolled_cnt > 0
          THEN
            v_key_tbl(i).key_value := 'TRUE';
          ELSE
            v_key_tbl(i).key_value := 'FALSE';
          END IF;
          --
          SELECT  nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO    v_key_tbl(i).result_value
          FROM    dual;
        END IF;
        IF (v_key_tbl(i).key_type IN ('IS_LINE_RESERVED')) THEN -- Added for My Account Phase II: CR35913
          -- Before getting the MIN value for the given ESN check for the for cases where multiple records are returned
          l_rec_count := 0;
          --
          SELECT COUNT(1)
          INTO   l_rec_count
          FROM   table_part_inst
          WHERE  x_domain              = 'LINES'
          AND    part_to_esn2part_inst = (SELECT objid FROM table_part_inst WHERE part_serial_no = in_esn);
          -- Incase of multiple records, get the MIN value as given below
          IF  l_rec_count > 1 THEN
            SELECT MIN
            INTO   l_min_value
            FROM
              (SELECT TABLE_SITE_PART.X_MIN MIN
              FROM    sa.table_site_part
              WHERE   sa.table_site_part.x_service_id = in_esn
              ORDER BY install_date DESC
              )
            WHERE  ROWNUM < 2;
            --
            V_Key_tbl(i).key_Value := l_min_value;
          ELSE
            l_min_value := get_esn_info_rec.min;
          END IF;
          --
          OPEN pi_min_cur(l_min_value);
          FETCH pi_min_cur INTO pi_min_rec;
          CLOSE pi_min_cur;
          --
          IF (pi_min_rec.x_part_inst_status IS NULL) THEN
            OPEN get_min_status_curs(in_esn);
            FETCH get_min_status_curs INTO get_min_status_rec;
            CLOSE get_min_status_curs;
            --
            l_min_status := get_min_status_rec.x_part_inst_status;
          ELSE
            l_min_status := pi_min_rec.x_part_inst_status;
          END IF;
          --
          IF (l_min_status IN ('37' ,'38' ,'39' ,'73')) THEN
            l_is_line_reserved := 'true';
          ELSE
            l_is_line_reserved := 'false';
          END IF;
          --
          v_key_tbl(i).key_value := l_is_line_reserved;
          --
          SELECT  nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO    v_key_tbl(i).result_value
          FROM    dual;
        END IF;
        --
        -- Addd for CR37756 BY sethiraj 3/14/2016
        IF (v_key_tbl(i).key_type IN ('GROUP_ID')) THEN
          --
          v_key_tbl(i).key_value := l_account_group_id;
          --
          SELECT  nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO    v_key_tbl(i).result_value
          FROM    dual;
          --
        END IF;
        --
        -- Get the Number of Lines for the Servie Plan id
        l_grp_no_of_lines := NVL( brand_x_pkg.get_number_of_lines ( ip_service_plan_id => l_service_plan_id), 1);
        -- Addd for CR37756 BY sethiraj 3/14/2016
        IF (v_key_tbl(i).key_type IN ('GROUP_NAME')) THEN
          --
          v_key_tbl(i).key_value := l_account_group_name;
          --
          SELECT  nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO    v_key_tbl(i).result_value
          FROM    dual;
          --
        END IF;
        --
        -- Addd for CR37756 BY sethiraj 3/14/2016
        IF (v_key_tbl(i).key_type IN ('INQUIRY_TYPE')) THEN

          -- CR55486, CR53217
          get_inquiry_type ( i_esn          => in_esn,
                             i_brand        => get_esn_info_rec.brand,
                             i_inquiry_type => l_inquiry_type);
          --
          v_key_tbl(i).key_value := l_inquiry_type;
          --
          SELECT  nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO    v_key_tbl(i).result_value
          FROM    dual;
          --
        END IF;
        -- CR43248 added the reward point attributes changes starts.
        IF (v_key_tbl(i).key_type IN ('MASTER_ESN_STATUS'))
        THEN
          --
          v_key_tbl(i).key_value := l_master_esn_status;
          --
          SELECT  nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO    v_key_tbl(i).result_value
          FROM    dual;
        END IF;
        --
        IF (v_key_tbl(i).key_type IN ('NUMBER_OF_LINES'))
        THEN
          --
          v_key_tbl(i).key_value := l_grp_no_of_lines;
          --
          SELECT  nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO    v_key_tbl(i).result_value
          FROM    dual;
          --
        END IF;
        --
        IF (v_key_tbl(i).key_type IN ('PRIMARY_DEVICE'))
        THEN
          --
          IF NVL(GET_ESN_INFO_REC.x_is_default,0) = 1
          THEN
            v_key_tbl(i).key_value := 'TRUE';
          ELSE
            v_key_tbl(i).key_value := 'FALSE';
          END IF;
          --
          SELECT  nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO    v_key_tbl(i).result_value
          FROM    dual;
          --
        END IF;
        --
        IF (v_key_tbl(i).key_type IN ('TOTAL_POINTS'))
        THEN
          v_key_tbl(i).key_value := l_total_points;
          --
          SELECT  nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO    v_key_tbl(i).result_value
          FROM    dual;
        END IF;
        --
        IF (v_key_tbl(i).key_type IN ('POINTS_ACCRUED'))
        THEN
          v_key_tbl(i).key_value := MOD(l_total_points,18);
          --
          SELECT  nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO    v_key_tbl(i).result_value
          FROM    dual;
        END IF;
        --
        IF (v_key_tbl(i).key_type IN ('REWARD_BENEFITS'))
        THEN
          IF l_reward_total > 0
          THEN
            v_key_tbl(i).key_value := 'TRUE';
          ELSE
            v_key_tbl(i).key_value := 'FALSE';
          END IF;
          --
          SELECT  nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO    v_key_tbl(i).result_value
          FROM    dual;
        END IF;
        --
        IF (v_key_tbl(i).key_type IN ('LEASE_APPLICATION_NUMBER'))
        THEN
          v_key_tbl(i).key_value := l_lease_app_no;
          --
          SELECT  nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO    v_key_tbl(i).result_value
          FROM    dual;
        END IF;
        -- CR43248 added the reward point attributes changes ends
        -- CR44680 Changes starts
        IF (V_Key_Tbl(i).Key_Type IN ('ZIPCODE'))
        THEN
          --
          V_Key_tbl(i).key_Value := l_zip_code;
          --
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
          --
        END IF;
        -- Added for Low balance enrollment
        IF (v_key_tbl(i).key_type IN ('IS_VAS_ENROLLED'))
        THEN
          --
          v_key_tbl(i).key_value := l_vas_enrolled;
          --
          SELECT  nvl2( v_key_tbl(i).key_value ,'success','Fail')
          INTO    v_key_tbl(i).result_value
          FROM    dual;
          --
        END IF;
        -- CR44680 Changes ends
        -- CR45378 Changes Starts
        IF (V_Key_Tbl(i).Key_Type IN ('ACCOUNTID')) THEN
          V_Key_tbl(i).key_Value := get_esn_info_rec.ACCOUNTID;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        --
        IF (V_Key_Tbl(i).Key_Type IN ('PYMNT_SRC_AVLBL')) THEN
          V_Key_tbl(i).key_Value := l_pymt_src_avlbl;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        --
        IF (V_Key_Tbl(i).Key_Type IN ('ISSIMREQUIRED')) THEN
          IF get_esn_info_rec.TECHNOLOGY = 'GSM' OR lte_service_pkg.is_esn_lte_cdma (In_Esn) = 1 THEN
              V_Key_tbl(i).key_Value := 'TRUE';
          ELSE
              V_Key_tbl(i).key_Value := 'FALSE';
          END IF;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        --
        -- CR47564 WFM  call to p_get_sim_info procedure.
        /*IF (V_Key_Tbl(i).Key_Type IN ('ICCID','SIMSTATUS','ISLEGACYFLAG','CARRIER'))THEN */
        -- Added more conditions for CR47608
        IF (V_Key_Tbl(i).Key_Type IN ('ICCID','SIMSTATUS','ISLEGACYFLAG','CARRIER','SIM_PARTCLASS','SIM_PARTNUMBER'))
        THEN
          IF (o_sim_serial_no  IS NULL)
          THEN
            /*p_get_sim_info(get_esn_info_rec.SIM,
                           o_sim_serial_no => o_sim_serial_no,
                           o_sim_status    => o_sim_status,
                           o_phone_carrier => o_phone_carrier,
                           o_err_num       => v_err_num,
                           o_err_msg       => v_err_string,
                           o_legacy_flag   => o_legacy_flag);*/
          --CR47608
            p_get_sim_info( i_sim             => get_esn_info_rec.SIM,
                            o_sim_serial_no   => o_sim_serial_no,
                            o_sim_part_class  => l_sim_part_class, -- CR47608
                            o_sim_partnumber  => l_sim_partnumber, -- CR47608
                            o_legacy_flag     => o_legacy_flag,   -- CR47608
                            o_sim_status      => o_sim_status,
                            o_phone_carrier   => o_phone_carrier,
                            o_err_num         => v_err_num,
                            o_err_msg         => v_err_string);
          END IF;
        END IF;

        IF (V_Key_Tbl(i).Key_Type IN ('ICCID')) THEN
              V_Key_tbl(i).key_Value := o_sim_serial_no;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        --
        IF (V_Key_Tbl(i).Key_Type IN ('SIMSTATUS')) THEN
              V_Key_tbl(i).key_Value := o_sim_status;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
         -- CR47564  ISLEGACYFLAG
        IF (V_Key_Tbl(i).Key_Type IN ('ISLEGACYFLAG')) THEN
          V_Key_tbl(i).key_Value := o_legacy_flag;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
            INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        --
	       --CR47608 DO NOT OVERWRITE CARRIER IF SIM IS NOT PRESENT
        IF o_sim_serial_no IS NOT NULL
        THEN
          IF (V_Key_Tbl(i).Key_Type IN ('CARRIER')) THEN
                V_Key_tbl(i).key_Value := o_phone_carrier;
            SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
            INTO V_KEY_TBL(i).RESULT_VALUE
            FROM dual;
          END IF;
        END IF;
        --
        -- CR47608 changes starts..
        IF (V_Key_Tbl(i).Key_Type IN ('SIM_PARTCLASS'))
        THEN
          V_Key_tbl(i).key_Value := l_sim_part_class;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;

        IF (V_Key_Tbl(i).Key_Type IN ('SIM_PARTNUMBER'))
        THEN
          V_Key_tbl(i).key_Value := l_sim_partnumber;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;

        -- CR47608 changes ends.
        --
        IF (V_Key_Tbl(i).Key_Type IN ('TRANSACTION_PENDING'))
        THEN
           IF l_ota_pending = 'Y'
           THEN
            V_Key_tbl(i).key_Value := 'OTAPENDING';
           ELSIF l_carrier_pending = 'Y'
           THEN
            V_Key_tbl(i).key_Value := 'CARRIERPENDING';
           ELSIF get_esn_info_rec.port_in_progress  = 'Y'
           THEN
            V_Key_tbl(i).key_Value := 'PORT IN PROGRESS';
           END IF;
           --
           SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
           INTO V_KEY_TBL(i).RESULT_VALUE
           FROM dual;
        END IF;
        -- CR45378 Changes Ends
	    	--CR47564 - WFM changes
        IF (V_Key_Tbl(i).Key_Type IN ('ACCOUNT_STATUS')) THEN
          BEGIN
            V_KEY_TBL(i).KEY_VALUE := sa.account_Maintenance_pkg.get_account_status (In_Esn);
          END;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        	--CR47564 - WFM changes
        IF (V_Key_Tbl(i).Key_Type IN ('IS_SECPIN_AVAILABLE')) THEN
          BEGIN
            contact_pkg.get_security_pin(i_min => NULL,
                                         i_esn => In_Esn,
                                         O_PIN => O_PIN,
                                         o_err_code => V_ERR_NUM,
                                         o_err_msg => V_ERR_STRING);
            IF(O_PIN                 IS NOT NULL) THEN
              V_KEY_TBL(i).KEY_VALUE :='Y';
            ELSE
              V_KEY_TBL(i).KEY_VALUE :='N';
            END IF;
            SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
            INTO V_KEY_TBL(i).RESULT_VALUE
            FROM dual;
          END;
        END IF;
 -- CR48383 Changes to block triple benefits for TF smartphones released after 4/4/17.
  -- mdave 03/27/2017
IF (V_KEY_TBL(i).KEY_TYPE IN ('IS_TRIPPLE_BENEFITS_ELIGIBLE')) THEN
		V_KEY_TBL(i).KEY_VALUE := l_block_triple_benefits_flag;
			SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
			INTO V_KEY_TBL(i).RESULT_VALUE
			FROM dual;
END IF;
  -- CR48383 ends.

        --CR49696 WFM changes start
        IF (V_KEY_TBL(i).KEY_TYPE IN ('SERVICE_PARTCLASS')) THEN
          c_service_plan_part_class := sa.CUSTOMER_INFO.get_service_plan_attributes ( i_esn => In_Esn,
                                                                                      I_value =>'PART_CLASS_NAME' );

          V_KEY_TBL(i).KEY_VALUE := c_service_plan_part_class;
          SELECT NVL2( V_KEY_TBL(i).KEY_VALUE ,'success','Fail')
          INTO V_KEY_TBL(i).RESULT_VALUE
          FROM dual;
        END IF;
        --CR49696 WFM changes end
 -- CR48383 ends.
        -- CR48846 VL My account
        IF (v_key_tbl(i).key_type IN ('ACCOUNT_DEVICE_COUNT'))
        THEN
          BEGIN
            SELECT COUNT(DISTINCT pi.part_serial_no),
                   'success'
            INTO   v_key_tbl(i).key_value,
                   v_key_tbl(i).result_value
            FROM   table_web_user web,
                   table_x_contact_part_inst conpi,
                   table_part_inst pi
            WHERE  web.objid                         = get_esn_info_rec.accountid
            AND    pi.objid                          = conpi.x_contact_part_inst2part_inst
            AND    conpi.x_contact_part_inst2contact = web.web_user2contact;

          EXCEPTION
          WHEN OTHERS
          THEN
            v_key_tbl(i).key_value    := '0';
            v_key_tbl(i).result_value := 'Fail';
          END;
        END IF;
        -- CR51182 Check if ESN is in Currentvals
        IF (V_KEY_TBL(i).KEY_TYPE IN ('IS_SAFELINK_ESN'))
        THEN
          SELECT COUNT(*)
            INTO l_safelink_esn
          FROM   sa.x_sl_currentvals cvals
          WHERE  1                    = 1
            AND  cvals.x_current_esn  = in_esn
            AND  ROWNUM               < 2;

          SELECT DECODE (l_safelink_esn, 1, 'Y','N')
            INTO V_KEY_TBL(i).KEY_VALUE
          FROM   DUAL;

          SELECT DECODE (V_KEY_TBL(i).KEY_VALUE,'Y','success', 'N','Fail')
            INTO V_KEY_TBL(i).RESULT_VALUE
          FROM   dual;
        END IF;
        -- CR51182
        IF v_key_tbl(i).key_type IN ('IS_SAFELINK','SL_RECERT_ALERT')--,'SL_NONUSAGE_ALERT')
        THEN
          BEGIN
            SELECT DISTINCT
                   CASE
                      WHEN sls.x_av_due_date < sysdate + 7 --LOGIC TO DEFINE "X" HERE
                      THEN 'Y'
                      ELSE 'N'
                   END,
                   'success'
            INTO   v_key_tbl(i).key_value,
                   v_key_tbl(i).result_value
            FROM   sa.x_program_enrolled pe,
                   sa.x_program_parameters pgm,
                   sa.x_sl_currentvals slcur,
                   sa.x_sl_subs sls
            WHERE  pe.x_esn = in_esn
            AND    pgm.objid = pe.pgm_enroll2pgm_parameter
            AND    pgm.x_prog_class = 'LIFELINE'
            AND    pe.x_enrollment_status = 'ENROLLED'
            AND    slcur.x_current_esn = pe.x_esn
            AND    slcur.lid = sls.lid;

            IF v_key_tbl(i).key_type = 'IS_SAFELINK'
            THEN
              v_key_tbl(i).key_value := 'Y';
            END IF;

          EXCEPTION
           WHEN NO_DATA_FOUND THEN
            v_key_tbl(i).key_value := 'N';
            v_key_tbl(i).result_value := 'success';
           WHEN OTHERS THEN
            v_key_tbl(i).key_value := 'N';
            v_key_tbl(i).result_value := 'fail';
          END;
        END IF;--v_key_tbl(i).key_type IN ('IS_SAFELINK','SL_RECERT_ALERT')
        -- CR48846 VL My account

	--CR47608
        IF v_key_tbl(i).key_type = 'IS_LTE'
        THEN
          BEGIN
            SELECT 'Y',
                   'success'
            INTO   v_key_tbl(i).key_value,
                   v_key_tbl(i).result_value
            FROM   table_part_class pc,
                   table_bus_org bo,
                   table_part_num pn,
                   pc_params_view vw,
                   table_part_inst pi,
                   table_mod_level ml
            WHERE  pn.part_num2bus_org = bo.objid
            AND    pn.part_num2part_class = pc.objid
            AND    pc.name=vw.part_class
            AND    vw.param_name  = 'CDMA LTE SIM' --'DLL'   --YM 07/13/2013
            AND    vw.param_value = 'REMOVABLE' --'-8'    --YM 07/13/2013
            AND    pi.n_part_inst2part_mod = ml.oBJID
            AND    ml.part_info2part_num = pn.objID
            AND    pi.part_serial_no = in_esn ;

         EXCEPTION
           WHEN OTHERS THEN
             v_key_tbl(i).key_type     := 'IS_LTE';
             v_key_tbl(i).key_value    := 'N'; -- Set as the DEFAULT value for Non-Leased subscribers
             v_key_tbl(i).result_value := 'Fail';
        END;
      END IF; --IF v_key_tbl(i).key_type = 'IS_LTE'
      --CR53217
      IF v_key_tbl(i).key_type = 'AUTO_ENRL_OBJID'
      THEN
        BEGIN
          SELECT pe.pgm_enroll2pgm_parameter,'success'
          INTO   v_key_tbl(i).key_value,
          		 v_key_tbl(i).result_value
          FROM   sa.x_program_enrolled   pe,
          	     sa.x_program_parameters PP
          WHERE  pe.x_esn = in_esn
          AND    pe.x_next_charge_date >= TRUNC(SYSDATE)
          AND    pe.x_is_grp_primary = 1
          AND    pe.x_enrollment_status not in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
          AND    pp.objid = pe.pgm_enroll2pgm_parameter
          AND    NVL(pp.x_prog_class,'X') not in ('ONDEMAND','WARRANTY');
        EXCEPTION
        WHEN OTHERS
        THEN
          v_key_tbl(i).key_value    := null;
          v_key_tbl(i).result_value := 'Fail';
        END;
      END IF;

      -- retrieve the service plan purchase part number
      IF v_key_tbl(i).key_type = 'PLAN_PURCHASE_PART_NUMBER'
      THEN
        -- get the app part number from the pivot table
        BEGIN
          SELECT plan_purchase_part_number,
                 'success'
          INTO   v_key_tbl(i).key_value,
                 v_key_tbl(i).result_value
          FROM   sa.service_plan_feat_pivot_mv
          WHERE  service_plan_objid = sa.customer_info.get_service_plan_objid ( i_esn => in_esn );
        EXCEPTION
        WHEN OTHERS
        THEN
          v_key_tbl(i).key_value    := NULL;
          v_key_tbl(i).result_value := 'Fail';
        END;
      END IF;

      IF v_key_tbl(i).key_type = 'CURRENT_SERV_PLAN_NAME'
      THEN
        -- get the app part number from the pivot table
        BEGIN
          SELECT ( sa.queue_card_pkg.fn_get_script_text_by_sp_desc(sa.customer_info.get_service_plan_objid(i_esn => in_esn),'CUST_PROFILE_SCRIPT',get_esn_info_rec.brand) ),
                 'success'
          INTO   v_key_tbl(i).key_value,
                 v_key_tbl(i).result_value
          FROM   dual;
        EXCEPTION
        WHEN OTHERS
        THEN
          v_key_tbl(i).key_value := NULL;
          v_key_tbl(i).result_value := 'Fail';
        end;
      END if;
      --CR53217
      --CR48260 changes start
      IF (V_KEY_TBL(i).KEY_TYPE IN ('SUB_BRAND')) THEN
        V_Key_tbl(i).key_Value := sa.CUSTOMER_INFO.get_sub_brand_by_esn ( i_esn => in_esn);
        V_KEY_TBL(i).RESULT_VALUE := 'success';
      END IF;
      --CR48260 changes end
	  END LOOP;
  END IF;
  CLOSE get_esn_info_cur;
  Io_Key_Tbl := V_Key_Tbl;

EXCEPTION
WHEN OTHERS
THEN
    --
    v_err_num    := sqlcode;
    v_err_string := substr(sqlerrm,1, 300);
    util_pkg.insert_error_tab_proc(ip_action => NULL, ip_key => substr(in_esn||';', 1, 50), ip_program_name => 'SP_MOBILE_ACCOUNT.ma_getesnattributes', ip_error_text => v_err_string);
    --
END ma_getesnattributes;

--Modified for CR 42489 starts
PROCEDURE p_get_nameduserid (
    i_web_account_id 	IN 	  VARCHAR2,
    i_nameduserid 	  IN  	VARCHAR2,
    o_nameduserid 	  OUT  	VARCHAR2,
    O_ERR_NUM       	OUT   NUMBER,
    O_ERR_STRING    	OUT   VARCHAR2)
IS
l_named_userid 	varchar2(50);
--
BEGIN
  --
  IF i_web_account_id IS NULL THEN
    o_nameduserid :=  null;
    O_ERR_NUM     :=  -301;
    O_ERR_STRING  :=  'Invalid Web User Id';
    RETURN;
  END IF;
  --
  BEGIN
    SELECT  named_userid
    INTO    l_named_userid
    FROM    table_web_user twu
    WHERE   twu.objid = i_web_account_id;
  EXCEPTION
  WHEN OTHERS THEN
    o_nameduserid   :=  null;
    O_ERR_NUM       :=  -301;
    O_ERR_STRING    :=  'Invalid Web User Id';
    RETURN;
  END;
  --
  IF l_named_userid IS NOT NULL THEN
    o_nameduserid :=  l_named_userid;
  ELSE
    --
    IF i_nameduserid IS NULL THEN
      O_ERR_NUM     :=  -3011;
      O_ERR_STRING  :=  'Invalid i_nameduserid';
      RETURN;
    END IF;
    --
    UPDATE  table_web_user
    SET     named_userid  =  i_nameduserid
    WHERE   objid         = i_web_account_id;
    --
    o_nameduserid :=  i_nameduserid;
    --
  END IF;
  --
  O_ERR_NUM     :=  0;
  O_ERR_STRING  :=  'SUCCESS';
  --
EXCEPTION
WHEN OTHERS THEN
  --
  o_err_num    := sqlcode;
  o_err_string := substr(sqlerrm,1, 300);
END p_get_nameduserid;
  --
PROCEDURE P_LOG_DEVICE_PREF (
      i_web_account_id  IN  VARCHAR2,
      i_channelid       IN  VARCHAR2,
      i_deviceid        IN  VARCHAR2,
      i_brand	          IN  VARCHAR2,
      i_pref_det        IN  sa.TAB_DEVICE_PREF,
      o_err_num         OUT NUMBER,
      o_err_string      OUT VARCHAR2
       )
IS
  --
  l_pref_det sa.TAB_DEVICE_PREF:=sa.TAB_DEVICE_PREF(null, null, null);
BEGIN
  --
  O_ERR_NUM:=0;
  O_ERR_STRING:='SUCCESS';
  --
  if i_web_account_id is null then
    O_ERR_NUM:=-302;
    O_ERR_STRING:='Invalid Web User Id';
    return;
  elsif i_channelid is null then
    O_ERR_NUM:=-303;
    O_ERR_STRING:='Invalid Channel Id';
    return;
  elsif i_deviceid is null then
    O_ERR_NUM:=-304;
    O_ERR_STRING:='Invalid Device Id';
    return;
  elsif i_pref_det is null then
    O_ERR_NUM:=-304;
    O_ERR_STRING:='Invalid Preference Details';
    return;
  end if;
  --
  l_pref_det:=i_pref_det;
  --
  FOR rec IN l_pref_det.first..l_pref_det.last
  LOOP
    BEGIN
      INSERT INTO Table_log_pref_device (
        objid          ,
        web_account_id ,
        Channel_id     ,
        Device_id      ,
        ESN            ,
        MIN            ,
        Preference_flag     ,
        Brand	     ,
        created_date   ,
        modified_date
        )
        VALUES
        (
        SEQ_LOG_PREF_DEVICE.NEXTVAL    ,
        i_web_account_id               ,
        i_channelid                    ,
        i_deviceid                     ,
        l_pref_det(rec).ESN            ,
        l_pref_det(rec).MIN            ,
        l_pref_det(rec).Preference     ,
        i_brand	                       ,
        SYSDATE                        ,
        SYSDATE
        );
    EXCEPTION
    WHEN dup_val_on_index THEN
      UPDATE  Table_log_pref_device
      SET     Preference_flag     = l_pref_det(rec).Preference,
              min                 = l_pref_det(rec).MIN,
              modified_date       = sysdate
      WHERE   web_account_id      = i_web_account_id
      AND     Channel_id          = i_channelid
      AND     Device_id           = i_deviceid
      AND     ESN                 = l_pref_det(rec).ESN;
    END;
  END LOOP;
  --
  EXCEPTION
  WHEN OTHERS THEN
    --
    o_err_num    := sqlcode;
    o_err_string := substr(sqlerrm,1, 300);
    --
  END P_LOG_DEVICE_PREF;
  --
  PROCEDURE P_LOG_MSG_STATUS (
      i_web_account_id 	    IN    VARCHAR2,
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
      o_err_string 	        OUT   VARCHAR2
)
  IS
  BEGIN
    o_err_num    := 0;
    o_err_string := 'SUCCESS';
    --
/*    if i_web_account_id is null then
      O_ERR_NUM:=-302;
      O_ERR_STRING:='Invalid Web User Id';
      return;

    elsif i_Channel_id is null then
      O_ERR_NUM:=-303;
      O_ERR_STRING:='Invalid Channel Id';
      return;
    elsif i_device_id is null then
      O_ERR_NUM:=-304;
      O_ERR_STRING:='Invalid Device Id';
      return;
    elsif i_campaign_id is null then
      O_ERR_NUM:=-305;
      O_ERR_STRING:='Invalid Campaign Id';
      return;
    elsif i_esn is null and i_min is null then
      O_ERR_NUM:=-307;
      O_ERR_STRING:='Provide atleast one of ESN/MIN';
      return;
    end if;
*/
    IF i_preference_id IS NULL THEN
      O_ERR_NUM:=-306;
      O_ERR_STRING:='Invalid Preference Id';
      RETURN;
    END IF;
    --
    INSERT INTO table_log_msg_status (
      objid          ,
      web_account_id ,
      Channel_id     ,
      Device_id      ,
      ESN            ,
      MIN            ,
      preference_id  ,
      campaign_id    ,
      cust_trans_id  ,
      push_date      ,
      vendor_id      ,
      response_date  ,
      Opt_out_req    ,
      Brand	     ,
      Record_Load_Date ,
      Receipt_Request ,
      created_date   ,
      modified_date
    )
    values
    (
      SEQ_LOG_MSG_STATUS.nextval,
      i_web_account_id ,
      i_Channel_id     ,
      i_Device_id      ,
      i_ESN            ,
      i_MIN            ,
      i_preference_id  ,
      i_campaign_id    ,
      i_cust_trans_id  ,
      i_push_date      ,
      i_vendor_id      ,
      i_response_date  ,
      i_Opt_out_req    ,
      i_Brand	       ,
      i_Record_Load_Date ,
      i_Receipt_Request ,
      sysdate	       ,
      sysdate
    );
    --
  EXCEPTION
  WHEN OTHERS THEN
    --
    o_err_num    := sqlcode;
    o_err_string := substr(sqlerrm,1, 300);
   -- util_pkg.insert_error_tab_proc(ip_action => NULL, ip_key => substr(i_web_account_id||';', 1, 50), ip_program_name => 'SP_MOBILE_ACCOUNT.P_LOG_MSG_STATUS', ip_error_text => o_err_string);
    --
  END P_LOG_MSG_STATUS;
  --Modified for CR 42489 ends
  --
  -- PMistry 07/19/2016 CR41473 Added new procedure to get named user id from web objid or vice versa
  PROCEDURE p_get_web_account_ids (
      io_web_account_id 	IN OUT	  NUMBER,
      io_nameduserid 	    IN OUT 	  VARCHAR2,
      O_ERR_NUM       	OUT       NUMBER,
      O_ERR_STRING    	OUT       VARCHAR2
      ) IS

   cursor cur_get_named_user_id is
      select named_userid
      from table_web_user
      where objid = io_web_account_id;

   cursor cur_get_web_user_objid is
      select objid
      from table_web_user
      where named_userid = io_nameduserid;

   begin
      O_ERR_NUM := 0;
      O_ERR_STRING := 'SUCCESS';

    if io_web_account_id is not null then
      open cur_get_named_user_id;
      fetch cur_get_named_user_id into io_nameduserid;
      close cur_get_named_user_id;
    elsif io_nameduserid is not null then
      open cur_get_web_user_objid;
      fetch cur_get_web_user_objid into io_web_account_id;
      close cur_get_web_user_objid;
    else
      O_ERR_NUM := -11;
      O_ERR_STRING := 'Invalid input values.';
    end if;


  EXCEPTION
    WHEN OTHERS THEN
      O_ERR_NUM      := -99;
      O_ERR_STRING       :='Error_code: '||sqlcode||' Error_msg: '||sqlerrm ||' - '||dbms_utility.format_error_backtrace;
      --
      ota_util_pkg.err_log (p_action      => 'Calling SP_MOBILE_ACCOUNT.p_get_web_account_id',
                         p_error_date     => SYSDATE,
                         p_key            => 'io_web_account_id: '||io_web_account_id||', io_nameduserid: '||io_nameduserid,
                         p_program_name   => 'SP_MOBILE_ACCOUNT.p_get_web_account_id',
                         p_error_text     => O_ERR_STRING);

   end p_get_web_account_ids;

-- CR43248 Changes Starts..
PROCEDURE validate_esn_sp_rules_wrp (
      ip_esn                    IN  VARCHAR2 ,
      ip_bus_org_id             IN  VARCHAR2 ,
      op_esn_sp_validation_tab  OUT esn_sp_validation_tab ,
      op_err_code               OUT NUMBER ,
      op_err_msg                OUT VARCHAR2
	  ) IS
--
  l_lease_phone               VARCHAR2(1);
  l_service_plan_id_list      typ_number_array;
  l_esn_sp_validation_tab     esn_sp_validation_tab;
--
BEGIN
--
  IF ip_esn IS NULL THEN
    op_err_code := 100;
    op_err_msg := 'Invalid ESN';
    RETURN;
  END IF;
  --
  IF ip_bus_org_id IS NULL THEN
    op_err_code := 101;
    op_err_msg := 'Invalid Brand';
    RETURN;
  END IF;
  --
  op_esn_sp_validation_tab  :=  esn_sp_validation_tab(esn_sp_validation_type('','','','','','',''));
  --
  SELECT DECODE (COUNT(*),0, 'N', 'Y')
  INTO   l_lease_phone
  FROM   sa.x_customer_lease
  WHERE  x_esn        = ip_esn
  AND    lease_status in ('1001','1002','1005');
  --
  IF l_lease_phone = 'N'
  THEN
    SELECT DISTINCT spmv.SP_OBJID BULK COLLECT
    INTO   l_service_plan_id_list
    FROM   table_part_num                   pn,
           table_part_class                 pc,
           table_bus_org                    bo,
           ADFCRM_SERV_PLAN_CLASS_MATVIEW   spmv
    WHERE  pc.objid                 =   pn.PART_NUM2PART_CLASS
    AND    pn.PART_NUM2BUS_ORG      =   bo.objid
    AND    bo.org_id                =   ip_bus_org_id
    AND    spmv.PART_CLASS_OBJID    =   pc.OBJID;
    --
  ELSE
    SELECT sp_id BULK COLLECT
    INTO   l_service_plan_id_list
    FROM (
          SELECT  DISTINCT spmv.service_plan_objid  sp_id
          FROM    table_part_num                  tpn,
                  table_part_inst                 pi,
                  table_mod_level                 tml,
                  adfcrm_serv_plan_class_matview  aspc,
                  service_plan_feat_pivot_mv      spmv
          WHERE   1                           =1
          AND     spmv.plan_type               <> 'MONTHLY PLANS'
          AND     aspc.SP_OBJID                 = spmv.service_plan_objid
          AND     tpn.part_num2part_class       = aspc.PART_CLASS_OBJID
          AND     tml.part_info2part_num        = tpn.objid
          AND     pi.n_part_inst2part_mod       = tml.objid
          AND     pi.part_serial_no             = ip_esn
          UNION
          SELECT  DISTINCT sp.objid       sp_id
          FROM 	  table_part_inst           pi,
                  x_service_plan            sp,
                  x_service_plan_site_part  spsp,
                  table_site_part           tsp
          WHERE   1                       =   1
          AND     spsp.x_service_plan_id  =   sp.objid
          AND     tsp.objid               =   spsp.table_site_part_id
          AND     pi.part_serial_no       =   tsp.x_service_id
          AND     pi.part_serial_no       =   ip_esn);
    --
  END IF;
  --
  IF  l_service_plan_id_list.COUNT = 0	OR
      l_service_plan_id_list	IS NULL
  THEN
    op_err_code :=  110;
    op_err_msg  :=  'Unable to get service plans for this ESN';
    RETURN;
  END IF;
  --
  op_esn_sp_validation_tab.DELETE;
  FOR each_rec IN l_service_plan_id_list.FIRST .. l_service_plan_id_list.LAST
  LOOP
    l_esn_sp_validation_tab :=  NULL;
    brand_x_pkg.validate_esn_sp_rules(ip_esn                    => ip_esn,
                                      ip_service_plan_id        => l_service_plan_id_list(each_rec),
                                      ip_bus_org_id             => ip_bus_org_id,
                                      op_esn_sp_validation_tab  => l_esn_sp_validation_tab,
                                      op_err_code               => op_err_code,
                                      op_err_msg                => op_err_msg);
    --
    FOR idx in l_esn_sp_validation_tab.FIRST  .. l_esn_sp_validation_tab.LAST
    LOOP
      op_esn_sp_validation_tab.EXTEND;
      op_esn_sp_validation_tab(op_esn_sp_validation_tab.LAST) := esn_sp_validation_type(l_esn_sp_validation_tab(idx).msgnum,
                                                                                        l_esn_sp_validation_tab(idx).msgstr,
                                                                                        l_esn_sp_validation_tab(idx).available_capacity,
                                                                                        l_esn_sp_validation_tab(idx).number_of_lines,
                                                                                        l_esn_sp_validation_tab(idx).service_plan_id,
                                                                                        l_esn_sp_validation_tab(idx).payment_pending_group_id,
                                                                                        l_esn_sp_validation_tab(idx).program_enrolled_id);
    END LOOP;
    --
  END LOOP;
  --
  op_err_code :=  0;
  op_err_msg  :=  'SUCCESS';
  --
  EXCEPTION
  WHEN OTHERS THEN
    --CR47564 changes start
    op_err_code:=111;
    op_err_msg:=sqlerrm;
    --CR47564 changes end
END validate_esn_sp_rules_wrp;
-- CR43248 Changes ends
-- CR45378 changes starts
--
PROCEDURE  p_get_sim_info ( i_sim             IN    VARCHAR2,
                            o_sim_serial_no   OUT   VARCHAR2,
                            o_sim_status      OUT   VARCHAR2,
                            o_phone_carrier   OUT   VARCHAR2,
                            o_err_num         OUT   NUMBER,
                            o_err_msg         OUT   VARCHAR2)
IS
--COMMENTING OUT, WILL CALL THE NEW OVERLOADED PROCEDURE FROM HERE
/*  CURSOR cur_sim_details
  IS
  SELECT  si.x_sim_serial_no            AS x_sim_serial_no,
          si.x_sim_inv_status           AS sim_status_code,
          ct.x_code_name                AS sim_status_msg,
          bo.org_id                     AS sim_brand,
          nvl(pcv.x_param_value,'2G')   AS sim_comp,
          pn.part_number                AS sim_part_number,
          pc.name                       AS sim_part_class  -- CR47608
    FROM  table_x_sim_inv si,
          table_x_code_table ct,
          table_part_mod_v pm,
          table_part_num pn,
          table_bus_org bo,
          table_part_class pc,
          table_x_part_class_values pcv,
          table_x_part_class_params pcp
    WHERE si.x_sim_inv_status    = ct.x_code_number
    AND   ct.x_code_type         = 'SIM'
    AND   si.x_sim_inv2part_mod  = pm.objid
    AND   pm.part_num_objid      = pn.objid
    AND   pn.part_num2part_class = pc.objid
    AND   pc.objid               = pcv.value2part_class (+)
    AND   pcv.value2class_param  = pcp.objid (+)
    AND   pcp.x_param_name (+)   = 'PHONE_GEN'
    AND   pn.part_num2bus_org    = bo.objid (+)
    AND   si.x_sim_serial_no     = i_sim ;

  rec_sim_details cur_sim_details%ROWTYPE;
  sim_details_validation_failed EXCEPTION;

  c_sim_profile  table_part_num.s_part_number%type;
  l_parent_name  table_x_parent.x_parent_name%type;

BEGIN
  -- Validate SIM
  IF i_sim  IS NULL THEN
    o_err_num := 10110;
    o_err_msg := 'Error. Unsupported or Null values received for I_SIM';
    RETURN; ----CR47564 change
  END IF;
  --
  OPEN cur_sim_details;
  FETCH cur_sim_details INTO rec_sim_details;

  IF cur_sim_details%FOUND THEN
    o_sim_serial_no   := rec_sim_details.x_sim_serial_no;
    o_sim_status      := rec_sim_details.sim_status_msg;
    c_sim_profile     := rec_sim_details.sim_part_number;
    o_err_num         := 0;
    o_err_msg         := 'SUCCESS';
  ELSE
    o_err_num         := 10100;
    o_err_msg         := 'No Details found for the given SIM';
  END IF;
  CLOSE cur_sim_details;

  IF c_sim_profile IS NOT NULL THEN
  BEGIN
   SELECT sa.util_pkg.get_short_parent_name(carrier_name)
   INTO o_phone_carrier
	FROM (SELECT * from carriersimpref
		   WHERE sim_profile = c_sim_profile
		   ORDER BY rank ASC)
   WHERE rownum = 1;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
           o_err_num := 10103;
           o_err_msg := 'No SIM Profile found for the given SIM';
      WHEN OTHERS THEN
      o_err_num      := 10101;
      o_err_msg      := SQLERRM;
  END;
  END IF;*/
    c_sim_part_class       VARCHAR2(100); -- CR47608
    c_sim_partnumber       VARCHAR2(100); -- CR47608
    c_legacy_flag          VARCHAR2(100); -- CR47608
BEGIN
  -- CALL THE NEW OVERLOADED PROCEDURE
  p_get_sim_info( i_sim            =>  i_sim,
                  o_sim_serial_no  =>  o_sim_serial_no,
                  o_sim_part_class =>  c_sim_part_class,
                  o_sim_partnumber =>  c_sim_partnumber,
                  o_legacy_flag    =>  c_legacy_flag,
                  o_sim_status     =>  o_sim_status,
                  o_phone_carrier  =>  o_phone_carrier,
                  o_err_num        =>  o_err_num,
                  o_err_msg        =>  o_err_msg );

EXCEPTION
WHEN OTHERS THEN
  --CR47564 changes start
  o_err_num := 10102;
  o_err_msg := SQLERRM;
  --CR47564 changes end
END p_get_sim_info;
--CR47564 changes start

PROCEDURE  p_get_sim_info ( i_sim           IN  VARCHAR2 ,
                            o_sim_serial_no OUT VARCHAR2 ,
                            o_sim_status    OUT VARCHAR2 ,
                            o_phone_carrier OUT VARCHAR2 ,
                            o_err_num       OUT NUMBER   ,
                            o_err_msg       OUT VARCHAR2,
                            o_legacy_flag   OUT VARCHAR2)
IS
    c_sim_part_class       VARCHAR2(100); -- CR47608
    c_sim_partnumber       VARCHAR2(100); -- CR47608

BEGIN
  p_get_sim_info( i_sim            =>  i_sim,
                  o_sim_serial_no  =>  o_sim_serial_no,
                  o_sim_part_class =>  c_sim_part_class,
                  o_sim_partnumber =>  c_sim_partnumber,
                  o_legacy_flag    =>  o_legacy_flag, --CR47608
                  o_sim_status     =>  o_sim_status,
                  o_phone_carrier  =>  o_phone_carrier,
                  o_err_num        =>  o_err_num,
                  o_err_msg        =>  o_err_msg );
  --commented as part of CR47608
  /*o_legacy_flag:=sa.customer_info.get_sim_legacy_flag (i_sim=>i_sim);*/

EXCEPTION
WHEN OTHERS THEN
  o_err_num := 10120;
  o_err_msg := sqlerrm;
END p_get_sim_info;
--CR47564 changes end

PROCEDURE get_partnumber_by_pin ( i_pin           IN  VARCHAR2 ,
	o_part_number   OUT VARCHAR2,
	o_err_num       OUT NUMBER,
	                                o_err_msg       OUT VARCHAR2 ) IS

  CURSOR cur_pin_partnumber
  IS
  SELECT part_number
  FROM   ( SELECT pn.part_number
           FROM   table_part_inst pi,
                  table_mod_level ml,
                  table_part_num pn
           WHERE  1 = 1
           AND    pi.x_red_code = i_pin
           AND    pi.x_domain = 'REDEMPTION CARDS'
           AND    pi.n_part_inst2part_mod = ml.objid
           AND    ml.part_info2part_num = pn.objid
           AND    pn.domain = 'REDEMPTION CARDS'
           UNION
           SELECT pn.part_number
           FROM   table_x_red_card rc,
                  table_mod_level ml,
                  table_part_num pn
           WHERE  rc.x_red_code = i_pin
           AND    ml.objid = rc.x_red_card2part_mod
           AND    ml.part_info2part_num = pn.objid
           AND    pn.domain = 'REDEMPTION CARDS'
           UNION
           SELECT pn.part_number
           FROM   table_x_posa_card_inv pi,
                  table_mod_level ml,
                  table_part_num pn
           WHERE  1 = 1
           AND    pi.x_red_code = i_pin
           AND    ml.objid = pi.x_posa_inv2part_mod
           AND    pn.objid = ml.part_info2part_num
           AND    pn.domain = 'REDEMPTION CARDS'
         );
  rec_pin_partnumber cur_pin_partnumber%ROWTYPE;
  validation_failed EXCEPTION;

BEGIN
  -- Validate i_pin
  IF i_pin  IS NULL THEN
    o_err_num := 10200;
    o_err_msg := 'Error. Unsupported or Null values received for I_PIN';
    RETURN; --CR47564 change
  END IF;
  --
  OPEN cur_pin_partnumber;
  FETCH cur_pin_partnumber INTO rec_pin_partnumber;

  IF cur_pin_partnumber%FOUND THEN
	o_part_number   := rec_pin_partnumber.part_number;

	o_err_num         := 0;
	o_err_msg         := 'SUCCESS';
  ELSE
    o_err_num         := 10210;
    o_err_msg         := 'Part Number not found';
  END IF;
  CLOSE cur_pin_partnumber;

EXCEPTION
 --CR47564 changes start
WHEN OTHERS THEN
  o_err_num := 10220;
  o_err_msg := sqlerrm;
 --CR47564 changes end
END get_partnumber_by_pin;
-- CR45378 changes ends
--

--CR47608 added new overloaded procedure
PROCEDURE  p_get_sim_info ( i_sim             IN    VARCHAR2,
                            o_sim_serial_no   OUT   VARCHAR2,
                            o_sim_part_class  OUT   VARCHAR2,  -- CR47608
                            o_sim_partnumber  OUT   VARCHAR2,  -- CR47608
                            o_legacy_flag     OUT   VARCHAR2,
                            o_sim_status      OUT   VARCHAR2,
                            o_phone_carrier   OUT   VARCHAR2,
                            o_err_num         OUT   NUMBER,
                            o_err_msg         OUT   VARCHAR2)
IS
  CURSOR cur_sim_details
  IS
  SELECT  si.x_sim_serial_no            AS x_sim_serial_no,
          si.x_sim_inv_status           AS sim_status_code,
          ct.x_code_name                AS sim_status_msg,
          bo.org_id                     AS sim_brand,
          nvl(pcv.x_param_value,'2G')   AS sim_comp,
          pn.part_number                AS sim_part_number,
          pc.name                       AS sim_part_class
    FROM  table_x_sim_inv si,
          table_x_code_table ct,
          table_part_mod_v pm,
          table_part_num pn,
          table_bus_org bo,
          table_part_class pc,
          table_x_part_class_values pcv,
          table_x_part_class_params pcp
    WHERE si.x_sim_inv_status    = ct.x_code_number
    AND   ct.x_code_type         = 'SIM'
    AND   si.x_sim_inv2part_mod  = pm.objid
    AND   pm.part_num_objid      = pn.objid
    AND   pn.part_num2part_class = pc.objid
    AND   pc.objid               = pcv.value2part_class (+)
    AND   pcv.value2class_param  = pcp.objid (+)
    AND   pcp.x_param_name (+)   = 'PHONE_GEN'
    AND   pn.part_num2bus_org    = bo.objid (+)
    AND   si.x_sim_serial_no     = i_sim ;

  rec_sim_details cur_sim_details%ROWTYPE;
  sim_details_validation_failed EXCEPTION;

  c_sim_profile  table_part_num.s_part_number%type;
  l_parent_name  table_x_parent.x_parent_name%type;

BEGIN
  -- Validate SIM
  IF i_sim  IS NULL THEN
    o_err_num := 10110;
    o_err_msg := 'Error. Unsupported or Null values received for I_SIM';
    RETURN; ----CR47564 change
  END IF;
  --
  OPEN cur_sim_details;
  FETCH cur_sim_details INTO rec_sim_details;

  IF cur_sim_details%FOUND THEN
    o_sim_serial_no   := rec_sim_details.x_sim_serial_no;
    o_sim_status      := rec_sim_details.sim_status_msg;
    c_sim_profile     := rec_sim_details.sim_part_number;
    o_sim_part_class  := rec_sim_details.sim_part_class;
    o_sim_partnumber  := rec_sim_details.sim_part_number;
    o_err_num         := 0;
    o_err_msg         := 'SUCCESS';
  ELSE
    o_err_num         := 10100;
    o_err_msg         := 'No Details found for the given SIM';
  END IF;
  CLOSE cur_sim_details;

  IF c_sim_profile IS NOT NULL
  THEN
    BEGIN
      SELECT sa.util_pkg.get_short_parent_name(carrier_name)
      INTO   o_phone_carrier
      FROM  ( SELECT *
              FROM   carriersimpref
              WHERE  sim_profile = c_sim_profile
              ORDER BY rank ASC )
      WHERE ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
            o_err_num := 10103;
            o_err_msg := 'No SIM Profile found for the given SIM';
       WHEN OTHERS THEN
       o_err_num      := 10101;
       o_err_msg      := SQLERRM;
    END;
  END IF;
  o_legacy_flag  := sa.customer_info.get_sim_legacy_flag (i_sim=>i_sim);
EXCEPTION
WHEN OTHERS THEN
  --CR47564 changes start
  o_err_num := 10102;
  o_err_msg := SQLERRM;
  --CR47564 changes end
END p_get_sim_info;

PROCEDURE  get_rebranding_attributes ( i_esn                 IN  VARCHAR2,
                                       i_target_brand        IN  VARCHAR2,
                                       o_rebrand_equi_phone  OUT VARCHAR2,
                                       o_err_code            OUT NUMBER,
                                       o_err_msg             OUT VARCHAR2)
IS
  c_part_number   table_part_num.part_number%TYPE;
  c_prefix_pn     table_part_num.part_number%TYPE;
  c_new_part_num  table_part_num.part_number%TYPE;

  i_zip_code          VARCHAR2(20) := NULL; -- CR52423 tas universal branding
  o_new_sim_part_num  VARCHAR2(20) := NULL;

  CURSOR get_esn_info_cur(i_esn table_part_inst.part_serial_no%TYPE)
  IS
    SELECT pn.part_num2bus_org,
           bo.org_id,
           pn.part_number,
           pn.x_technology technology
    FROM   table_part_num pn,
           table_mod_level ml,
           table_part_inst pi,
           table_bus_org bo
    WHERE  pi.part_serial_no = i_esn
    AND    ml.objid = pi.n_part_inst2part_mod
    AND    pn.objid = ml.part_info2part_num
    AND    pn.part_num2bus_org = bo.objid;
get_esn_info_rec   get_esn_info_cur%rowtype  ;
v_is_lte				 VARCHAR2(20); --CR47491
BEGIN

  IF i_esn IS NULL
  THEN
    o_err_code := -1;
    o_err_msg  := 'ESN NOT PASSED';
    RETURN;
  END IF;

  IF i_target_brand IS NULL
  THEN
    o_err_code := -2;
    o_err_msg := 'TARGET BRAND NOT PASSED';
    RETURN;
  END IF;

  OPEN get_esn_info_cur(i_esn);
  FETCH get_esn_info_cur INTO get_esn_info_rec;

  IF get_esn_info_cur%FOUND
  THEN
    BEGIN
      SELECT SUBSTR (loc_type, 1, 2)
      INTO   c_prefix_pn
      FROM   table_bus_org
      WHERE  org_id = i_target_brand;
    EXCEPTION
     WHEN OTHERS THEN
      c_prefix_pn :=NULL;
    END;

    c_new_part_num := REGEXP_REPLACE(get_esn_info_rec.part_number,SUBSTR (get_esn_info_rec.part_number, 1, 2), c_prefix_pn,1,1);

    BEGIN
      SELECT 'Y'
      INTO   o_rebrand_equi_phone
      FROM   table_mod_level ml,
             table_part_num pn,
             table_bus_org bo
      WHERE  ml.part_info2part_num = pn.objid
      AND    pn.part_number = c_new_part_num
      AND    pn.part_num2bus_org = bo.objid
      AND    ( bo.org_id = 'TRACFONE'
               OR EXISTS ( SELECT '1'
                           FROM sa.adfcrm_serv_plan_class_matview
                           WHERE part_class_objid = pn.part_num2part_class
                           AND ROWNUM < 2) );
      o_err_msg := 'SUCCESS';
      o_err_code := 0;


    EXCEPTION
      WHEN OTHERS THEN
      --CR47491 - This is redundant code. REBRAND EQUI PHONE logic was already present in Phone package.
      --SOA service uses this procedure call for Tracfone and NET10.
      --To handle Rebranding below changes are made similar to phone package.
      DBMS_OUTPUT.PUT_LINE('in exception Technology: '||get_esn_info_rec.technology);
      IF get_esn_info_rec.technology = 'CDMA'
      THEN --{
       BEGIN --{
         SELECT 'Y'
         INTO   v_is_lte
         FROM   table_part_class pc,
                table_bus_org bo,
                table_part_num pn,
                pc_params_view vw,
                table_part_inst pi,
                table_mod_level ml
         WHERE  pn.part_num2bus_org    = bo.objid
         AND    pn.pArt_num2part_class = pc.objid
         AND    PC.NAME                = VW.PART_CLASS
         AND    VW.PARAM_NAME          = 'CDMA LTE SIM'
         AND    VW.PARAM_VALUE         = 'REMOVABLE'
         AND    PI.N_PART_INST2PART_MOD= ML.OBJID
         AND    ML.PART_INFO2PART_NUM  = PN.OBJID
         AND    pi.part_serial_no      = i_esn;
       EXCEPTION
       WHEN OTHERS THEN
        v_is_lte := 'N';
       END; --}
        sa.phone_pkg.get_cdma_rebrand_pn
                                        (
                                         i_esn,
                                         v_is_lte,
                                         i_target_brand,
                                         c_new_part_num,
                                         o_rebrand_equi_phone,
                                         o_err_code,
                                         o_err_msg,
                                         i_zip_code,
                                         o_new_sim_part_num
                                        );
       IF o_err_code <> 0
       THEN
        o_err_code := -3;
        o_err_msg               := 'NEW PART NUMBER NOT FOUND '||SQLERRM;
        o_rebrand_equi_phone    := 'N';
       END IF;
       DBMS_OUTPUT.PUT_LINE('o_rebrand_equi_phone: '||o_rebrand_equi_phone);
       ELSE --}{
      --Mayank End
        o_err_code := -3;
        o_err_msg := 'NEW PART NUMBER NOT FOUND '||SQLERRM;
        o_rebrand_equi_phone    := 'N'; -- Set as the DEFAULT value for Non-Leased subscribers
       END IF; --}
    END;

  ELSE --IF get_esn_info_cur%FOUND
    o_err_code := -4;
    o_err_msg := 'ESN NOT FOUND IN CLARIFY';
    o_rebrand_equi_phone := 'N';
  END IF;  --IF get_esn_info_cur%FOUND

  IF get_esn_info_cur%ISOPEN
  THEN
    CLOSE get_esn_info_cur;
  END IF;
  IF o_rebrand_equi_phone = 'Y'
  AND
     (
      sa.phone_pkg.eligible_ppe_pn(c_new_part_num) = 'N'
      OR
      (
       sa.phone_pkg.is_sim_compatible(i_esn, c_new_part_num) = 'N'
       AND
       v_is_lte = 'Y'
      )
     )
  THEN --{
   o_err_code              := -3;
   o_err_msg               := 'PHONE NOT ELIGIBLE FOR REBRANDING.';
   o_rebrand_equi_phone    := 'N'; -- Set as the DEFAULT value for Non-Leased subscribers
  END IF; --}
EXCEPTION
 WHEN OTHERS THEN
  o_err_code := -5;
  o_err_msg := 'UNEXPECTED ERROR '|| DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
  o_rebrand_equi_phone := 'N';
END  get_rebranding_attributes;

--CR48846 Adding new procedures for device recovery code processing
PROCEDURE insert_device_recovery_code (i_esn                    IN  VARCHAR2,
                                       i_min                    IN  VARCHAR2,
                                       i_security_code          IN  VARCHAR2,
                                       i_communication_channel  IN  VARCHAR2,
                                       o_err_num                OUT NUMBER,
                                       o_err_msg                OUT VARCHAR2)
IS
  n_valid_seconds          NUMBER;
  n_objid                  NUMBER;
BEGIN

   --Either ESN or MIN is required
   IF i_esn IS NULL AND i_min IS NULL THEN
     o_err_num := -1;
     o_err_msg  := 'MISSING ESN/MIN';
     RETURN;
   END IF;

   --Security Code and Communication channel are both required
   IF i_security_code IS NULL OR i_communication_channel IS NULL THEN
      o_err_num := -2;
      o_err_msg  := 'MISSING SECURITY CODE/COMMUNICATION CHANNEL';
      RETURN;
   END IF;

   --Fetch validity time for the device recovery code
   BEGIN
     SELECT x_param_value
     INTO n_valid_seconds
     FROM table_x_parameters
     WHERE x_param_name = 'DEVICE_RECOVERY_CODE_VALID_TIME';
   EXCEPTION
    WHEN OTHERS THEN
       --DEFAULT TO 10 MINUTES
       n_valid_seconds := 600;
   END;

   --Update the record for that ESN/MIN if it already exists else create new record
   MERGE
   INTO  x_device_recovery_code d
   USING ( SELECT objid, esn, min, security_code, communication_channel, creation_time
           from  x_device_recovery_code
           WHERE (esn = i_esn OR min = i_min)
           AND communication_channel = i_communication_channel
           AND creation_time         >  SYSDATE - NUMTODSINTERVAL(n_valid_seconds,'SECOND')
           UNION
           SELECT NULL, i_esn esn, i_min min, i_security_code security_code, i_communication_channel communication_channel, SYSDATE creation_time
           FROM DUAL
           WHERE NOT EXISTS (SELECT 1
                             FROM  x_device_recovery_code
                             WHERE (esn = i_esn OR min = i_min)
                             AND communication_channel = i_communication_channel
                             AND creation_time         >  SYSDATE - NUMTODSINTERVAL(n_valid_seconds,'SECOND')
                            )
         ) s
   ON    ( d.objid = s.objid )
   WHEN MATCHED THEN
    UPDATE
    SET      security_code        = i_security_code,
             last_validation_time = NULL,
             failed_attempts      = 0,
             used_status          = 'N',
             creation_time        = SYSDATE
   WHEN NOT MATCHED THEN
     INSERT ( d.objid,
              d.esn,
              d.min,
              d.security_code,
              d.creation_time,
              d.last_validation_time,
              d.failed_attempts,
              d.communication_channel,
              d.used_status)
     VALUES( seq_x_device_recovery_code.NEXTVAL,
             s.esn,
             s.min,
             s.security_code,
             SYSDATE,
             NULL,
             0,
             s.communication_channel,
             'N');

   o_err_num := 0;
   o_err_msg := 'SUCCESS';

EXCEPTION
    WHEN OTHERS THEN
      o_err_num := -3;
      o_err_msg := dbms_utility.format_error_backtrace()|| SQLERRM ;
END  insert_device_recovery_code;

PROCEDURE verify_device_recovery_code(i_esn                    IN  VARCHAR2,
                                      i_min                    IN  VARCHAR2,
                                      i_security_code          IN  VARCHAR2,
                                      i_communication_channel  IN  VARCHAR2,
                                      o_result                 OUT NUMBER,
                                      o_err_num                OUT NUMBER,
                                      o_err_msg                OUT VARCHAR2)
IS
  n_valid_attempts      NUMBER;
  n_valid_seconds       NUMBER;
BEGIN

   IF i_esn IS NULL AND i_min IS NULL THEN
     o_err_num := -1;
     o_err_msg  := 'MISSING ESN/MIN';
     RETURN;
   END IF;

   IF i_security_code IS NULL OR i_communication_channel IS NULL THEN
      o_err_num := -2;
      o_err_msg  := 'MISSING SECURITY CODE/COMMUNICATION CHANNEL';
      RETURN;
   END IF;

   --Fetch allowed attempts for the device recovery code
   BEGIN
     SELECT x_param_value
     INTO n_valid_attempts
     FROM table_x_parameters
     WHERE x_param_name = 'DEVICE_RECOVERY_CODE_VALID_ATTEMPTS';
   EXCEPTION
    WHEN OTHERS THEN
       --DEFAULT TO 5 ATTEMPTS
       n_valid_attempts := 5;
   END;

   --Fetch validity time for the device recovery code
   BEGIN
     SELECT x_param_value
     INTO n_valid_seconds
     FROM table_x_parameters
     WHERE x_param_name = 'DEVICE_RECOVERY_CODE_VALID_TIME';
   EXCEPTION
    WHEN OTHERS THEN
       --DEFAULT TO 10 MINUTES
       n_valid_seconds := 600;
   END;

   --Validate the device recovery code
   SELECT COUNT(1)
   INTO o_result
   FROM x_device_recovery_code
   WHERE security_code         =  i_security_code
   AND   communication_channel =  i_communication_channel
   AND   used_status           =  'N'
   AND   creation_time         >  SYSDATE - NUMTODSINTERVAL(n_valid_seconds,'SECOND')
   AND   failed_attempts       <= n_valid_attempts
   AND   (min                  =  i_min
          OR esn               =  i_esn);

   -- Update the validation status/time
   UPDATE x_device_recovery_code
   SET   used_status = case when o_result > 0  then 'Y' else used_status end,
         failed_attempts = case when o_result > 0 then failed_attempts else failed_attempts+1 end,
         last_validation_time = SYSDATE
   WHERE (min                  =  i_min
          OR esn               =  i_esn)
   AND   communication_channel =  i_communication_channel
   AND   creation_time         >  SYSDATE - NUMTODSINTERVAL(n_valid_seconds,'SECOND');

   o_err_num := 0;
   o_err_msg  := 'SUCCESS';

EXCEPTION
    WHEN OTHERS THEN
      o_err_num := -3;
      o_err_msg := dbms_utility.format_error_backtrace()|| sqlerrm ;
END  verify_device_recovery_code;

PROCEDURE get_inquiry_type ( i_esn            IN  table_part_inst.part_serial_no%TYPE,
                             i_brand          IN  VARCHAR2,
                             i_inquiry_type   OUT VARCHAR2   )
IS

BEGIN
  IF i_brand = 'TRACFONE' OR
     ( i_brand = 'NET10' AND
       nvl(sa.get_serv_plan_value(sa.customer_info.get_service_plan_objid(i_esn => i_esn),'SERVICE_PLAN_GROUP'),0) NOT IN ( 'UNLIMITED',
                                                                                                                            'FP_UNLIMITED',
                                                                                                                            'UNLIMITED_ILD',
                                                                                                                            'FP_UNLIMITED_ILD',
                                                                                                                            'VOICE_ONLY',
                                                                                                                            'SL VOICE ONLY',
                                                                                                                            'VOICE_ONLY_ILD'
            ) )
  THEN -- Only for TRACFONE,for groups which are not 'UNLIMITED', 'FP_UNLIMITED', 'UNLIMITED_ILD', 'FP_UNLIMITED_ILD' the inquiry_type should be BALANCE for others USAGE.(CR53217)
    i_inquiry_type := 'BALANCE';
  ELSE
    i_inquiry_type := 'USAGE';
  END IF;
EXCEPTION
WHEN OTHERS THEN
  NULL;
END get_inquiry_type;
--CR48846 end

--CR48260 start
FUNCTION is_device_verified (i_device_id       IN    VARCHAR2)
  RETURN VARCHAR2
IS
  c_verified_flag VARCHAR2(1);
BEGIN
  SELECT 'Y'
  INTO   c_verified_flag
  FROM   x_device_recovery_code
  WHERE  (esn = i_device_id OR min = i_device_id)
  AND    used_status ='Y'
  AND    last_validation_time > (SYSDATE - to_number(sa.get_param_value ('RTR_ALLOWED_DEVICE_VERIFICATION_TIME'))/1440)
  AND    ROWNUM = 1;

  RETURN NVL(c_verified_flag, 'N');
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END is_device_verified;
--CR4826- end

END SP_MOBILE_ACCOUNT;
-- ANTHILL_TEST PLSQL/SA/PackageBodies/SP_MOBILE_ACCOUNT_BODY.sql 	CR55236: 1.187
/