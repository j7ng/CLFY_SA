CREATE OR REPLACE PACKAGE BODY sa.carrier_sw_pkg AS
/*******************************************************************************
 * --$RCSfile: carrier_sw_pkg_body.sql,v $
 --$Revision: 1.148 $
 --$Author: skota $
 --$Date: 2018/05/09 18:23:22 $
 --$ $Log: carrier_sw_pkg_body.sql,v $
 --$ Revision 1.148  2018/05/09 18:23:22  skota
 --$ Modified for the TF SL BI
 --$
 --$ Revision 1.147  2018/03/16 18:46:06  sgangineni
 --$ CR56512 - Claro switch changes merged with 3/20 release (REL_953) changes
 --$
 --$ Revision 1.146  2018/03/07 15:18:22  tbaney
 --$ CR49369 Removed bus org blocing check for Bucket group
 --$
 --$ Revision 1.145  2018/03/01 22:23:02  tbaney
 --$ CR49369 Corrected issue with bucket group.
 --$
 --$ Revision 1.144  2018/03/01 21:02:37  tbaney
 --$ CR49369 Modified sp_get_usage_by_trans
 --$
 --$ Revision 1.143  2018/02/22 19:29:43  tbaney
 --$ CR49369_SM_Add_HotspotTethering_Usage_and_Balance_for_611611
 --$ Expanded bucket group for Simple Mobile.
 --$
 --$ Revision 1.142  2018/02/12 15:08:18  jcheruvathoor
 --$ CR52654	Short code for TMOBILE WFM
 --$
 --$ Revision 1.140  2018/02/07 23:11:28  jcheruvathoor
 --$ CR52654	Short code for TMOBILE WFM
 --$
 --$ Revision 1.139  2017/12/07 13:54:23  skambhammettu
 --$ CR53217--Added 'MOBILE_BROADBAND','BYOT' IN sp_get_bal_cfg_id
 --$
 --$ Revision 1.138  2017/11/27 17:09:32  abustos
 --$ Logic added to determine when data should be considered UNLIMITED
 --$
 --$ Revision 1.137  2017/11/20 23:06:54  abustos
 --$ CR52587 set value to UNLIMITED for TFSL_UNL plans instead of 99999
 --$
 --$ Revision 1.134  2017/11/06 23:04:22  abustos
 --$ testing for CR52587
 --$
 --$ Revision 1.132  2017/10/16 18:56:22  mdave
 --$ CR54118 EME changes
 --$
 --$ Revision 1.130  2017/10/03 18:34:18  sgangineni
 --$ CR49915 - Merged with latest PROD version
 --$
 --$ Revision 1.126  2017/08/22 18:40:59  tpathare
 --$ Merged with PROD 08/22
 --$
 --$ Revision 1.118  2017/07/14 16:43:38  tbaney
 --$ Correct missing logic for CR47844
 --$
 --$ Revision 1.116  2017/06/06 15:47:02  smacha
 --$ Modified code changes only specific to TRACFONE brand as part of CR 49276.
 --$
 --$ Revision 1.112  2017/05/02 21:57:43  nsurapaneni
 --$ Code changes to call function get_last_addon_redemption_date  instead get_last_redemption_date for WFM
 --$
 --$ Revision 1.111  2017/05/02 15:08:24  nsurapaneni
 --$ Balance  Enquiry search_bi_trans procedure code changes for WFM
 --$
  --$ Revision 1.110  2017/04/14 18:34:37  nsurapaneni
  --$ Merge with CR49101
  --$
  --$ Revision 1.103  2017/04/11 16:50:04  nsurapaneni
  --$ Added a new private function get_bucket_group to get bucket_group information
  --$
  --$ Revision 1.99  2017/03/27 18:53:43  sgangineni
  --$ CR47564 - WFM Changes
  --$
  --$ Revision 1.98  2017/03/23 15:51:25  sgangineni
  --$ CR47564 - Changes to store bucket id list in table_x_call_trans_ext
  --$
  --$ Revision 1.97  2017/03/14 23:29:39  smeganathan
  --$ CR47564 WFM added WALLET in f_skip_bucket function
  --$
  --$ Revision 1.95  2017/02/01 15:59:22  tbaney
  --$ Added NVL logic for GET_DATA_MTG_SOURCE
  --$
  --$ Revision 1.94  2017/01/25 20:31:30  smeganathan
  --$ CR47803 changes to get only usage of Base data in SP_GET_USAGE_BY_TRANS
  --$
  --$ Revision 1.93  2017/01/25 19:11:29  smeganathan
  --$ CR47803 changes to get only usage of Base data in SP_GET_USAGE_BY_TRANS
  --$
  --$ Revision 1.92  2017/01/25 17:12:09  smeganathan
  --$ CR47803 changes to get only usage of Base data in SP_GET_USAGE_BY_TRANS
  --$
  --$ Revision 1.91  2017/01/12 17:18:01  smeganathan
  --$ CR46581 code changes to restrict bucket ids from BI result if the customer didnt purchase it
  --$
  --$ Revision 1.90  2017/01/12 16:23:31  smeganathan
  --$ CR46581 code changes to restrict bucket ids from BI result if the customer didnt purchase it
  --$
  --$ Revision 1.89  2017/01/12 16:11:25  smeganathan
  --$ CR46581 code changes to restrict bucket ids from BI result if the customer didnt purchase it
  --$
  --$ Revision 1.88  2017/01/12 16:07:34  smeganathan
  --$ CR46581 code changes to restrict bucket ids from BI result if the customer didnt purchase it
  --$
  --$ Revision 1.87  2017/01/09 20:08:06  smeganathan
  --$ CR46581 changed table name as x_product_config_detail and x_bi_transaction_log_detail as per review comments
  --$
  --$ Revision 1.86  2017/01/05 19:39:28  smeganathan
  --$ CR46581 Merged with 1/5 prod release
  --$
  --$ Revision 1.85  2017/01/03 17:05:41  smeganathan
  --$ CR46581 changes for source system in get_meter_source
  --$
  --$ Revision 1.84  2016/12/27 18:46:40  smeganathan
  --$ CR44729 code changes to get bucket usage and add inquiry type
  --$
  --$ Revision 1.75  2016/12/15 18:23:31  smeganathan
  --$ CR44729 merged with 12/15 prod release
  --$
  --$ Revision 1.63  2016/12/07 18:10:07  smeganathan
  --$ CR44729 updates error codes in new overloaded procedures
  --$
  --$ Revision 1.62  2016/12/01 21:18:32  smeganathan
  --$ CR44729 Added condition to get new metering source based on sub brand
  --$
  --$ Revision 1.61  2016/11/29 22:52:23  smeganathan
  --$ CR44729 Go smart Migration added new procs to overload Create Search Get BI transactions
  --$
  --$ Revision 1.60  2016/08/25 23:05:57  sraman
  --$ CR40903 - Added new procedure to return balance usage.
  --$  * -----------------------------------------------------------------------
*********************************************************************************/
--
  /*    Copyright   2002 Tracfone  Wireless Inc. All rights reserved            */
  /*                                                                            */
  /* NAME:         carrier_sw_pkg                                               */
  /* PURPOSE:      Perform all Tmobile Switch related actions -CR30457          */
  /* FREQUENCY:                                                                 */
  /* PLATFORMS:    Oracle 11g AND newer versions.                               */
  /*                                                                            */
  /* REVISIONS:                                                                 */
  /* VERSION   DATE        WHO       PURPOSE                                    */
  /* -------   ---------- ---------  -----------------------------------------  */
  /*  1.0      08/21/2015 Vijayakumar N/Vishnu  Initial  Revision               */
  /******************************************************************************/
  /***********************************************SP_GET_CURRENT_MTG*************/
--


PROCEDURE sp_get_current_mtg ( ip_esn      IN  VARCHAR2 ,
                               out_cur     OUT return_met_source_tbl,
                               op_err_code OUT VARCHAR2,
                               op_err_msg  OUT VARCHAR2 ) AS

  v_action VARCHAR2 (1000) := NULL;
  met_rec  return_met_source_tbl := return_met_source_tbl();
  cst      customer_type := customer_type ();

BEGIN
  -- validate esn
  IF ip_esn     IS NULL THEN
    v_action    := ' Failed to retrieve records: IP_ESN cannot be null';
    OP_ERR_CODE := '1';
    OP_ERR_MSG  := 'Failure-input is null';
    RETURN;
  END IF;

  --
  cst := cst.retrieve ( i_esn => ip_esn );

  --
  IF cst.device_type IS NULL THEN
    BEGIN
      SELECT pcpv.device_type
      INTO   cst.device_type
      FROM   table_part_inst pi,
             table_mod_level ml,
             table_part_num pn,
             pcpv_mv pcpv
      WHERE  1 = 1
      AND    pi.part_serial_no       = ip_esn
      AND    pi.x_domain             = 'PHONES'
      AND    pi.n_part_inst2part_mod = ml.objid
      AND    ml.part_info2part_num   = pn.objid
      AND    pn.domain               = 'PHONES'
      AND    pn.part_num2part_class  = pcpv.pc_objid;
     EXCEPTION
       WHEN OTHERS THEN
         cst.device_type := NULL;
    END;

    --
    -- CR40903_My_Account_App_Data_Balance_Inquiry_Update Tim 7/5/2016 added service plan group
    --

  END IF;
  --
  BEGIN
    SELECT return_met_source_obj ( (SELECT short_name
                                    FROM   X_USAGE_HOST
                                    WHERE  CARRIER_MTG_ID = cst.meter_source_voice
                                   ),
                                   (SELECT short_name
                                    FROM   X_USAGE_HOST
                                    WHERE  CARRIER_MTG_ID = cst.meter_source_sms
                                   ) ,
                                   (SELECT short_name
                                    FROM   X_USAGE_HOST
                                    WHERE  CARRIER_MTG_ID = cst.meter_source_data
                                   ),
                                   (SELECT short_name
                                    FROM   X_USAGE_HOST
                                    WHERE  CARRIER_MTG_ID = cst.meter_source_ild
                                   ),
                                   timeout_minutes_threshold ,
                                   daily_attempts_threshold
                                 )
    BULK COLLECT
    INTO  met_rec
    FROM  x_usage_host
    WHERE carrier_mtg_id = cst.meter_source_voice;
    OUT_CUR             := MET_REC;
    OP_ERR_CODE         :='0';
    OP_ERR_MSG          :='Success';
    IF ( MET_REC.COUNT = 0 ) THEN
      OP_ERR_CODE       :='0';
      OP_ERR_MSG        :='Success-No data found';
      RETURN;
    END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       OP_ERR_CODE :='0';
       OP_ERR_MSG  := 'Success-No data found';
       out_cur     := NULL;
     WHEN OTHERS THEN
       OP_ERR_CODE := SQLCODE;
       OP_ERR_MSG  := sqlerrm;
  END;
 EXCEPTION
   WHEN OTHERS THEN
     op_err_code := SQLCODE;
     op_err_msg  := SQLERRM;
END sp_get_current_mtg;
--
--*********************************************SP_GET_BALANCE****************************************************
PROCEDURE sp_get_balance ( ip_trans_id IN  NUMBER,
                           out_cur     OUT return_bucket_bal_tbl,
                           op_err_code OUT VARCHAR2,
                           op_err_msg  OUT VARCHAR2 ) AS
CURSOR c_deenroll_bi IS
SELECT ig.esn,
      ig.order_type,
      sp.benefit_type,
      ig.transaction_id,
      tsp.part_status,
      tt.title,
      ct.x_reason,
      spsp.x_service_plan_id,
      (SELECT tp.x_parent_name
      FROM table_x_carrier tc,
        table_x_carrier_group cg,
        table_x_parent tp
      WHERE 1         = 1
      AND tp.objid    = cg.x_carrier_group2x_parent
      AND cg.objid    = tc.carrier2carrier_group
      AND tc.objid    = ct.x_call_trans2carrier
      AND tp.x_status = 'ACTIVE'
      AND ROWNUM      = 1
      ) parent_name
  FROM ig_transaction ig,
    table_task tt,
    table_x_call_trans ct,
    table_site_part tsp,
    x_service_plan_site_part spsp,
    service_plan_feat_pivot_mv sp
  WHERE ct.objid    = IP_TRANS_ID
  AND ct.X_SUB_SOURCESYSTEM='TRACFONE'
  AND spsp.x_service_plan_id=252
  AND ig.action_item_id      = tt.task_id
  AND tt.x_task2x_call_trans = ct.objid
  AND ig.esn                 = tsp.x_service_id
  AND tsp.objid              =
    (SELECT MAX(tsp1.objid)
    FROM table_site_part tsp1
    WHERE tsp1.x_service_id = tsp.x_service_id
    )
  AND tsp.objid              = spsp.table_site_part_id
  AND spsp.x_service_plan_id = sp.service_plan_objid;

  --CR52587 Cursor to fetch the service plan group
  CURSOR cur_tfsl_unl IS
  SELECT spsp.x_service_plan_id,
         fea.service_plan_group,
         UPPER(fea.voice) service_plan_voice,
         UPPER(fea.sms) service_plan_sms
  FROM   table_x_call_trans ct,
         x_service_plan_site_part spsp,
         sa.service_plan_feat_pivot_mv fea
  WHERE  ct.objid                = ip_trans_id
    AND  spsp.table_site_part_id = ct.call_trans2site_part
    AND  spsp.x_service_plan_id  = fea.service_plan_objid;

  rec_tfsl_unl      cur_tfsl_unl%ROWTYPE;--CR52587
  l_id_count        NUMBER := 0;
  l_skip_bucket_ids bucket_id_tab :=  bucket_id_tab();  -- CR44729

BEGIN
  -- Call the function f_skip_bucket_ids to get Bucket ids which the customer did not purchase
  -- No Need to show 0 balance bucket if it has not been purchased
  l_skip_bucket_ids := f_skip_bucket_ids ( i_calltrans_id => ip_trans_id ); -- CR44729
  --
  SELECT  return_bucket_bal_obj ( bk.objid,
                                  balance_bucket2x_swb_tx,
                                  bk.x_type,
                                  CASE
                                   WHEN bk.x_type = 'mb'  AND bk.x_value > 102400    THEN 'UNLIMITED'
                                   WHEN bk.x_type = 'kb'  AND bk.x_value > 104857600 THEN 'UNLIMITED'
                                   ELSE bk.x_value
                                  END , --CR52587 if > 100GB data should be UNLIMITED
                                  bk.recharge_date,
                                  bk.expiration_date,
                                  bk.bucket_desc,
                                  get_bucket_group ( i_bucket_id        => bk.bucket_id ,
                                                     i_call_trans_objid => ip_trans_id  ) -- CR49087 Added by Naresh
                                ) BULK COLLECT
  INTO    out_cur
  FROM    x_swb_tx_balance_bucket bk,
          x_switchbased_transaction xsb
  WHERE   xsb.x_sb_trans2x_call_trans = ip_trans_id
  AND     bk.balance_bucket2x_swb_tx = xsb.objid
  AND     bk.bucket_id NOT IN ( SELECT bucket_id
                                FROM TABLE (CAST(l_skip_bucket_ids AS sa.bucket_id_tab))); -- CR44729 skip bucketids that are not purchased



  --
  IF (OUT_CUR.COUNT = 0) THEN
     FOR rec_c_deenroll_bi IN c_deenroll_bi LOOP
         IF rec_c_deenroll_bi.PARENT_NAME LIKE '%SAFELINK%' THEN
            SELECT RETURN_BUCKET_BAL_OBJ( NULL ,NULL ,igb.MEASURE_UNIT, igtb.BUCKET_BALANCE,igtb.RECHARGE_DATE,
                                          igtb.EXPIRATION_DATE,igb.BUCKET_DESC,
                                          NULL -- CR49087 Added by Naresh
                                        )
            BULK COLLECT
            INTO OUT_CUR
            FROM gw1.ig_buckets igb, gw1.ig_transaction_buckets igtb,IG_TRANSACTION ig
            WHERE 1 = 1
               AND igb.bucket_id = igtb.bucket_id
               AND igtb.direction != 'OUTBOUND'
               And Igtb.Transaction_Id = rec_c_deenroll_bi.TRANSACTION_ID
               AND IG.TRANSACTION_ID=IGTB.TRANSACTION_ID
               AND IGB.RATE_PLAN = sa.util_pkg.get_esn_rate_plan(rec_c_deenroll_bi.esn);

         END IF;
     END LOOP;

     IF (OUT_CUR.COUNT = 0) THEN
       OP_ERR_CODE := '1';
       OP_ERR_MSG  := 'No data found';
       RETURN;
     END IF;
  --
  ELSIF (OUT_CUR.COUNT <> 0)
  THEN
    --CR52587 for TFSL_UNL we are currently returing 0 for SMS and VOICE
    --Extending to return UNLIMITED if there service plan feature is set to that
    OPEN cur_tfsl_unl;
    FETCH cur_tfsl_unl INTO rec_tfsl_unl;

    IF rec_tfsl_unl.service_plan_group = 'TFSL_UNLIMITED'
    THEN
      IF rec_tfsl_unl.service_plan_voice = 'UNLIMITED'
      THEN
        l_id_count := out_cur.last + 1;
        out_cur.EXTEND(1);
        out_cur(l_id_count) := RETURN_BUCKET_BAL_OBJ(NULL,NULL,'min',rec_tfsl_unl.service_plan_voice,NULL,NULL,'Purchase Voice',NULL);
      END IF;
      --
      IF rec_tfsl_unl.service_plan_sms = 'UNLIMITED'
      THEN
        l_id_count := out_cur.last + 1;
        out_cur.EXTEND(1);
        out_cur(l_id_count) := RETURN_BUCKET_BAL_OBJ(NULL,NULL,'msg',rec_tfsl_unl.service_plan_sms,NULL,NULL,'Purchase Message',NULL);
      END IF;

    END IF;
    --CR52587 END
  END IF;

  --
  OP_ERR_CODE := 0;
  OP_ERR_MSG  := 'Success';

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     OP_ERR_CODE :='1';
     OP_ERR_MSG  :='No data found';
     out_cur     :=NULL;
   WHEN OTHERS THEN
     OP_ERR_CODE :=SQLCODE;
     OP_ERR_MSG  :=sqlerrm;
END sp_get_balance;
--*********************************************SP_GET_BALANCE****************************************************
--*********************************************SP_GET_USAGE_BY_TRANS****************************************************
PROCEDURE sp_get_usage_by_trans ( ip_trans_id IN  NUMBER                ,
                                  out_cur     OUT return_bucket_bal_tbl ,
                                  op_err_code OUT VARCHAR2              ,
                                  op_err_msg  OUT VARCHAR2              ) AS

BEGIN
  --
  SELECT return_bucket_bal_obj ( objid      , -- objid
                                 NULL       , -- balance_bucket2x_swb_tx
                                 'mb'       , -- x_type
                                 data_usage , -- x_value
                                 NULL       , -- recharge_date
                                 NULL       , -- expiration_date
                                 NULL       , -- bucket_desc
                                 sa.carrier_sw_pkg.get_bucket_group ( i_bucket_id        => bucket_id ,
                                                                      i_call_trans_objid => ip_trans_id        )) -- bucket_group
  BULK COLLECT
  INTO out_cur
  FROM ( SELECT it.transaction_id objid,
                itb.bucket_value,
                itb.bucket_balance,
                -- new function used to calculate the usage based on carrier logic
                calculate_usage ( i_call_trans_id  => ip_trans_id        ,
                                  i_bucket_value   => itb.bucket_value   ,
                                  i_bucket_balance => itb.bucket_balance ) data_usage,
                itb.bucket_id
         FROM   gw1.ig_transaction it,
                gw1.ig_transaction_buckets itb,
                sa.table_x_call_trans tct,
                sa.table_task tt
         WHERE  1 = 1
         AND    tct.objid               = ip_trans_id
         AND    tt.x_task2x_call_trans  = tct.objid
         AND    it.transaction_id       = itb.transaction_id
         AND    it.action_item_id       = tt.task_id
         AND    order_type              = 'BI'
         AND    direction               = 'INBOUND'
         AND EXISTS (SELECT 1
                        FROM   ig_buckets
                        WHERE  bucket_id    = itb.bucket_id
                        AND    bucket_group IN ('BASE_DATA','DATA_TETHERING', 'PROMO_DATA')  -- CR49369 SM Add HotspotTethering Usage and Balance for 611611 allowed
                    )
       );

  --
  op_err_code := 0;
  op_err_msg  := 'Success';
  --
  IF (out_cur.COUNT = 0) THEN
      op_err_code := '1';
      op_err_msg  := 'No data found';
  END IF;
  --
 EXCEPTION
  WHEN no_data_found THEN
    op_err_code := '1';
    op_err_msg  := 'No data found';
    out_cur     := NULL;
  WHEN OTHERS THEN
    op_err_code :=SQLCODE;
    op_err_msg  :=sqlerrm;
END sp_get_usage_by_trans;
--*********************************************SP_GET_USAGE_BY_TRANS****************************************************

--*********************************************SP_GET_OP_SW_METERING****************************************************
PROCEDURE sp_get_op_sw_metering(
    IP_ESN        IN VARCHAR2,
    IP_BRAND      IN VARCHAR2,
    IP_CARRIER_ID IN VARCHAR2,
    OP_SW_METERING OUT VARCHAR2 ,
    OP_MIGR_FLAG OUT VARCHAR2 ,
    OP_ERROR_CODE OUT INTEGER,
    OP_ERROR_MESSAGE OUT VARCHAR2)
IS
  --sqlstmt                 VARCHAR2 (4000);
  v_action           VARCHAR2 (1000) := NULL;
  user_exception     EXCEPTION;
  v_device_group     VARCHAR2(50);
  v_carrier_name     VARCHAR2(50);
  v_VOICE_MTG_SOURCE VARCHAR2(50);
  P_PARAMETER_VALUE  VARCHAR2(50);
  lv_debug           INTEGER := 0;
  lv_parameter_value sa.table_x_part_class_values.x_param_value%TYPE;
  lv_error_code    INTEGER;
  lv_error_message VARCHAR2(4000);
  v_cnt            NUMBER;
  cst customer_type := customer_type ();
  v_service_plan_group   VARCHAR2(200) := NULL;
  v_non_ppe_flag         sa.pcpv_mv.non_ppe%TYPE;
  c   customer_type := customer_type(); -- CR47138
  l_sub_brand     VARCHAR2(100);  -- CR44729
  l_brand         VARCHAR2(100);  -- CR44729
BEGIN
  -- finding the device type like feature phone or smart phone
  IF IP_ESN IS NOT NULL AND IP_BRAND IS NOT NULL THEN
    sa.sp_get_esn_parameter_value(IP_ESN, 'DEVICE_TYPE', lv_debug, lv_parameter_value, lv_error_code, lv_error_message);
    IF lv_parameter_value    ='BYOP' THEN
      v_device_group        :='SMARTPHONE';
    ELSIF lv_parameter_value ='SMARTPHONE' THEN
      v_device_group        :='SMARTPHONE';
    ELSIF lv_parameter_value ='FEATURE_PHONE' THEN
      v_device_group        :='FEATURE_PHONE';
    ELSE
      v_action := 'Not supported device group';
      --RAISE user_exception;
    END IF;
    DBMS_OUTPUT.PUT_LINE('v_device_group' || v_device_group);
    DBMS_OUTPUT.PUT_LINE('lv_parameter_value' || lv_parameter_value);
    DBMS_OUTPUT.PUT_LINE('lv_error_code' || lv_error_code);
    DBMS_OUTPUT.PUT_LINE('lv_error_message' || lv_error_message);
    --finding the parent carrier details
    BEGIN
      SELECT DISTINCT x_parent_name--DECODE (x_parent_name,'CINGULAR','AT&T WIRELESS','DOBSON CELLULAR','AT&T WIRELESS','DOBSON GSM','AT&T WIRELESS','T-MOBILE PREPAY PLATFORM','T-MOBILE', 'VERIZON PREPAY PLATFORM','VERIZON WIRELESS',x_parent_name)
      INTO   v_carrier_name
      FROM   table_x_parent p,
             table_x_carrier_group cg,
             TABLE_X_CARRIER carr
             --TABLE_PART_INST TPI
      WHERE  p.objid  = cg.x_carrier_group2x_parent
      AND    cg.objid   = carr.carrier2carrier_group
      AND    carr.objid = IP_CARRIER_ID ;
      DBMS_OUTPUT.PUT_LINE('v_carrier_name' || v_carrier_name);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_action         := 'Not able to find the carrier name for given ESN';
      OP_SW_METERING   := NULL;
      op_error_code    := 0;
      op_error_message := SUBSTR(SQLERRM, 1, 100);
      DBMS_OUTPUT.PUT_LINE('v_action' || v_action);
      -- write to error_table
      --ota_util_pkg.err_log(v_action => v_ACTION, p_error_date => SYSDATE, p_key => ip_esn, p_program_name => 'SA.SP_GET_OP_SW_METERING', p_error_text => op_error_message );
    END;
  ELSE
    v_action := ' Failed to retrieve records: IP_ESN and IP_BRAND cannot be null';
    -- RAISE user_exception;
  END IF;
  DBMS_OUTPUT.PUT_LINE('v_carrier_name' || v_carrier_name);
  SELECT COUNT (*)
  INTO   v_cnt
  FROM   TABLE_PART_INST
  WHERE  PART_SERIAL_NO = IP_ESN
  AND    x_part_inst_status|| '' IN ('52');

  -- call the retrieve method
  cst := cst.retrieve ( i_esn => ip_esn );
  --
  -- CR44729 changes starts..
  -- Get sub brand for the esn
  c.esn       := ip_esn;
  c.sub_brand := c.get_sub_brand;
  --
  IF NVL(c.sub_brand,'X') = 'GO_SMART'
  THEN
    l_brand   :=  c.sub_brand ;
  ELSE
    l_brand   :=  ip_brand  ;
  END IF;
  -- CR44729 changes ends
  --
  IF v_cnt > 0 THEN
    BEGIN
      SELECT short_name
      INTO   v_voice_mtg_source
      FROM   x_usage_host
      WHERE  carrier_mtg_id = cst.meter_source_voice;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_action         := 'Not able to find the metering source for given ESN';
      OP_SW_METERING   := NULL;
      op_error_code    := 0;
      op_error_message := SUBSTR(SQLERRM, 1, 100);
      -- write to error_table
      --ota_util_pkg.err_log(v_action => v_ACTION, p_error_date => SYSDATE, p_key => ip_esn, p_program_name => 'SA.SP_GET_OP_SW_METERING', p_error_text => op_error_message );
    END;
  ELSIF v_cnt = 0 THEN
	-- CR42459
    IF IP_BRAND = 'TRACFONE' THEN
       -- Check the PPE flag.
       IF v_device_group = 'FEATURE_PHONE' THEN
         v_service_plan_group := NULL;
       ELSE
          v_service_plan_group := 'PAY_GO';
       END IF;
    END IF;  -- Tracfone Safelink
    -- CR47138 changes starts..
    -- commented the below code and used type member function.
    /*
    BEGIN
      SELECT VOICE_MTG_SOURCE
       INTO v_VOICE_MTG_SOURCE
      FROM (SELECT VOICE_MTG_SOURCE
              FROM X_PRODUCT_CONFIG
             WHERE DEVICE_TYPE = v_device_group
             AND PARENT_NAME   =v_carrier_name
             AND BRAND_NAME    =IP_BRAND
             AND NVL(service_plan_group,'X') = CASE WHEN service_plan_group IS NOT NULL
                                                         AND
                                                         service_plan_group = v_service_plan_group
                                                    THEN service_plan_group
                                                    ELSE 'X'
                                                     END
                   ORDER BY  CASE WHEN service_plan_group = v_service_plan_group
                                  THEN 1
                                  ELSE 2
                                    END)
        WHERE ROWNUM = 1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_action         := 'Not able to find the metering source for given ESN';
      OP_SW_METERING   := NULL;
      op_error_code    := 0;
      op_error_message := SUBSTR(SQLERRM, 1, 100);
      -- write to error_table
      --ota_util_pkg.err_log(v_action => v_ACTION, p_error_date => SYSDATE, p_key => ip_esn, p_program_name => 'SA.SP_GET_OP_SW_METERING', p_error_text => op_error_message );
    END;
    */
    --
    c := c.get_meter_sources (i_device_type        => v_device_group  ,
                              i_source_system      => NULL            ,
                              i_brand              => l_brand         ,
                              i_parent_name        => v_carrier_name  ,
                              i_service_plan_group => v_service_plan_group );
    --
    BEGIN
      SELECT short_name
      INTO   v_voice_mtg_source
      FROM   x_usage_host
      WHERE  carrier_mtg_id = c.meter_source_voice;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_action         := 'Not able to find the metering source for given ESN';
      OP_SW_METERING   := NULL;
      op_error_code    := 0;
      op_error_message := SUBSTR(SQLERRM, 1, 100);
    END;
    -- CR47138 changes ends
    --
  END IF;

  DBMS_OUTPUT.PUT_LINE('v_VOICE_MTG_SOURCE' || v_VOICE_MTG_SOURCE);

  IF v_VOICE_MTG_SOURCE IS NOT NULL THEN
    IF v_VOICE_MTG_SOURCE ='PPE' THEN
      OP_SW_METERING := 'N';
    ELSE
      OP_SW_METERING := 'Y';
    END IF;
    op_error_code    := 0;
    op_error_message := 'SUCCESS';
    OP_MIGR_FLAG     :='N';
  ELSE
    v_action := ' No Voice metering source found';
  END IF;
EXCEPTION
WHEN OTHERS THEN
  OTA_UTIL_PKG.ERR_LOG( v_action,                                                                                                         --p_action
  SYSDATE,                                                                                                                                --p_error_date
  IP_ESN ||'-'||IP_BRAND,                                                                                                                 --p_key
  'DEVICE_UTIL_PKG.SP_GET_DEVICE_INFO',                                                                                                   --p_program_name
  'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
  );
  --RAISE;
END sp_get_op_sw_metering;
--*********************************************SP_GET_BI_REQUIRED****************************************************
PROCEDURE sp_get_bi_required(
    IP_FROM_ESN IN VARCHAR2 ,
    IP_FROM_MIN IN VARCHAR2 ,
    IP_TO_ESN   IN VARCHAR2 ,
    IP_TO_SIM   IN VARCHAR2 ,
    IP_ACTION   IN VARCHAR2 ,
    IP_BRAND    IN VARCHAR2 ,
    IP_ZIP_CODE IN VARCHAR2 ,
    IP_SOURCE   IN VARCHAR2,
    OP_BI_REQUIRED OUT VARCHAR2 ,
    OP_GET_BAL_INFO OUT VARCHAR2,
    OP_CARRIER_TYPE OUT VARCHAR2,
    OP_ERR_CODE OUT VARCHAR2 ,
    OP_ERR_MSG OUT VARCHAR2,
    IP_IS_UNIT_TRANSFER IN VARCHAR2 DEFAULT NULL) --CR54118
AS
  v_from_met_src_id NUMBER(3);
  v_to_met_src_id   NUMBER(3);
  v_from_met_src x_usage_host.short_name%type;
  v_to_met_src x_usage_host.short_name%type;
  v_ppe_flag         VARCHAR2(50);
  v_bal_inq_required VARCHAR2(5)                                  := NULL;
  v_get_balance_info phone_upgrade_benefits.get_balance_info%TYPE :=NULL;
  v_carrier_type        VARCHAR2(100)                                    :=NULL;
  v_service_plan_group  VARCHAR2(100)                                    :=NULL;
  v_ppe_meter_source_id NUMBER(3);
  v_brand               VARCHAR2(100);
  v_parent_carrier_name VARCHAR2(100);
  v_device_group        VARCHAR2(50);
  v_carrier_id table_x_parent.x_parent_ID%TYPE;
  v_carrier_name table_x_parent.x_parent_name%TYPE;
  op_part_number     VARCHAR2(100);
  repl_tech          VARCHAR2(100);
  op_sim_profile     VARCHAR2(100);
  part_serial_no     VARCHAR2(100);
  msg                VARCHAR2(500);
  pref_parent        VARCHAR2(100);
  pref_carrier_objid VARCHAR2(100);
  lv_debug           INTEGER := 0;
  lv_parameter_value sa.table_x_part_class_values.x_param_value%TYPE;
  lv_error_code    INTEGER;
  lv_error_message VARCHAR2(4000);
  v_action         VARCHAR2 (1000) := NULL;
  from_cst customer_type           := customer_type(ip_from_esn);
  from_cst_ret customer_type       := customer_type;
  to_cst customer_type             := customer_type(ip_to_esn);
  to_cst_ret customer_type         := customer_type;
  v_meter_source_voice x_subscriber_spr.meter_source_voice%type;
  v_safelink VARCHAR2(1) :='N';
  c                  customer_type := customer_type(); -- CR47138
  l_sub_brand     VARCHAR2(100);  -- CR44729
  l_brand         VARCHAR2(100);  -- CR44729
  l_from_esn_device       sa.table_x_part_class_values.x_param_value%TYPE;  -- CR49276

  CURSOR get_esn_serv_plan
  IS
    SELECT sp.x_service_id ,
      xspsp.x_service_plan_id service_plan_id ,
      NVL(sa.adfcrm_get_serv_plan_value(xspsp.x_service_plan_id, 'SERVICE_PLAN_GROUP') ,'PAY_GO') service_plan_group ,
      sp.part_status
    FROM sa.table_site_part sp ,
      sa.x_service_plan_site_part xspsp
    WHERE sp.x_service_id            = ip_from_esn
    AND sp.part_status               = 'Active'
    AND xspsp.table_site_part_id (+) = sp.objid
    ORDER BY sp.install_date DESC;
BEGIN
  v_brand := ip_brand;
  BEGIN
    SELECT carrier_mtg_id
    INTO v_ppe_meter_source_id
    FROM x_usage_host
    WHERE usage_host_name='PPE';
  EXCEPTION
  WHEN OTHERS THEN
    v_ppe_meter_source_id :=NULL;
  END;
  -- CR44729 changes starts..
  -- Get sub brand for the esn
  c.esn       := ip_from_esn;
  c.sub_brand := c.get_sub_brand;
  --
  IF NVL(c.sub_brand,'X') = 'GO_SMART'
  THEN
    l_brand   :=  c.sub_brand ;
  ELSE
    l_brand   :=  ip_brand  ;
  END IF;
  -- CR44729 changes ends
  FOR xrec IN get_esn_serv_plan
  LOOP
    v_service_plan_group   :=xrec.service_plan_group;
    --IF v_service_plan_group ='UNLIMITED' THEN --UNLIMITED any brand get balance
    IF v_service_plan_group IN ('UNLIMITED', 'TFSL_UNLIMITED') THEN --CR56512 change
      -- not required
      op_bi_required  :='N';
      op_get_bal_info :=NULL;
      op_carrier_type :='NA';
      op_err_code     := 0;
      op_err_msg      := 'Success';
      RETURN;
    --ELSIF (v_service_plan_group IN ('LIMITED','PAY_GO','VOICE_ONLY','TFSL_UNLIMITED')) THEN
    ELSIF (v_service_plan_group IN ('LIMITED','PAY_GO','VOICE_ONLY')) THEN --CR56512 change
      BEGIN
        --s_ret := s.retrieve(i_ignore_tw_logic_flag => 'Y');
        from_cst_ret          := from_cst.retrieve;
        to_cst_ret            := to_cst.retrieve;
        -- CR47024 IF TFSL_UNLIMITED then use data meter source.
        --CR56512 changes start
        /*IF v_service_plan_group = 'TFSL_UNLIMITED' THEN
           v_from_met_src_id     := from_cst_ret.meter_source_data;
        ELSE
        v_from_met_src_id     := from_cst_ret.meter_source_voice;
        END IF;*/
        v_from_met_src_id     := from_cst_ret.meter_source_voice;
        --CR56512 changes end

        v_parent_carrier_name := from_cst_ret.parent_name;
        /*IF(s_ret.status   NOT LIKE '%SUCCESS%') THEN
        op_err_msg :='Retrieve Fail '||s_ret.status;
        RETURN;
        END IF;*/
        SELECT ht.short_name
        INTO v_from_met_src
        FROM x_usage_host ht
        WHERE ht.carrier_mtg_id=v_from_met_src_id;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        op_err_code := -500;
        op_err_msg  := 'Faliure :From Metering source not found';
        RETURN;
      WHEN OTHERS THEN
        op_err_code := SQLCODE;
        op_err_msg  := 'Failed in fetching From Metering source' ;
        RETURN;
      END;
      v_ppe_flag := to_cst_ret.non_ppe_flag;
      /* BEGIN
      SELECT vw.non_ppe
      INTO v_ppe_flag
      FROM table_part_inst pi,
      table_mod_level ml,
      table_part_num pn,
      table_part_class pc,
      sa.pcpv vw
      WHERE pi.part_serial_no    = ip_to_esn
      AND pi.n_part_inst2part_mod= ml.objid
      AND ml.part_info2part_num  = pn.objid
      AND pn.part_num2part_class = pc.objid
      AND pc.name                = vw.part_class;
      EXCEPTION
      WHEN OTHERS THEN
      v_ppe_flag :=NULL;
      END;*/
     --CR41433
     --CR47844 Changed logic to check for old/new esn for SAFELINK
      BEGIN
        SELECT 'Y'
          INTO v_safelink
          FROM x_sl_currentvals cv
         WHERE cv.x_current_esn          = ip_from_esn
           AND ROWNUM                      =1;

       EXCEPTION
       WHEN OTHERS THEN
         v_safelink := 'N';

         BEGIN
            SELECT 'Y'
              INTO v_safelink
              FROM x_program_enrolled pe,
                   x_program_parameters pr
             WHERE pe.x_esn = ip_from_esn
               AND pe.x_enrollment_status      ='ENROLLED'
               AND pe.pgm_enroll2pgm_parameter = pr.objid
               AND pr.x_prog_class             = 'LIFELINE'
               AND ROWNUM                      =1;

         EXCEPTION
         WHEN OTHERS THEN
            v_safelink := 'N';
           -- CR47908_Safelink_Unlimited_project_post_rollout
           -- If the customer is not in the x_sl_currentvals table with old esn
           -- see if they are in table with new esn.
           BEGIN
              SELECT 'Y'
	        INTO v_safelink
	        FROM x_sl_currentvals cv
	       WHERE cv.x_current_esn          = ip_to_esn
                 AND ROWNUM                      =1;
            EXCEPTION
            WHEN OTHERS THEN
               v_safelink := 'N';
            END;
         END;


      END;
      IF (NVL(v_ppe_flag,'X')='0') THEN
        SELECT carrier_mtg_id ,
          short_name
        INTO v_to_met_src_id,
          v_to_met_src
        FROM x_usage_host
        WHERE short_name='PPE';
      ELSE
        BEGIN
          nap_digital( p_zip => ip_zip_code, p_esn => ip_to_esn, p_commit => 'N', p_language => 'English', P_SIM => ip_to_sim, p_source => ip_source, p_upg_flag => 'N', p_repl_part => op_part_number, p_repl_tech => repl_tech, p_sim_profile => op_sim_profile, p_part_serial_no => part_serial_no, P_MSG => msg, p_pref_parent => pref_parent, p_pref_carrier_objid => pref_carrier_objid );
        END;
        --sa.sp_get_esn_parameter_value(ip_to_esn, 'DEVICE_TYPE', lv_debug, lv_parameter_value, lv_error_code, lv_error_message);
        lv_parameter_value      := get_device_type(ip_to_esn);
        IF lv_parameter_value    ='BYOP' THEN
          v_device_group        :='SMARTPHONE';
        ELSIF lv_parameter_value ='SMARTPHONE' THEN
          v_device_group        :='SMARTPHONE';
        ELSIF lv_parameter_value ='FEATURE_PHONE' THEN
          v_device_group        :='FEATURE_PHONE';
        ELSE
          v_action := 'Not supported device group';
          --RAISE user_exception;
        END IF;

	-- CR 49276, Return the balance enquiry flag as 'Y' If Units transfer from Active PPE to Active smart phone.
	l_from_esn_device := get_device_type(ip_from_esn);

	IF ( IP_BRAND = 'TRACFONE'
	   AND l_from_esn_device IN ('FEATURE_PHONE','SMARTPHONE','BYOP')  --CR49354
	   AND lv_parameter_value IN ('SMARTPHONE','BYOP')
       AND from_cst_ret.min_part_inst_status  = 13
	   AND NVL(IP_IS_UNIT_TRANSFER,'N') = 'Y') -- EME CR54118 mdave 10/13/2017
		/* Parameter added to treat Unit Transfer(new min) seperately from Upgrade (same min)  */
		/* In case of Unit Transfer scenario, TAS would send the value as Y which would return balance enquiry = Y */
	THEN
              op_bi_required  := 'Y';
              op_get_bal_info := NULL;
              op_carrier_type := NULL;
              op_err_code     := 0;
              op_err_msg      := 'Success';
			  RETURN;
    END IF;	--CR 49276

        IF pref_carrier_objid IS NULL THEN
          op_err_code         := -400;
          op_err_msg          := msg;
          RETURN;
        ELSE
          BEGIN
            SELECT DISTINCT x_parent_name
            INTO v_carrier_name
            FROM table_x_parent p,
              table_x_carrier_group cg,
              table_x_carrier carr
            WHERE p.objid         = cg.x_carrier_group2x_parent
            AND cg.objid          = carr.carrier2carrier_group
            AND carr.objid        = pref_carrier_objid
            AND upper(p.x_status) ='ACTIVE';
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_action    := 'Not able to find the carrier name for given ESN';
            op_err_code := -400;
            op_err_msg  := 'Failure:Not able to find carrier for to ESN';
            RETURN;
          WHEN OTHERS THEN
            op_err_code := SQLCODE;
            op_err_msg  := 'Failure oracle error:Not able to find carrier for to ESN';
            RETURN;
          END;
        END IF;
        -- CR47138 changes starts..
        -- Changes done to get the metering id through type member function
        c := c.get_meter_sources (i_device_type        => v_device_group  ,
                                  i_source_system      => NULL            ,
                                  i_brand              => l_brand         ,
                                  i_parent_name        => v_carrier_name  ,
                                  i_service_plan_group => v_service_plan_group );
        --
        BEGIN
          SELECT carrier_mtg_id,
                 short_name
          INTO   v_to_met_src_id,
                 v_to_met_src
          FROM   x_usage_host
          WHERE  carrier_mtg_id = c.meter_source_voice; /*CASE WHEN	v_service_plan_group = 'TFSL_UNLIMITED' -- CR47024
									   THEN c.meter_source_data
                                       ELSE c.meter_source_voice
                                  END;*/ ----CR56512 changes - removed CASE statement
          /*
          SELECT carrier_mtg_id,
                 short_name
            INTO v_to_met_src_id,
                 v_to_met_src
            FROM (
                  SELECT DISTINCT carrier_mtg_id,
                         uh.short_name,
                         pc.service_plan_group
                    FROM x_product_config pc,
                         x_usage_host UH
                   WHERE pc.parent_name   =v_carrier_name
                     AND pc.device_type     =v_device_group
                     AND pc.brand_name      =ip_brand
                     AND uh.short_name = CASE WHEN pc.service_plan_group = 'TFSL_UNLIMITED' -- CR47024
                                              THEN pc.data_mtg_source
                                              ELSE pc.voice_mtg_source
                                               END
                     AND NVL(pc.service_plan_group,'X') = CASE WHEN pc.service_plan_group IS NOT NULL
                                                                 AND
                                                                 pc.service_plan_group = v_service_plan_group
                                                            THEN service_plan_group
                                                            ELSE 'X'
                                                             END
                           ORDER BY  CASE WHEN pc.service_plan_group = v_service_plan_group
                                          THEN 1
                                          ELSE 2
                                            END)
           WHERE ROWNUM = 1;
          */
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          op_err_code :='-300';
          op_err_msg  :='Failure-No data found in product config';
          RETURN;
        WHEN OTHERS THEN
          op_err_code :=SQLCODE;
          op_err_msg  :='Failure oracle error in product config';
          RETURN;
        END;
      END IF;
      IF ( (v_from_met_src_id =v_ppe_meter_source_id AND v_to_met_src_id= v_ppe_meter_source_id ) OR ( v_from_met_src_id <>v_ppe_meter_source_id AND v_to_met_src_id <> v_ppe_meter_source_id ) )--limited paygo same carrier other than PPE,from PPE to PPE
        THEN
        v_brand:='ANY';
      END IF;
      IF (v_safelink = 'Y' ) THEN
        v_brand     :='SL';
      END IF;
      BEGIN
        SELECT DECODE(get_balance_flag,'Yes','Y','No','N',get_balance_flag),
          get_balance_info,
          CASE
            WHEN from_balance_metering_id = to_balance_metering_id
            THEN 'SAME_CARRIER'
            ELSE 'CROSS_CARRIER'
          END carrier_type
        INTO v_bal_inq_required,
          v_get_balance_info,
          v_carrier_type
        FROM sa.phone_upgrade_benefits
        WHERE brand_name          =v_brand
        AND service_plan_group    =v_service_plan_group
        AND action                =ip_action
        AND from_balance_metering =v_from_met_src
        AND to_balance_metering   =v_to_met_src;
        op_bi_required           :=v_bal_inq_required;
        op_get_bal_info          :=v_get_balance_info;
        op_carrier_type          :=v_carrier_type;
        op_err_code              := 0;
        op_err_msg               := 'Success';

      dbms_output.put_line('v_brand :'||v_brand ||',v_service_plan_group:'||v_service_plan_group
	                    ||',ip_action:'||ip_action||',v_from_met_src:'||v_from_met_src||',v_to_met_src:'||v_to_met_src);

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        op_err_code := -200;
        op_err_msg  := 'Failure -phone upgrade config data not found';
        RETURN;
      WHEN OTHERS THEN
        op_err_code := SQLERRM;
        op_err_msg  := 'Failure : Oracle error in phone upgrage';
        RETURN;
      END;
    ELSE
      op_bi_required  :='N';
      op_get_bal_info :=NULL;
      op_carrier_type :=NULL;
      op_err_code     := -100;
      op_err_msg      := 'Failure- Not supported service plan';
      RETURN;
    END IF;
  END LOOP;
  IF v_service_plan_group IS NULL THEN
    op_bi_required        :='N';
    op_get_bal_info       :=NULL;
    op_carrier_type       :=NULL;
    op_err_code           := -600;
    op_err_msg            := 'Failure-service plan not found';
    RETURN;
  END IF;
  dbms_output.put_line('v_action' || v_action);
  IF op_bi_required IS NULL THEN
    op_bi_required := 'N';
  END IF;
END sp_get_bi_required;

PROCEDURE create_bi_trans(
    IP_ESN                         IN VARCHAR2 ,
    ip_voice_mtg_source            IN VARCHAR2 ,
    ip_voice_trans_id              IN VARCHAR2 ,
    ip_text_mtg_source             IN VARCHAR2 ,
    ip_text_trans_id               IN VARCHAR2 ,
    ip_data_mtg_source             IN VARCHAR2 ,
    ip_data_trans_id               IN VARCHAR2 ,
    ip_ild_mtg_source              IN VARCHAR2 ,
    ip_ild_trans_id                IN VARCHAR2 ,
    ip_trans_creation_date         IN DATE ,
    ip_X_TIMEOUT_MINUTES_THRESHOLD IN NUMBER ,
    ip_X_DAILY_ATTEMPTS_THRESHOLD  IN NUMBER ,
    OP_OBJID OUT NUMBER ,
    OP_ERR_CODE OUT VARCHAR2 ,
    OP_ERR_MSG OUT VARCHAR2 )
IS
  v_seq NUMBER:=NULL;
  --type_bi_record typ_bi_trans_log;
  trans_rec typ_bi_trans_tbl;
BEGIN
  IF (IP_ESN IS NOT NULL ) THEN
    v_seq    :=sa.sequ_x_bi_transaction_log.nextval;
    BEGIN
      INSERT
      INTO sa.x_bi_transaction_log
        (
          OBJID,
          ESN,
          voice_mtg_source ,
          voice_trans_id ,
          text_mtg_source ,
          text_trans_id ,
          data_mtg_source ,
          data_trans_id ,
          ild_mtg_source ,
          ild_trans_id ,
          trans_creation_date,
          X_TIMEOUT_MINUTES_THRESHOLD ,
          X_DAILY_ATTEMPTS_THRESHOLD
        )
        VALUES
        (
          v_seq,
          IP_ESN,
          ip_voice_mtg_source ,
          ip_voice_trans_id ,
          ip_text_mtg_source ,
          ip_text_trans_id ,
          ip_data_mtg_source ,
          ip_data_trans_id ,
          ip_ild_mtg_source ,
          ip_ild_trans_id ,
          sysdate ,
          ip_X_TIMEOUT_MINUTES_THRESHOLD ,
          ip_X_DAILY_ATTEMPTS_THRESHOLD
        );
      IF SQL%ROWCOUNT =1 THEN
        --  COMMIT;
        OP_OBJID   :=v_seq;
        OP_ERR_CODE:='0';
        OP_ERR_MSG :='Success';
      ELSE
        OP_ERR_CODE:='-1';
        OP_ERR_MSG :='Failure-record not created';
      END IF;
      --DBMS_OUTPUT.PUT_LINE('SQLRC ;'||SQL%ROWCOUNT);
      --COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
      OP_ERR_CODE:=SQLCODE;
      OP_ERR_MSG :=SQLERRM;
    END;
  ELSE
    OP_ERR_CODE:='1';
    OP_ERR_MSG :='Failure:Not enough values';
  END IF;
  --DBMS_OUTPUT.PUT_LINE('SQLRC ;'||SQL%ROWCOUNT);
  -- IF (IP_ESN IS NOT NULL AND IP_MET_SRC IS  NULL AND IP_TRANS_ID IS  NULL AND IP_TRANS_CR_DT IS  NULL)
  --THEN
  -- END IF;
  --NULL;
END create_bi_trans;

PROCEDURE search_bi_trans
  (
    IP_ESN IN VARCHAR2 ,
    OP_LAST_TRANS_FLAG OUT VARCHAR2 ,
    OP_BI_COUNT OUT VARCHAR2 ,
    OP_TRANS_REC OUT typ_bi_trans_tbl ,
    OP_ERR_CODE OUT VARCHAR2 ,
    OP_ERR_MSG OUT VARCHAR2
  )
IS
  trans_rec typ_bi_trans_tbl;
  c_minutes_interval  VARCHAR2(100);
BEGIN
  OP_LAST_TRANS_FLAG:='N';
  IF (IP_ESN        IS NOT NULL ) THEN

    BEGIN
      SELECT X_PARAM_VALUE
      INTO c_minutes_interval
      FROM TABLE_X_PARAMETERS
      WHERE X_PARAM_NAME='BI_TRANSACTION_MINUTES_INTERVAL' -- CR49721 WFM  Changes
      AND ROWNUM        =1;
     EXCEPTION
       WHEN others THEN
         c_minutes_interval := '15';
    END;

    BEGIN
      SELECT DISTINCT 'Y'
      INTO OP_LAST_TRANS_FLAG
      FROM sa.x_bi_transaction_log
      WHERE ESN             =IP_ESN
      AND INSERT_TIMESTAMP >= SYSDATE -c_minutes_interval/(24*60) ;

    EXCEPTION
    WHEN OTHERS THEN
      OP_LAST_TRANS_FLAG:='N';
    END ;

    BEGIN
      SELECT COUNT(OBJID)
      INTO OP_BI_COUNT
      FROM sa.x_bi_transaction_log
      WHERE ESN             =IP_ESN
      AND INSERT_TIMESTAMP >= TRUNC(SYSDATE);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      OP_BI_COUNT :=0;
    END;
    BEGIN
      SELECT typ_bi_trans_obj(objid , esn , voice_mtg_source , voice_trans_id , text_mtg_source , text_trans_id , data_mtg_source , data_trans_id, ild_mtg_source , ild_trans_id , trans_creation_date , X_TIMEOUT_MINUTES_THRESHOLD , X_DAILY_ATTEMPTS_THRESHOLD) bulk collect
      INTO TRANS_REC
      FROM sa.X_BI_TRANSACTION_LOG
      WHERE OBJID=
        (SELECT MAX(OBJID)
        FROM sa.X_BI_TRANSACTION_LOG
        WHERE ESN             =IP_ESN
        AND INSERT_TIMESTAMP >= SYSDATE - c_minutes_interval/(24*60)
        );

    IF CUSTOMER_INFO.get_bus_org_id (IP_ESN) ='WFM' THEN
      IF (CUSTOMER_INFO.get_last_addon_redemption_date(IP_ESN)   >= TRANS_REC(1).trans_creation_date) THEN   -- CR49721  WFM Changes
        OP_LAST_TRANS_FLAG               :='N';
      END IF;
    END IF;


      OP_TRANS_REC      := TRANS_REC;
      OP_ERR_CODE       :='0';
      OP_ERR_MSG        :='Success';
      IF (TRANS_REC.COUNT=0)THEN
        --OP_BI_COUNT :=0;
        OP_ERR_CODE :='0';
        OP_ERR_MSG  :='Success No data found';
      END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- OP_BI_COUNT :=0;
      OP_ERR_CODE :='0';
      OP_ERR_MSG  :='Success';
    WHEN OTHERS THEN
      OP_ERR_CODE:=SQLCODE;
      OP_ERR_MSG :=SQLERRM;
    END;
  ELSE
    OP_ERR_CODE:='1';
    OP_ERR_MSG :='Failure:Not enough values';
  END IF;
END search_bi_trans;

PROCEDURE get_bi_trans(
    IP_OBJID IN NUMBER ,
    OP_TRANS_REC OUT typ_bi_trans_tbl ,
    OP_ERR_CODE OUT VARCHAR2 ,
    OP_ERR_MSG OUT VARCHAR2 )
IS
  trans_rec typ_bi_trans_tbl;
BEGIN
  IF (IP_OBJID IS NOT NULL) THEN
    SELECT typ_bi_trans_obj(objid , esn , voice_mtg_source , voice_trans_id , text_mtg_source , text_trans_id , data_mtg_source , data_trans_id, ild_mtg_source , ild_trans_id , trans_creation_date , X_TIMEOUT_MINUTES_THRESHOLD , X_DAILY_ATTEMPTS_THRESHOLD) bulk collect
    INTO TRANS_REC
    FROM sa.X_BI_TRANSACTION_LOG
    WHERE OBJID        =IP_OBJID;
    OP_TRANS_REC      :=TRANS_REC;
    OP_ERR_CODE       :='0';
    OP_ERR_MSG        :='Success';
    IF (TRANS_REC.COUNT=0)THEN
      OP_ERR_CODE     :='-1';
      OP_ERR_MSG      :='Balance Transaction ID not found';
    END IF;
  ELSE
    OP_ERR_CODE:='-1';
    OP_ERR_MSG :='Failure:objid is null';
  END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  OP_ERR_CODE:='2';
  OP_ERR_MSG :='Failure:objid not found ';
WHEN OTHERS THEN
  OP_ERR_CODE:=SQLCODE;
  OP_ERR_MSG :=SQLERRM;
END get_bi_trans;

PROCEDURE sp_get_bal_cfg_id(
    IP_ESN   IN VARCHAR2,
    IP_BRAND IN VARCHAR2,
    IP_CHL   IN VARCHAR2 ,
    OP_FLOW_ID OUT VARCHAR2,
    OP_SCRIPT_ID OUT VARCHAR2,
    OP_ERR_CODE OUT NUMBER,
    OP_ERR_MSG OUT VARCHAR2)
IS
  v_action        VARCHAR2 (1000) := NULL;
  c_device_type   VARCHAR2(50);
  v_flow_id X_BI_FLOW_CONFIG.X_FLOW_ID%TYPE;
  v_script_id X_BI_FLOW_CONFIG.X_SCRIPT_ID%TYPE;
  v_carrier_id table_x_parent.x_parent_id%TYPE;
  v_carrier_name table_x_parent.x_parent_name%TYPE;
  P_PARAMETER_VALUE VARCHAR2(50);
  lv_debug          INTEGER := 0;
  lv_parameter_value sa.table_x_part_class_values.x_param_value%TYPE;
  lv_error_code    INTEGER;
  lv_error_message VARCHAR2(4000);
  cst customer_type := customer_type();
  c   customer_type := customer_type();
  l_sub_brand     VARCHAR2(100);  -- CR44729
  l_brand         VARCHAR2(100);  -- CR44729
  v_device_count varchar2(50);
BEGIN

  c.parent_name := c.get_parent_name ( i_esn => ip_esn );
  c.bus_org_id:=c.get_bus_org_id(i_esn => ip_esn); --CR53217
  DBMS_OUTPUT.PUT_LINE('PARENT NAME :'||c.parent_name);

  -- finding the device type like feature phone or smart phone
  IF IP_ESN IS NOT NULL AND IP_BRAND IS NOT NULL THEN
    sa.sp_get_esn_parameter_value(IP_ESN, 'DEVICE_TYPE', lv_debug, lv_parameter_value, lv_error_code, lv_error_message);
    P_PARAMETER_VALUE := lv_parameter_value;
    SELECT
    COUNT(*)
INTO
    v_device_count
FROM
    x_product_config
WHERE
    device_type = p_parameter_value;

IF
    p_parameter_value = 'BYOP'
THEN
    c_device_type := 'SMARTPHONE';
ELSIF p_parameter_value <> 'BYOP' AND v_device_count > 0 THEN
    --P_PARAMETER_VALUE IN ('SMARTPHONE','FEATURE_PHONE','MOBILE_BROADBAND','BYOT') THEN --Added 'MOBILE_BROADBAND','BYOT' as part of CR53217
    c_device_type := p_parameter_value;
ELSE
    v_action := 'Not supported device group';
      --RAISE user_exception;
END IF;
    --finding the parent carrier details
    DBMS_OUTPUT.PUT_LINE('PARAM VALUE :'||P_PARAMETER_VALUE);
    BEGIN
      SELECT DISTINCT x_parent_name--DECODE (x_parent_name,'CINGULAR','AT&T WIRELESS','DOBSON CELLULAR','AT&T WIRELESS','DOBSON GSM','AT&T WIRELESS','T-MOBILE PREPAY PLATFORM','T-MOBILE', 'VERIZON PREPAY PLATFORM','VERIZON WIRELESS',x_parent_name)
      INTO   v_carrier_name
      FROM   table_x_parent p
      WHERE  X_PARENT_NAME = c.parent_name
      AND    upper(X_STATUS) ='ACTIVE';
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_action   := 'Not able to find the carrier name for given ESN';
      op_err_code:=-1;
      op_err_msg :='Fail:Not able to find parent carrier id';
    END;
    DBMS_OUTPUT.PUT_LINE('CARRIER ID :'||v_carrier_ID);
  ELSE
    v_action   := ' Failed to retrieve records: IP_ESN and IP_BRAND cannot be null';
    op_err_code:=-1;
    op_err_msg :='ESN/Brand is null';
    --RAISE user_exception;
  END IF;

  -- set the esn
  cst.esn := ip_esn;

  -- call the function to get the service plan group
  cst := cst.get_service_plan_attributes;
  --
  -- CR44729 changes starts..
  -- Get sub brand for the esn
  c.esn       := ip_esn;
  c.sub_brand := c.get_sub_brand;
  --
  IF NVL(c.sub_brand,'X') = 'GO_SMART'
  THEN
    l_brand   :=  c.sub_brand ;
  ELSE
    l_brand   :=  ip_brand  ;
  END IF;
  -- CR44729 changes ends
  -- get the meter sources and the balance config ids
  --CR44107 - use the function transform_device_type as below
  c := c.get_meter_sources ( i_device_type        => sa.Transform_device_type(c_device_type,ip_esn),
                             i_brand              => l_brand                ,   -- CR44729
                             i_parent_name        => v_carrier_name         ,
                             i_service_plan_group => cst.service_plan_group );

  BEGIN
    IF IP_CHL = 'WEB' THEN
      --
      -- CR40903_My_Account_App_Data_Balance_Inquiry_Update Tim 7/5/2016 added service plan group
      --

      -- get the flow id and script id
      BEGIN
        SELECT x_flow_id,
               x_script_id
        INTO   v_flow_id,
               v_script_id
        FROM   x_bi_flow_config bfg,
               ( SELECT bal_cfg_id_web
                 FROM  ( SELECT c.web_balance_config_id bal_cfg_id_web
                         FROM   DUAL
                       )
               ) cfg
        WHERE  cfg.bal_cfg_id_web = bfg.x_bal_cfg_id
         AND bfg.X_BRAND_NAME=nvl(ip_brand,c.bus_org_id); --CR53217

        OP_FLOW_ID   := v_flow_id;
        OP_SCRIPT_ID := v_script_id;
        op_err_code  := 0;
        op_err_msg   := 'Success';
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        op_err_code := 0;
        op_err_msg := 'Success-No datafound';
      WHEN OTHERS THEN
        op_err_code:=SQLCODE;
        op_err_msg :='Oracle Error'||SUBSTR(sqlerrm,1,100);
      END;
    ELSIF IP_CHL ='IVR' THEN

      -- get the flow id and script id
      BEGIN
        SELECT x_flow_id,
               x_script_id
        INTO   v_flow_id,
               v_script_id
        FROM   x_bi_flow_config bfg,
               ( SELECT bal_cfg_id_ivr
                 FROM  ( SELECT c.ivr_balance_config_id bal_cfg_id_ivr
                         FROM   DUAL
                       )
               ) cfg
        WHERE cfg.bal_cfg_id_ivr = bfg.x_bal_cfg_id
        AND bfg.X_BRAND_NAME=nvl(ip_brand,c.bus_org_id); --CR53217

        op_flow_id   := v_flow_id;
        op_script_id := v_script_id;
        op_err_code  := 0;
        op_err_msg   := 'Success';

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        op_err_code:=0;
        op_err_msg :='Success-No datafound';
      WHEN OTHERS THEN
        op_err_code:=SQLCODE;
        op_err_msg :='Oracle Error'||SUBSTR(sqlerrm,1,100);
      END;
    ELSIF IP_CHL IS NULL THEN
      op_err_code:=-1;
      op_err_msg :='Failure :Channel is null';
    ELSE
      op_err_code:=-1;
      op_err_msg :='Failure :not supported Channel';
    END IF;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_action   := 'Not able to find the Balance config for given ESN';
    op_err_code:=-1;
    op_err_msg :='Fail:not able to retrieve bal cfg id';
  END;
EXCEPTION
WHEN OTHERS THEN
  OTA_UTIL_PKG.ERR_LOG( v_action,                                                                                                         --p_action
  SYSDATE,                                                                                                                                --p_error_date
  IP_ESN ||'-'||IP_BRAND,                                                                                                                 --p_key
  'DEVICE_UTIL_PKG.SP_GET_BAL_CFG_ID',                                                                                                    --p_program_name
  'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
  );
  --RAISE;
END sp_get_bal_cfg_id;

PROCEDURE sp_get_target_mtg(
    IP_ESN            IN VARCHAR2,
    IP_BRAND          IN VARCHAR2 ,
    IP_DEVICE_GROUP   IN VARCHAR2 DEFAULT NULL,
    IP_DEVICE_TECH    IN VARCHAR2 DEFAULT NULL,
    IP_PART_CLASS     IN VARCHAR2 DEFAULT NULL,
    IP_CARRIER_ID     IN NUMBER ,
    IP_SER_PLAN_GROUP IN VARCHAR2 DEFAULT NULL,
    out_cur OUT return_tgt_mtg_src_tbl,
    op_error_code OUT VARCHAR2 ,
    op_error_message OUT VARCHAR2 )
AS
  c_device_type      VARCHAR2(50);
  v_carrier_id       table_x_parent.x_parent_ID%TYPE;
  v_carrier_name     table_x_parent.x_parent_name%TYPE;
  v_VOICE_MTG_SOURCE VARCHAR2(50);
  P_PARAMETER_VALUE  VARCHAR2(50);
  lv_debug           INTEGER := 0;
  lv_parameter_value sa.table_x_part_class_values.x_param_value%TYPE;
  lv_error_code    INTEGER;
  lv_error_message VARCHAR2(4000);
  v_action         VARCHAR2 (1000) := NULL;
  cst customer_type := customer_type();
  c   customer_type := customer_type();
  v_service_plan_group sa.service_plan_feat_pivot_mv.service_plan_group%type; -- CR42459
  l_sub_brand     VARCHAR2(100);  -- CR44729
  l_brand         VARCHAR2(100);  -- CR44729
BEGIN
  --
  IF IP_DEVICE_GROUP IS NULL THEN
    sa.sp_get_esn_parameter_value ( IP_ESN, 'DEVICE_TYPE', lv_debug, lv_parameter_value, lv_error_code, lv_error_message );
    IF lv_parameter_value = 'BYOP' THEN
      c_device_type := 'SMARTPHONE';
    ELSIF lv_parameter_value = 'SMARTPHONE' THEN
      c_device_type := 'SMARTPHONE';
    ELSIF lv_parameter_value = 'FEATURE_PHONE' THEN
      c_device_type := 'FEATURE_PHONE';
    ELSE
      v_action := 'Not supported device group';
      --RAISE user_exception;
    END IF;
  ELSE
    c_device_type :=  IP_DEVICE_GROUP;
  END IF;

  DBMS_OUTPUT.PUT_LINE('c_device_type ' || c_device_type);
  DBMS_OUTPUT.PUT_LINE('lv_parameter_value ' || lv_parameter_value);
  DBMS_OUTPUT.PUT_LINE('lv_error_code ' || lv_error_code);
  DBMS_OUTPUT.PUT_LINE('lv_error_message ' || lv_error_message);
  --
  BEGIN
    SELECT DISTINCT x_parent_name--DECODE (x_parent_name,'CINGULAR','AT&T WIRELESS','DOBSON CELLULAR','AT&T WIRELESS','DOBSON GSM','AT&T WIRELESS','T-MOBILE PREPAY PLATFORM','T-MOBILE', 'VERIZON PREPAY PLATFORM','VERIZON WIRELESS',x_parent_name)
    INTO   v_carrier_name
    FROM   table_x_parent p,
           table_x_carrier_group cg,
           table_x_carrier carr
    WHERE  p.objid = cg.x_carrier_group2x_parent
    AND    cg.objid  = carr.carrier2carrier_group
    AND    carr.objid = ip_carrier_id
    AND    upper(p.x_status) = 'ACTIVE';

    DBMS_OUTPUT.PUT_LINE('v_carrier_id' || v_carrier_id);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       v_action := 'Not able to find the carrier name for given ESN';
       --OP_SW_METERING   := NULL;
       op_error_code    := SQLCODE;
       op_error_message := SUBSTR(SQLERRM, 1, 100);
       DBMS_OUTPUT.PUT_LINE('v_action' || v_action);
       -- write to error_table
       --ota_util_pkg.err_log(v_action => v_ACTION, p_error_date => SYSDATE, p_key => ip_esn, p_program_name => 'SA.SP_GET_OP_SW_METERING', p_error_text => op_error_message );
  END;

  BEGIN
    --
    -- CR40903_My_Account_App_Data_Balance_Inquiry_Update Tim 7/5/2016 added service plan group
    --

    -- set esn
    c.esn := ip_esn;
    --
    if  ip_ser_plan_group IS NOT NULL THEN
       v_service_plan_group := ip_ser_plan_group;
    else
       c := c.get_service_plan_attributes;
       v_service_plan_group := c.service_plan_group;
    end if;
    --
    -- CR44729 changes starts..
    -- Get sub brand for the esn
    c.sub_brand := c.get_sub_brand;
    --
    IF NVL(c.sub_brand,'X') = 'GO_SMART'
    THEN
      l_brand   :=  c.sub_brand ;
    ELSE
      l_brand   :=  ip_brand  ;
    END IF;
    -- CR44729 changes ends
    -- call the retrieve method to get all the metering sources
    --CR44107 - use the function transform_device_type as below
    cst := cst.get_meter_sources ( i_device_type        => sa.Transform_device_type(c_device_type,ip_esn),
                                   i_brand              => l_brand             ,-- CR44729
                                   i_parent_name        => v_carrier_name       ,
                                   i_service_plan_group => v_service_plan_group );

    --
    SELECT return_tgt_mtg_src_obj ( meter_source_voice ,
                                    meter_source_sms   ,
                                    meter_source_data  ,
                                    meter_source_ild   )
    BULK COLLECT
    INTO   OUT_CUR
    FROM   ( SELECT cst.meter_source_voice ,
                    cst.meter_source_sms   ,
                    cst.meter_source_data  ,
                    cst.meter_source_ild
             FROM   DUAL
           ) pc;

    op_error_code      :='0';
    op_error_message   :='Success';

    IF (OUT_CUR.COUNT   =0) THEN
      op_error_code    :='1';
      op_error_message :='Fail-No data found in product config';
    END IF;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       op_error_code    :='1';
       op_error_message :='Fail-No data found in product config';
       out_cur          :=NULL;
     WHEN OTHERS THEN
       op_error_code    :=SQLCODE;
       op_error_message :='Faliure in retrieving prod cfg'||SUBSTR(sqlerrm,1,50);
  END;

END sp_get_target_mtg;

PROCEDURE sp_get_current_mtg_wrapper(
    IP_ESN IN VARCHAR2 ,
    OP_VOICE_MTG_SOURCE OUT VARCHAR2,
    OP_SMS_MTG_SOURCE OUT VARCHAR2,
    OP_DATA_MTG_SOURCE OUT VARCHAR2,
    OP_ILD_MTG_SOURCE OUT VARCHAR2,
    OP_ERR_CODE OUT NUMBER,
    OP_ERR_MSG OUT VARCHAR2)
AS
  RET_MET_TYPE RETURN_MET_SOURCE_TBL:=RETURN_MET_SOURCE_TBL();
  V_ERR_CODE NUMBER;
  V_ERR_MSG  VARCHAR2(1000);
BEGIN
  SP_GET_CURRENT_MTG(IP_ESN=>IP_ESN,OUT_CUR=>RET_MET_TYPE,OP_ERR_CODE=>V_ERR_CODE,OP_ERR_MSG=>V_ERR_MSG);
  FOR i IN 1..RET_MET_TYPE.count
  LOOP
    OP_VOICE_MTG_SOURCE := RET_MET_TYPE(i).VOICE_MTG_SOURCE;
    OP_SMS_MTG_SOURCE   := RET_MET_TYPE(i).SMS_MTG_SOURCE;
    OP_DATA_MTG_SOURCE  := RET_MET_TYPE(i).DATA_MTG_SOURCE;
    OP_ILD_MTG_SOURCE   := RET_MET_TYPE(i).ILD_MTG_SOURCE;
    EXIT;
  END LOOP;
  OP_ERR_CODE:=V_ERR_CODE;
  OP_ERR_MSG :=V_ERR_MSG;
EXCEPTION
WHEN OTHERS THEN
  OP_ERR_CODE:=SQLCODE;
  OP_ERR_MSG :=SUBSTR(SQLERRM,1,100);
END sp_get_current_mtg_wrapper;

PROCEDURE create_bi_notification(
    IP_CLIENT_TRANS_ID    IN VARCHAR2,
    IP_CLIENT_ID          IN VARCHAR2,
    IP_ESN                IN VARCHAR2,
    IP_MIN                IN VARCHAR2,
    IP_BRAND              IN VARCHAR2,
    IP_SOURCE_SYSTEM      IN VARCHAR2,
    IP_BALANCE_TRANS_ID   IN VARCHAR2,
    IP_BALANCE_TRANS_DATE IN DATE,
    IP_NOTIFICATION_TYPE  IN VARCHAR2,
    IP_RETRY_COUNT        IN NUMBER,
    IP_STATUS             IN VARCHAR2,
   IP_language         IN VARCHAR2,
    OP_OBJID OUT NUMBER,
    OP_ERR_CODE OUT NUMBER,
    OP_ERR_MSG OUT VARCHAR2 )
AS
  v_seq NUMBER;
BEGIN
  v_seq :=sa.sequ_x_bi_notification_stg.nextval;
  INSERT
  INTO X_BI_NOTIFICATION_STG
    (
      OBJID ,
      CLIENT_TRANS_ID,
      CLIENT_ID ,
      ESN,
      MIN,
      BRAND,
      SOURCE_SYSTEM,
      BALANCE_TRANS_ID,
      BALANCE_TRANS_DATE,
      NOTIFICATION_TYPE ,
      RETRY_COUNT ,
      STATUS,
     language
    )
    VALUES
    (
      v_seq,
      IP_CLIENT_TRANS_ID ,
      IP_CLIENT_ID ,
      IP_ESN,
      IP_MIN,
      IP_BRAND,
      IP_SOURCE_SYSTEM,
      IP_BALANCE_TRANS_ID ,
      SYSDATE ,
      IP_NOTIFICATION_TYPE ,
      IP_RETRY_COUNT ,
      IP_STATUS,
     IP_language
    );
  IF (SQL%ROWCOUNT =1) THEN
    OP_OBJID      :=v_seq;
    OP_ERR_CODE   :='0';
    OP_ERR_MSG    :='Success';
  ELSE
    OP_ERR_CODE:='-1';
    OP_ERR_MSG :='Failure-record not created';
  END IF;
EXCEPTION
WHEN OTHERS THEN
  OP_ERR_CODE:='-1';
  OP_ERR_MSG :='Failure'||SUBSTR(sqlerrm,1,100);
END create_bi_notification;

PROCEDURE update_bi_notification
  (
    IP_OBJID       IN NUMBER,
    IP_RETRY_COUNT IN NUMBER,
    IP_STATUS      IN VARCHAR2,
    OP_ERR_CODE OUT NUMBER,
    OP_ERR_MSG OUT VARCHAR2
  )
AS
BEGIN
  IF (IP_RETRY_COUNT IS NOT NULL AND IP_STATUS IS NULL) THEN
    UPDATE X_BI_NOTIFICATION_STG
    SET retry_count  =IP_RETRY_COUNT
    WHERE objid      =IP_OBJID;
    IF (SQL%ROWCOUNT =1) THEN
      OP_ERR_CODE   :='0';
      OP_ERR_MSG    :='Success';
    ELSE
      OP_ERR_CODE:='-1';
      OP_ERR_MSG :='Failure-record not updated';
    END IF;
  END IF;
  IF (IP_STATUS IS NOT NULL AND IP_RETRY_COUNT IS NULL )THEN
    UPDATE X_BI_NOTIFICATION_STG SET status =IP_STATUS WHERE objid=IP_OBJID;
    IF (SQL%ROWCOUNT =1) THEN
      OP_ERR_CODE   :='0';
      OP_ERR_MSG    :='Success';
    ELSE
      OP_ERR_CODE:='-1';
      OP_ERR_MSG :='Failure-record not updated';
    END IF;
  END IF;
  IF (IP_STATUS IS NOT NULL AND IP_RETRY_COUNT IS NOT NULL )THEN
    UPDATE X_BI_NOTIFICATION_STG
    SET status       =IP_STATUS,
      retry_count    =IP_RETRY_COUNT
    WHERE objid      =IP_OBJID;
    IF (SQL%ROWCOUNT =1) THEN
      OP_ERR_CODE   :='0';
      OP_ERR_MSG    :='Success';
    ELSE
      OP_ERR_CODE:='-1';
      OP_ERR_MSG :='Failure-record not updated';
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  OP_ERR_CODE:=SQLCODE;
  OP_ERR_MSG :='Error :'||SUBSTR(sqlerrm,1,100);
END update_bi_notification;

PROCEDURE search_bi_notification(
    IP_CLIENT_TRANS_ID    IN VARCHAR2,
    IP_CLIENT_ID          IN VARCHAR2,
    IP_ESN                IN VARCHAR2,
    IP_BALANCE_TRANS_ID   IN VARCHAR2,
    IP_BALANCE_TRANS_DATE IN DATE,
    IP_NOTIFICATION_TYPE  IN VARCHAR2,
    OP_OBJID OUT NUMBER,
    OP_ERR_CODE OUT NUMBER,
    OP_ERR_MSG OUT VARCHAR2 )
AS
BEGIN
  SELECT OBJID
  INTO OP_OBJID
  FROM X_BI_NOTIFICATION_STG
  WHERE CLIENT_TRANS_ID =IP_CLIENT_TRANS_ID
  AND CLIENT_ID         =IP_CLIENT_ID
  AND BALANCE_TRANS_ID  =IP_BALANCE_TRANS_ID
  AND BALANCE_TRANS_DATE=IP_BALANCE_TRANS_DATE
  AND NOTIFICATION_TYPE =IP_NOTIFICATION_TYPE
  AND ESN               =IP_ESN ;
  OP_ERR_CODE          :=0;
  OP_ERR_MSG           :='Success';
EXCEPTION
WHEN NO_DATA_FOUND THEN
  OP_ERR_CODE :=-1;
  OP_ERR_MSG  :=' No Data Found';
END search_bi_notification;

PROCEDURE create_swb_transaction(
    IP_CALL_TRANS IN VARCHAR2,
    IP_STATUS     IN VARCHAR2,
    IP_X_TYPE     IN VARCHAR2,
    IP_X_VALUE    IN VARCHAR2,
    IP_EXP_DATE   IN DATE,
    IP_RSID       IN VARCHAR2,
    OP_ERR_CODE OUT NUMBER,
    OP_ERR_MSG OUT VARCHAR2 )
IS
BEGIN
  INSERT
  INTO X_SWITCHBASED_TRANSACTION
    (
      OBJID,
      X_SB_TRANS2X_CALL_TRANS,
      STATUS,
      X_TYPE,
      X_VALUE,
      EXP_DATE,
      RSID
    )
    VALUES
    (
      sa.SEQU_X_SB_TRANSACTION.NEXTVAL,
      IP_CALL_TRANS,
      IP_STATUS,
      IP_X_TYPE,
      IP_X_VALUE,
      IP_EXP_DATE,
      IP_RSID
    );
  IF (SQL%ROWCOUNT =1) THEN
    OP_ERR_CODE   :=0;
    OP_ERR_MSG    :='SUCCESS';
  ELSE
    OP_ERR_CODE:=-1;
    OP_ERR_MSG :='FAIL:RECORD NOT CREATED';
  END IF;
EXCEPTION
WHEN OTHERS THEN
  OP_ERR_CODE:=SQLCODE;
  OP_ERR_MSG :='FAIL: '||SUBSTR(SQLERRM,1,100);
END create_swb_transaction;

PROCEDURE sp_get_target_mtg_wrapper
  (
    IP_ESN            IN VARCHAR2 ,
    IP_BRAND          IN VARCHAR2 ,
    IP_DEVICE_GROUP   IN VARCHAR2 DEFAULT NULL,
    IP_DEVICE_TECH    IN VARCHAR2 DEFAULT NULL,
    IP_PART_CLASS     IN VARCHAR2 DEFAULT NULL,
    IP_CARRIER_ID     IN NUMBER ,
    IP_SER_PLAN_GROUP IN VARCHAR2 DEFAULT NULL,
    OP_VOICE_MTG_SOURCE OUT NUMBER,
    OP_SMS_MTG_SOURCE OUT NUMBER,
    OP_DATA_MTG_SOURCE OUT NUMBER,
    OP_ILD_MTG_SOURCE OUT NUMBER,
    OP_ERR_CODE OUT NUMBER,
    OP_ERR_MSG OUT VARCHAR2
  )
AS
  RET_MET_TYPE return_tgt_mtg_src_tbl:=return_tgt_mtg_src_tbl
  (
  )
  ;
  V_ERR_CODE         NUMBER;
  V_ERR_MSG          VARCHAR2(2000);
  V_VOICE_MTG_SOURCE VARCHAR2(100);
  V_SMS_MTG_SOURCE   VARCHAR2(100);
  V_DATA_MTG_SOURCE  VARCHAR2(100);
  V_ILD_MTG_SOURCE   VARCHAR2(100);
BEGIN
  SP_GET_TARGET_MTG( IP_ESN => IP_ESN, IP_BRAND => IP_BRAND, IP_DEVICE_GROUP => IP_DEVICE_GROUP, IP_DEVICE_TECH => IP_DEVICE_TECH, IP_PART_CLASS => IP_PART_CLASS, IP_CARRIER_ID => IP_CARRIER_ID, IP_SER_PLAN_GROUP => IP_SER_PLAN_GROUP, OUT_CUR => RET_MET_TYPE, OP_ERROR_CODE => V_ERR_CODE, OP_ERROR_MESSAGE => V_ERR_MSG);
  FOR i IN 1..RET_MET_TYPE.count
  LOOP
    V_VOICE_MTG_SOURCE := RET_MET_TYPE(i).VOICE_MTG_SOURCE;
    V_SMS_MTG_SOURCE  := RET_MET_TYPE(i).SMS_MTG_SOURCE;
    V_DATA_MTG_SOURCE := RET_MET_TYPE(i).DATA_MTG_SOURCE;
    V_ILD_MTG_SOURCE  := RET_MET_TYPE(i).ILD_MTG_SOURCE;
    EXIT;
  END LOOP;
  BEGIN
    SELECT
      (SELECT CARRIER_MTG_ID FROM X_USAGE_HOST WHERE SHORT_NAME=V_VOICE_MTG_SOURCE
      ) VOICE_MTG_SOURCE,
      (SELECT CARRIER_MTG_ID FROM X_USAGE_HOST WHERE SHORT_NAME=V_SMS_MTG_SOURCE
      ) VOICE_SMS_SOURCE,
      (SELECT CARRIER_MTG_ID FROM X_USAGE_HOST WHERE SHORT_NAME=V_DATA_MTG_SOURCE
      ) VOICE_DATA_SOURCE,
      (SELECT CARRIER_MTG_ID FROM X_USAGE_HOST WHERE SHORT_NAME=V_ILD_MTG_SOURCE
      ) VOICE_ILD_SOURCE
    INTO OP_VOICE_MTG_SOURCE,
      OP_SMS_MTG_SOURCE,
      OP_DATA_MTG_SOURCE,
      OP_ILD_MTG_SOURCE
    FROM DUAL;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    OP_VOICE_MTG_SOURCE:=NULL;
    OP_SMS_MTG_SOURCE  :=NULL;
    OP_DATA_MTG_SOURCE :=NULL;
    OP_ILD_MTG_SOURCE  :=NULL;
  END;
  OP_ERR_CODE:=V_ERR_CODE;
  OP_ERR_MSG :=V_ERR_MSG;
EXCEPTION
WHEN OTHERS THEN
  OP_ERR_CODE:=SQLCODE;
  OP_ERR_MSG :=SUBSTR(SQLERRM,1,100);
END sp_get_target_mtg_wrapper;

PROCEDURE get_meter_sources ( i_esn           IN  VARCHAR2 ,
                              o_meter_sources OUT meter_source_tab,
                              o_err_code      OUT VARCHAR2,
                              o_err_msg         OUT VARCHAR2,
                              i_source_system   IN  VARCHAR2 DEFAULT NULL -- CR46475
                              ) AS

  ms_tab          meter_source_tab  := meter_source_tab();
  cst             customer_type     := customer_type ();
  c               customer_type     := customer_type ();
  pc              customer_type     := customer_type ();
  c_bus_org_id    VARCHAR2(100);
  c_parent_name   VARCHAR2(100);
  l_source_sys_exist  VARCHAR2(1) :=  'N'; -- CR46475
  l_sub_brand     VARCHAR2(100);  -- CR44729
BEGIN
  --
  -- validate esn
  IF i_esn IS NULL THEN
    o_err_code := '1';
    o_err_msg  := 'ESN NOT PASSED';
    RETURN;
  END IF;
  --
  -- get the part class device type
  pc := pc.get_part_class_attributes ( i_esn => i_esn );
  -- get the brand
  c_bus_org_id := c.get_bus_org_id ( i_esn => i_esn );
  -- get the carrier parent name
  c_parent_name := c.get_parent_name ( i_esn => i_esn );
  -- set the esn
  cst.esn := i_esn;
  -- call the function to get the service plan attributes and service plan group for a particular esn
  c := cst.get_service_plan_attributes;
  -- CR44729 changes starts..
  -- Get sub brand for the esn
  cst.sub_brand := cst.get_sub_brand;
  --
  IF NVL(cst.sub_brand,'X') = 'GO_SMART'
  THEN
    c_bus_org_id  :=  cst.sub_brand ;
  END IF;
  -- CR44729 changes ends
  --
  -- CR46475 Changes starts..
  IF i_source_system IS NOT NULL
  THEN
    BEGIN
      SELECT 'Y'
      INTO   l_source_sys_exist
      FROM   table_x_parameters
      WHERE  x_param_name                         = c_bus_org_id||'_MTG_SOURCE_SYS'
      AND    INSTR(x_param_value,i_source_system) > 0 ;
    EXCEPTION
      WHEN OTHERS THEN
        l_source_sys_exist  :=  'N';
    END;
  ELSE
    l_source_sys_exist  :=  'N';
  END IF;
  -- CR46475 Changes ends
  --DBMS_OUTPUT.PUT_LINE('pc.device_type: ' || pc.device_type);
  --DBMS_OUTPUT.PUT_LINE('c_bus_org_id: ' || c_bus_org_id);
  --DBMS_OUTPUT.PUT_LINE('c_parent_name: ' || c_parent_name);
  --DBMS_OUTPUT.PUT_LINE('c.service_plan_group: ' || c.service_plan_group);

  --
  -- CR40903_My_Account_App_Data_Balance_Inquiry_Update Tim 7/5/2016 added service plan group
  --
  -- call the function to get the metering sources from the customer type
  --CR44107 - use the function transform_device_type as below
  cst := cst.get_meter_sources ( i_device_type        => sa.Transform_device_type(pc.device_type,i_esn),
                                 i_source_system      => CASE
                                                         WHEN l_source_sys_exist = 'Y'
                                                         THEN i_source_system
                                                         ELSE NULL
                                                         END,         -- CR46475
                                 i_brand              => c_bus_org_id         ,
                                 i_parent_name        => c_parent_name        ,
                                 i_service_plan_group => c.service_plan_group );
  --
  DBMS_OUTPUT.PUT_LINE('cst.meter_source_voice: ' || cst.meter_source_voice);
  DBMS_OUTPUT.PUT_LINE('cst.meter_source_sms  : ' || cst.meter_source_sms);
  DBMS_OUTPUT.PUT_LINE('cst.meter_source_data : ' || cst.meter_source_data);
  DBMS_OUTPUT.PUT_LINE('cst.meter_source_ild  : ' || cst.meter_source_ild);
  DBMS_OUTPUT.PUT_LINE('cst.prod_config_objid  : ' || cst.prod_config_objid);
  --
  BEGIN
    SELECT meter_source_type ( a.meter_source_name         ,
                               a.type                      ,
                               a.timeout_minutes_threshold ,
                               a.daily_attempts_threshold  )
    BULK COLLECT
    INTO   ms_tab
    FROM   ( SELECT short_name meter_source_name,
                    timeout_minutes_threshold,
                    daily_attempts_threshold,
                    'VOICE' type
             FROM   x_usage_host
             WHERE  carrier_mtg_id = cst.meter_source_voice
             UNION
             SELECT short_name meter_source_name,
                    timeout_minutes_threshold,
                    daily_attempts_threshold,
                    'SMS' type
             FROM   x_usage_host
             WHERE  carrier_mtg_id = cst.meter_source_sms
             UNION
             SELECT short_name meter_source_name,
                    timeout_minutes_threshold,
                    daily_attempts_threshold,
                    'DATA' type
             FROM   x_usage_host
             WHERE  carrier_mtg_id = cst.meter_source_data
             UNION
             SELECT short_name meter_source_name,
                    timeout_minutes_threshold,
                    daily_attempts_threshold,
                    'ILD' type
             FROM   x_usage_host
             WHERE  carrier_mtg_id = cst.meter_source_ild
           ) a;
   EXCEPTION
     WHEN others THEN
        o_err_code := SQLCODE;
        o_err_msg  := SQLERRM;
       RETURN;
  END;
  --
  -- CR44729 changes starts..
  -- Metering types other than standard ones like VOICE, SMS, DATA are moved to new table x_prod_config_dtl
  --
  IF cst.mtg_source_det.mtg_nameval IS NOT NULL THEN
  IF cst.mtg_source_det.mtg_nameval.COUNT > 0 AND NVL(l_sub_brand,'X') = 'GO_SMART'
  THEN
    FOR each_rec IN cst.mtg_source_det.mtg_nameval.FIRST .. cst.mtg_source_det.mtg_nameval.LAST
    LOOP
      --
      /*DBMS_OUTPUT.PUT_LINE('cst.mtg_source_det.mtg_nameval(each_rec).Key_Type  : ' || cst.mtg_source_det.mtg_nameval(each_rec).Key_Type);
      DBMS_OUTPUT.PUT_LINE('cst.mtg_source_det.mtg_nameval(each_rec).Key_Value : ' || cst.mtg_source_det.mtg_nameval(each_rec).Key_Value);*/
      ms_tab.extend;
      --
      SELECT meter_source_type ( a.meter_source_name         ,
                                 a.type                      ,
                                 a.timeout_minutes_threshold ,
                                 a.daily_attempts_threshold  )
      INTO   ms_tab(ms_tab.COUNT)
      FROM   (SELECT short_name meter_source_name,
                     timeout_minutes_threshold,
                     daily_attempts_threshold,
                     cst.mtg_source_det.mtg_nameval(each_rec).Key_Type type
              FROM   x_usage_host
              WHERE  carrier_mtg_id = cst.mtg_source_det.mtg_nameval(each_rec).Key_Value) a;
      --
    END LOOP;
  END IF;
  END IF;
  -- CR44729 changes ends
  IF ( ms_tab.COUNT = 0 ) THEN
    o_err_code := '0';
    o_err_msg  := 'SUCCESS | NO DATA FOUND';
    o_meter_sources := ms_tab;
    RETURN;
  END IF;

  o_meter_sources := ms_tab;
  o_err_code := '0';
  o_err_msg  := 'SUCCESS';

 EXCEPTION
   WHEN others THEN
     --
     o_err_code := SQLCODE;
     o_err_msg  := 'ERROR GETTING METERING SOURCES : ' || SQLERRM;
     --
END get_meter_sources;
--
-- overloaded method to return the metering sources in a ref cursor
PROCEDURE get_meter_sources ( i_esn               IN  VARCHAR2      ,
                              o_meter_sources_rc  OUT SYS_REFCURSOR ,
                              o_err_code          OUT VARCHAR2      ,
                              o_err_msg           OUT VARCHAR2      ) AS

  ms_tab  meter_source_tab := meter_source_tab();

BEGIN
  --
  get_meter_sources   ( i_esn           => i_esn ,
                        o_meter_sources => ms_tab ,
                        o_err_code      => o_err_code,
                        o_err_msg       => o_err_msg   );

  --
  IF o_err_code = '0' THEN
    IF ms_tab IS NOT NULL THEN
    -- if there are no sources
    IF ( ms_tab.COUNT = 0 ) THEN
      o_err_code := '0';
      o_err_msg  := 'SUCCESS | NO DATA FOUND';
      RETURN;
    END IF;
    END IF;
    -- return the metering sources as a ref cursor
    OPEN   o_meter_sources_rc FOR
    SELECT *
    FROM   TABLE(CAST(ms_tab AS meter_source_tab));
  END IF;

 EXCEPTION
   WHEN others THEN
     --
     o_err_code := SQLCODE;
     o_err_msg  := 'ERROR GETTING METERING SOURCES : ' || SQLERRM;
     --
END get_meter_sources;
--
-- overloaded method to return the metering sources in a ref cursor
-- CR46475 changes starts.
PROCEDURE get_meter_sources ( i_esn               IN  VARCHAR2      ,
                              i_source_system     IN  VARCHAR2      ,
                              o_meter_sources_rc  OUT SYS_REFCURSOR ,
                              o_err_code          OUT VARCHAR2      ,
                              o_err_msg           OUT VARCHAR2      ) AS

  ms_tab  meter_source_tab := meter_source_tab();

BEGIN
  --
  get_meter_sources   ( i_esn           => i_esn ,
                        i_source_system => i_source_system,  -- CR46475
                        o_meter_sources => ms_tab ,
                        o_err_code      => o_err_code,
                        o_err_msg       => o_err_msg   );
  --
  IF o_err_code = '0'
  THEN
    IF ms_tab IS NOT NULL THEN
    -- if there are no sources
    IF ( ms_tab.COUNT = 0 ) THEN
      o_err_code := '0';
      o_err_msg  := 'SUCCESS | NO DATA FOUND';
      RETURN;
       END IF;
    END IF;
    -- return the metering sources as a ref cursor
    OPEN   o_meter_sources_rc FOR
    SELECT *
    FROM   TABLE(CAST(ms_tab AS meter_source_tab));
  END IF;
  --
EXCEPTION
  WHEN others THEN
    --
    o_err_code := SQLCODE;
    o_err_msg  := 'ERROR GETTING METERING SOURCES : ' || SQLERRM;
    --
END get_meter_sources;
-- CR46475 changes ends
--
PROCEDURE sp_get_sl_ppe_sw (
   ip_esn              IN     VARCHAR2,
   ip_brand            IN     VARCHAR2,
   ip_device_group     IN     VARCHAR2 DEFAULT NULL,
   ip_device_tech      IN     VARCHAR2 DEFAULT NULL,
   ip_part_class       IN     VARCHAR2 DEFAULT NULL,
   ip_carrier_id       IN     NUMBER,
   ip_ser_plan_group   IN     VARCHAR2 DEFAULT NULL,
   v_voice_mtg_source     OUT VARCHAR2,
   op_error_code          OUT VARCHAR2,
   op_error_message       OUT VARCHAR2)
AS
   c_device_type          VARCHAR2 (50);
   v_carrier_id           table_x_parent.x_parent_id%TYPE;
   v_carrier_name         table_x_parent.x_parent_name%TYPE;
  -- v_voice_mtg_source     VARCHAR2 (50);
   p_parameter_value      VARCHAR2 (50);
   lv_debug               INTEGER := 0;
   lv_parameter_value     sa.table_x_part_class_values.x_param_value%TYPE;
   lv_error_code          INTEGER;
   lv_error_message       VARCHAR2 (4000);
   v_action               VARCHAR2 (1000) := NULL;
   v_service_plan_group   x_product_config.service_plan_group%TYPE;
   cst                    CUSTOMER_TYPE := Customer_type ();
   c                      CUSTOMER_TYPE := Customer_type ();
   v_cnt                  NUMBER;
BEGIN
   --
   IF ip_device_group IS NULL
   THEN
      sa.SP_GET_ESN_PARAMETER_VALUE (ip_esn,
                                     'DEVICE_TYPE',
                                     lv_debug,
                                     lv_parameter_value,
                                     lv_error_code,
                                     lv_error_message);

      IF lv_parameter_value = 'BYOP'
      THEN
         c_device_type := 'SMARTPHONE';
      ELSIF lv_parameter_value = 'SMARTPHONE'
      THEN
         c_device_type := 'SMARTPHONE';
      ELSIF lv_parameter_value = 'FEATURE_PHONE'
      THEN
         c_device_type := 'FEATURE_PHONE';
      ELSE
         v_action := 'Not supported device group';
      --RAISE user_exception;
      END IF;
   END IF;

   DBMS_OUTPUT.Put_line ('c_device_type ' || c_device_type);

   DBMS_OUTPUT.Put_line ('lv_parameter_value ' || lv_parameter_value);

   DBMS_OUTPUT.Put_line ('lv_error_code ' || lv_error_code);

   DBMS_OUTPUT.Put_line ('lv_error_message ' || lv_error_message);

   --
   BEGIN
      SELECT DISTINCT x_parent_name
        INTO v_carrier_name
        FROM table_x_parent p, table_x_carrier_group cg, table_x_carrier carr
       WHERE     p.objid = cg.x_carrier_group2x_parent
             AND cg.objid = carr.carrier2carrier_group
             AND carr.objid = ip_carrier_id
             AND UPPER (p.x_status) = 'ACTIVE';

      DBMS_OUTPUT.Put_line ('v_carrier_id' || v_carrier_id);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         v_action := 'Not able to find the carrier name for given ESN';

         --OP_SW_METERING   := NULL;
         op_error_code := SQLCODE;

         op_error_message := SUBSTR (SQLERRM, 1, 100);

         DBMS_OUTPUT.Put_line ('v_action' || v_action);

   END;

   v_service_plan_group := ip_ser_plan_group;

   IF c_device_type = 'FEATURE_PHONE' AND ip_ser_plan_group = 'PAY_GO'
   THEN
      BEGIN
         SELECT COUNT (1)
           INTO v_cnt
           FROM sa.table_site_part tsp, sa.x_service_plan_site_part spsp
          WHERE spsp.table_site_part_id = tsp.objid AND x_service_id = ip_esn;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_cnt := 0;
         WHEN OTHERS
         THEN
            v_cnt := 0;
      END;

      IF v_cnt = 0
      THEN
         v_service_plan_group := NULL;
      END IF;
   END IF;

   BEGIN
      SELECT voice_mtg_source
        INTO v_voice_mtg_source
        FROM (  SELECT voice_mtg_source
                  FROM x_product_config
                 WHERE     device_type = c_device_type
                       AND parent_name = v_carrier_name
                       AND brand_name = ip_brand
                       AND NVL (service_plan_group, 'X') =
                              CASE
                                 WHEN service_plan_group IS NOT NULL
                                      AND service_plan_group =
                                             v_service_plan_group
                                 THEN
                                    service_plan_group
                                 ELSE
                                    'X'
                              END
              ORDER BY CASE
                          WHEN service_plan_group = v_service_plan_group
                          THEN
                             1
                          ELSE
                             2
                       END)
       WHERE ROWNUM = 1;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         v_action := 'Not able to find the metering source for given ESN';

         v_voice_mtg_source := NULL;

         op_error_code := 0;

         op_error_message := SUBSTR (SQLERRM, 1, 100);

   END;
END sp_get_sl_ppe_sw;
--
-- CR44729 code changes starts..
-- This procedure stores the metering source , type and details in a dtl table
-- It will accomodate the addition of new metering types without code change
--
PROCEDURE create_bi_trans(
                    ip_esn                         IN   VARCHAR2 ,
                    ip_inquiry_type                IN   VARCHAR2 ,
                    ip_bi_mtg_src_tab              IN   bi_mtg_src_tab,
                    ip_trans_creation_date         IN   DATE ,
                    op_objid                       OUT  NUMBER ,
                    op_err_code                    OUT  VARCHAR2 ,
                    op_err_msg                     OUT  VARCHAR2 )
IS
  v_seq NUMBER:=NULL;
BEGIN
--
  IF (ip_esn IS NOT NULL ) THEN
    v_seq    :=sa.sequ_x_bi_transaction_log.nextval;
    BEGIN
      INSERT
      INTO sa.x_bi_transaction_log
        (
          OBJID,
          ESN,
          inquiry_type,
          trans_creation_date,
          insert_timestamp,
          update_timestamp
        )
        VALUES
        (
          v_seq,
          ip_esn,
          ip_inquiry_type,
          SYSDATE,
          SYSDATE,
          SYSDATE
        );
      IF SQL%ROWCOUNT =1
      THEN
        IF ip_bi_mtg_src_tab.COUNT > 0
        THEN
          FOR each_rec IN ip_bi_mtg_src_tab.FIRST .. ip_bi_mtg_src_tab.LAST
          LOOP
            INSERT
            INTO x_bi_transaction_log_detail
            (
              objid                       ,
              trans2trans_log_dtl         ,
              mtg_type                    ,
              mtg_src                     ,
              trans_id                    ,
              x_timeout_minutes_threshold ,
              x_daily_attempts_threshold
            )
            VALUES
            (
              seq_bi_transaction_log_detail.nextval,
              v_seq,
              ip_bi_mtg_src_tab(each_rec).mtg_type,
              ip_bi_mtg_src_tab(each_rec).mtg_src,
              ip_bi_mtg_src_tab(each_rec).trans_id,
              ip_bi_mtg_src_tab(each_rec).x_timeout_minutes_threshold,
              ip_bi_mtg_src_tab(each_rec).x_daily_attempts_threshold
            );
          END LOOP;
        END IF;
        op_objid    :=  v_seq;
        op_err_code :=  '0';
        op_err_msg  :=  'Success';
      ELSE
        OP_ERR_CODE:='-1';
        op_err_msg :='Failure-record not created';
      END IF;
      --DBMS_OUTPUT.PUT_LINE('SQLRC ;'||SQL%ROWCOUNT);
    EXCEPTION
    WHEN OTHERS THEN
      op_err_code:=SQLCODE;
      op_err_msg :=SQLERRM;
    END;
  ELSE
    op_err_code:='1';
    op_err_msg :='Failure:Not enough values';
  END IF;
--
END create_bi_trans;
--
-- Overloaded procedure to return the BI trans log
--
PROCEDURE search_bi_trans
  (
    ip_esn              IN  VARCHAR2 ,
    op_last_trans_flag  OUT VARCHAR2 ,
    op_bi_count         OUT VARCHAR2 ,
    op_trans_tab        OUT bi_mtg_trans_tab ,
    op_err_code         OUT VARCHAR2 ,
    op_err_msg          OUT VARCHAR2
  )
IS
  trans_tab             bi_mtg_src_tab  :=  bi_mtg_src_tab ();
  l_bi_trans_objid      x_bi_transaction_log.objid%TYPE;
  l_trans_create_date   x_bi_transaction_log.trans_creation_date%TYPE;
  l_inq_type            x_bi_transaction_log.inquiry_type%TYPE;
  c_minutes_interval                VARCHAR2(100);
BEGIN
  --
  op_last_trans_flag  :=  'N';
  op_trans_tab        :=  bi_mtg_trans_tab();
  --
  IF ip_esn IS NOT NULL
  THEN
    BEGIN

      SELECT X_PARAM_VALUE
      INTO   c_minutes_interval
      FROM   TABLE_X_PARAMETERS
      WHERE  X_PARAM_NAME = 'BI_TRANSACTION_MINUTES_INTERVAL'  -- CR49721  WFM Changes
      AND    ROWNUM = 1;
     EXCEPTION
       WHEN others THEN
         c_minutes_interval := '15';
    END;

    BEGIN
      SELECT  DISTINCT 'Y'
      INTO    op_last_trans_flag
      FROM    x_bi_transaction_log
      WHERE   ESN             =   ip_esn
      AND     insert_timestamp >= SYSDATE - c_minutes_interval/(24*60);
    EXCEPTION
    WHEN OTHERS THEN
      op_last_trans_flag:='N';
    END ;
    --
    SELECT  COUNT(objid)
    INTO    op_bi_count
    FROM    x_bi_transaction_log
    WHERE   esn               =   ip_esn
    AND     insert_timestamp  >=  TRUNC(SYSDATE);
    --
    BEGIN
      SELECT  objid , trans_creation_date, inquiry_type
      INTO    l_bi_trans_objid, l_trans_create_date, l_inq_type
      FROM    x_bi_transaction_log
      WHERE   objid =  (SELECT MAX(objid)
                        FROM sa.x_bi_transaction_log
                        WHERE esn             =ip_esn
                        AND insert_timestamp >= SYSDATE - c_minutes_interval/(24*60));
      --
      DBMS_OUTPUT.PUT_LINE('l_bi_trans_objid    :'||l_bi_trans_objid);
      DBMS_OUTPUT.PUT_LINE('l_trans_create_date :'||l_trans_create_date);
      --

    IF CUSTOMER_INFO.get_bus_org_id (IP_ESN) = 'WFM' THEN
      IF (CUSTOMER_INFO.get_last_addon_redemption_date(IP_ESN) >= l_trans_create_date) THEN  -- CR49721  WFM Changes
        OP_LAST_TRANS_FLAG := 'N';
      END IF;
    END IF;

      IF l_bi_trans_objid IS NOT NULL
      THEN
        BEGIN
          SELECT  bi_mtg_src_type (mtg_type,
                                   mtg_src,
                                   trans_id,
                                   x_timeout_minutes_threshold,
                                   x_daily_attempts_threshold)
          BULK COLLECT
          INTO    trans_tab
          FROM    x_bi_transaction_log_detail
          WHERE   trans2trans_log_dtl = l_bi_trans_objid;
        EXCEPTION
          WHEN OTHERS THEN
            op_err_code   :=  '100';
            op_err_msg    :=  'Failed while fetching x_bi_transaction_log_detail ' || SQLERRM;
        END;
      END IF;
      --
      SELECT bi_mtg_trans_type( l_bi_trans_objid    ,
                                ip_esn              ,
                                l_inq_type          ,
                                trans_tab           ,
                                l_trans_create_date )
      BULK COLLECT
      INTO  op_trans_tab
      FROM  DUAL;
      --
      op_err_code       :='0';
      op_err_msg        :='Success';
      --
      IF op_trans_tab.COUNT = 0
      THEN
        op_err_code :=  '0';
        op_err_msg  :=  'Success No data found';
      END IF;
      --
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      op_err_code   :=  '0';
      op_err_msg    :=  'Success';
    WHEN OTHERS THEN
      op_err_code :=  SQLCODE;
      op_err_msg  :=  SQLERRM;
    END;
  ELSE
    op_err_code :=  '1';
    op_err_msg  :=  'Failure :Not enough values';
  END IF;
--
EXCEPTION
WHEN OTHERS THEN
  op_err_code :=  SQLCODE;
  op_err_msg  :=  SQLERRM;
END search_bi_trans;
--
-- Overloaded method
PROCEDURE get_bi_trans(
    ip_objid      IN  NUMBER ,
    op_trans_tab  OUT bi_mtg_trans_tab ,
    op_err_code   OUT VARCHAR2 ,
    op_err_msg    OUT VARCHAR2 )
IS
  trans_tab             bi_mtg_src_tab  :=  bi_mtg_src_tab ();
  l_bi_trans_esn        x_bi_transaction_log.esn%TYPE;
  l_trans_create_date   x_bi_transaction_log.trans_creation_date%TYPE;
  l_inq_type            x_bi_transaction_log.inquiry_type%TYPE;
BEGIN
--
  op_trans_tab        :=  bi_mtg_trans_tab();
  --
  IF ip_objid IS NOT NULL
  THEN
    SELECT  esn,  trans_creation_date, inquiry_type
    INTO    l_bi_trans_esn, l_trans_create_date, l_inq_type
    FROM    x_bi_transaction_log
    WHERE   objid     = ip_objid;
    --
    SELECT  bi_mtg_src_type (mtg_type,
                             mtg_src,
                             trans_id,
                             x_timeout_minutes_threshold,
                             x_daily_attempts_threshold)
    BULK COLLECT
    INTO    trans_tab
    FROM    x_bi_transaction_log_detail
    WHERE   trans2trans_log_dtl = ip_objid;
    --
    SELECT bi_mtg_trans_type( ip_objid,
                              l_bi_trans_esn,
                              l_inq_type,
                              trans_tab,
                              l_trans_create_date )
    BULK COLLECT
    INTO  op_trans_tab
    FROM  DUAL;
    --
    op_err_code       :=  '0';
    op_err_msg        :=  'Success';
    --
    IF (op_trans_tab.COUNT=0)THEN
      op_err_code     :=  '-1';
      op_err_msg      :=  'Balance Transaction ID not found';
    END IF;
  ELSE
    op_err_code :=  '-1';
    op_err_msg  :=  'Failure:objid is null';
  END IF;
  --
EXCEPTION
WHEN NO_DATA_FOUND THEN
  op_err_code :=  '2';
  op_err_msg  :=  'Failure:objid not found ';
WHEN OTHERS THEN
  op_err_code :=  SQLCODE;
  op_err_msg  :=  SQLERRM;
END get_bi_trans;
--
-- Overloaded method, this will return bucket usage along with bucket balance
PROCEDURE sp_get_balance_usage ( ip_trans_id     IN    NUMBER,
                                 out_cur         OUT   bucket_balance_usage_tab,
                                 op_err_code     OUT   VARCHAR2,
                                 op_err_msg      OUT   VARCHAR2 ) AS

  CURSOR c_deenroll_bi IS
  SELECT  ig.esn,
          ig.order_type,
          sp.benefit_type,
          ig.transaction_id,
          tsp.part_status,
          tt.title,
          ct.x_reason,
          spsp.x_service_plan_id,
          (SELECT tp.x_parent_name
           FROM table_x_carrier tc,
                table_x_carrier_group cg,
                table_x_parent tp
          WHERE 1         = 1
          AND tp.objid    = cg.x_carrier_group2x_parent
          AND cg.objid    = tc.carrier2carrier_group
          AND tc.objid    = ct.x_call_trans2carrier
          AND tp.x_status = 'ACTIVE'
          AND ROWNUM      = 1
          ) parent_name
  FROM  ig_transaction ig,
        table_task tt,
        table_x_call_trans ct,
        table_site_part tsp,
        x_service_plan_site_part spsp,
        service_plan_feat_pivot_mv sp
  WHERE ct.objid                = ip_trans_id
  AND   ct.x_sub_sourcesystem   = 'TRACFONE'
  AND   spsp.x_service_plan_id  = 252
  AND   ig.action_item_id       = tt.task_id
  AND   tt.x_task2x_call_trans  = ct.objid
  AND   ig.esn                  = tsp.x_service_id
  AND   tsp.objid               =
                                (SELECT MAX(tsp1.objid)
                                FROM table_site_part tsp1
                                WHERE tsp1.x_service_id = tsp.x_service_id)
  AND   tsp.objid               = spsp.table_site_part_id
  AND   spsp.x_service_plan_id  = sp.service_plan_objid;
  --
  l_skip_bucket_ids      bucket_id_tab :=  bucket_id_tab();
--
BEGIN
--
  out_cur             :=  bucket_balance_usage_tab();
  --  Call the function f_skip_bucket_ids to get Bucket ids which the customer didnt purchase
  -- No Need to show 0 balance bucket if it has not been purchased
  l_skip_bucket_ids    :=  f_skip_bucket_ids  (i_calltrans_id =>  ip_trans_id);

  --
  SELECT bucket_balance_usage_type ( bk.objid,
                                     bk.balance_bucket2x_swb_tx,
                                     bk.x_type,
                                     bk.x_value,
                                     bk.bucket_usage,
                                     bk.recharge_date,
                                     bk.expiration_date,
                                     bk.bucket_desc,
                                     get_bucket_group ( i_bucket_id        => bk.bucket_id ,
                                                        i_call_trans_objid => ip_trans_id  ) -- CR49087 Added by Naresh
                                   )
  BULK COLLECT
  INTO  out_cur
  FROM  x_swb_tx_balance_bucket bk,
        x_switchbased_transaction xsb
  WHERE xsb.x_sb_trans2x_call_trans = ip_trans_id
  AND   bk.balance_bucket2x_swb_tx  = xsb.objid
  AND   bk.bucket_id NOT IN ( SELECT bucket_id          -- skip bucketids that are not purchased
                              FROM TABLE (CAST(l_skip_bucket_ids AS sa.bucket_id_tab)));
  --

  --
  IF (out_cur.COUNT = 0)
  THEN
    FOR rec_c_deenroll_bi IN c_deenroll_bi
    LOOP
      IF rec_c_deenroll_bi.parent_name LIKE '%SAFELINK%'
      THEN
        SELECT bucket_balance_usage_type ( NULL ,
                                           NULL ,
                                           igb.measure_unit,
                                           igtb.bucket_balance,
                                           igtb.bucket_usage,
                                           igtb.recharge_date,
                                           igtb.expiration_date,
                                           igb.bucket_desc,
                                           NULL -- CR49087 Added by Naresh
                                        )
        BULK COLLECT
        INTO   out_cur
        FROM   gw1.ig_buckets igb,
               gw1.ig_transaction_buckets igtb,
               ig_transaction ig
        WHERE  1 = 1
        AND    igb.bucket_id       =   igtb.bucket_id
        AND    igtb.direction      !=  'OUTBOUND'
        AND    igtb.transaction_id =   rec_c_deenroll_bi.transaction_id
        AND    ig.transaction_id   =   igtb.transaction_id
        AND    igb.rate_plan       =   sa.util_pkg.get_esn_rate_plan(rec_c_deenroll_bi.esn);
      END IF;
    END LOOP;
    --
    IF (out_cur.COUNT = 0)
    THEN
      op_err_code := '1';
      op_err_msg  := 'No data found';
      RETURN;
    END IF;
    --
  END IF;

  op_err_code := 0;
  op_err_msg  := 'Success';

 --
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     op_err_code := '1';
     op_err_msg  := 'No data found';
     out_cur     := NULL;
   WHEN OTHERS THEN
     op_err_code := SQLCODE;
     op_err_msg  := sqlerrm;
END sp_get_balance_usage;
--
-- Function will return bucket ids that need not be returned in the Balance Inquiry
FUNCTION f_skip_bucket_ids ( i_calltrans_id IN NUMBER) RETURN  bucket_id_tab DETERMINISTIC IS
--
  l_esn                     table_part_inst.part_serial_no%TYPE;
  cst                       customer_type := customer_type();
  l_ild_bucket_sent_flag    VARCHAR2(1)   :=  'N';
  l_intl_bucket_sent_flag   VARCHAR2(1)   :=  'N';
  l_bucket_id_tab           bucket_id_tab := bucket_id_tab() ;
--
BEGIN
  --CR47564 changes start by Sagar
  -- Get the ESN from call_trans
  BEGIN
    SELECT  x_service_id
    INTO    l_esn
    FROM    table_x_call_trans
    WHERE   objid   = i_calltrans_id;
  EXCEPTION
    WHEN OTHERS THEN
    RETURN NULL;
  END;

  cst.esn := l_esn;
  cst := cst.get_service_plan_attributes;

  SELECT bucket_id_type(bk.bucket_id)
  BULK COLLECT
  INTO   l_bucket_id_tab
  FROM   x_swb_tx_balance_bucket bk,
         x_switchbased_transaction xsb
  WHERE  xsb.x_sb_trans2x_call_trans   = i_calltrans_id
  AND    bk.balance_bucket2x_swb_tx    = xsb.objid
  /* Intergate returns the Wallet bucket balance as 0 in both cases i.e. if the bucket balance is 0 and if the bucket is not purchased.
     Customer should not get balance, if he didn't purchase*/
  AND    bk.bucket_id IN ('WALLETICA','WALLETPB','WALLET')
  AND    bk.x_value = 0
  AND    bk.bucket_id NOT IN (SELECT bucket_list.bucket_id
                               FROM  table_x_call_trans ct,
                                     table_x_call_trans_ext ctext,
                                     TABLE(ctext.bucket_id_list) bucket_list
                               WHERE ct.objid = i_calltrans_id
                               AND   ctext.call_trans_ext2call_trans = ct.objid
                               AND   TRUNC(ct.x_transact_date) >  TRUNC(SYSDATE) - NVL(cst.service_plan_days,0));

  --CR47564 changes end by Sagar
  RETURN  l_bucket_id_tab;
--
EXCEPTION
  WHEN OTHERS THEN
  RETURN  NULL;
END f_skip_bucket_ids;
-- CR44729 code changes ends.

-- CR49087 WFM changes start
FUNCTION get_bucket_group ( i_bucket_id        IN VARCHAR2 ,
                            i_call_trans_objid IN NUMBER   ) RETURN VARCHAR2 DETERMINISTIC IS

  c               sa.call_trans_type;
  c_rate_pan      VARCHAR2(60);
  c_bucket_group  VARCHAR2(50);
BEGIN

  -- call constructor to get call trans attributes
  c := call_trans_type ( i_call_trans_objid => i_call_trans_objid );

  -- only continue for WFM transactions
  -- CR49369 SM Add HotspotTethering Usage and Balance for 611611 allowed
  -- Removed the blocking check to allow all brands to return the bucket group when populated.


  -- get the rate plan from ig
  BEGIN
    SELECT rate_plan
    INTO   c_rate_pan
    FROM   ig_transaction
    WHERE  action_item_id = ( SELECT task_id
                              FROM   table_task
                              WHERE  x_task2x_call_trans = i_call_trans_objid
                            );
   EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
  END;

  -- get the bucket group from ig buckets configuration
  BEGIN
    SELECT bucket_group
    INTO   c_bucket_group
    FROM   ig_buckets
    WHERE  bucket_id = i_bucket_id
    AND    rate_plan = c_rate_pan;
   EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
  END;

  --
  RETURN c_bucket_group;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN NULL;
END get_bucket_group;
-- CR49087 changes end
FUNCTION calculate_usage ( i_call_trans_id  IN NUMBER   ,
                           i_bucket_value   IN VARCHAR2 ,
                           i_bucket_balance IN VARCHAR2 ) RETURN VARCHAR2 DETERMINISTIC IS
  c_usage   NUMBER  := NULL;
  c         customer_type := customer_type();
  cst       customer_type := customer_type();
BEGIN

  -- get the esn of the call trans
  BEGIN
    SELECT x_service_id
    INTO   c.esn
    FROM   table_x_call_trans
    WHERE  objid = i_call_trans_id;
   EXCEPTION
     WHEN others THEN
       NULL;
  END;

  -- instantiate the esn
  cst := customer_type ( i_esn => c.esn );

  -- get the short parent name
  cst.short_parent_name := cst.get_short_parent_name ( i_esn => c.esn );

  -- formula for verizon
  IF cst.short_parent_name = 'VZW' THEN

    -- calculation logic
    BEGIN
      SELECT  threshold - (TO_NUMBER(i_bucket_balance)/1024)
      INTO    c_usage
      FROM    x_policy_mapping_config
      WHERE   parent_name = cst.short_parent_name
      AND     cos = c.get_cos ( i_esn => c.esn ) -- using the cos from the call trans
      AND     usage_tier_id = 2 -- 100% tier
      AND     ROWNUM = 1;
     EXCEPTION
      WHEN others THEN
        c_usage := TO_NUMBER(i_bucket_value) - TO_NUMBER(i_bucket_balance);
    END;
  ELSE
    -- formula for all other carriers
    c_usage := TO_NUMBER(i_bucket_value) - TO_NUMBER(i_bucket_balance);
  END IF;

  -- return the calculated value
  RETURN (TO_CHAR(c_usage));

 EXCEPTION
  WHEN others THEN
    RETURN(i_bucket_value - i_bucket_balance);
END calculate_usage;

-- CR48846 - get the last bi transaction log row for a given esn or min
PROCEDURE get_last_bi_trans ( i_esn               IN  VARCHAR2 ,
                              i_min               IN  VARCHAR2 ,
                              o_bi_transaction_id OUT NUMBER   ,
                              o_response          OUT VARCHAR2 ) IS

  c customer_type := customer_type ( i_esn => i_esn );

BEGIN
  --
  IF c.esn IS NULL THEN
    --
    c.esn := c.get_esn ( i_min => i_min );
  END IF;

  --
  IF c.esn IS NULL THEN
   o_bi_transaction_id := NULL;
    o_response := 'ESN NOT FOUND';
  END IF;

  -- get the last bi transaction log row for a given esn
  BEGIN
    SELECT MAX(objid)
    INTO   o_bi_transaction_id
    FROM   x_bi_transaction_log
    WHERE  esn = c.esn;
   EXCEPTION
    WHEN others THEN
      o_bi_transaction_id := NULL;
  END;

  --
  o_response := 'SUCCESS';

 EXCEPTION
  WHEN OTHERS THEN
    o_response := SQLERRM;
END get_last_bi_trans;
-- Added new procedure as part of CR52654
PROCEDURE UPDATE_CUSTOMER_COMM_STG
  (
    IP_OBJID       IN NUMBER,
    IP_RETRY_COUNT IN NUMBER,
    IP_STATUS      IN VARCHAR2,
	IP_ERROR_MSG   IN VARCHAR2,
    OP_ERR_CODE    OUT NUMBER,
    OP_ERR_MSG     OUT VARCHAR2
  )
AS
BEGIN
  IF (IP_RETRY_COUNT IS NOT NULL AND IP_STATUS IS NULL) THEN
    UPDATE TABLE_CUSTOMER_COMM_STG
       SET retry_count      = IP_RETRY_COUNT,
	       error_message    = IP_ERROR_MSG,
	       update_timestamp = SYSDATE
     WHERE objid            = IP_OBJID;
    IF (SQL%ROWCOUNT =1) THEN
      OP_ERR_CODE   :='0';
      OP_ERR_MSG    :='Success';
    ELSE
      OP_ERR_CODE:='-1';
      OP_ERR_MSG :='Failure-record not updated';
    END IF;
  END IF;
  IF (IP_STATUS IS NOT NULL AND IP_RETRY_COUNT IS NULL )THEN
    UPDATE TABLE_CUSTOMER_COMM_STG
	   SET status           = IP_STATUS,
	       error_message    = IP_ERROR_MSG,
	       update_timestamp = SYSDATE
     WHERE objid            = IP_OBJID;
    IF (SQL%ROWCOUNT =1) THEN
      OP_ERR_CODE   :='0';
      OP_ERR_MSG    :='Success';
    ELSE
      OP_ERR_CODE:='-1';
      OP_ERR_MSG :='Failure-record not updated';
    END IF;
  END IF;
  IF (IP_STATUS IS NOT NULL AND IP_RETRY_COUNT IS NOT NULL )THEN
    UPDATE TABLE_CUSTOMER_COMM_STG
       SET status           = IP_STATUS,
           retry_count      = IP_RETRY_COUNT,
	       error_message    = IP_ERROR_MSG,
	       update_timestamp = SYSDATE
     WHERE objid            =  IP_OBJID;
    IF (SQL%ROWCOUNT =1) THEN
      OP_ERR_CODE   :='0';
      OP_ERR_MSG    :='Success';
    ELSE
      OP_ERR_CODE:='-1';
      OP_ERR_MSG :='Failure-record not updated';
    END IF;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  OP_ERR_CODE:=SQLCODE;
  OP_ERR_MSG :='Error :'||SUBSTR(sqlerrm,1,100);
END UPDATE_CUSTOMER_COMM_STG;

FUNCTION tf_sl_service_end_dt ( i_esn IN VARCHAR2) RETURN DATE
IS
 /*
 |  Tracfone safelink balance enquiry purpose only
 |  Retrun the next delivery date as the service_end_dt
 |  CR55583 -- TF SL WEB Display Next Refill Date for SL customers at Balance Inquiry Page
 */
  --
  c   customer_type := customer_type ( i_esn => i_esn );

BEGIN
  --
  c := c.get_safelink_attributes;
  --
  IF c.pgm_enroll_next_delivery_date IS NULL THEN
     c.expiration_date := c.get_expiration_date (i_esn => c.esn);
  END IF;

  RETURN NVL(c.pgm_enroll_next_delivery_date,c.expiration_date);

EXCEPTION
WHEN OTHERS
THEN
  RETURN NULL;
END tf_sl_service_end_dt;

END carrier_sw_pkg;
/