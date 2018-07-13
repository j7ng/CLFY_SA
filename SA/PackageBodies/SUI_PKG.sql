CREATE OR REPLACE PACKAGE BODY sa.sui_pkg
AS
 FUNCTION get_sui_order_flag( i_parameter_name IN VARCHAR2 ) RETURN VARCHAR2
  IS
  c_sui_order_flag VARCHAR2(1);
  BEGIN

   SELECT x_param_value
   INTO   c_sui_order_flag
   FROM   table_x_parameters
   WHERE  x_param_name = 'CREATE_SUI_ORDER_ALL';

   -- return if all carrier flag is turned OFF
   IF c_sui_order_flag = 'N' THEN
    RETURN 'N';
   END IF;

  -- Otherwise, get the flag for the carrier
   SELECT x_param_value
   INTO   c_sui_order_flag
   FROM   table_x_parameters
   WHERE  x_param_name = 'CREATE_SUI_ORDER_'||i_parameter_name;
   RETURN c_sui_order_flag;

  exception
   WHEN others THEN
    RETURN 'N';
  END;

  PROCEDURE create_sui_order ( i_esn                       IN VARCHAR2,
                               i_min                       IN VARCHAR2,
                               i_case_id                   IN NUMBER,
                               i_order_type                IN VARCHAR2,
                               i_source_system             IN VARCHAR2,
                               o_call_trans_objid          OUT NUMBER,
                               o_task_objid                OUT NUMBER,
                               o_transaction_id            OUT NUMBER,
                               o_errorcode                 OUT NUMBER,
                               o_errormsg                  OUT VARCHAR2,
                               o_transaction_found_flag    OUT VARCHAR2,
                               i_discount_code_list        IN sa.discount_code_tab DEFAULT NULL --for WFM transaction
                             )
  IS
   cust_type                customer_type;
   c_esn                    VARCHAR2(100);
   c_min                    VARCHAR2(100);
   ig_type                  gw1.ig_transaction%rowtype := NULL;
   --c_shrt_parent_name       VARCHAR2(20);
   c_sui_order_flag         VARCHAR2(1);
   ct                       call_trans_type;
   out_ai_status_code       NUMBER;
   out_destination_queue    NUMBER;
   out_ig_tran_status       NUMBER;
   out_action_item_objid    NUMBER;
   out_action_item_id       ig_transaction.action_item_id%TYPE;
   --order_action_type        sui_order_action_type;
   c_ct_action_type         table_x_call_trans.x_action_type%TYPE;
   c_ct_action_reason       table_x_call_trans.x_reason%type;
   c_task_order_type        x_ig_order_type.x_actual_order_type%type;
   pd                       sa.policy_mapping_config_type := policy_mapping_config_type ();
   pcrf                     pcrf_transaction_type;
   p                        pcrf_transaction_type;
   sub                      subscriber_type;
   --c_service_plan_group     VARCHAR2(100);
   c_voice_bucket_balance   VARCHAR2(10);
   c_data_bucket_balance    VARCHAR2(10);
   c_sms_bucket_balance     VARCHAR2(10);
   --SUI ON DEMAND
   --CR47708
   c_pending_ig_timeframe   VARCHAR2(10);
   n_pending_ig_count       NUMBER;
   igb                     ig_transaction_buckets_tab;
   n_upgrade_lookback_days NUMBER;
   n_upgrade_count         NUMBER;
   tt                      sa.task_type := sa.task_type();
   ig                      sa.ig_transaction_type := sa.ig_transaction_type();
   igf                     sa.ig_transaction_features_tab := sa.ig_transaction_features_tab();
   igt                     sa.ig_transaction_features_type := sa.ig_transaction_features_type();
   n_carrier_feat_objid    NUMBER; --CR48373
   n_st_esn_flag           NUMBER := 0 ;
   l_discount_code_list    sa.discount_code_tab := sa.discount_code_tab() ;
  BEGIN
   IF i_esn IS NULL AND i_min IS NULL AND i_case_id IS NULL THEN
     o_errorcode := -1;
     o_errormsg  := 'MISSING ESN/MIN/CASE ID';
     RETURN;
   END IF;

   c_esn := i_esn;

   IF i_esn IS NULL AND i_min IS NOT NULL THEN
     c_esn := util_pkg.get_esn_by_min(i_min => i_min);
     IF c_esn IS NULL THEN
       o_errorcode := -2;
       o_errormsg  := 'INVALID MIN, NO ESN FOUND';
       RETURN;
     END IF;
   END IF;

   IF i_esn IS NULL AND i_min IS NULL AND i_case_id IS NOT NULL THEN
     BEGIN
       SELECT x_esn
       INTO   c_esn
       FROM   table_case
       WHERE  id_number = i_case_id
       AND    x_esn IS NOT NULL;
     EXCEPTION
      WHEN OTHERS THEN
        o_errorcode := -3;
        o_errormsg  := 'INVALID case id, NO ESN FOUND';
        RETURN;
     END;
   END IF;

   --- SUI ON DEMAND
   --- GET THE VALUE OF TIME WHICH IS TO BE LOOKED BACK FOR NOT CREATING SUI ORDER IF THERE ALREADY IS ONE
   --- Juda: there is an existing function that returns the parameter value
   BEGIN
     SELECT x_param_value
     INTO   c_pending_ig_timeframe
     FROM   table_x_parameters
     WHERE  x_param_name = 'SUI_REQUEST_WAIT_TIME';
   EXCEPTION
     WHEN OTHERS THEN
       --DEFAULT TO 1 HOUR
       c_pending_ig_timeframe := '3600';
   END;

   --- CHECKING IF THERE ALREADY IS AN IG PENDING WITHIN LAST X TIMEFRAME
   SELECT /*+ use_invisible_indexes*/COUNT(*)
   INTO   n_pending_ig_count
   FROM   gw1.ig_transaction
   WHERE  esn  = c_esn
   AND    status IN ('L','Q','CP')
   AND    creation_date > sysdate - numtodsinterval(c_pending_ig_timeframe,'SECOND');

   --- IF YES, THEN RETURN ASKING TO COME BACK AFTER SOME TIME
   IF n_pending_ig_count > 0
   THEN
     o_errorcode := -18;
     o_errormsg  := 'A PREVIOUS TRANSACTION IS PENDING. TRY AFTER SOME TIME';
     RETURN;
   END IF;
   --- END SUI ON DEMAND

   cust_type := customer_type(i_esn => c_esn);
   cust_type := cust_type.retrieve;

   IF cust_type.response NOT LIKE '%SUCCESS%' THEN
     o_errorcode := -4;
     o_errormsg  := 'Error instantiating Customer Type '||cust_type.response;
     RETURN;
   END IF;

   IF cust_type.parent_name IS NULL THEN
     o_errorcode := -11;
     o_errormsg  := 'UNABLE TO DERIVE PARENT';
     RETURN;
   END IF;

   IF cust_type.bus_org_id IS NULL THEN
     o_errorcode := -19;
     o_errormsg  := 'UNABLE TO DERIVE BUS_ORG_ID';
     RETURN;
   END IF;

   IF cust_type.contact_objid IS NULL THEN
     o_errorcode := -20;
     o_errormsg  := 'UNABLE TO DERIVE CONTACT_OBJID';
     RETURN;
   END IF;

   --get sui create order flag
   c_sui_order_flag := get_sui_order_flag ( i_parameter_name => cust_type.short_parent_name );
   dbms_output.put_line(cust_type.short_parent_name);

   IF NVL(c_sui_order_flag,'N') = 'N' THEN
    o_errorcode := -5;
    o_errormsg  := 'SUI ORDER FLAG IS OFF, ORDER NOT CREATED';
    RETURN;
   END IF;


   --get MIN for ESN
   IF i_min IS NULL
   THEN
       c_min := cust_type.min;
       IF c_min IS NULL
       THEN
           o_errorcode := -6;
           o_errormsg  := 'MIN NOT FOUND FOR ESN:' ||i_esn;
           RETURN;
       END IF;
   ELSE
       c_min := i_min;
   END IF;

   -- SPECIAL PROCESSING FOR TTON AND TTOFF
   -- FOR TTON AND TTOFF, FIRST DO THROTTLING/UNTHROTTLING AND THEN DO CALL TRANS AS COMPLETED
   IF i_order_type IN ('TTON','TTOFF') THEN
     c_ct_action_reason := i_order_type;

     --GET ACTION TYPE
     BEGIN

       SELECT x_code_number
       INTO   c_ct_action_type
       FROM   table_x_code_table
       WHERE  x_code_name = 'SUI UPDATE'
       AND    x_code_type = 'AT';

     EXCEPTION
       WHEN OTHERS THEN
        o_errorcode := -14;
        o_errormsg  := 'UNABLE TO DERIVE ACTION TYPE';
        RETURN;

     END;

     -- START PROCESSING TTOFF
     IF i_order_type = 'TTOFF' THEN

       w3ci.throttling.sp_expire_cache ( p_min               => c_min,
                                         p_esn               => c_esn,
                                         p_error_code        => o_errorcode,
                                         p_error_message     => o_errormsg,
                                         p_source            => 'SUI_PKG.CREATE_SUI_ORDER');

       IF o_errorcode <> 0 THEN
         RETURN;
       END IF; --o_errorcode <> 0

       -- INSTANTIATE SUBSCRIBER TYPE
       sub  := subscriber_type(i_esn => c_esn);

       IF sub.status NOT LIKE '%SUCCESS%' THEN
         o_errorcode := -15;
         o_errormsg  := 'ERROR INSTANTIATING SUBSCRIBER TYPE: '||sub.status;
         RETURN;
       END IF;

       --INSTANTIATE PCRF TRANSACTION TYPE
       pcrf := pcrf_transaction_type ( i_esn            => c_esn,
                                     i_min              => c_min,
                                     i_order_type       => 'UP',
                                     i_zipcode          => sub.zipcode,
                                     i_sourcesystem     => i_source_system,
                                     i_pcrf_status_code => 'Q');

       -- Call insert pcrf transaction member procedure
       IF p.status NOT LIKE '%SUCCESS%' THEN
         o_errorcode := -16;
         o_errormsg  := 'ERROR INSTANTIATING PCRF TYPE: '||p.status;
         RETURN;
       END IF;

        -- SEND THE PCRF TRANSACTION RECORD
       p := pcrf.ins;
       o_errormsg := p.status;

       IF p.status NOT LIKE '%SUCCESS%' THEN
         o_errorcode := -17;
         o_errormsg  := 'ERROR INSERTING PCRF TRANSACTION: '||p.status;
         RETURN;
       END IF;

     ELSIF i_order_type = 'TTON' THEN
       pd  := sa.policy_mapping_config_type ( i_cos           => cust_type.cos,
                                              i_parent_name   => cust_type.short_parent_name,
                                              i_usage_tier_id => 2,
                                              i_entitlement   => NULL );
       dbms_output.put_line('pd.policy_name :'||pd.policy_name);

       w3ci.throttling.sp_throttling_valve ( p_min                  => c_min ,
                                             p_esn                  => c_esn,
                                             p_policy_name          => pd.policy_name,
                                             p_creation_date        => NULL ,
                                             p_transaction_num      => NULL,
                                             p_error_code           => o_errorcode,
                                             p_error_message        => o_errormsg,
                                             p_usage                => NULL,
                                             p_bypass_off           => 'YES',
                                             p_propagate_flag_value => NULL,
                                             p_parent_name          => NULL,
                                             p_usage_tier_id        => NULL,
                                             p_cos                  => cust_type.cos );

     END IF; --i_order_type = 'TTOFF'

     --CREATE CALL TRANS RECORD
     ct := call_trans_type ( i_esn              => c_esn               ,
                             i_action_type      => c_ct_action_type    ,
                             i_sourcesystem     => i_source_system     ,
                             i_sub_sourcesystem => cust_type.bus_org_id,
                             i_reason           => c_ct_action_reason  ,
                             i_result           => 'Completed'         ,
                             i_ota_req_type     => NULL                ,
                             i_ota_type         => NULL                ,
                             i_total_units      => NULL                ,
                             i_total_days       => NULL                ,
                             i_total_sms_units  => NULL                ,
                             i_total_data_units => NULL                  );

     -- call the insert method
     ct := ct.ins;
     o_call_trans_objid := ct.call_trans_objid;

     -- if call_trans was not created successfully
     IF ct.response <> 'SUCCESS' THEN
       dbms_output.put_line('CALL TRAN OBJID');
       o_errorcode := -7;
       o_errormsg  := 'CALL TRANS'|| ct.response;
       DBMS_OUTPUT.PUT_LINE('c_ct_action_type:'||c_ct_action_type);
       -- exit the program and transfer control to the calling process
       RETURN;
     END IF; -- ct.response <> 'SUCCESS'

   END IF; --i_order_type IN ('TTON','TTOFF')
   -- END SPECIAL PROCESSING FOR TTON AND TTOFF

   -- START CREATE CALL TRANS FOR OTHER ORDER TYPES
   -- GET THE ACTION_TYPE AND X_REASON FROM X_IG_ORDER_TYPE
   BEGIN
    SELECT x_actual_order_type,
           sui_action_type
      INTO c_ct_action_reason,
           c_ct_action_type
      FROM x_ig_order_type
     WHERE x_ig_order_type  = i_order_type
       AND x_programme_name = 'SP_INSERT_IG_TRANSACTION'
       AND ROWNUM           = 1 ;
   EXCEPTION
     WHEN OTHERS THEN
      o_errorcode := -13;
      o_errormsg  := 'ERROR GETTING ACTION_TYPE AND REASON :' ||SQLERRM;
      RETURN;
   END;

   -- instantiate call trans values
   ct := call_trans_type ( i_esn              => c_esn          ,
                           i_action_type      => c_ct_action_type,
                           i_sourcesystem     => i_source_system,
                           i_sub_sourcesystem => cust_type.bus_org_id,
                           i_reason           => c_ct_action_reason ,
                           i_result           => 'Pending'     ,
                           i_ota_req_type     => NULL          ,
                           i_ota_type         => NULL          ,
                           i_total_units      => NULL          ,
                           i_total_days       => NULL          ,
                           i_total_sms_units  => NULL          ,
                           i_total_data_units => NULL          );

   -- call the insert method
   ct := ct.ins;
   o_call_trans_objid := ct.call_trans_objid;

   -- if call_trans was not created successfully
   IF ct.response <> 'SUCCESS' THEN

    dbms_output.put_line('CALL TRAN OBJID');
    o_errorcode := -7;
    o_errormsg  := 'CALL TRANS'|| ct.response;
    DBMS_OUTPUT.PUT_LINE('c_ct_action_type:'||c_ct_action_type);
     -- exit the program and transfer control to the calling process
     RETURN;
   END IF;

   -- if call_trans was not created successfully
   IF ct.call_trans_objid IS NULL THEN
     o_errorcode := -8;
     o_errormsg  := 'CALL TRANS NOT CREATED';
      -- exit the program and transfer control to the calling process
     RETURN;
   END IF;
   dbms_output.put_line('CALL TRAN OBJID :'||CT.call_trans_objid);
   --
   -- END CREATE CALL TRANS

   -- CHECK IF IT IS TRACFONE PAY GO PLAN, IF SO PASS BUCKET VALUES AS 0 AND BENEFIT TYPE AS TRANSFER
   --c_service_plan_group := sa.util_pkg.get_sp_feature_value(i_esn => c_esn, i_value_name => 'SERVICE_PLAN_GROUP');

   -- COMMENTING OUT CAUSE AS PART OF PHASE 2
   /*IF  c_service_plan_group = 'PAY_GO'
   THEN
     c_voice_bucket_balance := '0';
     c_data_bucket_balance  := '0';
     c_sms_bucket_balance   := '0';
   ELSE
     c_voice_bucket_balance := NULL;
     c_data_bucket_balance  := NULL;
     c_sms_bucket_balance   := NULL;
   END IF;*/
    -- CR48480 Changes starts..
    IF i_discount_code_list IS NULL
    THEN
      BEGIN
        SELECT  discount_code_type(dl.discount_code)
        BULK COLLECT
        INTO    l_discount_code_list
        FROM    x_esn_promo_hist ph,
                TABLE(ph.discount_code_list) dl
        WHERE   ph.esn    = c_esn
        AND     TRUNC(ph.EXPIRATION_DATE) > TRUNC (SYSDATE)
        AND     ph.objid     = (SELECT MAX (ph1.objid)
                                FROM   x_esn_promo_hist ph1
                                WHERE  ph1.esn                = ph.esn
                                AND    ph1.discount_code_list IS NOT NULL
                               );
      EXCEPTION
        WHEN OTHERS THEN
          l_discount_code_list  :=  NULL;
      END;
    END IF;
    -- CR48480 changes ends.
   -- CR47708
   -- IF THE ORDER TYPE IS PFR AND
   -- THERE WAS AN UPGRADE I N LAST "X" DAYS (THERE SHOULD BE A TASK FOR THAT)
   -- THEN LOOK FOR A RECENT BI IN IG_TRANSACTION AND SEND BUCKET BALANCE ACCORDING TO THAT BI
   -- TO DO SO, WE'LL HAVE TO SKIP CREATING BUCKETS ACCORDING TO IGATE LOGIC AND CREATE IG/TASK AND BUCKETS ON OUR OWN

       igate.sp_set_action_item_ig_trans (  in_contact_objid      => cust_type.contact_objid,
                                            in_call_trans_objid   => ct.call_trans_objid,
                                            in_order_type         => c_ct_action_reason,
                                            in_bypass_order_type  => 0,
                                            in_case_code          => 0,
                                            in_trans_method       => NULL,
                                            in_application_system => 'SUI',
                                            in_service_days       => NULL,
                                            in_voice_units        => NULL, --c_voice_bucket_balance,-- LET IGATE DECIDE WHAT TO DO HERE
                                            in_text_units         => NULL, --c_sms_bucket_balance,  -- LET IGATE DECIDE WHAT TO DO HERE
                                            in_data_units         => NULL, --c_data_bucket_balance, -- LET IGATE DECIDE WHAT TO DO HERE
                                            in_discount_code_list => NVL(i_discount_code_list, l_discount_code_list),
                                            out_ai_status_code    => out_ai_status_code,
                                            out_destination_queue => out_destination_queue,
                                            out_ig_tran_status    => out_ig_tran_status,
                                            out_action_item_objid => o_task_objid,
                                            out_action_item_id    => out_action_item_id,
                                            out_errorcode         => o_errorcode,
                                            out_errormsg          => o_errormsg  );

       IF (o_errormsg IS NOT NULL AND UPPER(o_errormsg) NOT LIKE '%SUCCESS%') THEN
        RETURN;
       END IF;

       IF out_action_item_id IS NULL THEN
         o_errorcode := -10;
         o_errormsg  := 'TASK NOT CREATED : '||o_errormsg;
         RETURN;
       END IF;

       BEGIN
         SELECT transaction_id
         INTO   o_transaction_id
         FROM   gw1.ig_transaction
         WHERE  action_item_id = out_action_item_id;
       EXCEPTION
        WHEN OTHERS THEN
         o_errorcode := -9;
         o_errormsg  := 'ERROR OBTAINING IG TRANSACTION_ID: ' || SQLERRM;
         RETURN;
       END;

       -- Retrieve flag from GTT to determine if buckets were found in previous BI -- CR48373
       BEGIN
            SELECT NVL(transaction_found_flag,'N')
            INTO   o_transaction_found_flag
            FROM   gtt_sui_bi_buckets_check
            WHERE  transaction_id = o_transaction_id;
        EXCEPTION
         WHEN others THEN
           o_transaction_found_flag := 'N';
       END;

       DELETE
       FROM   gtt_sui_bi_buckets_check
       WHERE  transaction_id  = o_transaction_id;

   -- instantiate values to mark call trans as completed
    ct := call_trans_type ( i_esn              => NULL,
                            i_result           => 'Completed' ,
                            i_call_trans_objid => ct.call_trans_objid );

    -- mark call trans as completed
    ct := ct.upd;

    o_errorcode := 0;
    o_errormsg  := 'SUCCESS';

  EXCEPTION
    WHEN OTHERS THEN
      o_errorcode := -12;
      o_errormsg  := dbms_utility.format_error_backtrace()|| sqlerrm ;
  END create_sui_order;

 FUNCTION fetch_sui_order ( i_transaction_id  IN NUMBER )
  RETURN sui_result_rec_tab
  IS
   sui_rslt_ig          sui_result_rec_tab;
   sui_rslt_bucket      sui_result_rec_tab;
   fetch_rslt           sui_result_rec_tab;
   htln_rslt            sui_result_rec_tab; --CR51375 Added to fetch hotline status
   c_esn                VARCHAR2(100);
   c_shrt_parent_name   VARCHAR2(100);
   c_profile_id         NUMBER; --CR51375

 BEGIN

   sui_rslt_ig        :=   sui_result_rec_tab();
   sui_rslt_bucket    :=   sui_result_rec_tab();
   fetch_rslt         :=   sui_result_rec_tab();
   htln_rslt          :=   sui_result_rec_tab(); --CR51375

   BEGIN
      SELECT esn, cf_profile_id --CR51375 Added profile id
      INTO   c_esn, c_profile_id
      FROM   ig_transaction
      WHERE  transaction_id = i_transaction_id;
   EXCEPTION
      WHEN OTHERS THEN
        RETURN fetch_rslt;
   END;

   c_shrt_parent_name := sa.util_pkg.get_short_parent_name(sa.util_pkg.get_parent_name(i_esn => c_esn));

   SELECT result_rec BULK COLLECT INTO sui_rslt_ig FROM
   (
     -- FETCH RESULT FROM IG
     SELECT  sa.sui_result_rec_type(fea,fea_value) result_rec
     FROM    gw1.ig_transaction ig
     unpivot include NULLS ( fea_value FOR fea IN ("MIN",esn,esn_hex,iccid,rate_plan,status))
     WHERE   transaction_id = i_transaction_id
     UNION ALL
     SELECT  sa.sui_result_rec_type('MSID',decode(c_shrt_parent_name,'VZW',msid,"MIN"))
     FROM    gw1.ig_transaction ig
     WHERE   transaction_id = i_transaction_id

     --FETCH RESULTS FROM XMLTYPE
     UNION ALL
     SELECT sa.sui_result_rec_type
               (pm.x_param_value,
                CASE
                   WHEN pm.x_param_value = 'POST_TO_PRE'
                      THEN EXTRACTVALUE (xml_response, '/TRANSACTION/POST_TO_PRE')
                   WHEN pm.x_param_value = 'FEATURE_LIST'
                      THEN COALESCE
                                (EXTRACTVALUE (xml_response,
                                               '/TRANSACTION/CARRIER_FEATURES'
                                              ),
                                 EXTRACTVALUE (xml_response,
                                               '/TRANSACTION/ATT_FEATURES'
                                              ),
                                 EXTRACTVALUE (xml_response,
                                               '/TRANSACTION/ATT_BUNFEATURES'
                                              ),
                                 EXTRACTVALUE (xml_response,
                                               '/TRANSACTION/SOCS_LIST'
                                              ),
                                 EXTRACTVALUE (xml_response,
                                               '/TRANSACTION/RSS_FEATURES'
                                              ),
                                 EXTRACTVALUE (xml_response,
                                               '/TRANSACTION/MIN_INQ_LINE_FEATURES'
                                              )
                                )
                   WHEN pm.x_param_value = 'LINE_THROTTLED'
                      THEN DECODE (EXTRACTVALUE (xml_response,
                                                 '/TRANSACTION/LINE_THROTTLED'
                                                ),
                                   'Y', 'THROTTLED',
                                   'NOT THROTTLED'
                                  )
                   WHEN pm.x_param_value = 'LINE_STATUS'
                      THEN CASE
                             WHEN EXTRACTVALUE (xml_response,
                                                '/TRANSACTION/LINE_STATUS'
                                               ) LIKE '%INACTIVE%'
                                THEN 'INACTIVE'
                             WHEN EXTRACTVALUE (xml_response,
                                                '/TRANSACTION/LINE_STATUS'
                                               ) LIKE '%CANCEL%'
                                THEN 'INACTIVE'
                             WHEN EXTRACTVALUE (xml_response,
                                                '/TRANSACTION/LINE_STATUS'
                                               ) LIKE '%SUSPEND%'
                                THEN 'INACTIVE'
                             WHEN EXTRACTVALUE (xml_response,
                                                '/TRANSACTION/LINE_STATUS'
                                               ) LIKE '%DEACTIV%'
                                THEN 'INACTIVE'
                             WHEN EXTRACTVALUE (xml_response,
                                                '/TRANSACTION/LINE_STATUS'
                                               ) LIKE '%HOTLINE%'
                                THEN 'INACTIVE'
                             WHEN EXTRACTVALUE (xml_response,
                                                '/TRANSACTION/LINE_STATUS'
                                               ) LIKE '%EXPIRE%'
                                THEN 'INACTIVE'
                             WHEN EXTRACTVALUE (xml_response,
                                                '/TRANSACTION/LINE_STATUS'
                                               ) LIKE '%ACTIVE%'
                                THEN 'ACTIVE'
                             ELSE NULL
                          END
                   WHEN pm.x_param_value = 'SIM_STATUS_4G'
                      THEN EXTRACTVALUE (xml_response, '/TRANSACTION/SIM_STATUS_4G') --CR49737
                   WHEN pm.x_param_value = 'ILD_STATUS'
                      THEN EXTRACTVALUE (xml_response, '/TRANSACTION/ILD_STATUS') --CR51375
                   ELSE NULL
                END
               ) t
      FROM gw1.ig_trans_carrier_response cr, table_x_parameters pm
      WHERE pm.x_param_name = 'SUI_FETCH_XML_FIELDS'
      AND cr.transaction_id = i_transaction_id
    );

    --CR51375 Fetch Safelink Hotline status if it is present in the feature list from ig_trans_carrier_response
    --CR52120 Table x_cf_extension_config replaced with function
    SELECT sa.sui_result_rec_type('HOTLINE_STATUS', cfc.feature_name)
    BULK COLLECT INTO htln_rslt
    FROM  TABLE(igate.get_ig_features(c_profile_id)) cfc,
          table_x_parameters pm
    WHERE cfc.feature_value IN (SELECT regexp_substr(fea.str, '[^,]+', 1, rownum)
                                FROM   ( SELECT feature_value str
                                         FROM table(sui_rslt_ig)
                                         WHERE feature_name = 'FEATURE_LIST') fea
                                CONNECT BY LEVEL <= regexp_count(fea.str, ',') + 1)
    AND cfc.feature_name = pm.x_param_value
    AND pm.x_param_name = 'SUI_FETCH_HOTLINE_STATUS';

    IF htln_rslt.COUNT = 0 THEN
        SELECT sa.sui_result_rec_type('HOTLINE_STATUS', NULL)
        BULK COLLECT
        INTO  htln_rslt
        FROM  DUAL;
    END IF;

    sui_rslt_bucket := fetch_sui_buckets( i_transaction_id => i_transaction_id,
                                          i_direction      => 'INBOUND') ;

    --Merge the three results

    SELECT sui_rslt_ig MULTISET UNION ALL sui_rslt_bucket MULTISET UNION ALL htln_rslt
    INTO   fetch_rslt
    FROM dual;

   RETURN fetch_rslt;

 EXCEPTION
   WHEN OTHERS THEN
    RETURN fetch_rslt;
 END fetch_sui_order;

PROCEDURE update_sui ( i_esn          IN  VARCHAR2 ,
                       i_min          IN  VARCHAR2 ,
                       i_msid         IN  VARCHAR2 ,
                       i_sourcesystem IN  VARCHAR2 ,
                       o_response     OUT VARCHAR2 ) IS

  c     customer_type := customer_type();
  cm    customer_type := customer_type();
  s     subscriber_type := subscriber_type();
  pcrf  pcrf_transaction_type := pcrf_transaction_type();
  p     pcrf_transaction_type;
  --
  n_exists          NUMBER;
  n_ild_objid       sa.table_x_ild_transaction.objid%TYPE;
  c_ild_product_id  VARCHAR2(30) := NULL;
  c_ild_ig_account  VARCHAR2(30) := NULL;
  n_error_num       NUMBER;
  c_error_string    VARCHAR2(1000);

BEGIN
  --
  IF i_esn IS NULL THEN
    o_response := 'ESN NOT PASSED';
    RETURN;
  END IF;

  -- either min or msid is required
  IF i_min IS NULL AND i_msid IS NULL THEN
    o_response := 'MIN OR MSID IS REQUIRED';
    RETURN;
  END IF;

  -- either min or msid is required
  IF i_min IS NOT NULL AND
     LENGTH(i_min) <> 10
  THEN
    o_response := 'INVALID MIN LENGTH (' || LENGTH(i_min)||')';
    RETURN;
  END IF;

  DBMS_OUTPUT.PUT_LINE('RETRIEVING ALL THE ATTRIBUTES FOR THE ESN');

  -- retrieve all the attributes for the esn
  c := c.retrieve ( i_esn => i_esn );

  --If ESN MIN and MSID are unchanged then return
  IF c.esn = i_esn AND c.min = nvl(i_min,c.min) AND c.msid = nvl(i_msid,c.msid) THEN
    o_response := 'SUCCESS';
    RETURN;
  END IF;
  --
  IF c.esn_part_inst_objid IS NULL THEN
    o_response := 'ESN NOT FOUND';
    RETURN;
  END IF;

  IF c.min_part_inst_objid IS NULL THEN
    o_response := 'MIN NOT FOUND';
    RETURN;
  END IF;

  IF i_min = c.min AND i_msid <> c.msid then
    BEGIN
     UPDATE table_part_inst
     SET    part_serial_no = NVL(i_min, part_serial_no),
            x_msid = NVL(i_msid, x_msid)
     WHERE  objid = c.min_part_inst_objid
     AND    x_domain = 'LINES';

    EXCEPTION
      WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('FAILED UPDATING MIN IN PART INST: ' || SQLERRM);
        o_response := 'FAILED UPDATING MIN IN PART INST: ' || SQLERRM;
        RETURN;
    END;

    BEGIN
      UPDATE table_site_part
      SET    x_msid = NVL(i_msid, x_msid)
      WHERE  objid = c.site_part_objid
      AND    part_status = 'Active';
     EXCEPTION
       WHEN others THEN
         DBMS_OUTPUT.PUT_LINE('FAILED UPDATING MIN IN SITE PART: ' || SQLERRM);
         o_response := 'FAILED UPDATING MIN IN SITE PART: ' || SQLERRM;
         RETURN;
    END;

    o_response := 'SUCCESS';
    RETURN;
  END IF;

  --IF c.min = i_min THEN
  --  o_response := 'NOTHING TO UPDATE';
  --  RETURN;
  --END IF;

  DBMS_OUTPUT.PUT_LINE('RETRIEVING ALL THE ATTRIBUTES FOR THE NEW MIN');

  -- retrieve all the attributes for the new min
  cm.esn := cm.get_esn ( i_min => i_min );

  -- new min is already married to esn
  IF cm.esn IS NOT NULL THEN

    DBMS_OUTPUT.PUT_LINE('REMOVING THE RELATIONSHIP OF ESN AND MIN');

    -- remove the relationship of esn and min
    UPDATE table_part_inst
    SET    part_to_esn2part_inst = NULL
    WHERE  part_serial_no = i_min
    AND    x_domain = 'LINES';
  END IF;

  IF i_min IS NOT NULL OR i_msid IS NOT NULL THEN
    BEGIN
      SELECT COUNT(1)
      INTO   n_exists
      FROM   table_part_inst
      WHERE  part_serial_no = i_min
      AND    x_domain = 'LINES';
     EXCEPTION
       WHEN others THEN
         n_exists := 0;
    END;

    --
     IF n_exists > 0 THEN
       DBMS_OUTPUT.PUT_LINE('DELETING EXISTING MIN FROM PART INST');
       DELETE table_part_inst
       WHERE  part_serial_no = i_min
       AND    x_domain = 'LINES';
     END IF;

     DBMS_OUTPUT.PUT_LINE('UPDATING MIN IN PART INST');

    --
    BEGIN
      UPDATE table_part_inst
      SET    part_serial_no = NVL(i_min, part_serial_no),
             x_msid = NVL(i_msid, x_msid)
      WHERE  objid = c.min_part_inst_objid
      AND    x_domain = 'LINES';
     EXCEPTION
       WHEN others THEN
         DBMS_OUTPUT.PUT_LINE('FAILED UPDATING MIN IN PART INST: ' || SQLERRM);
         o_response := 'FAILED UPDATING MIN IN PART INST: ' || SQLERRM;
         RETURN;
    END;

    DBMS_OUTPUT.PUT_LINE('UPDATING MIN IN SITE PART');
    --
    BEGIN
      UPDATE table_site_part
      SET    x_min = NVL(i_min, x_min),
             x_msid = NVL(i_msid, x_msid)
      WHERE  objid = c.site_part_objid
      AND    part_status = 'Active';
     EXCEPTION
       WHEN others THEN
         DBMS_OUTPUT.PUT_LINE('FAILED UPDATING MIN IN SITE PART: ' || SQLERRM);
         o_response := 'FAILED UPDATING MIN IN SITE PART: ' || SQLERRM;
         RETURN;
    END;
    --
    DBMS_OUTPUT.PUT_LINE('UPDATING MIN IN SUBSCRIBER SPR');

    -- get the subscriber row
    s  := subscriber_type ( i_esn => i_esn );

    --
    IF s.status = 'SUCCESS' THEN
      --
      BEGIN
        -- update subscriber spr with new min
        UPDATE x_subscriber_spr
        SET    pcrf_min = NVL(i_min, pcrf_min),
               pcrf_mdn = NVL(i_min, pcrf_mdn)
        WHERE  pcrf_esn = s.pcrf_esn;
        --
        DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' ROWS UPDATED MIN IN SUBSCRIBER SPR');
        --
       EXCEPTION
         WHEN dup_val_on_index THEN
           DBMS_OUTPUT.PUT_LINE('DUPLICATE VALUE ON SUBSCRIBER SPR FOR THE NEW MIN');
           -- delete subscriber spr detail
           DELETE x_subscriber_spr_detail
           WHERE  subscriber_spr_objid IN ( SELECT objid
                                            FROM   x_subscriber_spr
                                            WHERE  pcrf_min = i_min
                                          );
           DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' ROW(S) DELETED FROM SUBSCRIBER SPR DETAIL');
           -- delete subscriber spr
           DELETE x_subscriber_spr
           WHERE  pcrf_min = i_min;
           DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' ROW DELETED FROM SUBSCRIBER SPR');
           -- update subscriber spr with new min
           UPDATE x_subscriber_spr
           SET    pcrf_min = NVL(i_min, pcrf_min),
                  pcrf_mdn = NVL(i_min, pcrf_mdn)
           WHERE  pcrf_esn = s.pcrf_esn;
           DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' ROW UPDATED FROM SUBSCRIBER SPR AFTER DELETES');
         WHEN others THEN
           DBMS_OUTPUT.PUT_LINE('FAILED UPDATING MIN IN SUBSCRIBER SPR: ' || SQLERRM);
           o_response := 'FAILED UPDATING MIN IN SUBSCRIBER SPR: ' || SQLERRM;
           RETURN;
      END;

      -- get the subscriber row after the update
      s  := subscriber_type ( i_esn => i_esn );

      -- send new pcrf transaction with new min
      pcrf := pcrf_transaction_type ( i_esn              => s.pcrf_esn     ,
                                      i_min              => s.pcrf_min     ,
                                      i_order_type       => 'UP'           ,
                                      i_zipcode          => s.zipcode      ,
                                      i_sourcesystem     => i_sourcesystem ,
                                      i_pcrf_status_code => 'Q'            );

      -- Call insert pcrf transaction member procedure
      p := pcrf.ins;

      DBMS_OUTPUT.PUT_LINE('creating pcrf transaction: p.status => ' || p.status);

    END IF; -- IF s.status = 'SUCCESS' THEN

  END IF; -- IF i_min IS NOT NULL OR i_msid IS NOT NULL THEN

  -- updating throttling cache with new min
  UPDATE w3ci.table_x_throttling_cache
  SET    x_min = i_min -- new min
  WHERE  x_esn = c.esn
  AND    x_min = c.min -- old min
  AND    x_status IN ('P','A');

  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' ROW(S) UPDATED IN W3CI.TABLE_X_THROTTLING_CACHE');

  -- updating throttling cache with new min
  UPDATE x_sl_currentvals
  SET    x_current_min = i_min -- new min
  WHERE  x_current_esn = c.esn
  AND    objid = ( SELECT MAX(objid)
                   FROM   x_sl_currentvals
                   WHERE  x_current_esn = c.esn );

  DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' ROW(S) UPDATED IN X_SL_CURRENTVALS');

  IF c.site_part_objid IS NOT NULL THEN

    --
    c_ild_product_id := NULL;
    c_ild_ig_account := NULL;

    -- procedure to provide the ILD product id based on site part objid
    sa.ild_transaction_pkg.get_ild_params_by_sitepart (	ip_site_part_objid => c.site_part_objid ,
                                                        ip_esn             => c.esn             ,
                                                        ip_bus_org         => c.bus_org_id      ,
                                                        op_ild_product_id  => c_ild_product_id  ,
                                                        op_ild_ig_account  => c_ild_ig_account  ,
                                                        op_err_num         => n_error_num       ,
                                                        op_err_string      => c_error_string    );

    --
    IF c_ild_product_id IS NOT NULL AND
       c_ild_product_id != 'ERR_BRAND'
    THEN
      -- Procedure to insert record into table_x_ild_transaction
      sa.ild_transaction_pkg.insert_table_x_ild_trans ( ip_dev                     => NULL                             ,
                                                        ip_x_min                   => NVL(i_msid,c.msid)               ,
                                                        ip_x_esn                   => c.esn                            ,
                                                        ip_x_transact_date         => SYSDATE                          ,
                                                        ip_x_ild_trans_type        => 'A'                              , -- Activation
                                                        ip_x_ild_status            => 'PENDING'                        ,
                                                        ip_x_last_update           => SYSDATE                          ,
                                                        ip_x_ild_account           => c_ild_ig_account                 ,
                                                        ip_ild_trans2site_part     => NULL                             ,
                                                        ip_ild_trans2user          => NULL                             ,
                                                        ip_x_conv_rate             => 1                                ,
                                                        ip_x_target_system         => NULL                             ,
                                                        ip_x_product_id            => c_ild_product_id                 ,
                                                        ip_x_api_status            => NULL                             ,
                                                        ip_x_api_message           => NULL                             ,
                                                        ip_x_ild_trans2ig_trans_id => NULL                             , -- ask teebu (pending)
                                                        ip_x_ild_trans2call_trans  => NULL                             , -- ask teebu (pending)
                                                        op_objid                   => n_ild_objid                      ,
                                                        op_err_num                 => n_error_num                      ,
                                                        op_err_string              => c_error_string                   );

      DBMS_OUTPUT.PUT_LINE('n_ild_objid: ' || n_ild_objid);

    END IF; -- IF c_ild_product_id IS NOT NULL AND ...

  END IF; -- IF c.site_part_objid IS NOT NULL THEN

  IF i_min IS NOT NULL THEN
    -- refresh VAS
    sa.vas_management_pkg.updatesubscriptionforminc ( ip_oldmin => c.min            ,
                                                      ip_newmin => NVL(i_min,c.min) ,
                                                      op_result => n_error_num      ,
                                                      op_msg    => c_error_string   );
  END IF;

  o_response := 'SUCCESS';

 EXCEPTION
   WHEN others THEN
     o_response := 'ERROR UPDATING MIN/MDN: ' || SQLERRM;
     DBMS_OUTPUT.PUT_LINE ( 'o_response : ' || o_response );
END update_sui;

--CR48570 - Verizon MIN Mismatch on SUI transactions
PROCEDURE update_sui_transaction ( i_transaction_id   IN  NUMBER ,
                                   i_sourcesystem     IN  VARCHAR2 ,
                                   o_response         OUT VARCHAR2 ) IS

  c_min       VARCHAR2(30) := NULL;
  c_msid      VARCHAR2(30) := NULL;
  c_esn       VARCHAR2(30) := NULL;
BEGIN

  BEGIN

    -- Transaction Id is required
    IF i_transaction_id IS NULL THEN
       DBMS_OUTPUT.PUT_LINE('IG TRANSACTION NOT PASSED: ' || SQLERRM);
       o_response := 'IG TRANSACTION NOT PASSED: ' || SQLERRM;
       RETURN;
    END IF;

    --ONLY FOR GSM - Assign MSID value to MIN, when there is a MIN change
    SELECT  esn,
            CASE  WHEN (NVL(new_msid_flag, 'N') = 'Y' AND technology_flag = 'G')
                    THEN msid
                  ELSE min
            END min,
            msid
    INTO
            c_esn,
            c_min,
            c_msid
    FROM    ig_transaction
    WHERE   transaction_id = i_transaction_id;

  EXCEPTION
      WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('IG TRANSACTION NOT FOUND: ' || SQLERRM);
        o_response := 'IG TRANSACTION NOT FOUND: ' || SQLERRM;
        RETURN;
  END;

  -- Call update_sui to update the correct MIN/MSID
  update_sui ( i_esn          => c_esn,
               i_min          => c_min,
               i_msid         => c_msid,
               i_sourcesystem => i_sourcesystem,
               o_response     => o_response );

  --response will be passed directly from the update_sui

 EXCEPTION
   WHEN others THEN
     o_response := 'ERROR UPDATING MIN/MDN: ' || SQLERRM;
     DBMS_OUTPUT.PUT_LINE ( 'o_response : ' || o_response );
END update_sui_transaction;

FUNCTION fetch_sui_buckets (
   i_transaction_id   IN   NUMBER,
   i_direction        IN   VARCHAR2 DEFAULT 'OUTBOUND'
)
   RETURN sui_result_rec_tab

IS
   sui_rslt                sui_result_rec_tab;
   c_bucket_flag           x_ig_order_type.create_buckets_flag%TYPE; --CR52905
BEGIN
   sui_rslt := sui_result_rec_tab ();

   IF i_transaction_id IS NULL OR i_direction IS NULL
   THEN
      RETURN sui_rslt;
   END IF;

   --CR52905 - Get the buckets creation flag for current order type
   --This hit on ig_transaction can be avoided by adding order type as input param to this procedure.
   BEGIN
    SELECT nvl(iot.create_buckets_flag, 'YES')
      INTO c_bucket_flag
      FROM x_ig_order_type iot, ig_transaction ig
     WHERE ig.order_type = iot.x_ig_order_type
       AND ig.transaction_id = i_transaction_id
       AND iot.x_programme_name = 'SP_INSERT_IG_TRANSACTION'
       AND ROWNUM           = 1 ;
   EXCEPTION
     WHEN OTHERS THEN
       c_bucket_flag := 'YES';
   END;

   --CR52905 - Added IF to handle SUI buckets
   IF c_bucket_flag = 'SUI' AND i_direction = 'OUTBOUND'
   THEN
       --Fetch OUTBOUND buckets from ig_sui_transaction_buckets for SUI orders
       SELECT *
       BULK COLLECT INTO sui_rslt
         FROM (SELECT sa.sui_result_rec_type(igb.sui_display_type, LISTAGG(igb.bucket_id, ',') WITHIN GROUP (ORDER BY igb.bucket_id))
               FROM ig_sui_transaction_buckets igt,
                    ig_buckets igb,
                    ig_transaction ig
               WHERE igt.transaction_id = i_transaction_id
                 AND igb.bucket_id = igt.bucket_id
                 AND igb.active_flag = 'Y'
                 AND igb.rate_plan = ig.rate_plan
                 AND igt.transaction_id = ig.transaction_id
                 AND igt.direction = i_direction
               GROUP BY igb.sui_display_type);
   ELSE
       SELECT *
       BULK COLLECT INTO sui_rslt
         FROM (
               -- FETCH BUCKETS FROM IG_TRANSACTION_BUCKETS FOR THE TRANSACTION
               SELECT sa.sui_result_rec_type(igb.sui_display_type, LISTAGG(igb.bucket_id, ',') WITHIN GROUP (ORDER BY igb.bucket_id))
               FROM ig_transaction_buckets igt,
                    ig_buckets igb,
                    ig_transaction ig
               WHERE igt.transaction_id = i_transaction_id
                 AND igb.bucket_id = igt.bucket_id
                 AND igb.active_flag = 'Y'
                 AND igb.rate_plan = ig.rate_plan
                 AND igt.transaction_id = ig.transaction_id
                 AND igt.direction = i_direction
               GROUP BY igb.sui_display_type);
   END IF;

   RETURN sui_rslt;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN sui_rslt;
END fetch_sui_buckets;

-- CR55008 - SUI Result Monitoring
PROCEDURE insert_sui_inquiry_mismatches ( i_transaction_id   IN  NUMBER ,
                                          i_min              IN  VARCHAR2,
                                          i_esn              IN  VARCHAR2,
                                          i_inquiry_result   IN  sa.SUI_INQUIRY_RESULT_REC_TAB,
                                          o_response        OUT  VARCHAR2)
IS

   n_features_check   NUMBER := 0;
   n_mismtach_check   NUMBER := 0;
   c_action_item_id   ig_transaction.action_item_id%TYPE;
   c_status           ig_transaction.status%TYPE;
   c_order_type       ig_transaction.order_type%TYPE;
   invalid_input      EXCEPTION;
BEGIN

  --Check for transaction_id and min
  IF i_transaction_id IS NULL OR i_min IS NULL
  THEN
    o_response := 'TRANSACTION_ID and MIN are required';
    RAISE invalid_input;
  END IF;

  --Check for successful UI transaction
  BEGIN

    SELECT action_item_id, status, order_type
    INTO c_action_item_id, c_status, c_order_type
    FROM ig_transaction
    WHERE transaction_id = i_transaction_id;

  EXCEPTION
    WHEN OTHERS THEN
      o_response := 'Transaction Not Found';
      RAISE invalid_input;
  END;

  IF c_status NOT IN ('S', 'W') OR c_order_type != 'UI' --Consider SS, check the code
  THEN
    o_response := 'Order Type is not UI OR Transaction is not Successful';
    RAISE invalid_input;
  END IF;

  --Check if mismatch records for transaction already exist
  BEGIN

    SELECT COUNT(1)
    INTO n_mismtach_check
    FROM ig_sui_inquiry_mismatch
    WHERE transaction_id = i_transaction_id;

  EXCEPTION
    WHEN OTHERS THEN
      o_response := 'Error checking mismatch record exist';
      RAISE invalid_input;
  END;

  IF n_mismtach_check > 0
  THEN
    o_response := 'Mismatch record already exists for this Transaction';
    RAISE invalid_input;
  END IF;

  IF i_inquiry_result IS NOT NULL
  THEN
    IF i_inquiry_result.COUNT > 0
    THEN

      --Insert mismatch transaction header
      INSERT
      INTO ig_sui_inquiry_mismatch
      (
        transaction_id  ,
        action_item_id  ,
        min             ,
        esn             ,
        insert_timestamp
      )
      VALUES
      (
        i_transaction_id,
        c_action_item_id,
        i_min,
        i_esn,
        SYSDATE
      );

      --Insert mismatch transaction details other than features
      INSERT
      INTO ig_sui_inquiry_mismatch_dtl
      (
        transaction_id  ,
        attribute_name  ,
        clarify_value   ,
        carrier_value
      )
      SELECT i_transaction_id,
             attribute_name,
             clarify_value,
             carrier_value
      FROM TABLE(i_inquiry_result)
      WHERE attribute_name != 'FEATURES';

      --Check if there is a features mismatch
      SELECT COUNT(1)
      INTO n_features_check
      FROM TABLE(i_inquiry_result)
      WHERE attribute_name = 'FEATURES';

      IF n_features_check > 0
      THEN
        --Insert mismatched features
        INSERT
        INTO ig_sui_inquiry_mismatch_dtl
        (
          transaction_id  ,
          attribute_name  ,
          clarify_value   ,
          carrier_value
        )
        SELECT i_transaction_id,
               'FEATURES',
               fea_value clarify_value,
               CASE WHEN is_valid = 'IN_VALID' THEN 'REMOVE'
                    ELSE is_valid
               END carrier_value
        FROM TABLE(sa.adfcrm_sui_vo.get_validate_features(i_transaction_id));

      END IF; --IF n_features_check > 0

    END IF; --IF i_inquiry_result.COUNT > 0
  END IF; --IF i_inquiry_result IS NOT NULL

  o_response := 'SUCCESS';

 EXCEPTION
  WHEN INVALID_INPUT THEN -- CR57868 Excluded Error Logging
    /*ota_util_pkg.err_log( p_action        => 'Insert into ig_sui_transaction_mismatches failed.',
                          p_error_date    => SYSDATE,
                          p_key           => i_transaction_id,
                          p_program_name  => 'SUI_PKG.INSERT_SUI_INQUIRY_MISMATCHES',
                          p_error_text    => o_response || ' - ' || SQLERRM);*/
	NULL;

  WHEN OTHERS THEN
    o_response := SQLERRM;
    ota_util_pkg.err_log( p_action        => 'Insert into ig_sui_transaction_mismatches failed.',
                          p_error_date    => SYSDATE,
                          p_key           => i_transaction_id,
                          p_program_name  => 'SUI_PKG.INSERT_SUI_INQUIRY_MISMATCHES',
                          p_error_text    => SQLERRM);
END insert_sui_inquiry_mismatches;

END sui_pkg;
/