CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_FRAUD_PKG"
AS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_FRAUD_PKB.sql,v $
--$Revision: 1.5 $
--$Author: hcampano $
--$Date: 2014/06/04 17:39:59 $
--$ $Log: ADFCRM_FRAUD_PKB.sql,v $
--$ Revision 1.5  2014/06/04 17:39:59  hcampano
--$ Change to Fraud Pkg forTAS_2013_03B rollout
--$
--$ Revision 1.4  2014/06/02 13:27:25  mmunoz
--$ TAS_2014_03B
--$
--------------------------------------------------------------------------------------------
FUNCTION cancel_risk_alerts(
    ip_user_objid NUMBER,
    ip_esn_objid  NUMBER)
  RETURN VARCHAR2
AS
  v_title VARCHAR2(200):='Risk Assessment Alert';
BEGIN

  delete  sa.table_alert
  WHERE Alert2contract = ip_esn_objid
  AND title            = v_title;

  COMMIT;

  RETURN 'Alert removed';

END;
FUNCTION create_risk_alerts(
    ip_user_objid NUMBER,
    ip_esn_objid  NUMBER)
  RETURN VARCHAR2
AS
  v_active      NUMBER  :=1;
  v_type        VARCHAR2(10):='SQL';
  v_title       VARCHAR2(200):='Risk Assessment Alert';
  v_alert_text  VARCHAR2(200):='Please contact ext 3001 to resolve issue.';
  v_web_text_en VARCHAR2(200);
  v_web_text_sp VARCHAR2(200);
  v_hot         NUMBER:=0;
  v_cancel_sql  VARCHAR2(200):='select count(*) from sa.table_part_inst where part_serial_no = :esn and x_domain = ''PHONES'' and x_part_inst_status <> ''56''  and sysdate between :start_date and :end_date';
  v_objid       NUMBER;
BEGIN

  delete sa.table_alert
  WHERE Alert2contract = ip_esn_objid
  AND title            = v_title;

  select sa.seq('alert') into v_objid from dual;
  INSERT
  INTO table_alert
    (
      objid,
      alert_text,
      start_date,
      end_date,
      active,
      title,
      hot,
      last_update2user,
      alert2contract,
      modify_stmp,
      x_web_text_english,
      x_web_text_spanish,
      type,
      X_Cancel_Sql
    )
    VALUES
    (
      v_objid,
      v_alert_text,
      sysdate,
      to_date('31-dec-2055'),
      v_active,
      v_title,
      v_hot,
      ip_user_objid,
      ip_esn_objid,
      sysdate,
      v_web_text_en,
      v_web_text_sp,
      v_type,
      v_cancel_sql
    );
  COMMIT;
  RETURN 'Alert created: '||v_objid;
END;

FUNCTION create_risk_alerts2(
    ip_user_objid NUMBER,
    ip_esn  VARCHAR2)
  RETURN VARCHAR2
AS

  cursor c1 is
  select objid from table_part_inst
  where part_serial_no = ip_esn
  and x_domain = 'PHONES';
  r1 c1%rowtype;

  v_result varchar2(100);
BEGIN

  open c1;
  fetch c1 into r1;
  if c1%found then
     v_result:=create_risk_alerts(Ip_User_Objid=>ip_user_objid,Ip_esn_objid=>r1.objid);
  end if;
  close c1;
  return v_result;

END;

FUNCTION set_status_risk_assessment
  (
    ip_esn        VARCHAR2,
    ip_user_objid VARCHAR2
  )
  RETURN VARCHAR2
IS
  v_reason  VARCHAR2(30):='STATUS CHANGE';
  v_output  VARCHAR2(200);
  v_message VARCHAR2(200);
  ra_objid  VARCHAR2(20);
  ra_code   VARCHAR2(20);
  ra_desc   VARCHAR2(200);
  v_return  VARCHAR2(30);
  CURSOR cur_esn
  IS
    SELECT x_part_inst_status,
      objid
    FROM table_part_inst
    WHERE part_serial_no = ip_esn
    AND x_domain         = 'PHONES';
  rec_esn cur_esn%rowtype;
BEGIN
  SELECT objid,
    x_code_number,
    x_code_name
  INTO ra_objid,
    ra_code,
    ra_desc
  FROM table_x_code_table
  WHERE x_code_name = 'RISK ASSESMENT'
  AND x_code_type   = 'PS';
  OPEN cur_esn;
  FETCH cur_esn INTO rec_esn;
  IF cur_esn%found THEN
    IF rec_esn.x_part_inst_status NOT IN ('51','53','54','50','150') THEN
      CLOSE cur_esn;
      v_message := 'The Status Change you are trying is not allowed.';
      RETURN v_message;
    END IF;
    UPDATE table_part_inst
    SET x_part_inst_status = ra_code,
      STATUS2X_CODE_TABLE  = ra_objid
    WHERE part_serial_no   = ip_esn
    AND x_domain           = 'PHONES';
    sa.INSERT_PI_HIST_PRC( IP_USER_OBJID => ip_user_objid, IP_MIN => ip_esn, IP_OLD_NPA => '', IP_OLD_NXX => '', IP_OLD_EXT => '', IP_REASON => v_reason, IP_OUT_VAL => v_output);
    v_message := 'Phone changed to Risk Assessment';
  END IF;
  CLOSE cur_esn;
  COMMIT;
  v_return := ADFCRM_FRAUD_PKG.create_risk_alerts(ip_user_objid,rec_esn.objid);
  RETURN v_message;
END;
FUNCTION set_status_used(
    ip_esn          VARCHAR2,
    ip_user_objid   VARCHAR2,
    ip_zero_out_max VARCHAR2)
  RETURN VARCHAR2
IS
  v_reason  VARCHAR2(30):='STATUS CHANGE';
  v_output  VARCHAR2(200);
  v_message VARCHAR2(200);
  ra_objid  VARCHAR2(20);
  ra_code   VARCHAR2(20);
  ra_desc   VARCHAR2(200);
  v_return  VARCHAR2(30);
  CURSOR cur_esn
  IS
    SELECT x_part_inst_status,
      objid
    FROM table_part_inst
    WHERE part_serial_no = ip_esn
    AND x_domain         = 'PHONES';
  rec_esn cur_esn%rowtype;
BEGIN
  SELECT objid,
    x_code_number,
    x_code_name
  INTO ra_objid,
    ra_code,
    ra_desc
  FROM table_x_code_table
  WHERE x_code_name = 'USED'
  AND x_code_type   = 'PS';
  OPEN cur_esn;
  FETCH cur_esn INTO rec_esn;
  IF cur_esn%found THEN
    IF rec_esn.x_part_inst_status NOT IN ('55','56') THEN
      CLOSE cur_esn;
      v_message := 'This Phone Does not have a status that allows it to be Reset.';
      RETURN v_message;
    END IF;
    UPDATE table_part_inst
    SET x_part_inst_status = ra_code,
      STATUS2X_CODE_TABLE  = ra_objid
    WHERE part_serial_no   = ip_esn
    AND x_domain           = 'PHONES';
    sa.INSERT_PI_HIST_PRC( IP_USER_OBJID => ip_user_objid, IP_MIN => ip_esn, IP_OLD_NPA => '', IP_OLD_NXX => '', IP_OLD_EXT => '', IP_REASON => v_reason, IP_OUT_VAL => v_output);
    v_message := 'Phone reset to Used.';
  END IF;
  CLOSE cur_esn;
  IF ip_zero_out_max='1' THEN
    INSERT
    INTO table_x_zero_out_max
      (
        objid,
        x_esn,
        x_req_date_time,
        x_sourcesystem,
        x_deposit,
        x_transaction_type,
        x_zero_out2user
      )
      VALUES
      (
        sa.seq('x_zero_out_max'),
        ip_esn,
        sysdate,
        'TAS',
        0,5,
        ip_user_objid
      );
  END IF;
  COMMIT;
  v_return := ADFCRM_FRAUD_PKG.cancel_risk_alerts(ip_user_objid,rec_esn.objid);
  RETURN v_message;
END;
FUNCTION create_ttv
  (
    ip_esn          VARCHAR2,
    ip_user_objid   VARCHAR2
  )
  RETURN VARCHAR2
IS
BEGIN

    INSERT
    INTO table_x_zero_out_max
      (
        objid,
        x_esn,
        x_req_date_time,
        x_sourcesystem,
        x_deposit,
        x_transaction_type,
        x_zero_out2user
      )
      VALUES
      (
        sa.seq('x_zero_out_max'),
        ip_esn,
        sysdate,
        'TAS',
        0,5,
        ip_user_objid
      );
    RETURN 'TTV request created';

END;

FUNCTION clear_time_tank(
    ip_esn          VARCHAR2,
    ip_user_objid   VARCHAR2)
  RETURN VARCHAR2 IS

   CURSOR c_esn
   IS
      SELECT part_serial_no
        FROM table_part_inst pi, table_mod_level ml, table_part_num pn
       WHERE x_part_inst_status IN ('54', '51')
         AND x_domain || '' = 'PHONES'
         AND x_clear_tank = 0  -- not flagged
         AND pi.n_part_inst2part_mod = ml.objid
         AND ml.part_info2part_num = pn.objid
         AND pi.part_serial_no = ip_esn
         AND nvl(pn.x_dll,0) >= 10;
   r_esn c_esn%rowtype;

   CURSOR c_max_esn_exists
   IS
      SELECT 'X'
        FROM table_x_zero_out_max
       WHERE x_esn = ip_esn
         AND x_reac_date_time IS NULL
         AND x_transaction_type = 2;

   r_max_esn_exists c_max_esn_exists%rowtype;

BEGIN

   open c_esn;
   fetch c_esn into r_esn;
   if c_esn%found then

      UPDATE table_part_inst
      SET x_clear_tank = 1
      WHERE part_serial_no = ip_esn
      AND x_domain = 'PHONES'
      AND x_part_inst_status || '' IN ('54', '51');

      open c_max_esn_exists;
      fetch c_max_esn_exists into r_max_esn_exists;
      if c_max_esn_exists%notfound then
         INSERT INTO table_x_zero_out_max (objid, x_esn, X_Sourcesystem, x_req_date_time, x_transaction_type )
         VALUES (seq ('x_zero_out_max'), ip_esn, 'TAS', SYSDATE, 2 );
      end if;
      close c_max_esn_exists;

   end if;
   close c_esn;
   commit;

   return 'SUCCESS';

   exception
      when others then
         return 'ERROR: '||SQLERRM;

END;


END ADFCRM_FRAUD_PKG;
/