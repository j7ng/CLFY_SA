CREATE OR REPLACE TRIGGER sa."TRIG_RTC_ACTIVATION" BEFORE
UPDATE OR INSERT ON sa.TABLE_X_CALL_TRANS
REFERENCING OLD AS OLD NEW AS NEW  -- missed
FOR EACH ROW
DISABLE DECLARE p_esn table_x_call_trans.x_service_id%type;
  p_min table_x_call_trans.x_min%type;
  p_bus_org table_x_call_trans.x_sub_sourcesystem%type;
  p_event table_x_call_trans.x_action_text%type;
  p_msg_string  VARCHAR2(200);
  p_priority    NUMBER;
  p_expiry      NUMBER;
  p_queue       VARCHAR2(200);
  p_ex_queue    VARCHAR2(200);
  p_correlation VARCHAR2(200);
  out_err_num   NUMBER;
  out_err_msg   VARCHAR2(200);
  c             customer_type := customer_type ();
BEGIN

  IF :NEW.x_action_type <> '1' THEN
    RETURN;
  END IF;

  -- get the brand
  c.bus_org_id := c.get_bus_org_id ( i_esn => :NEW.x_service_id );

  -- return when NET10
  IF c.bus_org_id NOT IN ( 'NET10' , 'STRAIGHT_TALK' ) THEN
    RETURN;
  END IF;

    -----------------------------------------------------------------------------------------------------------------------------------
    IF (UPDATING
            AND ( ( :old.x_min LIKE 'T%' AND :new.x_min NOT LIKE 'T%' AND :old.x_result = 'Completed')
                OR( :old.x_result != 'Completed' AND :new.x_result = 'Completed' AND :old.x_min NOT LIKE 'T%')
                OR( :old.x_min LIKE 'T%' AND :new.x_min NOT LIKE 'T%' AND :old.x_result != 'Completed' AND :new.x_result = 'Completed' )
                )
          OR
          (INSERTING AND :new.x_min NOT LIKE 'T%' AND :new.x_result = 'Completed')
       )
    THEN
      -----------------------------------------------------------------------------------------------------------------------------------
      p_event       := 'ACTIVATION';
      p_bus_org     := :new.x_sub_sourcesystem;
      p_min         := :new.x_min;
      p_priority    := 0;
      p_expiry      := 86400;
      p_queue       := 'SA.RTC_queue';
      p_ex_queue    := 'SA.RTC_Exception_Queue';
      p_correlation := 'RTC_Queue';
      IF inserting THEN
        p_esn := :new.x_service_id;
      ELSE
        p_esn := :old.x_service_id;
      END IF;
      p_msg_string := (p_event || ',' || p_esn || ',' || p_min || ',' || p_bus_org || ',' || '');
      sa.rtc_pkg.enqueue(p_msg_string,p_priority,p_expiry,p_queue,p_ex_queue,p_correlation,out_err_num,out_err_msg);
    -----------------------------------------------------------------------------------------------------------------------------------
    END IF;
    -----------------------------------------------------------------------------------------------------------------------------------
 EXCEPTION
   WHEN OTHERS THEN
     NULL;
END;
/