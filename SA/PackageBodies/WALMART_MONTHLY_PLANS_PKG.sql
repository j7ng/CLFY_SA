CREATE OR REPLACE PACKAGE BODY sa."WALMART_MONTHLY_PLANS_PKG"
AS
   ---------------------------------------------------------------------------------------------
   --$RCSfile: WALMART_MONTHLY_PLANS_PKG.sql,v $
   --$Revision: 1.94 $
   --$Author: sinturi $
   --$Date: 2018/03/29 21:46:30 $
   --$ $Log: WALMART_MONTHLY_PLANS_PKG.sql,v $
   --$ Revision 1.94  2018/03/29 21:46:30  sinturi
   --$ Merged with prod version
   --$
   --$ Revision 1.88  2017/12/15 19:32:12  jcheruvathoor
   --$ CR52604	CRM TF Sim change stuck in carrier pending in switchbased transaction
   --$
   --$ Revision 1.87  2017/08/15 18:27:54  vnainar
   --$ CR52803 error fixed
   --$
   --$ Revision 1.86  2017/08/09 15:04:36  vnainar
   --$ CR52803 enable new order type for safelink batch
   --$
   --$ Revision 1.85  2017/05/16 10:37:31  smacha
   --$ Added logic for need to send order type APN on the Port Credit.
   --$
   --$ Revision 1.84  2017/03/22 15:38:41  sraman
   --$ CR47564-Update x_account_group service_plan_id with the ESN service plan objid for Non-Shared Group Plan
   --$
   --$ Revision 1.83  2017/03/21 18:01:39  sgangineni
   --$ CR47564 - Merged WFM changes with Rel 853 changes
   --$
   --$ Revision 1.81  2017/02/21 17:34:02  skota
   --$ Modified for UPDATE PCRF LOGIC
   --$
   --$ Revision 1.79  2017/01/17 19:25:27  vyegnamurthy
   --$ Merger with prod for CR47182
   --$
   --$ Revision 1.78  2017/01/12 15:38:42  smeganathan
   --$ CR46581 code changes to add bucket id in x_swb_tx_balance_bucket
   --$
   --$ Revision 1.76  2017/01/05 18:19:27  smeganathan
   --$ CR46581 Merged with 1/5 prod release
   --$
   --$ Revision 1.75  2017/01/04 21:04:47  tbaney
   --$ Modified logic for CR47024
   --$
   --$ Revision 1.72  2016/12/27 18:43:26  smeganathan
   --$ CR44729 code changes to get bucket usage from ig_trans_bucket
   --$
   --$ Revision 1.71  2016/12/22 00:17:26  tbaney
   --$ Correct into.
   --$
   --$ Revision 1.70  2016/12/22 00:08:46  tbaney
   --$ Added check for SPECIAL PLANS
   --$
   --$ Revision 1.69  2016/12/19 21:42:46  tbaney
   --$ Added logic for Plan type CR47024.
   --$
   --$ Revision 1.68  2016/12/01 22:25:28  vyegnamurthy
   --$ CR46073
   --$
   --$ Revision 1.67  2016/11/03 16:01:08  skota
   --$ Merged with prod copy
   --$
   --$ Revision 1.66  2016/10/25 14:45:13  sraman
   --$ CR42895 - Merge with production code released on 10/25
   --$
   --$ Revision 1.65  2016/10/19 22:31:15  rpednekar
   --$ 43254
   --$
   --$ Revision 1.61  2016/08/03 18:55:17  ddudhankar
   --$ CR43682 - Changes after latest prod deployment
   --$
   --$ Revision 1.59  2016/06/30 23:18:28  pamistry
   --$ CR43819 - CRM: Simple Mobile RTR Redemptionto populate ILD tranasaction for Provision ILD Benefit
   --$
   --$ Revision 1.58  2016/06/30 19:25:56  pamistry
   --$ CR43819 - CRM: Simple Mobile RTR Redemptionto populate ILD tranasaction for Provision ILD Benefit
   --$
   --$ Revision 1.57  2016/04/22 20:37:56  jpena
   --$ Add skip pcrf subscriber flag to monthly plans call.
   --$
   --$ Revision 1.56  2016/04/21 19:42:40  skota
   --$ Merged the code with CR41784
   --$
   --$ Revision 1.55  2016/04/18 15:22:24  vnainar
   --$ CR41784 merged with PROD version 1.49
   --$
   --$ Revision 1.54  2016/04/01 22:01:37  vnainar
   --$ CR41784 update table_part_inst carrier id for CR safelink minutes delivery action item
   --$
   --$ Revision 1.53  2016/03/25 17:34:01  skota
   --$ for 39608 changes for TMO
   --$
   --$ Revision 1.52  2016/03/24 22:22:38  skota
   --$ for 39608 changes in sp set zero ut max procedure
   --$
   --$ Revision 1.51  2016/03/24 15:01:07  skota
   --$ for 39608 changes in sp set zero ut max procedure
   --$
   --$ Revision 1.50  2016/03/18 14:10:01  skota
   --$ for 39608 changes in sp set zero ut max procedure
   --$
   --$ Revision 1.49 2016/01/20 17:28:13 jarza
   --$ CR40388
   --$
   --$ Revision 1.48 2015/11/26 19:22:49 vnainar
   --$ CR38927 bucket hardcoding removed for table_x_zero_out_max
   --$
   --$ Revision 1.47 2015/11/19 21:11:06 vnainar
   --$ CR38927 table_x_zero_out_max bucket hardcoding removed with bucket_param table
   --$
   --$ Revision 1.46 2015/11/03 22:32:24 vnainar
   --$ CR30860 tmo cursor to insert into table_x_zero_out_max modified to select only if any of the buckets is not null
   --$
   --$ Revision 1.45 2015/10/30 22:25:34 vnainar
   --$ CR30860 table_x_zero_out_max cursor fixed
   --$
   --$ Revision 1.44 2015/10/30 21:49:24 vnainar
   --$ CR30860 distinct added buckets query for TMO
   --$
   --$ Revision 1.43 2015/10/30 21:39:20 vnainar
   --$ CR30860 removed bucket_type in cursor table_x_zero_out_max
   --$
   --$ Revision 1.42 2015/10/30 21:04:48 vnainar
   --$ CR30860 added overloaded function set_sf_zero_out_max to insert free voice,tet,data to table_x_zero_out_max
   --$
   --$ Revision 1.41 2015/09/08 16:28:34 vyegnamurthy
   --$ CR30457
   --$
   --$ Revision 1.40 2015/08/24 21:51:17 vyegnamurthy
   --$ CR30457
   --$
   --$ Revision 1.39 2015/07/02 20:16:21 rpednekar
   --$ Changes done for CR35193
   --$
   --$ Revision 1.38 2015/06/30 23:31:55 aganesan
   --$ CR36122 - Super Carrier Release5 changes.
   --$
   --$ Revision 1.36 2015/04/27 13:32:49 vyegnamurthy
   --$ ATT Carrier Switch
   --$
   --$ Revision 1.35 2015/02/09 22:53:43 pvenkata
   --$ NT Surepay
   --$
   --$ Revision 1.34 2015/02/09 22:41:39 pvenkata
   --$ NT Sure Pay
   --$
   --$ Revision 1.33 2014/01/27 17:06:42 mvadlapally
   --$ CR26069 TTC transactions
   --$
   --$ Revision 1.32 2013/09/30 13:01:49 mvadlapally
   --$ CR26071 TF Surepay - Change to INBOUND Procedure
   --$
   --$ Revision 1.31 2013/09/11 21:36:02 mvadlapally
   --$ CR23513 TF Sureapy
   --$
   --$ Revision 1.30 2013/09/10 02:47:37 mvadlapally
   --$ CR23513 TF Surepay
   --$
   --$ Revision 1.26 2013/09/04 22:30:28 mvadlapally
   --$ CR23513 TF Surepay
   --$
   --$ Revision 1.25 2013/08/22 23:49:31 mvadlapally
   --$ CR23513 TF Surepay
   --$
   --$ Revision 1.24 2013/03/13 18:18:00 ymillan
   --$ CR22452 CR23775
   --$
   --$ Revision 1.23 2013/01/11 21:58:23 ymillan
   --$ CR20403 RIM Project
   --$
   --$ Revision 1.22 2012/08/07 20:36:49 icanavan
   --$ TELCEL Add a / minor change
   --$
   --$ Revision 1.21 2012/07/30 21:23:37 icanavan
   --$ TELCESL modifications to use org_flow
   --$
   --$ Revision 1.20 2012/01/27 20:53:18 icanavan
   --$ merge with production
   --$
   --$ Revision 1.18 2012/01/18 14:17:50 kacosta
   --$ CR19321 IG Failed Log Update
   --$
   --$ Revision 1.16 2012/01/12 15:03:56 kacosta
   --$ CR19321 IG Failed Log Update
   --$
   --$ Revision 1.15 2012/01/12 14:26:59 kacosta
   --$ CR19321 IG Failed Log Update
   --$
   --$ Revision 1.13 2011/11/09 20:10:41 pmistry
   --$ Completing SWB Transaction created against PIR while doing complete port.
   --$
   ---------------------------------------------------------------------------------------------
   /******************************************************************************/
   /*    Copyright   2009 Tracfone  Wireless Inc. All rights reserved            */
   /*                                                                            */
   /* NAME:         WALMART_MONTHLY_PLANS_PKG                                          */
   /* PURPOSE:      WALMART_MONTHLY_PLANS Straight Talk SUREPAY                                       */
   /* FREQUENCY:                                                                 */
   /* PLATFORMS:    Oracle 9.2.0.7 AND newer versions.                             */
   /*                                                                            */
   /* REVISIONS:                                                                 */
   /* VERSION  DATE        WHO          PURPOSE                                  */
   /* -------  ---------- -----  ---------------------------------------------   */
   /*  1.0/1.4   04/24/2009   CLindner    Initial  Revision                               */
   /*  1.5       06/19/2009   VAdapa      STUL                               */
   /*  1.6       06/22/2009   VAdapa    STUL - no updates to X_PROGRAM_ENROLLED                               */
   /*  1.7       06/22/09    VAdapa     correct cr# CR10766               */
   /*  1.8       10/08/09   SKuthadi    ST_BUNDLE_II                       */
   /*  1.9       10/12/09   SKuthadi    ST_BUNDLE_II_A                     */
   /*  1.11      10/19/09   Clinder     CR11246 and merge with CR11975     */
   /*  1.12      12/14/09   Clinder     CR11246 move sp_close_action_item out of the loop */
   /*  1.13      05/06/10   Skuthadi    CR11971 ST_GSM                                                                     */
   /*  1.4       08/16/10   PMistry     CR13531 STCC as we are changing Order Type in IGATE from AP to PAP in case of VERIZON_PP */
   /*  1.5   09/04/10   PMistry     CR13531 STCC as we are changing Order Type in IGATE from CR to PCR in case of VERIZON_PP */
   /*  1.6   09/28/10   PMistry     CR13980 Need to handle CRU as CR */
   /*  1.7       10/04/10   Nguada      CR13085 Universal Branding*/
   /*  1.8-1.10  10/12/10   Nguada      CR13085 Universal Branding*/
   /*  1.8-1.10  08/16/11   Skuthadi    CR16308 SPRINT            */
   /*  1.18      12/28/11   ICanavan    CR17413 LG L95G (NT10 Unlimited GSM Postpaid)           */
   /*  1.19-1.20 01/27/12   ICanavan    merge CR17413 CR19552 and CR19321                       */
   /*  1.21-1.22 08/07/12   ICanavan    CR20451 | CR20854: Add TELCEL Brand                     */
   /*  1.23                 YMillan     CR20403 RIM Project      */
   /*  1.24                 YMillan     CR23775/CR22798 RIM GSM BYOP Project (SIMPLE MOBILE)     */
   close_action_item_out   NUMBER := 0;                              --CR11246
   out_errorcode           NUMBER := 0;                             -- CR23513
   out_errormsg            VARCHAR2 (300) := NULL;                  -- CR23513

   PROCEDURE Run_all_no_ap (p_div   IN NUMBER DEFAULT 1,
                            p_rem   IN NUMBER DEFAULT 0)
   IS
      CURSOR c1
      IS
         SELECT IGT.*, IGT.ROWID IG_ROWID
           FROM gw1.ig_transaction IGT
          WHERE    ( order_type IN ('BI', 'CR', 'CRU', 'EU', 'DB', 'PCR') -- CR13980 PM 09/28/2010.
	            OR EXISTS (SELECT 1 FROM sa.x_ig_order_type iot  WHERE igt.order_type = iot.x_ig_order_type AND iot.safelink_batch_flag= 'Y'))
                  --CR52803 enable new order type similar to CR-Credit
                AND status = 'W'
                AND MOD (transaction_id, p_div) = p_rem;

      --CR19321 Start KACOSTA 01/12/2012
      --CR43682 cursor modified
      CURSOR get_errored_transactions_curs
      IS
         SELECT action_item_id,
                carrier_id,
                order_type,
                MIN,
                esn,
                esn_hex,
                old_esn,
                old_esn_hex,
                pin,
                phone_manf,
                end_user,
                account_num,
                market_code,
                rate_plan,
                ld_provider,
                sequence_num,
                dealer_code,
                transmission_method,
                fax_num,
                online_num,
                email,
                network_login,
                network_password,
                system_login,
                system_password,
                template,
                com_port,
                status,
                status_message,
                trans_prof_key,
                q_transaction,
                fax_num2,
                creation_date,
                update_date,
                blackout_wait,
                transaction_id,
                technology_flag,
                voice_mail,
                voice_mail_package,
                caller_id,
                caller_id_package,
                call_waiting,
                call_waiting_package,
                digital_feature_code,
                state_field,
                zip_code,
                msid,
                new_msid_flag,
                sms,
                sms_package,
                iccid,
                old_min,
                digital_feature,
                ota_type,
                rate_center_no,
                application_system,
                subscriber_update,
                download_date,
                prl_number,
                amount,
                balance,
                LANGUAGE,
                exp_date,
                SYSDATE AS logged_date,
                'WALMART_MONTHLY_PLANS_PKG.RUN_ALL_NO_AP' AS logged_by,
                x_mpn                                      --added for CR37839
                     ,
                x_mpn_code,
                x_pool_name,
                carrier_initial_trans_time,
                carrier_end_trans_time
           FROM gw1.ig_transaction
          WHERE     (order_type IN ('BI', 'CR', 'CRU', 'EU', 'DB', 'PCR')
	             OR EXISTS (SELECT 1 FROM sa.x_ig_order_type iot WHERE order_type = iot.x_ig_order_type AND iot.safelink_batch_flag= 'Y'))
	            --CR52803 enable new order type similar to CR-Credit
                AND status = 'E'
                AND status_message <> 'CREATE SIM EXCHANGE CASE'
                AND MOD (transaction_id, p_div) = p_rem;

      --
      get_errored_transactions_rec   get_errored_transactions_curs%ROWTYPE;

      --CR19321 End KACOSTA 01/12/2012
      TYPE tab_get_errored_trans_cur IS TABLE OF get_errored_transactions_curs%ROWTYPE
                                           INDEX BY PLS_INTEGER;

      rec_get_errored_trans_cur      TAB_GET_ERRORED_TRANS_CUR;
      --  CR43254
      l_final_ig_status              gw1.ig_transaction.status%TYPE;
      fota_error_code                NUMBER;
      fota_error_msg                 VARCHAR2 (1000);
      o_response                     VARCHAR2(1000);  --CR 47142
   --  CR43254
   BEGIN
      FOR c1_rec IN c1
      LOOP
         Run_single (c1_rec.transaction_id);

         COMMIT;            -- included for CR43682 to avoid locking of tables

	 --CR 47142, Added logic for need to send order type APN on the Port Credit instead Port Request.
         apn_requests_pkg.create_ig_apn_requests ( i_transaction_id => c1_rec.transaction_id ,
                                                   o_response       => o_response ) ;

         --CR43254
         BEGIN
            SELECT status
              INTO l_final_ig_status
              FROM gw1.ig_transaction
             WHERE ROWID = c1_rec.ig_rowid;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         IF l_final_ig_status = 'S'
         THEN
            --CR43254 FOTA
            BEGIN
               sa.fota_service_pkg.
                Process_fota_camp_trans (
                  ip_transaction_id     => c1_rec.transaction_id,
                  ip_call_trans_objid   => NULL,
                  op_err_code           => fota_error_code,
                  op_err_msg            => fota_error_msg);
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         --CR43254 FOTA
         END IF;
      --CR43254
      END LOOP;

      --CR19321 Start KACOSTA 01/12/2012
      IF get_errored_transactions_curs%ISOPEN
      THEN
         --
         CLOSE get_errored_transactions_curs;
      --
      END IF;

      --
      /*
      OPEN get_errored_transactions_curs;
      --
      LOOP
        --
        FETCH get_errored_transactions_curs INTO get_errored_transactions_rec;
        --
        EXIT WHEN get_errored_transactions_curs%NOTFOUND;
        --
        INSERT INTO gw1.ig_failed_log
          (action_item_id
          ,carrier_id
          ,order_type
          ,MIN
          ,esn
          ,esn_hex
          ,old_esn
          ,old_esn_hex
          ,pin
          ,phone_manf
          ,end_user
          ,account_num
          ,market_code
          ,rate_plan
          ,ld_provider
          ,sequence_num
          ,dealer_code
          ,transmission_method
          ,fax_num
          ,online_num
          ,email
          ,network_login
          ,network_password
          ,system_login
          ,system_password
          ,template
          ,com_port
          ,status
          ,status_message
          ,trans_prof_key
          ,q_transaction
          ,fax_num2
          ,creation_date
          ,update_date
          ,blackout_wait
          ,transaction_id
          ,technology_flag
          ,voice_mail
          ,voice_mail_package
          ,caller_id
          ,caller_id_package
          ,call_waiting
          ,call_waiting_package
          ,digital_feature_code
          ,state_field
          ,zip_code
          ,msid
          ,new_msid_flag
          ,sms
          ,sms_package
          ,iccid
          ,old_min
          ,digital_feature
          ,ota_type
          ,rate_center_no
          ,application_system
          ,subscriber_update
          ,download_date
          ,prl_number
          ,amount
          ,balance
          ,LANGUAGE
          ,exp_date
          ,logged_date
          ,logged_by
          ,X_MPN
          ,X_MPN_CODE
          ,X_POOL_NAME
          ,CARRIER_INITIAL_TRANS_TIME
          ,CARRIER_END_TRANS_TIME)--end CR37839
        VALUES
          (get_errored_transactions_rec.action_item_id
          ,get_errored_transactions_rec.carrier_id
          ,get_errored_transactions_rec.order_type
          ,get_errored_transactions_rec.min
          ,get_errored_transactions_rec.esn
          ,get_errored_transactions_rec.esn_hex
          ,get_errored_transactions_rec.old_esn
          ,get_errored_transactions_rec.old_esn_hex
          ,get_errored_transactions_rec.pin
          ,get_errored_transactions_rec.phone_manf
          ,get_errored_transactions_rec.end_user
          ,get_errored_transactions_rec.account_num
          ,get_errored_transactions_rec.market_code
          ,get_errored_transactions_rec.rate_plan
          ,get_errored_transactions_rec.ld_provider
          ,get_errored_transactions_rec.sequence_num
          ,get_errored_transactions_rec.dealer_code
          ,get_errored_transactions_rec.transmission_method
          ,get_errored_transactions_rec.fax_num
          ,get_errored_transactions_rec.online_num
          ,get_errored_transactions_rec.email
          ,get_errored_transactions_rec.network_login
          ,get_errored_transactions_rec.network_password
          ,get_errored_transactions_rec.system_login
          ,get_errored_transactions_rec.system_password
          ,get_errored_transactions_rec.template
          ,get_errored_transactions_rec.com_port
          ,get_errored_transactions_rec.status
          ,get_errored_transactions_rec.status_message
          ,get_errored_transactions_rec.trans_prof_key
          ,get_errored_transactions_rec.q_transaction
          ,get_errored_transactions_rec.fax_num2
          ,get_errored_transactions_rec.creation_date
          ,get_errored_transactions_rec.update_date
          ,get_errored_transactions_rec.blackout_wait
          ,get_errored_transactions_rec.transaction_id
          ,get_errored_transactions_rec.technology_flag
          ,get_errored_transactions_rec.voice_mail
          ,get_errored_transactions_rec.voice_mail_package
          ,get_errored_transactions_rec.caller_id
          ,get_errored_transactions_rec.caller_id_package
          ,get_errored_transactions_rec.call_waiting
          ,get_errored_transactions_rec.call_waiting_package
          ,get_errored_transactions_rec.digital_feature_code
          ,get_errored_transactions_rec.state_field
          ,get_errored_transactions_rec.zip_code
          ,get_errored_transactions_rec.msid
          ,get_errored_transactions_rec.new_msid_flag
          ,get_errored_transactions_rec.sms
          ,get_errored_transactions_rec.sms_package
          ,get_errored_transactions_rec.iccid
          ,get_errored_transactions_rec.old_min
          ,get_errored_transactions_rec.digital_feature
          ,get_errored_transactions_rec.ota_type
          ,get_errored_transactions_rec.rate_center_no
          ,get_errored_transactions_rec.application_system
          ,get_errored_transactions_rec.subscriber_update
          ,get_errored_transactions_rec.download_date
          ,get_errored_transactions_rec.prl_number
          ,get_errored_transactions_rec.amount
          ,get_errored_transactions_rec.balance
          ,get_errored_transactions_rec.language
          ,get_errored_transactions_rec.exp_date
          ,SYSDATE
          ,'WALMART_MONTHLY_PLANS_PKG.RUN_ALL_NO_AP'
           ,get_errored_transactions_rec.X_MPN--added for CR37839
          ,get_errored_transactions_rec.X_MPN_CODE
          ,get_errored_transactions_rec.X_POOL_NAME
          ,get_errored_transactions_rec.CARRIER_INITIAL_TRANS_TIME
          ,get_errored_transactions_rec.CARRIER_END_TRANS_TIME);--end CR37839
        --
        UPDATE gw1.ig_transaction
           SET status = 'F'
         WHERE transaction_id = get_errored_transactions_rec.transaction_id;
        --
        COMMIT;
        --
      END LOOP;
      --
      CLOSE get_errored_transactions_curs;
      */
      --CR43682 changes
      OPEN get_errored_transactions_curs;

      LOOP
         FETCH get_errored_transactions_curs
         BULK COLLECT INTO rec_get_errored_trans_cur
         LIMIT 100;

         EXIT WHEN rec_get_errored_trans_cur.COUNT = 0;

         FORALL i IN 1 .. rec_get_errored_trans_cur.COUNT
            INSERT INTO gw1.ig_failed_log (action_item_id,
                                           carrier_id,
                                           order_type,
                                           MIN,
                                           esn,
                                           esn_hex,
                                           old_esn,
                                           old_esn_hex,
                                           pin,
                                           phone_manf,
                                           end_user,
                                           account_num,
                                           market_code,
                                           rate_plan,
                                           ld_provider,
                                           sequence_num,
                                           dealer_code,
                                           transmission_method,
                                           fax_num,
                                           online_num,
                                           email,
                                           network_login,
                                           network_password,
                                           system_login,
                                           system_password,
                                           template,
                                           com_port,
                                           status,
                                           status_message,
                                           trans_prof_key,
                                           q_transaction,
                                           fax_num2,
                                           creation_date,
                                           update_date,
                                           blackout_wait,
                                           transaction_id,
                                           technology_flag,
                                           voice_mail,
                                           voice_mail_package,
                                           caller_id,
                                           caller_id_package,
                                           call_waiting,
                                           call_waiting_package,
                                           digital_feature_code,
                                           state_field,
                                           zip_code,
                                           msid,
                                           new_msid_flag,
                                           sms,
                                           sms_package,
                                           iccid,
                                           old_min,
                                           digital_feature,
                                           ota_type,
                                           rate_center_no,
                                           application_system,
                                           subscriber_update,
                                           download_date,
                                           prl_number,
                                           amount,
                                           balance,
                                           LANGUAGE,
                                           exp_date,
                                           logged_date,
                                           logged_by,
                                           x_mpn,
                                           x_mpn_code,
                                           x_pool_name,
                                           carrier_initial_trans_time,
                                           carrier_end_trans_time) --end CR37839
                 VALUES (
                           Rec_get_errored_trans_cur (i).action_item_id,
                           Rec_get_errored_trans_cur (i).carrier_id,
                           Rec_get_errored_trans_cur (i).order_type,
                           Rec_get_errored_trans_cur (i).MIN,
                           Rec_get_errored_trans_cur (i).esn,
                           Rec_get_errored_trans_cur (i).esn_hex,
                           Rec_get_errored_trans_cur (i).old_esn,
                           Rec_get_errored_trans_cur (i).old_esn_hex,
                           Rec_get_errored_trans_cur (i).pin,
                           Rec_get_errored_trans_cur (i).phone_manf,
                           Rec_get_errored_trans_cur (i).end_user,
                           Rec_get_errored_trans_cur (i).account_num,
                           Rec_get_errored_trans_cur (i).market_code,
                           Rec_get_errored_trans_cur (i).rate_plan,
                           Rec_get_errored_trans_cur (i).ld_provider,
                           Rec_get_errored_trans_cur (i).sequence_num,
                           Rec_get_errored_trans_cur (i).dealer_code,
                           Rec_get_errored_trans_cur (i).transmission_method,
                           Rec_get_errored_trans_cur (i).fax_num,
                           Rec_get_errored_trans_cur (i).online_num,
                           Rec_get_errored_trans_cur (i).email,
                           Rec_get_errored_trans_cur (i).network_login,
                           Rec_get_errored_trans_cur (i).network_password,
                           Rec_get_errored_trans_cur (i).system_login,
                           Rec_get_errored_trans_cur (i).system_password,
                           Rec_get_errored_trans_cur (i).template,
                           Rec_get_errored_trans_cur (i).com_port,
                           Rec_get_errored_trans_cur (i).status,
                           Rec_get_errored_trans_cur (i).status_message,
                           Rec_get_errored_trans_cur (i).trans_prof_key,
                           Rec_get_errored_trans_cur (i).q_transaction,
                           Rec_get_errored_trans_cur (i).fax_num2,
                           Rec_get_errored_trans_cur (i).creation_date,
                           Rec_get_errored_trans_cur (i).update_date,
                           Rec_get_errored_trans_cur (i).blackout_wait,
                           Rec_get_errored_trans_cur (i).transaction_id,
                           Rec_get_errored_trans_cur (i).technology_flag,
                           Rec_get_errored_trans_cur (i).voice_mail,
                           Rec_get_errored_trans_cur (i).voice_mail_package,
                           Rec_get_errored_trans_cur (i).caller_id,
                           Rec_get_errored_trans_cur (i).caller_id_package,
                           Rec_get_errored_trans_cur (i).call_waiting,
                           Rec_get_errored_trans_cur (i).call_waiting_package,
                           Rec_get_errored_trans_cur (i).digital_feature_code,
                           Rec_get_errored_trans_cur (i).state_field,
                           Rec_get_errored_trans_cur (i).zip_code,
                           Rec_get_errored_trans_cur (i).msid,
                           Rec_get_errored_trans_cur (i).new_msid_flag,
                           Rec_get_errored_trans_cur (i).sms,
                           Rec_get_errored_trans_cur (i).sms_package,
                           Rec_get_errored_trans_cur (i).iccid,
                           Rec_get_errored_trans_cur (i).old_min,
                           Rec_get_errored_trans_cur (i).digital_feature,
                           Rec_get_errored_trans_cur (i).ota_type,
                           Rec_get_errored_trans_cur (i).rate_center_no,
                           Rec_get_errored_trans_cur (i).application_system,
                           Rec_get_errored_trans_cur (i).subscriber_update,
                           Rec_get_errored_trans_cur (i).download_date,
                           Rec_get_errored_trans_cur (i).prl_number,
                           Rec_get_errored_trans_cur (i).amount,
                           Rec_get_errored_trans_cur (i).balance,
                           Rec_get_errored_trans_cur (i).LANGUAGE,
                           Rec_get_errored_trans_cur (i).exp_date,
                           Rec_get_errored_trans_cur (i).logged_date,
                           Rec_get_errored_trans_cur (i).logged_by,
                           Rec_get_errored_trans_cur (i).x_mpn,
                           Rec_get_errored_trans_cur (i).x_mpn_code,
                           Rec_get_errored_trans_cur (i).x_pool_name,
                           Rec_get_errored_trans_cur (i).
                            carrier_initial_trans_time,
                           Rec_get_errored_trans_cur (i).
                            carrier_end_trans_time);
      END LOOP;

      --
      CLOSE get_errored_transactions_curs;

      --
      OPEN get_errored_transactions_curs;

      LOOP
         FETCH get_errored_transactions_curs
         BULK COLLECT INTO rec_get_errored_trans_cur
         LIMIT 100;

         EXIT WHEN rec_get_errored_trans_cur.COUNT = 0;

         --
         FORALL i IN 1 .. rec_get_errored_trans_cur.COUNT
            --
            UPDATE gw1.ig_transaction
               SET status = 'F'
             WHERE transaction_id =
                      Rec_get_errored_trans_cur (i).transaction_id;

         --
         COMMIT;
      --
      END LOOP;

      --
      CLOSE get_errored_transactions_curs;
   --CR19321 End KACOSTA 01/12/2012
   --
   END;

   PROCEDURE Run_single (p_transaction_id          IN NUMBER,
                         i_skip_pcrf_update_flag   IN VARCHAR2 DEFAULT 'N')
   IS
      -- Super Carrier Changes (CR35396, CR29586)
      l_error_code             NUMBER;
      l_error_msg              VARCHAR2 (1000);
      o_response               VARCHAR2(1000); --CR47564 --WFM
      gt sa.group_type := sa.group_type();     --CR47564 --WFM
      g sa.group_type  := sa.group_type();     --CR47564 --WFM
      -----------------------
      CURSOR c1
      IS
         /*    SELECT a.* ,
                (
                SELECT X_TASK2X_CALL_TRANS
             FROM table_task t
                   WHERE task_id = a.action_item_id) call_trans_objid
             FROM gw1.ig_transaction a
             WHERE transaction_id = p_transaction_id; */
         -- CR17793 Start PM 11/09/2011 adding new table (table_x_call_trans) in join condition.
         SELECT a.*,
                t.x_task2x_call_trans call_trans_objid,              --CR11975
                t.objid task_objid,                                  --CR11246
                ct.x_transact_date ct_transact_date,                -- CR17793
                ct.x_action_type ct_action_type,                    -- CR17793
                ct.x_call_trans2carrier                              --CR41784
                                       ,
                ct.call_trans2site_part,                             -- CR43819
		ct.x_reason                                          --CR55066 and CR55069
           FROM table_task t, gw1.ig_transaction a, table_x_call_trans ct -- CR
          WHERE     t.task_id = a.action_item_id
                AND ct.objid = t.x_task2x_call_trans
                AND transaction_id = p_transaction_id;

      c1_rec                   c1%ROWTYPE;

      CURSOR cur_last_swb_txn (
         c_esn              VARCHAR2,
         c_transact_date    DATE)
      IS
         SELECT ct.objid call_trans_objid, swb.objid swb_objid, swb.status
           FROM table_x_call_trans ct, x_switchbased_transaction swb
          WHERE swb.x_sb_trans2x_call_trans = ct.objid
                AND ct.objid IN
                       (SELECT MAX (objid)
                          FROM table_x_call_trans
                         WHERE     x_service_id = c_esn
                               AND x_transact_date < c_transact_date
                               AND x_action_type = '1');

      rec_last_swb_txn         cur_last_swb_txn%ROWTYPE;

      -- CR17793 End PM 11/09/2011 adding new table (table_x_call_trans) in join condition.
      --CR17413 LG L95G (NT10 Unlimited GSM Postpaid) Changed cursor for more
      -- flexibility.  Now, the NET10 LG95 requires similar data setup as the Straight Talk 45C
      --CURSOR chk_st_gsm_cur(c_esn IN VARCHAR2)   -- CR11971 ST_GSM
      --IS
      --  SELECT pcv.x_param_value, pn.x_technology
      --  FROM table_x_part_class_params pcp, table_x_part_class_values pcv,table_part_num pn,
      --       table_part_inst pi,table_mod_level ml,table_bus_org bo
      --  WHERE 1=1
      --  AND pcp.x_param_name = 'NON_PPE'
      --  AND pi.part_serial_no = c_esn
      --  AND pn.part_num2bus_org = bo.objid
      --  AND bo.org_id = 'STRAIGHT_TALK'
      --  AND pcv.value2class_param = pcp.objid
      --  AND pcv.value2part_class = pn.part_num2part_class
      --  AND ml.part_info2part_num = pn.objid
      --  AND pi.n_part_inst2part_mod = ml.objid;
      --CR20451 | CR20854: Add TELCEL Brand
      --CURSOR chk_st_gsm_cur(c_esn IN VARCHAR2)
      --IS
      --  Select
      --    pc.objid,
      --    (select param_value
      --       from pc_params_view ppv
      --      where ppv.part_class = pc.name
      --        and param_name = 'TECHNOLOGY') TECH,
      --    (select param_value
      --       from pc_params_view ppv
      --       where ppv.part_class = pc.name
      --         and param_name = 'BUS_ORG')   BUS,
      --    (select param_value
      --       from pc_params_view ppv
      --      where ppv.part_class = pc.name
      --        and param_name = 'DLL')        DLL,
      --    (select param_value
      --       from pc_params_view ppv
      --       where ppv.part_class = pc.name
      --         and param_name = 'NON_PPE')   NON_PPE
      --  from
      --     table_part_inst pi,
      --     table_mod_level ml,
      --     table_part_num pn,
      --     table_part_class pc
      --  WHERE 1=1
      --    and PI.PART_SERIAL_NO = c_esn
      --    and pi.n_part_inst2part_mod=ml.objid
      --    and ml.part_info2part_num=pn.objid
      --    and pn.part_num2part_class=pc.objid ;
      -- CR17413 END LG L95G (NT10 Unlimited GSM Postpaid)
      -- ADDED ORG_FLOW To this cursor for TELCEL
      CURSOR chk_st_gsm_cur (
         c_esn IN VARCHAR2)
      IS
         SELECT pc.objid,
                (SELECT param_value
                   FROM pc_params_view ppv
                  WHERE ppv.part_class = pc.name
                        AND param_name = 'TECHNOLOGY')
                   TECH,
                (SELECT param_value
                   FROM pc_params_view ppv
                  WHERE ppv.part_class = pc.name AND param_name = 'BUS_ORG')
                   BUS,
                (SELECT param_value
                   FROM pc_params_view ppv
                  WHERE ppv.part_class = pc.name AND param_name = 'DLL')
                   DLL,
                (SELECT param_value
                   FROM pc_params_view ppv
                  WHERE ppv.part_class = pc.name AND param_name = 'NON_PPE')
                   NON_PPE,
                (SELECT param_value
                   FROM pc_params_view ppv
                  WHERE ppv.part_class = pc.name
                        AND param_name = 'BALANCE_METERING')
                   BALANCE_METERING,
                --CR32451 NT Surepay 02/09/2015
                bo.org_flow,
                bo.org_id                        -- CR43819   added bus_org_id
           FROM table_part_inst pi,
                table_mod_level ml,
                table_part_num pn,
                table_part_class pc,
                table_bus_org bo
          WHERE     1 = 1
                AND PI.part_serial_no = c_esn  -- tc test '100000000013184068'
                AND pi.n_part_inst2part_mod = ml.objid
                AND ml.part_info2part_num = pn.objid
                AND pn.part_num2part_class = pc.objid
                AND pn.part_num2bus_org = bo.objid;

      rec_chk_st_gsm           chk_st_gsm_cur%ROWTYPE;

      CURSOR c2 (
         c_esn IN VARCHAR2)
      IS
         SELECT 1 col
           FROM x_program_parameters pp, x_program_enrolled pe
          WHERE     1 = 1
                AND pp.x_is_recurring = 1
                AND pp.x_prog_class || '' = 'SWITCHBASE'
                AND pp.objid = pe.pgm_enroll2pgm_parameter
                AND pe.x_esn = c_esn;

      c2_rec                   c2%ROWTYPE;

      CURSOR c3 (
         c_transaction_id IN NUMBER)
      IS
         SELECT igb.measure_unit,
                igtb.transaction_id,
                igtb.bucket_id,
                igtb.recharge_date,
                igtb.bucket_balance,
                igtb.bucket_value,
                igtb.bucket_usage,                                  -- CR44729
                igtb.expiration_date,
                igb.bucket_desc
           FROM gw1.ig_buckets igb,
                gw1.ig_transaction_buckets igtb,
                ig_transaction ig
          WHERE     1 = 1
                AND igb.bucket_id = igtb.bucket_id
                AND igtb.direction != 'OUTBOUND'
                AND Igtb.transaction_id = c_transaction_id
                AND ig.transaction_id = igtb.transaction_id
                AND IGB.rate_plan = ig.rate_plan;

      ----------------
      -- CR20403
      ----------------
      /* CR23775/CR22798
          CURSOR ESN_BB_curs  (p_esn IN VARCHAR2) IS
          select bo.org_id, pc.name, pn.*
             from table_part_class pc, table_part_num pn , table_bus_org bo,  pc_params_view pv
                  ,table_part_inst pi, table_mod_level ml
            where pn.part_num2part_class = pc.objid
              and pv.part_class = pc.name
             and  pi.part_serial_no = p_esn
             and pi.n_part_inst2part_mod = ml.objid
             AND   ml.part_info2part_num = pn.objid
             and pc.objid = pn.part_num2part_class
             and pn.part_num2bus_org = bo.objid
             and  pv.param_name = 'OPERATING_SYSTEM'
             and pv.param_value = 'BBOS';
          ESN_BB_rec ESN_BB_curs%ROWTYPE;
      CR23775/CR22798  */
      op_msg                   VARCHAR2 (300) := ' ';
      op_status                VARCHAR2 (30) := ' ';
      ------------
      -- CR20403
      ------------
      v_gsm_post_pay           NUMBER := 0;
      lv_ild                   VARCHAR2 (30) := NULL;
      lv_account               VARCHAR2 (10);
      lv_x_ild_objid           NUMBER;
      ipl                      IG_PCRF_LOG_TYPE := Ig_pcrf_log_type ();
      ip                       IG_PCRF_LOG_TYPE := Ig_pcrf_log_type ();
      --CR42895 changes starts here
      lv_esn                   VARCHAR2 (200);
      lv_last_rate_plan_sent   VARCHAR2 (60);
      lv_is_swb_carr           VARCHAR2 (200);
      lv_error_code            NUMBER;
      lv_error_message         VARCHAR2 (200);
      --CR42895 changes ends here

      v_service_plan_type      sa.service_plan_feat_pivot_mv.service_plan_group%TYPE; -- CR47024
      x_service_plan_rec       sa.x_service_plan%ROWTYPE;
      --CR55066 and CR55069
      lv_ild_flag		VARCHAR2(1);
   BEGIN
      OPEN c1;

      FETCH c1 INTO c1_rec;

      IF c1%NOTFOUND
      THEN
         RETURN;
      END IF;

      CLOSE c1;

      --       OPEN c2(c1_rec.esn);
      --       FETCH c2
      --       INTO c2_rec;
      --           --IF c2%found --STUL CR10766
      --       IF c2%found and c1_rec.order_type = 'BI'
      --       THEN
      --          UPDATE X_program_enrolled SET x_update_stamp = SYSDATE,
      --          X_NEXT_CHARGE_DATE = c1_rec.exp_date
      --          WHERE x_esn = c1_rec.esn;
      --       END IF;
      --       CLOSE c2;
      --
      -- ST_GSM CR11971 Starts
      OPEN chk_st_gsm_cur (c1_rec.esn);

      FETCH chk_st_gsm_cur INTO rec_chk_st_gsm;

      --
      IF chk_st_gsm_cur%FOUND
      THEN
         -- ST_GSM CR11971 Skip Update x_switchbased_transaction,x_swb_tx_balance_bucket if ESN is ST GSM
         -- CR17413 (B) LG L95G  START , combine ST w/ non_ppe or NT10 with non_ppe and dll
         -- If Rec_Chk_St_Gsm.X_Param_Value = '1' And Rec_Chk_St_Gsm.X_Technology ='GSM' Then
         -- CR20451 | CR20854: Add TELCEL Brand   replace reference to STRAIGHT TALK with ORG_FLOW
         -- If Rec_Chk_St_Gsm.NON_PPE = '1'  And Rec_Chk_St_Gsm.Tech ='GSM'  And Rec_Chk_St_Gsm.bus = 'STRAIGHT_TALK'
         IF     rec_chk_st_gsm.non_ppe = '1'
            AND rec_chk_st_gsm.tech = 'GSM'
            AND rec_chk_st_gsm.org_flow = '3'
         THEN
            v_gsm_post_pay := 1;
         END IF;

         IF rec_chk_st_gsm.non_ppe = '1' -- And Rec_Chk_St_Gsm.Tech ='GSM'
            AND rec_chk_st_gsm.bus = 'NET10' AND rec_chk_st_gsm.dll <= 0
         THEN
            v_gsm_post_pay := 1;
         END IF;

         --CR42895 changes starts here
         lv_esn := c1_rec.esn;

         sa.
          Sp_swb_carr_rate_plan (
            ip_esn                   => lv_esn,
            op_last_rate_plan_sent   => lv_last_rate_plan_sent,
            op_is_swb_carr           => lv_is_swb_carr,
            op_error_code            => lv_error_code,
            op_error_message         => lv_error_message);


         -- CR47024
         x_service_plan_rec :=
            sa.service_plan.get_service_plan_by_esn (c1_rec.esn);

         BEGIN
            SELECT sa.
                    get_serv_plan_value (x_service_plan_rec.objid,
                                         'PLAN TYPE')
              INTO v_service_plan_type
              FROM DUAL;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_service_plan_type := NULL;
         END;

         -- CR47024 end

         --CR42895 changes ends here
         -- CR17413 (B) LG L95G END
         -- IF rec_chk_st_gsm.x_param_value = '1' and rec_chk_st_gsm.x_technology ='CDMA' THEN --CR13085
         -- IF rec_chk_st_gsm.x_technology ='CDMA' THEN  --CR13085
         -- CR20451 | CR20854: Add TELCEL Brand   replace reference to STRAIGHT TALK with ORG_FLOW
         -- IF rec_chk_st_gsm.tech ='CDMA' And Rec_Chk_St_Gsm.bus = 'STRAIGHT_TALK' THEN
         IF /*(rec_chk_st_gsm.tech ='CDMA' And Rec_Chk_St_Gsm.org_flow = '3') OR
                    (Rec_Chk_St_Gsm.org_flow = '1' AND Rec_Chk_St_Gsm.non_ppe = '1')   OR -- CR23513 TF Surepay 09/06/2013
                     (Rec_Chk_St_Gsm.org_flow = '2' AND Rec_Chk_St_Gsm.balance_metering = 'SUREPAY' ) */
            --CR32451 NT Surepay 02/09/2015
            (rec_chk_st_gsm.
              org_flow =
                '3')
            OR (rec_chk_st_gsm.org_flow = '1'
                AND rec_chk_st_gsm.non_ppe = '1')
            OR                                -- CR23513 TF Surepay 09/06/2013
               (rec_chk_st_gsm.org_flow = '2'
                AND rec_chk_st_gsm.balance_metering = 'SUREPAY')
            OR --ATT Carrier switch (Both CDMA and GSM should update as completed)
               (    rec_chk_st_gsm.org_flow = '2'
                AND rec_chk_st_gsm.tech = 'GSM'
                AND NVL (lv_is_swb_carr, 'X') = 'Switch Base'
                AND NVL (sa.Get_device_type (lv_esn), 'X') IN
                       ('MOBILE_BROADBAND', 'BYOT')) --CR42895 Net10 TMO Carrier Switch base Data device
            OR (    rec_chk_st_gsm.bus = 'TRACFONE'
                AND rec_chk_st_gsm.non_ppe = 0
                AND v_service_plan_type IN ('SL_UNL_PLANS', 'SPECIAL PLANS')) --CR47024
            OR (    rec_chk_st_gsm.bus = 'WFM') --CR47564 WFM
         THEN
            UPDATE x_switchbased_transaction
               SET --exp_date = c1_rec.exp_date,
                   x_value = c1_rec.balance, status = 'Completed'
             WHERE x_sb_trans2x_call_trans = c1_rec.call_trans_objid;

            -- CR17793 Start PM 11/09/2011
            IF c1_rec.order_type IN ('CR', 'CRU', 'PCR', 'ACR')
               AND c1_rec.ct_action_type = '111'
            THEN
               OPEN cur_last_swb_txn (c1_rec.esn, c1_rec.ct_transact_date);

               FETCH cur_last_swb_txn INTO rec_last_swb_txn;

               IF cur_last_swb_txn%FOUND
                  AND rec_last_swb_txn.status <> 'Completed'
               THEN
                  UPDATE x_switchbased_transaction
                     SET status = 'Completed', x_value = c1_rec.balance
                   WHERE objid = rec_last_swb_txn.swb_objid;
               END IF;

               CLOSE cur_last_swb_txn;
            END IF;

            -- CR17793 End PM 11/09/2011
            --
            FOR c3_rec IN c3 (c1_rec.transaction_id)
            LOOP
               INSERT INTO x_swb_tx_balance_bucket (objid,
                                                    balance_bucket2x_swb_tx,
                                                    x_type,
                                                    x_value,
                                                    bucket_id,      -- CR44729
                                                    bucket_usage,   -- CR44729
                                                    recharge_date,
                                                    expiration_date,
                                                    bucket_desc)
                    VALUES (
                              sequ_x_balance_bucket.NEXTVAL,
                              (SELECT st.objid
                                 FROM x_switchbased_transaction st
                                WHERE x_sb_trans2x_call_trans =
                                         c1_rec.call_trans_objid),
                              c3_rec.measure_unit,
                              c3_rec.bucket_balance,
                              c3_rec.bucket_id,                     -- CR44729
                              c3_rec.bucket_usage,                  -- CR44729
                              c3_rec.recharge_date,
                              c3_rec.recharge_date,
                              c3_rec.bucket_desc);
            -------------------------------------------------------------------------------------------
            -- cwl 9/10/09 close all action items  --CR11246
            -------------------------------------------------------------------------------------------
            --sa.igate.sp_close_action_item ( c1_rec.task_objid, 0, close_action_item_out );
            END LOOP;
         --
         END IF;
      END IF;

      --
      CLOSE chk_st_gsm_cur;                             -- ST_GSM CR11971 ENDS

      -- CR11246 moved close_action_item out of the loop 12/14/09
      sa.igate.
       Sp_close_action_item (c1_rec.task_objid, 0, close_action_item_out);

      --
      -- TFSurepay Andriod
      -- for all order types
      DBMS_OUTPUT.Put_line ('TEST SP UPDAET 0');

      --
      IF device_util_pkg.Get_smartphone_fun (c1_rec.esn) = 0
      THEN
         Sp_set_zero_out_max (c1_rec.call_trans_objid,
                              c1_rec.esn,
                              c1_rec.order_type,
                              c1_rec.transaction_id,
                              c1_rec.rate_plan,
                              out_errorcode,
                              out_errormsg);
      -- TF Surepay CR23513
      END IF;

      DBMS_OUTPUT.Put_line (' c1_rec.order_type:' || c1_rec.order_type);

      IF (c1_rec.order_type NOT IN ('AP', 'E', 'PAP')
          AND NOT (c1_rec.order_type IN ('A', 'MINC')
                   AND c1_rec.template IN
                          ('SUREPAY',
                           'SPRINT',
                           'CSI_TLG',
                           'TMOBILE',
                           'CLARO',
                           'TMOWFM', --CR47564 WFM
                           'RSS')) -- CR13980 PM 09/15/2010 --'SPRINT' Skuthadi
          AND NOT (c1_rec.order_type IN ('A', 'E') AND v_gsm_post_pay = 1) -- CR17413
                                                                          --AND
                                                                          --not (c1_rec.order_type IN ('MINC') AND c1_rec.template IN('SUREPAY') )
         )
      -- CR13531 STCC PM   --- validating for 'E' also, ST_BUNDLE_II CR11975
      THEN
         DBMS_OUTPUT.Put_line ('TEST SP UPDAET 1');

         DBMS_OUTPUT.Put_line ('C1_Rec.Order_Type ' || c1_rec.order_type);

         DBMS_OUTPUT.Put_line ('c1_rec.TEMPLATE ' || c1_rec.template);

         DBMS_OUTPUT.Put_line ('v_gsm_post_pay ' || v_gsm_post_pay);

         -- CR40574: Exclude execution from IGATE_IN3 to avoid duplicates execution.
         IF i_skip_pcrf_update_flag = 'N'
         THEN
            -- reset types
            ipl := Ig_pcrf_log_type ();

            ip := Ig_pcrf_log_type ();

            -- logic to avoid duplicate execution of the update_pcrf_subscriber
            IF NOT ipl.Exist (i_transaction_id => c1_rec.transaction_id) THEN
               -- Super Carrier Changes to create the subscriber and pcrf record (CR35396, CR29586)
               BEGIN
                  sa.Update_pcrf_subscriber (i_esn                => c1_rec.esn,
                                             i_action_type        => NULL,
                                             i_reason             => NULL,
                                             i_src_program_name   => 'WALMART_MONTHLY_PLANS_PKG',
                                             i_sourcesystem       => NULL,
                                             i_ig_order_type      => c1_rec.order_type,
                                             i_transaction_id     => c1_rec.transaction_id,
                                             o_error_code         => l_error_code,
                                             o_error_msg          => l_error_msg);

                  IF  l_error_code = 0 then
				             -- log the pcrf ig log to avoid duplicate processing
                     ip := ipl.Ins (i_transaction_id => c1_rec.transaction_id);
          					 -- Save changes to avoid locks
					           COMMIT;
				          END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     NULL;
               END;

            -- End of Super Carrier Changes to create the subscriber and pcrf record (CR35396, CR29586)
            END IF;  -- IF NOT ipl.exist ( i_transaction_id => ig_trans_rec.transaction_id )
            --
	         -- Send thresholds to TMO
            BEGIN
              send_thresholds_to_tmo ( i_transaction_id    =>  c1_rec.transaction_id ,
                                       i_call_trans_objid  =>  NULL                   ,
                                       o_errorcode         =>  l_error_code  ,
                                       o_errormsg          =>  l_error_msg );
            EXCEPTION
              WHEN OTHERS THEN
               NULL;
            END;
           --CR47564 --Start
           enqueue_transactions_pkg.enqueue_transaction(i_esn               => c1_rec.esn           ,
                                                        i_ig_order_type     => c1_rec.order_type    ,
                                                        i_ig_transaction_id => c1_rec.transaction_id,
                                                        o_response         =>  o_response
                                                        );

           --Update x_account_group service_plan_id with the ESN service plan objid for Non-Shared Group Plan
           IF sa.customer_info.get_shared_group_flag ( i_esn => c1_rec.esn ) = 'N' THEN
             -- get the service plan and group ID
             gt                 := sa.group_type ( i_esn => c1_rec.esn );
             gt.service_plan_id := gt.get_service_plan_objid ( i_esn => c1_rec.esn );

             -- if the service plan was found
             IF gt.service_plan_id IS NOT NULL THEN
               -- instantiate values
               gt := sa.group_type ( i_group_objid => gt.group_objid, i_service_plan_id => gt.service_plan_id);
               -- call method to update the missing service plan
               g := gt.upd;
             END IF;

           END IF;
         --CR47564 --End
         END IF;                      -- IF i_skip_pcrf_update_flag = 'N' THEN

         -- END CR40574
         -- 06/30/2016 Pamistry CR43819 Start
         IF Check_x_parameter ('IGATE_PROVISION_ILD_BENEFITS',
                               rec_chk_st_gsm.org_id)
         THEN
            sa.ild_transaction_pkg.
             Get_ild_params_by_sitepart (
               ip_site_part_objid   => c1_rec.call_trans2site_part,
               ip_esn               => c1_rec.esn,
               ip_bus_org           => rec_chk_st_gsm.org_id,
               op_ild_product_id    => lv_ild,
               op_ild_ig_account    => lv_account,
               op_err_num           => l_error_code,
               op_err_string        => l_error_msg);
	       -- CR55066 and CR55069 prevent add-on insert to ild_transaction table.
	       lv_ild_flag := 'Y';
	       IF rec_chk_st_gsm.org_id = 'SIMPLE_MOBILE' and c1_rec.x_reason = 'ADD_ON' THEN
	         lv_ild_flag := 'N';
	       END IF;

            IF lv_ild IS NOT NULL AND lv_ild != 'ERR_BRAND' AND lv_ild_flag = 'Y'
	    --END CR55066 and CR55069, mdave, 03122018
            THEN
               sa.ild_transaction_pkg.
                Insert_table_x_ild_trans (NULL                           --DEV
                                              ,
                                          c1_rec.msid                  --X_MIN
                                                     ,
                                          c1_rec.esn                   --X_ESN
                                                    ,
                                          SYSDATE            --X_TRANSACT_DATE
                                                 ,
                                          c1_rec.order_type --X_ILD_TRANS_TYPE
                                                           ,
                                          'PENDING'             --X_ILD_STATUS
                                                   ,
                                          SYSDATE              --X_LAST_UPDATE
                                                 ,
                                          lv_account           --X_ILD_ACCOUNT
                                                    ,
                                          NULL           --ILD_TRANS2SITE_PART
                                              ,
                                          NULL                --ILD_TRANS2USER
                                              ,
                                          1                      --X_CONV_RATE
                                           ,
                                          NULL               --X_TARGET_SYSTEM
                                              ,
                                          lv_ild                --X_PRODUCT_ID
                                                ,
                                          NULL                  --X_API_STATUS
                                              ,
                                          NULL                 --X_API_MESSAGE
                                              ,
                                          c1_rec.transaction_id --X_ILD_TRANS2IG_TRANS_ID
                                                               ,
                                          c1_rec.call_trans_objid --X_ILD_TRANS2CALL_TRANS
                                                                 ,
                                          lv_x_ild_objid,
                                          l_error_code,
                                          l_error_msg);
            --DBMS_OUTPUT.PUT_LINE('LV_X_ILD_OBJID: '||LV_X_ILD_OBJID);
            END IF;
         END IF;
        -- CR52604 Starts
		IF NVL (lv_is_swb_carr, 'X') = 'Switch Base' THEN
			UPDATE x_switchbased_transaction
               SET status = 'Completed'
             WHERE x_sb_trans2x_call_trans = c1_rec.call_trans_objid;
		END IF;
		-- CR52604 Ends
         -- 06/30/2016 Pamistry CR43819 End
         UPDATE gw1.ig_transaction
            SET status = 'S'
          WHERE transaction_id = c1_rec.transaction_id;
	 -- CR56275 changes starts..
         --  update the actual MIN in vas
         vas_management_pkg.p_update_vas_min ( i_esn           =>  c1_rec.esn,
                                               i_min           =>  c1_rec.msid,
                                               i_order_type    =>  c1_rec.order_type,
                                               o_error_code    =>  l_error_code,
                                               o_error_msg     =>  l_error_msg
                                             );
          -- CR56275 changes ends.
         -- CR41784 Safelink upgrades Rate plan changes for safelink Disenrollment start
         FOR xrec
            IN (SELECT x_param_value
                  FROM table_x_parameters
                 WHERE x_param_name = 'SL SWITCH RATE PLAN CHANGE'
                       AND x_param_value = c1_rec.template)
         LOOP
            IF ((c1_rec.order_type = 'CR' OR  igate.get_safelink_batch_flag(i_order_type => c1_rec.order_type)='Y' ) AND c1_rec.LANGUAGE = 'TRANSFER')  --CR52803 TBD
            THEN
               DECLARE
                  CURSOR carrier_curs (c_objid IN NUMBER)
                  IS
                     SELECT *
                       FROM table_x_carrier
                      WHERE objid = c_objid;

                  carrier_rec   carrier_curs%ROWTYPE;
               BEGIN
                  OPEN carrier_curs (c1_rec.x_call_trans2carrier);

                  FETCH carrier_curs INTO carrier_rec;

                  CLOSE carrier_curs;

                  UPDATE table_part_inst tpi
                     SET tpi.part_inst2carrier_mkt =
                            CASE
                               WHEN tpi.part_inst2carrier_mkt <>
                                       c1_rec.x_call_trans2carrier
                               THEN
                                  c1_rec.x_call_trans2carrier
                               ELSE
                                  tpi.part_inst2carrier_mkt
                            END,
                         tpi.part_inst2x_pers =
                            CASE
                               WHEN tpi.part_inst2x_pers <>
                                       carrier_rec.carrier2personality
                               THEN
                                  carrier_rec.carrier2personality
                               ELSE
                                  tpi.part_inst2x_pers
                            END
                   WHERE part_serial_no = c1_rec.MIN
                         AND tpi.x_domain = 'LINES';
               END;
            END IF;
         END LOOP;

         --CR41784 Safelink upgrades Rate plan changes for safelink Disenrollment end
         --            DBMS_OUTPUT.PUT_LINE('TEST SP UPDAET 2');
         --                    UPDATE table_site_part SET
         --                     part_status = 'Active'
         --           WHERE objid = (
         --           SELECT call_trans2site_part
         --           FROM table_x_call_trans ct
         --           WHERE ct.objid = c1_rec.call_trans_objid);
         DBMS_OUTPUT.Put_line ('TEST SP UPDAET 3');

         ----------------------------------
         -- CR20403 RIM Integration CDMA
         ------------------------------------
         --     OPEN ESN_BB_curs(c1_rec.esn);
         --       FETCH ESN_BB_curs
         --       INTO ESN_BB_rec;
         --       IF ESN_BB_curs%FOUND THEN
         IF sa.rim_service_pkg.If_bb_esn (c1_rec.esn) = 'TRUE'
         THEN                                                --CR22487/CR23775
            DBMS_OUTPUT.
             Put_line (
               'Insert ig_transaction_RIM for SIM exchange case created ');

            sa.rim_service_pkg.
             Sp_create_rim_action_item (c1_rec.action_item_id,
                                        op_msg,
                                        op_status); --action_item_id (gw1.ig_transaction)

            IF op_status = 'S'
            THEN
               DBMS_OUTPUT.Put_line ('Inserted ig_transaction_RIM succesful');
            ELSE
               DBMS_OUTPUT.
                Put_line (
                  'fail process sa.sp_insert_ig_transaction_rim inserting into ig_transaction_RIM');
            END IF;
         END IF;

         -- close ESN_BB_curs; --CR22487/CR23775
         COMMIT;
      -- CR20403 RIM Integration CDMA
      --
      ELSE
         IF c1_rec.order_type = 'E'
         THEN                                                       -- CR11975
            UPDATE table_part_inst
               SET x_part_inst_status = '13',
                   status2x_code_table =
                      (SELECT objid
                         FROM table_x_code_table
                        WHERE x_code_number = '13')
             WHERE part_serial_no = c1_rec.MIN;
         END IF;

         DBMS_OUTPUT.Put_line ('TEST SP UPDAET 4');

         DBMS_OUTPUT.Put_line ('C1_Rec.Order_Type ' || c1_rec.order_type);

         DBMS_OUTPUT.Put_line ('c1_rec.TEMPLATE ' || c1_rec.template);

         DBMS_OUTPUT.Put_line ('v_gsm_post_pay ' || v_gsm_post_pay);

         UPDATE table_site_part
            SET --service_end_dt = c1_rec.EXP_DATE,
                --x_expire_dt = c1_rec.EXP_DATE,
                --warranty_date = c1_rec.EXP_DATE,
                part_status = 'Active'
          WHERE objid = (SELECT call_trans2site_part
                           FROM table_x_call_trans ct
                          WHERE ct.objid = c1_rec.call_trans_objid);

         DBMS_OUTPUT.Put_line ('TEST SP UPDAET 5');
      --update table_x_call_trans
      --   set X_NEW_DUE_DATE = c1_rec.EXP_DATE
      -- where objid = c1_rec.call_trans_objid;
      --update table_part_inst
      --   set warr_end_date = c1_rec.EXP_DATE
      -- where part_serial_no = c1_rec.esn;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         DECLARE
            sql_code       NUMBER := SQLCODE;
            sql_err        VARCHAR2 (2000) := SQLERRM;
            v_error_text   VARCHAR2 (2000) := NULL;
         BEGIN
            v_error_text :=
                  'SQL Error Code : '
               || TO_CHAR (sql_code)
               || ' Error Message : '
               || sql_err;

            ROLLBACK;

            INSERT INTO error_table (ERROR_TEXT,
                                     error_date,
                                     action,
                                     KEY,
                                     program_name)
                 VALUES (v_error_text,
                         SYSDATE,
                         'transaction id failed',
                         p_transaction_id,
                         'walmart_monthly_plans_pkg');
         END;

         --
         COMMIT;
   END;

   /* CR23513 TF Surepay MVadlapally  */
   -- this procedure will be called in IGATE_IN3 as well, to accomodate certain order types
   PROCEDURE Sp_set_zero_out_max (
      in_call_trans_objid   IN     table_x_call_trans.objid%TYPE,
      in_esn                IN     ig_transaction.esn%TYPE,
      in_order_type         IN     ig_transaction.order_type%TYPE,
      in_ig_trans_id        IN     ig_transaction.transaction_id%TYPE,
      in_ig_rate_plan       IN     ig_transaction.rate_plan%TYPE,
      out_errorcode            OUT NUMBER,
      out_errormsg             OUT VARCHAR2)
   IS
      CURSOR call_trans_curs
      IS
         SELECT *
           FROM table_x_call_trans
          WHERE objid = in_call_trans_objid;

      call_trans_rec         call_trans_curs%ROWTYPE;

      --CR39608
      CURSOR part_inst_curs
      IS
         SELECT *
           FROM table_part_inst
          WHERE part_serial_no = in_esn;

      part_inst_rec          part_inst_curs%ROWTYPE;

      CURSOR ig_trans_bkt_curs
      IS
           SELECT igtb.transaction_id,
                  (SELECT SUM (
                             DECODE (SIGN (igtb.bucket_value),
                                     -1, 0,
                                     igtb.bucket_value))
                     FROM ig_transaction_buckets igtb
                    --WHERE bucket_id = 'TFC'            Commented by Rahul for CR35193 on Jul022015
                    WHERE bucket_id IN ('TFC', 'VOICE') -- Modified by Rahul for CR35193 on Jul022015
                          AND igtb.transaction_id = in_ig_trans_id)
                     VOICE_UNITS,
                  (SELECT SUM (
                             DECODE (SIGN (bucket_value), -1, 0, bucket_value))
                     FROM (SELECT sa.walmart_monthly_plans_pkg.
                                   Isnumber (igtb.bucket_value)
                                     bucket_value                   ---CR47182
                             FROM ig_transaction_buckets igtb
                            --WHERE bucket_id = 'TSM'          Commented by Rahul for CR35193 on Jul022015
                            WHERE bucket_id IN ('TSM', 'MESSAGE') -- Modified by Rahul for CR35193 on Jul022015
                                  AND igtb.transaction_id = in_ig_trans_id))
                     SMS_UNITS,
                  (SELECT SUM (
                             DECODE (SIGN (igtb.bucket_value),
                                     -1, 0,
                                     igtb.bucket_value))
                     FROM ig_transaction_buckets igtb
                    --WHERE bucket_id = 'TFD'        Commented by Rahul for CR35193 on Jul022015
                    WHERE bucket_id IN ('TFD', 'DATA') -- Modified by Rahul for CR35193 on Jul022015
                          AND igtb.transaction_id = in_ig_trans_id)
                     DATA_UNITS
             FROM ig_transaction_buckets igtb, ig_buckets igb
            WHERE     igb.bucket_id = igtb.bucket_id
                  AND igtb.transaction_id = in_ig_trans_id
                  AND igb.rate_plan = in_ig_rate_plan
         GROUP BY igtb.transaction_id;

      --CR39608  below cursor modified
      CURSOR ig_trans_bkt_curs_tmo
      IS
         SELECT *
           FROM (  SELECT DISTINCT
                          igtb.transaction_id,
                          SUM (
                             (SELECT bucket_value
                                FROM ig_transaction_buckets igt
                               WHERE igt.bucket_id = igb.bucket_id
                                     AND igb.bucket_type = 'VOICE_UNITS'
                                     AND igt.transaction_id =
                                            igtb.transaction_id
                                     AND igt.direction = 'INBOUND'   --CR47182
                                     AND igt.bucket_id IN
                                            (SELECT bp.bucket_id
                                               FROM buckets_param bp
                                              WHERE bp.bucket_type =
                                                       'VOICE_UNITS'
                                                    AND bp.active_flag = 'Y')))
                             voice_units,
                          SUM (
                             (SELECT bucket_value
                                FROM ig_transaction_buckets igt
                               WHERE igt.bucket_id = igb.bucket_id
                                     AND igb.bucket_type = 'SMS_UNITS'
                                     AND igt.transaction_id =
                                            igtb.transaction_id
                                     AND igt.direction = 'INBOUND'   --CR47182
                                     AND igt.bucket_id IN
                                            (SELECT bp.bucket_id
                                               FROM buckets_param bp
                                              WHERE bp.bucket_type =
                                                       'SMS_UNITS'
                                                    AND bp.active_flag = 'Y')))
                             sms_units,
                          SUM (
                             (SELECT bucket_value
                                FROM ig_transaction_buckets igt
                               WHERE igt.bucket_id = igb.bucket_id
                                     AND igb.bucket_type = 'DATA_UNITS'
                                     AND igt.transaction_id =
                                            igtb.transaction_id
                                     AND igt.direction = 'INBOUND'   --CR47182
                                     AND igt.bucket_id IN
                                            (SELECT bp.bucket_id
                                               FROM buckets_param bp
                                              WHERE bp.bucket_type =
                                                       'DATA_UNITS'
                                                    AND bp.active_flag = 'Y')))
                             data_units,
                          SUM (
                             (SELECT bucket_value
                                FROM ig_transaction_buckets igt
                               WHERE igt.bucket_id = igb.bucket_id
                                     AND igb.bucket_type = 'FREE_VOICE_UNITS'
                                     AND igt.transaction_id =
                                            igtb.transaction_id
                                     AND igt.direction = 'INBOUND'   --CR47182
                                     AND igt.bucket_id IN
                                            (SELECT bp.bucket_id
                                               FROM buckets_param bp
                                              WHERE bp.bucket_type =
                                                       'FREE_VOICE_UNITS'
                                                    AND bp.active_flag = 'Y')))
                             FREE_VOICE_UNITS,
                          SUM (
                             (SELECT bucket_value
                                FROM ig_transaction_buckets igt
                               WHERE igt.bucket_id = igb.bucket_id
                                     AND igb.bucket_type = 'FREE_SMS_UNITS'
                                     AND igt.transaction_id =
                                            igtb.transaction_id
                                     AND igt.direction = 'INBOUND'   --CR47182
                                     AND igt.bucket_id IN
                                            (SELECT bp.bucket_id
                                               FROM buckets_param bp
                                              WHERE bp.bucket_type =
                                                       'FREE_SMS_UNITS'
                                                    AND bp.active_flag = 'Y')))
                             FREE_SMS_UNITS,
                          SUM (
                             (SELECT bucket_value
                                FROM ig_transaction_buckets igt
                               WHERE igt.bucket_id = igb.bucket_id
                                     AND igb.bucket_type = 'FREE_DATA_UNITS'
                                     AND igt.transaction_id =
                                            igtb.transaction_id
                                     AND igt.direction = 'INBOUND'   --CR47182
                                     AND igt.bucket_id IN
                                            (SELECT bp.bucket_id
                                               FROM buckets_param bp
                                              WHERE bp.bucket_type =
                                                       'FREE_DATA_UNITS'
                                                    AND bp.active_flag = 'Y')))
                             FREE_DATA_UNITS
                     FROM ig_transaction_buckets igtb, ig_buckets igb
                    WHERE     igb.bucket_id = igtb.bucket_id
                          AND igb.rate_plan = in_ig_rate_plan
                          AND igtb.transaction_id = in_ig_trans_id
                 GROUP BY igtb.transaction_id);

      ig_trans_bkt_rec       ig_trans_bkt_curs%ROWTYPE;
      ig_trans_bkt_rec_tmo   ig_trans_bkt_curs_tmo%ROWTYPE;

      CURSOR old_esn_curs (
         c_esn   IN VARCHAR2,
         c_min   IN VARCHAR2)
      IS
           /*  SELECT cd.x_value
              FROM table_x_case_detail cd, table_case c
             WHERE cd.detail2case = c.objid + 0
              AND cd.x_name || '' = 'CURRENT_ESN'
              AND c.x_esn = in_esn  --'100000000013194543'
              AND c.creation_time = SYSDATE - 1/48
             ORDER BY c.objid DESC; */
           SELECT oldc.detail2case,
                  MAX (DECODE (oldc.x_name, 'CURRENT_MIN', oldc.x_value, NULL))
                     CURRENT_MIN,
                  MAX (DECODE (oldc.x_name, 'CURRENT_ESN', oldc.x_value, NULL))
                     CURRENT_ESN,
                  MAX (DECODE (oldc.x_name, 'NEW_MIN', oldc.x_value, NULL))
                     NEW_MIN,
                  MAX (DECODE (oldc.x_name, 'NEW_ESN', oldc.x_value, NULL))
                     NEW_ESN
             FROM table_x_case_detail oldc, table_x_case_detail newc
            WHERE 1 = 1 AND oldc.detail2case = newc.detail2case
                  AND newc.x_name IN
                         ('NEW_ESN', 'NEW_MIN', 'CURRENT_MIN', 'CURRENT_ESN')
                  AND newc.x_value IN (c_esn, c_min)
         GROUP BY oldc.detail2case;

      old_esn_rec            old_esn_curs%ROWTYPE;
      --
      v_ret                  BOOLEAN := FALSE;
      v_ret_n                BOOLEAN := FALSE;

      --
      FUNCTION Set_sf_zero_out_max (
         in_esn              IN ig_transaction.esn%TYPE,
         in_x_sourcesystem   IN table_x_call_trans.x_sourcesystem%TYPE,
         in_order_type       IN ig_transaction.order_type%TYPE,
         in_voice_units      IN ig_transaction_buckets.bucket_balance%TYPE,
         in_sms_units        IN ig_transaction_buckets.bucket_balance%TYPE,
         in_data_units       IN ig_transaction_buckets.bucket_balance%TYPE,
         in_old_esn_flg      IN NUMBER)
         RETURN BOOLEAN
      IS
      BEGIN
         INSERT INTO table_x_zero_out_max (objid,
                                           x_esn,
                                           x_req_date_time,
                                           x_reac_date_time,
                                           x_max_date_time,
                                           x_sourcesystem,
                                           x_deposit,
                                           x_transaction_type,
                                           x_zero_out2user,
                                           x_sms_deposit,
                                           x_data_deposit,
                                           x_mtt_flag,
                                           x_product_type)
              VALUES (
                        Seq ('x_zero_out_max'),
                        in_esn,
                        SYSDATE,
                        NULL,
                        NULL,
                        in_x_sourcesystem,
                        in_voice_units,
                        CASE
                           WHEN in_order_type = 'BI'
                           THEN
                              4  ----CR52803 enable new order type similar to CR-Credit
                           WHEN (in_order_type = 'CR' OR igate.get_safelink_batch_flag(i_order_type => in_order_type) ='Y')
                           THEN
                              3
                           WHEN in_order_type = 'S'
                           THEN
                              3
                           WHEN in_order_type IN ('E', 'PIR')
                                AND in_old_esn_flg = 0
                           THEN
                              3                                     -- New ESN
                           WHEN in_order_type = 'D'
                           THEN
                              2
                           WHEN in_order_type IN ('E', 'PIR')
                                AND in_old_esn_flg = 1
                           THEN
                              5                                     -- Old ESN
                        END,
                        NULL,
                        in_sms_units,
                        in_data_units,
                        2,
                        'SB_SUREPAY');

         RETURN (SQL%ROWCOUNT != 0);
      END set_sf_zero_out_max;

      FUNCTION Set_sf_zero_out_max (
         in_esn                IN ig_transaction.esn%TYPE,
         in_x_sourcesystem     IN table_x_call_trans.x_sourcesystem%TYPE,
         in_order_type         IN ig_transaction.order_type%TYPE,
         in_voice_units        IN ig_transaction_buckets.bucket_balance%TYPE,
         in_sms_units          IN ig_transaction_buckets.bucket_balance%TYPE,
         in_data_units         IN ig_transaction_buckets.bucket_balance%TYPE,
         in_old_esn_flg        IN NUMBER,
         in_free_voice_units   IN ig_transaction_buckets.bucket_balance%TYPE,
         in_free_sms_units     IN ig_transaction_buckets.bucket_balance%TYPE,
         in_free_data_units    IN ig_transaction_buckets.bucket_balance%TYPE)
         RETURN BOOLEAN
      IS
      BEGIN
         INSERT INTO table_x_zero_out_max (objid,
                                           x_esn,
                                           x_req_date_time,
                                           x_reac_date_time,
                                           x_max_date_time,
                                           x_sourcesystem,
                                           x_deposit,
                                           x_transaction_type,
                                           x_zero_out2user,
                                           x_sms_deposit,
                                           x_data_deposit,
                                           x_mtt_flag,
                                           x_product_type,
                                           x_free_deposit,
                                           x_free_sms_deposit,
                                           x_free_data_deposit)
              VALUES (
                        Seq ('x_zero_out_max'),
                        in_esn,
                        SYSDATE,
                        NULL,
                        NULL,
                        in_x_sourcesystem,
                        in_voice_units,
                        CASE
                           WHEN in_order_type = 'BI'
                           THEN
                              4  ----CR52803 enable new order type similar to CR-Credit
                           WHEN (in_order_type = 'CR' OR  igate.get_safelink_batch_flag(i_order_type => in_order_type) ='Y')
                           THEN
                              3
                           WHEN in_order_type = 'S'
                           THEN
                              3
                           WHEN in_order_type IN ('E', 'PIR')
                                AND in_old_esn_flg = 0
                           THEN
                              3                                     -- New ESN
                           WHEN in_order_type = 'D'
                           THEN
                              2
                           WHEN in_order_type IN ('E', 'PIR')
                                AND in_old_esn_flg = 1
                           THEN
                              5                                     -- Old ESN
                        END,
                        NULL,
                        in_sms_units,
                        in_data_units,
                        2,
                        'SB_SUREPAY',
                        in_free_voice_units,
                        in_free_sms_units,
                        in_free_data_units);

         RETURN (SQL%ROWCOUNT != 0);
      END set_sf_zero_out_max;
   --
   BEGIN
      IF (in_call_trans_objid IS NOT NULL)
      THEN
         OPEN call_trans_curs;

         FETCH call_trans_curs INTO call_trans_rec;

         CLOSE call_trans_curs;

         --CR39608
         OPEN part_inst_curs;

         FETCH part_inst_curs INTO part_inst_rec;

         CLOSE part_inst_curs;

         OPEN ig_trans_bkt_curs;

         FETCH ig_trans_bkt_curs INTO ig_trans_bkt_rec;

         CLOSE ig_trans_bkt_curs;

         OPEN ig_trans_bkt_curs_tmo;

         FETCH ig_trans_bkt_curs_tmo INTO ig_trans_bkt_rec_tmo;

         CLOSE ig_trans_bkt_curs_tmo;

         --CR39608
         IF sa.util_pkg.Get_short_parent_name (part_inst_rec.objid) = 'TMO'
         THEN
            v_ret_n :=
               Set_sf_zero_out_max (in_esn,
                                    call_trans_rec.x_sourcesystem,
                                    in_order_type,
                                    ig_trans_bkt_rec_tmo.voice_units,
                                    ig_trans_bkt_rec_tmo.sms_units,
                                    ig_trans_bkt_rec_tmo.data_units,
                                    0,
                                    ig_trans_bkt_rec_tmo.free_voice_units,
                                    ig_trans_bkt_rec_tmo.free_sms_units,
                                    ig_trans_bkt_rec_tmo.free_data_units);
         ELSE
            v_ret :=
               Set_sf_zero_out_max (in_esn,
                                    call_trans_rec.x_sourcesystem,
                                    in_order_type,
                                    ig_trans_bkt_rec.voice_units,
                                    ig_trans_bkt_rec.sms_units,
                                    ig_trans_bkt_rec.data_units,
                                    0);
         END IF;

         IF in_order_type IN ('E', 'PIR')
         THEN
            OPEN old_esn_curs (call_trans_rec.x_service_id,
                               call_trans_rec.x_min);

            FETCH old_esn_curs INTO old_esn_rec;

            IF old_esn_curs%FOUND
            THEN
               v_ret :=
                  Set_sf_zero_out_max (old_esn_rec.current_esn,
                                       call_trans_rec.x_sourcesystem,
                                       in_order_type,
                                       ig_trans_bkt_rec.voice_units,
                                       ig_trans_bkt_rec.sms_units,
                                       ig_trans_bkt_rec.data_units,
                                       1);

               v_ret_n :=
                  Set_sf_zero_out_max (old_esn_rec.current_esn,
                                       call_trans_rec.x_sourcesystem,
                                       in_order_type,
                                       ig_trans_bkt_rec_tmo.voice_units,
                                       ig_trans_bkt_rec_tmo.sms_units,
                                       ig_trans_bkt_rec_tmo.data_units,
                                       1,
                                       ig_trans_bkt_rec_tmo.free_voice_units,
                                       ig_trans_bkt_rec_tmo.free_sms_units,
                                       ig_trans_bkt_rec_tmo.free_data_units);
            END IF;

            CLOSE old_esn_curs;
         END IF;
      END IF;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         out_errorcode := SQLCODE;

         out_errormsg := SUBSTR (SQLERRM, 1, 200);

         ota_util_pkg.
          Err_log (p_action         => 'INSERT INTO TABLE_X_ZERO_OUT_MAX',
                   p_error_date     => SYSDATE,
                   p_key            => in_esn,
                   p_program_name   => 'SP_SET_ZERO_OUT_MAX',
                   p_error_text     => out_errormsg);
   END sp_set_zero_out_max;

   FUNCTION Isnumber (p_num VARCHAR2)
      RETURN NUMBER
   AS
      a   NUMBER;
   BEGIN
      a := p_num;
      RETURN p_num;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;                                                             ---CR47182
END;
/