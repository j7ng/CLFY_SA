CREATE OR REPLACE TRIGGER sa."TRG_CALL_TRANS_QUEUE_CARD"
  BEFORE INSERT
ON sa.TABLE_X_CALL_TRANS REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DISABLE DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;

  LV_ERROR_CODE         NUMBER := 0;
  LV_ERROR_MESSAGE      VARCHAR2(300):= NULL;
  LV_STEP               VARCHAR2(30) := NULL;
  LV_GROUP_ID           sa.X_ACCOUNT_GROUP_MEMBER.ACCOUNT_GROUP_ID%TYPE;
BEGIN

  IF :NEW.X_ACTION_TYPE = 401 THEN
    DBMS_OUTPUT.PUT_LINE('Start trigger TRG_CALL_TRANS_QUEUE_CARD');
    BEGIN
      SELECT  AGM.ACCOUNT_GROUP_ID GROUP_ID
      INTO    LV_GROUP_ID
      FROM    sa.X_ACCOUNT_GROUP_MEMBER AGM
      WHERE   AGM.ESN = NVL(:NEW.X_SERVICE_ID,:OLD.X_SERVICE_ID)
      AND     UPPER(AGM.STATUS) <> 'EXPIRED';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        LV_GROUP_ID := NULL;
    END;

    IF LV_GROUP_ID IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE('Step 1: Group id is not null');
      FOR GROUP_LOOP IN (SELECT  AGM.ESN,
                        AGM.MASTER_FLAG,
                        (
                          SELECT  PI_MIN.PART_SERIAL_NO
                          FROM    sa.TABLE_PART_INST PI_ESN,
                                  sa.TABLE_PART_INST PI_MIN
                          WHERE   PI_ESN.PART_SERIAL_NO = AGM.ESN
                          AND     PI_ESN.X_DOMAIN = 'PHONES'
                          AND     PI_MIN.PART_TO_ESN2PART_INST = PI_ESN.OBJID
                          AND     ROWNUM <2) MIN
                FROM    sa.X_ACCOUNT_GROUP_MEMBER AGM
                WHERE   AGM.ACCOUNT_GROUP_ID = LV_GROUP_ID
                AND     UPPER(AGM.STATUS) = 'ACTIVE')
      LOOP
        LV_ERROR_CODE := 0;
        LV_ERROR_MESSAGE := NULL;
        W3CI.THROTTLING.SP_EXPIRE_CACHE( GROUP_LOOP.MIN,
                                       GROUP_LOOP.ESN,
                                       LV_ERROR_CODE,
                                       LV_ERROR_MESSAGE,
                                       NULL,
                                       'TRG_CALL_TRANS_QUEUE_CARD');
        IF LV_ERROR_CODE != 0 THEN
          LV_STEP := 'Step1';
          LV_ERROR_MESSAGE := 'objid:'||:NEW.OBJID||':'||LV_ERROR_MESSAGE;
          sa.OTA_UTIL_PKG.ERR_LOG(  P_ACTION        => 'Error while invalidating cache'
                                   ,P_ERROR_DATE   => SYSDATE
                                   ,P_KEY          => GROUP_LOOP.ESN
                                   ,P_PROGRAM_NAME => 'TRG_CALL_TRANS_QUEUE_CARD'
                                   ,P_ERROR_TEXT   => 'LV_STEP - '||LV_STEP||'; LV_ERROR_CODE - '||LV_ERROR_CODE||';LV_ERROR_MESSAGE - '||LV_ERROR_MESSAGE);
        END IF;
      END LOOP;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Step 2: Group id is null');
      LV_ERROR_CODE := 0;
      LV_ERROR_MESSAGE := NULL;
      W3CI.THROTTLING.SP_EXPIRE_CACHE( :NEW.X_MIN,
                                     :NEW.X_SERVICE_ID,
                                     LV_ERROR_CODE,
                                     LV_ERROR_MESSAGE,
                                     NULL,
                                     'TRG_CALL_TRANS_QUEUE_CARD');
      IF LV_ERROR_CODE != 0 THEN
        LV_STEP := 'Step2';
        LV_ERROR_MESSAGE := 'objid:'||:NEW.OBJID||':'||LV_ERROR_MESSAGE;
        sa.OTA_UTIL_PKG.ERR_LOG(  P_ACTION        => 'Error while invalidating cache'
                                 ,P_ERROR_DATE   => SYSDATE
                                 ,P_KEY          => :NEW.X_SERVICE_ID
                                 ,P_PROGRAM_NAME => 'TRG_CALL_TRANS_QUEUE_CARD'
                                 ,P_ERROR_TEXT   => 'LV_STEP - '||LV_STEP||'; LV_ERROR_CODE - '||LV_ERROR_CODE||';LV_ERROR_MESSAGE - '||LV_ERROR_MESSAGE);
      END IF;
    END IF;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('End trigger TRG_CALL_TRANS_QUEUE_CARD');
  END IF;

EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
  sa.OTA_UTIL_PKG.ERR_LOG(P_ACTION  => 'Generic Error while expiring a cache'
                                ,P_ERROR_DATE   => SYSDATE
                               ,P_KEY          => :NEW.OBJID
                               ,P_PROGRAM_NAME => 'TRG_CALL_TRANS_QUEUE_CARD'
                               ,P_ERROR_TEXT   => 'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE());
END;
/