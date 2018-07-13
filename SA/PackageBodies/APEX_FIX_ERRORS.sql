CREATE OR REPLACE PACKAGE BODY sa."APEX_FIX_ERRORS" AS
/* =====================================================================================
Author: Daryl de Silva
Date  : 7/26/2016
Description:
This is a master 1052 script. Meant to replace the FIX ESN button, and do every fix we have
under the sun

Changelog:
-----------------------------------------------------------------------------------------
Build 1.016     01/11/2018      ADDED TO SKIP SIMPLE_MOBILE (CO).----icaocabrera

Build 1.015     10/17/2017      ADDED FOR CR54214.----icaocabrera
                                Fix Esn script to add conditions for the existing rules.Below are the conditions:
                                1. Sim status cannot be reset from 250 by either 'Fix ESN' or '1052'.
							    2. Skip updating SP to inactive when "Obsolete" or "Carrier Pending".

Build 1.014     05/18/2017      ADDED TO SKIP WFM (CR50339).----icaocabrera

Build 1.013     12/21/2016      MODIFIED THE IG.STATUS TO INCLUDE SS AS A POSITIVE RESULT

Build 1.012     11/20/2016      MODIFIED THE BRAND PARAMETER FOR STRAIGHT_TALK

Build 1.011     11/16/2016      ISOLATED THE GLOBAL ESN VARIABLE CAUSING ISSUES WITH THE BUTTON CALL FOR FIX ESN IN TAS
                                MODIFIED CREATING A NEW WEB USER TO INCLUDE THE SITE EXTENSION
                                ADDED AN OVERLADED CALL FOR CALL_1052. THE BUTTON CREATES INTERACTIONS, A SCRIPT CALL DOES NOT.

Build 1.011     10/21/2016      FIXED THE CHECK_CARRIER_PENDING PROCEDURE.

Build 1.010     10/21/2016      CALL BACK LOOP WHEN UPDATES ARE MADE TO THE MAIN CURSOR, PART_INST
                                ENABLED THE
                                ENABLED THE CREATION OF MISSING WEB_USER, OTA_FEATURES, AND CONTACT RECORDS


Build 1.009     10/21/2016      ADDED BLOCK OF CODE TO CLEAR OTA_PENDING RECORDS WHEN CALL
                                TRANS IS COMPLETED


Build 1.008     10/19/2016      ADDED FIX_SITE_PART_MULTIPLE_ACTIVE
                                ADDED BLOCK OF CODE TO FIX_MIN TO DEACTIVATE PART_INST IF THERE
                                ARE NO ACTIVE SITE_PART RECORDS.
                                ADDED CALL TO RESET SIM WHEN A LINE IS DETACHED.
                                NOT NULL CHECKS WERE INCORRECT IN 4 PLACES. CHANGED.

Build 1.007     10/4/2016       FUNCTIONS WITHOUT A RETURN VALUE WERE FAILING. ADDED EXCEPTION
                                HANDLING.

Build 1.006     10/4/2016       ADDED A BLOCK TO UPDATE CARRIER PENDING, IF TMIN TO
                                INACTIVE, ELSE TO OBSOLETE

Build 1.005     10/3/2016       ADDED TMIN RESET
                                MODIFIED FIX_GROUP_NO_MASTER
                                ADDED DUGGI'S SUGGESTIONS FOR FIX_GROUP_WRONGBRAND (TW)
                                ADDED FIX_GROUP_DUPLICATE_MASTER
                                ADDED FIX_GROUP_ORDER
                                ADDED EXCEPTION HANDLING FOR ALL PROCEDURES

Build 1.004     9/26/2016       ADDED DUGGI'S SUGGESTIONS FOR CASE PENDING (TW)
                                ADDED FIX_SITE_PART_MOST_RECENT
                                ADDED FIX_SITE_PART_OBSOLETE
                                USE A MORE READER FRIENDLY LOGGED_IN_USER VALUE FOR LOGGING

Build 1.003     9/23/2016       ADDED REFURBISH CLEANUP PROCEDURE FIX_REFURBISH
                                FIXED THE LOGGED IP ADDRESS MISSING.

Build 1.002     9/7/2016        ADDED CLICK_PLAN LOGIC TO THE FIX_MIN PROCEDURE

Build 1.001     8/10/2016       RETIRED THE RULE FOR "MULTIPLE ADD INFO RECORDS ARE IN
                                TABLE_X_CONTACT_ADD_INFO". IN FIX_ACCOUNT PROCEDURE NO ENTRIES
                                SINCE JULY 2015.


========================================================================================*/

--DECLARE

--- VARIABLES  ---------------------------  -----------------------------------------------
  IP_USER             VARCHAR2(30);
  G_IP_USER           VARCHAR2(30);
  V_RESULT            VARCHAR2(5000);
  --V_ERROR             VARCHAR2(5000);
  INT_RESULT          NUMBER;
  V_SP_TMIN           VARCHAR2(30);       --  SITE PART T-MIN EXISTS
  V_CASE_EXIST        VARCHAR2(30);
  V_CARRIERPENDING    VARCHAR2(30);
  V_INSTALL           VARCHAR2(30);
  V_STATUS            VARCHAR2(30);
  V_ACT               VARCHAR2(30);
  V_ACCNT             VARCHAR2(30);
  V_BRAND             VARCHAR2(30);
  V_BRANDID           VARCHAR2(30);
  V_EXISTS            VARCHAR2(30);       -- USED FOR IF THE ESN EXISTS AT ALL
  ESN_IN              VARCHAR2(30);
  ESN                 VARCHAR2(30);
  V_ESN_NICK_NAME     VARCHAR2(250);
  ERROR               VARCHAR2(250);
  MESSAGE_EXCEP       EXCEPTION;
  INACTIVE_PHONE      EXCEPTION;
  STOLEN_PHONE        EXCEPTION;
  RISK_PHONE          EXCEPTION;
  MULTI_PHONE         EXCEPTION;
  WFM_NOT_SUPPORTED   EXCEPTION;-----SKIP WFM (CR50339)--icaocabrera
  SM_NOT_SUPPORTED    EXCEPTION;-----SKIP SIMPLE_MOBILE (CO)--icaocabrera
  V_X_MIN             VARCHAR2(30);
  V_PART_MOD          VARCHAR2(30);
  V_COUNT             NUMBER;
  V_INSERT            VARCHAR2 (25);
  V_CARRIER_ID        VARCHAR2 (15);
  V_ZIP               VARCHAR2 (10);
  DUE_DT              VARCHAR2 (25);
  CT_EXP_DT           DATE;
  SP_EXP_DT           DATE;
  SP_ACT_DT           DATE;
  ESN_OBJ             VARCHAR2 (25);
  V_MSG               VARCHAR2 (500);
  err_num             NUMBER;
  err_msg             VARCHAR2(100);
  V_CLICKPLANID_PN    NUMBER;
  V_CLICKPLANID_TECH  NUMBER;
  V_OUTPUT            VARCHAR2(250);
  V_HAS_OTA_FEATURES  NUMBER;
  RERUN               NUMBER;
  TOTAL_RERUNS        NUMBER := 0;

--- CURSORS  -----------------------------------------------------------------------------



  CURSOR C_PART_INST (ESN_IN IN VARCHAR2)
  IS
  SELECT PI.OBJID,
      PI.PART_SERIAL_NO,
      PI.X_PART_INST_STATUS,
      PI.X_PART_INST2CONTACT CONTACT,
      PI.X_ICCID,
      PN.PART_NUMBER,
      PN.PART_NUM2BUS_ORG BUS_ORG,
      PN.X_TECHNOLOGY,
      PI.X_PORT_IN
    FROM TABLE_PART_INST PI,
      TABLE_MOD_LEVEL ML,
      TABLE_PART_NUM PN
    WHERE PI.PART_SERIAL_NO     = ESN_IN
    AND PI.N_PART_INST2PART_MOD = ML.OBJID
    AND ML.PART_INFO2PART_NUM   = PN.OBJID;

  -- SITE PART CURSOR BY ESN, ACTIVE ONLY
  CURSOR C_SITE_PART_ESN  (ESN_IN IN VARCHAR2)
  IS
  SELECT *
  FROM TABLE_SITE_PART S
  WHERE 1=1
  AND X_SERVICE_ID = ESN_IN
  AND PART_STATUS  ='Active'
  AND INSTALL_DATE =
    (SELECT MAX(INSTALL_DATE)
    FROM TABLE_SITE_PART
    WHERE X_SERVICE_ID= S.X_SERVICE_ID
    AND PART_STATUS   ='Active'
    )
  AND X_MIN NOT LIKE 'T%'
  AND ROWNUM = 1;


  -- SITE PART CURSOR BY ESN, LAST RECORD ONLY
  CURSOR C_LAST_SITE_PART_ESN  (ESN_IN IN VARCHAR2)
  IS
  SELECT *
  FROM TABLE_SITE_PART S
  WHERE X_SERVICE_ID = ESN_IN
  AND INSTALL_DATE =
    (SELECT MAX(INSTALL_DATE)
    FROM TABLE_SITE_PART
    WHERE X_SERVICE_ID= S.X_SERVICE_ID
    )
  AND X_MIN NOT LIKE 'T%'
  AND ROWNUM = 1;
  ACTIVE_SP C_LAST_SITE_PART_ESN%ROWTYPE;

  -- REDEMPTION CARDS BY ESN
  CURSOR C_CARD(ESN IN VARCHAR2)
  IS
    SELECT CARD.PART_SERIAL_NO,
      CARD.X_PART_INST_STATUS
    FROM TABLE_PART_INST CARD,
      TABLE_PART_INST ESN
    WHERE ESN.PART_SERIAL_NO=ESN
    AND ESN.X_DOMAIN ='PHONES'
    AND CARD.PART_TO_ESN2PART_INST = ESN.OBJID
    AND CARD.X_DOMAIN='REDEMPTION CARDS';

  -- SITE PART CURSOR BY SPECIFIC LINE/MIN
  CURSOR C_SITE_PART_LINE (LINE IN VARCHAR2)
  IS
    SELECT OBJID,
      X_SERVICE_ID,
      X_MIN,
      PART_STATUS,
      INSTALL_DATE,
      SERVICE_END_DT,
      X_EXPIRE_DT,
      X_MSID
    FROM TABLE_SITE_PART
    WHERE X_MIN = LINE
    AND PART_STATUS = 'Active'
    AND ROWNUM =1;

    C_SPL C_SITE_PART_LINE%ROWTYPE;



  -- SITE PART CURSOR BY ESN, ACTIVE AND CARRIERPENDING
  CURSOR C_MINS (ESN_IN IN VARCHAR2)
      IS
        SELECT SP.OBJID,
          SP.X_MIN,
          SP.X_SERVICE_ID,
          SP.X_MSID,
          SP.INSTALL_DATE,
          DECODE(NVL(SP.X_EXPIRE_DT,'01-JAN-1753'),'01-JAN-1753','NA',SP.X_EXPIRE_DT)EXPIRE_DT,
          SP.PART_STATUS,
          SP.X_ZIPCODE,
          PN.X_TECHNOLOGY,
          PN.PART_NUM2PART_CLASS,
          PN.PART_NUMBER,
          SP.SITE_PART2X_PLAN,
          SP.SITE_PART2X_NEW_PLAN     ,
          PI.OBJID PI_OBJID
        FROM sa.TABLE_SITE_PART SP,
      TABLE_MOD_LEVEL ML,
      TABLE_PART_NUM PN,
      TABLE_PART_INST PI
        WHERE SP.X_SERVICE_ID = ESN_IN
        AND PI.PART_SERIAL_NO(+)    =SP.X_SERVICE_ID
        AND PI.N_PART_INST2PART_MOD = ML.OBJID
        AND ML.PART_INFO2PART_NUM   = PN.OBJID
        AND SP.PART_STATUS   IN ('Active', 'CarrierPending')
        AND SP.INSTALL_DATE   =
          (SELECT MAX (INSTALL_DATE)
          FROM sa.TABLE_SITE_PART
          WHERE X_SERVICE_ID = SP.X_SERVICE_ID
          AND PART_STATUS   IN ('Active', 'CarrierPending')
          );
  C_MIN_L C_MINS%ROWTYPE;

  -- CALL TRANS RECORD BY ESN AND DATE
  CURSOR C_CALL_TRANS_BY_DATE (ESN_IN IN VARCHAR2, TRANS_DATE IN DATE)
      IS
        SELECT OBJID,
          X_ACTION_TYPE,
          X_SERVICE_ID,
          X_MIN,
          X_RESULT,
          X_NEW_DUE_DATE,
          X_CALL_TRANS2CARRIER
        FROM sa.TABLE_X_CALL_TRANS
        WHERE X_SERVICE_ID           = ESN_IN
        AND TRUNC (X_TRANSACT_DATE) >= TRUNC (TRANS_DATE);

   CURSOR C_SITE_PART_EXCLUDE_DATE (ESN_IN IN VARCHAR2, ACTIVE_DT IN DATE)
      IS
        SELECT OBJID,
          X_SERVICE_ID,
          X_MIN,
          PART_STATUS,
          INSTALL_DATE,
          X_EXPIRE_DT,
          SERVICE_END_DT,
          X_MSID
        FROM sa.TABLE_SITE_PART
        WHERE X_SERVICE_ID = ESN_IN
        AND PART_STATUS   IN ('Active', 'CarrierPending')
        AND INSTALL_DATE  <> ACTIVE_DT;

  -- MOST RECENT CALL TRANS RECORD (ACTIVATION, REACTIVATION, OR REDEMPTION)
  CURSOR C_CALL_TRANS_DUE_DT (ESN_IN IN VARCHAR2)
      IS
        SELECT OBJID,
          X_ACTION_TYPE,
          X_SERVICE_ID,
          X_MIN,
          X_RESULT,
          X_NEW_DUE_DATE,
          X_CALL_TRANS2CARRIER
        FROM sa.TABLE_X_CALL_TRANS
        WHERE X_SERVICE_ID  = ESN_IN
        AND X_TRANSACT_DATE =
          (SELECT MAX (X_TRANSACT_DATE)
          FROM sa.TABLE_X_CALL_TRANS
          WHERE X_SERVICE_ID = ESN_IN
          AND X_ACTION_TYPE IN ('1', '3', '6')
          );

  --MOST RECENT CALL TRANS WITH X_CALL_TRANS2CARRIER NOT NULL
  CURSOR C_CALL_TRANS_CARRER(ESN_IN IN VARCHAR2)
  IS
    SELECT OBJID,
      X_SERVICE_ID,
      X_CALL_TRANS2CARRIER CR
    FROM sa.TABLE_X_CALL_TRANS CT
    WHERE CT.X_SERVICE_ID  = ESN_IN
    AND CT.X_TRANSACT_DATE =
      (SELECT MAX(X_TRANSACT_DATE)
      FROM sa.TABLE_X_CALL_TRANS
      WHERE X_SERVICE_ID        = CT.X_SERVICE_ID
      AND X_CALL_TRANS2CARRIER IS NOT NULL
      ) ;

  -- TRANSACTION AND CALL TRANS CURSOR BY ESN
  CURSOR EPIR_CHK (ESN_IN IN VARCHAR)
      IS
        SELECT ACTION_ITEM_ID,
          ESN,
          MIN,
          MSID,
          CREATION_DATE,
          TECHNOLOGY_FLAG,
          ORDER_TYPE
        FROM GW1.IG_TRANSACTION IG,
          TABLE_X_CALL_TRANS CT,
          TABLE_TASK TT
        WHERE CT.X_SERVICE_ID      =ESN_IN
        AND TT.X_TASK2X_CALL_TRANS = CT.OBJID
        AND IG.ACTION_ITEM_ID      = TT.TASK_ID
        AND IG.STATUS     IN ('S','SS')
        --AND IG.STATUS_MESSAGE IN ('TracFone: Completed succesfully','Transaction successful.','TracFone: transaction completed succesfully','NEWER TRANSACTION FOUND')
        --AND IG.ORDER_TYPE NOT IN ('S','D')
        AND IG.ORDER_TYPE IN ('A','E','CR','EPIR','PIR')
      UNION
      SELECT ACTION_ITEM_ID,
        ESN,
        MIN,
        MSID,
        CREATION_DATE,
        TECHNOLOGY_FLAG,
        ORDER_TYPE
      FROM GW1.IG_TRANSACTION_HISTORY IGH,
        TABLE_X_CALL_TRANS CT,
        TABLE_TASK TT
      WHERE CT.X_SERVICE_ID      = ESN_IN
      AND TT.X_TASK2X_CALL_TRANS = CT.OBJID
      AND IGH.ACTION_ITEM_ID     = TT.TASK_ID
      AND IGH.STATUS || ''       IN ('S','SS')
     -- AND IGH.STATUS_MESSAGE IN ('TracFone: Completed succesfully','Transaction successful.','TracFone: transaction completed succesfully','NEWER TRANSACTION FOUND')
     -- AND IGH.ORDER_TYPE NOT IN ('S','D');
     AND IGH.ORDER_TYPE IN ('A','E','CR','EPIR','PIR');

    -- LINE INFO GIVEN THE ESN
    CURSOR C_MIN(LINE_IN IN VARCHAR2)
    IS
    SELECT PI_LINE.OBJID,
      PI_LINE.PART_SERIAL_NO,
      PI_LINE.X_NPA,
      PI_LINE.X_NXX,
      PI_LINE.X_EXT,
      PI_LINE.PART_INST2CARRIER_MKT,
      PI_LINE.PART_INST2X_PERS,
      PI_ESN.PART_SERIAL_NO ESN
    FROM sa.TABLE_PART_INST PI_LINE,
      sa.TABLE_PART_INST PI_ESN
    WHERE PI_LINE.PART_SERIAL_NO = LINE_IN
    AND PI_ESN.X_DOMAIN='PHONES'
    AND PI_LINE.X_DOMAIN ='LINES'
    AND PI_LINE.PART_TO_ESN2PART_INST = PI_ESN.OBJID
    AND PI_LINE.PART_SERIAL_NO NOT LIKE 'T%';

    --USED IN THE FIX_NPANXX PROCEDURE
    CURSOR C_NPANXX(MIN_IN IN VARCHAR2, CARRIER_ID_IN IN VARCHAR2,ZIP IN VARCHAR2)
      IS
        SELECT DISTINCT SUBSTR (MIN_IN, 1, 3) NPA,
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
            WHEN N.GSM_TECH = 'GSM'
            THEN 'GSM'
            WHEN N.CDMA_TECH = 'CDMA'
            THEN 'CDMA'
            ELSE NULL
          END TECHNOLOGY,
          MIN (N.FREQUENCY1) FREQUENCY1,
          MIN (N.FREQUENCY2) FREQUENCY2,
          MIN (N.BTA_MKT_NUMBER) BTA_MKT_NUMBER,
          MIN (N.BTA_MKT_NAME) BTA_MKT_NAME,
          NULL TDMA_TECH,
          CASE
            WHEN N.GSM_TECH = 'GSM'
            THEN 'GSM'
            WHEN N.CDMA_TECH = 'CDMA'
            THEN 'NULL'
            ELSE NULL
          END GSM_TECH,
          CASE
            WHEN N.CDMA_TECH = 'CDMA'
            THEN 'CDMA'
            ELSE NULL
          END CDMA_TECH,
          CASE
            WHEN (N.CARRIER_NAME LIKE 'AT%T%'
            OR N.CARRIER_NAME LIKE 'CING%')
            THEN 'G0410'
            WHEN N.CARRIER_NAME LIKE 'T-MO%'
            THEN 'G0260'
            ELSE ''
          END MNC_V
        FROM NPANXX2CARRIERZONES N,
          CARRIERZONES C
        WHERE 1     = 1
        AND N.ZONE  = C.ZONE
        AND N.STATE = C.ST
        AND EXISTS
          (SELECT 1
          FROM sa.TABLE_X_CARRIER CR,
            sa.TABLE_X_CARRIER_GROUP CG
          WHERE CG.OBJID      = CR.CARRIER2CARRIER_GROUP
          AND CR.X_STATUS     = 'ACTIVE'
          AND CR.X_CARRIER_ID = CARRIER_ID_IN
          AND N.CARRIER_ID    = CR.X_CARRIER_ID
          )
      AND C.ZIP  = ZIP
      AND ROWNUM < 2
      GROUP BY N.NPA,
        N.NXX,
        N.CARRIER_ID,
        N.CARRIER_NAME,
        N.STATE,
        N.ZONE,
        CASE
          WHEN N.GSM_TECH = 'GSM'
          THEN 'GSM'
          WHEN N.CDMA_TECH = 'CDMA'
          THEN 'CDMA'
          ELSE NULL
        END,
        CASE
          WHEN N.GSM_TECH = 'GSM'
          THEN 'GSM'
          WHEN N.CDMA_TECH = 'CDMA'
          THEN 'NULL'
          ELSE NULL
        END,
        CASE
          WHEN N.CDMA_TECH = 'CDMA'
          THEN 'CDMA'
          ELSE NULL
        END,
        CASE
          WHEN (N.CARRIER_NAME LIKE 'AT%T%'
          AND N.CARRIER_NAME LIKE 'CING%')
          THEN 'G0410'
          WHEN (N.CARRIER_NAME LIKE 'T-MO%')
          THEN 'G0260'
          ELSE ''
        END;

    CURSOR C_LINE(ESN_IN IN VARCHAR2)
        IS
         SELECT LINE,
            LINE_STATUS,
            ESN,
            ESN_STATUS,
            ESN_OBJID, COUNT(A.RN) AS ROWCOUNT,
            X_PART_INST2SITE_PART
            FROM (
                  SELECT
                  LINE.PART_SERIAL_NO LINE,
                  LINE.X_PART_INST_STATUS LINE_STATUS,
                  PHONE.PART_SERIAL_NO ESN,
                  PHONE.X_PART_INST_STATUS ESN_STATUS,
                  PHONE.OBJID ESN_OBJID,
                  ROW_NUMBER() OVER (PARTITION BY LINE.objid ORDER BY LINE.objid)RN
                  ,LINE.X_PART_INST2SITE_PART
                  FROM TABLE_PART_INST PHONE,
                  TABLE_PART_INST LINE
                  WHERE PHONE.PART_SERIAL_NO        = ESN_IN
                  AND LINE.PART_TO_ESN2PART_INST(+) = PHONE.OBJID
                  AND LINE.X_DOMAIN='LINES'
                  AND PHONE.X_DOMAIN='PHONES'
                  ) A
          GROUP BY
          LINE,
          LINE_STATUS,
          ESN,
          ESN_STATUS,
          ESN_OBJID, X_PART_INST2SITE_PART;

  CURSOR C_MUL_ADD(P_CONTACT IN NUMBER)
  IS
    SELECT ADD_INFO2BUS_ORG,
      COUNT(*)
    FROM TABLE_X_CONTACT_ADD_INFO
    WHERE ADD_INFO2CONTACT=P_CONTACT
    AND ADD_INFO2BUS_ORG IS NOT NULL
    GROUP BY ADD_INFO2BUS_ORG
    HAVING COUNT(*)>1 ;

  CURSOR C_ADD_INFO(P_CONTACT IN NUMBER)
  IS
    SELECT OBJID,
      ADD_INFO2CONTACT,
      ADD_INFO2USER,
      X_LAST_UPDATE_DATE,
      ADD_INFO2BUS_ORG,
      X_INFO_REQUEST
    FROM sa.TABLE_X_CONTACT_ADD_INFO
    WHERE ADD_INFO2CONTACT = P_CONTACT;


 CURSOR C_BUS_ORG_CPI(P_CONTACT IN NUMBER, P_ESN IN NUMBER)
  IS
    SELECT DISTINCT PN.PART_NUM2BUS_ORG BUS_ORG
    FROM sa.TABLE_MOD_LEVEL ML,
      sa.TABLE_PART_NUM PN,
      TABLE_PART_INST PI
    WHERE PI.X_DOMAIN='PHONES'
    AND PI.N_PART_INST2PART_MOD = ML.OBJID
    AND ML.PART_INFO2PART_NUM   = PN.OBJID
    AND PI.PART_SERIAL_NO = P_ESN
    AND PI.OBJID               IN
      (SELECT X_CONTACT_PART_INST2PART_INST
      FROM TABLE_X_CONTACT_PART_INST
      WHERE X_CONTACT_PART_INST2CONTACT=P_CONTACT
      );


  CURSOR C_CHECK_CONTACT(ESN IN VARCHAR2)
  IS
    SELECT C.OBJID CONTACT_OBJID,
      C.X_DATEOFBIRTH,
      C.CITY,
      C.STATE,
      C.ZIPCODE,
      C.COUNTRY,
      C.E_MAIL,
      C.S_FIRST_NAME,
      C.S_LAST_NAME,
      C.ADDRESS_1,
      CR.OBJID CONT_ROLE_OBJID,
      CR.CONTACT_ROLE2SITE,
      CR.CONTACT_ROLE2CONTACT,
      S.OBJID SITE_OBJID,
      S.NAME,
      S.S_NAME,
      S.CUST_PRIMADDR2ADDRESS,
      S.CUST_BILLADDR2ADDRESS,
      S.CUST_SHIPADDR2ADDRESS
    FROM sa.TABLE_CONTACT C,
      sa.TABLE_CONTACT_ROLE CR,
      sa.TABLE_SITE_PART SP,
      sa.TABLE_SITE S
    WHERE CR.CONTACT_ROLE2CONTACT = C.OBJID
    AND CR.CONTACT_ROLE2SITE      = S.OBJID
    AND SP.SITE_PART2SITE         = S.OBJID
    AND SP.X_SERVICE_ID           = ESN
    AND SP.PART_STATUS            ='ACTIVE';
  C_CONTACT C_CHECK_CONTACT%ROWTYPE;

  CURSOR C_CONTACTS(ESN IN VARCHAR2)
  IS
    SELECT DISTINCT TC.CONTACT_ROLE2CONTACT CONTACT,
      TS.X_MIN
    FROM sa.TABLE_CONTACT_ROLE TC,
      sa.TABLE_SITE_PART TS
    WHERE TS.X_SERVICE_ID    = ESN
    AND TS.PART_STATUS       ='ACTIVE'
    AND TC.CONTACT_ROLE2SITE = TS.SITE_OBJID;
  C_CONT C_CONTACTS%ROWTYPE;

  CURSOR C_ADDRESS (OBJID_IN IN NUMBER)
  IS
    SELECT OBJID,
      S_ADDRESS,
      CITY,
      STATE,
      ZIPCODE
    FROM sa.TABLE_ADDRESS
    WHERE OBJID = OBJID_IN;
  C_ADD C_ADDRESS%ROWTYPE;

  CURSOR C_ZIP_CODE(ZIP IN VARCHAR2)
  IS
    SELECT OBJID,
      X_ZIP,
      X_CITY,
      X_STATE
    FROM sa.TABLE_X_ZIP_CODE
    WHERE X_ZIP=ZIP
    AND ROWNUM <2;
  C_ZIP C_ZIP_CODE%ROWTYPE;

 CURSOR FIX_CONTACT_DIFF (I_PI_OBJID NUMBER) IS
    SELECT CPI.X_CONTACT_PART_INST2CONTACT
    FROM TABLE_PART_INST PI, TABLE_X_CONTACT_PART_INST CPI
    WHERE PI.OBJID = I_PI_OBJID
    AND PI.OBJID = CPI.X_CONTACT_PART_INST2PART_INST
    AND PI.X_PART_INST2CONTACT != CPI.X_CONTACT_PART_INST2CONTACT
    AND NOT EXISTS (SELECT 1 FROM TABLE_WEB_USER W WHERE W.WEB_USER2CONTACT = PI.X_PART_INST2CONTACT)
    AND EXISTS (SELECT 1 FROM TABLE_WEB_USER W WHERE W.WEB_USER2CONTACT = CPI.X_CONTACT_PART_INST2CONTACT);

  CURSOR CHECK_DUP_CONTACT_ROLE (I_ESN VARCHAR2) IS
    SELECT CR.CONTACT_ROLE2CONTACT, COUNT(*)
    FROM sa.TABLE_PART_INST PI,sa.TABLE_CONTACT_ROLE CR
    WHERE PI.PART_SERIAL_NO = I_ESN
    AND PI.X_DOMAIN = 'PHONES'
    AND CR.CONTACT_ROLE2CONTACT = PI.X_PART_INST2CONTACT
    GROUP BY CR.CONTACT_ROLE2CONTACT;

  CURSOR GET_CONTACT_ROLE (I_ESN VARCHAR2) IS
    SELECT CR.*
    FROM sa.TABLE_PART_INST PI,sa.TABLE_CONTACT_ROLE CR
    WHERE PI.PART_SERIAL_NO = I_ESN
    AND PI.X_DOMAIN = 'PHONES'
    AND CR.CONTACT_ROLE2CONTACT = PI.X_PART_INST2CONTACT;
  C_TCROLE TABLE_CONTACT_ROLE%ROWTYPE;

  CURSOR C_PHONE (I_ESN VARCHAR2)
  IS
    SELECT PART_SERIAL_NO,
      X_PART_INST_STATUS,
      X_PART_INST2CONTACT,
      TS.OBJID SITEID
    FROM TABLE_PART_INST PI,
    TABLE_INV_BIN IB,
    TABLE_SITE TS
    WHERE PART_SERIAL_NO        = I_ESN
    AND PI.PART_INST2INV_BIN    = IB.OBJID
    AND IB.BIN_NAME             = TS.SITE_ID
    AND X_DOMAIN                ='PHONES';
  C_ESN C_PHONE%ROWTYPE;


  -- WEB USER BY CONTACT
  CURSOR WEB_USER(P_CONTACT VARCHAR2)
  IS
    SELECT OBJID,
      WEB_USER2CONTACT,
      WEB_USER2USER,
      X_LAST_UPDATE_DATE,
      WEB_USER2BUS_ORG,
      S_LOGIN_NAME LOG_NAME
    FROM sa.TABLE_WEB_USER
    WHERE WEB_USER2CONTACT =P_CONTACT;
  C_WEB WEB_USER%ROWTYPE;


  --FULL ENROLLMENT RECORD REGARDLESS OF FILTER
  CURSOR ENROLLMENT(P_ESN VARCHAR2)
          IS
            SELECT PE.*,
              PP.X_START_DATE PP_START_DATE,
              PP.X_END_DATE  PP_END_DATE,
              PP.X_IS_RECURRING
            FROM X_PROGRAM_ENROLLED PE,
              X_PROGRAM_PARAMETERS PP
            WHERE PE.X_ESN                 =P_ESN
            AND PE.PGM_ENROLL2PGM_PARAMETER=PP.OBJID;

  --ENROLLMENT WITH TYPE GROUP, BY ESN
  CURSOR ESN_GROUP(P_ESN VARCHAR2)
      IS
        SELECT OBJID,
          X_ESN,
          X_ENROLLMENT_STATUS,
          PGM_ENROLL2PGM_GROUP
        FROM X_PROGRAM_ENROLLED PE
        WHERE X_TYPE='GROUP'
        AND PE.X_ESN=P_ESN;

  --ENROLLMENT WITH TYPE GROUP BUT A PARENT OF THE GROUP.
  --THE OBJID IS THE KEY, USED IN PGM_ENROLL2PGM_GROUP OF CHILDREN
  CURSOR PRIMARY_ESN_GROUP(P_ESN VARCHAR2)
  IS
    SELECT OBJID,
      x_ESN ,
      X_ENROLLMENT_STATUS
    FROM X_PROGRAM_ENROLLED PE
    WHERE X_TYPE  ='GROUP'
    AND PE.OBJID IN
      ( SELECT PGM_ENROLL2PGM_GROUP FROM X_PROGRAM_ENROLLED WHERE X_ESN=P_ESN
      );

   --ENROLLMENT WITH TYPE GROUP BUT A CHILD OF THE GROUP.
  --THE OBJID IS THE KEY, USED IN PGM_ENROLL2PGM_GROUP OF CHILDREN
  CURSOR SECONDARY_ESN_GROUP (PE_OBJID IN NUMBER)
  IS
    SELECT OBJID,
      X_ENROLLMENT_STATUS,
      PGM_ENROLL2PGM_GROUP
    FROM X_PROGRAM_ENROLLED PE
    WHERE X_TYPE            ='GROUP'
    AND PGM_ENROLL2PGM_GROUP=PE_OBJID;

  ----------------------------------------------------------------------------------
  -- FUNCTIONS
  ----------------------------------------------------------------------------------
  FUNCTION GET_CLICKPLAN_PN(PART_OBJID IN VARCHAR2) RETURN NUMBER
  IS
  V_OBJID NUMBER;
  BEGIN

    SELECT OBJID INTO V_OBJID
    FROM TABLE_X_CLICK_PLAN
    WHERE CLICK_PLAN2PART_NUM = PART_OBJID;
    RETURN V_OBJID;

   EXCEPTION
    WHEN OTHERS
    THEN
    RETURN 0;
  END;

  FUNCTION GET_CLICKPLAN_TECH(PART_NUMBER IN VARCHAR2, TECH IN VARCHAR2) RETURN NUMBER
  IS
  V_OBJID NUMBER;
  BEGIN
    SELECT OBJID INTO V_OBJID
    FROM TABLE_X_CLICK_PLAN
    WHERE X_CLICK_TYPE LIKE SUBSTR(PART_NUMBER,1,2)
      ||'%'
      ||TECH
      ||'%';

  RETURN V_OBJID;
  EXCEPTION
    WHEN OTHERS
    THEN
    RETURN 0;

  END;


  FUNCTION GET_WEB_USER_OBJID(P_CONTACT IN VARCHAR2) RETURN NUMBER
  IS
  V_OBJID NUMBER;
  BEGIN
  V_OBJID:=0;
     SELECT
     OBJID INTO V_OBJID
     FROM sa.TABLE_WEB_USER
     WHERE WEB_USER2CONTACT =P_CONTACT;

  V_OBJID:=NVL(V_OBJID,0);
  RETURN V_OBJID;
  EXCEPTION
    WHEN OTHERS
    THEN
    RETURN 0;
  END;

  FUNCTION IS_SAFELINK(V_ESN IN VARCHAR2) RETURN NUMBER
  IS
  V_BOOL NUMBER;
  V_SERV_PLAN VARCHAR2(250);
  V_PART_NO VARCHAR2(250);
  BEGIN
  V_BOOL:=0;
  V_SERV_PLAN:='';
  V_PART_NO:='';

      -- FIRST CHECK TO SEE IF THERE IS A SITEPART RECORD, AND MAP THE SERVICEPLAN
      BEGIN
        SELECT
        UPPER(MKT_NAME)INTO V_SERV_PLAN
        FROM TABLE_SITE_PART SP, X_SERVICE_PLAN_SITE_PART SPLAN, X_SERVICE_PLAN SPL
        WHERE SPLAN.TABLE_SITE_PART_ID=SP.OBJID
        AND SPL.OBJID = SPLAN.X_SERVICE_PLAN_ID
        AND SP.OBJID = (SELECT MAX(OBJID) FROM TABLE_SITE_PART WHERE TABLE_SITE_PART.X_SERVICE_ID = V_ESN);

        CASE
        WHEN UPPER(V_SERV_PLAN) LIKE '%SAFELINK%' THEN
         V_BOOL:=1;
        ELSE
         V_BOOL:=0;
        END CASE;

      RETURN V_BOOL;

      EXCEPTION WHEN NO_DATA_FOUND THEN    --POSSIBLE IT DOESN'T HAVE A SITE_PART RECORD IF IT FAILED BEFORE IT CREATED ONE
        -- GRAB THE PART NUMBER AND CHECK FOR THE LL IN IT
        SELECT UPPER(ML.S_MOD_LEVEL) INTO V_PART_NO
        FROM TABLE_PART_INST PI,
        TABLE_MOD_LEVEL ML,
        TABLE_PART_NUM PN
        WHERE PI.PART_SERIAL_NO     = V_ESN
        AND PI.X_DOMAIN             ='PHONES'
        AND PI.N_PART_INST2PART_MOD = ML.OBJID
        AND ML.PART_INFO2PART_NUM   = PN.OBJID;

        IF V_PART_NO LIKE '%LL%' THEN
           V_BOOL:=1;
        ELSE
           V_BOOL:=0;
        END IF;
        RETURN V_BOOL;
      END;

  RETURN V_BOOL;
  EXCEPTION
    WHEN OTHERS
    THEN
    RETURN 0;

  END;


   --CHECKS WHETHER THIS IS A FEATURE PHONE OR A SMART PHONE, 1=TRUE,0=FALSE
   FUNCTION IS_FEATURE_PHONE(V_ESN IN VARCHAR2) RETURN NUMBER
   IS
   V_BOOL NUMBER;
   V_DEVICE_TYPE VARCHAR2(30);
   BEGIN
     V_BOOL :=1;
     V_DEVICE_TYPE:='';

     SELECT
      X_PARAM_VALUE INTO V_DEVICE_TYPE
      FROM table_part_inst a,
           table_mod_level b,
           table_part_num c,
           table_bus_org d,
           TABLE_X_PART_CLASS_VALUES pcv
      WHERE 1 = 1
       AND a.n_part_inst2part_mod = b.objid
       AND b.part_info2part_num = c.objid
       AND c.part_num2bus_org = d.objid
       and pcv.VALUE2PART_CLASS = c.PART_NUM2PART_CLASS
       and pcv.VALUE2CLASS_PARAM = (select objid from   TABLE_X_PART_CLASS_PARAMS where x_param_name = 'DEVICE_TYPE')
       AND a.part_serial_no =V_ESN;

      CASE
      WHEN V_DEVICE_TYPE IN ('FEATURE_PHONE') THEN
        V_BOOL:=1;
      ELSE
        V_BOOL:=0;
      END CASE;

     RETURN V_BOOL;
     EXCEPTION
    WHEN OTHERS
    THEN
    RETURN 0;

   END;

   -- GETS THE MOST RECENT ACTIVE MIN FOR THE ESN
   FUNCTION GET_MIN_FROM_ESN(V_ESN IN VARCHAR2) RETURN VARCHAR2
   IS
   BEGIN
    V_X_MIN:='';

    SELECT X_MIN INTO V_X_MIN FROM (
      SELECT X_MIN
      FROM TABLE_SITE_PART S
      WHERE 1          =1
      AND X_SERVICE_ID = V_ESN
      AND PART_STATUS  ='Active'
      AND INSTALL_DATE =
        (SELECT MAX(INSTALL_DATE)
        FROM TABLE_SITE_PART
        WHERE X_SERVICE_ID= S.X_SERVICE_ID
        AND PART_STATUS   ='Active'
        )
      AND X_MIN NOT LIKE 'T%'
    ORDER BY OBJID DESC)A WHERE ROWNUM =1;

    RETURN V_X_MIN;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN 'N';
   END;

   --RETURNS THE SITEPART OBJID FOR THE MOST RECENT ACTIVE RECORD GIVEN THE ESN
   FUNCTION GET_SITE_PART_ID(P_ESN IN VARCHAR2) RETURN NUMBER
   IS
   SP_OBJID NUMBER:=0;
   BEGIN

              SELECT MAX(OBJID)
              INTO SP_OBJID
              FROM TABLE_SITE_PART SP
              WHERE SP.X_SERVICE_ID=P_ESN
              AND SP.PART_STATUS  IN( 'Active')
              AND INSTALL_DATE     =
                (SELECT MAX(INSTALL_DATE)
                FROM TABLE_SITE_PART
                WHERE PART_STATUS IN ( 'Active')
                AND X_SERVICE_ID   =SP.X_SERVICE_ID
                )
             ORDER BY INSTALL_DATE DESC;

   RETURN SP_OBJID;

   END;

   --CHECK FOR AN ACTIVE SITE PART LINE
   FUNCTION CHECK_SITE_PART(ESN  IN VARCHAR2, LINE IN VARCHAR2) RETURN NUMBER
    IS
    BEGIN
      OPEN C_SITE_PART_LINE(LINE);
      FETCH C_SITE_PART_LINE INTO C_SPL;
        IF C_SITE_PART_LINE%NOTFOUND THEN
          CLOSE C_SITE_PART_LINE;
          RETURN 0;
        ELSE
          IF C_SPL.X_SERVICE_ID<>ESN THEN
            CLOSE C_SITE_PART_LINE;
            RETURN 1;
          ELSE
          CLOSE C_SITE_PART_LINE;
            RETURN 2;
          END IF;
        END IF;
      CLOSE C_SITE_PART_LINE;


      EXCEPTION
      WHEN NO_DATA_FOUND THEN
      CLOSE C_SITE_PART_LINE;
      RETURN 0;
      WHEN OTHERS THEN
      CLOSE C_SITE_PART_LINE;
      RETURN 0;
    END;

    -- RETURNS THE CARRER ID BASED ON EITHER THE CALL TRANS OR THE IG_TRANSACTION TABLE
    FUNCTION GET_CARRIER(ESN IN VARCHAR2, CREATE_DATE IN DATE) RETURN NUMBER
    IS

      V_CREATION_DATE VARCHAR2(30) :='';
      V_CARRIER_ID NUMBER :=NULL;
    BEGIN

        SELECT X_CARRIER_ID
        INTO V_CARRIER_ID
        FROM sa.TABLE_X_CARRIER
        WHERE OBJID = (
                      SELECT X_CALL_TRANS2CARRIER
                      FROM sa.TABLE_X_CALL_TRANS CT
                      WHERE X_SERVICE_ID  = ESN
                      AND X_ACTION_TYPE  IN ('1', '3')
                      AND X_TRANSACT_DATE =
                            (SELECT MAX (X_TRANSACT_DATE)
                            FROM sa.TABLE_X_CALL_TRANS
                            WHERE X_SERVICE_ID        = CT.X_SERVICE_ID
                            AND X_ACTION_TYPE        IN ('1', '3')
                            AND X_CALL_TRANS2CARRIER IS NOT NULL
                            )
                      );
        IF V_CARRIER_ID IS NOT NULL THEN
          RETURN V_CARRIER_ID;
        ELSE

            SELECT MAX(CREATION_DATE), CARRIER_ID INTO V_CREATION_DATE, V_CARRIER_ID FROM
            (
            SELECT CREATION_DATE, CARRIER_ID
                  FROM GW1.IG_TRANSACTION IG,
                    sa.TABLE_X_CALL_TRANS CT,
                    sa.TABLE_TASK TT
                  WHERE CT.X_SERVICE_ID      = ESN_IN
                  AND TT.X_TASK2X_CALL_TRANS = CT.OBJID
                  AND IG.ACTION_ITEM_ID      = TT.TASK_ID
                  AND IG.STATUS              in ('S','SS')
                  --AND IG.STATUS_MESSAGE     IN ('TracFone: Completed succesfully','Transaction successful.','TracFone: transaction completed succesfully')
                  AND IG.ORDER_TYPE NOT     IN ( 'S','D')
                UNION
                SELECT CREATION_DATE, CARRIER_ID
                FROM GW1.IG_TRANSACTION_HISTORY IGH,
                  sa.TABLE_X_CALL_TRANS CT,
                  sa.TABLE_TASK TT
                WHERE CT.X_SERVICE_ID      = ESN_IN
                AND TT.X_TASK2X_CALL_TRANS = CT.OBJID
                AND IGH.ACTION_ITEM_ID     = TT.TASK_ID
                AND IGH.STATUS             in ('S','SS')
                --AND IGH.STATUS_MESSAGE    IN ('TracFone: Completed succesfully','Transaction successful.','TracFone: transaction completed succesfully')
                AND IGH.ORDER_TYPE NOT    IN ( 'S','D')
            )A GROUP BY CARRIER_ID;


                IF V_CREATION_DATE > CREATE_DATE AND V_CARRIER_ID IS NOT NULL THEN
                    RETURN V_CARRIER_ID;
                ELSE
                    RETURN 0;
                END IF;

        END IF;
    END;

 --- PROCEDURES  --------------------------------------------------------------------------
  /*=======================================================================================
  PROCEDURE: LOG_MSG
  DETAILS  : CREATES A LOG ENTRY IN THE RESOLUTION TABLE, EVEN IF NO FIX WAS FOUND
  =======================================================================================*/
  PROCEDURE LOG_MSG(
      ESN      IN VARCHAR2,
      MSG      IN VARCHAR2,
      BRAND_IN IN VARCHAR2,
      LOG_TYPE IN VARCHAR2)
  IS
  BEGIN

    INSERT INTO ERROR_RESOLUTION_STG
      (
        ESN,
        REASON,
        BRAND,
        INSERT_DATE,
        LOGIN_NAME,
        LOG_TYPE,
        INVOKED_BY
      )
      VALUES
      (
        ESN,
        UPPER(MSG),
        BRAND_IN,
        SYSDATE,
        UPPER(G_IP_USER),
        LOG_TYPE,
        '1052 FORM'
      );
     /*
      INSERT INTO SA.CRM_CASE_RESOLUTIONS
    (REASON, INSERT_DATE, LOGIN_NAME, BRAND, LOG_TYPE, INVOKED_BY, CASE_ID, DOMAIN, PART_SERIAL_NO)
    VALUES
    (UPPER(MSG), SYSDATE, UPPER(G_IP_USER), BRAND_IN, LOG_TYPE, '1052 V2', '','',ESN);

   dbms_output.put_line(ESN || ' , ' || MSG || ' , ' || BRAND_IN || ' , ' || LOG_TYPE || ' , ' || UPPER(G_IP_USER) );
   */
  END;


  /*=======================================================================================
  PROCEDURE: CREATE_INTERACTION
  DETAILS  : CREATES AN INTERACTION WITH RESULTS FOR THE USER
  =======================================================================================*/
    PROCEDURE CREATE_INTERACTION
      (
        ESN     IN VARCHAR2,
        MSG     IN VARCHAR2,
        OUTCOME IN VARCHAR2
      )
    IS
      CURSOR C_PHONE
      IS
        SELECT PART_SERIAL_NO,
          NVL(X_PART_INST2CONTACT,0)CONTACT
        FROM TABLE_PART_INST
        WHERE PART_SERIAL_NO = ESN;
      C_ESN C_PHONE%ROWTYPE;
      V_INTERACT_ID NUMBER;
      V_OBJID       NUMBER;
      V_MESSAGE     VARCHAR(2000);
      V_USER_OBJID  NUMBER;
    BEGIN
      IF C_PHONE%ISOPEN THEN
        CLOSE C_PHONE;
      END IF;
      OPEN C_PHONE;
      FETCH C_PHONE INTO C_ESN;
      IF C_ESN.CONTACT >0 THEN
        SELECT OBJID
        INTO V_USER_OBJID
        FROM TABLE_USER
        WHERE S_LOGIN_NAME = UPPER(G_IP_USER);
        V_OBJID           := sa.SEQ ( 'INTERACT' );
        V_MESSAGE         := 'Fix ESN (1052 Form) was used for this ESN for error : '|| MSG; --||CHR(10)|| 'Please open a SYSTEM ERRORS Case for IT TOSS';

        SELECT sa.SEQU_INTERACTION_ID.NEXTVAL INTO V_INTERACT_ID FROM DUAL;
        INSERT
        INTO sa.TABLE_INTERACT
          (
            OBJID,
            INTERACT_ID,
            CREATE_DATE,
            INSERTED_BY,
            DIRECTION,
            REASON_1,
            S_REASON_1,
            REASON_2,
            S_REASON_2,
            RESULT,
            DONE_IN_ONE,
            FEE_BASED,
            WAIT_TIME,
            SYSTEM_TIME,
            ENTERED_TIME,
            PAY_OPTION,
            START_DATE,
            END_DATE,
            ARCH_IND,
            AGENT,
            S_AGENT,
            INTERACT2USER,
            INTERACT2CONTACT,
            X_SERVICE_TYPE,
            SERIAL_NO
          )
          VALUES
          (
            V_OBJID,
            V_INTERACT_ID,
            SYSDATE,
            UPPER(G_IP_USER),
            'Inbound',
            'Technical',
            'TECHNICAL',
            '1052 Fix',
            '1052 FIX',
            'Successful',
            0,
            0,
            0,
            0,
            0,
            'None',
            SYSDATE,
            '31-Dec-2055',
            0,
            UPPER(G_IP_USER),
            UPPER(G_IP_USER),
            V_USER_OBJID,
            C_ESN.CONTACT,
            'Wireless',
            ESN
          );
        COMMIT;
        INSERT
        INTO sa.TABLE_INTERACT_TXT
          (
            OBJID,
            NOTES,
            INTERACT_TXT2INTERACT
          )
          VALUES
          (
            sa.SEQ ( 'INTERACT_TXT' ),
            V_MESSAGE
            ||CHR(10)
            ||MSG,
            V_OBJID
          );
        COMMIT;
      END IF;
      CLOSE C_PHONE;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    END;
    -- END OF CREATE_INTERACTION PROCEDURE


 /*=======================================================================================
    PROCEDURE: RESET_SIM
    DETAILS  : SET SIM STATUS BACK TO 253
    =======================================================================================*/
    PROCEDURE RESET_SIM(
      P_ESN     IN VARCHAR2,
      P_BRAND   IN VARCHAR2,
      P_ICCID   IN VARCHAR2,
      V_MSG     OUT VARCHAR2)
    IS
    V_ESN_STATUS VARCHAR2(200);
    BEGIN
      V_ESN_STATUS := '';
      SELECT  X_PART_INST_STATUS INTO V_ESN_STATUS FROM TABLE_PART_INST WHERE PART_SERIAL_NO = P_ESN;

      IF (V_ESN_STATUS='50') THEN
        ----CR54214: Sim status cannot be reset from 250. Value 250 excluded
        UPDATE sa.TABLE_X_SIM_INV
        SET
          X_SIM_INV_STATUS          = '253',
          X_SIM_STATUS2X_CODE_TABLE = 268438606
        WHERE X_SIM_SERIAL_NO       = P_ICCID
          AND X_SIM_INV_STATUS        not in ('253','250');
        IF SQL%ROWCOUNT             >0 THEN
          V_MSG:='SIM IS RESET TO NEW';
          LOG_MSG(P_ESN, V_MSG, P_BRAND, 'FIX');
        END IF;
      ELSE
      ----CR54214: Sim status cannot be reset from 250. Value 250 excluded
        UPDATE sa.TABLE_X_SIM_INV
        SET
          X_SIM_INV_STATUS          = '251',
          X_SIM_STATUS2X_CODE_TABLE = 268438604
        WHERE X_SIM_SERIAL_NO       = P_ICCID
        AND X_SIM_INV_STATUS        not in ('251','250');
        IF SQL%ROWCOUNT             >0 THEN
          V_MSG:='SIM IS RESET TO RESERVED';
          LOG_MSG(P_ESN, V_MSG, P_BRAND, 'FIX');
        END IF;


      END IF;

    EXCEPTION
          WHEN OTHERS THEN
            RETURN;
    END;

  /*=======================================================================================
  PROCEDURE: UPDATE_LINE
  DETAILS  : UPDATES THE X_PART_INST_STATUS TO PASSED STATUS FOR LINE PARAMETER
  =======================================================================================*/
  PROCEDURE UPDATE_LINE(
    ESN_IN  IN VARCHAR2,
    LINE    IN VARCHAR2,
    V_BRAND IN VARCHAR2,
    STATUS  IN VARCHAR2)
    IS
    BEGIN
      UPDATE TABLE_PART_INST
      SET X_PART_INST_STATUS = STATUS,
        STATUS2X_CODE_TABLE  =
        ( SELECT OBJID FROM TABLE_X_CODE_TABLE WHERE X_CODE_NUMBER=STATUS
        )
      WHERE PART_SERIAL_NO = LINE
      AND X_DOMAIN         = 'LINES'
      AND X_PART_INST_STATUS != STATUS;
      IF SQL%ROWCOUNT >0 THEN
       V_MSG:='MIN '||LINE||' STATUS IS UPDATED TO ' || STATUS;
       LOG_MSG(ESN_IN, V_MSG,V_BRAND, 'FIX');
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
    V_MSG:='';
    END;

  /*=======================================================================================
    PROCEDURE: ATTACH_LINE
    DETAILS  : UPDATES THE PART_TO_ESN2PART_INST TO TABLE_PART_INST OBJID
    =======================================================================================*/
    PROCEDURE ATTACH_LINE(
        ESN     IN VARCHAR2,
        V_BRAND IN VARCHAR2,
        LINE    IN VARCHAR2,
        V_MSG OUT VARCHAR2)
    IS
    BEGIN
      UPDATE TABLE_PART_INST
      SET PART_TO_ESN2PART_INST =
        (SELECT OBJID
        FROM TABLE_PART_INST
        WHERE PART_SERIAL_NO = ESN
        AND X_DOMAIN='PHONES'
        )
      WHERE PART_SERIAL_NO = LINE
      AND X_DOMAIN ='LINES'
      AND PART_TO_ESN2PART_INST !=
        (SELECT OBJID
        FROM TABLE_PART_INST
        WHERE PART_SERIAL_NO = ESN
        AND X_DOMAIN='PHONES'
        );
      IF SQL%ROWCOUNT >0 THEN
       -- RERUN:=1;
        V_MSG:='MIN '||LINE||' IS ATTACHED TO '||ESN;
        LOG_MSG(ESN, V_MSG,V_BRAND, 'FIX');
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
    V_MSG:='';
    END;

  /*=======================================================================================
    PROCEDURE: DETACH_LINE
    DETAILS  : UPDATES THE PART_TO_ESN2PART_INST TO NULL FOR THE PARAMETER ESN
    NOTE     : IT BRANCHES OUT IF THE MIN IS A TMIN. CALLS THE UPDATE_LINE, SETS THE LINE TO
               RETURNED (17)
    =======================================================================================*/
    PROCEDURE DETACH_LINE(
        LINE    IN VARCHAR2,
        V_BRAND IN VARCHAR2,
        ESN_ID  IN NUMBER,
        V_MSG OUT VARCHAR2)
    IS
      V_PHONE VARCHAR2(30);
    BEGIN
      SELECT PART_SERIAL_NO
      INTO V_PHONE
      FROM TABLE_PART_INST
      WHERE OBJID = ESN_ID
      AND X_DOMAIN='PHONES';
      IF LINE LIKE 'T%' THEN
        UPDATE_LINE (V_PHONE, LINE, V_BRAND,'17');
      END IF;

      UPDATE TABLE_PART_INST
      SET PART_TO_ESN2PART_INST = NULL
      WHERE PART_SERIAL_NO      = LINE
      AND PART_TO_ESN2PART_INST = ESN_ID
      AND X_DOMAIN              = 'LINES';
      IF SQL%ROWCOUNT >0 THEN
        RERUN:=1;
        V_MSG:='MIN '||LINE||' IS DETACHED FROM '||V_PHONE;
        LOG_MSG(V_PHONE, V_MSG,V_BRAND, 'FIX');
      END IF;

    EXCEPTION
    WHEN OTHERS THEN
    V_MSG:='';
    END;

  /*=======================================================================================
  PROCEDURE: FIX_LINE_PART
  DETAILS  : SETS PART_MOD TO 23070541, WHICH MAPS TO 'LINE' IN TABLE_PART_NUM
  =======================================================================================*/
    PROCEDURE FIX_LINE_PART(
        LINE    IN VARCHAR2,
        V_BRAND IN VARCHAR2,
        V_MSG OUT VARCHAR2)
    IS

    BEGIN
        V_PART_MOD:='';
        SELECT N_PART_INST2PART_MOD
        INTO V_PART_MOD
        FROM TABLE_PART_INST
        WHERE PART_SERIAL_NO  =LINE
        AND X_DOMAIN          ='LINES';

        IF NVL(V_PART_MOD,0)<>23070541 THEN
          UPDATE TABLE_PART_INST
          SET N_PART_INST2PART_MOD = 23070541
          WHERE PART_SERIAL_NO     = LINE
          AND X_DOMAIN             ='LINES';
          IF SQL%ROWCOUNT >0 THEN
            RERUN:=1;
            V_MSG:='FIXED PART NUMBER FOR LINE '||LINE;
            LOG_MSG(LINE,V_MSG,V_BRAND, 'FIX');
          END IF;
        END IF;

  EXCEPTION
    WHEN OTHERS THEN
    V_MSG:='';
  END;

  /*=======================================================================================
  PROCEDURE: SET_PH_FROM_IG
  DETAILS  : A LOGIC PROCEDURE. SETS THE OUTBOUND MIN BASED ON RULES
  =======================================================================================*/
  PROCEDURE SET_PH_FROM_IG(
        TECHNOLOGY_FLAG VARCHAR2,
        P_MSID IG_TRANSACTION.MSID%TYPE,
        P_MIN IG_TRANSACTION.MIN%TYPE ,
        V_MIN OUT TABLE_SITE_PART.X_MIN%TYPE,
        V_MSID OUT TABLE_SITE_PART.X_MSID%TYPE )
    IS
    BEGIN
      CASE
      WHEN TECHNOLOGY_FLAG = 'G' AND NVL(P_MSID,'T') NOT LIKE 'T%' THEN --GSM
        IF NVL(P_MIN,'T') LIKE 'T%' THEN
          V_MIN := P_MSID;
        ELSE
          V_MIN := P_MIN;
        END IF;
        V_MSID            := P_MSID;
      WHEN TECHNOLOGY_FLAG = 'C' AND NVL(P_MSID,'T') NOT LIKE 'T%' AND NVL(P_MIN,'T') NOT LIKE 'T%' THEN --CDMA
        V_MIN             := P_MSID;
        V_MSID            := P_MSID;
      ELSE
        V_MIN  := NULL;
        V_MSID := NULL;
      END CASE;

    EXCEPTION
    WHEN OTHERS THEN
    V_MSG:='';
    END;


    /*=======================================================================================
    PROCEDURE: INSERT_NPANXX
    DETAILS  :
    =======================================================================================*/
    PROCEDURE INSERT_NPANXX(
        ESN           IN VARCHAR2,
        V_BRAND       IN VARCHAR2,
        MIN_IN        IN VARCHAR2,
        CARRIER_ID_IN IN VARCHAR2,
        ZIP           IN VARCHAR2)
    IS

    BEGIN

     FOR C_NPX IN C_NPANXX(MIN_IN, CARRIER_ID_IN, ZIP)
     LOOP
      --WILL ONLY RETURN ONE RECORD
        INSERT
        INTO NPANXX2CARRIERZONES VALUES
          (
            C_NPX.NPA,
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
            C_NPX.MNC_V
          );
        IF SQL%ROWCOUNT >0 THEN
            V_MSG:='INSERTED NPANXX2CARRIERZONES RECORD';
            LOG_MSG(ESN,V_MSG,V_BRAND, 'FIX');
        END IF;

     END LOOP;

    EXCEPTION
    WHEN OTHERS THEN
    V_MSG:='';
    END;


  /*=======================================================================================
  PROCEDURE: INSERT_MIN
  DETAILS  : ONCE THERE IS A CARRIER AND ESN IS NOT ACTIVE, THEN SET ESN (PART_INST) TO ACTIVE
             CHECK THE NUMBER OF LINES. IF NONE FOUND THEN CALL A CREATE LINE PACKAGE.
             CHECK NUMBER OF LINES AFTER THIS, IF ONE IS FOUND THEN FIND THE LINE IN PART_INST
             AND SET TO ACTIVE (13)
  =======================================================================================*/
  PROCEDURE INSERT_MIN
      (
        MIN_IN    IN VARCHAR2,
        ESN_OBJID IN VARCHAR2,
        P_ESN     IN VARCHAR2,
        P_BRAND   IN VARCHAR2,
        MSID      IN VARCHAR2,
        P_CARRIER IN VARCHAR2,
        EXP_DT    IN VARCHAR2,
        P_STATUS  IN VARCHAR2,
        P_ZIP     IN VARCHAR2
      )
    IS

      V_MIN           VARCHAR2(25);
      OP_CARRIER_ID   NUMBER;
      OP_CARRIER_NAME VARCHAR2 (100);
      OP_RESULT       NUMBER;
      OP_MSG          VARCHAR2 (250);
      MIN_EX          NUMBER;
    BEGIN
      V_MIN := MIN_IN;

      --ONCE WE HAVE A VALID CARRIER THEN CONTINUE
      IF NVL(P_CARRIER,0) != 0 THEN
          --IF THE ESN STATUS IS NOT ACTIVE, THEN CHANGE TO ACTIVE
          IF P_STATUS <> '52' THEN
            UPDATE sa.TABLE_PART_INST
            SET X_PART_INST_STATUS  = '52',
                STATUS2X_CODE_TABLE = 988
            WHERE OBJID             = ESN_OBJID;
            IF SQL%ROWCOUNT >0 THEN
              LOG_MSG(P_ESN,'ESN UPDATED TO ACTIVE',V_BRAND, 'FIX');
            END IF;
          END IF;

          -- THEN COUNT THE NUMBER OF LINES WE HAVE
          SELECT COUNT(*)
          INTO MIN_EX
          FROM sa.TABLE_PART_INST
          WHERE PART_SERIAL_NO=MIN_IN
          AND X_DOMAIN='LINES';

          -- IF NO LINES THEN INSERT A LINE
          IF MIN_EX=0 THEN
            TOPPAPP.LINE_INSERT_PKG.LINE_VALIDATION ( MSID, MIN_IN, P_CARRIER, 'CRM_APP_SUPPORT', '1', EXP_DT, OP_CARRIER_ID, OP_CARRIER_NAME, OP_RESULT, OP_MSG);    ----PERMISSIONS
            IF OP_RESULT = 102 THEN
              INSERT_NPANXX(P_ESN, V_BRAND, MIN_IN, P_CARRIER, P_ZIP);
              TOPPAPP.LINE_INSERT_PKG.LINE_VALIDATION ( MSID, MIN_IN, P_CARRIER, 'CRM_APP_SUPPORT', '1', EXP_DT, OP_CARRIER_ID, OP_CARRIER_NAME,OP_RESULT, OP_MSG);   ----PERMISSIONS
            END IF;
            LOG_MSG(P_ESN, 'INSERTED LINE '|| MIN_IN ||' INTO INVENTORY', V_BRAND,'FIX');
          END IF;

          --COUNTING AGAIN TO MAKE SURE IT WAS ADDED
          SELECT COUNT(*)
          INTO MIN_EX
          FROM sa.TABLE_PART_INST
          WHERE PART_SERIAL_NO=V_MIN;

          IF MIN_EX >0 THEN
            UPDATE sa.TABLE_PART_INST
            SET PART_TO_ESN2PART_INST = ESN_OBJID,
              X_PART_INST_STATUS      = '13',
              STATUS2X_CODE_TABLE     = 960
            WHERE PART_SERIAL_NO      = MIN_IN
            AND X_DOMAIN              = 'LINES'
            AND X_PART_INST_STATUS   != '13'
            AND STATUS2X_CODE_TABLE  != 960;
            IF SQL%ROWCOUNT >0 THEN
              V_INSERT := 'SUCCESS';
              LOG_MSG(P_ESN, 'SET LINE '  || MIN_IN || ' TO ACTIVE AND ATTACHED', V_BRAND,'FIX');
            ELSE
              V_INSERT := 'FAILED';
             -- LOG_MSG(ESN, 'SET LINE '  || MIN_IN || ' TO ACTIVE FAILED ' || ESN_OBJID, V_BRAND,'LOG');
            END IF;

          ELSE
          --UNABLE TO ADD THE LINE, LOG IT
            V_INSERT := 'FAILED';
            LOG_MSG(P_ESN, 'UNABLE TO INSERT LINE FOR ' || MIN_IN, V_BRAND,'LOG');
          END IF;

        END IF;

    EXCEPTION
    WHEN OTHERS THEN
    V_MSG:='';
    END;


 /*=======================================================================================
  PROCEDURE: CHECK_MIN_IG
  DETAILS  : COMPARES THE MIN INFORMATION IN THE CALL_TRANS AGAINST THE IG_TRANSACTION TABLE
  =======================================================================================*/
 PROCEDURE CHECK_MIN_IG(
        ESN         IN VARCHAR2,
        CREATE_DATE IN DATE,
        EXP_DT      IN VARCHAR2,
        V_BRAND     IN VARCHAR2)
    IS

    V_MIN TABLE_SITE_PART.X_MIN%TYPE := NULL;
    V_MSID TABLE_SITE_PART.X_MSID%TYPE := NULL;

    BEGIN



      FOR IG IN EPIR_CHK (ESN)
        LOOP

           IF IG.CREATION_DATE >= CREATE_DATE THEN
              SET_PH_FROM_IG(IG.TECHNOLOGY_FLAG, IG.MSID, IG.MIN, V_MIN, V_MSID );

              IF NVL(V_MSID,'T') NOT LIKE 'T%' THEN
                UPDATE sa.TABLE_SITE_PART
                SET X_MIN          = V_MIN,
                  X_MSID           = V_MSID,
                  PART_STATUS      = 'Active'
                WHERE X_SERVICE_ID = ESN
                AND PART_STATUS   IN ('Active', 'CarrierPending')
                AND INSTALL_DATE   = CREATE_DATE;
                IF SQL%ROWCOUNT >0 THEN
                  LOG_MSG(ESN, 'TABLE_SITE_PART UPDATED FROM CARRIERPENDING TO ACTIVE',V_BRAND, 'FIX');

                  UPDATE sa.TABLE_PART_INST
	                  SET X_PART_INST_STATUS = '52',
	                  STATUS2X_CODE_TABLE = '988'
	                  WHERE PART_SERIAL_NO = ESN
	                  AND X_PART_INST_STATUS != '52'
	                  AND X_DOMAIN = 'PHONES';
	                  IF SQL%ROWCOUNT >0 THEN
	                    LOG_MSG(ESN, 'TABLE_PART_INST UPDATED TO ACTIVE',V_BRAND, 'FIX');
	                  END IF;

                END IF;

                FOR CT IN C_CALL_TRANS_BY_DATE (ESN, CREATE_DATE)
                LOOP
                  -- IF CALL TRANS MIN IS DIFFERENT FROM THE IG_TRANSACTION MIN, THEN UPDATE CALL_TRANS MIN
                  IF CT.X_MIN <> IG.MIN THEN
                    UPDATE sa.TABLE_X_CALL_TRANS SET X_MIN = IG.MIN WHERE OBJID = CT.OBJID;
                    IF SQL%ROWCOUNT >0 THEN
                      LOG_MSG(ESN, 'CALL TRANS UPDATED. MIN TO '|| IG.MIN, V_BRAND, 'FIX');
                    END IF;
                  END IF;

                  -- IF CALL TRANS WAS AN ACTIVATION OR REACTIVATION, AND THE RESULT STILL SAYS FAILED, UPDATE IT TO COMPLETED.
                  IF (CT.X_ACTION_TYPE IN ('1','3') AND UPPER(CT.X_RESULT) ='FAILED') THEN
                    UPDATE sa.TABLE_X_CALL_TRANS
                    SET X_RESULT = 'Completed'
                    WHERE OBJID  = CT.OBJID;
                    IF SQL%ROWCOUNT >0 THEN
                      LOG_MSG(ESN, 'CALL TRANS RECORD UPDATED TO COMPLETED',V_BRAND, 'FIX');
                    END IF;
                  END IF;

                END LOOP;
              ELSE
                 LOG_MSG(ESN, 'NO VALID MIN FOUND IN IG_TRANSACTION TABLE',V_BRAND, 'LOG');
              END IF;

             END IF;
        END LOOP;

    EXCEPTION
    WHEN OTHERS THEN
    V_MSG:='';
    END;

 /*=======================================================================================
  PROCEDURE: CHECK_MIN_SITE_PART
  DETAILS  :
  =======================================================================================*/
 PROCEDURE CHECK_MIN_SITE_PART(
        MIN_INP   IN VARCHAR2,
        EXP_DT    IN VARCHAR2,
        V_ESN     IN VARCHAR2,
        V_BRAND   IN VARCHAR2,
        V_STATUS  IN VARCHAR2,
        V_ZIP     IN VARCHAR2)
    IS

    BEGIN


    FOR C_MIN_SP IN C_SITE_PART_LINE(MIN_INP)
    LOOP



         IF C_MIN_SP.X_MSID LIKE 'T%' THEN
            FOR IG IN EPIR_CHK (C_MIN_SP.X_SERVICE_ID)
            LOOP
             IF IG.CREATION_DATE>=C_MIN_SP.INSTALL_DATE THEN
                IF IG.MSID NOT LIKE 'T%' THEN
                  UPDATE sa.TABLE_SITE_PART SET X_MSID = IG.MSID WHERE OBJID = C_MIN_SP.OBJID;
                  IF SQL%ROWCOUNT >0 THEN
                   LOG_MSG(V_ESN, 'TABLE_SITE_PART UPDATED. MSISD TO ' || IG.MSID ,V_BRAND, 'FIX');
                  END IF;
                END IF;
              END IF;
            END LOOP;


            --PUT IN THE TMIN CODE HERE

         END IF;

        SELECT OBJID
        INTO ESN_OBJ
        FROM sa.TABLE_PART_INST
        WHERE PART_SERIAL_NO = C_MIN_SP.X_SERVICE_ID;

        IF ESN_OBJ > 0 THEN
          INSERT_MIN(C_MIN_SP.X_MIN, ESN_OBJ, V_ESN, V_BRAND, C_MIN_SP.X_MSID, GET_CARRIER (C_MIN_SP.X_SERVICE_ID, C_MIN_SP.INSTALL_DATE), EXP_DT, V_STATUS, V_ZIP);

        END IF;
    END LOOP;

    EXCEPTION
    WHEN OTHERS THEN
    V_MSG:='';
    END;

  /*=======================================================================================
  PROCEDURE: FIX_MIN
  DETAILS  : This procedure calls multiple procedures and a function
             INSERT_MIN, CHECK_MIN_SITE_PART, CHECK_MIN_IG, GET_CARRIER.
             The idea is to fix any MIN issues that may be found
  =======================================================================================*/
  PROCEDURE FIX_MIN(
    ESN_IN  IN VARCHAR2,
    V_BRAND IN VARCHAR2,
    V_STATUS IN VARCHAR2,
    V_ICCID IN VARCHAR2,
    V_MSG OUT VARCHAR2)
    IS
    DUE_DT  VARCHAR2(30) :='';
    V_ZIP   VARCHAR2(30) :='';
    V_ACTIVE_SP VARCHAR2(30) :='';
    VAR_STATUS  VARCHAR2(30) :='';
    VAR_CHECK integer:= 0;

    BEGIN



        BEGIN
         SELECT COUNT(OBJID) OBJID INTO V_ACTIVE_SP
         FROM TABLE_SITE_PART
         WHERE X_SERVICE_ID = ESN_IN
         AND PART_STATUS in ('Active','CarrierPending');



         IF V_ACTIVE_SP = 0 THEN
              --MEANS THERE ARE NO ACTIVE SITE PART RECORDS

                UPDATE TABLE_PART_INST
                SET X_PART_INST_STATUS    = '39',
                STATUS2X_CODE_TABLE = '1040'
                WHERE
                PART_TO_ESN2PART_INST IN (SELECT PI.OBJID
                                         FROM TABLE_PART_INST PI
                                         WHERE PI.PART_SERIAL_NO IN (ESN_IN))
                AND X_DOMAIN              = 'LINES'
                AND X_PART_INST_STATUS   != '39'
                AND STATUS2X_CODE_TABLE   != '1040';
                IF SQL%ROWCOUNT >0 THEN
                  V_MSG:='NO ACTIVE SP RECORDS. UPDATED LINE TO RESERVED USED';
                  LOG_MSG(ESN_IN, V_MSG,V_BRAND, 'FIX');
                END IF;

              --THEN DEACTIVATE THE PART_INST RECORD
                UPDATE TABLE_PART_INST
                SET X_PART_INST_STATUS = '51',
                STATUS2X_CODE_TABLE = '987'
                WHERE PART_SERIAL_NO = ESN_IN
                AND X_PART_INST_STATUS ='52';

                IF SQL%ROWCOUNT >0 THEN
                  LOG_MSG(ESN_IN,'NO ACTIVE SP RECORDS. UPDATED PHONE TO USED',V_BRAND, 'FIX');
                END IF;


             -- FINALLY RESET THE PREVIOUSLY ATTACHED SIM
                RESET_SIM(ESN_IN, V_BRAND, V_ICCID, V_MSG);

               RETURN;

            END IF;


        EXCEPTION WHEN OTHERS THEN
          LOG_MSG(ESN_IN, SQLERRM , V_BRAND, 'LOG');
        END;




        -- START BY PULLING ALL MINS (BY ESN), THAT ARE ACTIVE OR CARRIERPENDING
        FOR I IN C_MINS(ESN_IN)
        LOOP

          IF I.EXPIRE_DT = 'NA' THEN
            -- PULL THE MOST RECENT ACTIVATION, REACTIVATION OR REDEMPTION TRANSACTION RECORD
            FOR C_CT IN C_CALL_TRANS_DUE_DT(I.X_SERVICE_ID)
            LOOP
                IF NVL (C_CT.X_NEW_DUE_DATE, '01-JAN-1753') > '01-JAN-1753' THEN --<< MEANS THERE IS A VALID DUE DATE IN CALL_TRANS
                  UPDATE TABLE_SITE_PART
                  SET X_EXPIRE_DT = C_CT.X_NEW_DUE_DATE
                  WHERE OBJID     = I.OBJID;
                  IF SQL%ROWCOUNT >0 THEN
                    LOG_MSG(I.X_SERVICE_ID,'SITE PART DUE DATE UPDATED TO ' || C_CT.X_NEW_DUE_DATE,V_BRAND, 'FIX');
                    DUE_DT := C_CT.X_NEW_DUE_DATE;
                  END IF;
                ELSE
                  SELECT NULL INTO DUE_DT FROM DUAL;
                END IF;
            END LOOP;
          END IF;



           IF I.SITE_PART2X_PLAN IS NULL THEN
              --UPDATE TO THE NEW PLAN IF ONE EXISTS
              IF I.SITE_PART2X_NEW_PLAN IS NOT NULL THEN
                UPDATE TABLE_SITE_PART
                SET
                  SITE_PART2X_PLAN     = I.SITE_PART2X_NEW_PLAN,
                  SITE_PART2X_NEW_PLAN  =NULL
                WHERE OBJID           = I.OBJID;
                  IF SQL%ROWCOUNT >0 THEN
                    LOG_MSG(I.X_SERVICE_ID,'SITE_PART2X_PLAN UPDATED TO ' || I.SITE_PART2X_NEW_PLAN,V_BRAND, 'FIX');
                  END IF;
              END IF;


              --CHECKING FOR CLICK PLAN NOW

              V_CLICKPLANID_PN    := GET_CLICKPLAN_PN(I.OBJID);

              V_CLICKPLANID_TECH  := GET_CLICKPLAN_TECH(I.PART_NUMBER, I.X_TECHNOLOGY);


              IF V_CLICKPLANID_PN IS NOT NULL AND V_CLICKPLANID_PN !=0 THEN

                UPDATE TABLE_SITE_PART
                SET
                  SITE_PART2X_PLAN  = V_CLICKPLANID_PN,
                  SITE_PART2X_NEW_PLAN=NULL
                WHERE OBJID           = I.OBJID;
                IF SQL%ROWCOUNT >0 THEN
                    LOG_MSG(I.X_SERVICE_ID,'SITE_PART2X_PLAN UPDATED TO ' || V_CLICKPLANID_PN || ' BASED ON CLICK_PLAN TABLE AND PART NUMBER',V_BRAND, 'FIX');
                END IF;

              ELSE

                IF V_CLICKPLANID_TECH IS NOT NULL AND V_CLICKPLANID_TECH !=0 THEN

                    UPDATE TABLE_SITE_PART
                    SET
                      SITE_PART2X_PLAN  = V_CLICKPLANID_TECH,
                      SITE_PART2X_NEW_PLAN=NULL
                    WHERE OBJID           = I.OBJID;
                    IF SQL%ROWCOUNT >0 THEN
                        LOG_MSG(I.X_SERVICE_ID,'SITE_PART2X_PLAN UPDATED TO ' || V_CLICKPLANID_TECH|| ' BASED ON CLICK_PLAN TABLE, TECHNOLOGY AND PART TYPE',V_BRAND, 'FIX');
                    END IF;
                END IF;
              END IF;

              IF I.SITE_PART2X_PLAN <> V_CLICKPLANID_TECH THEN

                  UPDATE TABLE_SITE_PART
                  SET SITE_PART2X_PLAN = V_CLICKPLANID_TECH
                  WHERE OBJID          = I.OBJID;
                   IF SQL%ROWCOUNT >0 THEN
                    LOG_MSG(I.X_SERVICE_ID,'SITE_PART2X_PLAN UPDATED TO ' || V_CLICKPLANID_TECH || ' BASED ON CLICK_PLAN',V_BRAND, 'FIX');
                  END IF;
              END IF;

          END IF;

          V_ZIP := I.X_ZIPCODE;
          SELECT DECODE (NVL (DUE_DT, '01-JAN-1753'),'01-JAN-1753', 'NA',I.EXPIRE_DT)
          INTO DUE_DT
          FROM DUAL;



          IF I.X_MIN LIKE 'T%' OR I.PART_STATUS LIKE 'C%' THEN  --<<-- TMIN OR CARRIERPENDING




            CHECK_MIN_IG (I.X_SERVICE_ID, I.INSTALL_DATE, DUE_DT, V_BRAND);

            SELECT PART_STATUS INTO VAR_STATUS FROM TABLE_SITE_PART WHERE OBJID = I.OBJID;
             IF VAR_STATUS = 'Active' THEN
	                GOTO LEAVE;
	            END IF;



            -- ITS A TMIN WITH AN ACTIVE STATUS, SO RESET IT SO THEY CAN RETRY
            IF I.PART_STATUS = 'Active' THEN
              UPDATE TABLE_SITE_PART
              SET PART_STATUS = 'Inactive'
              , X_DEACT_REASON= 'FIX 1052',
              SERVICE_END_DT  = SYSDATE
              WHERE OBJID = I.OBJID;
              IF SQL%ROWCOUNT >0 THEN
                LOG_MSG(I.X_SERVICE_ID,'TMIN ISSUE - RESET PART_STATUS TO INACTIVE',V_BRAND, 'FIX');
              END IF;

              UPDATE TABLE_PART_INST SET  X_PART_INST_STATUS = '51', STATUS2X_CODE_TABLE = 987 WHERE PART_SERIAL_NO = I.X_SERVICE_ID;
              IF SQL%ROWCOUNT >0 THEN
                RERUN:=1;
                LOG_MSG(I.X_SERVICE_ID,'TMIN ISSUE - RESET X_PART_INST_STATUS TO USED',V_BRAND, 'FIX');
              END IF;

              UPDATE TABLE_PART_INST
                SET X_PART_INST_STATUS    = '39',
                STATUS2X_CODE_TABLE = '1040'
                WHERE
                PART_TO_ESN2PART_INST IN (SELECT PI.OBJID
                                         FROM TABLE_PART_INST PI
                                         WHERE PI.PART_SERIAL_NO IN (ESN_IN))
                AND X_DOMAIN              = 'LINES';
                IF SQL%ROWCOUNT >0 THEN
                  RERUN:=1;
                  V_MSG:='TMIN ISSUE - RESET LINE TO USED';
                  LOG_MSG(ESN_IN, V_MSG,V_BRAND, 'FIX');
                END IF;

              --SHOULD ALSO RESET SIM TO NEW
              RESET_SIM(I.X_SERVICE_ID, V_BRAND, V_ICCID, V_MSG);
              RERUN:=1;
              --AND THEN DISCONNECT THE SIM

            ELSE

                      IF I.X_MIN LIKE 'T%' THEN
                        UPDATE TABLE_SITE_PART
                        SET PART_STATUS ='Inactive'
                        , X_DEACT_REASON= 'FIX 1052',
                        SERVICE_END_DT  = SYSDATE
                        WHERE OBJID     = I.OBJID;
                        IF SQL%ROWCOUNT >0 THEN
                          LOG_MSG(I.X_SERVICE_ID,'TMIN ISSUE STUCK IN CARRIER PENDING - SET TO INACTIVE',V_BRAND, 'FIX');
                          --DETACH THE LINE
                          DETACH_LINE(I.X_MIN, V_BRAND, I.PI_OBJID, V_RESULT);
                          RERUN:=1;
                        END IF;
                      ELSE
                        UPDATE TABLE_SITE_PART
                        SET PART_STATUS ='Obsolete'
                        WHERE OBJID     = I.OBJID;
                        IF SQL%ROWCOUNT >0 THEN
                          LOG_MSG(I.X_SERVICE_ID,'STUCK IN CARRIERPENDING - SET TO OBSOLETE',V_BRAND, 'FIX');
                          RERUN:=1;
                        END IF;
                      END IF;
            END IF;

          ELSE

            CHECK_MIN_SITE_PART (I.X_MIN, DUE_DT, I.X_SERVICE_ID, V_BRAND, V_STATUS, V_ZIP);
          END IF;

          ---- THIS IS ONLY IF THERE WAS A NEED TO INSERT_MIN-------------------------------------------------------------------------------


          IF V_INSERT = 'SUCCESS' THEN
            UPDATE sa.TABLE_PART_INST
            SET X_PART_INST2SITE_PART = I.OBJID
            WHERE PART_SERIAL_NO      = I.X_SERVICE_ID
            AND X_PART_INST2SITE_PART != I.OBJID;
            IF SQL%ROWCOUNT >0 THEN
              V_MSG:='ATTACHED MIN TO ESN';
              LOG_MSG(I.X_SERVICE_ID, V_MSG,V_BRAND, 'FIX');
            END IF;

            FOR J IN C_SITE_PART_EXCLUDE_DATE (I.X_SERVICE_ID, I.INSTALL_DATE)
            LOOP

              ---CR54214: 2. Skip updating SP to inactive when obsolete or carrier pending.
	              select count(*)
	               into VAR_CHECK
	               from TABLE_SITE_PART t
	              WHERE t.OBJID = J.OBJID
	               and  t.PART_STATUS IN ('CarrierPending','Obsolete');

             if VAR_CHECK = 0 then

              UPDATE TABLE_SITE_PART
              SET PART_STATUS = 'Inactive'
              , X_DEACT_REASON= 'FIX 1052',
              SERVICE_END_DT  = SYSDATE
              WHERE OBJID = J.OBJID;
              IF SQL%ROWCOUNT >0 THEN
                V_MSG:='UPDATED RECORD(NOT CARRIERPENDING/OBSOLETE) IN TABLE_SITE_PART TO INACTIVE';
                LOG_MSG(I.X_SERVICE_ID, V_MSG,V_BRAND, 'FIX');
              END IF;

             END IF;

            END LOOP;
          END IF;
          ---------------------------------------------------------------------------------------------------------------------------------
          BEGIN



            SELECT NVL2(X_EXPIRE_DT,X_EXPIRE_DT,'01-JAN-1753'),
              INSTALL_DATE
            INTO SP_EXP_DT,
              SP_ACT_DT
            FROM sa.TABLE_SITE_PART
            WHERE X_SERVICE_ID=I.X_SERVICE_ID
            AND PART_STATUS   ='Active';


            SELECT NVL2(X_NEW_DUE_DATE,X_NEW_DUE_DATE,'01-JAN-1753')
            INTO CT_EXP_DT
            FROM sa.TABLE_X_CALL_TRANS
            WHERE X_SERVICE_ID  =I.X_SERVICE_ID
            AND X_ACTION_TYPE  IN ('1','3','6')
            AND X_TRANSACT_DATE =
              (SELECT MAX(X_TRANSACT_DATE)
              FROM sa.TABLE_X_CALL_TRANS
              WHERE X_SERVICE_ID  = I.X_SERVICE_ID
              AND X_ACTION_TYPE  IN ('1','3','6')
              AND X_TRANSACT_DATE>= SP_ACT_DT
              )
            AND ROWNUM=1;


            IF CT_EXP_DT > SP_EXP_DT THEN
              UPDATE sa.TABLE_SITE_PART
              SET X_EXPIRE_DT   = CT_EXP_DT,
                WARRANTY_DATE   = CT_EXP_DT
              WHERE X_SERVICE_ID=I.X_SERVICE_ID
              AND PART_STATUS   ='Active';
              IF SQL%ROWCOUNT >0 THEN
                V_MSG:='FIXED SITEPART DUE DATE AND WARRANTY DATE BASED ON CALL TRANS DUE DATE';
                LOG_MSG(I.X_SERVICE_ID, V_MSG,V_BRAND, 'FIX');
              END IF;

              UPDATE sa.TABLE_PART_INST
              SET WARR_END_DATE   = CT_EXP_DT
              WHERE PART_SERIAL_NO=I.X_SERVICE_ID;
              IF SQL%ROWCOUNT >0 THEN
                V_MSG:='FIXED PARTINST WARR_END_DATE BASED ON CALL TRANS DUE DATE';
                LOG_MSG(I.X_SERVICE_ID, V_MSG,V_BRAND, 'FIX');
              END IF;
            END IF;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
            V_MSG:='';
          WHEN OTHERS THEN
            LOG_MSG(ESN_IN, SQLERRM , V_BRAND, 'LOG');
          END;
        END LOOP;

      -- WHAT IF THE MIN WASN'T ACTIVE AT ALL

       -- V_MSG := 'FIX_MIN';
       -- LOG_MSG(ESN_IN, V_MSG,V_BRAND, 'FIX');
       <<LEAVE>>
       V_MSG := '';
    EXCEPTION
    WHEN OTHERS THEN
      LOG_MSG(ESN_IN, 'ERROR IN FIX_MIN PROCEDURE',V_BRAND, 'LOG');
     -- RETURN;
    END;

  /*=======================================================================================
  PROCEDURE: FIX_SITE_PART
  DETAILS  :
  NOTES    :
  =======================================================================================*/
 PROCEDURE FIX_SITE_PART(
  ESN     IN VARCHAR2,
  V_BRAND IN VARCHAR2,
  V_MSG OUT VARCHAR2)
  IS
    CURSOR C_SITE_PART
    IS
      SELECT OBJID,
        X_MIN,
        X_SERVICE_ID,
        PART_STATUS
      FROM TABLE_SITE_PART SP
      WHERE X_SERVICE_ID = ESN
      AND PART_STATUS   IN ('Active','CarrierPending');
    V_SP_OBJID NUMBER;

  BEGIN
    FOR C_SP IN C_SITE_PART
    LOOP
      SELECT MAX(OBJID)
      INTO V_SP_OBJID
      FROM TABLE_SITE_PART
      WHERE X_SERVICE_ID = ESN
      AND PART_STATUS   IN ('Active','CarrierPending');

      IF C_SP.OBJID     <> V_SP_OBJID THEN
        CASE
        WHEN C_SP.X_MIN LIKE 'T%' THEN
         UPDATE TABLE_SITE_PART
              SET PART_STATUS = 'Inactive'
              , X_DEACT_REASON= 'FIX 1052',
              SERVICE_END_DT  = SYSDATE
          WHERE OBJID     = C_SP.OBJID;

          V_MSG:='Fixed TMIN IN TABLE_SITE_PART. STATUS SET TO INACTIVE.';
          LOG_MSG(C_SP.X_SERVICE_ID, V_MSG,V_BRAND, 'FIX');
        ELSE
          UPDATE TABLE_SITE_PART
              SET PART_STATUS = 'Inactive' --OBSOLETE?
              , X_DEACT_REASON= 'FIX 1052',
              SERVICE_END_DT  = SYSDATE
          WHERE OBJID     = C_SP.OBJID;

          V_MSG:='Fixed MIN IN TABLE_SITE_PART. STATUS SET TO INACTIVE.';
          LOG_MSG(C_SP.X_SERVICE_ID, V_MSG,V_BRAND, 'FIX');
        END CASE;
      END IF;
      V_MSG:=V_MSG || V_RESULT;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN;
  END;

  /*=======================================================================================
  PROCEDURE: CHECK_CARRIER_PENDING
  DETAILS  : CHECKS IF THE ESN IS IN CARRIER PENDING STATUS, AND WITHIN THE 4 HOUR TIME FRAME
  =======================================================================================*/
  PROCEDURE CHECK_CARRIER_PENDING(ESN_IN IN VARCHAR2, IS_C_PENDING OUT VARCHAR2)
  IS
  BEGIN
  IS_C_PENDING :=0;


      SELECT COUNT(*)
      INTO V_CARRIERPENDING
      FROM TABLE_SITE_PART
      WHERE X_SERVICE_ID = ESN_IN
      AND PART_STATUS='CarrierPending';


      IF V_CARRIERPENDING <>0 THEN
        SELECT MAX(INSTALL_DATE)
        INTO V_INSTALL
        FROM TABLE_SITE_PART
        WHERE X_SERVICE_ID=ESN_IN;
        V_ACT:=0;


        FOR I IN EPIR_CHK(ESN_IN)
        LOOP

            IF I.CREATION_DATE>=V_INSTALL THEN
              V_ACT:=1;
            ELSIF V_INSTALL BETWEEN SYSDATE-4/24 AND sysdate THEN
              V_ACT:=0;
            END IF;
        END LOOP;


        IF V_ACT = 0 THEN
          IF V_INSTALL >SYSDATE-4/24 THEN
                V_ACT:=0; -- NOT ACTIVE AND LESS THAN 4 HOURS
                IS_C_PENDING := 1;
                V_RESULT:='Please wait 4 hours for Activation to complete';
                LOG_MSG(ESN_IN,V_RESULT,v_brand, 'NA CP');
          END IF;
        END IF;


      END IF;


  EXCEPTION
    WHEN OTHERS THEN
      RETURN;
  END;

/*=======================================================================================
  PROCEDURE: CHECK_SWITCHBASE
  DETAILS  : IF SWITCHBASED TRANSACTION HAS A STATUS OF CARRIER PENDING, SET TO COMPLETED
  =======================================================================================*/
  PROCEDURE CHECK_SWITCHBASE(
    ESN_IN    IN VARCHAR2,
    BRAND_IN  IN VARCHAR2,
    V_MSG     OUT VARCHAR2)
  IS
    CURSOR C_CHECK
    IS
      SELECT SBT.*
      FROM X_SWITCHBASED_TRANSACTION SBT,
        TABLE_X_CALL_TRANS CT
      WHERE SBT.X_SB_TRANS2X_CALL_TRANS = CT.OBJID
      AND CT.X_SERVICE_ID               = ESN_IN
      AND CT.X_ACTION_TYPE IN ('1','3','6','111','85')
      AND SBT.STATUS                    = 'CarrierPending';
  BEGIN
    FOR C_SBT IN C_CHECK
    LOOP
      UPDATE X_SWITCHBASED_TRANSACTION
      SET STATUS  = 'Completed'
      WHERE OBJID = C_SBT.OBJID
      AND  STATUS != 'Completed';
      V_MSG:= 'Cleared Carrier Pending Transaction in X_SWITCHBASED_TRANSACTION';
      LOG_MSG(ESN_IN, V_MSG, BRAND_IN,'FIX');
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN;
  END;

/*=======================================================================================
  PROCEDURE: CHECK_LINE_NOT_ACTIVE_ESN
  DETAILS  : IF LINE IS ACTIVE
  =======================================================================================*/
  PROCEDURE CHECK_LINE_NOT_ACTIVE_ESN(
    ESN_IN     IN VARCHAR2,
    V_BRAND IN VARCHAR2,
    ESN_STATUS IN VARCHAR2,
    V_MSG OUT VARCHAR2)
  IS

  V_LINE_CNT    NUMBER;
  V_CODE        NUMBER;
  LINE_MIN      VARCHAR2(30);

    BEGIN

      FOR LINES IN C_LINE(ESN_IN)
        LOOP

          IF LINES.ROWCOUNT >=1 THEN  --<< HAS A LINE.
            BEGIN

                LINE_MIN := GET_MIN_FROM_ESN(ESN_IN);


                V_CODE:= CHECK_SITE_PART(LINES.ESN, LINES.LINE);

                CASE
                WHEN LINES.LINE_STATUS IN ('13','110','73') THEN  --<< ACTIVE LINE
                        CASE V_CODE
                        WHEN 0 THEN --<< HAD NO ACTIVE LINES <<-----------------

                          ----Removed the "_" in Straight Talk--icaocabrera
                          IF (V_BRAND IN ('STRAIGHT TALK', 'SIMPLE_MOBILE', 'TOTAL_WIRELESS')) AND (LINES.LINE=LINE_MIN) THEN
                            -- UPDATE THE STATUS TO 39, RESERVED USED ----------
                            UPDATE_LINE(ESN_IN, LINES.LINE, V_BRAND,'39');
                          ELSE
                            --DETACH_LINE(LINES.LINE,V_BRAND, LINES.ESN_OBJID,V_RESULT);
                            UPDATE_LINE(ESN_IN, LINES.LINE,V_BRAND,'12');
                          END IF;
                          V_MSG:=V_MSG||V_RESULT;
                        WHEN 1 THEN --<< LINE ATTACHED INCORRECTLY <<-----------
                          DETACH_LINE(LINES.LINE,V_BRAND, LINES.ESN_OBJID,V_RESULT);
                          V_MSG:=V_MSG||V_RESULT;
                        ELSE --<< LINE ATTACHED CORRECTLY AND ACTIVE <<---------

                          IF(LINES.LINE_STATUS <> '13') THEN
                             UPDATE_LINE(ESN_IN, LINES.LINE,V_BRAND,'13');
                          END IF;


                         FIX_MIN(LINES.ESN, V_BRAND, ESN_STATUS, '', V_RESULT);
                         V_MSG:=V_MSG||V_RESULT;



                         FIX_SITE_PART(LINES.ESN,V_BRAND, V_RESULT);
                         V_MSG:=V_MSG||V_RESULT;

                        END CASE;

                ELSE
                  IF LINES.LINE LIKE 'T%' THEN
                      --LOG_MSG(ESN, 'HERE' , V_BRAND, 'TEST');
                      DETACH_LINE(LINES.LINE, V_BRAND, LINES.ESN_OBJID,V_RESULT);
                  END IF;
                  V_MSG:=V_MSG||V_RESULT;
                END CASE;
                FIX_LINE_PART(LINES.LINE,V_BRAND,V_RESULT);
            END;
          END IF;

        END LOOP;

    EXCEPTION
    WHEN OTHERS THEN
      RETURN;
    END;

/*=======================================================================================
  PROCEDURE: FIX_REFURBISH
  DETAILS  : SERIES OF REFURBISHMENT FIXES
              1. IF STATUS IN 150 THEN CHANGE TO 50
  =======================================================================================*/
  PROCEDURE FIX_REFURBISH(
      ESN     IN VARCHAR2,
      V_BRAND IN VARCHAR2,
      V_ESN_STATUS IN VARCHAR2,
      V_MSG OUT VARCHAR2)
  IS
  BEGIN

  --FIRST REFURBISHMENT CHECK, SET PHONE TO NEW
  IF(V_ESN_STATUS='150') THEN
     UPDATE TABLE_PART_INST
     SET
     X_PART_INST_STATUS = '50',
     STATUS2X_CODE_TABLE  = 986
     WHERE PART_SERIAL_NO   = ESN;
     IF SQL%ROWCOUNT >0 THEN
        RERUN:=1;
        V_MSG:='ESN IN 150 IS RESET TO NEW';
        LOG_MSG(ESN, V_MSG, V_BRAND, 'FIX');
     END IF;

  END IF;

  EXCEPTION
      WHEN OTHERS THEN
        RETURN;
  END;

/*=======================================================================================
  PROCEDURE: FIX_PORT_IN
  DETAILS  : IF X_PORT_IN IS ANYTHING BUT ZERO SET IT TO NULL. THIS CLEARS THE PORT IN FLAG.
  =======================================================================================*/
  PROCEDURE FIX_PORT_IN(
      ESN     IN VARCHAR2,
      V_BRAND IN VARCHAR2,
      X_PORT_IN IN VARCHAR2,
      V_MSG OUT VARCHAR2)
  IS

  BEGIN

    IF X_PORT_IN IS NOT NULL THEN
      UPDATE sa.TABLE_PART_INST SET X_PORT_IN = NULL WHERE PART_SERIAL_NO = ESN;
      V_MSG:='CLEARED PORT IN FLAG FOR ESN';
      LOG_MSG(ESN, V_MSG, V_BRAND, 'FIX');
    END IF;

  EXCEPTION
        WHEN OTHERS THEN
          RETURN;
  END;
  -- END OF FIX PORT_IN PROCEDURE

/*=======================================================================================
  PROCEDURE: FIX_INCORRECT_SIZE
  DETAILS  : CHECKS TO SEE IF WE HAVE DUPLICATE DEACTIVATION RECORDS IN CALL TRANS WHERE
             ESN AND TRANSACT DATE ARE THE SAME. IF THEY ARE, SET EACH TO ONE SECOND EARLIER
  =======================================================================================*/
  PROCEDURE FIX_INCORRECT_SIZE(
      ESN     IN VARCHAR2,
      V_BRAND IN VARCHAR2,
      V_MSG OUT VARCHAR2)
  IS
  V_CNT NUMBER;

    CURSOR C_CALL_TRANS
    IS
      SELECT OBJID CT_OBJID
      FROM (
          SELECT
            X_SERVICE_ID,
            X_TRANSACT_DATE,
            COUNT(X_TRANSACT_DATE) CNT
          FROM sa.TABLE_X_CALL_TRANS
          WHERE
            X_SERVICE_ID = ESN
            AND X_ACTION_TYPE = 2 --DEACTIVATION
          GROUP BY
          X_SERVICE_ID,
          X_TRANSACT_DATE) CT_CNT,
      sa.TABLE_X_CALL_TRANS CT
      WHERE CT.X_SERVICE_ID  = CT_CNT.X_SERVICE_ID
      AND CT.X_TRANSACT_DATE = CT_CNT.X_TRANSACT_DATE
      AND CNT > 1;

    BEGIN
     V_CNT:=0;
     FOR C_CT IN C_CALL_TRANS
     LOOP
       V_CNT:=V_CNT+1;
        UPDATE sa.TABLE_X_CALL_TRANS
        SET X_TRANSACT_DATE = X_TRANSACT_DATE - (V_CNT/86400)
        WHERE OBJID         = C_CT.CT_OBJID;

        IF SQL%ROWCOUNT >0 THEN
           V_MSG:='UPDATED TIME STAMP OF DUPLICATE DEACTIVATED RECORDS IN CALL TRANS BY 1 SEC EACH';
          LOG_MSG(ESN, V_MSG,V_BRAND, 'FIX');
        END IF;
     END LOOP;

    EXCEPTION
          WHEN OTHERS THEN
            RETURN;
    END;

/*=======================================================================================
  PROCEDURE: FIX_NPA
  DETAILS  : FIX NPA, NXX, EXT
  =======================================================================================*/
PROCEDURE FIX_NPA(
    LINE    IN VARCHAR2,
    V_BRAND IN VARCHAR2,
    V_MSG OUT VARCHAR2)
IS
  PERS NUMBER;
BEGIN
  FOR C_LINE IN C_MIN(LINE)
  LOOP
    BEGIN
      IF C_LINE.X_NPA <> SUBSTR(C_LINE.PART_SERIAL_NO,1,3) OR C_LINE.X_NXX <> SUBSTR(C_LINE.PART_SERIAL_NO,4,3) OR C_LINE.X_EXT <> SUBSTR(C_LINE.PART_SERIAL_NO,7,4) THEN
        UPDATE sa.TABLE_PART_INST
        SET X_NPA   = SUBSTR(C_LINE.PART_SERIAL_NO,1,3),
          X_NXX     = SUBSTR(C_LINE.PART_SERIAL_NO,4,3),
          X_EXT     = SUBSTR(C_LINE.PART_SERIAL_NO,7,4)
        WHERE OBJID = C_LINE.OBJID;

        V_MSG:='Fixed X_NPA, X_NXX, X_EXT for : '||C_LINE.PART_SERIAL_NO||CHR(10);
       LOG_MSG(C_LINE.PART_SERIAL_NO,V_MSG, V_BRAND, 'FIX');
      END IF;

      IF C_LINE.PART_INST2CARRIER_MKT IS NULL THEN
          FOR C_CM IN C_CALL_TRANS_CARRER(LINE) --<< GRABS THE MOST RECENT CALL_TRANS WHERE THERE IS A CARRIER DEFINED
          LOOP

              SELECT CARRIER2PERSONALITY
              INTO PERS                         --<< GET THE CARRIER PERSONALITY
              FROM sa.TABLE_X_CARRIER
              WHERE OBJID=C_CM.CR;

              UPDATE sa.TABLE_PART_INST
              SET PART_INST2CARRIER_MKT = C_CM.CR,
                PART_INST2X_PERS        = PERS
              WHERE OBJID               = C_LINE.OBJID; --<< UPDATE THE PERSONALITY

              V_MSG := V_MSG||'Fixed Missing Carrier'||CHR(10);
              LOG_MSG(C_LINE.ESN, V_MSG,V_BRAND, 'FIX');


            IF C_LINE.PART_INST2X_PERS IS NULL THEN
              SELECT CARRIER2PERSONALITY
              INTO PERS
              FROM sa.TABLE_X_CARRIER
              WHERE OBJID=C_CM.CR;

              UPDATE sa.TABLE_PART_INST
              SET PART_INST2X_PERS= PERS
              WHERE OBJID         = C_LINE.OBJID;

              V_MSG := V_MSG||'Fixed Personality'||CHR(10);
              LOG_MSG(C_LINE.ESN, V_MSG,V_BRAND, 'FIX');
            END IF;

           END LOOP;
      END IF;

    END;
  END LOOP;
  PERS:=0;

EXCEPTION
          WHEN OTHERS THEN
            RETURN;
END;


/*=======================================================================================
  PROCEDURE: FIX_CARD
  DETAILS  : IF CARD STATUS IS 42, 263 (NOT REDEEMED, OTA REDEMPTION PENDING), SET TO RESERVED (40)
  =======================================================================================*/
PROCEDURE FIX_CARD(
    ESN      IN VARCHAR2,
    BRAND_IN IN VARCHAR2,
    V_MSG OUT VARCHAR2)
IS

BEGIN
  FOR CARD IN C_CARD(ESN)
  LOOP
    IF CARD.X_PART_INST_STATUS IN ('42','263') THEN
      UPDATE sa.TABLE_PART_INST
      SET X_PART_INST_STATUS = '40',
        STATUS2X_CODE_TABLE  = '982'
      WHERE PART_SERIAL_NO = CARD.PART_SERIAL_NO
      AND X_DOMAIN         = 'REDEMPTION CARDS';
      IF SQL%ROWCOUNT >0 THEN
        V_MSG:='CARD '||CARD.PART_SERIAL_NO||' NOW RESERVED TO ESN';
        LOG_MSG(ESN,V_MSG,BRAND_IN, 'FIX');
      END IF;
    END IF;
  END LOOP;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  RETURN;
END;

/*=======================================================================================
  PROCEDURE: FIX_100
  DETAILS  : IF PART_INST2X_NEW_PERS IS NOT NULL, THEN UPDATE PART_INST2X_PERS TO THIS VALUE
              AND SET PART_INST2X_NEW_PERS = NULL
  =======================================================================================*/
PROCEDURE FIX_100(
    ESN      IN VARCHAR2,
    BRAND_IN IN VARCHAR2,
    V_MSG OUT VARCHAR2)
IS
  CURSOR C_PI_PERS
  IS
    SELECT LINE.OBJID,
      LINE.PART_INST2X_NEW_PERS
    FROM TABLE_PART_INST LINE,
      TABLE_PART_INST PHONE
    WHERE PHONE.PART_SERIAL_NO = ESN
    AND PHONE.X_DOMAIN ='PHONES'
    AND LINE.PART_TO_ESN2PART_INST(+) = PHONE.OBJID
    AND LINE.X_DOMAIN ='LINES'
    AND LINE.PART_INST2X_NEW_PERS IS NOT NULL;
    C_PPER C_PI_PERS%ROWTYPE;

BEGIN
  IF C_PI_PERS%ISOPEN THEN
    CLOSE C_PI_PERS;
  END IF;
  OPEN C_PI_PERS;
  FETCH C_PI_PERS INTO C_PPER;
  IF C_PI_PERS%FOUND THEN
    UPDATE TABLE_PART_INST
    SET PART_INST2X_PERS  =PART_INST2X_NEW_PERS,
      PART_INST2X_NEW_PERS=NULL
    WHERE OBJID           = C_PPER.OBJID;
    IF SQL%ROWCOUNT       >0 THEN
      RERUN:=1;
      V_MSG:='UPDATED PERSONALITY FOR ASSOCIATED LINE';
      LOG_MSG(ESN,V_MSG,BRAND_IN, 'FIX');
    END IF;

  END IF;
  CLOSE C_PI_PERS;

EXCEPTION
          WHEN OTHERS THEN
            RETURN;
END;

/*=======================================================================================
  PROCEDURE: FIX_ACTIVE_LINE
  DETAILS  : FIXES TO AN ACTIVE LINE
  =======================================================================================*/
  PROCEDURE FIX_ACTIVE_LINE(
      ESN_IN     IN VARCHAR2,
      V_BRAND IN VARCHAR2,
      V_MSG OUT VARCHAR2)
  IS
  LINE_MIN VARCHAR2(30);
  V_COUNT NUMBER;
  BEGIN
    V_MSG:='';
    LINE_MIN:='';
    V_COUNT:=0;

    FOR LN IN C_LINE(ESN_IN)
        LOOP

            IF LN.LINE LIKE 'T%' THEN --<< IF IT IS A TMIN, THEN DETACH IT
              DETACH_LINE(LN.LINE,V_BRAND,LN.ESN_OBJID,V_RESULT);
              V_MSG:=V_MSG||V_RESULT;
              LINE_MIN:='N';
            ELSE
              LINE_MIN:=LN.LINE;
            END IF;

            BEGIN
                FOR C_SPL IN C_SITE_PART_LINE(LN.LINE)--<< ALL ACTIVE LINES WITH THIS MIN
                LOOP
                 V_COUNT:=V_COUNT+1;

                    IF C_SPL.X_SERVICE_ID = LN.ESN THEN
                         IF C_SPL.X_MIN <> LN.LINE THEN --<<--

                            DETACH_LINE(LN.LINE,V_BRAND, LN.ESN_OBJID, V_RESULT);
                            V_MSG:=V_MSG||V_RESULT;

                            ATTACH_LINE (LN.ESN,V_BRAND, C_SPL.X_MIN,V_RESULT);
                            V_MSG:=V_MSG||V_RESULT;

                          ELSE
                            BEGIN

                              IF LN.LINE_STATUS <> '13' THEN --<< IF PART STATUS IS ACTIVE, BUT THE LINE_STATUS FIELD ISN'T 13, UPDATE IT
                                UPDATE_LINE (ESN_IN, LN.LINE,V_BRAND,'13');
                              END IF;

                              FIX_NPA(LN.LINE,V_BRAND,V_RESULT);
                              V_MSG:=V_MSG||V_RESULT;
                            END;
                          END IF;

                          IF LN.X_PART_INST2SITE_PART <> C_SPL.OBJID THEN --<< THE LINE ISN'T ATTACHED PROPERLY
                            UPDATE sa.TABLE_PART_INST
                            SET X_PART_INST2SITE_PART = C_SPL.OBJID
                            WHERE PART_SERIAL_NO      = LN.ESN
                            AND X_DOMAIN='PHONES';

                            V_MSG:=V_MSG||'Fixed TABLE_PART_INST - TABLE_SITE_PART Relation';
                            LOG_MSG(ESN_IN, V_MSG,V_BRAND, 'FIX');
                          END IF;
                    ELSE
                        -- MEANS THAT THE ESN DOESN'T MATCH IN THE LINE AND THE
                        DETACH_LINE(LN.LINE,V_BRAND,LN.ESN_OBJID,V_RESULT);
                        V_MSG:=V_MSG||V_RESULT;

                        ATTACH_LINE(C_SPL.X_SERVICE_ID,V_BRAND, LN.LINE,V_RESULT);
                        V_MSG:=V_MSG||V_RESULT;
                    END IF;


                END LOOP;

                IF  V_COUNT=0 THEN --<< FOUND NO RECORDS
                ----Added "_" to SIMPLE_MOBILE and TOTAL_WIRELESS---icaocabrera
                  IF NOT(V_BRAND IN ('STRAIGHT TALK', 'SIMPLE_MOBILE', 'TOTAL_WIRELESS') AND (LN.LINE=LINE_MIN)) THEN
                   -- DETACH_LINE(LN.LINE,V_BRAND,LN.ESN_OBJID,V_RESULT);
                    UPDATE_LINE(ESN_IN, LN.LINE,V_BRAND,'12');
                  END IF;
                END IF;

             END;

        FIX_LINE_PART(LN.LINE,V_BRAND, V_RESULT);
        END LOOP;

        --SHOULD ATTACH ANY LINES THAT ARE NOT PROPERLY ATTACHED
        MERGE INTO TABLE_PART_INST T0
        USING(
              SELECT
             SP.X_SERVICE_ID,
             SP.X_MIN ,
             PI1.OBJID TOUPDATE_OBJID,
             PI1.PART_TO_ESN2PART_INST,
             PI2.OBJID PARENT_OBJID
             FROM TABLE_SITE_PART SP, TABLE_PART_INST PI1, TABLE_PART_INST PI2
             WHERE 1=1
             AND PI1.PART_SERIAL_NO = SP.X_MIN
             AND PI2.PART_SERIAL_NO = SP.X_SERVICE_ID
             AND SP.X_SERVICE_ID = ESN_IN
             AND SP.PART_STATUS='Active'
             AND PI1.PART_TO_ESN2PART_INST IS NULL
              ) T4
        ON (T4.TOUPDATE_OBJID = T0.OBJID)
        WHEN MATCHED THEN
        UPDATE SET T0.PART_TO_ESN2PART_INST = T4.PARENT_OBJID,
        T0.X_PART_INST_STATUS = 13,
        T0.STATUS2X_CODE_TABLE = 960;
        IF SQL%ROWCOUNT>0 THEN
          LOG_MSG(ESN_IN,'ATTACHED LINE', V_BRAND ,'FIX');
        END IF;


  FIX_SITE_PART (ESN_IN, V_BRAND,V_RESULT);
  V_MSG:=V_MSG||V_RESULT;

  EXCEPTION
          WHEN OTHERS THEN
            RETURN;
  END;


/*=======================================================================================
  PROCEDURE: FIX_CONTACT
  DETAILS  : CHECKS FOR MISSING CONTACT IN PART_INST. IF MISSING GETS IT FROM SITE_PART.
            ALSO CHECKS FOR VALID CONTACT ROLE(DEFAULT). IF NONE IT CREATES ONE. IF DUPLICATE
            IT NULLS THE DUPLICATES. IF ONE, MAKE SURE IT SAYS DEFAULT.
            ALSO CHECKS VARIOUS SMALL FIELDS LIKE ZIP AND COUNTRY ETC.
  =======================================================================================*/
PROCEDURE FIX_CONTACT(
    ESN     IN VARCHAR2,
    V_BRAND IN VARCHAR2,
    V_MSG OUT VARCHAR2)
IS
  V_QTY NUMBER := 0;
  V_ROLE_QTY NUMBER := 0;
  V_CONTACT NUMBER;
  V_ROLECOUNT NUMBER := 0;


  BEGIN


    FOR C_ESN IN C_PHONE(ESN)
    LOOP
        -- CHECK FOR MISSING CONTACT IN PART INST
        IF NVL(C_ESN.X_PART_INST2CONTACT,0)=0 THEN --<<-- NO CONTACT FOUND IN PART_INST
          IF C_CONTACTS%ISOPEN THEN
            CLOSE C_CONTACTS;
          END IF;
          OPEN C_CONTACTS(ESN);
          FETCH C_CONTACTS INTO C_CONT;   --<<-- GET CONTACT FROM SITE_PART IF EXISTS
          IF C_CONTACTS%FOUND THEN
            UPDATE sa.TABLE_PART_INST
            SET X_PART_INST2CONTACT = C_CONT.CONTACT
            WHERE PART_SERIAL_NO    =ESN
            AND X_DOMAIN            ='PHONES';

            V_MSG:='FIXED NULL CONTACT IN TABLE_PART_INST';
            LOG_MSG(ESN, V_MSG,V_BRAND, 'FIX');
          END IF;
          CLOSE C_CONTACTS;
        END IF;

      -- CHECK FOR DEFAULT CONTACT ROLE. IF 1 FOUND, GOOD. IF 2 FOUND, NULL ONE. IF NONE FOUND INSERT ONE.
      OPEN CHECK_DUP_CONTACT_ROLE(ESN);
      FETCH CHECK_DUP_CONTACT_ROLE INTO V_CONTACT, V_ROLECOUNT;
      IF CHECK_DUP_CONTACT_ROLE%FOUND THEN
      CASE
      WHEN V_ROLECOUNT > 1 THEN
          --MORE THAN ONE ROLE WAS FOUND, ONLY ONE IS NEEDED, AND THAT'S A DEFAULT ROLE.
          UPDATE TABLE_CONTACT_ROLE SET CONTACT_ROLE2CONTACT = NULL
          WHERE CONTACT_ROLE2CONTACT = V_CONTACT AND S_ROLE_NAME != 'DEFAULT';

          IF SQL%ROWCOUNT>0 THEN
            LOG_MSG(ESN,'REMOVED UNNECESSARY CONTACT ROLE', V_BRAND ,'FIX');

          END IF;

       WHEN V_ROLECOUNT = 1 THEN
       -- ONLY FOUND ONE ROLE, MAKE SURE ITS SET AS DEFAULT
          OPEN GET_CONTACT_ROLE(ESN);
          FETCH GET_CONTACT_ROLE INTO C_TCROLE;
          IF GET_CONTACT_ROLE%FOUND THEN
            IF C_TCROLE.S_ROLE_NAME != 'DEFAULT' OR C_TCROLE.ROLE_NAME != 'Default' THEN
              UPDATE TABLE_CONTACT_ROLE
              SET ROLE_NAME = 'Default', S_ROLE_NAME = 'DEFAULT'
              WHERE OBJID = C_TCROLE.OBJID;
              IF SQL%ROWCOUNT>0 THEN
                LOG_MSG(ESN,'SET CONTACT ROLE TO DEFAULT', V_BRAND ,'FIX');

              END IF;
            END IF;
          END IF;
          CLOSE GET_CONTACT_ROLE;

        WHEN V_ROLECOUNT = 0 THEN
        -- THERE WAS NO ROLE FOUND AT ALL, SO CREATE A CONTACT ROLE
             BEGIN
               INSERT
                INTO TABLE_CONTACT_ROLE VALUES
                  (
                    sa.SEQ('CONTACT_ROLE'), --OBJID NUMBER
                    'DEFAULT' ,          --ROLE_NAME VARCHAR2(80)
                    'DEFAULT',           --S_ROLE_NAME VARCHAR2(80)
                    1,                   --PRIMARY_SITE NUMBER
                    NULL,                --DEV NUMBER
                    C_ESN.SITEID,        --CONTACT_ROLE2SITE NUMBER(38)
                    V_CONTACT,           --CONTACT_ROLE2CONTACT NUMBER(38)
                    NULL,                --CONTACT_ROLE2GBST_ELM NUMBER(38)
                    SYSDATE              --UPDATE_STAMP DATE
                  );
                  IF SQL%ROWCOUNT>0 THEN
                      LOG_MSG(ESN,'CREATED A CONTACT ROLE', V_BRAND ,'FIX');
                  END IF;


           EXCEPTION WHEN OTHERS THEN
               LOG_MSG(ESN,'INSUFFICIENT PRIVILEGES TO CREATE A CONTACT ROLE', V_BRAND ,'LOG');
          END;
        END CASE;
      END IF;
      CLOSE CHECK_DUP_CONTACT_ROLE;


      -- VARIOUS MINOR CHECKS ----
      IF C_CHECK_CONTACT%ISOPEN THEN
      CLOSE C_CHECK_CONTACT;
      END IF;
      OPEN C_CHECK_CONTACT(ESN);
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
      OPEN C_ZIP_CODE(C_ADD.ZIPCODE);
      FETCH C_ZIP_CODE INTO C_ZIP;
      CLOSE C_ZIP_CODE;

      IF C_CONTACT.X_DATEOFBIRTH IS NULL THEN
        UPDATE sa.TABLE_CONTACT
        SET X_DATEOFBIRTH=TO_DATE('01/01/1753','MM/DD/YYYY')
        WHERE OBJID      = C_CONTACT.CONTACT_OBJID;

      END IF;

      IF NVL(C_CONTACT.CITY,'N')<> C_ADD.CITY THEN
        UPDATE sa.TABLE_CONTACT
        SET CITY    =C_ZIP.X_CITY
        WHERE OBJID = C_CONTACT.CONTACT_OBJID;

      END IF;

      IF NVL(C_CONTACT.STATE,'N')<>C_ADD.STATE THEN
        UPDATE sa.TABLE_CONTACT
        SET STATE   =C_ZIP.X_STATE
        WHERE OBJID = C_CONTACT.CONTACT_OBJID;

      END IF;
      IF NVL(C_CONTACT.ZIPCODE,'N')<>C_ADD.ZIPCODE THEN
        UPDATE sa.TABLE_CONTACT
        SET ZIPCODE =C_ZIP.X_ZIP
        WHERE OBJID = C_CONTACT.CONTACT_OBJID;

      END IF;
      IF C_CONTACT.COUNTRY IS NULL THEN
        UPDATE sa.TABLE_CONTACT
        SET COUNTRY ='USA'
        WHERE OBJID = C_CONTACT.CONTACT_OBJID;

      END IF;
      IF C_CONTACT.E_MAIL IS NULL THEN
        UPDATE sa.TABLE_CONTACT
        SET E_MAIL  ='CUSTOMER@TRACFONE.COM'
        WHERE OBJID = C_CONTACT.CONTACT_OBJID;

      END IF;

    END LOOP;

  EXCEPTION
          WHEN OTHERS THEN
            RETURN;
  END;

  /*=======================================================================================
  PROCEDURE: FIX_SITE_PART_OBSOLETE
  DETAILS  : ITERATE THROUGH ALL THE SITE PART RECORDS WITH A STATUS OF OBSOLETE AND UPDATE
             TO INACTIVE
  =======================================================================================*/
PROCEDURE FIX_SITE_PART_OBSOLETE(
  ESN     IN VARCHAR2,
  V_BRAND IN VARCHAR2,
  V_MSG OUT VARCHAR2)
  IS

  BEGIN

      UPDATE TABLE_SITE_PART
      SET PART_STATUS = 'Inactive'
      , X_DEACT_REASON= 'FIX 1052',
      SERVICE_END_DT  = SYSDATE
      WHERE X_SERVICE_ID = ESN
      AND PART_STATUS   IN ('Obsolete');
      IF SQL%ROWCOUNT = 1 THEN
        V_MSG:='UPDATED TABLE_SITE_PART SET PART_STATUS TO INACTIVE WHERE OBSOLETE';
        LOG_MSG(ESN, V_MSG,V_BRAND, 'FIX');
      END IF;

  EXCEPTION
          WHEN OTHERS THEN
            RETURN;
  END;


/*=======================================================================================
  PROCEDURE: FIX_SITE_PART_MULTIPLE_ACTIVE
  DETAILS  : IF THERE ARE MULTIPLE ACTIVE RECORDS
  =======================================================================================*/
PROCEDURE FIX_SITE_PART_MULTIPLE_ACTIVE(
  ESN     IN VARCHAR2,
  V_BRAND IN VARCHAR2,
  V_MSG OUT VARCHAR2)
  IS
  V_NEW_SP_OBJID VARCHAR2(25):='';
  BEGIN


   SELECT COUNT(1)
   INTO V_COUNT
   FROM TABLE_SITE_PART
   WHERE X_SERVICE_ID = ESN
   AND PART_STATUS = 'Active';

    IF(V_COUNT>1) THEN
      UPDATE TABLE_SITE_PART
      SET PART_STATUS ='Inactive'
      , X_DEACT_REASON= 'FIX 1052',
      SERVICE_END_DT  = SYSDATE
      WHERE X_SERVICE_ID = ESN
      AND PART_STATUS   IN ('Active')
      AND OBJID = (SELECT MIN(OBJID) FROM TABLE_SITE_PART WHERE X_SERVICE_ID = ESN AND PART_STATUS = 'Active');

      IF SQL%ROWCOUNT = 1 THEN
        V_MSG:='MULTIPLE ACTIVE SP RECORDS DETECTED. OLDEST SET TO INACTIVE';
        LOG_MSG(ESN, V_MSG,V_BRAND, 'FIX');

        BEGIN
          --NOW MAKE SURE THAT THE CORRECT SITE PART RECORD IS POINTED AT PART_INST
          SELECT MAX(OBJID) INTO V_NEW_SP_OBJID FROM TABLE_SITE_PART WHERE X_SERVICE_ID = ESN AND PART_STATUS = 'Active';

          UPDATE TABLE_PART_INST SET
          X_PART_INST2SITE_PART = V_NEW_SP_OBJID
          WHERE PART_SERIAL_NO = ESN;
            IF SQL%ROWCOUNT = 1 THEN
              RERUN:=1;
              V_MSG:='UPDATED X_PART_INST2SITE_PART IN PI TO CORRECT ACTIVE RECORD IN SP';
              LOG_MSG(ESN, V_MSG,V_BRAND, 'FIX');
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            RETURN;
        END;
      END IF;
    END IF;

  EXCEPTION
          WHEN OTHERS THEN
            RETURN;
  END;

/*=======================================================================================
  PROCEDURE: FIX_SITE_PART_MOST_RECENT
  DETAILS  : IF ANY INACTIVE RECORDS ARE NEWER THAN THE ACTIVE RECORD, DISCONNECT BY UPDATING
              THE X_SERVICE_ID TO X_SERVICE_ID || 'R'
  =======================================================================================*/
PROCEDURE FIX_SITE_PART_MOST_RECENT(
  ESN     IN VARCHAR2,
  V_BRAND IN VARCHAR2,
  V_MSG OUT VARCHAR2)
  IS
  V_INSTALL_DATE VARCHAR2(25):='';
  BEGIN


   SELECT MAX(INSTALL_DATE)
   INTO V_INSTALL_DATE
   FROM TABLE_SITE_PART
   WHERE X_SERVICE_ID = ESN
   AND PART_STATUS = 'Active';

    IF(V_INSTALL_DATE!='') THEN
      UPDATE TABLE_SITE_PART
      SET X_SERVICE_ID =X_SERVICE_ID || 'R'
      WHERE X_SERVICE_ID = ESN
      AND PART_STATUS   IN ('Inactive','Obsolete')
      AND INSTALL_DATE > V_INSTALL_DATE;
      IF SQL%ROWCOUNT = 1 THEN
        V_MSG:='INCORRECT ORDER FOR STATUS. UPDATED TABLE_SITE_PART SET X_SERVICE_ID TO X_SERVICE_ID || R';
        LOG_MSG(ESN, V_MSG,V_BRAND, 'FIX');
      END IF;
    END IF;

  EXCEPTION
          WHEN OTHERS THEN
            RETURN;
  END;

  /*=======================================================================================
  PROCEDURE: FIX_SP_OBS_TIME
  DETAILS  : IF THERE IS A SITE_PART RECORD FLAGGED AS OBSOLETE WITH THE EXACT SAME TIME AS A
              RECORD THAT IS MARKED AS ACTIVE, THEN SET THE OBSOLETE RECORD BACK BY 1 SECOND
  =======================================================================================*/
  PROCEDURE FIX_SP_OBS_TIME
  (
    ESN_IN  IN VARCHAR2,
    V_BRAND IN VARCHAR2,
    V_MSG OUT VARCHAR2
  )
  IS
    CURSOR C_SP
    IS
      SELECT OBJID,
        X_SERVICE_ID ,
        INSTALL_DATE
      FROM TABLE_SITE_PART SP
      WHERE SP.X_SERVICE_ID =ESN_IN
      AND SP.PART_STATUS    in ('Obsolete','Inactive') -- added inactive
      AND SP.INSTALL_DATE  IN
        (SELECT INSTALL_DATE
        FROM TABLE_SITE_PART
        WHERE X_SERVICE_ID = SP.X_SERVICE_ID
        AND PART_STATUS    ='Active'
        );
  BEGIN
    FOR I IN C_SP
    LOOP
      UPDATE TABLE_SITE_PART
      SET INSTALL_DATE=INSTALL_DATE-1/86400
      WHERE OBJID     =I.OBJID;
      IF SQL%ROWCOUNT = 1 THEN
        V_MSG:='FIXED DUPLICATE TIME FOR OBSOLETE RECORD IN TABLE_SITE_PART';
        LOG_MSG(ESN_IN, V_MSG, V_BRAND, 'FIX');
      END IF;
    END LOOP;

  EXCEPTION
          WHEN OTHERS THEN
            RETURN;
  END;

  /*=======================================================================================
  PROCEDURE: CHECK_OTA
  DETAILS  : FOR A NON OTA PHONE, IF THERE IS A CALL TRANS OTA TYPE OF WITH 273, CHANGE IT TO 264
  =======================================================================================*/
  PROCEDURE CHECK_OTA(
    ESN     IN VARCHAR2,
    V_BRAND IN VARCHAR2,
    ESN_OBJID IN VARCHAR2,
    V_MSG OUT VARCHAR2)
  IS
  V_SP_OBJID      VARCHAR2(30);
  V_OTA_TYPE      VARCHAR2(30);
  V_CT_OBJID      VARCHAR2(30);
  V_CT_X_RESULT   VARCHAR2(30);
  V_ACTIVE_SP_OBJID VARCHAR2(30);
  BEGIN
  V_MSG         :='';
  V_SP_OBJID    :='';
  V_OTA_TYPE    :='';
  V_CT_OBJID    :='';
  V_CT_X_RESULT :='';
  V_ACTIVE_SP_OBJID :='';




  IF IS_FEATURE_PHONE(ESN) = 1 THEN

      --OBJID OF THE MOST RECENT SITE PART RECORD

    BEGIN
      SELECT OBJID INTO V_ACTIVE_SP_OBJID
      FROM TABLE_SITE_PART S
      WHERE X_SERVICE_ID = ESN
      AND INSTALL_DATE =
        (SELECT MAX(INSTALL_DATE)
        FROM TABLE_SITE_PART
        WHERE X_SERVICE_ID= S.X_SERVICE_ID
        )
      --AND X_MIN NOT LIKE 'T%'
      AND ROWNUM = 1;
      EXCEPTION
       WHEN NO_DATA_FOUND THEN
	        V_ACTIVE_SP_OBJID := NULL;
    END;

      --OBJID OF THE MOST RECENT CALL TRANS THAT MAPS TO THAT SITE PART OBJID

      BEGIN
      SELECT OBJID,
          X_OTA_TYPE
        INTO V_SP_OBJID,
          V_OTA_TYPE
        FROM TABLE_X_CALL_TRANS
        WHERE OBJID =
          (SELECT MAX(OBJID)
          FROM sa.TABLE_X_CALL_TRANS
          WHERE CALL_TRANS2SITE_PART = V_ACTIVE_SP_OBJID
          );
       EXCEPTION
			      WHEN NO_DATA_FOUND THEN
				        V_SP_OBJID := NULL;
				        V_OTA_TYPE := NULL;
      END;



      /*IF V_OTA_TYPE=273 THEN
        --NON OTA PHONE FLAG IN CALL TRANS SHOULDN'T BE THERE SO UPDATE IT
        UPDATE SA.TABLE_X_CALL_TRANS
        SET X_OTA_TYPE  = '264'
        WHERE OBJID     = V_SP_OBJID; --<<-- CALL TRANS OBJID
        IF SQL%ROWCOUNT = 1 THEN
          V_MSG:='REMOVED OTA RECORD FROM NON OTA CALL TRANS';
          LOG_MSG(ESN, V_MSG, V_BRAND, 'FIX');
        END IF;
      END IF;
      */

     UPDATE sa.TABLE_X_CALL_TRANS
			SET X_OTA_TYPE  = '264'
			WHERE CALL_TRANS2SITE_PART = V_ACTIVE_SP_OBJID
			AND X_OTA_TYPE = '273';
      IF SQL%ROWCOUNT > 0 THEN
      V_MSG:='REMOVED OTA RECORD FROM NON OTA CALL TRANS';
      LOG_MSG(ESN, V_MSG, V_BRAND, 'FIX');

      UPDATE TABLE_X_OTA_TRANSACTION
	          SET X_ACTION_TYPE = '271'
	          WHERE X_ACTION_TYPE = '273'
	          AND X_OTA_TRANS2X_CALL_TRANS IN (SELECT OBJID FROM TABLE_X_CALL_TRANS
	                                            WHERE CALL_TRANS2SITE_PART = V_ACTIVE_SP_OBJID);
	          IF SQL%ROWCOUNT > 0 THEN
	            V_MSG:='REMOVED OTA RECORD FROM NON OTA OTA_TRANSACTION';
	            LOG_MSG(ESN, V_MSG, V_BRAND, 'FIX');
	          END IF;
         END IF;


       --CONTINUE NOW AND CHECK THE OTA CALL TRANS
	      UPDATE sa.TABLE_X_OTA_TRANSACTION
	      SET X_STATUS                   = 'Completed'
	      WHERE X_OTA_TRANS2X_CALL_TRANS IN (SELECT OBJID
	        FROM sa.TABLE_X_CALL_TRANS
	        WHERE CALL_TRANS2SITE_PART = V_ACTIVE_SP_OBJID AND X_RESULT='Completed')
	      AND UPPER(X_STATUS)           IN ('OTA SEND', 'OTA PENDING');
	      IF SQL%ROWCOUNT > 0 THEN
	        V_MSG:='CLEARED OTA TRANSACTION IN TABLE_X_OTA_TRANSACTION';
	        LOG_MSG(ESN, V_MSG, V_BRAND, 'FIX');
	      END IF;







      --CONTINUE NOW AND CHECK THE CALL_TRANS FOR OTA PENDING IN X_RESULT
      BEGIN
        SELECT OBJID,
          X_RESULT
        INTO V_CT_OBJID,
          V_CT_X_RESULT
        FROM sa.TABLE_X_CALL_TRANS
        WHERE X_RESULT  IN('OTA PENDING')
        AND X_SERVICE_ID = ESN;


        IF V_CT_X_RESULT<>'' THEN --<< SHOULD NOT BE NECESSARY, JUST IN CASE CHECK
          UPDATE sa.TABLE_X_CALL_TRANS
          SET X_RESULT = 'Completed'
          WHERE OBJID  = V_CT_OBJID;
          IF SQL%ROWCOUNT > 0 THEN
          V_MSG:='CLEARED OTA TRANSACTION IN TABLE_X_CALL_TRANS';
          LOG_MSG(ESN, V_MSG, V_BRAND, 'FIX');
          END IF;
        END IF;

        UPDATE sa.TABLE_X_CODE_HIST
        SET X_CODE_ACCEPTED        = 'YES'
        WHERE CODE_HIST2CALL_TRANS = V_CT_OBJID
        AND X_CODE_ACCEPTED LIKE ('OTA%');
        IF SQL%ROWCOUNT > 0 THEN
          V_MSG:='CLEARED OTA PENDING TRANSACTION IN TABLE_X_CODE_HIST';
          LOG_MSG(ESN, V_MSG, V_BRAND, 'FIX');
        END IF;


        UPDATE sa.TABLE_X_OTA_TRANSACTION
        SET X_STATUS                   = 'Completed'
        WHERE X_OTA_TRANS2X_CALL_TRANS = V_CT_OBJID
        AND UPPER(X_STATUS)           IN ('OTA SEND', 'OTA PENDING');
        IF SQL%ROWCOUNT > 0 THEN
          V_MSG:='CLEARED OTA TRANSACTION IN TABLE_X_OTA_TRANSACTION';
          LOG_MSG(ESN, V_MSG, V_BRAND, 'FIX');
        END IF;

      EXCEPTION
      WHEN OTHERS THEN
        -- NOTHING TO UPDATE HERE, JUST A CATCH FOR THE EXCEPTION
        V_MSG:='';
      END;

      --CHECK IF THERE IS AN OTA RECORD
      BEGIN

         SELECT (SELECT COUNT(1) V_HAS_OTA_FEATURES
          FROM TABLE_X_OTA_FEATURES
          WHERE X_OTA_FEATURES2PART_INST = ESN_OBJID
          ) INTO V_HAS_OTA_FEATURES
          FROM DUAL;

          IF V_HAS_OTA_FEATURES=0 THEN
            --CREATE A NEW OTA RECORD
            BEGIN

            INSERT INTO TABLE_X_OTA_FEATURES
            ( OBJID,
              X_REDEMPTION_MENU,
              X_HANDSET_LOCK,
              X_LOW_UNITS,
              X_OTA_FEATURES2PART_INST,
              X_PSMS_DESTINATION_ADDR,
              X_ILD_CARR_STATUS,
              X_ILD_PROG_STATUS,
              X_CURRENT_CONV_RATE,
              X_BUY_AIRTIME_MENU,
              X_SPP_PROMO_CODE,
              X_CLOSE_COUNT)
              VALUES (sa.seq ('x_ota_features'),
                       'N',
                       'Y',
                       'N',
                       ESN_OBJID,
                       '31778',
                       'Inactive',
                       'Completed',
                       3,
                       'N',
                       'N',
                       0);
               IF SQL%ROWCOUNT > 0 THEN
                V_MSG:='INSERTED MISSING OTA FEATURES RECORD';
                LOG_MSG(ESN, V_MSG, V_BRAND, 'FIX');
               END IF;
            EXCEPTION WHEN OTHERS THEN

                V_MSG:='INSUFFICIENT PRIVILEGES TO INSERT MISSING OTA FEATURES RECORD';
                LOG_MSG(ESN, V_MSG, V_BRAND, 'LOG');
            END;

          END IF;

      EXCEPTION
      WHEN OTHERS THEN
        RETURN;
      END;


   -- CLOSE C_LAST_SITE_PART_ESN;
    END IF;



  EXCEPTION
  WHEN OTHERS THEN
  --IF C_LAST_SITE_PART_ESN%ISOPEN THEN CLOSE C_LAST_SITE_PART_ESN; END IF;
  V_MSG:='';
  END;


 /*=======================================================================================
  PROCEDURE: CHECK_ATTACHED_LINES
  DETAILS  : IF ESN HAS NO LINE ATTACHED, THEN ATTACH ONE
  =======================================================================================*/
  PROCEDURE CHECK_ATTACHED_LINES(
    ESN     IN VARCHAR2,
    V_BRAND IN VARCHAR2,
    V_MSG OUT VARCHAR2)
  IS

  V_LINE_CNT    NUMBER;
  V_CODE        NUMBER;
  LINE_MIN      VARCHAR2(30);

    BEGIN
    -- LOG_MSG(ESN,'CHECKING ATTACHED LINES',V_BRAND, 'FIX');
     OPEN C_LINE(ESN);
      IF NVL(C_LINE%ROWCOUNT,0) = 0 THEN  --<< HAS NO LINE.
            BEGIN
             -- LOG_MSG(ESN,'NO LINE ATTACHED',V_BRAND, 'FIX');
              FOR MY_LINE IN C_SITE_PART_ESN(ESN)
              LOOP
                V_COUNT:=0;
                -- this checks if the MIN is active for any other ESN as well.
                SELECT COUNT(*)
                INTO V_COUNT
                FROM TABLE_SITE_PART
                WHERE 1          = 1
                AND PART_STATUS  = 'Active'
                AND X_MIN        =  MY_LINE.X_MIN
                AND X_SERVICE_ID <> ESN;
                IF V_COUNT       = 0 THEN --<<-- if not then attach it properly
                  ATTACH_LINE (ESN,V_BRAND, MY_LINE.X_MIN, V_MSG );
                ELSE --<<-- if it is, then raise an error
                  V_MSG:='MULTI_PHONE';
                END IF;
              END LOOP;
            END;
        ELSE --<< IT HAS A LINE, SO JUST CHECK IF THERE ARE ANY CONFLICTS
               FOR MY_LINE IN C_SITE_PART_ESN(ESN)
                LOOP
                  V_COUNT:=0;
                  -- this checks if the MIN is active for any other ESN as well.
                  SELECT COUNT(*)
                  INTO V_COUNT
                  FROM TABLE_SITE_PART
                  WHERE 1          = 1
                  AND PART_STATUS  = 'Active'
                  AND X_MIN        =  MY_LINE.X_MIN
                  AND X_SERVICE_ID <> ESN;
                   IF V_COUNT       > 0 THEN
                     V_MSG:='MULTI_PHONE';
                   END IF;
                  END LOOP;
        END IF;

     CLOSE C_LINE;

      /*
      FOR LINES IN C_LINE(ESN)
        LOOP
        LOG_MSG(ESN,'CHECKING ATTACHED LINES -1',V_BRAND, 'FIX');
          CASE
          WHEN NVL(LINES.ROWCOUNT,0) = 0 THEN  --<< HAS NO LINE.
            BEGIN
              FOR MY_LINE IN C_SITE_PART_ESN(ESN)
              LOOP
                V_COUNT:=0;
                -- this checks if the MIN is active for any other ESN as well.
                SELECT COUNT(*)
                INTO V_COUNT
                FROM TABLE_SITE_PART
                WHERE 1          = 1
                AND PART_STATUS  = 'Active'
                AND X_MIN        =  MY_LINE.X_MIN
                AND X_SERVICE_ID <> ESN;
                IF V_COUNT       = 0 THEN --<<-- if not then attach it properly
                  ATTACH_LINE (ESN,V_BRAND, MY_LINE.X_MIN, V_MSG );
                ELSE --<<-- if it is, then raise an error
                  V_MSG:='MULTI_PHONE';
                END IF;
              END LOOP;
            END;
          WHEN  NVL(LINES.ROWCOUNT,0) > 0 THEN --<< IT HAS A LINE, SO JUST CHECK IF THERE ARE ANY CONFLICTS
               FOR MY_LINE IN C_SITE_PART_ESN(ESN)
                LOOP
                  V_COUNT:=0;
                  -- this checks if the MIN is active for any other ESN as well.
                  SELECT COUNT(*)
                  INTO V_COUNT
                  FROM TABLE_SITE_PART
                  WHERE 1          = 1
                  AND PART_STATUS  = 'Active'
                  AND X_MIN        =  MY_LINE.X_MIN
                  AND X_SERVICE_ID <> ESN;
                   IF V_COUNT       > 0 THEN
                     V_MSG:='MULTI_PHONE';
                   END IF;
                  END LOOP;
          END CASE;
        END LOOP;
    */

    EXCEPTION
          WHEN OTHERS THEN
            RETURN;
    END;

   /*=======================================================================================
      PROCEDURE: CHECK_ADD_INFO
      DETAILS  :  IF NO ADD_INFO FOR THIS CONTACT, THEN CHECK FOR A WEB USER (WITH SAME CONTACT AND BUS ORG)
                  IF A WEB USER EXISTS, THEN USE THAT TO CREATE AN ADD INFO RECORD
                  IF ADD_INFO DOES EXIST FOR THIS CONTACT, IF THE BUS ORG IS DIFFERENT, UPDATE IT TO THE PARAMETER BUS_ORG
                  IF MULTIPLE EXIST FOR THIS CONTACT, REMOVE ALL BUT THE MOST RECENT.
      =======================================================================================*/
    PROCEDURE CHECK_ADD_INFO(
    P_ESN   IN VARCHAR2,
    P_CONTACT IN NUMBER,
    P_BRAND IN VARCHAR2,
    P_BUS_ORG   IN VARCHAR2)
    IS
    BEGIN
        SELECT COUNT(*) INTO V_COUNT
        FROM sa.TABLE_X_CONTACT_ADD_INFO
        WHERE ADD_INFO2CONTACT = P_CONTACT
        AND ADD_INFO2BUS_ORG = P_BUS_ORG;

        CASE
        WHEN V_COUNT=0 THEN
              --NO RECORD FOUND. WE WOULD HAVE ALREADY FIXED THE WEB USER PREVIOUSLY, BUT CHECK ANYWAY
              SELECT COUNT(1) INTO V_COUNT FROM TABLE_WEB_USER WHERE WEB_USER2CONTACT = P_CONTACT;
              IF V_COUNT>0 THEN
                    INSERT
                    INTO TABLE_X_CONTACT_ADD_INFO
                      (
                        OBJID,
                        ADD_INFO2CONTACT,
                        ADD_INFO2USER,
                        X_LAST_UPDATE_DATE,
                        ADD_INFO2BUS_ORG,
                        X_INFO_REQUEST
                      )
                      VALUES
                      (
                        sa.SEQ('X_CONTACT_ADD_INFO'),
                        P_CONTACT,
                        268435556,
                        SYSDATE,
                        P_BUS_ORG,
                        SYSDATE
                      );
                      IF SQL%ROWCOUNT > 0 THEN
                          V_MSG:='TABLE_X_CONTACT_ADD_INFO RECORD CREATED';
                          LOG_MSG(P_ESN,V_MSG,P_BRAND, 'FIX');
                      END IF;
                END IF;
        WHEN V_COUNT=1 THEN

              V_MSG:='NO ISSUES WITH TABLE_X_CONTACT_ADD_INFO';
             -- LOG_MSG(P_ESN,V_MSG,P_BRAND, 'LOG');
        ELSE
          --MULTIPLE RECORDS FOUND. CLEAR THE OLDER DUPLICATES
                UPDATE TABLE_X_CONTACT_ADD_INFO SET
                ADD_INFO2BUS_ORG = NULL,
                ADD_INFO2CONTACT = NULL
                WHERE TABLE_X_CONTACT_ADD_INFO.OBJID !=( SELECT MAX(OBJID) FROM TABLE_X_CONTACT_ADD_INFO WHERE ADD_INFO2CONTACT=P_CONTACT and ADD_INFO2BUS_ORG = P_BUS_ORG)
                AND ADD_INFO2CONTACT=P_CONTACT
                AND ADD_INFO2BUS_ORG = P_BUS_ORG;


                IF SQL%ROWCOUNT > 0 THEN
                    V_MSG:='DUPLICATE ENTRIES IN TABLE_X_CONTACT_ADD_INFO REMOVED';
                    LOG_MSG(P_ESN,V_MSG,P_BRAND, 'FIX');
                END IF;
        END CASE;

    EXCEPTION
          WHEN OTHERS THEN
            RETURN;
    END;

    /*=======================================================================================
      PROCEDURE: CHECK_WEB_USER
      DETAILS  :  IF THE WEB USER TABLE HAS NO RECORDS FOR THE CONTACT AND BUS ORG COMBO, THEN CREATE ONE
                  IF MULTIPLE ARE FOUND, KEEP THE MOST RECENT, NULL OUT THE OTHERS.
      =======================================================================================*/
    PROCEDURE CHECK_WEB_USER(
    P_ESN       IN VARCHAR2,
    P_CONTACT   IN NUMBER,
    P_BRAND     IN VARCHAR2,
    P_BUS_ORG   IN VARCHAR2)
    IS
    V_WU_DUMMY_EXIST NUMBER;
    V_LOGIN   TABLE_WEB_USER.LOGIN_NAME%TYPE;
    IP_PW TABLE_WEB_USER.PASSWORD%TYPE;
    IP_SQUESTION  TABLE_WEB_USER.X_SECRET_QUESTN%TYPE;
    IP_SANSWER TABLE_WEB_USER.X_SECRET_ANS%TYPE;
    BEGIN
    V_WU_DUMMY_EXIST:=0;

    -- COUNT OF RECORDS IN TABLE WEB USER FOR THIS CONTACT AND BUSORG COMBO
    SELECT COUNT(*)
    INTO V_COUNT
    FROM sa.TABLE_WEB_USER
    WHERE WEB_USER2CONTACT  = P_CONTACT
    AND   WEB_USER2BUS_ORG  = P_BUS_ORG;


      CASE
      WHEN V_COUNT =0 THEN --<< IF NO RECORDS, THEN EITHER UPDATE OR INSERT
              SELECT COUNT(*) INTO V_WU_DUMMY_EXIST
              FROM TABLE_WEB_USER
              WHERE WEB_USER2CONTACT  = P_CONTACT
              AND WEB_USER2BUS_ORG = NULL;

              IF V_WU_DUMMY_EXIST = 1 THEN
                  --HAS A RECORD WITH NO BUS ORG, SO WE CAN USE THIS ONE AND JUST UPDATE IT
                  UPDATE TABLE_WEB_USER
                  SET WEB_USER2BUS_ORG   = P_BUS_ORG
                  WHERE WEB_USER2CONTACT = P_CONTACT
                  AND WEB_USER2BUS_ORG = NULL;
                  IF SQL%ROWCOUNT > 0 THEN
                     V_MSG:='WEB USER BUS_ORG UPDATED';
                      LOG_MSG(P_ESN,V_MSG,P_BRAND, 'FIX');
                  END IF;
              ELSE
                  --HAS NO RECORD SO INSERT ONE
                  V_LOGIN:='';
                  IP_PW:=NULL;
                  IP_SQUESTION:=NULL;
                  IP_SANSWER:=NULL;


                  BEGIN

                  SELECT P_CONTACT||'@'||ltrim(WEB_SITE,'_www.')  INTO V_LOGIN FROM TABLE_BUS_ORG WHERE
	                       OBJID = P_BUS_ORG AND ROWNUM =1;

                  /* SELECT P_CONTACT||'@'||ltrim(WEB_SITE,'_www.') INTO V_LOGIN FROM TABLE_BUS_ORG WHERE
                   NAME = P_BRAND AND ROWNUM =1;*/



                   INSERT INTO TABLE_WEB_USER
                         (OBJID,LOGIN_NAME,S_LOGIN_NAME,PASSWORD,STATUS,
                          X_SECRET_QUESTN,S_X_SECRET_QUESTN,X_SECRET_ANS,S_X_SECRET_ANS,
                          WEB_USER2USER,WEB_USER2CONTACT,WEB_USER2BUS_ORG,X_LAST_UPDATE_DATE)
                    VALUES (sa.SEQ('WEB_USER'),LOWER(V_LOGIN),UPPER(V_LOGIN),NULL,1,
                           NULL,NULL,NULL,NULL,
                           NULL,
                           P_CONTACT,P_BUS_ORG,SYSDATE);

                    IF SQL%ROWCOUNT > 0 THEN
                      V_MSG:='WEB USER ACCOUNT CREATED';
                      LOG_MSG(P_ESN,V_MSG,P_BRAND, 'FIX');
                    END IF;

                  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       V_MSG:='NO WEBSITE FOUND FOR THE BRAND ';
                      LOG_MSG(P_ESN,V_MSG,P_BRAND, 'LOG');
                  WHEN OTHERS THEN
                      V_MSG:='INSUFFICIENT PRIVILEGES TO CREATE MISSING WEB USER ACCOUNT';
                      LOG_MSG(P_ESN,V_MSG,P_BRAND, 'LOG');
                  END;


               END IF;
      WHEN V_COUNT =1 THEN -- SINGLE RECORD FOUND. ALL IS WELL
               V_MSG:='EXISTING WEB USER ACCOUNT FOUND';
               -- LOG_MSG(P_ESN, V_MSG,P_BRAND,'LOG');
      ELSE --MORE THAN ONE RECORD FOUND. CLEAR ALL BUT O.
            UPDATE TABLE_WEB_USER SET
            WEB_USER2CONTACT = NULL,
            WEB_USER2BUS_ORG = NULL
            WHERE WEB_USER2CONTACT = P_CONTACT
            AND WEB_USER2BUS_ORG = P_BUS_ORG
            AND OBJID NOT IN (SELECT MAX(OBJID) FROM TABLE_WEB_USER WHERE WEB_USER2CONTACT = P_CONTACT AND WEB_USER2BUS_ORG = P_BUS_ORG);
           IF SQL%ROWCOUNT > 0 THEN
                V_MSG:='DUPLICATE WEB USER ACCOUNT REMOVED';
                LOG_MSG(P_ESN,V_MSG,P_BRAND, 'FIX');
           END IF;
      END CASE;


    EXCEPTION
          WHEN OTHERS THEN
            RETURN;
    END;




    /*=======================================================================================
    PROCEDURE: CHECK_SIM_ATTACHMENT
    DETAILS  : IF SIM IS ACTIVE, AND SIM IS NOT ATTACHED TO THE RIGHT ESN, DETACH IT
    =======================================================================================*/
    PROCEDURE CHECK_SIM_ATTACHMENT(
      P_ESN     IN VARCHAR2,
      P_BRAND   IN VARCHAR2,
      P_ICCID   IN VARCHAR2,
      V_MSG     OUT VARCHAR2)
    IS
      V_SIM_STATUS VARCHAR2(5);
      V_ESN        VARCHAR2(30);
    BEGIN

      SELECT X_SIM_INV_STATUS
      INTO V_SIM_STATUS
      FROM sa.TABLE_X_SIM_INV
      WHERE X_SIM_SERIAL_NO = P_ICCID;

      IF V_SIM_STATUS       ='254' THEN --ACTIVE
        --CHECK HERE TO SEE IF SIM IS ATTACHED TO THE RIGHT ESN
        SELECT PART_SERIAL_NO
        INTO V_ESN
        FROM sa.TABLE_PART_INST
        WHERE X_ICCID = P_ICCID;

        IF V_ESN<>P_ESN THEN -- IF IT IS DIFFERENT THEN DETACH SIM

          UPDATE sa.TABLE_PART_INST
          SET X_ICCID = NULL
          WHERE PART_SERIAL_NO=P_ESN;
          IF SQL%ROWCOUNT             = 1 THEN
            V_MSG:='DETACHED SIM FROM ESN ' || P_ESN;
            LOG_MSG(P_ESN, V_MSG, P_BRAND, 'FIX');
          END IF;

        ELSE
         --IF IT IS THE RIGHT ESN, THEN RESET SIM
          RESET_SIM(P_ESN, P_BRAND, P_ICCID, V_MSG);
        END IF;
      END IF;

    EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      V_MSG:= 'SIM ATTACHED TO MULTIPLE ESNS';
      LOG_MSG(P_ESN, V_MSG, P_BRAND, 'LOG');
    WHEN OTHERS THEN
            RETURN;
    END;



  /*=======================================================================================
    PROCEDURE: ACTIVATE_SIM
    DETAILS  : IF SIM STATUS IN '253','251', THEN SET IT TO 254
    =======================================================================================*/
    PROCEDURE ACTIVATE_SIM(
      P_ESN     IN VARCHAR2,
      P_BRAND   IN VARCHAR2,
      P_ICCID   IN VARCHAR2,
      V_MSG     OUT VARCHAR2)
    IS
      V_SIM_STATUS VARCHAR2(5);
    BEGIN

      UPDATE sa.TABLE_X_SIM_INV
      SET X_SIM_INV_STATUS        = '254',
        X_SIM_STATUS2X_CODE_TABLE = 268438607
      WHERE X_SIM_SERIAL_NO       = P_ICCID
      AND X_SIM_INV_STATUS IN ('253','251')
      AND (SELECT X_PART_INST_STATUS FROM TABLE_PART_INST WHERE X_ICCID = P_ICCID) = 52 ; --<< WILL ONLY ACTIVATE IF THE STATUS IS NEW OR RESERVED
      IF SQL%ROWCOUNT             = 1 THEN
      V_MSG:='SIM IS UPDATED TO ACTIVE';
      LOG_MSG(P_ESN, V_MSG, P_BRAND, 'FIX');
      END IF;
    EXCEPTION
          WHEN OTHERS THEN
            RETURN;
    END;

    /*=======================================================================================
      PROCEDURE: CHECK_SIM
      DETAILS  : IF ESN IS ACTIVE AND THERE IS AN ICCID ATTACHED, THEN TRY ACTIVATE SIM
                 IF ESN IS NOT ACTIVE AND THERE IS AN ICCID ATTACHED, CHECK STATUS TO TRY AND DETACH SIM
      =======================================================================================*/
      PROCEDURE CHECK_SIM(
      P_ESN         IN VARCHAR2,
      P_BRAND       IN VARCHAR2,
      P_ESN_STATUS  IN VARCHAR2,
      P_ICCID       IN VARCHAR2,
      V_MSG         OUT VARCHAR2)
      IS

      BEGIN

        IF P_ICCID IS NOT NULL THEN
          IF P_ESN_STATUS='52' THEN
              ACTIVATE_SIM(P_ESN,P_BRAND,P_ICCID, V_MSG);
          ELSE
              CHECK_SIM_ATTACHMENT(P_ESN,P_BRAND,P_ICCID, V_MSG);
          END IF;
        END IF;
      EXCEPTION
          WHEN OTHERS THEN
            RETURN;
      END;


    /*=======================================================================================
      PROCEDURE: FIX_LIMITS_EXCEEDED
      DETAILS  : IF ESN HAS COMP UNITS ON A CASE THAT ARE MORE THAN AN HOUR OLD, THEN CREATE MORE
                REPLACEMENT UNITS AND UPDATE THE TABLE_CASE RECORD.
      =======================================================================================*/
    PROCEDURE FIX_LIMITS_EXCEEDED(
    P_ESN      IN VARCHAR2,
    P_BRAND    IN VARCHAR2,
    V_MSG      OUT VARCHAR2)
    IS

      CURSOR C_COMP_UNITS (ESN_COMP IN VARCHAR2)
      IS
        SELECT X_ESN,
          ID_NUMBER,
          CREATION_TIME,
          X_REPLACEMENT_UNITS
        FROM sa.TABLE_CASE
        WHERE X_ESN            = ESN_COMP
        AND X_REPLACEMENT_UNITS>0
        AND CREATION_TIME      < SYSDATE-1/24;

    BEGIN
      FOR C_COMP IN C_COMP_UNITS(P_ESN)
      LOOP
        /*
        INSERT
        INTO SA.CASE_REPL_UNITS_STG
          (
            X_ESN,
            ID_NUMBER,
            CREATION_TIME,
            X_REPLACEMENT_UNITS,
            UPDATE_DATE
          )
          VALUES
          (
            C_COMP.X_ESN,
            C_COMP.ID_NUMBER,
            C_COMP.CREATION_TIME,
            C_COMP.X_REPLACEMENT_UNITS,
            SYSDATE
          );
        IF SQL%ROWCOUNT         = 1 THEN
          V_MSG:='COMP REPL UNITS RECORD CREATED';
          LOG_MSG(P_ESN,V_MSG, P_BRAND, 'FIX');
        END IF;
        */ --------------------------------------------------------------------I THINK THIS IS INCORRECT
        UPDATE sa.TABLE_CASE
        SET X_REPLACEMENT_UNITS = 0
        WHERE ID_NUMBER         = C_COMP.ID_NUMBER;
        IF SQL%ROWCOUNT         >= 1 THEN
          V_MSG:='CASE LIMITS ARE RESET';
          LOG_MSG(P_ESN,V_MSG, P_BRAND, 'FIX');
        END IF;


      END LOOP;
    EXCEPTION
          WHEN OTHERS THEN
            RETURN;
    END;

    /*=======================================================================================
      PROCEDURE: CR_DUMMY_ACCT
      DETAILS  : THIS WILL CREATE A LINK TO TABLE_X_CONTACT_ADD_INFO, A NEW WEB USER AS WELL
      =======================================================================================*/
    PROCEDURE CR_DUMMY_ACCT(
    P_ESN       IN VARCHAR2,
    P_BRAND     IN VARCHAR2,
    P_BUS_ORG   IN NUMBER,
    P_ESN_OBJID IN VARCHAR2,
    P_ESN_CONTACT IN VARCHAR2)
    IS
    V_RESULT VARCHAR2(200);
    V_CONPARTINST NUMBER;
    BEGIN
    V_RESULT:='';
    V_CONPARTINST :=0;


        ---CHECK THE TABLE_X_CONTACT_ADD_INFO FOR A RECORD
       CHECK_WEB_USER(P_ESN,P_ESN_CONTACT, P_BRAND, P_BUS_ORG); --THIS WILL CREATE A WEB USER AS WELL, IF ONE ISN'T FOUND
       CHECK_ADD_INFO(P_ESN,P_ESN_CONTACT, P_BRAND, P_BUS_ORG); --THIS WILL CREATE A ADD INFO RECORD AS WELL, IF ONE ISN'T FOUND
       FIX_CONTACT(P_ESN,P_BRAND,V_RESULT); --THIS WILL CREATE CONTACT_ROLE RECORD AS WELL, IF ONE ISN'T FOUND


      --NOW JUST CHECK THE TABLE_X_CONTACT_PART_INST ---------------------------
      SELECT COUNT(1) INTO V_CONPARTINST
      FROM TABLE_X_CONTACT_PART_INST WHERE
      X_CONTACT_PART_INST2CONTACT = P_ESN_CONTACT
      AND X_CONTACT_PART_INST2PART_INST = P_ESN_OBJID;

      IF V_CONPARTINST = 0 THEN -- NONE FOUND
        INSERT
        INTO TABLE_X_CONTACT_PART_INST VALUES
        (
          sa.seq('x_contact_add_info') --OBJID NUMBER
          ,
          P_ESN_CONTACT --X_CONTACT_PART_INST2CONTACT NUMBER
          ,
          P_ESN_OBJID --X_CONTACT_PART_INST2PART_INST NUMBER
          ,
          NULL --X_ESN_NICK_NAME VARCHAR2(30)
          ,
          0 --X_IS_DEFAULT NUMBER
          ,
          0 --X_TRANSFER_FLAG NUMBER
          ,
          'Y' --X_VERIFIED VARCHAR2(1)
        );
       V_MSG :='RECORD INSERTED INTO TABLE_X_CONTACT_PART_INST ' || P_ESN_CONTACT ||  ' ' || P_ESN_OBJID;
       LOG_MSG(P_ESN, V_MSG,P_BRAND,'FIX');
     END IF;
     ---------------------------------------------------------------------------
    EXCEPTION
          WHEN OTHERS THEN
            RETURN;
    END;
  /*=======================================================================================
  PROCEDURE: FIX_ACCOUNT
  DETAILS  : SERIES OF FIXES AND CHECKS FOR THE ACCOUNT OF AN ESN
  =======================================================================================*/
  PROCEDURE FIX_ACCOUNT
  (
    P_ESN       IN VARCHAR2,
    P_BRAND     IN VARCHAR2,
    P_BUS_ORG   IN NUMBER,
    P_ESN_OBJID IN VARCHAR2,
    P_ESN_CONTACT IN VARCHAR2,
    P_CNT       OUT NUMBER
  )
  AS
  CNT_CPI       NUMBER;
  CNT_CONT_CPI  NUMBER;
  V_CONTACT     VARCHAR2(30);
  V_BUS_ORG     VARCHAR2(30);
  CNT_BUS_ORG   VARCHAR2(30);
  V_ADD_INFO_CNTN NUMBER;
  V_ADD_INFO_CNT NUMBER;
  V_WEB_USER_CNT NUMBER;
  BEGIN
  CNT_CPI:=0;
  CNT_CONT_CPI:=0;
  V_CONTACT:='';
  V_BUS_ORG :='';
  CNT_BUS_ORG:='';
  V_ADD_INFO_CNTN :=0;
  V_ADD_INFO_CNT:=0;
  V_WEB_USER_CNT:=0;


      --- CLEAN UP DUPLICATES --------------------------------------------------
      SELECT COUNT(*)
      INTO CNT_CPI  --<<-- NUMBER OF RECORDS IN TABLE_X_CONTACT_PART_INST
      FROM TABLE_X_CONTACT_PART_INST
      WHERE X_CONTACT_PART_INST2PART_INST =P_ESN_OBJID;



      IF (CNT_CPI>=1) THEN
          SELECT COUNT( DISTINCT X_CONTACT_PART_INST2CONTACT)
          INTO CNT_CONT_CPI  --<<-- NUMBER OF DUPLICATE RECORDS IN TABLE_X_CONTACT_PART_INST
          FROM TABLE_X_CONTACT_PART_INST
          WHERE X_CONTACT_PART_INST2PART_INST = P_ESN_OBJID;

          IF (CNT_CONT_CPI>1) THEN
            V_MSG :='MULTIPLE CONTACT RECORDS ARE IN TABLE_X_CONTACT_PART_INST FOR THIS ESN. PLEASE CHECK MY_ACCOUNT';
            LOG_MSG(P_ESN, V_MSG, P_BRAND, 'LOG');
            RETURN;
          ELSE
               --ONLY 1
            BEGIN
                  -- NULL THE DUPLICATES, ALL EXCEPT THE MOST RECENT ONE BASED ON LATEST OBJID
                  UPDATE TABLE_X_CONTACT_PART_INST
                  SET X_CONTACT_PART_INST2PART_INST  =NULL,
                    X_CONTACT_PART_INST2contact      =NULL
                  WHERE X_CONTACT_PART_INST2PART_INST=P_ESN_OBJID
                  AND OBJID <> (SELECT MAX(OBJID)
                    FROM TABLE_X_CONTACT_PART_INST
                    WHERE X_CONTACT_PART_INST2PART_INST =P_ESN_OBJID);
                  IF SQL%ROWCOUNT > 0 THEN
                     V_MSG :='FIXED DUPLICATE RECORDS IN TABLE_X_CONTACT_PART_INST';
                      LOG_MSG(P_ESN, V_MSG,P_BRAND, 'FIX');
                  END IF;


                  SELECT X_CONTACT_PART_INST2CONTACT INTO V_CONTACT FROM TABLE_X_CONTACT_PART_INST WHERE X_CONTACT_PART_INST2PART_INST =P_ESN_OBJID;


            EXCEPTION
                WHEN OTHERS THEN
                err_num := SQLCODE;
                LOG_MSG(P_ESN, err_num, P_BRAND, 'LOG');
            END;

          END IF;

      --- CLEAN UP THE NICKNAMES -----------------------------------------------
        BEGIN
            SELECT X_ESN_NICK_NAME INTO V_ESN_NICK_NAME
            FROM TABLE_X_CONTACT_PART_INST WHERE X_CONTACT_PART_INST2PART_INST =P_ESN_OBJID;

            IF REGEXP_LIKE (V_ESN_NICK_NAME,'[&|#|$|"]') THEN
                  --FOUND SOMETHING TO FIX
                  UPDATE TABLE_X_CONTACT_PART_INST
                  SET X_ESN_NICK_NAME = REGEXP_REPLACE(X_ESN_NICK_NAME,'[&|#|$|"|@]',' ')
                  WHERE X_CONTACT_PART_INST2PART_INST =P_ESN_OBJID
                  AND NVL(X_ESN_NICK_NAME,'0') <> '0';
                  IF SQL%ROWCOUNT > 0 THEN
                     V_MSG:='CLEAN UP MY ACCOUNT NICK NAME USING REGEX';
                      LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
                  END IF;

            END IF;
        EXCEPTION
                WHEN OTHERS THEN
                err_num := SQLCODE;
                LOG_MSG(P_ESN, err_num,P_BRAND, 'LOG');
        END;




    --- POPULATE NULL CONTACT INFO -----------------------------------------------
        -----Added "_" to SIMPLE_MOBILE and TOTAL_WIRELESS--icaocabrera
        IF P_BRAND IN ('STRAIGHT TALK', 'SIMPLE_MOBILE', 'TOTAL_WIRELESS') THEN
          UPDATE TABLE_CONTACT
          SET LAST_NAME =P_ESN,
            FIRST_NAME  =P_ESN,
            S_LAST_NAME =P_ESN,
            S_FIRST_NAME=P_ESN
          WHERE
          OBJID IN (SELECT X_CONTACT_PART_INST2CONTACT FROM TABLE_X_CONTACT_PART_INST WHERE X_CONTACT_PART_INST2PART_INST =P_ESN_OBJID)
          AND (LAST_NAME IS NULL OR FIRST_NAME IS NULL);
          IF SQL%ROWCOUNT > 0 THEN

            V_MSG :='FIXED NULL CONTACT INFO';
            LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
          END IF;

        ELSE
          UPDATE TABLE_CONTACT
          SET   LAST_NAME   =NVL(X_CUST_ID,'last name'),
                FIRST_NAME  =NVL(X_CUST_ID,'first name'),
                S_LAST_NAME =NVL(X_CUST_ID,'LAST NAME'),
                S_FIRST_NAME=NVL(X_CUST_ID,'FIRST NAME')
          WHERE
          OBJID IN (SELECT X_CONTACT_PART_INST2CONTACT FROM TABLE_X_CONTACT_PART_INST WHERE X_CONTACT_PART_INST2PART_INST =P_ESN_OBJID)
          AND (LAST_NAME IS NULL OR FIRST_NAME IS NULL);
          IF SQL%ROWCOUNT > 0 THEN
            V_MSG :='FIXED NULL CONTACT INFO';
            LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
          END IF;

        END IF;


        FOR J IN C_BUS_ORG_CPI(V_CONTACT, P_ESN)
        LOOP
          -- FOR EVERY BUS ORG FOUND, CHECK THE ESN_CONTACT AND BUS_ORG
           CHECK_WEB_USER(P_ESN,V_CONTACT, P_BRAND, J.BUS_ORG);
           CHECK_ADD_INFO(P_ESN,V_CONTACT, P_BRAND, J.BUS_ORG);

        END LOOP;


      ELSE  --<<--  THEN CNT_CPI==0, MEANS NO RECORD FOUND IN TABLE_X_CONTACT_PART_INST FOR THE PART INSTOBJ ID

        --V_CONTACT WOULD BE NULL SO USE A CONTACT
        SELECT X_PART_INST2CONTACT INTO V_CONTACT FROM TABLE_PART_INST WHERE PART_SERIAL_NO = P_ESN;

        CR_DUMMY_ACCT(P_ESN, P_BRAND, P_BUS_ORG, P_ESN_OBJID, V_CONTACT );
      END IF;

  -- THIS IS A RETURN PARAMETER
  P_CNT:=0;
  EXCEPTION
          WHEN OTHERS THEN
            RETURN;
  END;


  /*=======================================================================================
  PROCEDURE: COMMON_ENROLLMENT_ISSUES
  DETAILS  :
  =======================================================================================*/
  PROCEDURE COMMON_ENROLLMENT_ISSUES(
      P_ESN     IN VARCHAR2,
      P_BRAND   IN VARCHAR2,
      P_BUS_ORG IN NUMBER,
      P_ESN_CONTACT IN NUMBER)
  AS
  V_SITEPART_OBJID NUMBER;
  V_WEBUSER_OBJID NUMBER;
  BEGIN
  V_SITEPART_OBJID :=0;
  V_WEBUSER_OBJID  :=0;

      FOR E IN ENROLLMENT(P_ESN)
      LOOP
        -- FIRST CHECK: IS IT ENROLLED AND IS IT RECURRING
        IF  E.X_ENROLLMENT_STATUS='ENROLLED' AND E.X_IS_RECURRING=1 THEN

          --IF THE ENROLLMENT RECORD START DATE IS IN THE FUTURE -OR- THE
          -- ENROLLMENT RECORD END DATE IS IN THE PAST, THEN ALERT AGENT AND EXIT
          IF E.PP_END_DATE<SYSDATE OR E.PP_START_DATE>SYSDATE THEN
              V_MSG :='THE PROGRAM IS NOT VALID FOR ENROLLMENT';
              LOG_MSG (P_ESN,V_MSG,P_BRAND,'LOG');
              RETURN;
          END IF;

          BEGIN
              --GRAB THE SITE PART OBJID
               V_SITEPART_OBJID := GET_SITE_PART_ID(P_ESN);

               --ONCE A VALID OBJID HAS BEEN FOUND THEN
               IF V_SITEPART_OBJID!=0 THEN
                  -- UPDATE X_PROGRAM_ENROLLED LINK TO SITE PART IF ITS NOT
                  -- LINKED TO THE ACTIVE SITE PART AND IF THE ENROLMENT
                  -- STATUS = ENROLLED.
                  UPDATE X_PROGRAM_ENROLLED
                  SET PGM_ENROLL2SITE_PART =V_SITEPART_OBJID
                  WHERE
                  X_ENROLLMENT_STATUS  ='ENROLLED'
                  AND OBJID  =E.OBJID
                  AND (E.PGM_ENROLL2SITE_PART IS NULL OR E.PGM_ENROLL2SITE_PART<> V_SITEPART_OBJID);

                  IF SQL%ROWCOUNT >=1 THEN
                    V_MSG:='FIXED PROGRAM ENROLLED SITE PART ISSUE';
                    LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
                  END IF;
              END IF;

              --GRAB THE WEB USER OBJID
              V_WEBUSER_OBJID := GET_WEB_USER_OBJID(P_ESN_CONTACT);

              IF V_WEBUSER_OBJID!=0 THEN
              --IF THE WEB USER OBJID IS DIFFERENT FROM THE WEB USER ID THE ENROLLMENT RECORD HAS, THEN ALERT THE AGENT
                IF(E.PGM_ENROLL2WEB_USER!=V_WEBUSER_OBJID) THEN
                    V_MSG :='PLEASE CHECK PE_WU ISSUE';  --<<----------------------------------------------------------------------------------------------------------------------------------FIXES NOTHING
                   LOG_MSG (P_ESN,V_MSG,P_BRAND,'LOG');
                END IF;
              END IF;

          END;
        END IF;

         -- SECOND CHECK: IS IT NOT ENROLLED AND DOES X_WAIT_EXP_DATE HAVE A VALUE
            UPDATE X_PROGRAM_ENROLLED
            SET X_WAIT_EXP_DATE = NULL
            WHERE OBJID=E.OBJID
            and X_ENROLLMENT_STATUS NOT IN ('ENROLLED','SUSPENDED')
            AND X_WAIT_EXP_DATE IS NOT NULL;
            IF SQL%ROWCOUNT =1 THEN
              V_MSG:='FIXED X_WAIT_EXP_DATE NOT NULL FOR DEENROLLED PROGRAM';
              LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
            END IF;

        -- THIRD CHECK: IF RECORD IS SUSPENDED BUT EXP DATE IS NULL, SET THE DATE TO YESTERDAY
            UPDATE X_PROGRAM_ENROLLED
            SET X_EXP_DATE=SYSDATE-1
            WHERE OBJID   =E.OBJID
            AND X_ENROLLMENT_STATUS=('SUSPENDED')
            AND X_EXP_DATE IS NULL;
            IF SQL%ROWCOUNT =1 THEN
              V_MSG:='FIXED X_EXP_DATE FOR SUSPENDED RECORD';
              LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
            END IF;

        --FOURTH CHECK:
            UPDATE X_PROGRAM_ENROLLED
            SET PGM_ENROLL2PGM_GROUP   = NULL,
              X_NEXT_CHARGE_DATE       = NULL,
              X_NEXT_DELIVERY_DATE     = NULL,
              X_WAIT_EXP_DATE          = NULL,
              X_COOLING_EXP_DATE       = NULL,
              X_UPDATE_STAMP           = SYSDATE,
              X_EXP_DATE               = NULL,
              X_GRACE_PERIOD           = NULL,
              X_COOLING_PERIOD         = NULL,
              X_SERVICE_DAYS           = NULL,
              X_TOT_GRACE_PERIOD_GIVEN = NULL
            WHERE OBJID                = E.OBJID
            AND X_ENROLLMENT_STATUS    = 'READYTOREENROLL'
            AND (
                COALESCE (X_EXP_DATE, X_NEXT_CHARGE_DATE, X_COOLING_EXP_DATE, X_NEXT_DELIVERY_DATE)  IS NOT NULL
                OR
                COALESCE (X_GRACE_PERIOD, X_COOLING_PERIOD, X_SERVICE_DAYS, X_TOT_GRACE_PERIOD_GIVEN)IS NOT NULL
                );
            IF SQL%ROWCOUNT =1 THEN
              V_MSG:='FIXED NOT NULL COLUMNS ISSUE FOR READYTOREENROLL';
              LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
            END IF;



      END LOOP;

  EXCEPTION
          WHEN OTHERS THEN
            RETURN;
  END;



  /*=======================================================================================
  PROCEDURE: FIX_EP_RECORDS_NOT_ACTIVE
  DETAILS  : CHECKS TO SEE IF THERE IS AN ENROLLMENT (ENROLLMENTPENDING) FOR A PART INST
             ESN THAT IS NOT IN STATE 52 (ACTIVE). IF THERE IS A RECORD THEN
            UPDATE X_PROGRAM_ENROLLED AND SET X_ENROLLMENT_STATUS = ENROLLMENTFAILED
            FOR THAT ESN.
  =======================================================================================*/
  PROCEDURE FIX_EP_RECORDS_NOT_ACTIVE(
                P_ESN IN VARCHAR2,
                P_BRAND IN VARCHAR2)
            IS
  BEGIN
   --FOR EVERY PART INST RECORD FOR THIS ESN

    SELECT COUNT(1) INTO V_COUNT
    FROM sa.TABLE_PART_INST PI
    WHERE PI.PART_SERIAL_NO   = P_ESN
    AND PI.X_DOMAIN           ='PHONES'
    AND PI.X_PART_INST_STATUS<>'52'
    AND EXISTS
      (SELECT 1
      FROM X_PROGRAM_ENROLLED
      WHERE X_ESN             = PI.PART_SERIAL_NO
      AND X_ENROLLMENT_STATUS = 'ENROLLMENTPENDING'
      );

    IF V_COUNT > 0 THEN --SO THERE IS AN ENROLLMENT WE SHOULD FIX

      --THEN UPDATE THE ENROLLMENT
      UPDATE X_PROGRAM_ENROLLED
      SET X_ENROLLMENT_STATUS   = 'ENROLLMENTFAILED',
        X_UPDATE_STAMP          = SYSDATE
      WHERE X_ENROLLMENT_STATUS = 'ENROLLMENTPENDING'
      AND X_ESN                 = P_ESN;

      IF SQL%ROWCOUNT           >0 THEN
        V_MSG:='FIXED ENROLLMENTPENDING TO ENROLLMENTFAILED';
        LOG_MSG(P_ESN, V_MSG, P_BRAND, 'FIX');
      END IF;

    END IF;
  EXCEPTION
          WHEN OTHERS THEN
            RETURN;
  END;

  /*=======================================================================================
  PROCEDURE: CHECK_SERVICE_PLAN
  DETAILS  : CHECKS FOR AN ACTIVE SITE PART RECORD AND MAPS THE SERVICE PLAN TO THE ENROLLED RECORD
            IF THE ENROLLMENT RECORD IS NOT 'ENROLLED' THEN ALERT AGENT SAYING
            'ESN IS NOT ENROLLED IN ANY PROGRAM'.
  =======================================================================================*/
  PROCEDURE CHECK_SERVICE_PLAN(
            P_ESN   IN VARCHAR2,
            P_BRAND IN VARCHAR2)
        IS
        PE_ENR_CNT NUMBER;

          BEGIN

            PE_ENR_CNT:=0;
            SELECT
            COUNT(1) INTO PE_ENR_CNT
            FROM X_SERVICE_PLAN_SITE_PART XSP,
            TABLE_SITE_PART SP,  X_PROGRAM_ENROLLED PE
            WHERE SP.X_SERVICE_ID =P_ESN
            AND PE.X_ESN  = SP.X_SERVICE_ID
            AND PE.X_ENROLLMENT_STATUS = 'ENROLLED'
            AND SP.OBJID         =XSP.TABLE_SITE_PART_ID
            AND SP.PART_STATUS  IN ('Active');

            IF PE_ENR_CNT=0 THEN
              V_MSG:='ESN IS NOT ENROLLED IN ANY PROGRAM';
             LOG_MSG (P_ESN,V_MSG,P_BRAND,'LOG');
            END IF;
        EXCEPTION
          WHEN OTHERS THEN
            RETURN;
        END;

    /*=======================================================================================
    PROCEDURE: UPDATE_PGM_ENROLL
    DETAILS  : UPDATES X_PROGRAM_ENROLLED AND SETS THE PGM_ENROLL2PGM_GROUP TO NULL FOR A
               GIVEN OBJID
    =======================================================================================*/
    PROCEDURE UPDATE_PGM_ENROLL(
              OBJID_IN IN NUMBER,
              P_ESN   IN VARCHAR2,
              P_BRAND IN VARCHAR2
              )
      IS
      BEGIN
        UPDATE X_PROGRAM_ENROLLED SET PGM_ENROLL2PGM_GROUP=NULL WHERE OBJID=OBJID_IN;
        LOG_MSG(P_ESN, 'DISCONNECTED ESN PE RECORD FROM FAMILY PLAN GROUP', P_BRAND, 'FIX');
      EXCEPTION
          WHEN OTHERS THEN
            RETURN;
      END;



    /*=======================================================================================
    PROCEDURE: FIX_MISSING_SERVICE_PLAN
    DETAILS  : IF A GROUP SERVICE_PLAN_ID IS NULL, BUT THE ESN FOR A GROUP MEMBER VIA SITEPART
               HAS A SERVICE PLAN, THEN UDPATE ACCOUNT GROUP TO THAT SERVICE PLAN ID
    =======================================================================================*/
     PROCEDURE FIX_MISSING_SERVICE_PLAN(
            P_ESN   IN VARCHAR2,
            P_BRAND IN VARCHAR2,
            P_ESN_STATUS  IN VARCHAR2
            )

     IS

     V_GROUPID VARCHAR2(25) := NULL;
     V_SERVICEPLANID VARCHAR2(25) := NULL;
     BEGIN

          BEGIN
            SELECT AG.OBJID INTO V_GROUPID
            FROM  X_ACCOUNT_GROUP AG,
                  X_ACCOUNT_GROUP_MEMBER MEM
            WHERE
                  NVL(SERVICE_PLAN_ID,0)=0
              AND MEM.ACCOUNT_GROUP_ID = AG.OBJID
              AND MEM.ESN = P_ESN;
         EXCEPTION
              WHEN NO_DATA_FOUND THEN
              V_GROUPID := NULL;
          END;

        BEGIN
         SELECT SPSP.X_SERVICE_PLAN_ID
         INTO V_SERVICEPLANID
         FROM (SELECT MAX(TS.OBJID) TSP_OBJID
                FROM  TABLE_SITE_PART TS,
                      X_SERVICE_PLAN_SITE_PART MTM
                WHERE MTM.TABLE_SITE_PART_ID = TS.OBJID
                AND   TS.X_SERVICE_ID      = P_ESN
                AND   TS.PART_STATUS      = 'Active'
                ) MAX_TSP
                ,X_SERVICE_PLAN_SITE_PART SPSP
         WHERE SPSP.TABLE_SITE_PART_ID = MAX_TSP.TSP_OBJID;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_GROUPID := NULL;
          END;

           IF V_GROUPID IS NOT NULL AND NVL(V_SERVICEPLANID,0)!=0 THEN
            BEGIN
              UPDATE X_ACCOUNT_GROUP AG
              SET SERVICE_PLAN_ID = V_SERVICEPLANID
              WHERE AG.OBJID = V_GROUPID;
              IF SQL%ROWCOUNT > 0 THEN
                V_MSG:='FIXED MISSING SERVICE PLAN';
                LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
              END IF;
            END;
         END IF;

    EXCEPTION
          WHEN OTHERS THEN
            RETURN;
     END;

  /*=======================================================================================
  PROCEDURE: FIX_EXPIRED_GROUP
  DETAILS  : IF MEMBER IS ACTIVE (AND ESN IS ACTIVE), AND GROUP IS EXPIRED, THEN SET GROUP TO ACTIVE
  =======================================================================================*/
  PROCEDURE FIX_EXPIRED_GROUP(
            P_ESN   IN VARCHAR2,
            P_BRAND IN VARCHAR2,
            P_ESN_STATUS  IN VARCHAR2
            )
            IS

    V_GROUPID VARCHAR2(25) := NULL;

    BEGIN

        BEGIN
            SELECT
            G.OBJID GROUPID
            INTO V_GROUPID
            FROM
                   X_ACCOUNT_GROUP_MEMBER M,
                   X_ACCOUNT_GROUP G
            WHERE
                   M.ACCOUNT_GROUP_ID = G.OBJID
               AND BUS_ORG_OBJID IN (536876747, 268448087)
               AND UPPER(G.STATUS) = 'EXPIRED'
               AND UPPER(M.STATUS) in ( 'ACTIVE', 'SIM_PENDING')
               AND M.ESN = P_ESN;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            V_GROUPID := NULL;
        END;

       IF V_GROUPID IS NOT NULL THEN

           UPDATE X_ACCOUNT_GROUP SET STATUS = 'ACTIVE' WHERE OBJID = V_GROUPID;
            IF SQL%ROWCOUNT > 0 THEN
              V_MSG:='FIXED EXPIRED GROUP';
              LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
            END IF;

       END IF;

    EXCEPTION
          WHEN OTHERS THEN
            RETURN;
   END;

  /*=======================================================================================
  PROCEDURE: FIX_GROUP_MEMBER
  DETAILS  : IF GROUP IS ACTIVE (AND ESN AND LINE IS ACTIVE), AND MEMBER IS EXPIRED, THEN SET MEMBER TO ACTIVE
  =======================================================================================*/
  PROCEDURE FIX_GROUP_MEMBER(
            P_ESN   IN VARCHAR2,
            P_BRAND IN VARCHAR2,
            P_ESN_STATUS  IN VARCHAR2
            )
            IS

    V_MEMBERID VARCHAR2(25) := NULL;

    BEGIN

        BEGIN
            SELECT
            M.OBJID MEMBERID
            INTO V_MEMBERID
            FROM
                   X_ACCOUNT_GROUP_MEMBER M,
                   X_ACCOUNT_GROUP G,
                   TABLE_PART_INST PHONE_PI,
                   TABLE_PART_INST LINE_PI
            WHERE
                   M.ACCOUNT_GROUP_ID = G.OBJID
                   AND PHONE_PI.PART_SERIAL_NO = M.ESN
                   AND PHONE_PI.X_DOMAIN = 'PHONES'
                   AND LINE_PI.PART_TO_ESN2PART_INST = PHONE_PI.OBJID
                   AND LINE_PI.X_DOMAIN = 'LINES'
               AND BUS_ORG_OBJID IN (536876747, 268448087)
               AND PHONE_PI.X_PART_INST_STATUS = '52'
               AND LINE_PI.X_PART_INST_STATUS = '13'
               AND UPPER(G.STATUS) = 'ACTIVE'
               AND UPPER(M.STATUS) != 'ACTIVE'
               AND M.ESN = P_ESN;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            V_MEMBERID := NULL;
        END;

       IF V_MEMBERID IS NOT NULL THEN

           UPDATE X_ACCOUNT_GROUP_MEMBER SET STATUS = 'ACTIVE', END_DATE = NULL WHERE OBJID = V_MEMBERID;
            IF SQL%ROWCOUNT > 0 THEN
              V_MSG:='FIXED EXPIRED MEMBER';
              LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
            END IF;

       END IF;


       BEGIN
            SELECT
            M.OBJID MEMBERID
            INTO V_MEMBERID
            FROM
                   X_ACCOUNT_GROUP_MEMBER M,
                   X_ACCOUNT_GROUP G,
                   TABLE_PART_INST PHONE_PI,
                   TABLE_PART_INST LINE_PI
            WHERE
                   M.ACCOUNT_GROUP_ID = G.OBJID
                   AND PHONE_PI.PART_SERIAL_NO = M.ESN
                   AND PHONE_PI.X_DOMAIN = 'PHONES'
                   AND LINE_PI.PART_TO_ESN2PART_INST = PHONE_PI.OBJID
                   AND LINE_PI.X_DOMAIN = 'LINES'
               AND BUS_ORG_OBJID IN (536876747, 268448087)
               AND PHONE_PI.X_PART_INST_STATUS = '52'
               AND LINE_PI.X_PART_INST_STATUS = '13'
               AND UPPER(G.STATUS) in ( 'NEW')
               AND UPPER(M.STATUS) in ( 'PENDING_ENROLLMENT')
               AND M.ESN = P_ESN;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            V_MEMBERID := NULL;
        END;

       IF V_MEMBERID IS NOT NULL THEN

            UPDATE X_ACCOUNT_GROUP_MEMBER SET STATUS = 'ACTIVE', END_DATE = NULL WHERE OBJID = V_MEMBERID;
            IF SQL%ROWCOUNT > 0 THEN
              V_MSG:='FIXED PENDING_ENROLLMENT MEMBER - UPDATED TO ACTIVE';
              LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
            END IF;

            UPDATE X_ACCOUNT_GROUP SET STATUS = 'ACTIVE' WHERE OBJID = (SELECT ACCOUNT_GROUP_ID FROM X_ACCOUNT_GROUP_MEMBER WHERE OBJID = V_MEMBERID);
            IF SQL%ROWCOUNT > 0 THEN
              V_MSG:='FIXED PENDING_ENROLLMENT MEMBER GROUP - UPDATED GROUP TO ACTIVE';
              LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
            END IF;

       END IF;


      /*
      BEGIN
            SELECT
            M.OBJID MEMBERID
            INTO V_MEMBERID
            FROM
                   X_ACCOUNT_GROUP_MEMBER M,
                   X_ACCOUNT_GROUP G,
                   TABLE_PART_INST PHONE_PI,
                   TABLE_PART_INST LINE_PI
            WHERE
                   M.ACCOUNT_GROUP_ID = G.OBJID
                   AND PHONE_PI.PART_SERIAL_NO = M.ESN
                   AND PHONE_PI.X_DOMAIN = 'PHONES'
                   AND LINE_PI.PART_TO_ESN2PART_INST = PHONE_PI.OBJID
                   AND LINE_PI.X_DOMAIN = 'LINES'
               AND BUS_ORG_OBJID IN (536876747, 268448087)
               AND PHONE_PI.X_PART_INST_STATUS != '52'
               AND LINE_PI.X_PART_INST_STATUS != '13'
               AND UPPER(M.STATUS) = 'ACTIVE'
               AND M.ESN = P_ESN;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            V_MEMBERID := NULL;
        END;

       IF V_MEMBERID IS NOT NULL THEN

           UPDATE X_ACCOUNT_GROUP_MEMBER SET STATUS = 'EXPIRED', END_DATE = SYSDATE WHERE OBJID = V_MEMBERID;
            IF SQL%ROWCOUNT > 0 THEN
              V_MSG:='EXPIRED ACTIVE MEMBER WITH INACTIVE ESN';
              LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
            END IF;

       END IF;
*/



    EXCEPTION
          WHEN OTHERS THEN
            RETURN;
   END;


   /*=======================================================================================
  PROCEDURE: FIX_DUPLICATE_GROUP_MEMBER
  DETAILS  : IF A GROUP HAS THE SAME MEMBER OCCURRING MORE THAN ONCE, WE EXPIRE ALL BUT
             THE MOST RECENT COPY OF THAT MEMBER.
  =======================================================================================*/
  PROCEDURE FIX_DUPLICATE_GROUP_MEMBER(
            P_ESN   IN VARCHAR2,
            P_BRAND IN VARCHAR2,
            P_ESN_STATUS  IN VARCHAR2
            )
            IS

   V_GROUPID VARCHAR2(25)  :=NULL;
   V_MEMBERID VARCHAR2(25) :=NULL;
   BEGIN

      BEGIN
        SELECT
        ACCOUNT_GROUP_ID INTO V_GROUPID
        FROM X_ACCOUNT_GROUP_MEMBER
        WHERE ESN = P_ESN
        GROUP BY ACCOUNT_GROUP_ID, ESN, STATUS
        HAVING COUNT(1) > 1;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
            V_GROUPID := NULL;
      END;


       IF V_GROUPID IS NOT NULL THEN --MEANS THIS GROUP HAS A MEMBER MORE THAN ONCE
          BEGIN
          --SO SELECT ALL BUT THE MOST RECENT MEMBER RECORD AND EXPIRE IT
          SELECT MAX(OBJID) INTO V_MEMBERID
          FROM X_ACCOUNT_GROUP_MEMBER
          WHERE ESN = P_ESN
          AND ACCOUNT_GROUP_ID = V_GROUPID;

          UPDATE X_ACCOUNT_GROUP_MEMBER
          SET STATUS = 'EXPIRED',
          END_DATE = SYSDATE-1
          WHERE OBJID != V_MEMBERID;
          IF SQL%ROWCOUNT > 0 THEN
              V_MSG:='FIXED DUPLICATE GROUP MEMBER';
              LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
          END IF;
          END;
      END IF;

   EXCEPTION
          WHEN OTHERS THEN
            RETURN;
   END;



  /*=======================================================================================
  PROCEDURE: FIX_GROUP_ORDER
  DETAILS  : PROPERLY ORDERS THE GROUP, MAKING SURE THAT THE MASTER IS 1 AND THE OTHERS FLOW UNIQUELY
  =======================================================================================*/
  /*PROCEDURE FIX_GROUP_ORDER(
            P_ESN   IN VARCHAR2,
            P_BRAND IN VARCHAR2,
            P_ESN_STATUS  IN VARCHAR2
            )
            IS

     V_MEMBERID       VARCHAR2(25) :=NULL;
     V_GROUPID        VARCHAR2(25) :=NULL;
     V_MEMBERSTATUS   VARCHAR2(25) :=NULL;
     V_GROUPSTATUS    VARCHAR2(25) :=NULL;
     V_MEMBERCOUNT    NUMBER:=0;
   BEGIN


      SELECT OBJID, ACCOUNT_GROUP_ID INTO V_MEMBERID, V_GROUPID
      FROM X_ACCOUNT_GROUP_MEMBER
      WHERE ACCOUNT_GROUP_ID IN (SELECT account_group_id FROM x_account_group_member where esn = P_ESN )
      AND MASTER_FLAG = 'Y';


        --FIRST MAKE SURE THE MASTER IS SET TO 1
        UPDATE X_ACCOUNT_GROUP_MEMBER SET
        MEMBER_ORDER = '1'
        WHERE OBJID = V_MEMBERID
        AND MEMBER_ORDER !=1;

        IF SQL%ROWCOUNT > 0 THEN
            V_MSG:='REORDERED THE GROUP MASTER TO 1';
            LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
        END IF;

        --NOW UPDATE THE REST TO A NUMERIC SEQUENCE
        MERGE INTO X_ACCOUNT_GROUP_MEMBER GM
        USING (SELECT OBJID, ROWNUM+1 RN FROM X_ACCOUNT_GROUP_MEMBER WHERE ACCOUNT_GROUP_ID =V_GROUPID AND OBJID !=V_MEMBERID) CNT
        ON (GM.OBJID = CNT.OBJID)
        WHEN MATCHED THEN
        UPDATE SET GM.MEMBER_ORDER = CNT.RN;
        IF SQL%ROWCOUNT > 0 THEN
            V_MSG:='REORDERED THE GROUP MEMBERS';
            LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
        END IF;



   EXCEPTION
      WHEN OTHERS THEN
         V_MSG:='PROBLEM ORDERING THE GROUP MEMBERS';
         --LOG_MSG (P_ESN,V_MSG,P_BRAND,'LOG');

   END;

   */

  /*=======================================================================================
  PROCEDURE: FIX_GROUP_DUPLICATE_MASTER
  DETAILS  : IF A GROUP MEMBER IS IN A GROUP THAT HAS MORE THAN ONE MASTER, SET ALL BUT ONE TO 'N'
  =======================================================================================*/
  PROCEDURE FIX_GROUP_DUPLICATE_MASTER(
            P_ESN   IN VARCHAR2,
            P_BRAND IN VARCHAR2,
            P_ESN_STATUS  IN VARCHAR2
            )
            IS

     V_MEMBERID       VARCHAR2(25) :=NULL;
     V_GROUPID        VARCHAR2(25) :=NULL;
     V_MEMBERSTATUS   VARCHAR2(25) :=NULL;
     V_GROUPSTATUS    VARCHAR2(25) :=NULL;
     V_MEMBERCOUNT    NUMBER:=0;
   BEGIN

    SELECT account_group_id, count(1) cnt INTO  V_GROUPID, V_MEMBERCOUNT
    FROM X_ACCOUNT_GROUP_MEMBER
    WHERE ACCOUNT_GROUP_ID IN
    (SELECT account_group_id FROM x_account_group_member where esn = P_ESN )
    and master_flag = 'Y' group by account_group_id, master_flag;

   IF V_MEMBERCOUNT > 0 THEN
      --WE FOUND A DUPLICATE
      SELECT MIN(OBJID) INTO V_MEMBERID FROM X_ACCOUNT_GROUP_MEMBER WHERE ACCOUNT_GROUP_ID = V_GROUPID AND MASTER_FLAG='Y';

      --NOW THAT WE HAVE THE ONE WE ARE LEAVING AS MASTER, UPDATE THE REST TO N
      UPDATE X_ACCOUNT_GROUP_MEMBER SET
      MASTER_FLAG = 'N',
      RECEIVE_TEXT_ALERTS_FLAG = 'N'
      WHERE ACCOUNT_GROUP_ID = V_GROUPID AND MASTER_FLAG='Y'
      AND OBJID != V_MEMBERID;
      IF SQL%ROWCOUNT > 0 THEN
          V_MSG:='FIXED DUPLICATE GROUP MASTER';
          LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
      END IF;
   END IF;

   EXCEPTION
          WHEN OTHERS THEN
            RETURN;
   END;

  /*=======================================================================================
  PROCEDURE: FIX_GROUP_NO_MASTER
  DETAILS  : IF AN ACTIVE GROUP WITH ACTIVE MEMBERS HAS NONE OF THE MEMBERS WITH THE MASTER
             FLAG=Y, WE TAKE THE ESN AND MAKE THAT ONE THE MASTER.
  =======================================================================================*/
  PROCEDURE FIX_GROUP_NO_MASTER(
            P_ESN   IN VARCHAR2,
            P_BRAND IN VARCHAR2,
            P_ESN_STATUS  IN VARCHAR2
            )
            IS

     V_MEMBERID VARCHAR2(25) :=NULL;
   BEGIN

            BEGIN
                SELECT MIN(GM.OBJID) INTO V_MEMBERID
                FROM X_ACCOUNT_GROUP_MEMBER GM
                WHERE GM.ACCOUNT_GROUP_ID IN(
                                            SELECT AGM.ACCOUNT_GROUP_ID
                                            FROM X_ACCOUNT_GROUP_MEMBER AGM
                                            WHERE AGM.ESN = P_ESN
                                            AND AGM.STATUS='ACTIVE'
                                            AND (SELECT COUNT(GM.MASTER_FLAG) FROM X_ACCOUNT_GROUP_MEMBER GM WHERE GM.ACCOUNT_GROUP_ID = AGM.ACCOUNT_GROUP_ID AND GM.STATUS='ACTIVE' AND GM.MASTER_FLAG='Y')=0
                                            GROUP BY AGM.ACCOUNT_GROUP_ID
                                            )
                      AND GM.STATUS='ACTIVE';
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  V_MEMBERID := NULL;
              END;



      IF V_MEMBERID IS NOT NULL THEN
             UPDATE X_ACCOUNT_GROUP_MEMBER SET MASTER_FLAG = 'Y' WHERE OBJID = V_MEMBERID AND MASTER_FLAG != 'Y';
              IF SQL%ROWCOUNT > 0 THEN
                V_MSG:='FIXED GROUP MEMBER MASTER MISSING';
                LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
              END IF;
      END IF;


   EXCEPTION
          WHEN OTHERS THEN
         RETURN;
   END;

    /*=======================================================================================
  PROCEDURE: FIX_GROUP_WRONGBRAND
  DETAILS  : IF ESN IS IN A DIFFERENT BRAND THAN THE GROUP THEN EXPIRE THE GROUP AND THE ESN

  =======================================================================================*/
  PROCEDURE FIX_GROUP_WRONGBRAND(
            P_ESN   IN VARCHAR2,
            P_BRAND IN VARCHAR2,
            P_ESN_STATUS  IN VARCHAR2
            )
            IS

     V_MEMBERID       VARCHAR2(25) :=NULL;
     V_GROUPID        VARCHAR2(25) :=NULL;
     V_MEMBERSTATUS   VARCHAR2(25) :=NULL;
     V_GROUPSTATUS    VARCHAR2(25) :=NULL;
     V_MEMBERCOUNT    NUMBER:=0;
     BEGIN

      SELECT
           ag.objid, agm.objid INTO V_GROUPID,V_MEMBERID
      FROM
           x_account_group ag,
           x_account_group_member agm,
           table_part_inst pi,
           table_mod_level tml,
           table_part_num tpn,
           table_bus_org bo,
           table_bus_org bo1
      WHERE
           agm.ESN = P_ESN
           AND agm.account_group_id = ag.objid
           AND ag.status = 'ACTIVE'
           AND agm.status = 'ACTIVE'
           AND ag.bus_org_objid = 536876745
           AND pi.x_domain = 'PHONES'
           AND pi.x_part_inst_status <> '52'
           AND pi.part_serial_no = agm.esn
           AND pi.n_part_inst2part_mod = tml.objid
           AND tml.part_info2part_num = tpn.objid
           AND tpn.part_num2bus_org = bo.objid
           AND ag.bus_org_objid = bo1.objid
           AND bo.org_id = 'TOTAL_WIRELESS'
           AND bo.org_id <> bo1.org_id;

          -- IF ITS FOUND A RECORD, THEN YES WE SHOULD EXPIRE THIS BAD DATA
        IF V_MEMBERID <>'' THEN
            UPDATE x_account_group SET status = 'EXPIRED'
            WHERE objid = V_GROUPID;

            UPDATE x_account_group_member SET status = 'EXPIRED'
            WHERE account_group_id = V_MEMBERID;
            IF SQL%ROWCOUNT > 0 THEN
              V_MSG:='WRONG GROUP/MEMBER BRAND POINTING TO DIFFERENT ESN BRAND. EXPIRED RECORDS';
              LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
            END IF;

      END IF;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
              V_MEMBERID := NULL;
       WHEN OTHERS THEN
            RETURN;
     END;


   /*=======================================================================================
  PROCEDURE: FIX_GROUP_CASEPENDING
  DETAILS  : IF ESN IS IN STATUS NEW, GROUP MEMBER IS CASE PENDING, ITS A ONE MEMBER GROUP
             AND GROUP ITSELF IS IN EXPIRED STATE, THEN SET GROUP TO NEW

  =======================================================================================*/
  PROCEDURE FIX_GROUP_CASEPENDING(
            P_ESN   IN VARCHAR2,
            P_BRAND IN VARCHAR2,
            P_ESN_STATUS  IN VARCHAR2
            )
            IS

     V_MEMBERID       VARCHAR2(25) :=NULL;
     V_GROUPID        VARCHAR2(25) :=NULL;
     V_MEMBERSTATUS   VARCHAR2(25) :=NULL;
     V_GROUPSTATUS    VARCHAR2(25) :=NULL;
     V_MEMBERCOUNT    NUMBER:=0;
     BEGIN


            BEGIN
            --NEW, SO GET THE GROUP MEMBER STATUS
            SELECT M.OBJID, M.STATUS MEMBERSTATUS, M.ACCOUNT_GROUP_ID, G.STATUS GROUPSTATUS
            INTO V_MEMBERID , V_MEMBERSTATUS, V_GROUPID, V_GROUPSTATUS
            FROM X_ACCOUNT_GROUP_MEMBER M, X_ACCOUNT_GROUP G
            WHERE M.ACCOUNT_GROUP_ID = G.OBJID
            AND ESN = P_ESN;

            --GET THE COUNT OF GROUP MEMBERS
            SELECT COUNT(1) INTO V_MEMBERCOUNT
            FROM X_ACCOUNT_GROUP_MEMBER WHERE
            ACCOUNT_GROUP_ID = V_GROUPID;

            IF (V_MEMBERCOUNT=1 AND V_GROUPSTATUS='EXPIRED' AND V_MEMBERSTATUS = 'CASE_PENDING') THEN
                UPDATE X_ACCOUNT_GROUP_MEMBER
                SET STATUS = 'EXPIRED'
                ,END_DATE = SYSDATE-1
                WHERE OBJID = V_MEMBERID;

                /*UPDATE X_ACCOUNT_GROUP
                SET STATUS = 'NEW'
                WHERE OBJID = V_GROUPID;*/

                IF SQL%ROWCOUNT > 0 THEN
                  V_MSG:='FIXED EXPIRED GROUP WITH CASE PENDING MEMBER';
                  LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
                END IF;
            END IF;


            --INCORPORATING DUGGI'S CASE PENDING SOLUTION
            IF(V_GROUPSTATUS='ACTIVE' AND V_MEMBERSTATUS = 'CASE_PENDING') THEN
                 UPDATE X_ACCOUNT_GROUP_MEMBER
                SET STATUS = 'EXPIRED'
                ,END_DATE = SYSDATE-1
                WHERE OBJID IN(
                              SELECT
                              gm.objid
                              FROM
                                     table_case ca, X_ACCOUNT_GROUP_MEMBER gm, table_part_inst pi
                              WHERE
                                     gm.esn = ca.x_esn
                                     and pi.part_serial_no = gm.esn
                                     AND pi.X_PART_INST_STATUS != '50'
                                     and ca.creation_time > TRUNC( SYSDATE - 7 )
                                     AND ca.x_case_type = 'Payment Pending'
                                     AND ca.title = 'Stage External'
                                     AND ca.case_type_lvl2 = 'TOTAL_WIRELESS'
                                     and gm.objid = V_MEMBERID
                                     AND NOT EXISTS
                                             (SELECT
                                                     1
                                              FROM
                                                     table_case ca1
                                              WHERE
                                                     1 = 1
                                                     AND ca1.x_esn = ca.x_esn
                                                     AND ca1.creation_time > TRUNC( SYSDATE - 7 )
                                                     AND ca1.x_case_type = 'Warehouse'
                                                     AND ca1.title = 'LTE SIM not in kit'
                                                     AND ca1.case_type_lvl2 = 'TOTAL_WIRELESS')
                                     AND EXISTS
                                             (SELECT
                                                     1
                                              FROM
                                                     x_account_group_member gm
                                              WHERE
                                                     1 = 1
                                                     AND gm.esn = ca.x_esn
                                                     AND gm.status = 'CASE_PENDING'
                                         ));

                IF SQL%ROWCOUNT > 0 THEN
                  V_MSG:='FIXED GROUP MEMBER STUCK IN INVALID CASE PENDING STATUS';
                  LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
                END IF;
            END IF;


          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_MEMBERID := NULL;
          END;
    EXCEPTION
          WHEN OTHERS THEN
            RETURN;
     END;


  /*=======================================================================================
  PROCEDURE: FIX_GROUPS
  DETAILS  : COLLECTION OF FIXES FOR THE GROUPS
  =======================================================================================*/
  PROCEDURE FIX_GROUPS(
            P_ESN         IN VARCHAR2,
            P_BRAND       IN VARCHAR2,
            P_ESN_STATUS  IN VARCHAR2,
            V_MSG         OUT VARCHAR2
            )
      IS
      BEGIN

         --FIRST CHECK, IT HAS TO BE EITHER TOTAL WIRELESS OR SIMPLE MOBILE
         IF P_BRAND IN ('TOTAL_WIRELESS','SIMPLE_MOBILE') THEN
              --DBMS_OUTPUT.DISABLE;

              FIX_EXPIRED_GROUP(P_ESN, P_BRAND, P_ESN_STATUS);
              FIX_GROUP_MEMBER(P_ESN, P_BRAND, P_ESN_STATUS);
              FIX_MISSING_SERVICE_PLAN(P_ESN, P_BRAND, P_ESN_STATUS);
              FIX_DUPLICATE_GROUP_MEMBER(P_ESN, P_BRAND, P_ESN_STATUS);
              FIX_GROUP_NO_MASTER(P_ESN, P_BRAND, P_ESN_STATUS);
              FIX_GROUP_CASEPENDING(P_ESN, P_BRAND, P_ESN_STATUS);
              FIX_GROUP_DUPLICATE_MASTER(P_ESN, P_BRAND, P_ESN_STATUS);
              FIX_GROUP_WRONGBRAND(P_ESN, P_BRAND, P_ESN_STATUS);


              --DBMS_OUTPUT.ENABLE;
         END IF;
      EXCEPTION
          WHEN OTHERS THEN
            RETURN;
      END;



  /*=======================================================================================
  PROCEDURE: FAMILY_PLAN_DEENROLL
  DETAILS  : CHECKS FOR DISCREPANCIES WITH CHILD MEMBERS AND PARENT MEMBER OF A GROUP ENROLLMENT
             1. IF CHILD IS NOT ENROLLED, BUT PARENT IS, THEN DISCONNECT FROM GROUP
             2. IF PARENT IS ENROLLMENTSCHEDULED AND CHILD IS ANYTHING ELSE, DISCONNECT CHILD FROM GROUP
             3. IF PARENT IS SUSPENDED AND CHILD IS NOT SUSPENDED, DISCONNECT CHILD FROM GROUP
             4. WHEN PARENT IS NOT ENROLLED, NOT ENROLLMENTSCHEDULED, NOT SUSPENDED, THEN DISCONNECT CHILD FROM GROUP
             5. IF CHILD IS ENROLLED, BUT PARENT IS NOT ENROLLED,ENROLLMENTSCHEDULED OR SUSPENDED, THEN DISCONNECT CHILD
             6. IF CHILD IS ENROLLMENTSCHEDULED AND PARENT IS NOT, DISCONNECT CHILD
             7. IF CHILD IS SUSPENDED AND PARENT IS NOT SUSPENDED, DISCONNECT CHILD FROM GROUP
             8. WHEN CHILD IS NOT ENROLLED, NOT ENROLLMENTSCHEDULED, NOT SUSPENDED, THEN DISCONNECT CHILD FROM GROUP
  =======================================================================================*/
    PROCEDURE FAMILY_PLAN_DEENROLL(
        P_ESN   IN VARCHAR2,
        P_BRAND IN VARCHAR2)
    IS
    BEGIN
       FOR I IN ESN_GROUP(P_ESN)
      LOOP
        IF I.PGM_ENROLL2PGM_GROUP IS NOT NULL THEN
          FOR J IN PRIMARY_ESN_GROUP(P_ESN)
          LOOP
            CASE
            WHEN J.X_ENROLLMENT_STATUS = 'ENROLLED' THEN
              IF I.X_ENROLLMENT_STATUS NOT IN ('ENROLLED','ENROLLMENTSCHEDULED','SUSPENDED') THEN
                UPDATE_PGM_ENROLL(I.OBJID, P_ESN, P_BRAND);
              END IF;
            WHEN J.X_ENROLLMENT_STATUS  = 'ENROLLMENTSCHEDULED' THEN
              IF I.X_ENROLLMENT_STATUS <> 'ENROLLMENTSCHEDULED' THEN
                UPDATE_PGM_ENROLL(I.OBJID, P_ESN, P_BRAND);
              END IF;
            WHEN J.X_ENROLLMENT_STATUS  = 'SUSPENDED' THEN
              IF I.X_ENROLLMENT_STATUS <> 'SUSPENDED' THEN
                UPDATE_PGM_ENROLL(I.OBJID, P_ESN, P_BRAND);
              END IF;
            ELSE
              UPDATE_PGM_ENROLL (I.OBJID, P_ESN, P_BRAND);
            END CASE;
          END LOOP;
        ELSE
          FOR J IN SECONDARY_ESN_GROUP(I.OBJID)
          LOOP
            CASE
            WHEN J.X_ENROLLMENT_STATUS = 'ENROLLED' THEN
              IF I.X_ENROLLMENT_STATUS NOT IN ('ENROLLED','ENROLLMENTSCHEDULED','SUSPENDED') THEN
                UPDATE_PGM_ENROLL(J.OBJID, P_ESN, P_BRAND);
              END IF;
            WHEN J.X_ENROLLMENT_STATUS  = 'ENROLLMENTSCHEDULED' THEN
              IF I.X_ENROLLMENT_STATUS <> 'ENROLLMENTSCHEDULED' THEN
                UPDATE_PGM_ENROLL(J.OBJID, P_ESN, P_BRAND);
              END IF;
            WHEN J.X_ENROLLMENT_STATUS  = 'SUSPENDED' THEN
              IF I.X_ENROLLMENT_STATUS <> 'SUSPENDED' THEN
                UPDATE_PGM_ENROLL(J.OBJID, P_ESN, P_BRAND);
              END IF;
            ELSE
              UPDATE_PGM_ENROLL (J.OBJID, P_ESN, P_BRAND);
            END CASE;
          END LOOP;
        END IF;
      END LOOP;
    EXCEPTION
          WHEN OTHERS THEN
            RETURN;
    END;


  /*=======================================================================================
  PROCEDURE: FIX_BILLING_ISSUES
  DETAILS  : SERIES OF FIXES FOR ENROLLMENT ISSUES
  =======================================================================================*/
   PROCEDURE FIX_BILLING_ISSUES(
    P_ESN         IN VARCHAR2,
    P_BRAND       IN VARCHAR2,
    P_BUS_ORG     IN NUMBER,
    P_ESN_OBJID   IN VARCHAR2,
    P_ESN_CONTACT IN VARCHAR2,
    P_ESN_STATUS  IN VARCHAR2)
    IS
      V_MSG     VARCHAR2(100);
      CNT_VMBC  NUMBER;
      CNT       NUMBER;
      CNT_ESN   NUMBER;
      AC_SP_CNT NUMBER;
      ENR_CNT   NUMBER;

      BEGIN

            SELECT COUNT(*)
            INTO ENR_CNT
            FROM X_PROGRAM_ENROLLED WHERE X_ESN=P_ESN;

            IF ENR_CNT>0 THEN

               --- THESE FIXES DO NOT APPLY TO SAFELINK PHONES
               IF IS_SAFELINK(P_ESN)=0 THEN

                IF P_ESN_STATUS='52' THEN --ACTIVE
                      ---------ENROLLED ISSUE----------------------------------
                      COMMON_ENROLLMENT_ISSUES(P_ESN,P_BRAND,P_BUS_ORG,P_ESN_CONTACT);
                      ---------FIX FAMILY-PLAN DE-ENROLLMENT-------------------
                      FAMILY_PLAN_DEENROLL (P_ESN,P_BRAND);
                      ---------------------------------------------------------
                      ----Added "_" to SIMPLE_MOBILE and TOTAL_WIRELESS--icaocabrera
                      IF (P_BRAND  IN ('NET10','STRAIGHT TALK','SIMPLE_MOBILE','TOTAL_WIRELESS') )THEN
                        SELECT COUNT(*)
                        INTO AC_SP_CNT
                        FROM TABLE_SITE_PART
                        WHERE X_SERVICE_ID=P_ESN
                        AND PART_STATUS  IN ('Active');

                        --THERE IS AN ACTIVE SITE PART RECORD, SO CHECK FOR A SERVICE PLAN
                        IF AC_SP_CNT >0 THEN
                          CHECK_SERVICE_PLAN(P_ESN,P_BRAND);
                        END IF;

                      END IF;

                      UPDATE X_PROGRAM_ENROLLED
                      SET PGM_ENROLL2PGM_GROUP                       = NULL,
                        X_ENROLLMENT_STATUS                          = 'READYTOREENROLL',
                        X_NEXT_CHARGE_DATE                           = NULL,
                        X_NEXT_DELIVERY_DATE                         = NULL,
                        X_WAIT_EXP_DATE                              = NULL,
                        X_COOLING_EXP_DATE                           = NULL,
                        X_UPDATE_STAMP                               = SYSDATE,
                        X_EXP_DATE                                   = NULL,
                        X_GRACE_PERIOD                               = NULL,
                        X_COOLING_PERIOD                             = NULL,
                        X_SERVICE_DAYS                               = NULL,
                        X_TOT_GRACE_PERIOD_GIVEN                     = NULL
                      WHERE X_ENROLLMENT_STATUS                      ='DEENROLLED'
                      AND NVL(TRUNC (X_COOLING_EXP_DATE),SYSDATE-7) <= TRUNC (SYSDATE)
                      AND X_ESN                                      =P_ESN
                      AND PGM_ENROLL2PGM_PARAMETER                  IN
                        ( SELECT OBJID FROM X_PROGRAM_PARAMETERS WHERE X_IS_RECURRING=1
                        );
                      IF SQL%ROWCOUNT>0 THEN
                        V_MSG       :='FIXED THE DEENROLLED RECORD IN X_PROGRAM_ENROLLED';
                        LOG_MSG (P_ESN,V_MSG,P_BRAND,'FIX');
                      END IF;
                  ELSE -- NOT ACTIVE
                    FIX_EP_RECORDS_NOT_ACTIVE(P_ESN,P_BRAND);
                END IF;

              END IF;



           END IF; --ENR_CNT>0 (NOT ENROLLED IN ANYTHING

      EXCEPTION
          WHEN OTHERS THEN
            RETURN;
      END;



  /*=======================================================================================
  PROCEDURE: GENERAL_CHECKS
  DETAILS  : SERIES OF FIXES AND CHECKS GROUPED BECAUSE IT GETS CALLED IN DIFFERENT SCENARIOS
  =======================================================================================*/
  PROCEDURE GENERAL_CHECKS(
      ESN           IN VARCHAR2,
      ESN_OBJID     IN NUMBER,
      ESN_STATUS    IN VARCHAR2,
      P_PART_NUMBER IN VARCHAR2,
      ESN_CONTACT   IN VARCHAR2,
      BRAND_IN      IN VARCHAR2,
      P_BUS_ORG     IN NUMBER,
      X_TECHNOLOGY  IN VARCHAR2,
      X_ICCID       IN VARCHAR2,
      X_PORT_IN     IN VARCHAR2,
      ERROR_IN      IN VARCHAR2,
      V_MSG         OUT VARCHAR2)
    IS
      V_MSG_FINAL VARCHAR2(500);
      ENR_CNT     NUMBER;
      P_ACCNT     VARCHAR2(500);
      V_ESN_STATUS VARCHAR2(200);
      V_ICCID     VARCHAR2(200);
    BEGIN
    P_ACCNT:='';
    V_MSG:='';
    V_MSG_FINAL:='';
    V_ESN_STATUS:='';
    V_ICCID:='';


    FIX_MIN(ESN, BRAND_IN, ESN_STATUS, X_ICCID, V_RESULT);
    V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;

    --UPDATING CURSOR VALUES
    SELECT X_PART_INST_STATUS, X_ICCID INTO V_ESN_STATUS, V_ICCID FROM TABLE_PART_INST WHERE PART_SERIAL_NO = ESN;

    IF (RERUN=1) THEN
      GOTO QUICK_EXIT;
    END IF;

    FIX_PORT_IN(ESN, BRAND_IN, X_PORT_IN, V_RESULT);
    V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;

    FIX_REFURBISH(ESN, BRAND_IN, V_ESN_STATUS, V_RESULT);
    V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;



    --UPDATING CURSOR VALUES
    SELECT X_PART_INST_STATUS, X_ICCID INTO V_ESN_STATUS, V_ICCID FROM TABLE_PART_INST WHERE PART_SERIAL_NO = ESN;

    FIX_INCORRECT_SIZE(ESN, BRAND_IN, V_RESULT);
    V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;


    --DBMS_OUTPUT.PUT_LINE('CHECKING SAFELINK...');
    IF IS_SAFELINK(ESN)=0 THEN
    --SAFELINK PHONES SHOULD NOT HAVE THE CONTACT FIXED-------------------------
      --DBMS_OUTPUT.PUT_LINE('NOT A SAFELINK');
      FIX_CONTACT(ESN, BRAND_IN, V_RESULT);
      V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;
    END IF;
   -- DBMS_OUTPUT.PUT_LINE('FINISHED CHECKING SAFELINK...');


    FIX_100(ESN, BRAND_IN, V_RESULT);
    V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;

    FIX_CARD(ESN, BRAND_IN, V_RESULT);
    V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;

    CHECK_OTA(ESN, BRAND_IN, ESN_OBJID, V_RESULT);
    V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;

    FIX_SP_OBS_TIME (ESN,BRAND_IN,V_RESULT);
    V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;

  ----CR54214: Skip updating SP to inactive when obsolete or carrier pending.
   -- FIX_SITE_PART_OBSOLETE (ESN,BRAND_IN,V_RESULT);
   -- V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;

    FIX_SITE_PART_MULTIPLE_ACTIVE(ESN,BRAND_IN,V_RESULT);
    V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;

    FIX_SITE_PART_MOST_RECENT (ESN,BRAND_IN,V_RESULT);
    V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;


    FIX_ACCOUNT (ESN,BRAND_IN,P_BUS_ORG, ESN_OBJID,ESN_CONTACT, P_ACCNT );
    V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;


    FIX_BILLING_ISSUES (ESN, BRAND_IN, P_BUS_ORG, ESN_OBJID, ESN_CONTACT, V_ESN_STATUS);
    V_MSG:=V_MSG_FINAL;


    --IF X_TECHNOLOGY = 'GSM' THEN
      CHECK_SIM(ESN, BRAND_IN, V_ESN_STATUS, V_ICCID, V_RESULT);
      V_MSG:=V_MSG||V_RESULT;
    --END IF;
    --UPDATING CURSOR VALUES
    SELECT X_PART_INST_STATUS, X_ICCID INTO V_ESN_STATUS, V_ICCID FROM TABLE_PART_INST WHERE PART_SERIAL_NO = ESN;


    IF (UPPER(ERROR_IN) LIKE '%LIMITS%' OR UPPER(ERROR_IN) LIKE 'LIMITS%') THEN
      FIX_LIMITS_EXCEEDED(ESN, BRAND_IN, V_RESULT);
      V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;
    END IF;

    --NEW FEATURES
    FIX_GROUPS(ESN, BRAND_IN, V_ESN_STATUS, V_RESULT);
      V_MSG_FINAL:=V_MSG_FINAL||V_RESULT;


    <<QUICK_EXIT>>
    V_MSG := '';

    EXCEPTION
          WHEN OTHERS THEN
            RETURN;
    END;
-------------------------------------------------------------------------------------

/*=======================================================================================
  PROCEDURE: FIX_ESN
  DETAILS  : MAIN 1052 SCRIPT. CALLS ALL FIXES
  =======================================================================================*/
  PROCEDURE FIX_ESN(
    ESN_IN   IN VARCHAR2,
    ERROR_IN IN VARCHAR2,
    BRAND    IN VARCHAR2,
    BRAND_ID IN VARCHAR2,
    STATUS   IN VARCHAR2,
    RESULTS OUT VARCHAR2)
  IS
  BEGIN

     -- START FIXES ------------------------------------------------------------

     -- 01. CHECH FOR A CARRIERPENDING STATUS IN X_SWITCHBASED_TRANSACTION
     CHECK_SWITCHBASE(ESN_IN, BRAND, V_RESULT);
     RESULTS:= RESULTS || V_RESULT;


    -- GET THE PART_INST CURSOR FOR THE ESN, START WITH THOSE FIXES.
      FOR I IN C_PART_INST(ESN_IN)
          LOOP
          BEGIN
              CASE
                 WHEN V_STATUS IN ('51','54','50','150') THEN
                    -- USED, PASTDUE,NEW,REFURBISHED
                    --LOG_MSG(ESN_IN,'PROCESSING USED,PASTDUE,NEW,REFURBISHED...',BRAND,'LOG');
                    CHECK_LINE_NOT_ACTIVE_ESN(ESN_IN, BRAND, STATUS, V_RESULT);
                    RESULTS:= RESULTS || V_RESULT;



                    GENERAL_CHECKS(ESN_IN, I.OBJID, I.X_PART_INST_STATUS, I.PART_NUMBER, I.CONTACT, BRAND, I.BUS_ORG, I.X_TECHNOLOGY, I.X_ICCID, I.X_PORT_IN, ERROR_IN, V_RESULT);
                    RESULTS:= RESULTS || V_RESULT;


                 WHEN V_STATUS ='59' THEN
                  RAISE INACTIVE_PHONE;
                 WHEN V_STATUS = '53' THEN
                  RAISE STOLEN_PHONE;
                 WHEN V_STATUS = '56' THEN
                  RAISE RISK_PHONE;
                 WHEN V_STATUS = '52' THEN
                    -- ACTIVE WITH ISSUES

                    CHECK_LINE_NOT_ACTIVE_ESN(ESN_IN,BRAND,STATUS, V_RESULT);
                    RESULTS:= RESULTS || V_RESULT;
                   -- LOG_MSG(ESN_IN,'PHONE IS ACTIVE',BRAND,'LOG');


                    -- CHECK IF ACTIVE PHONE FOR IF LINES ARE ATTACHED
                    CHECK_ATTACHED_LINES(ESN_IN,BRAND,V_RESULT);
                    IF(V_RESULT='MULTI_PHONE') THEN
                      RAISE MULTI_PHONE;
                    END IF;

                    -- A WRAPPER FOR MULTIPLE COMMON CHECKS
                    GENERAL_CHECKS(ESN_IN, I.OBJID, I.X_PART_INST_STATUS, I.PART_NUMBER, I.CONTACT, BRAND ,I.BUS_ORG, I.X_TECHNOLOGY,  I.X_ICCID,I.X_PORT_IN, ERROR_IN, V_RESULT);
                    RESULTS:= RESULTS || V_RESULT;

                    --UNIQUE TO ACTIVE LINES
                    FIX_ACTIVE_LINE(ESN_IN, BRAND, V_RESULT);
                    RESULTS:= RESULTS || V_RESULT;

                 ELSE
                 NULL;
              END CASE;

          END;
          END LOOP;

    --LOG_MSG(ESN_IN,'CURRENT STATUS IS: ' || STATUS, BRAND,'LOG');
    RESULTS := '1052 COMPLETED FOR ' || ESN_IN;

  EXCEPTION
  WHEN INACTIVE_PHONE THEN
    RESULTS := 'ESN is in INACTIVE Status';
    LOG_MSG(ESN_IN, RESULTS,BRAND, 'LOG');

  WHEN STOLEN_PHONE THEN
    RESULTS := 'ESN is in STOLEN STATUS';
    LOG_MSG(ESN_IN, RESULTS,BRAND, 'LOG');

  WHEN RISK_PHONE THEN
    RESULTS := 'ESN is under RISK ASSESSMENT';
    LOG_MSG(ESN_IN, RESULTS,BRAND, 'LOG');

  WHEN MULTI_PHONE THEN
    RESULTS := 'MIN is ACTIVE with more than one ESN';--||V_MULTI_MSG;
    LOG_MSG(ESN_IN, RESULTS, BRAND, 'LOG');

  WHEN NO_DATA_FOUND THEN
    RESULTS:='Please open a IT TOSS/SYSTEM ERRORS Case';
    LOG_MSG(ESN_IN, RESULTS,BRAND, 'LOG');

  END;


/*=======================================================================================
  PROCEDURE: CALL_1052
  DETAILS  : MAIN 1052 SCRIPT. CALLS ALL FIXES. VIA THE BUTTON
  =======================================================================================*/

  PROCEDURE CALL_1052(
      ESN       IN VARCHAR2,
      ERROR     IN VARCHAR2 ,
      IP_USER   IN VARCHAR2,
      RESULT  OUT VARCHAR2)
  IS

  -- 1. SET THE LOGGED IN USER ---------------------------------------------


  BEGIN
      G_IP_USER :=IP_USER;

      BEGIN
          -- PRECHECKS -------------------------------------------------------------
          V_EXISTS  :=0;
          RESULT  :='';
          RERUN     :=0;
          -- 2. DOES IT EXIST IN OUR SYSTEM ----------------------------------------

          SELECT COUNT(1) INTO V_EXISTS FROM TABLE_PART_INST WHERE PART_SERIAL_NO = ESN AND X_DOMAIN ='PHONES';
          IF V_EXISTS = 0 THEN
            LOG_MSG(ESN,ERROR,NULL,'Error');
            RESULT := 'ESN IS NOT FOUND IN THE SYSTEM'; -- <-- REMEMBER THIS IS THROWN BACK OUT TO THE USER
            LOG_MSG(ESN,RESULT,NULL,'NA Brand');
            RAISE MESSAGE_EXCEP;
          END IF;




          -- 3. GET THE BRAND ----------------------------------------

          V_BRAND :='';
          V_BRANDID:='';
          V_STATUS:='';

          ---Added WFM --icaocabrera
          SELECT DECODE( PN.PART_NUM2BUS_ORG, 536876745, 'STRAIGHT TALK', 268438257, 'TRACFONE', 268438258, 'NET10', 536876746, 'GENERIC', 536876747, 'SIMPLE_MOBILE',268448087,'TOTAL_WIRELESS',536884081,'WFM','OTHER') BRAND,
          PN.PART_NUM2BUS_ORG, PI.X_PART_INST_STATUS
          INTO V_BRAND, V_BRANDID, V_STATUS
          FROM TABLE_PART_INST PI,
            TABLE_MOD_LEVEL ML,
            TABLE_PART_NUM PN
          WHERE PI.PART_SERIAL_NO     = ESN
          AND PI.X_DOMAIN             ='PHONES'
          AND PI.N_PART_INST2PART_MOD = ML.OBJID
          AND ML.PART_INFO2PART_NUM   = PN.OBJID;

          ---Added for CR50339 skip WFM.--icaocabrera
          IF (V_BRAND='WFM') THEN
            RAISE WFM_NOT_SUPPORTED;
			---Added for CO skip SIMPLE_MOBILE.--icaocabrera
		  ELSIF (V_BRAND='SIMPLE_MOBILE') THEN
            RAISE SM_NOT_SUPPORTED;
          END IF;

          -- OUR FIRST LOG INDICATING THE ERROR AND BRAND OF THE ESN--------
          LOG_MSG(ESN,ERROR,V_BRAND,'Error');
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            LOG_MSG(ESN,ERROR,NULL,'Error');
            RESULT := 'Please open a System Error case for IT TOSS and specify ''CHECK THE BRAND''.';
            LOG_MSG(ESN,RESULT,NULL,'LOG');
            RAISE MESSAGE_EXCEP;

          -----Exception added for CR50339 skip WFM.--icaocabrera
          WHEN WFM_NOT_SUPPORTED then
            RESULT := 'WFM Brand is not supported ''CHECK THE BRAND''.';
            LOG_MSG(ESN,RESULT,NULL,'LOG');
            RAISE MESSAGE_EXCEP;

   		-----Exception added for CO skip SIMPLE_MOBILE.--icaocabrera
		 WHEN SM_NOT_SUPPORTED then
           RESULT := 'SIMPLE_MOBILE and GO_SMART Brand/sub-brand are not supported ''CHECK THE BRAND''.';
            LOG_MSG(ESN,RESULT,NULL,'LOG');
            RAISE MESSAGE_EXCEP;

      END;


      -- 4. CHECK IF THERE IS AN EXISTING PORT IN CASE -------------------------
      --    1052 DOES NOT RUN ON ANY ESN WITH AN OPEN PORT IN CASE -------------
      --------------------------------------------------------------------------
      BEGIN
        V_CASE_EXIST:=0;
        SELECT COUNT(1)
        INTO V_CASE_EXIST
        FROM TABLE_CASE C,
          TABLE_CONDITION CA
        WHERE 1                    = 1
        AND (CA.CONDITION         IN (10, 536870920, 2)) --'OPEN-DISPATCH', 'OPEN ACTION ITEM-DISPATCH', 'OPEN'
        AND C.CASE_STATE2CONDITION = CA.OBJID
        AND UPPER(C.X_CASE_TYPE)   = 'PORT IN'
        AND C.X_ESN                = ESN;
        IF V_CASE_EXIST           <> 0 THEN
          RESULT                  := 'ESN has an open PORT IN case';
          LOG_MSG(ESN,RESULT,V_BRAND, 'NA Port');
          RAISE MESSAGE_EXCEP;
        END IF;
      END;


      -- 5. CHECK IF IT IS A VALID CARRIER PENDING -------------------------------------
      BEGIN
        INT_RESULT:=0;
        CHECK_CARRIER_PENDING(ESN,INT_RESULT);
        IF INT_RESULT > 0 THEN
          RAISE MESSAGE_EXCEP;
        END IF;
      END;

      -- 6. CHECK IF IT IS  IN A CARCONNECTION SERVICE PLAN -------------------------------------
      SELECT COUNT(1) INTO V_EXISTS FROM X_SERVICE_PLAN_SITE_PART SPSP, TABLE_SITE_PART SP
      WHERE
      SP.OBJID = SPSP.TABLE_SITE_PART_ID
      AND SP.X_SERVICE_ID = ESN
      AND SPSP.X_SERVICE_PLAN_ID IN ( SELECT SERVICE_PLAN_OBJID FROM sa.SERVICE_PLAN_FEAT_PIVOT_MV WHERE DEVICE_GROUP_TYPE = 'CARCONNECTION');
      IF V_EXISTS >0 THEN
        LOG_MSG(ESN,ERROR,NULL,'Error');
        RESULT := 'CARCONNECTION SERVICE PLANS ARE NOT SUPPORTED BY 1052'; -- <-- REMEMBER THIS IS THROWN BACK OUT TO THE USER
        LOG_MSG(ESN,RESULT,NULL,'NA Brand');
        RAISE MESSAGE_EXCEP;
      END IF;


      -- MAIN EXECUTION --------------------------------------------------------
      <<RUN_FIX_ESN>>
      FIX_ESN(ESN, ERROR, V_BRAND, V_BRANDID, V_STATUS, RESULT);
       IF(RERUN>0 AND TOTAL_RERUNS < 3) THEN
        RERUN:=0;
        TOTAL_RERUNS:=TOTAL_RERUNS+1;
        --DBMS_OUTPUT.put_line('reruns at :' || TOTAL_RERUNS || ' for esn:' || ESN);
        GOTO RUN_FIX_ESN;
       END IF;

      LOG_MSG(ESN,RESULT,V_BRAND,'LOG');

      CASE RESULT
      WHEN 'ESN is in STOLEN STATUS' THEN
        RAISE STOLEN_PHONE;
      WHEN 'ESN is under RISK ASSESSMENT' THEN
        RAISE RISK_PHONE;
      WHEN 'MIN is ACTIVE with more than one ESN' THEN
        RAISE MULTI_PHONE;
      ELSE
        RESULT:= 'The error has been fixed, please try the transaction again';
        CREATE_INTERACTION (ESN, ERROR, 'Successful');
      END CASE;


  EXCEPTION
    WHEN MESSAGE_EXCEP THEN
      NULL;
    WHEN NO_DATA_FOUND THEN
      RESULT :='Please open a System Error case for IT TOSS ';
      LOG_MSG(ESN,RESULT,NULL,'LOG');
      CREATE_INTERACTION (ESN, ERROR, 'Unsuccessful');
    WHEN STOLEN_PHONE THEN
      RESULT := 'ESN is in STOLEN STATUS';
      LOG_MSG(ESN_IN, RESULT,V_BRAND, 'LOG');
      CREATE_INTERACTION (ESN, ERROR, 'Unsuccessful');
    WHEN RISK_PHONE THEN
      RESULT := 'ESN is under RISK ASSESSMENT';
      LOG_MSG(ESN_IN, RESULT,V_BRAND, 'LOG');
      CREATE_INTERACTION (ESN, ERROR, 'Unsuccessful');
    WHEN MULTI_PHONE THEN
      RESULT := 'MIN is ACTIVE with more than one ESN';
      LOG_MSG(ESN_IN, RESULT,V_BRAND, 'LOG');
      CREATE_INTERACTION (ESN, ERROR, 'Unsuccessful');
    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SUBSTR(SQLERRM, 1, 100);
      RESULT :='Please open a System Error case for IT TOSS ' || err_msg ;
      LOG_MSG(ESN,RESULT,NULL,'LOG');
      CREATE_INTERACTION (ESN, ERROR, 'Unsuccessful');

  END;



  /*=======================================================================================
  PROCEDURE: CALL_1052
  DETAILS  : MAIN 1052 SCRIPT. CALLS ALL FIXES. VIA THE SCRIPT
  =======================================================================================*/

  PROCEDURE CALL_1052(
      ESN       IN VARCHAR2,
      ERROR     IN VARCHAR2 ,
      IP_USER   IN VARCHAR2,
      IS_SCRIPT IN BOOLEAN,
      RESULT  OUT VARCHAR2)
  IS

  -- 1. SET THE LOGGED IN USER ---------------------------------------------


  BEGIN
      G_IP_USER :=IP_USER;

      BEGIN
          -- PRECHECKS -------------------------------------------------------------
          V_EXISTS  :=0;
          RESULT  :='';
          RERUN     :=0;
          -- 2. DOES IT EXIST IN OUR SYSTEM ----------------------------------------

          SELECT COUNT(1) INTO V_EXISTS FROM TABLE_PART_INST WHERE PART_SERIAL_NO = ESN AND X_DOMAIN ='PHONES';
          IF V_EXISTS = 0 THEN
            LOG_MSG(ESN,ERROR,NULL,'Error');
            RESULT := 'ESN IS NOT FOUND IN THE SYSTEM'; -- <-- REMEMBER THIS IS THROWN BACK OUT TO THE USER
            LOG_MSG(ESN,RESULT,NULL,'NA Brand');
            RAISE MESSAGE_EXCEP;
          END IF;




          -- 3. GET THE BRAND ----------------------------------------

          V_BRAND :='';
          V_BRANDID:='';
          V_STATUS:='';

          ----Added WFM --icaocabrera
          SELECT DECODE( PN.PART_NUM2BUS_ORG, 536876745, 'STRAIGHT TALK', 268438257, 'TRACFONE', 268438258, 'NET10', 536876746, 'GENERIC', 536876747, 'SIMPLE_MOBILE',268448087,'TOTAL_WIRELESS', 536884081,'WFM','OTHER') BRAND,
          PN.PART_NUM2BUS_ORG, PI.X_PART_INST_STATUS
          INTO V_BRAND, V_BRANDID, V_STATUS
          FROM TABLE_PART_INST PI,
            TABLE_MOD_LEVEL ML,
            TABLE_PART_NUM PN
          WHERE PI.PART_SERIAL_NO     = ESN
          AND PI.X_DOMAIN             ='PHONES'
          AND PI.N_PART_INST2PART_MOD = ML.OBJID
          AND ML.PART_INFO2PART_NUM   = PN.OBJID;


		  ---Added for CR50339 skip WFM.--icaocabrera
          IF (V_BRAND='WFM') THEN
            RAISE WFM_NOT_SUPPORTED;
			---Added for CO skip SIMPLE_MOBILE.--icaocabrera
		  ELSIF (V_BRAND='SIMPLE_MOBILE') THEN
            RAISE SM_NOT_SUPPORTED;
          END IF;

          -- OUR FIRST LOG INDICATING THE ERROR AND BRAND OF THE ESN--------
          LOG_MSG(ESN,ERROR,V_BRAND,'Error');
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            LOG_MSG(ESN,ERROR,NULL,'Error');
            RESULT := 'Please open a System Error case for IT TOSS and specify ''CHECK THE BRAND''.';
            LOG_MSG(ESN,RESULT,NULL,'LOG');
            RAISE MESSAGE_EXCEP;

         ----Exception added for CR50339 skip WFM.--icaocabrera
         WHEN WFM_NOT_SUPPORTED then
            RESULT := 'WFM Brand is not supported ''CHECK THE BRAND''.';
            LOG_MSG(ESN,RESULT,NULL,'LOG');
            RAISE MESSAGE_EXCEP;

		-----Exception added for CO skip SIMPLE_MOBILE.--icaocabrera
		 WHEN SM_NOT_SUPPORTED then
            RESULT := 'SIMPLE_MOBILE and GO_SMART Brand/sub-brand are not supported ''CHECK THE BRAND''.';
            LOG_MSG(ESN,RESULT,NULL,'LOG');
            RAISE MESSAGE_EXCEP;

      END;


      -- 4. CHECK IF THERE IS AN EXISTING PORT IN CASE -------------------------
      --    1052 DOES NOT RUN ON ANY ESN WITH AN OPEN PORT IN CASE -------------
      --------------------------------------------------------------------------
      BEGIN
        V_CASE_EXIST:=0;
        SELECT COUNT(1)
        INTO V_CASE_EXIST
        FROM TABLE_CASE C,
          TABLE_CONDITION CA
        WHERE 1                    = 1
        AND (CA.CONDITION         IN (10, 536870920, 2)) --'OPEN-DISPATCH', 'OPEN ACTION ITEM-DISPATCH', 'OPEN'
        AND C.CASE_STATE2CONDITION = CA.OBJID
        AND UPPER(C.X_CASE_TYPE)   = 'PORT IN'
        AND C.X_ESN                = ESN;
        IF V_CASE_EXIST           <> 0 THEN
          RESULT                  := 'ESN has an open PORT IN case';
          LOG_MSG(ESN,RESULT,V_BRAND, 'NA Port');
          RAISE MESSAGE_EXCEP;
        END IF;
      END;


      -- 5. CHECK IF IT IS A VALID CARRIER PENDING -------------------------------------
      BEGIN
        INT_RESULT:=0;
        CHECK_CARRIER_PENDING(ESN,INT_RESULT);
        IF INT_RESULT > 0 THEN
          RAISE MESSAGE_EXCEP;
        END IF;
      END;

      -- 6. CHECK IF IT IS  IN A CARCONNECTION SERVICE PLAN -------------------------------------
      SELECT COUNT(1) INTO V_EXISTS FROM X_SERVICE_PLAN_SITE_PART SPSP, TABLE_SITE_PART SP
      WHERE
      SP.OBJID = SPSP.TABLE_SITE_PART_ID
      AND SP.X_SERVICE_ID = ESN
      AND SPSP.X_SERVICE_PLAN_ID IN ( SELECT SERVICE_PLAN_OBJID FROM sa.SERVICE_PLAN_FEAT_PIVOT_MV WHERE DEVICE_GROUP_TYPE = 'CARCONNECTION');
      IF V_EXISTS >0 THEN
        LOG_MSG(ESN,ERROR,NULL,'Error');
        RESULT := 'CARCONNECTION SERVICE PLANS ARE NOT SUPPORTED BY 1052'; -- <-- REMEMBER THIS IS THROWN BACK OUT TO THE USER
        LOG_MSG(ESN,RESULT,NULL,'NA Brand');
        RAISE MESSAGE_EXCEP;
      END IF;


      -- MAIN EXECUTION --------------------------------------------------------
      <<RUN_FIX_ESN>>
      FIX_ESN(ESN, ERROR, V_BRAND, V_BRANDID, V_STATUS, RESULT);
       IF(RERUN>0 AND TOTAL_RERUNS < 3) THEN
        RERUN:=0;
        TOTAL_RERUNS:=TOTAL_RERUNS+1;
        --DBMS_OUTPUT.put_line('No Of Reruns :' || TOTAL_RERUNS || ' for esn:' || ESN);
        GOTO RUN_FIX_ESN;
       END IF;

      LOG_MSG(ESN,RESULT,V_BRAND,'LOG');

  EXCEPTION
    WHEN MESSAGE_EXCEP THEN
      NULL;
    WHEN NO_DATA_FOUND THEN
      RESULT :='Please open a System Error case for IT TOSS ';
      LOG_MSG(ESN,RESULT,NULL,'LOG');
    WHEN OTHERS THEN
    err_num := SQLCODE;
    err_msg := SUBSTR(SQLERRM, 1, 100);
      RESULT :='Please open a System Error case for IT TOSS ' || err_msg ;
      DBMS_OUTPUT.put_line (DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      LOG_MSG(ESN,RESULT,NULL,'LOG');

  END;

END;
/