CREATE OR REPLACE PROCEDURE sa.enable_balance_simulator( in_esn              IN ig_transaction.esn%TYPE DEFAULT NULL,
                                                     in_voice_units       IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
                                                     in_text_units        IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
                                                     in_data_units        IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
                                                     in_free_voice_units  IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
                                                     in_free_text_units   IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
                                                     in_free_data_units   IN ig_transaction_buckets.bucket_balance%TYPE DEFAULT NULL,
                                                     op_balance_simulator OUT VARCHAR2) AS
  v_cnt NUMBER;
  v_x_param_value table_x_parameters.x_param_value%TYPE;
  v_device_type   VARCHAR2(30);
  stop_processing EXCEPTION;
  v_ota_objid     NUMBER;
  v_x_psms_ack_msg table_x_ota_ack.x_psms_ack_msg%TYPE;
  ecode NUMBER;
  emesg VARCHAR2(200);
  CURSOR c1 IS
    SELECT *
    FROM   (
                    SELECT   *
                    FROM     ig_transaction
                    WHERE    esn = in_esn
                    AND      order_type = 'BI'
                    ORDER BY creation_date DESC)
WHERE  ROWNUM = 1;

BEGIN
  SELECT count(*)
  INTO   v_cnt
  FROM   test_igate_esn
  WHERE  esn = in_esn
  AND    esn_type = 'C'; --Make sure its DATA ESN.
  IF v_cnt >= 1 THEN     --Count IF start
    SELECT x_param_value
    INTO   v_x_param_value
    FROM   table_x_parameters
    WHERE  x_param_name = 'ENABLE_BALANCE_SIMULATOR';

    --Make sure balance simulator flag is on
    IF v_x_param_value = 'TRUE' THEN
      SELECT sa.get_device_type(in_esn)
      INTO   v_device_type
      FROM   dual;

      v_x_psms_ack_msg := NVL(in_voice_units, 0) ||'-' ||NVL(in_text_units, 0) ||'-' ||NVL(in_data_units, 0);
      IF v_device_type = 'FEATURE_PHONE' THEN
        SELECT objid
        INTO   v_ota_objid
        FROM   table_x_ota_trans_dtl
        WHERE  x_ota_trans_dtl2x_ota_trans IN
               (
                      SELECT max(objid)
                      FROM   table_x_ota_transaction
                      WHERE  x_esn = in_esn)
        AND    x_action_type = 271;

        --  BEGIN
        merge
        INTO         sa.table_x_ota_ack s
        USING        dual
        ON (
                                  x_ota_ack2x_ota_trans_dtl = v_ota_objid)
        WHEN matched THEN
        UPDATE
        SET              x_units = in_voice_units,
                         x_sms_units = in_text_units,
                         x_data_units = in_data_units,
                         x_psms_ack_msg = v_x_psms_ack_msg
        WHERE            x_ota_ack2x_ota_trans_dtl = v_ota_objid
        WHEN NOT matched THEN
        INSERT
               (
                      objid,
                      x_ota_error_code,
                      x_ota_error_message,
                      x_ota_number_of_codes,
                      x_ota_codes_accepted,
                      x_units,
                      x_phone_sequence,
                      x_psms_ack_msg,
                      x_ota_ack2x_ota_trans_dtl,
                      x_service_end_dt,
                      x_sms_units,
                      x_data_units,
                      x_pre_units
               )
               VALUES
               (
                      sa.sequ_x_ota_ack.NEXTVAL,--objid
                      NULL,                     --x_ota_error_code
                      NULL,                     --x_ota_error_message
                      4,                        --x_ota_number_of_codes
                      1,                        --x_ota_codes_accepted
                      in_voice_units,           --x_units
                      NULL,                     --x_phone_sequence
                      v_x_psms_ack_msg,         --x_psms_ack_msg
                      v_ota_objid,              --x_ota_ack2x_ota_trans_dtl
                      NULL,                     --x_service_end_dt
                      in_text_units,            --x_sms_units
                      in_data_units,            --x_data_units
                      NULL                      --x_pre_units
               );

        --  END;
      ELSIF v_device_type IN ( 'BYOP', 'SMARTPHONE' ) THEN
        FOR i1 IN c1
        LOOP
          BEGIN
            merge
            INTO         ig_transaction_buckets s
            USING        dual
            ON ( transaction_id = i1.transaction_id
                AND bucket_id = 'VOICE')
            WHEN matched THEN
            UPDATE
            SET              --bucket_id = 'VOICE',
                             recharge_date = SYSDATE,
                             bucket_balance = in_voice_units,
                             bucket_value = in_voice_units,
                             direction = 'INBOUND'
            WHERE            transaction_id = i1.transaction_id
            AND              bucket_id = 'VOICE'
            WHEN NOT matched THEN
            INSERT
                   (
                          transaction_id,
                          bucket_id,
                          recharge_date,
                          bucket_balance,
                          bucket_value,
                          expiration_date,
                          direction
                   )
                   VALUES
                   (
                          i1.transaction_id,
                          'VOICE',
                          SYSDATE,
                          in_voice_units,
                          in_voice_units,
                          NULL,--expire_dt
                          'INBOUND'
                   );

            merge
            INTO         x_swb_tx_balance_bucket
            USING        dual
            ON ( balance_bucket2x_swb_tx=
                                      (
                                             SELECT min(objid)
                                             FROM   x_switchbased_transaction
                                             WHERE  x_sb_trans2x_call_trans =
                                                    (
                                                           SELECT max(objid)
                                                           FROM   table_x_call_trans
                                                           WHERE  x_service_id = in_esn
                                                           AND    x_action_type = '7'))
                  AND x_type='min' )
            WHEN matched THEN
            UPDATE
            SET              --x_type='min',
                             x_value=in_voice_units
            WHERE            balance_bucket2x_swb_tx=
                             (
                                    SELECT min(objid)
                                    FROM   x_switchbased_transaction
                                    WHERE  x_sb_trans2x_call_trans =
                                           (
                                                  SELECT max(objid)
                                                  FROM   table_x_call_trans
                                                  WHERE  x_service_id = in_esn
                                                  AND    x_action_type = '7')
            AND x_type='min')
            WHEN NOT matched THEN
            INSERT --INTO x_swb_tx_balance_bucket
            (       -- CR44729 called out attribute names below
            OBJID,
            BALANCE_BUCKET2X_SWB_TX,
            RECHARGE_DATE,
            X_TYPE,
            EXPIRATION_DATE,
            X_VALUE,
            BUCKET_DESC
            )
                   VALUES
                   (
                          sequ_x_balance_bucket.NEXTVAL,
                          (
                                 SELECT min(objid)
                                 FROM   x_switchbased_transaction
                                 WHERE  x_sb_trans2x_call_trans =
                                        (
                                               SELECT max(objid)
                                               FROM   table_x_call_trans
                                               WHERE  x_service_id = in_esn
                                               AND    x_action_type = '7')) ,--Call Trans Objid
                          NULL,
                          'min',
                          NULL,
                          in_voice_units,
                          NULL
                   );

            merge
            INTO         ig_transaction_buckets s
            USING        dual
            ON (
                                      transaction_id = i1.transaction_id
                                    AND  bucket_id = 'DATA')
            WHEN matched THEN
            UPDATE
            SET              --bucket_id = 'DATA',
                             recharge_date = SYSDATE,
                             bucket_balance = decode(i1.template,
                                                     'TMOBILE', in_data_units,
                                                     in_data_units * 1024 ),
                             bucket_value = decode(i1.template,
                                                   'TMOBILE', in_data_units ,
                                                   in_data_units * 1024 ),
                             direction = 'INBOUND'
            WHERE            transaction_id = i1.transaction_id
            AND               bucket_id = 'DATA'
            WHEN NOT matched THEN
            INSERT --INTO ig_transaction_buckets
                   (
                          transaction_id,
                          bucket_id,
                          recharge_date,
                          bucket_balance,
                          bucket_value,
                          expiration_date,
                          direction
                   )
                   VALUES
                   (
                          i1.transaction_id,
                          'DATA',
                          SYSDATE,
                          decode(i1.template,
                                 'TMOBILE', in_data_units,
                                 in_data_units * 1024),
                          decode(i1.template,
                                 'TMOBILE', in_data_units,
                                 in_data_units * 1024),
                          NULL,--expire_dt
                          'INBOUND'
                   );

            merge
            INTO         x_swb_tx_balance_bucket
            USING        dual
            ON (
                                      balance_bucket2x_swb_tx=
                                      (
                                             SELECT min(objid)
                                             FROM   x_switchbased_transaction
                                             WHERE  x_sb_trans2x_call_trans =
                                                    (
                                                           SELECT max(objid)
                                                           FROM   table_x_call_trans
                                                           WHERE  x_service_id = in_esn
                                                           AND    x_action_type = '7'))
                                      AND  x_type = decode(i1.template,'TMOBILE', 'mb', 'kb'))
            WHEN matched THEN
            UPDATE
            SET              --x_type=decode(i1.template,
                              --             'TMOBILE', 'mb',
                              --             'kb'),
                             x_value=in_data_units
            WHERE            balance_bucket2x_swb_tx=
                             (
                                    SELECT min(objid)
                                    FROM   x_switchbased_transaction
                                    WHERE  x_sb_trans2x_call_trans =
                                           (
                                                  SELECT max(objid)
                                                  FROM   table_x_call_trans
                                                  WHERE  x_service_id = in_esn
                                                  AND    x_action_type = '7')
                             AND  x_type = decode(i1.template,'TMOBILE', 'mb', 'kb'))
            WHEN NOT matched THEN
            INSERT --INTO x_swb_tx_balance_bucket
            (       -- CR44729 called out attribute names below
            OBJID,
            BALANCE_BUCKET2X_SWB_TX,
            RECHARGE_DATE,
            X_TYPE,
            EXPIRATION_DATE,
            X_VALUE,
            BUCKET_DESC
            )
                   VALUES
                   (
                          sequ_x_balance_bucket.NEXTVAL,
                          (
                                 SELECT min(objid)
                                 FROM   x_switchbased_transaction
                                 WHERE  x_sb_trans2x_call_trans =
                                        (
                                               SELECT max(objid)
                                               FROM   table_x_call_trans
                                               WHERE  x_service_id = in_esn
                                               AND    x_action_type = '7')) ,--Call Trans Objid
                          NULL,
                          decode(i1.template,
                                 'TMOBILE', 'mb',
                                 'kb'),
                          NULL,
                          in_data_units,
                          NULL
                   );

            merge
            INTO         ig_transaction_buckets s
            USING        dual
            ON (
                                      transaction_id = i1.transaction_id
                                    AND bucket_id = 'TEXT'
                                      )
            WHEN matched THEN
            UPDATE
            SET              --bucket_id = 'TEXT',
                             recharge_date = SYSDATE,
                             bucket_balance = in_text_units,
                             bucket_value = in_text_units,
                             direction = 'INBOUND'
            WHERE            transaction_id = i1.transaction_id
            AND              bucket_id = 'TEXT'
            WHEN NOT matched THEN
            INSERT --INTO ig_transaction_buckets
                   (
                          transaction_id,
                          bucket_id,
                          recharge_date,
                          bucket_balance,
                          bucket_value,
                          expiration_date,
                          direction
                   )
                   VALUES
                   (
                          i1.transaction_id,
                          'TEXT',
                          SYSDATE,
                          in_text_units,
                          in_text_units,
                          NULL,--expire_dt
                          'INBOUND'
                   );

            merge
            INTO         x_swb_tx_balance_bucket
            USING        dual
            ON (
                                      balance_bucket2x_swb_tx=
                                      (
                                             SELECT min(objid)
                                             FROM   x_switchbased_transaction
                                             WHERE  x_sb_trans2x_call_trans =
                                                    (
                                                           SELECT max(objid)
                                                           FROM   table_x_call_trans
                                                           WHERE  x_service_id = in_esn
                                                           AND    x_action_type = '7'))
                                    AND x_type='msg')
            WHEN matched THEN
            UPDATE
            SET              --x_type='msg',
                             x_value=in_text_units
            WHERE            balance_bucket2x_swb_tx=
                             (
                                    SELECT min(objid)
                                    FROM   x_switchbased_transaction
                                    WHERE  x_sb_trans2x_call_trans =
                                           (
                                                  SELECT max(objid)
                                                  FROM   table_x_call_trans
                                                  WHERE  x_service_id = in_esn
                                                  AND    x_action_type = '7')
            AND x_type='msg' )
            WHEN NOT matched THEN
            INSERT --INTO x_swb_tx_balance_bucket
            (       -- CR44729 called out attribute names below
            OBJID,
            BALANCE_BUCKET2X_SWB_TX,
            RECHARGE_DATE,
            X_TYPE,
            EXPIRATION_DATE,
            X_VALUE,
            BUCKET_DESC
            )
                   VALUES
                   (
                          sequ_x_balance_bucket.NEXTVAL,
                          (
                                 SELECT min(objid)
                                 FROM   x_switchbased_transaction
                                 WHERE  x_sb_trans2x_call_trans =
                                        (
                                               SELECT max(objid)
                                               FROM   table_x_call_trans
                                               WHERE  x_service_id = in_esn
                                               AND    x_action_type = '7')) ,--Call Trans Objid
                          NULL,
                          'msg',
                          NULL,
                          in_text_units,
                          NULL
                   );

          EXCEPTION
          WHEN dup_val_on_index THEN
            NULL;
          END;
        END LOOP;
      END IF; --device type end if
    ELSE
      RAISE stop_processing;
    END IF; --param value end if
    op_balance_simulator := 'FAIL';
  ELSE
    RAISE stop_processing;
    op_balance_simulator := 'FAIL';
  END IF; --Count IF end
  COMMIT;
  op_balance_simulator := 'SUCCESSFUL';
EXCEPTION
WHEN stop_processing THEN
  Raise_application_error (-20001, 'We can not continue with the provided ESN');
  op_balance_simulator := 'FAIL';
WHEN OTHERS THEN
  ecode := SQLCODE;
  emesg := SQLERRM;
  op_balance_simulator := 'FAIL';
  INSERT INTO error_table
              (
                          error_text,
                          error_date,
                          action,
                          KEY,
                          program_name
              )
              VALUES
              (
                          ecode
                                      ||'-'
                                      ||emesg,
                          SYSDATE,
                          'Enable_balance_simulator',
                          in_esn,
                          'Enable_balance_simulator'
              );

  COMMIT;
END enable_balance_simulator;
/