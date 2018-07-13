CREATE OR REPLACE PACKAGE BODY sa."BILLING_JOB_PKG"
IS
 --------------------------------------------------------------------------------------------
 /* ****************************************
 CR22313 HPP Phase 2 22-Aug-2014 vkashmire
 Below program units Modifed / created as part of CR22313 / CR29489 / CR29079
 procedure P_SUSPEND_HPP_ENROLLMENT
 Procedure P_CHECK_ZIPCODE_N_SUSPEND_HPP
 PROCEDURE P_SUSPEND_HPP_HAVING_NO_ACC
 FUNCTION F_VALIDATE_ACC_B4_HPP_TRANSFER
 PROCEDURE P_VALIDATE_HPP_TRANSFER
 PROCEDURE P_TRANSFER_HPP_FROM_ESN_TO_ESN
 PROCEDURE P_PORT_CASE_SUSPEND_HPP
 procedure p_brk_esn_relations_hppbyop
 ***************************************** */
  --$RCSfile: BILLING_JOB_PKG.sql,v $
  --$Revision: 1.151 $
  --$Author: rvegi $
  --$Date: 2018/05/25 18:43:49 $
  --$ $Log: BILLING_JOB_PKG.sql,v $
  --$ Revision 1.151  2018/05/25 18:43:49  rvegi
  --$ *** empty log message ***
  --$
  --$ Revision 1.150  2018/05/24 18:36:16  rvegi
  --$ *** empty log message ***
  --$
  --$ Revision 1.149  2018/05/23 21:52:36  rvegi
  --$ *** empty log message ***
  --$
  --$ Revision 1.148  2018/04/27 19:03:33  rvegi
  --$ CR57400 Code Improvement
  --$
  --$ Revision 1.147  2018/04/23 16:33:53  rvegi
  --$ CR57400
  --$
  --$ Revision 1.146  2018/04/20 20:58:13  rvegi
  --$ CR57400
  --$
  --$ Revision 1.145  2018/04/20 13:41:35  rvegi
  --$ CR57400
  --$
  --$ Revision 1.144  2018/04/20 13:39:01  rvegi
  --$ CR57400
  --$
  --$ Revision 1.143  2017/11/13 20:52:09  sinturi
  --$ Added exception block
  --$
  --$ Revision 1.140  2017/10/26 22:25:55  smeganathan
  --$ added call to vas in deenroll job procedure
  --$
  --$ Revision 1.139  2017/10/06 21:59:17  smeganathan
  --$ Added VAS program class for future use
  --$
  --$ Revision 1.138  2017/10/05 16:37:44  smeganathan
  --$ Merged Asurion Project changes with 10/5 prod release
  --$
  --$ Revision 1.137  2017/09/28 21:50:29  smeganathan
  --$ added a call to vas from recurring payment to sync statuses
  --$
  --$ Revision 1.136  2017/09/01 20:36:05  mtholkappian
  --$ CR52959
  --$
  --$ Revision 1.134  2017/03/27 21:10:06  mshah
  --$ CR49066 - Billing Upgrade job changes
  --$
  --$ Revision 1.133  2017/02/28 22:06:37  rpednekar
  --$ CR46033
  --$
  --$ Revision 1.132  2017/02/13 16:07:33  vlaad
  --$ Updated RECURRING_PAYMENT to remove case sensitive look up of X_ABA_TRANSIT
  --$
  --$ Revision 1.130  2016/12/15 23:15:36  sraman
  --$ CR44729 - go_smart added new merchant ids
  --$
  --$ Revision 1.129  2016/10/11 18:45:10  rpednekar
  --$ CR42924 - Main cursor query changed for B2B and non B2B.  Discount record inserted for B2B in x_program_discount_hist table.
  --$
  --$ Revision 1.128  2016/10/11 16:24:13  rpednekar
  --$ CR42924 - Main cursor query changed for B2B and non B2B.  Discount record inserted for B2B in x_program_discount_hist table.
  --$
  --$ Revision 1.124  2016/09/20 16:49:39  skota
  --$ modified the suspend wait period job for enrolled no accounts
  --$
  --$ Revision 1.122  2016/08/30 16:49:44  aganesan
  --$ New parameter added for program parameter objid value to while invoking get brm applicable flag function
  --$
  --$ Revision 1.121  2016/08/24 23:23:05  aganesan
  --$ Exclude simple mobile change removed from ready_to_reenroll_job procedure
  --$
  --$ Revision 1.120  2016/08/23 23:15:34  aganesan
  --$ Modified code to exclude simple mobile brand
  --$
  --$ Revision 1.119  2016/06/10 16:33:57  tbaney
  --$ Added Logic for cybersource.
  --$
  --$ Revision 1.118  2016/05/31 14:44:27  nmuthukkaruppan
  --$ CR41241-Using 2 digit X_POSTAL_CODE instead of NAME from table_country table.
  --$
  --$ Revision 1.117  2016/05/20 15:33:21  nmuthukkaruppan
  --$ CR41241- Removed the hardcoded 'USA' and take the Country Name from "table_country"  for International CreditCards Autorefill
  --$
  --$ Revision 1.115  2016/02/04 16:22:01  ddevaraj
  --$ CR38545
  --$
  --$ Revision 1.113  2016/01/25 19:56:40  jarza
  --$ Unmerged CR37949 changes
  --$
  --$ Revision 1.112  2016/01/21 21:56:35  skota
  --$ Modified for CR38545
  --$
  --$ Revision 1.111  2016/01/15 20:46:59  rpednekar
  --$ x_next_delivery_date is updated as NULL in suspense_wait_period_job and de_enrollment job.
  --$
  --$ Revision 1.106  2015/12/28 18:55:08  rpednekar
  --$ CR38545 - Cursor query changes for procedures suspend_wait_period_job and de_enroll_job
  --$
  --$ Revision 1.102  2015/12/09 21:32:52  vyegnamurthy
  --$ Commented DBMS for upgrade job
  --$
  --$ Revision 1.101  2015/12/05 14:45:25  vnainar
  --$ CR38927  program transfer procedure moved to safelink_service_pkg
  --$
  --$ Revision 1.100  2015/12/04 00:24:11  arijal
  --$ CR38927 sl upgrade
  --$
  --$ Revision 1.97  2015/09/17 15:34:04  jarza
  --$ CR35567 - Reverting back to production version for address
  --$
  --$ Revision 1.95  2015/08/25 15:08:02  pvenkata
  --$ CR33090
  --$
  --$ Revision 1.94  2015/08/07 18:10:10  jarza
  --$ Removed unwanted typo characters
  --$
  --$ Revision 1.93  2015/08/07 18:01:07  jarza
  --$ CR34962
  --$
  --$ Revision 1.91  2015/07/31 16:00:42  jarza
  --$ Removed unwanted typo characters
  --$
  --$ Revision 1.90  2015/07/30 18:05:52  jarza
  --$ CR34962
  --$
  --$ Revision 1.88  2015/07/24 14:32:56  jarza
  --$ CR34962
  --$
  --$ Revision 1.87  2015/07/24 14:30:56  jarza
  --$ Removed special characters which occured due to format
  --$
  --$ Revision 1.86  2015/07/24 14:16:56  jarza
  --$ CR34962 - adding bundle logic call
  --$
  --$ Revision 1.84  2015/06/09 18:25:08  aganesan
  --$ CR34303 - Added new column for priority in Group clause.
  --$
  --$ Revision 1.83  2015/06/03 23:47:39  aganesan
  --$ CR34303 - Changes
  --$
  --$ Revision 1.80  2015/02/21 00:52:56  vkashmire
  --$ CR32396 - remove x_real_esn
  --$
  --$ Revision 1.79  2015/01/21 19:04:50  jarza
  --$ Change due to schema change for table_x_bank_account adding encryption related columns - CR32288
  --$ Checked in for Aysha
  --$
  --$ Revision 1.78  2015/01/08 20:45:06  jarza
  --$ CR31859 - Changes to recurring_payment_b2b  - Processing B2B records based on input priority flag
  --$
  --$ Revision 1.77  2014/12/31 19:02:29  pvenkata
  --$ CR30259 Recurring payment proc changes
  --$
  --$ Revision 1.74  2014/12/19 22:14:22  jarza
  --$ Remove comma from all address related columns
  --$
  --$ Revision 1.73  2014/12/15 16:05:01  icanavan
  --$ MODIFY AND ADD NOTES FOR CR30259
  --$
  --$ Revision 1.68  2014/10/21 13:42:23  cpannala
  --$ Checked in for Aysha ? for CR28870
  --$
  --$ Revision 1.67  2014/10/06 15:59:01  vkashmire
  --$ checked in for Aysha ? for ACH POC Encryption
  --$ CR28870
  --$
  --$ Revision 1.66  2014/09/24 14:20:34  vkashmire
  --$ CR29079 -hpp transfer logs added
  --$
  --$ Revision 1.65  2014/09/23 16:44:42  vkashmire
  --$ CR29079-hpp transfer logs added
  --$
  --$ Revision 1.64  2014/09/22 17:55:23  vkashmire
  --$ CR29079 - hpp transfer change
  --$
  --$ Revision 1.63  2014/09/20 14:55:01  vkashmire
  --$ CR29489 - hpp transfer checks modified
  --$
  --$ Revision 1.62  2014/09/11 16:12:51  vkashmire
  --$ CR29489 - hpp deEnrollment changes
  --$
  --$ Revision 1.61  2014/09/02 15:14:57  vkashmire
  --$ CR29489
  --$
  --$ Revision 1.60  2014/08/28 20:22:54  vkashmire
  --$ CR29489
  --$
  --$ Revision 1.59  2014/08/23 17:06:14  vkashmire
  --$ CR22313
  --$
  --$ Revision 1.58  2014/08/23 17:05:07  vkashmire
  --$ CR22313
  --$
  --$ Revision 1.57  2014/08/23 14:07:46  vkashmire
  --$ CR29489
  --$
  --$ Revision 1.56  2014/08/22 20:57:12  vkashmire
  --$ CR22313 HPP Phase 2
  --$ CR29489 HPP BYOP
  --$ CR27087
  --$ CR29638
  --$
  --$ Revision 1.55  2014/08/12 21:55:53  rramachandran
  --$ CR29633 - Adding EnrollmentPending
  --$
  --$ Revision 1.54  2014/08/12 21:47:13  rramachandran
  --$ CR29633 - Modify Billing Upgrade Job for Port In Cases Defect #18
  --$
  --$ Revision 1.53  2014/08/01 19:27:38  rramachandran
  --$ CR29633 - Modify Billing Upgrade Job for Port In Cases
  --$
  --$ Revision 1.52  2014/06/23 19:42:41  jarza
  --$ Triming special characters from first name and last name columns
  --$
  --$ Revision 1.51  2014/06/19 18:04:25  jarza
  --$ Merging "CR26593 - Removing special characters for batch payment job failure" with production version 1.50
  --$
  --$ Revision 1.50  2014/06/18 23:06:09  cpannala
  --$ CR29410 has B2B changes with prod merge.
  --$
  --$ Revision 1.49  2014/06/18 14:22:37  cpannala
  --$ CR29410 Chanegs made to 'reccurring payment' for B2B grouping.
  --$
  --$ Revision 1.48  2014/06/16 22:04:02  cpannala
  --$ Changes for Recurring payment b2b
  --$
  --$ Revision 1.47  2014/06/16 21:55:23  cpannala
  --$ CR29410 has changes.
  --$
  --$ Revision 1.46  2014/06/16 17:37:23  cpannala
  --$ Changes made to fix defect 355,356 for B2B recuuring payment API
  --$
  --$ Revision 1.42  2014/05/08 12:24:16  ahabeeb
  --$ rectified data type of in_merch_ref_no for proc sp_bill_trans
  --$
  --$ Revision 1.41  2014/05/05 22:05:14  cpannala
  --$ CR25490 B2B changes
  --$
  --$ Revision 1.32  2014/03/17 15:49:08  cpannala
  --$ CR25490 changes amde to reccuring payment to accomidate B2B process
  --$
  --$ Revision 1.29  2014/03/05 16:38:16  mvadlapally
  --$ CR25625 Batch process improvement. Merge with Prod
  --$
  --$ Revision 1.28  2014/03/05 16:14:45  mvadlapally
  --$ CR25625 Batch process improvement. Merge with Prod
  --$
  --$ Revision 1.27  2014/03/05 15:46:27  mvadlapally
  --$ CR25625 Batch process improvement. Merge with Prod
  --$
  --$ Revision 1.26  2014/02/17 16:14:01  mvadlapally
  --$ CR25625 Batch process improvement. Merge with Prod
  --$
  --$ Revision 1.22  2013/09/30 13:23:12  ymillan
  --$ CR24538
  --$
  --$ Revision 1.21  2013/09/26 16:45:29  ymillan
  --$ CR24538
  --$
  --$ Revision 1.20  2013/09/10 19:25:44  ymillan
  --$ CR24538 E911 surcharge added
  --$
  --$ Revision 1.19  2012/11/02 19:03:34  mmunoz
  --$ CR22380: Updated in order to have the same signature in the SP_TAXES's functions
  --$
  --------------------------------------------------------------------------------------------
  global_error_message VARCHAR2(300);
  --CR8663
  ----
  -- CR30259 MODIFIED TO GET ZIP CODE FOR TAXES FROM TABLE_ADDRESS
PROCEDURE recurring_payment_b2b(
    p_bus_org   IN VARCHAR2 DEFAULT 'TRACFONE',
    in_priority IN VARCHAR2 DEFAULT NULL,
    op_result OUT NUMBER,
    op_msg OUT VARCHAR2 )
IS
  l_sysdate DATE DEFAULT SYSDATE;
  v_pgm_enrolled x_program_enrolled%ROWTYPE;
  v_credit_card_rec table_x_credit_card%ROWTYPE;
  v_bank_acount table_x_bank_account%ROWTYPE;
  l_mer_ref_no VARCHAR2 (200);
  address table_address%ROWTYPE;
  clear_address table_address%ROWTYPE;
  bank table_address%ROWTYPE;
  l_charge_desc     VARCHAR2 (255);
  retval            BOOLEAN;
  x_py_pur_hdr_id   NUMBER;
  l_price_p         NUMBER (10, 2) := 0;
  l_price_s         NUMBER (10, 2) := 0;
  l_tmp_s           NUMBER (10, 2) := 0;
  l_tax             NUMBER (10, 2) := 0;
  L_E911_TAX        NUMBER (10, 2) := 0;
  L_e911_surcharge  NUMBER (10, 2) := 0;
  l_usf_tax         NUMBER (10, 2) := 0;
  l_rcrf_tax        NUMBER (10, 2) := 0;
  l_count           NUMBER         := 0;
  l_next_cycle_date DATE;
  total_price       NUMBER (10, 2) := 0;
  l_payment_source_type x_payment_source.x_pymt_type%TYPE;
  l_credit_card_objid  NUMBER;
  l_bank_account_objid NUMBER;
  l_merchant_id table_x_cc_parms.x_merchant_id%TYPE;
  l_ignore_bad_cv table_x_cc_parms.x_ignore_bad_cv%TYPE;
  l_enroll_type       VARCHAR2 (30);
  l_enroll_amount     NUMBER;
  l_enroll_units      NUMBER;
  l_enroll_days       NUMBER;
  l_error_code        NUMBER;
  l_error_message     VARCHAR2 (255);
  l_sales_tax_percent NUMBER;
  l_e911_tax_percent  NUMBER;
  l_usf_tax_percent   NUMBER;
  l_rcrf_tax_percent  NUMBER;
  bmultimerchantflag  BOOLEAN := TRUE;
  l_commit_size       NUMBER  := 1;
  l_commit_counter    NUMBER  := 0;
  L_tax_rule          VARCHAR2(30) ;       -- CR27269
  L_data_tax_rule     VARCHAR2(30) ;       -- CR26033
  l_tmp_b2b           NUMBER (10, 2) := 0; --cr25490
  total_price_b2b     NUMBER (10, 2) := 0; --cr25490
  l_price_b2b         NUMBER (10, 2) := 0; --cr25490
  total_usf_tax       NUMBER (10, 2) ;
  total_rcrf_tax      NUMBER (10, 2);
  total_e911_tax      NUMBER (10, 2);
  total_tax           NUMBER (10, 2);
  l_b2b_pmt_counter   NUMBER; -- CR57400
  l_prog_class        x_program_parameters.x_prog_class%TYPE; -- CR57400
  --
  CURSOR b2b_cur
  IS
    SELECT
      /*+ ORDERED INDEX(pe IDX_PRG_PARAM_CHARGEDT) */
      pe.pgm_enroll2web_user web_objid,
      pe.pgm_enroll2x_pymt_src ps_objid,
      mtmb.x_priority
    FROM x_program_enrolled pe ,
      x_program_parameters pp ,
      sa.mtm_batch_process_type mtmb
    WHERE 1                     = 1
    AND pe.x_next_charge_date  <= SYSDATE
    AND pe.x_enrollment_status IN ('ENROLLED', 'ENROLLMENTSCHEDULED')
    AND pp.objid                = pe.pgm_enroll2pgm_parameter
    AND pp.x_program_name LIKE '%B2B'
    AND mtmb.x_prgm_objid          = pe.pgm_enroll2pgm_parameter
    AND NVL (mtmb.x_priority, '1') = NVL (UPPER (in_priority), NVL (mtmb.x_priority, '1'))
    AND pe.x_wait_exp_date        IS NULL
    AND pe.pgm_enroll2x_pymt_src IS NOT NULL    --CR42924
    --CR43305 Exclude Simple Mobile
        AND NOT EXISTS
        (SELECT 1
         FROM   x_program_parameters xpp
         WHERE  xpp.objid = pe.pgm_enroll2pgm_parameter
         AND    get_brm_applicable_flag(i_bus_org_objid => xpp.prog_param2bus_org,i_program_parameter_objid => xpp.objid ) = 'Y' )
    GROUP BY pe.pgm_enroll2web_user ,
      pe.pgm_enroll2x_pymt_src,
      mtmb.x_priority;
  b2b_rec b2b_cur%ROWTYPE; ---CR25490 CPannala
  --
  CURSOR b2b_esn_cur ( wu_objid IN NUMBER, ps_objid IN NUMBER)
  IS
    SELECT *
    FROM x_program_enrolled
    WHERE pgm_enroll2web_user    = wu_objid
    AND pgm_enroll2x_pymt_src+0  = ps_objid
    AND x_next_charge_date   +0 <= SYSDATE
    AND x_enrollment_status
      ||''               IN ('ENROLLED', 'ENROLLMENTSCHEDULED')
    AND (x_wait_exp_date IS NULL);
  b2b_esn_rec b2b_esn_cur%ROWTYPE;---CR25490 CPannala
  CURSOR c2(pe IN x_program_enrolled%rowtype)
  IS
    SELECT *
    FROM
      (SELECT RANK() OVER (PARTITION BY tab1.objid ORDER BY a.x_rqst_date DESC) rnk2,
        a.x_status,
        a.x_payment_type,
        tab1.rnk
      FROM
        (SELECT
          /*+ index(c PGM_PURCH_DTL2PGM_ENROLLED)
          use_nl(c) */
          pe.x_enrolled_date,
          pe.objid,
          c.objid dtl_objid,
          c.pgm_purch_dtl2prog_hdr,
          RANK() OVER (PARTITION BY pe.objid ORDER BY pgm_purch_dtl2prog_hdr DESC) rnk
        FROM x_program_purch_dtl c
        WHERE 1                          = 1
        AND c.pgm_purch_dtl2pgm_enrolled = pe.objid
        AND c.pgm_purch_dtl2penal_pend  IS NULL
        ) tab1,
      x_program_purch_hdr a
    WHERE tab1.rnk         < 5
    AND a.objid            = tab1.pgm_purch_dtl2prog_hdr
    AND a.x_rqst_date + 0 >= tab1.x_enrolled_date
      )tab2
    WHERE tab2.rnk2 = 1
    AND 1           = (
      CASE
        WHEN (tab2.x_status IN ('ENROLLACHPENDING', 'RECURACHPENDING','PAYNOWACHPENDING', 'INCOMPLETE', 'SUBMITTED', 'RECURINCOMPLETE' ) )
        THEN 1
        WHEN ( ( tab2.x_status  = 'FAILED'
        OR tab2.x_status        = 'FAILPROCESSED' )
        AND tab2.x_payment_type = 'RECURRING' )
        THEN 1
        ELSE 0
      END);
    c2_rec c2%rowtype;
    CURSOR CUR_PROMO_DTL (C_PROMO_ID NUMBER)
    IS
      SELECT * FROM TABLE_X_PROMOTION WHERE OBJID = C_PROMO_ID;
    REC_PROMO_DTL CUR_PROMO_DTL%ROWTYPE;
    CURSOR cur_act_stnt_promo ( c_esn VARCHAR2, c_program_enrolled_objid NUMBER )
    IS
      SELECT *
      FROM x_enroll_promo_grp2esn grp2esn
      WHERE 1                                   = 1
      AND grp2esn.x_esn                         = c_esn
      AND NVL(grp2esn.program_enrolled_objid,0) = c_program_enrolled_objid
      AND sysdate BETWEEN grp2esn.x_start_date AND NVL(grp2esn.x_end_date, sysdate + 1);
    rec_act_stnt_promo cur_act_stnt_promo%rowtype;
    l_promo_objid sa.table_x_promotion.objid%type;
    l_promo_code sa.table_x_promotion.x_promo_code%type;
    l_promo_enroll_type sa.table_x_promotion.x_transaction_type%type;
    l_promo_enroll_amount sa.table_x_promotion.x_discount_amount%type;
    l_esn_disc_amount sa.table_x_promotion.x_discount_amount%type;    --CR46033
    l_promo_enroll_units sa.table_x_promotion.x_units%type;
    l_promo_enroll_days sa.table_x_promotion.x_access_days%type;
    l_promo_error_code    NUMBER;
    l_promo_error_message VARCHAR2(400);
    l_country   table_country.s_name%type;
  BEGIN


    op_result := 0;
    op_msg    := 'Success';
    --DBMS_OUTPUT.PUT_LINE ('Beginning Payment Preparation Job b2b ');
    ---
    l_price_p  := 0;
    l_price_s  := 0;
    l_tax      := 0;
    l_e911_tax := 0;
    l_tmp_s    := 0;
    l_RCRF_tax := 0;
    l_usf_tax  := 0;
    BEGIN --b2b process strt CR25490 CPannala
      FOR b2b_rec IN b2b_cur
      LOOP
        total_price_b2b := 0;
        x_py_pur_hdr_id := billing_seq ('X_PROGRAM_PURCH_HDR');
        l_mer_ref_no    := merchant_ref_number;
        total_usf_tax   := 0 ;
        total_rcrf_tax  := 0;
        total_e911_tax  := 0;
        total_tax       := 0;
        l_enroll_amount := 0;

        FOR b2b_esn_rec IN b2b_esn_cur ( b2b_rec.web_objid, b2b_rec.ps_objid)

        LOOP

		-- CR57400 Changes

		l_b2b_pmt_counter :=1;

		BEGIN

		SELECT x_prog_class
		INTO l_prog_class
		FROM x_program_parameters
        WHERE objid=b2b_esn_rec.pgm_enroll2pgm_parameter;

		EXCEPTION
		WHEN OTHERS THEN
		l_prog_class :=NULL;
		END;


		IF l_prog_class = 'LOWBALANCE' THEN

		l_b2b_pmt_counter := NVL(data_club_pkg.b2b_payment_required_counter(b2b_esn_rec.x_esn),1);

		IF l_b2b_pmt_counter = 0 THEN
		   l_b2b_pmt_counter :=1;
		END IF;

		END IF;

		FOR I IN 1..l_b2b_pmt_counter  -- CR57400 Payment Required Counter Loop Starts
		LOOP

    l_esn_disc_amount    :=    0;    --CR46033

          IF (b2b_esn_rec.x_esn IS NULL) THEN
            --
            INSERT
            INTO x_program_error_log
              (
                x_source ,
                x_error_code ,
                x_error_msg ,
                x_date ,
                x_description ,
                x_severity
              )
              VALUES
              (
                'BILLING_JOB_PKG.recurring_payment' ,
                '-110' ,
                'Program enrolled ESN is null' ,
                SYSDATE ,
                'Program enrolled OBJID: '
                ||TO_CHAR(b2b_esn_rec.objid) ,
                2
              );
            COMMIT;
            --
          ELSE
            OPEN c2(b2b_esn_rec);
            FETCH c2 INTO c2_rec;
            IF c2%notfound THEN
              BEGIN
                l_tmp_b2b := b2b_esn_rec.x_amount;

                -------------- Start - CR35567 - B2B Promotion-----------------
                IF b2b_esn_rec.pgm_enroll2x_promotion IS NOT NULL THEN
                  --DBMS_OUTPUT.PUT_LINE ('B2B_ESN_CUR.PGM_ENROLL2X_PROMOTION: '||b2b_esn_rec.pgm_enroll2x_promotion);
                  OPEN cur_promo_dtl(b2b_esn_rec.pgm_enroll2x_promotion);
                  FETCH cur_promo_dtl INTO rec_promo_dtl;
                  IF cur_promo_dtl%FOUND THEN
                    --DBMS_OUTPUT.PUT_LINE ('ENTERED INTO NVL(L_PROMO_ENROLL_AMOUNT,0)');
                    l_promo_error_code    := NULL;
                    l_promo_error_message := NULL;
                    l_promo_objid         := NULL;
                    l_promo_code          := NULL;
                    l_promo_enroll_type   := NULL;
                    l_promo_enroll_amount := NULL;
                    l_promo_enroll_units  := NULL;
                    l_promo_enroll_days   := NULL;
                    OPEN cur_act_stnt_promo(b2b_esn_rec.x_esn, b2b_esn_rec.objid);
                    FETCH cur_act_stnt_promo INTO rec_act_stnt_promo;
                    IF cur_act_stnt_promo%FOUND THEN
                      --DBMS_OUTPUT.PUT_LINE ('entering into cur_act_stnt_promo%found');
                      l_promo_objid := rec_act_stnt_promo.promo_objid;
                      --DBMS_OUTPUT.PUT_LINE ('start - sa.enroll_promo_pkg.sp_validate_promo');
                      sa.enroll_promo_pkg.sp_validate_promo ( b2b_esn_rec.x_esn , NULL -- p_program_objid
                      , 'recurring'                                                    -- p_process
                      , l_promo_objid                                                  -- p_promo_objid
                      , l_promo_code , l_promo_enroll_type , l_promo_enroll_amount , l_promo_enroll_units , l_promo_enroll_days , l_promo_error_code , l_promo_error_message );
                      --DBMS_OUTPUT.PUT_LINE ('end - sa.enroll_promo_pkg.sp_validate_promo');
                      --DBMS_OUTPUT.PUT_LINE ('l_promo_error_code:'||l_promo_error_code);
                      --DBMS_OUTPUT.PUT_LINE ('l_promo_code:'||l_promo_code);
                      --DBMS_OUTPUT.PUT_LINE ('l_promo_enroll_amount:'||l_promo_enroll_amount);
                      IF ( l_promo_error_code = 0 AND l_promo_code IS NOT NULL ) THEN
                        l_tmp_b2b            := l_tmp_b2b - l_promo_enroll_amount;
                        --DBMS_OUTPUT.PUT_LINE('Entered into if condition l_tmp_b2b:'||l_tmp_b2b);
                      END IF;
                    END IF;
                    CLOSE cur_act_stnt_promo;
                  END IF;
                  CLOSE cur_promo_dtl;
                  --DBMS_OUTPUT.PUT_LINE ('L_PROMO_ERROR_CODE:'||L_PROMO_ERROR_CODE);
                  --DBMS_OUTPUT.PUT_LINE ('L_PROMO_CODE:'||L_PROMO_CODE);
                  IF L_PROMO_ERROR_CODE = 0 AND L_PROMO_CODE IS NOT NULL THEN
                    --DBMS_OUTPUT.PUT_LINE ('Entering IF L_PROMO_ERROR_CODE = 0 AND L_PROMO_CODE IS NOT NULL');
                    l_enroll_amount := (l_promo_enroll_amount+l_enroll_amount);
            l_esn_disc_amount    :=    l_promo_enroll_amount;    --CR46033
                  END IF;
                END IF;
                -------------- End - CR35567 - B2B Promotion-----------------
                L_tax_rule      := sa.SP_TAXES.tax_rules_BILLING(b2b_esn_rec.x_esn) ;            -- CR30259
                L_data_tax_rule := sa.SP_TAXES.tax_rules_progs_data_BILLING(b2b_esn_rec.objid) ; -- CR30259
                -- CR30259
                IF l_TAX_RULE NOT IN ('SALES TAX ONLY','NO TAX') AND L_DATA_TAX_RULE NOT IN ('SALES TAX ONLY','NO TAX') THEN
                  l_usf_tax_percent := SP_TAXES.computeusftax_BILLING (b2b_esn_rec.pgm_enroll2web_user , b2b_esn_rec.pgm_enroll2pgm_parameter, b2b_esn_rec.PGM_ENROLL2X_PYMT_SRC   --, pgm_enrolled_rec.x_esn CR22380 removing ESN
                  );                                                                                                                                                               --STUL
                  l_rcrf_tax_percent := SP_TAXES.computemisctax_BILLING (b2b_esn_rec.pgm_enroll2web_user , b2b_esn_rec.pgm_enroll2pgm_parameter, b2b_esn_rec.PGM_ENROLL2X_PYMT_SRC --, pgm_enrolled_rec.x_esn CR22380 removing ESN
                  );                                                                                                                                                               --STUL
                ELSE
                  l_usf_tax_percent  := 0 ;
                  l_rcrf_tax_percent := 0 ;
                END IF ;
                -- -- CR30259
                IF b2b_esn_rec.objid  IS NOT NULL THEN
                  l_sales_tax_percent := SP_TAXES.computetax_BILLING (b2b_esn_rec.pgm_enroll2web_user , b2b_esn_rec.pgm_enroll2pgm_parameter, b2b_esn_rec.x_esn,b2b_esn_rec.PGM_ENROLL2X_PYMT_SRC ); -- CR30259
                  l_e911_tax_percent  := SP_TAXES.computee911tax_BILLING (b2b_esn_rec.pgm_enroll2web_user , b2b_esn_rec.pgm_enroll2pgm_parameter,b2b_esn_rec.PGM_ENROLL2X_PYMT_SRC                   --, pgm_enrolled_rec.x_esn CR22380 removing ESN
                  );
                  l_e911_surcharge := SP_TAXES.computee911surcharge_BILLING(b2b_esn_rec.pgm_enroll2web_user , b2b_esn_rec.PGM_ENROLL2PGM_PARAMETER,b2b_esn_rec.PGM_ENROLL2X_PYMT_SRC);
               END IF ;
                --
                IF l_TAX_RULE IN ('SALES TAX ONLY','NO TAX') OR l_data_tax_rule IN ('SALES TAX ONLY','NO TAX') THEN
                  l_e911_tax_percent := 0 ;
                  l_e911_surcharge   := 0 ;
                END IF;
                IF l_TAX_RULE IN ('NO TAX') OR l_DATA_TAX_RULE IN ('NO TAX') THEN
                  l_sales_tax_percent :=0 ;
                END IF ;
                sp_taxes.gettax_bill ( l_tmp_b2b, l_sales_tax_percent, l_e911_tax_percent, l_tax, l_e911_tax);
                l_e911_tax := NVL (l_e911_tax, 0) + NVL (l_e911_surcharge, 0);
                sp_taxes.gettax2_bill ( l_tmp_b2b, l_usf_tax_percent, l_rcrf_tax_percent, l_usf_tax, l_rcrf_tax);
                -- BEGIN CR52959 Calling the following procedure to override the l_usf_tax and l_rcrf_tax amounts if there flags are N
                 sp_taxes.GET_TAX_AMT(i_source_system => b2b_esn_rec.x_sourcesystem, o_usf_tax_amt => l_usf_tax, o_rcrf_tax_amt =>l_rcrf_tax ,o_usf_percent  => l_usf_tax_percent,o_rcrf_percent =>l_rcrf_tax_percent );
                 DBMS_OUTPUT.PUT_LINE( 'l_usf_tax :' || l_usf_tax ) ;
                 DBMS_OUTPUT.PUT_LINE( 'l_rcrf_tax :' || l_rcrf_tax ) ;
                 DBMS_OUTPUT.PUT_LINE( ' l_usf_tax_percent :' ||  l_usf_tax_percent ) ;
                 DBMS_OUTPUT.PUT_LINE( 'l_rcrf_tax_percent :' || l_rcrf_tax_percent ) ;
                ---END CR52959 Calling the above procedure to override the l_usf_tax and l_rcrf_tax amounts if there flags are N
                sp_taxes.gettax_bill ( l_tmp_b2b, l_sales_tax_percent, l_e911_tax_percent, l_tax, l_e911_tax);
                l_e911_tax := NVL (l_e911_tax, 0) + NVL (l_e911_surcharge, 0);
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
                    x_priority
            ,x_discount_amount        --CR46033
                  )
                  VALUES
                  (
                    billing_seq ( 'X_PROGRAM_PURCH_DTL'),
                    b2b_esn_rec.x_esn,
                    l_tmp_b2b,
                    ROUND(l_tax,2),
                    ROUND(l_e911_tax,2),
                    'Program charges for the cycle '
                    || TO_CHAR ( b2b_esn_rec.x_next_charge_date, 'MM/DD/YYYY')
                    || ' to '
                    || TO_CHAR ( l_next_cycle_date - 1, 'MM/DD/YYYY'),
                    b2b_esn_rec.x_next_charge_date,
                    l_next_cycle_date,
                    b2b_esn_rec.objid,
                    x_py_pur_hdr_id,
                    ROUND(l_usf_tax,2),
                    ROUND(l_rcrf_tax,2),
                    NVL(b2b_rec.x_priority,20)--Modified for CR34303 --in_priority
            ,NVL(l_esn_disc_amount,'0')    --CR46033
                  );
                retval          := billing_job_pkg.set_new_exp_date ( b2b_esn_rec.x_esn, b2b_esn_rec.objid);
                total_price_b2b := (l_tmp_b2b  + total_price_b2b);
                total_usf_tax   := (l_usf_tax  + total_usf_tax);
                total_rcrf_tax  := (l_rcrf_tax + total_rcrf_tax);
                total_e911_tax  := (l_e911_tax + total_e911_tax);
                total_tax       := (l_tax      + total_tax);
              END;


            ---CR42924
    BEGIN

        IF ( l_promo_error_code = 0 AND L_PROMO_code IS NOT NULL )
        THEN

            INSERT
            INTO x_program_discount_hist
            (
            objid,
            x_discount_amount,
            pgm_discount2x_promo,
            pgm_discount2pgm_enrolled,
            pgm_discount2prog_hdr,
            pgm_discount2web_user
            )
            VALUES
            (
            billing_seq ('X_PROGRAM_DISCOUNT_HIST'),
            NVL(l_esn_disc_amount,'0'),
            l_promo_objid,
            b2b_esn_rec.objid,
            x_py_pur_hdr_id,
            b2b_esn_rec.pgm_enroll2web_user
            );

        END IF;

        IF l_promo_code IS NULL AND NVL(l_esn_disc_amount,'0') != 0
        THEN


            INSERT
            INTO x_program_discount_hist
              (
                objid,
                x_discount_amount,
                pgm_discount2x_promo,
                pgm_discount2pgm_enrolled,
                pgm_discount2prog_hdr,
                pgm_discount2web_user
              )
              VALUES
              (
                billing_seq ('X_PROGRAM_DISCOUNT_HIST'),
                NVL(l_esn_disc_amount,'0'),
                b2b_esn_rec.pgm_enroll2x_promotion,
                b2b_esn_rec.objid,
                x_py_pur_hdr_id,
                b2b_esn_rec.pgm_enroll2web_user
              );

        END IF;
    EXCEPTION WHEN OTHERS
    THEN

        NULL;

    END;
        ---CR42924

            END IF;
            CLOSE c2;
          END IF;
        END LOOP; -- CR57400 Payment Required Counter Loop Ends Here.
		END LOOP;
        BEGIN
          SELECT x_pymt_type,
            pymt_src2x_credit_card,
            pymt_src2x_bank_account
          INTO l_payment_source_type,
            l_credit_card_objid,
            l_bank_account_objid
          FROM x_payment_source
          WHERE objid = b2b_rec.ps_objid;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
              'BILLING_JOB_PKG.recurring_payment_b2b',
              -100,
              global_error_message,
              SYSDATE,
              'No Payment source found for '
              || TO_CHAR (b2b_rec.ps_objid ),
              2 -- MEDIUM
            );
          op_result := -100;
          op_msg    := 'No Payment source found for ' || TO_CHAR (b2b_rec.ps_objid );
          NULL;
          --This record has failed. However, do not hold up the batch. Continue further processing
        END;
        -----------------------------------------------------------------------------------------------------------
        --- Get the merchant id from x_cc_parms table.
        IF (bmultimerchantflag = FALSE) THEN
          BEGIN
            SELECT DECODE (p_bus_org, 'TRACFONE', 'tracfone', x_merchant_id),
              x_ignore_bad_cv
            INTO l_merchant_id,
              l_ignore_bad_cv
            FROM table_x_cc_parms
            WHERE x_bus_org = p_bus_org;
            --l_merchant_id := 'tracfone';     -- *** Hardcoded for now. All merchant IDs to be Tracfone **** ---
          EXCEPTION
          WHEN OTHERS THEN
            global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
                'BILLING_JOB_PKG.recurring_payment_b2b',
                -107,
                global_error_message,
                SYSDATE,
                'No merchant parameter settings found in table_x_cc_params for the business organization',
                2 -- MEDIUM
              );
            op_result     := -107;
            op_msg        := 'No merchant parameter settings found in table_x_cc_params for the business organization';
            l_merchant_id := NULL;
          END;
        ELSE
          --------------- Multi merchant ID ------------------------------------------------------------
          BEGIN
            SELECT COUNT (*)
            INTO l_count
            FROM
              (SELECT pe.*
              FROM table_web_user wu,
                x_business_accounts ba,
                x_program_enrolled pe
              WHERE wu.web_user2contact  = ba.bus_primary2contact
              AND pe.pgm_enroll2web_user = wu.objid
              UNION ALL--CR29196
              SELECT pe.*
              FROM table_web_user wu,
                X_SITE_WEB_ACCOUNTS swa,
                x_program_enrolled pe
              WHERE wu.objid             = SWA.SITE_WEB_ACCT2WEB_USER
              AND pe.pgm_enroll2web_user = wu.objid
              );
            IF l_count > 0 THEN --Buisness Account B2B
              SELECT x_merchant_id,
                x_ignore_bad_cv
              INTO l_merchant_id,
                l_ignore_bad_cv
              FROM table_x_cc_parms
              WHERE x_bus_org = 'BILLING B2B';
            ELSE -- regular account
              SELECT x_merchant_id,
                x_ignore_bad_cv
              INTO l_merchant_id,
                l_ignore_bad_cv
              FROM table_x_cc_parms
              WHERE x_bus_org =
                (SELECT 'BILLING '
                  || org_id
                FROM table_bus_org
                WHERE objid IN
                  (SELECT prog_param2bus_org
                  FROM x_program_parameters
                  WHERE objid = b2b_esn_rec.pgm_enroll2pgm_parameter
                  )
                );
            END IF;
          EXCEPTION
          WHEN OTHERS THEN
            global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
                'BILLING_JOB_PKG.recurring_payment_b2b',
                -107,
                global_error_message,
                SYSDATE,
                'No merchant parameter settings found in table_x_cc_params for the business organization',
                2 -- MEDIUM
              );
            op_result     := -107;
            op_msg        := 'No merchant parameter settings found in table_x_cc_params for the business organization';
            l_merchant_id := NULL;
          END;
        END IF;
        -----------------------------------------------------------------------------------------------------------
        -----DBMS_OUTPUT.PUT_LINE ('After checking payment type ' || l_payment_source_type );
        IF l_payment_source_type = 'CREDITCARD' THEN
          BEGIN
            SELECT OBJID ,                                               --    NUMBER
              X_CUSTOMER_CC_NUMBER ,                                     --    VARCHAR2(255)
              X_CUSTOMER_CC_EXPMO ,                                      --    VARCHAR2(2)
              X_CUSTOMER_CC_EXPYR ,                                      --    VARCHAR2(4)
              X_CC_TYPE ,                                                --    VARCHAR2(20)
              X_CUSTOMER_CC_CV_NUMBER ,                                  --    VARCHAR2(20)
              regexp_replace(X_CUSTOMER_FIRSTNAME, '[^0-9 A-Za-z]', '') ,--    VARCHAR2(20)
              regexp_replace(X_CUSTOMER_LASTNAME, '[^0-9 A-Za-z]', '') , --    VARCHAR2(20)
              CASE WHEN (LENGTH(X_CUSTOMER_PHONE) > 10                   --   CR42815_CyberSource
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
                     END X_CUSTOMER_PHONE,                               --    VARCHAR2(20)
              X_CUSTOMER_EMAIL ,                                         --    VARCHAR2(50)
              X_MAX_PURCH_AMT ,                                          --    NUMBER
              X_MAX_TRANS_PER_MONTH ,                                    --    NUMBER
              X_MAX_PURCH_AMT_PER_MONTH ,                                --    NUMBER
              X_CHANGEDATE ,                                             --    DATE
              X_ORIGINAL_INSERT_DATE ,                                   --    DATE
              X_CHANGEDBY ,                                              --    VARCHAR2(20)
              X_CC_COMMENTS ,                                            --    LONG()
              X_MOMS_MAIDEN ,                                            --    VARCHAR2(20)
              X_CREDIT_CARD2CONTACT ,                                    --    NUMBER
              X_CREDIT_CARD2ADDRESS ,                                    --    NUMBER
              X_CARD_STATUS ,                                            --   VARCHAR2(10)
              X_MAX_ILD_PURCH_AMT ,                                      --   NUMBER
              X_MAX_ILD_PURCH_MONTH ,                                    --   NUMBER
              X_CREDIT_CARD2BUS_ORG ,                                    --   NUMBER
              X_CUST_CC_NUM_KEY ,                                        --   VARCHAR2(255)
              X_CUST_CC_NUM_ENC ,                                        --   VARCHAR2(255)
              CREDITCARD2CERT                                            --   NUMBER
            INTO v_credit_card_rec
            FROM table_x_credit_card
            WHERE objid = l_credit_card_objid;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
                'BILLING_JOB_PKG.recurring_payment_b2b',
                -101,
                global_error_message,
                SYSDATE,
                ' No CreditCard record found for '
                || TO_CHAR (l_credit_card_objid),
                2 -- MEDIUM
              );
            op_result := -101;
            op_msg    := ' No CreditCard record found for ' || TO_CHAR (l_credit_card_objid);
          END;
          -----DBMS_OUTPUT.PUT_LINE ('After selecting credit card ');
          BEGIN
            SELECT OBJID,                                       --                   NUMBER
              regexp_replace(ADDRESS, '[^0-9 A-Za-z.-]', ''),   --                 VARCHAR2(200)
              regexp_replace(S_ADDRESS, '[^0-9 A-Za-z.-]', ''), --               VARCHAR2(200)
              regexp_replace(CITY, '[^0-9 A-Za-z.-]', ''),      --                    VARCHAR2(30)
              regexp_replace(S_CITY, '[^0-9 A-Za-z.-]', ''),    --                  VARCHAR2(30)
              regexp_replace(STATE, '[^0-9 A-Za-z.-]', ''),     --                   VARCHAR2(60)
              regexp_replace(S_STATE, '[^0-9 A-Za-z.-]', ''),   --                 VARCHAR2(60)
              regexp_replace(ZIPCODE, '[^0-9 A-Za-z.-]', ''),   --                 VARCHAR2(60)
              regexp_replace(ADDRESS_2, '[^0-9 A-Za-z.-]', ''), --               VARCHAR2(200)
              DEV,                                              --                     NUMBER
              ADDRESS2TIME_ZONE,                                --       NUMBER(38)
              ADDRESS2COUNTRY,                                  --         NUMBER(38)
              ADDRESS2STATE_PROV,                               --      NUMBER(38)
              UPDATE_STAMP,                                     --            DATE
              ADDRESS2E911
            INTO address
            FROM table_address
            WHERE objid = v_credit_card_rec.x_credit_card2address;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            address              := clear_address;
            global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
                'BILLING_JOB_PKG.recurring_payment_b2b',
                -101,
                global_error_message,
                SYSDATE,
                ' No address found for the credit card address ( address objid ) '
                || TO_CHAR ( v_credit_card_rec.x_credit_card2address)
                || ' cc(objid):'
                || TO_CHAR (v_credit_card_rec.objid)
                || ' contact(objid):'
                || TO_CHAR ( v_credit_card_rec.x_credit_card2contact),
                2
              ); -- MEDIUM CR19559
            op_result := -101;
            op_msg    := ' No address found for the credit card address ( address objid ) ' || TO_CHAR (v_credit_card_rec.x_credit_card2address) || ' cc(objid):' || TO_CHAR (v_credit_card_rec.objid) || ' contact(objid):' || TO_CHAR (v_credit_card_rec.x_credit_card2contact); --CR19559
          END;
          -----DBMS_OUTPUT.PUT_LINE ('After selecting address ' || 'Merchant ref number ' || l_mer_ref_no );
         --Added for CR41241 to get the country name from table_country table
         BEGIN
            SELECT DECODE(S_NAME,'USA', S_NAME, X_POSTAL_CODE)
              INTO l_country
              FROM TABLE_COUNTRY
             WHERE objid = address.ADDRESS2COUNTRY;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 l_country := 'USA';
           END;
         --DBMS_OUTPUT.PUT_LINE('l_country'||l_country);
         --CR41241 end
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
              --x_esn,
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
              --,purch_hdr2prog_enrolled   -- Not needed
              x_payment_type,
              x_usf_taxamount,
              x_rcrf_tax_amount,
              x_discount_amount,
              x_priority
            )
            VALUES
            (
              x_py_pur_hdr_id,
              'BATCH',--to identify B2B grouping,
              'CREDITCARD_PURCH',
              l_sysdate,
              'ccAuthService_run,ccCaptureService_run',
              l_merchant_id,
              l_mer_ref_no,
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
              NVL (v_credit_card_rec.x_customer_firstname, 'No Name Provided'),
              NVL (v_credit_card_rec.x_customer_lastname, 'No Name Provided'),
              v_credit_card_rec.x_customer_phone,
              NVL (v_credit_card_rec.x_customer_email, 'null@cybersource.com'),
              'RECURINCOMPLETE',
              NVL (address.address, 'No Address Provided'),
              NVL (address.address_2, 'No Address Provided'),
              address.city,
              address.state,
              address.zipcode,
              l_country,  --CR41241
              total_price_b2b,
              ROUND(total_tax,2),
              ROUND(total_e911_tax,2),
              NULL,
              NULL,
              'System',
              NULL,
              v_credit_card_rec.objid,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              b2b_rec.ps_objid,
              b2b_rec.web_objid,
              NULL,
              'RECURRING', --to identify B2B grouping,billing_job_pkg.getpaymenttype ( b2b_esn_rec.pgm_enroll2pgm_parameter ),
              ROUND(total_usf_tax,2),
              ROUND(total_rcrf_tax,2),
              l_enroll_amount,
              NVL(b2b_rec.x_priority,20)--Modified for CR34303 --in_priority
            );
          --                  -----DBMS_OUTPUT.PUT_LINE ('After insert into Prog Hdr ');
          ---------------------- Insert into CreditCard Trans record -------------------------------------
          INSERT
          INTO x_cc_prog_trans
            (
              objid,
              x_ignore_bad_cv,
              x_ignore_avs,
              x_avs,
              x_disable_avs,
              x_auth_avs,
              x_auth_cv_result,
              x_score_factors,
              x_score_host_severity,
              x_score_rcode,
              x_score_rflag,
              x_score_rmsg,
              x_score_result,
              x_score_time_local,
              x_customer_cc_number,
              x_customer_cc_expmo,
              x_customer_cc_expyr,
              x_customer_cvv_num,
              x_cc_lastfour,
              x_cc_trans2x_credit_card,
              x_cc_trans2x_purch_hdr
            )
            VALUES
            (
              billing_seq ('X_CC_PROG_TRANS'), --objid,
              l_ignore_bad_cv,                 --x_ignore_bad_cv,
              NULL,                            --x_ignore_avs,
              NULL,                            --x_avs,
              NULL,                            --x_disable_avs,
              NULL,                            --x_auth_avs,
              NULL,                            --x_auth_cv_result,
              NULL,                            --x_score_factors,
              NULL,                            --x_score_host_severity,
              NULL,                            --x_score_rcode,
              NULL,                            --x_score_rflag,
              NULL,                            --x_score_rmsg,
              NULL,                            --x_score_result,
              NULL,                            --x_score_time_local,
              v_credit_card_rec.x_customer_cc_number,
              v_credit_card_rec.x_customer_cc_expmo,
              v_credit_card_rec.x_customer_cc_expyr,
              v_credit_card_rec.x_customer_cc_cv_number,
              NULL, --x_cc_lastfour,
              v_credit_card_rec.objid,
              x_py_pur_hdr_id --,
            );
          --                  -----DBMS_OUTPUT.PUT_LINE ('After creating CC Trans ');
          ------------------------------------------------------------------------------------------------
        ELSIF l_payment_source_type = 'ACH' THEN
          -- This is an ACH Payment
          BEGIN
            SELECT OBJID ,                                               --   NUMBER
              X_BANK_NUM ,                                               --   VARCHAR2(30)
              X_CUSTOMER_ACCT ,                                          --   VARCHAR2(400)
              X_ROUTING ,                                                --   VARCHAR2(400)
              X_ABA_TRANSIT ,                                            --   VARCHAR2(30)
              X_BANK_NAME ,                                              --   VARCHAR2(20)
              X_STATUS ,                                                 --   VARCHAR2(10)
              regexp_replace(X_CUSTOMER_FIRSTNAME, '[^0-9 A-Za-z]', '') ,--   VARCHAR2(20)
              regexp_replace(X_CUSTOMER_LASTNAME, '[^0-9 A-Za-z]', '') , --   VARCHAR2(20)
              CASE WHEN (LENGTH(x_customer_phone) > 10                   --   CR42815_CyberSource
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
                     END X_CUSTOMER_PHONE,                               --    VARCHAR2(20)
              X_CUSTOMER_EMAIL ,                                         --   VARCHAR2(50)
              X_MAX_PURCH_AMT ,                                          --   NUMBER
              X_MAX_TRANS_PER_MONTH ,                                    --   NUMBER
              X_MAX_PURCH_AMT_PER_MONTH ,                                --   NUMBER
              X_CHANGEDATE ,                                             --   DATE
              X_ORIGINAL_INSERT_DATE ,                                   --   DATE
              X_CHANGEDBY ,                                              --   VARCHAR2(20)
              X_CC_COMMENTS ,                                            --   LONG()
              X_MOMS_MAIDEN ,                                            --   VARCHAR2(20)
              X_BANK_ACCT2CONTACT ,                                      --   NUMBER
              X_BANK_ACCT2ADDRESS ,                                      --   NUMBER
              X_BANK_ACCOUNT2BUS_ORG,                                    --   NUMBER
              BANK2CERT,                                                 --   NUMBER
              X_CUSTOMER_ACCT_KEY,                                       --   VARCHAR2(400)
              X_CUSTOMER_ACCT_ENC                                        --   VARCHAR2(400)
            INTO v_bank_acount
            FROM table_x_bank_account
            WHERE objid = l_bank_account_objid;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
                'BILLING_JOB_PKG.recurring_payment_b2b',
                -100,
                global_error_message,
                SYSDATE,
                ' No record found for the bank account '
                || TO_CHAR (l_bank_account_objid),
                2 -- MEDIUM
              );
            op_result := -103;
            op_msg    := ' No record found for the bank account ' || TO_CHAR (l_bank_account_objid);
          END;
          --                  -----DBMS_OUTPUT.PUT_LINE ('AFter bank account ');
          BEGIN
            SELECT OBJID,                                       --                   NUMBER
              regexp_replace(ADDRESS, '[^0-9 A-Za-z.-]', ''),   --                 VARCHAR2(200)
              regexp_replace(S_ADDRESS, '[^0-9 A-Za-z.-]', ''), --               VARCHAR2(200)
              regexp_replace(CITY, '[^0-9 A-Za-z.-]', ''),      --                    VARCHAR2(30)
              regexp_replace(S_CITY, '[^0-9 A-Za-z.-]', ''),    --                  VARCHAR2(30)
              regexp_replace(STATE, '[^0-9 A-Za-z.-]', ''),     --                   VARCHAR2(60)
              regexp_replace(S_STATE, '[^0-9 A-Za-z.-]', ''),   --                 VARCHAR2(60)
              regexp_replace(ZIPCODE, '[^0-9 A-Za-z.-]', ''),   --                 VARCHAR2(60)
              regexp_replace(ADDRESS_2, '[^0-9 A-Za-z.-]', ''), --               VARCHAR2(200)
              DEV,                                              --                     NUMBER
              ADDRESS2TIME_ZONE,                                --       NUMBER(38)
              ADDRESS2COUNTRY,                                  --         NUMBER(38)
              ADDRESS2STATE_PROV,                               --      NUMBER(38)
              UPDATE_STAMP,                                     --            DATE
              ADDRESS2E911
            INTO bank
            FROM table_address
            WHERE objid = v_bank_acount.x_bank_acct2address;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            address              := clear_address;
            global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
                'BILLING_JOB_PKG.recurring_payment_b2b',
                -100,
                global_error_message,
                SYSDATE,
                ' No address record found for '
                || TO_CHAR ( v_bank_acount.x_bank_acct2address)
                || ' contact(objid):'
                || TO_CHAR ( v_bank_acount.x_bank_acct2contact), --CR19559
                2
              );
            op_result := -104;
            op_msg    := ' No address record found for ' || TO_CHAR (v_bank_acount.x_bank_acct2address) || ' contact(objid):' || TO_CHAR (v_bank_acount.x_bank_acct2contact); --CR19559
            --                        -----DBMS_OUTPUT.PUT_LINE ( 'No Data found in table_address for the bank account '  );
          END;
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
              x_merchant_product_sku, -- NULL ,
              x_payment_line2program, -- NULL ,
              x_product_code,
              -- NULL ,
              x_ignore_avs, -- 'YES ' ,
              x_user_po,    -- NULL ,
              x_avs,        -- NULL ,
              x_disable_avs,
              -- ' FALSE ' ,
              x_customer_hostname, -- NULL
              x_customer_ipaddress,
              -- NULL
              x_auth_request_id, --NULL
              x_auth_code,       -- NULL
              x_auth_type,
              -- NULL
              x_ics_rcode,         -- NULL
              x_ics_rflag,         -- NULL
              x_ics_rmsg,          -- NULL
              x_request_id,        -- NULL
              x_auth_avs,          -- NULL
              x_auth_response,     --NULL
              x_auth_time,         -- NULL
              x_auth_rcode,        --NULL
              x_auth_rflag,        -- NULL
              x_auth_rmsg,         -- NULL
              x_bill_request_time, -- NULL
              x_bill_rcode,        -- NULL
              x_bill_rflag,        -- NULL
              x_bill_rmsg,         -- NULL
              x_bill_trans_ref_no, -- NULL
              x_customer_firstname,
              x_customer_lastname,
              x_customer_phone,
              x_customer_email,
              x_status, -- scheduled
              x_bill_address1,
              x_bill_address2,
              x_bill_city,
              x_bill_state,
              x_bill_zip,
              x_bill_country, -- x_esn,
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
              x_discount_amount,
              x_priority
            )
            VALUES
            (
              x_py_pur_hdr_id,
              'BATCH', --to identify B2B grouping
              'ACH_PURCH',
              l_sysdate,
              'ecDebitService_run',
              l_merchant_id,
              l_mer_ref_no,
              NULL,
              1,
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
              v_bank_acount.x_customer_phone,
              NVL (v_bank_acount.x_customer_email, 'null@cybersource.com'),
              'RECURINCOMPLETE',
              NVL (bank.address, 'No Address Provided'),
              NVL (bank.address_2, 'No Address Provided'),
              bank.city,
              bank.state,
              bank.zipcode,
              'US',
              total_price_b2b,
              ROUND(total_tax,2),
              ROUND(total_e911_tax,2),
              NULL,
              NULL,
              'System',
              NULL,
              NULL,
              v_bank_acount.objid,
              NULL,
              NULL,
              NULL,
              NULL,
              b2b_rec.ps_objid,
              b2b_rec.web_objid,
              NULL,
              'RECURRING', --to identify B2B grouping,--billing_job_pkg.getpaymenttype ( b2b_esn_rec.pgm_enroll2pgm_parameter ),
              ROUND(total_usf_tax,2),
              ROUND(total_rcrf_tax,2),
              l_enroll_amount,
              NVL(b2b_rec.x_priority,20)--Modified for CR34303 --in_priority
            );
          ------------------ Insert record into ACH Trans -----------------------------------------------
          --                  -----DBMS_OUTPUT.PUT_LINE ('Insert into ACH Prog Trans ');
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
              -- CR47971 Go Smart
              -- Changing v_bank_acount.x_aba_transit to UPPER(v_bank_acount.x_aba_transit)
              --DECODE (v_bank_acount.x_aba_transit, 'SAVINGS', 'S', 'CHECKING', 'C', 'CORPORATE', 'X', v_bank_acount.x_aba_transit), --x_ecp_account_type,
              DECODE (UPPER(v_bank_acount.x_aba_transit), 'SAVINGS', 'S', 'CHECKING', 'C', 'CORPORATE', 'X', v_bank_acount.x_aba_transit), --x_ecp_account_type,
              v_bank_acount.x_routing,                                                                                              -- x_ecp_rdfi,
              'A',
              --x_ecp_settlement_method,
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
              v_bank_acount.objid --,b2b_esn_rec.objid
            );
        END IF;
      END LOOP;--b2b_cur
    EXCEPTION
    WHEN OTHERS THEN
      global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
          'BILLING_JOB_PKG.recurring_payment_b2b',
          -900,
          global_error_message,
          SYSDATE,
          'BILLING_JOB_PKG.recurring_payment_b2b',
          2 -- MEDIUM
        );
      op_result := -900;
      op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
    END ;
    COMMIT;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    op_result := 0;
    op_msg    := 'Success';
  WHEN OTHERS THEN
    global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
        'BILLING_JOB_PKG.recurring_payment_b2b',
        -900,
        global_error_message,
        SYSDATE,
        'BILLING_JOB_PKG.recurring_payment_b2b',
        2 -- MEDIUM
      );
    op_result := - 900;
    op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  END recurring_payment_b2b;
  ----
  FUNCTION is_SB_esn
    (
      p_enrol_pgm_objid IN NUMBER,
      p_esn             IN VARCHAR2
    )
    RETURN NUMBER
  IS
    CURSOR c_get_sbesn_byenrol
    IS
      SELECT 'X'
      FROM X_PROGRAM_ENROLLED PE,
        X_PROGRAM_PARAMETERS PP
      WHERE PE.objid                  = p_enrol_pgm_objid
      AND PE.X_ENROLLMENT_STATUS      = 'ENROLLED'
      AND pe.pgm_enroll2pgm_parameter = pp.objid
      AND PP.X_PROG_CLASS             = 'SWITCHBASE';
    r_get_sbesn_byenrol c_get_sbesn_byenrol%ROWTYPE;
    CURSOR c_get_sbesn_byesn
    IS
      SELECT 'X'
      FROM X_PROGRAM_ENROLLED PE,
        X_PROGRAM_PARAMETERS PP
      WHERE PE.X_ESN                  = p_esn
      AND PE.X_ENROLLMENT_STATUS      = 'ENROLLED'
      AND pe.pgm_enroll2pgm_parameter = pp.objid
      AND PP.X_PROG_CLASS             = 'SWITCHBASE';
    r_get_sbesn_byesn c_get_sbesn_byesn%ROWTYPE;
  BEGIN
    IF p_enrol_pgm_objid IS NOT NULL THEN
      OPEN c_get_sbesn_byenrol;
      FETCH c_get_sbesn_byenrol INTO r_get_sbesn_byenrol;
      IF c_get_sbesn_byenrol%found THEN
        CLOSE c_get_sbesn_byenrol;
        RETURN 1;
      ELSE
        CLOSE c_get_sbesn_byenrol;
        RETURN 0;
      END IF;
    END IF;
    IF p_esn IS NOT NULL THEN
      OPEN c_get_sbesn_byesn;
      FETCH c_get_sbesn_byesn
      INTO r_get_sbesn_byesn;
      IF c_get_sbesn_byesn%found THEN
        CLOSE c_get_sbesn_byesn;
        RETURN 1;
      ELSE
        CLOSE c_get_sbesn_byesn;
        RETURN 0;
      END IF;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    IF c_get_sbesn_byenrol%isopen THEN
      CLOSE c_get_sbesn_byenrol;
    END IF;
    IF c_get_sbesn_byesn%isopen THEN
      CLOSE c_get_sbesn_byesn;
    END IF;
    RETURN 0;
  END is_SB_esn;
  --CR8663
PROCEDURE suspend_wait_period_job(
    op_result OUT NUMBER,
    op_msg OUT VARCHAR2 )
IS
  v_pgm_enrolled x_program_enrolled%ROWTYPE;
TYPE rc
IS
  REF
  CURSOR;
    v_rc1 rc;
    c_user        VARCHAR2 (20);
    l_date        DATE DEFAULT SYSDATE;
    l_trans_objid NUMBER;
    l_program_name x_program_parameters.x_program_name%TYPE;
    l_first_name table_contact.first_name%TYPE;
    l_last_name table_contact.last_name%TYPE;
  BEGIN
    IF NOT v_rc1%ISOPEN THEN
      /* Open cursor variable. to select the data from specified tables*/
    -- Start modified by Rahul for CR38545
        OPEN v_rc1 FOR with t as
        (
        SELECT * FROM x_program_enrolled
    WHERE TRUNC (x_wait_exp_date) <= TRUNC (l_date)
    AND UPPER (x_enrollment_status) IN ('ENROLLED', 'SUSPENDED')
        --- Check if the ESN still continues to exist in MyAccount
        AND EXISTS
        (SELECT 1
        FROM table_x_contact_part_inst c,
        table_web_user d
        WHERE pgm_enroll2part_inst        = c.x_contact_part_inst2part_inst
        AND c.x_contact_part_inst2contact = d.web_user2contact
        )
        )
        SELECT * FROM t
        UNION
        SELECT pe.* FROM x_program_enrolled pe,x_program_parameters ppout
        where pe.x_esn    IN (SELECT DISTINCT x_esn FROM t,x_program_parameters ppin
                            WHERE 1 = 1
                            AND ppin.objid  = t.pgm_enroll2pgm_parameter
                            AND ppin.x_prog_class = 'LIFELINE'
                            )
        AND ppout.objid  = pe.pgm_enroll2pgm_parameter
        AND ppout.x_prog_class = 'HMO'
        AND UPPER (pe.x_enrollment_status) <> 'DEENROLLED'
    union --CR43005
    select pe.*
      from sa.x_program_enrolled pe,
           sa.x_program_parameters pp
     where 1 = 1
       and (x_wait_exp_date) <= trunc (l_date)
       and pe.pgm_enroll2pgm_parameter = pp.objid
       and pe.x_enrollment_status = 'ENROLLED_NO_ACCOUNT'
       and pp.x_prog_class = 'WARRANTY';

    -- End modified by Rahul for CR38545

  END IF;
  LOOP
    FETCH v_rc1 INTO v_pgm_enrolled;
    EXIT
  WHEN v_rc1%NOTFOUND;
    /* Commented by Sharat : Review
    UPDATE x_program_enrolled
    SET x_enrollment_status = 'SUSPENDED'
    WHERE TRUNC (x_wait_exp_date) < = TRUNC (v_date)
    AND UPPER (x_enrollment_status) = 'ENROLLED';
    */
    --CR8663
    IF is_SB_esn ( v_pgm_enrolled.objid, NULL) <> 1 THEN
      INSERT
      INTO x_program_notify
        (
          objid,
          x_esn,
          x_program_name,
          x_program_status,
          x_notify_process,
          x_notify_status,
          x_source_system,
          x_process_date,
          x_phone,
          x_language,
          x_remarks,
          pgm_notify2pgm_objid,
          pgm_notify2contact_objid,
          pgm_notify2web_user,
          pgm_notify2pgm_enroll,
          x_message_name
        )
        VALUES
        (
          billing_seq ('X_PROGRAM_NOTIFY'),
          v_pgm_enrolled.x_esn,
          (SELECT x_program_name
          FROM x_program_parameters
          WHERE objid = v_pgm_enrolled.pgm_enroll2pgm_parameter
          ),
          'DEENROLLED',
          'DE_ENROLL_JOB',
          'PENDING',
          v_pgm_enrolled.x_sourcesystem ,
          SYSDATE,
          NULL,
          v_pgm_enrolled.x_language,
          'Wait Period has expired',
          v_pgm_enrolled.pgm_enroll2pgm_parameter ,
          v_pgm_enrolled.pgm_enroll2contact,
          v_pgm_enrolled.pgm_enroll2web_user ,
          v_pgm_enrolled.objid,
          'Enrollment Cancellation'
        );
    END IF;--CR8663
    UPDATE x_program_enrolled
    SET x_enrollment_status = 'READYTOREENROLL', --CR38545
      x_update_stamp        = l_date,
      --          X_GRACE_PERIOD =4,
      x_cooling_exp_date = null,--request from ramu
      -- Give 10 days of cooling period.
      x_wait_exp_date       = NULL,
      pgm_enroll2x_pymt_src = NULL
      ,x_next_delivery_date    =    NULL    --CR38545 On request from Ramu
    WHERE objid             = v_pgm_enrolled.objid;

    begin
    update x_sl_currentvals
   set X_DEENROLL_REASON = 'H - ENROLLMENT is in ONHOLD status due to Upgrade in process or No Active ESN to LLID at this time.'
   WHERE x_current_esn=v_pgm_enrolled.x_esn;
   exception
   when others then
   null;
   end;

    --end CR38545
    --- Get the program name
    SELECT x_program_name
    INTO l_program_name
    FROM x_program_parameters
    WHERE objid = v_pgm_enrolled.pgm_enroll2pgm_parameter;
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
        x_esn,
        x_exp_date,
        x_cooling_exp_date,
        x_update_status,
        x_update_user,
        pgm_tran2pgm_entrolled,
        pgm_trans2web_user,
        pgm_trans2site_part
      )
      VALUES
      (
        billing_seq ('X_PROGRAM_TRANS'),
        'DEENROLLED',
        --- Not clear on the statuses
        'Wait Period has Expired',
        NULL,
        NULL,
        NULL,
        l_date,
        'System DeEnrollment',
        'DE_ENROLL',
        l_program_name
        || '    Wait period has expired.',
        v_pgm_enrolled.x_sourcesystem,
        v_pgm_enrolled.x_esn,
        l_date,
        l_date,
        'I',
        'SYSTEM',
        v_pgm_enrolled.objid,
        v_pgm_enrolled.pgm_enroll2web_user,
        NULL
      );
    -- Change x_notify_status value PENDING from NULL
    ----------------------------- Insert a log into the billing table --------------------------------------
    --------------------------------------------------------------------------------------------------
    ---------------- Get the contact details for logging ---------------------------------------------
    --
    -- Start CR13082 Kacosta 01/24/2011
    --SELECT first_name,
    --   last_name
    --INTO l_first_name, l_last_name
    --FROM table_contact
    --WHERE objid = (
    --SELECT web_user2contact
    --FROM table_web_user
    --WHERE objid = v_pgm_enrolled.pgm_enroll2web_user);
    BEGIN
      --
      SELECT regexp_replace(first_name, '[^0-9 A-Za-z]', '') ,
        regexp_replace(last_name, '[^0-9 A-Za-z]', '')
      INTO l_first_name ,
        l_last_name
      FROM table_contact
      WHERE objid =
        (SELECT web_user2contact
        FROM table_web_user
        WHERE objid = v_pgm_enrolled.pgm_enroll2web_user
        );
      --
    EXCEPTION
    WHEN no_data_found THEN
      --
      NULL;
      --
    WHEN OTHERS THEN
      --
      RAISE;
      --
    END;
    -- End CR13082 Kacosta 01/24/2011
    --
    ---------------- Insert a billing Log ------------------------------------------------------------
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
        billing_seq ('X_BILLING_LOG'),
        'Program',
        'Program De-enrolled',
        SYSDATE,
        l_program_name
        || '    Wait Period has expired',
        l_program_name,
        billing_getnickname (v_pgm_enrolled.x_esn),
        v_pgm_enrolled.x_esn,
        'System',
        l_first_name,
        l_last_name,
        'System',
        v_pgm_enrolled.x_sourcesystem,
        v_pgm_enrolled.pgm_enroll2web_user
      );
    ---------------------------------------------------------------------------------------------------------
  END LOOP;
  CLOSE v_rc1;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
  op_result := - 900;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
      'SA.BILLING_JOB_PKG.suspend_wait_period_job',
      -900,
      op_Msg, --(SQLCODE || SUBSTR (SQLERRM, 1, 100)),
      SYSDATE,
      'BILLING_JOB_PKG.suspend_wait_period_job',
      2 -- MEDIUM
    );
END suspend_wait_period_job;
PROCEDURE ready_to_re_enroll_job
  (
    op_result OUT NUMBER,
    op_msg OUT VARCHAR2
  )
  /******************************************************************************/
  /* Copyright 2005 Tracfone Wireless Inc. All rights reserved */
  /* */
  /* */
  /* NAME: ready_to_re_enroll_job */
  /* */
  /* PURPOSE: get all the ESN are having the X_COOLING_EXP_DATE=sysdate */
  /* and update the same table column x_stauts, */
  /* and insert the record in to specified tables. */
  /* */
  /* PLATFORMS: Oracle 9i AND newer versions. */
  /* */
  /* REVISIONS: */
  /* VERSION DATE WHO PURPOSE */
  /* ------- ---------- ----- --------------------------------------------- */
  /* 1.0 09/22/05 SL Initial Revision */
  /* */
  /******************************************************************************/
IS
  v_pgm_enrolled x_program_enrolled%ROWTYPE;
TYPE rc
IS
  REF
  CURSOR;
  TYPE rc1
IS
  REF
  CURSOR;
    v_rc1 rc1;
    v_rc rc;
    l_program_name x_program_parameters.x_program_name%TYPE;
    c_user        VARCHAR2 (20);
    l_date        DATE DEFAULT SYSDATE;
    l_trans_objid NUMBER;
    l_first_name table_contact.first_name%TYPE;
    l_last_name table_contact.last_name%TYPE;


  BEGIN


    IF NOT v_rc1%ISOPEN THEN
      /* Open cursor variable. to select the data from specified tables*/
      OPEN v_rc1 FOR SELECT * FROM x_program_enrolled WHERE TRUNC
      (
        x_cooling_exp_date
      )
      <= TRUNC
      (
        l_date
      )
      AND ( UPPER (x_enrollment_status) = 'DEENROLLED' OR UPPER (x_enrollment_status) = 'ENROLLMENTBLOCKED' )
      --- Check if the ESN still continues to exist in MyAccount
      AND EXISTS
      (SELECT 1
        FROM table_x_contact_part_inst c,
          table_web_user d
        WHERE pgm_enroll2part_inst        = c.x_contact_part_inst2part_inst
        AND c.x_contact_part_inst2contact = d.web_user2contact
      );
  END IF;
  LOOP
    FETCH v_rc1 INTO v_pgm_enrolled;
    EXIT
  WHEN v_rc1%NOTFOUND;
    /* Commented by Sharat
    UPDATE x_program_enrolled
    SET x_enrollment_status = 'READYTOREENROLL'
    WHERE TRUNC (x_cooling_exp_date) <= TRUNC (v_date)
    AND (   UPPER (x_enrollment_status) = 'DEENROLLED'
    OR UPPER (x_enrollment_status) = 'ENROLLMENTBLOCKED'
    );
    */
    UPDATE x_program_enrolled
    SET x_enrollment_status             = 'READYTOREENROLL',
      x_cooling_exp_date                = NULL,
      x_delivery_cycle_number           = NULL,
      x_next_delivery_date              = NULL,
      x_charge_date                     = NULL,
      x_next_charge_date                = NULL,
      x_grace_period                    = NULL,
      x_cooling_period                  = NULL,
      x_service_days                    = NULL,
      x_wait_exp_date                   = NULL,
      x_tot_grace_period_given          = NULL,
      pgm_enroll2pgm_group              = NULL,
      x_update_stamp                    = l_date
    WHERE objid                         = v_pgm_enrolled.objid;
    IF (v_pgm_enrolled.x_cooling_period = 0) THEN
      NULL;
      -- Do not log if the cooling period is 0 days
    ELSE
      --- Get the program name for logging purposes
      SELECT x_program_name
      INTO l_program_name
      FROM x_program_parameters
      WHERE objid = v_pgm_enrolled.pgm_enroll2pgm_parameter;
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
          x_esn,
          x_exp_date,
          x_cooling_exp_date,
          x_update_status,
          x_update_user,
          pgm_tran2pgm_entrolled,
          pgm_trans2web_user,
          pgm_trans2site_part
        )
        VALUES
        (
          billing_seq ('X_PROGRAM_TRANS'),
          v_pgm_enrolled.x_enrollment_status,
          'This ESN has completed the cooling period applied and Ready To Re Enroll' ,
          NULL,
          v_pgm_enrolled.x_cooling_period,
          NULL,
          l_date,
          'Ready To Re Enroll',
          'READY_TO_REENROLL',
          l_program_name
          || '    Cooling Period expired. Ready to ReEnroll',
          v_pgm_enrolled.x_sourcesystem,
          v_pgm_enrolled.x_esn,
          v_pgm_enrolled.x_exp_date,
          l_date,
          'I',
          'System',
          v_pgm_enrolled.objid,
          v_pgm_enrolled.pgm_enroll2web_user,
          v_pgm_enrolled.pgm_enroll2part_inst
        );
    END IF;
    ----------------------------- Insert a log into the billing table --------------------------------------
    IF (v_pgm_enrolled.x_cooling_period = 0) THEN
      NULL;
      -- Do not log if the cooling period is 0 days
    ELSE
      --------------------------------------------------------------------------------------------------
      ---------------- Get the contact details for logging ---------------------------------------------
      --
      -- Start CR13082 Kacosta 01/24/2011
      --SELECT first_name,
      --   last_name
      --INTO l_first_name, l_last_name
      --FROM table_contact
      --WHERE objid = (
      --SELECT web_user2contact
      --FROM table_web_user
      --WHERE objid = v_pgm_enrolled.pgm_enroll2web_user);
      BEGIN
        --
        SELECT regexp_replace(first_name, '[^0-9 A-Za-z]', '') ,
          regexp_replace(last_name, '[^0-9 A-Za-z]', '')
        INTO l_first_name ,
          l_last_name
        FROM table_contact
        WHERE objid =
          (SELECT web_user2contact
          FROM table_web_user
          WHERE objid = v_pgm_enrolled.pgm_enroll2web_user
          );
        --
     EXCEPTION
      WHEN no_data_found THEN
        --
        NULL;
        --
      WHEN OTHERS THEN
        --
        RAISE;
        --
      END;
      -- End CR13082 Kacosta 01/24/2011
      --
      ---------------- Insert a billing Log ------------------------------------------------------------
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
          billing_seq ('X_BILLING_LOG'),
          'Program',
          'Program De-enrolled',
          SYSDATE,
          l_program_name
          || '    Cooling Period has expired',
          l_program_name,
          billing_getnickname (v_pgm_enrolled.x_esn),
          v_pgm_enrolled.x_esn,
          'System',
          l_first_name,
          l_last_name,
          'System',
          v_pgm_enrolled.x_sourcesystem,
          v_pgm_enrolled.pgm_enroll2web_user
        );
    END IF;
    ---------------------------------------------------------------------------------------------------------
  END LOOP;
  CLOSE v_rc1;
EXCEPTION
WHEN OTHERS THEN
  op_result := - 900;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
      'BILLING_JOB_PKG.ready_to_re_enroll_job',
      -900,
      op_msg,
      SYSDATE,
      'BILLING_JOB_PKG.ready_to_re_enroll_job',
      2 -- MEDIUM
    );
END ready_to_re_enroll_job;
---
-- START
PROCEDURE recurring_payment
  (
    p_bus_org   IN VARCHAR2 DEFAULT 'TRACFONE',
    in_priority IN VARCHAR2 DEFAULT NULL, ---CR25625
    op_result OUT NUMBER,
    op_msg OUT VARCHAR2
  )
IS
  l_sysdate DATE DEFAULT SYSDATE;
  v_pgm_enrolled x_program_enrolled%ROWTYPE;
  v_credit_card_rec table_x_credit_card%ROWTYPE;
  v_bank_acount table_x_bank_account%ROWTYPE;
  l_mer_ref_no VARCHAR2 (200);
  address table_address%ROWTYPE;
  clear_address table_address%ROWTYPE;
  bank table_address%ROWTYPE;
  l_charge_desc     VARCHAR2 (255);
  retval            BOOLEAN;
  x_pgm_objid       NUMBER;
  x_pgm_notify      NUMBER;
  x_py_pur_hdr_id   NUMBER;
  x_py_pur_de_id    NUMBER;
  l_price_p         NUMBER (10, 2) := 0;
  l_price_s         NUMBER (10, 2) := 0;
  l_tmp_s           NUMBER (10, 2) := 0;
  l_tax             NUMBER (10, 2) := 0;
  L_E911_TAX        NUMBER (10, 2) := 0;
  L_e911_surcharge  NUMBER (10, 2) := 0; -- CR24538
  l_usf_tax         NUMBER (10, 2) := 0; --STUL
  l_rcrf_tax        NUMBER (10, 2) := 0; --STUL
  l_count           NUMBER         := 0;
  l_next_cycle_date DATE;
  total_price       NUMBER (10, 2) := 0;
  l_payment_source_type x_payment_source.x_pymt_type%TYPE;
  l_credit_card_objid  NUMBER;
  l_bank_account_objid NUMBER;
  l_merchant_id table_x_cc_parms.x_merchant_id%TYPE;
  l_ignore_bad_cv table_x_cc_parms.x_ignore_bad_cv%TYPE;
  l_enroll_type       VARCHAR2 (30);
  l_enroll_amount     NUMBER;
  l_enroll_units      NUMBER;
  l_enroll_days       NUMBER;
  l_error_code        NUMBER;
  l_error_message     VARCHAR2 (255);
  l_sales_tax_percent NUMBER;
  l_e911_tax_percent  NUMBER;
  l_usf_tax_percent   NUMBER;--STUL
  l_rcrf_tax_percent  NUMBER;--STUL --CR11553
  -- l_add1_tax_percent NUMBER; -- STRAIGHT TALK .. CR8663
  --
  bmultimerchantflag BOOLEAN := TRUE;
  -- Commit Size
  l_commit_size    NUMBER := 1;
  l_commit_counter NUMBER := 0;
  L_tax_rule       VARCHAR2(30) ; -- CR27269
  L_data_tax_rule  VARCHAR2(30) ; -- CR26033
  i_priority       NUMBER;        --Arun
  --
  l_country   table_country.s_name%type;
  c           customer_type := customer_type();
  CURSOR c1
  IS
    /*SELECT a.*
    FROM x_program_enrolled a,x_program_parameters b     -------CR13581
    WHERE a.x_next_charge_date <= sysdate
    AND a.x_enrollment_status IN ('ENROLLED', 'ENROLLMENTSCHEDULED')
    AND a.x_is_grp_primary = 1
    AND A.x_wait_exp_date IS NULL
    and a.pgm_enroll2pgm_parameter = b.objid;   ------CR13581*/
    SELECT
      /*+ ORDERED INDEX(a IDX_PRG_PARAM_CHARGEDT) */
      a.*,
      mtmb.x_priority,
      b.x_prog_class    -- CR49058
    FROM sa.x_program_enrolled a ,
      sa.mtm_batch_process_type mtmb ,
      sa.x_program_parameters b
    WHERE 1                      =1
    AND a.x_next_charge_date    <= SYSDATE
    AND a.x_enrollment_status   IN ('ENROLLED', 'ENROLLMENTSCHEDULED')
    AND a.x_wait_exp_date       IS NULL
    AND a.x_is_grp_primary       = 1
    AND mtmb.x_prgm_objid        = a.pgm_enroll2pgm_parameter
    AND NVL (mtmb.x_priority, 1) = NVL (UPPER (in_priority), NVL (mtmb.x_priority, 1))
    AND b.objid                  = a.pgm_enroll2pgm_parameter
    AND b.x_program_name NOT LIKE '%B2B%'        --not to pick B2B records--CR25490
    AND NVL(A.X_CHARGE_TYPE,'NULL') != 'BUNDLE' --CR34962
    AND a.pgm_enroll2x_pymt_src IS NOT NULL    --CR42924
    --CR43305 Exclude Simple Mobile
    AND NOT EXISTS
    (SELECT 1
     FROM   x_program_parameters xpp
     WHERE  xpp.objid = a.pgm_enroll2pgm_parameter
     AND    get_brm_applicable_flag(i_bus_org_objid => xpp.prog_param2bus_org,i_program_parameter_objid => xpp.objid) = 'Y' );
  c1_rec c1%rowtype;
  CURSOR c2(pe IN c1%rowtype)--(pe IN x_program_enrolled%rowtype) --Modified for CR34303
  IS
    SELECT *
    FROM
      (SELECT RANK() OVER (PARTITION BY tab1.objid ORDER BY a.x_rqst_date DESC) rnk2,
        a.x_status,
        a.x_payment_type,
        tab1.rnk
      FROM
        (SELECT
          /*+ index(c PGM_PURCH_DTL2PGM_ENROLLED)
          use_nl(c) */
          pe.x_enrolled_date,
          pe.objid,
          c.objid dtl_objid,
          c.pgm_purch_dtl2prog_hdr,
          RANK() OVER (PARTITION BY pe.objid ORDER BY pgm_purch_dtl2prog_hdr DESC) rnk
        FROM x_program_purch_dtl c
        WHERE 1                          = 1
        AND c.pgm_purch_dtl2pgm_enrolled = pe.objid
        AND c.pgm_purch_dtl2penal_pend  IS NULL
        ) tab1,
      x_program_purch_hdr a
    WHERE tab1.rnk         < 5
    AND a.objid            = tab1.pgm_purch_dtl2prog_hdr
    AND a.x_rqst_date + 0 >= tab1.x_enrolled_date
      )tab2
    WHERE tab2.rnk2 = 1
    AND 1           = (
      CASE
        WHEN (tab2.x_status IN ('ENROLLACHPENDING', 'RECURACHPENDING','PAYNOWACHPENDING', 'INCOMPLETE', 'SUBMITTED', 'RECURINCOMPLETE' ) )
        THEN 1
        WHEN ( ( tab2.x_status  = 'FAILED'
        OR tab2.x_status        = 'FAILPROCESSED' )
        AND tab2.x_payment_type = 'RECURRING' )
        THEN 1
        ELSE 0
      END);
    c2_rec c2%rowtype;
    --
    -- CR15373 WMMC pm Start
    CURSOR CUR_ACT_PROMO_GRP( C_ESN VARCHAR2, C_CREDIT_CARD_OBJID NUMBER)
    IS
      SELECT PG_dtl.*
      FROM X_MONEY_CARD_CC EXT,
        x_promotion_group_dtl pg_dtl,
        TABLE_X_PROMOTION_GROUP PG
      WHERE 1                             = 1
      AND PG_DTL.OBJID                    = EXT.X_MONEY_CARD2PROMO_GRPDTL
      AND pg_dtl.X_PROMO_GRPDTL2PROMO_GRP = pg.objid
      AND X_MONEY_CARD2CREDITCARD         = C_CREDIT_CARD_OBJID
        --and    X_ESN                    = C_ESN
      AND sysdate BETWEEN PG.X_START_DATE AND NVL(PG.X_END_DATE, sysdate + 1);
    REC_ACT_PROMO_GRP CUR_ACT_PROMO_GRP%ROWTYPE;
    CURSOR CUR_ESN_DTL(C_ESN VARCHAR2)
    IS
      SELECT pi.part_serial_no,
        bo.org_id brand_name
      FROM TABLE_PART_INST PI,
        TABLE_MOD_LEVEL ML,
        TABLE_PART_NUM PN,
        TABLE_BUS_ORG BO
      WHERE ML.OBJID        = PI.N_PART_INST2PART_MOD
      AND PN.OBJID          = ML.PART_INFO2PART_NUM
      AND BO.OBJID          = PN.PART_NUM2BUS_ORG
      AND PI.PART_SERIAL_NO = C_ESN;
    REC_ESN_DTL CUR_ESN_DTL%rowtype;
    CURSOR CUR_PROMO_DTL (C_PROMO_ID NUMBER)
    IS
      SELECT * FROM TABLE_X_PROMOTION WHERE OBJID = C_PROMO_ID;
    REC_PROMO_DTL CUR_PROMO_DTL%ROWTYPE;
    l_promo_objid table_x_promotion.objid%type;
    l_promo_code table_x_promotion.x_promo_code%type;
    l_promo_enroll_type table_x_promotion.x_transaction_type%type;
    l_promo_enroll_amount table_x_promotion.x_discount_amount%type;
    l_promo_enroll_units table_x_promotion.x_units%type;
    l_promo_enroll_days table_x_promotion.x_access_days%type;
    l_promo_error_code    NUMBER;
    l_promo_error_message VARCHAR2(400);
    -- CR15373 WMMC pm End
    -- CR19467 ST/NT Promo Start.
    CURSOR cur_act_stnt_promo ( c_esn VARCHAR2, c_program_enrolled_objid NUMBER )
    IS
      SELECT *
      FROM x_enroll_promo_grp2esn grp2esn
      WHERE 1                                   = 1
      AND grp2esn.x_esn                         = c_esn
      AND NVL(grp2esn.program_enrolled_objid,0) = c_program_enrolled_objid
      AND sysdate BETWEEN grp2esn.x_start_date AND NVL(grp2esn.x_end_date, sysdate + 1);
    rec_act_stnt_promo cur_act_stnt_promo%rowtype;
    -- PROJECT START
    L_PE_PAYMENT_SOURCE NUMBER ;
    -- CR19467 ST/NT Promo End.
    -- MOVE CURSOR FOR DATA CARDS OUT OF THIS PACKAGE AND INTO FUNCTIN TAX_RULES_PROGRAMS_DATA_FUN CR26033
  BEGIN


    op_result := 0;
    op_msg    := 'Success';
    --DBMS_OUTPUT.PUT_LINE ('Beginning Payment Preparation Job ');
    /* ----------------- DeEnroll at cycle date ----------------------------- */
    --- Moved to de_enroll_job 10-Mar-2014  --    mvadlapally CR26707
    /*UPDATE x_program_enrolled SET x_tot_grace_period_given = NULL,
    x_wait_exp_date = NULL, x_next_charge_date = NULL
    WHERE x_enrollment_status = 'DEENROLLED'
    AND x_next_charge_date <= SYSDATE
    AND x_tot_grace_period_given = 1;*/
    /* ----------------- DeEnroll at cycle date end ------------------------- */
    --CR12135
    --         FOR pgm_enrolled_rec IN (
    --      select * from (
    -- select RANK() OVER (PARTITION BY tab1.objid ORDER BY a.x_rqst_date DESC) rnk2,
    --        a.x_status,a.x_payment_type,tab1.rnk, a.x_rqst_date,tab1.pgm_purch_dtl2prog_hdr,
    --         tab1.dtl_objid,to_char(a.x_rqst_date,'hh24:mi:ss') hh_date,tab1.x_esn,tab1.pgm_enroll2web_user,
    --  tab1.pgm_enroll2pgm_parameter,tab1.x_amount,tab1.pgm_enroll2x_promotion,tab1.x_sourcesystem,
    --  tab1.objid,tab1.x_next_charge_date,tab1.pgm_enroll2x_pymt_src
    --   from (
    --          SELECT /*+ leading(pe)
    --                        index(pe IDX_X_PROGRAM_ENROLLED_NEW3)
    --                        index(a IDX_X_PROGRAM_PURCH_HDR)
    --                        index(c PGM_PURCH_DTL2PGM_ENROLLED)
    --                        use_nl(c) */
    --             pe.* ,
    --             c.objid dtl_objid,
    --             c.pgm_purch_dtl2prog_hdr,
    --             RANK() OVER (PARTITION BY pe.objid
    --             ORDER BY pgm_purch_dtl2prog_hdr DESC) rnk
    --          FROM x_program_enrolled pe, x_program_purch_dtl c
    --          WHERE 1 = 1
    -- --         and pe.x_esn = '011616000066084'
    --          AND pe.x_is_grp_primary = 1
    --          AND pe.x_enrollment_status IN ('ENROLLED', 'ENROLLMENTSCHEDULED')
    --          AND pe.x_next_charge_date <= SYSDATE
    --          AND c.pgm_purch_dtl2pgm_enrolled = pe.objid
    --          AND pe.x_wait_exp_date is NULL
    --          AND c.pgm_purch_dtl2penal_pend IS NULL) tab1,
    --        x_program_purch_hdr a
    --  WHERE tab1.rnk < 5
    --    AND a.objid = tab1.pgm_purch_dtl2prog_hdr
    --    AND a.x_rqst_date + 0 >= tab1.x_enrolled_date)tab2
    -- where tab2.rnk2 = 1
    --    and 0 = (case when (tab2.x_status IN ('ENROLLACHPENDING', 'RECURACHPENDING','PAYNOWACHPENDING',
    --                                       'INCOMPLETE', 'SUBMITTED', 'RECURINCOMPLETE' ) ) THEN
    --                    1
    --                  when (    (    tab2.x_status = 'FAILED'
    --                              OR tab2.x_status = 'FAILPROCESSED' )
    --                        AND tab2.x_payment_type = 'RECURRING' ) THEN
    --                    1
    --                  ELSE
    --                    0
    --                  END)
    --       --CR12135
    --       )
    FOR pgm_enrolled_rec IN c1
    LOOP
      --bms_output.put_line('100000000013256162  pgm_enrolled_rec.x_esn  '|| pgm_enrolled_rec.x_esn );
      --
      -- CR20276 Start kacosta 04/01/2012
      IF (pgm_enrolled_rec.x_esn IS NULL) THEN
        --
        INSERT
        INTO x_program_error_log
          (
            x_source ,
            x_error_code ,
            x_error_msg ,
            x_date ,
            x_description ,
            x_severity
          )
          VALUES
          (
            'BILLING_JOB_PKG.recurring_payment' ,
            '-110' ,
            'Program enrolled ESN is null' ,
            SYSDATE ,
            'Program enrolled OBJID: '
            ||TO_CHAR(pgm_enrolled_rec.objid) ,
            2
          );
        COMMIT;
        --
      ELSE
        --
        -- CR20276 End kacosta 04/01/2012
        OPEN c2(pgm_enrolled_rec);
        FETCH c2 INTO c2_rec;
        IF c2%notfound THEN
          -- PROGRAM START
          BEGIN
            SELECT OBJID,
              x_pymt_type,
              pymt_src2x_credit_card,
              pymt_src2x_bank_account
            INTO L_PE_PAYMENT_SOURCE,
              l_payment_source_type,
              l_credit_card_objid,
              l_bank_account_objid
            FROM x_payment_source
            WHERE objid = pgm_enrolled_rec.pgm_enroll2x_pymt_src;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
          WHEN OTHERS THEN
            global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
                'BILLING_JOB_PKG.recurring_payment',
                -100,
                global_error_message,
                SYSDATE,
                'No Payment source found for '
                || TO_CHAR ( pgm_enrolled_rec.pgm_enroll2x_pymt_src),
                2 -- MEDIUM
              );
            op_result := - 100;
            op_msg    := 'No Payment source found for ' || TO_CHAR ( pgm_enrolled_rec.pgm_enroll2x_pymt_src);
            NULL;
            -- This record has failed. However, do not hold up the batch. Continue further processing
          END;
          ----DBMS_OUTPUT.PUT_LINE(' in the loop '||c2_rec.1);
          -- RETURN ;
          -- Process this enrollment only if there are no pending records in the payment header.
          --DBMS_OUTPUT.PUT_LINE ('Step 1: Beginning Processing ');
          BEGIN
            l_commit_counter := l_commit_counter + 1;
            --DBMS_OUTPUT.PUT_LINE ('Step 1: Beginning Processing ');
            l_price_p  := 0;
            l_price_s  := 0;
            l_tax      := 0;
            l_e911_tax := 0;
            --  l_add1_tax := 0; CR11553
            l_tmp_s      := 0;
            l_mer_ref_no := merchant_ref_number;
            l_RCRF_tax   := 0; --STUL CR11553
            l_usf_tax    := 0; --STUL
            -- Get the Merchant Ref Number
            x_py_pur_hdr_id := billing_seq ('X_PROGRAM_PURCH_HDR');
            -- Get the Purchase header objid
            ------- Get the sales tax percent for the given enrollment
            ------- Charge the sales tax only if tax to customer flag is set in the program definition.
            --STUL
            ----DBMS_OUTPUT.PUT_LINE('sb esn '|| is_SB_esn(NULL, pgm_enrolled_rec.x_esn));
            -- CR11553   IF is_SB_esn(NULL, pgm_enrolled_rec.x_esn) = 1
            --    THEN
            ----DBMS_OUTPUT.PUT_LINE ('SWITCHBASE ESNS');
            -- CR27269 CR26033 start
            -- CR30259
            L_tax_rule      := sa.SP_TAXES.tax_rules_BILLING(pgm_enrolled_rec.x_esn) ;
            L_data_tax_rule := sa.SP_TAXES.tax_rules_progs_data_BILLING(pgm_enrolled_rec.objid) ;
            IF l_TAX_RULE NOT IN ('SALES TAX ONLY','NO TAX') AND L_DATA_TAX_RULE NOT IN ('SALES TAX ONLY','NO TAX') THEN
              -- CR30259
              l_usf_tax_percent := sp_taxes.computeusftax_billing (pgm_enrolled_rec.pgm_enroll2web_user , pgm_enrolled_rec.pgm_enroll2pgm_parameter,L_PE_PAYMENT_SOURCE --, pgm_enrolled_rec.x_esn CR22380 removing ESN
              );
              -- CR30259
              --STUL
              l_rcrf_tax_percent := sp_taxes.computemisctax_billing (pgm_enrolled_rec.pgm_enroll2web_user , pgm_enrolled_rec.pgm_enroll2pgm_parameter,L_PE_PAYMENT_SOURCE --, pgm_enrolled_rec.x_esn CR22380 removing ESN
              );                                                                                                                                                          --STUL
            ELSE
              l_usf_tax_percent  := 0 ;
              l_rcrf_tax_percent := 0 ;
            END IF ;
            -- CR27269 CR26033 end
            --CR30259
            l_price_p := pgm_enrolled_rec.x_amount;
            SP_TAXES.GETTax2_BILL(l_price_p,l_usf_tax_percent,l_rcrf_tax_percent,l_usf_tax,l_rcrf_tax);

            -- BEGIN CR52959 Calling the following procedure to override the l_usf_tax and l_rcrf_tax amounts if there flags are N
                 sp_taxes.GET_TAX_AMT(i_source_system => pgm_enrolled_rec.x_sourcesystem, o_usf_tax_amt => l_usf_tax, o_rcrf_tax_amt =>l_rcrf_tax,o_usf_percent  => l_usf_tax_percent,o_rcrf_percent =>l_rcrf_tax_percent  );

                 DBMS_OUTPUT.PUT_LINE( 'l_usf_tax :' || l_usf_tax ) ;
                 DBMS_OUTPUT.PUT_LINE( 'l_rcrf_tax :' || l_rcrf_tax ) ;
                 DBMS_OUTPUT.PUT_LINE( ' l_usf_tax_percent :' ||  l_usf_tax_percent ) ;
                 DBMS_OUTPUT.PUT_LINE( 'l_rcrf_tax_percent :' || l_rcrf_tax_percent ) ;
            ---END CR52959 Calling the above procedure to override the l_usf_tax and l_rcrf_tax amounts if there flags are N

            --  l_usf_tax := l_price_p * l_usf_tax_percent;--STUL CR11553
            --  l_misc_tax := l_price_p * l_misc_tax_percent;
            --STUL
            /*   ELSE
            ----DBMS_OUTPUT.PUT_LINE ('NO SWITCHBASE ESNS');
            l_usf_tax_percent := 0;
            l_misc_tax_percent := 0;
            l_usf_tax := 0;
            l_misc_tax := 0;
            END IF; */
            --CR11553
            ----DBMS_OUTPUT.PUT_LINE ('usf '||l_usf_tax_percent);
            ----DBMS_OUTPUT.PUT_LINE ('misc '||l_misc_tax_percent);
            --STUL
            --CR11553
            IF PGM_ENROLLED_REC.objid IS NOT NULL THEN
              -- CR30259
              l_sales_tax_percent := sp_taxes.computetax_billing (pgm_enrolled_rec.pgm_enroll2web_user , pgm_enrolled_rec.pgm_enroll2pgm_parameter, pgm_enrolled_rec.x_esn,L_PE_PAYMENT_SOURCE );
              l_e911_tax_percent  := SP_TAXES.computee911tax_billing (pgm_enrolled_rec.pgm_enroll2web_user , pgm_enrolled_rec.pgm_enroll2pgm_parameter,L_PE_PAYMENT_SOURCE --, pgm_enrolled_rec.x_esn CR22380 removing ESN
              );
              -- CR24538
              -- CR30259
              l_e911_surcharge := SP_TAXES.computee911surcharge_billing(pgm_enrolled_rec.pgm_enroll2web_user , PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER,L_PE_PAYMENT_SOURCE);
              --CR24538
            END IF ;
            -- CR27269 CR26033 start
            IF l_TAX_RULE IN ('SALES TAX ONLY','NO TAX') OR l_data_tax_rule IN ('SALES TAX ONLY','NO TAX') THEN
              l_e911_tax_percent := 0 ;
              l_e911_surcharge   := 0 ;
            END IF;
            IF l_TAX_RULE IN ('NO TAX') OR l_DATA_TAX_RULE IN ('NO TAX') THEN
              l_sales_tax_percent :=0 ;
            END IF ;
            -- CR27269 end
            l_price_p := pgm_enrolled_rec.x_amount;
            -- STRAIGHT TALK .. CR8663
            ----DBMS_OUTPUT.PUT_LINE (TO_CHAR(pgm_enrolled_rec.pgm_enroll2pgm_parameter));
            /* CR11553
            SELECT X_ADDITIONAL_TAX1
            INTO l_add1_tax_percent
            FROM x_program_parameters pp
            WHERE pp.objid = pgm_enrolled_rec.pgm_enroll2pgm_parameter;
            */
            -- End of STRAIGHT TALK .. CR8663
            ---- Get the promocode details.--------------------------------------------------------------------------------------
            -- CR15373 WMMC pm Start
            l_promo_error_code                         := NULL;
            l_promo_error_message                      := NULL;
            l_promo_objid                              := NULL;
            l_promo_code                               := NULL;
            l_promo_enroll_type                        := NULL;
            l_promo_enroll_amount                      := NULL;
            l_promo_enroll_units                       := NULL;
            l_promo_enroll_days                        := NULL;
            l_enroll_type                              := NULL;
            l_enroll_amount                            := NULL;
            IF PGM_ENROLLED_REC.PGM_ENROLL2X_PROMOTION IS NOT NULL THEN
              OPEN CUR_PROMO_DTL(PGM_ENROLLED_REC.PGM_ENROLL2X_PROMOTION);
              FETCH CUR_PROMO_DTL INTO REC_PROMO_DTL;
              CLOSE CUR_PROMO_DTL;
            END IF;
            --            BEGIN
            --              SELECT x_pymt_type,
            --                pymt_src2x_credit_card,
            --                pymt_src2x_bank_account
            --              INTO l_payment_source_type,
            --                l_credit_card_objid,
            --                l_bank_account_objid
            --              FROM x_payment_source
            --              WHERE objid = pgm_enrolled_rec.pgm_enroll2x_pymt_src;
            --            EXCEPTION
            --            WHEN NO_DATA_FOUND THEN
            --              NULL;
            --            WHEN OTHERS THEN
            --              global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
            --              INSERT
            --              INTO x_program_error_log
            --                (
            --                  x_source,
            --                  x_error_code,
            --                  x_error_msg,
            --                  x_date,
            --                  x_description,
            --                  x_severity
           --                )
            --                VALUES
            --                (
            --                  'BILLING_JOB_PKG.recurring_payment',
            --                  -100,
            --                  global_error_message,
            --                  SYSDATE,
            --                  'No Payment source found for '
            --                  || TO_CHAR ( pgm_enrolled_rec.pgm_enroll2x_pymt_src),
            --                  2 -- MEDIUM
            --                );
            --              op_result := - 100;
            --              op_msg    := 'No Payment source found for ' || TO_CHAR ( pgm_enrolled_rec.pgm_enroll2x_pymt_src);
            --              NULL;
            --              -- This record has failed. However, do not hold up the batch. Continue further processing
            --            END;
            /* CR27159  comment money card
            if L_CREDIT_CARD_OBJID is not null then
            open CUR_ACT_PROMO_GRP ( PGM_ENROLLED_REC.X_ESN, L_CREDIT_CARD_OBJID );
            FETCH CUR_ACT_PROMO_GRP into REC_ACT_PROMO_GRP;
            if CUR_ACT_PROMO_GRP%FOUND then
            if REC_ACT_PROMO_GRP.description is not null then
            open CUR_ESN_DTL(PGM_ENROLLED_REC.X_ESN);
            FETCH CUR_ESN_DTL into REC_ESN_DTL;
            close CUR_ESN_DTL;
            MONEY_CARD_PKG.REGISTER_MONEY_CARD( PGM_ENROLLED_REC.X_ESN,
            REC_ESN_DTL.brand_name,
            L_CREDIT_CARD_OBJID,
            REC_ACT_PROMO_GRP.OBJID,
            'Recurring',
            l_promo_error_code,
            l_promo_error_message    );
            l_promo_error_code := null;
            L_promo_ERROR_MESSAGE := NULL;
            money_card_pkg.validate_money_card_promo( pgm_enrolled_rec.x_esn,
            l_credit_card_objid,
            'Recurring',
            l_promo_code,
            l_promo_objid,
            l_promo_enroll_type,
            l_promo_enroll_amount,
            l_promo_enroll_units,
            l_promo_enroll_days,
            l_promo_error_code,
            L_promo_ERROR_MESSAGE);
            IF ( L_promo_ERROR_CODE = 0  AND L_PROMO_OBJID is not null )
            THEN
            ----DBMS_OUTPUT.PUT_LINE('pm validate promo ESN :- '||pgm_enrolled_rec.x_esn||', cc objid :- '||l_credit_card_objid||', promocode :- '||l_wm_promo_code);
            -- This is a valid promocode and of type recurring.
            l_price_p := l_price_p - l_promo_enroll_amount;
            end if;
            end if;
            end if;
            close CUR_ACT_PROMO_GRP;
            end if;
            -- CR15373 WMMC pm End
            */
            --CR27159 comment money card
            -- CR19467 ST / NT Promo Start.
            IF NVL(l_promo_enroll_amount,0) = 0 THEN
              l_promo_error_code           := NULL;
              l_promo_error_message        := NULL;
              l_promo_objid                := NULL;
              l_promo_code                 := NULL;
              l_promo_enroll_type          := NULL;
              l_promo_enroll_amount        := NULL;
              l_promo_enroll_units         := NULL;
              l_promo_enroll_days          := NULL;
              l_enroll_type                := NULL;
              l_enroll_amount              := NULL;
              OPEN cur_act_stnt_promo(pgm_enrolled_rec.x_esn, pgm_enrolled_rec.objid);
              FETCH cur_act_stnt_promo INTO rec_act_stnt_promo;
              IF cur_act_stnt_promo%found THEN
                l_promo_objid := rec_act_stnt_promo.promo_objid;
                sa.enroll_promo_pkg.sp_validate_promo( pgm_enrolled_rec.x_esn, NULL, -- p_program_objid
                'RECURRING',                                                         -- p_process
                l_promo_objid,                                                       -- p_promo_objid
                l_promo_code, l_promo_enroll_type, l_promo_enroll_amount, l_promo_enroll_units, l_promo_enroll_days, l_promo_error_code, l_promo_error_message );
                IF ( l_promo_error_code = 0 AND l_promo_code IS NOT NULL ) THEN
                  l_price_p            := l_price_p - l_promo_enroll_amount;
                END IF;
              END IF;
              CLOSE cur_act_stnt_promo;
            END IF;
            -- CR19467 ST / NT Promo End.
            IF (pgm_enrolled_rec.pgm_enroll2x_promotion IS NOT NULL AND L_PROMO_code IS NULL AND REC_PROMO_DTL.x_promo_type <> 'Moneycard') -- CR15373 WMMC New condition added to skip applying other promo.
              THEN
              billing_validateenrollid (pgm_enrolled_rec.x_esn, pgm_enrolled_rec.pgm_enroll2x_promotion, pgm_enrolled_rec.x_sourcesystem , l_enroll_type, l_enroll_amount, l_enroll_units, l_enroll_days, l_error_code, l_error_message );
              IF ( l_error_code = 0 AND l_enroll_type LIKE 'RECURRING%' AND l_enroll_amount != 0 ) -- Ramu .. CR7316
                THEN
                -- This is a valid promocode and of type recurring.
                l_price_p := l_price_p - l_enroll_amount;
              END IF;
            END IF;
            -- CR15373 WMMC pm Start
            IF l_promo_error_code = 0 AND l_promo_code IS NOT NULL THEN
              l_enroll_amount    := l_promo_enroll_amount;
            END IF;
            -- CR15373 WMMC pm End
            SP_TAXES.GETTax_BILL(l_price_p,l_sales_tax_percent,l_e911_tax_percent,l_tax,l_e911_tax);
            --l_tax := l_price_p * l_sales_tax_percent; CR11553
            --l_e911_tax := l_price_p * l_e911_tax_percent; CR11553
            -- STRAIGHT TALK .. CR8663
            --l_add1_tax := l_price_p * (NVL(l_add1_tax_percent, 0) / 100);
            l_e911_tax := NVL(l_e911_tax,0) + NVL(l_e911_surcharge,0); --CR24538
            ----------------------------------------------------------------------------------------------------------------------
            ----------------- Proceed only if this is not a 0$ program. ------------------------------------------
            IF (l_price_p = 0 OR l_price_p IS NULL) THEN
             NULL;
              processzerodollarprogram (pgm_enrolled_rec.objid);
            ELSE
              --- Insert the record into purchase detail for the primary phone. ------------------------------------
              l_next_cycle_date := get_next_cycle_date (pgm_enrolled_rec.pgm_enroll2pgm_parameter , pgm_enrolled_rec.x_next_charge_date );
              --             ----DBMS_OUTPUT.PUT_LINE ( 'Inserting Primary record into Purchase Detail '  );
              l_charge_desc         := 'Program charges for the cycle ' || TO_CHAR ( pgm_enrolled_rec.x_next_charge_date, 'MM/DD/YYYY' );
              IF (l_next_cycle_date IS NOT NULL) THEN
                l_charge_desc       := l_charge_desc || ' ' || ' to ' || TO_CHAR ( l_next_cycle_date - 1, 'MM/DD/YYYY');
              END IF;
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
                  --x_merchant_ref_number,          -- No need to insert this
                  pgm_purch_dtl2pgm_enrolled,
                  pgm_purch_dtl2prog_hdr,
                  X_USF_TAXAMOUNT,   -- STRAIGHT TALK .. CR8663
                  X_RCRF_TAX_AMOUNT, --STUL CR11553
                  x_priority         --CR25625
                )
                VALUES
                (
                  billing_seq ('X_PROGRAM_PURCH_DTL'),
                  pgm_enrolled_rec.x_esn,
                  l_price_p,
                  ROUND(l_tax,2),     --CR23907 jchacon
                  ROUND(l_e911_tax,2),--CR23907 jchacon
                  l_charge_desc,
                  pgm_enrolled_rec.x_next_charge_date,
                  l_next_cycle_date,
                  -- x_exp_date is not to be used here
                  --l_mer_ref_no,   -- No need to insert this
                  pgm_enrolled_rec.objid,
                  x_py_pur_hdr_id,
                  --l_add1_tax -- STRAIGHT TALK .. CR8663
                  ROUND(l_usf_tax,2),                 --STUL--CR23907 jchacon
                  ROUND(l_rcrf_tax,2),                --STUL --CR11553--CR23907 jchacon
                  NVL (pgm_enrolled_rec.x_priority,20)--Modified for CR34303 --in_priority          --CR25625
                );
              -- --DBMS_OUTPUT.PUT_LINE ('Setting New Expiry Date ');
              retval := set_new_exp_date (pgm_enrolled_rec.x_esn, pgm_enrolled_rec.objid );
              ---------------------------------------------------------------------------------------------------
              --               --DBMS_OUTPUT.PUT_LINE (   'lprice_p' || l_price_p);
              ---------------- Select all the additional phones for the given primary record
              --               --DBMS_OUTPUT.PUT_LINE ('Beginning Additional Phone Processing ');
              FOR rec IN
              (SELECT  *
                FROM x_program_enrolled
                WHERE pgm_enroll2pgm_group = pgm_enrolled_rec.objid
                  --                         AND TRUNC (x_next_charge_date) = TRUNC (l_sysdate) -- Review: Sharat: No need to worry about dates since charges always done against the primary phone.
                AND x_enrollment_status IN ('ENROLLED', 'ENROLLMENTSCHEDULED')
                AND (x_wait_exp_date    IS NULL)
                  -- Review: Sharat: No need for this check. if group column has the values, it is always a additional phone
                AND x_is_grp_primary = 0
              )
              LOOP
                --                  --DBMS_OUTPUT.PUT_LINE ( 'Step 2: Processing Additional Phones ' );
                -- l_price_s cumulative totals
                -- l_tmp_s   current line item price.
                l_tmp_s := rec.x_amount;
                --CR11553         SP_TAXES.GETTax2_BILL(l_tmp_s,l_usf_tax_percent,l_rcrf_tax_percent,l_usf_tax,l_rcrf_tax);
                SP_TAXES.GETTAX_BILL(L_TMP_S,L_SALES_TAX_PERCENT,L_E911_TAX_PERCENT,L_TAX,L_E911_TAX);
                L_E911_TAX := NVL(L_E911_TAX,0) + NVL(L_E911_SURCHARGE,0); --CR24538
                /*CR11553
                l_tax := l_tmp_s * l_sales_tax_percent;
                l_e911_tax := l_tmp_s * l_e911_tax_percent;
                l_usf_tax := l_tmp_s * l_usf_tax_percent;--STUL
                l_misc_tax := l_tmp_s * l_misc_tax_percent;--STUL  cr11553*/
                --l_add1_tax := l_tmp_s * (NVL(l_add1_tax_percent, 0) / 100); -- STRAIGHT TALK .. CR8663
                -- Added by Sharat: Changes Start
                --- If the program status is ENROLLMENTSCHEDULED, then collect the enrollment fee + tax for the additional esn only.
                IF (rec.x_enrollment_status = 'ENROLLMENTSCHEDULED') THEN
                  l_tmp_s                  := l_tmp_s + rec.x_enroll_amount;
                  --CR11553
                  SP_TAXES.GETTax2_BILL(l_tmp_s,l_usf_tax_percent,l_rcrf_tax_percent,l_usf_tax,l_rcrf_tax);


                -- BEGIN CR52959 Calling the following procedure to override the l_usf_tax and l_rcrf_tax amounts if there flags are N
                  sp_taxes.GET_TAX_AMT(i_source_system => rec.x_sourcesystem, o_usf_tax_amt => l_usf_tax, o_rcrf_tax_amt =>l_rcrf_tax ,o_usf_percent  => l_usf_tax_percent,o_rcrf_percent =>l_rcrf_tax_percent );


                 DBMS_OUTPUT.PUT_LINE( 'l_usf_tax :' || l_usf_tax ) ;
                 DBMS_OUTPUT.PUT_LINE( 'l_rcrf_tax :' || l_rcrf_tax ) ;
                 DBMS_OUTPUT.PUT_LINE( ' l_usf_tax_percent :' ||  l_usf_tax_percent ) ;
                 DBMS_OUTPUT.PUT_LINE( 'l_rcrf_tax_percent :' || l_rcrf_tax_percent ) ;
                ---END CR52959 Calling the above procedure to override the l_usf_tax and l_rcrf_tax amounts if there flags are N

                  SP_TAXES.GETTAX_BILL(L_TMP_S,L_SALES_TAX_PERCENT,L_E911_TAX_PERCENT,L_TAX,L_E911_TAX);
                  L_E911_TAX := NVL(L_E911_TAX,0) + NVL(L_E911_SURCHARGE,0); --CR24538
                 /* CR11553
                  l_tax := l_tmp_s * l_sales_tax_percent;
                  l_e911_tax := l_tmp_s * l_e911_tax_percent;
                  l_usf_tax := l_tmp_s * l_usf_tax_percent;--STUL
                  l_misc_tax := l_tmp_s * l_misc_tax_percent; */
                  --STUL
                  --l_add1_tax := l_tmp_s * (NVL(l_add1_tax_percent, 0) / 100);
                  -- STRAIGHT TALK .. CR8663
                END IF;
                l_price_s := l_price_s + l_tmp_s;
                --                  ----DBMS_OUTPUT.PUT_LINE ('Inserting Record into Purchase Detail ');
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
                    --x_merchant_ref_number,   -- No need of this
                    pgm_purch_dtl2pgm_enrolled,
                    pgm_purch_dtl2prog_hdr,
                    X_USF_TAXAMOUNT,   -- STRAIGHT TALK .. CR8663
                    X_RCRF_TAX_AMOUNT, --STUL CR11553
                    x_priority         --CR25625
                  )
                  VALUES
                  (
                    billing_seq ('X_PROGRAM_PURCH_DTL'),
                    rec.x_esn,
                    l_tmp_s,
                    ROUND(l_tax,2),     --CR23907 jchacon
                    ROUND(l_e911_tax,2),--CR23907 jchacon
                    'Program charges for the cycle '
                    || TO_CHAR (rec.x_next_charge_date , 'MM/DD/YYYY' )
                    || ' to '
                    || TO_CHAR (l_next_cycle_date - 1, 'MM/DD/YYYY'),
                    rec.x_next_charge_date,
                    l_next_cycle_date,
                    -- Always follow the next cycle date of the primary
                    ---    l_mer_ref_no,  -- No Need of this
                    rec.objid,
                    x_py_pur_hdr_id,
                    --l_add1_tax -- STRAIGHT TALK .. CR8663
                    ROUND(l_usf_tax,2),                --STUL--CR23907 jchacon
                    ROUND(l_rcrf_tax,2),               --STUL  CR11553--CR23907 jchacon
                    NVL(pgm_enrolled_rec.x_priority,20)--Modified for CR34303 --in_priority          --CR25625
                  );
                --  --DBMS_OUTPUT.PUT_LINE ('Extending the expiry date ');
                retval := set_new_exp_date (rec.x_esn, rec.objid);
              END LOOP;
              total_price := (l_price_p + l_price_s);
              --               --DBMS_OUTPUT.PUT_LINE ('Total purchase amount '  || TO_CHAR (total_price) );
              --               --DBMS_OUTPUT.PUT_LINE ( 'Total tax is ' || TO_CHAR (total_price * l_sales_tax_percent));
              --               --DBMS_OUTPUT.PUT_LINE ('After inserting records into Payment Detail ' );
             ----------------------------- Get the payment type. Use payment source ID to determine the type of payment ----------------------
              BEGIN
                SELECT x_pymt_type,
                  pymt_src2x_credit_card,
                  pymt_src2x_bank_account
                INTO l_payment_source_type,
                  l_credit_card_objid,
                  l_bank_account_objid
                FROM x_payment_source
                WHERE objid = pgm_enrolled_rec.pgm_enroll2x_pymt_src;
              EXCEPTION
                --CR11480
              WHEN NO_DATA_FOUND THEN
                NULL;
                --CR11480
              WHEN OTHERS THEN
                global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
                    'BILLING_JOB_PKG.recurring_payment',
                    -100,
                    global_error_message,
                    SYSDATE,
                    'No Payment source found for '
                    || TO_CHAR ( pgm_enrolled_rec.pgm_enroll2x_pymt_src),
                    2 -- MEDIUM
                  );
                op_result := - 100;
                op_msg    := 'No Payment source found for ' || TO_CHAR ( pgm_enrolled_rec.pgm_enroll2x_pymt_src);
                NULL;
                -- This record has failed. However, do not hold up the batch. Continue further processing
              END;
              -----------------------------------------------------------------------------------------------------------
             -- instantiate esn from purch detail or purch hdr
              c := customer_type ( i_esn => pgm_enrolled_rec.x_esn );

              -- get the sub brand of the esn
              c.sub_brand := c.get_sub_brand;

              -- convert the SIMPLE_MOBILE to GO_SMART when applicable
              c.bus_org_id := CASE WHEN c.sub_brand IS NOT NULL THEN c.sub_brand ELSE p_bus_org END;

              --- Get the merchant id from x_cc_parms table.
              IF (bmultimerchantflag = FALSE) THEN
                BEGIN
                  SELECT DECODE (p_bus_org, 'TRACFONE', 'tracfone', x_merchant_id ),
                    x_ignore_bad_cv
                  INTO l_merchant_id,
                    l_ignore_bad_cv
                  FROM table_x_cc_parms
                  WHERE x_bus_org = c.bus_org_id; --previous: p_bus_org;
                  --l_merchant_id := 'tracfone';     -- *** Hardcoded for now. All merchant IDs to be Tracfone **** ---
                EXCEPTION
                WHEN OTHERS THEN
                  global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
                      'BILLING_JOB_PKG.recurring_payment',
                      -107,
                      global_error_message,
                      SYSDATE,
                      'No merchant parameter settings found in table_x_cc_params for the business organization',
                      2 -- MEDIUM
                    );
                  op_result     := - 107;
                  op_msg        := 'No merchant parameter settings found in table_x_cc_params for the business organization' ;
                  l_merchant_id := NULL;
                END;
              ELSE
                --------------- Multi merchant ID ------------------------------------------------------------
                BEGIN
                  ----CR13581
                  SELECT COUNT(*)
                  INTO L_Count
                  FROM Table_Web_User,
                    X_Business_Accounts,
                    x_program_enrolled
                  WHERE Web_User2contact       = Bus_Primary2contact
                  AND Pgm_Enroll2web_User      = Table_Web_User.Objid
                  AND x_program_enrolled.objid = pgm_enrolled_rec.objid;
                  IF L_Count                   >0 THEN --Buisness Account B2B
                    SELECT x_merchant_id,
                      x_ignore_bad_cv
                    INTO L_Merchant_Id,
                      L_Ignore_Bad_Cv
                    FROM Table_X_Cc_Parms
                    WHERE X_Bus_Org = 'BILLING B2B';
                  ELSE -- regular account            ---   CR13581
                    SELECT x_merchant_id,
                      x_ignore_bad_cv
                    INTO l_merchant_id,
                      l_ignore_bad_cv
                    FROM table_x_cc_parms
                    WHERE x_bus_org =
                      (SELECT 'BILLING '
                        ||(
                        CASE
                          WHEN x_program_name NOT IN ('Straight Talk REMOTE ALERT 30 D','Straight Talk REMOTE ALERT 365 D')
                          THEN CASE WHEN c.sub_brand IS NOT NULL THEN c.sub_brand ELSE org_id END --previos: org_id
                          ELSE 'REMOTE_ALERT'
                        END)
                      FROM table_bus_org bo,
                        x_program_parameters pp
                      WHERE bo.objid = prog_param2bus_org
                      AND pp.objid   = Pgm_Enrolled_Rec.Pgm_Enroll2pgm_Parameter
                      );
                  END IF; --------CR13581
                EXCEPTION
                WHEN OTHERS THEN
                  global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
                      'BILLING_JOB_PKG.recurring_payment',
                      -107,
                      global_error_message,
                      SYSDATE,
                      'No merchant parameter settings found in table_x_cc_params for the business organization',
                      2 -- MEDIUM
                    );
                  op_result     := - 107;
                  op_msg        := 'No merchant parameter settings found in table_x_cc_params for the business organization' ;
                  l_merchant_id := NULL;
                END;
              END IF;
              -----------------------------------------------------------------------------------------------------------
              --             ----DBMS_OUTPUT.PUT_LINE ('After checking payment type ' || l_payment_source_type  );
              IF l_payment_source_type = 'CREDITCARD' THEN
                BEGIN
                  SELECT OBJID ,                                               --    NUMBER
                    X_CUSTOMER_CC_NUMBER ,                                     --    VARCHAR2(255)
                    X_CUSTOMER_CC_EXPMO ,                                      --    VARCHAR2(2)
                    X_CUSTOMER_CC_EXPYR ,                                      --    VARCHAR2(4)
                    X_CC_TYPE ,                                                --    VARCHAR2(20)
                    X_CUSTOMER_CC_CV_NUMBER ,                                  --    VARCHAR2(20)
                    regexp_replace(X_CUSTOMER_FIRSTNAME, '[^0-9 A-Za-z]', '') ,--    VARCHAR2(20)
                    regexp_replace(X_CUSTOMER_LASTNAME, '[^0-9 A-Za-z]', '') , --    VARCHAR2(20)
                    CASE WHEN (LENGTH(X_CUSTOMER_PHONE) > 10                   --   CR42815_CyberSource
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
                           END X_CUSTOMER_PHONE,                               --    VARCHAR2(20)
                    X_CUSTOMER_EMAIL ,                                         --    VARCHAR2(50)
                    X_MAX_PURCH_AMT ,                                          --    NUMBER
                    X_MAX_TRANS_PER_MONTH ,                                    --    NUMBER
                    X_MAX_PURCH_AMT_PER_MONTH ,                                --    NUMBER
                    X_CHANGEDATE ,                                             --    DATE
                    X_ORIGINAL_INSERT_DATE ,                                   --    DATE
                    X_CHANGEDBY ,                                              --    VARCHAR2(20)
                    X_CC_COMMENTS ,                                            --    LONG()
                    X_MOMS_MAIDEN ,                                            --    VARCHAR2(20)
                    X_CREDIT_CARD2CONTACT ,                                    --    NUMBER
                    X_CREDIT_CARD2ADDRESS ,                                    --    NUMBER
                    X_CARD_STATUS ,                                            --   VARCHAR2(10)
                    X_MAX_ILD_PURCH_AMT ,                                      --   NUMBER
                    X_MAX_ILD_PURCH_MONTH ,                                    --   NUMBER
                    X_CREDIT_CARD2BUS_ORG ,                                    --   NUMBER
                    X_CUST_CC_NUM_KEY ,                                        --   VARCHAR2(255)
                    X_CUST_CC_NUM_ENC ,                                        --   VARCHAR2(255)
                    CREDITCARD2CERT                                            --   NUMBER
                  INTO v_credit_card_rec
                  FROM table_x_credit_card
                  WHERE objid = l_credit_card_objid;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
                      'BILLING_JOB_PKG.recurring_payment',
                      -101,
                      global_error_message,
                      SYSDATE,
                      ' No CreditCard record found for '
                      || TO_CHAR (l_credit_card_objid),
                      2 -- MEDIUM
                    );
                  op_result := - 101;
                  op_msg    := ' No CreditCard record found for ' || TO_CHAR (l_credit_card_objid);
                END;
                --                  ----DBMS_OUTPUT.PUT_LINE ('After selecting credit card ');
                BEGIN
                  SELECT OBJID,                                       --                   NUMBER
                    regexp_replace(ADDRESS, '[^0-9 A-Za-z.-]', ''),   --                 VARCHAR2(200)
                    regexp_replace(S_ADDRESS, '[^0-9 A-Za-z.-]', ''), --               VARCHAR2(200)
                    regexp_replace(CITY, '[^0-9 A-Za-z.-]', ''),      --                    VARCHAR2(30)
                    regexp_replace(S_CITY, '[^0-9 A-Za-z.-]', ''),    --                  VARCHAR2(30)
                    regexp_replace(STATE, '[^0-9 A-Za-z.-]', ''),     --                   VARCHAR2(60)
                    regexp_replace(S_STATE, '[^0-9 A-Za-z.-]', ''),   --                 VARCHAR2(60)
                    regexp_replace(ZIPCODE, '[^0-9 A-Za-z.-]', ''),   --                 VARCHAR2(60)
                    regexp_replace(ADDRESS_2, '[^0-9 A-Za-z.-]', ''), --               VARCHAR2(200)
                    DEV,                                              --                     NUMBER
                    ADDRESS2TIME_ZONE,                                --       NUMBER(38)
                    ADDRESS2COUNTRY,                                  --         NUMBER(38)
                    ADDRESS2STATE_PROV,                               --      NUMBER(38)
                    UPDATE_STAMP ,                                    --            DATE
                    ADDRESS2E911
                  INTO address
                  FROM table_address
                  WHERE objid = v_credit_card_rec.x_credit_card2address;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  --cwl 1/13/2012  CR19559
                  address := clear_address;
                  --cwl 1/13/2012  CR19559
                  global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
                      'BILLING_JOB_PKG.recurring_payment',
                      -101,
                      global_error_message,
                      SYSDATE,
                      ' No address found for the credit card address ( address objid ) '
                      || TO_CHAR (v_credit_card_rec.x_credit_card2address)
                      || ' cc(objid):'
                      || TO_CHAR (v_credit_card_rec.objid)
                      || ' contact(objid):'
                      || TO_CHAR(v_credit_card_rec.X_CREDIT_CARD2CONTACT),
                      2
                    );-- MEDIUM CR19559
                  op_result := - 101;
                  op_msg    := ' No address found for the credit card address ( address objid ) ' || TO_CHAR (v_credit_card_rec.x_credit_card2address)|| ' cc(objid):'|| TO_CHAR (v_credit_card_rec.objid) || ' contact(objid):'|| TO_CHAR(v_credit_card_rec.X_CREDIT_CARD2CONTACT); --CR19559
                END;
                --                  ----DBMS_OUTPUT.PUT_LINE ('After selecting address ' || 'Merchant ref number '  || l_mer_ref_no  );
                ----------------------------------------------------------------------------------------------------
                --Added for CR41241 to get the country name from table_country table
                BEGIN
                    SELECT DECODE(S_NAME,'USA', S_NAME, X_POSTAL_CODE)
                      INTO l_country
                      FROM TABLE_COUNTRY
                     WHERE objid = address.ADDRESS2COUNTRY;
                 EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   l_country := 'USA';
                 END;
                 --DBMS_OUTPUT.PUT_LINE('l_country'||l_country);
                 --End CR41241
                    ------------------ Insert into purchase header table.
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
                    --x_esn,
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
                    --,purch_hdr2prog_enrolled   -- Not needed
                    x_payment_type,
                    X_USF_TAXAMOUNT,   -- STRAIGHT TALK .. CR8663
                    x_rcrf_tax_amount, --STUL  --cr11553
                    x_discount_amount, -- CR11553
                    x_priority         --CR25625
                  )
                  VALUES
                  (
                    x_py_pur_hdr_id,
                    pgm_enrolled_rec.x_sourcesystem,
                    'CREDITCARD_PURCH',
                    l_sysdate,
                    'ccAuthService_run,ccCaptureService_run',
                    --- Review: Sharat: We need to check the source system. (CC_PURCH, ACH_PURCH)
                    l_merchant_id,
                    l_mer_ref_no,
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
                    --v_credit_card_rec.x_customer_firstname,
                    NVL(v_credit_card_rec.x_customer_firstname, 'No Name Provided'), --CR11480
                    --v_credit_card_rec.x_customer_lastname,
                    NVL(v_credit_card_rec.x_customer_lastname, 'No Name Provided'), --CR11480
                    v_credit_card_rec.x_customer_phone,
                    NVL (v_credit_card_rec.x_customer_email, 'null@cybersource.com' ),
                    'RECURINCOMPLETE',
                    --address.address,
                    --address.address_2,
                    NVL(address.address, 'No Address Provided'),  --CR11480
                    NVL(address.address_2, 'No Address Provided'),--CR11480
                    address.city,
                    address.state,
                    address.zipcode,
                    l_country,   --CR41241
                    -- pgm_enrolled_rec.x_esn, -- No need to insert
                    total_price,
                    ROUND(TOTAL_PRICE * L_SALES_TAX_PERCENT,2),--CR23907 jchacon
                    --total_price * l_e911_tax_percent,
                    ROUND((total_price * l_e911_tax_percent) + NVL(L_E911_SURCHARGE,0),2), --CR24538--CR23907 jchacon
                    NULL,
                    NULL,
                    'System',
                    NULL,
                    v_credit_card_rec.objid,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    pgm_enrolled_rec.pgm_enroll2x_pymt_src,
                    pgm_enrolled_rec.pgm_enroll2web_user,
                    NULL,
                    -- Put the value in, based on the program type.
                    getpaymenttype (pgm_enrolled_rec.pgm_enroll2pgm_parameter) ,
                    --total_price * (NVL(l_add1_tax_percent, 0) / 100) -- STRAIGHT TALK .. CR8663
                    ROUND(total_price * l_usf_tax_percent,2), --STUL--CR23907 jchacon
                    ROUND(total_price * l_rcrf_tax_percent,2),--STUL CR11553--CR23907 jchacon
                    l_enroll_amount,                          --CR11553
                    NVL(pgm_enrolled_rec.x_priority,20)       --Modified for CR34303 --in_priority                               --CR25625
                  );
                --                  ----DBMS_OUTPUT.PUT_LINE ('After insert into Prog Hdr ');
                ---------------------- Insert into CreditCard Trans record -------------------------------------
                INSERT
                INTO x_cc_prog_trans
                  (
                    objid,
                    x_ignore_bad_cv,
                    x_ignore_avs,
                    x_avs,
                    x_disable_avs,
                    x_auth_avs,
                    x_auth_cv_result,
                    x_score_factors,
                    x_score_host_severity,
                    x_score_rcode,
                    x_score_rflag,
                    x_score_rmsg,
                    x_score_result,
                    x_score_time_local,
                    x_customer_cc_number,
                    x_customer_cc_expmo,
                    x_customer_cc_expyr,
                    x_customer_cvv_num,
                    x_cc_lastfour,
                    x_cc_trans2x_credit_card,
                    x_cc_trans2x_purch_hdr
                    --,x_cc_trans2pgm_entrolled
                  )
                  VALUES
                  (
                    billing_seq ('X_CC_PROG_TRANS'), --objid,
                    l_ignore_bad_cv,                 --x_ignore_bad_cv,
                    NULL,                            --x_ignore_avs,
                    NULL,                            --x_avs,
                    NULL,                            --x_disable_avs,
                    NULL,                            --x_auth_avs,
                    NULL,                            --x_auth_cv_result,
                    NULL,                            --x_score_factors,
                    NULL,                            --x_score_host_severity,
                    NULL,                            --x_score_rcode,
                    NULL,                            --x_score_rflag,
                    NULL,                            --x_score_rmsg,
                    NULL,                            --x_score_result,
                    NULL,                            --x_score_time_local,
                    v_credit_card_rec.x_customer_cc_number,
                    --x_customer_cc_number,
                    v_credit_card_rec.x_customer_cc_expmo,
                    --x_customer_cc_expmo,
                    v_credit_card_rec.x_customer_cc_expyr,
                    --x_customer_cc_expyr,
                    v_credit_card_rec.x_customer_cc_cv_number,
                    --x_customer_cvv_num,
                    NULL, --x_cc_lastfour,
                    v_credit_card_rec.objid,
                    --x_cc_trans2x_credit_card,
                    x_py_pur_hdr_id --, --x_cc_trans2x_purch_hdr,
                    -- pgm_enrolled_rec.objid --x_cc_trans2pgm_entrolled
                  );
                --                  ----DBMS_OUTPUT.PUT_LINE ('After creating CC Trans ');
                ------------------------------------------------------------------------------------------------
              ELSIF l_payment_source_type = 'ACH' THEN
                -- This is an ACH Payment
                BEGIN
                  SELECT OBJID ,                                               --   NUMBER
                    X_BANK_NUM ,                                               --   VARCHAR2(30)
                    X_CUSTOMER_ACCT ,                                          --   VARCHAR2(30)
                    X_ROUTING ,                                                --   VARCHAR2(20)
                    X_ABA_TRANSIT ,                                            --   VARCHAR2(30)
                    X_BANK_NAME ,                                              --   VARCHAR2(20)
                    X_STATUS ,                                                 --   VARCHAR2(10)
                    regexp_replace(X_CUSTOMER_FIRSTNAME, '[^0-9 A-Za-z]', '') ,--   VARCHAR2(20)
                    regexp_replace(X_CUSTOMER_LASTNAME, '[^0-9 A-Za-z]', '') , --   VARCHAR2(20)
                    CASE WHEN (LENGTH(X_CUSTOMER_PHONE) > 10                   --   CR42815_CyberSource
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
                           END X_CUSTOMER_PHONE,                               --    VARCHAR2(20)
                    X_CUSTOMER_EMAIL ,                                         --   VARCHAR2(50)
                    X_MAX_PURCH_AMT ,                                          --   NUMBER
                    X_MAX_TRANS_PER_MONTH ,                                    --   NUMBER
                    X_MAX_PURCH_AMT_PER_MONTH ,                                --   NUMBER
                    X_CHANGEDATE ,                                             --   DATE
                    X_ORIGINAL_INSERT_DATE ,                                   --   DATE
                    X_CHANGEDBY ,                                              --   VARCHAR2(20)
                    X_CC_COMMENTS ,                                            --   LONG()
                    X_MOMS_MAIDEN ,                                            --   VARCHAR2(20)
                    X_BANK_ACCT2CONTACT ,                                      --   NUMBER
                    X_BANK_ACCT2ADDRESS ,                                      --   NUMBER
                    X_BANK_ACCOUNT2BUS_ORG,                                    --   NUMBER
                    BANK2CERT,                                                 --   NUMBER
                    X_CUSTOMER_ACCT_KEY,                                       --   VARCHAR2(400)
                    X_CUSTOMER_ACCT_ENC                                        --   VARCHAR2(400)
                  INTO v_bank_acount
                  FROM table_x_bank_account
                  WHERE objid = l_bank_account_objid;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
                      'BILLING_JOB_PKG.recurring_payment',
                      -100,
                      global_error_message,
                      SYSDATE,
                      ' No record found for the bank account '
                      || TO_CHAR (l_bank_account_objid),
                      2 -- MEDIUM
                    );
                  op_result := - 103;
                  op_msg    := ' No record found for the bank account ' || TO_CHAR (l_bank_account_objid);
                END;
                --                  ----DBMS_OUTPUT.PUT_LINE ('AFter bank account ');
                BEGIN
                  SELECT OBJID,                                       --                   NUMBER
                    regexp_replace(ADDRESS, '[^0-9 A-Za-z.-]', ''),   --                 VARCHAR2(200)
                    regexp_replace(S_ADDRESS, '[^0-9 A-Za-z.-]', ''), --               VARCHAR2(200)
                    regexp_replace(CITY, '[^0-9 A-Za-z.-]', ''),      --                    VARCHAR2(30)
                    regexp_replace(S_CITY, '[^0-9 A-Za-z.-]', ''),    --                  VARCHAR2(30)
                    regexp_replace(STATE, '[^0-9 A-Za-z.-]', ''),     --                   VARCHAR2(60)
                    regexp_replace(S_STATE, '[^0-9 A-Za-z.-]', ''),   --                 VARCHAR2(60)
                    regexp_replace(ZIPCODE, '[^0-9 A-Za-z.-]', ''),   --                 VARCHAR2(60)
                    regexp_replace(ADDRESS_2, '[^0-9 A-Za-z.-]', ''), --               VARCHAR2(200)
                    DEV,                                              --                     NUMBER
                    ADDRESS2TIME_ZONE,                                --       NUMBER(38)
                    ADDRESS2COUNTRY,                                  --         NUMBER(38)
                    ADDRESS2STATE_PROV,                               --      NUMBER(38)
                    UPDATE_STAMP ,                                    --            DATE
                    ADDRESS2E911
                  INTO bank
                  FROM table_address
                  WHERE objid = v_bank_acount.x_bank_acct2address;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  --cwl 1/13/2012  CR19559
                  address := clear_address;
                  --cwl 1/13/2012  CR19559
                  global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
                      'BILLING_JOB_PKG.recurring_payment',
                      -100,
                      global_error_message,
                      SYSDATE,
                      ' No address record found for '
                      || TO_CHAR (v_bank_acount.x_bank_acct2address)
                      || ' contact(objid):'
                      || TO_CHAR(v_bank_acount.X_BANK_ACCT2CONTACT), --CR19559
                      2
                    );
                  op_result := - 104;
                  op_msg    := ' No address record found for ' || TO_CHAR (v_bank_acount.x_bank_acct2address)|| ' contact(objid):'|| TO_CHAR(v_bank_acount.X_BANK_ACCT2CONTACT); --CR19559
                  --                        ----DBMS_OUTPUT.PUT_LINE ( 'No Data found in table_address for the bank account '  );
                END;
                --                  ----DBMS_OUTPUT.PUT_LINE ('Before ACH Insert program headers ');
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
                    x_merchant_product_sku, -- NULL ,
                    x_payment_line2program, -- NULL ,
                    x_product_code,
                    -- NULL ,
                    x_ignore_avs, -- 'YES ' ,
                    x_user_po,    -- NULL ,
                    x_avs,        -- NULL ,
                    x_disable_avs,
                    -- ' FALSE ' ,
                    x_customer_hostname, -- NULL
                    x_customer_ipaddress,
                    -- NULL
                    x_auth_request_id, --NULL
                    x_auth_code,       -- NULL
                    x_auth_type,
                    -- NULL
                    x_ics_rcode,         -- NULL
                    x_ics_rflag,         -- NULL
                    x_ics_rmsg,          -- NULL
                    x_request_id,        -- NULL
                    x_auth_avs,          -- NULL
                    x_auth_response,     --NULL
                    x_auth_time,         -- NULL
                    x_auth_rcode,        --NULL
                    x_auth_rflag,        -- NULL
                    x_auth_rmsg,         -- NULL
                    x_bill_request_time, -- NULL
                    x_bill_rcode,        -- NULL
                    x_bill_rflag,        -- NULL
                    x_bill_rmsg,         -- NULL
                    x_bill_trans_ref_no, -- NULL
                    x_customer_firstname,
                    x_customer_lastname,
                    x_customer_phone,
                    x_customer_email,
                    x_status, -- scheduled
                    x_bill_address1,
                    x_bill_address2,
                    x_bill_city,
                    x_bill_state,
                    x_bill_zip,
                    x_bill_country, -- x_esn,
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
                    X_USF_TAXAMOUNT,   -- STRAIGHT TALK .. CR8663
                    x_rcrf_tax_amount, --STUL CR11553
                    x_discount_amount, --CR11553
                    --                         ,purch_hdr2prog_enrolled     -- Not Required
                    x_priority --CR25625
                  )
                  VALUES
                  (
                    x_py_pur_hdr_id,
                    pgm_enrolled_rec.x_sourcesystem,
                    'ACH_PURCH',
                    l_sysdate,
                    'ecDebitService_run', -- ACH FLow
                    l_merchant_id,
                    l_mer_ref_no,
                    NULL,
                    1,
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
                    --v_bank_acount.x_customer_firstname,
                    --v_bank_acount.x_customer_lastname,
                    NVL(v_bank_acount.x_customer_firstname, 'No Name Provided'), --CR11480
                    NVL(v_bank_acount.x_customer_lastname, 'No Name Provided'),  --CR11480
                    v_bank_acount.x_customer_phone,
                    NVL (v_bank_acount.x_customer_email, 'null@cybersource.com' ),
                    'RECURINCOMPLETE',
                    --bank.address,
                    --bank.address_2,
                    NVL(bank.address, 'No Address Provided'),   --CR11480
                    NVL(bank.address_2, 'No Address Provided'), --CR11480
                    bank.city,
                    bank.state,
                    bank.zipcode,
                    'US',
                    --pgm_enrolled_rec.x_esn, -- No need to insert
                    total_price,
                    ROUND(TOTAL_PRICE * L_SALES_TAX_PERCENT,2),--CR23907 jchacon
                    --total_price * l_e911_tax_percent,
                    ROUND((total_price * l_e911_tax_percent) + NVL(L_E911_SURCHARGE,0),2), --CR23907 jchacon --CR24538
                    NULL,
                    NULL,
                    'System',
                    NULL,
                    NULL,
                    v_bank_acount.objid,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    pgm_enrolled_rec.pgm_enroll2x_pymt_src,
                    pgm_enrolled_rec.pgm_enroll2web_user,
                    NULL,
                    getpaymenttype (pgm_enrolled_rec.pgm_enroll2pgm_parameter) ,
                    --total_price * (NVL(l_add1_tax_percent, 0) / 100) -- STRAIGHT TALK .. CR8663
                    ROUND(total_price * l_usf_tax_percent,2),  --STUL--CR23907 jchacon
                    ROUND(total_price * l_rcrf_tax_percent,2), --STUL--CR23907 jchacon
                    l_enroll_amount,                           --CR11553
                    NVL(pgm_enrolled_rec.x_priority,20)        --Modified for CR34303 --in_priority                                --CR25625
                  );
                ------------------ Insert record into ACH Trans -----------------------------------------------
                --                  ----DBMS_OUTPUT.PUT_LINE ('Insert into ACH Prog Trans ');
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
                    --,ach_trans2pgm_enrolled
                  )
                  VALUES
                  (
                    billing_seq ('X_ACH_PROG_TRANS'), --objid,
                    v_bank_acount.x_bank_num,         --x_bank_num,
                    v_bank_acount.x_customer_acct,
                    --x_ecp_account_no,
                    -- CR47971 CHANGING FROM x_aba_transit TO UPPER x_aba_transit
                    --DECODE (v_bank_acount.x_aba_transit, 'SAVINGS', 'S', 'CHECKING', 'C', 'CORPORATE', 'X', v_bank_acount.x_aba_transit ), --x_ecp_account_type,
                    DECODE (UPPER(v_bank_acount.x_aba_transit), 'SAVINGS', 'S', 'CHECKING', 'C', 'CORPORATE', 'X', v_bank_acount.x_aba_transit ), --x_ecp_account_type,
                    v_bank_acount.x_routing,                                                                                               -- x_ecp_rdfi,
                    'A',
                    --x_ecp_settlement_method,
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
                    --,pgm_enrolled_rec.objid
                  );
                -----------------------------------------------------------------------------------------------
              END IF;
            END IF; --- 0$ Check
            -- Drop a record into X_PROGRAM_DISCOUNT_HIST if discount is applied.
            -- CR15373 WMMC pm Start
            IF ( l_promo_error_code = 0 AND L_PROMO_code IS NOT NULL ) THEN
              INSERT
              INTO x_program_discount_hist
                (
                  objid,
                  x_discount_amount,
                  pgm_discount2x_promo,
                  pgm_discount2pgm_enrolled,
                  pgm_discount2prog_hdr,
                  pgm_discount2web_user
                )
                VALUES
                (
                  billing_seq ('X_PROGRAM_DISCOUNT_HIST'),
                  l_promo_enroll_amount,
                  l_promo_objid,
                  pgm_enrolled_rec.objid,
                  x_py_pur_hdr_id,
                  pgm_enrolled_rec.pgm_enroll2web_user
                );
              /*CR27159
              money_card_pkg.modify_usage(x_py_pur_hdr_id,
              l_promo_error_code,
              l_promo_error_message);  */
              --CR27159 comment money card
              ----DBMS_OUTPUT.PUT_LINE('pm discount hist ESN :- '||pgm_enrolled_rec.x_esn||', py pur hhdr :- '||x_py_pur_hdr_id||', promocode :- '||l_wm_promo_objid);
            END IF;
            IF l_promo_code IS NULL THEN -- PM Added this condition to skip other promo.
              -- CR15373 WMMC pm End
              IF ( l_error_code = 0 AND l_enroll_type LIKE 'RECURRING%' AND l_enroll_amount != 0 ) THEN
                INSERT
                INTO x_program_discount_hist
                  (
                    objid,
                    x_discount_amount,
                    pgm_discount2x_promo,
                    pgm_discount2pgm_enrolled,
                    pgm_discount2prog_hdr,
                    pgm_discount2web_user
                  )
                  VALUES
                  (
                    billing_seq ('X_PROGRAM_DISCOUNT_HIST'),
                    l_enroll_amount,
                    pgm_enrolled_rec.pgm_enroll2x_promotion,
                    pgm_enrolled_rec.objid,
                    x_py_pur_hdr_id,
                    pgm_enrolled_rec.pgm_enroll2web_user
                  );
              END IF;
            END IF;
          END;
          -- CR49058 changes starts..
          -- call to update the status and expiry date in x_vas_subscription
          IF ( check_x_parameter ( p_v_x_param_name => 'NON_BASE_PROGRAM_CLASS',
                                   p_v_x_param_value => pgm_enrolled_rec.x_prog_class ) )
          THEN
            vas_management_pkg.p_update_vas_subscription ( i_esn                => pgm_enrolled_rec.x_esn,
                                                           i_program_enroll_id  => pgm_enrolled_rec.objid);
          END IF;
          -- CR49058 changes ends.
          ---- Log the details into the BILLING_LOG table
          l_error_message     := billing_payment_recon_pkg.payment_log ( x_py_pur_hdr_id, 1);
          IF (l_commit_counter > l_commit_size) THEN
            COMMIT;
            l_commit_counter := 0;
            ----DBMS_OUTPUT.PUT_LINE ('Commiting the records ');
          END IF;
        END IF;
        CLOSE c2;
        -- CR20276 Start kacosta 04/01/2012
      END IF;
      -- CR20276 End kacosta 04/01/2012
    END LOOP;
    ----DBMS_OUTPUT.PUT_LINE ('Add records processed ');
    COMMIT;
    --CR34962
    sa.BILLING_BUNDLE_PKG.SP_RECURRING_PAYMENT_BUNDLE( p_bus_org --IP_BUS_ORG
    ,in_priority                                                 --IP_PRIORITY
    ,OP_RESULT ,OP_MSG );
    ---  Cpannala CR25490/CR29410
    recurring_payment_b2b( p_bus_org , -- IN VARCHAR2 DEFAULT 'TRACFONE',
    in_priority ,                      --IN VARCHAR2 DEFAULT NULL, ---CR25625
    op_result ,                        --OUT NUMBER,
    op_msg );                          --OUT VARCHAR2 );
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    op_result := 0;
    op_msg    := 'Success';
  WHEN OTHERS THEN
    global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
        'BILLING_JOB_PKG.recurring_payment',
        -900,
        global_error_message,
        SYSDATE,
        'BILLING_JOB_PKG.recurring_payment',
        2 -- MEDIUM
      );
    op_result := - 900;
    op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  END recurring_payment;
  ---
  /* changes starts for CR22313 HPP Phase 2  */
PROCEDURE P_SUSPEND_HPP_ENROLLMENT
  (
    in_pgm_enroll_objid IN x_program_enrolled.objid%type,
    in_esn              IN x_program_enrolled.x_esn%type,
    in_suspend_reason   IN x_program_enrolled.x_reason%type,
    in_exp_date         IN x_program_enrolled.x_exp_date%type
  )
IS
  /*
  25-jun-2014
  CR22313 HPP Phase 2
  vkashmire@tracfone.com
  procedure p_suspend_hpp_enrollment : created to suspend given input ESN
  there are various places where an ESN gets suspended so better use this procedure for same
  ESN suspension has 4 steps
  update in x_program_enrolled
  insert in x_program_trans
 insert in x_program_notify
  insert in x_billing_log
  input paramaters
  in_pgm_enroll_objid    = x_program_enrolled.objID
  in_esn                 = ESN for which HPP enrollment will get suspended
  in_suspend_reason      = desciption for HPP enrollment suspension
  in_exp_date            = x_program_enrolled.x_exp_date
  This procedure gets invoked from
  1) P_Check_zipcode_N_suspend_Hpp
  2) P_Suspend_Hpp_Having_No_Acc
  */
  lv_enr_status CONSTANT x_program_enrolled.x_reason%type := 'SUSPENDED';
  lv_language x_program_enrolled.x_language%type;
  lv_pgm_enroll2pgm_group x_program_enrolled.pgm_enroll2pgm_group%type;
  lv_pgm_enroll2contact x_program_enrolled.pgm_enroll2contact%type;
  lv_pgm_enroll2web_user x_program_enrolled.pgm_enroll2web_user%type;
 lv_sourcesystem x_program_enrolled.x_sourcesystem%type;
  lv_cooling_period x_program_enrolled.x_cooling_period%type;
  lv_pgm_enroll2site_part x_program_enrolled.pgm_enroll2site_part%type;
  LV_pgm_enroll2pgm_parameter x_program_parameters.objid%type;
  lv_program_name x_program_parameters.x_program_name%type;
  lv_first_name table_contact.first_name%type;
  lv_last_name table_contact.last_name%type;
BEGIN
  BEGIN
    /* update the X_PROGRAM_ENROLLED set x_enrollment_status to suspended */
    UPDATE sa.x_program_enrolled
    SET x_enrollment_status = lv_enr_status,
      x_reason              = in_suspend_reason,
      x_exp_date            = in_exp_date
    WHERE objid             = in_pgm_enroll_objid returning x_language,
      x_sourcesystem,
      x_cooling_period,
      pgm_enroll2site_part,
      pgm_enroll2pgm_group,
      pgm_enroll2contact,
      pgm_enroll2web_user,
      pgm_enroll2pgm_parameter
    INTO lv_language,
      lv_sourcesystem,
      lv_cooling_period,
      lv_pgm_enroll2site_part,
      lv_pgm_enroll2pgm_group,
      lv_pgm_enroll2contact,
      lv_pgm_enroll2web_user,
      LV_pgm_enroll2pgm_parameter;
    SELECT x_program_name
    INTO lv_program_name
    FROM x_program_parameters
    WHERE objid = LV_pgm_enroll2pgm_parameter;
    /* Insert record into X_PROGRAM_TRANS for BI purpose */
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
        x_esn,
        x_exp_date,
        x_cooling_exp_date,
        x_update_status,
        x_update_user,
        pgm_tran2pgm_entrolled,
       pgm_trans2web_user,
        pgm_trans2site_part
      )
      VALUES
      (
        billing_seq ('X_PROGRAM_TRANS'),
        lv_enr_status,
        in_suspend_reason,
        NULL,               --in_float_given,
        NULL,               --in_cooling_given,
        lv_cooling_period,  --in_grace_period_given,
        sysdate,            --x_trans_date,
        'System Suspension',--in_action_text,
        'SUSPEND',          --in_action_type,
        in_suspend_reason,
        lv_sourcesystem,
        in_esn,
        in_exp_date,
        sysdate,
        'I',      --x_update_status
        'System', --x_update_user
        in_pgm_enroll_objid,
        lv_pgm_enroll2web_user,
        lv_pgm_enroll2site_part
      );
    /* insert record in x_program_notify  */
    INSERT
    INTO X_PROGRAM_NOTIFY
      (
        objid,
        x_esn,
        x_program_name,
        x_program_status,
        x_notify_process,
        x_notify_status,
        x_source_system,
        x_process_date,
        x_phone,
        x_language,
        x_remarks,
        pgm_notify2pgm_enroll,
        pgm_notify2pgm_objid,
        pgm_notify2contact_objid,
        pgm_notify2web_user
      )
      VALUES
      (
        billing_seq ('X_PROGRAM_NOTIFY'),
        in_esn,
        lv_program_name,
        lv_enr_status,
        lv_program_name,
        'PENDING', --x_notify_status,
        lv_sourcesystem,
        sysdate, --x_process_date
        NULL,    --x_phone
        lv_language,
        in_suspend_reason,
        in_pgm_enroll_objid,
        lv_pgm_enroll2pgm_group,
        lv_pgm_enroll2contact,
        lv_pgm_enroll2web_user
      );
    BEGIN
      SELECT first_name ,
        last_name
      INTO lv_first_name,
        lv_last_name
      FROM table_contact
      WHERE objid =
        (SELECT web_user2contact
        FROM table_web_user
        WHERE objid = lv_pgm_enroll2web_user
        );
    EXCEPTION
    WHEN no_data_found THEN
      NULL;
      --DBMS_OUTPUT.PUT_LINE ('ASsuming table_contact.first_name last_name as null since ' || 'no data found in table_contact correspodning to table_web_user.objid=' ||lv_pgm_enroll2web_user);
    WHEN OTHERS THEN
      --DBMS_OUTPUT.PUT_LINE ('exception while fetching table_contact data...ERR='||SUBSTR(sqlerrm, 1, 100));
      sa.OTA_UTIL_PKG.ERR_LOG ( 'P_SUSPEND_HPP_ENROLLMENT', SYSDATE, NULL, 'P_SUSPEND_HPP_ENROLLMENT', 'sqlcode='||SQLCODE ||', sqlerrm='||SUBSTR(sqlerrm,1,100) );
      RAISE;
    END;
    /*  Insert record into X_BILLING_LOG for logging purpose to display in agents screens */
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
        billing_seq ('X_BILLING_LOG'),
        'Program',
        'HPP Suspension',
        sysdate,
        in_suspend_reason,
        lv_program_name,
        billing_getnickname (in_esn),
        in_esn,
        'System',
        lv_first_name,
        lv_last_name,
        'System',
        lv_sourcesystem,
        lv_pgm_enroll2web_user
      );
    --DBMS_OUTPUT.PUT_LINE ('p_suspend_hpp_enrollment completed successfully');
  EXCEPTION
  WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE ('exception in p_suspend_hpp_enrollment...='||SUBSTR(sqlerrm,1,100));
    raise;
  END;
END P_SUSPEND_HPP_ENROLLMENT;
/* changes ENDS for CR22313 HPP Phase 2 */
/* changes STARTS for CR22313 HPP Phase 2 */
PROCEDURE P_CHECK_ZIPCODE_N_SUSPEND_HPP
  (
    in_esn            IN x_program_enrolled.x_esn%type,
    in_suspend_reason IN x_program_enrolled.x_reason%type DEFAULT NULL
  )
IS
  /*
  CR22313 HPP Phase 2 section 16
  25 Jun 2014
  vkashmire@tracfone.com
  Procedure P_CHECK_ZIPCODE_N_SUSPEND_HPP : verify whether or not the activation zipcode of input ESN
  is restricted for HPP enrollment
  Input paramaters
  in_esn :  ESN number for which to determines and suspends HPP enrollment
  in_suspend_reason : description for suspending the ESN
  This procedure gets invoked from multiple places as listed below
  Inside Upgrade_Job procedure,
 1) During the Upgrade_ESN activity (inside Upgrade_Esn cursor loop)
  2) During the Reactivation process (inside reactivation_esn cursor loop)
  3) During the Port In process (Inside P_Port_Case_Suspend_Hpp procedure )
  */
  lv_enrollment_objid sa.x_program_enrolled.objid%type;
  lv_para_objid sa.x_program_parameters.objid%type;
  lv_objid_sitepart sa.x_program_enrolled.pgm_enroll2site_part%type;
  lv_zipcode sa.table_site_part.x_zipcode%type;
  lv_count INTEGER;
  lv_reason_text sa.x_program_enrolled.x_reason%type;
BEGIN
  /* select enrollment-ObjID and tableSitePart objid for subsequent sqls */
  BEGIN
    SELECT x.pgm_enroll2site_part,
      para.objid,
      x.objid
    INTO lv_objid_sitepart,
      lv_para_objid,
      lv_enrollment_objid
    FROM sa.x_program_enrolled x ,
      sa.x_program_parameters para
    WHERE x.x_esn              = in_esn
    AND para.objid             = x.pgm_enroll2pgm_parameter
    AND para.x_prog_class      = 'WARRANTY'
    AND x.x_enrollment_status <> 'SUSPENDED';
  EXCEPTION
  WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE('ERROR !!! No Warranty enrollments for input ESN: '|| in_esn);
    NULL;
  END;
  /* select the activation zipcode */
  BEGIN
    SELECT x_zipcode
    INTO lv_zipcode
    FROM sa.table_site_part
    WHERE objid     = lv_objid_sitepart
    AND part_status = 'Active';
  EXCEPTION
  WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE('ERROR !!! Activation zipcode not found in table_site_part for input ESN: '|| in_esn);
    --raise_application_error(-20625, 'error in P_CHECK_ZIPCODE_N_SUSPEND_HPP...ERR='||sqlerrm);
    NULL;
  END;
  /* check whether activation zipcode is in restricted state or not
  restricted means the HPP is not available in that area
  */
  SELECT COUNT(1)
  INTO lv_count
  FROM sa.table_x_zip_code tzc,
    sa.x_mtm_pgm_restrict_state xprs
  WHERE tzc.x_zip              = lv_zipcode
  AND xprs.program_param_objid = lv_para_objid
  AND xprs.x_state             = tzc.x_state;
  /* if activation zipcode found in area where HPP is not available then suspend the enrollment */
  IF NVL(lv_count,0)      > 0 THEN
    IF in_suspend_reason IS NOT NULL THEN
      lv_reason_text     := in_suspend_reason;
    ELSE
      lv_reason_text := 'HPP Program has been suspended since its not available and not eligible at location mentioned by activation zipcode';
    END IF;
    p_suspend_hpp_enrollment(lv_enrollment_objid, in_esn, lv_reason_text, sysdate);
  END IF;
END P_CHECK_ZIPCODE_N_SUSPEND_HPP;
/* changes ends for CR22313 HPP Phase 2 */
/* --- CR22313 changes starts --- */
PROCEDURE P_SUSPEND_HPP_HAVING_NO_ACC(
    IN_DATE IN DATE )
IS
  /* CR22313 HPP Phase 2  - Section 18
  5-Jun-2014
  vkashmire@tracfone.com
  New procedure created : P_SUSPEND_HPP_HAVING_NO_ACC -
  check for handsets which are enrolled to program
  but removed from account for more than 'N' days
  and for all such handsets found, mark them suspended
  input
  in_date = the date after which records to be considered for suspension.
  usually this will be sysdate
  This procedure gets invoked from
  De_Enroll_Job procedure
  */
  CONST_ENROLL_NO_ACCOUNT CONSTANT VARCHAR2(30) := 'ENROLLED_NO_ACCOUNT';
  lv_loop_count pls_integer ;
  lv_reason                      VARCHAR2(200);
  lv_enrolled_no_account_maxdays INTEGER;
  lv_error_msg x_program_error_log.x_error_msg%type;
  Lv_Error_Code X_Program_Error_Log.X_Error_Code%Type;
  --lv_first_name           table_contact.first_name%type;
  --lv_last_name            table_contact.last_name%type;
  CURSOR CUR_ESN_ENROLL_NO_ACCOUNT
  IS
    SELECT ENR.OBJID,
      enr.x_enrollment_status,
      enr.X_EXP_DATE,
      enr.X_ESN,
      enr.x_sourcesystem,
      enr.x_cooling_period,
      enr.pgm_enroll2web_user,
      enr.pgm_enroll2part_inst,
      enr.x_language,
      enr.pgm_enroll2contact,
      enr.pgm_enroll2pgm_group,
      para.x_program_name
    FROM x_program_enrolled enr,
      x_program_parameters para
    WHERE ( enr.x_enrollment_status = const_enroll_no_account )
    AND ( para.objid                = enr.pgm_enroll2pgm_parameter )
    AND ( para.x_prog_class         = 'WARRANTY' )
    AND EXISTS
      (SELECT 1
      FROM X_PROGRAM_TRANS B
      WHERE b.pgm_tran2pgm_entrolled                             = enr.objid
      AND b.x_enrollment_status                                  = const_enroll_no_account
      AND B.X_TRANS_DATE + NVL(lv_Enrolled_No_Account_maxdays,0) < IN_DATE
      );
BEGIN
  BEGIN
    SELECT NVL(to_number(x_param_value),0)
    INTO lv_Enrolled_No_Account_maxdays
    FROM table_x_parameters
    WHERE X_Param_Name='ENROLLED_NO_ACCOUNT_THRESHOLD_DAYS';
    --DBMS_OUTPUT.PUT_LINE ('lv_Enrolled_No_Account_maxdays = '||lv_Enrolled_No_Account_maxdays);
  EXCEPTION
  WHEN No_Data_Found THEN
    lv_enrolled_no_account_maxdays := 0;
    --DBMS_OUTPUT.PUT_LINE ('Value for ENROLLED_NO_ACCOUNT_THRESHOLD_DAYS Not Found in database...');
  END;
  lv_loop_count := 0;
  lv_reason     := 'ESN was suspended due to being in status: ' ||const_enroll_no_account ||' for more than ' || lv_enrolled_no_account_maxdays ||' days';
  FOR Enr_Rec IN Cur_Esn_Enroll_No_Account
  LOOP
    BEGIN
      p_suspend_hpp_enrollment (enr_rec.objid, enr_rec.x_esn, lv_reason, sysdate);
      lv_loop_count := lv_loop_count + 1;
    EXCEPTION
    WHEN OTHERS THEN
      lv_error_code := SQLCODE;
      lv_error_msg  := SUBSTR(sqlerrm, 1, 100);
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
          'P_SUSPEND_HPP_HAVING_NO_ACC',
          lv_error_code,
          lv_error_msg,
          sysdate,
          'Failed to update in database for ESN: '
          || enr_rec.x_esn,
          2
        );
    END;
  END LOOP;
  --DBMS_OUTPUT.PUT_LINE ('P_SUSPEND_HPP_HAVING_NO_ACC LOOP run count='|| lv_loop_count );
END P_SUSPEND_HPP_HAVING_NO_ACC;
/* --- CR22313 changes ends --- */
/* CR29489 changes starts  */
PROCEDURE p_brk_esn_relations_hppbyop
  (
    ip_rundate IN DATE
  )
IS
  /* ************
  HPP BYOP CR 29489
  vkashmire@tracfone.com
  19 aug 2014
  new procedure created: p_brk_esn_relations_hppbyop : to remove the link between pseudo-ean and real-ean
  When the BYOP warranty program expires then remove the link between pseudo-esn and real-esn
  This procedure MUST BE RUN EVERYDAY ONLY AFTER DE_ENROLL_JOB is finished
  *********** */
  CURSOR cur_hppbyop_enrollments (ip_cur_rundate IN DATE)
  IS
    SELECT enr.x_esn
      --enr.objid,
      --enr.x_exp_date,
      --enr.x_next_charge_date,
      --pp.x_program_name,
      --pp.x_program_desc
    FROM sa.x_program_enrolled enr ,
      sa.x_program_parameters pp ,
      sa.table_part_inst pi ,
      sa.table_mod_level ml ,
      sa.table_part_num pn ,
      sa.table_x_part_class_params para ,
      sa.table_x_part_class_values vv
    WHERE ( enr.pgm_enroll2pgm_parameter = pp.objid )
    AND ( pp.x_prog_class                = 'WARRANTY' )
    AND ( enr.x_exp_date                 = ip_cur_rundate )
    AND ( enr.x_enrollment_status        = 'DEENROLLED' )
    AND ( enr.pgm_enroll2part_inst       = pi.objid )
    AND ( pi.n_part_inst2part_mod        = ml.objid )
    AND ( ml.part_info2part_num          = pn.objid )
    AND ( pn.part_num2part_class         = vv.value2part_class )
    AND ( vv.value2class_param           = para.objid )
    AND ( para.x_param_name              = 'DEVICE_TYPE' )
    AND ( vv.x_param_value               = 'BYOP' ) ;
type tab_byop_esns
IS
  TABLE OF cur_hppbyop_enrollments%rowtype INDEX BY pls_integer;
  tab_esn tab_byop_esns;
  lv_limit_cur_records INTEGER := 100;
BEGIN
  --DBMS_OUTPUT.PUT_LINE('p_brk_esn_relations_hppbyop Started------------------');
  BEGIN
    OPEN cur_hppbyop_enrollments(TRUNC(ip_rundate));
    LOOP
      FETCH cur_hppbyop_enrollments bulk collect
      INTO tab_esn limit lv_limit_cur_records;
      EXIT
    WHEN tab_esn.count = 0;
      forall irec IN 1..tab_esn.count SAVE exceptions
      UPDATE sa.x_vas_subscriptions
      SET vas_name     = NULL ,
        x_real_esn     = NULL ,
        x_manufacturer = NULL ,
        x_model_number = NULL ,
        x_email        = NULL ,
        addl_info      = SUBSTR('realEsn:'
        || x_real_esn
        ||' link removed on '
        || TO_CHAR(sysdate, 'mmddrrrr hh24:mi'), 1, 50)
      WHERE ( vas_esn = tab_esn(irec).x_esn )
      AND ( vas_name  = 'HPP BYOP' ) ;
      /*AND ( x_real_esn IS NOT NULL );  removed since this column will always be null CR32396 */
    END LOOP;
    CLOSE cur_hppbyop_enrollments;
  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -24381 THEN
      /*FOR i     IN 1 .. sql%bulk_exceptions.count
      LOOP
        --DBMS_OUTPUT.PUT_LINE ( sql%bulk_exceptions (i).error_index || ', ' || sql%bulk_exceptions (i).error_code);
      END LOOP;*/
      NULL;
    ELSE
      raise_application_error (-20555, 'p_brk_esn_relations_hppbyop..ERR='||sqlerrm);
    END IF;
  END;
  --DBMS_OUTPUT.PUT_LINE('p_brk_esn_relations_hppbyop completed------------------');
END p_brk_esn_relations_hppbyop;
/* CR29489 changes ends */
PROCEDURE de_enroll_job(
    op_result OUT NUMBER,
    op_msg OUT VARCHAR2 )
  /******************************************************************************/
  /*    Copyright   2005 Tracfone  Wireless Inc. All rights reserved            */
  /*                                                                            */
  /* AUTHOR        SETTU GOPAL                                                 */
  /* NAME:         DE_enroll_job                                                */
  /*                                                                            */
  /* PURPOSE:      To find out validate De_enrolled                             */
  /*             get all the ESN are having the x_exp_date=sysdate              */
  /*             and update the same table column x_stauts, cooling_exp_date    */
  /*          and insert the record in to specified tables.                     */
  /*                                                                            */
  /* PLATFORMS:    Oracle 9i AND newer versions.                                */
  /*                                                                            */
  /* REVISIONS:                                                                 */
  /* VERSION  DATE        WHO          PURPOSE                                  */
  /* -------  ---------- -----  ---------------------------------------------   */
  /*  1.0     09/22/05    SL     Initial  Revision                               */
  /*                                                                            */
  /***********************************************************
  5-Jun-2014
  vkashmire@tracfone.com
  CR22313  HPP Phase-2 section 19
  When a customer cancels the Monthly enrolled program the program will get cancelled at next charge date.
  till that time the esn has status as DEENROLL_SCHEDULED
  and when the next_charge_date occures the esn should get de-enrolled from the program
  So for De-enrollment - this de-enroll job should consider ESNs having status DEENROLL_SCHEDULED
  ******************************************************************/
IS
  v_pgm_enrolled x_program_enrolled%ROWTYPE;
TYPE rc
IS
  REF
  CURSOR;
  TYPE rc1
IS
  REF
  CURSOR;
    v_rc1 rc1;
    v_rc rc;
    l_date DATE DEFAULT SYSDATE;
    l_program_name x_program_parameters.x_program_name%TYPE;
    l_first_name table_contact.first_name%TYPE;
    l_last_name table_contact.last_name%TYPE;

  l_program_parameters_rec    x_program_parameters%ROWTYPE; -- CR49058
  vpt                         vas_programs_type       :=  vas_programs_type(); -- CR49058
  BEGIN

    IF NOT v_rc%ISOPEN THEN
      /* CR 22313 changes starts */
      ---open v_rc FOR SELECT * FROM x_program_enrolled a WHERE ( TRUNC (x_exp_date) <= TRUNC (l_date) AND ( x_enrollment_status = 'SUSPENDED'
      -- Start modified by Rahul for CR38545
        OPEN v_rc FOR
        WITH t as (
        SELECT * FROM x_program_enrolled a WHERE ( TRUNC (x_exp_date) <= TRUNC (l_date) AND ( x_enrollment_status IN ('SUSPENDED', 'DEENROLL_SCHEDULED')
          /* CR 22313 changes ends */
          --- Status should be On-Hold
          OR ( EXISTS
            (SELECT 1--- Non-recurring program
            FROM x_program_parameters b
            WHERE a.pgm_enroll2pgm_parameter = b.objid
              /* CR29489 changes starts */
              --AND b.x_is_recurring             = 0
            AND ( (b.x_is_recurring = 0)
            OR (b.x_is_recurring    = 1
            AND b.x_prog_class      ='WARRANTY') )
              /* CR29489 changes starts */
            AND ( b.x_charge_frq_code IS NULL
            OR b.x_charge_frq_code    != 'PASTDUE' )
              -- Do not include PastDue programs changed
            ) AND x_enrollment_status = 'ENROLLED' ) ) )
        --CR43305 Exclude Simple Mobile
        AND NOT EXISTS
        (SELECT 1
         FROM   x_program_parameters xpp
         WHERE  xpp.objid = a.pgm_enroll2pgm_parameter
         AND    get_brm_applicable_flag(i_bus_org_objid => xpp.prog_param2bus_org,i_program_parameter_objid => xpp.objid ) = 'Y' )
        )
        SELECT * FROM t
        UNION
        SELECT pe.* FROM x_program_enrolled pe,x_program_parameters ppout
        where pe.x_esn    IN (SELECT DISTINCT x_esn FROM t,x_program_parameters ppin
        WHERE 1 = 1
        AND ppin.objid  = t.pgm_enroll2pgm_parameter
        AND ppin.x_prog_class = 'LIFELINE'
        )
        AND ppout.objid  = pe.pgm_enroll2pgm_parameter
        AND ppout.x_prog_class = 'HMO'
        AND UPPER (pe.x_enrollment_status) <> 'DEENROLLED'
        ;
        -- End modified by Rahul for CR38545
    END IF;
    LOOP
      FETCH v_rc INTO v_pgm_enrolled;
      EXIT
    WHEN v_rc%NOTFOUND;
      /* Review : Sharat: Commented.
      UPDATE x_program_enrolled
      SET x_enrollment_status = 'DEENROLLED',
      x_cooling_exp_date =   TRUNC (v_date)
      + 10
      WHERE (    TRUNC (x_exp_date) = TRUNC (v_date)
      AND UPPER (x_enrollment_status) = 'SUSPENDED'
      );
      */
      IF is_SB_esn( v_pgm_enrolled.objid, NULL) <> 1 THEN
        --CR8663
        INSERT
        INTO x_program_notify
          (
            objid,
            x_esn,
            x_program_name,
            x_program_status,
            x_notify_process,
            x_notify_status,
            x_source_system,
            x_process_date,
            x_phone,
            x_language,
            x_remarks,
            pgm_notify2pgm_objid,
            pgm_notify2contact_objid,
            pgm_notify2web_user,
            pgm_notify2pgm_enroll,
            x_message_name
          )
          VALUES
          (
            billing_seq ('X_PROGRAM_NOTIFY'),
            v_pgm_enrolled.x_esn,
            (SELECT x_program_name
            FROM x_program_parameters
            WHERE objid = v_pgm_enrolled.pgm_enroll2pgm_parameter
            ),
            'DEENROLLED',
            'DE_ENROLL_JOB',
            'PENDING',
            v_pgm_enrolled.x_sourcesystem ,
            SYSDATE,
            NULL,
            v_pgm_enrolled.x_language,
            NULL,
            v_pgm_enrolled.pgm_enroll2pgm_parameter,
            v_pgm_enrolled.pgm_enroll2contact ,
            v_pgm_enrolled.pgm_enroll2web_user,
            v_pgm_enrolled.objid,
            'Enrollment Cancellation'
          );
      END IF ; --CR8663
      -- CR49058 changes.. to retrieve vas program based on the
      vpt    :=  vas_programs_type ( i_program_param_id => v_pgm_enrolled.pgm_enroll2pgm_parameter);
      --
      UPDATE x_program_enrolled
      SET x_enrollment_status   = (CASE WHEN vpt.vas_service_id IS NOT NULL AND vpt.response = 'SUCCESS'
                                        THEN  'DEENROLLED'
                                        ELSE  'READYTOREENROLL' --CR38545
                                    END),-- CR49058 added case to set status as deeenrolled for VAS
          x_reason              = 'System Deenrollment',
          x_cooling_exp_date    = GREATEST ( l_date + x_cooling_period, NVL (x_cooling_exp_date, l_date) ),
          pgm_enroll2x_pymt_src = NULL,
          x_update_stamp        = l_date
          ,x_next_delivery_date    =    NULL    --CR38545 On request from Ramu
      WHERE objid             = v_pgm_enrolled.objid;
      --
      BEGIN
        -- Get the program name
        SELECT *
        INTO l_program_parameters_rec   -- CR49058 changed to retrieve entire row
        FROM x_program_parameters
        WHERE objid = v_pgm_enrolled.pgm_enroll2pgm_parameter;
      EXCEPTION
      WHEN OTHERS
      THEN
        l_program_parameters_rec := NULL;
      END;
      --
      -- CR49058 changes starts..
      -- call to update the status and expiry date in x_vas_subscription
      IF ( check_x_parameter ( p_v_x_param_name => 'NON_BASE_PROGRAM_CLASS',
                               p_v_x_param_value => l_program_parameters_rec.x_prog_class ) )
      THEN
        vas_management_pkg.p_update_vas_subscription ( i_esn                => v_pgm_enrolled.x_esn,
                                                       i_program_enroll_id  => v_pgm_enrolled.objid);
      END IF;
      -- CR49058 changes ends.
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
          x_esn,
          x_exp_date,
          x_cooling_exp_date,
          x_update_status,
          x_update_user,
          pgm_tran2pgm_entrolled,
          pgm_trans2web_user,
          pgm_trans2site_part
        )
        VALUES
        (
          billing_seq ('X_PROGRAM_TRANS'),
          'DEENROLLED',
          'Grace period given has expired',
          NULL,
          v_pgm_enrolled.x_cooling_period,
          NULL,
          l_date,
          'System DeEnrollment',
          'DE_ENROLL',
          l_program_parameters_rec.x_program_name
          || '  ',
          v_pgm_enrolled.x_sourcesystem,
          v_pgm_enrolled.x_esn,
          l_date,
          l_date,
          'I',
          'System',
          v_pgm_enrolled.objid,
          v_pgm_enrolled.pgm_enroll2web_user,
          v_pgm_enrolled.pgm_enroll2part_inst
        );
      --Changed x_notify_status PENDING from NULL
      ----------------------------- Insert a log into the billing table --------------------------------------
      --------------------------------------------------------------------------------------------------
      ---------------- Get the contact details for logging ---------------------------------------------
      --
      -- Start CR13082 Kacosta 01/24/2011
      --SELECT first_name,
      --   last_name
      --INTO l_first_name, l_last_name
      --FROM table_contact
      --WHERE objid = (
      --SELECT web_user2contact
      --FROM table_web_user
      --WHERE objid = v_pgm_enrolled.pgm_enroll2web_user);
      BEGIN
        --
        SELECT regexp_replace(first_name, '[^0-9 A-Za-z]', '') ,
          regexp_replace(last_name, '[^0-9 A-Za-z]', '')
        INTO l_first_name ,
          l_last_name
        FROM table_contact
        WHERE objid =
          (SELECT web_user2contact
          FROM table_web_user
          WHERE objid = v_pgm_enrolled.pgm_enroll2web_user
          );
        --
      EXCEPTION
      WHEN no_data_found THEN
        --
        NULL;
        --
      WHEN OTHERS THEN
        --
        RAISE;
        --
     END;
      -- End CR13082 Kacosta 01/24/2011
      --
      ---------------- Insert a billing Log ------------------------------------------------------------
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
          billing_seq ('X_BILLING_LOG'),
          'Program',
          'Program De-enrolled',
          SYSDATE,
          l_program_parameters_rec.x_program_name
          || '    Grace Period has expired',
          l_program_parameters_rec.x_program_name,
          billing_getnickname (v_pgm_enrolled.x_esn),
          v_pgm_enrolled.x_esn,
          'System',
          l_first_name,
          l_last_name,
          'System',
          v_pgm_enrolled.x_sourcesystem,
          v_pgm_enrolled.pgm_enroll2web_user
        );
      ---------------------------------------------------------------------------------------------------------
    END LOOP;
    COMMIT;
    CLOSE v_rc;
    --DBMS_OUTPUT.PUT_LINE ('Procedure executed successfully ');
    /* CR29489 changes starts */
    /* after de-enroll is completed; run the procedure to break link between pseudo-esn and real-esn */
    BEGIN
      --DBMS_OUTPUT.PUT_LINE ('*** P_BRK_ESN_RELATIONS_HPPBYOP Started on :' || TO_CHAR(sysdate,'dd-mon-yyyy hh24:mi:ss'));
      P_BRK_ESN_RELATIONS_HPPBYOP (l_date);
      COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20998, 'P_BRK_ESN_RELATIONS_HPPBYOP failed...ERR=' || sqlerrm);
    END;
    --DBMS_OUTPUT.PUT_LINE ('*** P_BRK_ESN_RELATIONS_HPPBYOP Completed on :' || TO_CHAR(sysdate,'dd-mon-yyyy hh24:mi:ss'));
    /* CR29489 changes ends */
  EXCEPTION
  WHEN OTHERS THEN
    global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
        'BILLING_JOB_PKG.de_enroll_job',
        -900,
        global_error_message,
        SYSDATE,
        'BILLING_JOB_PKG.de_enroll_job',
        2 -- MEDIUM
      );
    op_result := - 900;
    op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
    --DBMS_OUTPUT.PUT_LINE (op_msg);
  END de_enroll_job;
PROCEDURE minutes_delivery_job
  (
    op_result OUT NUMBER,
    op_msg OUT VARCHAR2
  )
IS
  v_pgm_enrolled x_program_enrolled%ROWTYPE;
TYPE rc
IS
  REF
  CURSOR;
    v_rc1 rc;
    c_user     VARCHAR2 (20);
    v_date     DATE DEFAULT SYSDATE;
    l_max_date CONSTANT DATE := '01-JAN-2099';
    l_delivery_frq_code x_program_parameters.x_delivery_frq_code%TYPE;

  BEGIN

    IF NOT v_rc1%ISOPEN THEN
      /* Open cursor variable. to select all the ESN who is delivery date expires today */
      /*  CR14801  CWL tuned this query
      -- CR12989 ST Retention Start PM -- CR13094 NET10MC
      OPEN v_rc1 FOR
      select *
      FROM x_program_enrolled pe
      WHERE NVL (x_next_delivery_date, l_max_date) <= v_date
      --TRUNC (NVL (x_next_delivery_date, l_max_date)) <= TRUNC (v_date) --Commented since the job is configured for running every hour.
      AND ( x_enrollment_status = 'ENROLLED'
      OR ( x_enrollment_status = 'DEENROLLED'
      and X_TOT_GRACE_PERIOD_GIVEN = 1 ) ) -- DeEnrollment scheduled case.
      and  not exists ( select '1'
      from    TABLE_PART_INST PI
      where   PI.PART_TO_ESN2PART_INST = PE.PGM_ENROLL2PART_INST
      and     PI.X_DOMAIN              = 'REDEMPTION CARDS'
      AND     PI.X_PART_INST_STATUS    = '400' );
      -- CR12989 ST Retention End PM -- CR13094 NET10MC
      */
      -- CR14801 STARTS
      OPEN V_RC1 FOR SELECT
      /*+ ORDERED_PREDICATES */
      * FROM X_PROGRAM_ENROLLED PE WHERE NVL
      (
        x_next_delivery_date, l_max_date
      )
      <= v_date AND ( X_ENROLLMENT_STATUS = 'ENROLLED' OR ( X_ENROLLMENT_STATUS = 'DEENROLLED' AND X_TOT_GRACE_PERIOD_GIVEN = 1 ) ) AND NOT EXISTS
      (SELECT '1'
        FROM TABLE_PART_INST PI
        WHERE PI.PART_TO_ESN2PART_INST = PE.PGM_ENROLL2PART_INST
        AND PI.X_DOMAIN
          ||'' = 'REDEMPTION CARDS'
        AND PI.X_PART_INST_STATUS
          ||'' = '400'
      )
      --CR43305 Exclude Simple Mobile
      AND NOT EXISTS
      (SELECT 1
       FROM   x_program_parameters xpp
       WHERE  xpp.objid = pe.pgm_enroll2pgm_parameter
       AND    get_brm_applicable_flag(i_bus_org_objid => xpp.prog_param2bus_org,i_program_parameter_objid => xpp.objid ) = 'Y' );
    -- CR14801 ENDS
    -- Pick up all the past deliveries as well.
  END IF;
  LOOP
    FETCH v_rc1 INTO v_pgm_enrolled;
    EXIT
  WHEN v_rc1%NOTFOUND;
    ------- In case of pre-payment, X_SERVICE_DELIVERY_DATE will be set at cycle date.
    IF (TRUNC (v_pgm_enrolled.x_service_delivery_date) = TRUNC (v_date) ) THEN
      --- Check for the delivery freq. If the delivery freq is 'AFTERCHARGE' then do not deliver benefits.
      SELECT x_delivery_frq_code
      INTO l_delivery_frq_code
      FROM x_program_parameters
      WHERE objid             = v_pgm_enrolled.pgm_enroll2pgm_parameter;
      IF (l_delivery_frq_code = 'AFTERCHARGE') THEN
        --- Do not deliver benefits, since the recon job will take care of this scenario
        NULL;
      ELSE
        billing_deliverbenefits (v_pgm_enrolled.objid, op_result, op_msg );
      END IF;
    ELSE
      billing_deliverbenefits (v_pgm_enrolled.objid, op_result, op_msg);
    END IF;
    COMMIT;
    -- Commit at individual levels so that any exceptions do not deny benefits to success records.
  END LOOP;
  CLOSE v_rc1;
  /* Always assume success. The delivery benefits procedure skips the delivery incase of ESN in Wait Period. */
  op_result := 0;
  op_msg    := 'Success';
EXCEPTION
WHEN OTHERS THEN
  global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
      'BILLING_JOB_PKG.minutes_delivery_job',
      -900,
      global_error_message,
      SYSDATE,
      'BILLING_JOB_PKG.minutes_delivery_job',
      2 -- MEDIUM
    );
  op_result := - 900;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
END minutes_delivery_job;
FUNCTION set_new_exp_date
  (
    p_esn          IN VARCHAR2,
    p_enroll_objid IN NUMBER
  )
  RETURN BOOLEAN
IS
  l_exp_date   DATE;
  l_float      NUMBER;
  l_sysdate    DATE DEFAULT SYSDATE;
  new_exp_date DATE;
  l_site_objid NUMBER;
  l_pymt_type x_payment_source.x_pymt_type%TYPE;
  l_service_days_given NUMBER;
  l_charge_frq_code x_program_parameters.x_charge_frq_code%TYPE;
  /* additional functionality:
  If this is a deactivation protection program set the next_charge_date to null
  */
BEGIN
  BEGIN
    SELECT x_expire_dt,
      objid
    INTO l_exp_date,
      l_site_objid
    FROM table_site_part
    WHERE x_service_id IN (p_esn)
    AND part_status     = 'Active';
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
  WHEN OTHERS THEN
    global_error_message := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
        'BILLING_JOB_PKG.set_new_exp_date',
        -900,
        global_error_message,
        SYSDATE,
        'BILLING_JOB_PKG.set_new_exp_date',
        2 -- MEDIUM
      );
    RETURN false;
  END;
  BEGIN
    SELECT x_pymt_type
    INTO l_pymt_type
    FROM x_payment_source
    WHERE objid =
      (SELECT pgm_enroll2x_pymt_src
      FROM x_program_enrolled
      WHERE objid = p_enroll_objid
      );
    IF l_pymt_type = 'CREDITCARD' THEN
      SELECT x_ser_days_float_nonach,
        x_charge_frq_code
      INTO l_float,
        l_charge_frq_code
      FROM x_program_parameters
      WHERE objid =
        (SELECT pgm_enroll2pgm_parameter
        FROM x_program_enrolled
        WHERE objid = p_enroll_objid
        );
    ELSE
      SELECT x_ser_days_float_ach,
        x_charge_frq_code
      INTO l_float,
        l_charge_frq_code
      FROM x_program_parameters
      WHERE objid =
        (SELECT pgm_enroll2pgm_parameter
        FROM x_program_enrolled
        WHERE objid = p_enroll_objid
        );
      /* ACH Payment additional check
      if the float parameter is set to less than 5 days, then assume a min. of 5 days. */
      IF (l_float < 5) THEN
        l_float  := 5;
      END IF;
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
  END;
  /*
  select decode (c.x_pymt_type, 'CREDITCARD', a.x_ser_days_float_nonach,
  'ACH', a.x_ser_days_float_ach,
  0 )
  into l_float
  from   x_program_parameters a, x_program_enrolled b, x_payment_source c
  where  a.objid = b.pgm_enroll2pgm_parameter
  and    b.pgm_enroll2x_pymt_src = c.objid
  and    b.objid = p_enroll_objid;
  */
  /* -------- check if there were any service days given earlier ------------------------ */
  SELECT NVL (x_service_days, 0)
  INTO l_service_days_given
  FROM x_program_enrolled
  WHERE objid = p_enroll_objid;
  /* -------------------------------------------------------------------------------------- */
  --new_exp_date :=   l_sysdate + (l_float - l_service_days_given) ;
  new_exp_date  := l_sysdate + l_float;
  IF l_exp_date >= new_exp_date THEN
    NULL;
  ELSE
    UPDATE table_site_part
    SET x_expire_dt = new_exp_date
    WHERE objid     = l_site_objid;
    UPDATE table_part_inst
    SET warr_end_date     = new_exp_date
    WHERE part_serial_no IN (p_esn)
    AND part_status       = 'Active';
    --- Update the enrolled table with the number of days given as float.
    -- Use trunc function to truncate the number of days to avoid any datatype mismatches.
    --DBMS_OUTPUT.PUT_LINE ( 'New ' || new_exp_date || ', Old' || l_exp_date || ' , Float ' || l_float || ' Delta ' || TRUNC (new_exp_date -l_exp_date) );
    UPDATE x_program_enrolled
    SET x_service_days   = x_service_days + LEAST (l_float, TRUNC (new_exp_date - l_exp_date)),
      x_next_charge_date = DECODE (l_charge_frq_code, 'PASTDUE', NULL, x_next_charge_date ),
      x_update_stamp     = l_sysdate
    WHERE objid          = p_enroll_objid;
  END IF;
  RETURN TRUE;
END set_new_exp_date;
FUNCTION get_next_cycle_date(
    p_prog_param_objid   IN NUMBER,
    p_current_cycle_date IN DATE )
  RETURN DATE
IS
  l_next_cycle_date DATE;
BEGIN
  SELECT DECODE (x_charge_frq_code, 'MONTHLY', ADD_MONTHS ( p_current_cycle_date, 1), 'LOWBALANCE', NULL, 'PASTDUE', NULL, TRUNC (NVL (p_current_cycle_date, SYSDATE)) + TO_NUMBER (x_charge_frq_code) )
  INTO l_next_cycle_date
  FROM x_program_parameters
  WHERE objid = p_prog_param_objid;
  RETURN l_next_cycle_date;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END;
--STUL
FUNCTION ispaymentprocessingpending(
    p_objid IN x_program_enrolled.objid%TYPE )
  RETURN NUMBER
IS
  /* This procedure returns whether there are any pending transactions with the payment processor or not.
  0 - No pending transactions
  1 - There are pending transactions
  */
  /* Assumptions: Even if there is any pending transaction (irrespective of the cycle date),
  do not submit this request
  */
  l_count NUMBER;
  l_payment_status x_program_purch_hdr.x_status%TYPE;
  l_payment_type x_program_purch_hdr.x_payment_type%TYPE;
BEGIN
  -- Get the last payment made by this enrollment.
  -- Commented by Ramu ... CR6602
  /*
  select *
  into   l_payment_status, l_payment_type
  from (
  select x_status, x_payment_type
  from   x_program_purch_hdr z
  where  objid in (
  SELECT a.pgm_purch_dtl2prog_hdr
  FROM x_program_purch_dtl a, x_program_enrolled b
  WHERE a.pgm_purch_dtl2pgm_enrolled = b.objid
  AND a.PGM_PURCH_DTL2PENAL_PEND is null
  AND b.objid = p_objid
  AND b.x_enrolled_date <= z.x_rqst_date -- To Handle $0 enrollments 04/30/2007 Ramu
  )
  order by x_rqst_date desc
  ) where rownum < 2;
  */
  -- New Query by Ramu .. CR6602
  SELECT *
  INTO l_payment_status,
    l_payment_type
  FROM
    (SELECT a.x_status,
      a.x_payment_type
    FROM x_program_purch_hdr a,
      x_program_enrolled b,
      x_program_purch_dtl c
    WHERE 1                          = 1
    AND a.objid                      = c.pgm_purch_dtl2prog_hdr
    AND c.pgm_purch_dtl2pgm_enrolled = b.objid
    AND c.pgm_purch_dtl2penal_pend  IS NULL
    AND b.objid                      = p_objid
    AND b.x_enrolled_date           <= a.x_rqst_date
    ORDER BY x_rqst_date DESC
    )
  WHERE ROWNUM < 2;
  IF (l_payment_status IN ('ENROLLACHPENDING', 'RECURACHPENDING', 'PAYNOWACHPENDING', 'INCOMPLETE', 'SUBMITTED', 'RECURINCOMPLETE' ) ) THEN
    RETURN 1;
    -- Pending transactions are there.
  ELSIF ( ( l_payment_status = 'FAILED' OR l_payment_status = 'FAILPROCESSED' ) AND l_payment_type = 'RECURRING' ) THEN
    RETURN 1;
    -- Failed transactions exist. Do not submit this record again.
  ELSE
    RETURN 0;
   -- No pending or failed transactions. Go for recurring payments.
  END IF;
  /*
  SELECT COUNT (*)
  INTO l_count
  FROM x_program_purch_hdr
  WHERE x_status IN ('ENROLLACHPENDING',
  'RECURACHPENDING',
  'PAYNOWACHPENDING',
  'INCOMPLETE',
  'SUBMITTED',
  'RECURINCOMPLETE'
  )
  AND objid IN (SELECT a.pgm_purch_dtl2prog_hdr
  FROM x_program_purch_dtl a, x_program_enrolled b
  WHERE a.pgm_purch_dtl2pgm_enrolled = b.objid
  AND b.objid = p_objid);
  IF (l_count = 0)
  THEN
  RETURN 0; -- No pending transactions
  ELSE
  RETURN 1; -- Pending transactions are there.
  END IF;
  */
EXCEPTION
WHEN OTHERS THEN
  RETURN 0;
END; -- Function ISPAYMENTPROCESSINGPENDING
FUNCTION getpaymenttype(
    p_objid IN x_program_parameters.objid%TYPE )
  RETURN VARCHAR2
IS
  /* This procedure returns the type of payment we are trying to present. The types of payments are:
  1. RECURRING
  2. LOWBALANCE
  3. PASTDUE
  4. ENROLLMENT       ( handled real-time)
  5. PAYNOW           ( handled real-time)
  */
  l_payment_type VARCHAR2 (30);
BEGIN
  SELECT
    /*
    decode ( x_is_recurring, 1, 'RECURRING',
    decode( X_FIRST_DELIVERY_DATE_CODE,
    'PASTDUE','PASTDUE',
    'LOWBALANCE','LOWBALANCE',
    'NON-RECURRING')
    )
    */
    DECODE (x_is_recurring, 1, 'RECURRING', 'NON-RECURRING')
  INTO l_payment_type
  FROM x_program_parameters
  WHERE objid = p_objid;
  RETURN l_payment_type;
EXCEPTION
WHEN OTHERS THEN
  RETURN 'RECURRING';
  -- By Default assume RECURRING Payment
END; -- Function getPaymentType
/* This job runs in the background monitoring all the following activities taking place
in the system
1. Upgrade
2. Technology Exchange
3. Defective Exchange
4. Removal of Wait Period when moving to Activation/ReActivation
Logic:
1. Upgrade: Scan table_case for any upgrade records. Check if the old records has any
programs associated with it. If not, return from the procedure. If yes,
pick up the new ESN from x_stock_type column and transfer the programs to the new ESN.
2. Technology Exchange: Replacement ESN will be found in table_x_alt_esn and it is linked with table_case
3. Defective Exchange: Replacement ESN will be found in table_case and x_case_type = 'Warranty'
*/
/* CR22313 changes starts   */
FUNCTION F_VALIDATE_ACC_B4_HPP_TRANSFER(
    in_s_esn           VARCHAR2 ,
    in_t_esn           VARCHAR2 ,
    in_createmyaccount VARCHAR2 DEFAULT 'NO' ,
    out_webuser_objid OUT NUMBER )
  RETURN NUMBER
IS
  /* ----------------------
  CR22313 HPP Phase-2 requirements - Point 17
  13 Jun 2014
  Function: F_validate_acc_b4_hpp_transfer - validates whether HPP transfer can be done from source ESN to target ESN
  vkashmire@tracfone.com
  returns
  -1 = If target esn is not active
  -2 = if source esn dont have any web user objid
  -9 = if soruice esn or target esn is null
  0 = if validations succeeded
  2 = if new esn is added in myaccount
  4 = if new esn dont have any account and its not added in myaccount
  This procedure gets invoked from
  P_transfer_Hpp_From_Esn_To_Esn
  ---------------------
  */
  --l_error_code           NUMBER;
  l_error_message   VARCHAR2(255);
  l_s_webuser_objid NUMBER;
  l_t_webuser_objid NUMBER;
  l_s_contact_objid NUMBER;
  l_t_part_inst     NUMBER;
  l_s_contact_first_name table_contact.first_name%TYPE;
  l_s_contact_last_name table_contact.last_name%TYPE;
BEGIN
  IF in_s_esn IS NULL OR in_t_esn IS NULL THEN
    --DBMS_OUTPUT.PUT_LINE ('in_s_esn='||in_s_esn||', in_t_esn='||in_t_esn || '.  Source ESN or Target ESN cannot be null');
    RETURN -9;
  END IF;
  --DBMS_OUTPUT.PUT_LINE('validate_acc_b4_hpp_transfer...'|| 'in_s_esn='||in_s_esn ||', in_t_esn='|| in_t_esn );
  --retrieve source ESN details
  BEGIN
    --DBMS_OUTPUT.PUT_LINE('validate_acc_b4_hpp_transfer ' || ' Getting OLD ESN : ' || in_s_esn);
    SELECT a.objid ,
      a.web_user2contact
    INTO l_s_webuser_objid ,
      l_s_contact_objid
    FROM table_web_user a ,
      table_x_contact_part_inst b ,
      table_part_inst c ,
      table_mod_level d ,
      table_part_num e
    WHERE a.web_user2contact            = b.x_contact_part_inst2contact
    AND b.x_contact_part_inst2part_inst = c.objid
    AND d.objid                         = c.n_part_inst2part_mod
    AND d.part_info2part_num            = e.objid
    AND a.web_user2bus_org              = e.part_num2bus_org
    AND c.part_serial_no                = in_s_esn;
    --DBMS_OUTPUT.PUT_LINE('Old ESN data retrieved. ');
    out_webuser_objid := l_s_webuser_objid;
  EXCEPTION
  WHEN OTHERS THEN
    l_error_message := 'Source ESN not present in Myaccount !';
    --DBMS_OUTPUT.PUT_LINE(l_error_message || SQLERRM);
    BEGIN
      SELECT PGM_ENROLL2CONTACT,
        PGM_ENROLL2WEB_USER
      INTO l_s_contact_objid,
        l_s_webuser_objid
      FROM x_program_enrolled xx,
        x_program_parameters xp
      WHERE xx.x_esn                  = in_s_esn
      AND XX.PGM_ENROLL2PGM_PARAMETER = XP.OBJID
      AND xp.x_prog_class             = 'WARRANTY';
      out_webuser_objid              := l_s_webuser_objid;
    EXCEPTION
    WHEN OTHERS THEN
      l_error_message := 'failed to retrieve the source esn contact and webuser objid';
      --DBMS_OUTPUT.PUT_LINE(l_error_message || ', err='|| SQLERRM);
      INSERT
      INTO x_program_error_log
        (
          x_source ,
          x_error_code ,
          x_error_msg ,
          x_date ,
          x_description ,
          x_severity
        )
        VALUES
        (
          'f_validate_acc_b4_hpp_transfer' ,
          -2 ,
          'Failure retriving the s_esn contact and webuser objid. ERR='
          || l_error_message ,
          SYSDATE ,
          'ESN='
          || in_s_esn
          || ' transferring warranty to ESN='
          || in_t_esn ,
          1
        );
      RETURN -2;
    END;
  END;
  -----------------------------------------------------------------------------------------------
  --retrieve target ESN details
  BEGIN
    SELECT objid
    INTO l_t_part_inst
    FROM table_part_inst
    WHERE part_serial_no = in_t_esn
    AND part_status      = 'Active';
  EXCEPTION
  WHEN no_data_found THEN
    l_error_message := 'Target ESN [' || in_t_esn || ' ] not found or is not Active';
    --DBMS_OUTPUT.PUT_LINE(l_error_message || SQLERRM);
    RETURN -1;
  END;
  BEGIN
    SELECT a.objid
    INTO l_t_webuser_objid
    FROM table_web_user a ,
      table_x_contact_part_inst b ,
      table_part_inst c ,
      table_mod_level d ,
      table_part_num e
    WHERE a.web_user2contact            = b.x_contact_part_inst2contact
    AND b.x_contact_part_inst2part_inst = c.objid
    AND d.objid                         = c.n_part_inst2part_mod
    AND d.part_info2part_num            = e.objid
    AND a.web_user2bus_org              = e.part_num2bus_org
    AND c.part_serial_no                = in_t_esn;
    --DBMS_OUTPUT.PUT_LINE('Target ESN data retrieved. ');
  EXCEPTION
  WHEN no_data_found THEN
    --- target ESN does not exist in any account.
    --- Add this target ESN to MyAccount
    --DBMS_OUTPUT.PUT_LINE('target ESN is not present in MyAccount..add new esn in Myaccount?='||in_createmyaccount);
    IF (in_createmyaccount = 'YES') THEN
      -- ESN does not belong to any account. so create a new record in MyAccount.
      IF (l_s_contact_objid IS NOT NULL ) THEN
        INSERT
        INTO TABLE_X_CONTACT_PART_INST
          (
            objid ,
            x_contact_part_inst2contact ,
            x_contact_part_inst2part_inst
          )
          VALUES
          (
            seq('x_contact_part_inst') ,
            l_s_contact_objid ,
            l_t_part_inst
          );
        SELECT first_name ,
          last_name
        INTO l_s_contact_first_name ,
          l_s_contact_last_name
        FROM table_contact
        WHERE objid = l_s_contact_objid;
        INSERT
        INTO x_billing_log
          (
            objid ,
            x_log_category ,
            x_log_title ,
            x_log_date ,
            x_details ,
            x_nickname ,
            x_esn ,
            x_originator ,
            x_contact_first_name ,
            x_contact_last_name ,
            x_agent_name ,
            x_sourcesystem ,
            billing_log2web_user
          )
          VALUES
          (
            billing_seq('X_BILLING_LOG') ,
            'ESN' ,
            'ADD_ESN' ,
            SYSDATE ,
            'ESN '
            || in_t_esn
            || ' has been successfully added.' ,
            billing_getnickname(in_t_esn) ,
            in_s_esn ,
            'System' ,
            l_s_contact_first_name ,
            l_s_contact_last_name ,
            'System' ,
            'WEBCSR' ,
            l_s_webuser_objid
          );
        --DBMS_OUTPUT.PUT_LINE('As requested, New ESN has been added in MyAccount');
      END IF;
      RETURN 2;
    END IF;
    RETURN 4;
  END;
  /* For warranty program transfer, Do not validate whether old ESN and new ESN are in same account or not.
  IF (l_s_webuser_objid != l_t_webuser_objid) THEN
  -- ESN belongs to another account.
  SELECT first_name
  ,last_name
  INTO l_s_contact_first_name
  ,l_s_contact_last_name
  FROM table_contact
  WHERE objid = l_s_contact_objid;
  --- Log a message into the source account that the target ESN belongs to another account
  INSERT INTO x_billing_log
  (objid
  ,x_log_category
  ,x_log_title
  ,x_log_date
  ,x_details
  ,x_nickname
  ,x_esn
  ,x_originator
  ,x_contact_first_name
  ,x_contact_last_name
  ,x_agent_name
  ,x_sourcesystem
  ,billing_log2web_user)
  VALUES
  (billing_seq('X_BILLING_LOG')
  ,'ESN'
  ,'ADD_ESN'
  ,SYSDATE
  ,'ESN ' || in_t_esn || ' belongs to a different account.'
  ,billing_getnickname(in_s_esn)
  ,in_s_esn
  ,'System'
  ,l_s_contact_first_name
  ,l_s_contact_last_name
  ,'System'
  ,'WEBCSR'
  ,l_s_webuser_objid);
  -- ESN belongs to another account.
  SELECT first_name
  ,last_name
  INTO l_s_contact_first_name
  ,l_s_contact_last_name
  FROM table_contact
  WHERE objid = (SELECT web_user2contact
  FROM table_web_user
  WHERE objid = l_t_webuser_objid);
  --- Log a message into the target account that target ESN was attempted for HPP transfer
  INSERT INTO x_billing_log
  (objid
  ,x_log_category
  ,x_log_title
  ,x_log_date
  ,x_details
  ,x_nickname
  ,x_esn
  ,x_originator
  ,x_contact_first_name
  ,x_contact_last_name
  ,x_agent_name
  ,x_sourcesystem
  ,billing_log2web_user)
  VALUES
  (billing_seq('X_BILLING_LOG')
  ,'ESN'
  ,'ADD_ESN'
  ,SYSDATE
  ,'ESN ' || in_t_esn || ' was attempted for HPP transfer.'
  ,billing_getnickname(in_s_esn)
  ,in_s_esn
  ,'System'
  ,l_s_contact_first_name
  ,l_s_contact_last_name
  ,'System'
  ,'WEBCSR'
  ,l_t_webuser_objid);
  COMMIT;
  RETURN 3;
  -- ESN Belongs to another account
  END IF;
  */
  RETURN 0; -- ESN exists and belongs to same account.
EXCEPTION
WHEN OTHERS THEN
  l_error_message := SUBSTR(SQLERRM,1,100);
  --DBMS_OUTPUT.PUT_LINE(SQLERRM);
  sa.OTA_UTIL_PKG.ERR_LOG ( 'HPP Transfer', SYSDATE, NULL, 'f_validate_acc_b4_hpp_transfer', l_error_message);
  RETURN -100;
END f_validate_acc_b4_hpp_transfer;
/* CR22313 changes ends   */
/* CR22313 Changes starts  */
PROCEDURE P_VALIDATE_HPP_TRANSFER
  (
    In_Source_Esn         IN X_Program_Enrolled.X_Esn%Type,
    In_Target_Esn         IN X_Program_Enrolled.X_Esn%TYPE,
    In_Case_Creation_Date IN Table_Case.Creation_Time%Type,
    Out_Error_Code OUT INTEGER,
    Out_Error_Msg OUT VARCHAR2
  )
IS
  /*
  CR22313 HPP Phase 2  requirements - section 17
  13 Jun 2014
  vkashmire@tracfone.com
  procedure: P_Validate_Hpp_Transfer = validates whether the HPP can be transferred to new handset or not.
  input parameters
  in_source_esn = esn of old device being replaced
  in_target_esn = esn of new device which will get replaced
  In_Case_Creation_Date = date when the case was created
  output parameters
  if out_error_code = 0 then the HPP can be transferred
  if out_error_code <> 0 then HPP cannot be transferred
  out_error_msg = error details
  This procedure gets invoked from
  P_transfer_Hpp_From_Esn_To_Esn
  */
  lv_enr_objid x_program_enrolled.objid%type;
  lv_hpp_plan_name x_program_parameters.x_program_name%TYPE;
  Lv_Enroll_Date X_Program_Enrolled.X_Enrolled_Date%TYPE;
  lv_transfer_count              INTEGER;
  lv_hpp_transfer_threshold_days INTEGER;
  lv_target_esn_eligible_hpp x_program_parameters.objid%type;
  lv_source_esn_enrolled_hpp x_program_parameters.objid%type;
  /*
  0 = success ; can transfer HPP to target esn from source esn
  -9 =  source esn / target esn can not be null
  -4 = 'HPP CAN NOT be transferred after '|| Lv_Hpp_Transfer_Threshold_Days || ' days the case is created';
  -8 = No HPP found for source esn
  -1 = This plan DOES NOT allow to transfer HPP more than once in first 12 months from date of enrollment';
  -2 = 'This plan DOES NOT allow to transfer HPP to new ESN after 12 months from date of enrollment';
  -3 = 'This plan Never allows to transfer enrollment to new ESN';
  -5 = 'This plan DOES NOT allow to transfer HPP for third time within a period of 12 months';
  -7 = 'Transfer not allowed for HPP' || lv_hpp_plan_name
  -11 = 'Target ESN is not eligible to enroll in HPP : ' || lv_hpp_plan_name;
  */
BEGIN
  --DBMS_OUTPUT.PUT_LINE ('HPP validations started - P_Validate_Hpp_Transfer');
  BEGIN
    IF In_Source_Esn IS NULL OR In_Target_Esn IS NULL THEN
      --DBMS_OUTPUT.PUT_LINE ('In_Source_Esn='||In_Source_Esn||', In_Target_Esn='||In_Target_Esn);
      Out_Error_Code := -9;
      Out_Error_Msg  := 'Source esn or Target esn cannot be null';
      RETURN;
    END IF;
  END;
  --check when was the case created
  BEGIN
    SELECT NVL(to_number(x_param_value),0 )
    INTO lv_hpp_transfer_threshold_days
    FROM sa.table_x_parameters
    WHERE X_PARAM_NAME='HPP_TRANSFER_THRESHOLD_DAYS';
    --DBMS_OUTPUT.PUT_LINE ('hpp_transfer_threshold_days found in database as = '|| lv_hpp_transfer_threshold_days);
  EXCEPTION
  WHEN No_Data_Found THEN
    lv_hpp_transfer_threshold_days := NULL;
    --DBMS_OUTPUT.PUT_LINE ('hpp_transfer_threshold_days Not found in database');
  END;
  IF (SYSDATE < In_Case_Creation_Date + Lv_Hpp_Transfer_Threshold_Days) THEN
    NULL;
  ELSE
    out_error_code := -4;
    Out_Error_Msg  := 'HPP CAN NOT be transferred after ' || Lv_Hpp_Transfer_Threshold_Days || ' days the case is created';
    RETURN;
  END IF;
  --select the HPP plan for the source esn
  BEGIN
    SELECT para.x_program_name,
      prg.x_enrolled_date,
      prg.objid,
      para.objid
    INTO lv_hpp_plan_name,
      lv_enroll_date,
      lv_enr_objid,
      lv_source_esn_enrolled_hpp
    FROM sa.x_program_parameters para,
      sa.x_program_enrolled prg
    WHERE para.objid        = prg.pgm_enroll2pgm_parameter
    AND Prg.X_Esn           = In_Source_Esn
    AND para.x_is_recurring = 1
    AND Para.X_Prog_Class   = 'WARRANTY';
  EXCEPTION
  WHEN No_Data_Found THEN
    Out_Error_Code := -8;
    Out_Error_Msg  := 'No HPP found for source esn = ' || In_Source_Esn;
    RETURN;
  END;
  IF (lv_hpp_plan_name = 'Exchange Annual') THEN
    /*Easy exchange Plan*/
    IF (SYSDATE < ADD_MONTHS(lv_enroll_date, 12) ) THEN
      /* check how many transfers have been made; only 1 transfer is allowed in this plan */
      SELECT COUNT(1)
      INTO lv_transfer_count
      FROM sa.X_Program_Transfers Tr
      WHERE Tr.Pgm_Transfer2_Pgm_Enrolled = Lv_Enr_Objid
      AND tr.X_Prog_Class                 = 'WARRANTY';
      IF NVL(lv_transfer_count,0)         < 1 THEN
        out_error_code                   := 0;
        out_error_msg                    := 'TRANSFER HPP';
      ELSE
        out_error_code := -1;
        out_error_msg  := 'This plan DOES NOT allow to transfer HPP more than once in first 12 months from date of enrollment';
      END IF;
    ELSE
      Out_Error_Code := -2;
      out_error_msg  := 'This plan DOES NOT allow to transfer HPP to new ESN after 12 months from date of enrollment';
    END IF;
  elsif (lv_hpp_plan_name = 'Plus - Annual') THEN
    /* Easy exchange plus (Annual) */
    /* In this plan, handset can be replaced but HPP doesn't get transferred */
    out_error_code       := -3;
    out_error_msg        := 'This plan Never allows to transfer enrollment to new ESN';
  elsif (lv_hpp_plan_name = 'Plus - Monthly') THEN
    /*Easy exchange plus (Monthly) */
    /* check how many transfers have been made */
    SELECT COUNT(1)
    INTO lv_transfer_count
    FROM sa.x_program_transfers tr
    WHERE Tr.Pgm_Transfer2_Pgm_Enrolled = Lv_Enr_Objid
    AND tr.X_Prog_Class                 = 'WARRANTY'
    AND tr.x_transfer_date BETWEEN add_months (SYSDATE, -12) AND SYSDATE;
    IF NVL(lv_transfer_count,0) < 2 THEN
      out_error_code           := 0;
      out_error_msg            := 'TRANSFER HPP';
    ELSE
      out_error_code := -5;
      out_error_msg  := 'This plan DOES NOT allow to transfer HPP for third time within a period of 12 months';
    END IF;
  ELSE
    /* here this might be HPP BYOP - and it cannot be transfered to new handset */
    out_error_code := -7;
    out_error_msg  := 'The HPP : ' || lv_hpp_plan_name || ' DOES NOT allow to transfer from one ESN to another ESN';
  END IF;
  IF Out_Error_Code = 0 THEN
    /* verify whether target ESN can be enrolled to same warranty program the old esn has enrolled
   since the source esn and target esn can fall under different tiers based on their price,
    */
    BEGIN
      SELECT PROG_ID
      INTO lv_target_esn_eligible_hpp
      FROM TABLE(sa.value_addedprg.geteligiblewtyprograms(In_Target_Esn))
      WHERE X_PROGRAM_NAME = lv_hpp_plan_name ;
    EXCEPTION
    WHEN OTHERS THEN
      lv_target_esn_eligible_hpp := 0;
    END;
    IF NVL(lv_target_esn_eligible_hpp, 0) = lv_source_esn_enrolled_hpp THEN
      out_error_code                     := 0;
    ELSE
      out_error_code := -11;
      out_error_msg  := 'Target ESN is not eligible to enroll in HPP : ' || lv_hpp_plan_name;
    END IF;
  END IF;
  IF Out_Error_Code = 0 THEN
    /* all validations are through and now its ready to transfer hpp */
    INSERT
    INTO sa.x_program_transfers
      (
        pgm_transfer2_pgm_enrolled ,
        X_Old_Esn ,
        X_New_Esn ,
        X_Prog_Class ,
        X_Transfer_Date ,
        X_Transfer_Reason
      )
      VALUES
      (
        Lv_Enr_Objid,
        In_Source_Esn,
        In_Target_Esn,
        'WARRANTY',
        SYSDATE,
        'WARRANTY Transfer: '
        || lv_hpp_plan_name
      );
    Out_Error_Msg := 'TRANSFER HPP';
  END IF;
  --DBMS_OUTPUT.PUT_LINE ('HPP validations completed - P_Validate_Hpp_Transfer; out_error_code='||out_error_code);
END P_VALIDATE_HPP_TRANSFER;
/* CR22313 changes ends  */
/* CR22313 changes starts  */
PROCEDURE P_TRANSFER_HPP_FROM_ESN_TO_ESN
  (
    In_Job_Objid IN NUMBER ,
    out_error_code OUT NUMBER ,
    out_error_message OUT VARCHAR2
  )
IS
  /*
  CR22313 HPP Phase 2 Section 17
  3 jun   2014
  vkashmire@tracfone.com
  PROCEDURE P_TRANSFER_HPP_FROM_ESN_TO_ESN
  This procedure validates the HPP transfer cases
  and if eligible transfer the HPP enrollment from old ESN to new ESN
  This procedure gets invoked from
  Upgrade_Job procedure
  */
  lv_pgm_upgrade_Objid X_PROGRAM_UPGRADE.OBJID%TYPE;
  lv_hpp_transfer_count INTEGER := 0;
  lv_success_count pls_integer  := 0;
  -- Cursor: Cur_HPP_transfer_esn : fetch all 'Handset Program' that have taken place from a specified date till today.
  CURSOR Cur_HPP_transfer_esn (c_run_date IN DATE)
  IS
    SELECT a.objid,
      a.x_esn,
      a.creation_time,
      b.x_value
    FROM table_x_case_detail b,
      table_case a
    WHERE 1 = 1
    AND EXISTS
      (SELECT 1
      FROM table_site_part
      WHERE x_service_id IN (b.x_value)
      AND part_status
        || '' = 'Active'
      )
  AND b.x_name
    || '' LIKE ('NEW_ESN')
  AND (b.detail2case = a.objid + 0)
  AND NOT EXISTS
    (SELECT 1
    FROM x_program_upgrade
    WHERE pgm_upgrade2case = A.objid + 0
    AND x_status           = 'SUCCESS'
    AND X_TYPE             = 'HPP Transfer'
    )
  AND (a.creation_time >= c_run_date)
  AND (a.x_case_type
    || ''     = 'Handset Program'
  AND a.title = 'Handset Protection' )
    /*Handset Protection Plan*/
  AND EXISTS
    (SELECT 1
    FROM x_program_enrolled enr,
      x_program_parameters para
    WHERE enr.x_esn              = A.x_esn
    AND para.objid               = enr.PGM_ENROLL2PGM_PARAMETER
    AND para.x_is_recurring      = 1
    AND para.x_prog_class        = 'WARRANTY'
    AND enr.x_enrollment_status IN ('ENROLLED', 'SUSPENDED', 'ENROLLMENTSCHEDULED', 'DEENROLL_SCHEDULED')
    );
  Hpp_Rec Cur_Hpp_Transfer_Esn%Rowtype;
  Lv_Hpp_Error_Code   INTEGER;
  Lv_Hpp_Error_Msg    VARCHAR2(100);
  lv_start_time       DATE;
  lv_error            INTEGER;
  lv_s_web_user_objid NUMBER; -- Webuser Objid for the old ESN
  Lv_Error_Message    VARCHAR2 (255);
  Lv_Job_Status       VARCHAR2 (50);
  lv_trans_error      NUMBER;
  --CR38927 safelink upgrade
  l_pe_objid x_program_enrolled.objid%TYPE;
  l_from_pgm_objid x_program_parameters.objid%TYPE;

BEGIN
  lv_start_time := SYSDATE-30;
  --DBMS_OUTPUT.PUT_LINE ('Getting all Handset Protection Programs from ' || lv_start_time);
  OPEN Cur_HPP_transfer_esn (TRUNC(lv_start_time));
  LOOP
    FETCH Cur_HPP_transfer_esn INTO hpp_rec;
    EXIT
  WHEN Cur_HPP_transfer_esn%NOTFOUND;
    lv_hpp_transfer_count := lv_hpp_transfer_count + 1;
    --insert a record in X_PROGRAM_UPGRADE to indicate the process has started
    lv_pgm_upgrade_Objid := billing_seq ('X_PROGRAM_UPGRADE');
    INSERT
    INTO x_program_upgrade
      (
        objid,
        x_esn,
        x_replacement_esn,
        x_type,
        x_date,
        x_status,
        pgm_upgrade2case,
        x_description
      )
      VALUES
      (
        lv_pgm_upgrade_Objid,
        hpp_rec.x_esn,
        hpp_rec.x_value,
        'HPP Transfer',
        SYSDATE,
        'INCOMPLETE',
        hpp_rec.objid,
        'Initiated the process : HPP Transfer from x_esn to x_replacement_esn'
      );
    --DBMS_OUTPUT.PUT_LINE ('x_program_upgrade.Objid='||lv_pgm_upgrade_Objid ||', record inserted in x_program_upgrade');
    /*-- Check if the ESNs can be transferred
    lv_error := billing_webcsr_pkg.validate_upgrade_account (hpp_rec.x_esn,
    hpp_rec.x_value,
    1,
    lv_s_web_user_objid);
    */
    lv_s_web_user_objid := NULL;
    lv_error            := F_VALIDATE_ACC_B4_HPP_TRANSFER (hpp_rec.x_esn, hpp_rec.x_value, 'YES', lv_s_web_user_objid);
    --DBMS_OUTPUT.PUT_LINE ('F_VALIDATE_ACC_B4_HPP_TRANSFER returns --- ' || lv_error);
    --DBMS_OUTPUT.PUT_LINE ('source esn webuser objid='|| lv_s_web_user_objid);
    IF lv_error IN (0,2,4) THEN
      -- check for HPP validations
      Lv_Hpp_Error_Code := NULL;
      Lv_Hpp_Error_Msg  := NULL;
      P_VALIDATE_HPP_TRANSFER(hpp_rec.x_esn, Hpp_Rec.X_Value, Hpp_Rec.Creation_time, Lv_Hpp_Error_Code, Lv_Hpp_Error_Msg );
      --DBMS_OUTPUT.PUT_LINE ('Lv_Hpp_Error_Code = ' || Lv_Hpp_Error_Code);
      sa.OTA_UTIL_PKG.ERR_LOG ( 'HPP Transfer', SYSDATE, NULL, 'P_VALIDATE_HPP_TRANSFER', 'code='||Lv_Hpp_Error_Code ||', msg='||Lv_Hpp_Error_Msg ||', lv_s_web_user_objid='|| lv_s_web_user_objid );
      IF Lv_Hpp_Error_Code = 0 THEN -- 0 means hpp transfer validation criterias succeeded
        --DBMS_OUTPUT.PUT_LINE ('invoking transfer_esn_prog_to_diff_esn..' || 'lv_s_web_user_objid = '|| lv_s_web_user_objid);
        lv_trans_error := NULL;
        billing_webcsr_pkg.transfer_esn_prog_to_diff_esn ( lv_s_web_user_objid, hpp_rec.x_esn, hpp_rec.x_value, 'System', l_pe_objid, l_from_pgm_objid, lv_trans_error, Lv_Error_Message, 'ALLOW_HPP_TRANSFER');
        IF (lv_trans_error = 0) THEN
          -- Success transferring the programs.
          --DBMS_OUTPUT.PUT_LINE ( 'Successfully transferred programs (HPP) from ' || hpp_rec.x_esn || ' to ' || hpp_rec.x_value);
          UPDATE x_program_upgrade
          SET x_status    = 'SUCCESS',
            x_description = 'Successfully transferred programs (HPP) from '
            || hpp_rec.x_esn
            || ' to '
            || hpp_rec.x_value
          WHERE objid       = lv_pgm_upgrade_Objid;
          lv_success_count := lv_success_count + 1;
        ELSE
          -- Failed to transfer the programs.
          --DBMS_OUTPUT.PUT_LINE ('Failed to transfer the programs(HPP) to new ESN..lv_trans_error='||lv_trans_error);
          UPDATE x_program_upgrade
          SET x_status    = 'FAILED',
            x_description = 'Failed to transfer the programs(HPP) to new ESN. lv_trans_error='
            ||lv_trans_error
            || ', Lv_Error_Message='
            ||Lv_Error_Message
            ||'.'
          WHERE objid = lv_pgm_upgrade_Objid;
        END IF;
        /*
        elsif Lv_Hpp_Error_Code in(-1, -2, -3, -4, -5, -8) THEN
        --DBMS_OUTPUT.PUT_LINE ('HPP transfer Validations succeeded but CAN NOT transfer HPP..Lv_Hpp_Error_Code='
        ||Lv_Hpp_Error_Code);
        UPDATE x_program_upgrade
        SET x_status        = 'SUCCESS',
        x_description    = Lv_Hpp_Error_Code || ' ' || Lv_Hpp_Error_Msg
       WHERE objid = lv_pgm_upgrade_Objid;
        elsif Lv_Hpp_Error_Code in (-11) then
        --DBMS_OUTPUT.PUT_LINE ('target ESN is not eligible for same HPP as Old ESN ..Lv_Hpp_Error_Code=' || Lv_Hpp_Error_Code);
        UPDATE x_program_upgrade
        SET x_status        = 'SUCCESS',
        x_description    = Lv_Hpp_Error_Code || ' ' || Lv_Hpp_Error_Msg
        WHERE objid = lv_pgm_upgrade_Objid;
        */
      ELSE
        --HPP transfer validations criterias failed
        --DBMS_OUTPUT.PUT_LINE ('HPP transfer Validations failed..Lv_Hpp_Error_Code=' ||Lv_Hpp_Error_Code ||' err-msg='|| SUBSTR(Lv_Hpp_Error_Msg,1,150));
        UPDATE x_program_upgrade
        SET x_status    = 'FAILED',
          X_Description = 's_ESN '
          || Hpp_Rec.X_Esn
          || '. HPP transfer failed.'
          || 'Lv_Hpp_Error_Code='
          ||Lv_Hpp_Error_Code
          ||', ERR='
          || SUBSTR(Lv_Hpp_Error_Msg,1,150)
        WHERE objid = lv_pgm_upgrade_Objid;
      END IF;
    ELSE
      --DBMS_OUTPUT.PUT_LINE ('billing_webcsr_pkg.validate_acc_b4_hpp_transfer returned error_code as  ' || lv_error);
      UPDATE x_program_upgrade
      SET x_status    = 'FAILED',
        x_description = 'Data Error. validate_acc_b4_hpp_transfer return as= '
        || lv_error
      WHERE objid = lv_pgm_upgrade_Objid;
    END IF;
    Lv_Job_Status := 'SUCCESS';
  END LOOP;
  CLOSE Cur_HPP_transfer_esn ;
  --DBMS_OUTPUT.PUT_LINE ('completed processing of all ESNs for HPP transfer. '|| 'Total records processed = '|| lv_hpp_transfer_count ||', lv_success_count='||lv_success_count ||', Lv_Job_Status='||Lv_Job_Status);
  IF (Lv_Job_Status = 'SUCCESS') THEN
    out_error_code := 0;
  ELSE
    out_error_code := -1;
  END IF;
  ----------------------- Mark the Job status as success. ---------------------------------------
  --consider all program upgrade failures as Job Success only.
  UPDATE x_job_run_details
  SET x_status = 'SUCCESS',
    x_end_time = SYSDATE
  WHERE objid  = in_Job_ObjID;
  sa.OTA_UTIL_PKG.ERR_LOG ( 'HPP Transfer', SYSDATE, NULL, 'P_TRANSFER_HPP_FROM_ESN_TO_ESN', 'completed processing of all ESNs for HPP transfer. '|| 'Total records processed = '|| lv_hpp_transfer_count ||', HPP transferred='||lv_success_count ||', Lv_Job_Status='||Lv_Job_Status );
END P_TRANSFER_HPP_FROM_ESN_TO_ESN;
/* CR22313 HPP Phase-2 changes ends  */
/* CR22313 changes starts */
PROCEDURE P_PORT_CASE_SUSPEND_HPP
IS
  /*
  CR22313 HPP Phase 2 requirement section 16
  24 Jun 2014
  vkashmire@tracfone.com
  PROCEDURE P_PORT_CASE_SUSPEND_HPP :  created For all the port in cases, check for activation zipcode and
  for that activation zipcode if HPP is  not available then suspend the enrollment
  This procedure gets invoked from
  Upgrade_Job procedure
  */
  CURSOR cur_port_cases
  IS
    SELECT a.x_case_type,
      a.title,
      a.x_esn
      --param.objid as param_objid,
      --enr.objid as enr_objid
    FROM table_case a,
      table_site_part tsp,
      x_program_enrolled enr,
      x_program_parameters param
    WHERE 1               = 1
    AND (a.creation_time >= TRUNC (sysdate - 3))
    AND (tsp.x_service_id = a.x_esn)
    AND (tsp.part_status
      || '' = 'Active')
    AND (a.x_case_type
      ||''                       = 'Port In')
    AND (enr.x_esn               = a.x_esn)
    AND (param.objid             = enr.pgm_enroll2pgm_parameter)
    AND (param.x_prog_class      = 'WARRANTY')
    AND enr.x_enrollment_status IN ('ENROLLED', 'ENROLLMENTSCHEDULED', 'ENROLLMENTPENDING', 'ENROLLED_NO_ACCOUNT', 'DEENROLL_SCHEDULED') ;
  port_rec cur_port_cases%rowtype;
  lv_retval INTEGER;
  lv_text x_program_enrolled.x_reason%type;
BEGIN
  lv_text := 'During Port In case, HPP Program has been suspended since its not available' ||'and not eligible at activation zipcode';
  FOR port_rec IN cur_port_cases
  LOOP
    P_CHECK_ZIPCODE_N_SUSPEND_HPP (port_rec.x_esn, lv_text);
  END LOOP;
END P_PORT_CASE_SUSPEND_HPP ;
/* CR22313 HPP Phase 2 changes Ends */

PROCEDURE upgrade_job(
    op_result OUT NUMBER,
    op_msg OUT VARCHAR2 )
IS
  /*
  CR22313     HPP phase-2      6-Jun-2014      vkashmire
  procedure Upgrade_Job: modified to invoke a new procedure (p_transfer_hpp_from_esn_to_esn)
  which handles HPP transfer from one esn to another esn
  */
  job_master_id   NUMBER := 300;
  l_job_run_objid NUMBER;
  -- Cursor that fetches all the upgrades that have taken place.
  CURSOR upgrade_esn( c_run_date IN DATE )
  IS
    SELECT a.* ,
      b.x_value,
     (select b1.x_value
         from table_x_case_detail b1
        where b1.detail2case = b.detail2case and b1.x_name||'' ='LIFELINE_LID'
        and b1.detail2case = a.objid) LIFELINE_LID
    FROM table_x_case_detail b,
      table_case a
    WHERE 1 = 1
    AND EXISTS
      (SELECT 1
      FROM table_site_part
      WHERE x_service_id IN (b.x_value)
      AND part_status
        || '' = 'Active'
      )
  AND b.x_name
    || '' LIKE ('NEW_ESN')
  AND b.detail2case = a.objid + 0
  AND NOT EXISTS
    (SELECT 1
    FROM x_program_upgrade
    WHERE pgm_upgrade2case = a.objid + 0
    AND x_status           = 'SUCCESS'
    )
  AND a.creation_time >= TRUNC (SYSDATE) - (3)
  AND a.x_case_type
    || '' IN ('Phone Upgrade', 'Units')
  AND EXISTS
    (SELECT 1
    FROM x_program_enrolled
    WHERE x_esn              = a.x_esn
    AND x_enrollment_status IN ('ENROLLED', 'SUSPENDED', 'ENROLLMENTSCHEDULED', 'ENROLLMENTPENDING' )
    );
  --Ensure that the target ESN is active.
  upgrade_esn_rec upgrade_esn%ROWTYPE;
  --CR29633 RRS
  CURSOR upgrade_esn_port_in( c_run_date IN DATE)
  IS
    SELECT a.* ,
      b.x_value,
      (select b1.x_value
         from table_x_case_detail b1
        where b1.detail2case = b.detail2case and b1.x_name||'' ='LIFELINE_LID'
        and b1.detail2case = a.objid) LIFELINE_LID
    FROM table_x_case_detail b,
      table_case a
    WHERE creation_time >=TRUNC(sysdate)-(7)
    AND x_case_type      ='Port In'
    AND a.objid          =b.detail2case
    AND b.x_name        IN ('CURRENT_ESN')
    AND a.s_title NOT LIKE '%EXTERNAL%'
    AND a.s_title NOT LIKE '%CROSS%'
    AND a.x_esn <> b.x_value
    AND EXISTS
      (SELECT 1
      FROM table_part_inst
      WHERE part_serial_no   =a.x_esn
      AND x_part_inst_status = '52'
      ) -- Make sure new phone is Active
  AND EXISTS
    (SELECT 1 FROM table_part_inst WHERE part_serial_no=b.x_value
    ) -- make sure ESN is not External
  AND NOT EXISTS
    (SELECT 1
    FROM x_program_upgrade
    WHERE pgm_upgrade2case = a.objid + 0
    AND x_status           = 'SUCCESS'
    ) -- Make sure Upgrade job did not picked up yet
  AND EXISTS
    (SELECT 1
    FROM x_program_enrolled pe,
      x_program_parameters pp
    WHERE pe.pgm_enroll2pgm_parameter=pp.objid
    AND NVL(pp.x_prog_class, 'X')   <> 'WARRANTY'
    AND pe.x_esn                     = b.x_value
    AND pe.x_enrollment_status      IN ('ENROLLED','SUSPENDED', 'ENROLLMENTSCHEDULED','ENROLLMENTPENDING')
    AND PP.PROG_PARAM2BUS_ORG        =
      (SELECT PN.PART_NUM2BUS_ORG
      FROM table_part_inst pi,
        table_mod_level ml,
        table_part_num pn
      WHERE 1                    =1
      AND pi.part_serial_no      =a.x_esn
      AND PI.N_PART_INST2PART_MOD=ml.objid
      AND ML.PART_INFO2PART_NUM  =pn.objid
      )
    );
  upgrade_esn_port_in_rec upgrade_esn_port_in%ROWTYPE;
  ---
  -- Cursor that fetches all the 'Defective Exchanges' that have taken place.
  CURSOR defective_exhange_esn( c_run_date IN DATE )
  IS
    SELECT a.* ,
      b.x_value
    FROM table_x_case_detail b,
      table_case a
    WHERE 1 = 1
    AND EXISTS
      (SELECT 1
      FROM table_site_part
      WHERE x_service_id IN (b.x_value)
      AND part_status
        || '' = 'Active'
      )
  AND b.x_name
    || '' LIKE ('NEW_ESN')
  AND b.detail2case = a.objid + 0
  AND NOT EXISTS
    (SELECT 1
    FROM x_program_upgrade
    WHERE pgm_upgrade2case = a.objid + 0
    AND x_status           = 'SUCCESS'
    )
  AND a.creation_time >= TRUNC (SYSDATE) - (3)
  AND a.x_case_type
    || '' = 'Warranty'
  AND EXISTS
    (SELECT 1
    FROM x_program_enrolled
    WHERE x_esn              = a.x_esn
    AND x_enrollment_status IN ('ENROLLED', 'SUSPENDED', 'ENROLLMENTSCHEDULED', 'ENROLLMENTPENDING' )
    );
  --Ensure that the target ESN is active.
  defective_exhange_esn_rec defective_exhange_esn%ROWTYPE;
  -- Cursor that fetches all the Technology exchanges that have taken place.
  CURSOR technology_exchange_esn( c_run_date IN DATE )
  IS
    --CR8663
    SELECT a.* ,
      b.x_value x_replacement_esn
    FROM table_x_case_detail b,
      table_case a
    WHERE 1 = 1
    AND EXISTS
      (SELECT 1
      FROM table_site_part
      WHERE x_service_id IN (b.x_value)
      AND part_status
        || '' = 'Active'
      )
  AND b.x_name
    || '' LIKE ('NEW_ESN')
  AND b.detail2case = a.objid + 0
  AND NOT EXISTS
    (SELECT 1
    FROM x_program_upgrade
    WHERE pgm_upgrade2case = a.objid + 0
    AND x_status           = 'SUCCESS'
    )
  AND a.creation_time >= TRUNC (SYSDATE) - (3)
  AND a.x_case_type
    || '' = 'Technology Exchange'
  AND EXISTS
    (SELECT 1
    FROM x_program_enrolled
    WHERE x_esn              = a.x_esn
    AND x_enrollment_status IN ('ENROLLED', 'SUSPENDED', 'ENROLLMENTSCHEDULED', 'ENROLLMENTPENDING' )
    );
  /*
  SELECT a.x_esn, b.x_replacement_esn
  FROM table_x_alt_esn b, table_case a
  WHERE 1 = 1
  AND EXISTS (
  SELECT 1
  FROM table_site_part
  WHERE x_service_id IN (b.x_replacement_esn)
  AND part_status || '' = 'Active')
  AND b.x_alt_esn2case = a.objid + 0
  AND NOT EXISTS (SELECT 1
  FROM x_program_upgrade
  WHERE pgm_upgrade2case = a.objid + 0)
  AND a.x_case_type || '' = 'Technology Exchange'
  AND a.creation_time >= TRUNC (SYSDATE) - (1)
  AND b.x_replacement_esn IS NOT NULL
  AND EXISTS (
  SELECT 1
  FROM x_program_enrolled
  WHERE x_esn = a.x_esn
  AND x_enrollment_status IN
  ('ENROLLED',
  'SUSPENDED',
  'ENROLLMENTSCHEDULED',
  'ENROLLMENTPENDING'
  ));
  */
  --CR8663
  -- Ensure that the target ESN is active.
  TECHNOLOGY_EXCHANGE_ESN_REC TECHNOLOGY_EXCHANGE_ESN%ROWTYPE;
  -- CR15325 PMistry 02/28/201 Start
  -- Cursor that fetches all the Defective SIM that have taken place.
  CURSOR defective_SIM_cur( c_run_date IN DATE )
  IS
    --CR8663
    SELECT a.*
    FROM table_case a
    WHERE 1 = 1
   AND EXISTS
      (SELECT 1
      FROM TABLE_SITE_PART
      WHERE x_service_id IN (a.x_esn)
      AND part_status
        || '' = 'Active'
      )
  AND NOT EXISTS
    (SELECT 1
    FROM x_program_upgrade
    WHERE pgm_upgrade2case = a.objid + 0
    AND x_status           = 'SUCCESS'
    )
  AND A.CREATION_TIME >= TRUNC (SYSDATE) - (3)
  AND (a.x_case_type
    || ''     = 'Warranty'
  AND a.title = 'Defective SIM')
  AND EXISTS
    (SELECT 1
    FROM x_program_enrolled
    WHERE x_esn              = a.x_esn
    AND x_enrollment_status IN ('ENROLLED', 'SUSPENDED', 'ENROLLMENTSCHEDULED', 'ENROLLMENTPENDING' )
    );
  DEFECTIVE_SIM_REC DEFECTIVE_SIM_CUR%ROWTYPE;
  -- CR15325 PMistry 02/28/201 End
  --
  -- Cursor that fetches all the reactivations that have taken place.
  CURSOR reactivation_esn( c_run_date IN DATE )
  IS
    SELECT a.objid calltrans_objid,
      b.*
    FROM table_x_call_trans a,
      x_program_enrolled b
    WHERE 1 = 1
    AND EXISTS
      (SELECT 1
      FROM table_site_part
      WHERE a.call_trans2site_part = objid
      AND part_status
        || '' = 'Active'
      )
  AND a.x_service_id = b.x_esn
  AND NOT EXISTS
    ( SELECT 1 FROM x_program_upgrade WHERE pgm_upgrade2case = a.objid
    )
  AND a.x_action_text
    || ''                = 'REACTIVATION'
  AND b.x_wait_exp_date IS NOT NULL
  AND a.x_transact_date >= TRUNC (SYSDATE) - (1)
  AND EXISTS
    (SELECT 1
    FROM x_program_enrolled
    WHERE x_esn              = b.x_esn
    AND x_enrollment_status IN ('ENROLLED', 'SUSPENDED', 'ENROLLMENTSCHEDULED', 'ENROLLMENTPENDING' )
    );
  reactivation_esn_rec reactivation_esn%ROWTYPE;
  -- New Cursor added for code optimization -- Ramu
  -- Cursor to fetch the latest failure record time
  -- This is handled to check the SUCCESS transactions after the recent FAILURE
  CURSOR start_date_curs( c_job_master_id IN NUMBER )
  IS
    SELECT tab1.max_d
    FROM
      (SELECT MIN (x_start_time) min_d,
        MAX (x_start_time) max_d,
        x_status
      FROM x_job_run_details
      WHERE x_status             = 'FAILED'
      AND run_details2job_master = c_job_master_id
      GROUP BY x_status
      ) tab1
  WHERE NOT EXISTS
    (SELECT 1
    FROM x_job_run_details d
    WHERE d.run_details2job_master = c_job_master_id
    AND d.x_status                 = 'SUCCESS'
    AND d.x_start_time             > tab1.max_d
    );
  start_date_rec start_date_curs%ROWTYPE;
  -- CR20399
  CURSOR net10_upg_curs ( c_esn IN VARCHAR2 )
  IS
    SELECT pe.objid
    FROM x_program_enrolled pe,
      x_program_parameters pp
    WHERE pe.x_esn                  = c_esn
    AND pe.pgm_enroll2pgm_parameter =pp.objid
    AND pp.prog_param2bus_org      IN
      ( SELECT objid FROM table_bus_org WHERE org_id = 'NET10'
      );
  net10_upg_rec net10_upg_curs%ROWTYPE;

  --SL UPGRADE
  CURSOR org_id_curs ( c_web_user_objid IN table_web_user.objid%TYPE )
  IS
    SELECT org_id
    FROM x_subscriber_spr ss,
      table_bus_org bb
    WHERE 1 = 1
    AND bb.objid = ss.bus_org_objid
   AND ss.web_user_objid = c_web_user_objid
    AND rownum < 2;
  org_id_rec org_id_curs%ROWTYPE;

  p_error_code        NUMBER;         -- CR20399
  p_error_msg         VARCHAR2 (100); --CR20399
  l_s_web_user_objid  NUMBER;         -- Webuser Objid for the old ESN
  l_t_web_user_objid  NUMBER;         -- Webuser Objid for the new ESN
  l_pgm_upgrade_objid NUMBER;
  -- Objid for inserting data into the upgrade table
  l_error         NUMBER;
  l_error_message VARCHAR2 (255);
  l_start_time    DATE;
  l_wait_exp_date DATE; -- Earliest WaitExpiry Date
  l_job_status    VARCHAR2 (50);
  ---- For logging purposes
  l_program_name x_program_parameters.x_program_name%TYPE;
  l_first_name table_contact.first_name%TYPE;
  l_last_name table_contact.last_name%TYPE;
  l_pe_objid x_program_enrolled.objid%TYPE;
  l_from_pgm_objid x_program_parameters.objid%TYPE;

BEGIN
  --- Added to fetch objid for Upgrade Job from x_job_master - Ruchi

  BEGIN --{
   SELECT MAX (objid)
   INTO job_master_id
   FROM x_job_master
   WHERE x_job_name = 'UpgradeJob';
  EXCEPTION --CR49066
  WHEN OTHERS THEN
  util_pkg.insert_error_tab ( i_action         => 'get job_master_id',
                              i_key            =>  'UpgradeJob',
                              i_program_name   => 'billing_job_pkg.upgrade_job',
                              i_error_text     => 'Error due to '||substr(sqlerrm,1,200));

  END; --}
  l_job_run_objid := billing_seq ('X_JOB_RUN_DETAILS');
  ---- Mark the job as started running.
  INSERT
  INTO x_job_run_details
    (
      objid,
      x_scheduled_run_date,
      x_actual_run_date,
      x_status,
      x_job_run_mode,
      x_start_time,
      run_details2job_master
    )
    VALUES
    (
      l_job_run_objid,
      SYSDATE,
      SYSDATE,
      'RUNNING',
      0,
      SYSDATE,
      job_master_id
    );
  --DBMS_OUTPUT.PUT_LINE ('Inserting record into JOB RUN ');
  ---- Get the failed records
  --select MAX(X_START_TIME) into l_start_time
  --from   X_JOB_RUN_DETAILS
  --where  X_STATUS = 'FAILED'
  --and   RUN_DETAILS2JOB_MASTER = JOB_MASTER_ID;
  -- New Cursor added for code optimization -- Ramu
  -- Cursor to fetch the latest failure record time
  -- This is handled to check the SUCCESS transactions after the recent FAILURE
  OPEN start_date_curs (job_master_id);
  FETCH start_date_curs INTO start_date_rec;
  IF start_date_curs%NOTFOUND THEN
    -- If SUCCESS records are available after recent FAILURE
    l_start_time := TRUNC (SYSDATE);
  ELSE
    l_start_time := start_date_rec.max_d;
  END IF;
  CLOSE start_date_curs;
  ---- Get the earliest wait_exp_date
  BEGIN --{
   SELECT MAX (x_wait_exp_date)
   INTO l_wait_exp_date
   FROM x_program_enrolled;
  EXCEPTION --CR49066
  WHEN OTHERS THEN
  util_pkg.insert_error_tab ( i_action         => 'get l_wait_exp_date',
                              i_key            =>  'UpgradeJob',
                              i_program_name   => 'billing_job_pkg.upgrade_job',
                              i_error_text     => 'Error due to '||substr(sqlerrm,1,200));
  END; --}
  --DBMS_OUTPUT.PUT_LINE ('Wait Exp ' || l_wait_exp_date);
  ---- Set the job start time as the earliest of the two.
  l_start_time := LEAST (NVL (l_start_time, TRUNC (SYSDATE - 1)), NVL ( l_wait_exp_date, TRUNC (SYSDATE + 1)) );
  -- Start from 1 day earlier to capture lost activations, if any
  --DBMS_OUTPUT.PUT_LINE ('After Wait exp ' || l_start_time);
  ---- Get the last success record.
  IF (l_start_time IS NULL) THEN
    --- No failed records found.
    --- Pick up the last success record.
  BEGIN --{
    SELECT MAX (x_start_time)
    INTO l_start_time
    FROM x_job_run_details
    WHERE x_status             = 'SUCCESS'
    AND run_details2job_master = job_master_id;
  EXCEPTION --CR49066
  WHEN OTHERS THEN
  util_pkg.insert_error_tab ( i_action         => 'get l_start_time',
                              i_key            =>  'UpgradeJob',
                              i_program_name   => 'billing_job_pkg.upgrade_job',
                              i_error_text     => 'Error due to '||substr(sqlerrm,1,200));
  END; --}
  END IF;
  --DBMS_OUTPUT.PUT_LINE ('After last success ' || l_start_time);
  ---- Assume today
  IF (l_start_time IS NULL) THEN
    l_start_time   := TRUNC (SYSDATE);
  END IF;
  ----------------------------------------------- Upgrade --------------------------------------------------
  --DBMS_OUTPUT.PUT_LINE ( 'Getting Upgrade records starting from ' || l_start_time );
  OPEN upgrade_esn (l_start_time);
  LOOP
    FETCH upgrade_esn INTO upgrade_esn_rec;
    EXIT
  WHEN upgrade_esn%NOTFOUND;
    --- Insert data into the progress table ------------------------------------------------------------------
    l_pgm_upgrade_objid := billing_seq ('X_PROGRAM_UPGRADE');
    INSERT
    INTO x_program_upgrade
      (
        objid,
        x_esn,
        x_replacement_esn,
        x_type,
        x_date,
        x_status,
        pgm_upgrade2case
      )
      --values ( l_pgm_upgrade_objid, upgrade_esn_rec.x_esn, upgrade_esn_rec.X_STOCK_TYPE, 'Phone Upgrade', sysdate, 'INCOMPLETE', upgrade_esn_rec.objid );
      VALUES
      (
        l_pgm_upgrade_objid,
        upgrade_esn_rec.x_esn,
        upgrade_esn_rec.x_value,
        'Phone Upgrade',
        SYSDATE,
        'INCOMPLETE',
        upgrade_esn_rec.objid
      );
    ------------ END ------------------------------------------------------------------------------------------
    --DBMS_OUTPUT.PUT_LINE ('Checking for Validate Upgrade Account ');
    -- Check if the ESNs can be transferred
    l_error := billing_webcsr_pkg.validate_upgrade_account ( upgrade_esn_rec.x_esn, upgrade_esn_rec.x_value, 1, l_s_web_user_objid );
    -- ESNs belong to the same account.
    IF (l_error = 0 OR l_error = 2) THEN
      --DBMS_OUTPUT.PUT_LINE ('Validate Return ' || l_error);
      billing_webcsr_pkg.transfer_esn_prog_to_diff_esn ( l_s_web_user_objid, upgrade_esn_rec.x_esn, upgrade_esn_rec.x_value, 'System', l_pe_objid, l_from_pgm_objid, l_error, l_error_message );
      --DBMS_OUTPUT.PUT_LINE ('After calling the transfer proc ');
      IF (l_error = 0) THEN
 --DBMS_OUTPUT.PUT_LINE ('upgrade_esn_rec.lifeline_lid '||upgrade_esn_rec.lifeline_lid);
 --DBMS_OUTPUT.PUT_LINE ('l_pe_objid '||l_pe_objid);
 --DBMS_OUTPUT.PUT_LINE ('l_error '||l_error);
      --CR38927 safelink changes start
      IF TRIM(upgrade_esn_rec.lifeline_lid) IS NOT NULL AND TRIM (l_pe_objid) IS NOT NULL THEN
       --DBMS_OUTPUT.PUT_LINE ('Condition satisfied ');
   BEGIN
         sa.safelink_services_pkg.p_program_transfer(
                                  p_web_objid        => l_s_web_user_objid,
                                  p_s_esn            => upgrade_esn_rec.x_esn,
                                  p_t_esn            => upgrade_esn_rec.x_value,
                                  p_pe_objid         => l_pe_objid,
                                  p_lid              => upgrade_esn_rec.lifeline_lid,
                                  p_from_pgm_objid   => l_from_pgm_objid,
                                  op_result          => l_error,
                                  op_msg             => l_error_message
                                );
--call procedure arproc
--DBMS_OUTPUT.PUT_LINE ('After program transfer ');
     EXCEPTION
       WHEN OTHERS THEN

        util_pkg.insert_error_tab ( i_action         => 'calling p_program_transfer failed',
                                    i_key            =>  upgrade_esn_rec.x_value,
                                    i_program_name   => 'billing_job_pkg.upgrade_job',
                                    i_error_text     => 'Failed for From ESN :'||upgrade_esn_rec.x_esn||' to ESN :'||upgrade_esn_rec.x_value||'Err :'||substr(sqlerrm,1,200));
     END;
      END IF;
      --CR38927 safelink changes end
        -- Success transferring the programs.
        --DBMS_OUTPUT.PUT_LINE ( 'Successfully transferred programs from ' || upgrade_esn_rec.x_esn || ' to ' || upgrade_esn_rec.x_value );
        UPDATE x_program_upgrade
        SET x_status    = 'SUCCESS',
          x_description = 'Successfully transferred programs from '
          || upgrade_esn_rec.x_esn
          || ' to '
          || upgrade_esn_rec.x_value
        WHERE objid = l_pgm_upgrade_objid;
        ----------------------- Mark the Job status as Success. ---------------------------------------
        UPDATE x_job_run_details
        SET x_status = 'SUCCESS',
          x_end_time = SYSDATE
        WHERE objid  = l_job_run_objid;
      ELSE
        -- Failed to transfer the programs.
        UPDATE x_program_upgrade
        SET x_status    = 'FAILED',
          x_description = 'Failed to transfer the programs to the new ESN '
        WHERE objid     = l_pgm_upgrade_objid;
        --DBMS_OUTPUT.PUT_LINE ( 'Failed to transfer the programs to the new ESN ');
        l_job_status := 'FAILED';
      END IF;
    ELSIF (l_error = 1) THEN
      --DBMS_OUTPUT.PUT_LINE ( 'ESN ' || upgrade_esn_rec.x_esn || ' does not exist in any account' );
      UPDATE x_program_upgrade
      SET x_status    = 'SUCCESS',
        x_description = 'ESN '
        || upgrade_esn_rec.x_esn
        || ' does not exist in any account'
      WHERE objid = l_pgm_upgrade_objid;
    ELSE
      --DBMS_OUTPUT.PUT_LINE ('Got return as  ' || l_error);
      UPDATE x_program_upgrade
      SET x_status    = 'FAILED',
        x_description = 'Data Error. '
        || ' Got return as  '
        || l_error
      WHERE objid   = l_pgm_upgrade_objid;
      l_job_status := 'FAILED';
    END IF;
    ---------------- NET10 Promo Logic changes  ----------------------------------------------
    -- begin CR20399
    OPEN net10_upg_curs (upgrade_esn_rec.x_esn);
    FETCH net10_upg_curs INTO net10_upg_rec;
    IF net10_upg_curs%FOUND THEN
      sa.enroll_promo_pkg.SP_TRANSFER_PROMO_ENROLLMENT ( upgrade_esn_rec.objid, --objid table_case
      upgrade_esn_rec.x_value,                                                  --new esn (replacement ESN)
      p_error_code,                                                             --          out   number,
      p_error_msg );
      --CR49066                                                       --          out   varchar2
      /*IF ( p_error_code = 0 ) THEN
        --DBMS_OUTPUT.PUT_LINE ('Upgrade NET10 succesful' );
      END IF;*/
    END IF;
    CLOSE net10_upg_curs;
    -- end CR20399
    /* changes starts 22313 HPP Phase2 */
    DECLARE
      lv_text x_program_enrolled.x_reason%type;
    BEGIN
      lv_text := 'During Upgrade Job, HPP Program has been suspended since its not available' ||'and not eligible at activation zipcode';
      --DBMS_OUTPUT.PUT_LINE('Invoking procedure : P_CHECK_ZIPCODE_N_SUSPEND_HPP ...Inside Upgrade_ESN ');
      P_CHECK_ZIPCODE_N_SUSPEND_HPP(UPGRADE_ESN_REC.X_ESN, LV_TEXT);
      --DBMS_OUTPUT.PUT_LINE('Completed procedure : P_CHECK_ZIPCODE_N_SUSPEND_HPP ...Inside Upgrade_ESN ');
    EXCEPTION
    WHEN OTHERS THEN
      --DBMS_OUTPUT.PUT_LINE('ERROR in P_CHECK_ZIPCODE_N_SUSPEND_HPP... ESN=' || upgrade_esn_rec.x_esn || ' ERR='|| SUBSTR(sqlerrm, 1, 100));
      NULL;
    END;
    /* changes ends 22313 HPP Phase2 */
  END LOOP;
  CLOSE upgrade_esn;
  IF (l_job_status = 'FAILED') THEN
    ----------------------- Mark the Job status as failed. ---------------------------------------
    --Modified to consider all program upgrade failures as Job Success only. 05/03/2007  Ramu
    --update X_JOB_RUN_DETAILS set X_STATUS = 'FAILED', X_END_TIME = sysdate where objid = l_job_run_objid;
    UPDATE x_job_run_details
    SET x_status = 'SUCCESS',
      x_end_time = SYSDATE
    WHERE objid  = l_job_run_objid;
  ELSE
    ----------------------- Mark the Job status as success. ---------------------------------------
    UPDATE x_job_run_details
    SET x_status = 'SUCCESS',
      x_end_time = SYSDATE
    WHERE objid  = l_job_run_objid;
  END IF;
  l_job_status := 'SUCCESS';
  ------------------------------------------------- Upgrade End -------------------------------------------------------------------------------------------------
  -------------------------------------------------PORT IN UPGRADE-----------------------------------------------------------------
  --DBMS_OUTPUT.PUT_LINE ( 'Getting PORT IN Upgrade records starting from ' || l_start_time );
  OPEN upgrade_esn_port_in (l_start_time);
  LOOP
    FETCH upgrade_esn_port_in INTO upgrade_esn_port_in_rec;
    EXIT
  WHEN upgrade_esn_port_in%NOTFOUND;
    --- Insert data into the progress table ------------------------------------------------------------------
    l_pgm_upgrade_objid := billing_seq ('X_PROGRAM_UPGRADE');
    INSERT
    INTO x_program_upgrade
      (
        objid,
        x_esn,
        x_replacement_esn,
        x_type,
        x_date,
        x_status,
        pgm_upgrade2case
      )
      --values ( l_pgm_upgrade_objid, upgrade_esn_rec.x_esn, upgrade_esn_rec.X_STOCK_TYPE, 'Phone Upgrade', sysdate, 'INCOMPLETE', upgrade_esn_rec.objid );
      VALUES
      (
        l_pgm_upgrade_objid,
        upgrade_esn_port_in_rec.x_value,
        upgrade_esn_port_in_rec.x_esn,
        'Port In',
        SYSDATE,
        'INCOMPLETE',
        upgrade_esn_port_in_rec.objid
      );
    ------------ END ------------------------------------------------------------------------------------------
    --DBMS_OUTPUT.PUT_LINE ('Checking for Validate Upgrade Account ');
    -- Check if the ESNs can be transferred
    l_error := billing_webcsr_pkg.validate_upgrade_account ( upgrade_esn_port_in_rec.x_value, upgrade_esn_port_in_rec.x_esn, 1, l_s_web_user_objid );
    -- ESNs belong to the same account.
    IF (l_error = 0 OR l_error = 2) THEN
      --DBMS_OUTPUT.PUT_LINE ('Validate Return ' || l_error);
      billing_webcsr_pkg.transfer_esn_prog_to_diff_esn ( l_s_web_user_objid, upgrade_esn_port_in_rec.x_value, upgrade_esn_port_in_rec.x_esn, 'System', l_pe_objid, l_from_pgm_objid, l_error, l_error_message );
      ----DBMS_OUTPUT.PUT_LINE ('After calling the transfer proc ');
      IF (l_error = 0) THEN
       --CR38927 safelink changes start
       ----DBMS_OUTPUT.PUT_LINE ('l_error '||l_error);
       ----DBMS_OUTPUT.PUT_LINE ('upgrade_esn_port_in_rec.lifeline_lid '||upgrade_esn_port_in_rec.lifeline_lid);
       ----DBMS_OUTPUT.PUT_LINE ('l_pe_objid '||l_pe_objid);
      IF TRIM(upgrade_esn_port_in_rec.lifeline_lid) IS NOT NULL AND TRIM (l_pe_objid) IS NOT NULL THEN
          ----DBMS_OUTPUT.PUT_LINE ('COndition satisfied ');
   BEGIN
   ----DBMS_OUTPUT.PUT_LINE ('l_s_web_user_objid '||l_s_web_user_objid);
   ----DBMS_OUTPUT.PUT_LINE ('upgrade_esn_port_in_rec.x_esn '||upgrade_esn_port_in_rec.x_esn);
  -- --DBMS_OUTPUT.PUT_LINE ('upgrade_esn_port_in_rec.x_value '||upgrade_esn_port_in_rec.x_value);
   ----DBMS_OUTPUT.PUT_LINE ('l_pe_objid '||l_pe_objid);
  --  --DBMS_OUTPUT.PUT_LINE ('l_from_pgm_objid '||l_from_pgm_objid);
   -- --DBMS_OUTPUT.PUT_LINE ('Started executing |p_program_transfer ');
         sa.safelink_services_pkg.p_program_transfer(
                                  p_web_objid        => l_s_web_user_objid,
                                  p_s_esn            => upgrade_esn_port_in_rec.x_value,
                                  p_t_esn            => upgrade_esn_port_in_rec.x_esn,
                                  p_pe_objid         => l_pe_objid,
                                  p_lid              => upgrade_esn_port_in_rec.lifeline_lid,
                                  p_from_pgm_objid   => l_from_pgm_objid,
                                  op_result          => l_error,
                                  op_msg             => l_error_message
                                );
--call procedure arproc
    -- --DBMS_OUTPUT.PUT_LINE ('finished executing p_program_transfer  ');
     EXCEPTION
       WHEN OTHERS THEN
--DBMS_OUTPUT.PUT_LINE ('entered p_program_transfer exception ');
        util_pkg.insert_error_tab ( i_action         => 'calling p_program_transfer failed',
                                    i_key            =>  upgrade_esn_rec.x_value,
                                    i_program_name   => 'billing_job_pkg.upgrade_job',
                                    i_error_text     => 'Failed for From ESN :'||upgrade_esn_rec.x_esn||' to ESN :'||upgrade_esn_rec.x_value||'Err :'||substr(sqlerrm,1,200));
     END;
      END IF;
      --CR38927 safelink changes end
        -- Success transferring the programs.
        --DBMS_OUTPUT.PUT_LINE ( 'Successfully transferred programs from ' || upgrade_esn_port_in_rec.x_value || ' to ' || upgrade_esn_port_in_rec.x_esn );
        UPDATE x_program_upgrade
        SET x_status    = 'SUCCESS',
          x_description = 'Successfully transferred programs from '
          || upgrade_esn_port_in_rec.x_value
          || ' to '
          || upgrade_esn_port_in_rec.x_esn
        WHERE objid = l_pgm_upgrade_objid;
        ----------------------- Mark the Job status as Success. ---------------------------------------
        UPDATE x_job_run_details
        SET x_status = 'SUCCESS',
          x_end_time = SYSDATE
        WHERE objid  = l_job_run_objid;
      ELSE
        -- Failed to transfer the programs.
        UPDATE x_program_upgrade
        SET x_status    = 'FAILED',
          x_description = 'Failed to transfer the programs to the new ESN '
        WHERE objid     = l_pgm_upgrade_objid;
        --DBMS_OUTPUT.PUT_LINE ( 'Failed to transfer the programs to the new ESN ');
        l_job_status := 'FAILED';
      END IF;
    ELSIF (l_error = 1) THEN
      --DBMS_OUTPUT.PUT_LINE ( 'ESN ' || upgrade_esn_port_in_rec.x_value || ' does not exist in any account' );
      UPDATE x_program_upgrade
      SET x_status    = 'SUCCESS',
        x_description = 'ESN '
        || upgrade_esn_port_in_rec.x_value
        || ' does not exist in any account'
      WHERE objid = l_pgm_upgrade_objid;
    ELSE
      --DBMS_OUTPUT.PUT_LINE ('Got return as  ' || l_error);
      UPDATE x_program_upgrade
      SET x_status    = 'FAILED',
        x_description = 'Data Error. '
        || ' Got return as  '
        || l_error
      WHERE objid   = l_pgm_upgrade_objid;
      l_job_status := 'FAILED';
    END IF;
  END LOOP;
  CLOSE upgrade_esn_port_in;
  IF (l_job_status = 'FAILED') THEN
    ----------------------- Mark the Job status as failed. ---------------------------------------
    --Modified to consider all program upgrade failures as Job Success only. 05/03/2007  Ramu
    --update X_JOB_RUN_DETAILS set X_STATUS = 'FAILED', X_END_TIME = sysdate where objid = l_job_run_objid;
    UPDATE x_job_run_details
    SET x_status = 'SUCCESS',
      x_end_time = SYSDATE
    WHERE objid  = l_job_run_objid;
  ELSE
    ----------------------- Mark the Job status as success. ---------------------------------------
    UPDATE x_job_run_details
    SET x_status = 'SUCCESS',
      x_end_time = SYSDATE
    WHERE objid  = l_job_run_objid;
  END IF;
  l_job_status := 'SUCCESS';
  -----------------------------------------------PORT IN UPGRADE ENDS-----------------------------------------------------
 ------------------------------------------------- Technology Exchange --------------------------------------------------
  --DBMS_OUTPUT.PUT_LINE ( '================== Getting Technology upgrades from ' || l_start_time );
  OPEN technology_exchange_esn (l_start_time);
  LOOP
    FETCH technology_exchange_esn INTO technology_exchange_esn_rec;
    EXIT
  WHEN technology_exchange_esn%NOTFOUND;
    -- Check if the ESNs can be transferred
    l_error := billing_webcsr_pkg.validate_upgrade_account ( technology_exchange_esn_rec.x_esn, technology_exchange_esn_rec.x_replacement_esn , 1, l_s_web_user_objid );
    -- ESNs belong to the same account.
    IF (l_error = 0 OR l_error = 2) THEN
      billing_webcsr_pkg.transfer_esn_prog_to_diff_esn ( l_s_web_user_objid, technology_exchange_esn_rec.x_esn, technology_exchange_esn_rec.x_replacement_esn, 'System', l_pe_objid, l_from_pgm_objid, l_error, l_error_message );
      IF (l_error = 0) THEN
        -- Success transferring the programs.
        --DBMS_OUTPUT.PUT_LINE ( 'Successfully transferred programs(tech upgrade) from ' || technology_exchange_esn_rec.x_esn || ' to ' || technology_exchange_esn_rec.x_replacement_esn );
        UPDATE x_program_upgrade
        SET x_status    = 'SUCCESS',
          x_description = 'Successfully transferred programs (tech upgrade) from '
          || technology_exchange_esn_rec.x_esn
          || ' to '
          || technology_exchange_esn_rec.x_replacement_esn
        WHERE objid = l_pgm_upgrade_objid;
        ----------------------- Mark the Job status as Success. ---------------------------------------
        UPDATE x_job_run_details
        SET x_status = 'SUCCESS',
          x_end_time = SYSDATE
        WHERE objid  = l_job_run_objid;
      ELSE
        -- Failed to transfer the programs.
        --DBMS_OUTPUT.PUT_LINE ( 'Failed to transfer the programs to the new ESN (Tech Upgrade) ' || l_error );
        UPDATE x_program_upgrade
        SET x_status    = 'FAILED',
          x_description = 'Failed to transfer the programs(tech upgrade) to the new ESN '
        WHERE objid     = l_pgm_upgrade_objid;
        l_job_status   := 'FAILED';
      END IF;
    ELSIF (l_error = 1) THEN
      --DBMS_OUTPUT.PUT_LINE ( 'ESN ' || technology_exchange_esn_rec.x_esn || ' does not exist in any account' );
      UPDATE x_program_upgrade
      SET x_status    = 'SUCCESS',
        x_description = 'ESN '
        || technology_exchange_esn_rec.x_esn
        || ' does not exist in any account'
      WHERE objid = l_pgm_upgrade_objid;
    ELSE
      --DBMS_OUTPUT.PUT_LINE ('Got return as  ' || l_error);
      UPDATE x_program_upgrade
      SET x_status    = 'FAILED',
        x_description = 'Data Error. '
        || ' Got return as  '
        || l_error
      WHERE objid   = l_pgm_upgrade_objid;
      l_job_status := 'FAILED';
    END IF;
  END LOOP;
  CLOSE technology_exchange_esn;
  IF (l_job_status = 'FAILED') THEN
    ----------------------- Mark the Job status as failed. ---------------------------------------
    --Modified to consider all program upgrade failures as Job Success only. 05/03/2007  Ramu
    --update X_JOB_RUN_DETAILS set X_STATUS = 'FAILED', X_END_TIME = sysdate where objid = l_job_run_objid;
    UPDATE x_job_run_details
    SET x_status = 'SUCCESS',
      x_end_time = SYSDATE
    WHERE objid  = l_job_run_objid;
  ELSE
    ----------------------- Mark the Job status as success. ---------------------------------------
    UPDATE x_job_run_details
    SET x_status = 'SUCCESS',
      x_end_time = SYSDATE
    WHERE objid  = l_job_run_objid;
  END IF;
  l_job_status := 'SUCCESS';
  ------------------------------------------------- Technology Exchange End -------------------------------------------------------------------------------------------------
  -- CR15325 PMistry 02/28/201 Start
  ----------------------------------------------- Defective SIM Start --------------------------------------------------
  --DBMS_OUTPUT.PUT_LINE ( '================== Getting Defective SIM from ' || l_start_time );
  OPEN DEFECTIVE_SIM_CUR (l_start_time);
  LOOP
    FETCH DEFECTIVE_SIM_CUR INTO DEFECTIVE_SIM_REC;
    EXIT
  WHEN DEFECTIVE_SIM_CUR%NOTFOUND;
    -- Check if the ESNs can be transferred
    L_ERROR := BILLING_WEBCSR_PKG.VALIDATE_UPGRADE_ACCOUNT ( DEFECTIVE_SIM_REC.x_esn, DEFECTIVE_SIM_REC.x_esn , 1, l_s_web_user_objid );
    -- ESNs belong to the same account.
    IF (l_error = 0 OR l_error = 2) THEN
      billing_webcsr_pkg.transfer_esn_prog_to_diff_esn ( l_s_web_user_objid, DEFECTIVE_SIM_REC.x_esn, DEFECTIVE_SIM_REC.x_esn, 'System', l_pe_objid, l_from_pgm_objid, l_error, l_error_message );
      IF (l_error = 0) THEN
        -- Success transferring the programs.
        --DBMS_OUTPUT.PUT_LINE ( 'Successfully transferred programs(SIM upgrade) from ' || DEFECTIVE_SIM_REC.x_esn || ' to ' || DEFECTIVE_SIM_REC.x_esn );
        UPDATE X_PROGRAM_UPGRADE
        SET X_STATUS    = 'SUCCESS',
          X_DESCRIPTION = 'Successfully transferred programs (SIM upgrade) from '
          || DEFECTIVE_SIM_REC.x_esn
          || ' to '
          || DEFECTIVE_SIM_REC.x_esn
        WHERE objid = l_pgm_upgrade_objid;
        ----------------------- Mark the Job status as Success. ---------------------------------------
        UPDATE x_job_run_details
        SET x_status = 'SUCCESS',
          x_end_time = SYSDATE
        WHERE objid  = l_job_run_objid;
      ELSE
        -- Failed to transfer the programs.
        --DBMS_OUTPUT.PUT_LINE ( 'Failed to transfer the programs to the new ESN (SIM Upgrade) ' || l_error );
        UPDATE x_program_upgrade
        SET x_status    = 'FAILED',
          x_description = 'Failed to transfer the programs(SIM upgrade) to the new ESN '
        WHERE objid     = l_pgm_upgrade_objid;
        l_job_status   := 'FAILED';
      END IF;
    ELSIF (l_error = 1) THEN
      --DBMS_OUTPUT.PUT_LINE ( 'ESN ' || DEFECTIVE_SIM_REC.x_esn || ' does not exist in any account' );
      UPDATE x_program_upgrade
      SET x_status    = 'SUCCESS',
        x_description = 'ESN '
        || DEFECTIVE_SIM_REC.x_esn
        || ' does not exist in any account'
      WHERE objid = l_pgm_upgrade_objid;
    ELSE
      --DBMS_OUTPUT.PUT_LINE ('Got return as  ' || l_error);
      UPDATE x_program_upgrade
      SET x_status    = 'FAILED',
        x_description = 'Data Error. '
        || ' Got return as  '
        || l_error
      WHERE objid   = l_pgm_upgrade_objid;
      l_job_status := 'FAILED';
    END IF;
  END LOOP;
  CLOSE DEFECTIVE_SIM_CUR;
  IF (l_job_status = 'FAILED') THEN
    ----------------------- Mark the Job status as failed. ---------------------------------------
    --Modified to consider all program upgrade failures as Job Success only. 05/03/2007  Ramu
    --update X_JOB_RUN_DETAILS set X_STATUS = 'FAILED', X_END_TIME = sysdate where objid = l_job_run_objid;
    UPDATE x_job_run_details
    SET x_status = 'SUCCESS',
      x_end_time = SYSDATE
    WHERE objid  = l_job_run_objid;
  ELSE
    ----------------------- Mark the Job status as success. ---------------------------------------
    UPDATE x_job_run_details
    SET x_status = 'SUCCESS',
      x_end_time = SYSDATE
    WHERE objid  = l_job_run_objid;
  END IF;
  L_JOB_STATUS := 'SUCCESS';
  ------------------------------------------------- Defective SIM End -------------------------------------------------------------------------------------------------
  -- CR15325 PMistry 02/28/201 End
  ----------------------------------------------- Defective Exchanges --------------------------------------------------
  --DBMS_OUTPUT.PUT_LINE ('Getting Defective Exchanges from ' || l_start_time );
  OPEN defective_exhange_esn (l_start_time);
  LOOP
    FETCH defective_exhange_esn INTO defective_exhange_esn_rec;
    EXIT
  WHEN defective_exhange_esn%NOTFOUND;
    -- Check if the ESNs can be transferred
    l_error := billing_webcsr_pkg.validate_upgrade_account ( defective_exhange_esn_rec.x_esn, defective_exhange_esn_rec.x_value, 1, l_s_web_user_objid );
    --DBMS_OUTPUT.PUT_LINE ('Got error ------------------ ' || l_error);
    -- ESNs belong to the same account.
    IF (l_error = 0 OR l_error = 2) THEN
      -- ESNs belong to the same account.
      billing_webcsr_pkg.transfer_esn_prog_to_diff_esn ( l_s_web_user_objid, defective_exhange_esn_rec.x_esn, defective_exhange_esn_rec.x_value, 'System', l_pe_objid, l_from_pgm_objid, l_error, l_error_message );
      IF (l_error = 0) THEN
        -- Success transferring the programs.
        --DBMS_OUTPUT.PUT_LINE ( 'Successfully transferred programs from ' || defective_exhange_esn_rec.x_esn || ' to ' || defective_exhange_esn_rec.x_value );
        UPDATE x_program_upgrade
        SET x_status    = 'SUCCESS',
          x_description = 'Successfully transferred programs (def. upgrade) from '
          || defective_exhange_esn_rec.x_esn
          || ' to '
          || defective_exhange_esn_rec.x_value
        WHERE objid = l_pgm_upgrade_objid;
        ----------------------- Mark the Job status as Success. ---------------------------------------
        UPDATE x_job_run_details
        SET x_status = 'SUCCESS',
          x_end_time = SYSDATE
        WHERE objid  = l_job_run_objid;
      ELSE
        -- Failed to transfer the programs.
        --DBMS_OUTPUT.PUT_LINE ( 'Failed to transfer the programs to the new ESN ');
        UPDATE x_program_upgrade
        SET x_status    = 'FAILED',
          x_description = 'Failed to transfer the programs(def. Exchange) to the new ESN '
        WHERE objid     = l_pgm_upgrade_objid;
        l_job_status   := 'FAILED';
      END IF;
    ELSIF (l_error = 1) THEN
      --DBMS_OUTPUT.PUT_LINE ( 'ESN ' || defective_exhange_esn_rec.x_esn || ' does not exist in any account' );
      UPDATE x_program_upgrade
      SET x_status    = 'SUCCESS',
        x_description = 'ESN '
        || defective_exhange_esn_rec.x_esn
        || ' does not exist in any account'
      WHERE objid = l_pgm_upgrade_objid;
    ELSE
      --DBMS_OUTPUT.PUT_LINE ('Got return as  ' || l_error);
      UPDATE x_program_upgrade
      SET x_status    = 'FAILED',
        x_description = 'Data Error. '
        || ' Got return as  '
        || l_error
      WHERE objid   = l_pgm_upgrade_objid;
      l_job_status := 'FAILED';
    END IF;
  END LOOP;
  CLOSE defective_exhange_esn;
  IF (l_job_status = 'FAILED') THEN
    ----------------------- Mark the Job status as failed. ---------------------------------------
    --Modified to consider all program upgrade failures as Job Success only. 05/03/2007  Ramu
    --update X_JOB_RUN_DETAILS set X_STATUS = 'FAILED', X_END_TIME = sysdate where objid = l_job_run_objid;
    UPDATE x_job_run_details
    SET x_status = 'SUCCESS',
      x_end_time = SYSDATE
    WHERE objid  = l_job_run_objid;
  ELSE
    ----------------------- Mark the Job status as failed. ---------------------------------------
    UPDATE x_job_run_details
    SET x_status = 'SUCCESS',
      x_end_time = SYSDATE
    WHERE objid  = l_job_run_objid;
  END IF;
  ------------------------------------------------- Defective Exchanges End -------------------------------------------------------------------------------------------------
  /*  CR22313 changes starts -- vkashmire */
  ----------------------------------------------- HPP transfer starts --------------------------------------------------
  DECLARE
    lv_hpp_error_code INTEGER;
    lv_hpp_error_msg  VARCHAR2(200);
  BEGIN
    p_transfer_hpp_from_esn_to_esn(l_job_run_objid, lv_hpp_error_code, lv_hpp_error_msg );
  EXCEPTION
  WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE ('exception caught !!! p_transfer_hpp_from_esn_to_esn...' || 'lv_hpp_error_msg = ' || lv_hpp_error_msg );
    sa.OTA_UTIL_PKG.ERR_LOG ( 'HPP Transfer', SYSDATE, NULL, 'p_transfer_hpp_from_esn_to_esn', 'errcode='||lv_hpp_error_code ||', err='||lv_hpp_error_msg);
  END;
  ------------------------------------------------- HPP transfer Ends -------------------------------------------------
  /* CR22313 changes ends  vkashmire  */
  ------------------------------------------------- Reactivation ---------------------------------------------------
  /*  If there is a REACTIVATION and the ESN has previously been de-activated, remove the wait period
  on the programs, if any.
  */
  OPEN reactivation_esn (l_start_time);
  LOOP
    FETCH reactivation_esn INTO reactivation_esn_rec;
    EXIT
  WHEN reactivation_esn%NOTFOUND;
    UPDATE x_program_enrolled
    SET x_wait_exp_date   = NULL,
      x_enrollment_status =
      CASE
        WHEN x_next_charge_date <= TRUNC (SYSDATE)
        AND x_enrollment_status  = 'ENROLLED'
        THEN
          -- If this is a primary phone, then SUSPEND,
          -- otherwise move them to ready to re-enroll
          CASE
            WHEN x_is_grp_primary = 1
            THEN 'SUSPENDED'
            ELSE 'READYTOREENROLL'
          END
        ELSE x_enrollment_status
      END,
      pgm_enroll2site_part =
      (
      --
      -- Start CR13082 Kacosta 01/20/2011
      --SELECT objid
      --FROM table_site_part
      --WHERE x_service_id IN (reactivation_esn_rec.x_esn)
      --AND part_status = 'Active'

      SELECT tsp.objid
      FROM   table_part_inst tpi ,
             table_site_part tsp
      WHERE  tsp.x_service_id    IN (reactivation_esn_rec.x_esn)
      AND    tsp.part_status        = 'Active'
      AND    tsp.objid              = tpi.x_part_inst2site_part
      AND    tpi.x_part_inst_status = '52'
      AND    tpi.x_domain           = 'PHONES'
        -- End CR13082 Kacosta 01/20/2011
        --
      ),
      x_exp_date =
      CASE
        WHEN x_next_charge_date <= (SYSDATE)
        AND x_enrollment_status  = 'ENROLLED'
        AND x_is_grp_primary     = 1
        THEN GREATEST (SYSDATE + 5, NVL (x_exp_date, SYSDATE))
        ELSE x_exp_date
      END
      WHERE objid = reactivation_esn_rec.objid;
    IF (reactivation_esn_rec.x_enrollment_status IN ('SUSPENDED', 'ENROLLED') ) THEN
      --------------------------- If the program is SUSPENDED, Insert additional log for suspension ---------------
      ----------------------------- Insert a log into the billing table --------------------------------------
      --------------------------------------------------------------------------------------------------
      --------------- Get the program name
     BEGIN --{
      SELECT x_program_name
      INTO   l_program_name
      FROM   x_program_parameters
      WHERE  objid = reactivation_esn_rec.pgm_enroll2pgm_parameter;
     EXCEPTION --CR49066
     WHEN OTHERS THEN
     util_pkg.insert_error_tab ( i_action         => 'get l_program_name',
                                 i_key            =>  'UpgradeJob',
                                 i_program_name   => 'billing_job_pkg.upgrade_job',
                                 i_error_text     => 'Error due to '||substr(sqlerrm,1,200));
     END; --}

      ---------------- Get the contact details for logging ---------------------------------------------
     BEGIN --{
       SELECT regexp_replace(first_name, '[^0-9 A-Za-z]', ''),
              regexp_replace(last_name, '[^0-9 A-Za-z]', '')
       INTO   l_first_name,
              l_last_name
       FROM table_contact
       WHERE objid =
         (SELECT web_user2contact
         FROM table_web_user
         WHERE objid = reactivation_esn_rec.pgm_enroll2web_user
         );
     EXCEPTION --CR49066
     WHEN OTHERS THEN
     util_pkg.insert_error_tab ( i_action         => 'get l_first_name, l_last_name',
                                 i_key            =>  'UpgradeJob',
                                 i_program_name   => 'billing_job_pkg.upgrade_job',
                                 i_error_text     => 'Error due to '||substr(sqlerrm,1,200));
     END; --}
      IF ( reactivation_esn_rec.x_enrollment_status = 'ENROLLED' AND reactivation_esn_rec.x_next_charge_date <= TRUNC (SYSDATE) AND reactivation_esn_rec.x_is_grp_primary = 1 ) THEN
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
            x_esn,
            x_exp_date,
            x_cooling_exp_date,
            x_update_status,
            x_update_user,
            pgm_tran2pgm_entrolled,
            pgm_trans2web_user,
            pgm_trans2site_part
          )
          VALUES
          (
            billing_seq ('X_PROGRAM_TRANS'),
            reactivation_esn_rec.x_enrollment_status,
            'Reactivation of ESN',
            NULL,
            NULL,
            NULL,
            SYSDATE,
            'Reactivation',
            'SUSPENDED',
            'Due to reactivation, Program '
            ||
            (SELECT x_program_name
            FROM x_program_parameters
            WHERE objid = reactivation_esn_rec.pgm_enroll2pgm_parameter
            )
            || ' is suspended',
            reactivation_esn_rec.x_sourcesystem,
            reactivation_esn_rec.x_esn,
            reactivation_esn_rec.x_exp_date ,
            reactivation_esn_rec.x_cooling_exp_date,
            'I',
            'System',
            reactivation_esn_rec.objid,
            reactivation_esn_rec.pgm_enroll2web_user ,
            reactivation_esn_rec.pgm_enroll2site_part
          );
        IF is_SB_esn(NULL, reactivation_esn_rec.x_esn) <> 1 THEN
          --CR8663
          INSERT
          INTO x_program_notify
            (
              objid,
              x_esn,
              x_program_name,
              x_program_status,
              x_notify_process,
              x_notify_status,
              x_source_system,
              x_process_date,
              x_phone,
              x_language,
              x_remarks,
              pgm_notify2pgm_objid,
              pgm_notify2contact_objid,
              pgm_notify2web_user
            )
            VALUES
            (
              billing_seq ('X_PROGRAM_NOTIFY'),
              reactivation_esn_rec.x_esn,
              l_program_name,
              'SUSPENDED',
              'REACTIVATION_JOB',
              'PENDING',
              reactivation_esn_rec.x_sourcesystem,
              SYSDATE,
              NULL,
              reactivation_esn_rec.x_language,
              'Due to reactivation after cycle date, program is suspended' ,
              reactivation_esn_rec.pgm_enroll2pgm_group,
              reactivation_esn_rec.pgm_enroll2contact,
              reactivation_esn_rec.pgm_enroll2web_user
            );
        END IF ; --CR8663
        ---------------- Insert a billing Log ------------------------------------------------------------
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
            billing_seq ('X_BILLING_LOG'),
            'Program',
            'ESN Activation',
            SYSDATE,
            'Due to reactivation, Program '
            || l_program_name
            || ' is suspended',
            l_program_name,
            billing_getnickname (reactivation_esn_rec.x_esn),
            reactivation_esn_rec.x_esn,
            'System',
            l_first_name,
            l_last_name,
            'System',
            reactivation_esn_rec.x_sourcesystem,
            reactivation_esn_rec.pgm_enroll2web_user
          );
      ELSE
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
            x_esn,
            x_exp_date,
            x_cooling_exp_date,
            x_update_status,
            x_update_user,
            pgm_tran2pgm_entrolled,
            pgm_trans2web_user,
            pgm_trans2site_part
          )
          VALUES
          (
            billing_seq ('X_PROGRAM_TRANS'),
            reactivation_esn_rec.x_enrollment_status,
            'Reactivation of ESN',
            NULL,
            NULL,
            NULL,
            SYSDATE,
            'Reactivation',
            'RE_ENROLL',
            'Due to reactivation, Program '
            ||
            (SELECT x_program_name
            FROM x_program_parameters
            WHERE objid = reactivation_esn_rec.pgm_enroll2pgm_parameter
            )
            || ' is out of wait period',
            reactivation_esn_rec.x_sourcesystem ,
            reactivation_esn_rec.x_esn,
            reactivation_esn_rec.x_exp_date ,
            reactivation_esn_rec.x_cooling_exp_date,
            'I',
            'System',
            reactivation_esn_rec.objid,
            reactivation_esn_rec.pgm_enroll2web_user ,
            reactivation_esn_rec.pgm_enroll2site_part
          );
        ---------------- Insert a billing Log ------------------------------------------------------------
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
            billing_seq ('X_BILLING_LOG'),
            'Program',
            'ESN Activation',
            SYSDATE,
            'Due to reactivation, Program '
            || l_program_name
            || ' is out of wait period',
            l_program_name,
            billing_getnickname (reactivation_esn_rec.x_esn),
            reactivation_esn_rec.x_esn,
            'System',
            l_first_name,
            l_last_name,
            'System',
            reactivation_esn_rec.x_sourcesystem,
            reactivation_esn_rec.pgm_enroll2web_user
          );
      END IF;
      --------------------------------------------------------------------------------------------------------------
      -------------------------- If the program is SUSPENDED, insert additional LOG (Additional Phones)---------------------------
      IF ( reactivation_esn_rec.x_enrollment_status = 'ENROLLED' AND reactivation_esn_rec.x_next_charge_date <= TRUNC (SYSDATE) AND reactivation_esn_rec.x_is_grp_primary = 0 ) THEN
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
            billing_seq ('X_BILLING_LOG'),
            'Program',
            'ESN Activation',
            SYSDATE,
            'Due to reactivation, Program '
            || l_program_name
            || ' is on-hold',
            l_program_name,
            billing_getnickname (reactivation_esn_rec.x_esn),
            reactivation_esn_rec.x_esn,
            'System',
            l_first_name,
            l_last_name,
            'System',
            reactivation_esn_rec.x_sourcesystem,
            reactivation_esn_rec.pgm_enroll2web_user
          );
        IF is_SB_esn(NULL, reactivation_esn_rec.x_esn) <> 1 THEN
          --CR8663
          INSERT
          INTO x_program_notify
            (
              objid,
              x_esn,
              x_program_name,
              x_program_status,
              x_notify_process,
              x_notify_status,
              x_source_system,
              x_process_date,
              x_phone,
              x_language,
              x_remarks,
              pgm_notify2pgm_objid,
              pgm_notify2contact_objid,
              pgm_notify2web_user
            )
            VALUES
            (
              billing_seq ('X_PROGRAM_NOTIFY'),
              reactivation_esn_rec.x_esn,
              l_program_name,
              'DEENROLLED',
              'REACTIVATION_JOB',
              'PENDING',
              reactivation_esn_rec.x_sourcesystem,
              SYSDATE,
              NULL,
              reactivation_esn_rec.x_language,
              'Due to reactivation after cycle date, program is de-enrolled' ,
              reactivation_esn_rec.pgm_enroll2pgm_group,
              reactivation_esn_rec.pgm_enroll2contact,
              reactivation_esn_rec.pgm_enroll2web_user
            );
        END IF ;
        --CR8663
      END IF;
      ----------------------------------------------------------------------------------------------------------
      ---------------------------------------------------------------------------------------------------------
      --- Insert data into the progress table ------------------------------------------------------------------
      l_pgm_upgrade_objid := billing_seq ('X_PROGRAM_UPGRADE');
      INSERT
      INTO x_program_upgrade
        (
          objid,
          x_esn,
          x_replacement_esn,
          x_type,
          x_date,
          x_status,
          pgm_upgrade2case
        )
        VALUES
        (
          l_pgm_upgrade_objid,
          reactivation_esn_rec.x_esn,
          reactivation_esn_rec.x_esn,
          'Phone Reactivation',
          SYSDATE,
          'COMPLETE',
          reactivation_esn_rec.calltrans_objid
        );
      ------------ END ------------------------------------------------------------------------------------------
    END IF;
    /* changes starts 22313 HPP Phase 2 */
    DECLARE
      lv_text x_program_enrolled.x_reason%type;
    BEGIN
      lv_text := 'During Reactivation, HPP Program has been suspended since its not available' ||'and not eligible at activation zipcode';
      --DBMS_OUTPUT.PUT_LINE('Invoking procedure : P_CHECK_ZIPCODE_N_SUSPEND_HPP ...Inside Reactivation ');
      P_CHECK_ZIPCODE_N_SUSPEND_HPP(reactivation_esn_rec.x_esn, lv_text);
      --DBMS_OUTPUT.PUT_LINE('Comlpeted procedure : P_CHECK_ZIPCODE_N_SUSPEND_HPP ...Inside Reactivation ');
    EXCEPTION
    WHEN OTHERS THEN
      --DBMS_OUTPUT.PUT_LINE('ERROR in P_CHECK_ZIPCODE_N_SUSPEND_HPP... ESN=' || reactivation_esn_rec.x_esn || ' ERR='|| SUBSTR(sqlerrm, 1, 100));
      NULL;
    END;
   /* changes ends 22313 HPP Phase2 */
    /*
    ------------- If there are any additional phone, that would have been put into wait period
    ------------- since the primary phone had deactivated, remove the additional phones from
    ------------- the wait period
    for idx in ( select *
    from x_program_enrolled
    where pgm_enroll2pgm_group = reactivation_esn_rec.objid
    )
    LOOP
    ----- Update program enrolled
    update x_program_enrolled
    set
    x_wait_exp_date = null,
    X_ENROLLMENT_STATUS = case when x_next_charge_date < trunc(sysdate)
    and x_enrollment_status = 'ENROLLED'
    then
    -- If this is a primary phone, then SUSPEND,
    -- otherwise move them to ready to re-enroll
    case when x_is_grp_primary     = 1 then 'SUSPENDED'
    else                                    'READYTOREENROLL'
    end
    else X_ENROLLMENT_STATUS end
    where objid = idx.objid;
    if ( reactivation_esn_rec.x_enrollment_status in ( 'ENROLLED','SUSPENDED' ) ) then
    --- Insert a record into program log
    INSERT INTO x_program_trans
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
    x_esn,
    x_exp_date,
    x_cooling_exp_date,
    x_update_status,
    x_update_user,
    pgm_tran2pgm_entrolled,
    pgm_trans2web_user,
    pgm_trans2site_part
    )
    VALUES
    (
    billing_seq ('X_PROGRAM_TRANS'),
    idx.x_enrollment_status,
    'Reactivation of Group Primary ESN - ' || reactivation_esn_rec.x_esn,
    null,
    null,
    null,
    sysdate,
    'Reactivation',
    'PLAN_CHANGE',
    'Due to reactivation, Program '
    || ( select x_program_name
    from x_program_parameters
    where objid=reactivation_esn_rec.pgm_enroll2pgm_parameter)
    || ' is out of wait period',
    idx.x_sourcesystem,
    idx.x_esn,
    idx.x_exp_date,
    idx.x_cooling_exp_date,
    'I',
    'System',
    idx.objid,
    idx.pgm_enroll2web_user,
    idx.pgm_enroll2site_part
    ) ;
    end if;
    END LOOP;
    */
  END LOOP;
  CLOSE reactivation_esn;
  -----------------------------------------------------------------------------------------------------------------
  /* CR22313 changes started */
  ----------------------------------------------- Port cases starts --------------------------------------------------
  --DBMS_OUTPUT.PUT_LINE('Invoking procedure P_PORT_CASE_SUSPEND_HPP ');
  BEGIN
    P_PORT_CASE_SUSPEND_HPP;
    --DBMS_OUTPUT.PUT_LINE('Completed procedure P_PORT_CASE_SUSPEND_HPP ');
  EXCEPTION
  WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE(' Exception in P_PORT_CASE_SUSPEND_HPP...ERR='|| SUBSTR(SQLERRM,1,100));
    NULL;
  END;
  ------------------------------------------------- Port Cases Ends -------------------------------------------------
  /* CR22313 changes Ends */
  op_result := 0;
  op_msg    := 'Success';
   COMMIT;
EXCEPTION
WHEN OTHERS THEN
  op_result := - 900;
  op_msg    := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
      'BILLING_JOB_PKG.upgrade',
      op_result,
      op_msg,
      SYSDATE,
      'Upgrade Job could not be processed ',
      1 -- HIGH
    );
  ------------------------ Exception Logging --------------------------------------------------------------------
  --DBMS_OUTPUT.PUT_LINE (op_msg);
END upgrade_job;
PROCEDURE processzerodollarprogram
  (
    p_objid IN NUMBER
  )
  /* Purpose      :   This procedure short-circuits data submission to payment systems when the    */
  /*                    program is 0$ in cost                                                      */
IS
  l_error_code NUMBER;
  l_error_msg  VARCHAR2 (255);
BEGIN
  -- Select the Primary and the additional ESN for the given primary enrollment
  FOR idx1 IN
  (SELECT   *
    FROM x_program_enrolled
    WHERE objid             = p_objid
    OR pgm_enroll2pgm_group = p_objid
  )
  LOOP
    -- Insert data into program trans
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
        x_esn,
        x_exp_date,
        x_cooling_exp_date,
        x_update_status,
        x_update_user,
        pgm_tran2pgm_entrolled,
        pgm_trans2web_user,
        pgm_trans2site_part
      )
      VALUES
      (
        billing_seq ('X_PROGRAM_TRANS'),
        idx1.x_enrollment_status,
        '0$ Recurring payment',
        NULL,
        NULL,
        NULL,
        SYSDATE,
        'Payment Receipt',
        'RECURRING_PAYMENT',
        '0$ Payment Cycle - Assumed successful',
        idx1.x_sourcesystem,
        idx1.x_esn,
        idx1.x_exp_date,
        idx1.x_cooling_exp_date,
        'I',
        'System',
        idx1.objid,
        idx1.pgm_enroll2web_user,
        idx1.pgm_enroll2site_part
      );
    ---------------- Update the program status ------------------------------------------
    UPDATE x_program_enrolled
    SET x_enrollment_status = 'ENROLLED',
      x_charge_date         = SYSDATE,
      x_next_charge_date    = get_next_cycle_date ( idx1.pgm_enroll2pgm_parameter, x_next_charge_date ),
      x_cooling_period      = NULL,
      x_update_stamp        = SYSDATE
    WHERE objid             = idx1.objid;
    -------------------------- Deliver Service days as applicable. --------------------------------------------
    billing_deliverservicedays (idx1.objid, l_error_code, l_error_msg);
    --CR49066
/*    IF (l_error_code != 0) THEN
      --DBMS_OUTPUT.PUT_LINE ( 'Error in delivering service days for  ' || idx1.x_esn || ' Enrolled : ' || TO_CHAR (idx1.objid) );
     --         RAISE APPERROR;
    END IF;*/
    -------------------------------- Service Days Delivery End -------------------------------------------------
  END LOOP;
EXCEPTION
WHEN OTHERS THEN
  l_error_code := - 900;
  l_error_msg  := SQLCODE || SUBSTR (SQLERRM, 1, 100);
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
      'BILLING_JOB_PKG.processZeroDollarProgram',
      l_error_code,
      l_error_msg,
      SYSDATE,
      'Enrollment  '
      || p_objid
      || ' could not be processed. ',
      2 -- MEDIUM
    );
  ------------------------ Exception Logging --------------------------------------------------------------------
  --DBMS_OUTPUT.PUT_LINE (SQLERRM);
END PROCESSZERODOLLARPROGRAM;
END BILLING_JOB_PKG;
/