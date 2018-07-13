CREATE OR REPLACE PROCEDURE sa."SP_UPDATE_DO_NOT_CALL_PHONE"
  (IP_START_DATE      DATE)
  AS
  LV_COUNT                PLS_INTEGER := 0;
  LV_CASE_TYPE            sa.TABLE_X_CASE_CONF_HDR.X_CASE_TYPE%type;
  LV_TITLE                sa.TABLE_X_CASE_CONF_HDR.X_TITLE%type;
  LV_X_VALUE              sa.TABLE_X_PARAMETERS.X_PARAM_VALUE%type;
  LV_STATUS               VARCHAR2(2000);
  LV_MSG                  VARCHAR2(2000);
  P_ERROR_NO              VARCHAR2(2000);
  P_ERROR_STR             VARCHAR2(2000);
  LV_C_UPDATE_COUNT       PLS_INTEGER := 0;
  LV_USER_OBJID 		  sa.TABLE_USER.OBJID%TYPE;

BEGIN
  DBMS_OUTPUT.PUT_LINE('Start of SA.SP_UPDATE_DO_NOT_CALL_PHONE');
  BEGIN
    SELECT  CH.X_CASE_TYPE
            , CH.X_TITLE
    INTO    LV_CASE_TYPE
            , LV_TITLE
    FROM    sa.TABLE_X_CASE_CONF_HDR CH
    WHERE   CH.OBJID IN (
                      SELECT P.X_PARAM_VALUE
                      FROM sa.TABLE_X_PARAMETERS P
                      WHERE P.X_PARAM_NAME = 'DO_NOT_CALL_PHONE_CASE_CONF_HDR_OBJID'
                      );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
  --DBMS_OUTPUT.PUT_LINE('LV_CASE_TYPE: '||LV_CASE_TYPE);
  --DBMS_OUTPUT.PUT_LINE('LV_TITLE: '||LV_TITLE);
  BEGIN
    SELECT  P.X_PARAM_VALUE
    INTO    LV_X_VALUE
    FROM    sa.TABLE_X_PARAMETERS P
    WHERE   P.X_PARAM_NAME = 'DO_NOT_CALL_PHONE_CASE_DETAIL_KEY_NAME';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  BEGIN
	  SELECT OBJID
	  INTO   LV_USER_OBJID
	  FROM   sa.TABLE_USER
	  WHERE  1=1
	  AND    S_LOGIN_NAME = 'SA';
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
  --DBMS_OUTPUT.PUT_LINE('LV_X_VALUE: '||LV_X_VALUE);
  FOR X IN (SELECT  C.OBJID, C.ID_NUMBER, C.CASE_REPORTER2CONTACT, CD.X_VALUE
            FROM    sa.TABLE_CASE C
                    , sa.TABLE_X_CASE_DETAIL CD
                    , sa.TABLE_CONDITION CON
            WHERE   C.CREATION_TIME > IP_START_DATE
            AND     C.S_TITLE = UPPER(LV_TITLE)
            AND     C.X_CASE_TYPE = LV_CASE_TYPE
            AND     C.OBJID = CD.DETAIL2CASE
            AND     TRIM(CD.X_NAME) = LV_X_VALUE
            AND     C.CASE_STATE2CONDITION = CON.OBJID
            AND     CON.S_TITLE != 'CLOSED'
            )
  LOOP
    --Update all records which have this phone number to null
    FOR Y IN (SELECT  *
              FROM    sa.TABLE_CONTACT C
              WHERE   PHONE = Regexp_replace(X.X_VALUE, '[^0-9]', '')
              )
    LOOP
      UPDATE  sa.TABLE_CONTACT C
      SET     PHONE = NULL
              , X_NO_PHONE_FLAG = 1
              , UPDATE_STAMP = SYSDATE
      WHERE   C.OBJID = Y.OBJID;
      LV_C_UPDATE_COUNT := SQL%ROWCOUNT;
      LV_COUNT := LV_COUNT + LV_C_UPDATE_COUNT;

      UPDATE  sa.TABLE_X_CONTACT_ADD_INFO CAI
      SET     X_DO_NOT_PHONE = 1
      WHERE   CAI.ADD_INFO2CONTACT = Y.OBJID;
    END LOOP;

    IF LV_C_UPDATE_COUNT > 0  THEN
      sa.CLARIFY_CASE_PKG.LOG_NOTES(X.OBJID ,LV_USER_OBJID ,'Phone number removed' ,'System Added Notes: ' ,P_ERROR_NO ,P_ERROR_STR);
      sa.CREATE_CASE_PKG.SP_CLOSE_CASE(X.ID_NUMBER, 'SA', 'SP_UPDATE_DO_NOT_CALL_PHONE', NULL, LV_STATUS, LV_MSG);
    ELSE
      sa.CLARIFY_CASE_PKG.LOG_NOTES(X.OBJID ,LV_USER_OBJID ,'Case closed as phone number not found' ,'System Added Notes: ' ,P_ERROR_NO ,P_ERROR_STR);
      sa.CREATE_CASE_PKG.SP_CLOSE_CASE(X.ID_NUMBER, 'SA', 'SP_UPDATE_DO_NOT_CALL_PHONE', NULL, LV_STATUS, LV_MSG);
    END IF;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('No of records updated :'||LV_COUNT);
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('End of SA.SP_UPDATE_DO_NOT_CALL_PHONE');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END SP_UPDATE_DO_NOT_CALL_PHONE;
/