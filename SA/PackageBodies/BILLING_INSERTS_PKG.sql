CREATE OR REPLACE PACKAGE BODY sa."BILLING_INSERTS_PKG"
IS
 /********************************************************************************************/
 /* Copyright 2009 Tracfone Wireless Inc. All rights reserved */
 /* */
 /* NAME : SA.BILLING_INSERTS_PKG */
 /* PURPOSE : */
 /* */
 /* PLATFORMS: Oracle 10.2.0 AND newer versions. */
 /* */
 /* REVISIONS: */
 /* VERSION DATE WHO PURPOSE */
 /* ------- ---------- ----- --------------------------------------------- */
 /* 1.0 11/01/09 SKUTHADI Initial Revision */
 /* 1.1-1.7 11/18/09 SKUTHADI CR12155 ST_BUNDLE_III */
 /* */
 /******************************************************************************************/
 /* CVS CHECK IN HISTORY */
 --$RCSfile: BILLING_INSERTS_PKb.sql,v $
 --$Revision: 1.34 $
 --$Author: rmorthala $
 --$Date: 2017/12/12 17:11:07 $
 --$Log: BILLING_INSERTS_PKb.sql,v $
 --Revision 1.34  2017/12/12 17:11:07  rmorthala
 --*** empty log message ***
 --
 --Revision 1.32  2017/11/08 19:39:25  sinturi
 --Removed the debug
 --
 --Revision 1.31  2017/11/08 17:13:56  sinturi
 --Added debug
 --
 --Revision 1.30  2017/11/07 15:33:53  sinturi
 --Added overloading proc
 --
 --Revision 1.22 2017/04/24 16:32:23 tbaney
 --Modified parameter name.
 --
 --Revision 1.21 2017/04/21 20:16:27 tbaney
 --Added parameter for CR48480.
 --
 --Revision 1.20 2017/02/16 21:36:49 smacha
 --Added new logic to insert records for additional columns(pcrf_subscriber_id, pcrf_group_id) of x_program_dealer_info for
 --Auto Refill Solution for Indirect Channel - Simple Mobile (CR 44929).
 --
 --Revision 1.19 2017/02/06 23:01:40 smacha
 --Inserting Enrollment records into new table x_program_dealer_info for
 --Auto Refill Solution for Indirect Channel - Simple Mobile (CR 44929).
 --
 --Revision 1.16 2016/09/24 23:34:51 vlaad
 --Updated to allow multiple enrollment for data club
 --
 --Revision 1.10 2015/08/27 15:01:52 jarza
 --CR35567 - B2B promotion
 --
 --Revision 1.9 2015/07/16 15:12:57 rpednekar
 --Changes done by Rahul for CR34597. Changes done in insert of x_program_purch_hdr and billing_log tables.
 --
 --Revision 1.8 2015/06/04 15:55:24 jarza
 --CR33498 changes - to allow low balance program class to enroll
 --
 --Revision 1.7 2014/12/19 16:38:59 ahabeeb
 --CR30259
 --
 --Revision 1.6 2014/08/18 15:16:47 cpannala
 --Cr30255 payment status changed
 --
 --Revision 1.5 2014/06/20 21:48:15 cpannala
 --Changes made for CR29467
 --
 --Revision 1.4 2014/05/15 20:07:33 cpannala
 --CR25490 changes made for Post activation job
 --
 --Revision 1.7 2014/02/07 16:03:30 cpannala
 --CR25490 new procedure for preenrollment
 --
 --Revision 1.5 2012/04/04 20:21:07 ymillan
 --CR19853
 --
 --Revision 1.4 2012/04/04 20:07:12 ymillan
 --CR19853
 --
 --Revision 1.3 2011/04/11 13:31:10 ymilan
 --CR11553
 --
 --Revision 1.2 2011/03/24 20:00:46 skuthadi
 --CR14092 - Mega-750-III modified chk_esn_enrolled_curs added x_prog_class check
 --
 --Revision 1.1 2011/03/14 15:46:19 skuthadi
 --
 /* 1.3 04/11/11 YMILLAN CR11553 */
 /* 1.5 04/04/12 YMILLAN CR19853
 /*
 * --$Description: New procedure added for CR22623
 * --$Created by: cpannala
 * --$Date: 12/03/2013
 -----------------------------------------------------------------------------------------------------
 * 12/03/2013 cpannala CR22623*/
 /********************************************************************************************/
PROCEDURE inserts_billing_proc(
 ip_esn IN VARCHAR2,
 ip_pgm_param_objid IN NUMBER,
 ip_web_user_objid IN NUMBER,
 ip_payment_src_objid IN NUMBER,
 ip_next_charge_date IN DATE,
 ip_sourcesystem IN VARCHAR2,
 op_result OUT NUMBER, -- Output Result
 op_msg OUT VARCHAR2, -- Output Message
 ip_enrollment_status IN VARCHAR2 DEFAULT NULL,
	-- CR43498 DATA CLUB
 ip_dataclub_flag IN VARCHAR2 DEFAULT 'N',
 ip_dealer_id IN VARCHAR2 DEFAULT NULL, --CR 44929, --CR 44929
 ip_partner_name IN VARCHAR2 DEFAULT NULL --- CR48480 Partner name ex: AMAZON WEB ORDERS, Best Buy, Ebay
	)
IS
 CURSOR CUR_PYMT_SOURCE_ZIP (PS_OBJID IN NUMBER)
 IS
 SELECT ADR.ZIPCODE
	-- Start added by Rahul for CR34597
	,BANK.X_CUSTOMER_FIRSTNAME
	,BANK.X_CUSTOMER_LASTNAME
	,BANK.X_CUSTOMER_PHONE
	,BANK.X_CUSTOMER_EMAIL
	,ADR.ADDRESS
	,ADR.ADDRESS_2
	,ADR.CITY
	,ADR.STATE
	,CNTR.NAME
	-- End added by Rahul for CR34597
 FROM TABLE_ADDRESS ADR,
 TABLE_COUNTRY CNTR,
 TABLE_X_BANK_ACCOUNT BANK,
 X_PAYMENT_SOURCE PYMTSRC
 WHERE ADR.OBJID = BANK.X_BANK_ACCT2ADDRESS
 AND CNTR.OBJID(+) = ADR.ADDRESS2COUNTRY
 AND BANK.OBJID = PYMTSRC.PYMT_SRC2X_BANK_ACCOUNT
 AND BANK.X_STATUS = 'ACTIVE'
 AND PYMTSRC.X_STATUS = 'ACTIVE'
 AND PYMTSRC.OBJID = PS_OBJID
 UNION
 SELECT ADR.ZIPCODE
 -- Start added by Rahul for CR34597
	,CC.X_CUSTOMER_FIRSTNAME
	,CC.X_CUSTOMER_LASTNAME
	,CC.X_CUSTOMER_PHONE
	,CC.X_CUSTOMER_EMAIL
	,ADR.ADDRESS
	,ADR.ADDRESS_2
	,ADR.CITY
	,ADR.STATE
	,CNTR.NAME
	-- End added by Rahul for CR34597
 FROM TABLE_ADDRESS ADR,
 TABLE_COUNTRY CNTR,
 TABLE_X_CREDIT_CARD CC,
 X_PAYMENT_SOURCE PYMTSRC
 WHERE ADR.OBJID = CC.X_CREDIT_CARD2ADDRESS
 AND CNTR.OBJID(+) = ADR.ADDRESS2COUNTRY
 AND CC.OBJID = PYMTSRC.PYMT_SRC2X_CREDIT_CARD
 AND CC.X_CARD_STATUS = 'ACTIVE'
 AND PYMTSRC.X_STATUS = 'ACTIVE'
 AND PYMTSRC.OBJID = PS_OBJID;
 L_BILL_ZIP TABLE_ADDRESS.ZIPCODE%TYPE;
 CURSOR chk_esn_enrolled_curs (c_esn VARCHAR2,c_enrollment_status VARCHAR2, c_pgm_param_objid VARCHAR2)
 IS
 SELECT pp.*
 FROM x_program_enrolled pe,
 x_program_parameters pp
 WHERE pp.objid = pe.pgm_enroll2pgm_parameter
 AND pp.x_is_recurring = 1
 --AND pp.x_prog_class = 'SWITCHBASE'
 AND pp.x_prog_class =( SELECT x_prog_class
 FROM x_program_parameters param
 where objid = c_pgm_param_objid)
 AND pe.x_enrollment_status = c_enrollment_status --'ENROLLED'
 AND x_esn = c_esn;
 chk_esn_enrolled_rec chk_esn_enrolled_curs%ROWTYPE;
 -- CR14092
 /*
 1) Added prog class SWITCH BASE to above cursor
 2) Buy Now (which is recurring 1, ONDEMAND) can be combined with Mega/750 (SWITHCBASE)
 */
 --l_action_type varchar2(30);
 l_enroll_seq NUMBER;
 l_purch_hdr_seq NUMBER;
 l_purch_dtl_seq NUMBER;
 l_prgm_trans_seq NUMBER;
 l_billing_log_seq NUMBER;
 l_case_objid NUMBER;
 l_case_id VARCHAR2(30);
 l_enroll_fee table_x_pricing.x_retail_price%TYPE;
 l_pgm_param_objid		sa.x_program_parameters.objid%TYPE;
 l_pgm_param_name x_program_parameters.x_program_name%TYPE;
 rec_table_contact table_contact%ROWTYPE;
 rec_x_pymt_src x_payment_source%ROWTYPE;
 l_chk_cc_blklstd NUMBER;
 chk_cc_blklstd EXCEPTION; -- to check credit card status
 esn_is_enrolled EXCEPTION; -- to check esn already enrolled in any recurring program
 case_creation EXCEPTION; --to check case status
 l_enrollment_status VARCHAR2(30);
 l_status VARCHAR2(30);
 l_enroll_part_no table_part_num.part_number%type;
 l_dealer_seq NUMBER := sa.sequ_x_dealer.nextval; --CR 44929
 l_sysdate DATE := SYSDATE; --CR 44929
 l_brand table_bus_org.org_id%type := NULL; --CR 44929
 l_pcrf_subscriber_id x_program_dealer_info.pcrf_subscriber_id%type := NULL; --CR 44929
 l_pcrf_group_id x_program_dealer_info.pcrf_group_id%type := NULL; --CR 44929

 ---- Start added by Rahul for CR34597

	V_FIRST_NAME 	TABLE_X_CREDIT_CARD.X_CUSTOMER_FIRSTNAME%TYPE;
	V_LAST_NAME 	TABLE_X_CREDIT_CARD.X_CUSTOMER_LASTNAME%TYPE;
	V_PHONE			TABLE_X_CREDIT_CARD.X_CUSTOMER_PHONE%TYPE;
	V_E_MAIL 		TABLE_X_CREDIT_CARD.X_CUSTOMER_EMAIL%TYPE;
	V_ADDRESS_1 	TABLE_ADDRESS.ADDRESS%TYPE;
	V_ADDRESS_2 	TABLE_ADDRESS.ADDRESS_2%TYPE;
	V_CITY 			TABLE_ADDRESS.CITY%TYPE;
	V_STATE 		TABLE_ADDRESS.STATE%TYPE;
	V_COUNTRY 		TABLE_COUNTRY.NAME%TYPE;
---- End added by Rahul for CR34597
	LV_PROMO_OBJID 			sa.TABLE_X_PROMOTION.OBJID%TYPE;
	LV_PROMO_CODE 			VARCHAR2(200);
	LV_SCRIPT_ID 			VARCHAR2(200);
	LV_ERROR_CODE 			NUMBER;
	LV_ERROR_MSG 			VARCHAR2(200);
 c_program_name VARCHAR2(200);

BEGIN
 IF ( ip_enrollment_status IS NULL ) THEN
 l_enrollment_status := 'ENROLLED';
 -- l_status := 'SUCCESS';
 -- l_action_type := 'Enrollment';
 ELSE
 l_enrollment_status := 'ENROLLMENTPENDING';
 -- l_status := 'PENDING';
 -- l_action_type := 'Trying To Enroll';
 END IF;
 -----------------------------------------------------------------------------------------------
 ---------------- Check if ESN already enrolled in a Recurring Program --------------------------
 --CR43498 DATA CLUB.. SKIP IF DATACLUB FLAG IS "Y"

 begin
 select x_program_name
 into c_program_name
 from x_program_parameters
 where objid = ip_pgm_param_objid;
 exception
 when others then
 null;
 end;

 IF c_program_name like '%Data Club%' or ip_dataclub_flag = 'Y' THEN
 NULL;
 ELSE
 OPEN chk_esn_enrolled_curs (ip_esn,l_enrollment_status, ip_pgm_param_objid);
 FETCH chk_esn_enrolled_curs INTO chk_esn_enrolled_rec;
 IF chk_esn_enrolled_curs%FOUND THEN
 CLOSE chk_esn_enrolled_curs;
 RAISE esn_is_enrolled;
 END IF;
 CLOSE chk_esn_enrolled_curs;
 END IF;
 ---------------- Get the Credit card status details --------------------------
 BEGIN
 SELECT x_max_purch_amt
 INTO l_chk_cc_blklstd
 FROM table_x_credit_card
 WHERE objid =
 (SELECT pymt_src2x_credit_card
 FROM x_payment_source
 WHERE objid = ip_payment_src_objid
 );
 EXCEPTION
 WHEN OTHERS THEN
 l_chk_cc_blklstd := 0;
 END;
 IF l_chk_cc_blklstd = .01 THEN
 RAISE chk_cc_blklstd;
 END IF;
 ---------------- Get the Program details --------------------------
 SELECT param.objid,
		param.x_program_name,
 (price1.x_retail_price + price2.x_retail_price ) enroll_fee,
 pn.part_number
 INTO l_pgm_param_objid,
	l_pgm_param_name,
 l_enroll_fee,
 l_enroll_part_no
 FROM x_program_parameters param,
 table_part_num pn,
 table_x_pricing price1,
 table_x_pricing price2
 WHERE 1 = 1
 AND param.objid = ip_pgm_param_objid
 AND param.prog_param2prtnum_monfee = price1.x_pricing2part_num
 AND param.prog_param2prtnum_enrlfee = pn.objid
 AND param.prog_param2prtnum_enrlfee = price2.x_pricing2part_num
 AND sysdate BETWEEN price1.x_start_date AND price1.x_end_date --CR19853
 AND sysdate BETWEEN price2.x_start_date AND price2.x_end_date; --CR19853
 ---------------- Get the contact details --------------------------
 SELECT *
 INTO rec_table_contact
 FROM table_contact
 WHERE objid =
 (SELECT web_user2contact FROM table_web_user WHERE objid = ip_web_user_objid
 );


 ---------------- Get the payment details --------------------------
 SELECT *
 INTO rec_x_pymt_src
 FROM x_payment_source
 WHERE objid = ip_payment_src_objid;
 ---------------------------------------------------------------------------
 -- Get the Enrollment NEXT VAL for Objid
 l_enroll_seq := billing_seq ('X_PROGRAM_ENROLLED');
 -- Get the Purch hdr NEXT VAL for Objid
 l_purch_hdr_seq := billing_seq ('X_PROGRAM_PURCH_HDR');
 -- Get the Purch dtl NEXT VAL for Objid
 l_purch_dtl_seq := billing_seq ('X_PROGRAM_PURCH_DTL');
 -- Get the program trans NEXT VAL for Objid
 l_prgm_trans_seq := billing_seq ('X_PROGRAM_TRANS');
 -- Get the billing log NEXT VAL for Objid
 l_billing_log_seq := billing_seq ('X_BILLING_LOG');
 /*All the amount columns in purch hdr and purch dtl will be 0 for enrollmentwithoutpayment */
 --11/18/09
 -------------------------Insert a record in x_program_enrolled --------------------------------
 --dbms_output.put_line ('Insert into x_program_enrolled Starts');
 INSERT
 INTO x_program_enrolled
 (
 objid,
 x_esn,
 x_amount,
 x_type,
 x_sourcesystem,
 x_insert_date,
 x_charge_date,
 x_enrolled_date,
 x_start_date,
 x_reason,
 x_delivery_cycle_number,
 x_enroll_amount,
 x_language,
 x_enrollment_status,
 x_is_grp_primary,
 x_next_charge_date,
 x_update_stamp,
 x_update_user,
 pgm_enroll2pgm_parameter,
 pgm_enroll2site_part,
 pgm_enroll2part_inst,
 pgm_enroll2contact,
 pgm_enroll2web_user,
 pgm_enroll2x_pymt_src,
 x_termscond_accepted,
 x_pec_customer,
 x_service_days
 )
 VALUES
 (
 l_enroll_seq,
 ip_esn,
 l_enroll_fee,
 'INDIVIDUAL',
 ip_sourcesystem,
 SYSDATE,
 SYSDATE,
 SYSDATE,
 SYSDATE,
 'First Time Enrollment',
 1,
 0,
 'English',
 l_enrollment_status,
 1,
 ip_next_charge_date,--l_nxt_chrge_date,
 SYSDATE,
 'web2',
 ip_pgm_param_objid,
 (SELECT objid
 FROM
 (SELECT objid
 FROM table_site_part
 WHERE x_service_id = ip_esn
 AND part_status NOT IN ('Inactive','Obsolete')
 ORDER BY install_date DESC
 )
 WHERE rownum = 1
 ),
 (SELECT objid
 FROM table_part_inst
 WHERE x_domain = 'PHONES'
 AND part_serial_no = ip_esn
 ),
 (SELECT web_user2contact FROM table_web_user WHERE objid = ip_web_user_objid
 ),
 ip_web_user_objid,
 ip_payment_src_objid,
 1,
 0,
	 0
 );
 --dbms_output.put_line ('Insert into x_program_enrolled Finish');
 -------------------------Insert a record in x_program_dealer_info (CR 44929) --------------------------------
 --CR44929 - Auto Refill Solution for Indirect Channel - Simple Mobile and insert the records when dealer id is not NULL.
 IF ip_dealer_id IS NOT NULL THEN

 --CR 44929 Get the Brand name (Simple Mobile).
 BEGIN
 SELECT bo.org_id
 INTO l_brand
 FROM x_program_parameters pp,
 table_bus_org bo
 WHERE bo.objid = pp.prog_param2bus_org
 AND pp.objid = ip_pgm_param_objid
 AND bo.org_id = 'SIMPLE_MOBILE';
 EXCEPTION
 WHEN OTHERS THEN
 l_brand := NULL;
 END;

 IF l_brand = 'SIMPLE_MOBILE' THEN
 BEGIN
 SELECT pcrf_subscriber_id,
 pcrf_group_id
 INTO l_pcrf_subscriber_id,
	 l_pcrf_group_id
 FROM x_subscriber_spr
 WHERE pcrf_esn = ip_esn;

 EXCEPTION
 WHEN OTHERS THEN
 l_pcrf_subscriber_id := NULL;
 l_pcrf_group_id := NULL;
 END;

 INSERT
 INTO x_program_dealer_info
 (
 objid,
 x_dealer_id,
 x_esn,
 x_enrolled_date,
 x_created_date,
 x_enrollment_status,
 pgm_dealer2pgm_parameter,
	pcrf_subscriber_id,
	pcrf_group_id
 )
 VALUES
 (
 l_dealer_seq, --objid
 ip_dealer_id, --x_dealer_id
 ip_esn, --x_esn
 l_sysdate, --x_enrolled_date
 l_sysdate, --x_created_date
 'ENROLLED', --x_enrollment_status
 ip_pgm_param_objid, --pgm_dealer2pgm_parameter
	l_pcrf_subscriber_id, --pcrf_subscriber_id
	l_pcrf_group_id --pcrf_group_id
 );
 END IF; --l_brand = 'SIMPLE_MOBILE'
 END IF; --ip_dealer_id IS NOT NULL

 --dbms_output.put_line ('Insert into x_program_dealer_info Finish');
 ----------------CR35567 Start - B2B recurring promotion ------------------------
 IF UPPER(L_PGM_PARAM_NAME) LIKE '%B2B%' THEN
	DBMS_OUTPUT.PUT_LINE('Checking if this is a B2B program:'||L_PGM_PARAM_NAME);
	LV_PROMO_OBJID := NULL;
	LV_PROMO_CODE := NULL;
	LV_SCRIPT_ID := NULL;
	LV_ERROR_CODE := NULL;
	LV_ERROR_MSG := NULL;
	-- todo: check for no data found error and other errors..
	-- insert into x_billing_log

 IF ip_partner_name IS NULL THEN
 sa.ENROLL_PROMO_PKG.SP_GET_ELIGIBLE_PROMO(
		P_ESN => IP_ESN,
		P_PROGRAM_OBJID => L_PGM_PARAM_OBJID,
		P_PROCESS => 'RECURRING',
		P_PROMO_OBJID => LV_PROMO_OBJID,
		P_PROMO_CODE => LV_PROMO_CODE,
		P_SCRIPT_ID => LV_SCRIPT_ID,
		P_ERROR_CODE => LV_ERROR_CODE,
		P_ERROR_MSG => LV_ERROR_MSG
		);
 ELSE
 sa.promotion_pkg.get_authenticated_promos (
 i_esn => ip_esn,
 i_program_objid => l_pgm_param_objid,
 i_partner_name => ip_partner_name,
 i_ar_promo_flag => 'Y',
 o_promo_objid => lv_promo_objid,
 o_promo_code => lv_promo_code,
 o_script_id => lv_script_id,
 o_error_code => lv_error_code,
 o_error_msg => lv_error_msg,
 i_ignore_attached_promo => 'N'
 );
 END IF;
	IF LV_PROMO_OBJID IS NOT NULL THEN
		DBMS_OUTPUT.PUT_LINE('Calling SP_REGISTER_ESN_PROMO procedure to register promo:'||LV_PROMO_OBJID);
		sa.ENROLL_PROMO_PKG.SP_REGISTER_ESN_PROMO(
			P_ESN => IP_ESN,
			P_PROMO_OBJID => LV_PROMO_OBJID,
			P_PROGRAM_ENROLLED_OBJID => L_ENROLL_SEQ,
			P_ERROR_CODE => LV_ERROR_CODE,
			P_ERROR_MSG => LV_ERROR_MSG
		 );
	END IF;
 END IF;
 ----------------CR35567 End - B2B recurring promotion ------------------------

 -- Insert a record in x_program_purch_hdr
 --dbms_output.put_line ('Insert into x_program_purch_hdr Starts');
 OPEN CUR_PYMT_SOURCE_ZIP (ip_payment_src_objid);
 --FETCH CUR_PYMT_SOURCE_ZIP INTO L_BILL_ZIP;	-- Commented by Rahul for CR34597
 FETCH CUR_PYMT_SOURCE_ZIP INTO L_BILL_ZIP,V_FIRST_NAME,V_LAST_NAME,V_PHONE,V_E_MAIL,V_ADDRESS_1,V_ADDRESS_2,V_CITY,V_STATE,V_COUNTRY; -- Modified by Rahul for CR34597
 IF CUR_PYMT_SOURCE_ZIP%NOTFOUND
 THEN
 L_BILL_ZIP 		:= rec_table_contact.zipcode;
	-- Start added by Rahul for CR34597
	V_FIRST_NAME	:= rec_table_contact.first_name;
	V_LAST_NAME		:= rec_table_contact.last_name;
	V_PHONE			:= rec_table_contact.phone;
	V_E_MAIL		:= rec_table_contact.e_mail;
	V_ADDRESS_1		:= rec_table_contact.address_1;
	V_ADDRESS_2		:= rec_table_contact.address_2;
	V_CITY			:= rec_table_contact.city;
	V_STATE			:= rec_table_contact.state;
	-- End added by Rahul for CR34597


 END IF;
 CLOSE CUR_PYMT_SOURCE_ZIP;
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
 x_esn,
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
 x_rcrf_tax_amount, --CR11553
 x_process_date
 )
 VALUES
 (
 l_purch_hdr_seq,
 ip_sourcesystem,
 rec_x_pymt_src.x_pymt_type
 ||'_PURCH',
 SYSDATE,
 NULL,
 NULL,
 sa.merchant_ref_number,
 'offer0',
 1,
 NULL,
 NULL,
 NULL,
 'YES',
 NULL,
 NULL,
 'False',
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 1,
 'SOK',
 'Request was processed successfully.',
 NULL,
 'X',
 NULL,
 NULL,
 1,
 'SOK',
 'Request was processed successfully.',
 NULL,
 1,
 'SOK',
 'Request was processed successfully.',
 NULL,
	 /* Commented by Rahul for CR34597
 NVL(rec_table_contact.first_name, 'No Name Provided'),
 NVL(rec_table_contact.last_name, 'No Name Provided'),
 rec_table_contact.phone,
 rec_table_contact.e_mail,--'null@cybersource.com',
 'SUCCESS', --l_status,
 NVL(rec_table_contact.address_1, 'No Address Provided'),
 NVL(rec_table_contact.address_2, 'No Address Provided'),
 rec_table_contact.city,
 rec_table_contact.state,
	 */
	 -- Start added by Rahul for CR34597
	 NVL(V_FIRST_NAME, 'No Name Provided'),
 NVL(V_LAST_NAME, 'No Name Provided'),
 V_PHONE,
 V_E_MAIL,--'null@cybersource.com',
 'SUCCESS', --l_status,
 NVL(V_ADDRESS_1, 'No Address Provided'),
 NVL(V_ADDRESS_2, 'No Address Provided'),
 V_CITY,
 V_STATE,
	 -- End added by Rahul for CR34597
 L_BILL_ZIP, -- rec_table_contact.zipcode,
 'USA',
 ip_esn,
 0,
 0,
 0,
 0,
 0,
 'web2',
 NULL,
 rec_x_pymt_src.pymt_src2x_credit_card,
 rec_x_pymt_src.pymt_src2x_bank_account,
 NULL,
 NULL,
 148,
 NULL,
 ip_payment_src_objid,
 ip_web_user_objid,
 NULL,
 'ENROLLMENT',
 0,
 0,
 SYSDATE
 );
 --dbms_output.put_line ('Insert into x_program_purch_hdr Finish');
 -- Insert a record in x_program_purch_dtl
 --dbms_output.put_line ('Insert into x_program_purch_dtl Starts');
 INSERT
 INTO x_program_purch_dtl
 (
 objid,
 x_esn,
 x_amount,
 x_tax_amount,
 x_e911_tax_amount,
 x_usf_taxamount,
 x_rcrf_tax_amount, --CR11553
 x_charge_desc,
 x_cycle_start_date,
 x_cycle_end_date,
 pgm_purch_dtl2pgm_enrolled,
 pgm_purch_dtl2prog_hdr
 )
 VALUES
 (
 l_purch_dtl_seq,
 ip_esn,
 0,
 0,
 0,
 0,
 0,
 'First Time Enrollment Charges',
 TRUNC (SYSDATE),
 TRUNC (SYSDATE) + 30,
 l_enroll_seq,
 l_purch_hdr_seq
 );
 --dbms_output.put_line ('Insert into x_program_purch_dtl Finish');
 ---------------- Get the program enrolled for program trans ---------------------------------------------
 -- Insert a record in x_program_trans
 --dbms_output.put_line ('Insert into x_program_trans Starts');
 INSERT
 INTO x_program_trans
 (
 objid,
 x_enrollment_status,
 x_enroll_status_reason,
 x_float_given,
 x_cooling_given,
 x_grace_period_given,
 x_trans_date,
 x_action_text,
 x_action_type,
 x_reason,
 x_sourcesystem,
 x_esn,--x_exp_date,x_cooling_exp_date,
 x_update_user,
 pgm_tran2pgm_entrolled,
 pgm_trans2web_user,
 pgm_trans2site_part
 )
 VALUES
 (
 l_prgm_trans_seq,
 l_enrollment_status,
 'First Time Enrollment',
 NULL,
 NULL,
 NULL,
 SYSDATE,
 'Enrollment Attempt',
 'ENROLLMENT',
 l_pgm_param_name
 || ' $'
 ||l_enroll_fee
 ||'.00',
 ip_sourcesystem,
 ip_esn,--SYSDATE,SYSDATE,
 'web2',
 l_enroll_seq,
 ip_web_user_objid,
 (SELECT objid
 FROM
 (SELECT objid
 FROM table_site_part
 WHERE x_service_id = ip_esn
 AND part_status NOT IN ('Inactive','Obsolete')
 ORDER BY install_date DESC
 )
 WHERE rownum = 1
 )
 );
 --dbms_output.put_line ('Insert into x_program_trans Finish');
 ---------------- Insert a billing Log ------------------------------------------------------------
 -- Insert a record in x_billing_log
 --dbms_output.put_line ('Insert into x_billing_log Starts');
 INSERT
 INTO x_billing_log
 (
 objid,
 x_log_category,
 x_log_title,
 x_log_date,
 x_details,
 x_program_name,
 x_nickname,
 x_esn,
 x_originator,
 x_contact_first_name,
 x_contact_last_name,
 x_agent_name,
 x_sourcesystem,
 billing_log2web_user
 )
 VALUES
 (
 l_billing_log_seq,
 'Program',
 'Program Enrolled',
 SYSDATE,
 'Successfully Enrolled in '
 || l_pgm_param_name,
 l_pgm_param_name,
 billing_getnickname (ip_esn),
 ip_esn,
 'web2',
	 /* Commented by Rahul for CR34597
 NVL(rec_table_contact.first_name, 'No Name Provided'),
 NVL(rec_table_contact.last_name, 'No Name Provided'),
	 */
	 -- Start added by Rahul for CR34597
	 NVL(V_FIRST_NAME, 'No Name Provided'),
 NVL(V_LAST_NAME, 'No Name Provided'),
	 -- End added by Rahul for CR34597
 'web2',
 ip_sourcesystem,
 ip_web_user_objid
 );
 IF l_enrollment_status IN ('ENROLLMENTPENDING') THEN
 BEGIN
 clarify_case_pkg.create_case(p_title => 'ENROLLMENT PENDING' ,p_case_type => 'Value Plan' ,p_status => 'ENROLLMENT PENDING' ,p_priority => 'Low' ,p_issue => '' ,p_source => 'BILLING_INSERTS' ,p_point_contact => 'BILLING_INSERTS' ,p_creation_time => SYSDATE ,p_task_objid => 0 ,p_contact_objid => rec_table_contact.objid ,p_user_objid => '' --Dont know
 ,p_esn => ip_esn ,p_phone_num => rec_table_contact.phone ,p_first_name => rec_table_contact.first_name ,p_last_name => rec_table_contact.last_name ,p_e_mail => rec_table_contact.e_mail ,p_delivery_type => NULL ,p_address => rec_table_contact.address_1 ,p_city => rec_table_contact.city ,p_state => rec_table_contact.state ,p_zipcode => L_BILL_ZIP --rec_table_contact.zipcode
 ,p_repl_units => 0 ,p_fraud_objid => 0 ,p_case_detail => 'VALUE_PLAN||'||l_enroll_seq --||' PE_OBJID|| '
 ,p_part_request => l_enroll_part_no ,p_id_number => l_case_id --OUT
 ,p_case_objid => l_case_objid --OUT
 ,p_error_no => op_result --OUT
 ,p_error_str => op_msg); --OUT
 -- dbms_output.put_line ('p_id_number:' ||l_case_id);
 -- dbms_output.put_line ('p_case_objid:'||l_case_objid);
 -- dbms_output.put_line ('p_error_str:'||op_msg);
 EXCEPTION
 WHEN OTHERS THEN
 op_result := -1;
 op_msg := 'CASE Not Created';
 raise case_creation;
 END;
 BEGIN
 sa.CLARIFY_CASE_PKG.LOG_NOTES(l_case_objid, 268435556,'B2B Pre_Enroll',NULL,op_result,op_msg);
 EXCEPTION
 WHEN OTHERS THEN
 op_result := -1;
 op_msg := 'CASE Log Not Created';
 raise case_creation;
 END;
 BEGIN
 sa.CLARIFY_CASE_PKG.DISPATCH_CASE(l_case_objid, 268435556, 'TBD' , op_result, op_msg);
 EXCEPTION
 WHEN OTHERS THEN
 op_result := -1;
 op_msg := 'DISPATCH_CASE Not Created';
 raise case_creation;
 END;
 BEGIN
 sa.Clarify_Case_Pkg.close_case (l_case_objid, 268435556, NULL, 'Closed', 'Closed', op_result, op_msg);
 EXCEPTION
 WHEN OTHERS THEN
 op_result := -1;
 op_msg := 'Case Not Closed';
 raise case_creation;
 END;
 END IF;
 --dbms_output.put_line ('Insert into x_billing_log Finish');
 if c_program_name like '%Data Club Plan%B2B' or ip_dataclub_flag = 'Y' THEN
 null;
 else
 commit;
 end if;
 op_result := 0;
 op_msg := 'Inserts are Successful';
EXCEPTION
WHEN esn_is_enrolled THEN
 op_result := 3003;
 op_msg := 'ESN is already Enrolled in'||chk_esn_enrolled_rec.x_program_name;
 DBMS_OUTPUT.put_line (op_result ||','||op_msg);
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
 'SA.Billing_Inserts_Pkg.Inserts_Billing_Proc',
 op_result,
 op_msg,
 SYSDATE,
 'ESN is already Enrolled in a Program',
 2 -- MEDIUM
 );
WHEN chk_cc_blklstd THEN
 op_result := 3001;
 op_msg := 'Please choose another funding source.This funding source can not be used.';
 DBMS_OUTPUT.put_line (op_result ||','||op_msg);
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
 'Billing_Inserts_Pkg.Inserts_Billing_Proc',
 op_result,
 op_msg,
 SYSDATE,
 'The Credit Card used is Black Listed. Please contact fraud department',
 2 -- MEDIUM
 );
WHEN case_creation THEN
 --op_result := -1;
 --op_msg := 'CASE Not Created';
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
 'Billing_Inserts_Pkg.Inserts_Billing_Proc',
 op_result,
 op_msg,
 SYSDATE,
 'Case Creation Exception',
 2 -- MEDIUM
 );
WHEN NO_DATA_FOUND THEN
 DBMS_OUTPUT.put_line ('Error ' || TO_CHAR (SQLCODE) || ': ' || SQLERRM);
 op_result := 3002; -- No Data Found
 op_msg := SUBSTR (SQLERRM, 1, 100);
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
 'Billing_Inserts_Pkg.Inserts_Billing_Proc',
 op_result,
 op_msg,
 SYSDATE,
 'No data found error',
 2 -- MEDIUM
 );
WHEN OTHERS THEN
 ROLLBACK;
 --dbms_output.put_line ('RollBack all the Inserts as an error occured while inserting into one of the tables ');
 DBMS_OUTPUT.put_line ('Error ' || TO_CHAR (SQLCODE) || ': ' || SQLERRM);
 op_result := 3000; -- Failed
 op_msg := SUBSTR (SQLERRM, 1, 100);
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
 'Billing_Inserts_Pkg.Inserts_Billing_Proc',
 op_result,
 op_msg,
 SYSDATE,
 'Enrollement without payment for '
 || ip_esn
 || ' Failed',
 2 -- MEDIUM
 );
END inserts_billing_proc;
 --START: CR49058 Overloading inserts_billing_proc procedure to add the o_program_enrol_objid output variable.
 PROCEDURE inserts_billing_proc ( ip_esn                 IN  VARCHAR2                  ,
                                  ip_pgm_param_objid     IN  NUMBER                    ,
                                  ip_web_user_objid      IN  NUMBER                    ,
                                  ip_payment_src_objid   IN  NUMBER                    ,
                                  ip_next_charge_date    IN  DATE                      ,
                                  ip_sourcesystem        IN  VARCHAR2                  ,
                                  op_result              OUT NUMBER                    ,
                                  op_msg                 OUT VARCHAR2                  ,
                                  ip_enrollment_status   IN  VARCHAR2 DEFAULT NULL     ,
                                  ip_dataclub_flag       IN  VARCHAR2 DEFAULT 'N'      ,
                                  ip_dealer_id           IN  VARCHAR2 DEFAULT NULL     ,
                                  ip_partner_name        IN  VARCHAR2 DEFAULT NULL     ,
                                  o_program_enroll_objid OUT NUMBER                    )
AS
BEGIN

  inserts_billing_proc ( ip_esn                 => ip_esn,
                         ip_pgm_param_objid     => ip_pgm_param_objid,
                         ip_web_user_objid      => ip_web_user_objid,
                         ip_payment_src_objid   => ip_payment_src_objid,
                         ip_next_charge_date    => ip_next_charge_date,
                         ip_sourcesystem        => ip_sourcesystem,
                         op_result              => op_result,
                         op_msg                 => op_msg,
                         ip_enrollment_status   => ip_enrollment_status,
                         ip_dataclub_flag       => ip_dataclub_flag,
                         ip_dealer_id           => ip_dealer_id,
                         ip_partner_name        => ip_partner_name );

  IF op_result <> 0
  THEN
	  RETURN;
  END IF;

  BEGIN
    SELECT objid
    INTO   o_program_enroll_objid
    FROM   x_program_enrolled
    WHERE  x_esn = ip_esn
    AND    x_sourcesystem = ip_sourcesystem
    AND    pgm_enroll2pgm_parameter = ip_pgm_param_objid
    AND    x_enrollment_status = 'ENROLLED';
  EXCEPTION
  WHEN OTHERS
  THEN
    op_result := 3000; -- Failed
    op_msg := SUBSTR (SQLERRM, 1, 100);
  END;

END inserts_billing_proc;
  --END: CR49058

  --CR48643
FUNCTION get_purch_history_for_device(
  i_esn  IN  VARCHAR2
 ,i_min  IN  VARCHAR2
)
  RETURN sys_refcursor
IS
  ret_curs  sys_refcursor;
  cst  sa.customer_type := sa.customer_type;
  grp  sa.group_type    := sa.group_type;
  c_errr_msg  VARCHAR2(4000);
BEGIN
  OPEN ret_curs FOR
  SELECT NULL amount,
         NULL discamount,
         NULL transactiondate,
         NULL accounttype,
         NULL last4digit,
         NULL transactionnumber,
         NULL refund_id,
         NULL transaction_type,
         NULL transaction_status,
         NULL group_nick_name,
         NULL device_nickname,
         NULL min,
         NULL error_message
  FROM DUAL;
  IF i_esn IS NULL AND i_min IS NULL
  THEN
    DBMS_OUTPUT.PUT_LINE('ESN AND MIN NULL');
      OPEN ret_curs FOR
      SELECT NULL amount,
             NULL discamount,
             NULL transactiondate,
             NULL accounttype,
             NULL last4digit,
             NULL transactionnumber,
             NULL refund_id,
             NULL transaction_type,
             NULL transaction_status,
             NULL group_nick_name,
             NULL device_nickname,
             NULL min,
             'ESN AND MIN NULL' error_message
      FROM DUAL;
    RETURN ret_curs;
  END IF;
  IF i_esn IS NOT NULL THEN
    cst     := sa.customer_type(i_esn => i_esn);
    cst.min := cst.get_min(i_esn => i_esn);
    IF cst.min IS NULL OR cst.min != NVL(i_min,cst.min)
    THEN
      DBMS_OUTPUT.PUT_LINE('ESN AND MIN COMBINATION INVALID');
      OPEN ret_curs FOR
      SELECT NULL amount,
             NULL discamount,
             NULL transactiondate,
             NULL accounttype,
             NULL last4digit,
             NULL transactionnumber,
             NULL refund_id,
             NULL transaction_type,
             NULL transaction_status,
             NULL group_nick_name,
             NULL device_nickname,
             NULL min,
             'ESN AND MIN COMBINATION INVALID' error_message
      FROM DUAL;
      RETURN ret_curs;
    END IF;
  ELSIF i_min IS NOT NULL THEN
    cst     := sa.customer_type(i_esn => null, i_min => i_min);
    cst.esn := cst.get_esn(i_min => i_min);
    IF cst.esn IS NULL OR cst.esn != NVL(i_esn,cst.esn)
    THEN
      DBMS_OUTPUT.PUT_LINE('MIN AND ESN COMBINATION INVALID');
      OPEN ret_curs FOR
      SELECT NULL amount,
             NULL discamount,
             NULL transactiondate,
             NULL accounttype,
             NULL last4digit,
             NULL transactionnumber,
             NULL refund_id,
             NULL transaction_type,
             NULL transaction_status,
             NULL group_nick_name,
             NULL device_nickname,
             NULL min,
             'MIN AND ESN COMBINATION INVALID' error_message
      FROM DUAL;
      RETURN ret_curs;
    END IF;
  END IF;
  cst := cst.get_web_user_attributes;
  grp := sa.group_type(i_esn => cst.esn);
  IF cst.web_user_objid IS NULL
  THEN
     DBMS_OUTPUT.PUT_LINE('WEBUSER NOT FOUND');
     OPEN ret_curs FOR
      SELECT NULL amount,
             NULL discamount,
             NULL transactiondate,
             NULL accounttype,
             NULL last4digit,
             NULL transactionnumber,
             NULL refund_id,
             NULL transaction_type,
             NULL transaction_status,
             NULL group_nick_name,
             NULL device_nickname,
             NULL min,
             'WEBUSER NOT FOUND' error_message
      FROM DUAL;
     RETURN ret_curs;
  END IF;
  OPEN ret_curs FOR
    SELECT                                                          --  a.objid
           TO_CHAR((  NVL(a.x_amount, 0)
                    + NVL(a.x_tax_amount, 0)
                    + NVL(a.x_e911_tax_amount, 0)
                    + NVL(a.x_usf_taxamount, 0)
                    + NVL(a.x_rcrf_tax_amount, 0)
                   )
                  ,'999999999990.99') amount
          ,TO_CHAR(a.x_discount_amount,'999999999990.99')  discamount
          ,CASE
             WHEN a.x_rqst_date > SYSDATE
               THEN a.x_bill_request_time
             ELSE TO_char (a.x_rqst_date, 'MM/dd/yyyy hh24:mi:ss')
           END transactiondate
          ,DECODE(x_rqst_type
                 ,'CREDITCARD_PURCH', b.x_cc_type
                 ,'ACH_PURCH', 'ACH'
                 ,'CREDITCARD_REFUND', b.x_cc_type
                 ) accounttype
          ,DECODE(x_rqst_type
                 ,'CREDITCARD_PURCH', SUBSTR(b.x_customer_cc_number, -4)
                 ,'ACH_PURCH', SUBSTR(c.x_customer_acct, -4)
                 ,'CREDITCARD_REFUND', SUBSTR(b.x_customer_cc_number, -4)
                 ) last4digit
          ,a.x_merchant_ref_number transactionnumber
          ,CASE
             WHEN(a.x_payment_type = 'REFUND')
               THEN a.x_bill_trans_ref_no
             ELSE NULL
           END refund_id
          ,CASE
             WHEN(a.x_payment_type = 'REFUND')
               THEN 'Refund'
             ELSE 'Airtime Purchase'
           END transaction_type
          ,CASE
             WHEN(x_rqst_type = 'CREDITCARD_PURCH' OR x_rqst_type = 'ACH_PURCH'
                 )
               THEN CASE
                     WHEN(a.x_status LIKE 'CHARGEBACK%')
                       THEN 'Chargeback'
                     WHEN(    (   a.x_ics_rcode = '1'
                               OR a.x_ics_rcode = '100'
                               OR a.x_ics_rcode IS NULL
                              )
                          AND a.x_status LIKE '%PENDING'
                         )
                       THEN 'Pending Response'
                     WHEN(a.x_ics_rcode IS NULL)
                       THEN 'Pending Response'
                     WHEN((a.x_ics_rcode = '1' OR a.x_ics_rcode = '100'))
                       THEN 'Approved'
                     WHEN(a.x_status LIKE 'SUBMITTED')
                       THEN 'Pending Response'
                     WHEN(a.x_status LIKE 'INCOMPLETE')
                       THEN 'Incomplete'
                     ELSE 'Declined'
                   END
             ELSE CASE
             WHEN(a.x_ics_rcode = '1')
               THEN 'Refund Approved'
             WHEN(a.x_ics_rcode = '0')
               THEN 'Refund Declined'
             ELSE 'Refund Declined'
           END
           END transaction_status
          ,grp.account_group_name group_nick_name
          ,billing_getnickname(dtl.x_esn) device_nickname
          ,cst.min MIN                                                      --> min
          ,'SUCCESS' error_message
    FROM   x_program_purch_hdr a
          ,x_program_purch_dtl dtl
          ,x_payment_source d
          ,table_x_credit_card b
          ,table_x_bank_account c
    WHERE  1 = 1
    AND    a.objid = dtl.pgm_purch_dtl2prog_hdr
    AND    a.x_payment_type != 'REDEBIT'
    AND    a.x_amount IS NOT NULL
    AND    a.prog_hdr2x_pymt_src = d.objid
    AND    d.pymt_src2x_credit_card = b.objid(+)
    AND    d.pymt_src2x_bank_account = c.objid(+)
    AND    a.prog_hdr2web_user = cst.web_user_objid
    AND    dtl.x_esn   = cst.esn
    UNION ALL
    SELECT TO_CHAR((  NVL(ph.x_amount, 0)
                    + NVL(ph.x_tax_amount, 0)
                    + NVL(ph.x_e911_amount, 0)
                    + NVL(ph.x_usf_taxamount, 0)
                    + NVL(ph.x_rcrf_tax_amount, 0)
                   )
                  ,'999999999990.99') amount
          ,TO_CHAR(ph.x_discount_amount,'999999999990.99')  discamount
          ,CASE
             WHEN ph.x_rqst_date > SYSDATE
               THEN ph.x_bill_request_time
             ELSE TO_CHAR(ph.x_rqst_date, 'MM/dd/yyyy hh24:mi:ss')
           END transactiondate
          ,cc.x_cc_type
          ,SUBSTR(cc.x_customer_cc_number, -4)
          ,ph.x_merchant_ref_number transactionnumber
          ,CASE
             WHEN x_rqst_type = 'cc_refund'
               THEN ph.x_bill_trans_ref_no
             ELSE NULL
           END refund_id
          ,CASE
             WHEN x_rqst_type = 'cc_refund'
               THEN 'Refund'
             ELSE 'Airtime Purchase'
           END transaction_type
          ,CASE
             WHEN x_rqst_type = 'cc_purch'
               THEN CASE
                     WHEN(    (   ph.x_ics_rcode = '1'
                               OR ph.x_ics_rcode = '100'
                               OR ph.x_ics_rcode IS NULL
                              )
                          AND ph.x_ics_rflag LIKE '%Pending'
                         )
                       THEN 'Pending Response'
                     WHEN(ph.x_ics_rflag IS NULL OR ph.x_ics_rflag LIKE '%Pending')
                       THEN 'Pending Response'
                     WHEN(ph.x_ics_rcode IN('1', '100'))
                       THEN 'Approved'
                     WHEN(ph.x_ics_rflag LIKE '%INCOMPLETE')
                       THEN 'InComplete'
                     WHEN(ph.x_ics_rcode NOT IN('1', '100'))
                       THEN 'Declined'
                     ELSE ''
                   END
             WHEN x_rqst_type = 'cc_refund'
               THEN CASE
                     WHEN(ph.x_ics_rcode = '1')
                       THEN 'Refund Approved'
                     WHEN(ph.x_ics_rcode = '0')
                       THEN 'Refund Declined'
                     ELSE 'Refund Declined'
                   END
           END status
          ,grp.account_group_name group_nick_name
          ,billing_getnickname(ph.x_esn) device_nickname
          ,cst.min MIN
          ,'SUCCESS' error_message
    FROM   table_x_purch_hdr ph
          ,table_x_credit_card cc
          ,table_web_user web
          ,table_x_contact_part_inst cpi
          ,table_part_inst pi
    WHERE  1 = 1
    AND    ph.x_amount IS NOT NULL
    AND    ph.x_esn = pi.part_serial_no
    AND    pi.objid = cpi.x_contact_part_inst2part_inst
    AND    ph.x_purch_hdr2creditcard = cc.objid
    AND    cpi.x_contact_part_inst2contact = web.web_user2contact
    AND    web.objid = cst.web_user_objid
    AND    ph.x_esn   = cst.esn
    UNION ALL
    SELECT TO_CHAR(ph.x_auth_amount, '999999999990.99') amount
          ,TO_CHAR(0, '999999999990.99') discamount
          ,CASE
             WHEN ph.x_rqst_date > SYSDATE
               THEN ph.x_bill_request_time
             ELSE TO_CHAR(ph.x_rqst_date, 'MM/dd/yyyy hh24:mi:ss')
           END transactiondate
          ,cc.x_cc_type accounttype
          ,SUBSTR(cc.x_customer_cc_number, -4) fundingsource
          ,ph.x_merchant_ref_number transactionnumber
          ,CASE
             WHEN x_rqst_type = 'CREDITCARD_REFUND'
               THEN ph.x_bill_trans_ref_no
             ELSE NULL
           END refund_id
          ,CASE
             WHEN x_rqst_type = 'CREDITCARD_REFUND'
               THEN 'Refund'
             ELSE 'Airtime Purchase'
           END transaction_type
          ,CASE
             WHEN x_rqst_type = 'CREDITCARD_PURCH'
               THEN CASE
                     WHEN(    (   ph.x_ics_rcode = '1'
                               OR ph.x_ics_rcode = '100'
                               OR ph.x_ics_rcode IS NULL
                              )
                          AND ph.x_ics_rflag LIKE '%Pending'
                         )
                       THEN 'Pending Response'
                     WHEN(ph.x_ics_rflag IS NULL OR ph.x_ics_rflag LIKE '%Pending')
                       THEN 'Pending Response'
                     WHEN(ph.x_ics_rcode IN('1', '100'))
                       THEN 'Approved'
                     WHEN(ph.x_ics_rflag LIKE '%INCOMPLETE')
                       THEN 'InComplete'
                     WHEN(ph.x_ics_rcode NOT IN('1', '100'))
                       THEN 'Declined'
                     ELSE ''
                   END
             WHEN x_rqst_type = 'CREDITCARD_REFUND'
               THEN CASE
                     WHEN(ph.x_ics_rcode = '1')
                       THEN 'Refund Approved'
                     WHEN(ph.x_ics_rcode = '0')
                       THEN 'Refund Declined'
                     ELSE 'Refund Declined'
                   END
           END status
          ,grp.account_group_name group_nick_name
          ,billing_getnickname(ph.x_esn) nickname
          ,cst.min MIN
          ,'SUCCESS' error_message
    FROM   x_biz_purch_hdr ph
          ,table_x_credit_card cc
          ,table_web_user web
          ,table_x_contact_part_inst cpi
          ,table_part_inst pi
    WHERE  1 = 1
    AND    ph.x_amount IS NOT NULL
    AND    ph.x_esn = pi.part_serial_no
    AND    pi.objid = cpi.x_contact_part_inst2part_inst
    AND    ph.purch_hdr2creditcard = cc.objid
    AND    cpi.x_contact_part_inst2contact = web.web_user2contact
    AND    ph.x_ics_applications IN('ics_auth', 'ics_credit')
    AND    web.objid = cst.web_user_objid -- 581129709;
    AND    ph.x_esn  =  cst.esn;
    return ret_curs;
   EXCEPTION
   WHEN OTHERS THEN
     c_errr_msg := dbms_utility.format_error_backtrace;
     OPEN ret_curs FOR
     SELECT NULL amount,
            NULL discamount,
            NULL transactiondate,
            NULL accounttype,
            NULL last4digit,
            NULL transactionnumber,
            NULL refund_id,
            NULL transaction_type,
            NULL transaction_status,
            NULL group_nick_name,
            NULL device_nickname,
            NULL min,
            c_errr_msg error_message
  FROM DUAL;
END get_purch_history_for_device;


END billing_inserts_pkg;
-- ANTHILL_TEST PLSQL/SA/PackageBodies/BILLING_INSERTS_PKb.sql CR30255: 1.6
/