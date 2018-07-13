CREATE OR REPLACE PROCEDURE sa."SP_SIMOUT_FRAUD_CHECK" (
      i_source_system         IN      VARCHAR2,
      i_store_id              IN      VARCHAR2,
      i_terminal_id           IN      VARCHAR2,
      o_result_code           OUT     VARCHAR2,
      o_result_msg            OUT     VARCHAR2,
      o_esn_count             OUT     VARCHAR2,
      o_last_register_time    OUT     VARCHAR2,
      o_fraud_alert           OUT     VARCHAR2,
      o_fraud_alert_to_add    OUT     VARCHAR2,
      o_fraud_alert_subj      OUT     VARCHAR2,
      o_store_details         OUT     VARCHAR2,
      o_simout_log            OUT     SYS_REFCURSOR)
AS
--
/**********************************************************************************************/
/* */
/* Name : sp_fraud_check */
/* */
/* Purpose : Checks whether there are more than stipulated no of esns registered within the  */
/*           configured time frame. */
--
/* VERSION DATE WHO PURPOSE */
/* ------- ---------- ----- -------------------------------------------- */
/* 1.0 Initial Revision */
/**********************************************************************************************/
--
CURSOR c_simout_conf
IS
SELECT  *
FROM    simoutconfrules
WHERE   sourcesystem  = i_source_system
AND     rownum < 2;
--
simout_conf_rec    c_simout_conf%ROWTYPE;
--
CURSOR c_store_details
IS
SELECT *
FROM   table_store_details
WHERE  store_id   =    i_store_id
AND     rownum < 2;
--
store_details_rec   c_store_details%ROWTYPE;
--
out_simout_log_tab  sa.simout_log_tab ;
--
BEGIN
--
  SELECT sa.simout_log_obj ( '','','','','','','','','','','','','','','')
  BULK COLLECT
  INTO out_simout_log_tab
  FROM dual;
  --
  OPEN o_simout_log
  FOR
  SELECT *
  FROM TABLE (CAST(out_simout_log_tab AS sa.simout_log_tab )) ;
  --
  --
  OPEN c_simout_conf;
  FETCH c_simout_conf INTO simout_conf_rec;
  IF c_simout_conf%found THEN
    CLOSE c_simout_conf;
  ELSE
    CLOSE c_simout_conf;
    o_result_code   :=  '100';
    o_result_msg    :=  'Invalid Source System';
    RETURN;
  END IF;
  --
  IF i_store_id IS NULL
  THEN
    o_result_code   :=  '110';
    o_result_msg    :=  'Store ID cannot be null';
    RETURN;
  END IF;
  --
  OPEN c_store_details;
  FETCH c_store_details INTO store_details_rec;
  IF c_store_details%found THEN
    CLOSE c_store_details;
    --
    SELECT  store_details_rec.Vendor_name   || ' '  || chr(10) ||
            store_details_rec.store_name    || ' '  || chr(10) ||
            store_details_rec.store_address || ' '  || chr(10) ||
            store_details_rec.store_city    || ', ' || store_details_rec.store_state_cd || ' ' || store_details_rec.store_zip_cd || ' ' || chr(10) ||
            'Phone: ' || store_details_rec.store_phone_no
    INTO    o_store_details
    FROM    dual;
    --
  ELSE
    CLOSE c_store_details;
  END IF;
  --
  o_fraud_alert         :=    simout_conf_rec.fraud_alert_chk;
  o_fraud_alert_to_add  :=    simout_conf_rec.fraud_alert_to_add;
  o_fraud_alert_subj    :=    simout_conf_rec.fraud_alert_subj;
  --
  SELECT  to_char(to_date(MAX (insert_date), 'DD-MON-YYYY HH24:MI:SS'))
  INTO    o_last_register_time
  FROM    simout_log
  WHERE   store_id             = i_store_id
  AND     NVL(terminal_id, 0)  = NVL(i_terminal_id,0)
  AND     insert_date > SYSTIMESTAMP - (simout_conf_rec.time_interval/1440);
  --
  SELECT sa.simout_log_obj (client_trans_id,
                            client_id      ,
                            esn            ,
                            sim            ,
                            brand          ,
                            source_system  ,
                            dealer_id      ,
                            store_id       ,
                            terminal_id    ,
                            phone_make     ,
                            phone_model    ,
                            retry_flag     ,
                            vd_trans_id    ,
                            to_char(insert_date, 'DD-MON-YYYY  HH24:MI:SS'),
                            register_status
                            )
  BULK COLLECT
  INTO   out_simout_log_tab
  FROM   simout_log sl
  WHERE  sl.store_id             = i_store_id
  AND    NVL(sl.terminal_id, 0)  = NVL(i_terminal_id,0)
  AND    sl.insert_date > (SYSTIMESTAMP - (simout_conf_rec.time_interval/1440))
  AND    sl.insert_date  =  (SELECT MAX(sol.insert_date)
                             FROM   simout_log  sol
                             WHERE  sol.store_id              = sl.store_id
                             AND    NVL(sol.terminal_id, 0)   = NVL(sl.terminal_id, 0)
                             AND    sol.esn                   = sl.esn)
  ORDER BY insert_date ;
  --
  DBMS_OUTPUT.PUT_LINE('After fetching data ');
  --
  IF out_simout_log_tab.count >= simout_conf_rec.esn_count
  THEN
    -- Move the Data from the Object to the Cursor
    OPEN o_simout_log
    FOR
    SELECT *
    FROM TABLE (CAST(out_simout_log_tab AS sa.simout_log_tab )) ;
    --
    o_esn_count       :=  out_simout_log_tab.count;
    --
  ELSIF out_simout_log_tab.count = 0
  THEN
    --
    o_esn_count       :=  out_simout_log_tab.count;
    o_fraud_alert     :=  'N';
    o_result_code     :=  '200';
    o_result_msg      :=  'No Phones Registered within the last ' ||simout_conf_rec.time_interval || ' Minutes';
    RETURN;
    --
  ELSE
    -- Move the Data from the Object to the Cursor
    OPEN o_simout_log
    FOR
    SELECT *
    FROM TABLE (CAST(out_simout_log_tab AS sa.simout_log_tab )) ;
    --
    o_esn_count       :=  out_simout_log_tab.count;
    o_fraud_alert     :=  'N';
    o_result_code     :=  '300';
    o_result_msg      :=  'Only ' || out_simout_log_tab.count || ' Phones Registered within last ' ||
                          simout_conf_rec.time_interval || ' Minutes';
    RETURN;
    --
  END IF;
  --
  o_result_code   :=  0;
  o_result_msg    :=  'SUCCESS';
--
EXCEPTION
WHEN OTHERS THEN
  o_result_code   :=  500;
  o_result_msg    :=  'Failed in when others ' || SQLERRM;
END sp_simout_fraud_check;
/