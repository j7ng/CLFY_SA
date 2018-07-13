CREATE OR REPLACE PACKAGE BODY sa.rtc_pkg AS
--------------------------------------------------------------------------------
PROCEDURE is_rtc_enabled_for_esn (in_esn       IN   VARCHAR2,
                                  in_event     IN   VARCHAR2,
                                  in_bus_org   IN   VARCHAR2,
                                  in_language  IN   VARCHAR2,
                                  in_case_id   IN   NUMBER DEFAULT NULL,
                                  io_key_tbl   IN   OUT keys_tbl,
                                  out_err_num  OUT  NUMBER,
                                  out_err_msg  OUT  VARCHAR2)
IS

  l_key_name    sa.rtc_criteria.criteria_name%TYPE;
  l_key_value   sa.rtc_criteria_values.criteria_value%TYPE;
  l_key_tbl     keys_tbl := keys_tbl();

  CURSOR cur_event (in_event VARCHAR2)
  IS
    SELECT *
      FROM sa.rtc_event
     WHERE rtc_event = in_event
       AND rtc_comm_on = '1';

  event_rec cur_event%ROWTYPE;

  CURSOR cur_bus_org (in_bus_org VARCHAR2)
  IS
    SELECT objid
      FROM sa.table_bus_org
     WHERE org_id = in_bus_org;

  bus_org_rec cur_bus_org%ROWTYPE;

  CURSOR cur_criteria_values_by_sp (in_event VARCHAR2,
                                    l_key_name VARCHAR2,
                                    esn_sp_objid NUMBER)
  IS
    SELECT rcv.criteria_value
      FROM sa.rtc_criteria_values rcv,
           sa.rtc_criteria rc,
           sa.rtc_event re
     WHERE 1                              = 1
       AND UPPER(re.rtc_event)            = UPPER(in_event)
       AND UPPER(re.rtc_comm_on)          = '1'
       AND re.objid                       = rcv.values2event
       AND UPPER(rc.criteria_name)        = UPPER(l_key_name)
       AND rcv.values2criteria            = rc.objid
       AND rcv.values2serviceplan         = esn_sp_objid
       AND rcv.values2event               = re.objid
       AND NVL(rcv.start_date,sysdate)    <= SYSDATE  --CR41175
       AND NVL(rcv.end_date,sysdate+3000) >= SYSDATE; --CR41175

  criteria_values_by_sp_rec cur_criteria_values_by_sp%ROWTYPE;

  CURSOR cur_criteria_values_by_st (in_event VARCHAR2,
                                    l_key_name VARCHAR2)
  IS
    SELECT rcv.criteria_value
      FROM sa.rtc_criteria_values rcv,
           sa.rtc_criteria rc,
           sa.rtc_event re
     WHERE 1                              = 1
       AND UPPER(re.rtc_event)            = UPPER(in_event)
       AND UPPER(re.rtc_comm_on)          = '1'
       AND re.objid                       = rcv.values2event
       AND UPPER(rc.criteria_name)        = UPPER(l_key_name)
       AND rcv.values2criteria            = rc.objid
       AND rcv.values2event               = re.objid
       AND rcv.values2serviceplan         IS NULL
       AND NVL(rcv.start_date,sysdate)    <= SYSDATE    --CR41175
       AND NVL(rcv.end_date,sysdate+3000) >= SYSDATE;   --CR41175

  criteria_values_by_st_rec cur_criteria_values_by_st%ROWTYPE;

  CURSOR cur_criteria_values_by_bo (in_event VARCHAR2,
                                    l_key_name VARCHAR2,
                                    bus_org_objid NUMBER,
                                    in_language VARCHAR2)
  IS
    SELECT rcv.criteria_value
      FROM sa.rtc_criteria_values rcv,
           sa.rtc_criteria rc,
           sa.rtc_event re
     WHERE 1                               = 1
       AND UPPER(re.rtc_event)             = UPPER(in_event)
       AND UPPER(re.rtc_comm_on)           = '1'
       AND re.objid                        = rcv.values2event
       AND UPPER(rc.criteria_name)         = UPPER(l_key_name)
       AND rcv.values2criteria             = rc.objid
       AND rcv.values2bus_org              = bus_org_objid
       AND rcv.values2event                = re.objid
       AND NVL(rcv.x_language,in_language) = in_language --CR32782
       AND NVL(rcv.start_date,sysdate)     <= SYSDATE    --CR41175
       AND NVL(rcv.end_date,sysdate+3000)  >= SYSDATE;   --CR41175

  criteria_values_by_bo_rec cur_criteria_values_by_bo%ROWTYPE;

  --added for CR39624
  CURSOR cur_criteria_throttle (in_event VARCHAR2,
                                l_key_name VARCHAR2,
                                bus_org_objid NUMBER)
  IS
    SELECT rcv.criteria_value
      FROM sa.rtc_criteria_values rcv,
           sa.rtc_criteria rc,
           sa.rtc_event re
     WHERE 1                               = 1
       AND UPPER(re.rtc_event)             = UPPER(in_event)
       AND UPPER(re.rtc_comm_on)           = '1'
       AND re.objid                        = rcv.values2event
       AND UPPER(rc.criteria_name)         = UPPER(l_key_name)
       AND rcv.values2criteria             = rc.objid
       AND rcv.values2bus_org              = bus_org_objid
       AND rcv.values2event                = re.objid
       AND NVL(rcv.x_language,in_language) = in_language  --CR41175
       AND NVL(rcv.start_date,sysdate)     <= SYSDATE     --CR41175
       AND NVL(rcv.end_date,sysdate+3000)  >= SYSDATE;    --CR41175

  cur_criteria_throttle_rec cur_criteria_throttle%ROWTYPE;

  ---END CR39624
  CURSOR cur_count_channels (esn_sp_objid NUMBER)
  IS
    SELECT COUNT(rcv.criteria_value) count_cv
      FROM sa.rtc_criteria_values rcv,
           sa.rtc_criteria rc,
           sa.rtc_event re
     WHERE rc.criteria_name LIKE 'SEND%'
       AND rcv.criteria_value             = '1'
       AND rcv.values2criteria            = rc.objid
       AND rcv.values2serviceplan         = esn_sp_objid
       AND rcv.values2event               = re.objid
       AND NVL(rcv.start_date,sysdate)    <= SYSDATE  --CR41175
       AND NVL(rcv.end_date,sysdate+3000) >= SYSDATE; --CR41175

  count_channels      cur_count_channels%ROWTYPE;

  CURSOR cur_due_date (c_esn VARCHAR2)
  IS
    SELECT (MAX(x_new_due_date) || '') due_date
      FROM sa.table_x_call_trans
     WHERE x_service_id = c_esn;

  rec_due_date        cur_due_date%ROWTYPE;

  --Added for CR42764
  CURSOR cur_criteria_case (in_event VARCHAR2,
                            l_key_name VARCHAR2,
                            bus_org_objid NUMBER,
                            p_language VARCHAR2)
  IS
    SELECT rcv.criteria_value
      FROM sa.rtc_criteria_values rcv,
           sa.rtc_criteria rc,
           sa.rtc_event re
     WHERE 1                              = 1
       AND UPPER(re.rtc_event)            = UPPER(in_event)
       AND UPPER(re.rtc_comm_on)          = '1'
       AND re.objid                       = rcv.values2event
       AND UPPER(rc.criteria_name)        = UPPER(l_key_name)
       AND rcv.values2criteria            = rc.objid
       AND rcv.values2bus_org             = bus_org_objid
       AND rcv.values2event               = re.objid
       AND NVL(rcv.x_language,p_language) = p_language
       AND NVL(rcv.start_date,sysdate)    <= sysdate
       AND NVL(rcv.end_date,sysdate+3000) >= SYSDATE;

  cur_criteria_case_rec cur_criteria_case%ROWTYPE;

  --Added for CR42764
  CURSOR cur_shipping_info (p_case_id VARCHAR2)
  IS
    SELECT pr.x_courier,
           pr.x_tracking_no,
           c.alt_first_name||' '||c.alt_last_name||','||REPLACE(c.alt_address , '|', '')||','||c.alt_city||', '||c.alt_state ||', '||c.alt_zipcode address
      FROM sa.table_case c,
           sa.table_x_part_request pr
     WHERE pr.request2case = c.objid
       AND c.id_number = p_case_id;

   cur_shipping_info_rec cur_shipping_info%ROWTYPE;

  l_new_due_dt        VARCHAR2(100) := NULL;
  lv_email_domain     VARCHAR2(50);
  lv_dummy_email      VARCHAR2(3)   := 'NO';
  v_dummy_email_exist PLS_INTEGER   := 0;
  lv_language         VARCHAR2(10);
  rc                  sa.customer_type := sa.customer_type (); --added by CR41175
  esn_sp_rec          x_service_plan%ROWTYPE;
  v_case_id           table_case.id_number%TYPE;

BEGIN

  rc := rc.retrieve (in_esn);     --added by CR41175

  SELECT DECODE(in_language,'ENG','ENGLISH', 'SPA', 'SPANISH', in_language)
    INTO lv_language
    FROM dual;

  -- Scoping out Tracfone :
  IF in_bus_org IN ('TRACFONE') AND in_event NOT IN ('CASE_CREATION','CASE_SHIPMENT','FORGOT_PASSWORD') THEN   --Condition added for CR42764 -- FORGOT_PW condition added for CR46253
    out_err_num := 1;
    out_err_msg := 'RTC off for bus_org TRACFONE.';
    RETURN;
  END IF;
  --
  IF ((in_esn IS NULL AND in_event NOT IN ('ONLINE_ACCT_CREATION', 'FORGOT_PASSWORD')) OR in_event IS NULL OR in_bus_org IS NULL) THEN
    out_err_num := 1;
    out_err_msg := 'ESN, EVENT or BUS_ORG cannot be null.';
    RETURN;
  END IF;

  OPEN cur_event (in_event);
  FETCH cur_event INTO event_rec;

  IF cur_event%notfound THEN
    out_err_num := 1;
    out_err_msg := 'RTC off for event.';
    CLOSE cur_event;
    RETURN;
  END IF;

  l_key_tbl   := io_key_tbl;
  out_err_num := 0;
  out_err_msg := 'Success';

  OPEN cur_bus_org (in_bus_org);
  FETCH cur_bus_org INTO bus_org_rec;

  IF (in_esn IS NULL AND in_event = 'ONLINE_ACCT_CREATION') THEN

    IF (l_key_tbl.count > 0) THEN

      FOR i IN 1..l_key_tbl.COUNT LOOP

        l_key_name := l_key_tbl(i).key_type;

        IF l_key_name = 'SP_MKT_NAME' THEN

          l_key_tbl(i).key_value := NULL;

          SELECT NVL2(l_key_tbl(i).key_value,'Success','Failed')
            INTO l_key_tbl(i).result_value
            FROM dual;

        ELSE

          IF l_key_tbl(i).key_value IS NULL THEN

            BEGIN

              OPEN cur_criteria_values_by_bo (in_event, l_key_name, bus_org_rec.objid, LV_LANGUAGE);
                FETCH cur_criteria_values_by_bo INTO criteria_values_by_bo_rec;

                IF cur_criteria_values_by_bo%FOUND THEN
                 l_key_tbl(i).key_value := criteria_values_by_bo_rec.criteria_value;
                END IF;

              CLOSE cur_criteria_values_by_bo;

              SELECT NVL2(l_key_tbl(i).key_value ,'Success','Failed')
                INTO l_key_tbl(i).result_value
                FROM dual;

            EXCEPTION
              WHEN OTHERS THEN
                l_key_tbl(i).key_value := NULL;
            END;

          END IF;

        END IF;

      END LOOP;

      io_key_tbl := l_key_tbl;

    ELSE

      SELECT keys_obj (rc.criteria_name, rcv.criteria_value, NULL) BULK COLLECT
        INTO l_key_tbl
        FROM sa.rtc_criteria_values rcv,
             sa.rtc_criteria rc,
             sa.rtc_event re
       WHERE 1                              = 1
         AND UPPER(re.rtc_event)            = UPPER(in_event)
         AND UPPER(re.rtc_comm_on)          = '1'
         AND re.objid                       = rcv.values2event
         AND rcv.values2serviceplan         IS NULL
         AND rcv.values2criteria            = rc.objid
         AND rcv.values2bus_org             = bus_org_rec.objid
         AND rcv.values2event               = re.objid
         AND NVL(rcv.start_date,sysdate)    <= SYSDATE   --CR41175
         AND NVL(rcv.end_date,sysdate+3000) >= SYSDATE;  --CR41175

      FOR i IN 1..l_key_tbl.COUNT LOOP
        SELECT NVL2(l_key_tbl(i).key_value ,'Success','Failed')
          INTO l_key_tbl(i).result_value
          FROM dual;
      END LOOP;

      io_key_tbl := l_key_tbl;

    END IF;

    CLOSE cur_bus_org;
    ---FOR CR39624
  ELSIF in_event = 'THROTTLE' THEN

    IF (l_key_tbl.count > 0) THEN

      FOR i IN 1..l_key_tbl.COUNT LOOP

        l_key_name := l_key_tbl(i).key_type;

        DBMS_OUTPUT.PUT_LINE('1');

        IF l_key_name = 'SP_MKT_NAME' THEN

          l_key_tbl(i).key_value    := NULL;
          l_key_tbl(i).result_value := 'Success';

        ELSE

           BEGIN

             DBMS_OUTPUT.PUT_LINE('l_key_name  '||l_key_name  );

             cur_criteria_throttle_rec := NULL;

             OPEN cur_criteria_throttle (in_event, l_key_name, bus_org_rec.objid);
              FETCH cur_criteria_throttle INTO cur_criteria_throttle_rec;
             CLOSE cur_criteria_throttle;

             DBMS_OUTPUT.PUT_LINE('THROTTLE_VALUES:  '||l_key_name ||'==>' ||cur_criteria_throttle_rec.criteria_value);

               --for testing
             IF RC.NON_PPE_FLAG = 1 THEN

                  IF l_key_name            = 'SEND_SMS' THEN
                    l_key_tbl(i).key_value := cur_criteria_throttle_rec.criteria_value;
                  ELSIF l_key_name         = 'SEND_EMAIL' THEN
                    l_key_tbl(i).key_value := cur_criteria_throttle_rec.criteria_value;
                  ELSIF l_key_name         = 'SCRIPT_ID' THEN
                    l_key_tbl(i).key_value := NULL;
                  ELSIF l_key_name         = 'SHORT_CODE' THEN
                    l_key_tbl(i).key_value := cur_criteria_throttle_rec.criteria_value;
                  ELSIF l_key_name         = 'CAMPAIGN_CD' THEN
                    l_key_tbl(i).key_value := NULL;
                  ELSIF l_key_name         = 'SMS_TEXT_TEMPLATE' THEN
                    l_key_tbl(i).key_value := cur_criteria_throttle_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_CAMPAIGN_CD' THEN
                    l_key_tbl(i).key_value := cur_criteria_throttle_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_VENDOR_OBJID' THEN
                    l_key_tbl(i).key_value := cur_criteria_throttle_rec.criteria_value;
                  ELSIF l_key_name         = 'TRIGGER_ID' THEN
                    l_key_tbl(i).key_value := cur_criteria_throttle_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_PPE_TEXT' THEN
                    l_key_tbl(i).key_value := 'NO MESSAGE';
                  ELSIF l_key_name         = 'EMAIL_VENDOR_OBJID' THEN
                    l_key_tbl(i).key_value := NULL;
                  END IF;

              ELSIF RC.NON_PPE_FLAG       = 0 THEN

                  IF l_key_name            = 'SEND_SMS' THEN
                    l_key_tbl(i).key_value := cur_criteria_throttle_rec.criteria_value;
                  ELSIF l_key_name         = 'SEND_EMAIL' THEN
                    l_key_tbl(i).key_value := cur_criteria_throttle_rec.criteria_value;
                  ELSIF l_key_name         = 'SCRIPT_ID' THEN
                    l_key_tbl(i).key_value := NULL;
                  ELSIF l_key_name         = 'SHORT_CODE' THEN
                    l_key_tbl(i).key_value := cur_criteria_throttle_rec.criteria_value;
                  ELSIF l_key_name         = 'CAMPAIGN_CD' THEN
                    l_key_tbl(i).key_value := NULL;
                  ELSIF l_key_name         = 'SMS_TEXT_TEMPLATE' THEN
                    l_key_tbl(i).key_value := 'NO MESSAGE';
                  ELSIF l_key_name         = 'SMS_CAMPAIGN_CD' THEN
                    l_key_tbl(i).key_value := cur_criteria_throttle_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_VENDOR_OBJID' THEN
                    l_key_tbl(i).key_value := cur_criteria_throttle_rec.criteria_value;
                  ELSIF l_key_name         = 'TRIGGER_ID' THEN
                    l_key_tbl(i).key_value := cur_criteria_throttle_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_PPE_TEXT' THEN
                    l_key_tbl(i).key_value := cur_criteria_throttle_rec.criteria_value;
                  ELSIF l_key_name         = 'EMAIL_VENDOR_OBJID' THEN
                    l_key_tbl(i).key_value := NULL;
                  END IF;

              END IF;

              DBMS_OUTPUT.PUT_LINE('cursor Close');
              DBMS_OUTPUT.PUT_LINE('l_key_tbl(i).key_value456===>'||l_key_tbl(i).key_value);

              SELECT NVL2(l_key_tbl(i).key_value ,'Success','Failed')
                INTO l_key_tbl(i).result_value
                FROM dual;

          EXCEPTION
            WHEN OTHERS THEN
              l_key_tbl(i).key_value := NULL;
          END;

        END IF;

      END LOOP;

      io_key_tbl := l_key_tbl;

    ELSE

      SELECT keys_obj(rc.criteria_name, rcv.criteria_value, NULL) BULK COLLECT
        INTO l_key_tbl
        FROM sa.rtc_criteria_values rcv,
             sa.rtc_criteria rc,
             sa.rtc_event re
       WHERE 1                              = 1
         AND UPPER(re.rtc_event)            = UPPER(in_event)
         AND UPPER(re.rtc_comm_on)          = '1'
         AND re.objid                       = rcv.values2event
         AND rcv.values2serviceplan         IS NULL
         AND rcv.values2criteria            = rc.objid
         AND rcv.values2bus_org             = bus_org_rec.objid
         AND rcv.values2event               = re.objid
         AND NVL(rcv.start_date,sysdate)    <= SYSDATE   --CR41175
         AND NVL(rcv.end_date,sysdate+3000) >= SYSDATE;  --CR41175

      FOR i IN 1..l_key_tbl.COUNT LOOP
        SELECT NVL2( l_key_tbl(i).key_value ,'Success','Failed')
          INTO l_key_tbl(i).result_value
          FROM dual;
      END LOOP;

      io_key_tbl := l_key_tbl;

    END IF;

    CLOSE cur_bus_org;

    -- END CR39624
    -- Added for CR42764

  ELSIF in_event = 'CASE_CREATION' THEN

    DBMS_OUTPUT.PUT_LINE('in_event  '||in_event);

    esn_sp_rec := sa.service_plan.get_service_plan_by_esn (in_esn);

    IF (l_key_tbl.count > 0) THEN

      FOR i IN 1..l_key_tbl.COUNT LOOP

        l_key_name               := l_key_tbl(i).key_type;

        IF l_key_name             = 'SP_MKT_NAME' THEN

          l_key_tbl(i).key_value := esn_sp_rec.mkt_name;

          SELECT NVL2(l_key_tbl(i).key_value ,'Success','Failed')
            INTO l_key_tbl(i).result_value
            FROM dual;

        ELSIF l_key_name          = 'UDF' THEN

          l_key_tbl(i).key_value := in_case_id;

          SELECT NVL2( l_key_tbl(i).key_value ,'Success','Failed')
            INTO l_key_tbl(i).result_value
            FROM dual;

        ELSIF l_key_name          = 'UDF1' THEN

          l_key_tbl(i).key_value := NULL;

          SELECT NVL2( l_key_tbl(i).key_value ,'Success','Failed')
          INTO l_key_tbl(i).result_value
          FROM dual;

        ELSIF l_key_name          = 'UDF2' THEN

          l_key_tbl(i).key_value :=  NULL;

          SELECT NVL2( l_key_tbl(i).key_value ,'Success','Failed')
            INTO l_key_tbl(i).result_value
            FROM dual;

        ELSIF l_key_name          = 'UDF3' THEN

          l_key_tbl(i).key_value :=  NULL;

          SELECT NVL2( l_key_tbl(i).key_value ,'Success','Failed')
            INTO l_key_tbl(i).result_value
            FROM dual;

        ELSE

           BEGIN
             DBMS_OUTPUT.PUT_LINE('l_key_name  '||l_key_name  );
             DBMS_OUTPUT.PUT_LINE('bus_org_rec.objid  '||bus_org_rec.objid  );

             cur_criteria_case_rec := NULL;

             OPEN cur_criteria_case (in_event, l_key_name, bus_org_rec.objid, lv_language);
               FETCH cur_criteria_case INTO cur_criteria_case_rec;
             CLOSE cur_criteria_case;

             DBMS_OUTPUT.PUT_LINE('CASE_CREATION_VALUES:  '||l_key_name ||'==>' ||cur_criteria_case_rec.criteria_value);
             DBMS_OUTPUT.PUT_LINE('NON_PPE_FLAG:  '||RC.NON_PPE_FLAG);

             IF RC.NON_PPE_FLAG = 1 THEN

                  DBMS_OUTPUT.PUT_LINE(' It is NON_PPE Phone');

                  IF l_key_name            = 'SEND_SMS' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SEND_EMAIL' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SCRIPT_ID' THEN
                    l_key_tbl(i).key_value := NULL;
                  ELSIF l_key_name         = 'SHORT_CODE' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'CAMPAIGN_CD' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_CAMPAIGN_CD' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_TEXT_TEMPLATE' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_PPE_TEXT' THEN
                    l_key_tbl(i).key_value := 'NO MESSAGE';
                  ELSIF l_key_name         = 'TRIGGER_ID' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_VENDOR_OBJID' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'EMAIL_VENDOR_OBJID' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  END IF;

              ELSIF RC.NON_PPE_FLAG       = 0 THEN

                  DBMS_OUTPUT.PUT_LINE(' It is PPE Phone');

                  IF l_key_name            = 'SEND_SMS' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SEND_EMAIL' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SCRIPT_ID' THEN
                    l_key_tbl(i).key_value := NULL;
                  ELSIF l_key_name         = 'SHORT_CODE' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'CAMPAIGN_CD' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_CAMPAIGN_CD' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_TEXT_TEMPLATE' THEN
                    l_key_tbl(i).key_value := 'NO MESSAGE';
                  ELSIF l_key_name         = 'SMS_PPE_TEXT' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'TRIGGER_ID' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_VENDOR_OBJID' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'EMAIL_VENDOR_OBJID' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  END IF;

              END IF;

              DBMS_OUTPUT.PUT_LINE('cursor Close');
              DBMS_OUTPUT.PUT_LINE('l_key_tbl(i).key_value456===>'||l_key_tbl(i).key_value);

              SELECT NVL2(l_key_tbl(i).key_value,'Success','Failed')
                INTO l_key_tbl(i).result_value
                FROM dual;

          EXCEPTION
            WHEN OTHERS THEN
              l_key_tbl(i).key_value := NULL;
          END;

        END IF;

      END LOOP;

      io_key_tbl := l_key_tbl;

    ELSE

      SELECT keys_obj(rc.criteria_name, rcv.criteria_value, NULL) BULK COLLECT
        INTO l_key_tbl
        FROM sa.rtc_criteria_values rcv,
             sa.rtc_criteria rc,
             sa.rtc_event re
        WHERE 1                              = 1
          AND UPPER(re.rtc_event)            = UPPER(in_event)
          AND UPPER(re.rtc_comm_on)          = '1'
          AND re.objid                       = rcv.values2event
          AND rcv.values2serviceplan         IS NULL
          AND rcv.values2criteria            = rc.objid
          AND rcv.values2bus_org             = bus_org_rec.objid
          AND rcv.values2event               = re.objid
          AND NVL(rcv.start_date,sysdate)    <= SYSDATE
          AND NVL(rcv.end_date,sysdate+3000) >= SYSDATE;

      FOR i IN 1..l_key_tbl.COUNT LOOP
        SELECT NVL2( l_key_tbl(i).key_value,'Success','Failed')
          INTO l_key_tbl(i).result_value
          FROM dual;
      END LOOP;

      io_key_tbl := l_key_tbl;

    END IF;

    CLOSE cur_bus_org;

  --Added for CR42764
  ELSIF in_event = 'CASE_SHIPMENT' THEN

    DBMS_OUTPUT.PUT_LINE('in_event  '||in_event  );
    DBMS_OUTPUT.PUT_LINE('in_case_id  '||in_case_id  );

    esn_sp_rec := sa.service_plan.get_service_plan_by_esn (in_esn);

    SELECT TO_CHAR(in_case_id)
      INTO v_case_id
      FROM dual;

    OPEN cur_shipping_info (v_case_id);
    FETCH cur_shipping_info INTO cur_shipping_info_rec;

      IF cur_shipping_info%NOTFOUND THEN
        dbms_output.put_line('cur_shipping_info NOT FOUND.');
        out_err_num    := 1;
        out_err_msg    := 'Shipping info Not found - case_idnumber :'|| in_case_id ||'- esn :'|| TO_CHAR(in_esn) || '- ' || 'in_event: '||in_event;
        sa.ota_util_pkg.err_log (p_action => 'Fetching Shipping Info ',
                                 p_error_date => SYSDATE,
                                 p_key => 'case_idnumber :'|| in_case_id ,
                                 p_program_name => 'sa.RTC_Pkg.is_rtc_enabled_for_esn',
                                 p_error_text => out_err_msg );
      ELSE
        dbms_output.put_line('cur_shipping_info FOUND.');
      END IF;

    CLOSE cur_shipping_info;

    IF (l_key_tbl.count > 0) THEN

      FOR i IN 1..l_key_tbl.COUNT LOOP

        l_key_name := l_key_tbl(i).key_type;

        IF l_key_name = 'SP_MKT_NAME' THEN

          l_key_tbl(i).key_value := esn_sp_rec.mkt_name;

          SELECT NVL2(l_key_tbl(i).key_value,'Success','Failed')
            INTO l_key_tbl(i).result_value
            FROM dual;

        ELSIF l_key_name = 'UDF' THEN

          l_key_tbl(i).key_value := in_case_id;

          SELECT NVL2( l_key_tbl(i).key_value,'Success','Failed')
            INTO l_key_tbl(i).result_value
            FROM dual;

        ELSIF l_key_name = 'UDF1' THEN

          l_key_tbl(i).key_value := cur_shipping_info_rec.x_courier;

          SELECT NVL2(l_key_tbl(i).key_value,'Success','Failed')
            INTO l_key_tbl(i).result_value
            FROM dual;

        ELSIF l_key_name = 'UDF2' THEN

          l_key_tbl(i).key_value := cur_shipping_info_rec.x_tracking_no;

          SELECT NVL2(l_key_tbl(i).key_value,'Success','Failed')
            INTO l_key_tbl(i).result_value
            FROM dual;

        ELSIF l_key_name = 'UDF3' THEN

          l_key_tbl(i).key_value := cur_shipping_info_rec.address;

          SELECT NVL2(l_key_tbl(i).key_value,'Success','Failed')
            INTO l_key_tbl(i).result_value
            FROM dual;

        ELSE

           BEGIN

             DBMS_OUTPUT.PUT_LINE('l_key_name  '||l_key_name  );
             DBMS_OUTPUT.PUT_LINE('bus_org_rec.objid  '||bus_org_rec.objid  );

             cur_criteria_case_rec := NULL;

             OPEN cur_criteria_case(in_event, l_key_name, bus_org_rec.objid, lv_language);
              FETCH cur_criteria_case INTO cur_criteria_case_rec;
             CLOSE cur_criteria_case;

             DBMS_OUTPUT.PUT_LINE('CASE_SHIPMENT_VALUES:  '||l_key_name ||'==>' ||cur_criteria_case_rec.criteria_value);
             DBMS_OUTPUT.PUT_LINE('NON_PPE_FLAG:  '||RC.NON_PPE_FLAG);

             IF RC.NON_PPE_FLAG = 1 THEN

                  DBMS_OUTPUT.PUT_LINE('It is NON_PPE Phone');

                  IF l_key_name            = 'SEND_SMS' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SEND_EMAIL' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SCRIPT_ID' THEN
                    l_key_tbl(i).key_value := NULL;
                  ELSIF l_key_name         = 'SHORT_CODE' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'CAMPAIGN_CD' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_CAMPAIGN_CD' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_TEXT_TEMPLATE' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_PPE_TEXT' THEN
                    l_key_tbl(i).key_value := 'NO MESSAGE';
                  ELSIF l_key_name         = 'TRIGGER_ID' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_VENDOR_OBJID' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'EMAIL_VENDOR_OBJID' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  END IF;

              ELSIF RC.NON_PPE_FLAG = 0 THEN

                  DBMS_OUTPUT.PUT_LINE('It is PPE Phone');

                  IF l_key_name            = 'SEND_SMS' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SEND_EMAIL' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SCRIPT_ID' THEN
                    l_key_tbl(i).key_value := NULL;
                  ELSIF l_key_name         = 'SHORT_CODE' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'CAMPAIGN_CD' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_CAMPAIGN_CD' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_TEXT_TEMPLATE' THEN
                    l_key_tbl(i).key_value := 'NO MESSAGE';
                  ELSIF l_key_name         = 'SMS_PPE_TEXT' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'TRIGGER_ID' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'SMS_VENDOR_OBJID' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  ELSIF l_key_name         = 'EMAIL_VENDOR_OBJID' THEN
                    l_key_tbl(i).key_value := cur_criteria_case_rec.criteria_value;
                  END IF;

              END IF;

              DBMS_OUTPUT.PUT_LINE('cursor Close');
              DBMS_OUTPUT.PUT_LINE('l_key_tbl(i).key_value456===>'||l_key_tbl(i).key_value);

              SELECT NVL2(l_key_tbl(i).key_value,'Success','Failed')
                INTO l_key_tbl(i).result_value
                FROM dual;

          EXCEPTION
            WHEN OTHERS THEN
              l_key_tbl(i).key_value := NULL;
          END;

        END IF;

      END LOOP;

      io_key_tbl := l_key_tbl;

    ELSE

      SELECT keys_obj(rc.criteria_name, rcv.criteria_value, NULL) BULK COLLECT
        INTO l_key_tbl
        FROM sa.rtc_criteria_values rcv,
             sa.rtc_criteria rc,
             sa.rtc_event re
       WHERE 1                              = 1
         AND UPPER(re.rtc_event)            = UPPER(in_event)
         AND UPPER(re.rtc_comm_on)          = '1'
         AND re.objid                       = rcv.values2event
         AND rcv.values2serviceplan         IS NULL
         AND rcv.values2criteria            = rc.objid
         AND rcv.values2bus_org             = bus_org_rec.objid
         AND rcv.values2event               = re.objid
         AND NVL(rcv.start_date,sysdate)    <= SYSDATE
         AND NVL(rcv.end_date,sysdate+3000) >= SYSDATE;

      FOR i IN 1..l_key_tbl.COUNT LOOP
        SELECT NVL2( l_key_tbl(i).key_value ,'Success','Failed')
          INTO l_key_tbl(i).result_value
          FROM dual;
      END LOOP;

      io_key_tbl := l_key_tbl;

    END IF;

    CLOSE cur_bus_org;

  ELSIF in_event = 'ACTIVATION' THEN

    dbms_output.put_line('in_esn'||in_esn);

    esn_sp_rec := sa.service_plan.get_service_plan_by_esn (in_esn);

    dbms_output.put_line('esn_sp_rec.objid = '||esn_sp_rec.objid);

    IF in_bus_org = 'NET10' THEN  --FOR CR41175

      OPEN cur_count_channels (esn_sp_rec.objid);
       FETCH cur_count_channels INTO count_channels;
      CLOSE cur_count_channels;

      IF (NVL(count_channels.count_cv,0) = 0) THEN
        out_err_num    := 1;
        out_err_msg    := 'RTC off for service plan.';
        RETURN;
      END IF;

    END IF;--CR41175

    OPEN cur_due_date (in_esn);
    FETCH cur_due_date INTO rec_due_date;
      IF cur_due_date%FOUND THEN
        l_new_due_dt := rec_due_date.due_date;
      END IF;
    CLOSE cur_due_date;

    IF (l_key_tbl.count > 0) THEN

      FOR i IN 1..l_key_tbl.COUNT LOOP

        l_key_name := l_key_tbl(i).key_type;

        dbms_output.put_line(l_key_name);

        IF l_key_name = 'SP_MKT_NAME' THEN

          l_key_tbl(i).key_value := esn_sp_rec.mkt_name;

          SELECT NVL2( l_key_tbl(i).key_value ,'Success','Failed')
            INTO l_key_tbl(i).result_value
            FROM dual;

        ELSIF l_key_name = 'UDF1' THEN

          IF sa.get_serv_plan_value (esn_sp_rec.objid, 'PARENT') LIKE '%UNLIMITED%' THEN
            l_key_tbl(i).key_value := 'UNLIMITED'; -- CR31603
          ELSE
            l_key_tbl(i).key_value := sa.get_serv_plan_value(esn_sp_rec.objid, 'VOICE'); -- CR31603
          END IF;

        ELSIF l_key_name = 'UDF2' THEN

          l_key_tbl(i).key_value := sa.get_serv_plan_value(esn_sp_rec.objid, 'SERVICE DAYS'); -- CR31603

        ELSIF l_key_name = 'UDF3' THEN

          l_key_tbl(i).key_value := l_new_due_dt; -- CR31603

        ELSE

          BEGIN

            IF IN_BUS_ORG = 'NET10' THEN  --CR41175

              criteria_values_by_sp_rec := NULL;

              OPEN cur_criteria_values_by_sp (in_event, l_key_name, esn_sp_rec.objid);
                FETCH cur_criteria_values_by_sp INTO criteria_values_by_sp_rec;
              CLOSE cur_criteria_values_by_sp;

              IF RC.NON_PPE_FLAG = 1 THEN

                IF l_key_name            = 'SEND_SMS' THEN
                  l_key_tbl(i).key_value := criteria_values_by_sp_rec.criteria_value;
                ELSIF l_key_name         = 'SEND_EMAIL' THEN
                  l_key_tbl(i).key_value := criteria_values_by_sp_rec.criteria_value;
                ELSIF l_key_name         = 'SCRIPT_ID' THEN
                  l_key_tbl(i).key_value := NULL;
                ELSIF l_key_name         = 'SHORT_CODE' THEN
                  l_key_tbl(i).key_value := criteria_values_by_sp_rec.criteria_value;
                ELSIF l_key_name         = 'CAMPAIGN_CD' THEN
                  l_key_tbl(i).key_value := NULL;
                ELSIF l_key_name         = 'SMS_TEXT_TEMPLATE' THEN
                  l_key_tbl(i).key_value := criteria_values_by_sp_rec.criteria_value;
                ELSIF l_key_name         = 'SMS_CAMPAIGN_CD' THEN
                  l_key_tbl(i).key_value := NULL;
                ELSIF l_key_name         = 'SMS_VENDOR_OBJID' THEN
                  l_key_tbl(i).key_value := criteria_values_by_sp_rec.criteria_value;
                ELSIF l_key_name         = 'TRIGGER_ID' THEN
                  l_key_tbl(i).key_value := NULL;
                ELSIF l_key_name         = 'SMS_PPE_TEXT' THEN
                  l_key_tbl(i).key_value := 'NO MESSAGE';
                ELSIF l_key_name         = 'EMAIL_VENDOR_OBJID' THEN
                  l_key_tbl(i).key_value := NULL;
                END IF;

              ELSIF RC.NON_PPE_FLAG       = 0 THEN

                IF l_key_name            = 'SEND_SMS' THEN
                  l_key_tbl(i).key_value := criteria_values_by_sp_rec.criteria_value;
                ELSIF l_key_name         = 'SEND_EMAIL' THEN
                  l_key_tbl(i).key_value := criteria_values_by_sp_rec.criteria_value;
                ELSIF l_key_name         = 'SCRIPT_ID' THEN
                  l_key_tbl(i).key_value := NULL;
                ELSIF l_key_name         = 'SHORT_CODE' THEN
                  l_key_tbl(i).key_value := criteria_values_by_sp_rec.criteria_value;
                ELSIF l_key_name         = 'CAMPAIGN_CD' THEN
                  l_key_tbl(i).key_value := NULL;
                ELSIF l_key_name         = 'SMS_TEXT_TEMPLATE' THEN
                  l_key_tbl(i).key_value := 'NO MESSAGE';
                ELSIF l_key_name         = 'SMS_CAMPAIGN_CD' THEN
                  l_key_tbl(i).key_value := NULL;
                ELSIF l_key_name         = 'SMS_VENDOR_OBJID' THEN
                  l_key_tbl(i).key_value := criteria_values_by_sp_rec.criteria_value;
                ELSIF l_key_name         = 'TRIGGER_ID' THEN
                  l_key_tbl(i).key_value := NULL;
                ELSIF l_key_name         = 'SMS_PPE_TEXT' THEN
                  l_key_tbl(i).key_value := criteria_values_by_sp_rec.criteria_value;
                ELSIF l_key_name         = 'EMAIL_VENDOR_OBJID' THEN
                  l_key_tbl(i).key_value := NULL;
                END IF;

              END IF;

              DBMS_OUTPUT.PUT_LINE('cursor Close');

            ELSE

              criteria_values_by_st_rec := NULL;

              OPEN cur_criteria_values_by_st (in_event, l_key_name);
                FETCH cur_criteria_values_by_st INTO criteria_values_by_st_rec;
              CLOSE cur_criteria_values_by_st;

              IF RC.NON_PPE_FLAG          = 0 THEN

                IF l_key_name            = 'SEND_SMS' THEN
                  l_key_tbl(i).key_value := criteria_values_by_st_rec.criteria_value;
                ELSIF l_key_name         = 'SEND_EMAIL' THEN
                  l_key_tbl(i).key_value := criteria_values_by_st_rec.criteria_value;
                ELSIF l_key_name         = 'SCRIPT_ID' THEN
                  l_key_tbl(i).key_value := NULL;
                ELSIF l_key_name         = 'SHORT_CODE' THEN
                  l_key_tbl(i).key_value := criteria_values_by_st_rec.criteria_value;
                ELSIF l_key_name         = 'CAMPAIGN_CD' THEN
                  l_key_tbl(i).key_value := NULL;
                ELSIF l_key_name         = 'SMS_TEXT_TEMPLATE' THEN
                  l_key_tbl(i).key_value := 'NO MESSAGE';
                ELSIF l_key_name         = 'SMS_CAMPAIGN_CD' THEN
                  l_key_tbl(i).key_value := criteria_values_by_st_rec.criteria_value;
                ELSIF l_key_name         = 'SMS_VENDOR_OBJID' THEN
                  l_key_tbl(i).key_value := criteria_values_by_st_rec.criteria_value;
                ELSIF l_key_name         = 'TRIGGER_ID' THEN
                  l_key_tbl(i).key_value := criteria_values_by_st_rec.criteria_value;
                ELSIF l_key_name         = 'SMS_PPE_TEXT' THEN
                  l_key_tbl(i).key_value := criteria_values_by_st_rec.criteria_value;
                ELSIF l_key_name         = 'EMAIL_VENDOR_OBJID' THEN
                  l_key_tbl(i).key_value := NULL;
                END IF;

              ELSIF RC.NON_PPE_FLAG       = 1 THEN

                IF l_key_name            = 'SEND_SMS' THEN
                  l_key_tbl(i).key_value := criteria_values_by_st_rec.criteria_value;
                ELSIF l_key_name         = 'SEND_EMAIL' THEN
                  l_key_tbl(i).key_value := criteria_values_by_st_rec.criteria_value;
                ELSIF l_key_name         = 'SCRIPT_ID' THEN
                  l_key_tbl(i).key_value := NULL;
                ELSIF l_key_name         = 'SHORT_CODE' THEN
                  l_key_tbl(i).key_value := criteria_values_by_st_rec.criteria_value;
                ELSIF l_key_name         = 'CAMPAIGN_CD' THEN
                  l_key_tbl(i).key_value := NULL;
                ELSIF l_key_name         = 'SMS_TEXT_TEMPLATE' THEN
                  l_key_tbl(i).key_value := criteria_values_by_st_rec.criteria_value;
                ELSIF l_key_name         = 'SMS_CAMPAIGN_CD' THEN
                  l_key_tbl(i).key_value := criteria_values_by_st_rec.criteria_value;
                ELSIF l_key_name         = 'SMS_VENDOR_OBJID' THEN
                  l_key_tbl(i).key_value := criteria_values_by_st_rec.criteria_value;
                ELSIF l_key_name         = 'TRIGGER_ID' THEN
                  l_key_tbl(i).key_value := criteria_values_by_st_rec.criteria_value;
                ELSIF l_key_name         = 'SMS_PPE_TEXT' THEN
                  l_key_tbl(i).key_value := 'NO MESSAGE';
                ELSIF l_key_name         = 'EMAIL_VENDOR_OBJID' THEN
                  l_key_tbl(i).key_value := NULL;
                END IF;

              END IF;  --PPE FLAG END IF

              DBMS_OUTPUT.PUT_LINE('l_key_tbl(i).key_value456===>'||l_key_tbl(i).key_value);

              SELECT NVL2(l_key_tbl(i).key_value,'Success','Failed')
                INTO l_key_tbl(i).result_value
                FROM dual;

            END IF;

          EXCEPTION
            WHEN OTHERS THEN
              l_key_tbl(i).key_value := NULL;
          END;

        END IF;

      END LOOP;

      io_key_tbl := l_key_tbl;

    ELSE

        SELECT keys_obj (rc.criteria_name, rcv.criteria_value, NULL) BULK COLLECT
          INTO l_key_tbl
          FROM sa.rtc_criteria_values rcv,
               sa.rtc_criteria rc,
               sa.rtc_event re
         WHERE 1                              = 1
           AND UPPER(re.rtc_event)            = UPPER(in_event)
           AND UPPER(re.rtc_comm_on)          = '1'
           AND re.objid                       = rcv.values2event
           AND rcv.values2criteria            = rc.objid
           AND rcv.values2serviceplan         = esn_sp_rec.objid
           AND rcv.values2event               = re.objid
           AND NVL(rcv.start_date,sysdate)    <= SYSDATE  --CR41175
           AND NVL(rcv.end_date,sysdate+3000) >= SYSDATE; --CR41175

        l_key_tbl.extend;

        l_key_tbl(l_key_tbl.last) := keys_obj('SP_MKT_NAME',esn_sp_rec.mkt_name,NULL);

        IF sa.get_serv_plan_value(esn_sp_rec.objid, 'PARENT') LIKE '%UNLIMITED%' THEN
          l_key_tbl.extend;
          l_key_tbl(l_key_tbl.last) := keys_obj('UDF1','UNLIMITED',NULL); --> CR31603
        ELSE
          l_key_tbl.extend;
          l_key_tbl(l_key_tbl.last) := keys_obj('UDF1',sa.get_serv_plan_value(esn_sp_rec.objid, 'VOICE'),NULL); --> CR31603
        END IF;

        l_key_tbl.extend;
        l_key_tbl(l_key_tbl.last) := keys_obj('UDF2',sa.get_serv_plan_value(esn_sp_rec.objid, 'SERVICE DAYS'),NULL); --> CR31603
        l_key_tbl.extend;
        l_key_tbl(l_key_tbl.last) := keys_obj('UDF3',l_new_due_dt,NULL); --> CR31603

        FOR i IN 1..l_key_tbl.COUNT LOOP
          SELECT NVL2(l_key_tbl(i).key_value ,'Success','Failed')
            INTO l_key_tbl(i).result_value
            FROM dual;
        END LOOP;

        io_key_tbl := l_key_tbl;

      END IF;

      CLOSE cur_bus_org;

    ELSIF in_event = 'FORGOT_PASSWORD' THEN

      LV_DUMMY_EMAIL := 'NO';

      IF (l_key_tbl.count > 0) THEN

        FOR i IN 1..l_key_tbl.COUNT LOOP

          l_key_name               := l_key_tbl(i).key_type;

          IF l_key_name             = 'SP_MKT_NAME' THEN

            l_key_tbl(i).key_value := NULL;

            SELECT NVL2( l_key_tbl(i).key_value ,'Success','Failed')
              INTO l_key_tbl(i).result_value
              FROM dual;

          ELSE

            IF l_key_name  = 'UDF1' THEN

              l_key_value := l_key_tbl(i).key_value;

              SELECT SUBSTR(l_key_value,instr(l_key_value,'@',1,1)+1, LENGTH(l_key_value))
                INTO LV_EMAIL_DOMAIN
                FROM dual;

              SELECT COUNT(1)
              INTO V_DUMMY_EMAIL_EXIST
              FROM sa.RTC_CRITERIA_VALUES
              WHERE VALUES2EVENT = (SELECT objid
                                      FROM sa.rtc_event
                                     WHERE rtc_event = in_event)
              AND VALUES2CRITERIA = (SELECT objid
                                       FROM sa.rtc_criteria
                                       WHERE criteria_name = 'INVALID_EMAIL_DOMAIN')
              AND VALUES2BUS_ORG  = bus_org_rec.objid
              AND CRITERIA_VALUE  = UPPER(LV_EMAIL_DOMAIN);

              IF V_DUMMY_EMAIL_EXIST > 0 THEN
                LV_DUMMY_EMAIL         := 'YES';
              ELSIF V_DUMMY_EMAIL_EXIST = 0 THEN
                LV_DUMMY_EMAIL         := 'NO';
              END IF;

            END IF;

            IF l_key_tbl(i).key_value IS NULL AND (l_key_name NOT IN ( 'SEND_SMS','SEND_EMAIL', 'SHORT_CODE', 'CAMPAIGN_CD') ) THEN

              BEGIN

                OPEN cur_criteria_values_by_bo (in_event, l_key_name, bus_org_rec.objid, LV_LANGUAGE);
                  FETCH cur_criteria_values_by_bo INTO criteria_values_by_bo_rec;

                  IF cur_criteria_values_by_bo%FOUND THEN
                    l_key_tbl(i).key_value := criteria_values_by_bo_rec.criteria_value;
                  END IF;

                CLOSE cur_criteria_values_by_bo;

                SELECT NVL2(l_key_tbl(i).key_value ,'Success','Failed')
                  INTO l_key_tbl(i).result_value
                  FROM dual;

              EXCEPTION
                WHEN OTHERS THEN
                  l_key_tbl(i).key_value := NULL;
              END;

            END IF;

          END IF;

        END LOOP;

        FOR X IN 1..l_key_tbl.COUNT LOOP

          IF LV_DUMMY_EMAIL = 'YES' THEN

            IF (l_key_tbl(X).key_type IN ('SEND_SMS','SHORT_CODE')) THEN

              BEGIN
                OPEN cur_criteria_values_by_bo (in_event, l_key_tbl(X).key_type, bus_org_rec.objid, LV_LANGUAGE);
                  FETCH cur_criteria_values_by_bo INTO criteria_values_by_bo_rec;
                  IF cur_criteria_values_by_bo%FOUND THEN
                    l_key_tbl(X).key_value := criteria_values_by_bo_rec.criteria_value;
                  END IF;
                CLOSE cur_criteria_values_by_bo;

                SELECT NVL2(l_key_tbl(x).key_value ,'Success','Failed')
                  INTO l_key_tbl(x).result_value
                  FROM dual;

              EXCEPTION
                WHEN OTHERS THEN
                  l_key_tbl(x).key_value := NULL;
              END;

            END IF;

          ELSIF LV_DUMMY_EMAIL = 'NO' THEN

            IF (l_key_tbl(X).key_type IN ('SEND_EMAIL', 'CAMPAIGN_CD')) THEN

              BEGIN

                OPEN cur_criteria_values_by_bo (in_event, l_key_tbl(X).key_type, bus_org_rec.objid, LV_LANGUAGE);
                  FETCH cur_criteria_values_by_bo INTO criteria_values_by_bo_rec;
                  IF cur_criteria_values_by_bo%FOUND THEN
                    l_key_tbl(x).key_value := criteria_values_by_bo_rec.criteria_value;
                  END IF;
                CLOSE cur_criteria_values_by_bo;

                SELECT NVL2(l_key_tbl(x).key_value ,'Success','Failed')
                  INTO l_key_tbl(x).result_value
                  FROM dual;

              EXCEPTION
                WHEN OTHERS THEN
                  l_key_tbl(x).key_value := NULL;
              END;

            END IF;

          END IF;

        END LOOP;

        io_key_tbl := l_key_tbl;

      ELSE

        SELECT keys_obj(rc.criteria_name, rcv.criteria_value, NULL) BULK COLLECT
          INTO l_key_tbl
          FROM rtc_criteria_values rcv,
               rtc_criteria rc,
               rtc_event re
         WHERE 1                               = 1
           AND UPPER(re.rtc_event)             = UPPER(in_event)
           AND UPPER(re.rtc_comm_on)           = '1'
           AND re.objid                        = rcv.values2event
           AND rcv.values2serviceplan          IS NULL
           AND rcv.values2criteria             = rc.objid
           AND rcv.values2bus_org              = bus_org_rec.objid
           AND rcv.values2event                = re.objid
           AND NVL(rcv.x_language,in_language) = in_language --CR32782
           AND NVL(rcv.start_date,sysdate)     <= SYSDATE    --CR41175
           AND NVL(rcv.end_date,sysdate+3000)  >= SYSDATE;   --CR41175

        FOR i IN 1..l_key_tbl.COUNT LOOP
          SELECT NVL2(l_key_tbl(i).key_value,'Success','Failed')
            INTO l_key_tbl(i).result_value
            FROM dual;
        END LOOP;

        io_key_tbl := l_key_tbl;

      END IF;

      CLOSE cur_bus_org;

    ELSE -------------->> EVENT IS NOT ONL ACC CREATION, PW RESET OR ACTIVATION.

      NULL;
      CLOSE cur_bus_org;

    END IF;

EXCEPTION
  WHEN OTHERS THEN
    out_err_num := SQLCODE;
    out_err_msg := SUBSTR(SQLERRM, 1, 300);
    sa.ota_util_pkg.err_log (p_action => 'Fetching ESN info for RTC.',
                             p_error_date => SYSDATE,
                             p_key => TO_CHAR(in_esn) || '- ' || in_event,
                             p_program_name => 'sa.RTC_Pkg.is_rtc_enabled_for_esn',
                             p_error_text => out_err_msg );
END is_rtc_enabled_for_esn;
--------------------------------------------------------------------------------
PROCEDURE set_rtc_event (in_event    IN   VARCHAR2,
                         in_comm_on  IN   VARCHAR2,
                         in_desc     IN   VARCHAR2,
                         out_msg     OUT  VARCHAR2)
IS
  CURSOR cur_event_exists (in_event VARCHAR2)
  IS
    SELECT *
      FROM sa.rtc_event
     WHERE rtc_event = UPPER(in_event);

  event_exists_rec   cur_event_exists%ROWTYPE;

BEGIN

  IF in_event IS NULL OR in_comm_on IS NULL THEN
    out_msg := 'EVENT or COMM_ON cannot be null.';
    RETURN;
  END IF;

  OPEN cur_event_exists (in_event);
   FETCH cur_event_exists INTO event_exists_rec;

   IF cur_event_exists%NOTFOUND THEN

     INSERT INTO sa.rtc_event (objid,
                               rtc_event,
                               rtc_comm_on,
                               description)
                       VALUES (sa.sequ_rtc_event.nextval,
                               UPPER(in_event),
                               in_comm_on,
                               in_desc);

     COMMIT;

     out_msg := 'Event inserted.';

   ELSE

     UPDATE sa.rtc_event
        SET rtc_comm_on = in_comm_on
      WHERE rtc_event = UPPER(in_event);

     COMMIT;

     out_msg := 'Event updated.';

  END IF;

  CLOSE cur_event_exists;

EXCEPTION
  WHEN OTHERS THEN
    out_msg := 'Error: ' || SQLCODE;
END set_rtc_event;
--------------------------------------------------------------------------------
PROCEDURE set_rtc_criteria (in_criteria  IN   VARCHAR2,
                            in_desc      IN   VARCHAR2,
                            out_msg      OUT  VARCHAR2)
IS
  CURSOR cur_criteria_exists (in_criteria VARCHAR2)
  IS
    SELECT *
      FROM sa.rtc_criteria
     WHERE criteria_name = UPPER(in_criteria);

  criteria_exists_rec cur_criteria_exists%ROWTYPE;

BEGIN

  IF in_criteria IS NULL THEN
    out_msg := 'CRITERIA cannot be null.';
    RETURN;
  END IF;

  OPEN cur_criteria_exists(in_criteria);
   FETCH cur_criteria_exists INTO criteria_exists_rec;

   IF cur_criteria_exists%NOTFOUND THEN

     INSERT INTO sa.rtc_criteria (objid,
                                  criteria_name,
                                  description)
                          VALUES (sa.sequ_rtc_criteria.nextval,
                                  UPPER(in_criteria),
                                  in_desc);

     COMMIT;

     out_msg := 'Criteria inserted.';
     CLOSE cur_criteria_exists;

   ELSE

     out_msg := 'Criteria already exists.';
     CLOSE cur_criteria_exists;

   END IF;

EXCEPTION
  WHEN OTHERS THEN
    out_msg := 'Error: ' || SQLCODE;
END set_rtc_criteria;
--------------------------------------------------------------------------------
PROCEDURE set_rtc_criteria_values (in_sp_objid    IN    NUMBER,
                                   in_event       IN    VARCHAR2,
                                   in_bus_org     IN    VARCHAR2,
                                   io_key_tbl     IN    sa.keys_tbl,
                                   out_err_num    OUT   VARCHAR2,
                                   out_err_msg    OUT   VARCHAR2)
AS
  CURSOR cur_event_objid (in_event VARCHAR2)
  IS
    SELECT objid
      FROM sa.rtc_event
     WHERE rtc_event = in_event;

  event_objid_rec cur_event_objid%ROWTYPE;

  CURSOR cur_bus_org_objid (in_bus_org VARCHAR2)
  IS
    SELECT objid
      FROM sa.table_bus_org
     WHERE org_id = in_bus_org;

  bus_org_objid_rec cur_bus_org_objid%ROWTYPE;

  CURSOR cur_sp_objid (in_sp_objid NUMBER)
  IS
    SELECT objid
      FROM sa.x_service_plan
     WHERE objid = in_sp_objid;

  sp_objid_rec cur_sp_objid%ROWTYPE;

  CURSOR cur_criteria_objid (in_criteria VARCHAR2)
  IS
    SELECT objid
      FROM sa.rtc_criteria
     WHERE criteria_name = in_criteria;

  criteria_objid_rec cur_criteria_objid%ROWTYPE;

  event_objid         NUMBER;
  criteria_objid      NUMBER;
  l_counter_inserted  NUMBER;
  l_counter_failed    NUMBER;
  v_key_tbl           KEYS_TBL := keys_tbl();
  l_criteria_name     sa.rtc_criteria.criteria_name%TYPE;

BEGIN

  l_counter_inserted := 0;
  l_counter_failed   := 0;

  OPEN cur_event_objid (in_event);
  FETCH cur_event_objid INTO event_objid_rec;

  IF cur_event_objid%NOTFOUND THEN
    dbms_output.put_line('Invalid event.');
    CLOSE cur_event_objid;
    RETURN;
  END IF;

  OPEN cur_bus_org_objid (in_bus_org);
  FETCH cur_bus_org_objid INTO bus_org_objid_rec;

  IF cur_bus_org_objid%NOTFOUND THEN
    dbms_output.put_line('Invalid bus_org.');
    CLOSE cur_bus_org_objid;
    RETURN;
  END IF;

  /*  --CR41175
  OPEN cur_sp_objid (in_sp_objid);
  FETCH cur_sp_objid INTO sp_objid_rec;

  IF cur_sp_objid%NOTFOUND AND in_event != 'ONLINE_ACCT_CREATION' THEN
    dbms_output.put_line('Invalid service plan.');
    CLOSE cur_sp_objid;
    RETURN;
  END IF;
  */  --CR41175

  IF (io_key_tbl.COUNT = 0) THEN
    out_err_num       := -1;
    out_err_msg       := 'No criteria provided to insert.';
    RETURN;
  END IF;

  v_key_tbl := io_key_tbl;

  FOR i IN v_key_tbl.FIRST..v_key_tbl.LAST LOOP

    l_criteria_name := UPPER(v_key_tbl(i).key_type);

    OPEN cur_criteria_objid (l_criteria_name);
    FETCH cur_criteria_objid INTO criteria_objid_rec;

    IF cur_criteria_objid%FOUND THEN

      DELETE
        FROM sa.rtc_criteria_values
       WHERE values2serviceplan = in_sp_objid
         AND values2event       = event_objid_rec.objid
         AND values2criteria    = criteria_objid_rec.objid
         AND values2bus_org     = bus_org_objid_rec.objid;

      INSERT INTO sa.rtc_criteria_values (objid,
                                          values2serviceplan,
                                          values2event,
                                          values2criteria,
                                          values2bus_org,
                                          criteria_value,
                                          description,
                                          x_language)                         --CR41175
                                  VALUES (sa.sequ_rtc_criteria_values.nextval,
                                          in_sp_objid,
                                          event_objid_rec.objid,
                                          criteria_objid_rec.objid,
                                          bus_org_objid_rec.objid,
                                          UPPER(v_key_tbl(i).key_value),
                                          NULL,
                                          UPPER(v_key_tbl(i).result_value));  --CR41175

      l_counter_inserted := l_counter_inserted + 1;

      IF l_counter_inserted = 1000 THEN
        COMMIT;
        l_counter_inserted := 0;
      END IF;

      SELECT 'Success'
        INTO v_key_tbl(i).result_value
        FROM dual;

    ELSE

      dbms_output.put_line('Invalid Criteria_name provided: ' || v_key_tbl(i).key_type || '.');

      SELECT 'Failed'
        INTO v_key_tbl(i).result_value
        FROM dual;

      l_counter_failed := l_counter_failed + 1;

    END IF;

    CLOSE cur_criteria_objid;

  END LOOP;

  COMMIT;

  IF l_counter_failed > 0 THEN
    OUT_ERR_NUM := 1;
    OUT_ERR_MSG := 'Failed. ' || l_counter_failed || ' records not inserted.' ;
  ELSE
    OUT_ERR_NUM := 0;
    OUT_ERR_MSG := 'Inserts successful.';
  END IF;

  DBMS_OUTPUT.PUT_LINE(OUT_ERR_MSG);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE || ' : ' || SQLERRM);
    OUT_ERR_NUM := SQLCODE;
    OUT_ERR_MSG := SQLERRM;
END set_rtc_criteria_values;
--------------------------------------------------------------------------------
PROCEDURE enqueue (in_msg_string        IN    VARCHAR2,
                   in_priority          IN    NUMBER    DEFAULT 1,
                   in_expiration        IN    NUMBER    DEFAULT 86400,
                   in_queue             IN    VARCHAR2  DEFAULT 'SA.RTC_queue',
                   in_exception_queue   IN    VARCHAR2  DEFAULT 'SA.RTC_Exception_Queue',
                   in_correlation       IN    VARCHAR2  DEFAULT 'RTC_Queue',
                   out_err_num          OUT   NUMBER,
                   out_err_msg          OUT   VARCHAR2)
IS
  RTC_msg_prop  DBMS_AQ.message_properties_t;
  RTC_enq_opt   DBMS_AQ.enqueue_options_t;
  RTC_enq_msgid RAW(16);
  RTC_payload   RAW(1000);
BEGIN

  RTC_payload                  := UTL_RAW.CAST_TO_RAW(in_msg_string);
  RTC_enq_opt.visibility       := DBMS_AQ.IMMEDIATE;
  RTC_enq_opt.delivery_mode    := DBMS_AQ.PERSISTENT;
  RTC_msg_prop.delivery_mode   := DBMS_AQ.PERSISTENT;
  RTC_msg_prop.priority        := in_priority;
  RTC_msg_prop.expiration      := in_expiration;
  RTC_msg_prop.correlation     := in_correlation;
  RTC_msg_prop.exception_queue := in_exception_queue;

  DBMS_AQ.enqueue (queue_name         => in_queue,
                   enqueue_options    => RTC_enq_opt,
                   message_properties => RTC_msg_prop,
                   payload            => RTC_payload,
                   msgid              => RTC_enq_msgid);

  out_err_num := 0;
  out_err_msg := 'Success';

EXCEPTION
  WHEN OTHERS THEN
    out_err_num := 1;
    out_err_msg := SQLCODE || ': ' || SQLERRM;
END enqueue;
--------------------------------------------------------------------------------
PROCEDURE dequeue (in_queue       IN   VARCHAR2  DEFAULT 'SA.RTC_EXCEPTION_QUEUE',
                   in_consumer    IN   VARCHAR2  DEFAULT  NULL,
                   in_msg_state   IN   VARCHAR2  DEFAULT 'EXPIRED')
IS
  RTC_msg_prop     DBMS_AQ.message_properties_t;
  RTC_deq_opt      DBMS_AQ.dequeue_options_t;
  RTC_recipients   DBMS_AQ.aq$_recipient_list_t;
  RTC_deq_msgid    RAW(16);
  RTC_payload_deqd RAW(1000);
  l_count_of_msgs  NUMBER;
BEGIN

  SELECT COUNT(1)
    INTO l_count_of_msgs
    FROM sa.AQ$RTC_Q_TABLE
   WHERE msg_state = in_msg_state;

  RTC_deq_opt.consumer_name := in_consumer;
  RTC_deq_opt.visibility    := DBMS_AQ.IMMEDIATE;

  FOR i IN 1..l_count_of_msgs LOOP
    DBMS_AQ.dequeue (queue_name         => in_queue,
                     dequeue_options    => RTC_deq_opt,
                     message_properties => RTC_msg_prop,
                     payload            => RTC_payload_deqd,
                     msgid              => RTC_deq_msgid);
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END dequeue;
--------------------------------------------------------------------------------
FUNCTION get_rtc_event_data (i_event             IN   VARCHAR2,
                             i_esn               IN   VARCHAR2,
                             i_min               IN   VARCHAR2,
                             i_bus_org_id        IN   VARCHAR2,
                             i_contact_email     IN   VARCHAR2,
                             i_language          IN   VARCHAR2,
                             i_web_user_key      IN   VARCHAR2,
                             i_non_ppe_flag      IN   VARCHAR2,
                             i_case_id           IN   VARCHAR2,
                             i_sourcesystem      IN   VARCHAR2,
                             i_bus_org_objid     IN   VARCHAR2,
                             i_carrier_id        IN   VARCHAR2,
                             i_service_plan      IN   VARCHAR2,
                             i_udf1              IN   VARCHAR2,
                             i_udf2              IN   VARCHAR2,
                             i_udf3              IN   VARCHAR2,
                             i_udf4              IN   VARCHAR2,
                             i_udf5              IN   VARCHAR2,
                             i_udf6              IN   VARCHAR2,
                             i_udf7              IN   VARCHAR2,
                             i_udf8              IN   VARCHAR2,
                             i_udf9              IN   VARCHAR2,
                             i_err_num           IN   VARCHAR2,
                             i_err_msg           IN   VARCHAR2)
RETURN sys_refcursor IS
  l_device_type VARCHAR2(100);
  rcur          sys_refcursor;
BEGIN
  -- CR52235 - Created function to collect RTC XML tags including RTC event and criteria values//Juda Pena/Sabumon Raman.
  -- CR54384 - Added conditions for web_user_key and non_ppe_flag from new function parameters//OImana

  l_device_type := NVL(sa.get_device_type (i_esn),'X');

  OPEN rcur FOR
    SELECT * FROM (SELECT UPPER(i_event)         event,
                          i_esn                  esn,
                          i_min                  min,
                          i_bus_org_id           brandname,
                          LOWER(i_contact_email) email,
                          DECODE(UPPER(i_language), NULL,  DECODE(UPPER(i_web_user_key),
                                                                  NULL,       DECODE(i_bus_org_id,
                                                                                     'TELCEL','SPA',
                                                                                     'ENG'),
                                                                  'SPANISH', 'SPA',
                                                                  'ENG'),
                                                    'EN',  'ENG',
                                                    'ENG', 'ENG',
                                                    'ES',  'SPA',
                                                    'ESP', 'SPA',
                                                    UPPER(i_language)) language,
                          i_case_id              caseid,
                          i_sourcesystem         sourcesystem
                     FROM DUAL),
                  (SELECT brand,
                          campaign_cd,
                          email_text_template,
                          email_vendor_objid,
                          invalid_email_domain,
                          script_id,
                          send_email,
                          send_sms,
                          short_code,
                          sms_campaign_cd,
                          CASE WHEN NVL(i_non_ppe_flag,'0') = '0'
                               THEN sms_ppe_text
                               ELSE CASE WHEN l_device_type = 'FEATURE_PHONE'
                                         THEN sms_ppe_text
                                         ELSE NULL
                                     END
                           END sms_ppe_text,
                          CASE WHEN NVL(i_non_ppe_flag,'0') = '1'
                               THEN CASE WHEN l_device_type = 'FEATURE_PHONE'
                                         THEN NULL
                                         ELSE sms_text_template
                                     END
                               ELSE NULL
                           END sms_text_template,
                          sms_vendor_objid,
                          trigger_id
                     FROM (SELECT rc.criteria_name,
                                  rcv.criteria_value
                             FROM sa.rtc_event re,
                                  sa.rtc_criteria rc,
                                  sa.rtc_criteria_values rcv
                            WHERE sysdate BETWEEN NVL(rcv.start_date,sysdate) AND NVL(rcv.end_date,sysdate+1)
                              AND (rcv.x_language        = DECODE(i_language, NULL,  DECODE(UPPER(i_web_user_key),
                                                                                            NULL,      DECODE(i_bus_org_id,
                                                                                                              'TELCEL','SPANISH',
                                                                                                              'ENGLISH'),
                                                                                            'SPANISH', 'SPANISH',
                                                                                            'ENGLISH'),
                                                                              'ENG', 'ENGLISH',
                                                                              'EN',  'ENGLISH',
                                                                              'SPA', 'SPANISH',
                                                                              'ES',  'SPANISH',
                                                                              i_language)
                               OR rcv.x_language         IS NULL)
                              AND ((rcv.value2carrier    = i_carrier_id OR i_carrier_id IS NULL)
                               OR rcv.value2carrier      IS NULL)
                              AND rcv.values2serviceplan IS NULL
                              AND rc.objid               = rcv.values2criteria
                              AND rcv.values2bus_org     = i_bus_org_objid
                              AND rcv.values2event       = re.objid
                              AND UPPER(re.rtc_comm_on)  = '1'
                              AND UPPER(re.rtc_event)    = UPPER(i_event))
                   PIVOT (MAX(criteria_value)
                     FOR (criteria_name) IN ('BRAND'                 AS BRAND,
                                             'CAMPAIGN_CD'           AS CAMPAIGN_CD,
                                             'EMAIL_TEXT_TEMPLATE'   AS EMAIL_TEXT_TEMPLATE,
                                             'EMAIL_VENDOR_OBJID'    AS EMAIL_VENDOR_OBJID,
                                             'INVALID_EMAIL_DOMAIN'  AS INVALID_EMAIL_DOMAIN,
                                             'SCRIPT_ID'             AS SCRIPT_ID,
                                             'SEND_EMAIL'            AS SEND_EMAIL,
                                             'SEND_SMS'              AS SEND_SMS,
                                             'SHORT_CODE'            AS SHORT_CODE,
                                             'SMS_CAMPAIGN_CD'       AS SMS_CAMPAIGN_CD,
                                             'SMS_PPE_TEXT'          AS SMS_PPE_TEXT,
                                             'SMS_TEXT_TEMPLATE'     AS SMS_TEXT_TEMPLATE,
                                             'SMS_VENDOR_OBJID'      AS SMS_VENDOR_OBJID,
                                             'TRIGGER_ID'            AS TRIGGER_ID))),
                  (SELECT i_service_plan     SP_MKT_NAME,
                          i_udf1             UDF1,
                          i_udf2             UDF2,
                          i_udf3             UDF3,
                          i_udf4             UDF4,
                          i_udf5             UDF5,
                          i_udf6             UDF6,
                          i_udf7             UDF7,
                          i_udf8             UDF8,
                          i_udf9             UDF9,
                          i_err_num          OUT_ERR_NUM,
                          i_err_msg          OUT_ERR_MSG
                     FROM dual);

  RETURN rcur;

END get_rtc_event_data;
--------------------------------------------------------------------------------
FUNCTION is_cust_not_lrp_enrolled (i_payload_msg   IN   q_payload_t,
                                   i_number_days   IN   NUMBER DEFAULT 30)
RETURN BOOLEAN IS

  -- CR54384 - param i_number_days for 30 days or more between activation and redemption.

  v_is_not_lrp_enrolled   VARCHAR2(1) := 'N';
  v_action_type           VARCHAR2(20);
  v_web_user_id           NUMBER;
  v_ct_objid              NUMBER;

BEGIN

  FOR i IN 1..i_payload_msg.nameval.COUNT LOOP

    IF i_payload_msg.nameval(i).fld = 'ACTION_TYPE' THEN
      v_action_type := i_payload_msg.nameval(i).val;      --Action_Type
    ELSIF i_payload_msg.nameval(i).fld = 'CT_OBJID' THEN
      v_ct_objid    := i_payload_msg.nameval(i).val;      --CT Obj_ID
    END IF;

  END LOOP;

  -- CR54384 - In search for the web account not enrolled in LRP associated with ESN with current redemption card processed.
  -- C92315  - CO implemented on code to correct mapping on AND rpx.web_account_id = TO_CHAR(twu.objid) constraint
  BEGIN
    SELECT CASE WHEN (SELECT TRUNC(ct.x_transact_date) - TRUNC(MIN(cta.x_transact_date))
                        FROM sa.table_x_call_trans cta
                        WHERE cta.x_service_id = ct.x_service_id
                          AND cta.x_min = ct.x_min
                          AND cta.x_result = 'Completed'
                          AND cta.x_action_type = '1') >= i_number_days
                THEN (CASE WHEN (SELECT MIN(rpx.objid)
                                   FROM sa.x_reward_benefit rpx,
                                        sa.x_reward_benefit_program rbp
                                  WHERE rbp.program_name = rpx.program_name
                                    AND rpx.account_status = 'ENROLLED'
                                    AND rpx.benefit_owner = 'ACCOUNT'
                                    AND rpx.benefit_type_code = 'LOYALTY_POINTS'
                                    AND rbp.program_name = 'LOYALTY_PROGRAM'
                                    AND rpx.brand = ct.x_sub_sourcesystem
                                    AND rpx.web_account_id = TO_CHAR(twu.objid)) IS NULL
                           THEN (CASE WHEN (SELECT MAX(rowid)
                                              FROM sa.q_payload_log
                                             WHERE event_name = 'REWARD_BENEFIT'
                                               AND brand = ct.x_sub_sourcesystem
                                               AND min = ct.x_min
                                               AND esn = ct.x_service_id) IS NULL
                                      THEN 'Y'
                                      ELSE 'N'
                                 END)
                           ELSE 'N'
                      END)
                ELSE 'N'
           END is_not_lrp_enrolled,
           twu.objid web_user_objid
      INTO v_is_not_lrp_enrolled,
           v_web_user_id
      FROM sa.table_part_inst pi,
           sa.table_mod_level ml,
           sa.table_part_num pn,
           sa.table_bus_org bo,
           sa.table_x_call_trans ct,
           sa.table_x_contact_part_inst cpi,
           sa.table_web_user twu
     WHERE twu.web_user2bus_org     = bo.objid
       AND twu.web_user2contact     = cpi.x_contact_part_inst2contact
       AND cpi.x_contact_part_inst2part_inst = pi.objid
       AND ct.x_sub_sourcesystem    = bo.org_id
       AND bo.objid                 = pn.part_num2bus_org
       AND pn.domain                = 'PHONES'
       AND pn.objid                 = ml.part_info2part_num
       AND pn.domain                = pi.x_domain
       AND ml.objid                 = pi.n_part_inst2part_mod
       AND pi.part_serial_no        = ct.x_service_id
       AND ct.x_result              = 'Completed'
       AND ct.x_sub_sourcesystem    = i_payload_msg.brand
       AND ct.x_action_type         = v_action_type
       AND ct.x_min                 = i_payload_msg.min
       AND ct.x_service_id          = i_payload_msg.esn
       AND ct.objid                 = v_ct_objid;
  EXCEPTION
    WHEN OTHERS THEN
      v_is_not_lrp_enrolled := 'N';
      v_web_user_id         := NULL;
  END;

  IF NVL(v_is_not_lrp_enrolled,'N') = 'N' THEN
    RETURN FALSE;
  ELSE              --CR54384 - YES=TRUE - Customer is not enrolled and message should be sent.
    RETURN TRUE;
  END IF;

END is_cust_not_lrp_enrolled;
--------------------------------------------------------------------------------
END rtc_pkg;
/