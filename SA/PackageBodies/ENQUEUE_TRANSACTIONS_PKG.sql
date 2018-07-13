CREATE OR REPLACE PACKAGE BODY sa."ENQUEUE_TRANSACTIONS_PKG" IS

-- Procedure to insert records into x_queue_event_log table
PROCEDURE insert_queue_event_log ( i_queue_event_log_objid  IN  NUMBER         DEFAULT NULL,
                                   i_esn                    IN  VARCHAR2       DEFAULT NULL,
                                   i_event_name             IN  VARCHAR2       DEFAULT NULL,
                                   i_min                    IN  VARCHAR2       DEFAULT NULL,
                                   i_msid                   IN  VARCHAR2       DEFAULT NULL,
                                   i_smptab                 IN  sa.smplist     DEFAULT NULL,
                                   i_call_trans_objid       IN  VARCHAR2       DEFAULT NULL,
                                   i_action_type            IN  VARCHAR2       DEFAULT NULL,
                                   i_action_text            IN  VARCHAR2       DEFAULT NULL,
                                   i_reason                 IN  VARCHAR2       DEFAULT NULL,
                                   i_sourcesystem           IN  VARCHAR2       DEFAULT NULL,
                                   i_sub_sourcesystem       IN  VARCHAR2       DEFAULT NULL,
                                   i_bus_org_id             IN  VARCHAR2       DEFAULT NULL,
                                   i_priority               IN  NUMBER         DEFAULT NULL,
                                   i_site_part_objid        IN  VARCHAR2       DEFAULT NULL,
                                   i_queue_event_log_status IN  VARCHAR2       DEFAULT NULL,
                                   i_seconds_delay          IN  NUMBER         DEFAULT NULL,
                                   i_enqueue_output_msg     IN  VARCHAR2       DEFAULT NULL,
                                   i_enqueue_timestamp      IN  DATE           DEFAULT NULL,
                                   i_dequeue_timestamp      IN  DATE           DEFAULT NULL,
                                   i_ignore_duplicate_flag  IN  VARCHAR2       DEFAULT NULL,
                                   i_insert_timestamp       IN  DATE           DEFAULT NULL,
                                   i_update_timestamp       IN  DATE           DEFAULT NULL,
                                   i_ig_transaction_id      IN  VARCHAR2       DEFAULT NULL,
                                   i_ig_order_type          IN  VARCHAR2       DEFAULT NULL,
                                   i_payload                IN  sa.q_payload_t DEFAULT NULL,
                                   o_response               OUT VARCHAR2	  ) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN --Main Section

    -- Logging into x_event_gateway table for tracking transactions
    INSERT
    INTO   sa.x_queue_event_log
           (objid                 ,
            esn                   ,
            event_name            ,
            min                   ,
            msid                  ,
            smps                  ,
            call_trans_objid      ,
            action_type           ,
            action_text           ,
            reason                ,
            sourcesystem          ,
            sub_sourcesystem      ,
            bus_org_id            ,
            priority              ,
            site_part_objid       ,
            queue_event_log_status,
            seconds_delay         ,
            enqueue_output_message,
            enqueue_timestamp     ,
            dequeue_timestamp     ,
            ignore_duplicate_flag ,
            insert_timestamp      ,
            update_timestamp      ,
            ig_transaction_id     ,
            ig_order_type         ,
            payload
           )
    VALUES (i_queue_event_log_objid ,
            i_esn                   ,
            i_event_name            ,
            i_min                   ,
            i_msid                  ,
            i_smptab                ,
            i_call_trans_objid      ,
            i_action_type           ,
            i_action_text           ,
            i_reason                ,
            i_sourcesystem          ,
            i_sub_sourcesystem      ,
            i_bus_org_id            ,
            i_priority              ,
            i_site_part_objid       ,
            i_queue_event_log_status,
            i_seconds_delay         ,
            i_enqueue_output_msg    ,
            i_enqueue_timestamp     ,
            i_dequeue_timestamp     ,
            i_ignore_duplicate_flag ,
            i_insert_timestamp      ,
            i_update_timestamp      ,
            i_ig_transaction_id     ,
            i_ig_order_type         ,
            i_payload
           );
  COMMIT;
  o_response := 'SUCCESS';
 EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK;
     o_response := 'ERROR INSERTING INTO QUEUE EVENT LOG: '||SQLERRM;
     RETURN;
END insert_queue_event_log;

--New stored procedure to enqueue transactions to AQ
PROCEDURE enqueue_transaction ( i_esn               IN  VARCHAR2 ,
                                i_ig_order_type     IN  VARCHAR2 ,
                                i_ig_transaction_id IN  NUMBER   ,
                                o_response          OUT VARCHAR2 ) IS
  -- Local variables
  payload                 sa.q_payload_t                                    ;
  nameval                 sa.q_nameval_tab       := sa.q_nameval_tab()      ;
  enq_msg                 VARCHAR2(1000)                                    ;
  c_brm_notification_flag VARCHAR2(1)                                       ;
  n_queue_event_log_seq   NUMBER                                            ;
  n_seconds_delay         NUMBER                 := 0                       ;
  n_message_priority      NUMBER                 := 1                       ;
  c_event_name            VARCHAR2(100)                                     ;
  cst                     sa.customer_type       := sa.customer_type()      ;
  c                       sa.customer_type       := sa.customer_type()      ;
  ig                      sa.ig_transaction_type := sa.ig_transaction_type();
  ct                      sa.call_trans_type     := sa.call_trans_type()    ;
  pintab                  sa.smplist                                        ;
  c_smp                   VARCHAR2(30)                                      ;
  c_pin                   VARCHAR2(40)                                      ;
  n_brm_channel_id        NUMBER                                            ;
  c_deal_name             VARCHAR2(40)                                      ;
  c_old_min               VARCHAR2(30)                                      ;
  c_brm_react_flag        VARCHAR2(1)            := 'N'                     ;
  c_ct_reason             VARCHAR2(500)                                     ;
  n_service_days_remain   NUMBER                 := 0                       ;
BEGIN -- Main Section

  -- determine if the order type transaction needs to be sent to brm
  BEGIN
    SELECT NVL(brm_notification_flag,'N'),
           UPPER(x_actual_order_type)
    INTO   c_brm_notification_flag,
           c_event_name
    FROM   sa.x_ig_order_type
    WHERE  TRIM(x_programme_name) = 'SP_INSERT_IG_TRANSACTION'
    AND    x_ig_order_type        = i_ig_order_type
    AND    ROWNUM = 1;
   EXCEPTION
    WHEN OTHERS THEN
      o_response := 'SUCCESS|TRANSACTION NOT APPLICABLE FOR BRM';
      RETURN;
  END;

  -- exit the program when the order type is not applicable
  IF NVL(c_brm_notification_flag,'N') = 'N' THEN
    o_response := 'TRANSACTION NOT APPLICABLE FOR BRM';
    RETURN;
  END IF;

  -- get the web user attributes
  cst := customer_type ( i_esn => i_esn );
  c   := cst.get_web_user_attributes;

  -- validate if the brand applies to be sent to BRM
  IF NVL(cst.get_brm_notification_flag ( i_bus_org_objid => c.bus_org_objid),'N') = 'N' OR
     sa.customer_info.get_brm_notification_flag ( i_esn => i_esn ) = 'N'
  THEN
    o_response := 'BRAND NOT APPLICABLE FOR BRM';
    RETURN;
  END IF;

  -- get IG transaction details
  ig := ig_transaction_type ( i_transaction_id   => i_ig_transaction_id );

  -- get the call trans details
  ct := call_trans_type ( i_call_trans_objid => ig.call_trans_objid );

  --CR52355 -Start
  --Adding below condition to suppress transactions and not to notify BRM
  -- CR53838 Removing the condition which supress the BRM notifications
  -- Check for IG order type 'CR' then retrieve SMP
  IF ig.order_type = 'CR' THEN
    -- Retrieve the list of SMP's
    BEGIN
      SELECT rc.x_red_code
      BULK   COLLECT
      INTO   pintab
      FROM   table_x_call_trans ct1,
             table_x_red_card   rc
      WHERE  ct1.objid = ct.call_trans_objid
      AND    ct1.objid = rc.red_card2call_trans;
     EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    -- Retrieve single SMP value from SMP list to place it in WFM AQ
    BEGIN
      SELECT *
      INTO  c_pin
      FROM  TABLE(CAST(pintab AS smplist))
      WHERE ROWNUM = 1;
     EXCEPTION
       WHEN OTHERS THEN
         NULL;
    END;

    --
    BEGIN
      SELECT brm_channel_id
      INTO   n_brm_channel_id
      FROM   table_channel tc
      WHERE  tc.s_title = ct.sourcesystem;
     EXCEPTION
       WHEN OTHERS THEN
            NULL;
    END;
    -- To retrieve the APP part number's part class for the given PIN
    BEGIN
      SELECT pc.name
      INTO   c_deal_name
      FROM   sa.table_x_red_card rc,
             sa.table_part_num pn,
             sa.table_mod_level ml,
             sa.table_part_class pc
      WHERE  rc.x_red_code = c_pin
      AND    ml.objid      = rc.x_red_card2part_mod
      AND    pn.objid      = ml.part_info2part_num
      AND    pc.objid      = pn.part_num2part_class
      AND    ROWNUM        = 1;
     EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF;

  -- Retrieve OLD MIN to notify BRM for MIN change
  IF ig.order_type IN ('A','MINC') THEN
  --
    BEGIN
      SELECT ct.x_min,
             ct.x_reason
      INTO   c_old_min,
             c_ct_reason
      FROM   table_x_call_trans ct
      WHERE  objid = ( SELECT MAX(objid)
                       FROM   table_x_call_trans
                       WHERE  x_service_id  = i_esn
                       AND    x_action_type = '2'
                       AND    x_action_text = 'DEACTIVATION'
                       AND    x_result      = 'Completed'
                     );
     EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    --Validating for reactivation and prior deactivation reason to notify BRM
    IF ct.action_text = 'REACTIVATION' THEN
       --
       BEGIN
         SELECT CASE
                  WHEN dc.brm_order_type = 'D' THEN 'Y'
                  ELSE 'N'
                END
         INTO   c_brm_react_flag
         FROM   x_deact_reason_config dc
         WHERE  dc.deact_reason          = c_ct_reason
         AND    dc.brm_notification_flag = 'Y';
       EXCEPTION
         WHEN OTHERS THEN
              c_brm_react_flag := 'N';
       END;
    --
    END IF;
  --
  END IF;

  -- get service days left
  n_service_days_remain := TRUNC(sa.customer_info.get_expiration_date( i_esn => i_esn ) ) - TRUNC (SYSDATE);

  -- Generating sequence
  SELECT seq_queue_event_log.NEXTVAL
  INTO   n_queue_event_log_seq
  FROM   DUAL;

  -- Assigning values to name value element
  sa.queue_pkg.add_nameval_elmt('WEBOBJID'              ,c.web_user_objid      , nameval);
  sa.queue_pkg.add_nameval_elmt('ESNPARTINSTOBJID'      ,c.esn_part_inst_objid , nameval);
  sa.queue_pkg.add_nameval_elmt('CALL_TRANS_REASON'     ,ct.reason             , nameval);
  sa.queue_pkg.add_nameval_elmt('MIN'                   ,ig.min                , nameval);
  sa.queue_pkg.add_nameval_elmt('MSID'                  ,ig.msid               , nameval);
  sa.queue_pkg.add_nameval_elmt('IG_ORDER_TYPE'         ,ig.order_type         , nameval);
  sa.queue_pkg.add_nameval_elmt('EVENTOBJID'            ,n_queue_event_log_seq , nameval);
  sa.queue_pkg.add_nameval_elmt('PIN'                   ,c_pin                 , nameval);
  sa.queue_pkg.add_nameval_elmt('CHANNEL_ID'            ,n_brm_channel_id      , nameval);
  sa.queue_pkg.add_nameval_elmt('DEAL_NAME'             ,c_deal_name           , nameval);
  sa.queue_pkg.add_nameval_elmt('CALL_TRANS_ACTION_TEXT',ct.action_text        , nameval);
  sa.queue_pkg.add_nameval_elmt('OLD_MIN'               ,c_old_min             , nameval);
  sa.queue_pkg.add_nameval_elmt('BRM_REACT_FLAG'        ,c_brm_react_flag      , nameval);
  sa.queue_pkg.add_nameval_elmt('SERVICE_DAYS_REMAINING',n_service_days_remain , nameval);
  sa.queue_pkg.add_nameval_elmt('LL_ENROLLMENT_FLAG'    ,NULL                  ,nameval); --Added for CR49915 Lifeline
  sa.queue_pkg.add_nameval_elmt('AFFILIATED_PARTNER'    ,NULL                  ,nameval); --Added for CR48260_MLD SM
  -- Framing the payload to enqueue
  payload := sa.q_payload_t('IG_ORDER_TYPE'  ,-- source_type
                            'X_IG_ORDER_TYPE',-- source_tbl
                            'COMPLETE'       ,-- source_status
                            i_esn            ,-- esn
                            ig.msid          ,-- min
                            c.bus_org_id     ,-- brand
                            c_event_name     ,-- event_name
                            nameval          ,-- varray
                            'INIT'            -- step_complete
                            );
   --Call procedure to insert record into x_queue_event_log table
  BEGIN
    insert_queue_event_log ( i_queue_event_log_objid => n_queue_event_log_seq ,
                             i_esn                   => i_esn                 ,
                             i_event_name            => c_event_name          ,
                             i_min                   => ig.min                ,
                             i_msid                  => ig.msid               ,
                             i_smptab                => pintab                ,
                             i_call_trans_objid      => ig.call_trans_objid   ,
                             i_action_type           => ct.action_type        ,
                             i_action_text           => ct.action_text        ,
                             i_reason                => ct.reason             ,
                             i_sourcesystem          => ct.sourcesystem       ,
                             i_sub_sourcesystem      => ct.sub_sourcesystem   ,
                             i_bus_org_id            => c.bus_org_id          ,
                             i_priority              => 2                     ,
                             i_site_part_objid       => NULL                  ,-- site_part_objid,
                             i_queue_event_log_status=> 'N'                   ,
                             i_seconds_delay         => 0                     ,
                             i_enqueue_output_msg    => enq_msg               ,
                             i_enqueue_timestamp     => SYSDATE               ,
                             i_dequeue_timestamp     => SYSDATE               ,
                             i_ignore_duplicate_flag => NULL                  ,--ignore_duplicate_flag,
                             i_insert_timestamp      => SYSDATE               ,
                             i_update_timestamp      => SYSDATE               ,
                             i_ig_transaction_id     => i_ig_transaction_id   ,
                             i_ig_order_type         => i_ig_order_type       ,
                             i_payload               => payload               ,
                             o_response              => o_response            );
  END;

  --  Enqueue transactions to MAIN AQ for the above mentioned payload
  IF NOT sa.queue_pkg.enq ( i_q_name     => 'SA.CLFY_MAIN_Q'   ,
                            io_q_payload => payload            ,
                            o_op_msg     => enq_msg            ,
                            ip_delay     => n_seconds_delay    , -- delay in seconds (before available for dequeue)
                            ip_priority  => n_message_priority )
  THEN
    -- Updating to 'E' if any error occurred while enqueue
    UPDATE x_queue_event_log
    SET    queue_event_log_status = 'E',
           enqueue_output_message = enq_msg
    WHERE  objid = n_queue_event_log_seq;
  END IF;

  -- Updating to 'Q' on successful enqueue
  UPDATE x_queue_event_log
  SET    queue_event_log_status = 'Q',
         enqueue_output_message = enq_msg
  WHERE  objid = n_queue_event_log_seq;

  --CR48260_MultiLine Discount on SM - call sp_notify_affpart_discount_BRM
  enqueue_transactions_pkg.sp_notify_affpart_discount_BRM   (i_web_user_objid    => c.web_user_objid     ,
                                                             i_login_name        => c.web_login_name     ,
                                                             i_bus_org_id        => c.bus_org_id         ,
                                                             i_web_user2contact	 => c.web_contact_objid	 ,
                                                             o_response          => o_response)	;
  -- set response
  o_response := 'SUCCESS';
  --
 EXCEPTION
   WHEN OTHERS THEN
     o_response := 'ERROR WHILE ENQUEUING TRANSACTION: ' ||SQLERRM;
END enqueue_transaction;

--New stored procedure to update x_event_gateway table based on event objid
PROCEDURE update_event ( i_event_objid            IN  NUMBER   ,
                         i_request                IN  XMLTYPE  ,
                         i_response               IN  XMLTYPE  ,
                         i_http_code              IN  NUMBER   ,
                         i_retry_count            IN  NUMBER   ,
                         i_queue_event_log_status IN  VARCHAR2 ,
                         o_response               OUT VARCHAR2 ) IS

BEGIN -- Main Section
  --
  UPDATE x_queue_event_log
  SET    request                = i_request    ,
         response               = i_response   ,
         http_code              = i_http_code  ,
         retry_count            = CASE WHEN i_queue_event_log_status='R' THEN retry_count ELSE i_retry_count END,
         queue_event_log_status = i_queue_event_log_status,
         update_timestamp       = SYSDATE
  WHERE  objid                  = i_event_objid;

  -- Set response
  o_response := 'SUCCESS';
  --
 EXCEPTION
   WHEN OTHERS THEN
     o_response := 'ERROR WHILE UPDATE EVENT: '||SQLERRM;
END update_event;

-- New stored procedure to enqueue deactivation transactions
PROCEDURE enqueue_deactivation ( i_esn            IN  VARCHAR2 ,
                                 i_min            IN  VARCHAR2 ,
                                 i_deactreason    IN  VARCHAR2 ,
                                 i_sourcesystem   IN  VARCHAR2 ,
                                 i_action_item_id IN  VARCHAR2 ,
                                 o_response       OUT VARCHAR2 ) IS
  --
  payload                 sa.q_payload_t                              ;
  nameval                 sa.q_nameval_tab       := sa.q_nameval_tab();
  enq_msg                 VARCHAR2(1000)                              ;
  c_brm_notification_flag VARCHAR2(1)                                 ;
  n_queue_event_log_seq   NUMBER                                      ;
  n_seconds_delay         NUMBER                 := 0                 ;
  n_message_priority      NUMBER                 := 1                 ;
  cst                     sa.customer_type       := sa.customer_type();
  c                       sa.customer_type       := sa.customer_type();
  c_brm_order_type        VARCHAR2(30)                                ;
  c_smp                   VARCHAR2(30)                                ;
  c_pin                   VARCHAR2(40)                                ;
  n_service_days_remain   NUMBER                 := 0                 ;
  c_ig_order_type         VARCHAR2(30);

BEGIN -- Main Section

  -- Determine if the order type transaction needs to be sent to BRM
  BEGIN
    SELECT NVL(brm_notification_flag,'N'),
           brm_order_type
    INTO   c_brm_notification_flag,
           c_brm_order_type
    FROM   sa.x_deact_reason_config
    WHERE  deact_reason = UPPER(i_deactreason);
   EXCEPTION
     WHEN OTHERS THEN
       o_response := 'DEACTIVATION REASON NOT FOUND';
       RETURN;
  END;

  -- exit the program when the deactivation reason is not applicable
  IF NVL(c_brm_notification_flag,'N') = 'N' THEN
    o_response := 'DEACTIVATION REASON NOT APPLICABLE FOR BRM';
    RETURN;
  END IF;

  -- get the web user attributes
  cst := customer_type ( i_esn => i_esn );
  c   := cst.get_web_user_attributes;

  -- validate if the brand applies to be sent to BRM
  IF NVL(cst.get_brm_notification_flag ( i_bus_org_objid => c.bus_org_objid),'N') = 'N' OR
     sa.customer_info.get_brm_notification_flag ( i_esn => i_esn ) = 'N'
  THEN
    o_response := 'BRAND NOT APPLICABLE FOR BRM';
    RETURN;
  END IF;

  -- get the ig order type from action item
  BEGIN
    SELECT order_type
    INTO   c_ig_order_type
	FROM   ig_transaction
	WHERE  action_item_id = i_action_item_id;
   EXCEPTION
    WHEN others THEN
      c_ig_order_type := NULL;
  END;

  -- block past due batch job executions from notifying brm
--   IF (i_sourcesystem IN ('PAST_DUE_BATCH' ) AND (c_ig_order_type IN ('S') OR i_action_item_id is NULL ))
--  THEN
--    o_response := 'TRANSACTION NOT APPLICABLE FOR BRM';
--    RETURN;
--  END IF;

  -- Get the last valid redeemed pin (smp)
  BEGIN
     SELECT sa.customer_info.convert_pin_to_smp ( i_red_card_code => rc.x_red_code ) smp,
            rc.x_red_code pin
     INTO   c_smp,
            c_pin
     FROM   table_x_call_trans ct,
            table_x_red_card rc
     WHERE  rc.red_card2call_trans = ct.objid
     AND    ct.objid = ( SELECT MAX(objid)
                         FROM   table_x_call_trans xct
                         WHERE  x_action_type IN ( '1', '3', '6')
                         AND    x_service_id = i_esn
                         AND EXISTS ( SELECT 1
                                      FROM   x_serviceplanfeaturevalue_def a,
                                             sa.mtm_partclass_x_spf_value_def b,
                                             sa.x_serviceplanfeaturevalue_def c,
                                             sa.mtm_partclass_x_spf_value_def d,
                                             x_serviceplanfeature_value spfv,
                                             x_service_plan_feature spf,
                                             x_service_plan sp
                                      WHERE  a.objid = b.spfeaturevalue_def_id
                                      AND    b.part_class_id in ( SELECT pn.part_num2part_class
                                                                  FROM   table_x_red_card rc,
                                                                         -- validate there is a base service plan redemption from red card
                                                                         table_mod_level ml,
                                                                         table_part_num pn
                                                                  WHERE  1 = 1
                                                                  AND    rc.red_card2call_trans = xct.objid
                                                                  AND    ml.objid = rc.x_red_card2part_mod
                                                                  AND    pn.objid = ml.part_info2part_num
                                                                  AND    pn.domain = 'REDEMPTION CARDS'
                                                                )
                                      -- Include the base service plans only (not the add on)
                                      AND NOT EXISTS ( SELECT 1
                                                       FROM   sa.service_plan_feat_pivot_mv
                                                       WHERE  service_plan_objid = sp.objid
                                                       AND    service_plan_group = 'ADD_ON_DATA'
                                                     )
                                      AND    c.objid = d.spfeaturevalue_def_id
                                      AND    d.part_class_id = ( SELECT pn.part_num2part_class
                                                                 FROM   table_part_inst pi,
                                                                        table_mod_level ml,
                                                                        table_part_num pn
                                                                 WHERE  1 = 1
                                                                 AND    pi.part_serial_no   = xct.x_service_id
                                                                 AND    pi.x_domain         = 'PHONES'
                                                                 AND    ml.objid            = pi.n_part_inst2part_mod
                                                                 AND    pn.objid            = ml.part_info2part_num
                                                                 AND    pn.domain           = 'PHONES'
                                                               )
                                      AND    a.value_name = c.value_name
                                      AND    spfv.value_ref = c.objid
                                      AND    spf.objid = spfv.spf_value2spf
                                      AND    sp.objid = spf.sp_feature2service_plan
                                    )
                       );
   EXCEPTION
    WHEN OTHERS THEN
      c_smp := NULL;
      c_pin := NULL;
  END;

  -- get service days left
  n_service_days_remain := TRUNC(sa.customer_info.get_expiration_date( i_esn => i_esn ) ) - TRUNC (SYSDATE);

  -- generating sequence
  SELECT seq_queue_event_log.NEXTVAL
  INTO   n_queue_event_log_seq
  FROM   DUAL;

  -- Assigning values to name value element
  sa.queue_pkg.add_nameval_elmt('WEBOBJID'              ,c.web_user_objid      ,nameval);
  sa.queue_pkg.add_nameval_elmt('ESNPARTINSTOBJID'      ,c.esn_part_inst_objid ,nameval);
  sa.queue_pkg.add_nameval_elmt('DEACTIVATION_REASON'   ,i_deactreason         ,nameval);
  sa.queue_pkg.add_nameval_elmt('MIN'                   ,i_min                 ,nameval);
  sa.queue_pkg.add_nameval_elmt('MSID'                  ,NULL                  ,nameval); --This name value element is placed for POJO order but value will be NULL
  sa.queue_pkg.add_nameval_elmt('IG_ORDER_TYPE'         ,c_brm_order_type      ,nameval);
  sa.queue_pkg.add_nameval_elmt('EVENTOBJID'            ,n_queue_event_log_seq ,nameval);
  sa.queue_pkg.add_nameval_elmt('PIN'                   ,c_pin                 ,nameval);
  sa.queue_pkg.add_nameval_elmt('CHANNEL_ID'            ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('DEAL_NAME'             ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('CALL_TRANS_ACTION_TEXT',NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('OLD_MIN'               ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('BRM_REACT_FLAG'        ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('SERVICE_DAYS_REMAINING',n_service_days_remain ,nameval);
  sa.queue_pkg.add_nameval_elmt('LL_ENROLLMENT_FLAG'    ,NULL                  ,nameval); --Added for CR49915 Lifeline
  sa.queue_pkg.add_nameval_elmt('AFFILIATED_PARTNER'    ,NULL                  ,nameval); --Added for CR48260_MLD SM
  -- Framing the payload to enqueue
  payload := sa.q_payload_t ( 'IG_ORDER_TYPE'  ,-- source_type
                              'X_IG_ORDER_TYPE',-- source_tbl
                              'COMPLETE'       ,-- source_status
                              i_esn            ,-- esn
                              i_min            ,-- min
                              c.bus_org_id     ,-- brand
                              'DEACTIVATION'   ,-- event_name
                              nameval          ,-- varray
                              'INIT'            -- step_complete
                            );

  --Call procedure to insert record into x_queue_event_log table
  BEGIN
    insert_queue_event_log ( i_queue_event_log_objid  => n_queue_event_log_seq ,
                             i_esn                    => i_esn                 ,
                             i_event_name             => 'DEACTIVATION'        ,
                             i_min                    => i_min                 ,
                             i_msid                   => NULL                  ,--msid
                             i_smptab                 => NULL                  ,--pintab
                             i_call_trans_objid       => NULL                  ,--call_trans_objid
                             i_action_type            => NULL                  ,--action_type
                             i_action_text            => NULL                  ,--action_text
                             i_reason                 => i_deactreason         ,
                             i_sourcesystem           => i_sourcesystem        ,
                             i_sub_sourcesystem       => NULL                  ,--sub_sourcesystem
                             i_bus_org_id             => c.bus_org_id          ,
                             i_priority               => 2                     ,
                             i_site_part_objid        => NULL                  ,--site_part_objid
                             i_queue_event_log_status => 'N'                   ,
                             i_seconds_delay          => 0                     ,
                             i_enqueue_output_msg     => enq_msg               ,
                             i_enqueue_timestamp      => SYSDATE               ,
                             i_dequeue_timestamp      => SYSDATE               ,
                             i_ignore_duplicate_flag  => NULL                  ,--ignore_duplicate_flag
                             i_insert_timestamp       => SYSDATE               ,
                             i_update_timestamp       => SYSDATE               ,
                             i_ig_transaction_id      => NULL                  ,--ig_transaction_id
                             i_ig_order_type          => NULL                  ,--ig_order_type
                             i_payload                => payload               ,
                             o_response               => o_response            );
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
  END;

  --  Enqueue transactions to MAIN AQ for the above mentioned payload
  IF NOT sa.queue_pkg.enq ( i_q_name     => 'SA.CLFY_MAIN_Q'   ,
                            io_q_payload => payload            ,
                            o_op_msg     => enq_msg            ,
                            ip_delay     => n_seconds_delay    , -- delay in seconds (before available for dequeue)
                            ip_priority  => n_message_priority )
  THEN
    -- Updating to 'E' if any error occurred while enqueue
    UPDATE x_queue_event_log
    SET    queue_event_log_status = 'E',
           enqueue_output_message = enq_msg
    WHERE  objid                  = n_queue_event_log_seq;
  END IF;

  -- Updating to 'Q' on successful enqueue
  UPDATE x_queue_event_log
  SET    queue_event_log_status = 'Q',
         enqueue_output_message = enq_msg
  WHERE  objid                  = n_queue_event_log_seq;

  -- Set response
  o_response := 'SUCCESS';

 EXCEPTION
  WHEN OTHERS THEN
    o_response := 'ERROR WHILE ENQUEUING DEACTIVATION: '||SQLERRM;
--
END enqueue_deactivation;

--New stored procedure to enqueue migration
PROCEDURE enqueue_migration ( i_esn               IN VARCHAR2  ,
                              i_min               IN VARCHAR2  ,
                              i_web_user_objid    IN NUMBER    ,
                              i_bus_org_id        IN VARCHAR2  ,
                              i_sourcesystem      IN VARCHAR2  ,
                              i_ct_objid          IN NUMBER    ,
                              i_ct_action_type    IN VARCHAR2  ,
                              i_ct_action_text    IN VARCHAR2  ,
                              i_ct_reason         IN VARCHAR2  ,
                              i_ig_order_type     IN VARCHAR2  ,
                              i_ig_transaction_id IN NUMBER    ,
                              i_event_name        IN VARCHAR2  ,
                              o_response          OUT VARCHAR2 ) IS

  -- Local variables
  payload                 sa.q_payload_t                              ;
  nameval                 sa.q_nameval_tab       := sa.q_nameval_tab();
  enq_msg                 VARCHAR2(1000)                              ;
  n_queue_event_log_seq   NUMBER                                      ;
  n_seconds_delay         NUMBER                 := 0                 ;
  n_message_priority      NUMBER                 := 1                 ;
  n_esn_partinst_objid    NUMBER                                      ;
  n_service_days_remain   NUMBER                 := 0                 ;


BEGIN -- Main Section

  -- get service days left
  n_service_days_remain := TRUNC(sa.customer_info.get_expiration_date( i_esn => i_esn ) ) - TRUNC (SYSDATE);

  -- Generating sequence
  SELECT seq_queue_event_log.NEXTVAL
  INTO   n_queue_event_log_seq
  FROM   DUAL;

  n_esn_partinst_objid := sa.customer_info.get_esn_part_inst_objid ( i_esn => i_esn );

  -- Assigning values to name value element
  sa.queue_pkg.add_nameval_elmt('WEBOBJID'              ,i_web_user_objid      ,nameval);
  sa.queue_pkg.add_nameval_elmt('ESNPARTINSTOBJID'      ,n_esn_partinst_objid  ,nameval);
  sa.queue_pkg.add_nameval_elmt('CALL_TRANS_REASON'     ,i_ct_reason           ,nameval);
  sa.queue_pkg.add_nameval_elmt('MIN'                   ,i_min                 ,nameval);
  sa.queue_pkg.add_nameval_elmt('MSID'                  ,i_min                 ,nameval);
  sa.queue_pkg.add_nameval_elmt('IG_ORDER_TYPE'         ,i_ig_order_type       ,nameval);
  sa.queue_pkg.add_nameval_elmt('EVENTOBJID'            ,n_queue_event_log_seq ,nameval);
  sa.queue_pkg.add_nameval_elmt('PIN'                   ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('CHANNEL_ID'            ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('DEAL_NAME'             ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('CALL_TRANS_ACTION_TEXT',i_ct_action_text      ,nameval);
  sa.queue_pkg.add_nameval_elmt('OLD_MIN'               ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('BRM_REACT_FLAG'        ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('SERVICE_DAYS_REMAINING',n_service_days_remain ,nameval);
  sa.queue_pkg.add_nameval_elmt('LL_ENROLLMENT_FLAG'    ,NULL                  ,nameval); --Added for CR49915 Lifeline
  sa.queue_pkg.add_nameval_elmt('AFFILIATED_PARTNER'    ,NULL                  ,nameval); --Added for CR48260_MLD SM
  -- Framing the payload to enqueue
  payload := sa.q_payload_t ('IG_ORDER_TYPE'  ,-- source_type
                             'X_IG_ORDER_TYPE',-- source_tbl
                             'COMPLETE'       ,-- source_status
                             i_esn            ,-- esn
                             i_min            ,-- min
                             i_bus_org_id     ,-- brand
                             i_event_name     ,-- event_name
                             nameval          ,-- varray
                             'INIT'            -- step_complete
                            );
  -- Call procedure to insert record into x_queue_event_log table
  BEGIN
    insert_queue_event_log ( i_queue_event_log_objid => n_queue_event_log_seq ,
                             i_esn                   => i_esn                 ,
                             i_event_name            => i_event_name          ,
                             i_min                   => i_min                 ,
                             i_msid                  => i_min                 ,
                             i_smptab                => NULL                  , -- PIN
                             i_call_trans_objid      => i_ct_objid            ,
                             i_action_type           => i_ct_action_type      ,
                             i_action_text           => i_ct_action_text      ,
                             i_reason                => i_ct_reason           ,
                             i_sourcesystem          => i_sourcesystem        ,
                             i_sub_sourcesystem      => i_bus_org_id          ,
                             i_bus_org_id            => i_bus_org_id          ,
                             i_priority              => 2                     ,
                             i_site_part_objid       => NULL                  , -- site_part_objid,
                             i_queue_event_log_status=> 'N'                   ,
                             i_seconds_delay         => 0                     ,
                             i_enqueue_output_msg    => enq_msg               ,
                             i_enqueue_timestamp     => SYSDATE               ,
                             i_dequeue_timestamp     => SYSDATE               ,
                             i_ignore_duplicate_flag => NULL                  , -- ignore_duplicate_flag,
                             i_insert_timestamp      => SYSDATE               ,
                             i_update_timestamp      => SYSDATE               ,
                             i_ig_transaction_id     => i_ig_transaction_id   ,
                             i_ig_order_type         => i_ig_order_type       ,
                             i_payload               => payload               ,
                             o_response              => o_response            );
  END;

  --  Enqueue transactions to MAIN AQ for the above mentioned payload
  IF NOT sa.queue_pkg.enq ( i_q_name     => 'SA.CLFY_MAIN_Q'   ,
                            io_q_payload => payload            ,
                            o_op_msg     => enq_msg            ,
                            ip_delay     => n_seconds_delay    , -- delay in seconds (before available for dequeue)
                            ip_priority  => n_message_priority )
  THEN
    -- Updating to 'E' if any error occurred while enqueue
    UPDATE x_queue_event_log
    SET    queue_event_log_status = 'E',
           enqueue_output_message = enq_msg
    WHERE  objid = n_queue_event_log_seq;
  END IF;

  -- Updating to 'Q' on successful enqueue
  UPDATE x_queue_event_log
  SET    queue_event_log_status = 'Q',
         enqueue_output_message = enq_msg
  WHERE  objid = n_queue_event_log_seq;

  -- set response
  o_response := 'SUCCESS';
  --
 EXCEPTION
   WHEN OTHERS THEN
     o_response := 'ERROR WHILE ENQUEUING MIGRATION: '||SQLERRM;

END enqueue_migration;
-- New Stored procedure to re-enqueue the failed transactions.
PROCEDURE reenqueue_transactions ( i_max_rows_limit     IN    NUMBER  DEFAULT 10000,
                                   i_commit_every_rows  IN    NUMBER  DEFAULT 5000,
                                   i_max_retries        IN    NUMBER  DEFAULT 3,
                                   o_err_num            OUT   VARCHAR2,
                                   o_err_msg            OUT   VARCHAR2 )
IS
  CURSOR requeue_transactions_cur
  IS
    SELECT *
    FROM   ( SELECT *
             FROM   x_queue_event_log
             WHERE  queue_event_log_status = 'R'
             AND    NVL(retry_count, 0) <= i_max_retries
             ORDER BY insert_timestamp
           )
    WHERE  ROWNUM <= i_max_rows_limit;

  enq_msg                 VARCHAR2(1000);
  n_seconds_delay         NUMBER    := 0;
  n_message_priority      NUMBER    := 1;
  n_count_rows            NUMBER    := 0;

BEGIN
  --Fetch the transaction for re-enqueue
  FOR i IN requeue_transactions_cur
  LOOP

    IF NVL(i.retry_count,0) = i_max_retries
    THEN
      UPDATE x_queue_event_log
      SET    queue_event_log_status = 'F',
             enqueue_output_message = 'Maximum retries completed',
             update_timestamp = SYSDATE
      WHERE  objid = i.objid;

    ELSE

      --  Enqueue transactions to MAIN AQ for the above mentioned payload
      IF NOT sa.queue_pkg.enq ( i_q_name     => 'SA.CLFY_MAIN_Q',
                                io_q_payload => i.payload,
                                o_op_msg     => enq_msg ,
                                ip_delay     => n_seconds_delay , -- delay in seconds (before available for dequeue)
                                ip_priority  => n_message_priority )
      THEN
        -- Updating to 'E' if any error occurred while enqueue
        UPDATE x_queue_event_log
        SET queue_event_log_status = 'E',
          enqueue_output_message   = enq_msg,
          update_timestamp         = SYSDATE,
          retry_count              = GREATEST(NVL(retry_count,0),0) + 1 -- add a retry count when message is resent
        WHERE objid                = i.objid;
      ELSE
        -- Updating to 'Q' on successful enqueue
        UPDATE x_queue_event_log
        SET queue_event_log_status = 'Q',
          enqueue_output_message   = enq_msg,
          update_timestamp         = SYSDATE,
          retry_count              = GREATEST(NVL(retry_count,0),0) + 1 -- add a retry count when message is resent
        WHERE objid                = i.objid;
      END IF;
    END IF;

    n_count_rows := n_count_rows + 1;

    IF (MOD (n_count_rows, i_commit_every_rows) = 0) THEN
      -- Save changes
      COMMIT;
    END IF;

  END LOOP;

  -- save changes
  COMMIT;

  o_err_num := '0';
  o_err_msg := 'SUCCESS';

 EXCEPTION
  WHEN OTHERS THEN
    o_err_num := SQLCODE;
    o_err_msg := SUBSTR(SQLERRM, 1, 1000);
END reenqueue_transactions;

--New stored procedure to enqueue manual refurbish transactions from TAS
PROCEDURE enqueue_refurbish_transaction(i_esn      IN  VARCHAR2,
                                        o_response OUT VARCHAR2
					)
AS
-- Local variables
  payload                 sa.q_payload_t                              ;
  nameval                 sa.q_nameval_tab       := sa.q_nameval_tab();
  enq_msg                 VARCHAR2(1000)                              ;
  n_queue_event_log_seq   NUMBER                                      ;
  n_seconds_delay         NUMBER                 := 0                 ;
  n_message_priority      NUMBER                 := 1                 ;
  c_event_name            VARCHAR2(100)          := 'REFURBISH'       ;
  cst                     sa.customer_type       := sa.customer_type();
  c                       sa.customer_type       := sa.customer_type();

BEGIN -- Main Section

  -- get the web user attributes
  cst := customer_type ( i_esn => i_esn );
  c   := cst.get_web_user_attributes;

  -- validate if the brand applies to be sent to BRM
  IF NVL(cst.get_brm_notification_flag ( i_bus_org_objid => c.bus_org_objid),'N') = 'N' OR
     sa.customer_info.get_brm_notification_flag ( i_esn => i_esn ) = 'N'
  THEN
    o_response := 'BRAND NOT APPLICABLE FOR BRM';
    RETURN;
  END IF;

  -- Generating sequence
  SELECT seq_queue_event_log.NEXTVAL
  INTO   n_queue_event_log_seq
  FROM   DUAL;

  -- Assigning values to name value element
  sa.queue_pkg.add_nameval_elmt('WEBOBJID'              ,c.web_user_objid      ,nameval);
  sa.queue_pkg.add_nameval_elmt('ESNPARTINSTOBJID'      ,c.esn_part_inst_objid ,nameval);
  sa.queue_pkg.add_nameval_elmt('CALL_TRANS_REASON'     ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('MIN'                   ,c.min                 ,nameval);
  sa.queue_pkg.add_nameval_elmt('MSID'                  ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('IG_ORDER_TYPE'         ,'RF'                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('EVENTOBJID'            ,n_queue_event_log_seq ,nameval);
  sa.queue_pkg.add_nameval_elmt('PIN'                   ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('CHANNEL_ID'            ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('DEAL_NAME'             ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('CALL_TRANS_ACTION_TEXT',NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('OLD_MIN'               ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('BRM_REACT_FLAG'        ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('SERVICE_DAYS_REMAINING',NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('LL_ENROLLMENT_FLAG'    ,NULL                  ,nameval); --Added for CR49915 Lifeline
  sa.queue_pkg.add_nameval_elmt('AFFILIATED_PARTNER'    ,NULL                  ,nameval); --Added for CR48260_MLD SM
  -- Framing the payload to enqueue
  payload := sa.q_payload_t('REFURBISH'    ,-- source_type
                            'REFURBISH'    ,-- source_tbl
                            'COMPLETE'     ,-- source_status
                            i_esn          ,-- esn
                            c.min          ,-- min
                            c.bus_org_id   ,-- brand
                            c_event_name   ,-- event_name
                            nameval        ,-- varray
                            'INIT'         -- step_complete
                            );
   --Call procedure to insert record into x_queue_event_log table
  BEGIN
    insert_queue_event_log ( i_queue_event_log_objid  => n_queue_event_log_seq ,
                             i_esn                    => i_esn                 ,
                             i_event_name             => c_event_name          ,
                             i_min                    => c.min                 ,
                             i_bus_org_id             => c.bus_org_id          ,
                             i_priority               => n_message_priority    ,
                             i_queue_event_log_status => 'N'                   ,
                             i_seconds_delay          => n_seconds_delay       ,
                             i_enqueue_output_msg     => enq_msg               ,
                             i_enqueue_timestamp      => SYSDATE               ,
                             i_dequeue_timestamp      => SYSDATE               ,
                             i_insert_timestamp       => SYSDATE               ,
                             i_update_timestamp       => SYSDATE               ,
                             i_payload                => payload               ,
                             i_ig_order_type          =>'RF'                   ,
                             o_response               => o_response            );
  END;

  --  Enqueue transactions to MAIN AQ for the above mentioned payload
  IF NOT sa.queue_pkg.enq ( i_q_name     => 'SA.CLFY_MAIN_Q'   ,
                            io_q_payload => payload            ,
                            o_op_msg     => enq_msg            ,
                            ip_delay     => n_seconds_delay    , -- delay in seconds (before available for dequeue)
                            ip_priority  => n_message_priority )
  THEN
    -- Updating to 'E' if any error occurred while enqueue
    UPDATE x_queue_event_log
    SET    queue_event_log_status = 'E',
           enqueue_output_message = enq_msg
    WHERE  objid = n_queue_event_log_seq;
  END IF;

  -- Updating to 'Q' on successful enqueue
  UPDATE x_queue_event_log
  SET    queue_event_log_status = 'Q',
         enqueue_output_message = enq_msg
  WHERE  objid = n_queue_event_log_seq;

  -- set response
  o_response := 'SUCCESS';
  --
 EXCEPTION
   WHEN OTHERS THEN
     o_response := 'ERROR WHILE ENQUEUING REFURBISH TRANSACTION: ' ||SQLERRM;

END enqueue_refurbish_transaction;

-- Procedure to AQ LifeLine enrollments to BRM
-- Lifeline for Other Brands - WFM. CR49915
-- mdave 06/03/2017
PROCEDURE enqueue_lifeline_enrollments(i_esn                 IN  VARCHAR2,
                                       i_min                 IN  VARCHAR2,
                                       i_enrollment_status   IN  VARCHAR2,
                                       o_response            OUT VARCHAR2
                                       )
AS
-- Local variables
  payload                 sa.q_payload_t                              ;
  nameval                 sa.q_nameval_tab       := sa.q_nameval_tab();
  enq_msg                 VARCHAR2(1000)                              ;
  n_queue_event_log_seq   NUMBER                                      ;
  n_seconds_delay         NUMBER                 := 0                 ;
  n_message_priority      NUMBER                 := 1                 ;
  c_event_name            VARCHAR2(100)          := 'LL_ENROLLMENT'   ;
  c_action_type	  		  VARCHAR2(100)          := 'LLE'    		  ;
  c_action_text	  		  VARCHAR2(100)          					  ;
  c_ll_order_type  		  VARCHAR2(10)           := 'LLE'			  ; -- Agreed value with POJO
  cst                     sa.customer_type       := sa.customer_type();
  c                       sa.customer_type       := sa.customer_type();
  l_enrollment_status     VARCHAR2(10)								  ;

BEGIN -- Main Section

  -- get the web user attributes
  cst := customer_type ( i_esn => i_esn );
  c   := cst.get_web_user_attributes;

  -- validate if the brand applies to be sent to BRM
  IF NVL(cst.get_brm_notification_flag ( i_bus_org_objid => c.bus_org_objid),'N') = 'N' OR
     sa.customer_info.get_brm_notification_flag ( i_esn => i_esn ) = 'N'
  THEN
    o_response := 'BRAND NOT APPLICABLE FOR BRM';
    RETURN;
  END IF;

  -- Generating sequence
  SELECT seq_queue_event_log.NEXTVAL
  INTO   n_queue_event_log_seq
  FROM   DUAL;

  -- set enrollment flag based on the status received
  IF UPPER(i_enrollment_status) = 'ENROLLED' THEN
		l_enrollment_status := 'Y';
		c_action_text := 'LL_ENROLLED';
  ELSIF UPPER(i_enrollment_status) = 'DEENROLLED' THEN
		l_enrollment_status := 'N';
		c_action_text := 'LL_DEENROLLED';
  ELSE
		l_enrollment_status := NULL;
  END IF;

  -- Assigning values to name value element
  sa.queue_pkg.add_nameval_elmt('WEBOBJID'              ,c.web_user_objid      ,nameval);
  sa.queue_pkg.add_nameval_elmt('ESNPARTINSTOBJID'      ,c.esn_part_inst_objid ,nameval);
  sa.queue_pkg.add_nameval_elmt('CALL_TRANS_REASON'     ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('MIN'                   ,i_min                 ,nameval);
  sa.queue_pkg.add_nameval_elmt('MSID'                  ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('IG_ORDER_TYPE'         ,c_ll_order_type       ,nameval);
  sa.queue_pkg.add_nameval_elmt('EVENTOBJID'            ,n_queue_event_log_seq ,nameval);
  sa.queue_pkg.add_nameval_elmt('PIN'                   ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('CHANNEL_ID'            ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('DEAL_NAME'             ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('CALL_TRANS_ACTION_TEXT',NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('OLD_MIN'               ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('BRM_REACT_FLAG'        ,NULL                  ,nameval);
  sa.queue_pkg.add_nameval_elmt('SERVICE_DAYS_REMAINING',NULL                  ,nameval);
--addition to existing elements for LiefeLine for others - WFM CR49915 mdave, 06/03/2017
-- To ensure POJO processes the payload, all the payloads in this package should have same number of elements.
  sa.queue_pkg.add_nameval_elmt('LL_ENROLLMENT_FLAG'    ,l_enrollment_status   ,nameval);
  sa.queue_pkg.add_nameval_elmt('AFFILIATED_PARTNER'    ,NULL                  ,nameval); --Added for CR48260_MLD SM

  -- Framing the payload to enqueue
  payload := sa.q_payload_t('LL_SUBSCRIBERS',-- source_type
                            'LL_SUBSCRIBERS',-- source_tbl
                            'COMPLETE'     ,-- source_status
                            i_esn          ,-- esn
                            i_min          ,-- min
                            c.bus_org_id   ,-- brand
                            c_event_name   ,-- event_name
                            nameval        ,-- varray
                            'INIT'         -- step_complete
                            );
   --Call procedure to insert record into x_queue_event_log table
  BEGIN
    insert_queue_event_log ( i_queue_event_log_objid  => n_queue_event_log_seq ,
                             i_esn                    => i_esn                 ,
                             i_event_name             => c_event_name          ,
                             i_min                    => i_min                 ,
							 i_action_type            => c_action_type         ,
							 i_action_text            => c_action_text         ,
                             i_bus_org_id             => c.bus_org_id          ,
                             i_priority               => n_message_priority    ,
                             i_queue_event_log_status => 'N'                   ,
                             i_seconds_delay          => n_seconds_delay       ,
                             i_enqueue_output_msg     => enq_msg               ,
                             i_enqueue_timestamp      => SYSDATE               ,
                             i_dequeue_timestamp      => SYSDATE               ,
                             i_insert_timestamp       => SYSDATE               ,
                             i_update_timestamp       => SYSDATE               ,
                             i_payload                => payload               ,
                             o_response               => o_response            );
  END;

  --  Enqueue Lifeline enrollment/deenrollment to MAIN AQ for the above mentioned payload ( agreed with Intergate to use same Queue as WFM)
  IF NOT sa.queue_pkg.enq ( i_q_name     => 'SA.CLFY_MAIN_Q'   ,
                            io_q_payload => payload            ,
                            o_op_msg     => enq_msg            ,
                            ip_delay     => n_seconds_delay    , -- delay in seconds (before available for dequeue)
                            ip_priority  => n_message_priority )
  THEN
    -- Updating to 'E' if any error occurred while enqueue
    UPDATE x_queue_event_log
    SET    queue_event_log_status = 'E',
           enqueue_output_message = enq_msg
    WHERE  objid = n_queue_event_log_seq;
  END IF;

  -- Updating to 'Q' on successful enqueue
  UPDATE x_queue_event_log
  SET    queue_event_log_status = 'Q',
         enqueue_output_message = enq_msg
  WHERE  objid = n_queue_event_log_seq;

  --Commit changes
  COMMIT;

  -- set response
  o_response := 'SUCCESS';
  --
 EXCEPTION
   WHEN OTHERS THEN
     o_response := 'ERROR WHILE ENQUEUING LIFELINE ENROLLMENT TRANSACTION: ' ||SQLERRM;
END enqueue_lifeline_enrollments;
--
--CR48260_MultiLine Discount on SM - New proc to enquue Affiliated partner
PROCEDURE sp_notify_affpart_discount_BRM   (i_web_user_objid       IN    NUMBER   ,
                                            i_login_name           IN    VARCHAR2 ,
                                            i_bus_org_id           IN    VARCHAR2 ,
                                            i_web_user2contact	   IN	 NUMBER   ,
                                            o_response             OUT   VARCHAR2)

IS
 CURSOR  affiliated_partners
 IS
     SELECT aff.brm_discount_name , emp.rowid rid
     FROM   sa.table_x_employee_discount emp,
            sa.table_affiliated_partners aff
     WHERE  1=1
     and    emp. partner_name              = aff.partner_name
     and    emp.brand                      = aff.brand
     and    emp.login_name                 = lower(i_login_name)
     and    emp.brand                      = i_bus_org_id
     and    emp.partner_type               = 'AFFILIATED'
     and    NVL(emp.brm_notified_flag,'N') = 'N'
     and    ROWNUM                         = 1 ;
 affiliated_partners_rec affiliated_partners%ROWTYPE;

 CURSOR get_esn_info_cur
 IS
  SELECT esn.part_serial_no esn ,
         esn.objid partinst_objid,
         line.part_serial_no min
  FROM table_part_inst esn,
    table_part_inst line,
    table_x_contact_part_inst cpi
  WHERE 1                             = 1
  AND esn.objid                       = cpi.x_contact_part_inst2part_inst
  AND cpi.x_contact_part_inst2contact =  i_web_user2contact
  AND esn.x_domain                    = 'PHONES'
  AND line.part_to_esn2part_inst      = esn.objid
  AND line.x_domain                   = 'LINES'
  AND line.part_serial_no NOT LIKE 'T%'
  ORDER BY (CASE WHEN esn.x_part_inst_status = '52' THEN 1
                 ELSE 2
            END
           );
 get_esn_info_rec get_esn_info_cur%ROWTYPE;

 nameval          sa.q_nameval_tab :=  sa.q_nameval_tab ();

BEGIN
   --Check if EMAIL is Registered for affiliated partner disc and not notified BRM
   OPEN affiliated_partners ;
   FETCH affiliated_partners INTO affiliated_partners_rec;
   IF  affiliated_partners%NOTFOUND THEN
      o_response := 'EMAIL IS EITHER NOT REGISTERED OR ALREADY NOTIFIED TO BRM' ;
      CLOSE affiliated_partners;
      RETURN;
   END IF;
   CLOSE affiliated_partners;

   --EMail is eligible for discount, so Get min details to enqueue transaction
   OPEN get_esn_info_cur;
   FETCH   get_esn_info_cur INTO get_esn_info_rec;
   IF  get_esn_info_cur%NOTFOUND THEN
       o_response := 'NO MIN IN THIS ACCOUNT' ;
       CLOSE get_esn_info_cur;
       RETURN;
   END IF;
   CLOSE get_esn_info_cur;

   -- Assigning values to name value element
   sa.queue_pkg.add_nameval_elmt('WEBOBJID'              ,i_web_user_objid                          ,nameval);
   sa.queue_pkg.add_nameval_elmt('ESNPARTINSTOBJID'      ,get_esn_info_rec.partinst_objid           ,nameval);
   sa.queue_pkg.add_nameval_elmt('MIN'                   ,get_esn_info_rec.min                      ,nameval);
   sa.queue_pkg.add_nameval_elmt('MSID'                  ,get_esn_info_rec.min                      ,nameval);
   sa.queue_pkg.add_nameval_elmt('IG_ORDER_TYPE'         ,'EP'                                      , nameval);
   sa.queue_pkg.add_nameval_elmt('AFFILIATED_PARTNER'    ,affiliated_partners_rec.brm_discount_name ,nameval);


   --Call enqueue_generic_transaction to notify BRM
   enqueue_transactions_pkg.enqueue_generic_transaction
   (
         i_source_type          => 'EMP_DISC_ENROLLMENT'     ,
         i_source_tbl           => 'EMP_DISC_ENROLLMENT'     ,
         i_source_status        => 'COMPLETE'                ,
         i_esn                  => get_esn_info_rec.esn      ,
         i_min                  => get_esn_info_rec.min      ,
         i_bus_org_id           => i_bus_org_id              ,
         i_event_name           => 'EMPLOYEE_DISCOUNT'       ,
         i_nameval              => nameval                   ,
         i_step                 => 'INIT'                    ,
         i_action_type          => 'ENROLL_AFF_PARTNER'      ,
         i_action_text          => 'ENROLL_AFF_PARTNER'      ,
         o_response             => o_response
    );
   --update table_x_employee_discount to flag BRM is notified
   IF o_response LIKE '%SUCCESS%' THEN
     UPDATE sa.table_x_employee_discount
        SET brm_notified_flag ='Y'
      WHERE rowid=affiliated_partners_rec.rid;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    o_response := 'ERROR - SQLERRM : '||substr (SQLERRM,500);
    RETURN ;
END sp_notify_affpart_discount_BRM;

--CR48260_MultiLine Discount on SM - New generic proc to enqueue transaction
PROCEDURE enqueue_generic_transaction (i_source_type         IN  VARCHAR2,
                                       i_source_tbl          IN  VARCHAR2,
                                       i_source_status       IN  VARCHAR2,
                                       i_esn                 IN  VARCHAR2 DEFAULT NULL,
                                       i_min                 IN  VARCHAR2 DEFAULT NULL,
                                       i_bus_org_id          IN  VARCHAR2,
                                       i_event_name          IN  VARCHAR2,
                                       i_nameval             IN  sa.q_nameval_tab,
                                       i_step                IN  VARCHAR2,
                                       i_action_type         IN  VARCHAR2,
                                       i_action_text         IN  VARCHAR2,
                                       o_response            OUT VARCHAR2
                                       )
AS
-- Local variables
  payload                    sa.q_payload_t                                ;
  nameval                    sa.q_nameval_tab         := sa.q_nameval_tab();
  enq_msg                    VARCHAR2(1000)                                ;
  n_queue_event_log_seq      NUMBER                                        ;
  n_seconds_delay            NUMBER                   := 0                 ;
  n_message_priority         NUMBER                   := 1                 ;
  l_webobjid                 NUMBER                   := NULL              ;
  l_esnpartinstobjid         NUMBER                   := NULL              ;
  l_call_trans_reason        VARCHAR2(250)            := NULL              ;
  l_min                      VARCHAR2(50)             := NULL              ;
  l_msid                     VARCHAR2(50)             := NULL              ;
  l_ig_order_type            VARCHAR2(50)             := NULL              ;
  l_eventobjid               NUMBER                   := NULL              ;
  l_pin                      VARCHAR2(50)             := NULL              ;
  l_channel_id               VARCHAR2(50)             := NULL              ;
  l_deal_name                VARCHAR2(50)             := NULL              ;
  l_call_trans_action_text   VARCHAR2(250)            := NULL              ;
  l_old_min                  VARCHAR2(50)             := NULL              ;
  l_brm_react_flag           VARCHAR2(50)             := NULL              ;
  l_service_days_remaining   VARCHAR2(50)             := NULL              ;
  l_ll_enrollment_flag       VARCHAR2(50)             := NULL              ;
  l_affiliated_partner       VARCHAR2(50)             := NULL              ;
  l_bus_org_objid            NUMBER                   := NULL              ;

BEGIN -- Main Section

  IF i_nameval IS NULL THEN
    o_response := 'INPUT KEY VALUE PAIR TAB IS NULL';
    RETURN;
  END IF;

  l_bus_org_objid := sa.customer_info.get_bus_org_objid ( i_bus_org_id =>i_bus_org_id  );

  -- validate if the brand applies to be sent to BRM
  IF NVL(sa.customer_info.get_brm_notification_flag ( i_bus_org_objid  => l_bus_org_objid),'N') = 'N' OR
     sa.customer_info.get_brm_notification_flag ( i_esn => i_esn ) = 'N'
  THEN
    o_response := 'BRAND NOT APPLICABLE FOR BRM';
    RETURN;
  END IF;

  FOR i in 1 .. i_nameval.COUNT
  LOOP
      IF i_nameval(i).FLD    =  'WEBOBJID'               THEN
         l_webobjid              := i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'ESNPARTINSTOBJID'       THEN
	     l_esnpartinstobjid      := i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'CALL_TRANS_REASON'      THEN
         l_call_trans_reason     := i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'MIN'                    THEN
         l_min                   := i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'MSID'                   THEN
         l_msid	                 := i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'IG_ORDER_TYPE'          THEN
         l_ig_order_type         := i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'EVENTOBJID'             THEN
         l_eventobjid	         := i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'PIN'                    THEN
         l_pin                   := i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'CHANNEL_ID'             THEN
         l_channel_id            := i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'DEAL_NAME'              THEN
         l_deal_name	         := i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'CALL_TRANS_ACTION_TEXT' THEN
         l_call_trans_action_text:= i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'OLD_MIN'                THEN
         l_old_min               := i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'BRM_REACT_FLAG'         THEN
         l_brm_react_flag        := i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'SERVICE_DAYS_REMAINING' THEN
	     l_service_days_remaining:= i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'LL_ENROLLMENT_FLAG'     THEN
         l_ll_enrollment_flag    := i_nameval(i).VAL;
      ELSIF i_nameval(i).FLD =  'AFFILIATED_PARTNER'     THEN
         l_affiliated_partner    := i_nameval(i).VAL;
      END IF;
  END LOOP;

  -- Generating sequence
  SELECT seq_queue_event_log.NEXTVAL
  INTO   n_queue_event_log_seq
  FROM   DUAL;
  l_eventobjid := n_queue_event_log_seq;

   -- Assigning values to name value element
  sa.queue_pkg.add_nameval_elmt('WEBOBJID'              ,l_webobjid               ,nameval);
  sa.queue_pkg.add_nameval_elmt('ESNPARTINSTOBJID'      ,l_esnpartinstobjid       ,nameval);
  sa.queue_pkg.add_nameval_elmt('CALL_TRANS_REASON'     ,l_call_trans_reason      ,nameval);
  sa.queue_pkg.add_nameval_elmt('MIN'                   ,NVL(l_min,i_min)         ,nameval);
  sa.queue_pkg.add_nameval_elmt('MSID'                  ,l_msid                   ,nameval);
  sa.queue_pkg.add_nameval_elmt('IG_ORDER_TYPE'         ,l_ig_order_type          ,nameval);
  sa.queue_pkg.add_nameval_elmt('EVENTOBJID'            ,l_eventobjid             ,nameval);
  sa.queue_pkg.add_nameval_elmt('PIN'                   ,l_pin                    ,nameval);
  sa.queue_pkg.add_nameval_elmt('CHANNEL_ID'            ,l_channel_id             ,nameval);
  sa.queue_pkg.add_nameval_elmt('DEAL_NAME'             ,l_deal_name              ,nameval);
  sa.queue_pkg.add_nameval_elmt('CALL_TRANS_ACTION_TEXT',l_call_trans_action_text ,nameval);
  sa.queue_pkg.add_nameval_elmt('OLD_MIN'               ,l_old_min                ,nameval);
  sa.queue_pkg.add_nameval_elmt('BRM_REACT_FLAG'        ,l_brm_react_flag         ,nameval);
  sa.queue_pkg.add_nameval_elmt('SERVICE_DAYS_REMAINING',l_service_days_remaining ,nameval);
  sa.queue_pkg.add_nameval_elmt('LL_ENROLLMENT_FLAG'    ,l_ll_enrollment_flag     ,nameval);
  sa.queue_pkg.add_nameval_elmt('AFFILIATED_PARTNER'    ,l_affiliated_partner     ,nameval);

  -- Framing the payload to enqueue
  payload := sa.q_payload_t(i_source_type    ,-- source_type
                            i_source_tbl     ,-- source_tbl
                            i_source_status  ,-- source_status
                            i_esn            ,-- esn
                            i_min            ,-- min
                            i_bus_org_id     ,-- brand
                            i_event_name     ,-- event_name
                            nameval          ,-- varray
                            i_step            -- step_complete
                            );
   --Call procedure to insert record into x_queue_event_log table
    insert_queue_event_log ( i_queue_event_log_objid  => n_queue_event_log_seq ,
                             i_esn                    => i_esn                 ,
                             i_event_name             => i_event_name          ,
                             i_min                    => i_min                 ,
                             i_action_type            => i_action_type         ,
                             i_action_text            => i_action_text         ,
                             i_bus_org_id             => i_bus_org_id          ,
                             i_priority               => n_message_priority    ,
                             i_queue_event_log_status => 'N'                   ,
                             i_seconds_delay          => n_seconds_delay       ,
                             i_enqueue_output_msg     => enq_msg               ,
                             i_enqueue_timestamp      => SYSDATE               ,
                             i_dequeue_timestamp      => SYSDATE               ,
                             i_insert_timestamp       => SYSDATE               ,
                             i_update_timestamp       => SYSDATE               ,
                             i_payload                => payload               ,
                             o_response               => o_response            );
  --  Enqueue to MAIN AQ for the above mentioned payload
  IF NOT sa.queue_pkg.enq ( i_q_name     => 'SA.CLFY_MAIN_Q'   ,
                            io_q_payload => payload            ,
                            o_op_msg     => enq_msg            ,
                            ip_delay     => n_seconds_delay    , -- delay in seconds (before available for dequeue)
                            ip_priority  => n_message_priority )
  THEN
    -- Updating to 'E' if any error occurred while enqueue
    UPDATE x_queue_event_log
    SET    queue_event_log_status = 'E',
           enqueue_output_message = enq_msg
    WHERE  objid = n_queue_event_log_seq;
    o_response := 'ERROR WHILE ENQUEUE :' || enq_msg;
  ELSE
    UPDATE x_queue_event_log
    SET    queue_event_log_status = 'Q',
           enqueue_output_message = enq_msg
    WHERE  objid = n_queue_event_log_seq;
    o_response := 'SUCCESS';
  END IF;

 EXCEPTION
   WHEN OTHERS THEN
     o_response := 'ERROR WHILE ENQUEUING GENERIC TRANSACTION: ' ||SQLERRM;
END enqueue_generic_transaction;

END enqueue_transactions_pkg;
/