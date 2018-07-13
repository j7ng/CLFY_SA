CREATE OR REPLACE PACKAGE BODY sa."BILLING_LIFELINE_MONTHLY_PKG" IS
 --
 ---------------------------------------------------------------------------------------------
 --$RCSfile: Billing_lifeline_monthly_pkg.sql,v $
 --$Revision: 1.14 $
 --$Author: arijal $
 --$Date: 2015/06/18 22:38:52 $
 --$ $Log: Billing_lifeline_monthly_pkg.sql,v $
 --$ Revision 1.14  2015/06/18 22:38:52  arijal
 --$ CR33124 SL BYOP
 --$
 --$ Revision 1.13  2015/01/20 20:40:39  arijal
 --$ CR31545 SL CA HOME PHONE packages ota issue
 --$
 --$ Revision 1.12  2014/11/21 01:14:03  arijal
 --$ CR29866-CR30295 SafeLink California Existing Pkg Body billing lifeline monthly
 --$
  --$ Revision 1.10  2014/03/11 15:11:51  ymillan
  --$ CR26591
  --$
  --$ Revision 1.9  2011/11/14 21:00:07  kacosta
  --$ CR16984 SafeLink New Airtime Cards
  --$
  --$ Revision 1.8  2011/11/09 22:43:10  kacosta
  --$ CR16984 SafeLink New Airtime Cards
  --$
  --$ Revision 1.7  2011/11/09 19:59:03  kacosta
  --$ CR16984 SafeLink New Airtime Cards
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
 FUNCTION IS_LIFELINE_CUSTOMER(
 p_esn IN VARCHAR2
 )
 RETURN NUMBER
 IS
 l_count NUMBER := 0;
 BEGIN
 IF p_esn IS NULL
 THEN
 DBMS_OUTPUT.PUT_LINE('ESN is NULL. Fix it ...');
 RETURN l_count;
-- ESN Not Found
 END IF;
 -- Just see if any records on x_program_enrolled
 SELECT COUNT(1)
 INTO l_count
 FROM X_PROGRAM_ENROLLED ENROLL, X_PROGRAM_PARAMETERS PARAM
 WHERE 1 = 1
 AND ENROLL.X_ESN = p_esn
 AND X_ENROLLMENT_STATUS = 'ENROLLED'
 AND PARAM.X_PROG_CLASS = 'LIFELINE'
 AND ENROLL.PGM_ENROLL2PGM_PARAMETER = PARAM.OBJID;
 RETURN l_count ;
 EXCEPTION
 WHEN OTHERS
 THEN
 RETURN 0 ;
-- Returns FALSE
 END IS_LIFELINE_CUSTOMER;

 PROCEDURE DELIVER_RECURRING_MINUTES_M(
 ip_x_ota_trans_id IN NUMBER,
 future_days IN NUMBER,
 l_batch_id IN Number, -- input batch id proccess month
 batch_id OUT VARCHAR2, -- output batch id proccess
 op_result OUT VARCHAR2, -- Output Result
 op_msg OUT VARCHAR2 -- Output Message
 )
 IS

 -- Variable Declarations
 l_lifeline_eligible NUMBER := 0 ;
 l_site_part_objid table_site_part.objid%TYPE;
 l_prog_purch_objid NUMBER := 0;
 l_sales_tax_percent NUMBER := 0;
 l_e911_tax_percent NUMBER := 0;
 l_tax NUMBER := 0;
 l_e911_tax NUMBER := 0;
 l_usf_tax NUMBER := 0; --CR11553
 l_rcrf_tax NUMBER := 0; --CR11553
 l_next_delivery_date DATE;
 v_start_date date;
 v_end_date date;
 v_batch_id varchar2(50) :='';
 v_count number := 0;
 -----------------------------------------------------------------------------------------------
 -- Cursor Declarations
 -- Cursor # 1
 -- Fetch all Lifeline Customers whose delivery date is today.
 CURSOR lifeline_enroll_cur
 IS
 SELECT /*+ PARALLEL(a,8) */
 DISTINCT -- CR11547
 a.objid,
 a.x_esn,
 b.x_type,
 a.x_delivery_cycle_number,
 a.x_enrollment_status,
 a.x_is_grp_primary,
 a.x_next_delivery_date,
 a.pgm_enroll2pgm_parameter,
 b.x_incl_service_days,
 b.x_delivery_frq_code,
 b.x_promo_incl_min_at,
 b.x_promo_incr_min_at,
 a.x_wait_exp_date,
 b.x_promo_incl_grpmin_at,
 b.x_promo_incr_grpmin_at,
 b.x_incr_minutes_dlv_cyl,
 b.x_incr_minutes_dlv_days,
 b.x_incr_grp_minutes_dlv_cyl,
 b.x_incr_grp_minutes_dlv_days,
 b.x_stack_dur_enroll,
 a.pgm_enroll2site_part,
 a.pgm_enroll2x_promotion,
 b.prog_param2bus_org,
 a.pgm_enroll2web_user,
 b.x_program_name,
 a.X_TOT_GRACE_PERIOD_GIVEN,
 a.x_amount,
 a.x_sourcesystem,
 c.objid site_part_objid,
 --CR16984 Start kacosta 09/30/2011
 --case when b.x_sweep_and_add_flag =1 --CR12369
 --and exists (select 1
 --from table_x_red_card rc,
 --table_x_call_trans ct
 --where 1=1
 --and upper(rc.X_RESULT) = 'COMPLETED'
 --and ct.x_transact_date+0 > sysdate -(select nvl(x_param_value,0) from table_x_parameters where x_param_name = 'SAFELINK_GENCODES_DAYS_AHEAD')
 --and rc.RED_CARD2CALL_TRANS = ct.objid
 --and ct.CALL_TRANS2SITE_PART= c.objid) then
 --4 --CR12369
 --else
 --b.X_SWEEP_AND_ADD_FLAG --CR14175
 --end x_sweep_and_add_flag
 CASE
   WHEN b.x_sweep_and_add_flag = 1
        AND EXISTS (SELECT 1
           FROM table_x_call_trans xct
           JOIN table_x_red_card xrc
             ON xct.objid = xrc.red_card2call_trans
           JOIN table_mod_level tml
             ON xrc.x_red_card2part_mod = tml.objid
           JOIN table_part_num tpn
             ON tml.part_info2part_num = tpn.objid
           JOIN sl_gencodes_days_ahead_view dav
             ON 1 = 1
          WHERE xct.call_trans2site_part = c.objid
            AND xct.x_transact_date > SYSDATE - TO_NUMBER(dav.days_ahead)
            AND UPPER(xrc.x_result) = 'COMPLETED'
            AND dav.promo_code = 'ALL'
            AND dav.part_number = 'ALL'
            AND NOT EXISTS (SELECT 1
                              FROM sl_gencodes_days_ahead_view dav_exception
                              JOIN table_x_promotion txp_promo
                                ON dav_exception.promo_code = txp_promo.x_promo_code
                             WHERE dav_exception.part_number = tpn.part_number
                               AND txp_promo.objid = b.x_promo_incl_min_at)) THEN
    4
   WHEN b.x_sweep_and_add_flag = 1
        AND EXISTS (SELECT 1
           FROM table_x_call_trans xct
           JOIN table_x_red_card xrc
             ON xct.objid = xrc.red_card2call_trans
           JOIN table_mod_level tml
             ON xrc.x_red_card2part_mod = tml.objid
           JOIN table_part_num tpn
             ON tml.part_info2part_num = tpn.objid
           JOIN sl_gencodes_days_ahead_view dav
             ON tpn.part_number = dav.part_number
           JOIN table_x_promotion txp_promo
             ON dav.promo_code = txp_promo.x_promo_code
          WHERE xct.call_trans2site_part = c.objid
            AND UPPER(xrc.x_result) = 'COMPLETED'
            AND xct.x_transact_date > SYSDATE - TO_NUMBER(dav.days_ahead)
            AND txp_promo.objid = b.x_promo_incl_min_at) THEN
    4
   ELSE
    b.x_sweep_and_add_flag
 END x_sweep_and_add_flag
 --CR16984 End kacosta 09/30/2011
 FROM table_site_part c, x_program_parameters b, x_program_enrolled a
 WHERE 1 = 1
 AND c.PART_STATUS||'' = 'Active' -- Take only Active ESN's
 AND c.x_service_id||'' = a.x_esn
 AND c.objid = a.PGM_ENROLL2SITE_PART
 AND B.X_PROG_CLASS = 'LIFELINE' -- Program class should be LIFELINE only
 AND b.x_program_name not in ('Lifeline - Texas State TracFone','Lifeline - Texas State Net10', 'Lifeline - CA - UNL1', 'Lifeline - CA - HUNL1', 'Lifeline - CA - BUNL1') --CR26591 remove regular tx
--CR26591 AND b.x_program_name not in ('Lifeline - TX - 1','Lifeline - TX - 2','Lifeline - TX - 3','Lifeline - Texas State TracFone','Lifeline - Texas State Net10') --CR12417 to accomodate CR12784 requirement
 --CR13940
 --CR30295 SafeLink CA (exclude 'Lifeline - CA - UNL1')
 --CR31988 SL HOME PHONE CA (exclude 'Lifeline - CA - HUNL1')
 --CR33124 SL BYOP (EXCLUDE Lifeline - CA - BUNL1)
 AND b.objid = a.pgm_enroll2pgm_parameter
 AND A.X_NEXT_DELIVERY_DATE < TRUNC(SYSDATE + 1) + future_days -- Since this job runs on 1st day of every m CR10569
 AND (CASE
 WHEN future_days = 0
 THEN
 SYSDATE + 1
 ELSE
 A.X_NEXT_DELIVERY_DATE
 END) >= (CASE
 WHEN future_days = 0
 THEN
 SYSDATE
 ELSE
 TRUNC(SYSDATE + 1)
 END) --CR10569
 AND A.X_ENROLLMENT_STATUS = 'ENROLLED' -- Take only Current Enrolled customers
AND ROWNUM < 500001; -- NEW CHANGE - OCT - NN for production change 500001

 -----------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------
 -----------------------------------------------------------------------------------------------
 -- End of Cursors
 BEGIN
 --DBMS_OUTPUT.put_line ('into principal begin');
 v_start_date:=trunc(sysdate);
 FOR rec1 IN lifeline_enroll_cur
 LOOP
 --DBMS_OUTPUT.put_line ('into loop');
 -- 1. Update the Delivery Cycle Number and also Next Delivery date
 -- For the time being update the last charge date also
 UPDATE x_program_enrolled SET x_delivery_cycle_number = NVL(
 x_delivery_cycle_number, 0) + 1, x_charge_date = TRUNC(SYSDATE) +
 future_days, --CR10569
 -- Drop Next delivery date as 1st date of next month
 --x_next_delivery_date = ADD_MONTHS(x_next_delivery_date ,1)
 x_next_delivery_date = (LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE), (CASE
 WHEN future_days = 0
 THEN
 0
 ELSE
 1
 END))) + 1) -- CR10569
 WHERE objid = rec1.objid;
 --DBMS_OUTPUT.put_line ('after update, before insert ');
 -- 2a. Add procedure call to drop a dummy record on x_program_purch_hdr and x_program_purch_dtl
 -----------------------------------------------------------------------------------------------
 -- 1. Insert record in x_program_purch_hdr
 INSERT
 INTO x_program_purch_hdr(
 objid,
 x_rqst_source,
 x_rqst_type,
 x_rqst_date,
 x_process_date, -- NEW CHANGE - OCT - NN
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
 x_usf_taxamount, --CR11553
 x_rcrf_tax_amount, --CR11553
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
 x_payment_type
 ) VALUES(
 (sa.SEQ_X_PROGRAM_PURCH_HDR.NEXTVAL),
 rec1.x_sourcesystem,
 'LIFELINE_PURCH',
-- SYSDATE + future_days, --CR10569
-- SYSDATE + future_days, -- NEW CHANGE - OCT - NN
TRUNC(SYSDATE + future_days)+0.001* l_batch_id/24, -- CO C5944
TRUNC(SYSDATE + future_days)+0.001* l_batch_id/24, -- CO C5944
 NULL,
 NULL,
 'BPSAFELINK', --sa.merchant_ref_number,
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 'Yes',
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 '100',
 'ACCEPT',
 'ACCEPT',
 NULL,
 NULL,
 NULL,
 NULL,
 '100',
 'ACCEPT',
 'ACCEPT',
 NULL,
 '100',
 'ACCEPT',
 'ACCEPT',
 NULL,
 NULL,
 NULL,
 NULL,
 'null@cybersource.com',
 'LIFELINEPROCESSED',
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 'USA',
 rec1.x_amount,
 l_tax,
 l_e911_tax,
 l_usf_tax, --CR11553
 l_rcrf_tax, --CR11553
 NULL,
 NULL,
 'System',
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 NULL,
 rec1.pgm_enroll2web_user,
 NULL,
 'LL_RECURRING'
 );

 --DBMS_OUTPUT.put_line ('after insert , before insert x_program_purch_dtl');
 -- 2b. Insert record in x_program_purch_dtl
 INSERT
 INTO x_program_purch_dtl(
 objid,
 x_esn,
 x_amount,
 x_tax_amount,
 x_e911_tax_amount,
 x_usf_taxamount,--CR11553
 x_rcrf_tax_amount,--CR11553
 x_charge_desc,
 x_cycle_start_date,
 x_cycle_end_date,
 pgm_purch_dtl2pgm_enrolled,
 pgm_purch_dtl2prog_hdr
 ) VALUES(
 (sa.SEQ_X_PROGRAM_PURCH_DTL.NEXTVAL),
 rec1.x_esn,
 rec1.x_amount,
 l_tax,
 l_e911_tax,
 l_usf_tax,--CR11553
 l_rcrf_tax,--CR11553
 'Charges for Lifelink Wireless Customers',
 (ADD_MONTHS(rec1.x_next_delivery_date, 1)),
 (ADD_MONTHS(rec1.x_next_delivery_date, 2)),
 rec1.objid,
 sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL
 );

 --DBMS_OUTPUT.put_line ('after insert , before insert table_x_pending_redemption');
 -- 3. Insert record into table_x_pending_redemption
 INSERT
 INTO table_x_pending_redemption(
 objid,
 pend_red2x_promotion,
 x_pend_red2site_part,
 x_pend_type,
 pend_redemption2esn,
 x_case_id,
 x_granted_from2x_call_trans,
 PEND_RED2PROG_PURCH_HDR
 ) VALUES(
 (sa.sequ_x_pending_redemption.NEXTVAL),
 rec1.x_promo_incl_min_at,
 rec1.site_part_objid,
 'BPDelivery',
 NULL,
 NULL,
 NULL,
 sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL --rec1.purch_hdr_objid
 );
 -- 4. Insert Record in to x_program_gencode for benefits delivery thru OTA
 -- Make sure this is an OTA enabled phone or carrier
 -- CR10881 NEW INPUT PARAMETER ip_x_ota_trans_id

 --DBMS_OUTPUT.put_line ('after insert , before insert x_program_gencode');
 v_batch_id:=SUBSTR(to_char(sysdate,'MONTH'),1,3)||to_char(sysdate,'YY')||to_char(l_batch_id)||'_QUEUED';

 INSERT
 INTO x_program_gencode(
 objid,
 x_esn,
 x_insert_date,
 x_status,
 GENCODE2PROG_PURCH_HDR,
 x_ota_trans_id,
 X_SWEEP_AND_ADD_FLAG -- CR14175
 ) VALUES(
 (sa.SEQ_X_PROGRAM_GENCODE.NEXTVAL),
 rec1.x_esn,
 SYSDATE + future_days, --CR10569
 v_batch_id,
 sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL, -- rec1.purch_hdr_objid,
 ip_x_ota_trans_id,
 rec1.X_SWEEP_AND_ADD_FLAG -- CR14175
 );

 --DBMS_OUTPUT.put_line ('after insert x_program_gencode, before if sqlrowcount');
 IF SQL%ROWCOUNT > 0 THEN
 v_count:=v_count + 1;
 end if;

 COMMIT;
 END LOOP;

 v_end_date:= SYSDATE;

--DBMS_OUTPUT.put_line ('v_count '||to_char(v_count));
--DBMS_OUTPUT.put_line ('before insert history');
 Insert into X_LIFELINE_HIST_JOB
 (OBJID,
 X_START_DATE,
 X_END_DATE,
 X_BATCH_ID,
 X_ACTION_STATUS,
 X_JOBNAME) values
 (sa.seq_x_lifeline_hist_job.nextval,
 v_start_date,
 v_end_date,
 v_batch_id,
 (CASE WHEN v_count = 0 THEN 'FAILURE' ELSE 'SUCCESS' END),
 'BILLING_LIFELINE_MONTHLY_PKG');
--DBMS_OUTPUT.put_line ('after insert history');
 op_result := 0;
 op_msg := 'Success';
 batch_id := v_batch_id;
 commit;
 EXCEPTION
 WHEN OTHERS
 THEN
 DBMS_OUTPUT.put_line ('Error '|| TO_CHAR (SQLCODE)|| ': '|| SQLERRM);
 op_result := SQLCODE;
 op_msg := SQLERRM;
 INSERT INTO X_PROGRAM_ERROR_LOG
 (X_SOURCE, X_ERROR_CODE, X_ERROR_MSG, X_DATE, X_DESCRIPTION,X_SEVERITY
 )
 VALUES ('BILLING_LIFELINE_MONTHLY_PKG',op_result,op_msg,SYSDATE,'ERROR INTO DELIVER_RECURRING_MINUTES_M',1
 );

 COMMIT;
 END DELIVER_RECURRING_MINUTES_M;
END BILLING_LIFELINE_MONTHLY_PKG; -- Package Body SA.BILLING_LIFELINE_MONTHLY_PKG
/