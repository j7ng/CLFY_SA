CREATE OR REPLACE PACKAGE BODY sa.payment_services_pkg
IS
 /*******************************************************************************************************
 --$RCSfile: PAYMENT_SERVICES_PKb.sql,v $
 --$Revision: 1.214 $
 --$Author: tbaney $
 --$Date: 2018/04/17 13:22:46 $
 --$ $Log: PAYMENT_SERVICES_PKb.sql,v $
 --$ Revision 1.214  2018/04/17 13:22:46  tbaney
 --$ Corrected comment.
 --$
 --$ Revision 1.213  2018/04/16 21:03:24  tbaney
 --$ Populated the payment status field.
 --$
 --$ Revision 1.212  2018/04/16 19:34:56  tbaney
 --$ CR57737_artSOA_Fetching_inactive_CC_at_the_time_of_Auto_Refill_payment_for_SM_WFM
 --$
 --$ Revision 1.211  2018/01/10 21:46:16  smacha
 --$ Merged to prod version.
 --$
 --$ Revision 1.210  2018/01/05 15:02:23  mshah
 --$ CR53474 - Net10 Business ACH Data club real time processing.
 --$
 --$ Revision 1.209  2018/01/04 23:48:37  mshah
 --$ CR53474 - Net10 Business ACH Data club real time processing.
 --$
 --$ Revision 1.208  2018/01/04 22:56:51  mshah
 --$ CR53474 - Net10 Business ACH Data club real time processing.
 --$
 --$ Revision 1.205  2017/12/07 14:02:57  skambhammettu
 --$ CR53217--new procedures
 --$
 --$ Revision 1.204  2017/12/05 02:53:10  sgangineni
 --$ Code merged with prod code - commiting on behlaf Sagar Inturi
 --$
 --$ Revision 1.192 2017/09/28 21:52:11 mtholkappian
 --$ changes over latest production version
 --$
 --$ Revision 1.189 2017/09/22 17:15:31 tpathare
 --$ Fix for country NULL in table_address
 --$
 --$ Revision 1.182 2017/08/03 21:40:18 mmunoz
 --$ CR52543 : Fix lines with comment, replacing // for --
 --$
 --$ Revision 1.181 2017/08/02 12:23:04 hcampano
 --$ CR52543 Straight Talks Rewards Program enrollment is failing in TAS - Part of REL900 - Scheduled for 8/22/17 - SITB
 --$ Added back application key in check_aps and added logic to insert_alternate_paymentsource to for LRP customers during enrollment.
 --$
 --$ Revision 1.180 2017/08/01 18:48:37 sraman
 --$ Merged with 1.177, 178 and 179 as CR52703 is also added to 8/22 release.
 --$
 --$ Revision 1.179 2017/08/01 15:33:01 hcampano
 --$ CR52543 Straight Talks Rewards Program enrollment is failing in TAS - Part of REL900 - Scheduled for 8/22/17 - SITB
 --$ MERGED WITH CODE VERSION 1.177 (CR47992)
 --$
 --$ Revision 1.177 2017/07/25 19:50:34 jcheruvathoor
 --$ CR47992		UP IVR BackEnd Changes
 --$
 --$ Revision 1.174 2017/07/18 22:06:27 tpathare
 --$ 52164 - Fix for country column NULL in table_address
 --$
 --$ Revision 1.172 2017/06/23 18:56:38 nmuthukkaruppan
 --$ CR50154 - ST LTO Phase II changes
 --$
 --$ Revision 1.171 2017/06/23 18:51:50 nmuthukkaruppan
 --$ CR50154 - ST LTO Phase II changes - additional attributes in update_settlement_rec
 --$
 --$ Revision 1.170 2017/06/22 21:44:45 nmuthukkaruppan
 --$ CR50154 - ST LTO Phase II merged with Prod release 06/22
 --$
 --$ Revision 1.169 2017/06/21 21:08:08 nmuthukkaruppan
 --$ CR50154 - ST LTO Phase II changes.
 --$
 --$ Revision 1.168 2017/06/16 22:02:58 nmuthukkaruppan
 --$ CR50154 - ST LTO Phase II changes
 --$
 --$ Revision 1.165 2017/06/01 20:37:01 nmuthukkaruppan
 --$ CR50154 - ST LTO - Retriggering Settlement flow for SmartPay
 --$
 --$ Revision 1.164 2017/05/19 19:40:02 nmuthukkaruppan
 --$ CR50154 - ST LTO merged with production.
 --$
 --$ Revision 1.162 2017/04/27 22:08:11 nmuthukkaruppan
 --$ CR50154 - ST LTO - Added Retriggering logic for SmartPay in Validate_auth_settle proc.
 --$
 --$ Revision 1.160 2017/04/27 19:29:09 nsurapaneni
 --$ Error code fix in getpaymentsourcehistory and Getpaymentsource procedure.
 --$
 --$ Revision 1.159 2017/04/26 18:32:55 nsurapaneni
 --$ input type table IS NULL and COUNT validation
 --$
 --$ Revision 1.158 2017/04/25 23:30:14 aganesan
 --$ CR49696 - Getpaymentsource procedure condition include for brand check
 --$
 --$ Revision 1.157 2017/04/24 14:21:17 sgangineni
 --$ CR49696 - Changed the error code for zip code validation
 --$
 --$ Revision 1.156 2017/04/24 14:05:50 sgangineni
 --$ CR49696 - replaced validate_zip_code call with is_valid_zip_code
 --$
 --$ Revision 1.155 2017/04/24 13:45:39 sgangineni
 --$ CR49696 - Added logic to validate zip code for US in addpaymentsource and updatepaymentsource.
 --$
 --$ Revision 1.153 2017/04/06 15:29:53 sgangineni
 --$ CR47564 - Fix for defect #23736
 --$
 --$ Revision 1.152 2017/04/05 18:55:36 aganesan
 --$ CR47564 - Removed commented code from addpaymentsource procedure
 --$
 --$ Revision 1.151 2017/04/04 22:47:04 sgangineni
 --$ CR47564 - Fix for existing defect#23169 - Modified getpaymentsourcedetails to send
 --$ address_2 value
 --$
 --$ Revision 1.149 2017/03/22 14:25:04 aganesan
 --$ CR47564 Addpayment source modified to handle ESN new status during purchase.
 --$
 --$ Revision 1.148 2017/03/21 20:49:19 nsurapaneni
 --$ Code changes Addpaymentsource,Updatepaymentsource , getpaymentsource and formatting
 --$
 --$ Revision 1.146 2017/02/27 21:24:44 aganesan
 --$ CR47564 - Addpaymentsource by ESN procedure modified to handle check if the payment source exists
 --$
 --$ Revision 1.145 2017/02/20 22:18:20 aganesan
 --$ CR47564 - getpaymentsourcehistory modified to handle duplicate payment source ids
 --$
 --$ Revision 1.144 2017/02/17 02:44:24 aganesan
 --$ CR47564 Review comments and validations modified
 --$
 --$ Revision 1.140 2017/02/09 01:22:17 aganesan
 --$ CR47564 - Addpaymentsource additional validation included payment source exists check
 --$
 --$ Revision 1.139 2017/02/08 02:06:26 aganesan
 --$ CR47564 Removepaymentsource brand validation added
 --$
 --$ Revision 1.138 2017/02/08 01:25:35 aganesan
 --$ CR47564 - New condition added for removepaymentsource changes
 --$
 --$ Revision 1.136 2017/02/04 22:20:21 aganesan
 --$ CR47564 New stored procedure added to add payment source based on ESN
 --$
 --$ Revision 1.135 2017/02/03 19:36:24 aganesan
 --$ CR47564 Condition modified to handle when only login name is passed
 --$
 --$ Revision 1.134 2017/02/03 00:04:29 aganesan
 --$ CR47564 Modified code for integration testing fix
 --$
 --$ Revision 1.130 2017/01/27 21:45:24 aganesan
 --$ CR47564 Condition modified to handle invalid brand and login association
 --$
 --$ Revision 1.128 2017/01/24 22:45:27 aganesan
 --$ CR47564 upper case handled for active status check in the existing procedure calls
 --$
 --$ Revision 1.123 2017/01/18 20:21:11 aganesan
 --$ CR47564 - WFM changes merged with CR46581 Go Smart production release version
 --$
 --$ Revision 1.121 2016/12/15 23:12:20 sraman
 --$ CR44729 ??? Go Smart Data Migration - added new merchant id
 --$
 --$ Revision 1.120 2016/11/11 15:19:50 abustos
 --$ CR46468 - changes to only have one lower case in x_customer_email in x_buz_purch_hdr
 --$
 --$ Revision 1.119 2016/11/07 16:25:36 smeganathan
 --$ CR46373 code fix to handle REVIEW for Charge transactions
 --$
 --$ Revision 1.118 2016/10/28 20:43:14 smeganathan
 --$ CR43524 added a call to sp_ivr_insert_order_info from validate_settle_authid for CHARGE transactions
 --$
 --$ Revision 1.117 2016/10/21 16:41:03 smeganathan
 --$ CR43524 defect fix
 --$
 --$ Revision 1.116 2016/09/06 18:24:18 smeganathan
 --$ CR43524 incorporated code review comments
 --$
 --$ Revision 1.115 2016/08/26 21:16:56 smeganathan
 --$ CR43248 changes for charge transaction
 --$
 --$ Revision 1.114 2016/08/03 17:30:15 smeganathan
 --$ CR43524 Changes for IVR Tracfone
 --$
 --$ Revision 1.113 2016/08/03 14:12:26 skota
 --$ Merged the code
 --$
 --$ Revision 1.111 2016/07/08 14:13:36 nmuthukkaruppan
 --$ CR39912 - ST Commerce changes merged with Etailer Prod version.
 --$
 --$ Revision 1.109 2016/06/29 18:40:27 smeganathan
 --$ Merged etailer code alone with prod version
 --$
 --$ Revision 1.108 2016/06/20 18:23:59 smeganathan
 --$ replaced customer type with red card type
 --$
 --$ Revision 1.107 2016/06/08 19:29:31 nmuthukkaruppan
 --$ CR39912 - Straight Talk Go Live changes Merged with Etailer Changes
 --$
 --$ Revision 1.106 2016/06/07 16:13:12 smeganathan
 --$ CR43162 changed p_update_smp added new parameter i_pin
 --$
 --$ Revision 1.105 2016/06/02 15:56:13 smeganathan
 --$ Added new proc p_update_smp for etailer
 --$
 --$ Revision 1.104 2016/05/31 20:06:10 nmuthukkaruppan
 --$ CR39912 - Straight Talk Launch
 --$ Revision 1.102 2016/05/17 18:25:09 smeganathan
 --$ changes for eteds in inserts purch
 --$
 --$ Revision 1.101 2016/05/13 21:08:52 smeganathan
 --$ CR42257 changes for Payment source ID for ETEDS
 --$
 --$ Revision 1.100 2016/05/12 15:39:04 smeganathan
 --$ CR42257 payment source id changes for Etailer
 --$
 --$ Revision 1.99 2016/05/06 23:04:04 smeganathan
 --$ CR42257 merchant id changes for Etailer project
 --$
 --$ Revision 1.95 2016/02/03 21:07:31 aganesan
 --$ Update variable to get the auth request ID.
 --$
 --$ Revision 1.94 2016/02/02 21:44:38 aganesan
 --$ CR26169 - Biz_order_dtl table population changes to retrieve the APP and AR plan part number.
 --$
 --$ Revision 1.93 2016/02/01 23:56:17 aganesan
 --$ CR26169 - Biz order detail info table population changes.
 --$
 --$ Revision 1.89 2016/01/27 17:37:11 aganesan
 --$ CR26169 - Refund flow fix to restrict AR partnumber.
 --$
 --$ Revision 1.86 2015/11/28 04:39:53 nmuthukkaruppan
 --$ CR36886 - Changes to incorporate ST B2C - SMART PAY requirements
 --$
 --$ Revision 1.79 2015/10/28 18:11:44 rpednekar
 --$ CR35874- Update statement added in procedure validate_settle_authid
 --$
 --$ Revision 1.74 2015/10/07 18:34:43 jarza
 --$ CR37343 - populating country name in GETPAYMENTSOURCEDETAILS
 --$
 --$ Revision 1.56 2015/02/20 20:45:54 oarbab
 --$ CR28870 removed AND ba.x_routing = ip_routing_number
 --$ per SOA this will always be null
 --$
 --$ Revision 1.55 2015/02/19 23:39:57 oarbab
 --$ CR28870 REMOVED X_CUSTOMER_ACCT_ENC AS PER soa TEAM
 --$
 --$ Revision 1.54 2015/02/19 21:11:28 oarbab
 --$ CR31683 UPDATED UPPER(cc.x_cc_type) = days.s_card_type;
 --$
 --$ Revision 1.53 2015/02/19 17:16:05 oarbab
 --$ CR28870 modified proc check_ba_ps added ba.X_CUSTOMER_ACCT_ENC = ip_cust_acct_enc
 --$
 --$ Revision 1.52 2015/02/18 21:36:47 oarbab
 --$ CR28870 insert ACH encrypted info.
 --$
 --$ Revision 1.51 2015/02/13 20:41:53 ahabeeb
 --$ CR28870
 --$
 --$ Revision 1.49 2015/02/07 18:41:21 vmadhawnadella
 --$ CR28870 CHANGES
 --$
 --$ Revision 1.48 2014/12/10 23:28:42 oarbab
 --$ CR31699_Clearway_Reauthorization_Fix
 --$
 --$ Revision 1.47 2014/12/09 14:55:53 oarbab
 --$ CR30348 Simple Commerce Sub Release Alpha
 --$
 --$ Revision 1.43 2014/09/16 13:21:28 cpannala
 --$ CR30715
 --$
 --$ Revision 1.40 2014/08/18 15:02:49 cpannala
 --$ Cr30255 Changes to remove payment source
 --$
 --$ Revision 1.39 2014/07/23 21:21:25 cpannala
 --$ CR29771 Changes for Billing History and validate settle authid
 --$
 --$ Revision 1.38 2014/07/14 14:34:11 cpannala
 --$ Cr29468 New enhancements for billing history
 --$
 --$ Revision 1.37 2014/07/07 14:02:00 cpannala
 --$ Billing History payment id changed to Merchant ref number
 --$
 --$ Revision 1.29 2014/05/23 20:41:51 ahabeeb
 --$ updated validated_settle_authid to clone purch_dtls records also.
 --$
 --$ Revision 1.28 2014/05/22 21:22:28 cpannala
 --$ CR28999
 --$
 --$ Revision 1.25 2014/05/12 22:22:32 cpannala
 --$ CR25490 insurts purch chages for defect 168
 --$
 --$ Revision 1.24 2014/05/06 14:58:01 cpannala
 --$ CR25490 / missing in end of file
 --$
 --$ Revision 1.23 2014/05/02 15:39:54 ahabeeb
 --$ updated validate_settle_authid
 --$
 --$ Revision 1.14 2014/03/11 19:08:23 cpannala
 --$ CR25490 Added error logic
 --$
 --$ Revision 1.1 2013/12/05 16:22:36 cpannala
 --$ CR22623 - B2B Initiative
 --$
 * Description: This package includes the five procedures
 * getpaymentsource, getpaymentsourcedetails, addpaymentsource, updatepaymentsource, removepaymentsource and also the Enrollment Services.
 *
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/
 ---------------to get number of payment sources availble to the existing account.-----*/
PROCEDURE Getpaymentsource( In_Login_Name IN VARCHAR2,
 In_Bus_Org_Id IN VARCHAR2,
 In_Esn IN VARCHAR2,
 In_Min IN VARCHAR2,
 in_PYMT_SRC_TYPE IN VARCHAR2,
 OUT_tbl OUT pymt_src_tbl,
 Out_Err_Num OUT NUMBER,
 Out_Err_Msg OUT VARCHAR2)IS

 PYMT_SRC_OBJ TYP_PYMT_SRC_OBJ := TYP_PYMT_SRC_OBJ (NULL, NULL, NULL, NULL, NULL, NULL, NULL);
 DTL_PYMT_SRC PYMT_SRC_TBL := PYMT_SRC_TBL (NULL);
 WU_OBJID NUMBER;
 Bo_Objid NUMBER;
 Boobjid NUMBER;
 Brand VARCHAR2 (40);
 esn_wu_objid NUMBER;
BEGIN
 IF in_login_name IS NULL OR in_BUS_ORG_ID IS NULL THEN
 Out_Err_Num := 701; ---'Login name and bus org required'
 Out_Err_Msg := sa.Get_Code_Fun ('SA.PAYMENT_SERVICES_PKG', Out_Err_Num, 'ENGLISH');
 RETURN;
 END IF;
 B2B_PKG.get_esn_web_user (in_login_name, in_bus_org_id, in_esn, in_min, wu_objid, esn_wu_objid, bo_objid, out_err_num, out_err_msg);
 IF out_err_num = 0 THEN
 IF ( (wu_objid IS NOT NULL) OR (esn_wu_objid IS NOT NULL)) AND ( (in_pymt_src_type IS NULL) OR (in_pymt_src_type != 'CREDITCARD')) THEN
 SELECT TYP_PYMT_SRC_OBJ (ps.objid, ps.x_pymt_type, ps.x_status, ps.x_is_default, ps.x_billing_email, NULL, NULL) BULK COLLECT
 INTO dtl_pymt_src
 FROM x_payment_source ps,
 table_web_user wu
 WHERE ps.pymt_src2web_user = wu.objid
 AND ps.x_status = 'ACTIVE' --Cpannala
 AND WU.OBJID = NVL (WU_OBJID, esn_WU_OBJID);
 END IF;
 IF ( (wu_objid IS NOT NULL) OR (esn_wu_objid IS NOT NULL)) AND in_pymt_src_type = 'CREDITCARD' THEN
 SELECT typ_pymt_src_obj (ps.objid, cc.x_cc_type, ps.x_status, ps.x_is_default, ps.x_billing_email, cc.x_customer_cc_number, cc.x_cc_type) BULK COLLECT
 INTO dtl_pymt_src
 FROM table_x_credit_card cc,
 x_payment_source ps,
 table_web_user wu
 WHERE PS.PYMT_SRC2X_CREDIT_CARD = CC.OBJID
 AND ps.x_status = 'ACTIVE' --Cpannala
 AND ps.pymt_src2web_user = wu.objid
 AND wu.objid = wu_objid
 AND PS.X_PYMT_TYPE = 'CREDITCARD';
 END IF;
 Out_Err_Num := '0';
 Out_Err_Msg := 'Success';
 OUT_TBL := DTL_PYMT_SRC;
 END IF;
 EXCEPTION
 WHEN OTHERS THEN
 out_err_num := SQLCODE;
 OUT_ERR_MSG := SUBSTR (SQLERRM, 1, 300);
 UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL,
 IP_KEY => IN_LOGIN_NAME,
 IP_PROGRAM_NAME => 'SA.PAYMENT_SERVICES_PKG.GETPAYMENTSOURCE',
 iP_ERROR_TEXT => OUT_ERR_MSG);
END getpaymentsource;
---------------to get payment source details of the existing account.-----
PROCEDURE getpaymentsourcedetails(p_pymt_src_id IN NUMBER,
 out_rec OUT typ_pymt_src_dtls_rec,
 out_err_num OUT NUMBER,
 out_err_msg OUT VARCHAR2)IS

 v_objid VARCHAR2 (40);
 v_payment_type VARCHAR2 (80);
 --out_err_num NUMBER;
 --out_err_msg VARCHAR2 (40);
BEGIN
 IF p_pymt_src_id IS NULL THEN
 out_err_num := 702; ------'payment source id required'
 out_err_msg := sa.get_code_fun ('SA.PAYMENT_SERVICES_PKG', out_err_num, 'ENGLISH');
 RETURN;
 END IF;
 BEGIN
 SELECT ps.objid,ps.x_pymt_type
 INTO v_objid, v_payment_type
 FROM x_payment_source ps
 WHERE ps.objid = p_pymt_src_id;
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
 out_err_num := 702; --asim change this eg 703 so that the call below will get "pymnt_src_id not found"
 out_err_msg := sa.get_code_fun ('SA.PAYMENT_SERVICES_PKG', out_err_num, 'ENGLISH');
 RETURN;
 WHEN OTHERS THEN
 out_err_num := 702; --asim same as above
 out_err_msg := sa.get_code_fun ('SA.PAYMENT_SERVICES_PKG', out_err_num, 'ENGLISH');
 RETURN;
 END;
 IF v_payment_type = 'CREDITCARD' THEN
 BEGIN
 SELECT typ_pymt_src_dtls_rec ( ps.objid, ps.x_pymt_type, ps.x_status, ps.x_is_default, ps.x_billing_email, typ_creditcard_info ( cc.x_customer_cc_number, cc.x_cc_type, ( cc.x_customer_cc_expmo
 || '-'
 || cc.x_customer_cc_expyr), NULL, NULL, cc.X_CUST_CC_NUM_ENC, cc.X_CUST_CC_NUM_KEY, cert.X_CC_ALGO, cert.X_KEY_ALGO, cert.x_cert), cc.x_customer_firstname, cc.x_customer_lastname, cc.x_customer_email, address_type_rec (a.address, a.address_2, a.city, a.state, c.s_name, a.zipcode), cc.x_cust_cc_num_key, NULL, NULL)
 INTO out_rec
 FROM table_x_credit_card cc,
 x_cert cert,
 x_payment_source ps,
 table_address a,
 sa.table_country c
 WHERE ps.pymt_src2x_credit_card = cc.objid
 AND UPPER(ps.x_status) = 'ACTIVE' --Cpannala --CR47564 WFM
 AND cc.x_credit_card2address = a.objid(+)
 AND a.address2country = c.objid(+)
 AND cc.creditcard2cert = cert.objid
 AND ps.objid = v_objid;
 EXCEPTION
 WHEN OTHERS THEN
 out_err_num := 702;
 out_err_msg := 'Missing details'; --SA.GET_CODE_FUN('SA.PAYMENT_SERVICES_PKG', out_err_num, 'ENGLISH');
 END;
 ELSIF v_payment_type = 'APS' THEN ---Added for Smartpay integration on 07/15/2015
 BEGIN
 SELECT typ_pymt_src_dtls_rec ( ps.objid, ps.x_pymt_type, ps.x_status, ps.x_is_default, ps.x_billing_email, NULL, aps.x_customer_firstname, aps.x_customer_lastname, aps.x_customer_email, address_type_rec (a.address, a.address_2, a.city, a.state, c.s_name, a.zipcode), NULL, NULL, typ_aps_info ( aps.x_alt_pymt_source,aps.x_alt_pymt_source_type,aps.x_application_key))
 INTO out_rec
 FROM table_x_altpymtsource aps,
 x_payment_source ps,
 table_address a,
 sa.table_country c
 WHERE ps.pymt_src2x_altpymtsource = aps.objid
 AND UPPER(ps.x_status) = 'ACTIVE' --CR47564 WFM
 AND aps.x_altpymtsource2address = a.objid(+)
 AND a.address2country = c.objid(+)
 AND ps.objid = v_objid;
 EXCEPTION
 WHEN OTHERS THEN
 out_err_num := 702;
 out_err_msg := 'Missing details'; --SA.GET_CODE_FUN('SA.PAYMENT_SERVICES_PKG', out_err_num, 'ENGLISH');
 END;
 ELSE
 BEGIN
 SELECT typ_pymt_src_dtls_rec ( ps.objid, ps.x_pymt_type, ps.x_status, ps.x_is_default, ps.x_billing_email, NULL, ba.x_customer_firstname, ba.x_customer_lastname, ba.x_customer_email, address_type_rec (a.address, a.address_2, a.city, a.state, c.s_name, a.zipcode), NULL, typ_ach_info(ba.x_routing, ba.x_customer_acct, ba.x_aba_transit, ba.x_customer_acct_key, ba.x_customer_acct_enc, cert.x_cert, cert.x_key_algo, cert.x_cc_algo), NULL)
 INTO out_rec
 FROM table_x_bank_account ba,
 x_payment_source ps,
 table_address a,
 x_cert cert,
 sa.table_country c
 WHERE ps.pymt_src2x_bank_account = ba.objid
 AND UPPER(ps.x_status) = 'ACTIVE' --Cpannala --CR47564 WFM
 AND ba.x_bank_acct2address = a.objid(+)
 AND a.address2country = c.objid(+)
 AND ps.objid = v_objid
 AND ba.bank2cert = cert.objid;
 EXCEPTION
 WHEN OTHERS THEN
 out_err_num := 702;
 out_err_msg := 'Missing details'; --SA.GET_CODE_FUN('SA.PAYMENT_SERVICES_PKG', out_err_num, 'ENGLISH');
 END;
 END IF;
 out_err_num := 0;
 out_err_msg := 'Success';
EXCEPTION
WHEN OTHERS THEN
 out_err_num := SQLCODE;
 out_err_msg := SUBSTR (SQLERRM, 1, 300);
 UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL,
 IP_KEY => TO_CHAR (P_PYMT_SRC_ID),
 IP_PROGRAM_NAME => 'SA.PAYMENT_SERVICES_PKG.GETPAYMENTSOURCEDETAILS',
 iP_ERROR_TEXT => out_err_msg);
END getpaymentsourcedetails;

---------------to add new payment source to the existing account.-----

PROCEDURE insert_bank_account(p_rec IN typ_pymt_src_dtls_rec,
 ip_contact_objid NUMBER,
 ip_addr_objid NUMBER,
 ip_phone_no VARCHAR2,
 ip_bo_objid NUMBER,
 op_ba_objid OUT NUMBER,
 op_err_num OUT NUMBER,
 op_err_msg OUT VARCHAR2)IS

 l_bank_acnt_objid NUMBER := 0;
BEGIN
 l_bank_acnt_objid := sa.sequ_x_bank_account.NEXTVAL;
 INSERT
 INTO table_x_bank_account
 (
 objid,
 x_bank_num,
 x_customer_acct,
 x_routing,
 x_aba_transit,
 x_bank_name,
 x_status,
 x_customer_firstname,
 x_customer_lastname,
 x_customer_phone,
 x_customer_email,
 x_max_purch_amt,
 x_max_trans_per_month,
 x_max_purch_amt_per_month,
 x_changedate,
 x_original_insert_date,
 x_changedby,
 x_cc_comments,
 x_moms_maiden,
 x_bank_acct2contact,
 x_bank_acct2address,
 x_bank_account2bus_org,
 bank2cert, --CR28870
 x_customer_acct_key, --CR28870
 x_customer_acct_enc --CR28870
 )
 VALUES
 (
 l_bank_acnt_objid, --objid
 NULL, -- x_bank_num
 p_rec.ach_info.account_number,-- encrypted routing and acc combined CR28870
 NULL, -- p_rec.ach_info.routing_number, CR28870
 p_rec.ach_info.account_type,
 NULL,
 p_rec.payment_status,
 p_rec.first_name,
 p_rec.last_name,
 ip_phone_no,
 p_rec.email,
 NULL,
 NULL,
 NULL,
 SYSDATE,
 SYSDATE,
 NULL,
 NULL,
 NULL,
 ip_contact_objid,
 ip_addr_objid,
 ip_bo_objid,
 (SELECT OBJID -- bank2cert CR28870
 FROM X_CERT
 WHERE X_CERT = p_rec.ach_info.cert
 AND x_key_algo = p_rec.ach_info.key_algo
 AND x_cc_algo = p_rec.ach_info.cc_algo
 ), --CR28870
 p_rec.ach_info.customer_acct_key, --CR28870
 p_rec.ach_info.customer_acct_enc --CR28870
 );
 op_ba_objid := l_bank_acnt_objid;
EXCEPTION
WHEN OTHERS THEN
 op_err_num := 1;
 op_err_msg := 'Inserting into bank account ' || SUBSTR (SQLERRM, 1, 100);
RETURN;
END insert_bank_account;
------------------------------------------------------------------------------------
PROCEDURE insert_alternate_paymentsource( p_rec IN typ_pymt_src_dtls_rec,
 ip_contact_objid NUMBER,
 ip_addr_objid NUMBER,
 ip_phone_no VARCHAR2,
 ip_bo_objid NUMBER,
 op_aps_objid OUT NUMBER,
 op_err_num OUT NUMBER,
 op_err_msg OUT VARCHAR2)IS
 l_aps_objid NUMBER := 0;
 v_app_key sa.table_x_altpymtsource.X_APPLICATION_KEY%TYPE; --THIS IS A VARCHAR2(100);
BEGIN
 l_aps_objid := sa.sequ_x_altpymtsource.NEXTVAL;

 --ENTERED LAST
 if p_rec.aps_info.Alt_Pymt_Source = 'LOYALTY_PTS' then
 v_app_key := 'LTPS_'||ip_contact_objid;
 else
 v_app_key := p_rec.aps_info.Application_Key;
 end if;

 INSERT
 INTO table_x_altpymtsource
 (
 objid,
 x_alt_pymt_source,
 x_alt_pymt_source_type,
 x_application_key,
 x_status,
 x_customer_firstname,
 x_customer_lastname,
 x_customer_phone,
 x_customer_email,
 x_changedate,
 x_original_insert_date,
 x_changedby,
 x_comments,
 x_moms_maiden,
 x_altpymtsource2contact,
 x_altpymtsource2address,
 x_altpymtsource2bus_org
 )
 VALUES
 (
 l_aps_objid, --objid
 p_rec.aps_info.Alt_Pymt_Source, -- Alt_Pymt_Source
 p_rec.aps_info.Alt_Pymt_Source_Type,-- Alt_Pymt_Source_Type
 v_app_key, --p_rec.aps_info.Application_Key, --Application Key
 p_rec.payment_status,
 p_rec.first_name,
 p_rec.last_name,
 ip_phone_no,
 p_rec.email,
 SYSDATE,
 SYSDATE,
 NULL,
 NULL,
 NULL,
 ip_contact_objid,
 ip_addr_objid,
 ip_bo_objid
 );
 op_aps_objid := l_aps_objid;
EXCEPTION
WHEN OTHERS THEN
 op_err_num := 1;
 op_err_msg := 'Inserting into Alternate Payment source ' || SUBSTR (SQLERRM, 1, 100);
RETURN;
END insert_alternate_paymentsource;

FUNCTION insert_pymt_src( p_rec typ_pymt_src_dtls_rec,
 ip_pymt_src_name VARCHAR2,
 ip_cc_objid VARCHAR2,
 ip_ba_objid NUMBER,
 ip_aps_objid NUMBER,
 ip_wu_objid NUMBER,
 op_err_num OUT NUMBER,
 op_err_msg OUT VARCHAR2
 )RETURN NUMBER IS
 out_pymt_src_objid NUMBER;
BEGIN
 INSERT
 INTO x_payment_source
 (
 objid,
 x_pymt_type,
 x_pymt_src_name,
 x_status,
 x_is_default,
 x_insert_date,
 x_update_date,
 x_sourcesystem,
 x_changedby,
 pymt_src2web_user,
 pymt_src2x_credit_card,
 pymt_src2x_bank_account,
 x_billing_email,
 pymt_src2x_altpymtsource
 )
 VALUES
 (
 seq_x_payment_source.NEXTVAL,
 p_rec.payment_type,
 ip_pymt_src_name,
 p_rec.payment_status,
 p_rec.is_default,
 SYSDATE,
 SYSDATE,
 NULL,
 NULL,
 ip_wu_objid,
 ip_cc_objid,
 ip_ba_objid,
 p_rec.user_id,
 ip_aps_objid
 )
 RETURNING objid
 INTO out_pymt_src_objid;
 op_err_msg := 'Success';
 op_err_num := 0;
 RETURN out_pymt_src_objid;
EXCEPTION
WHEN OTHERS THEN
 op_err_num := -1;
 op_err_msg := 'Inserting Payment source ' || SUBSTR (SQLERRM, 1, 200);
 out_pymt_src_objid := -1;
 RETURN out_pymt_src_objid;
END;
--------------------------------------------------------------------------------------------------
PROCEDURE check_cc_ps(in_masked_card_number IN VARCHAR2,
 in_bo_objid IN NUMBER,
 wu_objid IN NUMBER,
 cc_objid OUT NUMBER,
 ps_objid OUT NUMBER
 )IS
 --------------------------------------------------------------------------------------------------
BEGIN
 SELECT cc.objid,
 NVL (ps.objid, -1)
 INTO cc_objid,
 ps_objid
 FROM x_payment_source ps,
 table_x_credit_card cc
 WHERE 1 = 1
 AND ps.pymt_src2x_credit_card(+) = cc.objid
 AND ps.x_status = 'ACTIVE' --Cpannala
 AND cc.X_CUSTOMER_CC_NUMBER = in_masked_card_number
 AND x_credit_card2bus_org = in_bo_objid
 AND ps.pymt_src2web_user = wu_objid;
EXCEPTION
WHEN NO_DATA_FOUND THEN
 cc_objid := -1;
 ps_objid := -1;
END;
--------------------------------------------------------------------------------------------------
PROCEDURE check_ba_ps(ip_account_number VARCHAR2,
 --ip_routing_number IN VARCHAR2,
 ip_account_type VARCHAR2,
 wu_objid IN NUMBER,
 op_ba_objid OUT NUMBER,
 op_ps_objid OUT NUMBER
 )IS
 --------------------------------------------------------------------------------------------------
BEGIN
 SELECT ba.objid,
 NVL (ps.objid, -1)
 INTO op_ba_objid,
 op_ps_objid
 FROM x_payment_source ps,
 TABLE_X_BANK_ACCOUNT ba
 WHERE 1 = 1
 AND ps.pymt_src2x_bank_account(+) = ba.objid
 AND ps.x_status = 'ACTIVE' --Cpannala
 AND ba.x_customer_acct = ip_account_number
--AND ba.x_routing = ip_routing_number CR28870
 AND ba.x_aba_transit = ip_account_type
 AND ps.pymt_src2web_user = wu_objid;

EXCEPTION
WHEN NO_DATA_FOUND THEN
 op_ba_objid := -1;
 op_ps_objid := -1;
END;
--------------------------------------------------------------------------------------------------
PROCEDURE check_aps(in_alt_pymt_source IN VARCHAR2,
 in_alt_pymt_source_type IN VARCHAR2,
 in_application_key IN VARCHAR2,
 in_bo_objid IN NUMBER,
 wu_objid IN NUMBER,
 aps_objid OUT NUMBER,
 ps_objid OUT NUMBER )IS
 --------------------------------------------------------------------------------------------------
BEGIN
 SELECT aps.objid,
 NVL (ps.objid, -1)
 INTO aps_objid,
 ps_objid
 FROM x_payment_source ps,
 table_x_altpymtsource aps
 WHERE 1 = 1
 AND ps.pymt_src2x_altpymtsource(+) = aps.objid
 AND ps.x_status = 'ACTIVE' --Cpannala
 AND aps.x_alt_pymt_source = in_alt_pymt_source
 AND aps.x_alt_pymt_source_type = in_alt_pymt_source_type
 AND aps.x_application_key = in_application_key
 AND x_altpymtsource2bus_org = in_bo_objid
 AND ps.pymt_src2web_user = wu_objid;

EXCEPTION
WHEN NO_DATA_FOUND THEN
 aps_objid := -1;
 ps_objid := -1;
END;
 --------------------------------------------------------------------------------------------------
PROCEDURE addpaymentsource( p_login_name IN VARCHAR2,
 p_bus_org IN VARCHAR2,
 p_esn IN VARCHAR2,
 p_rec IN typ_pymt_src_dtls_rec,
 op_pymt_src_id OUT VARCHAR2,
 op_err_num OUT NUMBER,
 op_err_msg OUT VARCHAR2)IS
 --------------------------------------------------------------------------------------------------
 PRAGMA AUTONOMOUS_TRANSACTION;
 l_pymt_src_name VARCHAR2 (100);
 wu_objid NUMBER;
 esn_wu_objid NUMBER;
 l_cc_objid NUMBER := 0;
 l_bo_objid NUMBER;
 l_ps_objid NUMBER;
 l_ba_objid NUMBER := 0;
 l_aps_objid NUMBER := 0;
 cont_objid NUMBER;
 addr_objid NUMBER;
 phone_no NUMBER;
 v_count INTEGER := 0;
 o_response VARCHAR2(500); -- CR52164
 end_of_proc EXCEPTION;
 v_app_key sa.table_x_altpymtsource.X_APPLICATION_KEY%TYPE; --THIS IS A VARCHAR2(100);
BEGIN
 B2B_PKG.get_esn_web_user (p_login_name, p_bus_org, p_esn, NULL, wu_objid, esn_wu_objid, l_bo_objid, op_err_num, op_err_msg);
 IF op_err_num <> 0 THEN
 op_err_num := -1;
 op_err_msg := 'Invalid Inputs';
 RAISE end_of_proc;
 END IF;
 ---get contact

 BEGIN
 SELECT web_user2contact,
 PHONE
 INTO cont_objid,
 phone_no
 FROM table_web_user wu,
 table_contact c
 WHERE c.objid = wu.web_user2contact
 AND wu.objid = NVL (wu_objid, esn_wu_objid);
 EXCEPTION
 WHEN OTHERS THEN
 op_err_num := -1;
 op_err_msg := 'Contact Not Exists';
 RAISE end_of_proc;
 END;

 --get Address

 IF NOT p_rec.address_info.write2db (addr_objid) THEN
 op_err_num := -1;
 op_err_msg := 'Address Creation Failed';
 RAISE end_of_proc;
 END IF;
 --
 IF p_rec.payment_type = 'CREDITCARD' THEN
 check_cc_ps (p_rec.cc_info.masked_card_number, l_bo_objid, NVL (wu_objid, esn_wu_objid), l_cc_objid, l_ps_objid);
 l_pymt_src_name := 'CREDITCARD';
----Added for Smartpay integration - CR33430 on 07/15/2015
 ELSIF p_rec.payment_type = 'APS' THEN
 if p_rec.aps_info.Alt_Pymt_Source = 'LOYALTY_PTS' then
 v_app_key := 'LTPS_'||cont_objid;
 else
 v_app_key := p_rec.aps_info.Application_Key;
 end if;

 check_aps ( p_rec.aps_info.Alt_Pymt_Source
 , p_rec.aps_info.Alt_Pymt_Source_Type
 , v_app_key --p_rec.aps_info.Application_Key
 , l_bo_objid
 , NVL (wu_objid, esn_wu_objid)
 , l_aps_objid
 , l_ps_objid
 );
 l_pymt_src_name := 'Alternate Payment Source';

 ELSE
 check_ba_ps ( p_rec.ach_info.account_number
 -- , p_rec.ach_info.routing_number CR28870
 , p_rec.ach_info.account_type
 , NVL (wu_objid, esn_wu_objid)
 , l_ba_objid
 , l_ps_objid
 );
 l_pymt_src_name := 'ACH';

 END IF;
 --
 IF (l_ps_objid <> -1 AND (l_cc_objid <> -1 OR l_ba_objid <> -1 OR l_aps_objid <> -1)) THEN
 op_err_num := -3;
 op_err_msg := 'Payment Source Already Exist';
 op_pymt_src_id := l_ps_objid;
 --CR53104 - ST_ Fix Straight Talk website Issue with phone purchase error message
 update_customer_address(i_payment_source_rec => p_rec,
 o_response => o_response);
 IF o_response != 'SUCCESS' THEN
 op_err_msg := op_err_msg || ' | ' || o_response ;
 END IF;

 RAISE end_of_proc;
 END IF;
 IF l_cc_objid = -1 THEN
 sa.edit_creditcard_prc_pci (NULL, p_rec.cc_info.masked_card_number, SUBSTR (p_rec.cc_info.exp_date, 1, INSTR (p_rec.cc_info.exp_date, '-', 1, 1) - 1), SUBSTR (p_rec.cc_info.exp_date, INSTR (p_rec.cc_info.exp_date, '-', 1, 1) + 1), p_rec.cc_info.card_type, NULL, p_rec.first_name, p_rec.last_name, phone_no, p_rec.email, NULL, cont_objid, p_rec.payment_status, p_bus_org, --CR3190
 p_rec.cc_info.cc_enc_number, p_rec.cc_info.key_enc_number, p_rec.cc_info.cc_enc_algorithm, p_rec.cc_info.key_enc_algorithm, p_rec.cc_info.cc_enc_cert, l_cc_objid, op_err_num, op_err_msg);
 IF op_err_num <> 0 THEN
 RAISE end_of_proc;
 ELSE
 UPDATE table_x_credit_card
 SET x_credit_card2address = addr_objid
 -- X_CUSTOMER_CC_CV_NUMBER = p_rec.cc_info.cvv
 WHERE objid = l_cc_objid;
 END IF;
 END IF;
 IF l_ba_objid = -1 THEN
 insert_bank_account (p_rec, cont_objid, addr_objid, phone_no, l_bo_objid, l_ba_objid, op_err_num, op_err_msg);
 IF op_err_num <> 0 THEN
 RAISE end_of_proc;
 END IF;
 END IF;
 IF l_aps_objid = -1 THEN ---Added for New payment source for Smartpay integration CR33430 on 07/15/2015
 insert_alternate_paymentsource (p_rec, cont_objid, addr_objid, phone_no,l_bo_objid , l_aps_objid, op_err_num, op_err_msg);

 IF op_err_num <> 0 THEN
 RAISE end_of_proc;
 END IF;
 END IF;
 IF l_ps_objid = -1 THEN
 l_ps_objid := insert_pymt_src (p_rec
 , l_pymt_src_name
 , l_cc_objid
 , l_ba_objid
 , l_aps_objid
 , wu_objid
 , op_err_num
 , op_err_msg);
 IF op_err_num <> 0 THEN
 RAISE end_of_proc;
 END IF;
 --CR52164 - Fix Straight Talk website Issue with phone purchase error message
 op_pymt_src_id := l_ps_objid;
 update_customer_address(i_payment_source_rec => p_rec,
 o_response => o_response);
 IF o_response != 'SUCCESS' THEN
 op_err_msg := o_response;
 RAISE end_of_proc;
 END IF;
 END IF;
 op_err_num := 0;
 op_err_msg := 'Success';
 COMMIT;
EXCEPTION
WHEN end_of_proc THEN
 IF op_err_msg <> 'Success' THEN
 UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL,
 IP_KEY => P_LOGIN_NAME,
 IP_PROGRAM_NAME => 'SA.PAYMENT_SERVICES_PKG.addPaymentSource',
 iP_ERROR_TEXT => OP_ERR_MSG);
 END IF;
 COMMIT;
WHEN OTHERS THEN
 ROLLBACK;
 OP_ERR_NUM := SQLCODE;
 OP_ERR_MSG := SUBSTR (SQLERRM, 1, 300);
 UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL,
 IP_KEY => P_LOGIN_NAME,
 IP_PROGRAM_NAME => 'SA.PAYMENT_SERVICES_PKG.addPaymentSource',
 iP_ERROR_TEXT => OP_ERR_MSG);
 ---
END addpaymentsource;
------------to Update the exiscting payment source to the existing account.--------
PROCEDURE updatepaymentsource(p_login_name IN VARCHAR2,
 p_bus_org_id IN VARCHAR2,
 p_esn IN VARCHAR2,
 p_rec IN typ_pymt_src_dtls_rec,
 op_pymt_src_id OUT VARCHAR2,
 op_err_num OUT NUMBER,
 op_err_msg OUT VARCHAR2)IS

 ccc_objid NUMBER; -- cc contact objid
 cc_objid NUMBER;
 bac_objid NUMBER;
 ba_objid NUMBER;
 cca_objid NUMBER; --cc address objid
 baa_objid NUMBER;
 l_bo_objid NUMBER;
 wu_objid NUMBER;
 esn_wu_objid NUMBER;
 n_country_objid NUMBER := NULL; --CR47564 fix for defect#23736
BEGIN
 IF p_login_name IS NULL OR p_bus_org_id IS NULL THEN
 op_err_num := 701; --'Login name and Brand required'
 op_err_msg := sa.get_code_fun ('SA.PAYMENT_SERVICES_PKG', op_err_num, 'ENGLISH');
 RETURN;
 END IF;
 IF p_rec.payment_source_id IS NULL THEN
 op_err_num := 702;
 op_err_msg := sa.get_code_fun ('PAYMENT_SERVICES_PKG', op_err_num, 'ENGLISH');
 RETURN;
 END IF;
 ----
 B2B_PKG.get_esn_web_user (p_login_name, p_bus_org_id, p_esn, NULL, wu_objid, esn_wu_objid, l_bo_objid, op_err_num, op_err_msg);
 IF op_err_num = 0 THEN
 -------
 IF p_rec.payment_type = 'CREDITCARD' THEN
 ---------to get credit crad contact and address----
 BEGIN
 SELECT cc.objid,
 cc.x_credit_card2contact,
 cc.x_credit_card2address
 INTO cc_objid,
 ccc_objid,
 cca_objid
 FROM table_x_credit_card cc,
 x_payment_source ps,
 table_web_user wu
 WHERE cc.objid = ps.pymt_src2x_credit_card
 AND ps.pymt_src2web_user = wu.objid(+) --CR47564 --WFM
 AND ps.objid = p_rec.payment_source_id
 AND wu.objid(+) = wu_objid; --CR47564 --WFM
 EXCEPTION
 WHEN OTHERS THEN
 op_err_num := -1;
 op_err_msg := 'Selecting cc info' || SUBSTR (SQLERRM, 1, 100);
 RETURN;
 END;
 ----updates in TABLE_X_CREDIT_CARD--------
 BEGIN
 UPDATE table_x_credit_card cc
 SET x_customer_firstname = NVL (p_rec.first_name, x_customer_firstname),
 x_customer_lastname = NVL (p_rec.last_name, x_customer_lastname),
 x_customer_email = NVL (p_rec.email, x_customer_email),
 x_customer_cc_expmo = NVL (SUBSTR (p_rec.cc_info.exp_date, 1, INSTR (p_rec.cc_info.exp_date, '-', 1, 1) - 1), x_customer_cc_expmo),
 x_customer_cc_expyr = NVL (SUBSTR (p_rec.cc_info.exp_date, INSTR (p_rec.cc_info.exp_date, '-', 1, 1) + 1), x_customer_cc_expyr), -- p_rec.EXP_DATE
 x_cc_type = NVL (p_rec.cc_info.card_type, x_cc_type)
 WHERE objid = cc_objid;
 EXCEPTION
 WHEN OTHERS THEN
 op_err_num := -1;
 op_err_msg := 'Update credit card info' || SUBSTR (SQLERRM, 1, 100);
 RETURN;
 END;
 END IF;
    IF p_rec.payment_type = 'ACH' THEN
      ---------to get BANK ACCOUNT  contact and address----
      BEGIN
        SELECT ba.objid,
          ba.x_bank_acct2contact,
          ba.x_bank_acct2address
        INTO ba_objid,
          bac_objid,
          baa_objid
        FROM table_x_bank_account ba,
          x_payment_source ps,
          table_web_user wu
        WHERE ba.objid           = ps.pymt_src2x_bank_account
        AND ps.pymt_src2web_user = wu.objid(+) --CR47564 --WFM
        AND ps.objid             = p_rec.payment_source_id
        AND wu.objid(+)          = wu_objid; --CR47564 --WFM
      EXCEPTION
      WHEN OTHERS THEN
        op_err_num := -1;
        op_err_msg := 'Selecting ach info' || SUBSTR (SQLERRM, 1, 100);
        RETURN;
      END;
      --------------------updates in TABLE_X_BANK_ACCOUNT----------------------------
      BEGIN
        UPDATE table_x_bank_account
        SET x_customer_firstname = NVL (p_rec.first_name, x_customer_firstname),
          x_customer_lastname    = NVL (p_rec.last_name, x_customer_lastname),
          x_customer_email       = NVL (p_rec.email, x_customer_email)
        WHERE objid              = ba_objid;
      EXCEPTION
      WHEN OTHERS THEN
        op_err_num := 1;
        op_err_msg := 'update bank account info' || SUBSTR (SQLERRM, 1, 100);
        RETURN;
      END;
    END IF;
    ----to Update table_contact-------
    BEGIN
      UPDATE table_contact
      SET first_name = NVL (p_rec.first_name, first_name),
        s_first_name = NVL (UPPER (p_rec.first_name), s_first_name),
        last_name    = NVL (p_rec.last_name, last_name),
        s_last_name  = NVL (UPPER (p_rec.last_name), s_last_name),
        e_mail       = NVL (p_rec.email, e_mail),
        address_1    = NVL (p_rec.address_info.address_1, address_1),
        city         = NVL (p_rec.address_info.city, city),
        state        = NVL (p_rec.address_info.state, state),
        zipcode      = NVL (p_rec.address_info.zipcode, zipcode)
      WHERE objid    = NVL2 (ccc_objid, ccc_objid, bac_objid);
    EXCEPTION
    WHEN OTHERS THEN
      op_err_num := 1;
      op_err_msg := 'update contact info' || SUBSTR (SQLERRM, 1, 100);
      RETURN;
    END;
    ---- end to Updates in table_contact-------
    -----to update Adsress in table_address---
    --CR47564 Changes start - Fix for defect#323736
    IF p_rec.address_info.country IS NOT NULL
    THEN
      BEGIN
        SELECT objid
        INTO   n_country_objid
        FROM   table_country
        WHERE  s_name = UPPER(p_rec.address_info.country);
      EXCEPTION
        WHEN OTHERS
        THEN
          n_country_objid := NULL;
      END;
    END IF;
    --CR47564 Changes end - Fix for defect#323736
    BEGIN
      UPDATE table_address a
      SET a.address = NVL (p_rec.address_info.address_1, address),
        a.s_address = NVL (UPPER (p_rec.address_info.address_1), s_address),
	      a.address_2  = NVL (UPPER (p_rec.address_info.address_2), address_2), --CR47564 --WFM fix for defect#23169
        a.city      = NVL (p_rec.address_info.city, city),
        a.s_city    = NVL (UPPER (p_rec.address_info.city), s_city),
        a.state     = NVL (p_rec.address_info.state, state),
        a.s_state   = NVL (UPPER (p_rec.address_info.state), s_state),
        a.zipcode   = NVL (p_rec.address_info.zipcode, zipcode),
        a.address2country = NVL(n_country_objid, address2country) --CR47564 fix for defect#23736
      WHERE a.objid = NVL2 (cca_objid, cca_objid, baa_objid);
    EXCEPTION
    WHEN OTHERS THEN
      op_err_num := 1;
      op_err_msg := 'update address info' || SUBSTR (SQLERRM, 1, 100);
      RETURN;
    END;
    -----end to update Adsress in table_address---
    --------------------updates in x_payment_source---------------------------
    BEGIN
      UPDATE x_payment_source ps
      SET x_is_default  = NVL (p_rec.is_default, x_is_default),
        x_status        = NVL (p_rec.payment_status, x_status),
        x_pymt_src_name = NVL2 (p_rec.cc_info.card_type, p_rec.cc_info.card_type, p_rec.ach_info.account_type),
        x_billing_email = NVL (p_rec.user_id, x_billing_email)
      WHERE ps.objid    = p_rec.payment_source_id;
    EXCEPTION
    WHEN OTHERS THEN
      op_err_num := 1;
      op_err_msg := 'update paymnet source info' || SUBSTR (SQLERRM, 1, 100);
      RETURN;
    END;
    op_pymt_src_id := p_rec.payment_source_id;
    op_err_num     := '0';
    op_err_msg     := 'Success';
  END IF; --  op_err_num = 0 (get_esn_web_user)
EXCEPTION
WHEN OTHERS THEN
  --
  ROLLBACK;
  OP_ERR_NUM := SQLCODE;
  OP_ERR_MSG := SUBSTR (SQLERRM, 1, 300);
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION       => NULL,
                                   IP_KEY          => TO_CHAR (P_REC.PAYMENT_SOURCE_ID),
                                   IP_PROGRAM_NAME => 'PAYMENT_SERVICES_PKG.UPDATEPAYMENTSOURCE',
                                   iP_ERROR_TEXT   => OP_ERR_MSG);
  ---
END updatepaymentsource;

---to remove payment source to the existing account.-----
PROCEDURE removepaymentsource(p_login_name  IN VARCHAR2 DEFAULT NULL,
                              p_bus_org_id  IN VARCHAR2 ,
                              p_esn         IN VARCHAR2 DEFAULT NULL,
                              p_min         IN VARCHAR2 DEFAULT NULL,
                              p_pymt_src_id IN OUT NUMBER ,
                              out_err_num   OUT NUMBER ,
                              out_err_msg   OUT VARCHAR2)IS

  wu_objid      NUMBER;
  esn_wu_objid  NUMBER;
  l_bo_objid    NUMBER;
  active_enroll NUMBER := 0;
  pymt_status   VARCHAR2 (30);
  --CR47564 -START
  l_esn_cnt      NUMBER;
  l_min_cnt      NUMBER;
  l_bo_cnt       NUMBER;
  l_esn          VARCHAR2(30);
  l_min          VARCHAR2(30);
  l_login_name   VARCHAR2(50);
  l_web_user_cnt NUMBER;
  --Declaring variable to access customer type
  c sa.customer_type         := sa.customer_type();
  cust sa.customer_type      := sa.customer_type();
  cst sa.customer_type       := sa.customer_type();
  cst_login sa.customer_type := sa.customer_type();
  --CR47564 --END
BEGIN
  IF p_pymt_src_id IS NULL THEN
    p_pymt_src_id  := NULL;
    out_err_num    := 702; --' payment source id required';
    out_err_msg    := sa.get_code_fun ('PAYMENT_SERVICES_PKG', out_err_num, 'ENGLISH');
    RETURN;
  END IF;
  --CR47564 WFM - START
  l_esn            := p_esn;
  l_min            := p_min;
  l_login_name     := p_login_name;
  IF (l_login_name IS NULL OR l_esn IS NULL OR l_min IS NULL) AND p_pymt_src_id IS NOT NULL THEN
    --
    --Retrieve Login/ESN/MIN based on payment source id
    BEGIN
      SELECT UPPER(wu.s_login_name),
        pi_esn.part_serial_no,
        pi_min.part_serial_no
      INTO l_login_name,
        l_esn,
        l_min
      FROM x_payment_source ps,
        table_web_user wu,
        table_x_contact_part_inst cpi,
        table_part_inst pi_esn,
        table_part_inst pi_min
      WHERE ps.objid                        = p_pymt_src_id
      AND ps.pymt_src2web_user              = wu.objid
      AND wu.web_user2contact               = cpi.x_contact_part_inst2contact
      AND cpi.x_contact_part_inst2part_inst = pi_esn.objid
      AND pi_esn.x_domain                   = 'PHONES'
      AND pi_min.part_to_esn2part_inst      = pi_esn.objid
      AND pi_min.x_domain                   = 'LINES';
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
  ELSE
    --To check whether the input ESN is not null and Valid.
    IF l_esn IS NOT NULL THEN
      --
      BEGIN
        SELECT COUNT (*)
        INTO l_esn_cnt
        FROM table_part_inst pi_esn
        WHERE pi_esn.part_serial_no = l_esn
        AND pi_esn.x_domain         = 'PHONES';
      EXCEPTION
      WHEN OTHERS THEN
        out_err_num := '1001';
        out_err_msg := SQLCODE||'-'||SUBSTR (SQLERRM, 1, 100);
        RETURN;
      END;
      --
    END IF; --This end if for ESN is not null condition.
    IF l_esn_cnt   = 0 THEN
      out_err_num := '1002' ;
      out_err_msg := 'ESN is not valid';
      RETURN;
      --
    END IF;
    --To check whether the input MIN is Valid.
    IF l_min IS NOT NULL THEN
      --
      BEGIN
        SELECT COUNT (*)
        INTO l_min_cnt
        FROM table_part_inst pi_esn
        WHERE pi_esn.part_serial_no = l_min
        AND pi_esn.x_domain         = 'LINES';
      EXCEPTION
      WHEN OTHERS THEN
        out_err_num := '1003';
        out_err_msg := SQLCODE||'-'||SUBSTR (SQLERRM, 1, 100);
        RETURN;
      END;
      IF l_min_cnt   = 0 THEN
        out_err_num := '1004';
        out_err_msg := 'MIN is not valid';
        RETURN;
      ELSE
        l_esn := cust.get_esn(i_min => l_min);
      END IF;
      --
    END IF; --This end if for MIN is not null condition.
    --To check whether the input login name is Valid.
    IF l_login_name IS NOT NULL THEN
      --
      cst_login             := cust.retrieve_login(i_login_name => l_login_name);
      IF cst_login.response <> 'SUCCESS' THEN
        out_err_num         := '1005';
        out_err_msg         := cst.response;
        RETURN;
      END IF;
      --
    END IF;
    --
  END IF;
  --To check whether the input bus org is NOT NULL and Valid.
  IF p_bus_org_id IS NULL THEN
    --
    out_err_num := '1009';
    out_err_msg := 'BRAND CANNOT BE NULL';
    RETURN;
    --
  END IF;
  cst.bus_org_id  := p_bus_org_id;
  c.bus_org_objid := cst.get_bus_org_objid;
  --To check whether the input bus org is NOT NULL and Valid.
  IF c.bus_org_objid IS NULL THEN
    --
    out_err_num := '1007';
    out_err_msg := 'INVALID BRAND: ' || p_bus_org_id;
    RETURN;
    --
  END IF;
  --Condition to check valid brand passed for the given login name
  IF l_login_name IS NOT NULL AND c.bus_org_objid IS NOT NULL THEN
    --
    BEGIN
      --
      SELECT COUNT(1)
      INTO l_web_user_cnt
      FROM table_web_user wu
      WHERE wu.s_login_name   = UPPER(l_login_name)
      AND wu.web_user2bus_org = c.bus_org_objid;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
      --
    END;
    IF l_web_user_cnt = 0 THEN
      --
      out_err_num := '1008';
      out_err_msg := 'INVALID BRAND';
      RETURN;
      --
    END IF;
    --
  END IF; --This is END IF condition to check for bus org input parameter is not null.
  --CR47564-WFM --END
  ---
  B2B_PKG.get_esn_web_user (l_login_name, p_bus_org_id, l_esn, l_min, wu_objid, esn_wu_objid, l_bo_objid, out_err_num, out_err_msg);
  IF out_err_num <> 0 THEN
    RETURN;
  ELSE
    BEGIN
      SELECT ps.x_status
      INTO pymt_status
      FROM table_web_user wu,
        x_payment_source ps
      WHERE ps.pymt_src2web_user = wu.objid
      AND wu.objid               = NVL (wu_objid, esn_wu_objid) --271110258
      AND ps.objid               = p_pymt_src_id;
    EXCEPTION
    WHEN OTHERS THEN
      OUT_ERR_NUM := -1;
      OUT_ERR_MSG := 'Need Valid Payment Source ID';
      RETURN;
    END;
    IF pymt_status = 'DELETED' THEN
      OUT_ERR_NUM := -1;
      OUT_ERR_MSG := 'Payment Source Already Deleted';
      RETURN;
    ELSE
      SELECT COUNT (*)
      INTO active_enroll
      FROM table_web_user wu,
        x_payment_source ps,
        x_program_enrolled pe
      WHERE ps.pymt_src2web_user   = wu.objid
      AND pe.pgm_enroll2x_pymt_src = ps.objid
      AND pe.x_enrollment_status  IN ('ENROLLED', 'ENROLLMENTPENDING', 'SUSPENDED', 'ENROLLMENTSCHEDULED')
      AND wu.objid                 = NVL (wu_objid, esn_wu_objid) --271110258
      AND ps.objid                 = p_pymt_src_id;
      IF active_enroll             > 0 THEN
        OUT_ERR_NUM               := -1;
        OUT_ERR_MSG               := 'Payment Source Have Active Enrollments';
        RETURN;
      END IF;
      BEGIN
        UPDATE x_payment_source
        SET x_status          = 'DELETED'
        WHERE objid           = p_pymt_src_id
        AND pymt_src2web_user = NVL (wu_objid, esn_wu_objid);
      EXCEPTION
      WHEN OTHERS THEN
        OUT_ERR_NUM := -1;
        OUT_ERR_MSG := 'Payment Source Not Updated';
        RETURN;
      END;
      out_err_num := 0;
      out_err_msg := 'Success';
    END IF; --pymt_status
  END IF;   --out_err_num = 0
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  OUT_ERR_NUM := SQLCODE;
  OUT_ERR_MSG := SUBSTR (SQLERRM, 1, 300);
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION       => NULL,
                                   IP_KEY          => TO_CHAR (P_PYMT_SRC_ID),
                                   IP_PROGRAM_NAME => 'PAYMENT_SERVICES_PKG.removePaymentSource',
                                   ip_error_text   => out_err_msg);
END removepaymentsource;
---
PROCEDURE getbillinghistory(  in_login_name      IN Table_Web_User.Login_Name%TYPE,
                              in_bus_org         IN VARCHAR2,
                              in_esn             IN table_part_inst.part_serial_no%TYPE,
                              in_min             IN table_site_part.x_min%TYPE,
                              in_phone_nick_name IN table_x_contact_part_inst.x_esn_nick_name%TYPE DEFAULT NULL,
                              in_org_name        IN table_site.s_name%TYPE DEFAULT NULL,
                              in_org_id          IN Table_Site.X_Commerce_Id%TYPE DEFAULT NULL,
                              in_buyer_id        IN Table_Web_User.Login_Name%TYPE DEFAULT NULL,
                              in_start_date      IN DATE DEFAULT NULL,
                              in_end_date        IN DATE DEFAULT NULL,
                              in_low_amt         IN x_program_purch_hdr.x_bill_amount%TYPE,
                              in_high_amt        IN x_program_purch_hdr.x_bill_amount%TYPE,
                              in_start_idx       IN BINARY_INTEGER DEFAULT 0,
                              in_max_rec_number  IN NUMBER DEFAULT 100,
                              in_order_by_field  IN VARCHAR2 DEFAULT NULL,
                              in_order_direction IN VARCHAR2 DEFAULT 'ASC',
                              out_bill_hist      OUT typ_bill_hist_tbl,
                              OUT_ERR_NUM        OUT NUMBER,
                              OUT_ERR_MSG OUT VARCHAR2)IS
  esn_wu_objid NUMBER;
  l_bo_objid   NUMBER;
  wu_objid     NUMBER;
  CURSOR acct_curs ( c_wu_objid IN NUMBER)
  IS
    SELECT ts.x_commerce_id
    FROM x_site_web_accounts swa,
      table_site ts
    WHERE ts.objid                 = swa.site_web_acct2site
    AND x_account_type             = 'BUYERADMIN'
    AND swa.site_web_acct2web_user = c_WU_OBJID; -- 580930491
  acct_rec acct_curs%ROWTYPE;
  CURSOR org_cur ( c_commerce_id VARCHAR2)
  IS
    SELECT site_web_acct2web_user web_user
    FROM x_site_web_accounts
    WHERE site_web_acct2site IN
      (SELECT objid
      FROM table_site
      WHERE LEVEL                     >= 1
        START WITH x_commerce_id       = c_commerce_id
        CONNECT BY NOCYCLE PRIOR objid = child_site2site
      );
  org_rec org_cur%ROWTYPE;
  l_typ_bill_hist_tbl2 typ_bill_hist_tbl := typ_bill_hist_tbl ();
  --
PROCEDURE billing_hist( in_wu_objid VARCHAR2,
                        in_esn             IN table_part_inst.part_serial_no%TYPE,
                        in_min             IN table_site_part.x_min%TYPE,
                        in_phone_nick_name IN table_x_contact_part_inst.x_esn_nick_name%TYPE DEFAULT NULL,
                        in_org_name        IN table_site.s_name%TYPE DEFAULT NULL,
                        in_org_id          IN Table_Site.X_Commerce_Id%TYPE DEFAULT NULL,
                        in_buyer_id        IN Table_Web_User.Login_Name%TYPE DEFAULT NULL,
                        in_start_date      IN DATE DEFAULT NULL,
                        in_end_date        IN DATE DEFAULT NULL,
                        in_low_amt         IN x_program_purch_hdr.x_bill_amount%TYPE,
                        in_high_amt        IN x_program_purch_hdr.x_bill_amount%TYPE,
                        in_start_idx       IN BINARY_INTEGER DEFAULT 0,
                        in_max_rec_number  IN NUMBER DEFAULT 100,
                        in_order_by_field  IN VARCHAR2 DEFAULT NULL,
                        in_order_direction IN VARCHAR2 DEFAULT 'ASC',
                        out_bill_hist      OUT typ_bill_hist_tbl)IS

BEGIN
  SELECT typ_bill_hist_rec (tbl.payment_id, tbl.payment_date, tbl.payment_status, tbl.payment_amount, tbl.payment_source_id, tbl.org_name, tbl.org_id, tbl.buyer_id, tbl.MIN, tbl.esn, tbl.phone_nick_name, tbl.subtotal_amount, tbl.sales_TAX_AMOUNT, tbl.USF_TAXAMOUNT, tbl.E911_TAX_AMOUNT, tbl.RCRF_TAX_AMOUNT, tbl.bill_amount, tbl.DISCOUNT_AMOUNT) BULK COLLECT
  INTO out_bill_hist
  FROM
    (SELECT ph.X_MERCHANT_REF_NUMBER payment_id,
      ph.x_rqst_date PAYMENT_DATE,
      --NVL ( TO_DATE (SUBSTR (ph.x_auth_time, 1, 10), 'YYYY-MM-DD'), ph.x_rqst_date) PAYMENT_DATE, --CR41809
      CASE
        WHEN x_rqst_type = 'cc_purch'
        THEN
          CASE
            WHEN ( ( ph.x_ics_rcode = '1'
            OR ph.x_ics_rcode       = '100'
            OR ph.x_ics_rcode      IS NULL)
            AND ph.x_ics_rflag LIKE '%Pending')
            THEN 'Pending'
            WHEN ( ph.x_ics_rflag IS NULL
            OR ph.x_ics_rflag LIKE '%Pending')
            THEN 'Pending'
            WHEN (ph.x_ics_rcode IN ('1', '100'))
            THEN 'Paid'
            WHEN (ph.x_ics_rflag LIKE '%INCOMPLETE')
            THEN 'Processing'
            WHEN (ph.x_ics_rcode NOT IN ('1', '100'))
            THEN 'Rejected'
            ELSE 'Rejected'
          END
        WHEN x_rqst_type = 'cc_refund'
        THEN
          CASE
            WHEN (ph.x_ics_rcode = '1')
            THEN 'Refunded'
            WHEN (ph.x_ics_rcode = '0')
            THEN 'Refund Rejected'
            ELSE 'Refund Rejected'
          END
      END PAYMENT_STATUS,
      NVL (ph.x_bill_amount, ph.x_amount) PAYMENT_AMOUNT,
      ph.x_purch_hdr2creditcard payment_source_id,
      s.s_name org_name,
      s.x_commerce_id org_id,
      web.s_login_name buyer_id,
      pi_line.part_serial_no MIN,
      ph.x_esn ESN,
      cpi.x_esn_nick_name phone_nick_name,
      ph.x_amount subtotal_amount,
      ph.x_tax_amount sales_TAX_AMOUNT,
      ph.x_usf_taxamount USF_TAXAMOUNT,
      ph.x_e911_amount E911_TAX_AMOUNT,
      ph.x_rcrf_tax_amount RCRF_TAX_AMOUNT,
      ph.X_bill_AMOUNT bill_amount,
      ph.x_discount_amount DISCOUNT_AMOUNT
    FROM x_site_web_accounts sw,
      table_web_user web,
      table_x_contact_part_inst cpi,
      table_part_inst pi,
      table_part_inst pi_line,
      table_site s,
      table_x_purch_hdr ph,
      table_x_credit_card cc
    WHERE 1                             = 1
    AND web.objid                       = in_wu_objid
    AND cpi.x_contact_part_inst2contact = web.web_user2contact
    AND pi.objid                        = cpi.x_contact_part_inst2part_inst
    AND web.objid                       = sw.SITE_WEB_ACCT2WEB_USER
    AND s.objid                         = sw.SITE_WEB_ACCT2SITE
    AND ph.x_esn                        = pi.part_serial_no
    AND PI.X_DOMAIN                     = 'PHONES'
    AND pi.objid                        = pi_line.part_to_esn2part_inst(+)
    AND pi_line.x_domain(+)             = 'LINES'
    AND ph.x_esn                        = in_esn --'100000000013388954'--
    AND ph.x_amount                    IS NOT NULL
    AND cc.objid                        = ph.x_purch_hdr2creditcard
    AND TRUNC (ph.x_rqst_date) BETWEEN NVL ( TO_DATE ( in_start_date, 'MM/DD/YYYY'), SYSDATE - 90) AND NVL ( TO_DATE ( in_end_date, 'MM/DD/YYYY'), SYSDATE)
    AND ph.x_amount BETWEEN NVL (in_low_amt, 0) AND NVL (in_high_amt, 999999999999.99)
    AND S.X_Commerce_Id        = NVL (in_org_id, S.X_Commerce_Id)
    AND web.s_login_name       = NVL (UPPER (in_buyer_id), web.s_login_name)
    AND cpi.x_esn_nick_name    = NVL (in_phone_nick_name, cpi.x_esn_nick_name)
    AND pi_line.part_serial_no = NVL (in_min, pi_line.part_serial_no)
    UNION
    SELECT a.X_MERCHANT_REF_NUMBER payment_id,
     a.x_rqst_date payment_date,
      --NVL ( TO_DATE (SUBSTR (a.x_auth_time, 1, 10), 'YYYY-MM-DD'), a.x_rqst_date) payment_date, --CR41809
      CASE
        WHEN ( x_rqst_type = 'CREDITCARD_PURCH'
        OR x_rqst_type     = 'ACH_PURCH')
        THEN
          CASE
            WHEN (a.x_status LIKE 'CHARGEBACK%')
            THEN 'Chargeback'
            WHEN ( ( a.x_ics_rcode = '1'
            OR a.x_ics_rcode       = '100'
            OR a.x_ics_rcode      IS NULL)
            AND a.x_status LIKE '%PENDING')
            THEN 'Pending'
            WHEN (a.x_ics_rcode IS NULL)
            THEN 'Pending'
            WHEN ( ( a.x_ics_rcode = '1'
            OR a.x_ics_rcode       = '100'))
            THEN 'Paid'
            WHEN (a.x_status LIKE 'SUBMITTED')
            THEN 'Processing'
            WHEN (a.x_status LIKE 'INCOMPLETE')
            THEN 'Processing'
            ELSE 'Rejected'
          END
        ELSE
          CASE
            WHEN (a.x_ics_rcode = '1')
            THEN 'Refund Approved'
            WHEN (a.x_ics_rcode = '0')
            THEN 'Refund Declined'
            ELSE 'Refund Declined'
          END
      END payment_status,
      NVL (a.x_bill_amount, a.x_amount) payment_amount,
      a.prog_hdr2x_pymt_src payment_source_id,
      s.s_name org_name,
      s.x_commerce_id org_id,
      web.s_login_name buyer_id,
      pi_line.part_serial_no MIN,
      dtl.x_esn esn,
      cpi.x_esn_nick_name phone_nick_name,
      dtl.x_amount subtotal_amount,
      dtl.x_tax_amount sales_TAX_AMOUNT,
      dtl.x_usf_taxamount USF_TAXAMOUNT,
      dtl.x_e911_tax_amount E911_TAX_AMOUNT,
      dtl.x_rcrf_tax_amount RCRF_TAX_AMOUNT,
      ( dtl.x_amount + dtl.x_tax_amount + dtl.x_usf_taxamount + dtl.x_e911_tax_amount + dtl.x_rcrf_tax_amount) bill_amount,
      a.x_discount_amount DISCOUNT_AMOUNT
    FROM x_program_purch_hdr a,
      table_part_inst pi,
      table_part_inst pi_line,
      table_x_contact_part_inst cpi,
      x_site_web_accounts sw,
      table_web_user web,
      table_site s,
      x_program_purch_dtl dtl,
      table_x_credit_card b,
      table_x_bank_account c
    WHERE 1                               = 1
    AND sw.SITE_WEB_ACCT2WEB_USER         = in_wu_objid
    AND web.objid                         = sw.SITE_WEB_ACCT2WEB_USER
    AND a.prog_hdr2web_user               = sw.SITE_WEB_ACCT2WEB_USER --580940648
    AND cpi.x_contact_part_inst2part_inst = pi.objid
    AND pi.part_serial_no                 = dtl.x_esn
    AND PI.X_DOMAIN                       = 'PHONES'
    AND pi.objid                          = pi_line.part_to_esn2part_inst(+)
    AND pi_line.x_domain(+)               = 'LINES'
    AND a.x_amount                        > 0
    AND a.x_status                       <> 'VALIDATIONFAILED'
    AND a.x_payment_type                 != 'REDEBIT'
    AND dtl.x_esn                         = NVL (in_esn, dtl.x_esn)
    AND SW.SITE_WEB_ACCT2SITE             = s.objid
    AND dtl.pgm_purch_dtl2prog_hdr        = a.objid
    AND b.objid(+)                        = a.purch_hdr2creditcard
    AND c.objid(+)                        = a.purch_hdr2bank_acct
    AND TRUNC (a.x_rqst_date) BETWEEN NVL ( TO_DATE ( in_start_date, 'MM/DD/YYYY'), SYSDATE - 90) AND NVL ( TO_DATE ( in_end_date, 'MM/DD/YYYY'), SYSDATE)
    AND a.x_amount BETWEEN NVL (in_low_amt, 0) AND NVL (in_high_amt, 999999999999.99)
    AND S.X_Commerce_Id        = NVL (in_org_id, S.X_Commerce_Id)
    AND web.s_login_name       = NVL (UPPER (in_buyer_id), web.s_login_name)
    AND cpi.x_esn_nick_name    = NVL (in_phone_nick_name, cpi.x_esn_nick_name)
    AND pi_line.part_serial_no = NVL (in_min, pi_line.part_serial_no)
    ) tbl
  WHERE 1     = 1
  AND ROWNUM <= NVL (IN_MAX_REC_NUMBER, 100)
  ORDER BY NVL (IN_ORDER_DIRECTION, 'ASC');
END billing_hist;
--
BEGIN
  B2B_PKG.get_esn_web_user (in_login_name, in_bus_org, in_esn, in_min, wu_objid, esn_wu_objid, l_bo_objid, OUT_ERR_NUM, OUT_ERR_MSG);
  OPEN acct_curs (wu_objid);
  FETCH acct_curs INTO acct_rec;
  IF acct_curs%NOTFOUND THEN
    IF OUT_ERR_NUM <> 0 THEN
      CLOSE acct_curs;
      RETURN;
    END IF;
    CLOSE acct_curs;
    billing_hist (wu_objid,              --varchar2,
    in_esn,                              --  IN table_part_inst.part_serial_no%TYPE,
    in_min,                              --   IN table_site_part.x_min%TYPE,
    in_phone_nick_name,                  --IN table_x_contact_part_inst.x_esn_nick_name%TYPE DEFAULT NULL,
    in_org_name, in_org_id, in_buyer_id, -- IN VARCHAR2 DEFAULT NULL,
    in_start_date,                       -- IN DATE DEFAULT NULL,
    in_end_date,                         -- IN DATE DEFAULT NULL,
    in_low_amt,                          --  IN x_program_purch_hdr.x_bill_amount%TYPE,
    in_high_amt,                         --  IN x_program_purch_hdr.x_bill_amount%TYPE,
    in_start_idx,                        --  IN BINARY_INTEGER DEFAULT 0,
    in_max_rec_number,                   --  IN NUMBER DEFAULT 100,
    in_order_by_field,                   -- IN VARCHAR2 DEFAULT NULL,
    in_order_direction,                  --IN VARCHAR2 DEFAULT 'ASC',
    out_bill_hist);                      --OUT typ_bill_hist_tbl
  ELSE
    FOR org_rec IN org_cur (acct_rec.x_commerce_id)
    LOOP
      billing_hist (org_rec.web_user,      --varchar2,
      in_esn,                              --  IN table_part_inst.part_serial_no%TYPE,
      in_min,                              --   IN table_site_part.x_min%TYPE,
      in_phone_nick_name,                  --IN table_x_contact_part_inst.x_esn_nick_name%TYPE DEFAULT NULL,
      in_org_name, in_org_id, in_buyer_id, -- IN VARCHAR2 DEFAULT NULL,
      in_start_date,                       -- IN DATE DEFAULT NULL,
      in_end_date,                         -- IN DATE DEFAULT NULL,
      in_low_amt,                          --  IN x_program_purch_hdr.x_bill_amount%TYPE,
      in_high_amt,                         --  IN x_program_purch_hdr.x_bill_amount%TYPE,
      in_start_idx,                        --  IN BINARY_INTEGER DEFAULT 0,
      in_max_rec_number,                   --  IN NUMBER DEFAULT 100,
      in_order_by_field,                   -- IN VARCHAR2 DEFAULT NULL,
      in_order_direction,                  --IN VARCHAR2 DEFAULT 'ASC',
      out_bill_hist);                      --OUT typ_bill_hist_tbl
      l_typ_bill_hist_tbl2 := out_bill_hist MULTISET
      UNION l_typ_bill_hist_tbl2;
    END LOOP;
    CLOSE acct_curs;
    out_bill_hist := l_typ_bill_hist_tbl2;
  END IF;
  IF out_bill_hist.COUNT > 0 THEN
    OUT_ERR_NUM         := 0;
    Out_Err_msg         := 'Success';
  ELSE
    OUT_ERR_NUM := -1;
    Out_Err_msg := 'Account Credentials And Criterias Are Not Associated';
  END IF;
EXCEPTION
WHEN OTHERS THEN
  --
  Out_Err_Num := SQLCODE;
  Out_Err_msg := SUBSTR (SQLERRM, 1, 300);
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION       => TO_CHAR (Out_Err_Num),
                                   IP_KEY          => IN_LOGIN_NAME || '-' || IN_ESN,
                                   IP_PROGRAM_NAME => 'PAYMENT_SERVICES_PKG.getBillingHistory',
                                   ip_error_text   => Out_Err_msg);
END getbillinghistory;
---
PROCEDURE setrecurringpaymentsource(in_esn               IN table_part_inst.part_serial_no%TYPE,
                                    in_min               IN table_site_part.x_min%TYPE,
                                    in_plan_id           IN x_program_parameters.objid%TYPE,
                                    in_payment_source_id IN x_payment_source.objid%TYPE,
                                    out_err_num          OUT NUMBER,
                                    out_err_msg          OUT VARCHAR2)IS

  PE_OBJID NUMBER;
  v_count  NUMBER := 0;
BEGIN
  IF (in_esn    IS NULL) OR (in_plan_id IS NULL) OR (in_payment_source_id IS NULL) THEN
    out_err_num := -1;
    out_err_msg := 'Valid Parameters Required';
    RETURN;
  END IF;
  SELECT COUNT (*)
  INTO v_count
  FROM x_program_enrolled
  WHERE pgm_enroll2pgm_parameter = in_plan_id --'5800004'
  AND x_esn                      = in_esn     --'010738002826678'
  AND pgm_enroll2x_pymt_src      = in_payment_source_id
  AND x_enrollment_status        = 'ENROLLED';
  --
  IF v_count     > 0 THEN
    out_err_num := 705; -- 'PAYMENT SOURCE EXISTS FOR THE ESN';
    out_err_msg := sa.get_code_fun ('PAYMENT_SERVICES_PKG', out_err_num, 'ENGLISH');
    RETURN;
  ELSE
    ---
    BEGIN
      SELECT DISTINCT pe.objid ---584695846
      INTO pe_objid
      FROM table_x_contact_part_inst cpi,
        table_web_user wu,
        x_program_enrolled pe,
        x_payment_source ps
      WHERE 1                             = 1
      AND cpi.x_contact_part_inst2contact = wu.web_user2contact
      AND wu.objid                        = pe.pgm_enroll2web_user
      AND ps.PYMT_SRC2WEB_USER            = pe.pgm_enroll2web_user
      AND ps.x_status                     = 'ACTIVE'
      AND pe.pgm_enroll2pgm_parameter     = in_plan_id
      AND pe.x_enrollment_status          = 'ENROLLED'
      AND pe.x_esn                        = in_esn;
    EXCEPTION
    WHEN OTHERS THEN
      out_err_num := -1;
      out_err_msg := 'ESN not enrolled in a program';
    END;
    ---
    IF pe_objid IS NOT NULL THEN
      BEGIN
        UPDATE x_program_enrolled
        SET pgm_enroll2x_pymt_src = in_payment_source_id
        WHERE objid               = pe_objid;
      EXCEPTION
      WHEN OTHERS THEN
        OUT_ERR_NUM := -1;
        out_err_msg := 'Set Payment Source' || SUBSTR (SQLERRM, 1, 100);
        RETURN;
      END;
      out_err_num := 0;
      out_err_msg := 'Success';
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  --
  out_err_num := SQLCODE;
  OUT_ERR_MSG := SUBSTR (SQLERRM, 1, 300);
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION       => NULL,
                                   IP_KEY          => IN_ESN || '' || TO_CHAR (IN_PAYMENT_SOURCE_ID),
                                   IP_PROGRAM_NAME => 'PAYMENT_SERVICES_PKG.SetRecurringPaymentsource',
                                   IP_ERROR_TEXT   => OUT_ERR_NUM);
  ---
END setrecurringpaymentsource;
---------------------------------------------------------------------------------------------------------------------
PROCEDURE Inserts_Purch(In_Org_Id    				      IN VARCHAR2,
                        In_Brand     				      IN VARCHAR2,
                        In_Language  				      IN VARCHAR2,
                        In_Promocode 				      IN VARCHAR2,
                        in_purch_hdr 				      IN purch_hdr_rec,
                        In_ADDRESS   				      IN ADDRESS_REC,
                        IN_PURCH_DTL 				      IN BIZ_PURCH_DTL_TBL,
                        Out_Purch_Hdr_Objid       OUT NUMBER,
                        OUT_MERCHANT_REF_NUMBER   OUT VARCHAR2,
                        OUT_MERCHANT_ID           OUT VARCHAR2,
                        OUT_ERROR_MSG 			      OUT VARCHAR2,
                        OUT_Error_num 			      OUT NUMBER  )IS

  l_credit_card     NUMBER;
  l_BANK_ACcount    NUMBER;
  l_WEB_USER        NUMBER;
  l_billing_email   VARCHAR2 (80);
  v_purch_objid     NUMBER;
  l_merchant_id     VARCHAR2 (80);
  V_MERCH_REF_NUM   VARCHAR2 (100);
  i_count           PLS_INTEGER := 0;
  V_STATUS          VARCHAR2 (40);
  l_pymt_cnt        PLS_INTEGER := 0;
  v_auth_request_id VARCHAR2(40);
  l_pymt_source_id  VARCHAR2(100); -- CR42257
  c customer_type := customer_type();
  ---
  CURSOR pymt_cur (pymt_src_id NUMBER)
  IS
    SELECT objid,
      pymt_src2x_credit_card,
      pymt_src2x_bank_account,
      pymt_src2x_altpymtsource,
      pymt_src2web_user,
      x_billing_email
    FROM x_payment_source
    WHERE objid  = pymt_src_id
    AND x_status = 'ACTIVE';
  pymt_rec pymt_cur%ROWTYPE;
  --
BEGIN
  /*
  record_inputs('Payment_services_pkg.Inserts_Purch( '||
  ' In_Org_Id=>'||In_Org_Id||','||
  ' In_Brand=>'||In_Brand||','||
  ' In_Language=>'||In_Language||','||
  ' In_Promocode=>'||In_Promocode||','||
  ' in_purch_hdr=>'||in_purch_hdr||','||
  ' In_ADDRESS=>'||In_Address||','||
  ' IN_PURCH_DTL=>'||In_Purch_dtl||');'); */
  v_purch_objid   := sa.SEQU_BIZ_PURCH_HDR.NEXTVAL;
  v_merch_ref_num := B2B_PKG.b2b_merchant_ref_number (in_purch_hdr.in_channel);
  v_status        := in_purch_hdr.in_status;
  ----
  IF (in_purch_hdr.in_C_ORDERID IS NULL) OR (in_purch_hdr.in_channel IS NULL) OR (in_purch_hdr.in_pymt_src_id IS NULL) OR (In_Brand IS NULL) THEN
    OUT_Error_num               := -1;                  --704;---'ORDER ID REQUIRED'
    out_error_msg               := 'Need Valid Inputs'; --sa.get_code_fun('PAYMENT_SERVICES_PKG', out_error_num, 'ENGLISH');
    RETURN;
  END IF;
  -- CR42257 changes starts..
  IF NVL(in_purch_hdr.in_channel,'X') = 'ETEDS' THEN
    -- Get partner param value for PYMT_SOURCE_ID
    etailer_service_pkg.get_partner_param (i_partner_id  => in_purch_hdr.in_merchant_id,
                                           i_param_name  => 'PYMT_SOURCE_ID',
                                           o_param_value => l_pymt_source_id,
                                           o_err_code    => out_error_num,
                                           o_err_msg     => out_error_msg);
  ELSE
    l_pymt_source_id := in_purch_hdr.in_pymt_src_id;
  END IF;
  -- CR42257 changes Ends.
  -- IF in_purch_hdr.in_pymt_src_id IS NOT NULL THEN
  OPEN pymt_cur (to_number(l_pymt_source_id)); -- CR42257 changed cursor parameter variable to l_pymt_source_id
  FETCH pymt_cur INTO pymt_rec;
  IF pymt_cur%NOTFOUND THEN
    OUT_Error_num := 702; ---'payment source id required'
    out_error_msg := sa.get_code_fun ('PAYMENT_SERVICES_PKG', out_error_num, 'ENGLISH');
    CLOSE pymt_cur;
    RETURN;
  END IF;
  CLOSE pymt_cur;
  -- end if;
  ---
  IF (in_purch_hdr.in_channel IS NOT NULL) THEN
    BEGIN
      --
      -- CR42257 added to fetch merchant ID for ETEDS
      IF in_purch_hdr.in_channel = 'ETEDS' THEN
        l_merchant_id           := in_purch_hdr.in_merchant_id;
        --
        --CR30348 Start Kacosta 12/4/2014
      ELSIF in_purch_hdr.in_channel NOT IN ('B2C','ETEDS') -- CR42257 added ETEDS
        THEN
        --
        IF In_Brand = 'STRAIGHT_TALK' THEN --Added this on 09/10/2015 for CR33430 - to fetch the new merchant id for Straight_talk
          SELECT x_merchant_id
          INTO l_merchant_id
          FROM table_x_cc_parms
          WHERE x_bus_org = in_purch_hdr.in_channel
            || ' '
            || In_Brand;
        ELSE
          SELECT x_merchant_id
          INTO l_merchant_id
          FROM table_x_cc_parms
          WHERE x_bus_org IN (in_purch_hdr.in_channel);
          --
        END IF;
      ELSE
        -- instantiate esn from purch detail or purch hdr
        c := customer_type ( i_esn => NVL(in_purch_dtl(1).in_x_esn, in_purch_hdr.in_esn) );
        -- get the sub brand of the esn
        c.sub_brand := c.get_sub_brand;
        -- convert the SIMPLE_MOBILE to GO_SMART when applicable
        c.bus_org_id :=
        CASE
        WHEN c.sub_brand IS NOT NULL THEN
          c.sub_brand
        ELSE
          in_brand
        END;
        --
        SELECT x_merchant_id
        INTO l_merchant_id
        FROM table_x_cc_parms
        WHERE x_bus_org = in_purch_hdr.in_channel
          || ' '
          || c.bus_org_id; -- previous: in_purch_hdr.in_channel || ' ' || In_Brand;
        --
      END IF;
      --CR30348 End Kacosta 12/4/2014
      --
    EXCEPTION
    WHEN OTHERS THEN
      --
      OUT_ERROR_NUM := -1;
      OUT_ERROR_MSG := 'MERCHANT_ID Not Exists';
      RETURN;
    END;
  ELSE
    OUT_Error_num := -1;
    out_error_msg := 'Channel Not valid'; --sa.get_code_fun('PAYMENT_SERVICES_PKG', out_error_num, 'ENGLISH');
    RETURN;
  END IF;
  ---
  IF in_purch_hdr.in_status IS NULL THEN
    v_status                := 'INCOMPLETE';
  END IF;
  IF in_purch_hdr.in_rqst_type = 'ALTSOURCE_PURCH' THEN
    v_auth_request_id         := SUBSTR(in_purch_hdr.in_auth_request_id,1,40);
  ELSE
    v_auth_request_id := in_purch_hdr.in_auth_request_id;
  END IF;
  BEGIN
    /* DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.IN_RQST_SOURCE ='||IN_PURCH_HDR.IN_RQST_SOURCE);
    DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.IN_CHANNEL   ='|| IN_PURCH_HDR.IN_CHANNEL );
    DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.IN_C_ORDERID   ='|| IN_PURCH_HDR.IN_C_ORDERID );
    DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.IN_ACCOUNT_ID    ='|| IN_PURCH_HDR.IN_ACCOUNT_ID );
    DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.IN_AUTH_REQUEST_ID   ='|| IN_PURCH_HDR.IN_AUTH_REQUEST_ID );
    DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.IN_GROUPIDENTIFIER   ='|| IN_PURCH_HDR.IN_GROUPIDENTIFIER );
    DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.IN_RQST_TYPE       ='|| IN_PURCH_HDR.IN_RQST_TYPE );
    DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.IN_RQST_DATE     ='|| IN_PURCH_HDR.IN_RQST_DATE );
    DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.IN_ICS_APPLICATIONS  ='|| IN_PURCH_HDR.IN_ICS_APPLICATIONS );
    DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.IN_MERCHANT_ID   ='|| IN_PURCH_HDR.IN_MERCHANT_ID );
    DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.IN_OFFER_NUM    ='|| IN_PURCH_HDR.IN_OFFER_NUM );
    DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.IN_QUANTITY      ='|| IN_PURCH_HDR.IN_QUANTITY );
    DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.IN_IGNORE_AVS         ='|| IN_PURCH_HDR.IN_IGNORE_AVS );
    DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.In_Pymt_Src_Id     ='|| IN_PURCH_HDR.In_Pymt_Src_Id);
    DBMS_OUTPUT.PUT_LINE('IN_PURCH_HDR.IN_web_user      ='|| IN_PURCH_HDR.IN_web_user );*/
    INSERT
    INTO x_biz_purch_hdr
      (
        OBJID,
        X_RQST_SOURCE,
        Channel,
        ecom_Org_Id,
        ORDER_TYPE,
        C_ORDERID,
        ACCOUNT_ID,
        X_AUTH_REQUEST_ID,
        GROUPIDENTIFIER,
        X_RQST_TYPE,
        X_RQST_DATE,
        X_ICS_APPLICATIONS,
        X_MERCHANT_ID,
        X_MERCHANT_REF_NUMBER,
        X_OFFER_NUM,
        X_QUANTITY,
        X_IGNORE_AVS,
        X_AVS,
        X_DISABLE_AVS,
        X_CUSTOMER_HOSTNAME,
        X_CUSTOMER_IPADDRESS,
        X_CUSTOMER_FIRSTNAME,
        X_CUSTOMER_LASTNAME,
        X_CUSTOMER_PHONE,
        X_CUSTOMER_EMAIL,
        X_STATUS,
        X_BILL_ADDRESS1,
        X_BILL_ADDRESS2,
        X_BILL_CITY,
        x_bill_state,
        x_bill_zip,
        X_BILL_COUNTRY,
        X_SHIP_ADDRESS1,
        X_SHIP_ADDRESS2,
        X_SHIP_CITY,
        x_ship_state,
        x_ship_zip,
        X_SHIP_COUNTRY,
        X_ESN,
        X_AMOUNT,
        X_Tax_Amount,
        X_Sales_Tax_Amount,
        X_E911_TAX_AMOUNT,
        X_USF_TAXAMOUNT,
        X_RCRF_TAX_AMOUNT,
        X_ADD_TAX1,
        X_ADD_TAX2,
        DISCOUNT_AMOUNT,
        FREIGHT_AMOUNT,
        X_AUTH_AMOUNT,
        X_USER,
        PURCH_HDR2CREDITCARD,
        PURCH_HDR2BANK_ACCT,
        PURCH_HDR2ALTPYMTSOURCE,
        PURCH_HDR2OTHER_FUNDS,
        PROG_HDR2X_PYMT_SRC,
        PROG_HDR2WEB_USER,
        X_PAYMENT_TYPE,
        X_Process_Date,
        x_promo_code
      )
      VALUES
      (
        v_purch_objid,
        in_purch_hdr.IN_RQST_SOURCE,
        In_Purch_Hdr.In_Channel,
        in_Org_Id,
        in_purch_hdr.in_order_type,
        in_purch_hdr.IN_c_orderid,
        in_purch_hdr.IN_ACCOUNT_ID,
        v_auth_request_id,
        in_purch_hdr.IN_GROUPIDENTIFIER,
        in_purch_hdr.IN_RQST_TYPE,
        SYSDATE, ---in_purch_hdr.IN_RQST_DATE ,
        in_purch_hdr.IN_ICS_APPLICATIONS,
        l_MERCHANT_ID,
        V_MERCH_REF_NUM,
        in_purch_hdr.IN_OFFER_NUM,
        in_purch_hdr.IN_QUANTITY,
        in_purch_hdr.in_ignore_avs,
        in_purch_hdr.IN_AVS,
        in_purch_hdr.IN_DISABLE_AVS,
        in_purch_hdr.IN_CUSTOMER_HOSTNAME,
        in_purch_hdr.in_customer_ipaddress,
        in_purch_hdr.IN_CUSTOMER_FIRSTNAME,
        in_purch_hdr.IN_CUSTOMER_LASTNAME,
        in_purch_hdr.IN_CUSTOMER_PHONE,
        lower(in_purch_hdr.in_customer_email),
        v_STATUS,
        in_address.X_BILL_ADDRESS1,
        in_address.X_BILL_ADDRESS2,
        in_address.X_BILL_CITY,
        in_address.X_BILL_STATE,
        in_address.X_BILL_ZIP,
        in_address.X_BILL_COUNTRY,
        in_address.X_SHIP_ADDRESS1,
        in_address.X_SHIP_ADDRESS2,
        in_address.X_SHIP_CITY,
        in_address.X_SHIP_STATE,
        in_address.X_SHIP_ZIP,
        in_address.X_SHIP_COUNTRY,
        in_purch_hdr.IN_esn,
        in_purch_hdr.IN_AMOUNT,
        In_Purch_Hdr.In_Tax_Amount,
        in_purch_hdr.IN_sales_TAX_AMOUNT,
        in_purch_hdr.IN_E911_TAX_AMOUNT,
        in_purch_hdr.IN_USF_TAXAMOUNT,
        in_purch_hdr.IN_RCRF_TAX_AMOUNT,
        in_purch_hdr.IN_ADD_TAX1,
        in_purch_hdr.IN_ADD_TAX2,
        in_purch_hdr.IN_DISCOUNT_AMOUNT,
        in_purch_hdr.IN_FREIGHT_AMOUNT,
        In_Purch_Hdr.In_Auth_Amount,
        IN_PURCH_HDR.IN_user,
        pymt_rec.pymt_src2x_credit_card,
        pymt_rec.pymt_src2x_bank_account,
        pymt_rec.pymt_src2x_altpymtsource,
        in_purch_hdr.IN_OTHER_FUNDS,
        l_pymt_source_id, -- in_purch_hdr.in_pymt_src_id,
        pymt_rec.pymt_src2web_user,
        In_Purch_Hdr.In_Payment_Type,
        In_Purch_Hdr.In_Process_Date,
        in_promocode
      );
  EXCEPTION
  WHEN OTHERS THEN
    --
    OUT_ERROR_NUM := -1;
    OUT_ERROR_MSG := 'Insert Not Success' || (SUBSTR (SQLERRM, 1, 300));
    RETURN;
  END;
  --DBMS_OUTPUT.PUT_LINE('inserts into hdr are successful');
  IF in_Purch_dtl.COUNT > 0 THEN
    FOR i_count IN in_Purch_dtl.FIRST .. in_Purch_dtl.LAST
    LOOP
      BEGIN
        INSERT
        INTO X_BIZ_PURCH_DTL
          (
            OBJID,
            X_ESN,
            X_AMOUNT,
            LINE_NUMBER,
            part_number,
            biz_PURCH_DTL2biz_PURCH_HDR,
            X_QUANTITY,
            DOMAIN,
            SALES_RATE,
            SALESTAX_AMOUNT,
            E911_RATE,
            X_E911_TAX_AMOUNT,
            USF_RATE,
            X_USF_TAXAMOUNT,
            RCRF_RATE,
            X_RCRF_TAX_AMOUNT,
            TOTAL_TAX_AMOUNT,
            TOTAL_AMOUNT,
            FREIGHT_AMOUNT,
            FREIGHT_METHOD,
            FREIGHT_CARRIER,
            DISCOUNT_AMOUNT,
            ADD_TAX_1,
            ADD_TAX_2,
            CONDITION,
            DESCRIPTION,
            KIND,
            TAXABLE
          )
          VALUES
          (
            sequ_biz_purch_dtl.NEXTVAL,
            in_Purch_dtl (i_count).IN_X_ESN,
            in_Purch_dtl (i_count).IN_LINE_AMOUNT,
            in_Purch_dtl (i_count).IN_LINE_NUMBER,
            in_Purch_dtl (i_count).IN_PART_NUMBER,
            v_purch_objid, ------- HDR OBJID
            in_Purch_dtl (i_count).IN_LINE_QUANTITY,
            in_Purch_dtl (i_count).IN_DOMAIN,
            in_Purch_dtl (i_count).IN_SALES_RATE,
            in_Purch_dtl (i_count).IN_SALESTAX_AMOUNT,
            in_Purch_dtl (i_count).IN_E911_RATE,
            in_Purch_dtl (i_count).IN_E911_TAX_AMOUNT,
            in_Purch_dtl (i_count).IN_USF_RATE,
            in_Purch_dtl (i_count).IN_USF_TAXAMOUNT,
            in_Purch_dtl (i_count).IN_RCRF_RATE,
            in_Purch_dtl (i_count).IN_RCRF_TAX_AMOUNT,
            in_Purch_dtl (i_count).IN_TOTAL_TAX_AMOUNT,
            in_Purch_dtl (i_count).IN_TOTAL_AMOUNT,
            in_Purch_dtl (i_count).IN_LINE_FREIGHT_AMOUNT,
            in_Purch_dtl (i_count).IN_LINE_FREIGHT_METHOD,
            in_Purch_dtl (i_count).IN_LINE_FREIGHT_CARRIER,
            in_Purch_dtl (i_count).IN_LINE_DISCOUNT_AMOUNT,
            in_Purch_dtl (i_count).IN_ADD_TAX_1,
            in_Purch_dtl (i_count).IN_ADD_TAX_2,
            in_Purch_dtl (i_count).IN_CONDITION,
            in_Purch_dtl (i_count).IN_DESCRIPTION,
            in_Purch_dtl (i_count).IN_KIND,
            in_Purch_dtl (i_count).IN_TAXABLE
          );
        /* EXCEPTION
        WHEN OTHERS THEN
        TOSS_UTIL_PKG.INSERT_ERROR_TAB_PROC(IP_ACTION => 'Inserts into purch_dtl',
        IP_KEY => v_purch_objid ||' '||in_Purch_dtl(i_count).IN_PART_NUMBER  ||' '||in_Purch_dtl(i_count).IN_X_ESN,
        IP_PROGRAM_NAME => 'PAYMENT_SERVICES_PKG.inserts_purch',
        ip_error_text => OUT_Error_MSg);*/
      END;
    END LOOP;
  END IF;
  Out_Purch_Hdr_Objid     := v_purch_objid;
  Out_Merchant_Ref_Number := V_MERCH_REF_NUM;
  out_merchant_id         := l_MERCHANT_ID;
  OUT_Error_MSg           := 'Success';
  OUT_ERROR_NUM           := 0;
EXCEPTION
WHEN OTHERS THEN
  -- rollback;
  --
  OUT_ERROR_NUM := SQLCODE;
  OUT_ERROR_MSG := SUBSTR (SQLERRM, 1, 300);
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION       => NULL,
                                   IP_KEY          => IN_PURCH_HDR.IN_C_ORDERID,
                                   IP_PROGRAM_NAME => 'PAYMENT_SERVICES_PKG.inserts_purch',
                                   ip_error_text   => OUT_Error_MSg);
  --DBMS_OUTPUT.PUT_LINE('l_hdr_objid =' l_hdr_objid );
END inserts_purch;
-------------------------------------------------------------------------------
PROCEDURE UPDATE_PURCH(in_hdr_objid           IN NUMBER,
                       IN_C_ORDERID           IN VARCHAR2,
                       IN_MERCHANT_REF_NUMBER IN VARCHAR2,
                       IN_AUTH_REQUEST_ID     IN VARCHAR2,
                       IN_AUTH_CODE           IN VARCHAR2,
                       IN_ICS_RCODE           IN VARCHAR2,
                       IN_ICS_RFLAG           IN VARCHAR2,
                       IN_ICS_RMSG            IN VARCHAR2,
                       IN_REQUEST_ID          IN VARCHAR2,
                       IN_AUTH_REQUEST_TOKEN  IN VARCHAR2,
                       IN_AUTH_AVS            IN VARCHAR2,
                       IN_AUTH_RESPONSE       IN VARCHAR2,
                       IN_AUTH_TIME           IN VARCHAR2,
                       IN_AUTH_RCODE          IN VARCHAR2,
                       IN_AUTH_RFLAG          IN VARCHAR2,
                       IN_AUTH_RMSG           IN VARCHAR2,
                       IN_BILL_REQUEST_TIME   IN VARCHAR2,
                       IN_BILL_RCODE          IN VARCHAR2,
                       IN_BILL_RFLAG          IN VARCHAR2,
                       IN_BILL_RMSG           IN VARCHAR2,
                       IN_BILL_TRANS_REF_NO   IN VARCHAR2,
                       IN_SCORE_RCODE         IN VARCHAR2,
                       IN_SCORE_RFLAG         IN VARCHAR2,
                       IN_SCORE_RMSG          IN VARCHAR2,
                       IN_STATUS              IN VARCHAR2,
                       in_bill_amount         IN NUMBER,
                       IN_PROCESS_DATE        IN DATE,
                       OUT_Error_Msg  		     OUT VARCHAR2,
                       OUT_Error_num  		     OUT NUMBER
                       )IS
  v_pymt_source       table_x_altpymtsource.x_alt_pymt_source%TYPE;
  v_pymt_type         x_payment_source.x_pymt_type%TYPE;
  v_auth_request_id   x_biz_purch_hdr.x_auth_request_id%TYPE;
  -- v_business_error_excp EXCEPTION;
BEGIN

  IF (IN_HDR_OBJID IS NULL) OR (IN_AUTH_REQUEST_ID IS NULL) OR (in_merchant_ref_number IS NULL) THEN
    OUT_Error_num  := 704; ---'ORDER ID REQUIRED'
    out_error_msg  := sa.get_code_fun ('PAYMENT_SERVICES_PKG', out_error_num, 'ENGLISH');
    --- raise v_business_error_excp;
    RETURN;
  END IF;
  ---
  BEGIN
    SELECT ps.x_pymt_type, aps.x_alt_pymt_source
      INTO v_pymt_type, v_pymt_source
      FROM x_payment_source ps, table_x_altpymtsource aps
    WHERE aps.objid = ps.pymt_src2x_altpymtsource
    AND aps.objid in ( select distinct purch_hdr2altpymtsource from X_Biz_Purch_Hdr
                            where objid = in_hdr_objid);
        --AND x_merchant_ref_number = in_merchant_ref_number
  EXCEPTION
    WHEN no_data_found THEN
      v_pymt_type := ' ';
      v_pymt_source := ' ';
    WHEN OTHERS THEN
      OUT_ERROR_NUM := -1;
      OUT_ERROR_MSG := 'Error in fetching Payment Type and Payment source' || (SUBSTR (SQLERRM, 1, 300));
      RETURN;
  END;

  IF v_pymt_type = 'APS' THEN
     v_auth_request_id := substr(in_auth_request_id,1,40);
  ELSE
     v_auth_request_id := in_auth_request_id;
  END IF;

  BEGIN
    UPDATE X_Biz_Purch_Hdr
    SET X_Auth_Request_Id     = NVL (v_auth_request_id, X_Auth_Request_Id),
      X_Auth_Code             = NVL (In_Auth_Code, In_Auth_Code),
      X_Ics_Rcode             = NVL (In_Ics_Rcode, X_Ics_Rcode),
      X_Ics_Rflag             = NVL (In_Ics_Rflag, X_Ics_Rflag),
      X_Ics_Rmsg              = NVL (In_Ics_Rmsg, X_Ics_Rmsg),
      X_Request_Id            = NVL (In_Request_Id, X_Request_Id),
      X_Auth_Request_Token    = NVL (In_Auth_Request_Token, X_Auth_Request_Token),
      X_Auth_Avs              = NVL (In_Auth_Avs, X_Auth_Avs),
      X_Auth_Response         = NVL (In_Auth_Response, X_Auth_Response),
      X_Auth_Time             = NVL (In_Auth_Time, X_Auth_Time),
      X_Auth_Rcode            = NVL (In_Auth_Rcode, X_Auth_Rcode),
      X_Auth_Rflag            = NVL (In_Auth_Rflag, X_Auth_Rflag),
      X_Auth_Rmsg             = NVL (In_Auth_Rmsg, X_Auth_Rmsg),
      X_Bill_Request_Time     = NVL (In_Bill_Request_Time, X_Bill_Request_Time),
      X_Bill_Rcode            = NVL (In_Bill_Rcode, X_Bill_Rcode),
      X_Bill_Rflag            = NVL (In_Bill_Rflag, X_Bill_Rflag),
      X_Bill_Rmsg             = NVL (In_Bill_Rmsg, X_Bill_Rmsg),
      X_Bill_Trans_Ref_No     = NVL (In_Bill_Trans_Ref_No, X_Bill_Trans_Ref_No),
      X_Score_Rcode           = NVL (In_Score_Rcode, X_Score_Rcode),
      X_Score_Rflag           = NVL (In_Score_Rflag, X_Score_Rflag),
      X_Score_Rmsg            = NVL (In_Score_Rmsg, X_Score_Rmsg),
      X_Bill_Amount           = NVL (In_Bill_Amount, X_Bill_Amount),
      -- x_payment_type          = 'AUTH', -- CR43524 commented
      X_PROCESS_DATE          = NVL (IN_PROCESS_DATE, X_PROCESS_DATE)
    WHERE objid               = in_hdr_objid
    AND x_merchant_ref_number = in_merchant_ref_number;
    -- CR43524 changes starts..
    --
    UPDATE  X_Biz_Purch_Hdr
    SET     x_payment_type            =   (CASE
                                          WHEN  x_payment_type  = 'PRE_CHARGE'
                                          THEN  'CHARGE'
                                          WHEN  x_payment_type  NOT IN ('PRE_CHARGE','CHARGE')
                                          THEN  'AUTH'
                                          ELSE  x_payment_type
                                          END)
    WHERE   objid                     =   in_hdr_objid
    AND     x_merchant_ref_number     =   in_merchant_ref_number;
    -- CR43524 changes ends
    --
  EXCEPTION
  WHEN OTHERS THEN
    --
    OUT_ERROR_NUM := -1;
    OUT_ERROR_MSG := 'Not Able to Update' || (SUBSTR (SQLERRM, 1, 300));
    RETURN;
  END;
  --
  BEGIN

  IF  v_pymt_source = 'SMARTPAY' THEN
    IF in_ICS_RCODE IN ('100') THEN
      UPDATE X_Biz_Purch_Hdr
      SET x_status              = NVL ('SUCCESS', x_status)
      WHERE Objid               = In_Hdr_Objid
      AND x_merchant_ref_number = in_merchant_ref_number;
     ELSE
      UPDATE X_Biz_Purch_Hdr
      SET x_status              = NVL ('FAILED', x_status)
      WHERE Objid               = In_Hdr_Objid
      AND x_merchant_ref_number = in_merchant_ref_number;
    END IF;
  ELSE
    IF in_ICS_RCODE IN ('1', '100') THEN
      UPDATE X_Biz_Purch_Hdr
      SET x_status              = NVL ('SUCCESS', x_status)
      WHERE Objid               = In_Hdr_Objid
      AND x_merchant_ref_number = in_merchant_ref_number;
    ELSIF in_ICS_RCODE IN ('480') THEN
      UPDATE X_Biz_Purch_Hdr
      SET x_status              = NVL ('PENDING REVIEW', x_status)
      WHERE Objid               = In_Hdr_Objid
      AND x_merchant_ref_number = in_merchant_ref_number;
    ELSE
      UPDATE X_Biz_Purch_Hdr
      SET x_status              = NVL ('FAILED', x_status)
      WHERE Objid               = In_Hdr_Objid
      AND x_merchant_ref_number = in_merchant_ref_number;
    END IF;
  END IF;
  EXCEPTION
  WHEN OTHERS THEN
    --
    OUT_ERROR_NUM := -1;
    OUT_ERROR_MSG := 'Status Not Updated' || (SUBSTR (SQLERRM, 1, 300));
    RETURN;
  END;
  --commit;
  OUT_Error_MSg := 'Success';
  OUT_ERROR_NUM := 0;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  --
  OUT_ERROR_NUM := SQLCODE;
  OUT_ERROR_MSG := SUBSTR (SQLERRM, 1, 300);
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION      => NULL,
                                   IP_KEY         => IN_MERCHANT_REF_NUMBER,
                                  IP_PROGRAM_NAME => 'PAYMENT_SERVICES_PKG.update_purch',
                                  ip_error_text   => OUT_Error_MSg);
END update_purch;
--------------------------------------------------------------------------------------------------------------------------
PROCEDURE validate_settle_authid(in_authid                 IN x_biz_purch_hdr.x_auth_request_id%type,
                                 out_error_msg             OUT VARCHAR2,
                                 out_status                OUT VARCHAR2,
                                 out_code                  OUT NUMBER,
                                 out_objid                 OUT x_biz_purch_hdr.objid%type,
                                 out_orderid               OUT x_biz_purch_hdr.c_orderid%type,
                                 out_merchant_id           OUT x_biz_purch_hdr.x_merchant_id%type,
                                 out_merchant_ref_number   OUT x_biz_purch_hdr.x_merchant_ref_number%type,
                                 out_customer_ipaddress    OUT x_biz_purch_hdr.x_customer_ipaddress%type,
                                 out_amount                OUT x_biz_purch_hdr.X_Auth_Amount%type,
                                 out_rqst_type             OUT x_biz_purch_hdr.x_rqst_type%type,
                                 out_bill_trans_ref_no     OUT x_biz_purch_hdr.x_bill_trans_ref_no%TYPE )IS
  l_count_of_matching_authids NUMBER;
  l_last_trans_dt             DATE;
  dtls_result_set purch_dtl_tbl;
  l_authid x_biz_purch_hdr.x_auth_request_id%TYPE;
  l_ics_applications x_biz_purch_hdr.x_ics_applications%TYPE;
  l_rqst_date x_biz_purch_hdr.x_rqst_date%TYPE;
  l_new_authid x_biz_purch_hdr.x_auth_request_id%TYPE;
  l_orderid x_biz_purch_hdr.c_orderid%TYPE;
  l_payment_type x_biz_purch_hdr.x_payment_type%TYPE;
  l_ics_rcode x_biz_purch_hdr.x_ics_rcode%TYPE;
  l_ics_rflag x_biz_purch_hdr.x_ics_rflag%TYPE;
  l_ics_rmsg x_biz_purch_hdr.x_ics_rmsg%TYPE;
  l_request_id x_biz_purch_hdr.x_request_id%TYPE;
  l_auth_request_token x_biz_purch_hdr.x_auth_request_token%TYPE;
  l_auth_avs x_biz_purch_hdr.x_auth_avs%TYPE;
  l_auth_response x_biz_purch_hdr.x_auth_response%TYPE;
  l_auth_time x_biz_purch_hdr.x_auth_time%TYPE;
  l_auth_rcode x_biz_purch_hdr.x_auth_rcode%TYPE;
  l_auth_rflag x_biz_purch_hdr.x_auth_rflag%TYPE;
  l_auth_rmsg x_biz_purch_hdr.x_auth_rmsg%TYPE;
  l_bill_request_time x_biz_purch_hdr.x_bill_request_time%TYPE;
  l_bill_rcode x_biz_purch_hdr.x_bill_rcode%TYPE;
  l_bill_rflag x_biz_purch_hdr.x_bill_rflag%TYPE;
  l_bill_rmsg x_biz_purch_hdr.x_bill_rmsg%TYPE;
  l_bill_trans_ref_no x_biz_purch_hdr.x_bill_trans_ref_no%TYPE;
  l_status x_biz_purch_hdr.x_status%TYPE;
  l_bill_amount x_biz_purch_hdr.x_bill_amount%TYPE;
  l_auth_validity NUMBER :=0; -- CR31699
  -- end_of_proc       EXCEPTION; -- CR31699
  lv_orderid   x_biz_purch_hdr.c_orderid%TYPE;
  l_merchant_ref_number  x_biz_purch_hdr.x_merchant_ref_number%type;
  l_biz_order_dtl_flag    VARCHAR2(1)  ;  -- CR43524
  CURSOR biz_hdr_cur
  IS
    SELECT *
    FROM x_biz_purch_hdr
    WHERE x_auth_request_id = in_authid
    AND x_payment_type LIKE '%AUTH';
  biz_hdr_rec biz_hdr_cur%ROWTYPE;
  CURSOR valid_cur ( l_orderid VARCHAR2)
  IS
    SELECT *
    FROM x_biz_purch_hdr
    WHERE c_orderid             = l_orderid
    AND UPPER (x_payment_type) IN ('SETTLEMENT', 'REAUTH');
  valid_rec valid_cur%ROWTYPE;
  -- CR43524 changes starts..
  CURSOR biz_hdr_chg_cur
  IS
    SELECT  *
    FROM    x_biz_purch_hdr
    WHERE   x_auth_request_id        =  in_authid
    AND     UPPER(x_payment_type)    =  'CHARGE';
  biz_hdr_chg_rec    biz_hdr_chg_cur%ROWTYPE;
  -- CR43524 changes ends
  ----------------------------------------------------------------------------------
BEGIN
  -- CR43524 changes starts..
  OPEN  biz_hdr_chg_cur;
  FETCH biz_hdr_chg_cur INTO biz_hdr_chg_rec;
  IF biz_hdr_chg_cur%FOUND
  THEN
    -- CR46373 fix starts..
    IF biz_hdr_chg_rec.x_ics_rflag IN ('REVIEW') THEN
      out_code      := -1;
      out_status    := 'REVIEW';
      out_error_msg := 'Error 108: AUTH In Review';
      --   CLOSE valid_cur;
      CLOSE biz_hdr_chg_cur;
      RETURN;
    END IF;
    -- CR46373 fix ends
    out_objid                         := biz_hdr_chg_rec.objid;
    out_merchant_ref_number           := biz_hdr_chg_rec.x_merchant_ref_number;
    out_bill_trans_ref_no             := biz_hdr_chg_rec.x_bill_trans_ref_no;
    out_orderid                       := biz_hdr_chg_rec.c_orderid;
    out_merchant_id                   := biz_hdr_chg_rec.x_merchant_id;
    out_customer_ipaddress            := biz_hdr_chg_rec.x_customer_ipaddress;
    out_amount                        := biz_hdr_chg_rec.X_Auth_Amount;
    out_rqst_type                     := biz_hdr_chg_rec.x_rqst_type;
    out_code                          := -1;
    out_status                        := 'AlreadySettled';
    out_error_msg                     := 'AUTHID already settled.X_BILL_TRANS_REF_NO: ' || biz_hdr_chg_rec.x_bill_trans_ref_no; -- CR46373 fix
    --
    BEGIN
      SELECT x_biz_order_dtl_flag
      INTO   l_biz_order_dtl_flag
      FROM   table_x_cc_parms prm
      WHERE  prm.x_merchant_id = biz_hdr_chg_rec.x_merchant_id;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    --
    IF l_biz_order_dtl_flag = 'Y'
    THEN
      --Calling the sp_ivr_insert_order_info standalone stored procedure to load
      sp_ivr_insert_order_info(i_auth_request_id =>  in_authid ,
                               o_err_code        =>  out_code,
                               o_err_msg         =>  out_error_msg);
      --
    END IF;
    --
    CLOSE biz_hdr_chg_cur;
    RETURN;
  ELSE
    CLOSE biz_hdr_chg_cur;
  END IF;
  -- CR43524 changes ends
        -- CR35874 Start
        UPDATE x_biz_purch_hdr
        SET x_payment_type = 'SETTLE_VOID', x_merchant_ref_number = x_merchant_ref_number || '_VOID'
        WHERE 1 = 1
        AND x_auth_request_id = in_authid
        AND x_status = 'SETTLEMENT PENDING'
        AND TRUNC(sysdate - x_rqst_date,5) > 0.04166  -- Request time more than an hour
        ;
        -- CR35874 End

        --CR40440  start
        SELECT distinct c_orderid
          INTO lv_orderid
          FROM x_biz_purch_hdr
     WHERE x_auth_request_id = in_authid;

        UPDATE x_biz_purch_hdr
        SET x_payment_type = 'REAUTH_VOID'
        WHERE 1 = 1
        AND c_orderid  = lv_orderid
        AND x_payment_type = 'REAUTH' AND x_status = 'SETTLEMENT PENDING'
        AND TRUNC(sysdate - x_rqst_date,5) > 0.04166;  -- Request time more than an hour        ;
        --CR40440 end
                DBMS_OUTPUT.PUT_LINE ('SQL%ROWCOUNT'||SQL%ROWCOUNT);


  OPEN biz_hdr_cur;
  FETCH biz_hdr_cur INTO biz_hdr_rec;
  --> Validation rule 1 - Checking if AUTHID exists:
  IF biz_hdr_cur%NOTFOUND THEN
    out_code      := -1;
    out_status    := 'NotExist';
    out_error_msg := 'Error 241: AUTHID does not exist';
    CLOSE biz_hdr_cur;
    RETURN;
  ELSE
         --> Validation rule 2 - Checking if AUTH in REVIEW :
    IF biz_hdr_rec.x_ics_rflag IN ('REVIEW') THEN
      out_code      :=               -1;
      out_status    := 'REVIEW';
      out_error_msg := 'Error 108: AUTH In Review';
      --   CLOSE valid_cur;
      CLOSE biz_hdr_cur;
      RETURN;
    END IF;
    OPEN valid_cur (biz_hdr_rec.c_orderid);
    FETCH valid_cur INTO valid_rec;
    IF valid_cur%FOUND THEN
      out_objid               := biz_hdr_rec.objid;
      out_orderid             := biz_hdr_rec.c_orderid;
      out_merchant_id         := biz_hdr_rec.x_merchant_id;
      out_merchant_ref_number := biz_hdr_rec.x_merchant_ref_number;
      out_customer_ipaddress  := biz_hdr_rec.x_customer_ipaddress;
      out_amount              := biz_hdr_rec.X_Auth_Amount;
      out_rqst_type           := biz_hdr_rec.x_rqst_type;
      --> Validation rule 3 - Checking if AUTHID is already settled:
      IF valid_rec.x_ics_rcode IN ('1', '100') THEN
        out_code      :=             -1;
        out_status    := 'AlreadySettled';
        out_error_msg := 'Error 100: AUTHID already settled.X_BILL_TRANS_REF_NO: ' || valid_rec.x_bill_trans_ref_no;
        CLOSE valid_cur;
        CLOSE biz_hdr_cur;
        RETURN;
      END IF;
      --> Validation rule 4 - Checking if AUTHID settlement is already in progress:
      IF valid_rec.x_status = 'SETTLEMENT PENDING' THEN
        out_code           := -1;
        out_status         := 'SettlementInProgress';
        out_error_msg      := 'Error 107: Settlement already in progress. X_BILL_TRANS_REF_NO: ' || valid_rec.x_bill_trans_ref_no;
        CLOSE valid_cur;
        CLOSE biz_hdr_cur;
        RETURN;
      END IF;
      --> Validation rule 5 - Checking if AUTHID was previously declined:
          --CR39912 Changes - adding date condition to allow failed transaction to retry after 24 hours
      IF valid_rec.x_bill_rcode NOT IN ('1', '100') AND (sysdate - valid_rec.x_rqst_date ) < 1 THEN
        out_code      := TO_NUMBER (biz_hdr_rec.x_ics_rcode);
        out_status    := 'PrevDeclined';
        out_error_msg := 'Error 106: Settlement for this AUTHID previously declined. ';
         CLOSE valid_cur;
        CLOSE biz_hdr_cur;
        RETURN;
      END IF;
      --> Validation rule 6 - Checking if REAUTH in REVIEW :
      IF valid_rec.x_ics_rflag IN ('REVIEW') THEN
        out_code      :=             -1;
        out_status    := 'REVIEW';
        out_error_msg := 'Error 109: REAUTH In Review';
        CLOSE valid_cur;
        CLOSE biz_hdr_cur;
        RETURN;
      END IF;
    END IF;
    CLOSE valid_cur;
          --> Validation rule 7 - Checking if AUTHID is for a CC/ACH purchase or not:
    IF UPPER (biz_hdr_rec.x_rqst_type) NOT IN ('ACH_PURCH', 'CREDITCARD_PURCH') THEN
      out_code      :=                           -1;
      out_status    := 'Invalid';
      out_error_msg := ('Error 102: Not an ACH or CC transaction.');
      --CLOSE valid_cur;
      CLOSE biz_hdr_cur;
      RETURN;
    END IF;
    -- PREPARING TO INSERT THE HEADER SETTLEMENT RECORD:
    out_objid                         := sequ_biz_purch_hdr.NEXTVAL;
  --  out_merchant_ref_number           := l_merchant_ref_number;
    out_bill_trans_ref_no             := biz_hdr_rec.x_bill_trans_ref_no;
    out_orderid                       := biz_hdr_rec.c_orderid;
    out_merchant_id                   := biz_hdr_rec.x_merchant_id;
    out_customer_ipaddress            := biz_hdr_rec.x_customer_ipaddress;
    out_amount                        := biz_hdr_rec.X_Auth_Amount;
    out_rqst_type                     := biz_hdr_rec.x_rqst_type;

    IF UPPER (biz_hdr_rec.x_rqst_type) in ('ACH_PURCH') THEN
      l_new_authid                    := biz_hdr_rec.x_auth_request_id;
      l_ics_rcode                     := biz_hdr_rec.x_ics_rcode;
      l_ics_rflag                     := biz_hdr_rec.x_ics_rflag;
      l_ics_rmsg                      := biz_hdr_rec.x_ics_rmsg;
      l_request_id                    := biz_hdr_rec.x_request_id;
      l_auth_request_token            := biz_hdr_rec.x_auth_request_token;
      l_auth_avs                      := biz_hdr_rec.x_auth_avs;
      l_auth_response                 := biz_hdr_rec.x_auth_response;
      l_auth_time                     := biz_hdr_rec.x_auth_time;
      l_auth_rcode                    := biz_hdr_rec.x_auth_rcode;
      l_auth_rflag                    := biz_hdr_rec.x_auth_rflag;
      l_auth_rmsg                     := biz_hdr_rec.x_auth_rmsg;
      l_bill_request_time             := biz_hdr_rec.x_bill_request_time;
      l_bill_rcode                    := biz_hdr_rec.x_bill_rcode;
      l_bill_rflag                    := biz_hdr_rec.x_bill_rflag;
      l_bill_rmsg                     := biz_hdr_rec.x_bill_rmsg;
      l_bill_trans_ref_no             := biz_hdr_rec.x_bill_trans_ref_no;
      l_status                        := biz_hdr_rec.x_status;
      l_bill_amount                   := biz_hdr_rec.x_bill_amount;
      l_payment_type                  := 'SETTLEMENT';
      l_rqst_date                     := biz_hdr_rec.x_rqst_date;
      l_ics_applications              := 'ecp_debit';
    ELSE
      --> Validation rule 8 (applies to CC only) - Checking if AUTHID is expired:
      ----- CR 31699 START
      SELECT DAYS.AUTH_VALIDITY_DAYS
      INTO l_auth_validity
      FROM TABLE_X_CC_AUTH_DAYS DAYS ,
        TABLE_X_CREDIT_CARD CC ,
        X_BIZ_PURCH_HDR HDR
      WHERE HDR.X_AUTH_REQUEST_ID = in_authid
      AND HDR.X_RQST_TYPE         = 'CREDITCARD_PURCH'
      AND HDR.X_PAYMENT_TYPE LIKE '%AUTH'
      AND HDR.PURCH_HDR2CREDITCARD = CC.OBJID
      AND UPPER (CC.X_CC_TYPE)            = DAYS.S_CARD_TYPE ;
      ----- CR 31699 END
      IF l_auth_validity < 0 THEN
        out_code        := -1;
        out_status      := 'Failed';
        out_error_msg   := 'Failed to find credit card authorizaion days';
        RETURN;
      END IF;
      -- CR 31699 END
      IF ( (TRUNC(SYSDATE) - TRUNC(biz_hdr_rec.x_rqst_date)) > l_auth_validity) --CR41809
      --IF ( (SYSDATE - TO_DATE (SUBSTR (biz_hdr_rec.x_auth_time, 1, 10), 'YYYY/MM/DD')) > l_auth_validity) -- CR31699
        THEN
        l_ics_applications := 'ics_auth, ics_bill'; -- new field 3 of 4 (for cc)
        l_payment_type     := 'REAUTH';
        l_new_authid       := NULL;
                --CR39912 Changes  - Generate New merchant ref number for all REAUTH scenarios
        l_merchant_ref_number := B2B_PKG.b2b_merchant_ref_number (biz_hdr_rec.channel);
        DBMS_OUTPUT.PUT_LINE ('inside reauth '||l_merchant_ref_number);
        out_code           := -1;
        out_status         := 'Expired';
         out_error_msg      := ( 'Error 104: AUTHID expired approx. ' || ROUND ((  SYSDATE - biz_hdr_rec.x_rqst_date)) || ' days ago. Reauthorize.' );
        --out_error_msg      := ( 'Error 104: AUTHID expired approx. ' || ROUND ( ( SYSDATE - TO_DATE (SUBSTR (biz_hdr_rec.x_auth_time, 1, 10), 'YYYY/MM/DD'))) || ' days ago. Reauthorize.' );
        UPDATE X_BIZ_PURCH_HDR
        SET X_STATUS            = 'EXPIRED'
        WHERE X_Auth_Request_Id = in_authid
        AND x_payment_type LIKE '%AUTH%';
      ELSE
        l_ics_applications := 'ics_bill';
        l_payment_type     := 'SETTLEMENT';
        l_new_authid       := biz_hdr_rec.x_auth_request_id;
        --CR39912 Changes  - Generate New merchant ref number if "_BILL" is already exist to avoid unique contraint error.
          BEGIN
           SELECT B2B_PKG.b2b_merchant_ref_number (biz_hdr_rec.channel)
             INTO l_merchant_ref_number
             FROM x_biz_purch_hdr
            WHERE x_merchant_ref_number = biz_hdr_rec.x_merchant_ref_number || '_BILL';
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  l_merchant_ref_number  := biz_hdr_rec.x_merchant_ref_number || '_BILL';
          END;
           DBMS_OUTPUT.PUT_LINE ('inside settlement '||l_merchant_ref_number);
      END IF;
      out_merchant_ref_number           := l_merchant_ref_number;


      l_ics_rcode          := NULL;
      l_ics_rflag          := NULL;
      l_ics_rmsg           := NULL;
      l_request_id         := NULL;
      l_auth_request_token := NULL;
      l_auth_avs           := NULL;
      l_auth_response      := NULL;
      l_auth_time          := NULL;
      l_auth_rcode         := NULL;
      l_auth_rflag         := NULL;
      l_auth_rmsg          := NULL;
      l_bill_request_time  := NULL;
      l_bill_rcode         := NULL;
      l_bill_rflag         := NULL;
      l_bill_rmsg          := NULL;
      l_bill_trans_ref_no  := NULL;
      l_status             := 'SETTLEMENT PENDING';
      l_bill_amount        := NULL;
      l_rqst_date          := SYSDATE;
    END IF;
    BEGIN
      INSERT
      INTO x_biz_purch_hdr
        (
          objid,
          x_rqst_source,
          channel,
          ecom_org_id,
          order_type,
          c_orderid,
          account_id,
          x_auth_request_id,
          groupidentifier,
          x_rqst_type,
          x_rqst_date,
          x_ics_applications,
          x_merchant_id,
          x_merchant_ref_number,
          x_offer_num,
          x_quantity,
          x_ignore_avs,
          x_avs,
          x_disable_avs,
          x_customer_hostname,
          x_customer_ipaddress,
          x_auth_code,
          x_ics_rcode,
          x_ics_rflag,
          x_ics_rmsg,
          x_request_id,
          x_auth_request_token,
          x_auth_avs,
          x_auth_response,
          x_auth_time,
          x_auth_rcode,
          x_auth_rflag,
          x_auth_rmsg,
          x_bill_request_time,
          x_bill_rcode,
          x_bill_rflag,
          x_bill_rmsg,
          x_bill_trans_ref_no,
          x_score_rcode,
          x_score_rflag,
          x_score_rmsg,
          x_customer_firstname,
          x_customer_lastname,
          x_customer_phone,
          x_customer_email,
          x_status,
          x_bill_address1,
          x_bill_address2,
          x_bill_city,
          x_bill_state,
          x_bill_zip,
          x_bill_country,
          x_ship_address1,
          x_ship_address2,
          x_ship_city,
          x_ship_state,
          x_ship_zip,
          x_ship_country,
          x_esn,
          x_amount,
          x_tax_amount,
          x_sales_tax_amount,
          x_e911_tax_amount,
          x_usf_taxamount,
          x_rcrf_tax_amount,
          x_add_tax1,
          x_add_tax2,
          discount_amount,
          freight_amount,
          x_auth_amount,
          x_bill_amount,
          x_user,
          purch_hdr2creditcard,
          purch_hdr2bank_acct,
          purch_hdr2other_funds,
          prog_hdr2x_pymt_src,
          prog_hdr2web_user,
          x_payment_type,
          x_process_date,
          x_promo_code
        )
        VALUES
        (
          out_objid,
          biz_hdr_rec.x_rqst_source,
          biz_hdr_rec.channel,
          biz_hdr_rec.ecom_org_id,
          biz_hdr_rec.order_type,
          out_orderid,
          biz_hdr_rec.account_id,
          l_new_authid,
          biz_hdr_rec.groupidentifier,
          out_rqst_type,
          l_rqst_date,
          l_ics_applications,
          out_merchant_id,
          out_merchant_ref_number,
          biz_hdr_rec.x_offer_num,
          biz_hdr_rec.x_quantity,
          biz_hdr_rec.x_ignore_avs,
          biz_hdr_rec.x_avs,
          biz_hdr_rec.x_disable_avs,
          biz_hdr_rec.x_customer_hostname,
          out_customer_ipaddress,
          biz_hdr_rec.x_auth_code,
          l_ics_rcode,
          l_ics_rflag,
          l_ics_rmsg,
          l_request_id,
          l_auth_request_token,
          l_auth_avs,
          l_auth_response,
          l_auth_time,
          l_auth_rcode,
          l_auth_rflag,
          l_auth_rmsg,
          l_bill_request_time,
          l_bill_rcode,
          l_bill_rflag,
          l_bill_rmsg,
          l_bill_trans_ref_no,
          biz_hdr_rec.x_score_rcode,
          biz_hdr_rec.x_score_rflag,
          biz_hdr_rec.x_score_rmsg,
          biz_hdr_rec.x_customer_firstname,
          biz_hdr_rec.x_customer_lastname,
          biz_hdr_rec.x_customer_phone,
          biz_hdr_rec.x_customer_email,
          l_status,
          biz_hdr_rec.x_bill_address1,
          biz_hdr_rec.x_bill_address2,
          biz_hdr_rec.x_bill_city,
          biz_hdr_rec.x_bill_state,
          biz_hdr_rec.x_bill_zip,
          biz_hdr_rec.x_bill_country,
          biz_hdr_rec.x_ship_address1,
          biz_hdr_rec.x_ship_address2,
          biz_hdr_rec.x_ship_city,
          biz_hdr_rec.x_ship_state,
          biz_hdr_rec.x_ship_zip,
          biz_hdr_rec.x_ship_country,
          biz_hdr_rec.x_esn,
          biz_hdr_rec.x_amount,
          biz_hdr_rec.x_tax_amount,
          biz_hdr_rec.x_sales_tax_amount,
          biz_hdr_rec.x_e911_tax_amount,
          biz_hdr_rec.x_usf_taxamount,
          biz_hdr_rec.x_rcrf_tax_amount,
          biz_hdr_rec.x_add_tax1,
          biz_hdr_rec.x_add_tax2,
          biz_hdr_rec.discount_amount,
          biz_hdr_rec.freight_amount,
          out_amount,
          l_bill_amount,
          biz_hdr_rec.x_user,
          biz_hdr_rec.purch_hdr2creditcard,
          biz_hdr_rec.purch_hdr2bank_acct,
          biz_hdr_rec.purch_hdr2other_funds,
          biz_hdr_rec.prog_hdr2x_pymt_src,
          biz_hdr_rec.prog_hdr2web_user,
          l_payment_type,
          biz_hdr_rec.x_process_date,
          biz_hdr_rec.x_promo_code
        );
    EXCEPTION
    WHEN OTHERS THEN
      out_code      := -1;
      out_error_msg := ( 'Error 110: Cloning of purch_hdr record failed due to' || SQLCODE || '.');
      UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => 'Validation of AUTHID for settlement', IP_KEY => TO_CHAR (in_authid), IP_PROGRAM_NAME => ( out_status || 'SA.PAYMENT_SERVICES_PKG.validate_settle_authid'), IP_ERROR_TEXT => out_error_msg);
    END;

    -- PREPARING TO INSERT THE DETAILS SETTLEMENT RECORDS:
    SELECT Purch_dtl_rec (x_esn, x_amount, line_number, part_number, x_quantity, domain, sales_rate, salestax_amount, e911_rate, x_e911_tax_amount, usf_rate, x_usf_taxamount, rcrf_rate, x_rcrf_tax_amount, total_tax_amount, total_amount, freight_amount, freight_method, freight_carrier, discount_amount, add_tax_1, add_tax_2) BULK COLLECT
    INTO dtls_result_set
    FROM x_biz_purch_dtl
    WHERE biz_purch_dtl2biz_purch_hdr = biz_hdr_rec.objid;
    FOR i_count IN dtls_result_set.FIRST .. dtls_result_set.LAST
    LOOP
      BEGIN
        INSERT
        INTO x_biz_purch_dtl
          (
            objid,
            x_esn,
            x_amount,
            line_number,
            part_number,
            biz_purch_dtl2biz_purch_hdr,
            x_quantity,
            domain,
            sales_rate,
            salestax_amount,
            e911_rate,
            x_e911_tax_amount,
            usf_rate,
            x_usf_taxamount,
            rcrf_rate,
            x_rcrf_tax_amount,
            total_tax_amount,
            total_amount,
            freight_amount,
            freight_method,
            freight_carrier,
            discount_amount,
            add_tax_1,
            add_tax_2
          )
          VALUES
          (
            sequ_biz_purch_dtl.NEXTVAL,
            dtls_result_set (i_count).in_x_esn,
            dtls_result_set (i_count).in_line_amount,
            dtls_result_set (i_count).in_line_number,
            dtls_result_set (i_count).in_part_number,
            out_objid, -------> hdr objid
            dtls_result_set (i_count).in_line_quantity,
            dtls_result_set (i_count).in_domain,
            dtls_result_set (i_count).in_sales_rate,
            dtls_result_set (i_count).in_salestax_amount,
            dtls_result_set (i_count).in_e911_rate,
            dtls_result_set (i_count).in_e911_tax_amount,
            dtls_result_set (i_count).in_usf_rate,
            dtls_result_set (i_count).in_usf_taxamount,
            dtls_result_set (i_count).in_rcrf_rate,
            dtls_result_set (i_count).in_rcrf_tax_amount,
            dtls_result_set (i_count).in_total_tax_amount,
            dtls_result_set (i_count).in_total_amount,
            dtls_result_set (i_count).in_line_freight_amount,
            dtls_result_set (i_count).in_line_freight_method,
            dtls_result_set (i_count).in_line_freight_carrier,
            dtls_result_set (i_count).in_line_discount_amount,
            dtls_result_set (i_count).in_add_tax_1,
            dtls_result_set (i_count).in_add_tax_2
          );
      EXCEPTION
      WHEN OTHERS THEN
        out_code      := -1;
        out_error_msg := ( 'Error 109: Cloning of purch_details records failed due to' || SQLCODE || '.');
        UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION        => 'Validation of AUTHID for settlement',
                                         IP_KEY           => TO_CHAR (in_authid),
                                         IP_PROGRAM_NAME  => ( out_status || 'SA.PAYMENT_SERVICES_PKG.validate_settle_authid'),
                                         IP_ERROR_TEXT    => out_error_msg);

      END;

    END LOOP;
  END IF;
  CLOSE biz_hdr_cur;
  --Passing the SUCCESS message:
  IF out_code  IS NULL THEN
    out_code   := 0;
    out_status := 'Success';
  END IF;
EXCEPTION
WHEN OTHERS THEN
  out_code      := -1;
  out_error_msg := (SQLCODE || SQLERRM);
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION       => 'Validation of AUTHID for settlement',
                                   IP_KEY          => TO_CHAR (in_authid),
                                   IP_PROGRAM_NAME => ( out_status || 'SA.PAYMENT_SERVICES_PKG.validate_settle_authid'),
                                   IP_ERROR_TEXT   => out_error_msg);
END validate_settle_authid;
------------------------------
--Procedure Overloaded
--for AlternatePayment source method
--Added for Smartpay integartion - CR33430
PROCEDURE validate_settle_authid(in_authid                   IN x_biz_purch_hdr.x_auth_request_id%type,
                                 out_error_msg               OUT VARCHAR2,
                                 out_status                  OUT VARCHAR2,
                                 out_code                    OUT NUMBER,
                                 out_purch_dtl               OUT BIZ_PURCH_DTL_TBL ,
                                 out_address_rec             OUT ADDR_REC ,
                                 out_application_key         OUT table_x_altpymtsource.x_application_key%type,
                                 out_objid                   OUT x_biz_purch_hdr.objid%type,
                                 out_orderid                 OUT x_biz_purch_hdr.c_orderid%type,
                                 out_merchant_id             OUT x_biz_purch_hdr.x_merchant_id%type,
                                 out_merchant_ref_number     OUT x_biz_purch_hdr.x_merchant_ref_number%type,
                                 out_customer_ipaddress      OUT x_biz_purch_hdr.x_customer_ipaddress%type,
                                 out_amount                  OUT x_biz_purch_hdr.X_Amount%type,
                                 out_tax_amount              OUT  x_biz_purch_hdr.x_tax_amount%type,
                                 out_auth_amount             OUT  x_biz_purch_hdr.x_auth_amount%type,
                                 out_rqst_type               OUT x_biz_purch_hdr.x_rqst_type%type,
                                 out_bill_trans_ref_no       OUT x_biz_purch_hdr.x_bill_trans_ref_no%TYPE,
                                 out_freight_amount          OUT  X_BIZ_PURCH_HDR.FREIGHT_AMOUNT%TYPE )IS

  l_count_of_matching_authids NUMBER;
  l_last_trans_dt             DATE;
  dtls_result_set biz_purch_dtl_tbl ;
  l_addr_rec ADDR_REC ;
  l_authid x_biz_purch_hdr.x_auth_request_id%TYPE;
  l_ics_applications x_biz_purch_hdr.x_ics_applications%TYPE;
  l_rqst_date x_biz_purch_hdr.x_rqst_date%TYPE;
  l_new_authid x_biz_purch_hdr.x_auth_request_id%TYPE;
  l_orderid x_biz_purch_hdr.c_orderid%TYPE;
  l_payment_type x_biz_purch_hdr.x_payment_type%TYPE;
  l_ics_rcode x_biz_purch_hdr.x_ics_rcode%TYPE;
  l_ics_rflag x_biz_purch_hdr.x_ics_rflag%TYPE;
  l_ics_rmsg x_biz_purch_hdr.x_ics_rmsg%TYPE;
  l_request_id x_biz_purch_hdr.x_request_id%TYPE;
  l_auth_request_token x_biz_purch_hdr.x_auth_request_token%TYPE;
  l_auth_avs x_biz_purch_hdr.x_auth_avs%TYPE;
  l_auth_response x_biz_purch_hdr.x_auth_response%TYPE;
  l_auth_time x_biz_purch_hdr.x_auth_time%TYPE;
  l_auth_rcode x_biz_purch_hdr.x_auth_rcode%TYPE;
  l_auth_rflag x_biz_purch_hdr.x_auth_rflag%TYPE;
  l_auth_rmsg x_biz_purch_hdr.x_auth_rmsg%TYPE;
  l_bill_request_time x_biz_purch_hdr.x_bill_request_time%TYPE;
  l_bill_rcode x_biz_purch_hdr.x_bill_rcode%TYPE;
  l_bill_rflag x_biz_purch_hdr.x_bill_rflag%TYPE;
  l_bill_rmsg x_biz_purch_hdr.x_bill_rmsg%TYPE;
  l_bill_trans_ref_no x_biz_purch_hdr.x_bill_trans_ref_no%TYPE;
  l_status x_biz_purch_hdr.x_status%TYPE;
  l_bill_amount x_biz_purch_hdr.x_bill_amount%TYPE;
  l_auth_validity NUMBER :=0; -- CR31699
  v_purch_hdr2altpymtsource  x_biz_purch_hdr.purch_hdr2altpymtsource%TYPE;
  l_merchant_ref_number  x_biz_purch_hdr.x_merchant_ref_number%type;

  l_in_authid      x_biz_purch_hdr.x_auth_request_id%type;
  l_out_error_msg  VARCHAR2(100);
  l_out_status     VARCHAR2(100);
  l_out_code       NUMBER;
  l_out_objid      x_biz_purch_hdr.objid%type;
  l_out_orderid     x_biz_purch_hdr.c_orderid%type;
  l_out_merchant_id   x_biz_purch_hdr.x_merchant_id%type;
  l_out_merchant_ref_number  x_biz_purch_hdr.x_merchant_ref_number%type;
  l_out_customer_ipaddress   x_biz_purch_hdr.x_customer_ipaddress%type;
  l_out_auth_amount           x_biz_purch_hdr.X_Auth_Amount%type;
  l_out_rqst_type            x_biz_purch_hdr.x_rqst_type%type;
  l_out_bill_trans_ref_no    x_biz_purch_hdr.x_bill_trans_ref_no%TYPE;

-- end_of_proc       EXCEPTION; -- CR31699
CURSOR biz_hdr_cur
IS
  SELECT *
  FROM x_biz_purch_hdr
  WHERE x_auth_request_id = in_authid
  AND x_payment_type LIKE '%AUTH';
biz_hdr_rec biz_hdr_cur%ROWTYPE;
CURSOR valid_cur ( l_orderid VARCHAR2)
IS
  SELECT *
  FROM x_biz_purch_hdr
  WHERE c_orderid             = l_orderid
  AND UPPER (x_payment_type) IN ('SETTLEMENT');
valid_rec valid_cur%ROWTYPE;
l_rqst_type x_biz_purch_hdr.x_rqst_type%type;
----------------------------------------------------------------------------------
BEGIN
  BEGIN
    SELECT DISTINCT x_rqst_type
    INTO l_rqst_type
    FROM x_biz_purch_hdr
    WHERE x_auth_request_id = in_authid;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    out_code   := -1;
    out_status := 'No transaction found for the given auth id';
  WHEN OTHERS THEN
    out_code   := -1;
    out_status := 'Error in fetching x_rqst_type';
  END;
  IF l_rqst_type IN ( 'CREDITCARD_PURCH','ACH_PURCH') THEN
    validate_settle_authid( in_authid,
                            l_out_error_msg,
                            l_out_status,
                            l_out_code,
                            l_out_objid,
                            l_out_orderid,
                            l_out_merchant_id,
                            l_out_merchant_ref_number,
                            l_out_customer_ipaddress,
                            l_out_auth_amount,
                            l_out_rqst_type,
                            l_out_bill_trans_ref_no );

    out_error_msg           := l_out_error_msg;
    out_status              := l_out_status ;
    out_code                := l_out_code;
    out_objid               := l_out_objid;
    out_orderid             := l_out_orderid;
    out_merchant_id         := l_out_merchant_id;
    out_merchant_ref_number := l_out_merchant_ref_number;
    out_customer_ipaddress  := l_out_customer_ipaddress;
    out_amount              := l_out_auth_amount; --out_amount parameter is meant for passing Auth_amount for Credit Card and ACH.
    out_rqst_type           := l_out_rqst_type;
    out_bill_trans_ref_no   := l_out_bill_trans_ref_no;
  ELSE
    OPEN biz_hdr_cur;
    FETCH biz_hdr_cur INTO biz_hdr_rec;
    --> Validation rule 1 - Checking if AUTHID exists:
    IF biz_hdr_cur%NOTFOUND THEN
      out_code      := -1;
      out_status    := 'NotExist';
      out_error_msg := 'Error 241: AUTHID does not exist';
      CLOSE biz_hdr_cur;
      RETURN;
    ELSE
      --> Checking if AUTHID is for AlternateSource Payment purchase:
      IF UPPER (biz_hdr_rec.x_rqst_type) NOT IN ('ALTSOURCE_PURCH') THEN
        out_code      :=                           -1;
        out_status    := 'Invalid';
        out_error_msg := ('Error 102: Not an Alternate PaymentSource transaction.');
        --CLOSE valid_cur;
        CLOSE biz_hdr_cur;
        RETURN;
      END IF;
      --> Checking if AUTHID was already settled:
      OPEN valid_cur (biz_hdr_rec.c_orderid);
      FETCH valid_cur INTO valid_rec;
      IF valid_cur%FOUND THEN
        IF valid_rec.x_ics_rcode IN ('100') THEN
          out_code      :=             -1;
          out_status    := 'AlreadySettled';
          out_error_msg := 'Error 100: AUTHID already settled.X_BILL_TRANS_REF_NO: ' || valid_rec.x_bill_trans_ref_no;
          CLOSE valid_cur;
          CLOSE biz_hdr_cur;
          RETURN;
        END IF;
		--CR50154 - Commenting the below to allow Re-triggering
      /*  --> Checking if AUTHID was previously declined:
        IF valid_rec.x_bill_rcode NOT IN ('100') THEN
          out_code      := TO_NUMBER (biz_hdr_rec.x_ics_rcode);
          out_status    := 'PrevDeclined';
          out_error_msg := 'Error 106: Settlement for this AUTHID previously declined. ';
          CLOSE valid_cur;
          CLOSE biz_hdr_cur;
          RETURN;
        END IF;  */

		--CR50154 ST LTO - Void the existing SETTLEMENT record
       UPDATE x_biz_purch_hdr
          SET x_payment_type = 'SETTLE_VOID', x_merchant_ref_number = x_merchant_ref_number || '_VOID', x_auth_request_id = NULL
          WHERE 1 = 1
			AND c_orderid             = biz_hdr_rec.c_orderid
			AND UPPER (x_payment_type) IN ('SETTLEMENT')
			AND x_status   = 'FAILED';
		DBMS_OUTPUT.PUT_LINE ('update SETTLE VOID count'||SQL%ROWCOUNT);
       --CR50154 ST LTO - End
      END IF;
      --Preparing the Out Parameter values
      BEGIN
        SELECT aps.x_application_key
        INTO out_application_key
        FROM x_biz_purch_hdr h,
          table_x_altpymtsource aps
        WHERE aps.objid       = h.purch_hdr2altpymtsource
        AND x_auth_request_id = in_authid;
      EXCEPTION
      WHEN OTHERS THEN
        out_code      := -1;
        out_error_msg := ( 'Error in fetching Application_key for the given Auth id' || (SUBSTR (SQLERRM, 1, 300)));
        RETURN;
      END;

	 --CR50154 ST LTO
	 DBMS_OUTPUT.PUT_LINE ('biz_hdr_rec.x_merchant_ref_number'||biz_hdr_rec.x_merchant_ref_number );
	 BEGIN
	   SELECT B2B_PKG.b2b_merchant_ref_number (biz_hdr_rec.channel)
		 INTO l_merchant_ref_number   --to be used for new settlment record insert if all validation is success
		 FROM x_biz_purch_hdr
		WHERE x_merchant_ref_number like biz_hdr_rec.x_merchant_ref_number || '_BILL%';
	  EXCEPTION
		 WHEN NO_DATA_FOUND THEN
			  l_merchant_ref_number  := biz_hdr_rec.x_merchant_ref_number || '_BILL';
	  END;
	  DBMS_OUTPUT.PUT_LINE ('l_merchant_ref_number ' ||l_merchant_ref_number);
     --CR50154 ST LTO End

      out_objid               := sequ_biz_purch_hdr.NEXTVAL;
      out_merchant_ref_number := l_merchant_ref_number;
      out_bill_trans_ref_no   := biz_hdr_rec.x_bill_trans_ref_no;
      out_orderid             := biz_hdr_rec.c_orderid;
      out_merchant_id         := biz_hdr_rec.x_merchant_id;
      out_customer_ipaddress  := biz_hdr_rec.x_customer_ipaddress;
      out_amount              := biz_hdr_rec.x_amount;
      out_tax_amount          := biz_hdr_rec.x_tax_amount;
      out_auth_amount         := biz_hdr_rec.X_Auth_Amount;
      out_rqst_type           := biz_hdr_rec.x_rqst_type;
      out_freight_amount      := biz_hdr_rec.freight_amount;
      SELECT addr_rec ( X_BILL_ADDRESS1,
                        X_BILL_ADDRESS2,
                        X_BILL_CITY ,
                        X_BILL_STATE ,
                        X_BILL_ZIP ,
                        X_BILL_COUNTRY ,
                        X_SHIP_ADDRESS1 ,
                        X_SHIP_ADDRESS2,
                        X_SHIP_CITY ,
                        X_SHIP_STATE ,
                        X_Ship_Zip ,
                        X_SHIP_COUNTRY )
      INTO l_addr_rec
      FROM x_biz_purch_hdr
      WHERE x_auth_request_id = in_authid;
      out_address_rec        := l_addr_rec;
      -- PREPARING TO INSERT THE HEADER SETTLEMENT RECORD:
      IF UPPER (biz_hdr_rec.x_rqst_type) IN ('ALTSOURCE_PURCH') THEN
	  --CR50154 ST LTO - update_settlmnt_rec will be invoked to update the Smartpay responses.
    /*    l_new_authid         := biz_hdr_rec.x_auth_request_id;
        l_ics_rcode          := biz_hdr_rec.x_ics_rcode;
        l_ics_rflag          := biz_hdr_rec.x_ics_rflag;
        l_ics_rmsg           := biz_hdr_rec.x_ics_rmsg;
        l_request_id         := biz_hdr_rec.x_request_id;
        l_auth_request_token := biz_hdr_rec.x_auth_request_token;
        l_auth_avs           := biz_hdr_rec.x_auth_avs;
        l_auth_response      := biz_hdr_rec.x_auth_response;
        l_auth_time          := biz_hdr_rec.x_auth_time;
        l_auth_rcode         := biz_hdr_rec.x_auth_rcode;
        l_auth_rflag         := biz_hdr_rec.x_auth_rflag;
        l_auth_rmsg          := biz_hdr_rec.x_auth_rmsg;
        l_bill_request_time  := biz_hdr_rec.x_bill_request_time;
        l_bill_rcode         := biz_hdr_rec.x_bill_rcode;
        l_bill_rflag         := biz_hdr_rec.x_bill_rflag;
        l_bill_rmsg          := biz_hdr_rec.x_bill_rmsg;
        l_bill_trans_ref_no  := biz_hdr_rec.x_bill_trans_ref_no;
        l_status             := biz_hdr_rec.x_status;
        l_bill_amount        := biz_hdr_rec.x_bill_amount;
        l_payment_type       := 'SETTLEMENT';
        l_rqst_date          := SYSDATE;   --CR50154
        l_ics_applications   := 'ics_bill';  */
      l_new_authid         := NULL;
	  l_ics_rcode          := NULL;
      l_ics_rflag          := NULL;
      l_ics_rmsg           := NULL;
      l_request_id         := NULL;
      l_auth_request_token := NULL;
      l_auth_avs           := NULL;
      l_auth_response      := NULL;
      l_auth_time          := NULL;
      l_auth_rcode         := NULL;
      l_auth_rflag         := NULL;
      l_auth_rmsg          := NULL;
      l_bill_request_time  := NULL;
      l_bill_rcode         := NULL;
      l_bill_rflag         := NULL;
      l_bill_rmsg          := NULL;
      l_bill_trans_ref_no  := NULL;
      l_status             := NULL;
      l_bill_amount        := NULL;
      l_rqst_date          := SYSDATE;
	  l_payment_type       := 'SETTLEMENT';
	  l_ics_applications   := 'ics_bill';
	  --CR50154 ST LTO - End

      END IF;
      BEGIN
        INSERT
        INTO x_biz_purch_hdr
          (
            objid,
            x_rqst_source,
            channel,
            ecom_org_id,
            order_type,
            c_orderid,
            account_id,
            x_auth_request_id,
            groupidentifier,
            x_rqst_type,
            x_rqst_date,
            x_ics_applications,
            x_merchant_id,
            x_merchant_ref_number,
            x_offer_num,
            x_quantity,
            x_ignore_avs,
            x_avs,
            x_disable_avs,
            x_customer_hostname,
            x_customer_ipaddress,
            x_auth_code,
            x_ics_rcode,
            x_ics_rflag,
            x_ics_rmsg,
            x_request_id,
            x_auth_request_token,
            x_auth_avs,
            x_auth_response,
            x_auth_time,
            x_auth_rcode,
            x_auth_rflag,
            x_auth_rmsg,
            x_bill_request_time,
            x_bill_rcode,
            x_bill_rflag,
            x_bill_rmsg,
            x_bill_trans_ref_no,
            x_score_rcode,
            x_score_rflag,
            x_score_rmsg,
            x_customer_firstname,
            x_customer_lastname,
            x_customer_phone,
            x_customer_email,
            x_status,
            x_bill_address1,
            x_bill_address2,
            x_bill_city,
            x_bill_state,
            x_bill_zip,
            x_bill_country,
            x_ship_address1,
            x_ship_address2,
            x_ship_city,
            x_ship_state,
            x_ship_zip,
            x_ship_country,
            x_esn,
            x_amount,
            x_tax_amount,
            x_sales_tax_amount,
            x_e911_tax_amount,
            x_usf_taxamount,
            x_rcrf_tax_amount,
            x_add_tax1,
            x_add_tax2,
            discount_amount,
            freight_amount,
            x_auth_amount,
            x_bill_amount,
            x_user,
            purch_hdr2creditcard,
            purch_hdr2bank_acct,
            purch_hdr2altpymtsource,
            purch_hdr2other_funds,
            prog_hdr2x_pymt_src,
            prog_hdr2web_user,
            x_payment_type,
            x_process_date,
            x_promo_code
          )
          VALUES
          (
            out_objid,
            biz_hdr_rec.x_rqst_source,
            biz_hdr_rec.channel,
            biz_hdr_rec.ecom_org_id,
            biz_hdr_rec.order_type,
            out_orderid,
            biz_hdr_rec.account_id,
            l_new_authid,
            biz_hdr_rec.groupidentifier,
            out_rqst_type,
            l_rqst_date,
            l_ics_applications,
            out_merchant_id,
            out_merchant_ref_number,
            biz_hdr_rec.x_offer_num,
            biz_hdr_rec.x_quantity,
            biz_hdr_rec.x_ignore_avs,
            biz_hdr_rec.x_avs,
            biz_hdr_rec.x_disable_avs,
            biz_hdr_rec.x_customer_hostname,
            out_customer_ipaddress,
            biz_hdr_rec.x_auth_code,
            l_ics_rcode,
            l_ics_rflag,
            l_ics_rmsg,
            l_request_id,
            l_auth_request_token,
            l_auth_avs,
            l_auth_response,
            l_auth_time,
            l_auth_rcode,
            l_auth_rflag,
            l_auth_rmsg,
            l_bill_request_time,
            l_bill_rcode,
            l_bill_rflag,
            l_bill_rmsg,
            l_bill_trans_ref_no,
            biz_hdr_rec.x_score_rcode,
            biz_hdr_rec.x_score_rflag,
            biz_hdr_rec.x_score_rmsg,
            biz_hdr_rec.x_customer_firstname,
            biz_hdr_rec.x_customer_lastname,
            biz_hdr_rec.x_customer_phone,
            biz_hdr_rec.x_customer_email,
            l_status,
            biz_hdr_rec.x_bill_address1,
            biz_hdr_rec.x_bill_address2,
            biz_hdr_rec.x_bill_city,
            biz_hdr_rec.x_bill_state,
            biz_hdr_rec.x_bill_zip,
            biz_hdr_rec.x_bill_country,
            biz_hdr_rec.x_ship_address1,
            biz_hdr_rec.x_ship_address2,
            biz_hdr_rec.x_ship_city,
            biz_hdr_rec.x_ship_state,
            biz_hdr_rec.x_ship_zip,
            biz_hdr_rec.x_ship_country,
            biz_hdr_rec.x_esn,
            biz_hdr_rec.x_amount,
            biz_hdr_rec.x_tax_amount,
            biz_hdr_rec.x_sales_tax_amount,
            biz_hdr_rec.x_e911_tax_amount,
            biz_hdr_rec.x_usf_taxamount,
            biz_hdr_rec.x_rcrf_tax_amount,
            biz_hdr_rec.x_add_tax1,
            biz_hdr_rec.x_add_tax2,
            biz_hdr_rec.discount_amount,
            biz_hdr_rec.freight_amount,
            out_auth_amount,
            l_bill_amount,
            biz_hdr_rec.x_user,
            biz_hdr_rec.purch_hdr2creditcard,
            biz_hdr_rec.purch_hdr2bank_acct,
            biz_hdr_rec.purch_hdr2altpymtsource,
            biz_hdr_rec.purch_hdr2other_funds,
            biz_hdr_rec.prog_hdr2x_pymt_src,
            biz_hdr_rec.prog_hdr2web_user,
            l_payment_type,
            biz_hdr_rec.x_process_date,
            biz_hdr_rec.x_promo_code
          );
      EXCEPTION
      WHEN OTHERS THEN
        out_code      := -1;
        out_error_msg := ( 'Error 110: Cloning of purch_hdr record failed due to' || SQLCODE || '.');
        UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION       => 'Validation of AUTHID for settlement',
                                         IP_KEY          => TO_CHAR (in_authid),
                                         IP_PROGRAM_NAME => ( out_status || 'SA.PAYMENT_SERVICES_PKG.validate_settle_authid'),
                                         IP_ERROR_TEXT   => out_error_msg);
      END;
      -- PREPARING TO INSERT THE DETAILS SETTLEMENT RECORDS:
      SELECT biz_Purch_dtl_rec (x_esn, x_amount, line_number, part_number, x_quantity, domain, sales_rate, salestax_amount, e911_rate, x_e911_tax_amount, usf_rate, x_usf_taxamount, rcrf_rate, x_rcrf_tax_amount, total_tax_amount, total_amount, freight_amount, freight_method, freight_carrier, discount_amount, add_tax_1, add_tax_2,condition,description,Kind,taxable) BULK COLLECT
      INTO dtls_result_set
      FROM x_biz_purch_dtl
      WHERE biz_purch_dtl2biz_purch_hdr = biz_hdr_rec.objid;
      FOR i_count IN dtls_result_set.FIRST .. dtls_result_set.LAST
      LOOP
        BEGIN
          INSERT
          INTO x_biz_purch_dtl
            (
              objid,
              x_esn,
              x_amount,
              line_number,
              part_number,
              biz_purch_dtl2biz_purch_hdr,
              x_quantity,
              domain,
              sales_rate,
              salestax_amount,
              e911_rate,
              x_e911_tax_amount,
              usf_rate,
              x_usf_taxamount,
              rcrf_rate,
              x_rcrf_tax_amount,
              total_tax_amount,
              total_amount,
              freight_amount,
              freight_method,
              freight_carrier,
              discount_amount,
              add_tax_1,
              add_tax_2,
              condition,
              description,
              kind,
              taxable
            )
            VALUES
            (
              sequ_biz_purch_dtl.NEXTVAL,
              dtls_result_set (i_count).in_x_esn,
              dtls_result_set (i_count).in_line_amount,
              dtls_result_set (i_count).in_line_number,
              dtls_result_set (i_count).in_part_number,
              out_objid, -------> hdr objid
              dtls_result_set (i_count).in_line_quantity,
              dtls_result_set (i_count).in_domain,
              dtls_result_set (i_count).in_sales_rate,
              dtls_result_set (i_count).in_salestax_amount,
              dtls_result_set (i_count).in_e911_rate,
              dtls_result_set (i_count).in_e911_tax_amount,
              dtls_result_set (i_count).in_usf_rate,
              dtls_result_set (i_count).in_usf_taxamount,
              dtls_result_set (i_count).in_rcrf_rate,
              dtls_result_set (i_count).in_rcrf_tax_amount,
              dtls_result_set (i_count).in_total_tax_amount,
              dtls_result_set (i_count).in_total_amount,
              dtls_result_set (i_count).in_line_freight_amount,
              dtls_result_set (i_count).in_line_freight_method,
              dtls_result_set (i_count).in_line_freight_carrier,
              dtls_result_set (i_count).in_line_discount_amount,
              dtls_result_set (i_count).in_add_tax_1,
              dtls_result_set (i_count).in_add_tax_2,
              dtls_result_set (i_count).in_condition,
              dtls_result_set (i_count).in_description,
              dtls_result_set (i_count).in_kind,
              dtls_result_set (i_count).in_taxable
            );
        EXCEPTION
        WHEN OTHERS THEN
          out_code      := -1;
          out_error_msg := ( 'Error 109: Cloning of purch_details records failed due to' || SQLCODE || '.');
          UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION       => 'Validation of AUTHID for settlement',
                                           IP_KEY          => TO_CHAR (in_authid),
                                           IP_PROGRAM_NAME => ( out_status || 'SA.PAYMENT_SERVICES_PKG.validate_settle_authid'),
                                           IP_ERROR_TEXT   => out_error_msg);
        END;
      END LOOP;
      out_purch_dtl             := dtls_result_set;
      v_purch_hdr2altpymtsource := biz_hdr_rec.purch_hdr2altpymtsource;
    END IF;
    CLOSE biz_hdr_cur;
    --Passing the SUCCESS message:
    IF out_code     IS NULL THEN
      out_code      := 0;
      out_status    := 'Success';
      out_error_msg := '';
      --Updating the status as 'DELETED' once it is settled - For Smart pay .
      UPDATE x_payment_source ps
      SET ps.x_status                = 'DELETED'
      WHERE pymt_src2x_altpymtsource = v_purch_hdr2altpymtsource;
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  out_code      := -1;
  out_error_msg := (SQLCODE || SQLERRM);
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION       => 'Validation of AUTHID for settlement',
                                   IP_KEY          => TO_CHAR (in_authid),
                                   IP_PROGRAM_NAME => ( out_status || 'SA.PAYMENT_SERVICES_PKG.validate_settle_authid'),
                                   IP_ERROR_TEXT   => out_error_msg);
END validate_settle_authid;
--------------------------------------------------------------------------------------------------------------------------
PROCEDURE  sp_ivr_insert_order_info(i_auth_request_id  IN   VARCHAR2,
                                    o_err_msg          OUT  VARCHAR2,
                                    o_err_code         OUT  NUMBER
                                    )IS

    --Cursor Declaration to retrieve order details for x_biz_order_dtl table.
  CURSOR order_dtl_info_cur(l_auth_request_id IN VARCHAR2)
  IS
    SELECT ph.objid                 ,
           ph.c_orderid             ,
           pd_app.part_number       ,
           pd_app.line_number       ,
           pd_app.x_amount          ,
           pd_app.salestax_amount   ,
           pd_app.x_e911_tax_amount ,
           pd_app.x_usf_taxamount   ,
           pd_app.x_rcrf_tax_amount ,
           pd_app.total_tax_amount  ,
           pd_app.total_amount      ,
           ph.groupidentifier
    FROM   x_biz_purch_hdr       ph    ,
             x_biz_purch_dtl       pd_app
    WHERE  ph.x_auth_request_id      = l_auth_request_id
    AND    ph.x_rqst_type            = 'CREDITCARD_PURCH'
    --AND    ph.x_ics_applications     = 'ics_auth'
    AND    ph.x_payment_type         =   'CHARGE' -- CR43524
    AND    ph.objid                  = pd_app.biz_purch_dtl2biz_purch_hdr
    AND    NOT EXISTS  (SELECT 1
                        FROM   x_biz_purch_hdr       ph       ,
                               x_biz_purch_dtl       pd_appar
                        WHERE  ph.x_auth_request_id                 = l_auth_request_id
                          AND    ph.x_rqst_type                       = 'CREDITCARD_PURCH'
                         -- AND    ph.x_ics_applications                = 'ics_auth'
                          AND    ph.x_payment_type                    = 'CHARGE' -- CR43524
                          AND    ph.objid                             = pd_appar.biz_purch_dtl2biz_purch_hdr
                          AND    pd_appar.biz_purch_dtl2biz_purch_hdr = pd_app.biz_purch_dtl2biz_purch_hdr
                          AND    EXISTS  (SELECT 1  FROM x_ff_part_num_mapping where x_source_part_num = pd_appar.part_number)
                          )
    UNION
    SELECT ph.objid                   ,
           ph.c_orderid               ,
           pd_appar.part_number       ,
           pd_appar.line_number       ,
           pd_appar.x_amount          ,
           pd_appar.salestax_amount   ,
           pd_appar.x_e911_tax_amount ,
           pd_appar.x_usf_taxamount   ,
           pd_appar.x_rcrf_tax_amount ,
           pd_appar.total_tax_amount  ,
           pd_appar.total_amount      ,
           ph.groupidentifier
    FROM   x_biz_purch_hdr       ph       ,
           x_biz_purch_dtl       pd_appar
    WHERE  ph.x_auth_request_id        = l_auth_request_id
    AND    ph.x_rqst_type              = 'CREDITCARD_PURCH'
    --AND    ph.x_ics_applications       = 'ics_auth'
    AND    ph.x_payment_type           = 'CHARGE' -- CR43524
    AND    ph.objid                    = pd_appar.biz_purch_dtl2biz_purch_hdr
    AND    EXISTS  (SELECT 1  FROM x_ff_part_num_mapping where x_source_part_num = pd_appar.part_number );

--Local variables
  order_dtl_info_rec order_dtl_info_cur%ROWTYPE;
  l_auth_request_id  VARCHAR2(40);

BEGIN --Main section

  SELECT x_auth_request_id
  INTO   l_auth_request_id
  FROM   x_biz_purch_hdr
  WHERE  c_orderid in (SELECT c_orderid
                       FROM   x_biz_purch_hdr
                       WHERE  x_auth_request_id  = i_auth_request_id
                       AND    x_rqst_type        = 'CREDITCARD_PURCH'
                       --AND    x_ics_applications = 'ics_bill'
                       AND    x_payment_type     = 'CHARGE' -- CR43524
                       )
  AND  x_rqst_type        = 'CREDITCARD_PURCH'
  -- AND  x_ics_applications = 'ics_auth'
  AND    x_payment_type     = 'CHARGE'; -- CR43524

  --Loop through the cursor
  FOR order_dtl_info_rec IN order_dtl_info_cur(l_auth_request_id)
  LOOP

        --Inserting records into x_biz_order_dtl table for the given auth_request_id.
    BEGIN
      INSERT INTO sa.x_biz_order_dtl
	    ( objid                         ,
        x_item_type                    ,
        x_item_value                   ,
        x_item_part                    ,
        x_ecom_order_number            ,
        x_ofs_order_number             ,
        x_order_line_number            ,
        x_amount                       ,
        x_sales_tax_amount             ,
        x_e911_tax_amount              ,
        x_usf_tax_amount               ,
        x_rcrf_tax_amount              ,
        x_total_tax_amount             ,
        x_total_amount                 ,
        x_ecom_group_id                ,
        x_extract_flag                 ,
        x_extract_date                 ,
        x_creation_date                ,
        x_create_by                    ,
        x_last_update_date             ,
        x_last_updated_by              ,
        biz_order_dtl2biz_purch_hdr_cr ,
        biz_order_dtl2biz_order_dtl_cr
        )
        VALUES
        (sa.sequ_order_dtl.nextval                   ,
        'PLAN'                                      ,--ITEM_TYPE
        NULL                                        ,--ITEM_VALUE (Billing)
        order_dtl_info_rec.part_number              ,--ITEM_PART
        order_dtl_info_rec.c_orderid                ,--ECOM_ORDER_NUMBER
        NULL                                        ,--OFS ORDER NUMBER
        order_dtl_info_rec.line_number              ,--ORDER LINE NUMBER
        order_dtl_info_rec.x_amount                 ,
        order_dtl_info_rec.salestax_amount          ,
        order_dtl_info_rec.x_e911_tax_amount        ,
        order_dtl_info_rec.x_usf_taxamount          ,
        order_dtl_info_rec.x_rcrf_tax_amount        ,
        order_dtl_info_rec.total_tax_amount         ,
        order_dtl_info_rec.total_amount             ,
        order_dtl_info_rec.groupidentifier          ,
        'YES'                                       ,--x_extract_flag
        SYSDATE                                     ,--x_extract_date
        SYSDATE                                     ,--x_creation_date
        'CORECBO'                                   ,--x_create_by
        SYSDATE                                     ,--x_last_update_date
        'CORECBO'                                   ,--x_last_updated_by
        NULL                                        ,--biz_order_dtl2biz_purch_hdr_cr
        NULL                                        --biz_order_dtl2biz_order_dtl_cr
        );
    EXCEPTION
    WHEN OTHERS THEN
      o_err_code :=  -2                                                                ;
      o_err_msg :=  'Error occurred while inserting record : '||substr(sqlerrm,1,100) ;
    END;
    END LOOP;

      o_err_code := 0;
      o_err_msg  := 'Success';
   EXCEPTION
     WHEN OTHERS THEN
       o_err_code := -3;
       o_err_msg  := 'sp_ivr_insert_order_info:  '||substr(sqlerrm,1,100);

  sa.util_pkg.insert_error_tab ( i_action        => 'Insert Order Detail Info'     ,
                                  i_key          => l_auth_request_id              ,
                                  i_program_name => 'sp_ivr_insert_order_info'     ,
                                  i_error_text   => o_err_msg
                                  );

END sp_ivr_insert_order_info;
--------------------------------------------------------------------------------------------------------------------------
PROCEDURE update_settlmnt_rec(in_objid                IN x_biz_purch_hdr.objid%TYPE,
                              in_authid               IN x_biz_purch_hdr.x_auth_request_id%TYPE,
                              in_pymt_source_type     IN x_biz_purch_hdr.x_rqst_type%TYPE,
                              in_ics_rcode            IN x_biz_purch_hdr.x_ics_rcode%TYPE,
                              in_ics_rflag            IN x_biz_purch_hdr.x_ics_rflag%TYPE,
                              in_ics_rmsg             IN x_biz_purch_hdr.x_ics_rmsg%TYPE,
                              in_bill_request_time    IN x_biz_purch_hdr.x_bill_request_time%TYPE,
                              in_bill_rcode           IN x_biz_purch_hdr.x_bill_rcode%TYPE,
                              in_bill_rflag           IN x_biz_purch_hdr.x_bill_rflag%TYPE,
                              in_bill_rmsg            IN x_biz_purch_hdr.x_bill_rmsg%TYPE,
                              inout_bill_trans_ref_no IN OUT x_biz_purch_hdr.x_bill_trans_ref_no%TYPE,
                              in_bill_amount          IN x_biz_purch_hdr.x_bill_amount%TYPE,
                              in_auth_rcode           IN x_biz_purch_hdr.X_AUTH_RCODE%TYPE,
                              in_auth_rflag           IN x_biz_purch_hdr.X_AUTH_RFLAG%TYPE,
                              in_auth_rmsg            IN x_biz_purch_hdr.X_AUTH_RMSG%TYPE,
                              in_auth_avs             IN x_biz_purch_hdr.X_AUTH_AVS%TYPE,
                              in_auth_response        IN x_biz_purch_hdr.X_AUTH_RESPONSE%TYPE,
                              in_auth_time            IN x_biz_purch_hdr.X_AUTH_TIME%TYPE,
                              in_auth_code            IN x_biz_purch_hdr.X_AUTH_CODE%TYPE,
                              out_error_msg           OUT VARCHAR2,
                              out_status              OUT VARCHAR2,
                              out_code                OUT NUMBER )IS
  CURSOR cur_bizpurchhdr_row
  IS
    SELECT * FROM x_biz_purch_hdr WHERE objid = in_objid;
  x_biz_purch_hdr_rec x_biz_purch_hdr%ROWTYPE;
  l_count_of_matching_objids NUMBER;
  l_objid x_biz_purch_hdr.x_auth_request_id%TYPE;
  l_status x_biz_purch_hdr.x_status%TYPE;
  --l_payment_type            x_biz_purch_hdr.x_payment_type%type;

  --CR26169 -IVR Universal Purchase
  l_biz_order_dtl_flag  VARCHAR2(1)  ;
  l_err_code            VARCHAR2(50) ;
  l_err_msg             VARCHAR2(100);
BEGIN
  -- Validation rule 1 - Checking if objid exists:
  SELECT COUNT (objid)
  INTO l_count_of_matching_objids
  FROM x_biz_purch_hdr
  WHERE objid                   = in_objid;
  IF l_count_of_matching_objids = 0 THEN
    out_code                   := -1;
    out_status                 := 'NotExist';
    out_error_msg              := 'Error 241: OBJID does not exist';
    RETURN;
  END IF;
  -- Validation rule 2 - Checking if AUTHID is not yet settled/cloned:
  OPEN cur_bizpurchhdr_row;
  FETCH cur_bizpurchhdr_row INTO x_biz_purch_hdr_rec;
  IF UPPER (x_biz_purch_hdr_rec.x_ics_applications) NOT LIKE '%ICS_BILL%' THEN
    out_code      := -1;
    out_status    := 'NotSettled';
    out_error_msg := 'Error 105: AUTHID not yet settled.';
    CLOSE cur_bizpurchhdr_row;
    RETURN;
  END IF;
  --CR50154 ST LTO - Commented to allow Alternate payment sources as well
 /* -- Validation rule 3 - Checking if AUTHID is for a CC/ACH purchase or not:
  IF NOT UPPER (x_biz_purch_hdr_rec.x_rqst_type) IN ('ACH_PURCH', 'CREDITCARD_PURCH') THEN
    out_code      :=                                   -1;
    out_status    := 'Invalid';
    out_error_msg := ('Error 102: Not an ACH or CC transaction.');
    CLOSE cur_bizpurchhdr_row;
    RETURN;
  END IF; */
  --CR50154 ST LTO - End
    -- Updating the settlement record - only for CC. In the case of ACH, NO UPDATION REQUIRED.
    IF in_pymt_source_type = 'ACH_PURCH' THEN
      NULL;
    --CR50154 ST LTO -Start - Storing Smartpay responses
    ELSIF in_pymt_source_type = 'ALTSOURCE_PURCH' THEN
      IF in_ics_rcode IN ('100') THEN
        l_status := 'SUCCESS';
      ELSE
        l_status := 'FAILED';
      END IF;

    UPDATE x_biz_purch_hdr
    SET x_auth_request_id = in_authid,
	  x_rqst_date         = SYSDATE,
	  x_ics_rcode         = in_ics_rcode,
	  x_ics_rflag         = in_ics_rflag,
	  x_ics_rmsg          = substr(in_ics_rmsg,1,255),
	  x_bill_request_time = in_bill_request_time,
      x_bill_rcode        = in_bill_rcode,
      x_bill_rflag        = in_bill_rflag,
      x_bill_rmsg         = in_bill_rmsg,
      x_bill_trans_ref_no = inout_bill_trans_ref_no,
	  x_status            = l_status,
	  x_bill_amount       = in_bill_amount,
	  x_request_id        = in_authid,
	  X_AUTH_RCODE        = in_auth_rcode,
      X_AUTH_RFLAG        = in_auth_rflag,
      X_AUTH_RMSG         = in_auth_rmsg,
      X_AUTH_AVS          = in_auth_avs,
      X_AUTH_RESPONSE     = in_auth_response,
      X_AUTH_TIME         = in_auth_time,
      X_AUTH_CODE         = in_auth_code
    WHERE objid           = in_objid;
  --CR50154 - ST LTO End - Storing Smartpay responses
  ELSE
    IF in_ics_rcode IN ('1', '100') THEN
      l_status := 'SUCCESS';
    ELSE
      l_status := 'FAILED';
    END IF;
    UPDATE x_biz_purch_hdr
    SET x_auth_request_id = in_authid,
      x_rqst_date         = SYSDATE,
      x_ics_rcode         = in_ics_rcode,
      x_ics_rflag         = in_ics_rflag,
      x_ics_rmsg          = in_ics_rmsg,
      x_bill_request_time = in_bill_request_time,
      x_bill_rcode        = in_bill_rcode,
      x_bill_rflag        = in_bill_rflag,
      x_bill_rmsg         = in_bill_rmsg,
      x_bill_trans_ref_no = inout_bill_trans_ref_no,
      x_status            = l_status,
      x_bill_amount       = in_bill_amount,
      x_request_id        = in_authid,
      X_AUTH_RCODE        = in_auth_rcode,
      X_AUTH_RFLAG        = in_auth_rflag,
      X_AUTH_RMSG         = in_auth_rmsg,
      X_AUTH_AVS          = in_auth_avs,
      X_AUTH_RESPONSE     = in_auth_response,
      X_AUTH_TIME         = in_auth_time,
      X_AUTH_CODE         = in_auth_code
    WHERE objid           = in_objid;
    --COMMIT;
     --CR26169 IVR Universal Purchase changes to check and calling stored procedure to load X_BIZ_ORDER_DTL table.
    BEGIN
        SELECT x_biz_order_dtl_flag
        INTO   l_biz_order_dtl_flag
        FROM   table_x_cc_parms prm
        WHERE  prm.x_merchant_id = x_biz_purch_hdr_rec.x_merchant_id;
    EXCEPTION
        WHEN OTHERS THEN
        NULL;
    END;

    IF in_ics_rcode IN ('1', '100') AND l_biz_order_dtl_flag = 'Y' THEN
    --
      IF in_authid IS NOT NULL THEN
         --Calling the sp_ivr_insert_order_info standalone stored procedure to load
        sp_ivr_insert_order_info(i_auth_request_id    =>  in_authid ,
                                  o_err_code          =>  l_err_code,
                                  o_err_msg           =>  l_err_msg
                                  );
        out_code      :=  l_err_code;
        out_error_msg :=  l_err_msg ;
    ELSE
      out_code      :=  -1;
      out_error_msg :=  'Authorization ID Cannot be NULL';
    END IF;
    --
    END IF;
  END IF;
  CLOSE cur_bizpurchhdr_row;
  --Passing the SUCCESS message
  out_code   := 0;
  out_status := 'Success';
EXCEPTION
WHEN OTHERS THEN
  out_code      := -1;
  out_error_msg := (SQLCODE || SQLERRM);
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION       => 'Update of settlement record',
                                   IP_KEY          => TO_CHAR (in_objid),
                                   IP_PROGRAM_NAME => ( out_status || 'SA.PAYMENT_SERVICES_PKG.update_settlmnt_rec'),
                                   IP_ERROR_TEXT   => out_error_msg);
END update_settlmnt_rec;
--------------------------------------------------------------------------------------------------------------------------
PROCEDURE get_expired_auth_dtls(in_authid           IN VARCHAR2,
                                out_hdr_rec         OUT purch_hdr_rec_full,
                                out_dtls_result_set OUT purch_dtl_tbl)
IS
  l_original_trans_dt DATE;
  cur_out_dtls_results SYS_REFCURSOR;
BEGIN
  SELECT MIN (x_rqst_date)
  INTO l_original_trans_dt
  FROM x_biz_purch_hdr
  WHERE x_auth_request_id = in_authid;
  -----
  BEGIN
    SELECT purch_hdr_rec_full (objid, x_rqst_source, channel, ecom_org_id, order_type, c_orderid, account_id, x_auth_request_id, groupidentifier, x_rqst_type, x_rqst_date, x_ics_applications, x_merchant_id, x_merchant_ref_number, x_offer_num, x_quantity, x_ignore_avs, x_avs, x_disable_avs, x_customer_hostname, x_customer_ipaddress, x_auth_code, x_ics_rcode, x_ics_rflag, x_ics_rmsg, x_request_id, x_auth_request_token, x_auth_avs, x_auth_response, x_auth_time, x_auth_rcode, x_auth_rflag, x_auth_rmsg, x_bill_request_time, x_bill_rcode, x_bill_rflag, x_bill_rmsg, x_bill_trans_ref_no, x_score_rcode, x_score_rflag, x_score_rmsg, x_customer_firstname, x_customer_lastname, x_customer_phone, x_customer_email, x_status, x_bill_address1, x_bill_address2, x_bill_city, x_bill_state, x_bill_zip, x_bill_country, x_ship_address1, x_ship_address2, x_ship_city, x_ship_state, x_ship_zip, x_ship_country, x_esn, x_amount, x_tax_amount, x_sales_tax_amount, x_e911_tax_amount, x_usf_taxamount,
      x_rcrf_tax_amount, x_add_tax1, x_add_tax2, discount_amount, freight_amount, x_auth_amount, x_bill_amount, x_user, purch_hdr2creditcard, purch_hdr2bank_acct, purch_hdr2other_funds, prog_hdr2x_pymt_src, prog_hdr2web_user, x_payment_type, x_process_date, x_promo_code)
    INTO out_hdr_rec
    FROM x_biz_purch_hdr
    WHERE x_auth_request_id = in_authid
    AND x_rqst_date         = l_original_trans_dt;
  EXCEPTION
  WHEN OTHERS THEN
    UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION        => 'Get details for the expired authid',
                                     IP_KEY           => TO_CHAR (in_authid),
                                     IP_PROGRAM_NAME  => ('SA.PAYMENT_SERVICES_PKG.get_expired_auth_dtls'),
                                     IP_ERROR_TEXT    => (SQLCODE || ':' || SQLERRM));
  END;
  --------
  OPEN cur_out_dtls_results FOR SELECT Purch_dtl_rec (x_esn, x_amount, line_number, part_number, x_quantity, domain, sales_rate, salestax_amount, e911_rate, x_e911_tax_amount, usf_rate, x_usf_taxamount, rcrf_rate, x_rcrf_tax_amount, total_tax_amount, total_amount, freight_amount, freight_method, freight_carrier, discount_amount, add_tax_1, add_tax_2) FROM x_biz_purch_dtl WHERE biz_purch_dtl2biz_purch_hdr = out_hdr_rec.in_objid;
  LOOP
    FETCH cur_out_dtls_results BULK COLLECT INTO out_dtls_result_set;
    EXIT
  WHEN cur_out_dtls_results%NOTFOUND;
  END LOOP;
  CLOSE cur_out_dtls_results;
EXCEPTION
WHEN OTHERS THEN
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION      => 'Get details for the expired authid',
                                   IP_KEY         => TO_CHAR (in_authid),
                                  IP_PROGRAM_NAME => ('SA.PAYMENT_SERVICES_PKG.get_expired_auth_dtls'),
                                  IP_ERROR_TEXT   => (SQLCODE || ':' || SQLERRM));
END get_expired_auth_dtls;
--
-- CR42257 changes starts..
PROCEDURE p_update_smp( i_biz_hdr_objid       IN    VARCHAR2,
                        i_pin                 IN    VARCHAR2,
                        i_smp                 IN    VARCHAR2,
                        o_error_code          OUT   VARCHAR2,
                        o_error_msg           OUT   VARCHAR2)IS
--
  l_smp               table_part_inst.part_serial_no%TYPE;
  l_pin               table_part_inst.x_red_code%TYPE;
  c                   sa.red_card_type := red_card_type();
  cp                  sa.red_card_type := red_card_type();
  cst                 sa.red_card_type := red_card_type();
--
BEGIN
  --
  IF  TRIM(i_biz_hdr_objid) IS NULL
  THEN
    o_error_code  :=  '400';
    o_error_msg   :=  'Biz Hdr objid cannot be null';
    RETURN;
  ELSIF TRIM(i_smp) IS NULL AND TRIM(i_pin) IS NULL
  THEN
    o_error_code  :=  '410';
    o_error_msg   :=  'Both smp and pin value cannot be null';
    RETURN;
  END IF;
  --
  IF i_smp IS NOT NULL AND i_pin IS NULL
  THEN
    l_smp :=  i_smp;
    l_pin :=  c.convert_smp_to_pin ( i_smp => i_smp );
  --
  ELSIF i_smp IS NULL AND i_pin IS NOT NULL
  THEN
    l_pin :=  i_pin;
    l_smp :=  c.convert_pin_to_smp ( i_red_card_code =>  i_pin);
    --
    IF  l_smp IS NULL
    THEN
      o_error_code  :=  '420';
      o_error_msg   :=  'SMP Not found for the PIN - '|| i_pin;
    END IF;
    --
  END IF;
  --
  --Get the part number using PIN
  cst  :=  cp.retrieve_pin ( i_red_card_code  =>  l_pin);
  --
  UPDATE  X_BIZ_PURCH_dtl
  SET     SMP                           = l_smp,
          PART_NUMBER                   = cst.pin_part_number
  WHERE   BIZ_PURCH_DTL2BIZ_PURCH_HDR   = i_biz_hdr_objid;
  --
  IF SQL%FOUND
  THEN
    o_error_code  :=  '0';
    o_error_msg   :=  'SUCCESS';
  ELSE
    o_error_code  :=  '430';
    o_error_msg   :=  'Invalid Biz hdr objid';
    RETURN;
  END IF;
  --
EXCEPTION
WHEN OTHERS
THEN
  o_error_code  :=  '490';
  o_error_msg   :=  'Failed in when others of p_update_smp';
END p_update_smp;
-- CR42257 changes ends
-- CR43524 changes starts..
-- New procedure to check whether score is required or not based on the Input params
-- and based on the aging of the request date
PROCEDURE p_check_score ( i_esn               IN    VARCHAR2,
                          i_payment_src_id    IN    VARCHAR2,
                          i_channel           IN    VARCHAR2,
                          i_brand             IN    VARCHAR2,
                          i_source            IN    VARCHAR2,
                          o_cc_scoring_reqd   OUT   VARCHAR2,
                          o_error_code        OUT   VARCHAR2,
                          o_error_msg         OUT   VARCHAR2) IS
--
  l_merchant_id       x_biz_purch_hdr.x_merchant_id%TYPE;
  l_ivr_score_days    NUMBER   := 180;
  c customer_type := customer_type();
--
BEGIN

  -- instantiate esn from purch detail or purch hdr
  c := customer_type ( i_esn => i_esn );

  -- get the sub brand of the esn
  c.sub_brand := c.get_sub_brand;

  -- convert the SIMPLE_MOBILE to GO_SMART when applicable
  c.bus_org_id := CASE WHEN c.sub_brand IS NOT NULL THEN c.sub_brand ELSE i_brand END;

  --
  BEGIN
    SELECT  x_merchant_id
    INTO    l_merchant_id
    FROM    table_x_cc_parms
    WHERE   x_bus_org = i_channel || ' ' || c.bus_org_id; -- previous: in_brand
  EXCEPTION
    WHEN OTHERS THEN
      l_merchant_id   :=  NULL;
      o_error_code    :=  '100';
      o_error_msg     :=  'Couldnt fetch Merchant ID ' || SUBSTR(SQLERRM,1,100);
      RETURN;
  END;
  --
  BEGIN
    SELECT TO_NUMBER(tp.X_PARAM_VALUE)
    INTO   l_ivr_score_days
    FROM   table_x_parameters tp
    WHERE  tp.X_PARAM_NAME      =  'IVR_SCORE_DAYS'
    AND    tp.objid             =  (SELECT MAX(tp1.objid)
                                    FROM  table_x_parameters tp1
                                    WHERE tp1.X_PARAM_NAME =  tp.X_PARAM_NAME);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  --
  -- Check score
  SELECT  DECODE (COUNT(*), 0, 'Y',  'N')
  INTO    o_cc_scoring_reqd
  FROM    x_biz_purch_hdr
  WHERE   X_ESN                                 = i_esn
  AND     PROG_HDR2X_PYMT_SRC                   = i_payment_src_id
  AND     CHANNEL                               = i_channel
  AND     X_RQST_SOURCE                         = i_source
  AND     NVL(x_merchant_id,'X')                = l_merchant_id
  AND     TRUNC(SYSDATE) - TRUNC(X_RQST_DATE)   < l_ivr_score_days;
  --
  o_error_code  :=  '0';
  o_error_msg   :=  'SUCCESS';
--
EXCEPTION
  WHEN OTHERS THEN
    o_error_code  :=  '99';
    o_error_msg   :=  'Failed in when others of p_check_score' || SUBSTR(SQLERRM,1,100);
END  p_check_score;
-- CR43525 changes ends

--CR47564 WFM changes --Start
--
--
FUNCTION get_customer_phone_number(i_payment_source_id NUMBER)
RETURN VARCHAR2
AS
  l_phone_number           VARCHAR2(20);
  l_creditcard_objid       NUMBER      ;
  l_bank_account_objid     NUMBER      ;
  l_alt_pymnt_src_objid    NUMBER      ;
  l_payment_type           VARCHAR2(20);
BEGIN
  --Retrieve CreditCard/Bank account/APS table objid
  BEGIN
    SELECT pymt_src2x_credit_card   ,
           pymt_src2x_bank_account  ,
           pymt_src2x_altpymtsource ,
	   x_pymt_type
    INTO   l_creditcard_objid       ,
           l_bank_account_objid     ,
           l_alt_pymnt_src_objid    ,
	   l_payment_type
    FROM   x_payment_source
    WHERE  objid = i_payment_source_id;
  EXCEPTION
    WHEN OTHERS THEN
    RETURN NULL;
  END;
  --Retrieve customer phone number based on payment type
  IF l_payment_type = 'CREDITCARD' THEN
        --Retrieve phone number from table_x_credit_card table
    BEGIN
      SELECT x_customer_phone
      INTO   l_phone_number
      FROM   table_x_credit_card
      WHERE  objid = l_creditcard_objid;
    EXCEPTION
      WHEN OTHERS THEN
      RETURN NULL;
    END;
  ELSIF l_payment_type = 'ACH' THEN
    --Retrieve phone number from table_x_bank_account table
    BEGIN
      SELECT x_customer_phone
      INTO   l_phone_number
      FROM   table_x_bank_account
      WHERE  objid = l_bank_account_objid;
    EXCEPTION
      WHEN OTHERS THEN
      RETURN NULL;
    END;
  ELSIF l_payment_type = 'APS' THEN
        --Updating the table_x_altpymtsource table with the input phone number
    BEGIN
      SELECT x_customer_phone
      INTO   l_phone_number
      FROM   table_x_altpymtsource
      WHERE  objid = l_alt_pymnt_src_objid;
    EXCEPTION
      WHEN OTHERS THEN
      RETURN NULL;
    END;
  END IF;
  RETURN l_phone_number;
EXCEPTION
  WHEN OTHERS THEN
  RETURN NULL;
END get_customer_phone_number;

--CR51037 --Start
--New procedure to update address information
PROCEDURE update_customer_address(i_payment_source_rec IN  sa.typ_pymt_src_dtls_rec ,
				  o_response           OUT VARCHAR2
				  )
IS
n_address_objid NUMBER;
n_country_objid NUMBER;

BEGIN --Main section

  -- exclude dummy address updates
  IF UPPER(i_payment_source_rec.address_info.address_1) LIKE '%1295%CHARLESTON%' AND
     UPPER(i_payment_source_rec.address_info.city) = 'MOUNTAIN VIEW'
  THEN
    o_response := 'SUCCESS';
    RETURN;
  END IF;

  IF  i_payment_source_rec.payment_type = 'CREDITCARD' THEN
     --Retrieve address objid associated with credit card
     BEGIN
         SELECT cc.x_credit_card2address
         INTO   n_address_objid
         FROM   table_x_credit_card cc,
                x_payment_source    ps
         WHERE  cc.objid = ps.pymt_src2x_credit_card
         AND    ps.objid = i_payment_source_rec.payment_source_id;
     EXCEPTION
         WHEN OTHERS THEN
              n_address_objid := NULL;
     END;

     ELSIF i_payment_source_rec.payment_type = 'ACH' THEN

     --Retrieve address objid associated with bank account
     BEGIN
         SELECT ba.x_bank_acct2address
         INTO   n_address_objid
         FROM   table_x_bank_account ba,
                x_payment_source     ps
         WHERE  ba.objid = ps.pymt_src2x_bank_account
         AND    ps.objid = i_payment_source_rec.payment_source_id;
     EXCEPTION
         WHEN OTHERS THEN
              n_address_objid := NULL;
     END;
  END IF;
    --Retrieve country objid for the given country and update table address
    IF i_payment_source_rec.address_info.country IS NOT NULL THEN
      BEGIN
        SELECT objid
        INTO   n_country_objid
        FROM   table_country
        WHERE  s_name = UPPER(i_payment_source_rec.address_info.country);
      EXCEPTION
        WHEN OTHERS THEN
          n_country_objid := NULL;
      END;
    END IF;

  --Updating table_address
  UPDATE table_address
  SET    address            = NVL(i_payment_source_rec.address_info.address_1, address)          ,
         s_address          = NVL(UPPER (i_payment_source_rec.address_info.address_1), s_address),
         city               = NVL(i_payment_source_rec.address_info.city, city)                  ,
         s_city             = NVL(UPPER (i_payment_source_rec.address_info.city), s_city)        ,
         state              = NVL(i_payment_source_rec.address_info.state, state)                ,
         s_state            = NVL(UPPER (i_payment_source_rec.address_info.state), s_state)      ,
         zipcode            = NVL(i_payment_source_rec.address_info.zipcode, zipcode)            ,
         address_2          = NVL(i_payment_source_rec.address_info.address_2, address)          ,
         address2country    = NVL(n_country_objid, address2country)                              ,
         update_stamp       = SYSDATE
  WHERE  objid              = n_address_objid;

  o_response := 'SUCCESS';

EXCEPTION
    WHEN OTHERS THEN
         o_response := 'update_customer_address: '||SQLCODE ||' '||SUBSTR (SQLERRM, 1, 300);
	 RETURN;
--
END update_customer_address;
--CR51037 --End

--New overloaded addpaymentsource procedure to payment source based on ESN/MIN
PROCEDURE addpaymentsource( p_esn               IN VARCHAR2 ,
                            p_bus_org           IN VARCHAR2 ,
                            p_esn_contact_objid IN NUMBER ,
                            p_rec               IN typ_pymt_src_dtls_rec,
                            op_pymt_src_id      OUT VARCHAR2 ,
                            op_err_num          OUT NUMBER ,
                            op_err_msg          OUT VARCHAR2 )IS
  --local variables
  l_pymt_src_name     VARCHAR2 (100);
  wu_objid            NUMBER;
  esn_wu_objid        NUMBER;
  l_cc_objid          NUMBER := 0;
  l_bo_objid          NUMBER;
  l_ps_objid          NUMBER;
  l_ba_objid          NUMBER := 0;
  l_aps_objid         NUMBER := 0;
  cont_objid          NUMBER;
  addr_objid          NUMBER;
  phone_no            NUMBER;
  v_count             INTEGER := 0;
  cst sa.customer_type:= sa.customer_type();
  o_response      VARCHAR2(500); --CR47992
BEGIN --Main section
  cst.esn             := p_esn ;
  cont_objid          := p_esn_contact_objid ;
  cst.bus_org_id      := p_bus_org ;
  l_bo_objid          := cst.get_bus_org_objid;
  --get Address
  IF NOT p_rec.address_info.write2db (addr_objid) THEN
    op_err_num := -1;
    op_err_msg := 'Address Creation Failed';
    RETURN;
  END IF;
  --
  IF p_rec.payment_type = 'CREDITCARD' THEN
    BEGIN
      SELECT cc.objid,
        NVL (ps.objid, -1)
      INTO l_cc_objid,
        l_ps_objid
      FROM x_payment_source ps,
        table_x_credit_card cc
      WHERE 1                          = 1
      AND ps.pymt_src2x_credit_card(+) = cc.objid
      AND ps.x_status                  = 'ACTIVE'
      AND cc.X_CUSTOMER_CC_NUMBER      = p_rec.cc_info.masked_card_number
      AND x_credit_card2bus_org        = l_bo_objid;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_cc_objid := -1;
      l_ps_objid := -1;
    WHEN TOO_MANY_ROWS THEN
      l_cc_objid := -2;
      l_ps_objid := -2;
    WHEN OTHERS THEN
      OP_ERR_NUM := SQLCODE;
      OP_ERR_MSG := SQLERRM;
      RETURN;
    END;
    l_pymt_src_name       := 'CREDITCARD';
  ELSIF p_rec.payment_type = 'APS' THEN
    BEGIN
      SELECT aps.objid,
        NVL (ps.objid, -1)
      INTO l_aps_objid,
        l_ps_objid
      FROM x_payment_source ps,
        table_x_altpymtsource aps
      WHERE 1                            = 1
      AND ps.pymt_src2x_altpymtsource(+) = aps.objid
      AND ps.x_status                    = 'ACTIVE'
      AND aps.x_alt_pymt_source          = p_rec.aps_info.Alt_Pymt_Source
      AND aps.x_alt_pymt_source_type     = p_rec.aps_info.Alt_Pymt_Source_Type
      AND aps.x_application_key          = p_rec.aps_info.Application_Key
      AND x_altpymtsource2bus_org        = l_bo_objid;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_aps_objid := -1;
      l_ps_objid  := -1;
    WHEN TOO_MANY_ROWS THEN
      l_aps_objid := -2;
      l_ps_objid  := -2;
    WHEN OTHERS THEN
      OP_ERR_NUM := SQLCODE;
      OP_ERR_MSG := SQLERRM;
      RETURN;
    END;
    l_pymt_src_name := 'Alternate Payment Source';
  ELSE
    BEGIN
      SELECT ba.objid,
        NVL (ps.objid, -1)
      INTO l_ba_objid,
        l_ps_objid
      FROM x_payment_source ps,
        TABLE_X_BANK_ACCOUNT ba
      WHERE 1                           = 1
      AND ps.pymt_src2x_bank_account(+) = ba.objid
      AND ps.x_status                   = 'ACTIVE'
      AND ba.x_customer_acct            = p_rec.ach_info.account_number
      AND ba.x_aba_transit              = p_rec.ach_info.account_type;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_ba_objid := -1;
      l_ps_objid := -1;
    WHEN TOO_MANY_ROWS THEN
      l_ba_objid := -2;
      l_ps_objid := -2;
    WHEN OTHERS THEN
      OP_ERR_NUM := SQLCODE;
      OP_ERR_MSG := SQLERRM;
      RETURN;
    END;
    l_pymt_src_name := 'ACH';
  END IF;
  --
  dbms_output.put_line('l_ps_objid  - l_cc_objid: '||l_ps_objid||' - '||l_cc_objid);
  IF (l_ps_objid   <> -1 AND (l_cc_objid <> -1 OR l_ba_objid <> -1 OR l_aps_objid <> -1)) THEN
    op_err_num     := -3;
    op_err_msg     := 'Payment Source Already Exist';
    op_pymt_src_id := l_ps_objid;
	   update_customer_address(i_payment_source_rec => p_rec,
                            o_response           => o_response); --CR47992
    dbms_output.put_line('In Else addr upadte : '||o_response);
    --CR53104 - ST_ Fix Straight Talk website Issue with phone purchase error message
    IF o_response != 'SUCCESS' THEN
      op_err_msg  := op_err_msg || ' | ' || o_response;
    END IF;

    RETURN;
  END IF;
  --
  IF l_cc_objid = -1 THEN
    --Invoking this procedure to insert record into credit card table
    sa.edit_creditcard_prc_pci (p_cc_objid => NULL,
                                p_customer_cc_number                => p_rec.cc_info.masked_card_number,
                                p_customer_cc_expmo                 => SUBSTR (p_rec.cc_info.exp_date, 1, INSTR (p_rec.cc_info.exp_date, '-', 1, 1) - 1),
                                p_customer_cc_expyr                 => SUBSTR (p_rec.cc_info.exp_date, INSTR (p_rec.cc_info.exp_date, '-', 1, 1) + 1),
                                p_cc_type                           => p_rec.cc_info.card_type,
                                p_customer_cc_cv_number             => NULL,
                                p_customer_firstname                => p_rec.first_name,
                                p_customer_lastname                 => p_rec.last_name,
                                p_customer_phone                    => phone_no,
                                p_customer_email                    => p_rec.email,
                                p_changedby                         => NULL,
                                p_credit_card2contact               => cont_objid,
                                p_card_status                       => p_rec.payment_status,
                                p_bus_org                           => p_bus_org,
                                p_customer_cc_enc_number            => p_rec.cc_info.cc_enc_number,
                                p_customer_key_enc_number           => p_rec.cc_info.key_enc_number,
                                p_customer_cc_enc_algorithm         => p_rec.cc_info.cc_enc_algorithm,
                                p_customer_key_enc_algorithm        => p_rec.cc_info.key_enc_algorithm,
                                p_customer_cc_enc_cert              => p_rec.cc_info.cc_enc_cert,
                                p_out_cc_objid                      => l_cc_objid,
                                p_errno                             =>op_err_num,
                                p_errstr                            => op_err_msg );
    IF op_err_num != 0 THEN
      RETURN;
    ELSE
      UPDATE table_x_credit_card
      SET x_credit_card2address = addr_objid
      WHERE objid               = l_cc_objid;
    END IF;
  END IF;
  IF l_ba_objid = -1 THEN
    --Inserting into bank account table for ACH payment source added
    insert_bank_account (p_rec            => p_rec ,
                         ip_contact_objid => cont_objid,
                         ip_addr_objid    => addr_objid,
                         ip_phone_no      => phone_no ,
                         ip_bo_objid      => l_bo_objid,
                         op_ba_objid      => l_ba_objid,
                         op_err_num       => op_err_num,
                         op_err_msg       => op_err_msg );
    --
    IF op_err_num != 0 THEN
      RETURN;
    END IF;
    --
  END IF;
  IF l_aps_objid = -1 THEN
    --To insert alternate payment source for the given payment source
    insert_alternate_paymentsource (p_rec              => p_rec ,
                                    ip_contact_objid   => cont_objid ,
                                    ip_addr_objid      => addr_objid ,
                                    ip_phone_no        => phone_no ,
                                    ip_bo_objid        => l_bo_objid ,
                                    op_aps_objid       => l_aps_objid,
                                    op_err_num         => op_err_num ,
                                    op_err_msg         => op_err_msg );
    IF op_err_num != 0 THEN
      RETURN;
    END IF;
    --
  END IF;
  IF l_ps_objid = -1 THEN
    --
    BEGIN
      SELECT seq_x_payment_source.NEXTVAL
        INTO l_ps_objid
      FROM DUAL;
      --Inserting record into x_payment_source table for the new payment source added
      INSERT
      INTO x_payment_source
        ( objid,
          x_pymt_type,
          x_pymt_src_name,
          x_status,
          x_is_default,
          x_insert_date,
          x_update_date,
          x_sourcesystem,
          x_changedby,
          pymt_src2web_user,
          pymt_src2x_credit_card,
          pymt_src2x_bank_account,
          x_billing_email,
          pymt_src2x_altpymtsource,
          pymt_src2contact
        )
        VALUES
        ( l_ps_objid,
          p_rec.payment_type,
          l_pymt_src_name,
          p_rec.payment_status,
          p_rec.is_default,
          SYSDATE,
          SYSDATE,
          NULL,
          NULL,
          NULL,
          l_cc_objid,
          l_ba_objid,
          p_rec.user_id,
          l_aps_objid,
          cont_objid
        );

        op_pymt_src_id := l_ps_objid;
    EXCEPTION
     WHEN OTHERS THEN
       op_err_num  := SQLCODE;
       op_err_msg  := 'Insert Payment Source Failed';
       RETURN;
    END;

    --CR53104 - ST_ Fix Straight Talk website Issue with phone purchase error message
--    IF op_err_num != 0 THEN
--      op_err_num  := op_err_num;
--      op_err_msg  := op_err_msg;
--      RETURN;
--    END IF;
    update_customer_address(i_payment_source_rec => p_rec,
                            o_response           => o_response);
    IF o_response != 'SUCCESS' THEN
      op_err_num  := -2;
      op_err_msg  := o_response;
      RETURN;
    END IF;
  END IF;
  op_err_num     := 0;
  op_err_msg     := 'Success';
EXCEPTION
WHEN OTHERS THEN
  OP_ERR_NUM := SQLCODE;
  OP_ERR_MSG := SUBSTR (SQLERRM, 1, 300);
  RETURN;
  --
END addpaymentsource;
--
PROCEDURE addpaymentsource( i_esn                       IN VARCHAR2 DEFAULT NULL ,
                            i_min                       IN VARCHAR2 DEFAULT NULL ,
                            i_login_name                IN VARCHAR2 DEFAULT NULL ,
                            i_bus_org                   IN VARCHAR2 ,
                            i_payment_source_detail_rec IN payment_source_detail_type ,
                            o_payment_source_id         OUT VARCHAR2 ,
                            o_err_num                   OUT NUMBER ,
                            o_err_msg                   OUT VARCHAR2 ) AS
  --Local variables
  l_pymt_src_name             VARCHAR2(100);
  l_esn_cnt                   NUMBER ;
  l_min_cnt                   NUMBER ;
  l_esn                       VARCHAR2(30) ;
  l_creditcard_objid          NUMBER ;
  l_bank_account_objid        NUMBER ;
  l_alt_pymnt_src_objid       NUMBER ;
  l_ps_cnt                    NUMBER ;
  l_web_user_cnt              NUMBER ;
  o_response                  VARCHAR2(500);
  --Declaring variable to access customer type
  cst sa.customer_type        := sa.customer_type();
  c sa.customer_type          := sa.customer_type();
  ret sa.customer_type        := sa.customer_type();
  cst_login sa.customer_type  := sa.customer_type();
  psd typ_pymt_src_dtls_rec   := sa.typ_pymt_src_dtls_rec();
BEGIN --Main Section
  cst.esn := i_esn;
  --Instantiate payment_source_detail_rec value in typ_pymt_src_dtls_rec type
  psd       := sa.typ_pymt_src_dtls_rec(i_payment_source_detail_rec => i_payment_source_detail_rec);
  IF (i_esn IS NULL AND i_min IS NULL AND i_login_name IS NULL) THEN
    --
    o_err_num := '1001';
    o_err_msg := 'ESN/MIN/Login name all cannot be null';
    RETURN;
    --
  END IF;

  --Validating whether brand input is null
  IF i_bus_org IS NULL THEN
    --
    o_err_num := '1009';
    o_err_msg := 'BRAND CANNOT BE NULL';
    RETURN;
    --
  END IF;

  cst.bus_org_id  := i_bus_org;
  c.bus_org_objid := cst.get_bus_org_objid;
  --To check whether the input bus org is NOT NULL and Valid.
  IF c.bus_org_objid IS NULL THEN
    --
    o_err_num := '1008';
    o_err_msg := 'INVALID BRAND: ' || i_bus_org;
    RETURN;
    --
  END IF;



  -- Condition to check whether input ESN/MIN IS NOT NULL
  IF (i_esn IS NOT NULL OR i_min IS NOT NULL) THEN
    --

    IF i_esn IS NULL AND i_min IS NOT NULL THEN
      cst.esn := cst.get_esn ( i_min => i_min );
      --
      IF cst.esn IS NULL THEN
        o_err_num := '1005';
        o_err_msg := 'MIN is not valid';
        RETURN;
      END IF;
    END IF;

    ret := cst.get_contact_add_info ( i_esn => cst.esn );

    IF ret.response NOT LIKE ('SUCCESS') THEN
      o_err_num := '1005';
      o_err_msg := ret.response;
      RETURN;
    END IF;

    --CR49696 changes start
    --Check if the input zip code is valid when the input country is US
    IF    psd.address_info.country IN ('US', 'USA')
      AND sa.customer_info.is_valid_zip_code (i_zip_code => psd.address_info.zipcode) = 'N'
    THEN
      o_err_num := '1010';
      o_err_msg := 'ZIP Code is not valid';
      RETURN;
    END IF;
    --CR49696 changes end

    --Invoking the existing addpaymentsource procedure by ESN/MIN
    payment_services_pkg.addpaymentsource(p_esn               => cst.esn ,
                                          p_bus_org           => cst.bus_org_id ,
                                          p_esn_contact_objid => ret.contact_objid ,
                                          p_rec               => psd ,
                                          op_pymt_src_id      => o_payment_source_id,
                                          op_err_num          => o_err_num ,
                                          op_err_msg          => o_err_msg );
    --CR53104 - Update address being handled in the main procedure addpaymentsource called above.
    --o_err_num being specifically set to 0 for SOA during WFM initial release
    IF o_err_num = -3 THEN
      --Update customer address
--      update_customer_address(i_payment_source_rec => psd       ,
--                              o_response           => o_response
--                             );
      o_err_num := 0;
      RETURN;
    END IF;

    IF o_err_num != 0 THEN
      RETURN;
    END IF;

  ELSIF i_login_name      IS NOT NULL THEN
    cst_login             := cst.retrieve_login (i_login_name => i_login_name,
                                                 i_bus_org_id => i_bus_org );
    IF cst_login.response <> 'SUCCESS' THEN
      --
      IF cst_login.response = 'LOGIN NAME NOT FOUND FOR PROVIDED BRAND' THEN
        o_err_num          := '1008';
        o_err_msg          := 'INVALID BRAND';
        RETURN;
      ELSE
        o_err_num := '1006';
        o_err_msg := cst_login.response;
        RETURN;
      END IF;
      --
    END IF;
    IF cst.esn IS NULL THEN
      --Retrieve ESN for the given login
      BEGIN
        SELECT pi.part_serial_no
        INTO l_esn
        FROM table_x_contact_part_inst cpi,
          table_part_inst pi
        WHERE cpi.x_contact_part_inst2contact = cst_login.web_contact_objid
        AND cpi.x_contact_part_inst2part_inst = pi.objid
        AND pi.x_domain                       = 'PHONES';
      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;
      --
    END IF;

    --CR49696 changes start
    --Check if the input zip code is valid when the input country is US
    IF    psd.address_info.country IN ('US', 'USA')
      AND sa.customer_info.is_valid_zip_code (i_zip_code => psd.address_info.zipcode) = 'N'
    THEN
      o_err_num := '1010';
      o_err_msg := 'ZIP Code is not valid';
      RETURN;
    END IF;
    --CR49696 changes end

    --Invoking the existing addpaymentsource procedure by web login name
    payment_services_pkg.addpaymentsource(p_login_name   => i_login_name ,
                                          p_bus_org      => cst.bus_org_id ,
                                          p_esn          => nvl(cst.esn,l_esn) ,
                                          p_rec          => psd ,
                                          op_pymt_src_id => o_payment_source_id,
                                          op_err_num     => o_err_num ,
                                          op_err_msg     => o_err_msg );
    --CR53104 - Update address being handled in the main procedure addpaymentsource called above.
    --o_err_num being specifically set to 0 for SOA during WFM initial release
    IF o_err_num = -3 THEN
      --Update customer address
--      update_customer_address(i_payment_source_rec => psd       ,
--                              o_response           => o_response
--                             );
     o_err_num := 0;
     RETURN;
    END IF;
    IF o_err_num != 0 THEN
      RETURN;
    END IF;
    --
  END IF; --This is the end if for ESN/MIN not null condition
  --Retrieve credit card /bank account/alternate payment source objid
  BEGIN
    --
    SELECT pymt_src2x_credit_card ,
      pymt_src2x_bank_account ,
      pymt_src2x_altpymtsource
    INTO l_creditcard_objid ,
      l_bank_account_objid ,
      l_alt_pymnt_src_objid
    FROM x_payment_source
    WHERE objid = o_payment_source_id;
    --
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
    --
  END;
  --Updating the x_payment_source table with payment source name
  BEGIN
    --
    UPDATE x_payment_source
    SET x_pymt_src_name = i_payment_source_detail_rec.payment_src_name
    WHERE objid         = o_payment_source_id;
    --
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  IF i_payment_source_detail_rec.payment_type = 'CREDITCARD' THEN
    --
    --Updating the table_x_credit_card table with the input phone number
    BEGIN
      --
      UPDATE table_x_credit_card
      SET x_customer_phone = i_payment_source_detail_rec.phone_number
      WHERE objid          = l_creditcard_objid;
      --
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
      --
    END;
    --
  ELSIF i_payment_source_detail_rec.payment_type = 'ACH' THEN
    --
    --Updating the table_x_bank_account table with the input phone number
    BEGIN
      --
      UPDATE table_x_bank_account
      SET x_customer_phone = i_payment_source_detail_rec.phone_number
      WHERE objid          = l_bank_account_objid;
      --
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
      --
    END;
    --
  ELSIF i_payment_source_detail_rec.payment_type = 'APS' THEN
    --
    --Updating the table_x_altpymtsource table with the input phone number
    BEGIN
      --
      UPDATE table_x_altpymtsource
      SET x_customer_phone = i_payment_source_detail_rec.phone_number
      WHERE objid          = l_alt_pymnt_src_objid;
      --
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
      --
    END;
    --
  END IF;
  --Return output parameter values
  o_err_num := 0 ;
  o_err_msg := 'Success' ;
EXCEPTION --Main exception section
  --
WHEN OTHERS THEN
  o_err_num := '1012';
  o_err_msg := SQLCODE||'-'||SUBSTR (SQLERRM, 1, 300);
  RETURN;
  --
END addpaymentsource;

PROCEDURE updatepaymentsource(i_login_name                IN VARCHAR2 DEFAULT NULL ,
                              i_bus_org_id                IN VARCHAR2 ,
                              i_esn                       IN VARCHAR2 DEFAULT NULL ,
                              i_min                       IN VARCHAR2 DEFAULT NULL ,
                              i_payment_source_detail_rec IN payment_source_detail_type ,
                              o_payment_source_id         OUT VARCHAR2 ,
                              o_err_num                   OUT NUMBER ,
                              o_err_msg                   OUT VARCHAR2 )
AS
  --Local variables
  l_pymt_src_name             VARCHAR2(100);
  l_esn_cnt                   NUMBER ;
  l_min_cnt                   NUMBER ;
  l_esn                       VARCHAR2(30) ;
  l_creditcard_objid          NUMBER ;
  l_bank_account_objid        NUMBER ;
  l_alt_pymnt_src_objid       NUMBER ;
  l_payment_source_type       VARCHAR2(30) ;
  l_payment_src_cnt           NUMBER ;
  l_web_user_cnt              NUMBER ;
  --Declaring variable to access customer type
  cst sa.customer_type        := sa.customer_type();
  c sa.customer_type          := sa.customer_type();
  cst_login sa.customer_type  := sa.customer_type();
  psd typ_pymt_src_dtls_rec   := sa.typ_pymt_src_dtls_rec();

BEGIN --Main Section
  IF (i_esn IS NULL AND i_min IS NULL AND i_login_name IS NULL) THEN
    --
    o_err_num := '1001';
    o_err_msg := 'ESN/MIN/Login name all cannot be null';
    RETURN;
    --
  END IF;
  cst.esn := i_esn;
  --Validating whether brand input is null
  IF i_bus_org_id IS NULL THEN
    --
    o_err_num := '1009';
    o_err_msg := 'BRAND CANNOT BE NULL';
    RETURN;
    --
  END IF;
  --Initialize customer type brand variables and validate
  cst.bus_org_id  := i_bus_org_id;
  c.bus_org_objid := cst.get_bus_org_objid;
  --To check whether the input bus org is NOT NULL and Valid.
  IF c.bus_org_objid IS NULL THEN
    --
    o_err_num := '1008';
    o_err_msg := 'INVALID BRAND: ' || i_bus_org_id;
    RETURN;
    --
  END IF;
  -- Condition to check whether input ESN/MIN IS NOT NULL
  IF (i_esn IS NOT NULL OR i_min IS NOT NULL) THEN
    --
    IF i_esn IS NULL AND i_min IS NOT NULL THEN
      cst.esn := cst.get_esn ( i_min => i_min );
      --
      IF cst.esn IS NULL THEN
        o_err_num := '1005';
        o_err_msg := 'MIN is not valid';
        RETURN;
      END IF;
    END IF;

    IF i_min IS NULL AND i_esn IS NOT NULL THEN
      cst.min := cst.get_min ( i_esn => i_esn );
      --
      IF cst.min IS NULL THEN
        o_err_num := '1006';
        o_err_msg := 'ESN is not valid';
        RETURN;
      END IF;
    END IF;
    --Retrieve the ESN web attributes
    cst             := cst.get_web_user_attributes;
    IF cst.response <> 'SUCCESS' THEN
      o_err_num     := '1003';
      o_err_msg     := cst.response;
      RETURN;
    END IF;
  ELSIF i_login_name IS NOT NULL THEN
    --Initialize customer type web login variables and brand validation
    cst_login             := cst.retrieve_login (i_login_name => i_login_name,
                                                 i_bus_org_id => i_bus_org_id );
    IF cst_login.response <> 'SUCCESS' THEN
      --
      IF cst_login.response = 'LOGIN NAME NOT FOUND FOR PROVIDED BRAND' THEN
        o_err_num          := '1008';
        o_err_msg          := 'INVALID BRAND';
        RETURN;
      ELSE
        o_err_num := '1006';
        o_err_msg := cst_login.response;
        RETURN;
      END IF;
      --
    END IF;
    --
  END IF; --This END IF condition for ESN/MIN or web login name check
  --Retrieve payment type
  IF i_payment_source_detail_rec.payment_source_id IS NOT NULL THEN
    --
    BEGIN
      SELECT COUNT(1)
      INTO l_payment_src_cnt
      FROM x_payment_source ps
      WHERE ps.objid = i_payment_source_detail_rec.payment_source_id;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
    --Valid Payment Source ID check
    IF l_payment_src_cnt <> 0 THEN
      --
      IF i_payment_source_detail_rec.payment_type IS NULL THEN
        --
        BEGIN
          SELECT ps.x_pymt_type
          INTO l_payment_source_type
          FROM x_payment_source ps
          WHERE ps.objid = i_payment_source_detail_rec.payment_source_id;
        EXCEPTION
        WHEN OTHERS THEN
          NULL;
        END;
      ELSE
        --
        l_payment_source_type := i_payment_source_detail_rec.payment_type;
        --
      END IF;
    ELSE
      o_err_num := '1017';
      o_err_msg := 'Payment Source ID not found';
      RETURN;
    END IF;
  ELSE
    o_err_num := '1016';
    o_err_msg := 'Payment Source ID cannot be NULL';
    RETURN;
  END IF;
  --Instantiate payment_source_detail_rec value in typ_pymt_src_dtls_rec type
  psd              := sa.typ_pymt_src_dtls_rec(i_payment_source_detail_rec => i_payment_source_detail_rec);
  psd.payment_type := l_payment_source_type;
  IF cst.esn       IS NULL THEN
    --
    --Retrieve ESN for the given login
    BEGIN
      SELECT pi.part_serial_no
      INTO cst.esn
      FROM table_x_contact_part_inst cpi,
        table_part_inst pi
      WHERE cpi.x_contact_part_inst2contact = cst_login.web_contact_objid
      AND cpi.x_contact_part_inst2part_inst = pi.objid
      AND pi.x_domain                       = 'PHONES';
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
    --
  END IF;
  cst.web_login_name := NVL(cst.web_login_name,cst_login.web_login_name);

    --CR49696 changes start
    --Check if the input zip code is valid when the input country is US
    IF    psd.address_info.country IN ('US', 'USA')
      AND sa.customer_info.is_valid_zip_code (i_zip_code => psd.address_info.zipcode) = 'N'
    THEN
      o_err_num := '1010';
      o_err_msg := 'ZIP Code is not valid';
      RETURN;
    END IF;
    --CR49696 changes end

  --Invoking the existing updatepaymentsource procedure
  payment_services_pkg.updatepaymentsource(p_login_name   => cst.web_login_name ,
                                           p_bus_org_id   => cst.bus_org_id ,
                                           p_esn          => cst.esn ,
                                           p_rec          => psd ,
                                           op_pymt_src_id => o_payment_source_id,
                                           op_err_num     => o_err_num ,
                                           op_err_msg     => o_err_msg );
  IF o_err_num != 0 THEN
    RETURN;
  END IF;
  --Updating phone number for the given ESN/MIN/Login name
  BEGIN
    UPDATE table_contact
    SET phone   = i_payment_source_detail_rec.phone_number
    WHERE objid = cst.web_contact_objid;
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  --Retrieve CreditCard/Bank account/APS table objid
  BEGIN
    --
    SELECT pymt_src2x_credit_card ,
      pymt_src2x_bank_account ,
      pymt_src2x_altpymtsource
    INTO l_creditcard_objid ,
      l_bank_account_objid ,
      l_alt_pymnt_src_objid
    FROM x_payment_source
    WHERE objid = o_payment_source_id;
    --
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
    --
  END;
  --Updating the x_payment_source table with payment source name
  BEGIN
    --
    UPDATE x_payment_source
    SET x_pymt_src_name = i_payment_source_detail_rec.payment_src_name
    WHERE objid         = o_payment_source_id;
    --
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END;
  IF l_payment_source_type = 'CREDITCARD' THEN
    --
    --Updating the table_x_credit_card table with the input phone number
    BEGIN
      --
      UPDATE table_x_credit_card
      SET x_customer_phone = i_payment_source_detail_rec.phone_number
      WHERE objid          = l_creditcard_objid;
      --
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
      --
    END;
    --
  ELSIF l_payment_source_type = 'ACH' THEN
    --
    --Updating the table_x_bank_account table with the input phone number
    BEGIN
      --
      UPDATE table_x_bank_account
      SET x_customer_phone = i_payment_source_detail_rec.phone_number
      WHERE objid          = l_bank_account_objid;
      --
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
      --
    END;
    --
  ELSIF l_payment_source_type = 'APS' THEN
    --
    --Updating the table_x_altpymtsource table with the input phone number
    BEGIN
      --
      UPDATE table_x_altpymtsource
      SET x_customer_phone = i_payment_source_detail_rec.phone_number
      WHERE objid          = l_alt_pymnt_src_objid;
      --
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
      --
    END;
    --
  END IF;
  --Return output parameter values
  o_err_num := 0 ;
  o_err_msg := 'Success' ;
EXCEPTION --Main exception section
  --
WHEN OTHERS THEN
  o_err_num := '1024';
  o_err_msg := SQLCODE||'-'||SUBSTR (SQLERRM, 1, 300);
  RETURN;
END updatepaymentsource;

PROCEDURE Getpaymentsource(i_login_name                    IN VARCHAR2 DEFAULT NULL ,
                           i_bus_org_id                    IN VARCHAR2 ,
                           i_esn                           IN VARCHAR2 DEFAULT NULL ,
                           i_min                           IN VARCHAR2 DEFAULT NULL ,
                           o_payment_source_detail_tbl     OUT payment_source_detail_tab,
                           o_err_num                       OUT NUMBER ,
                           o_err_msg                       OUT VARCHAR2 )
AS
  --Local variables
  l_pymt_src_name                 VARCHAR2(100);
  l_esn_cnt                       NUMBER ;
  l_min_cnt                       NUMBER ;
  l_bo_objid                      NUMBER ;
  l_esn                           VARCHAR2(30) ;
  l_web_user_cnt                  NUMBER ;
  l_phone_number                  VARCHAR2(20);
  --Declaring variable to access type objects
  cst sa.customer_type            := sa.customer_type() ;
  c sa.customer_type              := sa.customer_type() ;
  cst_login sa.customer_type      := sa.customer_type() ;
  psd typ_pymt_src_dtls_rec       := sa.typ_pymt_src_dtls_rec() ;
  psdt payment_source_detail_type := payment_source_detail_type() ;
  TYPE psd_typ
  IS
    TABLE OF x_payment_source%ROWTYPE INDEX BY PLS_INTEGER;
  psd_tab psd_typ;
BEGIN -- Main Section
  cst.esn := i_esn;
  --Instantiate
  o_payment_source_detail_tbl := sa.payment_source_detail_tab();
  IF (i_esn                   IS NULL AND i_min IS NULL AND i_login_name IS NULL) THEN
    --
    o_err_num := '1001';
    o_err_msg := 'ESN/MIN/Login name all cannot be null';
    RETURN;
    --
  END IF;
  IF i_bus_org_id IS NULL THEN
    --
    o_err_num := '1009';
    o_err_msg := 'BRAND CANNOT BE NULL';
    RETURN;
    --
  END IF;
  -- Initialize customer type brand variables and validation
  cst.bus_org_id  := i_bus_org_id;
  c.bus_org_objid := cst.get_bus_org_objid;
  --To check whether the input bus org is NOT NULL and Valid.
  IF c.bus_org_objid IS NULL THEN
    --
    o_err_num := '1008';
    o_err_msg := 'INVALID BRAND: ' || i_bus_org_id;
    RETURN;
    --
  END IF;
  -- Condition to check whether input ESN/MIN IS NOT NULL
  IF (i_esn IS NOT NULL OR i_min IS NOT NULL) THEN

    IF i_esn IS NULL AND i_min IS NOT NULL THEN
      cst.esn := cst.get_esn ( i_min => i_min );
      --
      IF cst.esn IS NULL THEN
        o_err_num := '1005';
        o_err_msg := 'MIN is not valid';
        RETURN;
      END IF;
    END IF;

    IF i_min IS NULL AND i_esn IS NOT NULL THEN
      cst.min := cst.get_min ( i_esn => i_esn );
      --
      IF cst.min IS NULL THEN
        o_err_num := '1006';
        o_err_msg := 'ESN is not valid';
        RETURN;
      END IF;
    END IF;
    --Retrieve the ESN web attributes
    cst             := cst.get_web_user_attributes;
    IF cst.response <> 'SUCCESS' THEN
      o_err_num     := '1003';
      o_err_msg     := cst.response;
      RETURN;
    END IF;
  ELSIF i_login_name IS NOT NULL THEN
    --
    cst_login             := cst.retrieve_login ( i_login_name => i_login_name,
                                                  i_bus_org_id => i_bus_org_id);
    IF cst_login.response <> 'SUCCESS' THEN
      --
      IF cst_login.response = 'LOGIN NAME NOT FOUND FOR PROVIDED BRAND' THEN
        o_err_num          := '1008';
        o_err_msg          := 'INVALID BRAND';
        RETURN;
      ELSE
        o_err_num := '1006';
        o_err_msg := cst_login.response;
        RETURN;
      END IF;
      --
    END IF;
    --
  END IF;
  cst.web_login_name := NVL(cst.web_login_name,cst_login.web_login_name);
  -- Retrieve set of payment sources for given login name
  SELECT ps.* BULK COLLECT
  INTO psd_tab
  FROM x_payment_source ps,
    table_web_user wu
  WHERE wu.s_login_name    = UPPER(cst.web_login_name)
  AND ps.pymt_src2web_user = wu.objid
  AND wu.web_user2bus_org = c.bus_org_objid --CR49696 Condition included to retrieve only brand specific payment sources
  AND UPPER(ps.x_status)   = 'ACTIVE';
  --Return if there is no payment source available for given login name

 -- CR49696 wfm Changes
  IF  psd_tab IS NULL THEN
    o_err_num     := '1013';
    o_err_msg     := 'No payment sources available';
    RETURN;
  END IF;

  IF psd_tab.COUNT = 0  THEN
    o_err_num     := '1013';
    o_err_msg     := 'No payment sources available';
    RETURN;
  END IF;

  FOR i IN 1 ..psd_tab.COUNT
  LOOP
    payment_services_pkg.getpaymentsourcedetails ( p_pymt_src_id => psd_tab(i).objid ,
                                                   out_rec       => psd ,
                                                   out_err_num   => o_err_num ,
                                                   out_err_msg   => o_err_msg );
    IF o_err_num != 0 THEN
      RETURN;
    END IF;
    psdt := sa.payment_source_detail_type
              (
              psd.payment_source_id                           ,
              psd.payment_type                                ,
              psd.payment_status                              ,
              psd_tab(i).x_pymt_src_name                      ,
              psd.is_default                                  ,
              psd.user_id               					            ,
              psd.first_name            					            ,
              psd.last_name             					            ,
              psd.email                 					            ,
              get_customer_phone_number(psd.payment_source_id),
              psd.secure_date                                 ,
              sa.address_type_rec
               (
                psd.address_info.address_1 					          ,
                psd.address_info.address_2 					          ,
                psd.address_info.city      					          ,
                psd.address_info.state     					          ,
                psd.address_info.country   					          ,
                psd.address_info.zipcode
                ),
              sa.typ_creditcard_info
               (
			          psd.cc_info.masked_card_number                ,
                psd.cc_info.card_type         				        ,
                psd.cc_info.exp_date          				        ,
                psd.cc_info.security_code     				        ,
                psd.cc_info.cvv               				        ,
                psd.cc_info.cc_enc_number     				        ,
                psd.cc_info.key_enc_number    				        ,
                psd.cc_info.cc_enc_algorithm  				        ,
                psd.cc_info.key_enc_algorithm 				        ,
                psd.cc_info.cc_enc_cert
                ),
              sa.typ_ach_info
               (
      			    psd.ach_info.routing_number                   ,
                psd.ach_info.account_number    				        ,
                psd.ach_info.account_type      				        ,
                psd.ach_info.customer_acct_key 				        ,
                psd.ach_info.customer_acct_enc 				        ,
                psd.ach_info.cert              				        ,
                psd.ach_info.key_algo          				        ,
                psd.ach_info.cc_algo
                ),
              sa.typ_aps_info
               (
			          psd.aps_info.alt_pymt_source                  ,
                psd.aps_info.alt_pymt_source_type 			      ,
                psd.aps_info.application_key
                )
              );

    -- Extend the collection variable
    o_payment_source_detail_tbl.EXTEND;
    o_payment_source_detail_tbl ( o_payment_source_detail_tbl.LAST ) := psdt;
    --
  END LOOP;
  -- Return output parameter values
  o_err_num := 0 ;
  o_err_msg := 'Success' ;
EXCEPTION --Main exception section
WHEN OTHERS THEN
  o_err_num := '1012';
  o_err_msg := SQLCODE||'-'||SUBSTR (SQLERRM, 1, 300);
  RETURN;
END getpaymentsource;

PROCEDURE getpaymentsourcehistory(io_payment_source_tbl IN OUT payment_source_detail_tab,
                                  o_err_num             OUT NUMBER ,
                                  o_err_msg             OUT VARCHAR2 )AS
  --Local variables
  psd_rec typ_pymt_src_dtls_rec     := sa.typ_pymt_src_dtls_rec();
  psd_tbl payment_source_detail_tab := sa.payment_source_detail_tab();
  psd payment_source_detail_type    := payment_source_detail_type();
  l_ps_name VARCHAR2(30);
BEGIN --Main Section
  --Condition to check whether the input table type parameter has any records

   -- CR49696 wfm Changes
   IF  io_payment_source_tbl IS NULL THEN
    o_err_num                   := '1001';
    o_err_msg                   := 'NO RECORDS EXISTS IN THE GIVEN INPUT PARAMETER';
     RETURN;
  END IF;

   IF io_payment_source_tbl.COUNT = 0 THEN
    o_err_num                   := '1001';
    o_err_msg                   := 'NO RECORDS EXISTS IN THE GIVEN INPUT PARAMETER';
     RETURN;
  END IF;
  -- To check and remove duplicate payment source ID's passed from SOA.
  SELECT sa.payment_source_detail_type(payment_source_id ,--payment source id
    NULL ,                                                --payment_type
    payment_status,                                       --payment_status    --CR57737_artSOA_Fetching_inactive_CC_at_the_time_of_Auto_Refill_payment_for_SM_WFM end
    NULL ,                                                --payment_src_name
    NULL ,                                                --is_default
    NULL ,                                                --user_id
    NULL ,                                                --first_name
    NULL ,                                                --last_name
    NULL ,                                                --email
    NULL ,                                                --phone_number
    NULL ,                                                --secure_date
    NULL ,                                                --address_info
    NULL ,                                                --cc_info
    NULL ,                                                --ach_info
    NULL                                                  --aps_info
    ) BULK COLLECT
  INTO psd_tbl
  FROM
    (SELECT DISTINCT payment_source_id,
                     payment_status
    FROM TABLE(CAST(io_payment_source_tbl AS payment_source_detail_tab))
    );
  -- reset output table
  io_payment_source_tbl := sa.payment_source_detail_tab();
  -- Loop through the input io_payment_source_tbl table type parameter
  FOR i IN 1 ..psd_tbl.COUNT
  LOOP
    --Invoking the getpaymentsourcedetails procedure
    --CR 52703 changed below call to invoke the new proc getpaymentsourcedetails_hist to retrieve Active/Inactive
    payment_services_pkg.getpaymentsourcedetails_hist(p_pymt_src_id  => psd_tbl(i).payment_source_id,
                                                      out_rec        => psd_rec ,
                                                      out_err_num    => o_err_num,
                                                      out_err_msg    => o_err_msg,
                                                      i_payment_source_status => psd_tbl(i).payment_status);
    IF o_err_num != 0 THEN
      RETURN;
    END IF;
    --Retrieve payment source name for the given payment source id
    BEGIN
      SELECT ps.x_pymt_src_name
      INTO l_ps_name
      FROM x_payment_source ps
      WHERE ps.objid = psd_tbl(i).payment_source_id;
    EXCEPTION
    WHEN OTHERS THEN
      NULL;
    END;
    --Returning the set of payment source associated with the given ESN/MIN/Account
    psd := sa.payment_source_detail_type(psd_rec.payment_source_id , psd_rec.payment_type , psd_rec.payment_status , l_ps_name , psd_rec.is_default , psd_rec.user_id , psd_rec.first_name , psd_rec.last_name , psd_rec.email , get_customer_phone_number(psd_tbl(i).payment_source_id) , psd_rec.secure_date , sa.Address_type_rec(psd_rec.address_info.address_1 , psd_rec.address_info.address_2 , psd_rec.address_info.city , psd_rec.address_info.state , psd_rec.address_info.country , psd_rec.address_info.zipcode ) ,
    (
      CASE
      WHEN psd_rec.payment_type = 'CREDITCARD' THEN
        sa.typ_creditcard_info(psd_rec.cc_info.masked_card_number, psd_rec.cc_info.card_type , psd_rec.cc_info.exp_date , psd_rec.cc_info.security_code , psd_rec.cc_info.cvv , psd_rec.cc_info.cc_enc_number , psd_rec.cc_info.key_enc_number , psd_rec.cc_info.cc_enc_algorithm , psd_rec.cc_info.key_enc_algorithm , psd_rec.cc_info.cc_enc_cert )
      END) ,
    (
      CASE
      WHEN psd_rec.payment_type = 'ACH' THEN
        sa.typ_ach_info(psd_rec.ach_info.routing_number , psd_rec.ach_info.account_number , psd_rec.ach_info.account_type , psd_rec.ach_info.customer_acct_key , psd_rec.ach_info.customer_acct_enc , psd_rec.ach_info.cert , psd_rec.ach_info.key_algo , psd_rec.ach_info.cc_algo )
      END ) ,
    (
      CASE
      WHEN psd_rec.payment_type = 'APS' THEN
        sa.typ_aps_info(psd_rec.aps_info.alt_pymt_source , psd_rec.aps_info.alt_pymt_source_type , psd_rec.aps_info.application_key )
      END) );
    -- Extending the io_payment_source_tbl table type variable
    io_payment_source_tbl.extend;
    io_payment_source_tbl(io_payment_source_tbl.LAST) := psd;
    --
  END LOOP;
  o_err_num := 0;
  o_err_msg := 'SUCCESS';
EXCEPTION --Main exception section
WHEN OTHERS THEN
  o_err_num := '1003';
  o_err_msg := SQLCODE||'-'||SUBSTR (SQLERRM, 1, 300);
  RETURN;
  --
END getpaymentsourcehistory;

--CR47564 WFM changes --End

--CR 52703 changes starts here
-- CR57737_artSOA_Fetching_inactive_CC_at_the_time_of_Auto_Refill_payment_for_SM_WFM end
PROCEDURE getpaymentsourcedetails_hist ( p_pymt_src_id              IN  NUMBER                ,
                                         out_rec                    OUT typ_pymt_src_dtls_rec ,
                                         out_err_num                OUT NUMBER                ,
                                         out_err_msg                OUT VARCHAR2              ,
                                         i_payment_source_status    IN  VARCHAR2 DEFAULT NULL )
IS
  n_payment_source_id     NUMBER;
  c_payment_type          VARCHAR2 (80);
BEGIN
  -- validate passed payment source id
  IF p_pymt_src_id IS NULL
  THEN
    out_err_num    := 702; ------'payment source id required'
    out_err_msg    := sa.get_code_fun ('SA.PAYMENT_SERVICES_PKG', out_err_num, 'ENGLISH');
    RETURN;
  END IF;

  -- get the payment source id
  BEGIN
    SELECT objid,
           x_pymt_type
    INTO   n_payment_source_id,
           c_payment_type
    FROM   x_payment_source
    WHERE  objid = p_pymt_src_id;
  EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
    out_err_num := 702; -- asim change this eg 703 so that the call below will get "pymnt_src_id not found"
    out_err_msg := sa.get_code_fun ('SA.PAYMENT_SERVICES_PKG', out_err_num, 'ENGLISH');
    RETURN;
  WHEN OTHERS
  THEN
    out_err_num := 702; -- asim same as above
    out_err_msg := sa.get_code_fun ('SA.PAYMENT_SERVICES_PKG', out_err_num, 'ENGLISH');
    RETURN;
  END;

  -- get the details for the credit card information
  IF c_payment_type = 'CREDITCARD'
  THEN
    BEGIN
      SELECT typ_pymt_src_dtls_rec ( ps.objid                ,
                                     ps.x_pymt_type          ,
                                     ps.x_status             ,
                                     ps.x_is_default         ,
                                     ps.x_billing_email      ,
                                     typ_creditcard_info ( cc.x_customer_cc_number                                    ,
                                                           cc.x_cc_type                                               ,
                                                           ( cc.x_customer_cc_expmo || '-' || cc.x_customer_cc_expyr ),
                                                           NULL                                                       ,
                                                           NULL                                                       ,
                                                           cc.x_cust_cc_num_enc                                       ,
                                                           cc.x_cust_cc_num_key                                       ,
                                                           cert.x_cc_algo                                             ,
                                                           cert.x_key_algo                                            ,
                                                           cert.x_cert                                                ) ,
                                     cc.x_customer_firstname ,
                                     cc.x_customer_lastname  ,
                                     cc.x_customer_email     ,
                                     address_type_rec ( a.address   ,
                                                        a.address_2 ,
                                                        a.city      ,
                                                        a.state     ,
                                                        c.s_name    ,
                                                        a.zipcode   ) ,
                                     cc.x_cust_cc_num_key    ,
                                     NULL                    ,
                                     NULL                    )
      INTO   out_rec
      FROM   table_x_credit_card cc,
             x_cert cert,
             x_payment_source ps,
             table_address a,
             sa.table_country c
      WHERE  1 = 1
      AND    ps.objid                    = n_payment_source_id
      -- CR Added condition to filter by status (ACTIVE) only when the status is passed as an input
      AND    ( ( ps.x_status = i_payment_source_status AND
                 i_payment_source_status IS NOT NULL
               )
               OR
               ( i_payment_source_status IS NULL )
             )
      AND    ps.pymt_src2x_credit_card = cc.objid
      AND    cc.x_credit_card2address    = a.objid(+)
      AND    a.address2country           = c.objid(+)
      AND    cc.creditcard2cert          = cert.objid;
    EXCEPTION
    WHEN OTHERS THEN
      out_err_num := 702;
      out_err_msg := 'Missing details'; --SA.GET_CODE_FUN('SA.PAYMENT_SERVICES_PKG', out_err_num, 'ENGLISH');
    END;
  -- get the details for the alternate payment source
  ELSIF c_payment_type = 'APS' THEN ---Added for Smartpay integration on 07/15/2015
    BEGIN
      SELECT typ_pymt_src_dtls_rec ( ps.objid,
                                     ps.x_pymt_type,
                                     ps.x_status,
                                     ps.x_is_default,
                                     ps.x_billing_email,
                                     NULL,
                                     aps.x_customer_firstname,
                                     aps.x_customer_lastname,
                                     aps.x_customer_email,
                                     address_type_rec ( a.address  ,
                                                        a.address_2,
                                                        a.city     ,
                                                        a.state    ,
                                                        c.s_name   ,
                                                        a.zipcode  ),
                                     NULL,
                                     NULL,
                                     typ_aps_info ( aps.x_alt_pymt_source     ,
                                                    aps.x_alt_pymt_source_type,
                                                    aps.x_application_key     )
                                   )
      INTO   out_rec
      FROM   table_x_altpymtsource aps,
             x_payment_source ps,
             table_address a,
             sa.table_country c
      WHERE  1 = 1
      AND    ps.objid                      = n_payment_source_id
      -- CR Added condition to filter by status (ACTIVE) only when the status is passed as an input
      AND    ( ( ps.x_status = i_payment_source_status AND
                 i_payment_source_status IS NOT NULL
               )
               OR
               ( i_payment_source_status IS NULL )
             )
      AND    ps.pymt_src2x_altpymtsource = aps.objid
      AND    aps.x_altpymtsource2address   = a.objid(+)
      AND    a.address2country             = c.objid(+);
    EXCEPTION
    WHEN OTHERS
    THEN
      out_err_num := 702;
      out_err_msg := 'Missing details';
    END;

  -- get the ach details from the bank account
  ELSE
    --
    BEGIN
      SELECT typ_pymt_src_dtls_rec ( ps.objid               ,
                                     ps.x_pymt_type         ,
                                     ps.x_status            ,
                                     ps.x_is_default        ,
                                     ps.x_billing_email     ,
                                     NULL                   ,
                                     ba.x_customer_firstname,
                                     ba.x_customer_lastname ,
                                     ba.x_customer_email    ,
                                     address_type_rec ( a.address   ,
                                                        a.address_2 ,
                                                        a.city      ,
                                                        a.state     ,
                                                        c.s_name    ,
                                                        a.zipcode   ),
                                     NULL,
                                     typ_ach_info ( ba.x_routing           ,
                                                    ba.x_customer_acct     ,
                                                    ba.x_aba_transit       ,
                                                    ba.x_customer_acct_key ,
                                                    ba.x_customer_acct_enc ,
                                                    cert.x_cert            ,
                                                    cert.x_key_algo        ,
                                                    cert.x_cc_algo         ),
                                     NULL )
      INTO   out_rec
      FROM   table_x_bank_account ba,
             x_payment_source ps,
             table_address a,
             x_cert cert,
             sa.table_country c
      WHERE  1 = 1
      AND    ps.objid                     = n_payment_source_id
      -- CR Added condition to filter by status (ACTIVE) only when the status is passed as an input
      AND    ( ( ps.x_status = i_payment_source_status AND
                 i_payment_source_status IS NOT NULL
               )
               OR
               ( i_payment_source_status IS NULL )
             )
      AND    ps.pymt_src2x_bank_account = ba.objid
      AND    ba.x_bank_acct2address     = a.objid(+)
      AND    a.address2country          = c.objid(+)
      AND    ba.bank2cert               = cert.objid;
    EXCEPTION
    WHEN OTHERS THEN
      out_err_num := 702;
      out_err_msg := 'Missing details';
    END;

  END IF;
  --
  out_err_num := 0;
  out_err_msg := 'Success';
  --
EXCEPTION
WHEN OTHERS THEN
  out_err_num := SQLCODE;
  out_err_msg := SUBSTR (SQLERRM, 1, 300);
  UTIL_PKG.INSERT_ERROR_TAB_PROC ( IP_ACTION => NULL, IP_KEY => TO_CHAR (P_PYMT_SRC_ID), IP_PROGRAM_NAME => 'PAYMENT_SERVICES_PKG.GETPAYMENTSOURCEDETAILS', iP_ERROR_TEXT => out_err_msg);
END getpaymentsourcedetails_hist;
-- CR57737_artSOA_Fetching_inactive_CC_at_the_time_of_Auto_Refill_payment_for_SM_WFM end
--CR 52703 changes ends here

--CR51907 WARP Auto pay --Start
PROCEDURE upsert_payment_details_staging(io_payment_detail_id IN OUT  VARCHAR2,
                                         i_payment_details   IN  XMLTYPE ,
                                         o_response          OUT VARCHAR2
					)
AS
BEGIN --Main Section

  IF io_payment_detail_id IS NULL THEN
     o_response := 'Payment detail ID cannot be NULL';
     RETURN;
  END IF;

  IF i_payment_details IS NULL THEN
     o_response := 'Payment details cannot be NULL';
     RETURN;
  END IF;


 --Inserting record into x_payment_detail_staging
   MERGE
   INTO  sa.x_payment_detail_staging pds
   USING DUAL
   ON   (pds.id = io_payment_detail_id)
   WHEN MATCHED THEN
   UPDATE
   SET pds.payment_details = i_payment_details
   WHEN NOT MATCHED THEN
   INSERT
   (id             ,
    payment_details
    )
   VALUES
   (io_payment_detail_id,
    i_payment_details
   );

   o_response := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
  o_response := 'ERROR WHILE INSERTING or UPDATING PAYMENT DETAILS: '||SQLERRM;

END upsert_payment_details_staging;
--
PROCEDURE delete_payment_details_staging(i_payment_detail_id IN  VARCHAR2,
                                         o_response          OUT VARCHAR2
                                        )
AS
n_payment_detail_cnt NUMBER;

BEGIN --Main Section

  IF i_payment_detail_id IS NULL THEN
     o_response := 'Payment detail ID cannot be NULL';
     RETURN;
  END IF;

  --
  DELETE sa.x_payment_detail_staging
  WHERE  id = i_payment_detail_id;

  IF SQL%ROWCOUNT = 0 THEN
     o_response := 'No record exists for given payment detail id';
     RETURN;
  END IF;
  --
    o_response := 'SUCCESS';
EXCEPTION
  WHEN OTHERS THEN
    o_response := 'ERROR DELETING PAYMENT DETAILS: '||SQLERRM;

END delete_payment_details_staging;
--
PROCEDURE get_payment_details_staging(i_payment_detail_id IN  VARCHAR2,
                                      o_payment_details   OUT XMLTYPE ,
                                      o_response          OUT VARCHAR2
                                     )
AS
BEGIN --Main Section

  IF i_payment_detail_id IS NULL THEN
     o_response := 'Payment detail ID cannot be NULL';
     RETURN;
  END IF;

  BEGIN
    SELECT pds.payment_details
    INTO   o_payment_details
    FROM   x_payment_detail_staging pds
    WHERE  pds.id = i_payment_detail_id;
  EXCEPTION
    WHEN OTHERS THEN
         o_response := SQLCODE||'-'||SQLERRM;
  END;
  --
  o_response := 'SUCCESS';

EXCEPTION
  WHEN OTHERS THEN
    o_response := 'ERROR WHILE RETRIEVING PAYMENT DETAILS: '||SQLERRM;

END get_payment_details_staging;

--CR51907 WARP Auto pay --End
-- CR49058 Adding get_paymentsrc_by_vass_id proc to fetch the payment source details with Vas ID
PROCEDURE getpaymentsourcedetails_by_vas(
	i_vas_subscription_id IN NUMBER,
	o_rec OUT typ_pymt_src_dtls_rec,
	o_err_num OUT NUMBER,
	o_err_msg OUT VARCHAR2)
AS
	c_pymt_src x_program_enrolled.pgm_enroll2x_pymt_src%TYPE;
BEGIN

	IF i_vas_subscription_id IS NULL THEN
		o_err_num := 702; ------'Vas Subscription Id required'
		o_err_msg := sa.get_code_fun ('SA.PAYMENT_SERVICES_PKG', o_err_num, 'ENGLISH');
		RETURN;
	END IF;
	--
	BEGIN
		SELECT pe.pgm_enroll2x_pymt_src
		INTO c_pymt_src
		FROM x_program_enrolled pe,
			 x_vas_subscriptions vs
		WHERE vs.program_enrolled_id = pe.objid
		 AND  vs.vas_subscription_id = i_vas_subscription_id
		 AND  vs.vas_is_active = 'T';
	EXCEPTION
	WHEN NO_DATA_FOUND THEN

		o_err_num := 702; --asim change this eg 703 so that the call below will get "pymnt_src_id not found"
		o_err_msg := sa.get_code_fun ('SA.PAYMENT_SERVICES_PKG', o_err_num, 'ENGLISH');
		RETURN;

	WHEN OTHERS THEN
		o_err_num := 702; --asim same as above
		o_err_msg := sa.get_code_fun ('SA.PAYMENT_SERVICES_PKG', o_err_num, 'ENGLISH');
		RETURN;

	END;

	payment_services_pkg.getpaymentsourcedetails
	(
		p_pymt_src_id   =>  c_pymt_src,
		out_rec         =>  o_rec,
		out_err_num     =>  o_err_num,
		out_err_msg     =>  o_err_msg
	);

END getpaymentsourcedetails_by_vas;

-- CR49058 Adding get_payment_details proc to fetch the payment details
PROCEDURE get_payment_details
(
	i_esn					IN  VARCHAR2,
	i_prog_purch_id         IN  NUMBER,
	i_pymt_type             IN  VARCHAR2,
	i_bus_org               IN  VARCHAR2,
	o_merchant_ref_number   OUT VARCHAR2,
	o_merchant_id           OUT VARCHAR2,
	o_customer_hostname     OUT VARCHAR2,
	o_customer_ipaddress    OUT VARCHAR2,
	o_ignore_avs            OUT VARCHAR2,
	o_disable_avs           OUT VARCHAR2,
	o_ignore_bad_cv         OUT VARCHAR2,
	o_offer_num             OUT VARCHAR2,
	o_quantity              OUT NUMBER,
	o_amount                OUT NUMBER,
	o_tax_amount            OUT NUMBER,
	o_e911_tax_amount       OUT NUMBER,
	o_usf_taxamount         OUT NUMBER,
	o_rcrf_tax_amount       OUT NUMBER,
	o_discount_amount       OUT NUMBER,
	o_capture_req_id        OUT VARCHAR2,
	o_error_code            OUT NUMBER,
	o_error_msg             OUT VARCHAR2
)
IS
	t_ppht program_purch_hdr_type := program_purch_hdr_type();
BEGIN
	IF i_prog_purch_id IS NULL THEN

		 o_error_code := 702;
		o_error_msg  := 'i_prog_purch_id IS NULL!!';
		RETURN;
	END IF;

	t_ppht := program_purch_hdr_type( i_program_purch_hdr_objid => i_prog_purch_id );

	o_merchant_ref_number := t_ppht.merchant_ref_number;
	o_merchant_id         := t_ppht.merchant_id;
	o_customer_hostname   := t_ppht.customer_hostname;
	o_customer_ipaddress  := t_ppht.customer_ipaddress;
	o_ignore_avs          := t_ppht.ignore_avs;
	o_disable_avs         := t_ppht.disable_avs;
	o_offer_num           := t_ppht.offer_num;
	o_quantity            := t_ppht.quantity;
	o_amount              := t_ppht.amount;
	o_tax_amount          := t_ppht.tax_amount;
	o_e911_tax_amount     := t_ppht.e911_taamount;
	o_usf_taxamount       := t_ppht.usf_taxamount;
	o_rcrf_tax_amount     := t_ppht.rcrf_tax_amount;
	o_discount_amount     := t_ppht.discount_amount;

	IF i_pymt_type = 'REFUND' THEN
		o_ignore_bad_cv := 'Yes';

		BEGIN
			SELECT x_request_id
			INTO o_capture_req_id
			FROM x_program_purch_hdr
			WHERE objid = t_ppht.purch_hdr2cr_purch;
		EXCEPTION
		WHEN no_data_found THEN
			o_capture_req_id := NULL;
		END;
	ELSE
		BEGIN
			SELECT x_ignore_bad_cv
			INTO o_ignore_bad_cv
			FROM (  SELECT x_ignore_bad_cv
					FROM (  SELECT '1' as priority, parm.x_ignore_bad_cv
							FROM sa.table_part_inst tpi
							INNER JOIN sa.table_mod_level tml ON tpi.n_part_inst2part_mod = tml.objid  AND tpi.part_serial_no = i_esn
							INNER JOIN sa.table_part_num tpn ON tml.part_info2part_num = tpn.objid
							INNER JOIN sa.table_x_cc_parms_mapping parm_map ON tpn.objid = parm_map.mapping2part_num
							INNER JOIN sa.table_x_cc_parms parm ON parm.objid = parm_map.mapping2cc_parms
							WHERE parm.x_bus_org like '%BILLING%'
							UNION ALL
							SELECT '2' as priority, parm.x_ignore_bad_cv
							FROM sa.table_x_cc_parms parm
							WHERE x_bus_org = i_bus_org
						) a
					ORDER BY priority
				)
			WHERE ROWNUM = 1;
		EXCEPTION
		WHEN no_data_found THEN
			o_ignore_bad_cv := NULL;
		END;
		o_capture_req_id := NULL;
	END IF;
	o_error_code := 0;
	o_error_msg  := 'SUCCESS';
EXCEPTION
WHEN OTHERS THEN
	o_error_code := 702;
	o_error_msg  := ' Not able to fetch the related payment details!!';
END get_payment_details;
--CR53217 Net10 web common standards
  PROCEDURE recurring_payment_fail_flag(
    i_esn IN VARCHAR2,
    o_recurring_payment_flag OUT VARCHAR2,
    o_err_num OUT NUMBER,
    o_err_string OUT VARCHAR2)
IS
BEGIN
  IF i_esn       IS NULL THEN
    o_err_num    := '1112';
    o_err_string := 'ESN cannot be null';
    RETURN;
    END IF;
    SELECT case when COUNT(*)=1 then 'Y' else 'N' end
    INTO o_recurring_payment_flag
    FROM x_program_purch_dtl ppd,
      x_program_purch_hdr hdr,
      x_program_enrolled pe
    WHERE pe.x_esn                    =i_esn
    AND NVL(hdr.x_ics_rcode,'0') NOT IN ('1','100')
    AND ppd.pgm_purch_dtl2prog_hdr    = hdr.objid
    AND pe.objid                      = ppd.pgm_purch_dtl2pgm_enrolled
    AND x_enrollment_status           = 'ENROLLED'
    AND hdr.objid                     =
      (SELECT MAX(hdr1.objid)
      FROM x_program_purch_hdr hdr1,
        x_program_purch_dtl dtl
      WHERE dtl.pgm_purch_dtl2prog_hdr = hdr1.objid
      AND dtl.x_esn                    = pe.x_esn
      );
    o_err_num    := 0;
    o_err_string := 'SUCCESS';
EXCEPTION
WHEN OTHERS THEN
  o_err_num    := 11122;
  o_err_string := SUBSTR(SQLERRM ,1 ,100);
END recurring_payment_fail_flag;

PROCEDURE get_enrolled_esns(
    i_payment_source_id IN VARCHAR2,
    o_esns_ref OUT sys_refcursor,
    o_err_num OUT VARCHAR2,
    o_err_string OUT VARCHAR2)
AS
BEGIN
  IF i_payment_source_id IS NULL THEN
    o_err_num            :='1115';
    o_err_string         :='source id cannot be null';
    RETURN;
  END IF;
  OPEN o_esns_ref FOR SELECT --ps.OBJID,
					  wu.objid webobjid,
					  pi_esn.part_serial_no esn ,
					  pi_min.part_serial_no MIN,
					  enr.pgm_enroll2pgm_parameter program_parameter_id,
					  spsp.x_service_plan_id service_plan_id
						FROM x_payment_source ps,
						  table_web_user wu,
						  table_x_contact_part_inst cpi,
						  table_part_inst pi_esn,
						  table_part_inst pi_min,
						  x_program_enrolled enr,
						  table_site_part sp,
						  x_service_plan_site_part spsp
					WHERE ps.objid                        = i_payment_source_id
					AND ps.pymt_src2web_user              = wu.objid
					AND wu.web_user2contact               = cpi.x_contact_part_inst2contact
					AND cpi.x_contact_part_inst2part_inst = pi_esn.objid
					AND pi_esn.x_domain                   = 'PHONES'
					AND pi_min.part_to_esn2part_inst      = pi_esn.objid
					AND pi_min.x_domain                   = 'LINES'
					AND x_service_id                      = pi_esn.part_serial_no
					AND sp.x_service_id                   =pi_esn.part_serial_no
					AND sp.part_status                    = 'Active'
					AND spsp.table_site_part_id           = sp.objid
					AND pi_esn.part_serial_no             =enr.x_esn
					AND ps.objid                          =enr.pgm_enroll2x_pymt_src
					AND x_enrollment_status               ='ENROLLED';
  o_err_num                                                                                                                                                                                                                                                                                                                                                                               :='0';
  o_err_string                                                                                                                                                                                                                                                                                                                                                                            :='success';
EXCEPTION
WHEN OTHERS THEN
  o_err_num    := 111;
  o_err_string := SUBSTR(SQLERRM ,1 ,100);
END;
--CR53217 Net10 web common standards

--CR53474 Start
PROCEDURE insert_program_purch
(
 ip_x_rqst_source  				           IN VARCHAR2,
 ip_x_rqst_type  				             IN VARCHAR2,
 ip_x_ics_applications  			       IN VARCHAR2,
 ip_x_merchant_id  				           IN VARCHAR2,
 ip_x_merchant_ref_number  		     IN VARCHAR2,
 ip_x_offer_num   				            IN VARCHAR2,
 ip_x_quantity   				             IN NUMBER,
 ip_x_merchant_product_sku   	    IN VARCHAR2,
 ip_x_product_code    			         IN VARCHAR2,
 ip_x_ignore_avs    				          IN VARCHAR2,
 ip_x_customer_hostname 			       IN VARCHAR2,
 ip_x_customer_ipaddress 		       IN VARCHAR2,
 ip_x_customer_phone 			          IN VARCHAR2,
 ip_x_status 					                IN VARCHAR2,
 ip_x_esn 						                  IN VARCHAR2,
 ip_x_amount 					                IN NUMBER,
 ip_x_tax_amount 				             IN NUMBER,
 ip_prog_hdr2x_pymt_src 			       IN NUMBER,
 ip_prog_hdr2web_user 			         IN NUMBER,
 ip_x_payment_type 				           IN VARCHAR2,
 ip_x_e911_tax_amount 			         IN NUMBER,
 ip_x_usf_taxamount 				          IN NUMBER,
 ip_x_rcrf_tax_amount 			         IN NUMBER,
 ip_x_discount_amount 			         IN NUMBER,
 ip_x_charge_desc                 IN VARCHAR2,
 ip_is_dataclub                   IN VARCHAR2 DEFAULT 'N',
 op_program_purchhdr_objid		      OUT NUMBER,
 op_errornum						                OUT VARCHAR2,
 op_errormsg						                OUT VARCHAR2
)
IS

 l_payment_source_type x_payment_source.x_pymt_type%TYPE;
 l_credit_card_objid  NUMBER;
 l_bank_account_objid NUMBER;
 v_bank_acount        table_x_bank_account%ROWTYPE;
 clear_address        table_address%ROWTYPE;
 bank                 table_address%ROWTYPE;
 x_py_pur_hdr_id      NUMBER;
 address table_address%ROWTYPE;
 v_pgmenrl_objid      NUMBER;
 v_webuser_objid      NUMBER;

BEGIN --{
op_errornum := '0';
op_errormsg := 'Success';

 IF   IP_PROG_HDR2X_PYMT_SRC IS NULL --OR IP_PROG_HDR2WEB_USER   IS NULL
 THEN --{
   util_pkg.insert_error_tab_proc(ip_action => 'Invalid Input parameters',
                                   ip_key =>    ip_x_esn,
                                   ip_program_name => 'PAYMENT_SERVICES_PKG.insert_program_purch',
                                   ip_error_text => 'Validate input Exception');
 op_errornum := '-110';
 op_errormsg := 'Payment source not passed.';
 RETURN;
 END IF; --}

 x_py_pur_hdr_id := billing_seq ('X_PROGRAM_PURCH_HDR');

 IF ip_is_dataclub = 'Y'
 THEN --{
  BEGIN --{
   SELECT pe.objid, pe.pgm_enroll2web_user
   INTO   v_pgmenrl_objid, v_webuser_objid
   FROM   x_program_enrolled pe,
          x_program_parameters pp
   WHERE  pe.x_esn = ip_x_esn
   AND    pe.x_enrollment_status      = 'ENROLLED'
   AND    pe.pgm_enroll2pgm_parameter = pp.objid
   AND    pp.x_program_name LIKE '%Data Club Plan%B2B%'
   AND    pp.x_charge_frq_code           =   'LOWBALANCE';
  EXCEPTION
  WHEN OTHERS THEN
   v_pgmenrl_objid := NULL;
  END; --}
 END IF; --}

 BEGIN --{
 INSERT
 INTO x_program_purch_dtl
   (
     objid,
     x_esn,
     x_amount,
     x_tax_amount,
     x_e911_tax_amount,
     x_charge_desc,
     x_cycle_start_date,
     x_cycle_end_date,
     pgm_purch_dtl2pgm_enrolled,
     pgm_purch_dtl2prog_hdr,
     x_usf_taxamount,
     x_rcrf_tax_amount,
     x_discount_amount
   )
   VALUES
   (
     billing_seq ( 'X_PROGRAM_PURCH_DTL'),
     ip_x_esn,
     ROUND(IP_X_AMOUNT,2),
     ROUND(IP_X_TAX_AMOUNT,2),
     ROUND(IP_X_E911_TAX_AMOUNT,2),
     IP_X_CHARGE_DESC,
     SYSDATE,
     SYSDATE,
     v_pgmenrl_objid,
     x_py_pur_hdr_id,
     ROUND(IP_X_USF_TAXAMOUNT,2),
     ROUND(IP_X_RCRF_TAX_AMOUNT,2),
     NVL(IP_X_DISCOUNT_AMOUNT,'0')
   );
 EXCEPTION
 WHEN OTHERS THEN
  op_errormsg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  INSERT
  INTO x_program_error_log
    (
      x_source,
      x_error_code,
      x_error_msg,
      x_date,
      x_description,
      x_severity
    )
    VALUES
    (
      'PAYMENT_SERVICES_PKG.insert_program_purch',
      -100,
      op_errormsg,
      SYSDATE,
      'Error while inserting purch dtl'
      || ip_x_esn,
      2 -- MEDIUM
    );
  op_errornum      := '-100';
  op_errormsg      := 'Error while inserting purch dtl ' || ip_x_esn;
 END; --}

 BEGIN --{
  SELECT x_pymt_type,
         pymt_src2x_credit_card,
         pymt_src2x_bank_account
  INTO   l_payment_source_type,
         l_credit_card_objid,
         l_bank_account_objid
  FROM   x_payment_source
  WHERE  objid = ip_prog_hdr2x_pymt_src;
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
  NULL;
 WHEN OTHERS THEN
  op_errormsg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  INSERT
  INTO x_program_error_log
    (
      x_source,
      x_error_code,
      x_error_msg,
      x_date,
      x_description,
      x_severity
    )
    VALUES
    (
      'PAYMENT_SERVICES_PKG.insert_program_purch',
      -100,
      op_errormsg,
      SYSDATE,
      'No Payment source found for '
      || TO_CHAR (ip_prog_hdr2x_pymt_src ),
      2 -- MEDIUM
    );
  op_errornum      := '-101';
  op_errormsg      := 'No Payment source found for ' || TO_CHAR (ip_prog_hdr2x_pymt_src );
 END; --}

 IF l_payment_source_type = 'ACH'
 THEN --{

          BEGIN --{
            SELECT OBJID ,
              X_BANK_NUM ,
              X_CUSTOMER_ACCT ,
              X_ROUTING ,
              X_ABA_TRANSIT ,
              X_BANK_NAME ,
              X_STATUS ,
              regexp_replace(X_CUSTOMER_FIRSTNAME, '[^0-9 A-Za-z]', '') ,
              regexp_replace(X_CUSTOMER_LASTNAME, '[^0-9 A-Za-z]', '') ,
              CASE WHEN (LENGTH(x_customer_phone) > 10
                         OR
                         LENGTH(X_CUSTOMER_PHONE) < 10
                         OR
                         X_CUSTOMER_PHONE LIKE '305715%'
                         OR
                         X_CUSTOMER_PHONE LIKE '305000%'
                         OR
                         X_CUSTOMER_PHONE LIKE '000%')
                    THEN NULL
                    ELSE X_CUSTOMER_PHONE
                     END X_CUSTOMER_PHONE,
              X_CUSTOMER_EMAIL ,
              X_MAX_PURCH_AMT ,
              X_MAX_TRANS_PER_MONTH ,
              X_MAX_PURCH_AMT_PER_MONTH ,
              X_CHANGEDATE ,
              X_ORIGINAL_INSERT_DATE ,
              X_CHANGEDBY ,
              X_CC_COMMENTS ,
              X_MOMS_MAIDEN ,
              X_BANK_ACCT2CONTACT ,
              X_BANK_ACCT2ADDRESS ,
              X_BANK_ACCOUNT2BUS_ORG,
              BANK2CERT,
              X_CUSTOMER_ACCT_KEY,
              X_CUSTOMER_ACCT_ENC
            INTO   v_bank_acount
            FROM   table_x_bank_account
            WHERE  objid = l_bank_account_objid;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            op_errormsg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
            INSERT
            INTO x_program_error_log
              (
                x_source,
                x_error_code,
                x_error_msg,
                x_date,
                x_description,
                x_severity
              )
              VALUES
              (
                'PAYMENT_SERVICES_PKG.insert_program_purch',
                -100,
                op_errormsg,
                SYSDATE,
                ' No record found for the bank account '
                || TO_CHAR (l_bank_account_objid),
                2
              );
            op_errornum    := '-102';
            op_errormsg    := ' No record found for the bank account ' || TO_CHAR (l_bank_account_objid);
          END; --}

          BEGIN --{
            SELECT OBJID,
              regexp_replace(ADDRESS, '[^0-9 A-Za-z.-]', ''),
              regexp_replace(S_ADDRESS, '[^0-9 A-Za-z.-]', ''),
              regexp_replace(CITY, '[^0-9 A-Za-z.-]', ''),
              regexp_replace(S_CITY, '[^0-9 A-Za-z.-]', ''),
              regexp_replace(STATE, '[^0-9 A-Za-z.-]', ''),
              regexp_replace(S_STATE, '[^0-9 A-Za-z.-]', ''),
              regexp_replace(ZIPCODE, '[^0-9 A-Za-z.-]', ''),
              regexp_replace(ADDRESS_2, '[^0-9 A-Za-z.-]', ''),
              DEV,
              ADDRESS2TIME_ZONE,
              ADDRESS2COUNTRY,
              ADDRESS2STATE_PROV,
              UPDATE_STAMP,
              ADDRESS2E911
            INTO  bank
            FROM  table_address
            WHERE objid = v_bank_acount.x_bank_acct2address;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            address              := clear_address;
            op_errormsg          := SQLCODE || SUBSTR (SQLERRM, 1, 100);
            INSERT
            INTO x_program_error_log
              (
                x_source,
                x_error_code,
                x_error_msg,
                x_date,
                x_description,
                x_severity
              )
              VALUES
              (
                'PAYMENT_SERVICES_PKG.insert_program_purch',
                -100,
                op_errormsg,
                SYSDATE,
                ' No address record found for '
                || TO_CHAR ( v_bank_acount.x_bank_acct2address)
                || ' contact(objid):'
                || TO_CHAR ( v_bank_acount.x_bank_acct2contact),
                2
              );
            op_errornum    := '-103';
            op_errormsg    := ' No address record found for ' || TO_CHAR (v_bank_acount.x_bank_acct2address) || ' contact(objid):' || TO_CHAR (v_bank_acount.x_bank_acct2contact);
          END; --}

         BEGIN --{
          INSERT
          INTO x_program_purch_hdr
            (
              objid,
              x_rqst_source,
              x_rqst_type,
              x_rqst_date,
              x_ics_applications,
              x_merchant_id,
              x_merchant_ref_number,
              x_offer_num,
              x_quantity,
              x_merchant_product_sku,
              x_payment_line2program,
              x_product_code,
              x_ignore_avs,
              x_user_po,
              x_avs,
              x_disable_avs,
              x_customer_hostname,
              x_customer_ipaddress,
              x_auth_request_id,
              x_auth_code,
              x_auth_type,
              x_ics_rcode,
              x_ics_rflag,
              x_ics_rmsg,
              x_request_id,
              x_auth_avs,
              x_auth_response,
              x_auth_time,
              x_auth_rcode,
              x_auth_rflag,
              x_auth_rmsg,
              x_bill_request_time,
              x_bill_rcode,
              x_bill_rflag,
              x_bill_rmsg,
              x_bill_trans_ref_no,
              x_customer_firstname,
              x_customer_lastname,
              x_customer_phone,
              x_customer_email,
              x_status,
              x_bill_address1,
              x_bill_address2,
              x_bill_city,
              x_bill_state,
              x_bill_zip,
              x_bill_country,
              x_amount,
              x_tax_amount,
              x_e911_tax_amount,
              x_auth_amount,
              x_bill_amount,
              x_user,
              x_credit_code,
              purch_hdr2creditcard,
              purch_hdr2bank_acct,
              purch_hdr2user,
              purch_hdr2esn,
              purch_hdr2rmsg_codes,
              purch_hdr2cr_purch,
              prog_hdr2x_pymt_src,
              prog_hdr2web_user,
              prog_hdr2prog_batch,
              x_payment_type,
              x_usf_taxamount,
              x_rcrf_tax_amount,
              x_discount_amount --,
              --x_priority
            )
            VALUES
            (
              x_py_pur_hdr_id,
              IP_X_RQST_SOURCE,
              NVL(IP_X_RQST_TYPE,'ACH_PURCH'),
              SYSDATE,
              NVL(IP_X_ICS_APPLICATIONS,'ecDebitService_run'),
              IP_X_MERCHANT_ID,
              IP_X_MERCHANT_REF_NUMBER,
              IP_X_OFFER_NUM,
              NVL(IP_X_QUANTITY, 1),
              IP_X_MERCHANT_PRODUCT_SKU,
              NULL,
              IP_X_PRODUCT_CODE,
              NVL(IP_X_IGNORE_AVS, 'Yes'),
              NULL,
              NULL,
              NULL,
              IP_X_CUSTOMER_HOSTNAME,
              IP_X_CUSTOMER_IPADDRESS,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NVL (v_bank_acount.x_customer_firstname, 'No Name Provided'),
              NVL (v_bank_acount.x_customer_lastname, 'No Name Provided'),
              NVL(ip_x_customer_phone, v_bank_acount.x_customer_phone),
              NVL (v_bank_acount.x_customer_email, 'null@cybersource.com'),
              NVL(IP_X_STATUS,'RECURINCOMPLETE'),
              NVL (bank.address, 'No Address Provided'),
              NVL (bank.address_2, 'No Address Provided'),
              bank.city,
              bank.state,
              bank.zipcode,
              'US',
              ROUND(IP_X_AMOUNT,2),
              ROUND(IP_X_TAX_AMOUNT,2),
              ROUND(IP_X_E911_TAX_AMOUNT,2),
              NULL,
              NULL,
              'System',
              NULL,
              NULL,
              NVL(l_bank_account_objid,v_bank_acount.objid),
              NULL,
              NULL,
              NULL,
              NULL,
              IP_PROG_HDR2X_PYMT_SRC,
              NVL(IP_PROG_HDR2WEB_USER,v_webuser_objid),
              NULL,
              NVL(IP_X_PAYMENT_TYPE, 'RECURRING'),
              ROUND(IP_X_USF_TAXAMOUNT,2),
              ROUND(IP_X_RCRF_TAX_AMOUNT,2),
              IP_X_DISCOUNT_AMOUNT --,
              --NVL(b2b_rec.x_priority,20)
            );
           EXCEPTION
           WHEN OTHERS THEN
            op_errormsg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
            INSERT
            INTO x_program_error_log
              (
                x_source,
                x_error_code,
                x_error_msg,
                x_date,
                x_description,
                x_severity
              )
              VALUES
              (
                'PAYMENT_SERVICES_PKG.insert_program_purch',
                -100,
                op_errormsg,
                SYSDATE,
                'Error while inserting purch hdr'
                || ip_x_esn,
                2 -- MEDIUM
              );
            op_errornum      := '-104';
            op_errormsg      := 'Error while inserting purch hdr ' || ip_x_esn;
           END; --}

         BEGIN --{
          INSERT
          INTO x_ach_prog_trans
            (
              objid,
              x_bank_num,
              x_ecp_account_no,
              x_ecp_account_type,
              x_ecp_rdfi,
              x_ecp_settlement_method,
              x_ecp_payment_mode,
              x_ecp_debit_request_id,
              x_ecp_verfication_level,
              x_ecp_ref_number,
              x_ecp_debit_ref_number,
              x_ecp_debit_avs,
              x_ecp_debit_avs_raw,
              x_ecp_rcode,
              x_ecp_trans_id,
              x_ecp_ref_no,
              x_ecp_result_code,
              x_ecp_rflag,
              x_ecp_rmsg,
              x_ecp_credit_ref_number,
              x_ecp_credit_trans_id,
              x_decline_avs_flags,
              ach_trans2x_purch_hdr,
              ach_trans2x_bank_account
            )
            VALUES
            (
              billing_seq ('X_ACH_PROG_TRANS'), --objid,
              v_bank_acount.x_bank_num,         --x_bank_num,
              v_bank_acount.x_customer_acct,
              DECODE (UPPER(v_bank_acount.x_aba_transit), 'SAVINGS', 'S', 'CHECKING', 'C', 'CORPORATE', 'X', v_bank_acount.x_aba_transit),
              v_bank_acount.x_routing,
              'A',
              NULL,  --x_ecp_payment_mode,
              NULL,  --x_ecp_debit_request_id,
              1,     --x_ecp_verfication_level,
              NULL,  --x_ecp_ref_number,
              NULL,  --x_ecp_debit_ref_number,
              NULL,  --x_ecp_debit_avs,
              NULL,  --x_ecp_debit_avs_raw,
              NULL,  --x_ecp_rcode,
              NULL,  --x_ecp_trans_id,
              NULL,  --x_ecp_ref_no,
              NULL,  --x_ecp_result_code,
              NULL,  --x_ecp_rflag,
              NULL,  --x_ecp_rmsg,
              NULL,  --x_ecp_credit_ref_number,
              NULL,  --x_ecp_credit_trans_id,
              'Yes', --x_decline_avs_flags,
              x_py_pur_hdr_id,
              v_bank_acount.objid
            );
          EXCEPTION
          WHEN OTHERS THEN
           op_errormsg := SQLCODE || SUBSTR (SQLERRM, 1, 100);
           INSERT
           INTO x_program_error_log
             (
               x_source,
               x_error_code,
               x_error_msg,
               x_date,
               x_description,
               x_severity
             )
             VALUES
             (
               'PAYMENT_SERVICES_PKG.insert_program_purch',
               -100,
               op_errormsg,
               SYSDATE,
               'Error while inserting ACH purch trans'
               || ip_x_esn,
               2 -- MEDIUM
             );
           op_errornum      := '-105';
           op_errormsg      := 'Error while inserting ACH purch trans ' || ip_x_esn;
          END; --}

 END IF; --}
op_program_purchhdr_objid := x_py_pur_hdr_id;

NULL;
EXCEPTION
WHEN OTHERS THEN
 NULL;
END insert_program_purch; --}

--CR53474 End

-- CR53192 changes begin :Overloading Getpaymentsource, get_all_payment_source_details for sending the Inactive Payment source info
PROCEDURE get_all_payment_sources ( i_login_name                    IN  VARCHAR2 DEFAULT NULL    ,
                                    i_bus_org_id                    IN  VARCHAR2                 ,
                                    i_esn                           IN  VARCHAR2 DEFAULT NULL    ,
                                    i_min                           IN  VARCHAR2 DEFAULT NULL    ,
							                      i_include_inactive              IN  VARCHAR2 DEFAULT 'Y'     ,
                                    o_payment_source_detail_tbl     OUT payment_source_detail_tab,
                                    o_err_num                       OUT NUMBER                   ,
                                    o_err_msg                       OUT VARCHAR2                 )
AS
  --Local variables
  l_pymt_src_name                 VARCHAR2(100);
  l_esn_cnt                       NUMBER ;
  l_min_cnt                       NUMBER ;
  l_bo_objid                      NUMBER ;
  l_esn                           VARCHAR2(30) ;
  l_web_user_cnt                  NUMBER ;
  l_phone_number                  VARCHAR2(20);
  --Declaring variable to access type objects
  cst sa.customer_type            := sa.customer_type() ;
  c sa.customer_type              := sa.customer_type() ;
  cst_login sa.customer_type      := sa.customer_type() ;
  psd typ_pymt_src_dtls_rec       := sa.typ_pymt_src_dtls_rec() ;
  psdt payment_source_detail_type := payment_source_detail_type() ;
  TYPE psd_typ
  IS
    TABLE OF x_payment_source%ROWTYPE INDEX BY PLS_INTEGER;
  psd_tab psd_typ;

BEGIN -- Main Section

  cst.esn := i_esn;
  --Instantiate
  o_payment_source_detail_tbl := sa.payment_source_detail_tab();
  IF (i_esn                   IS NULL AND i_min IS NULL AND i_login_name IS NULL) THEN
    --
    o_err_num := '1001';
    o_err_msg := 'ESN/MIN/Login name all cannot be null';
    RETURN;
    --
  END IF;
  IF i_bus_org_id IS NULL THEN
    --
    o_err_num := '1009';
    o_err_msg := 'BRAND CANNOT BE NULL';
    RETURN;
    --
  END IF;
  -- Initialize customer type brand variables and validation
  cst.bus_org_id  := i_bus_org_id;
  c.bus_org_objid := cst.get_bus_org_objid;
  --To check whether the input bus org is NOT NULL and Valid.
  IF c.bus_org_objid IS NULL THEN
    --
    o_err_num := '1008';
    o_err_msg := 'INVALID BRAND: ' || i_bus_org_id;
    RETURN;
    --
  END IF;
  -- Condition to check whether input ESN/MIN IS NOT NULL
  IF (i_esn IS NOT NULL OR i_min IS NOT NULL) THEN

    IF i_esn IS NULL AND i_min IS NOT NULL THEN
      cst.esn := cst.get_esn ( i_min => i_min );
      --
      IF cst.esn IS NULL THEN
        o_err_num := '1005';
        o_err_msg := 'MIN is not valid';
        RETURN;
      END IF;
    END IF;

    IF i_min IS NULL AND i_esn IS NOT NULL THEN
      cst.min := cst.get_min ( i_esn => i_esn );
      --
      IF cst.min IS NULL THEN
        o_err_num := '1006';
        o_err_msg := 'ESN is not valid';
        RETURN;
      END IF;
    END IF;
    --Retrieve the ESN web attributes
    cst             := cst.get_web_user_attributes;
    IF cst.response <> 'SUCCESS' THEN
      o_err_num     := '1003';
      o_err_msg     := cst.response;
      RETURN;
    END IF;
  ELSIF i_login_name IS NOT NULL THEN
    --
    cst_login             := cst.retrieve_login ( i_login_name => i_login_name,
                                                  i_bus_org_id => i_bus_org_id);
    IF cst_login.response <> 'SUCCESS' THEN
      --
      IF cst_login.response = 'LOGIN NAME NOT FOUND FOR PROVIDED BRAND' THEN
        o_err_num          := '1008';
        o_err_msg          := 'INVALID BRAND';
        RETURN;
      ELSE
        o_err_num := '1006';
        o_err_msg := cst_login.response;
        RETURN;
      END IF;
      --
    END IF;
    --
  END IF;
  cst.web_login_name := NVL(cst.web_login_name,cst_login.web_login_name);
  -- Retrieve set of payment sources for given login name
  SELECT ps.* BULK COLLECT
  INTO psd_tab
  FROM x_payment_source ps,
    table_web_user wu
  WHERE wu.s_login_name    = UPPER(cst.web_login_name)
  AND ps.pymt_src2web_user = wu.objid
  AND wu.web_user2bus_org = c.bus_org_objid --CR49696 Condition included to retrieve only brand specific payment sources
  AND (( UPPER(ps.x_status)   = 'ACTIVE' AND i_include_inactive = 'N' )
       OR i_include_inactive = 'Y' );
  --Return if there is no payment source available for given login name

 -- CR49696 wfm Changes
  IF  psd_tab IS NULL THEN
    o_err_num     := '1013';
    o_err_msg     := 'No payment sources available';
    RETURN;
  END IF;

  IF psd_tab.COUNT = 0  THEN
    o_err_num     := '1013';
    o_err_msg     := 'No payment sources available';
    RETURN;
  END IF;

  FOR i IN 1 ..psd_tab.COUNT
  LOOP
    payment_services_pkg.get_all_payment_source_details ( i_pymt_src_id                => psd_tab(i).objid  ,
	                                                        i_include_inactive           => i_include_inactive,
                                                          o_payment_source_detail_rec  => psd               ,
                                                          o_err_num                    => o_err_num         ,
                                                          o_err_msg                    => o_err_msg         );
    IF o_err_num != 0 THEN
      RETURN;
    END IF;
    psdt := sa.payment_source_detail_type
              (
              psd.payment_source_id                           ,
              psd.payment_type                                ,
              psd.payment_status                              ,
              psd_tab(i).x_pymt_src_name                      ,
              psd.is_default                                  ,
              psd.user_id               					  ,
              psd.first_name            					  ,
              psd.last_name             					  ,
              psd.email                 					  ,
              get_customer_phone_number(psd.payment_source_id),
              psd.secure_date                                 ,
              sa.address_type_rec
               (
                psd.address_info.address_1 					  ,
                psd.address_info.address_2 					  ,
                psd.address_info.city      					  ,
                psd.address_info.state     					  ,
                psd.address_info.country   					  ,
                psd.address_info.zipcode
                ),
              sa.typ_creditcard_info
               (
			          psd.cc_info.masked_card_number          ,
                psd.cc_info.card_type         				  ,
                psd.cc_info.exp_date          				  ,
                psd.cc_info.security_code     				  ,
                psd.cc_info.cvv               				  ,
                psd.cc_info.cc_enc_number     				  ,
                psd.cc_info.key_enc_number    				  ,
                psd.cc_info.cc_enc_algorithm  				  ,
                psd.cc_info.key_enc_algorithm 				  ,
                psd.cc_info.cc_enc_cert
                ),
              sa.typ_ach_info
               (
      			psd.ach_info.routing_number                   ,
                psd.ach_info.account_number    				  ,
                psd.ach_info.account_type      				  ,
                psd.ach_info.customer_acct_key 				  ,
                psd.ach_info.customer_acct_enc 				  ,
                psd.ach_info.cert              				  ,
                psd.ach_info.key_algo          				  ,
                psd.ach_info.cc_algo
                ),
              sa.typ_aps_info
               (
			    psd.aps_info.alt_pymt_source                  ,
                psd.aps_info.alt_pymt_source_type 			  ,
                psd.aps_info.application_key
                )
              );

    -- Extend the collection variable
    o_payment_source_detail_tbl.EXTEND;
    o_payment_source_detail_tbl ( o_payment_source_detail_tbl.LAST ) := psdt;
    --
  END LOOP;

  -- Return output parameter values
  o_err_num := 0 ;
  o_err_msg := 'Success' ;

EXCEPTION --Main exception section
WHEN OTHERS THEN
  o_err_num := '1012';
  o_err_msg := SQLCODE||'-'||SUBSTR (SQLERRM, 1, 300);
  RETURN;
END get_all_payment_sources;

--CR53192
PROCEDURE get_all_payment_source_details ( i_pymt_src_id                IN  NUMBER               ,
                                           i_include_inactive           IN  VARCHAR2 DEFAULT 'Y' ,
                                           o_payment_source_detail_rec  OUT typ_pymt_src_dtls_rec,
                                           o_err_num                    OUT NUMBER               ,
                                           o_err_msg                    OUT VARCHAR2             )
IS

 v_objid        VARCHAR2 (40);
 v_payment_type VARCHAR2 (80);

BEGIN

  IF i_pymt_src_id IS NULL THEN
    o_err_num := 702; ------'payment source id required'
    o_err_msg := sa.get_code_fun ('SA.PAYMENT_SERVICES_PKG', o_err_num, 'ENGLISH');
    RETURN;
  END IF;

  BEGIN

    SELECT ps.objid,ps.x_pymt_type
    INTO v_objid, v_payment_type
    FROM x_payment_source ps
    WHERE ps.objid = i_pymt_src_id;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    o_err_num := 702; --asim change this eg 703 so that the call below will get "pymnt_src_id not found"
    o_err_msg := sa.get_code_fun ('SA.PAYMENT_SERVICES_PKG', o_err_num, 'ENGLISH');
    RETURN;
  WHEN OTHERS THEN
    o_err_num := 702; --asim same as above
    o_err_msg := sa.get_code_fun ('SA.PAYMENT_SERVICES_PKG', o_err_num, 'ENGLISH');
    RETURN;
  END;

  IF v_payment_type = 'CREDITCARD' THEN
    BEGIN
      SELECT typ_pymt_src_dtls_rec ( ps.objid,
	                                 ps.x_pymt_type,
									 ps.x_status,
									 ps.x_is_default,
									 ps.x_billing_email,
									 typ_creditcard_info ( cc.x_customer_cc_number,
									                       cc.x_cc_type,
														   ( cc.x_customer_cc_expmo || '-' || cc.x_customer_cc_expyr),
														   NULL,
														   NULL,
														   cc.X_CUST_CC_NUM_ENC,
														   cc.X_CUST_CC_NUM_KEY,
														   cert.X_CC_ALGO,
														   cert.X_KEY_ALGO,
														   cert.x_cert
														 ),
									 cc.x_customer_firstname,
									 cc.x_customer_lastname,
									 cc.x_customer_email,
									 address_type_rec ( a.address,
									                    a.address_2,
														a.city,
														a.state,
														c.s_name,
														a.zipcode
													  ),
							         cc.x_cust_cc_num_key,
									 NULL,
									 NULL
									)
      INTO  o_payment_source_detail_rec
      FROM  table_x_credit_card cc,
            x_cert cert,
            x_payment_source ps,
            table_address a,
            sa.table_country c
      WHERE ps.pymt_src2x_credit_card = cc.objid
      AND   (( UPPER(ps.x_status)   = 'ACTIVE' AND i_include_inactive = 'N' )
             OR i_include_inactive = 'Y' )
      AND   cc.x_credit_card2address = a.objid(+)
      AND   a.address2country = c.objid(+)
      AND   cc.creditcard2cert = cert.objid
      AND   ps.objid = v_objid ;

    EXCEPTION
    WHEN OTHERS THEN
      o_err_num := 702;
      o_err_msg := 'Missing details'; --SA.GET_CODE_FUN('SA.PAYMENT_SERVICES_PKG', o_err_num, 'ENGLISH');
    END;

  ELSIF v_payment_type = 'APS' THEN ---Added for Smartpay integration on 07/15/2015

    BEGIN

      SELECT typ_pymt_src_dtls_rec ( ps.objid,
	                                 ps.x_pymt_type,
									 ps.x_status,
									 ps.x_is_default,
									 ps.x_billing_email,
									 NULL,
									 aps.x_customer_firstname,
									 aps.x_customer_lastname,
									 aps.x_customer_email,
									 address_type_rec ( a.address,
									                    a.address_2,
														a.city,
														a.state,
														c.s_name,
														a.zipcode
													  ),
									 NULL,
									 NULL,
									 typ_aps_info ( aps.x_alt_pymt_source,
									                aps.x_alt_pymt_source_type,
													aps.x_application_key
												   )
								    )
      INTO   o_payment_source_detail_rec
      FROM   table_x_altpymtsource aps,
             x_payment_source ps,
             table_address a,
             sa.table_country c
      WHERE  ps.pymt_src2x_altpymtsource = aps.objid
      AND    (( UPPER(ps.x_status)   = 'ACTIVE' AND i_include_inactive = 'N' )
              OR i_include_inactive = 'Y' )
      AND    aps.x_altpymtsource2address = a.objid(+)
      AND    a.address2country = c.objid(+)
      AND    ps.objid = v_objid;

    EXCEPTION
    WHEN OTHERS THEN
      o_err_num := 702;
      o_err_msg := 'Missing details'; --SA.GET_CODE_FUN('SA.PAYMENT_SERVICES_PKG', o_err_num, 'ENGLISH');
    END;

  ELSE

    BEGIN

      SELECT typ_pymt_src_dtls_rec ( ps.objid,
	                                 ps.x_pymt_type,
									 ps.x_status,
									 ps.x_is_default,
									 ps.x_billing_email,
									 NULL,
									 ba.x_customer_firstname,
									 ba.x_customer_lastname,
									 ba.x_customer_email,
									 address_type_rec ( a.address,
									                    a.address_2,
														a.city,
														a.state,
														c.s_name,
														a.zipcode
													   ),
							         NULL,
									 typ_ach_info( ba.x_routing,
									               ba.x_customer_acct,
												   ba.x_aba_transit,
												   ba.x_customer_acct_key,
												   ba.x_customer_acct_enc,
												   cert.x_cert,
												   cert.x_key_algo,
												   cert.x_cc_algo
												  ),
									 NULL
									)
      INTO   o_payment_source_detail_rec
      FROM   table_x_bank_account ba,
             x_payment_source ps,
             table_address a,
             x_cert cert,
             sa.table_country c
      WHERE  ps.pymt_src2x_bank_account = ba.objid
      AND   (( UPPER(ps.x_status)   = 'ACTIVE' AND i_include_inactive = 'N' )
               OR i_include_inactive = 'Y' )
      AND    ba.x_bank_acct2address = a.objid(+)
      AND    a.address2country = c.objid(+)
      AND    ps.objid = v_objid
      AND    ba.bank2cert = cert.objid;

    EXCEPTION
    WHEN OTHERS THEN
      o_err_num := 702;
      o_err_msg := 'Missing details'; --SA.GET_CODE_FUN('SA.PAYMENT_SERVICES_PKG', o_err_num, 'ENGLISH');
    END;

  END IF;

  o_err_num := 0;
  o_err_msg := 'Success';

EXCEPTION
WHEN OTHERS THEN
  o_err_num := SQLCODE;
  o_err_msg := SUBSTR (SQLERRM, 1, 300);
  util_pkg.insert_error_tab_proc ( ip_action       => NULL,
                                   ip_key          => TO_CHAR (i_pymt_src_id),
                                   ip_program_name => 'SA.PAYMENT_SERVICES_PKG.get_all_payment_source_details',
                                   ip_error_text   => o_err_msg );
END get_all_payment_source_details;

-- CR53192 changes Ends here

END PAYMENT_SERVICES_PKG;
/