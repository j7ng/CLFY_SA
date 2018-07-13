CREATE OR REPLACE PACKAGE BODY sa.RESET_PASSWORD AS
  PROCEDURE CREATE_PASSWORD(L_NAME IN VARCHAR2,PIN IN VARCHAR2, V_CODE OUT NUMBER,V_CODE_MSG OUT VARCHAR2,V_PASSWD OUT VARCHAR2) IS
    V_USER          TABLE_USER%ROWTYPE;
    V_EMP           TABLE_EMPLOYEE%ROWTYPE;
    V_TEMP2         VARCHAR2(10);
    V_TEMP1         NUMBER;
    V_ACCT          VARCHAR2(30);
    INACTIVE_USER   EXCEPTION;
    CONTACT_DBA     EXCEPTION;
  BEGIN
    SELECT  UPPER(ACCOUNT_STATUS) INTO V_ACCT 
    FROM    SYS.DBA_USERS
    WHERE   USERNAME = UPPER(L_NAME);
    
    IF UPPER(V_ACCT)  IN ('LOCKED','EXPIRED') THEN
        RAISE CONTACT_DBA;
    END IF;
    
    SELECT  * 
    INTO    V_USER  
    FROM    sa.TABLE_USER
    WHERE   S_LOGIN_NAME=UPPER(L_NAME);
    
    SELECT  * 
    INTO    V_EMP
    FROM    sa.TABLE_EMPLOYEE
    WHERE   EMPLOYEE2USER=V_USER.OBJID 
    AND     EMPLOYEE_NO=NVL(PIN,'NA');

    IF (V_USER.STATUS=0 AND V_EMP.S_LAST_NAME LIKE 'ZZ%' AND V_EMP.MAIL_STOP IS NOT NULL) THEN
        RAISE  INACTIVE_USER;
    END IF;
    IF UPPER(L_NAME)=V_USER.S_LOGIN_NAME AND PIN = V_EMP.EMPLOYEE_NO THEN
       /*   SELECT  ABS(ROUND(DBMS_RANDOM.VALUE(1111,9999))) INTO V_TEMP1 
          FROM    DUAL;
          SELECT  DBMS_RANDOM.STRING('L',4)  INTO V_TEMP2 
          FROM    DUAL;*/
          
           SELECT  DBMS_RANDOM.STRING('U',1)||CASE WHEN DBMS_RANDOM.VALUE(0, 1) <0.25 then '!' WHEN  DBMS_RANDOM.VALUE(0, 1)  BETWEEN 0.25 AND 0.5 THEN '*' ELSE '@' END || DBMS_RANDOM.STRING('L',1)||ABS(ROUND(DBMS_RANDOM.VALUE(11,99)))||DBMS_RANDOM.STRING('L',1)  ||
          ABS(ROUND(DBMS_RANDOM.VALUE(11,99))) INTO V_PASSWD FROM DUAL;
          /*
          V_PASSWD:=V_TEMP2||V_TEMP1; */
          V_CODE:=0;
          V_CODE_MSG:= 'User Password is reset to : '||V_PASSWD;
    END IF;    
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN    V_CODE:=2;
                               V_CODE_MSG:='The User is Not Found';
    RETURN;
    WHEN INACTIVE_USER THEN    V_CODE:=3;
                               V_CODE_MSG:='The User is Inactive';
    RETURN;
    WHEN CONTACT_DBA THEN  V_CODE:=9;
                               V_CODE_MSG:='Account is locked/expired on DB side.  Please contact DBA to unlock the account And then reset the password';
     RETURN;
  END;


  PROCEDURE RESET_PASSWD (L_NAME VARCHAR2, V_ENC_PASSWD VARCHAR2, V_CODE OUT NUMBER,V_CODE_MSG OUT VARCHAR2) IS
    BEGIN
      
        UPDATE TABLE_USER 
        SET   WEB_PASSWORD = V_ENC_PASSWD,
              WEB_LAST_LOGIN = SYSDATE,
              WEB_PASSWD_CHG ='01-JAN-1753',
              DEV = 1,
              STATUS = 1,
              SUBMITTER_IND = 0,
              USER2RC_CONFIG = 268436363
        WHERE S_LOGIN_NAME = UPPER(L_NAME);
        IF SQL%ROWCOUNT =1 THEN
            COMMIT;
            V_CODE:=0;
            V_CODE_MSG:='The Password is reset in Webcsr';
         ELSE
            V_CODE:=1;
            V_CODE_MSG:='Password is not reset. Please contact CRMAPPSSUPPORT';
         END IF;
     
      
    END;
END; 
/