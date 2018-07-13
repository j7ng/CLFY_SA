CREATE OR REPLACE PACKAGE BODY sa."BILLING_LIFELINE_PKG"
IS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: BILLING_LIFELINE_PKG.sql,v $
  --$Revision: 1.53 $
  --$Author: sraman $
  --$Date: 2017/08/21 18:26:42 $
  --$ $Log: BILLING_LIFELINE_PKG.sql,v $
  --$ Revision 1.53  2017/08/21 18:26:42  sraman
  --$ CR52803 - Converted get_sw_cr_flag from function to procedure to get plan_type
  --$
  --$ Revision 1.52  2017/08/11 21:52:41  sraman
  --$ CR52803 - incorporated the review comments from Ramu
  --$
  --$ Revision 1.51  2017/08/10 20:51:56  sraman
  --$ Fixed a unit testing defect
  --$
  --$ Revision 1.50  2017/08/09 21:20:07  sraman
  --$ CR52803 Safelink Benefits delivery for Smart phones
  --$
  --$ Revision 1.46  2017/07/12 15:53:39  tbaney
  --$ Overwrote change for \s
  --$
  --$ Revision 1.45  2017/07/12 14:46:29  tbaney
  --$ Added logic for tribal for CR49050.
  --$
  --$ Revision 1.43  2016/12/21 16:14:53  tbaney
  --$ Set the sw_flag and x_ota_trans_id to null if record is labeled Skipped.  CR47024
  --$
  --$ Revision 1.42  2016/12/13 16:28:04  tbaney
  --$ Changed logic to use Plan Type SL_UNL_PLANS CR42459
  --$
  --$ Revision 1.41  2016/12/12 19:16:37  tbaney
  --$ Modified logic for FeaturePhone PPE
  --$
  --$ Revision 1.40  2016/12/12 17:36:25  tbaney
  --$ Changed PPE check from 0 to 1.  CR42459
  --$
  --$ Revision 1.39  2016/12/07 22:03:43  tbaney
  --$ Changed processed to skipped.  CR42459.
  --$
  --$ Revision 1.38  2016/12/05 19:50:27  tbaney
  --$ Added logic for CR42459 to set to processed.
  --$
  --$ Revision 1.37  2016/11/22 18:35:19  tbaney
  --$ Corrected <> CR42459
  --$
  --$ Revision 1.36  2016/11/22 18:25:09  tbaney
  --$ Changes for PPE checks.  CR42459
  --$
  --$ Revision 1.35  2016/10/13 16:02:50  skota
  --$ modified
  --$
  --$ Revision 1.34  2016/10/11 17:41:57  skota
  --$ Modified the x program puch hdr insert for unthrottling
  --$
  --$ Revision 1.33  2016/10/11 15:47:45  skota
  --$ Modified the x program puch hdr insert for unthrottling
  --$
  --$ Revision 1.31  2016/05/27 20:40:01  vyegnamurthy
  --$ Excluded budget programs from intial query
  --$
  --$ Revision 1.30  2016/03/25 16:11:17  vyegnamurthy
  --$ CR41733
  --$
  --$ Revision 1.28  2015/12/24 20:47:06  vyegnamurthy
  --$ CR38927
  --$
  --$ Revision 1.27  2015/12/15 23:01:03  vnainar
  --$ CR38927 table_x_pending_redemption skip added for smartphone
  --$
  --$ Revision 1.26  2015/12/09 21:25:32  vyegnamurthy
  --$ CR38927
  --$
  --$ Revision 1.25  2015/12/09 17:27:11  vyegnamurthy
  --$ CR38927
  --$
  --$ Revision 1.24  2015/12/08 21:12:29  vyegnamurthy
  --$ CR38927
  --$
  --$ Revision 1.23  2015/12/05 16:05:04  vnainar
  --$ CR38927 brand logic added
  --$
  --$ Revision 1.22  2015/11/13 18:45:54  vnainar
  --$ CR38927 SW_CR added
  --$
  --$ Revision 1.21  2015/10/27 18:22:17  arijal
  --$ CR29935 SL SMARTPHONE UPGRADE ..........
  --$
  --$ Revision 1.20  2015/10/26 21:58:41  arijal
  --$ CR29935 SL SMARTPHONE UPGRADE ..........
  --$
  --$ Revision 1.17  2015/06/18 22:38:52  arijal
  --$ CR33124 SL BYOP
  --$
  --$ Revision 1.16  2015/01/20 20:48:47  arijal
  --$ CR31545 SL CA HOME PHONE packages ota issue
  --$
  --$ Revision 1.15  2014/11/28 17:32:06  arijal
  --$ CR29866-CR30295 SafeLink California Existing Pkg Body BILLING_LIFELINE_PKG-DAILY
  --$
  --$ Revision 1.14  2014/11/26 19:30:04  arijal
  --$ CR29866-CR30295 SafeLink California Existing Pkg Body BILLING_LIFELINE_PKG-DAILY
  --$
  --$ Revision 1.13  2014/11/21 16:37:27  arijal
  --$ CR29866-CR30295 SafeLink California Existing Pkg Body BILLING_LIFELINE_PKG-DAILY
  --$
  --$ Revision 1.12  2014/04/10 14:25:23  ymillan
  --$ CR27745
  --$
  --$ Revision 1.10  2014/03/11 15:12:37  ymillan
  --$ CR26591
  --$
  --$ Revision 1.9  2011/11/14 21:00:07  kacosta
  --$ CR16984 SafeLink New Airtime Cards
  --$
  --$ Revision 1.8  2011/11/09 22:43:09  kacosta
  --$ CR16984 SafeLink New Airtime Cards
  --$
  --$ Revision 1.7  2011/11/09 19:59:03  kacosta
  --$ CR16984 SafeLink New Airtime Cards
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
FUNCTION IS_LIFELINE_CUSTOMER(
    p_esn IN VARCHAR2 )
  RETURN NUMBER
IS
  l_count NUMBER := 0;
BEGIN
  IF p_esn IS NULL THEN
    DBMS_OUTPUT.PUT_LINE('ESN is NULL. Fix it ...');
    RETURN l_count;
    -- ESN Not Found
  END IF;
  -- Just see if any records on x_program_enrolled
  SELECT COUNT(1)
  INTO l_count
  FROM X_PROGRAM_ENROLLED ENROLL,
    X_PROGRAM_PARAMETERS PARAM
  WHERE 1                             = 1
  AND ENROLL.X_ESN                    = p_esn
  AND X_ENROLLMENT_STATUS             = 'ENROLLED'
  AND PARAM.X_PROG_CLASS              = 'LIFELINE'
  AND ENROLL.PGM_ENROLL2PGM_PARAMETER = PARAM.OBJID;
  RETURN l_count ;
EXCEPTION
WHEN OTHERS THEN
  RETURN 0 ;
  -- Returns FALSE
END IS_LIFELINE_CUSTOMER;


PROCEDURE DELIVER_RECURRING_MINUTES(
    op_result OUT VARCHAR2, -- Output Result
    op_msg OUT VARCHAR2     -- Output Message
  )
IS
  V_ip_x_ota_trans_id VARCHAR2(1000);
BEGIN
  V_ip_x_ota_trans_id := NULL;
  DELIVER_RECURRING_MINUTES ( V_ip_x_ota_trans_id, 0, op_result, op_msg );
END;
PROCEDURE DELIVER_RECURRING_MINUTES(
    ip_x_ota_trans_id IN NUMBER, -- CR10881
    future_days       IN NUMBER, --CR10569
    op_result OUT VARCHAR2,      -- Output Result
    op_msg OUT VARCHAR2          -- Output Message
  )
IS
  -- Variable Declarations
  l_lifeline_eligible NUMBER := 0 ;
  l_site_part_objid table_site_part.objid%TYPE;
  l_prog_purch_objid   NUMBER := 0;
  l_sales_tax_percent  NUMBER := 0;
  l_e911_tax_percent   NUMBER := 0;
  l_tax                NUMBER := 0;
  l_e911_tax           NUMBER := 0;
  l_usf_tax            NUMBER := 0; --CR11553
  l_rcrf_tax           NUMBER := 0; --CR11553
  l_next_delivery_date DATE;
  l_texas_client       NUMBER := 0; --CR12784
  l_ca_client          NUMBER := 0; --CR30295
  --   IP_ESN VARCHAR2(200);
  l_parameter_value TABLE_X_PART_CLASS_VALUES.X_PARAM_VALUE%TYPE;
  l_is_swb_carr   VARCHAR2(100);
  l_error_code    NUMBER;
  l_error_message VARCHAR2(200);
  l_brand         VARCHAR2(100);
  ppe_flag        NUMBER := 0;  --EME SL
  status_flag     VARCHAR2(100);--EME SL
  l_pgm_hdr_objid NUMBER;
  v_service_plan_group  sa.service_plan_feat_pivot_mv.service_plan_group%type; -- CR42459
  x_service_plan_rec sa.x_service_plan%rowtype;
  -----------------------------------------------------------------------------------------------
  -- Cursor Declarations
  -- Cursor # 1
  -- Fetch all Lifeline Customers whose delivery date is today.
  CURSOR lifeline_enroll_cur
  IS
    SELECT
      /*+ PARALLEL(a,8) */
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
      b.x_program_name p_name, --CR12784
      a.X_TOT_GRACE_PERIOD_GIVEN,
      a.x_amount,
      a.x_sourcesystem,
      c.x_expire_dt exp_date, --CR12784
	  sa.get_sw_cr_flag(a.x_esn)  SW_FLAG,
      c.objid site_part_objid,
      CASE
        WHEN b.x_sweep_and_add_flag = 1
        AND EXISTS
          (SELECT 1
          FROM table_x_call_trans xct
          JOIN table_x_red_card xrc
          ON xct.objid = xrc.red_card2call_trans
          JOIN table_mod_level tml
          ON xrc.x_red_card2part_mod = tml.objid
          JOIN table_part_num tpn
          ON tml.part_info2part_num = tpn.objid
          JOIN sl_gencodes_days_ahead_view dav
          ON 1                           = 1
          WHERE xct.call_trans2site_part = c.objid
          AND xct.x_transact_date        > SYSDATE - TO_NUMBER(dav.days_ahead)
          AND UPPER(xrc.x_result)        = 'COMPLETED'
          AND dav.promo_code             = 'ALL'
          AND dav.part_number            = 'ALL'
          AND NOT EXISTS
            (SELECT 1
            FROM sl_gencodes_days_ahead_view dav_exception
            JOIN table_x_promotion txp_promo
            ON dav_exception.promo_code     = txp_promo.x_promo_code
            WHERE dav_exception.part_number = tpn.part_number
            AND txp_promo.objid             = b.x_promo_incl_min_at
            )
          )
        THEN 4
        WHEN b.x_sweep_and_add_flag = 1
        AND EXISTS
          (SELECT 1
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
          ON dav.promo_code              = txp_promo.x_promo_code
          WHERE xct.call_trans2site_part = c.objid
          AND UPPER(xrc.x_result)        = 'COMPLETED'
          AND xct.x_transact_date        > SYSDATE - TO_NUMBER(dav.days_ahead)
          AND txp_promo.objid            = b.x_promo_incl_min_at
          )
        THEN 4
        ELSE b.x_sweep_and_add_flag
      END x_sweep_and_add_flag
      --CR16984 End kacosta 09/30/2011
    FROM table_site_part c,
      x_program_parameters b,
      x_program_enrolled a
    WHERE 1 = 1
    AND c.PART_STATUS
      ||'' = 'Active' -- Take only Active ESN's
    AND c.x_service_id
      ||''                     = a.x_esn
    AND c.objid                = a.PGM_ENROLL2SITE_PART
    AND B.X_PROG_CLASS         = 'LIFELINE' -- Program class should be LIFELINE only
    AND B.X_PROGRAM_NAME   NOT  IN ('Lifeline - BG - 3','Lifeline - BG - 4','Lifeline - BG - UNL1')
	AND b.objid                = a.pgm_enroll2pgm_parameter
    AND A.X_NEXT_DELIVERY_DATE < TRUNC(SYSDATE + 1) + future_days -- Since this job runs on 1st day of every m CR10569
    AND (
      CASE
        WHEN future_days = 0
        THEN SYSDATE + 1
        ELSE A.X_NEXT_DELIVERY_DATE
      END) >= (
      CASE
        WHEN future_days = 0
        THEN SYSDATE
        ELSE TRUNC(SYSDATE + 1)
      END)                                 --CR10569
    AND A.X_ENROLLMENT_STATUS = 'ENROLLED' -- Take only Current Enrolled customers
    AND ROWNUM                < 500001;    -- NEW CHANGE - OCT - NN
    -- CR12784 review if promo is valid
    CURSOR Promo_exist_cur
    IS
      SELECT *
      FROM table_x_promotion
      WHERE x_promo_code IN ('REDNT45D','REDTF45D')
      AND x_end_date     >= sysdate;
    v_promo_exist_rec promo_exist_cur%ROWTYPE;
    -----------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------
    -- End of Cursors
  BEGIN
    FOR rec1 IN lifeline_enroll_cur
    LOOP
      --CR12784 review if ESN is Texas client
      --if rec1.p_name in ('Lifeline - TX - 1','Lifeline - TX - 2','Lifeline - TX - 3','Lifeline - Texas State TracFone','Lifeline - Texas State Net10', 'Lifeline - TX - 4') then --CR13940
      IF rec1.p_name IN ('Lifeline - Texas State TracFone','Lifeline - Texas State Net10') THEN --CR13940 CR26591 CR27748 remove regular tx states
        l_texas_client:=1;
      ELSE
        l_texas_client:=0;
      END IF;
      --CR30295 SafeLink CA Plans
      IF rec1.p_name IN ('Lifeline - CA - UNL1', 'Lifeline - CA - HUNL1', 'Lifeline - CA - BUNL1') -- CR31988 SL CA HOME PHONE ADDED 'Lifeline - CA - HUNL1'
         OR
         regexp_instr(UPPER(rec1.p_name),'\s[T][0-9]') > 0 -- CR49050 Add TRIBAL programs so we will write redemption records.
         THEN
        -- CR33124 SL BYOP 'Lifeline - CA - BUNL1'
        l_ca_client:=1;
      ELSE
        l_ca_client:=0;
      END IF;
      --EME Changes Vishnu SL START
      l_parameter_value   :=get_device_type(rec1.x_esn);
      IF (l_parameter_value = 'FEATURE_PHONE' AND GET_DATA_MTG_SOURCE (rec1.x_esn) = 'PPE') THEN  -- CR42459 Added get_data_mtg_source check.
        ppe_flag          := 1;
      ELSIF (l_parameter_value = 'FEATURE_PHONE' AND GET_DATA_MTG_SOURCE (rec1.x_esn) <> 'PPE') THEN
        ppe_flag          := 0;
      ELSIF l_parameter_value IN ('BYOP','SMARTPHONE') THEN ---THIS IS FOR SL BYOP SMARTPHONE
        ppe_flag := 0;
      ELSE
        ppe_flag := 1;
      END IF;
      --EME Changes Vishnu SL END
      -- 1. Update the Delivery Cycle Number and also Next Delivery date
      -- For the time being update the last charge date also
      UPDATE x_program_enrolled
      SET x_delivery_cycle_number = NVL( x_delivery_cycle_number, 0) + 1,
        x_charge_date             = TRUNC(SYSDATE)                   + (
        CASE
          WHEN l_ca_client = 1
          THEN 0
          ELSE future_days
        END), --CR10569
        -- Drop Next delivery date as 1st date of next month
        --x_next_delivery_date = ADD_MONTHS(x_next_delivery_date ,1)
        -- x_next_delivery_date = (LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE), (CASE WHEN future_days = 0 THEN 0
        -- ELSE 1 END))) + 1) -- CR10569
        x_next_delivery_date = (
        CASE
          WHEN l_ca_client = 1
          THEN TRUNC(sysdate)+30 --CR30295
          ELSE (LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE), (
            CASE
              WHEN future_days = 0
              THEN 0
              ELSE 1
            END))) + 1) --(CASE WHEN l_texas_client = 1 THEN 5 ELSE 1 END)) -- CR12784 if is texas client 5th day of month CR26591 CR27748 CR27745 change 5 days for 1 days
        END)            --CR30295
      WHERE objid = rec1.objid;
      -- 2a. Add procedure call to drop a dummy record on x_program_purch_hdr and x_program_purch_dtl
      -----------------------------------------------------------------------------------------------
      -- 1. Insert record in x_program_purch_hdr
      l_pgm_hdr_objid := sa.SEQ_X_PROGRAM_PURCH_HDR.NEXTVAL; --CR44345
      INSERT
      INTO x_program_purch_hdr
        (
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
          x_usf_taxamount,   --CR11553
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
        )
        VALUES
        (

          l_pgm_hdr_objid  ,
          rec1.x_sourcesystem,
          'LIFELINE_PURCH',
          SYSDATE + future_days, --CR10569
          SYSDATE + future_days, -- NEW CHANGE - OCT - NN
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
          NULL,  --x_ics_rcode CR44345
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
          l_usf_tax,  --CR11553
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
      -- 2b. Insert record in x_program_purch_dtl
      INSERT
      INTO x_program_purch_dtl
        (
          objid,
          x_esn,
          x_amount,
          x_tax_amount,
          x_e911_tax_amount,
          x_usf_taxamount,   --CR11553
          x_rcrf_tax_amount, --CR11553
          x_charge_desc,
          x_cycle_start_date,
          x_cycle_end_date,
          pgm_purch_dtl2pgm_enrolled,
          pgm_purch_dtl2prog_hdr
        )
        VALUES
        (
          (
            sa.SEQ_X_PROGRAM_PURCH_DTL.NEXTVAL
          )
          ,
          rec1.x_esn,
          rec1.x_amount,
          l_tax,
          l_e911_tax,
          l_usf_tax,  --CR11553
          l_rcrf_tax, --CR11553
          'Charges for Lifelink Wireless Customers',
          (ADD_MONTHS(rec1.x_next_delivery_date, 1)),
          (ADD_MONTHS(rec1.x_next_delivery_date, 2)),
          rec1.objid,
          sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL
        );
      -- 3. Insert record into table_x_pending_redemption
	  --CR41733 insert smart ph which are not ready
		IF  ppe_flag = 1 OR (rec1.SW_FLAG IS NULL AND  ppe_flag = 0) THEN   --Only PPES get insert into table_x_pending_redemption
        INSERT
        INTO table_x_pending_redemption
          (
            objid,
            pend_red2x_promotion,
            x_pend_red2site_part,
            x_pend_type,
            pend_redemption2esn,
            x_case_id,
            x_granted_from2x_call_trans,
            PEND_RED2PROG_PURCH_HDR
          )
          VALUES
          (
            (
              sa.sequ_x_pending_redemption.NEXTVAL
            )
            ,
            rec1.x_promo_incl_min_at,
            rec1.site_part_objid,
            'BPDelivery',
            NULL,
            NULL,
            NULL,
            sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL --rec1.purch_hdr_objid
          );
      END IF; --PPE FLAG CHECK for pending redemption END IF --CR41733
      -- 3A. Insert record into table_x_pending_redemption for California days (CR30295)
      IF l_ca_client =1 THEN --CR41733 checking CA client start
        INSERT
        INTO table_x_pending_redemption
          (
            objid,
            pend_red2x_promotion,
            x_pend_red2site_part,
            x_pend_type,
            pend_redemption2esn,
            x_case_id,
            x_granted_from2x_call_trans,
            PEND_RED2PROG_PURCH_HDR
          )
          VALUES
          (
            (
              sa.sequ_x_pending_redemption.NEXTVAL
            )
            ,
            rec1.x_incl_service_days,
            rec1.site_part_objid,
            'BPDelivery',
            NULL,
            NULL,
            NULL,
            sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL --rec1.purch_hdr_objid
          );
      END IF; --CR41733 checking CA client end
      --
      -- CR12784 insert 45 dias more for texas clientes
      --
      OPEN promo_exist_cur;
      FETCH promo_exist_cur INTO v_promo_exist_rec;
      IF promo_exist_cur%FOUND THEN
        IF (TRUNC(rec1.exp_date) - TRUNC(sysdate) < 45) AND (l_texas_client = 1 ) THEN
          INSERT
          INTO table_x_pending_redemption
            (
              objid,
              pend_red2x_promotion,
              x_pend_red2site_part,
              x_pend_type,
              pend_redemption2esn,
              x_case_id,
              x_granted_from2x_call_trans,
              PEND_RED2PROG_PURCH_HDR
            )
            VALUES
            (
              (
                sa.sequ_x_pending_redemption.NEXTVAL
              )
              ,
              DECODE(rec1.p_name,'Lifeline - Texas State Net10',
              (SELECT objid FROM table_x_promotion WHERE x_promo_code = 'REDNT45D'
              ),
              (SELECT objid FROM table_x_promotion WHERE x_promo_code = 'REDTF45D'
              )),
              rec1.site_part_objid,
              'BPDelivery',
              NULL,
              NULL,
              NULL,
              sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL --rec1.purch_hdr_objid
            );
          UPDATE table_site_part
          SET x_expire_dt = TRUNC(rec1.exp_date) + DECODE(rec1.p_name,'Lifeline - Texas State Net10',
            (SELECT x_access_days FROM table_x_promotion WHERE x_promo_code = 'REDNT45D'
            ),
            (SELECT x_access_days FROM table_x_promotion WHERE x_promo_code = 'REDTF45D'
            ))
          WHERE objid     = rec1.site_part_objid
          AND part_status = 'Active';
          UPDATE table_part_inst
          SET WARR_END_DATE = TRUNC(WARR_END_DATE) + DECODE(rec1.p_name,'Lifeline - Texas State Net10',
            (SELECT x_access_days FROM table_x_promotion WHERE x_promo_code = 'REDNT45D'
            ),
            (SELECT x_access_days FROM table_x_promotion WHERE x_promo_code = 'REDTF45D'
            ))
          WHERE PART_SERIAL_NO IN ( rec1.x_esn )
          AND x_part_inst_status='52';
          --DBMS_OUTPUT.put_line('Updated Site Part / Part Inst');
        END IF;
      ELSE
        op_result := 9999;
        op_msg    := 'Days promo is not valid';
      END IF;
      CLOSE promo_exist_cur;
      --
      --L_PARAMETER_VALUE:=get_device_type(rec1.x_esn); --CR38927 SL UPGRADE
      BEGIN
        SELECT org_id
        INTO l_brand
        FROM table_bus_org
        WHERE objid = rec1.prog_param2bus_org;
      EXCEPTION
      WHEN OTHERS THEN
        l_brand :=NULL;
      END;
      --CR38927 SL UPGRADE  START
      -- IF l_parameter_value = 'FEATURE_PHONE' THEN
      --  l_is_swb_carr     := NULL;
      -- ELSIF l_parameter_value IN ('BYOP','SMARTPHONE') THEN ---THIS IS FOR SL BYOP TRACFONE SMARTPHONE
      --   IF (l_brand      ='TRACFONE') THEN
      --    l_is_swb_carr := 'SW_CR';
      --   END IF;
      --  ELSE
      -- l_is_swb_carr := NULL;
      -- END IF;
      IF ppe_flag      =0 AND l_brand ='TRACFONE' THEN
		-- get_sw_cr_flag(rec1.x_esn );
         l_is_swb_carr := sa.get_sw_cr_flag(rec1.x_esn );--'SW_CR';
         IF l_is_swb_carr ='SW_CR' THEN
            status_flag   := 'SW_INSERTED';

            -- Now check the service plan.  CR42459
            x_service_plan_rec := sa.service_plan.get_service_plan_by_esn(rec1.x_esn);
            BEGIN
               SELECT sa.get_serv_plan_value(x_service_plan_rec.objid, 'PLAN TYPE')
                 INTO v_service_plan_group
                 FROM DUAL;

            EXCEPTION WHEN OTHERS THEN
               v_service_plan_group := NULL;

            END;

             IF v_service_plan_group  = 'SL_UNL_PLANS' THEN
                status_flag   := 'SKIPPED';
             END IF;


        ELSE

		  status_flag   := 'INSERTED';
        END IF;
      ELSE
        l_is_swb_carr := NULL;
        status_flag   := 'INSERTED';
      END IF;
      --CR38927 SL UPGRADE  END

      IF ppe_flag                                  =0 AND l_brand ='TRACFONE' THEN --CR41733 TF SL SMARTPHONE CHECK STARTS
        IF (TRUNC(rec1.exp_date) - TRUNC(sysdate) <= 30) THEN                      --check the service end date less than 30 days
          INSERT
          INTO table_x_pending_redemption
            (
              objid,
              pend_red2x_promotion,
              x_pend_red2site_part,
              x_pend_type,
              pend_redemption2esn,
              x_case_id,
              x_granted_from2x_call_trans,
              PEND_RED2PROG_PURCH_HDR
            )
            VALUES
            (
              sa.sequ_x_pending_redemption.NEXTVAL,
               (SELECT objid FROM table_x_promotion WHERE x_promo_code = 'SLTF30D'), --check this the promo code value to be insert in table_x_promotion
              rec1.site_part_objid,
              'BPDelivery',----x_pend_type check this value
              NULL,
              NULL,
              NULL,
              sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL --rec1.purch_hdr_objid
            );
          --Check do we have to update site part and part inst tables
		  UPDATE table_site_part
          SET x_expire_dt = x_expire_dt + (SELECT X_ACCESS_DAYS FROM table_x_promotion WHERE x_promo_code = 'SLTF30D'),
			  WARRANTY_DATE = WARRANTY_DATE + (SELECT X_ACCESS_DAYS FROM table_x_promotion WHERE x_promo_code = 'SLTF30D')
          WHERE objid     = rec1.site_part_objid
          AND part_status = 'Active';

          UPDATE table_part_inst
          SET WARR_END_DATE = WARR_END_DATE + (SELECT X_ACCESS_DAYS FROM table_x_promotion WHERE x_promo_code = 'SLTF30D')
          WHERE PART_SERIAL_NO IN ( rec1.x_esn )
          AND x_part_inst_status='52';
        END IF;
      END IF ;--CR41733 TF SL SMARTPHONE CHECK ENDS
      INSERT
      INTO x_program_gencode
        (
          objid,
          x_esn,
          x_insert_date,
          x_status,
          GENCODE2PROG_PURCH_HDR,
          x_ota_trans_id,
          X_SWEEP_AND_ADD_FLAG, -- CR14175
          sw_flag               --CR29935
        )
        VALUES
        (
          sa.SEQ_X_PROGRAM_GENCODE.NEXTVAL,
          rec1.x_esn,
          SYSDATE + future_days,              --CR10569
          status_flag,                        -- CR12417 'QUEUED', NEW CHANGE - OCT - NN
          sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL, -- rec1.purch_hdr_objid,
          (
          CASE
            WHEN l_ca_client=1 OR status_flag = 'SKIPPED' -- CR47024
            THEN NULL
			WHEN l_is_swb_carr IS NULL AND ppe_flag=0 --CR41733 TF SL SMARTPHONE which are not ready will be with NULL
			THEN NULL
            WHEN l_is_swb_carr = 'SW_CR'
            THEN 256
            ELSE ip_x_ota_trans_id
          END),
          rec1.X_SWEEP_AND_ADD_FLAG, -- CR14175
          CASE WHEN status_flag = 'SKIPPED'
               THEN NULL
               ELSE l_is_swb_carr -- CR47024
                END
        );
      COMMIT;
      --CR44345, the below code will help to fire the purch_hdr_trigger for unthrotlle lifeline

      --
      update x_program_purch_hdr
         set x_status    = x_status,
             x_ics_rcode = '100'
       where objid = l_pgm_hdr_objid;

      commit;
    END LOOP;
    op_result := 0;
    op_msg    := 'Success';
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line ('Error '|| TO_CHAR (SQLCODE)|| ': '|| SQLERRM);
    op_result := SQLCODE;
    op_msg    := SQLERRM;
  END DELIVER_RECURRING_MINUTES;

--Overloaded for performance improvement
PROCEDURE DELIVER_RECURRING_MINUTES(
    ip_x_ota_trans_id    IN   NUMBER,
    future_days          IN   NUMBER,
    i_daily_monthly_flag IN   VARCHAR2,          -- M for Monthly and D for Daily
    i_divisor            IN   NUMBER,
    i_remainder          IN   NUMBER,
    i_bulk_collect_limit IN   NUMBER,
    op_result            OUT  VARCHAR2,         -- Output Result
    op_msg               OUT  VARCHAR2          -- Output Message
  )
IS
  -- Variable Declarations
  l_lifeline_eligible NUMBER := 0 ;
  l_site_part_objid table_site_part.objid%TYPE;
  l_prog_purch_objid   NUMBER := 0;
  l_sales_tax_percent  NUMBER := 0;
  l_e911_tax_percent   NUMBER := 0;
  l_tax                NUMBER := 0;
  l_e911_tax           NUMBER := 0;
  l_usf_tax            NUMBER := 0; --CR11553
  l_rcrf_tax           NUMBER := 0; --CR11553
  l_next_delivery_date DATE;
  l_texas_client       NUMBER := 0; --CR12784
  l_ca_client          NUMBER := 0; --CR30295
  l_parameter_value TABLE_X_PART_CLASS_VALUES.X_PARAM_VALUE%TYPE;
  l_is_swb_carr   VARCHAR2(100);
  l_error_code    NUMBER;
  l_error_message VARCHAR2(1000);
  l_brand         VARCHAR2(100);
  ppe_flag        NUMBER := 0;  --EME SL
  status_flag     VARCHAR2(100);--EME SL
  l_pgm_hdr_objid NUMBER;
  v_service_plan_group  sa.service_plan_feat_pivot_mv.service_plan_group%type; -- CR42459
  --x_service_plan_rec sa.x_service_plan%rowtype; --CR52803 commented
  -----------------------------------------------------------------------------------------------
  -- Cursor Declarations
  -- Cursor # 1
  CURSOR lifeline_enroll_cur
  IS
    SELECT a.*,a.rowid rid
    FROM   x_sl_deliver_benefits_stg a
    WHERE  MOD(row_number,NVL(i_divisor,1) ) = NVL(i_remainder,0)
      AND  processed_flag = 'N'
      AND  insert_timestamp > TRUNC(SYSDATE);

    TYPE datalist IS TABLE OF lifeline_enroll_cur%ROWTYPE;

    rec1 datalist;
    -- CR12784 review if promo is valid
    CURSOR Promo_exist_cur
    IS
      SELECT *
      FROM table_x_promotion
      WHERE x_promo_code IN ('REDNT45D','REDTF45D')
      AND x_end_date     >= sysdate;
    v_promo_exist_rec promo_exist_cur%ROWTYPE;

    v_new_batch            NUMBER;
    v_batch_id             VARCHAR2(50);
    n_cnt                  NUMBER;

    -----------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------
    -- End of Cursors
  BEGIN
    dbms_output.put_line ('********INPUT PARAMETERS*************');
    dbms_output.put_line ('ip_x_ota_trans_id    :' || ip_x_ota_trans_id);
    dbms_output.put_line ('i_remainder          :' ||i_remainder );
    dbms_output.put_line ('i_divisor            :' ||i_divisor );
    dbms_output.put_line ('i_daily_monthly_flag :' ||i_daily_monthly_flag );
    dbms_output.put_line ('future_days          :' ||future_days );

    OPEN lifeline_enroll_cur;

    --FOR rec1 IN lifeline_enroll_cur
    LOOP
	  FETCH lifeline_enroll_cur BULK COLLECT INTO rec1 LIMIT i_bulk_collect_limit;
	  FOR i IN 1 .. rec1.COUNT
      LOOP
         v_service_plan_group := NULL;
	  --Logic to update SW_FLAG and x_sweep_and_add_flag
         sa.billing_lifeline_pkg.get_sw_cr_flag (i_site_part_objid => rec1(i).site_part_objid ,
                                                 i_esn             => rec1(i).x_esn           ,
                                                 o_sw_flag         => rec1(i).sw_flag         ,
                                                 o_plan_type       => v_service_plan_group    ,
                                                 o_msg             => l_error_message );


         IF rec1(i).x_sweep_and_add_flag = 1 THEN
           SELECT COUNT(1)
           INTO n_cnt
           FROM table_x_call_trans xct
           JOIN table_x_red_card xrc
           ON xct.objid = xrc.red_card2call_trans
           JOIN table_mod_level tml
           ON xrc.x_red_card2part_mod = tml.objid
           JOIN table_part_num tpn
           ON tml.part_info2part_num = tpn.objid
           JOIN sl_gencodes_days_ahead_view dav
           ON 1                           = 1
           WHERE xct.call_trans2site_part = rec1(i).site_part_objid
           AND xct.x_transact_date        > SYSDATE - TO_NUMBER(dav.days_ahead)
           AND UPPER(xrc.x_result)        = 'COMPLETED'
           AND dav.promo_code             = 'ALL'
           AND dav.part_number            = 'ALL'
           AND NOT EXISTS
             (SELECT 1
             FROM sl_gencodes_days_ahead_view dav_exception
             JOIN table_x_promotion txp_promo
             ON dav_exception.promo_code     = txp_promo.x_promo_code
             WHERE dav_exception.part_number = tpn.part_number
             AND txp_promo.objid             = rec1(i).x_promo_incl_min_at
             )
           AND ROWNUM               <=1;

           IF n_cnt                  >= 1 THEN
             rec1(i).x_sweep_and_add_flag := 4;
           ELSE
             SELECT COUNT(1)
             INTO n_cnt
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
             ON dav.promo_code              = txp_promo.x_promo_code
             WHERE xct.call_trans2site_part = rec1(i).site_part_objid
             AND UPPER(xrc.x_result)        = 'COMPLETED'
             AND xct.x_transact_date        > SYSDATE - TO_NUMBER(dav.days_ahead)
             AND txp_promo.objid            = rec1(i).x_promo_incl_min_at
             AND ROWNUM                    <=1;

             IF n_cnt                       >= 1 THEN
               rec1(i).x_sweep_and_add_flag      := 4 ;
             END IF;
           END IF;
         END IF;


         --CR12784 review if ESN is Texas client
         --if rec1.p_name in ('Lifeline - TX - 1','Lifeline - TX - 2','Lifeline - TX - 3','Lifeline - Texas State TracFone','Lifeline - Texas State Net10', 'Lifeline - TX - 4') then --CR13940
         IF rec1(i).p_name IN ('Lifeline - Texas State TracFone','Lifeline - Texas State Net10') THEN --CR13940 CR26591 CR27748 remove regular tx states
           l_texas_client:=1;
         ELSE
           l_texas_client:=0;
         END IF;
         --CR30295 SafeLink CA Plans
         IF rec1(i).p_name IN ('Lifeline - CA - UNL1', 'Lifeline - CA - HUNL1', 'Lifeline - CA - BUNL1') -- CR31988 SL CA HOME PHONE ADDED 'Lifeline - CA - HUNL1'
            OR
            regexp_instr(UPPER(rec1(i).p_name),'\s[T][0-9]') > 0 -- CR49050 Add TRIBAL programs so we will write redemption records.
            THEN
            -- CR33124 SL BYOP 'Lifeline - CA - BUNL1'
            l_ca_client:=1;
         ELSE
            l_ca_client:=0;
         END IF;

         l_parameter_value   :=get_device_type(rec1(i).x_esn);
         IF (l_parameter_value = 'FEATURE_PHONE' AND GET_DATA_MTG_SOURCE (rec1(i).x_esn) = 'PPE') THEN  -- CR42459 Added get_data_mtg_source check.
           ppe_flag          := 1;
         ELSIF (l_parameter_value = 'FEATURE_PHONE' AND GET_DATA_MTG_SOURCE (rec1(i).x_esn) <> 'PPE') THEN
           ppe_flag          := 0;
         ELSIF l_parameter_value IN ('BYOP','SMARTPHONE') THEN ---THIS IS FOR SL BYOP SMARTPHONE
           ppe_flag := 0;
         ELSE
           ppe_flag := 1;
         END IF;
         -- 1. Update the Delivery Cycle Number and also Next Delivery date
         -- For the time being update the last charge date also
         UPDATE x_program_enrolled
         SET x_delivery_cycle_number = NVL( x_delivery_cycle_number, 0) + 1,
           x_charge_date             = TRUNC(SYSDATE)                   + (
           CASE
             WHEN l_ca_client = 1
             THEN 0
             ELSE future_days
           END), --CR10569
           -- Drop Next delivery date as 1st date of next month
           --x_next_delivery_date = ADD_MONTHS(x_next_delivery_date ,1)
           -- x_next_delivery_date = (LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE), (CASE WHEN future_days = 0 THEN 0
           -- ELSE 1 END))) + 1) -- CR10569
           x_next_delivery_date = (
           CASE
             WHEN l_ca_client = 1
             THEN TRUNC(sysdate)+30 --CR30295
             ELSE (LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE), (
               CASE
                 WHEN future_days = 0
                 THEN 0
                 ELSE 1
               END))) + 1) --(CASE WHEN l_texas_client = 1 THEN 5 ELSE 1 END)) -- CR12784 if is texas client 5th day of month CR26591 CR27748 CR27745 change 5 days for 1 days
           END)            --CR30295
         WHERE objid = rec1(i).objid;
         -- 2a. Add procedure call to drop a dummy record on x_program_purch_hdr and x_program_purch_dtl
         -----------------------------------------------------------------------------------------------
         -- 1. Insert record in x_program_purch_hdr
         l_pgm_hdr_objid := sa.SEQ_X_PROGRAM_PURCH_HDR.NEXTVAL; --CR44345
         INSERT
         INTO x_program_purch_hdr
           (
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
             x_usf_taxamount,   --CR11553
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
           )
           VALUES
           (

             l_pgm_hdr_objid  ,
             rec1(i).x_sourcesystem,
             'LIFELINE_PURCH',
             SYSDATE + future_days, --CR10569
             SYSDATE + future_days, -- NEW CHANGE - OCT - NN
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
             NULL,  --x_ics_rcode CR44345
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
             rec1(i).x_amount,
             l_tax,
             l_e911_tax,
             l_usf_tax,  --CR11553
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
             rec1(i).pgm_enroll2web_user,
             NULL,
             'LL_RECURRING'
           );
         -- 2b. Insert record in x_program_purch_dtl
         INSERT
         INTO x_program_purch_dtl
           (
             objid,
             x_esn,
             x_amount,
             x_tax_amount,
             x_e911_tax_amount,
             x_usf_taxamount,   --CR11553
             x_rcrf_tax_amount, --CR11553
             x_charge_desc,
             x_cycle_start_date,
             x_cycle_end_date,
             pgm_purch_dtl2pgm_enrolled,
             pgm_purch_dtl2prog_hdr
           )
           VALUES
           (
             (
               sa.SEQ_X_PROGRAM_PURCH_DTL.NEXTVAL
             )
             ,
             rec1(i).x_esn,
             rec1(i).x_amount,
             l_tax,
             l_e911_tax,
             l_usf_tax,  --CR11553
             l_rcrf_tax, --CR11553
             'Charges for Lifelink Wireless Customers',
             (ADD_MONTHS(rec1(i).x_next_delivery_date, 1)),
             (ADD_MONTHS(rec1(i).x_next_delivery_date, 2)),
             rec1(i).objid,
             sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL
           );
           -- 3. Insert record into table_x_pending_redemption
	       --CR41733 insert smart ph which are not ready
		 IF  ppe_flag = 1 OR (rec1(i).SW_FLAG IS NULL AND  ppe_flag = 0) THEN   --Only PPES get insert into table_x_pending_redemption
           INSERT
           INTO table_x_pending_redemption
             (
               objid,
               pend_red2x_promotion,
               x_pend_red2site_part,
               x_pend_type,
               pend_redemption2esn,
               x_case_id,
               x_granted_from2x_call_trans,
               PEND_RED2PROG_PURCH_HDR
             )
             VALUES
             (
               (
                 sa.sequ_x_pending_redemption.NEXTVAL
               )
               ,
               rec1(i).x_promo_incl_min_at,
               rec1(i).site_part_objid,
               'BPDelivery',
               NULL,
               NULL,
               NULL,
               sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL --rec1.purch_hdr_objid
             );
         END IF; --PPE FLAG CHECK for pending redemption END IF --CR41733
         -- 3A. Insert record into table_x_pending_redemption for California days (CR30295)
         IF l_ca_client =1 THEN --CR41733 checking CA client start
           INSERT
           INTO table_x_pending_redemption
             (
               objid,
               pend_red2x_promotion,
               x_pend_red2site_part,
               x_pend_type,
               pend_redemption2esn,
               x_case_id,
               x_granted_from2x_call_trans,
               PEND_RED2PROG_PURCH_HDR
             )
             VALUES
             (
               (
                 sa.sequ_x_pending_redemption.NEXTVAL
               )
               ,
               rec1(i).x_incl_service_days,
               rec1(i).site_part_objid,
               'BPDelivery',
               NULL,
               NULL,
               NULL,
               sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL --rec1.purch_hdr_objid
             );
         END IF; --CR41733 checking CA client end
         --
         -- CR12784 insert 45 dias more for texas clientes
         --
         OPEN promo_exist_cur;
         FETCH promo_exist_cur INTO v_promo_exist_rec;
         IF promo_exist_cur%FOUND THEN
           IF (TRUNC(rec1(i).exp_date) - TRUNC(sysdate) < 45) AND (l_texas_client = 1 ) THEN
             INSERT
             INTO table_x_pending_redemption
               (
                 objid,
                 pend_red2x_promotion,
                 x_pend_red2site_part,
                 x_pend_type,
                 pend_redemption2esn,
                 x_case_id,
                 x_granted_from2x_call_trans,
                 PEND_RED2PROG_PURCH_HDR
               )
               VALUES
               (
                 (
                   sa.sequ_x_pending_redemption.NEXTVAL
                 )
                 ,
                 DECODE(rec1(i).p_name,'Lifeline - Texas State Net10',
                 (SELECT objid FROM table_x_promotion WHERE x_promo_code = 'REDNT45D'
                 ),
                 (SELECT objid FROM table_x_promotion WHERE x_promo_code = 'REDTF45D'
                 )),
                 rec1(i).site_part_objid,
                 'BPDelivery',
                 NULL,
                 NULL,
                 NULL,
                 sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL --rec1.purch_hdr_objid
               );
             UPDATE table_site_part
             SET x_expire_dt = TRUNC(rec1(i).exp_date) + DECODE(rec1(i).p_name,'Lifeline - Texas State Net10',
               (SELECT x_access_days FROM table_x_promotion WHERE x_promo_code = 'REDNT45D'
               ),
               (SELECT x_access_days FROM table_x_promotion WHERE x_promo_code = 'REDTF45D'
               ))
             WHERE objid     = rec1(i).site_part_objid
             AND part_status = 'Active';
             UPDATE table_part_inst
             SET WARR_END_DATE = TRUNC(WARR_END_DATE) + DECODE(rec1(i).p_name,'Lifeline - Texas State Net10',
               (SELECT x_access_days FROM table_x_promotion WHERE x_promo_code = 'REDNT45D'
               ),
               (SELECT x_access_days FROM table_x_promotion WHERE x_promo_code = 'REDTF45D'
               ))
             WHERE PART_SERIAL_NO IN ( rec1(i).x_esn )
             AND x_part_inst_status='52';
             --DBMS_OUTPUT.put_line('Updated Site Part / Part Inst');
           END IF;
         ELSE
           op_result := 9999;
           op_msg    := 'Days promo is not valid';
         END IF;
         CLOSE promo_exist_cur;
         --
         --L_PARAMETER_VALUE:=get_device_type(rec1.x_esn); --CR38927 SL UPGRADE
         BEGIN
           SELECT org_id
           INTO l_brand
           FROM table_bus_org
           WHERE objid = rec1(i).prog_param2bus_org;
         EXCEPTION
         WHEN OTHERS THEN
           l_brand :=NULL;
         END;
         IF ppe_flag      =0 AND l_brand ='TRACFONE' THEN
		   -- get_sw_cr_flag(rec1.x_esn );
           -- l_is_swb_carr := get_sw_cr_flag(rec1.x_esn );--'SW_CR';
           l_is_swb_carr := rec1(i).sw_flag;--'SW_CR';
           IF l_is_swb_carr ='SW_CR' THEN
               status_flag   := 'SW_INSERTED';

               -- Now check the service plan.  CR42459
               --CR52803 Commenting below, replaced with one single procedure call get_sw_cr_flag to get plan_type
               --x_service_plan_rec := sa.service_plan.get_service_plan_by_esn(rec1(i).x_esn);
               --BEGIN
                  --SELECT sa.get_serv_plan_value(x_service_plan_rec.objid, 'PLAN TYPE')
                  --  INTO v_service_plan_group
                  --  FROM DUAL;

               --EXCEPTION WHEN OTHERS THEN
               --   v_service_plan_group := NULL;
               --END;

               IF v_service_plan_group  = 'SL_UNL_PLANS' THEN
                  status_flag   := 'SKIPPED';
               END IF;
           ELSE
		     status_flag   := 'INSERTED';
           END IF;
         ELSE
           l_is_swb_carr := NULL;
           status_flag   := 'INSERTED';
         END IF;
         --CR38927 SL UPGRADE  END

         IF ppe_flag                                  =0 AND l_brand ='TRACFONE' THEN --CR41733 TF SL SMARTPHONE CHECK STARTS
           IF (TRUNC(rec1(i).exp_date) - TRUNC(sysdate) <= 30) THEN                      --check the service end date less than 30 days
             INSERT
             INTO table_x_pending_redemption
               (
                 objid,
                 pend_red2x_promotion,
                 x_pend_red2site_part,
                 x_pend_type,
                 pend_redemption2esn,
                 x_case_id,
                 x_granted_from2x_call_trans,
                 PEND_RED2PROG_PURCH_HDR
               )
               VALUES
               (
                 sa.sequ_x_pending_redemption.NEXTVAL,
                  (SELECT objid FROM table_x_promotion WHERE x_promo_code = 'SLTF30D'), --check this the promo code value to be insert in table_x_promotion
                 rec1(i).site_part_objid,
                 'BPDelivery',----x_pend_type check this value
                 NULL,
                 NULL,
                 NULL,
                 sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL --rec1.purch_hdr_objid
               );
          --Check do we have to update site part and part inst tables
		     UPDATE table_site_part
             SET x_expire_dt = x_expire_dt + (SELECT X_ACCESS_DAYS FROM table_x_promotion WHERE x_promo_code = 'SLTF30D'),
		       WARRANTY_DATE = WARRANTY_DATE + (SELECT X_ACCESS_DAYS FROM table_x_promotion WHERE x_promo_code = 'SLTF30D')
             WHERE objid     = rec1(i).site_part_objid
             AND part_status = 'Active';

             UPDATE table_part_inst
             SET WARR_END_DATE = WARR_END_DATE + (SELECT X_ACCESS_DAYS FROM table_x_promotion WHERE x_promo_code = 'SLTF30D')
             WHERE PART_SERIAL_NO IN ( rec1(i).x_esn )
             AND x_part_inst_status='52';
           END IF;
         END IF ;--CR41733 TF SL SMARTPHONE CHECK ENDS

         --Generate Batch ID
         BEGIN
           SELECT COUNT(*)+1 new_batch
           INTO v_new_batch
           FROM sa.X_LIFELINE_HIST_JOB
           WHERE SUBSTR(x_batch_id,1,3)= SUBSTR(TO_CHAR(sysdate,'MONTH'),1,3);
           v_batch_id                 := SUBSTR(TO_CHAR(sysdate,'MONTH'),1,3)||TO_CHAR(sysdate,'YY')||TO_CHAR(v_new_batch)||'_NONPPE';
         EXCEPTION
         WHEN OTHERS THEN
           v_batch_id := SUBSTR(TO_CHAR(sysdate,'MONTH'),1,3)||TO_CHAR(sysdate,'YY')||TO_CHAR(999)||'_NONPPE';
         END;

         INSERT
         INTO x_program_gencode
           (
             objid,
             x_esn,
             x_insert_date,
             x_status,
             GENCODE2PROG_PURCH_HDR,
             x_ota_trans_id,
             X_SWEEP_AND_ADD_FLAG, -- CR14175
             sw_flag               --CR29935
           )
           VALUES
           (
             sa.SEQ_X_PROGRAM_GENCODE.NEXTVAL,
             rec1(i).x_esn,
             SYSDATE + future_days,              --CR10569
             CASE WHEN i_daily_monthly_flag = 'D' THEN status_flag
                  WHEN i_daily_monthly_flag = 'M' AND status_flag = 'SW_INSERTED' THEN v_batch_id
				  ELSE status_flag
             END, --For Daily status_flag (BAU)                       --
             sa.SEQ_X_PROGRAM_PURCH_HDR.CURRVAL, -- rec1.purch_hdr_objid,
             (
             CASE
               WHEN l_ca_client=1 OR status_flag = 'SKIPPED' -- CR47024
               THEN NULL
			   WHEN l_is_swb_carr IS NULL AND ppe_flag=0 --CR41733 TF SL SMARTPHONE which are not ready will be with NULL
    			THEN NULL
               WHEN l_is_swb_carr = 'SW_CR'
               THEN 256
               ELSE ip_x_ota_trans_id
             END),
             rec1(i).X_SWEEP_AND_ADD_FLAG, -- CR14175
             CASE WHEN status_flag = 'SKIPPED'
                  THEN NULL
                  ELSE l_is_swb_carr -- CR47024
                   END
           );
         COMMIT;
         --CR44345, the below code will help to fire the purch_hdr_trigger for unthrotlle lifeline
         update x_program_purch_hdr
            set x_status    = x_status,
                x_ics_rcode = '100'
          where objid = l_pgm_hdr_objid;

          UPDATE x_sl_deliver_benefits_stg
          SET processed_flag       = 'Y',
              processed_date       = SYSDATE,
              x_sweep_and_add_flag = rec1(i).x_sweep_and_add_flag ,
              sw_flag              = rec1(i).sw_flag
          WHERE rowid              = rec1(i).rid;

         commit;
   	  END LOOP; -- bulk Collection loop
   	  EXIT WHEN rec1.COUNT = 0;
    END LOOP; -- Cursor fetch loop
    CLOSE lifeline_enroll_cur;
    op_result := 0;
    op_msg    := 'Success';
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line ('Error '|| TO_CHAR (SQLCODE)|| ': '|| SQLERRM);
    op_result := SQLCODE;
    op_msg    := SQLERRM;
  END DELIVER_RECURRING_MINUTES;
---
--Local procedure
PROCEDURE get_data_metering_source ( i_esn_part_inst_objid  IN  NUMBER   ,
                                     i_bus_org_id           IN  VARCHAR2 ,
                                     i_service_plan_group   IN  VARCHAR2 ,
                                     i_device_type          IN  VARCHAR2 ,
                                     o_parent_name          OUT VARCHAR2 ,
                                     o_data_metering_source OUT VARCHAR2 ,
                                     o_response             OUT VARCHAR2 ) IS

BEGIN

  BEGIN
    SELECT p.x_parent_name parent_name
    INTO   o_parent_name
    FROM   table_part_inst pi_min,
           table_x_parent p,
           table_x_carrier_group cg,
           table_x_carrier c
    WHERE  1 = 1
    AND    pi_min.part_to_esn2part_inst = i_esn_part_inst_objid
    AND    pi_min.x_domain = 'LINES'
    and    pi_min.part_inst2carrier_mkt = c.objid
    AND    c.carrier2carrier_group = cg.objid
    AND    cg.x_carrier_group2x_parent = p.objid;
   EXCEPTION
    WHEN OTHERS THEN
      o_data_metering_source := 'PPE';
      RETURN;
  END;

  IF o_parent_name IS NULL THEN
    o_data_metering_source :=  'PPE';
    RETURN;
  END IF;

  BEGIN
    SELECT NVL(data_mtg_source,'PPE') mtg_source
    INTO   o_data_metering_source
    FROM   ( SELECT data_mtg_source
             FROM   sa.x_product_config
             WHERE  1 = 1
             AND    brand_name = i_bus_org_id
             AND    device_type = i_device_type
             AND    parent_name = o_parent_name
             AND    NVL(service_plan_group,'X') = CASE WHEN service_plan_group IS NOT NULL
                                                         AND
                                                         service_plan_group = i_service_plan_group
                                                    THEN service_plan_group
                                                    ELSE 'X'
                                                     END
             ORDER BY CASE WHEN service_plan_group = i_service_plan_group
                            THEN 1
                            ELSE 2
                              END)
    WHERE ROWNUM = 1;
   EXCEPTION
    WHEN OTHERS THEN
       o_data_metering_source := 'PPE';
       RETURN;
  END;

  -- Success
  o_response := 'SUCCESS';

 EXCEPTION
  WHEN OTHERS THEN
   o_data_metering_source := 'PPE';
   o_response := 'UNHANDLED ERROR: ' || SQLERRM;
END get_data_metering_source;

---
PROCEDURE get_sw_cr_flag ( i_site_part_objid IN NUMBER          ,
                           i_esn             IN VARCHAR2        ,
                           o_sw_flag         OUT      VARCHAR2  ,
                           o_plan_type       OUT      VARCHAR2  ,
                           o_msg              OUT      VARCHAR2                 -- Output Message
                          ) IS

  sw_flag                VARCHAR2(30) := NULL;
  c                      sa.customer_type := sa.customer_type();
  c_parent_exist_flag    VARCHAR2(1);
  c_data_metering_source VARCHAR2(50);
BEGIN

  -- get the service plan group
  BEGIN
    SELECT fea.service_plan_group , fea.plan_type
    INTO   c.service_plan_group   , o_plan_type
    FROM   x_service_plan_site_part spsp,
           sa.service_plan_feat_pivot_mv fea
    WHERE  spsp.table_site_part_id = i_site_part_objid
    AND    spsp.x_service_plan_id = fea.service_plan_objid;
   EXCEPTION
    WHEN OTHERS THEN
      o_plan_type := NULL;
  END;

  --DBMS_OUTPUT.PUT_LINE('service_plan_group => ' || c.service_plan_group);

  -- get the device type, esn part inst objid and brand name
  BEGIN
    SELECT pcpv.device_type ,
           pi.objid,
           pcpv.bus_org bus_org_id
    INTO   c.device_type,
           c.esn_part_inst_objid,
           c.bus_org_id
    FROM   table_part_inst pi,
           table_mod_level ml,
           table_part_num pn,
           pcpv_mv pcpv
    WHERE  1 = 1
    AND    pi.part_serial_no       = i_esn
    AND    pi.x_domain             = 'PHONES'
    AND    pi.n_part_inst2part_mod = ml.objid
    AND    ml.part_info2part_num   = pn.objid
    AND    pn.domain               = 'PHONES'
    AND    pn.part_num2part_class  = pcpv.pc_objid;
   EXCEPTION
    WHEN OTHERS THEN
      c.device_type := NULL;
  END;

  --DBMS_OUTPUT.PUT_LINE('device_type => ' || c.device_type);
  --DBMS_OUTPUT.PUT_LINE('esn_part_inst_objid => ' || c.esn_part_inst_objid);
  --DBMS_OUTPUT.PUT_LINE('bus_org_id => ' || c.bus_org_id);

  -- get the parent name and data metering source
  get_data_metering_source ( i_esn_part_inst_objid  => c.esn_part_inst_objid ,
                             i_bus_org_id           => c.bus_org_id          ,
                             i_service_plan_group   => c.service_plan_group  ,
                             i_device_type          => c.device_type         ,
							 o_parent_name          => c.parent_name         ,
							 o_data_metering_source => c_data_metering_source,
                             o_response             => c.response            );

  --DBMS_OUTPUT.PUT_LINE('parent_name => ' || c.parent_name);
  --DBMS_OUTPUT.PUT_LINE('c_data_metering_source => ' || c_data_metering_source);
  --DBMS_OUTPUT.PUT_LINE('response => ' || c.response);

  -- get the parent name exists flag
  BEGIN
    SELECT CASE WHEN COUNT(1) > 0 THEN 'Y' ELSE 'N' END parent_name_exist_flag
    INTO   c_parent_exist_flag
    FROM   table_x_parameters
    WHERE  x_param_name LIKE 'SL_SW_READY%'
    AND    x_param_value = c.parent_name;
   EXCEPTION
    WHEN OTHERS THEN
      c_parent_exist_flag := 'N';
  END;

  --DBMS_OUTPUT.PUT_LINE('c_parent_exist_flag => ' || c_parent_exist_flag);

  --
  IF ( c.device_type IN ('BYOP','SMARTPHONE')) OR
     ( c.device_type = 'FEATURE_PHONE' AND
       c_data_metering_source <> 'PPE'
     )
  THEN
    --
    IF c_parent_exist_flag = 'Y' THEN
      sw_flag := 'SW_CR';
    END IF;
  ELSE
    sw_flag := NULL; -- including 'FEATURE_PHONE'
  END IF;

  o_sw_flag := sw_flag;
  o_msg     := 'SUCCESS';

 EXCEPTION
  WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE('UNHANDLED EXCEPTION: ' || SQLERRM);
  o_sw_flag   := NULL;
  o_msg     := substr (SQLERRM,1,500);
END get_sw_cr_flag;
END BILLING_LIFELINE_PKG;
/