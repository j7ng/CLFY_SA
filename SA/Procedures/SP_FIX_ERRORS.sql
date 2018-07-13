CREATE OR REPLACE PROCEDURE sa."SP_FIX_ERRORS"
(ESN_IN IN VARCHAR2, ERROR_IN IN VARCHAR2, BRAND IN VARCHAR2, RESULTS OUT VARCHAR2) IS
/*  PROCEDURE TO CHECK/FIX COMMON DATA ISSUES SPECIFIC TO TRACFONE/NET10 PHONES */
/*                                                                              */
/*  AUTHOR              :   SRINIVAS C KARUMURI                                 */
/*  DEVELOPED ON        :   MAY 10, 2011                                        */
/*  INPUT   PARAMETERS  :   ESN, ERROR                                          */
/*  OUTPUT  PARAMETERS  :   MESSAGE TO THE AGENT                                */
    CURSOR  C_PART_INST IS
        SELECT  PI.PART_SERIAL_NO, PI.X_PART_INST_STATUS,
                PI.X_PART_INST2CONTACT CONTACT,
                PN.PART_NUMBER, PN.PART_NUM2BUS_ORG, PN.X_TECHNOLOGY
        FROM    sa.TABLE_PART_INST PI, sa.TABLE_MOD_LEVEL ML, sa.TABLE_PART_NUM PN
        WHERE   PI.PART_SERIAL_NO = ESN_IN
        AND     PI.N_PART_INST2PART_MOD = ML.OBJID
        AND     ML.PART_INFO2PART_NUM = PN.OBJID;
    C_ESN   C_PART_INST%ROWTYPE;

    CURSOR  C_SITE_PART (LINE IN VARCHAR2) IS
        SELECT  OBJID, X_SERVICE_ID, X_MIN, PART_STATUS, INSTALL_DATE, X_EXPIRE_DT
        FROM    sa.TABLE_SITE_PART
        WHERE   X_MIN = LINE
        AND     PART_STATUS||'' = 'Active';
    C_SP   C_SITE_PART%ROWTYPE;

    CURSOR  C_ACTIVE_ESN (ESN IN VARCHAR2) IS
        SELECT  PHONE.PART_SERIAL_NO ESN, PHONE.X_PART_INST_STATUS ESN_STATUS,
                LINE.PART_SERIAL_NO LINE, LINE.X_PART_INST_STATUS LINE_STATUS
        FROM    sa.TABLE_PART_INST LINE, sa.TABLE_PART_INST PHONE
        WHERE   LINE.PART_TO_ESN2PART_INST(+) = PHONE.OBJID
        AND     PHONE.X_PART_INST_STATUS||''='52'
        AND     PHONE.PART_SERIAL_NO = ESN
        AND     LINE.X_PART_INST_STATUS ||''='13'
        AND     PHONE.X_DOMAIN||''='PHONES'
        AND     LINE.X_DOMAIN = 'LINES' ;
    C_PI    C_ACTIVE_ESN%ROWTYPE;
    V_RESULT    VARCHAR2(5000);
    V_STATUS    VARCHAR2(100);
    V_ESN       VARCHAR2(30);
    V_MSG       VARCHAR2(200);
    V_MSG_CP    VARCHAR2(100);
    V_MULTI1    VARCHAR2(30);
    V_MULTI2    VARCHAR2(30);
    V_MIN       VARCHAR2(25);
    V_MULTI_MSG VARCHAR2(200);
    V_NULL_RES  VARCHAR2(50);
    V_ERROR     VARCHAR2(500);
    V_OUTCOME   VARCHAR2(15);
    V_ACCOUNT   VARCHAR2(500);
    V_BRAND     VARCHAR2(30);

    V_SP_CNT    NUMBER;
    V_CONTACT   NUMBER;

    INACTIVE_PHONE  EXCEPTION;
    STOLEN_PHONE    EXCEPTION;
    RISK_PHONE      EXCEPTION;
    MULTI_PHONE     EXCEPTION;
    MESSAGE         VARCHAR2(5000);

    PROCEDURE LOG_MSG (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, MSG IN VARCHAR2, LOG_TYPE IN VARCHAR2) IS

    BEGIN
        INSERT INTO sa.ERROR_RESOLUTION_STG (ESN,REASON,BRAND,INSERT_DATE,LOGIN_NAME, LOG_TYPE, INVOKED_BY)
            VALUES (ESN, MSG, BRAND_IN, SYSDATE, SYS_CONTEXT('USERENV', 'OS_USER'), LOG_TYPE, '1052 FORM' );
        COMMIT;
    END;
-- END OF PROCEDURE TO LOG MESSAGE

    PROCEDURE CREATE_INTERACTION (ESN IN VARCHAR2, MSG IN VARCHAR2, OUTCOME IN VARCHAR2) IS
        CURSOR  C_PHONE IS
            SELECT  PART_SERIAL_NO, NVL(X_PART_INST2CONTACT,0)CONTACT
            FROM    TABLE_PART_INST
            WHERE   PART_SERIAL_NO = ESN;
        C_ESN   C_PHONE%ROWTYPE;

            V_INTERACT_ID       NUMBER;
            V_OBJID             NUMBER;
            V_MESSAGE           VARCHAR(2000);
            V_USER              NUMBER;

    BEGIN
        IF C_PHONE%ISOPEN THEN
            CLOSE C_PHONE;
        END IF;
        OPEN C_PHONE;
        FETCH C_PHONE INTO C_ESN;
        IF C_ESN.CONTACT >0 THEN
            SELECT  OBJID INTO V_USER
            FROM    TABLE_USER
            WHERE   S_LOGIN_NAME = UPPER(SYS_CONTEXT('USERENV', 'OS_USER'));
            V_OBJID := sa.SEQ ( 'INTERACT' );
            V_MESSAGE :=  'Fix ESN (1052 Form) was used for this ESN for error : '||MSG||CHR(10)||
                          'Please open a System Error Case for IT TOSS.';
            SELECT  sa.SEQU_INTERACTION_ID.NEXTVAL  INTO V_INTERACT_ID
            FROM    DUAL;
            INSERT INTO sa.TABLE_INTERACT(  OBJID, INTERACT_ID, CREATE_DATE, INSERTED_BY, DIRECTION, REASON_1,
                                            S_REASON_1, REASON_2,S_REASON_2, RESULT, DONE_IN_ONE,
                                            FEE_BASED, WAIT_TIME, SYSTEM_TIME, ENTERED_TIME,
                                            PAY_OPTION, START_DATE, END_DATE,ARCH_IND, AGENT,S_AGENT,
                                            INTERACT2USER,INTERACT2CONTACT,X_SERVICE_TYPE,SERIAL_NO)
                VALUES                   (  V_OBJID, V_INTERACT_ID, SYSDATE,SYS_CONTEXT('USERENV', 'OS_USER'), 'Inbound',
                                            'Technical','TECHNICAL', '1052 Fix','1052 FIX', 'Successful', 0,0,0,0,0, 'None',
                                            SYSDATE,'31-Dec-2055', 0, SYS_CONTEXT('USERENV', 'OS_USER'),
                                            UPPER(SYS_CONTEXT('USERENV', 'OS_USER')), V_USER, C_ESN.CONTACT, 'Wireless',
                                            ESN  );
            COMMIT;
            INSERT INTO sa.TABLE_INTERACT_TXT( OBJID, NOTES, INTERACT_TXT2INTERACT )
                VALUES                   (  sa.SEQ ( 'INTERACT_TXT' ),  V_MESSAGE||CHR(10)||MSG,  V_OBJID  );
            COMMIT;
        END IF;
        CLOSE C_PHONE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN;
  END;

    PROCEDURE CHECK_SWITCHBASE (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR C_CHECK IS
            SELECT  SBT.*
            FROM    sa.X_SWITCHBASED_TRANSACTION SBT, sa.TABLE_X_CALL_TRANS CT
            WHERE   SBT.X_SB_TRANS2X_CALL_TRANS = CT.OBJID
            AND     CT.X_SERVICE_ID = ESN
            AND     SBT.STATUS||'' ='CarrierPending';

        BEGIN
            FOR C_SBT IN C_CHECK
            LOOP
                UPDATE  sa.X_SWITCHBASED_TRANSACTION
                SET     STATUS = 'Completed'
                WHERE   OBJID = C_SBT.OBJID;
                COMMIT;
                V_MSG:= 'Cleared Carrier Pending Transaction in X_SWITCHBASED_TRANSACTION'||CHR(10);
                LOG_MSG(ESN, BRAND_IN, V_MSG, 'Fix');
            END LOOP;
        END;
-- END OF SWITCHBASED TRANSACTION PROCEDURE

    PROCEDURE  FIX_CARD (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR  C_CARD IS
            SELECT  CARD.PART_SERIAL_NO, CARD.X_PART_INST_STATUS
            FROM    TABLE_PART_INST CARD, TABLE_PART_INST ESN
            WHERE   ESN.PART_SERIAL_NO=ESN
            AND     ESN.X_DOMAIN||''='PHONES'
            AND     CARD.PART_TO_ESN2PART_INST = ESN.OBJID
            AND     CARD.X_DOMAIN||''='REDEMPTION CARDS';

    BEGIN
        FOR CARD IN C_CARD
        LOOP
            IF CARD.X_PART_INST_STATUS IN ('42','263') THEN
                UPDATE  sa.TABLE_PART_INST
                SET     X_PART_INST_STATUS = '40',
                        STATUS2X_CODE_TABLE = ( SELECT  OBJID
                                                FROM    TABLE_X_CODE_TABLE
                                                WHERE   X_CODE_NUMBER='40')
                WHERE   PART_SERIAL_NO =  CARD.PART_SERIAL_NO
                AND     X_DOMAIN = 'REDEMPTION CARDS';
                IF SQL%ROWCOUNT =1 THEN
                    COMMIT;
                    V_MSG:='Card '||CARD.PART_SERIAL_NO||' now reserved to ESN';
                    LOG_MSG(ESN, BRAND_IN, V_MSG, 'Fix');
                END IF;
            END IF;
        END LOOP;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN;
    END;
-- END OF PROCEDURE TO RESERVE THE CARD

    PROCEDURE FIX_LIMITS_EXCEEDED (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR  C_COMP_UNITS (ESN_COMP IN VARCHAR2) IS
            SELECT  X_ESN, ID_NUMBER, CREATION_TIME, X_REPLACEMENT_UNITS
            FROM    sa.TABLE_CASE
            WHERE   X_ESN  = ESN_COMP
            AND     X_REPLACEMENT_UNITS>0
            AND     CREATION_TIME< SYSDATE-1/24;

    BEGIN
        FOR C_COMP IN C_COMP_UNITS(ESN)
        LOOP
            INSERT INTO sa. CASE_REPL_UNITS_STG( X_ESN, ID_NUMBER, CREATION_TIME, X_REPLACEMENT_UNITS, UPDATE_DATE )
                VALUES( C_COMP.X_ESN, C_COMP.ID_NUMBER, C_COMP.CREATION_TIME, C_COMP.X_REPLACEMENT_UNITS, SYSDATE );
            COMMIT;
            UPDATE sa.  TABLE_CASE
            SET     X_REPLACEMENT_UNITS = 0
            WHERE   ID_NUMBER = C_COMP.ID_NUMBER;
            IF SQL%ROWCOUNT = 1 THEN
                COMMIT;
                V_MSG:='Limits are reset';
            END IF;
        END LOOP;
        LOG_MSG(ESN, BRAND_IN, V_MSG, 'Fix');
    END;
-- END OF PROCEDURE TO FIX LIMITS EXCEEDED

    PROCEDURE FIX_NPA (LINE IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR C_MIN IS
            SELECT  PI_LINE.OBJID, PI_LINE.PART_SERIAL_NO, PI_LINE.X_NPA, PI_LINE.X_NXX, PI_LINE.X_EXT,
                    PI_LINE.PART_INST2CARRIER_MKT, PI_LINE.PART_INST2X_PERS,
                    PI_ESN.PART_SERIAL_NO ESN
            FROM    sa.TABLE_PART_INST PI_LINE, sa.TABLE_PART_INST PI_ESN
            WHERE   PI_LINE.PART_SERIAL_NO = LINE
            AND     PI_ESN.X_DOMAIN||''='PHONES'
            AND     PI_LINE.X_DOMAIN||''='LINES'
            AND     PI_LINE.PART_TO_ESN2PART_INST = PI_ESN.OBJID
            AND     PI_LINE.PART_SERIAL_NO NOT LIKE 'T%';
        C_LINE     C_MIN%ROWTYPE;

        CURSOR C_CALL_TRANS_CM (ESN_IN IN VARCHAR2) IS
            SELECT  OBJID, X_SERVICE_ID, X_CALL_TRANS2CARRIER CR
            FROM    sa.TABLE_X_CALL_TRANS CT
            WHERE   CT.X_SERVICE_ID = ESN_IN
            AND     CT.X_TRANSACT_DATE = (  SELECT  MAX(X_TRANSACT_DATE)
                                            FROM    sa.TABLE_X_CALL_TRANS
                                            WHERE   X_SERVICE_ID= CT.X_SERVICE_ID
                                            AND     X_CALL_TRANS2CARRIER IS NOT NULL) ;
        C_CM    C_CALL_TRANS_CM%ROWTYPE;
        PERS    NUMBER;
    BEGIN
        IF C_MIN%ISOPEN THEN
            CLOSE C_MIN;
        END IF;
        OPEN C_MIN;
        FETCH C_MIN INTO C_LINE;
        IF C_MIN%FOUND THEN
            BEGIN
            IF C_LINE.X_NPA <> SUBSTR(C_LINE.PART_SERIAL_NO,1,3)
                OR C_LINE.X_NXX <> SUBSTR(C_LINE.PART_SERIAL_NO,4,3)
                OR C_LINE.X_EXT <> SUBSTR(C_LINE.PART_SERIAL_NO,7,4) THEN
                    UPDATE  sa.TABLE_PART_INST
                    SET     X_NPA = SUBSTR(C_LINE.PART_SERIAL_NO,1,3),
                            X_NXX = SUBSTR(C_LINE.PART_SERIAL_NO,4,3),
                            X_EXT = SUBSTR(C_LINE.PART_SERIAL_NO,7,4)
                    WHERE   OBJID = C_LINE.OBJID;
                    COMMIT;
                    V_MSG:='Fixed X_NPA, X_NXX, X_EXT for : '||C_LINE.PART_SERIAL_NO||CHR(10);
                    LOG_MSG(C_LINE.PART_SERIAL_NO, BRAND_IN, V_MSG, 'Fix');
            END IF;

            IF C_LINE.PART_INST2CARRIER_MKT IS NULL THEN
                IF C_CALL_TRANS_CM%ISOPEN THEN
                    CLOSE C_CALL_TRANS_CM;
                END IF;
                OPEN C_CALL_TRANS_CM(C_LINE.ESN);
                FETCH C_CALL_TRANS_CM INTO C_CM;
                CLOSE C_CALL_TRANS_CM;
                SELECT  CARRIER2PERSONALITY INTO PERS
                FROM    sa.TABLE_X_CARRIER
                WHERE   OBJID=C_CM.CR;
                UPDATE  sa.TABLE_PART_INST
                SET     PART_INST2CARRIER_MKT = C_CM.CR,
                        PART_INST2X_PERS= PERS
                WHERE   OBJID = C_LINE.OBJID;
                COMMIT;
                V_MSG := V_MSG||'Fixed Missing Carrier'||CHR(10);
                LOG_MSG(C_LINE.ESN, BRAND_IN, V_MSG, 'Fix');
            END IF;
            IF C_LINE.PART_INST2X_PERS IS NULL THEN
                SELECT CARRIER2PERSONALITY INTO PERS FROM sa.TABLE_X_CARRIER WHERE OBJID=C_CM.CR;
                UPDATE sa.TABLE_PART_INST
                SET    PART_INST2X_PERS= PERS
                WHERE  OBJID = C_LINE.OBJID;
                COMMIT;
            END IF;
            END;
        END IF;
        PERS:=0;
    END;
-- END OF PROCEDURE TO FIX NPA, NXX, EXT
    PROCEDURE FIX_100 (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR  C_PI_PERS IS
            SELECT      LINE.OBJID, LINE.PART_INST2X_NEW_PERS
            FROM        TABLE_PART_INST LINE, TABLE_PART_INST PHONE
            WHERE       PHONE.PART_SERIAL_NO = ESN
            AND         PHONE.X_DOMAIN ||''='PHONES'
            AND         LINE.PART_TO_ESN2PART_INST(+) = PHONE.OBJID
            AND         LINE.X_DOMAIN ||''='LINES'
            AND         LINE.PART_INST2X_NEW_PERS IS NOT NULL;
        C_PPER  C_PI_PERS%ROWTYPE;

    BEGIN
        IF C_PI_PERS%ISOPEN THEN
            CLOSE C_PI_PERS;
        END IF;
        OPEN C_PI_PERS;
        FETCH C_PI_PERS INTO C_PPER;
        IF C_PI_PERS%FOUND THEN
            UPDATE TABLE_PART_INST
            SET    PART_INST2X_PERS=PART_INST2X_NEW_PERS,
                   PART_INST2X_NEW_PERS=NULL
            WHERE OBJID = C_PPER.OBJID;
            IF SQL%ROWCOUNT = 1 THEN
                COMMIT;
            END IF;
            V_MSG:='Updated personality for associated Line';
            LOG_MSG (ESN, BRAND_IN, V_MSG, 'Fix');
        END IF;
        CLOSE C_PI_PERS;
    END;
-- END OF PROCEDURE TO FIX PERSONALITY

    PROCEDURE FIX_MIN (ESN_IN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR C_MINS IS
            SELECT  SP.OBJID, SP.X_MIN, SP.X_SERVICE_ID, SP.X_MSID, SP.INSTALL_DATE,
                    DECODE(NVL(SP.X_EXPIRE_DT,'01-JAN-1753'),'01-JAN-1753','NA',SP.X_EXPIRE_DT)EXPIRE_DT,
                    SP.PART_STATUS, SP.X_ZIPCODE
            FROM    sa.TABLE_SITE_PART SP
            WHERE   SP.X_SERVICE_ID = ESN_IN
            AND     SP.PART_STATUS IN ('Active', 'CarrierPending')
            AND     SP.INSTALL_DATE =
                                (   SELECT MAX (INSTALL_DATE)
                                    FROM   sa.TABLE_SITE_PART
                                    WHERE  X_SERVICE_ID = SP.X_SERVICE_ID
                                    AND    PART_STATUS IN ('Active', 'CarrierPending'));
        CURSOR C_SITE_PART (ESN_IN IN VARCHAR2, ACTIVE_DT IN DATE) IS
            SELECT    OBJID, X_SERVICE_ID, X_MIN, PART_STATUS, INSTALL_DATE, X_EXPIRE_DT, SERVICE_END_DT, X_MSID
            FROM      sa.TABLE_SITE_PART
            WHERE     X_SERVICE_ID = ESN_IN
            AND       PART_STATUS IN ('Active', 'CarrierPending')
            AND       INSTALL_DATE <> ACTIVE_DT;

        CURSOR C_CALL_TRANS (ESN_IN   IN VARCHAR2, TRANS_DATE   IN DATE) IS
            SELECT    OBJID, X_ACTION_TYPE, X_SERVICE_ID, X_MIN, X_RESULT, X_NEW_DUE_DATE, X_CALL_TRANS2CARRIER
            FROM      sa.TABLE_X_CALL_TRANS
            WHERE     X_SERVICE_ID = ESN_IN
            AND       TRUNC (X_TRANSACT_DATE) >= TRUNC (TRANS_DATE);

        CURSOR C_CALL_TRANS_DUE_DT (ESN_IN IN VARCHAR2)IS
            SELECT    OBJID, X_ACTION_TYPE, X_SERVICE_ID, X_MIN, X_RESULT, X_NEW_DUE_DATE, X_CALL_TRANS2CARRIER
            FROM      sa.TABLE_X_CALL_TRANS
            WHERE     X_SERVICE_ID = ESN_IN
            AND       X_TRANSACT_DATE = (   SELECT  MAX (X_TRANSACT_DATE)
                                            FROM    sa.TABLE_X_CALL_TRANS
                                            WHERE   X_SERVICE_ID = ESN_IN
                                            AND     X_ACTION_TYPE IN ('1', '3', '6'));
        C_CT           C_CALL_TRANS_DUE_DT%ROWTYPE;

        V_INSERT       VARCHAR2 (25);
        V_CARRIER_ID   VARCHAR2 (15);
        V_ZIP          VARCHAR2 (10);
        DUE_DT         VARCHAR2 (25);
        CT_EXP_DT      DATE;
        SP_EXP_DT      DATE;
        SP_ACT_DT      DATE;

        PROCEDURE INSERT_NPANXX (MIN_IN IN VARCHAR2, CARRIER_ID_IN  IN VARCHAR2, ZIP IN VARCHAR2) IS
            CURSOR C_NPANXX  IS
                SELECT  DISTINCT SUBSTR (MIN_IN, 1, 3) NPA,
                        SUBSTR (MIN_IN, 4, 3) NXX,
                        N.CARRIER_ID,
                        MIN (N.CARRIER_NAME) CARRIER_NAME,
                        '0' LEAD_TIME,
                        '0' TARGET_LEVEL,
                        MIN (N.RATECENTER) RATECENTER,
                        N.STATE,
                        'PORT CALL_CENTER' CARRIER_ID_DESCRIPTION,
                        N.ZONE,
                        MIN (N.COUNTY) COUNTY,
                        MIN (N.MARKETID) MARKETID,
                        MIN (N.MRKT_AREA) MRKT_AREA,
                        MIN (N.SID) SID,
                        CASE
                            WHEN N.GSM_TECH = 'GSM' THEN 'GSM'
                            WHEN N.CDMA_TECH = 'CDMA' THEN 'CDMA'
                            ELSE NULL
                        END TECHNOLOGY,
                        MIN (N.FREQUENCY1) FREQUENCY1,
                        MIN (N.FREQUENCY2) FREQUENCY2,
                        MIN (N.BTA_MKT_NUMBER) BTA_MKT_NUMBER,
                        MIN (N.BTA_MKT_NAME) BTA_MKT_NAME,
                        NULL TDMA_TECH,
                        CASE
                            WHEN N.GSM_TECH = 'GSM' THEN 'GSM'
                            WHEN N.CDMA_TECH = 'CDMA' THEN 'NULL'
                            ELSE NULL
                        END GSM_TECH,
                        CASE WHEN N.CDMA_TECH = 'CDMA' THEN 'CDMA'
                             ELSE NULL
                        END CDMA_TECH,
                        CASE
                            WHEN (N.CARRIER_NAME LIKE 'AT%T%' OR N.CARRIER_NAME LIKE 'CING%') THEN 'G0410'
                            WHEN N.CARRIER_NAME LIKE 'T-MO%' THEN 'G0260'
                            ELSE ''
                        END MNC_V
                FROM    NPANXX2CARRIERZONES N, CARRIERZONES C
                WHERE   1 = 1
                AND     N.ZONE = C.ZONE
                AND     N.STATE = C.ST
                AND     EXISTS (    SELECT  1
                                    FROM    sa.TABLE_X_CARRIER CR, sa.TABLE_X_CARRIER_GROUP CG
                                    WHERE   CG.OBJID = CR.CARRIER2CARRIER_GROUP
                                    AND     CR.X_STATUS = 'ACTIVE'
                                    AND     CR.X_CARRIER_ID = CARRIER_ID_IN
                                    AND     N.CARRIER_ID = CR.X_CARRIER_ID)
                AND     C.ZIP = ZIP
                AND     ROWNUM < 2
                GROUP BY N.NPA, N.NXX, N.CARRIER_ID, N.CARRIER_NAME, N.STATE, N.ZONE,
                  CASE
                     WHEN N.GSM_TECH = 'GSM' THEN 'GSM'
                     WHEN N.CDMA_TECH = 'CDMA' THEN 'CDMA'
                     ELSE NULL
                  END,
                  CASE
                     WHEN N.GSM_TECH = 'GSM' THEN 'GSM'
                     WHEN N.CDMA_TECH = 'CDMA' THEN 'NULL'
                     ELSE NULL
                  END,
                  CASE
                     WHEN N.CDMA_TECH = 'CDMA' THEN 'CDMA'
                     ELSE NULL
                  END,
                  CASE
                     WHEN (N.CARRIER_NAME LIKE 'AT%T%' AND N.CARRIER_NAME LIKE 'CING%')THEN 'G0410'
                     WHEN (N.CARRIER_NAME LIKE 'T-MO%') THEN 'G0260'
                     ELSE ''
                  END;
                C_NPX   C_NPANXX%ROWTYPE;
                BEGIN
                    IF C_NPANXX%ISOPEN THEN
                        CLOSE C_NPANXX;
                    END IF;
                    OPEN C_NPANXX;
                    FETCH C_NPANXX INTO C_NPX;
                    IF C_NPANXX%FOUND THEN
                        INSERT INTO NPANXX2CARRIERZONES
                        VALUES (C_NPX.NPA,
                                C_NPX.NXX,
                                C_NPX.CARRIER_ID,
                                C_NPX.CARRIER_NAME,
                                C_NPX.LEAD_TIME,
                                C_NPX.TARGET_LEVEL,
                                C_NPX.RATECENTER,
                                C_NPX.STATE,
                                C_NPX.CARRIER_ID_DESCRIPTION,
                                C_NPX.ZONE,
                                C_NPX.COUNTY,
                                C_NPX.MARKETID,
                                C_NPX.MRKT_AREA,
                                C_NPX.SID,
                                C_NPX.TECHNOLOGY,
                                C_NPX.FREQUENCY1,
                                C_NPX.FREQUENCY2,
                                C_NPX.BTA_MKT_NUMBER,
                                C_NPX.BTA_MKT_NAME,
                                C_NPX.TDMA_TECH,
                                C_NPX.GSM_TECH,
                                C_NPX.CDMA_TECH,
                                C_NPX.MNC_V);
                        COMMIT;
                    END IF;
                    CLOSE C_NPANXX;
                END;
        PROCEDURE INSERT_MIN (  MIN_IN IN VARCHAR2, ESN_OBJID IN VARCHAR2, MSID IN VARCHAR2,
                                V_CARRIER IN VARCHAR2, EXP_DT IN VARCHAR2) IS
            CURSOR C_ESN (ESN_OBJ IN NUMBER)  IS
                SELECT  PI.PART_SERIAL_NO ESN, PI.X_PART_INST_STATUS ESN_STATUS, PI.OBJID ESN_OBJID, PI.X_MSID
                FROM    sa.TABLE_PART_INST PI
                WHERE   PI.OBJID = ESN_OBJ
                AND     PI.X_DOMAIN = 'PHONES';
            C_E   C_ESN%ROWTYPE;
            CURSOR C_MIN (LINE IN VARCHAR2) IS
                SELECT     OBJID, PART_SERIAL_NO, X_MSID
                FROM       sa.TABLE_PART_INST
                WHERE      PART_SERIAL_NO = LINE
                AND        X_DOMAIN = 'LINES';
            C_M               C_MIN%ROWTYPE;

            V_MIN             VARCHAR2(25);
            OP_CARRIER_ID     NUMBER;
            OP_CARRIER_NAME   VARCHAR2 (100);
            OP_RESULT         NUMBER;
            OP_MSG            VARCHAR2 (250);
            MIN_EX        NUMBER;
        BEGIN
            V_MIN := MIN_IN;
            IF C_ESN%ISOPEN THEN
                CLOSE C_ESN;
            END IF;
            IF V_CARRIER = 0 THEN
                NULL;
            ELSE
                OPEN C_ESN (ESN_OBJID);
                FETCH C_ESN INTO C_E;
                IF C_ESN%FOUND   THEN
                    IF C_E.ESN_STATUS <> '52'  THEN
                        UPDATE  sa.TABLE_PART_INST
                        SET     X_PART_INST_STATUS = '52',
                                STATUS2X_CODE_TABLE = 988
                        WHERE   OBJID = ESN_OBJID;
                        COMMIT;
                        LOG_MSG(C_E.ESN, BRAND_IN, 'ESN updated to ACTIVE', 'Fix');
                    END IF;

                    SELECT  COUNT(*) INTO MIN_EX
                    FROM    sa.TABLE_PART_INST
                    WHERE   PART_SERIAL_NO=MIN_IN
                    AND     X_DOMAIN||''='LINES';
                    IF MIN_EX=0 THEN
                        TOPPAPP.LINE_INSERT_PKG.LINE_VALIDATION (   MSID, MIN_IN, V_CARRIER, 'CRM_APP_SUPPORT', '1',
                                                                    EXP_DT, OP_CARRIER_ID, OP_CARRIER_NAME, OP_RESULT,
                                                                    OP_MSG);
                        IF  OP_RESULT = 102   THEN
                            INSERT_NPANXX (MIN_IN, V_CARRIER, V_ZIP);
                            TOPPAPP.LINE_INSERT_PKG.LINE_VALIDATION (   MSID, MIN_IN, V_CARRIER, 'CRM_APP_SUPPORT', '1',
                                                                        EXP_DT, OP_CARRIER_ID, OP_CARRIER_NAME,OP_RESULT,
                                                                        OP_MSG);
                        END IF;
                        LOG_MSG(V_MIN,  BRAND_IN, 'Inserted Line '|| MIN_IN ||'into Invertory', 'Fix');
                    END IF;
                      SELECT  COUNT(*) INTO MIN_EX
                    FROM    sa.TABLE_PART_INST
                    WHERE   PART_SERIAL_NO=V_MIN;
                    IF MIN_EX>0 THEN
                        UPDATE    sa.TABLE_PART_INST
                        SET       PART_TO_ESN2PART_INST = ESN_OBJID,
                                  X_PART_INST_STATUS = '13',
                                  STATUS2X_CODE_TABLE = 960
                        WHERE     PART_SERIAL_NO = MIN_IN
                        AND       X_DOMAIN = 'LINES';
                        COMMIT;
                        V_INSERT := 'SUCCESS';
                    ELSE
                        V_INSERT := 'FAILED';
                    END IF;
                END IF;
                CLOSE C_ESN;
            END IF;
        END;
        FUNCTION GET_CARRIER (ESN IN VARCHAR2, CREATE_DATE IN DATE) RETURN NUMBER  IS
            CURSOR C_TRANS (ESN IN VARCHAR2)IS
                SELECT  OBJID, X_SERVICE_ID, X_CALL_TRANS2CARRIER
                FROM    sa.TABLE_X_CALL_TRANS CT
                WHERE   X_SERVICE_ID = ESN
                AND     X_ACTION_TYPE IN ('1', '3')
                AND     X_TRANSACT_DATE = ( SELECT  MAX (X_TRANSACT_DATE)
                                            FROM    sa.TABLE_X_CALL_TRANS
                                            WHERE   X_SERVICE_ID = CT.X_SERVICE_ID
                                            AND     X_ACTION_TYPE IN ('1', '3')
                                            AND     X_CALL_TRANS2CARRIER IS NOT NULL);
            C_CT    C_TRANS%ROWTYPE;

            CURSOR C_MIN_IG (ESN_IN IN VARCHAR2)IS
                SELECT     ACTION_ITEM_ID, ESN, MIN, MSID, CREATION_DATE, CARRIER_ID
                FROM       GW1.IG_TRANSACTION IG, sa.TABLE_X_CALL_TRANS CT, sa.TABLE_TASK TT
                WHERE      CT.X_SERVICE_ID = ESN_IN
                AND        TT.X_TASK2X_CALL_TRANS = CT.OBJID
                AND        IG.ACTION_ITEM_ID = TT.TASK_ID
                AND        IG.STATUS = 'S'
                AND        IG.ORDER_TYPE NOT IN ( 'S','D')
                UNION
                SELECT     ACTION_ITEM_ID, ESN, MIN, MSID, CREATION_DATE, CARRIER_ID
                FROM       GW1.IG_TRANSACTION_HISTORY IGH, sa.TABLE_X_CALL_TRANS CT, sa.TABLE_TASK TT
                WHERE      CT.X_SERVICE_ID = ESN_IN
                AND        TT.X_TASK2X_CALL_TRANS = CT.OBJID
                AND        IGH.ACTION_ITEM_ID = TT.TASK_ID
                AND        IGH.STATUS = 'S'
                AND        IGH.ORDER_TYPE NOT IN ( 'S','D');
            C_M_I   C_MIN_IG%ROWTYPE;

        BEGIN
            IF C_TRANS%ISOPEN THEN
                CLOSE C_TRANS;
            END IF;
            OPEN C_TRANS (ESN);
            FETCH C_TRANS INTO C_CT;
            IF C_TRANS%FOUND THEN
                SELECT  X_CARRIER_ID INTO V_CARRIER_ID
                FROM    sa.TABLE_X_CARRIER
                WHERE   OBJID = C_CT.X_CALL_TRANS2CARRIER;
                RETURN V_CARRIER_ID;
            ELSE
                BEGIN
                    IF C_MIN_IG%ISOPEN THEN
                        CLOSE C_MIN_IG;
                    END IF;
                    OPEN C_MIN_IG (ESN);
                    FETCH C_MIN_IG INTO C_M_I;
                    IF C_MIN_IG%NOTFOUND THEN
                        RETURN 0;
                        CLOSE C_MIN_IG;
                    ELSE
                        CLOSE C_MIN_IG;
                        FOR IG IN C_MIN_IG (ESN)
                        LOOP
                            IF IG.CREATION_DATE >= CREATE_DATE  THEN
                                IF IG.CARRIER_ID IS NOT NULL THEN
                                    RETURN IG.CARRIER_ID;
                                ELSE
                                    RETURN 0;
                                END IF;
                            END IF;
                        END LOOP;
                    END IF;
                END;
            END IF;
        END;
        PROCEDURE CHECK_MIN_SITE_PART (MIN_INP IN VARCHAR2, EXP_DT IN VARCHAR2) IS
            CURSOR C_SP_MIN IS
                SELECT     OBJID, X_SERVICE_ID, X_MIN, X_MSID MSID, INSTALL_DATE, SERVICE_END_DT, X_EXPIRE_DT
                FROM       sa.TABLE_SITE_PART
                WHERE      X_MIN = MIN_INP
                AND        PART_STATUS ||''= 'Active';
            C_MIN_SP   C_SP_MIN%ROWTYPE;

            CURSOR C_MIN_IG ( ESN_IN IN VARCHAR2, CREATE_DATE   IN VARCHAR2) IS
                SELECT     ACTION_ITEM_ID, ESN, MIN, MSID, CREATION_DATE
                FROM       GW1.IG_TRANSACTION IG, sa.TABLE_X_CALL_TRANS CT, sa.TABLE_TASK TT
                WHERE      CT.X_SERVICE_ID = ESN_IN
                AND        TT.X_TASK2X_CALL_TRANS = CT.OBJID
                AND        IG.ACTION_ITEM_ID = TT.TASK_ID
                AND        IG.STATUS ||''= 'S'
                AND        IG.ORDER_TYPE NOT IN ( 'S','D')
                UNION
                SELECT     ACTION_ITEM_ID, ESN, MIN, MSID, CREATION_DATE
                FROM       GW1.IG_TRANSACTION_HISTORY IGH, sa.TABLE_X_CALL_TRANS CT, sa.TABLE_TASK TT
                WHERE      CT.X_SERVICE_ID = ESN_IN
                AND        TT.X_TASK2X_CALL_TRANS = CT.OBJID
                AND        IGH.ACTION_ITEM_ID = TT.TASK_ID
                AND        IGH.STATUS ||'' = 'S'
                AND        IGH.ORDER_TYPE NOT IN ( 'S','D');
            C_M_I     C_MIN_IG%ROWTYPE;
            ESN_OBJ    NUMBER;

        BEGIN
            ESN_OBJ := 0;
                IF C_SP_MIN%ISOPEN THEN
                    CLOSE C_SP_MIN;
                END IF;
            OPEN C_SP_MIN;
            FETCH C_SP_MIN INTO C_MIN_SP;
            IF C_SP_MIN%FOUND THEN
                IF C_MIN_SP.MSID LIKE 'T%' THEN
                    OPEN C_MIN_IG(C_MIN_SP.X_SERVICE_ID, C_MIN_SP.INSTALL_DATE);
                    FETCH C_MIN_IG INTO C_M_I;
                    IF C_MIN_IG%FOUND THEN
                        CLOSE C_MIN_IG;
                        FOR IG IN C_MIN_IG(C_MIN_SP.X_SERVICE_ID, C_MIN_SP.INSTALL_DATE)
                        LOOP
                            IF IG.CREATION_DATE>=C_MIN_SP.INSTALL_DATE THEN
                                IF IG.MSID NOT LIKE 'T%' THEN
                                    UPDATE  sa.TABLE_SITE_PART
                                    SET     X_MSID = IG.MSID
                                    WHERE   OBJID = C_MIN_SP.OBJID;
                                    COMMIT;
                                END IF;
                            END IF;
                        END LOOP;
                    END IF;
                    CLOSE C_MIN_IG;
                END IF;
                SELECT  OBJID INTO ESN_OBJ
                FROM    sa.TABLE_PART_INST
                WHERE   PART_SERIAL_NO = C_MIN_SP.X_SERVICE_ID;
                IF ESN_OBJ > 0 THEN
                    INSERT_MIN (C_MIN_SP.X_MIN, ESN_OBJ, C_MIN_SP.MSID,
                                GET_CARRIER (C_MIN_SP.X_SERVICE_ID, C_MIN_SP.INSTALL_DATE), EXP_DT);
                END IF;
            END IF;
            CLOSE C_SP_MIN;
        END;

        PROCEDURE CHECK_MIN_IG (ESN IN VARCHAR2, CREATE_DATE IN DATE, EXP_DT IN VARCHAR2) IS
            CURSOR C_MIN_IG ( ESN_IN        IN VARCHAR2, CREATE_DATE   IN VARCHAR2) IS
                SELECT     ACTION_ITEM_ID, ESN, MIN, MSID, CREATION_DATE
                FROM       GW1.IG_TRANSACTION IG, sa.TABLE_X_CALL_TRANS CT, sa.TABLE_TASK TT
                WHERE      CT.X_SERVICE_ID = ESN_IN
                AND        TT.X_TASK2X_CALL_TRANS = CT.OBJID
                AND        IG.ACTION_ITEM_ID = TT.TASK_ID
                AND        IG.STATUS ||''= 'S'
                AND        IG.ORDER_TYPE NOT IN ( 'S','D')
                UNION
                SELECT     ACTION_ITEM_ID, ESN, MIN, MSID, CREATION_DATE
                FROM       GW1.IG_TRANSACTION_HISTORY IGH, sa.TABLE_X_CALL_TRANS CT, sa.TABLE_TASK TT
                WHERE      CT.X_SERVICE_ID = ESN_IN
                AND        TT.X_TASK2X_CALL_TRANS = CT.OBJID
                AND        IGH.ACTION_ITEM_ID = TT.TASK_ID
                AND        IGH.STATUS ||''= 'S'
                AND        IGH.ORDER_TYPE NOT IN ( 'S','D');
          C_M_I     C_MIN_IG%ROWTYPE;

          CARR_ID   NUMBER;
          ESN_OBJ   NUMBER;

     BEGIN
            ESN_OBJ := 0;
            IF C_MIN_IG%ISOPEN THEN
                CLOSE C_MIN_IG;
            END IF;
            OPEN C_MIN_IG (ESN, CREATE_DATE);
            FETCH C_MIN_IG INTO C_M_I;
            IF C_MIN_IG%NOTFOUND THEN
                CLOSE C_MIN_IG;
            ELSE
                CLOSE C_MIN_IG;
                FOR IG IN C_MIN_IG (ESN, CREATE_DATE)
                LOOP
                    IF IG.CREATION_DATE >= CREATE_DATE THEN
                        IF IG.MIN NOT LIKE 'T%' THEN
                            UPDATE    sa.TABLE_SITE_PART
                            SET       X_MIN = IG.MIN,
                                      X_MSID = IG.MSID,
                                      PART_STATUS = 'Active'
                            WHERE     X_SERVICE_ID = ESN
                            AND       PART_STATUS IN ('Active', 'CarrierPending')
                            AND       INSTALL_DATE = CREATE_DATE;
                            COMMIT;
                            LOG_MSG(ESN, BRAND_IN, 'MIN updated in TABLE_SITE_PART based on IG TABLE ', 'Fix');

                            FOR CT IN C_CALL_TRANS (ESN, CREATE_DATE)
                            LOOP
                                IF CT.X_MIN <> IG.MIN THEN
                                    UPDATE  sa.TABLE_X_CALL_TRANS
                                    SET     X_MIN = IG.MIN
                                    WHERE   OBJID = CT.OBJID;
                                    COMMIT;
                                END IF;
                                IF (CT.X_ACTION_TYPE IN ('1','3') AND UPPER(CT.X_RESULT) ='FAILED') THEN
                                    UPDATE  sa.TABLE_X_CALL_TRANS
                                    SET     X_RESULT = 'Completed'
                                    WHERE   OBJID = CT.OBJID;
                                    COMMIT;
                                    LOG_MSG(ESN, BRAND_IN, 'Call Trans record updated to Completed', 'Fix');
                                END IF;
                            END LOOP;
                            SELECT  OBJID INTO ESN_OBJ
                            FROM    sa.TABLE_PART_INST
                            WHERE   PART_SERIAL_NO = ESN;
                            IF ESN_OBJ > 0 THEN
                                INSERT_MIN (C_M_I.MIN, ESN_OBJ, C_M_I.MSID,
                                            GET_CARRIER (C_M_I.ESN, CREATE_DATE), EXP_DT);
                            END IF;
                        ELSE
                            LOG_MSG(ESN_IN, BRAND_IN, 'No Valid Min Found in IG TRANSACTION TABLE ', 'Fix');
                        END IF;
                    END IF;
                END LOOP;
            END IF;
        END;
        BEGIN
            FOR I IN C_MINS
            LOOP
                IF I.EXPIRE_DT = 'NA' THEN
                    IF C_CALL_TRANS_DUE_DT%ISOPEN THEN
                        CLOSE C_CALL_TRANS_DUE_DT;
                    END IF;
                    OPEN C_CALL_TRANS_DUE_DT (I.X_SERVICE_ID);
                    FETCH C_CALL_TRANS_DUE_DT INTO C_CT;
                    IF NVL (C_CT.X_NEW_DUE_DATE, '01-JAN-1753') > '01-JAN-1753' THEN
                        UPDATE  sa.TABLE_SITE_PART
                        SET     X_EXPIRE_DT = C_CT.X_NEW_DUE_DATE
                        WHERE   OBJID = I.OBJID;
                        COMMIT;
                        DUE_DT := C_CT.X_NEW_DUE_DATE;
                    ELSE
                        SELECT NULL INTO DUE_DT FROM DUAL;
                    END IF;
                    CLOSE C_CALL_TRANS_DUE_DT;
                END IF;
                V_ZIP := I.X_ZIPCODE;
                IF I.X_MIN LIKE 'T%' OR I.PART_STATUS LIKE 'C%'  THEN
                    SELECT  DECODE (NVL (DUE_DT, '01-JAN-1753'),'01-JAN-1753', 'NA',I.EXPIRE_DT)INTO DUE_DT
                    FROM    DUAL;
                    CHECK_MIN_IG (I.X_SERVICE_ID, I.INSTALL_DATE, DUE_DT);
                ELSE
                    SELECT  DECODE (NVL (DUE_DT, '01-JAN-1753'),'01-JAN-1753', 'NA',I.EXPIRE_DT)INTO DUE_DT
                    FROM    DUAL;
                    CHECK_MIN_SITE_PART (I.X_MIN, DUE_DT);
                END IF;
                IF V_INSERT = 'SUCCESS' THEN
                    UPDATE     sa.TABLE_PART_INST
                    SET        X_PART_INST2SITE_PART = I.OBJID
                    WHERE      PART_SERIAL_NO = I.X_SERVICE_ID;
                    COMMIT;
                    FOR J IN C_SITE_PART (I.X_SERVICE_ID, I.INSTALL_DATE)
                    LOOP
                        UPDATE  sa.TABLE_SITE_PART
                        SET     PART_STATUS = 'Inactive'
                        WHERE   OBJID = J.OBJID;
                        COMMIT;
                        V_MSG:='Updated CarrierPending record in TABLE_SITE_PART to Inactive';
                        LOG_MSG(I.X_SERVICE_ID,  BRAND_IN, V_MSG, 'Fix');
                    END LOOP;
                END IF;

                SELECT  NVL2(X_EXPIRE_DT,X_EXPIRE_DT,'01-JAN-1753'), INSTALL_DATE INTO SP_EXP_DT, SP_ACT_DT
                FROM    sa.TABLE_SITE_PART
                WHERE   X_SERVICE_ID=I.X_SERVICE_ID AND PART_STATUS='Active';
                SELECT  NVL2(X_NEW_DUE_DATE,X_NEW_DUE_DATE,'01-JAN-1753') INTO CT_EXP_DT
                FROM    sa.TABLE_X_CALL_TRANS
                WHERE   X_SERVICE_ID=I.X_SERVICE_ID AND X_TRANSACT_DATE = ( SELECT  MAX(X_TRANSACT_DATE)
                                                                            FROM    sa.TABLE_X_CALL_TRANS
                                                                            WHERE   X_SERVICE_ID= I.X_SERVICE_ID
                                                                            AND     X_ACTION_TYPE IN ('1','3','6')
                                                                            AND     X_TRANSACT_DATE>= SP_ACT_DT);
                IF CT_EXP_DT > SP_EXP_DT THEN
                    UPDATE  sa.TABLE_SITE_PART
                    SET     X_EXPIRE_DT = CT_EXP_DT,
                            WARRANTY_DATE = CT_EXP_DT
                    WHERE   X_SERVICE_ID=I.X_SERVICE_ID
                    AND     PART_STATUS='Active';
                    COMMIT;
                    UPDATE  sa.TABLE_PART_INST
                    SET     WARR_END_DATE = CT_EXP_DT
                    WHERE   PART_SERIAL_NO=I.X_SERVICE_ID;
                    COMMIT;
                    V_MSG:=V_MSG||'Fixed Due Date based on Call Trans New_Due_Date ';
                    LOG_MSG(I.X_SERVICE_ID, BRAND_IN, V_MSG, 'Fix');
                END IF;
            END LOOP;
        EXCEPTION
            WHEN OTHERS THEN
                RETURN;
        END;
-- END OF FIX MISSING MIN PROCEDURE
    PROCEDURE FIX_PORT_IN (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR  C_PORT IS
            SELECT  PART_SERIAL_NO, X_PORT_IN
            FROM    sa.TABLE_PART_INST
            WHERE   PART_SERIAL_NO=ESN;
        C_PRT   C_PORT%ROWTYPE;

     BEGIN
        IF C_PORT%ISOPEN THEN
            CLOSE C_PORT;
        END IF;
        OPEN C_PORT;
        FETCH C_PORT INTO C_PRT;
        IF C_PRT.X_PORT_IN >0 THEN
            UPDATE  sa.TABLE_PART_INST
            SET     X_PORT_IN = NULL
            WHERE   PART_SERIAL_NO = ESN;
            COMMIT;
            V_MSG:='Cleared PORT IN flag';
            LOG_MSG(ESN, BRAND_IN, V_MSG, 'Fix');
        END IF;
        CLOSE C_PORT;

     END;
-- END OF FIX PORT_IN PROCEDURE

    PROCEDURE  ATTACH_LINE (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, LINE IN VARCHAR2, V_MSG OUT VARCHAR2) IS
    BEGIN
        UPDATE  sa.TABLE_PART_INST
        SET     PART_TO_ESN2PART_INST = ( SELECT OBJID
                                          FROM   sa.TABLE_PART_INST
                                          WHERE  PART_SERIAL_NO = ESN
                                          AND    X_DOMAIN||''='PHONES')
        WHERE   PART_SERIAL_NO = LINE
        AND     X_DOMAIN||''='LINES';
        COMMIT;
        V_MSG:='MIN '||LINE||' is attached to '||ESN||CHR(10);
        LOG_MSG(ESN, BRAND_IN, V_MSG, 'Fix');
    END;
-- END OF ATTACH LINE PROCEDURE

    PROCEDURE  DETACH_LINE (LINE IN VARCHAR2, BRAND_IN IN VARCHAR2, ESN_ID IN NUMBER, V_MSG OUT VARCHAR2) IS
        V_PHONE     VARCHAR2(30);
    BEGIN
        SELECT  PART_SERIAL_NO INTO V_PHONE
        FROM    TABLE_PART_INST
        WHERE   OBJID = ESN_ID
        AND     X_DOMAIN='PHONES';

        UPDATE  sa.TABLE_PART_INST
        SET     PART_TO_ESN2PART_INST = NULL
        WHERE   PART_SERIAL_NO = LINE
        AND     PART_TO_ESN2PART_INST=ESN_ID
        AND     X_DOMAIN = 'LINES';
        COMMIT;
        V_MSG:='MIN '||LINE||' is detached from '||V_PHONE;
        LOG_MSG(ESN_ID, BRAND_IN, V_MSG, 'Fix');
    END;
-- END OF DETACH LINE PROCEDURE
    PROCEDURE UPDATE_LINE (LINE IN VARCHAR2, BRAND_IN IN VARCHAR2, STATUS IN VARCHAR2) IS
    BEGIN
        UPDATE  sa.TABLE_PART_INST
        SET     X_PART_INST_STATUS = STATUS,
                STATUS2X_CODE_TABLE = ( SELECT   OBJID
                                        FROM TABLE_X_CODE_TABLE
                                        WHERE X_CODE_NUMBER=STATUS)
        WHERE   PART_SERIAL_NO = LINE
        AND     X_DOMAIN = 'LINES';
        COMMIT;
    END;
-- END OF UPDATE LINE STATUS PROCEDURE
    PROCEDURE  FIX_LINE_PART (LINE IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR  C_LINE IS
            SELECT  PART_SERIAL_NO, N_PART_INST2PART_MOD
            FROM    TABLE_PART_INST
            WHERE   PART_SERIAL_NO=LINE
            AND     X_DOMAIN='LINES';
        C_MIN   C_LINE%ROWTYPE;

    BEGIN
        IF C_LINE%ISOPEN THEN
            CLOSE C_LINE;
        END IF;
        OPEN C_LINE;
        FETCH C_LINE INTO C_MIN;
        IF C_LINE%FOUND THEN
            IF NVL(C_MIN.N_PART_INST2PART_MOD,0)<>23070541 THEN
                UPDATE  TABLE_PART_INST
                SET     N_PART_INST2PART_MOD = 23070541
                WHERE   PART_SERIAL_NO=C_MIN.PART_SERIAL_NO
                AND     X_DOMAIN='LINES';
                COMMIT;
                V_MSG:='Fixed PART NUMBER for LINE '||C_MIN.PART_SERIAL_NO;
                LOG_MSG(LINE, BRAND_IN, V_MSG, 'Fix');
            END IF;
        END IF;
    END;
 -- END OF FIX PART NUMBER FOR LINE PROCEDURE
    PROCEDURE FIX_SITE_PART (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR  C_SITE_PART IS
            SELECT  OBJID, X_MIN, X_SERVICE_ID, PART_STATUS
            FROM    sa.TABLE_SITE_PART SP
            WHERE   X_SERVICE_ID = ESN
            AND     PART_STATUS IN ('Active','CarrierPending');

        V_SP_OBJID      NUMBER;
        V_RESULT        VARCHAR2(200);

    BEGIN
        FOR C_SP IN C_SITE_PART
        LOOP
            SELECT MAX(OBJID) INTO V_SP_OBJID
            FROM    sa.TABLE_SITE_PART
            WHERE   X_SERVICE_ID = ESN
            AND     PART_STATUS IN ('Active','CarrierPending');

            IF C_SP.OBJID <> V_SP_OBJID THEN
                CASE
                    WHEN C_SP.X_MIN LIKE 'T%' THEN
                        UPDATE  sa.TABLE_SITE_PART
                        SET     PART_STATUS = 'Inactive'
                        WHERE   OBJID = C_SP.OBJID;
                        COMMIT;
                        V_MSG:='Fixed TMIN in TABLE_SITE_PART ';
                        LOG_MSG(C_SP.X_SERVICE_ID, BRAND_IN, V_MSG, 'Fix');
                    ELSE
                        UPDATE  sa.TABLE_SITE_PART
                        SET     PART_STATUS = 'Obsolete'
                        WHERE   OBJID = C_SP.OBJID;
                        COMMIT;
                        V_MSG:='Fixed MIN in TABLE_SITE_PART ';
                        LOG_MSG(C_SP.X_SERVICE_ID, BRAND_IN, V_MSG, 'Fix');
                END CASE;
            ELSE
                FIX_MIN (C_SP.X_SERVICE_ID, BRAND_IN, V_RESULT);
            END IF;
                V_MSG:=V_MSG||CHR(10)||V_RESULT;
        END LOOP;
    END;
-- END OF FIX SITE PART PROCEDURE
    PROCEDURE  FIX_ACTIVE_LINE (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR C_LINE IS
            SELECT  LINES.PART_SERIAL_NO LINE, LINES.X_PART_INST_STATUS LINE_STATUS,
                    PHONE.PART_SERIAL_NO ESN, PHONE.X_PART_INST_STATUS ESN_STATUS,
                    PHONE.OBJID ESN_OBJID, PHONE.X_PART_INST2SITE_PART
            FROM    sa.TABLE_PART_INST LINES, sa.TABLE_PART_INST PHONE
            WHERE   LINES.X_DOMAIN = 'LINES'
            AND     LINES.PART_TO_ESN2PART_INST(+) = PHONE.OBJID
            AND     PHONE.X_DOMAIN ='PHONES'
            AND     PHONE.X_PART_INST_STATUS='52'
            AND     PHONE.PART_SERIAL_NO = ESN;

        CURSOR  C_MIN_SP (LINE_IN IN VARCHAR2)IS
            SELECT  OBJID, X_SERVICE_ID, X_MIN, PART_STATUS
            FROM    sa.TABLE_SITE_PART
            WHERE   X_MIN = LINE_IN
            AND     PART_STATUS = 'Active';
        C_SP    C_MIN_SP%ROWTYPE;

        V_RESULT    VARCHAR2(200);
    BEGIN
        FOR LN IN C_LINE
        LOOP
            IF LN.LINE LIKE 'T%' THEN
                DETACH_LINE(LN.LINE, BRAND_IN, LN.ESN_OBJID, V_RESULT);
                V_MSG:=V_MSG||V_RESULT;
            END IF;
            IF C_MIN_SP%ISOPEN THEN
                CLOSE C_MIN_SP;
            END IF;
            OPEN C_MIN_SP(LN.LINE);
            FETCH C_MIN_SP INTO C_SP;
            IF C_MIN_SP%FOUND THEN
                IF C_SP.X_SERVICE_ID = LN.ESN THEN
                    IF C_SP.X_MIN<>LN.LINE THEN
                        DETACH_LINE(LN.LINE, BRAND_IN, LN.ESN_OBJID, V_RESULT);
                        V_MSG:=V_MSG||V_RESULT;
                        ATTACH_LINE (LN.ESN,  BRAND_IN, C_SP.X_MIN, V_RESULT);
                        V_MSG:=V_MSG||V_RESULT;
                        COMMIT;
                    ELSE
                        BEGIN
                            IF LN.LINE_STATUS <> '13' THEN
                                UPDATE_LINE (LN.LINE, BRAND_IN, '13');
                            END IF;
                            FIX_NPA(LN.LINE, BRAND_IN, V_RESULT);
                            V_MSG:=V_MSG||V_RESULT;
                        END;
                    END IF;
                    IF LN.X_PART_INST2SITE_PART <> C_SP.OBJID THEN
                        UPDATE  sa.TABLE_PART_INST
                        SET     X_PART_INST2SITE_PART = C_SP.OBJID
                        WHERE   PART_SERIAL_NO = LN.ESN
                        AND     X_DOMAIN||''='PHONES';
                        COMMIT;
                        V_MSG:=V_MSG||'Fixed TABLE_PART_INST - TABLE_SITE_PART Relation';
                        LOG_MSG(ESN,  BRAND_IN, V_MSG, 'Fix');
                    END IF;
                ELSE
                    DETACH_LINE(LN.LINE, BRAND_IN, LN.ESN_OBJID,V_RESULT);
                    V_MSG:=V_MSG||V_RESULT;
                    ATTACH_LINE(C_SP.X_SERVICE_ID, BRAND_IN, LN.LINE, V_RESULT);
                    V_MSG:=V_MSG||V_RESULT;
                END IF;
            ELSE
                DETACH_LINE(LN.LINE, BRAND_IN, LN.ESN_OBJID, V_RESULT);
            END IF;
            CLOSE C_MIN_SP;
            FIX_LINE_PART(LN.LINE, BRAND_IN, V_RESULT);
         END LOOP;
         FIX_SITE_PART (ESN, BRAND_IN, V_RESULT);
         V_MSG:=V_MSG||V_RESULT;
    END;

    PROCEDURE CHECK_LINE_NOT_ACTIVE_ESN (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR  C_LINE IS
            SELECT  LINE.PART_SERIAL_NO LINE, LINE.X_PART_INST_STATUS LINE_STATUS,
                    PHONE.PART_SERIAL_NO ESN, PHONE.X_PART_INST_STATUS ESN_STATUS, PHONE.OBJID ESN_OBJID
            FROM    sa.TABLE_PART_INST PHONE, sa.TABLE_PART_INST LINE
            WHERE   PHONE.PART_SERIAL_NO=ESN
            AND     LINE.PART_TO_ESN2PART_INST(+) = PHONE.OBJID
            AND     LINE.X_DOMAIN||''='LINES'
            AND     PHONE.X_DOMAIN||''='PHONES';

        V_LINE_CNT  NUMBER;
        V_CODE      NUMBER;
        V_RESULT    VARCHAR2(200);

        FUNCTION CHECK_SITE_PART (ESN IN VARCHAR2, LINE IN VARCHAR2)
            RETURN NUMBER IS
            CURSOR  C_SITE_PART(LINE_IN IN VARCHAR2) IS
            SELECT  X_SERVICE_ID, X_MIN, PART_STATUS
            FROM    sa.TABLE_SITE_PART
            WHERE   X_MIN = LINE_IN
            AND     PART_STATUS = 'Active';
            C_SP    C_SITE_PART%ROWTYPE;

        BEGIN
            IF C_SITE_PART%ISOPEN THEN
                CLOSE C_SITE_PART;
            END IF;
            OPEN C_SITE_PART(LINE);
            FETCH C_SITE_PART INTO C_SP;
            IF C_SITE_PART%NOTFOUND THEN
                RETURN 0;
            ELSE IF C_SP.X_SERVICE_ID<>ESN THEN
                    RETURN 1;
                ELSE
                    RETURN 2;
                END IF; END IF;
        END;

    BEGIN
        SELECT  COUNT(*) INTO V_LINE_CNT
        FROM    sa.TABLE_PART_INST ESN, sa.TABLE_PART_INST LINE
        WHERE   LINE.PART_TO_ESN2PART_INST= ESN.OBJID
        AND     LINE.X_DOMAIN='LINES'
        AND     ESN.X_DOMAIN='PHONES'
        AND     ESN.PART_SERIAL_NO = ESN;

        IF V_LINE_CNT >= 1 THEN
            FOR LINES IN C_LINE
            LOOP
                V_CODE:= CHECK_SITE_PART(LINES.ESN, LINES.LINE);
                CASE
                    WHEN LINES.LINE_STATUS IN ('13') THEN
                        CASE V_CODE
                            WHEN 0 THEN
                                UPDATE_LINE(LINES.LINE, BRAND_IN,'39');
                                DETACH_LINE(LINES.LINE, BRAND_IN, LINES.ESN_OBJID,V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                            WHEN 1 THEN
                                DETACH_LINE(LINES.LINE, BRAND_IN, LINES.ESN_OBJID,V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                            ELSE
                                FIX_MIN (LINES.ESN, BRAND_IN, V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                                FIX_SITE_PART(LINES.ESN, BRAND_IN, V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                         END CASE;
                    WHEN LINES.LINE_STATUS IN ('110') THEN
                        CASE V_CODE
                            WHEN 0 THEN
                                UPDATE_LINE(LINES.LINE, BRAND_IN,'39');
                                DETACH_LINE(LINES.LINE, BRAND_IN, LINES.ESN_OBJID,V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                            WHEN 1 THEN
                                DETACH_LINE(LINES.LINE, BRAND_IN, LINES.ESN_OBJID,V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                            ELSE
                                UPDATE_LINE(LINES.LINE, BRAND_IN,'13');
                                FIX_MIN (LINES.ESN, BRAND_IN, V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                                FIX_SITE_PART(LINES.ESN, BRAND_IN, V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                         END CASE;
                    WHEN LINES.LINE_STATUS = '73' THEN
                        CASE V_CODE
                            WHEN 0 THEN
                                UPDATE_LINE(LINES.LINE, BRAND_IN,'39');
                                DETACH_LINE(LINES.LINE, BRAND_IN, LINES.ESN_OBJID,V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                            WHEN 1 THEN
                                DETACH_LINE(LINES.LINE, BRAND_IN, LINES.ESN_OBJID,V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                            ELSE
                                UPDATE_LINE(LINES.LINE, BRAND_IN,'13');
                                FIX_MIN(LINES.ESN, BRAND_IN, V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                                FIX_SITE_PART(LINES.ESN, BRAND_IN, V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                            END CASE;
                   WHEN LINES.LINE_STATUS = '39' THEN
                        CASE
                            WHEN V_CODE IN (0,1) THEN
                                DETACH_LINE(LINES.LINE, BRAND_IN, LINES.ESN_OBJID, V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                            ELSE
                                UPDATE_LINE(LINES.LINE, BRAND_IN,'13');
                                FIX_MIN(LINES.ESN, BRAND_IN, V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                                FIX_SITE_PART(LINES.ESN, BRAND_IN, V_RESULT);
                                V_MSG:=V_MSG||V_RESULT;
                         END CASE;
                    ELSE
                        NULL;
                    END CASE;
                    FIX_LINE_PART(LINES.LINE, BRAND_IN, V_RESULT);
            END LOOP;
        END IF;
        FOR SP IN (SELECT OBJID, X_SERVICE_ID, X_MIN FROM sa.TABLE_SITE_PART WHERE X_SERVICE_ID= ESN AND PART_STATUS LIKE 'Carr%')
        LOOP
            FIX_MIN(SP.X_SERVICE_ID, BRAND_IN, V_RESULT);
            FIX_SITE_PART(SP.X_SERVICE_ID, BRAND_IN, V_RESULT);
        END LOOP;
    END;

-- END OF FIX ACTIVE LINE PROCEDURE

    PROCEDURE FIX_ACCOUNT_NOT_FOUND (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR C_ESN IS
            SELECT  PI.OBJID, PI.PART_SERIAL_NO ESN, PI.X_PART_INST2CONTACT CONTACT
            FROM    sa.TABLE_PART_INST PI
            WHERE   PI.PART_SERIAL_NO = ESN
            AND     X_PART_INST2CONTACT IS NOT NULL;
        C_PI    C_ESN%ROWTYPE;

        CURSOR C_SITE_PART (ESN IN VARCHAR2) IS
            SELECT  DISTINCT TC.CONTACT_ROLE2CONTACT, TS.X_MIN
            FROM    sa.TABLE_CONTACT_ROLE TC,
                    sa.TABLE_SITE_PART TS
            WHERE   TS.X_SERVICE_ID = ESN
            AND     TC.CONTACT_ROLE2SITE = TS.SITE_OBJID;
        C_SP    C_SITE_PART%ROWTYPE;

        CURSOR C_PART (ESN IN VARCHAR2) IS
            SELECT C.PART_NUMBER, C.PART_NUM2BUS_ORG
            FROM sa.TABLE_PART_INST A, sa.TABLE_MOD_LEVEL B, sa.TABLE_PART_NUM C
            WHERE A.PART_SERIAL_NO = ESN
            AND A.N_PART_INST2PART_MOD=B.OBJID
            AND B.PART_INFO2PART_NUM=C.OBJID;
        C_PN    C_PART%ROWTYPE;

        V_ESN_ID    NUMBER;
        V_CONTACT   NUMBER;
        V_RESULT    VARCHAR2(200);
        OUT_MSG     VARCHAR2(200);

        PROCEDURE CHECK_ADD_INFO (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, CONTACT IN NUMBER, OUT_MSG OUT VARCHAR2) IS
            CURSOR C_ADD_INFO  IS
                SELECT  OBJID, ADD_INFO2CONTACT, ADD_INFO2USER, X_LAST_UPDATE_DATE, ADD_INFO2BUS_ORG, X_INFO_REQUEST
                FROM    sa.TABLE_X_CONTACT_ADD_INFO
                WHERE   ADD_INFO2CONTACT = CONTACT;
            C_ADDINFO   C_ADD_INFO%ROWTYPE;

            V_COUNT     NUMBER;

         BEGIN
            IF C_ADD_INFO%ISOPEN THEN
                CLOSE C_ADD_INFO;
            END IF;
            OPEN C_ADD_INFO;
            FETCH C_ADD_INFO INTO C_ADDINFO;
            IF C_ADD_INFO%NOTFOUND THEN

                OUT_MSG:='CREATE RECORD IN TABLE_X_CONTACT_ADD_INFO';
                LOG_MSG(ESN, BRAND_IN, OUT_MSG, 'Fix');
            ELSE
                SELECT  COUNT(*) INTO V_COUNT
                FROM    sa.TABLE_X_CONTACT_ADD_INFO
                WHERE   ADD_INFO2CONTACT = CONTACT;
                IF V_COUNT=1 THEN
                    CASE
                        WHEN BRAND_IN='TRACFONE' THEN
                            IF NVL(C_ADDINFO.ADD_INFO2BUS_ORG,0)<>268438257 THEN
                                UPDATE  TABLE_X_CONTACT_ADD_INFO
                                SET     ADD_INFO2BUS_ORG = 268438257
                                WHERE   OBJID = C_ADDINFO.OBJID;
                                COMMIT;
                                OUT_MSG:='Fixed BUS ORG in TABLE_X_CONTACT_ADD_INFO for this ESN '||CHR(10);
                                LOG_MSG(ESN, BRAND_IN, OUT_MSG, 'Fix');
                             END IF;
                        WHEN BRAND_IN='NET10' THEN
                            IF NVL(C_ADDINFO.ADD_INFO2BUS_ORG,0)<>268438258 THEN
                                UPDATE  TABLE_X_CONTACT_ADD_INFO
                                SET     ADD_INFO2BUS_ORG = 268438258
                                WHERE   OBJID = C_ADDINFO.OBJID;
                                COMMIT;
                                OUT_MSG:='Fixed BUS ORG in TABLE_X_CONTACT_ADD_INFO for this ESN '||CHR(10);
                                LOG_MSG(ESN, BRAND_IN, OUT_MSG, 'Fix');
                            END IF;
                        ELSE
                            NULL;
                        END CASE;
                ELSE
                    OUT_MSG:='Mulitple ADD INFO Records exist for this ESN '||CHR(10);
                    LOG_MSG(ESN, BRAND_IN, OUT_MSG, 'Fix');
                END IF;
            END IF;
        END;

        PROCEDURE CHECK_WEB_USER (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, CONTACT IN NUMBER, ESN_OBJID IN NUMBER, OUT_MSG OUT VARCHAR2) IS
            CURSOR C_WEB_USER IS
                SELECT  OBJID, WEB_USER2CONTACT, WEB_USER2BUS_ORG
                FROM    sa.TABLE_WEB_USER
                WHERE   WEB_USER2CONTACT = CONTACT;
            C_WEB   C_WEB_USER%ROWTYPE;

            V_MSG       VARCHAR2(200);
            V_COUNT     NUMBER;
        BEGIN
            IF C_WEB_USER%ISOPEN THEN
                CLOSE C_WEB_USER;
            END IF;
            OPEN C_WEB_USER;
            FETCH C_WEB_USER INTO C_WEB;
            IF C_WEB_USER%NOTFOUND THEN
                OUT_MSG:='WEB USER Account need to be created';
                LOG_MSG(ESN, BRAND_IN, OUT_MSG, 'Fix');
            ELSE
                SELECT  COUNT(*) INTO V_COUNT
                FROM    sa.TABLE_WEB_USER
                WHERE   WEB_USER2CONTACT = CONTACT;
                IF V_COUNT=1 THEN
                    CASE
                        WHEN BRAND_IN='TRACFONE' THEN
                            IF NVL(C_WEB.WEB_USER2BUS_ORG,0)<>268438257 THEN
                                UPDATE  TABLE_WEB_USER
                                SET     WEB_USER2BUS_ORG = 268438257
                                WHERE   OBJID = C_WEB.OBJID;
                                COMMIT;
                                OUT_MSG:='Fixed BUS ORG in TABLE_WEB_USER ';
                                LOG_MSG(ESN, BRAND_IN, OUT_MSG, 'Fix');
                            END IF;

                        WHEN BRAND_IN='NET10' THEN
                            IF NVL(C_WEB.WEB_USER2BUS_ORG,0)<>268438258 THEN
                                UPDATE  TABLE_WEB_USER
                                SET     WEB_USER2BUS_ORG = 268438258
                                WHERE   OBJID = C_WEB.OBJID;
                                COMMIT;
                                OUT_MSG:='Fixed BUS ORG in TABLE_WEB_USER ';
                                LOG_MSG(ESN, BRAND_IN, OUT_MSG, 'Fix');
                            END IF;
                    ELSE
                        NULL;
                    END CASE;
                    CHECK_ADD_INFO(ESN, BRAND_IN, CONTACT, V_MSG);
                    OUT_MSG:=OUT_MSG||V_MSG||CHR(10);

                    --CHECK_CONTACT_PART_INST (C_PI.OBJID, V_CONTACT);
                ELSE
                    OUT_MSG:='Multiple WEB USER Accounts exist for this ESN ';
                    LOG_MSG(ESN, BRAND_IN, OUT_MSG, 'Fix');
                    RETURN;
                END IF;
            END IF;
        END;

    BEGIN
        IF C_ESN%ISOPEN THEN
            CLOSE C_ESN;
        END IF;
        OPEN C_ESN;
        FETCH C_ESN INTO C_PI;
        IF C_ESN%NOTFOUND THEN
            IF C_SITE_PART%ISOPEN THEN
                CLOSE C_SITE_PART;
            END IF;
            OPEN C_SITE_PART(C_PI.ESN);
            FETCH C_SITE_PART INTO C_SP;
            CLOSE C_SITE_PART;
            V_CONTACT:=C_SP.CONTACT_ROLE2CONTACT;
            UPDATE  sa.TABLE_PART_INST
            SET     X_PART_INST2CONTACT = C_SP.CONTACT_ROLE2CONTACT
            WHERE   PART_SERIAL_NO=C_PI.ESN;
            COMMIT;
        ELSE
            V_CONTACT:=C_PI.CONTACT;
            V_ESN_ID:=C_PI.OBJID;
        END IF;
        CLOSE C_ESN;
        CHECK_WEB_USER(ESN, BRAND_IN, V_CONTACT, V_ESN_ID, V_RESULT);
        V_MSG:=V_RESULT;
    END;
-- END OF FIX FOR ACCOUNT NOT FOUND PROCEDURE

    PROCEDURE CHECK_SIM (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR  C_SIM_STATUS (ICCID IN VARCHAR2)IS
            SELECT  X_SIM_SERIAL_NO, X_SIM_INV_STATUS
            FROM    sa.TABLE_X_SIM_INV
            WHERE   X_SIM_SERIAL_NO = ICCID;
        C_SIM C_SIM_STATUS%ROWTYPE;

        CURSOR  C_PART_INST IS
            SELECT  PART_SERIAL_NO, X_PART_INST_STATUS, X_ICCID
            FROM    sa.TABLE_PART_INST
            WHERE   PART_SERIAL_NO = ESN
            AND     X_DOMAIN ='PHONES';
        C_PI  C_PART_INST%ROWTYPE;

        PROCEDURE MAKE_SIM_ACTIVE (ICCID IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG1 OUT VARCHAR2) IS
            V_SIM_STATUS  VARCHAR2(5);
            BEGIN
                SELECT  X_SIM_INV_STATUS INTO V_SIM_STATUS
                FROM    sa.TABLE_X_SIM_INV
                WHERE   X_SIM_SERIAL_NO = ICCID;

                IF V_SIM_STATUS IN ('253','251') THEN
                    UPDATE  sa.TABLE_X_SIM_INV
                    SET     X_SIM_INV_STATUS = '254',
                            X_SIM_STATUS2X_CODE_TABLE =268438607
                    WHERE   X_SIM_SERIAL_NO=ICCID;
                    IF SQL%ROWCOUNT=1 THEN
                        COMMIT;
                        V_MSG1:='SIM is updated to Active';
                        LOG_MSG(ESN, BRAND_IN, V_MSG1, 'Fix');
                    END IF;
                END IF;
            END;

         PROCEDURE  RESET_SIM (ICCID IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG2 OUT VARCHAR2) IS
            BEGIN
                UPDATE  sa.TABLE_X_SIM_INV
                SET     X_SIM_INV_STATUS = '253',
                        X_SIM_STATUS2X_CODE_TABLE =268438606
                WHERE   X_SIM_SERIAL_NO=ICCID;
                IF SQL%ROWCOUNT = 1 THEN
                    COMMIT;
                    V_MSG2:='SIM is reset to  New';
                    LOG_MSG(ESN, BRAND_IN, V_MSG2, 'Fix');
                END IF;
            END;

         PROCEDURE CHECK_SIM_STATUS (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, ICCID IN VARCHAR2, V_MSG3 OUT VARCHAR2) IS
            V_SIM_STATUS    VARCHAR2(5);
            V_ESN           VARCHAR2(30);
            BEGIN
                SELECT  X_SIM_INV_STATUS INTO V_SIM_STATUS
                FROM    sa.TABLE_X_SIM_INV
                WHERE   X_SIM_SERIAL_NO = ICCID;

                IF V_SIM_STATUS ='254' THEN
                    SELECT  PART_SERIAL_NO INTO V_ESN
                    FROM    sa.TABLE_PART_INST
                    WHERE   X_ICCID =  ICCID;

                    IF V_ESN<>ESN THEN
                        UPDATE sa.TABLE_PART_INST
                        SET     X_ICCID = NULL
                        WHERE   PART_SERIAL_NO=ESN;
                        COMMIT;
                        V_MSG3:='Detached SIM From ESN';
                        LOG_MSG(ESN, BRAND_IN, V_MSG3, 'Fix');
                    ELSE
                        RESET_SIM(ICCID, BRAND_IN, V_MSG3);
                    END IF;
                END IF;
            END;

    BEGIN
        IF C_PART_INST%ISOPEN THEN
            CLOSE C_PART_INST;
        END IF;
        IF C_SIM_STATUS%ISOPEN THEN
            CLOSE C_SIM_STATUS;
        END IF;
        OPEN C_PART_INST;
        FETCH C_PART_INST INTO C_PI;
        IF C_PI.X_ICCID IS NOT NULL THEN
            IF C_PI.X_PART_INST_STATUS ='52' THEN
                OPEN C_SIM_STATUS(C_PI.X_ICCID);
                FETCH C_SIM_STATUS INTO C_SIM;
                IF C_SIM_STATUS%FOUND THEN
                    MAKE_SIM_ACTIVE(C_PI.X_ICCID, BRAND_IN, V_MSG);
                END IF;
                CLOSE C_SIM_STATUS;
            ELSE
                OPEN C_SIM_STATUS(C_PI.X_ICCID);
                FETCH C_SIM_STATUS INTO C_SIM;
                IF C_SIM_STATUS%FOUND THEN
                    CHECK_SIM_STATUS(C_PI.PART_SERIAL_NO, BRAND_IN, C_PI.X_ICCID, V_MSG);
                END IF;
                CLOSE C_SIM_STATUS;
            END IF;
         END IF;
    END;
-- END OF CHECK SIM PROCEDURE

    PROCEDURE  CHECK_OTA (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2) IS
        CURSOR  C_CALL_TRANS_OTA IS
            SELECT  OBJID, X_SERVICE_ID, X_OTA_TYPE
            FROM    sa.TABLE_X_CALL_TRANS
            WHERE   X_SERVICE_ID= ESN
            AND     X_OTA_TYPE||''='273';
        C_CALL_OTA  C_CALL_TRANS_OTA%ROWTYPE;
        CURSOR  C_OTA_TRANS IS
            SELECT OBJID, X_ESN, X_ACTION_TYPE
            FROM   sa.TABLE_X_OTA_TRANSACTION
            WHERE  X_ACTION_TYPE||''='273'
            AND    X_ESN=ESN;
        C_OTA   C_OTA_TRANS%ROWTYPE;

        CURSOR  C_OTA_SEND IS
            SELECT  OBJID, X_ESN, X_MIN, X_STATUS, X_TRANSACTION_DATE, MAX(X_TRANSACTION_DATE) TRANS_DT
            FROM    sa.TABLE_X_OTA_TRANSACTION
            WHERE   X_ESN=ESN
            AND     X_STATUS IN( 'OTA SEND','OTA PENDING')
            GROUP BY OBJID, X_ESN, X_MIN, X_STATUS, X_TRANSACTION_DATE;
        C_OTAS    C_OTA_SEND%ROWTYPE;

        CURSOR C_CT_OTA IS
            SELECT  OBJID, X_SERVICE_ID ESN, X_TRANSACT_DATE, X_RESULT
            FROM    sa.TABLE_X_CALL_TRANS
            WHERE   1=1
            AND     X_RESULT IN('OTA PENDING')
            AND     X_SERVICE_ID=ESN;
        CURSOR C_CH_OTA (OBJID_IN NUMBER) IS
            SELECT  CODE_HIST2CALL_TRANS ESN, X_CODE_ACCEPTED
            FROM    sa.TABLE_X_CODE_HIST
            WHERE   1=1
            AND     CODE_HIST2CALL_TRANS = OBJID_IN
            AND     X_CODE_ACCEPTED LIKE ('OTA%');

        C_CH    C_CH_OTA%ROWTYPE;

        BEGIN
            IF C_CALL_TRANS_OTA%ISOPEN THEN
                CLOSE C_CALL_TRANS_OTA;
            END IF;
            OPEN C_CALL_TRANS_OTA;
            FETCH C_CALL_TRANS_OTA INTO C_CALL_OTA;
            IF C_CALL_TRANS_OTA%FOUND THEN
                CLOSE C_CALL_TRANS_OTA;
                FOR CT_OTA IN C_CALL_TRANS_OTA
                LOOP
                    UPDATE  sa.TABLE_X_CALL_TRANS
                    SET     X_OTA_TYPE = '264'
                    WHERE   OBJID = CT_OTA.OBJID;
                    COMMIT;
                END LOOP;
            ELSE
                CLOSE C_CALL_TRANS_OTA;
            END IF;

            IF C_OTA_TRANS%ISOPEN THEN
                CLOSE C_OTA_TRANS;
            END IF;
            OPEN C_OTA_TRANS;
            FETCH C_OTA_TRANS INTO C_OTA;
            IF C_OTA_TRANS%FOUND THEN
                CLOSE C_OTA_TRANS;
                FOR OT_OTA IN C_OTA_TRANS
                LOOP
                    UPDATE  sa.TABLE_X_OTA_TRANSACTION
                    SET     X_ACTION_TYPE ='264'
                    WHERE   OBJID = OT_OTA.OBJID;
                    COMMIT;
                END LOOP;
            ELSE
                CLOSE C_OTA_TRANS;
            END IF;

            IF C_OTA_SEND%ISOPEN THEN
                CLOSE C_OTA_SEND;
            END IF;
            OPEN C_OTA_SEND;
            FETCH C_OTA_SEND INTO C_OTAS;
            IF C_OTA_SEND%FOUND THEN
                CLOSE C_OTA_SEND;
                FOR OT_OTA IN C_OTA_SEND
                LOOP
                    UPDATE  sa.TABLE_X_OTA_TRANSACTION
                    SET     X_STATUS = 'Completed'
                    WHERE   OBJID = OT_OTA.OBJID;
                    COMMIT;
                    LOG_MSG(ESN, BRAND_IN, 'Cleared OTA SEND transaction in TABLE_X_OTA_TRANSACTION', 'Fix');
                END LOOP;

                COMMIT;
            ELSE
                CLOSE C_OTA_SEND;
            END IF;

            FOR COT IN C_OTA_SEND
            LOOP
                IF COT.X_TRANSACTION_DATE = COT.TRANS_DT AND COT.X_STATUS LIKE 'OTA PENDING' THEN
                    UPDATE  sa.TABLE_X_OTA_TRANSACTION
                    SET     X_STATUS = 'Completed'
                    WHERE   OBJID = COT.OBJID;
                    COMMIT;
                    LOG_MSG(ESN, BRAND_IN, 'Cleared OTA SEND transaction in TABLE_X_OTA_TRANSACTION', 'Fix');
                 END IF;
            END LOOP;

            FOR CTOTA IN C_CT_OTA
            LOOP
                IF CTOTA.X_RESULT = 'OTA PENDING'  THEN
                    UPDATE  sa.TABLE_X_CALL_TRANS
                    SET     X_RESULT = 'Completed'
                    WHERE   OBJID = CTOTA.OBJID;
                    COMMIT;
                    LOG_MSG(ESN, BRAND_IN, 'Cleared OTA PENDING transaction in TABLE_X_CALL_TRANS', 'Fix');
                    IF C_CH_OTA%ISOPEN THEN
                      CLOSE C_CH_OTA;
                    END IF;
                    OPEN C_CH_OTA(CTOTA.OBJID);
                    FETCH C_CH_OTA INTO C_CH;
                    IF C_CH_OTA%FOUND THEN
                       UPDATE sa.TABLE_X_CODE_HIST
                       SET X_CODE_ACCEPTED = 'YES'
                       WHERE CODE_HIST2CALL_TRANS = CTOTA.OBJID;
                       COMMIT;
                       LOG_MSG(ESN, BRAND_IN, 'Cleared OTA PENDING transaction in TABLE_X_CODE_HIST', 'Fix');
                       CLOSE C_CH_OTA;
                    ELSE
                        CLOSE C_CH_OTA;
                    END IF;
                END IF;
            END LOOP;
        END;
-- END OF FIX OTA SEND PROCEDURE

    PROCEDURE FIX_INCORRECT_SIZE (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR  C_CALL_TRANS IS
            SELECT  MIN(OBJID) CT_OBJID
            FROM    (SELECT  X_SERVICE_ID, X_TRANSACT_DATE, COUNT(X_TRANSACT_DATE) CNT
                     FROM    sa.TABLE_X_CALL_TRANS
                     WHERE   X_SERVICE_ID = ESN
                     AND     X_ACTION_TYPE||'' IN ('2','3')
                     GROUP BY  X_SERVICE_ID,X_TRANSACT_DATE
                     HAVING COUNT(X_TRANSACT_DATE)>1) CT_CNT, sa.TABLE_X_CALL_TRANS CT
            WHERE   CT.X_SERVICE_ID = CT_CNT.X_SERVICE_ID
            AND     CT.X_TRANSACT_DATE =  CT_CNT.X_TRANSACT_DATE;
        C_CT C_CALL_TRANS%ROWTYPE;
        CURSOR  C_CONTACT_ROLE (ESN IN VARCHAR2) IS
            SELECT  CR.OBJID
            FROM    (   SELECT  COUNT(*),CONTACT_ROLE2CONTACT
                        FROM    sa.TABLE_CONTACT_ROLE
                        WHERE   CONTACT_ROLE2CONTACT = ( SELECT NVL(X_PART_INST2CONTACT,0)
                                                         FROM sa.TABLE_PART_INST WHERE PART_SERIAL_NO= ESN)
                        AND     S_ROLE_NAME='DEFAULT'
                        GROUP BY CONTACT_ROLE2CONTACT
                        HAVING COUNT(*)>1) CT, sa.TABLE_CONTACT_ROLE CR
            WHERE   CR.CONTACT_ROLE2CONTACT = CT.CONTACT_ROLE2CONTACT
            AND     CR.OBJID = ( SELECT MIN(OBJID)
                                 FROM   sa.TABLE_CONTACT_ROLE
                                 WHERE  CONTACT_ROLE2CONTACT=CR.CONTACT_ROLE2CONTACT);

        V_CR_CNT        NUMBER;
        V_SITE_OBJID    NUMBER;
        V_PI_HIST       NUMBER;
        V_ESN           VARCHAR2(30);
        V_LINE          VARCHAR2(25);
        V_CHANGE_DT     DATE;
        V_SP_EXIST     NUMBER;

    BEGIN
        IF C_CALL_TRANS%ISOPEN THEN
            CLOSE C_CALL_TRANS;
        END IF;
        OPEN C_CALL_TRANS;
        FETCH C_CALL_TRANS INTO C_CT;
        IF C_CALL_TRANS%FOUND THEN
            UPDATE  sa.TABLE_X_CALL_TRANS
            SET     X_TRANSACT_DATE = X_TRANSACT_DATE-1/86400
            WHERE   OBJID = C_CT.CT_OBJID;
            IF SQL%ROWCOUNT=1 THEN
                COMMIT;
                V_MSG:='UPDATED TIME STAMP OF DEACT RECORD IN TABLE_X_CALL_TRANS BY 1 SECOND';
                LOG_MSG(ESN, BRAND_IN, V_MSG, 'Fix');
            END IF;
        END IF;
        CLOSE C_CALL_TRANS;
     /*
        IF C_ESN_PI%ISOPEN THEN
            CLOSE C_ESN_PI;
        END IF;
        OPEN C_ESN_PI;
        FETCH C_ESN_PI INTO C_ESN;


        SELECT  COUNT(*) INTO V_CR_CNT
        FROM    SA.TABLE_CONTACT_ROLE CR
        WHERE   CR.CONTACT_ROLE2CONTACT = NVL(C_ESN.X_PART_INST2CONTACT,0)
        AND     CR.S_ROLE_NAME = 'DEFAULT';

        SELECT COUNT(*)INTO V_SP_EXIST
        FROM    SA.TABLE_SITE_PART SP
        WHERE   SP.X_SERVICE_ID = ESN
        AND     SP.OBJID = (SELECT MAX(OBJID) FROM SA.TABLE_SITE_PART WHERE X_SERVICE_ID = SP.X_SERVICE_ID);
        --AND PART_STATUS = 'Active';
        IF V_SP_EXIST>0 THEN
            SELECT  SITE_OBJID INTO V_SITE_OBJID
            FROM    SA.TABLE_SITE_PART SP
            WHERE   SP.X_SERVICE_ID = ESN
            AND     SP.OBJID = (SELECT MAX(OBJID) FROM SA.TABLE_SITE_PART WHERE X_SERVICE_ID = SP.X_SERVICE_ID);
            --AND     PART_STATUS='Active';

            IF V_CR_CNT>1 THEN
                UPDATE  SA.TABLE_CONTACT_ROLE
                SET     ROLE_NAME = NULL,
                        S_ROLE_NAME = NULL
                WHERE   CONTACT_ROLE2CONTACT = NVL(C_ESN.X_PART_INST2CONTACT,0)
                AND     CONTACT_ROLE2SITE <> V_SITE_OBJID;
                COMMIT;
            END IF;

            SELECT  COUNT(*) INTO V_CR_CNT
            FROM    SA.TABLE_CONTACT_ROLE CR
            WHERE   CR.CONTACT_ROLE2CONTACT = NVL(C_ESN.X_PART_INST2CONTACT,0)
            AND     (CR.S_ROLE_NAME IS NULL OR CR.ROLE_NAME IS NULL);

            IF V_CR_CNT>0 THEN
                UPDATE  SA.TABLE_CONTACT_ROLE
                SET     ROLE_NAME = 'Default',
                        S_ROLE_NAME = 'DEFAULT'
                WHERE   CONTACT_ROLE2CONTACT = C_ESN.X_PART_INST2CONTACT
                AND     CONTACT_ROLE2SITE = V_SITE_OBJID;
                COMMIT;

            END IF;
        END IF;
        CLOSE C_ESN_PI; */
    END;
-- END OF FIX INCORRECT SIZE PROCEDURE
    PROCEDURE FIX_CONTACT (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR  C_PHONE IS
            SELECT  PART_SERIAL_NO, X_PART_INST_STATUS, X_PART_INST2CONTACT
            FROM    TABLE_PART_INST
            WHERE   PART_SERIAL_NO = ESN
            AND     X_DOMAIN||''='PHONES';
        C_ESN    C_PHONE%ROWTYPE;

        CURSOR  C_CHECK_CONTACT IS
            SELECT  C.OBJID CONTACT_OBJID, C.X_DATEOFBIRTH, C.CITY, C.STATE, C.ZIPCODE,
                    C.COUNTRY, C.E_MAIL, C.S_FIRST_NAME, C.S_LAST_NAME, C.ADDRESS_1,
                    CR.OBJID CONT_ROLE_OBJID, CR.CONTACT_ROLE2SITE, CR.CONTACT_ROLE2CONTACT,
                    S.OBJID SITE_OBJID, S.NAME, S.S_NAME, S.CUST_PRIMADDR2ADDRESS,
                    S.CUST_BILLADDR2ADDRESS, S.CUST_SHIPADDR2ADDRESS
            FROM    sa.TABLE_CONTACT C, sa.TABLE_CONTACT_ROLE CR, sa.TABLE_SITE_PART SP, sa.TABLE_SITE S
            WHERE   CR.CONTACT_ROLE2CONTACT = C.OBJID
            AND     CR.CONTACT_ROLE2SITE = S.OBJID
            AND     SP.SITE_PART2SITE = S.OBJID
            AND     SP.X_SERVICE_ID =ESN
            AND     SP.PART_STATUS='Active';
        C_CONTACT   C_CHECK_CONTACT%ROWTYPE;

        CURSOR C_CONTACTS IS
            SELECT  DISTINCT TC.CONTACT_ROLE2CONTACT CONTACT, TS.X_MIN
            FROM    sa.TABLE_CONTACT_ROLE TC, sa.TABLE_SITE_PART TS
            WHERE   TS.X_SERVICE_ID = ESN
            AND     TS.PART_STATUS='Active'
            AND     TC.CONTACT_ROLE2SITE = TS.SITE_OBJID;
        C_CONT       C_CONTACTS%ROWTYPE;

        CURSOR  C_ADDRESS (OBJID_IN IN NUMBER) IS
            SELECT  OBJID, S_ADDRESS, CITY, STATE, ZIPCODE
            FROM    sa.TABLE_ADDRESS
            WHERE   OBJID = OBJID_IN;
        C_ADD   C_ADDRESS%ROWTYPE;

        CURSOR  C_ZIP_CODE(ZIP IN VARCHAR2) IS
            SELECT  OBJID, X_ZIP, X_CITY, X_STATE
            FROM    sa.TABLE_X_ZIP_CODE
            WHERE   X_ZIP=ZIP
            AND     ROWNUM<2;
        C_ZIP   C_ZIP_CODE%ROWTYPE;

    BEGIN
        IF C_PHONE%ISOPEN THEN
          CLOSE C_PHONE;
        END IF;
        OPEN C_PHONE;
        FETCH C_PHONE INTO C_ESN;
        IF C_ESN.X_PART_INST2CONTACT IS NULL THEN
          IF C_CONTACTS%ISOPEN THEN
            CLOSE C_CONTACTS;
          END IF;
          OPEN C_CONTACTS;
          FETCH C_CONTACTS INTO C_CONT;
          IF C_CONTACTS%FOUND THEN
              UPDATE  sa.TABLE_PART_INST
              SET     X_PART_INST2CONTACT = C_CONT.CONTACT
              WHERE   PART_SERIAL_NO=ESN
              AND     X_DOMAIN='PHONES';
              COMMIT;
              V_MSG:='Fixed NULL CONTACT in TABLE_PART_INST';
              LOG_MSG(ESN, BRAND_IN, V_MSG, 'Fix');
          END IF;
          CLOSE C_CONTACTS;
        END IF;
        IF C_CHECK_CONTACT%ISOPEN THEN
            CLOSE C_CHECK_CONTACT;
        END IF;
        OPEN C_CHECK_CONTACT;
        FETCH C_CHECK_CONTACT INTO C_CONTACT;
        CLOSE C_CHECK_CONTACT;

        IF C_ADDRESS%ISOPEN THEN
            CLOSE C_ADDRESS;
        END IF;
        OPEN C_ADDRESS (C_CONTACT.CUST_PRIMADDR2ADDRESS);
        FETCH C_ADDRESS INTO C_ADD;
        CLOSE C_ADDRESS;

        IF C_ZIP_CODE%ISOPEN THEN
            CLOSE C_ZIP_CODE;
        END IF;
        OPEN  C_ZIP_CODE(C_ADD.ZIPCODE);
        FETCH C_ZIP_CODE INTO C_ZIP;
        CLOSE C_ZIP_CODE;

        IF C_CONTACT.X_DATEOFBIRTH IS NULL THEN
            UPDATE sa.TABLE_CONTACT
            SET X_DATEOFBIRTH=TO_DATE('01/01/1753','MM/DD/YYYY')
            WHERE OBJID = C_CONTACT.CONTACT_OBJID;
            COMMIT;
        END IF;

        IF NVL(C_CONTACT.CITY,'N')<> C_ADD.CITY THEN
            UPDATE sa.TABLE_CONTACT
            SET CITY=C_ZIP.X_CITY
            WHERE OBJID = C_CONTACT.CONTACT_OBJID;
            COMMIT;
        END IF;

        IF NVL(C_CONTACT.STATE,'N')<>C_ADD.STATE THEN
            UPDATE sa.TABLE_CONTACT
            SET STATE=C_ZIP.X_STATE
            WHERE OBJID = C_CONTACT.CONTACT_OBJID;
            COMMIT;
        END IF;

        IF NVL(C_CONTACT.ZIPCODE,'N')<>C_ADD.ZIPCODE THEN
            UPDATE sa.TABLE_CONTACT
            SET ZIPCODE=C_ZIP.X_ZIP
            WHERE OBJID = C_CONTACT.CONTACT_OBJID;
            COMMIT;
        END IF;

        IF C_CONTACT.COUNTRY IS NULL THEN
           UPDATE sa.TABLE_CONTACT
           SET COUNTRY='USA'
           WHERE OBJID = C_CONTACT.CONTACT_OBJID;
           COMMIT;
        END IF;

        IF C_CONTACT.E_MAIL IS NULL THEN
            UPDATE sa.TABLE_CONTACT
            SET E_MAIL='customer@tracfone.com'
            WHERE OBJID = C_CONTACT.CONTACT_OBJID;
            COMMIT;
        END IF;
    END;
-- END OF FIX CONTACT PROCEDURE

    PROCEDURE CHECK_CARRIER_PENDING (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        CURSOR C_CHECK IS
           SELECT   SP.OBJID, SP.X_SERVICE_ID, SP.X_MIN, SP.PART_STATUS, SP.INSTALL_DATE
            FROM    sa.TABLE_SITE_PART SP
            WHERE   SP.X_SERVICE_ID = ESN
            AND     SP.INSTALL_DATE = ( SELECT MAX(INSTALL_DATE)
                                     FROM   sa.TABLE_SITE_PART
                                     WHERE  X_SERVICE_ID = SP.X_SERVICE_ID
                                     AND    PART_STATUS = 'CarrierPending')
            AND     SP.PART_STATUS = 'CarrierPending';
        C_CP   C_CHECK%ROWTYPE;
        V_RESULT  VARCHAR2(200);

        BEGIN
            IF C_CHECK%ISOPEN THEN
                CLOSE C_CHECK;
            END IF;
            OPEN C_CHECK;
            FETCH C_CHECK INTO C_CP;
            IF C_CHECK%FOUND THEN
                IF C_CP.INSTALL_DATE > SYSDATE-4/24 THEN
                    V_MSG:='WAIT';
                    RETURN;
                ELSE
                    V_MSG:='PROCEED';
                    FIX_MIN(C_CP.X_SERVICE_ID, BRAND_IN, V_RESULT);
                    V_MSG:=V_RESULT;
                END IF;
            END IF;
            CLOSE C_CHECK;
        END;
-- END OF CARRIER PENDING PROCEDURE

    PROCEDURE CHECK_ISSUES (ESN IN VARCHAR2, BRAND_IN IN VARCHAR2, V_MSG OUT VARCHAR2) IS
        V_RESULT   VARCHAR2(200);
        V_MSG_FINAL VARCHAR2(500);

        BEGIN
            V_MSG_FINAL:='';
            FIX_MIN(ESN, BRAND_IN, V_RESULT);
            V_MSG_FINAL:=V_MSG||V_RESULT;
            FIX_PORT_IN(ESN, BRAND_IN, V_RESULT);
            V_MSG_FINAL:=V_MSG||V_RESULT;
            FIX_INCORRECT_SIZE(ESN, BRAND_IN, V_RESULT);
            V_MSG_FINAL:=V_MSG||V_RESULT;
            FIX_CONTACT(ESN, BRAND_IN, V_RESULT);
            FIX_100(ESN, BRAND_IN, V_RESULT);
            V_MSG_FINAL:=V_MSG||V_RESULT;
            FIX_CARD(ESN, BRAND_IN, V_RESULT);
            V_MSG_FINAL:=V_MSG||V_RESULT;
            CHECK_OTA(ESN, BRAND_IN);
            V_MSG:=V_MSG_FINAL;
        END;

    BEGIN
        V_MSG:='';
        V_ACCOUNT:='';
        V_OUTCOME :='Successful';
        V_BRAND:= BRAND;
        IF C_PART_INST%ISOPEN THEN
            CLOSE C_PART_INST;
        END IF;
        OPEN C_PART_INST;
        FETCH C_PART_INST INTO C_ESN;
        V_ESN:=C_ESN.PART_SERIAL_NO;
        V_STATUS:=C_ESN.X_PART_INST_STATUS;
        CHECK_CARRIER_PENDING (V_ESN, V_BRAND, V_MSG_CP);
        IF V_MSG_CP ='WAIT' THEN
            V_RESULT :='PLEASE ALLOW 4 HOURS FOR ACTIVATION';
        ELSE
            --CHECK_SWITCHBASE(V_ESN, V_BRAND, V_RESULT);
            V_MSG:=V_MSG||V_RESULT;
            CASE
                WHEN V_STATUS IN ('51','54','50','150') THEN
                    CHECK_LINE_NOT_ACTIVE_ESN(V_ESN, V_BRAND, V_RESULT);
                    V_MSG:=V_MSG||V_RESULT;
                    FIX_PORT_IN(V_ESN, V_BRAND, V_RESULT);
                    V_MSG:=V_MSG||V_RESULT;
                    CHECK_ISSUES(V_ESN, V_BRAND, V_RESULT);
                    V_MSG:=V_MSG||V_RESULT;
                    IF C_ESN.X_TECHNOLOGY = 'GSM' THEN
                        CHECK_SIM(V_ESN, V_BRAND, V_RESULT);
                        V_MSG:=V_MSG||V_RESULT;
                    END IF;
                    FIX_ACCOUNT_NOT_FOUND(V_ESN, V_BRAND, V_RESULT);
                    IF (V_RESULT LIKE '%Multiple%' OR V_RESULT LIKE 'Multiple%') THEN
                        V_ACCOUNT:=V_RESULT;
                    END IF;
                    IF (UPPER(ERROR_IN) LIKE '%LIMITS%' OR UPPER(ERROR_IN) LIKE 'LIMITS%') THEN
                        FIX_LIMITS_EXCEEDED(V_ESN, V_BRAND, V_RESULT);
                        V_MSG:=V_MSG||V_RESULT;
                    END IF;
                WHEN V_STATUS ='59' THEN
                    RAISE INACTIVE_PHONE;
                WHEN V_STATUS = '53' THEN
                    RAISE STOLEN_PHONE;
                WHEN V_STATUS = '56' THEN
                    RAISE RISK_PHONE;
                WHEN V_STATUS = '52' THEN
                    IF C_ACTIVE_ESN%ISOPEN THEN
                        CLOSE C_ACTIVE_ESN;
                    END IF;
                    OPEN C_ACTIVE_ESN(V_ESN);
                    FETCH C_ACTIVE_ESN INTO C_PI;
                    IF C_ACTIVE_ESN%FOUND THEN
                        SELECT  COUNT(*) INTO V_SP_CNT
                        FROM    sa.TABLE_SITE_PART
                        WHERE   X_MIN = C_PI.LINE
                        AND     PART_STATUS = 'Active';
                        IF V_SP_CNT>1 THEN
                            FOR C_SP IN C_SITE_PART(C_PI.LINE)
                            LOOP
                                IF C_SP.X_SERVICE_ID <> C_PI.ESN THEN
                                    V_MULTI1:=C_PI.ESN;
                                    V_MULTI2:=C_SP.X_SERVICE_ID;
                                    V_MIN:=C_SP.X_MIN;
                                    V_MULTI_MSG := 'MIN '||V_MIN||' Is Active with '||V_MULTI1||' and  '||V_MULTI2;
                                    RAISE MULTI_PHONE;
                                END IF;
                            END LOOP;
                        END IF;
                    END IF;
                    CLOSE C_ACTIVE_ESN;
                    CHECK_ISSUES(V_ESN, V_BRAND, V_RESULT);
                    V_MSG:=V_MSG||V_RESULT;
                    FIX_ACCOUNT_NOT_FOUND(C_ESN.PART_SERIAL_NO, V_BRAND, V_RESULT);
                    IF (V_RESULT LIKE '%Multiple%' OR V_RESULT LIKE 'Multiple%') THEN
                        V_ACCOUNT:=V_RESULT;
                    END IF;
                    FIX_ACTIVE_LINE(V_ESN, V_BRAND, V_RESULT);
                    V_MSG:=V_MSG||V_RESULT;
                    IF C_ESN.X_TECHNOLOGY = 'GSM' THEN
                        CHECK_SIM(V_ESN, V_BRAND, V_RESULT);
                        V_MSG:=V_MSG||V_RESULT;
                    END IF;
                    IF (UPPER(ERROR_IN) LIKE '%LIMITS%' OR UPPER(ERROR_IN) LIKE 'LIMITS%') THEN
                        FIX_LIMITS_EXCEEDED(V_ESN, V_BRAND, V_RESULT);
                        V_MSG:=V_MSG||V_RESULT;
                    END IF;
                ELSE
                    NULL;
            END CASE;
        END IF;
        CLOSE C_PART_INST;
        IF V_MSG_CP ='WAIT' THEN
            RESULTS:= 'Please Allows 4 Hours for Activation ';
            V_OUTCOME := 'Unuccessful';
        ELSE
            RESULTS:=V_ACCOUNT||'Please Try Transaction Again As a New Caller';
        END IF;
        LOG_MSG(V_ESN, V_BRAND, ERROR_IN, 'Error');
        CREATE_INTERACTION (V_ESN, ERROR_IN, V_OUTCOME);

        EXCEPTION
            WHEN INACTIVE_PHONE THEN
                LOG_MSG(V_ESN,  V_BRAND, ERROR_IN, 'Error');
                RESULTS := 'ESN is in INACTIVE Status';
                LOG_MSG(V_ESN, V_BRAND, RESULTS, 'Fix');
                CREATE_INTERACTION (V_ESN, ERROR_IN||CHR(10)||RESULTS,'Unsuccessful');
            WHEN STOLEN_PHONE THEN
                LOG_MSG(V_ESN,  V_BRAND, ERROR_IN, 'Error');
                RESULTS := 'ESN is in STOLEN STATUS';
                LOG_MSG(V_ESN, V_BRAND, RESULTS, 'Fix');
                CREATE_INTERACTION (V_ESN, RESULTS,'Unsuccessful');
            WHEN RISK_PHONE THEN
                LOG_MSG(V_ESN,  V_BRAND, ERROR_IN, 'Error');
                RESULTS := 'ESN is under RISK ASSESSMENT';
                LOG_MSG(V_ESN, V_BRAND, RESULTS, 'Fix');
                CREATE_INTERACTION (V_ESN, RESULTS,'Unsuccessful');
            WHEN MULTI_PHONE THEN
                LOG_MSG(V_ESN,  V_BRAND, ERROR_IN, 'Error');
                RESULTS := 'MIN is ACTIVE with more than one ESN'||CHR(10)||V_MULTI_MSG;
                LOG_MSG(V_ESN, V_BRAND, RESULTS, 'Fix');
                CREATE_INTERACTION (V_ESN, RESULTS,'Unsuccessful');
            WHEN NO_DATA_FOUND THEN
                LOG_MSG(V_ESN,  V_BRAND, ERROR_IN, 'Error');
                RESULTS:='Please open a IT TOSS/SYSTEM ERRORS Case';
                LOG_MSG(V_ESN, V_BRAND, RESULTS, 'Fix');
                CREATE_INTERACTION (V_ESN, RESULTS,'Unsuccessful');
    END;
/