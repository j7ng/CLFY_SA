CREATE OR REPLACE PROCEDURE sa."P_COMM_BY_TIMEZONE"
                                             (
                                              i_esn            IN  VARCHAR2,
                                              i_min            IN  VARCHAR2,
                                              i_sms_message    IN  VARCHAR2,
                                              i_source_system  IN  VARCHAR2,
                                              o_send_sms_flag  OUT VARCHAR2,
                                              o_err_code       OUT NUMBER,
                                              o_err_msg        OUT VARCHAR2
                                             )
IS
 v_zipcode         x_zip2time_zone.zip%TYPE;
 v_zip_timezone    x_zip2time_zone.timezone%TYPE;
 v_zip_time        DATE;
 v_schedule_time   DATE;
 v_min             VARCHAR2(50);
 v_esn             VARCHAR2(50);

BEGIN
----------------------------------------1
o_send_sms_flag := 'N';
o_err_code      := 0;
o_err_msg       := 'Success';

 --validations
 IF (i_esn IS NULL AND i_min IS NULL)
    OR
    i_sms_message IS NULL
 THEN --{
  o_send_sms_flag := '';
  o_err_code := 1;
  o_err_msg  := 'Invalid inputs';
  DBMS_OUTPUT.PUT_LINE(o_err_msg);
  RETURN;
 END IF; --}
----------------------------------------2

 IF i_min IS NULL
 THEN --{
  v_min := sa.util_pkg.get_min_by_esn(i_esn);
  v_esn := i_esn;
 ELSE
  v_esn := sa.util_pkg.get_esn_by_min(i_min);
  v_min := i_min;
 END IF; --}

 --Get time by zipcode
 BEGIN --{
  SELECT sa.convert_time_by_timezone(x_zipcode, SYSDATE, 'EST', NULL), x_zipcode
  INTO   v_zip_time, v_zipcode
  FROM   table_site_part outt
  WHERE  outt.x_min         = NVL(i_min, v_min)
  --AND    part_status   = 'Active'
  AND    outt.objid = (
                        SELECT MAX(inn.objid)
                        FROM   table_site_part inn
                        WHERE  inn.x_min         = NVL(i_min, v_min)
                      )
  AND    ROWNUM        = 1;
 EXCEPTION
 WHEN OTHERS THEN
  o_send_sms_flag := '';
  v_zipcode := NULL;
  o_err_code := 2;
  o_err_msg  := 'ESN/MIN not valid.';
  DBMS_OUTPUT.PUT_LINE(o_err_msg);
  RETURN;
 END; --}
----------------------------------------3
 --Wait if time is between 1 AM and 6 AM
 BEGIN --{
  SELECT 'N'
  INTO   o_send_sms_flag
  FROM   dual
  WHERE  v_zip_time BETWEEN
                           (TRUNC(v_zip_time) + (SELECT TO_NUMBER(x_param_value) FROM table_x_parameters WHERE x_param_name = 'RESTRICT_SMS_FROM_TIME')/24)
                            AND
                           (TRUNC(v_zip_time) + (SELECT TO_NUMBER(x_param_value) FROM table_x_parameters WHERE x_param_name = 'RESTRICT_SMS_TO_TIME')/24);
 EXCEPTION
 WHEN OTHERS THEN
  o_send_sms_flag := 'Y';
  RETURN;
 END; --}
----------------------------------------4
--Schedule SMS
 IF o_send_sms_flag = 'N'
 THEN --{

 BEGIN --{
  SELECT timezone
  INTO   v_zip_timezone
  FROM   x_zip2time_zone
  WHERE  zip    = v_zipcode
  AND    ROWNUM = 1;
 EXCEPTION
 WHEN OTHERS THEN
  o_send_sms_flag := '';
  v_zip_timezone := NULL;
  o_err_code := 3;
  o_err_msg  := 'Error while getting timezone for ESN: '||i_esn||' '||SQLERRM;
  DBMS_OUTPUT.PUT_LINE(o_err_msg);
  RETURN;
 END; --}

 BEGIN --{
  SELECT sa.convert_time_by_timezone(NULL, TRUNC(SYSDATE)+TO_NUMBER(x_param_value)/24, v_zip_timezone, 'EST')
  INTO   v_schedule_time
  FROM   table_x_parameters
  WHERE  x_param_name = 'SCHEDULE_SMS_TIME';
 EXCEPTION
 WHEN OTHERS THEN
  o_send_sms_flag := '';
  v_schedule_time := NULL;
  o_err_code := 4;
  o_err_msg  := 'Error while getting timezone for ESN: '||i_esn||' '||SQLERRM;
  DBMS_OUTPUT.PUT_LINE(o_err_msg);
  RETURN;
 END; --}

  BEGIN --{
   INSERT INTO table_customer_comm_stg
                                      (
                                      objid,
                                      esn,
                                      min,
                                      brand,
                                      sms_message,
                                      source_system,
                                      status,
                                      error_message,
                                      retry_count,
                                      insert_timestamp,
                                      update_timestamp,
                                      schedule_timestamp
                                      )
                                      (
                                      SELECT sa.seq_x_table_customer_comm_stg.NEXTVAL,
                                             NVL(i_esn, v_esn),
                                             NVL(i_min, v_min),
                                             sa.util_pkg.get_bus_org_id(NVL(i_esn,v_esn)),
                                             i_sms_message,
                                             NVL(i_source_system, 'BATCH'),
                                             'Q',
                                             NULL,
                                             0,
                                             SYSDATE,
                                             NULL,
                                             v_schedule_time
                                      FROM   dual
                                      );

  EXCEPTION
  WHEN OTHERS THEN
   o_send_sms_flag := '';
   o_err_code := 5;
   o_err_msg  := 'Error while queing the message for ESN: '||i_esn||' '||SQLERRM;
   DBMS_OUTPUT.PUT_LINE(o_err_msg);
  RETURN;
  END; --}
 END IF;--}
----------------------------------------
EXCEPTION
WHEN OTHERS THEN
 o_err_code := 6;
 o_err_msg  := 'In main exception of p_comm_by_timezone for: '||i_esn||' '||SQLERRM;
 DBMS_OUTPUT.PUT_LINE(o_err_msg);
 o_send_sms_flag := '';
 RETURN;
END;
/