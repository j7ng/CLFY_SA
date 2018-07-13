CREATE OR REPLACE TRIGGER sa."TRIG_RTC_ONACC_PWRESET" BEFORE
INSERT ON sa.table_web_user
REFERENCING OLD AS OLD NEW AS NEW  -- missed
FOR EACH ROW
DECLARE
  p_event       VARCHAR2(200);
  p_msg_string  VARCHAR2(200);
  p_priority    NUMBER;
  p_expiry      NUMBER;
  p_queue       VARCHAR2(200);
  p_ex_queue    VARCHAR2(200);
  p_correlation VARCHAR2(200);
  p_language   varchar2(100);
  out_err_num   NUMBER;
  out_err_msg   VARCHAR2(200);
  CURSOR cur_bus_org IS
    SELECT s_org_id
    FROM   table_bus_org bo
    WHERE  bo.objid = :NEW.web_user2bus_org;
  rec_bus_org     cur_bus_org%rowtype;
BEGIN

  -- CR41175 RTc is only working for NET10 added TELCEL as a part of defect fix
  IF :NEW.web_user2bus_org NOT IN ( 268438258, 536883543 ) THEN  ----> because RTC is on only for NET10 right now.
    RETURN;
  END IF;

  -- CR41175 RTc is only working for NET10 added TELCEL as a part of defect fix
  IF (:NEW.s_login_name LIKE '%@NET10.COM%' OR :NEW.s_login_name LIKE '%@SAFELINK.COM%' OR :NEW.s_login_name LIKE '%@TELCEL%COM%')
  THEN
    RETURN;
  END IF;

  IF sa.B2B_PKG.is_b2b('EMAIL',:NEW.s_login_name,NULL,out_err_num,out_err_msg) = 1
  THEN
    RETURN;
  END IF;

  --

     p_language := NVL(UPPER(:NEW.user_key),'ENGLISH');

    OPEN cur_bus_org;
    FETCH cur_bus_org INTO rec_bus_org;
    IF cur_bus_org%NOTFOUND THEN
      CLOSE cur_bus_org;
      RETURN;
    ELSE
      CLOSE cur_bus_org;
      p_event       := 'ONLINE_ACCT_CREATION';
      p_priority    := 0;
      p_expiry      := 86400;
      p_queue       := 'SA.RTC_queue';
      p_ex_queue    := 'SA.RTC_Exception_Queue';
      p_correlation := 'RTC_Queue';
      p_msg_string  := (p_event || ',' || '' || ',' || '' || ',' || rec_bus_org.s_org_id || ',' || :NEW.s_login_name||','||p_language);

      sa.rtc_pkg.enqueue ( p_msg_string  ,
                           p_priority    ,
                           p_expiry      ,
                           p_queue       ,
                           p_ex_queue    ,
                           p_correlation ,
                           out_err_num   ,
                           out_err_msg   );


    END IF;

 EXCEPTION
   WHEN OTHERS THEN
     --
     util_pkg.insert_error_tab ( i_action       => 'EXCEPTION',
                                 i_key          => :NEW.objid,
                                 i_program_name => 'TRIG_RTC_ONACC_PWRESET',
                                 i_error_text   => SQLERRM );

END;
/