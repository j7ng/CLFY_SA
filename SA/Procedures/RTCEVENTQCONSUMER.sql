CREATE OR REPLACE PROCEDURE sa."RTCEVENTQCONSUMER" (i_max_dequeue_exec  IN NUMBER   DEFAULT 1000,
                                                  i_queue_subscriber  IN VARCHAR2 DEFAULT 'RTCSUBSCRIBER') IS
--------------------------------------------------------------------------------------------
--$RCSfile: rtceventqconsumer.sql,v $
--$Revision: 1.12 $
--$Author: oimana $
--$Date: 2018/02/05 20:03:25 $
--$ $Log: rtceventqconsumer.sql,v $
--$ Revision 1.12  2018/02/05 20:03:25  oimana
--$ CR54384 - PostDeployment Update
--$
--$ Revision 1.0  2017/09/29 15:24:10  akhan
--------------------------------------------------------------------------------------------
  --
  v_key_value        VARCHAR2(1000);
  v_msg_string       VARCHAR2(2400) := NULL;
  v_case_id          VARCHAR2(30);
  v_sourcesystem     VARCHAR2(30);
  v_plan_minutes     VARCHAR2(50);
  v_plan_data        VARCHAR2(50);
  v_service_days     NUMBER;
  v_priority         NUMBER;
  v_crt_count        NUMBER := 0;
  v_delay            NUMBER := 30;
  v_rtc_queued       NUMBER := 0;
  v_org_objid        NUMBER;
  v_rtc_flag         VARCHAR2(1);
  v_queue_act_flag   VARCHAR2(1);
  v_already_sent     VARCHAR2(1);
  v_consumer_name    VARCHAR2(240);
  v_udf1             VARCHAR2(240);
  v_udf2             VARCHAR2(240);
  v_udf3             VARCHAR2(240);
  v_udf4             VARCHAR2(240);
  v_udf5             VARCHAR2(240);
  v_udf6             VARCHAR2(240);
  v_udf7             VARCHAR2(240);
  v_udf8             VARCHAR2(240);
  v_udf9             VARCHAR2(240);
  --
  out_err_num        NUMBER;
  out_err_msg        VARCHAR2(2400);
  out_xml_payload    VARCHAR2(32000) := NULL;
  out_queryctx       DBMS_XMLGEN.ctxhandle;
  out_xml            XMLTYPE;
  --
  esn_attr           sa.customer_type := sa.customer_type();
  --
  q_payload_msg      sa.q_payload_t;
  CLFY_queue_name    VARCHAR2(30);
  --
  RTC_queue_name     VARCHAR2(30);
  RTC_msg_prop       DBMS_AQ.message_properties_t;
  RTC_enq_opt        DBMS_AQ.enqueue_options_t;
  RTC_enq_msgid      RAW(16);
  RTC_payload        XMLTYPE;
  --
  PROCEDURE clfy_dequeue (i_queue_name   IN  VARCHAR2,
                          i_consumer     IN  VARCHAR2,
                          o_payload_msg  OUT q_payload_t,
                          o_deq_msg      OUT VARCHAR2) IS

  CLFY_msg_prop      DBMS_AQ.message_properties_t;
  CLFY_deq_opt       DBMS_AQ.dequeue_options_t;
  CLFY_msg_handle    RAW(16);
  no_messages        EXCEPTION;
  PRAGMA             EXCEPTION_INIT (no_messages, -25228);

  BEGIN

     o_deq_msg := 'SUCCESS';

     CLFY_deq_opt.dequeue_mode   := DBMS_AQ.remove;
     CLFY_deq_opt.wait           := DBMS_AQ.no_wait;
     CLFY_deq_opt.visibility     := DBMS_AQ.on_commit;
     CLFY_deq_opt.delivery_mode  := DBMS_AQ.persistent;
     CLFY_deq_opt.navigation     := DBMS_AQ.first_message;
     CLFY_deq_opt.consumer_name  := i_consumer;

     DBMS_AQ.dequeue (queue_name          => i_queue_name,
                      dequeue_options     => CLFY_deq_opt,
                      message_properties  => CLFY_msg_prop,
                      payload             => o_payload_msg,
                      msgid               => CLFY_msg_handle);

     COMMIT;

  EXCEPTION
    WHEN no_messages THEN
      DBMS_OUTPUT.PUT_LINE ('No more messages for '||i_queue_name||'.'||i_consumer||' queue.subscriber'||' - '||o_deq_msg);
      COMMIT;
    WHEN OTHERS THEN
      o_deq_msg := 'ERROR - While running DBMS_AQ.dequeue - '||SQLERRM;
      DBMS_OUTPUT.PUT_LINE (o_deq_msg);
      COMMIT;
  END;
  --
  PROCEDURE insert_rtc_log (i_esn         IN VARCHAR2,
                            i_min         IN VARCHAR2,
                            i_brand       IN VARCHAR2,
                            i_event_name  IN VARCHAR2,
                            i_created_by  IN VARCHAR2) IS

  PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    INSERT INTO sa.q_payload_log (esn,
                                  min,
                                  brand,
                                  event_name,
                                  created_by)
                          VALUES (i_esn,
                                  i_min,
                                  i_brand,
                                  i_event_name,
                                  i_created_by);

    COMMIT;

  EXCEPTION
    WHEN others THEN
      ROLLBACK;
  END;
  --
BEGIN
  --
  v_consumer_name := NVL(i_queue_subscriber,'RTCSUBSCRIBER');
  CLFY_queue_name := 'SA.CLFY_EVENT_Q';
  RTC_queue_name  := 'SA.CLFY_RTC_Q';
  --
  DBMS_OUTPUT.PUT_LINE ('Executing RTCEVENTQCONSUMERJOB process with values: '||i_max_dequeue_exec||' - '||v_consumer_name);
  --
  LOOP
    --
    BEGIN

       q_payload_msg := NULL;

       clfy_dequeue (CLFY_queue_name,
                     v_consumer_name,
                     q_payload_msg,
                     out_err_msg);

       IF NVL(out_err_msg,'NULL') <> 'SUCCESS' THEN

         UTIL_PKG.insert_error_tab ('Not reading queue: CLFY_EVENT_Q',
                                    q_payload_msg.esn,
                                    'rtceventqconsumer',
                                    out_err_msg);

         DBMS_OUTPUT.PUT_LINE ('ERROR - Dequeue process from SA.CLFY_EVENT_Q failed - '||out_err_msg);
         DBMS_OUTPUT.PUT_LINE ('WARNING - Exiting LOOP process and program');

         EXIT;   --Do not use CONTINUE because the exception issue from dequeue is unknown and process may loop forever.

       END IF;

    END;
    --
    IF (q_payload_msg IS NULL) THEN
      DBMS_OUTPUT.PUT_LINE ('WARNING - Queue SA.CLFY_EVENT_Q is empty for subscriber '||v_consumer_name||' - Exiting LOOP process');
      EXIT;
    END IF;
    --
    DBMS_OUTPUT.PUT_LINE ('Dequeued message from SA.CLFY_EVENT_Q for consumer: '||v_consumer_name||' - '||out_err_msg);
    --
    out_err_num := 0;
    out_err_msg := NULL;
    --
    BEGIN
      SELECT NVL(clfy_rtc_queue_flag,'N'),
             objid
        INTO v_rtc_flag,
             v_org_objid
        FROM sa.table_bus_org
       WHERE org_id = q_payload_msg.brand;
    EXCEPTION
      WHEN OTHERS THEN
        v_rtc_flag  := 'N';
        v_org_objid := NULL;
    END;
    --
    -- CR54384 PosProduction release update to remove consumer RTCREWARDBENEFIT and eliminate callback PLSQL setup//OImana//020518
    -- CR54384 - Set the event to REWARD_BENEFIT because true, brand and CT redemption meet RTC LRP criteria
    IF (q_payload_msg.brand = 'STRAIGHT_TALK') AND (q_payload_msg.event_name = 'REDEMPTION') THEN

      IF sa.RTC_PKG.is_cust_not_lrp_enrolled (q_payload_msg) THEN
        q_payload_msg.event_name := 'REWARD_BENEFIT';
      END IF;

    END IF;
    --
    DBMS_OUTPUT.PUT_LINE ('Processing Event: '||q_payload_msg.event_name||' for ESN: '||q_payload_msg.esn);
    --
    BEGIN
      SELECT NVL(queue_active_flag,'N')
        INTO v_queue_act_flag
        FROM sa.rtc_event re
       WHERE re.rtc_event = q_payload_msg.event_name
         AND EXISTS (SELECT NULL
                       FROM sa.rtc_criteria_values rcv
                      WHERE rcv.values2event = re.objid
                        AND sysdate BETWEEN NVL(rcv.start_date,sysdate)
                                        AND NVL(rcv.end_date,sysdate+1)
                        AND rcv.values2bus_org = v_org_objid);
    EXCEPTION
      WHEN OTHERS THEN
        v_queue_act_flag := 'N';
    END;
    --
    -- CR52234 - Send message only for brand and RTC criteria values setup flag v_rtc_flag are set to Y
    IF (v_rtc_flag = 'N') OR (v_queue_act_flag = 'N') THEN

      out_err_num  := 0;
      out_err_msg  := 'NO ACTION';

      DBMS_OUTPUT.PUT_LINE ('WARNING - Brand or Event do not qualify for RTC - <'||v_rtc_flag||'><'||v_queue_act_flag||'>');

      COMMIT;

      v_crt_count := v_crt_count + 1;

      IF v_crt_count > NVL(i_max_dequeue_exec,0) THEN
        EXIT;
      ELSE
        CONTINUE;
      END IF;

    END IF;
    --
    BEGIN
      SELECT 'Y'
        INTO v_already_sent
        FROM sa.q_payload_log qpa
       WHERE qpa.esn = q_payload_msg.esn
         AND qpa.min = q_payload_msg.min
         AND qpa.brand = q_payload_msg.brand
         AND qpa.event_name = q_payload_msg.event_name
         AND qpa.created_by = 'CLFY_RTC_Q_'||v_consumer_name
         AND qpa.creation_date BETWEEN (sysdate-0.01) AND sysdate
         AND ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        v_already_sent := 'N';
    END;
    --
    -- CR52234 - Send message only for events set for new process to avoid duplicate delivery of messages.
    -- CR52234 - Check if a previous message payload was sent for same ESN attributes within 15 seconds.
    IF (v_already_sent = 'Y') THEN

      out_err_num  := 0;
      out_err_msg  := 'NO ACTION';

      DBMS_OUTPUT.PUT_LINE ('WARNING - RTC Message has already been sent <'||v_already_sent||'>');

      COMMIT;

      v_crt_count := v_crt_count + 1;

      IF v_crt_count > NVL(i_max_dequeue_exec,0) THEN
        EXIT;
      ELSE
        CONTINUE;
      END IF;

    END IF;
    --
    esn_attr := esn_attr.retrieve (q_payload_msg.esn);
    --
    BEGIN
      --
      FOR i IN 1..q_payload_msg.nameval.COUNT LOOP

        IF q_payload_msg.nameval(i).fld = 'SOURCESYSTEM' THEN
          v_sourcesystem := q_payload_msg.nameval(i).val;    --Channel
        END IF;

      END LOOP;
      --
      BEGIN
        SELECT days service_days,
               voice plan_minutes,
               data plan_data
          INTO v_service_days,
               v_plan_minutes,
               v_plan_data
          FROM sa.service_plan_feat_pivot_mv
         WHERE service_plan_objid = esn_attr.service_plan_objid;
      EXCEPTION
        WHEN OTHERS THEN
          v_service_days := NULL;
          v_plan_minutes := NULL;
          v_plan_data    := NULL;
      END;
      --
      IF q_payload_msg.event_name IN('CASE_CREATION','CASE_SHIPMENT') THEN
        BEGIN
          SELECT MAX(id_number) case_id
            INTO v_case_id
            FROM sa.table_case
           WHERE x_esn = q_payload_msg.esn
             AND x_min = esn_attr.min;
        EXCEPTION
          WHEN OTHERS THEN
            v_case_id := NULL;
        END;
      END IF;
      --
      BEGIN
        SELECT DECODE (q_payload_msg.event_name,'REDEMPTION',TO_CHAR(esn_attr.expiration_date,'DD-MON-YYYY'),NULL),
               DECODE (q_payload_msg.event_name,'REDEMPTION',v_plan_data,NULL),
               DECODE (q_payload_msg.event_name,'REDEMPTION',v_service_days,NULL),
               DECODE (q_payload_msg.event_name,'REDEMPTION',v_plan_minutes,NULL),
               DECODE (q_payload_msg.event_name,'REDEMPTION',esn_attr.contact_objid,NULL),
               DECODE (q_payload_msg.event_name,'REDEMPTION',INITCAP(TRIM(esn_attr.contact_first_name)),NULL),
               DECODE (q_payload_msg.event_name,'REDEMPTION',INITCAP(TRIM(esn_attr.contact_last_name)),NULL),
               NULL,
               NULL
          INTO v_udf1,
               v_udf2,
               v_udf3,
               v_udf4,
               v_udf5,
               v_udf6,
               v_udf7,
               v_udf8,
               v_udf9
          FROM dual;
      EXCEPTION
        WHEN OTHERS THEN
          out_err_num  := SQLCODE;
          out_err_msg  := NVL(SQLERRM,out_err_msg);
          DBMS_OUTPUT.PUT_LINE('Error - Gathering UDF values - SQLERRM: '||out_err_msg);
          RAISE_APPLICATION_ERROR (-20002, out_err_msg);
      END;

      DBMS_OUTPUT.PUT_LINE ('Queue Input Values: '       ||
                            q_payload_msg.event_name     ||' - '||
                            q_payload_msg.esn            ||' - '||
                            esn_attr.min                 ||' - '||
                            q_payload_msg.brand          ||' - '||
                            esn_attr.contact_email       ||' - '||
                            esn_attr.language_preference ||' - '||
                            esn_attr.web_user_key        ||' - '||
                            esn_attr.non_ppe_flag        ||' - '||
                            v_case_id                    ||' - '||
                            v_sourcesystem               ||' - '||
                            esn_attr.bus_org_objid       ||' - '||
                            esn_attr.carrier_objid);

      -- CR52234 - Beging building the XML file contents
      out_xml_payload := '<?xml version="1.0" encoding="UTF-8"?>'||CHR(13);
      out_xml_payload := out_xml_payload ||'<RTC_CLFY_Event xmlns="http://www.tracfone.com/InboundService">'||CHR(13);
      -- CR52234 - Get the DBMS_XMLGEN.ctxhandle context from the ref cursor
      out_queryctx := DBMS_XMLGEN.newcontext ('SELECT SA.RTC_PKG.get_rtc_event_data (i_event              => :i_event,
                                                                                     i_esn                => :i_esn,
                                                                                     i_min                => :i_min,
                                                                                     i_bus_org_id         => :i_bus_org_id,
                                                                                     i_contact_email      => :i_contact_email,
                                                                                     i_language           => :i_language,
                                                                                     i_web_user_key       => :i_web_user_key,
                                                                                     i_non_ppe_flag       => :i_non_ppe_flag,
                                                                                     i_case_id            => :i_case_id,
                                                                                     i_sourcesystem       => :i_sourcesystem,
                                                                                     i_bus_org_objid      => :i_bus_org_objid,
                                                                                     i_carrier_id         => :i_carrier_id,
                                                                                     i_service_plan       => :i_service_plan,
                                                                                     i_udf1               => :i_udf1,
                                                                                     i_udf2               => :i_udf2,
                                                                                     i_udf3               => :i_udf3,
                                                                                     i_udf4               => :i_udf4,
                                                                                     i_udf5               => :i_udf5,
                                                                                     i_udf6               => :i_udf6,
                                                                                     i_udf7               => :i_udf7,
                                                                                     i_udf8               => :i_udf8,
                                                                                     i_udf9               => :i_udf9,
                                                                                     i_err_num            => :i_err_num,
                                                                                     i_err_msg            => :i_err_msg) RTC
                                                 FROM dual');

      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_event'           , q_payload_msg.event_name);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_esn'             , q_payload_msg.esn);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_min'             , q_payload_msg.min);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_bus_org_id'      , q_payload_msg.brand);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_contact_email'   , esn_attr.contact_email);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_language'        , esn_attr.language_preference);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_web_user_key'    , esn_attr.web_user_key);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_non_ppe_flag'    , esn_attr.non_ppe_flag);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_case_id'         , v_case_id);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_sourcesystem'    , v_sourcesystem);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_bus_org_objid'   , esn_attr.bus_org_objid);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_carrier_id'      , esn_attr.carrier_objid);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_service_plan'    , esn_attr.service_plan_name);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_udf1'            , v_udf1);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_udf2'            , v_udf2);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_udf3'            , v_udf3);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_udf4'            , v_udf4);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_udf5'            , v_udf5);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_udf6'            , v_udf6);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_udf7'            , v_udf7);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_udf8'            , v_udf8);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_udf9'            , v_udf9);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_err_num'         , out_err_num);
      DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_err_msg'         , out_err_msg);

      DBMS_XMLGEN.setRowTag (out_queryctx, NULL);

      DBMS_XMLGEN.setRowSetTag (out_queryctx, NULL);

      out_xml := DBMS_XMLGEN.getxmltype (out_queryctx);

      DBMS_XMLGEN.closeContext (out_queryctx);

      out_xml_payload := out_xml_payload || out_xml.getClobVal;

      out_xml_payload := out_xml_payload ||'</RTC_CLFY_Event>'||CHR(13);

    EXCEPTION
      WHEN OTHERS THEN
        -- CR52234 - Send message to SOA with error so it is known
        out_err_num     := SQLCODE;
        out_err_msg     := NVL(SQLERRM,out_err_msg);
        out_xml_payload := '<?xml version="1.0" encoding="UTF-8"?>'||CHR(13);
        out_xml_payload := out_xml_payload ||'<RTC_CLFY_Event xmlns="http://www.tracfone.com/InboundService">'||CHR(13);

        out_queryctx := DBMS_XMLGEN.NEWCONTEXT ('SELECT :i_sqlcode OUT_ERR_NUM,
                                                        :i_sqlerrm OUT_ERR_MSG
                                                   FROM DUAL');

        DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_sqlcode', out_err_num);
        DBMS_XMLGEN.setbindvalue (out_queryctx, 'i_sqlerrm', out_err_msg);
        DBMS_XMLGEN.setRowTag (out_queryctx, NULL);
        DBMS_XMLGEN.setRowSetTag (out_queryctx, NULL);
        out_xml := DBMS_XMLGEN.getxmltype (out_queryctx);
        DBMS_XMLGEN.closeContext (out_queryctx);
        out_xml_payload := out_xml_payload || out_xml.getClobVal;
        out_xml_payload := out_xml_payload ||'</RTC_CLFY_Event>'||CHR(13);

        UTIL_PKG.insert_error_tab ('Searching keys: SA.CLFY_RTC_Q',
                                   q_payload_msg.esn,
                                   'rtceventqconsumer',
                                   out_err_msg);

        DBMS_OUTPUT.PUT_LINE('Searching key Elements - SQLERRM: '||out_err_msg);
    END;
    --
    v_priority                    := NVL(sa.get_queue_priority (i_esn => q_payload_msg.esn),0);
    --
    RTC_payload                   := XMLTYPE(out_xml_payload);
    --
    RTC_enq_opt.visibility        := DBMS_AQ.ON_COMMIT;
    RTC_enq_opt.delivery_mode     := DBMS_AQ.PERSISTENT;
    --
    RTC_msg_prop.delivery_mode    := DBMS_AQ.PERSISTENT;
    RTC_msg_prop.priority         := v_priority;
    RTC_msg_prop.expiration       := 86400;
    RTC_msg_prop.delay            := v_delay;
    RTC_msg_prop.correlation      := 'CLFY_RTC_Q';

    DBMS_OUTPUT.PUT_LINE (XMLTYPE.getClobVal(RTC_payload));

    -- CR52234 - Calling queue SA.CLFY_RTC_Q with RTC payload message
    BEGIN
      DBMS_AQ.enqueue (queue_name         => RTC_queue_name,
                       enqueue_options    => RTC_enq_opt,
                       message_properties => RTC_msg_prop,
                       payload            => RTC_payload,
                       msgid              => RTC_enq_msgid);
    EXCEPTION
      WHEN OTHERS THEN
        out_err_num := SQLCODE;
        out_err_msg := SQLERRM;
        ROLLBACK;
        UTIL_PKG.insert_error_tab ('Sending queue: SA.CLFY_RTC_Q',
                                   q_payload_msg.esn,
                                   'rtceventqconsumer',
                                   out_err_msg);
        DBMS_OUTPUT.PUT_LINE ('ERROR - When queueing payload to SA.CLFY_RTC_Q: '||out_err_num||' - '||out_err_msg);
    END;

    COMMIT;

    v_rtc_queued := v_rtc_queued + 1;

    -- Logging messages
    BEGIN
      insert_rtc_log (i_esn        => q_payload_msg.esn,
                      i_min        => q_payload_msg.min,
                      i_brand      => q_payload_msg.brand,
                      i_event_name => q_payload_msg.event_name,
                      i_created_by => 'CLFY_RTC_Q_'||v_consumer_name);
    END;
    --
    -- CR54384 - PostProd release - DBA required change to control execution with specific number of iteration//Oimana.
    EXIT WHEN v_crt_count > NVL(i_max_dequeue_exec,0);
    --
  END LOOP;
  --
  DBMS_OUTPUT.PUT_LINE ('Number of payload messages queued to '||RTC_queue_name||': '||v_rtc_queued);
  --
EXCEPTION
  WHEN OTHERS THEN
    UTIL_PKG.insert_error_tab ('Main queue call: SA.CLFY_RTC_Q',
                               q_payload_msg.esn,
                               'rtceventqconsumer',
                               SQLERRM);
    DBMS_OUTPUT.PUT_LINE ('ERROR - Process in rtceventqconsumer Procedure Failed: '||out_err_num||' - '||out_err_msg);
END rtceventqconsumer;
/