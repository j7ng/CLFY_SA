CREATE OR REPLACE PACKAGE BODY sa.BILLING_BUNDLE_PKG
IS
  GLOBAL_ERROR_MESSAGE VARCHAR2(300);
  -- Get Web obj id associated to ESN
  CURSOR WEBXESN_CUR (P_ESN sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE)
  IS
    SELECT WEB.OBJID
    FROM sa.TABLE_PART_INST PI,
      sa.TABLE_X_CONTACT_PART_INST CPI ,
      sa.TABLE_WEB_USER WEB
    WHERE PI.PART_SERIAL_NO             = P_ESN
    AND PI.OBJID                        = CPI.X_CONTACT_PART_INST2PART_INST
    AND CPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT;
  -- List of all ESNs in a web account
  CURSOR ESNSXACC_CUR (P_WEB_OBJID sa.TABLE_WEB_USER.OBJID%TYPE)
  IS
    SELECT PI.PART_SERIAL_NO
    FROM sa.TABLE_PART_INST PI,
      sa.TABLE_X_CONTACT_PART_INST CPI ,
      sa.TABLE_WEB_USER WEB
    WHERE WEB.OBJID                     = P_WEB_OBJID
    AND PI.OBJID                        = CPI.X_CONTACT_PART_INST2PART_INST
    AND CPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT ;
  -- Check if ESN is enrolled into billing program provided
  CURSOR ESNXPROGRAM_CUR( P_ESN sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE , P_ELIG_PROG_ARRAY sa.TYP_VARCHAR2_ARRAY)
  IS
    SELECT PI.PART_SERIAL_NO ,
      PE.OBJID                  AS PROG_ENROLLED_OBJID ,
      PE.X_NEXT_CHARGE_DATE     AS X_NEXT_CHARGE_DATE ,
      PE.X_CHARGE_TYPE          AS X_CHARGE_TYPE ,
      PE.PGM_ENROLL2PROG_HDR    AS X_PRIMARY_PROG_ENROLL_OBJID ,
      PP.OBJID                  AS X_PROGRAM_PARAM_OBJID ,
      PP.X_PROGRAM_NAME         AS X_PROGRAM_NAME ,
      PE.PGM_ENROLL2X_PROMOTION AS X_PROMOTION_OBJID
    FROM sa.X_PROGRAM_PARAMETERS PP,
      sa.X_PROGRAM_ENROLLED PE,
      sa.TABLE_PART_INST PI
    WHERE PP.OBJID                         = PE.PGM_ENROLL2PGM_PARAMETER
    AND PE.X_ESN                           = P_ESN
    AND PE.X_ESN                           = PI.PART_SERIAL_NO
    AND PI.X_PART_INST_STATUS              = '52'
    AND PI.X_DOMAIN                        = 'PHONES'
    AND NVL(PE.X_ENROLLMENT_STATUS,'NULL') = 'ENROLLED'
    AND PP.X_PROGRAM_NAME                 IN
      (SELECT * FROM TABLE(P_ELIG_PROG_ARRAY)
      );
  -- Check if ESN is enrolled in promotion provided
  CURSOR ENROLLED_PROMO_CUR( P_ESN sa.X_ENROLL_PROMO_GRP2ESN.X_ESN%TYPE , P_PROMO_OBJID sa.TABLE_X_PROMOTION.OBJID%TYPE)
  IS
    SELECT PR.X_SCRIPT_ID,
      P.X_PROMO_CODE,
      GRP2ESN.*
    FROM sa.X_ENROLL_PROMO_GRP2ESN GRP2ESN ,
      sa.TABLE_X_PROMOTION P ,
      sa.X_ENROLL_PROMO_RULE PR ,
      sa.TABLE_BUS_ORG BO
    WHERE 1           = 1
    AND GRP2ESN.X_ESN = P_ESN
    AND SYSDATE BETWEEN GRP2ESN.X_START_DATE AND NVL(GRP2ESN.X_END_DATE, SYSDATE + 1)
    AND EXISTS
      (SELECT PE.X_ENROLLMENT_STATUS
      FROM sa.X_PROGRAM_ENROLLED PE
      WHERE PE.OBJID                         = GRP2ESN.PROGRAM_ENROLLED_OBJID
      AND PE.X_ESN                           = P_ESN
      AND NVL(PE.X_ENROLLMENT_STATUS,'NULL') = 'ENROLLED'
      )
  AND P.OBJID = GRP2ESN.PROMO_OBJID
  AND SYSDATE BETWEEN P.X_START_DATE AND P.X_END_DATE
  AND PR.PROMO_OBJID = GRP2ESN.PROMO_OBJID
  AND BO.OBJID       = P.PROMOTION2BUS_ORG
  AND P.OBJID        = P_PROMO_OBJID
  ORDER BY PR.X_PRIORITY;
  --For a given ESN, get if any ESN (in same web account) is eligible in given program list
  -- for this promotion.
  CURSOR ELIGIBLE_ENROLLED_ESN_CUR( P_ESN sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE , P_WEB_OBJID sa.TABLE_WEB_USER.OBJID%TYPE , P_ELIG_PROG_ARRAY sa.TYP_VARCHAR2_ARRAY)
  IS
    SELECT *
    FROM
      (SELECT PI.PART_SERIAL_NO --X_ESN
        ,
        PE.OBJID AS PROG_ENROLLED_OBJID --X_PROG_ENROLLED_OBJID
        ,
        PE.X_NEXT_CHARGE_DATE
      FROM sa.X_PROGRAM_PARAMETERS PP,
        sa.X_PROGRAM_ENROLLED PE,
        sa.TABLE_PART_INST PI
      WHERE PP.OBJID = PE.PGM_ENROLL2PGM_PARAMETER
      AND PE.X_ESN  IN
        (SELECT PI.PART_SERIAL_NO
        FROM sa.TABLE_PART_INST PI,
          sa.TABLE_X_CONTACT_PART_INST CPI ,
          sa.TABLE_WEB_USER WEB
        WHERE WEB.OBJID                     = P_WEB_OBJID
        AND PI.OBJID                        = CPI.X_CONTACT_PART_INST2PART_INST
        AND CPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT
        AND PI.PART_SERIAL_NO              != P_ESN
        )
    AND PE.X_ESN                           = PI.PART_SERIAL_NO
    AND PI.X_PART_INST_STATUS              = '52'
    AND PI.X_DOMAIN                        = 'PHONES'
    AND NVL(PE.X_ENROLLMENT_STATUS,'NULL') = 'ENROLLED'
    AND PP.X_PROGRAM_NAME                 IN
      (SELECT * FROM TABLE(P_ELIG_PROG_ARRAY)
      )
    ORDER BY X_NEXT_CHARGE_DATE ASC
      )
    WHERE ROWNUM = 1;
    /***************************************************************************************************************
    Program Name       :   SP_GET_WEBACCT_INFO
    Program Type       :   Procedure
    Program Arguments  :   IP_ESN
    IP_ELIG_PROG1_ARRAY
    IP_ELIG_PROG2_ARRAY
    Returns            :   OP_PROG1_ESN_INFO_TAB
    OP_PROG2_ESN_INFO_TAB
    OP_BUNDLE_PROMO_ELIGIBLE
    OP_ERROR_CODE
    OP_ERROR_MSG
    Program Called     :   SA.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE
    Description        :   This procedure will get information related to all ESNs in the web account,
    associated to the input ESN. We will know, ESNs which are enrolled into
    billing programs being provided and if input ESN is eligible for bundle promotion.
    Modified By            Modification     CR             Description
    Date           Number
    =============          ============     ======      ===================================
    Jai Arza       07/06/2015     34962          Initial Creation
    ***************************************************************************************************************/
  PROCEDURE SP_GET_WEBACCT_INFO(
      IP_ESN              IN sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE ,
      IP_ELIG_PROG1_ARRAY IN sa.TYP_VARCHAR2_ARRAY ,
      IP_ELIG_PROG2_ARRAY IN sa.TYP_VARCHAR2_ARRAY ,
      OP_PROG1_ESN_INFO_TAB OUT sa.TYP_ESN_INFO_TABLE ,
      OP_PROG2_ESN_INFO_TAB OUT sa.TYP_ESN_INFO_TABLE ,
      OP_BUNDLE_PROMO_ELIGIBLE OUT NUMBER ,
      OP_ERROR_CODE OUT NUMBER ,
      OP_ERROR_MSG OUT VARCHAR2)
  AS
    LV_IS_BUNDLE_PROMO PLS_INTEGER := 0;
    WEBXESN_REC WEBXESN_CUR%ROWTYPE;
    ESNXPROGRAM_REC1 ESNXPROGRAM_CUR%ROWTYPE;
    ESNXPROGRAM_REC2 ESNXPROGRAM_CUR%ROWTYPE;
    ENROLLED_PROMO_REC ENROLLED_PROMO_CUR%ROWTYPE;
    LV_PROG_ENROLL_COUNT PLS_INTEGER  := 0;
    LV_PROMO_ENROLL_COUNT PLS_INTEGER := 0;
  BEGIN
    DBMS_OUTPUT.PUT_LINE( 'Start of SP_GET_WEBACCT_INFO for IP_ESN: '||IP_ESN);
    OP_PROG1_ESN_INFO_TAB    := sa.TYP_ESN_INFO_TABLE();
    OP_PROG2_ESN_INFO_TAB    := sa.TYP_ESN_INFO_TABLE();
    OP_BUNDLE_PROMO_ELIGIBLE := 0;
    OP_ERROR_CODE            := 0;
    OP_ERROR_MSG             := 'Success';
    LV_PROG_ENROLL_COUNT     := 0;
    LV_PROMO_ENROLL_COUNT    := 0;
    OPEN WEBXESN_CUR(IP_ESN);
    FETCH WEBXESN_CUR
    INTO WEBXESN_REC;
    -- check web objid for account
    IF WEBXESN_CUR%NOTFOUND THEN
      CLOSE WEBXESN_CUR;
      OP_ERROR_CODE := 1;
      OP_ERROR_MSG  := 'Failure. No web account found for this ESN';
      DBMS_OUTPUT.PUT_LINE( 'Do not have Web account');
      RETURN;
    ELSE
      DBMS_OUTPUT.PUT_LINE( 'Web account exist for ESN provided:'||WEBXESN_REC.OBJID);
      CLOSE WEBXESN_CUR;
      --Check list of ESNs associated to this web account
      FOR ESNSXACC_REC IN
      (SELECT PI.PART_SERIAL_NO
      FROM sa.TABLE_PART_INST PI,
        sa.TABLE_X_CONTACT_PART_INST CPI ,
        sa.TABLE_WEB_USER WEB
      WHERE WEB.OBJID                     = WEBXESN_REC.OBJID
      AND PI.OBJID                        = CPI.X_CONTACT_PART_INST2PART_INST
      AND CPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT
      )
      LOOP
        DBMS_OUTPUT.PUT_LINE( 'Processing ESN:'||ESNSXACC_REC.PART_SERIAL_NO);
        DBMS_OUTPUT.PUT_LINE( 'Start - Checking if this ESN exist in program1 list');
        -- Check if this esn is enrolled in program 1
        OPEN ESNXPROGRAM_CUR(ESNSXACC_REC.PART_SERIAL_NO, IP_ELIG_PROG1_ARRAY);
        FETCH ESNXPROGRAM_CUR INTO ESNXPROGRAM_REC1;
        IF ESNXPROGRAM_CUR%FOUND THEN
          --Get number of ESNs enrolled into this program from this web account
          LV_PROG_ENROLL_COUNT := LV_PROG_ENROLL_COUNT + 1;
          DBMS_OUTPUT.PUT_LINE( 'ESN which is enrolled into '||ESNXPROGRAM_REC1.X_PROGRAM_NAME||' is '||ESNSXACC_REC.PART_SERIAL_NO);
          OP_PROG1_ESN_INFO_TAB.EXTEND();
          OP_PROG1_ESN_INFO_TAB(OP_PROG1_ESN_INFO_TAB.LAST) := TYP_ESN_INFO_OBJ ( ESNSXACC_REC.PART_SERIAL_NO , WEBXESN_REC.OBJID , ESNXPROGRAM_REC1.PROG_ENROLLED_OBJID , ESNXPROGRAM_REC1.X_PRIMARY_PROG_ENROLL_OBJID , ESNXPROGRAM_REC1.X_PROGRAM_PARAM_OBJID , ESNXPROGRAM_REC1.X_PROGRAM_NAME , ESNXPROGRAM_REC1.X_PROMOTION_OBJID , ESNXPROGRAM_REC1.X_NEXT_CHARGE_DATE , ESNXPROGRAM_REC1.X_CHARGE_TYPE );
        ELSIF ESNXPROGRAM_CUR%NOTFOUND THEN
          DBMS_OUTPUT.PUT_LINE( 'ESN :'||ESNSXACC_REC.PART_SERIAL_NO||' is not enrolled into program1 list');
        END IF;
        CLOSE ESNXPROGRAM_CUR;
        DBMS_OUTPUT.PUT_LINE( 'End - Checking if this ESN exist in program1 list');
        DBMS_OUTPUT.PUT_LINE( 'Start - Checking if this ESN exist in program2 list');
        -- Check if this ESN is enrolled into program 2.
        OPEN ESNXPROGRAM_CUR(ESNSXACC_REC.PART_SERIAL_NO, IP_ELIG_PROG2_ARRAY);
        FETCH ESNXPROGRAM_CUR INTO ESNXPROGRAM_REC2;
        IF ESNXPROGRAM_CUR%FOUND THEN
          --Get number of ESNs enrolled into this program from this web account
          LV_PROMO_ENROLL_COUNT := LV_PROMO_ENROLL_COUNT+1;
          DBMS_OUTPUT.PUT_LINE( 'ESN which is enrolled into '||ESNXPROGRAM_REC2.X_PROGRAM_NAME||' is '||ESNSXACC_REC.PART_SERIAL_NO);
          OP_PROG2_ESN_INFO_TAB.EXTEND();
          OP_PROG2_ESN_INFO_TAB(OP_PROG2_ESN_INFO_TAB.LAST):= TYP_ESN_INFO_OBJ ( ESNSXACC_REC.PART_SERIAL_NO , WEBXESN_REC.OBJID , ESNXPROGRAM_REC2.PROG_ENROLLED_OBJID , ESNXPROGRAM_REC2.X_PRIMARY_PROG_ENROLL_OBJID , ESNXPROGRAM_REC2.X_PROGRAM_PARAM_OBJID , ESNXPROGRAM_REC2.X_PROGRAM_NAME , ESNXPROGRAM_REC2.X_PROMOTION_OBJID , ESNXPROGRAM_REC2.X_NEXT_CHARGE_DATE , ESNXPROGRAM_REC2.X_CHARGE_TYPE );
        ELSIF ESNXPROGRAM_CUR%NOTFOUND THEN
          DBMS_OUTPUT.PUT_LINE( 'ESN :'||ESNSXACC_REC.PART_SERIAL_NO||' is not enrolled into program2 list');
        END IF;
        CLOSE ESNXPROGRAM_CUR;
        DBMS_OUTPUT.PUT_LINE( 'End - Checking if this ESN exist in program2 list');
      END LOOP;
      DBMS_OUTPUT.PUT_LINE( 'LV_PROG_ENROLL_COUNT: '||LV_PROG_ENROLL_COUNT);
      DBMS_OUTPUT.PUT_LINE( 'LV_PROMO_ENROLL_COUNT: '||LV_PROMO_ENROLL_COUNT);
      IF LV_PROG_ENROLL_COUNT > LV_PROMO_ENROLL_COUNT THEN
        --We can give promotion to this ESN, as all conditions got satisfied
        OP_BUNDLE_PROMO_ELIGIBLE := 1;
      ELSE
        OP_BUNDLE_PROMO_ELIGIBLE := 0;
      END IF;
    END IF;
    DBMS_OUTPUT.PUT_LINE( 'End of SP_GET_WEBACCT_INFO');
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ( 'Error while getting web account info for :'||IP_ESN,                                          --p_action
    SYSDATE,                                                                                                                                --p_error_date
    IP_ESN,                                                                                                                                 --p_key
    'SA.BILLING_BUNDLE_PKG.SP_GET_WEBACCT_INFO',                                                                                            --p_program_name
    'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
    );
    OP_ERROR_CODE := 1;
    OP_ERROR_MSG  := 'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
    RAISE;
  END SP_GET_WEBACCT_INFO ;
  /***************************************************************************************************************
  Program Name       :   FN_CHECK_ST_BUNDLE_FAMILY
  Program Type       :   Function
  Program Arguments  :   IP_ESN
  IP_PROMO_OBJID
  Returns            :   Number
  Program Called     :   SA.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE
  Description        :   This function will let us know, if a bundle promotion can be given or not.
  We check if at-least one ESN in this web account is enrolled into
  parent programs for this promotion.
  --  Ex: return 0 if there is no ESN enrolled into ST unlimited plans (or) have already utilized this promo before
  --  Ex: return 1 if we found an ESN in the same web account enrolled into ST unlimited plans
  Modified By            Modification     CR             Description
  Date           Number
  =============          ============     ======      ===================================
  Jai Arza        07/06/2015     34962          Initial Creation
  ***************************************************************************************************************/
  FUNCTION FN_CHECK_ST_BUNDLE_FAMILY(
      IP_ESN         IN sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE ,
      IP_PROMO_OBJID IN sa.TABLE_X_PROMOTION.OBJID%TYPE)
    RETURN NUMBER
  AS
    L_DEFAULT NUMBER                  := 0;
    LV_PROG_ENROLL_COUNT PLS_INTEGER  := 0;
    LV_PROMO_ENROLL_COUNT PLS_INTEGER := 0;
    WEBXESN_REC WEBXESN_CUR%ROWTYPE;
    ESNXPROGRAM_REC ESNXPROGRAM_CUR%ROWTYPE;
    ENROLLED_PROMO_REC ENROLLED_PROMO_CUR%ROWTYPE;
    L_ELIG_PROG1_ARRAY sa.TYP_VARCHAR2_ARRAY := TYP_VARCHAR2_ARRAY();
    L_ESN_LIST_ARRAY sa.TYP_VARCHAR2_ARRAY   := TYP_VARCHAR2_ARRAY();
    LV_IS_BUNDLE_PROMO PLS_INTEGER           := 0;
    LV_BUNDLE_PROGRAM_PROMO PLS_INTEGER      := 0;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Start of FN_CHECK_ST_BUNDLE_FAMILY for ESN:'||IP_ESN||', IP_PROMO_OBJID:'||IP_PROMO_OBJID);
    sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING',     --IP_X_PARAM_NAME
    'Debug - Start of SA.BILLING_BUNDLE_PKG.FN_CHECK_ST_BUNDLE_FAMILY',                       --p_action
    SYSDATE,                                                                                  --p_error_date
    IP_ESN,                                                                                   --p_key
    'SA.BILLING_BUNDLE_PKG.FN_CHECK_ST_BUNDLE_FAMILY',                                        --p_program_name
    'Start of FN_CHECK_ST_BUNDLE_FAMILY for ESN:'||IP_ESN||', IP_PROMO_OBJID:'||IP_PROMO_OBJID--p_error_text
    );
    SELECT COUNT(*)
    INTO LV_IS_BUNDLE_PROMO
    FROM sa.TABLE_X_PROMOTION_MTM PM
    WHERE PM.X_PROMO_MTM2X_PROMO_GROUP IN
      (SELECT OBJID
      FROM sa.TABLE_X_PROMOTION_GROUP
      WHERE GROUP_NAME = 'BUNDLE_PROMO_GRP'
      )
    AND PM.X_PROMO_MTM2X_PROMOTION = IP_PROMO_OBJID ;
    DBMS_OUTPUT.PUT_LINE('LV_IS_BUNDLE_PROMO: '||LV_IS_BUNDLE_PROMO);
    IF LV_IS_BUNDLE_PROMO > 0 THEN
      DBMS_OUTPUT.PUT_LINE('This promo is a valid bundle promo. Processing..');
      LV_PROG_ENROLL_COUNT  := 0;
      LV_PROMO_ENROLL_COUNT := 0;
      OPEN WEBXESN_CUR(IP_ESN);
      FETCH WEBXESN_CUR INTO WEBXESN_REC;
      IF WEBXESN_CUR%NOTFOUND THEN
        CLOSE WEBXESN_CUR;
        DBMS_OUTPUT.PUT_LINE( 'Error: Do not have Web account linked to this ESN');
        RETURN L_DEFAULT; -- doesn't have account
      ELSIF WEBXESN_CUR%FOUND THEN
        DBMS_OUTPUT.PUT_LINE( 'Web account: '||WEBXESN_REC.OBJID);
        SELECT DISTINCT BPP.X_PARENT_PROG_NAME BULK COLLECT
        INTO L_ELIG_PROG1_ARRAY
        FROM sa.X_BUNDLE_PROGRAM_PROMO BPP
        WHERE BPP.X_PROMO_OBJID = IP_PROMO_OBJID;
        IF L_ELIG_PROG1_ARRAY  IS NULL OR L_ELIG_PROG1_ARRAY.COUNT = 0 THEN
          DBMS_OUTPUT.PUT_LINE('Exiting as there are no records found for promo:'||IP_PROMO_OBJID||' in SA.X_BUNDLE_PROGRAM_PROMO');
          RETURN 0;
        END IF;
        SELECT PI.PART_SERIAL_NO BULK COLLECT
        INTO L_ESN_LIST_ARRAY
        FROM sa.TABLE_PART_INST PI,
          sa.TABLE_X_CONTACT_PART_INST CPI ,
          sa.TABLE_WEB_USER WEB
        WHERE WEB.OBJID                     = WEBXESN_REC.OBJID
        AND PI.OBJID                        = CPI.X_CONTACT_PART_INST2PART_INST
        AND CPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT ;
        DBMS_OUTPUT.PUT_LINE( 'Start - Checking if this ESN exist in program1 list');
        --Check list of esns associated to the account
        FOR ESNSXACC_REC IN
        (SELECT T.COLUMN_VALUE FROM TABLE(L_ESN_LIST_ARRAY) T
        )
        LOOP
          DBMS_OUTPUT.PUT_LINE( 'Processing ESN:'||ESNSXACC_REC.COLUMN_VALUE);
          DBMS_OUTPUT.PUT_LINE( 'Checking if this ESN is enrolled into programs 1 list');
          -- Check if this esn is enrolled in Straight talk unlimited programs
          OPEN ESNXPROGRAM_CUR(ESNSXACC_REC.COLUMN_VALUE, L_ELIG_PROG1_ARRAY);
          FETCH ESNXPROGRAM_CUR
          INTO ESNXPROGRAM_REC;
          IF ESNXPROGRAM_CUR%FOUND THEN
            --Get number of ESNs enrolled into this program from this web account
            LV_PROG_ENROLL_COUNT := LV_PROG_ENROLL_COUNT + 1;
            DBMS_OUTPUT.PUT_LINE( 'ESN which is enrolled into '||ESNXPROGRAM_REC.X_PROGRAM_NAME||' is '||ESNSXACC_REC.COLUMN_VALUE);
          ELSIF ESNXPROGRAM_CUR%NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE( 'ESN is not enrolled into program1 list');
            NULL;
          END IF;
          CLOSE ESNXPROGRAM_CUR;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE( 'End - Checking if this ESN exist in program1 list');
        --We will be giving new promotion, only if at-least one ESN in this web account is enrolled into ST unlimited program.
        IF LV_PROG_ENROLL_COUNT > 0 THEN
          DBMS_OUTPUT.PUT_LINE( 'Number of ESNs in this web account which are enrolled into program 1 list is - LV_PROG_ENROLL_COUNT : '||LV_PROG_ENROLL_COUNT);
          -- As at least one ESN is enrolled into ST program, we are checking if this promotion is already given or not.
          FOR ESNSXACC_REC_1 IN
          (SELECT T.COLUMN_VALUE FROM TABLE(L_ESN_LIST_ARRAY) T
          )
          LOOP
            DBMS_OUTPUT.PUT_LINE( 'Processing ESN: '||ESNSXACC_REC_1.COLUMN_VALUE);
            DBMS_OUTPUT.PUT_LINE( 'Checking if this ESN is enrolled into promotion: '||IP_PROMO_OBJID);
            FOR ENROLLED_PROMO_REC IN ENROLLED_PROMO_CUR( ESNSXACC_REC_1.COLUMN_VALUE, IP_PROMO_OBJID)
            LOOP
              --Checking if this promotion has already been given to anyone in this web account
              LV_PROMO_ENROLL_COUNT := LV_PROMO_ENROLL_COUNT+1;
              DBMS_OUTPUT.PUT_LINE( 'ESN: '||ESNSXACC_REC_1.COLUMN_VALUE||' is enrolled into promotion: '||IP_PROMO_OBJID);
            END LOOP;
          END LOOP;
          DBMS_OUTPUT.PUT_LINE( 'LV_PROG_ENROLL_COUNT: '||LV_PROG_ENROLL_COUNT);
          DBMS_OUTPUT.PUT_LINE( 'LV_PROMO_ENROLL_COUNT: '||LV_PROMO_ENROLL_COUNT);
          IF LV_PROG_ENROLL_COUNT > LV_PROMO_ENROLL_COUNT THEN
            --We can give promotion to this ESN, as all conditions got satisfied
            L_DEFAULT := 1;
            DBMS_OUTPUT.PUT_LINE( 'As number of ESNs enrolled into progam 1 are greater than number of ESNs enrolled into promo, it is eligible');
          ELSE
            L_DEFAULT := 0;
            DBMS_OUTPUT.PUT_LINE( 'As number of ESNs enrolled into progam 1 are less than or equal to number of ESNs enrolled into promo, it is Not eligible');
          END IF;
        ELSE
          L_DEFAULT := 0;
          DBMS_OUTPUT.PUT_LINE( 'As there are no ESNs in this account which are enrolled into program 1 list, bundle promo is not eligible');
        END IF;
        CLOSE WEBXESN_CUR;
      END IF;
    ELSE
      DBMS_OUTPUT.PUT_LINE('This promo is not a valid bundle promo.');
    END IF;
    sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING' ,                        --IP_X_PARAM_NAME
    'Debug - End of SA.BILLING_BUNDLE_PKG.FN_CHECK_ST_BUNDLE_FAMILY',                                             --p_action
    SYSDATE,                                                                                                      --p_error_date
    IP_ESN,                                                                                                       --p_key
    'SA.BILLING_BUNDLE_PKG.FN_CHECK_ST_BUNDLE_FAMILY',                                                            --p_program_name
    'End of SA.BILLING_BUNDLE_PKG.FN_CHECK_ST_BUNDLE_FAMILY for ESN:'||IP_ESN||', IP_PROMO_OBJID:'||IP_PROMO_OBJID--p_error_text
    );
    DBMS_OUTPUT.PUT_LINE('End of FN_CHECK_ST_BUNDLE_FAMILY');
    RETURN L_DEFAULT;
  EXCEPTION
  WHEN OTHERS THEN
    sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Error SA.BILLING_BUNDLE_PKG.FN_CHECK_ST_BUNDLE_FAMILY for ESN:'||IP_ESN||', IP_PROMO_OBJID:'||IP_PROMO_OBJID, --p_action
    SYSDATE,                                                                                                                                               --p_error_date
    IP_ESN,                                                                                                                                                --p_key
    'SA.BILLING_BUNDLE_PKG.FN_CHECK_ST_BUNDLE_FAMILY',                                                                                                     --p_program_name
    'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()               --p_error_text
    );
    RAISE;
    RETURN L_DEFAULT;
  END FN_CHECK_ST_BUNDLE_FAMILY;
  /***************************************************************************************************************
  Program Name       :   SP_REGISTER_BUNDLE_PROMO
  Program Type       :   Procedure
  Program Arguments  :   IP_ESN
  IP_PROMO_OBJID
  IP_PROGRAM_ENROLLED_OBJID
  Returns            :   OP_ERROR_CODE
  OP_ERROR_MSG
  Program Called     :   None
  Description        :   This procedure will make all necessary changes that need to happen
  during registering bundle promotion.
  Modified By            Modification     CR             Description
  Date           Number
  =============          ============     ======      ===================================
  Jai Arza        07/06/2015     34962          Initial Creation
  ***************************************************************************************************************/
PROCEDURE SP_REGISTER_BUNDLE_PROMO(
    IP_ESN                    IN sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE ,
    IP_PROMO_OBJID            IN sa.TABLE_X_PROMOTION.OBJID%TYPE ,
    IP_PROGRAM_ENROLLED_OBJID IN sa.X_PROGRAM_ENROLLED.OBJID%TYPE ,
    OP_ERROR_CODE OUT NUMBER ,
    OP_ERROR_MSG OUT VARCHAR2)
AS
  LV_IS_BUNDLE_PROMO PLS_INTEGER := 0;
  WEBXESN_REC WEBXESN_CUR%ROWTYPE;
  ESNXPROGRAM_REC1 ESNXPROGRAM_CUR%ROWTYPE;
  ESNXPROGRAM_REC2 ESNXPROGRAM_CUR%ROWTYPE;
  ENROLLED_PROMO_REC ENROLLED_PROMO_CUR%ROWTYPE;
  L_ELIG_PROG1_ARRAY sa.TYP_VARCHAR2_ARRAY                    := TYP_VARCHAR2_ARRAY();
  L_ELIG_PROG2_ARRAY sa.TYP_VARCHAR2_ARRAY                    := TYP_VARCHAR2_ARRAY();
  PROG1_ESN_INFO_TAB sa.TYP_ESN_INFO_TABLE                    := sa.TYP_ESN_INFO_TABLE(); --Defining this for ST Unlimited enrolled ESNs
  PROG2_ESN_INFO_TAB sa.TYP_ESN_INFO_TABLE                    := sa.TYP_ESN_INFO_TABLE(); --Defining this for RA enrolled ESNs
  LV_X_PROG_ENROLLED_OBJID_1 sa.X_PROGRAM_ENROLLED.OBJID%TYPE := 0;
  LV_X_PROG_ENROLLED_OBJID_2 sa.X_PROGRAM_ENROLLED.OBJID%TYPE := 0;
  LV_BUNDLE_LINK_EXIST PLS_INTEGER                            := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Start of SP_REGISTER_BUNDLE_PROMO for ESN:'||IP_ESN||', IP_PROMO_OBJID:'||IP_PROMO_OBJID||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID);
  sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING',                                                                                     --IP_X_PARAM_NAME
  'Debug - Start of SA.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO',                                                                                                        --p_action
  SYSDATE,                                                                                                                                                                  --p_error_date
  IP_ESN,                                                                                                                                                                   --p_key
  'SA.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO',                                                                                                                         --p_program_name
  'Start of SA.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO for ESN:'||IP_ESN||', IP_PROMO_OBJID:'||IP_PROMO_OBJID||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID--p_error_text
  );
  OP_ERROR_CODE := 0;
  OP_ERROR_MSG  := 'Success';
  SELECT COUNT(*)
  INTO LV_IS_BUNDLE_PROMO
  FROM sa.TABLE_X_PROMOTION_MTM PM
  WHERE PM.X_PROMO_MTM2X_PROMO_GROUP IN
    (SELECT OBJID
    FROM sa.TABLE_X_PROMOTION_GROUP
    WHERE GROUP_NAME = 'BUNDLE_PROMO_GRP'
    )
  AND PM.X_PROMO_MTM2X_PROMOTION = IP_PROMO_OBJID;
  DBMS_OUTPUT.PUT_LINE('Is provided promo part of bundle promo LV_IS_BUNDLE_PROMO:'||LV_IS_BUNDLE_PROMO);
  IF LV_IS_BUNDLE_PROMO > 0 THEN
    DBMS_OUTPUT.PUT_LINE('This promo is a valid bundle promo. Processing..');
    --Get parent program names for the promotion provided.
    SELECT DISTINCT BPP.X_PARENT_PROG_NAME BULK COLLECT
    INTO L_ELIG_PROG1_ARRAY
    FROM sa.X_BUNDLE_PROGRAM_PROMO BPP
    WHERE BPP.X_PROMO_OBJID = IP_PROMO_OBJID;
    --Get child program names for the promotion provided.
    SELECT DISTINCT BPP.X_CHILD_PROG_NAME BULK COLLECT
    INTO L_ELIG_PROG2_ARRAY
    FROM sa.X_BUNDLE_PROGRAM_PROMO BPP
    WHERE BPP.X_PROMO_OBJID = IP_PROMO_OBJID;
    IF (L_ELIG_PROG1_ARRAY IS NULL OR L_ELIG_PROG1_ARRAY.COUNT = 0) OR (L_ELIG_PROG2_ARRAY IS NULL OR L_ELIG_PROG2_ARRAY.COUNT = 0) THEN
      DBMS_OUTPUT.PUT_LINE('L_ELIG_PROG1_ARRAY or L_ELIG_PROG2_ARRAY - No records found these nested tables');
      sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Debug SP_REGISTER_BUNDLE_PROMO - Failure, No records found in L_ELIG_PROG1_ARRAY or L_ELIG_PROG2_ARRAY. Data might not be existing in SA.X_BUNDLE_PROGRAM_PROMO for IP_PROMO_OBJID:'||IP_PROMO_OBJID, --p_action
      SYSDATE,                                                                                                                                                                                                                                       --p_error_date
      IP_ESN,                                                                                                                                                                                                                                        --p_key
      'SA.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO',                                                                                                                                                                                              --p_program_name
      'SP_REGISTER_BUNDLE_PROMO for ESN:'||IP_ESN||', IP_PROMO_OBJID:'||IP_PROMO_OBJID||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID                                                                                                    --p_error_text
      );
      RETURN;
    END IF;
    OPEN WEBXESN_CUR(IP_ESN);
    FETCH WEBXESN_CUR
    INTO WEBXESN_REC;
    -- check web objid for account
    IF WEBXESN_CUR%NOTFOUND THEN
      CLOSE WEBXESN_CUR;
      DBMS_OUTPUT.PUT_LINE('Do not have Web account');
      RETURN;
    ELSE
      DBMS_OUTPUT.PUT_LINE('Web account exist for ESN provided:'||WEBXESN_REC.OBJID);
      CLOSE WEBXESN_CUR;
      DBMS_OUTPUT.PUT_LINE('Start - Loading enrolled ESNs in this web account into arrays');
      --Check list of esns associated to the account
      FOR ESNSXACC_REC IN
      (SELECT PI.PART_SERIAL_NO
      FROM sa.TABLE_PART_INST PI,
        sa.TABLE_X_CONTACT_PART_INST CPI ,
        sa.TABLE_WEB_USER WEB
      WHERE WEB.OBJID                     = WEBXESN_REC.OBJID
      AND PI.OBJID                        = CPI.X_CONTACT_PART_INST2PART_INST
      AND CPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT
      )
      LOOP
        DBMS_OUTPUT.PUT_LINE( '---- ESN existing in this account:'||ESNSXACC_REC.PART_SERIAL_NO||' ----');
        -- Check if this esn is enrolled into master program
        DBMS_OUTPUT.PUT_LINE('Checking if this ESN is enrolled into program 1 list');
        OPEN ESNXPROGRAM_CUR(ESNSXACC_REC.PART_SERIAL_NO, L_ELIG_PROG1_ARRAY);
        FETCH ESNXPROGRAM_CUR INTO ESNXPROGRAM_REC1;
        IF ESNXPROGRAM_CUR%FOUND THEN
          --Get number of ESNs enrolled into this program from this web account
          DBMS_OUTPUT.PUT_LINE('ESN which is enrolled into program 1 list: '||ESNSXACC_REC.PART_SERIAL_NO);
          PROG1_ESN_INFO_TAB.EXTEND();
          PROG1_ESN_INFO_TAB(PROG1_ESN_INFO_TAB.LAST) := TYP_ESN_INFO_OBJ(ESNSXACC_REC.PART_SERIAL_NO , WEBXESN_REC.OBJID , ESNXPROGRAM_REC1.PROG_ENROLLED_OBJID , ESNXPROGRAM_REC1.X_PRIMARY_PROG_ENROLL_OBJID , ESNXPROGRAM_REC1.X_PROGRAM_PARAM_OBJID , ESNXPROGRAM_REC1.X_PROGRAM_NAME , ESNXPROGRAM_REC1.X_PROMOTION_OBJID , ESNXPROGRAM_REC1.X_NEXT_CHARGE_DATE , ESNXPROGRAM_REC1.X_CHARGE_TYPE );
        END IF;
        CLOSE ESNXPROGRAM_CUR;
        -- Check if this ESN is enrolled into child program.
        DBMS_OUTPUT.PUT_LINE('Checking if this ESN is enrolled into program 2 list');
        OPEN ESNXPROGRAM_CUR(ESNSXACC_REC.PART_SERIAL_NO, L_ELIG_PROG2_ARRAY);
        FETCH ESNXPROGRAM_CUR INTO ESNXPROGRAM_REC2;
        IF ESNXPROGRAM_CUR%FOUND THEN
          --Get number of ESNs enrolled into this program from this web account
          DBMS_OUTPUT.PUT_LINE('ESN which is enrolled into program 2 list: '||ESNSXACC_REC.PART_SERIAL_NO);
          PROG2_ESN_INFO_TAB.EXTEND();
          PROG2_ESN_INFO_TAB(PROG2_ESN_INFO_TAB.LAST) := TYP_ESN_INFO_OBJ(ESNSXACC_REC.PART_SERIAL_NO , WEBXESN_REC.OBJID , ESNXPROGRAM_REC2.PROG_ENROLLED_OBJID , ESNXPROGRAM_REC2.X_PRIMARY_PROG_ENROLL_OBJID , ESNXPROGRAM_REC2.X_PROGRAM_PARAM_OBJID , ESNXPROGRAM_REC2.X_PROGRAM_NAME , ESNXPROGRAM_REC2.X_PROMOTION_OBJID , ESNXPROGRAM_REC2.X_NEXT_CHARGE_DATE , ESNXPROGRAM_REC2.X_CHARGE_TYPE );
        END IF;
        CLOSE ESNXPROGRAM_CUR;
      END LOOP;
      DBMS_OUTPUT.PUT_LINE('End - Loading enrolled ESNs in this web account into arrays');
      DBMS_OUTPUT.PUT_LINE('Start - Checking if this ESN is already bundled');
      LV_BUNDLE_LINK_EXIST  := 0;
      IF PROG1_ESN_INFO_TAB IS NOT NULL AND PROG1_ESN_INFO_TAB.COUNT > 0 AND PROG2_ESN_INFO_TAB IS NOT NULL AND PROG2_ESN_INFO_TAB.COUNT > 0 THEN
        --If link already exist, ignore and proceed further.
        SELECT COUNT(*)
        INTO LV_BUNDLE_LINK_EXIST
        FROM TABLE(PROG1_ESN_INFO_TAB) T1
        WHERE T1.X_PROG_ENROLLED_OBJID IN
          (SELECT T2.X_PRIMARY_PROG_ENROLL_OBJID
          FROM TABLE(PROG2_ESN_INFO_TAB) T2
          WHERE 1                          =1
          AND T2.X_ESN                     = IP_ESN
          AND T2.X_PROMOTION_OBJID         = IP_PROMO_OBJID
          AND T2.X_PROG_ENROLLED_OBJID     = IP_PROGRAM_ENROLLED_OBJID
          AND NVL(T2.X_CHARGE_TYPE,'NULL') = 'BUNDLE'
          )
        AND NVL(T1.X_CHARGE_TYPE,'NULL') = 'BUNDLE' ;
        DBMS_OUTPUT.PUT_LINE('LV_BUNDLE_LINK_EXIST Count:'||LV_BUNDLE_LINK_EXIST);
      ELSE
        --As one of array is null, this will error out in next step
        LV_BUNDLE_LINK_EXIST := 0;
      END IF;
      DBMS_OUTPUT.PUT_LINE('End - Checking if this ESN is already bundled');
      IF LV_BUNDLE_LINK_EXIST = 0 THEN
        DBMS_OUTPUT.PUT_LINE('ESN is not bundled. Processing..');
        DBMS_OUTPUT.PUT_LINE('Processing all ESNs which are enrolled in program 1');
        IF PROG1_ESN_INFO_TAB IS NOT NULL AND PROG1_ESN_INFO_TAB.COUNT > 0 THEN
          DBMS_OUTPUT.PUT_LINE('PROG1_ESN_INFO_TAB Checking for valid prog1 enrolled objid');
          --Get the ESNs enrolled into program 1, which is not yet bundled
          BEGIN
            SELECT X_PROG_ENROLLED_OBJID
            INTO LV_X_PROG_ENROLLED_OBJID_1
            FROM
              (SELECT T.X_PROG_ENROLLED_OBJID
              FROM TABLE(PROG1_ESN_INFO_TAB) T
              WHERE NVL(X_CHARGE_TYPE,'NULL') != 'BUNDLE'
              ORDER BY X_NEXT_CHARGE_DATE ASC
              )
            WHERE ROWNUM=1;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            LV_X_PROG_ENROLLED_OBJID_1 := 0;
            DBMS_OUTPUT.PUT_LINE('All ESNs enrolled in program 1 are already bundled. Failure, could not find eligible program 1 enrolled objid.');
            sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Debug SP_REGISTER_BUNDLE_PROMO - Failure, could not find eligible program 1 enrolled objid',      --p_action
            SYSDATE,                                                                                                                                   --p_error_date
            IP_ESN,                                                                                                                                    --p_key
            'SA.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO',                                                                                          --p_program_name
            'SP_REGISTER_BUNDLE_PROMO for ESN:'||IP_ESN||', IP_PROMO_OBJID:'||IP_PROMO_OBJID||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID--p_error_text
            );
            OP_ERROR_CODE := 1;
            OP_ERROR_MSG  := 'Failure, could not find eligible program 1 enrolled objid';
            RETURN;
          END;
        ELSE
          DBMS_OUTPUT.PUT_LINE('PROG1_ESN_INFO_TAB - No records found this nested table');
          sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Debug SP_REGISTER_BUNDLE_PROMO - Failure, No records found in PROG1_ESN_INFO_TAB which are enrolled into mobile program 1', --p_action
          SYSDATE,                                                                                                                                                             --p_error_date
          IP_ESN,                                                                                                                                                              --p_key
          'SA.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO',                                                                                                                    --p_program_name
          'SP_REGISTER_BUNDLE_PROMO for ESN:'||IP_ESN||', IP_PROMO_OBJID:'||IP_PROMO_OBJID||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID                          --p_error_text
          );
          RETURN;
        END IF;
        IF PROG1_ESN_INFO_TAB IS NOT NULL AND PROG1_ESN_INFO_TAB.COUNT > 0 THEN
          DBMS_OUTPUT.PUT_LINE('PROG1_ESN_INFO_TAB Count: '||PROG1_ESN_INFO_TAB.COUNT);
          FOR ESN_IDX IN PROG1_ESN_INFO_TAB.FIRST..PROG1_ESN_INFO_TAB.LAST
          LOOP
            IF PROG1_ESN_INFO_TAB(ESN_IDX).X_PROG_ENROLLED_OBJID = LV_X_PROG_ENROLLED_OBJID_1 THEN
              PROG1_ESN_INFO_TAB(ESN_IDX).X_CHARGE_TYPE         := 'BUNDLE';
              UPDATE sa.X_PROGRAM_ENROLLED
              SET X_CHARGE_TYPE = 'BUNDLE'
              WHERE OBJID       = PROG1_ESN_INFO_TAB(ESN_IDX).X_PROG_ENROLLED_OBJID
              AND X_ESN         = PROG1_ESN_INFO_TAB(ESN_IDX).X_ESN;
              DBMS_OUTPUT.PUT_LINE('Number of records updated in SA.X_PROGRAM_ENROLLED: '||SQL%ROWCOUNT);
            ELSE
              DBMS_OUTPUT.PUT_LINE('No records updated in SA.X_PROGRAM_ENROLLED');
            END IF;
            DBMS_OUTPUT.PUT_LINE('PROG1_ESN_INFO_TAB('||ESN_IDX||').X_ESN: '||PROG1_ESN_INFO_TAB(ESN_IDX).X_ESN);
            DBMS_OUTPUT.PUT_LINE('PROG1_ESN_INFO_TAB('||ESN_IDX||').X_WEB_ACCT_OBJID: '||PROG1_ESN_INFO_TAB(ESN_IDX).X_WEB_ACCT_OBJID);
            DBMS_OUTPUT.PUT_LINE('PROG1_ESN_INFO_TAB('||ESN_IDX||').X_PROG_ENROLLED_OBJID: '||PROG1_ESN_INFO_TAB(ESN_IDX).X_PROG_ENROLLED_OBJID);
            DBMS_OUTPUT.PUT_LINE('PROG1_ESN_INFO_TAB('||ESN_IDX||').X_PRIMARY_PROG_ENROLL_OBJID: '||PROG1_ESN_INFO_TAB(ESN_IDX).X_PRIMARY_PROG_ENROLL_OBJID);
            DBMS_OUTPUT.PUT_LINE('PROG1_ESN_INFO_TAB('||ESN_IDX||').X_PROGRAM_PARAM_OBJID: '||PROG1_ESN_INFO_TAB(ESN_IDX).X_PROGRAM_PARAM_OBJID);
            DBMS_OUTPUT.PUT_LINE('PROG1_ESN_INFO_TAB('||ESN_IDX||').X_PROGRAM_NAME: '||PROG1_ESN_INFO_TAB(ESN_IDX).X_PROGRAM_NAME);
            DBMS_OUTPUT.PUT_LINE('PROG1_ESN_INFO_TAB('||ESN_IDX||').X_PROMOTION_OBJID: '||PROG1_ESN_INFO_TAB(ESN_IDX).X_PROMOTION_OBJID);
            DBMS_OUTPUT.PUT_LINE('PROG1_ESN_INFO_TAB('||ESN_IDX||').X_NEXT_CHARGE_DATE: '||PROG1_ESN_INFO_TAB(ESN_IDX).X_NEXT_CHARGE_DATE);
            DBMS_OUTPUT.PUT_LINE('PROG1_ESN_INFO_TAB('||ESN_IDX||').X_CHARGE_TYPE: '||PROG1_ESN_INFO_TAB(ESN_IDX).X_CHARGE_TYPE);
          END LOOP;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Processing all ESNs which are enrolled in program 2');
        IF PROG2_ESN_INFO_TAB IS NOT NULL AND PROG2_ESN_INFO_TAB.COUNT > 0 THEN
          DBMS_OUTPUT.PUT_LINE('PROG2_ESN_INFO_TAB Count: '||PROG2_ESN_INFO_TAB.COUNT);
          FOR ESN_IDX IN PROG2_ESN_INFO_TAB.FIRST..PROG2_ESN_INFO_TAB.LAST
          LOOP
            IF PROG2_ESN_INFO_TAB(ESN_IDX).X_PROG_ENROLLED_OBJID = IP_PROGRAM_ENROLLED_OBJID THEN
              PROG2_ESN_INFO_TAB(ESN_IDX).X_CHARGE_TYPE         := 'BUNDLE';
              UPDATE sa.X_PROGRAM_ENROLLED
              SET X_CHARGE_TYPE     = 'BUNDLE' ,
                PGM_ENROLL2PROG_HDR = LV_X_PROG_ENROLLED_OBJID_1
              WHERE OBJID           = PROG2_ESN_INFO_TAB(ESN_IDX).X_PROG_ENROLLED_OBJID
              AND X_ESN             = PROG2_ESN_INFO_TAB(ESN_IDX).X_ESN;
              DBMS_OUTPUT.PUT_LINE('Number of records updated in SA.X_PROGRAM_ENROLLED: '||SQL%ROWCOUNT);
            ELSE
              DBMS_OUTPUT.PUT_LINE('No records updated in SA.X_PROGRAM_ENROLLED');
            END IF;
            DBMS_OUTPUT.PUT_LINE('PROG2_ESN_INFO_TAB('||ESN_IDX||').X_ESN: '||PROG2_ESN_INFO_TAB(ESN_IDX).X_ESN);
            DBMS_OUTPUT.PUT_LINE('PROG2_ESN_INFO_TAB('||ESN_IDX||').X_WEB_ACCT_OBJID: '||PROG2_ESN_INFO_TAB(ESN_IDX).X_WEB_ACCT_OBJID);
            DBMS_OUTPUT.PUT_LINE('PROG2_ESN_INFO_TAB('||ESN_IDX||').X_PROG_ENROLLED_OBJID: '||PROG2_ESN_INFO_TAB(ESN_IDX).X_PROG_ENROLLED_OBJID);
            DBMS_OUTPUT.PUT_LINE('PROG2_ESN_INFO_TAB('||ESN_IDX||').X_PRIMARY_PROG_ENROLL_OBJID: '||PROG2_ESN_INFO_TAB(ESN_IDX).X_PRIMARY_PROG_ENROLL_OBJID);
            DBMS_OUTPUT.PUT_LINE('PROG2_ESN_INFO_TAB('||ESN_IDX||').X_PROGRAM_PARAM_OBJID: '||PROG2_ESN_INFO_TAB(ESN_IDX).X_PROGRAM_PARAM_OBJID);
            DBMS_OUTPUT.PUT_LINE('PROG2_ESN_INFO_TAB('||ESN_IDX||').X_PROGRAM_NAME: '||PROG2_ESN_INFO_TAB(ESN_IDX).X_PROGRAM_NAME);
            DBMS_OUTPUT.PUT_LINE('PROG2_ESN_INFO_TAB('||ESN_IDX||').X_PROMOTION_OBJID: '||PROG2_ESN_INFO_TAB(ESN_IDX).X_PROMOTION_OBJID);
            DBMS_OUTPUT.PUT_LINE('PROG2_ESN_INFO_TAB('||ESN_IDX||').X_NEXT_CHARGE_DATE: '||PROG2_ESN_INFO_TAB(ESN_IDX).X_NEXT_CHARGE_DATE);
            DBMS_OUTPUT.PUT_LINE('PROG2_ESN_INFO_TAB('||ESN_IDX||').X_CHARGE_TYPE: '||PROG2_ESN_INFO_TAB(ESN_IDX).X_CHARGE_TYPE);
          END LOOP;
        ELSE
          DBMS_OUTPUT.PUT_LINE('PROG2_ESN_INFO_TAB - No records found this nested table');
          sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Debug SP_REGISTER_BUNDLE_PROMO - Failure, No records found in PROG2_ESN_INFO_TAB which are enrolled into mobile program 1', --p_action
          SYSDATE,                                                                                                                                                             --p_error_date
          IP_ESN,                                                                                                                                                              --p_key
          'SA.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO',                                                                                                                    --p_program_name
          'SP_REGISTER_BUNDLE_PROMO for ESN:'||IP_ESN||', IP_PROMO_OBJID:'||IP_PROMO_OBJID||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID                          --p_error_text
          );
          RETURN;
        END IF;
      ELSE
        NULL;
        DBMS_OUTPUT.PUT_LINE('ESN is already bundled. Nothing to process');
      END IF;
    END IF;
  ELSE
    DBMS_OUTPUT.PUT_LINE('This promo is not a valid bundle promo.');
    NULL;
  END IF;
  sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING',                                                                                   --IP_X_PARAM_NAME
  'Debug SA.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO',                                                                                                                 --p_action
  SYSDATE,                                                                                                                                                                --p_error_date
  IP_ESN,                                                                                                                                                                 --p_key
  'SA.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO',                                                                                                                       --p_program_name
  'End of SA.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO for ESN:'||IP_ESN||', IP_PROMO_OBJID:'||IP_PROMO_OBJID||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID--p_error_text
  );
  DBMS_OUTPUT.PUT_LINE('End of SP_REGISTER_BUNDLE_PROMO');
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Error SA.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO for ESN:'||IP_ESN||', IP_PROMO_OBJID:'||IP_PROMO_OBJID||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID, --p_action
  SYSDATE,                                                                                                                                                                                                         --p_error_date
  IP_ESN,                                                                                                                                                                                                          --p_key
  'SA.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO',                                                                                                                                                                --p_program_name
  'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()                                                                         --p_error_text
  );
  RAISE;
END SP_REGISTER_BUNDLE_PROMO;
/***************************************************************************************************************
Program Name       :   SP_GET_BUNDLED_PROMO_OBJID
Program Type       :   Procedure
Program Arguments  :   IP_ESN
IP_PROGRAM_ENROLLED_OBJID
Returns            :   OP_PROMO_OBJID
OP_ERROR_CODE
OP_ERROR_MSG
Program Called     :   SA.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE
Description        :   This procedure will get promotion objid based on which this ESN
is bundled.
Modified By            Modification     CR             Description
Date           Number
=============          ============     ======      ===================================
Jai Arza       07/06/2015      34962          Initial Creation
***************************************************************************************************************/
PROCEDURE SP_GET_BUNDLED_PROMO_OBJID(
    IP_ESN                    IN sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE ,
    IP_PROGRAM_ENROLLED_OBJID IN sa.X_PROGRAM_ENROLLED.OBJID%TYPE ,
    OP_PROMO_OBJID OUT sa.TABLE_X_PROMOTION.OBJID%TYPE ,
    OP_ERROR_CODE OUT NUMBER ,
    OP_ERROR_MSG OUT VARCHAR2)
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('Start of SP_GET_BUNDLED_PROMO_OBJID for ESN:'||IP_ESN||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID);
  OP_PROMO_OBJID := 0;
  OP_ERROR_CODE  := 0;
  OP_ERROR_MSG   := 'Success';
  FOR PROMO IN
  (SELECT PE.OBJID            AS PROG_ENROLLED_OBJID ,
    PE.X_NEXT_CHARGE_DATE     AS X_NEXT_CHARGE_DATE ,
    PE.X_CHARGE_TYPE          AS X_CHARGE_TYPE ,
    PE.PGM_ENROLL2PROG_HDR    AS X_PRIMARY_PROG_ENROLL_OBJID ,
    PP.OBJID                  AS X_PROGRAM_PARAM_OBJID ,
    PP.X_PROGRAM_NAME         AS X_PROGRAM_NAME ,
    PE.PGM_ENROLL2X_PROMOTION AS X_PROMOTION_OBJID
  FROM sa.X_PROGRAM_PARAMETERS PP ,
    sa.X_PROGRAM_ENROLLED PE
  WHERE PE.OBJID                   = IP_PROGRAM_ENROLLED_OBJID
  AND PE.X_ESN                     = IP_ESN
  AND NVL(PE.X_CHARGE_TYPE,'NULL') = 'BUNDLE'
  AND PP.OBJID                     = PE.PGM_ENROLL2PGM_PARAMETER
  )
  LOOP
    IF PROMO.X_PRIMARY_PROG_ENROLL_OBJID IS NULL THEN
      DBMS_OUTPUT.PUT_LINE('This ESN is the primary one of this bundle');
      BEGIN
        SELECT PGM_ENROLL2X_PROMOTION
        INTO OP_PROMO_OBJID
        FROM sa.X_PROGRAM_ENROLLED PE1
        WHERE 1                           =1
        AND PE1.PGM_ENROLL2PROG_HDR       = IP_PROGRAM_ENROLLED_OBJID
        AND NVL(PE1.X_CHARGE_TYPE,'NULL') = 'BUNDLE' ;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        OP_PROMO_OBJID:= 0;
        sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ( 'Error SA.BILLING_BUNDLE_PKG.SP_GET_BUNDLED_PROMO_OBJID for ESN:'||IP_ESN||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID, --p_action
        SYSDATE,                                                                                                                                                                       --p_error_date
        IP_ESN,                                                                                                                                                                        --p_key
        'SA.BILLING_BUNDLE_PKG.SP_GET_BUNDLED_PROMO_OBJID',                                                                                                                            --p_program_name
        'No data found when looking for Program enrolled record for IP_PROGRAM_ENROLLED_OBJID: '||IP_PROGRAM_ENROLLED_OBJID                                                            --p_error_text
        );
      END;
    ELSE
      DBMS_OUTPUT.PUT_LINE('This ESN is the child one of this bundle');
      OP_PROMO_OBJID := PROMO.X_PROMOTION_OBJID;
    END IF;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('End of SP_GET_BUNDLED_PROMO_OBJID for ESN:'||IP_ESN||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID);
EXCEPTION
WHEN OTHERS THEN
  OP_ERROR_CODE := 1;
  OP_ERROR_MSG  := 'Failure';
  sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ( 'Error SA.BILLING_BUNDLE_PKG.SP_GET_BUNDLED_PROMO_OBJID for ESN:'||IP_ESN||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID, --p_action
  SYSDATE,                                                                                                                                                                       --p_error_date
  IP_ESN,                                                                                                                                                                        --p_key
  'SA.BILLING_BUNDLE_PKG.SP_GET_BUNDLED_PROMO_OBJID',                                                                                                                            --p_program_name
  'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()                                       --p_error_text
  );
  RAISE;
END SP_GET_BUNDLED_PROMO_OBJID;
/***************************************************************************************************************
Program Name       :   SP_DEENROLL_BUNDLE_PROG
Program Type       :   Procedure
Program Arguments  :   IP_ESN
IP_PROGRAM_ENROLLED_OBJID
Returns            :   OP_ERROR_CODE
OP_ERROR_MSG
Program Called     :   SA.BILLING_BUNDLE_PKG.SP_GET_BUNDLED_PROMO_OBJID
SA.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE
Description        :   This procedure will make all necessary changes that need to happen
during bundle promotion De-enrolment.
Modified By            Modification     CR             Description
Date           Number
=============          ============     ======      ===================================
Jai Arza       07/06/2015       34962          Initial Creation
***************************************************************************************************************/
PROCEDURE SP_DEENROLL_BUNDLE_PROG(
    IP_ESN                    IN sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE ,
    IP_PROGRAM_ENROLLED_OBJID IN sa.X_PROGRAM_ENROLLED.OBJID%TYPE ,
    OP_ERROR_CODE OUT NUMBER ,
    OP_ERROR_MSG OUT VARCHAR2)
AS
  LV_PROG_ENROLL_COUNT PLS_INTEGER := 0;
  WEBXESN_REC WEBXESN_CUR%ROWTYPE;
  L_ELIG_PROG1_ARRAY sa.TYP_VARCHAR2_ARRAY := TYP_VARCHAR2_ARRAY();
  L_ELIG_PROG2_ARRAY sa.TYP_VARCHAR2_ARRAY := TYP_VARCHAR2_ARRAY();
  ELIGIBLE_ENROLLED_ESN_REC ELIGIBLE_ENROLLED_ESN_CUR%ROWTYPE;
  LV_PROMO_OBJID sa.TABLE_X_PROMOTION.OBJID%TYPE;
  LV_ERROR_CODE NUMBER(10);
  LV_ERROR_MSG  VARCHAR2(4000);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Start of SP_DEENROLL_BUNDLE_PROG for ESN:'||IP_ESN||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID);
  sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING',                                            --IP_X_PARAM_NAME
  'Debug - Start of SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_PROG',                                                                --p_action
  SYSDATE,                                                                                                                         --p_error_date
  IP_ESN,                                                                                                                          --p_key
  'SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_PROG',                                                                                 --p_program_name
  'Debug SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_PROG for ESN:'||IP_ESN||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID--p_error_text
  );
  --Entering this loop only if provided ESN is a bundled one.
  FOR PROG IN
  (SELECT PE.OBJID            AS PROG_ENROLLED_OBJID ,
    PE.X_NEXT_CHARGE_DATE     AS X_NEXT_CHARGE_DATE ,
    PE.X_CHARGE_TYPE          AS X_CHARGE_TYPE ,
    PE.PGM_ENROLL2PROG_HDR    AS X_PRIMARY_PROG_ENROLL_OBJID ,
    PP.OBJID                  AS X_PROGRAM_PARAM_OBJID ,
    PP.X_PROGRAM_NAME         AS X_PROGRAM_NAME ,
    PE.PGM_ENROLL2X_PROMOTION AS X_PROMOTION_OBJID
  FROM sa.X_PROGRAM_PARAMETERS PP ,
    sa.X_PROGRAM_ENROLLED PE
  WHERE PE.OBJID                   = IP_PROGRAM_ENROLLED_OBJID
  AND PE.X_ESN                     = IP_ESN
  AND NVL(PE.X_CHARGE_TYPE,'NULL') = 'BUNDLE'
  AND PP.OBJID                     = PE.PGM_ENROLL2PGM_PARAMETER
  )
  LOOP
    sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING',                                                                                        --IP_X_PARAM_NAME
    'Debug 1- SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_PROG',                                                                                                                    --p_action
    SYSDATE,                                                                                                                                                                     --p_error_date
    IP_ESN,                                                                                                                                                                      --p_key
    'SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_PROG',                                                                                                                             --p_program_name
    'PROG.PROG_ENROLLED_OBJID:'||PROG.PROG_ENROLLED_OBJID||', PROG.X_PROGRAM_NAME:'||PROG.X_PROGRAM_NAME||', PROG.X_PRIMARY_PROG_ENROLL_OBJID:'||PROG.X_PRIMARY_PROG_ENROLL_OBJID--p_error_text
    );
    --Get promotion objid based on which this ESN is bundled.
    sa.BILLING_BUNDLE_PKG.SP_GET_BUNDLED_PROMO_OBJID( IP_ESN , IP_PROGRAM_ENROLLED_OBJID , LV_PROMO_OBJID --OP_PROMO_OBJID
    , LV_ERROR_CODE , LV_ERROR_MSG );
    IF LV_PROMO_OBJID = 0 THEN
      --If promotion objid is 0, clearing this hanging link.
      UPDATE sa.X_PROGRAM_ENROLLED
      SET X_CHARGE_TYPE = NULL
      WHERE OBJID       = IP_PROGRAM_ENROLLED_OBJID
      AND X_ESN         = IP_ESN;
      RETURN;
    END IF;
    SELECT DISTINCT BPP.X_PARENT_PROG_NAME BULK COLLECT
    INTO L_ELIG_PROG1_ARRAY
    FROM sa.X_BUNDLE_PROGRAM_PROMO BPP
    WHERE BPP.X_PROMO_OBJID = LV_PROMO_OBJID;
    SELECT DISTINCT BPP.X_CHILD_PROG_NAME BULK COLLECT
    INTO L_ELIG_PROG2_ARRAY
    FROM sa.X_BUNDLE_PROGRAM_PROMO BPP
    WHERE BPP.X_PROMO_OBJID = LV_PROMO_OBJID;
    IF (L_ELIG_PROG1_ARRAY IS NULL OR L_ELIG_PROG1_ARRAY.COUNT = 0) OR (L_ELIG_PROG2_ARRAY IS NULL OR L_ELIG_PROG2_ARRAY.COUNT = 0) THEN
      DBMS_OUTPUT.PUT_LINE('PROG1_ESN_INFO_TAB - No records found this nested table');
      sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ( 'Debug SP_DEENROLL_BUNDLE_PROG - Failure, No records found in L_ELIG_PROG1_ARRAY or L_ELIG_PROG2_ARRAY. Data might not be existing in SA.X_BUNDLE_PROGRAM_PROMO for LV_PROMO_OBJID:'||LV_PROMO_OBJID, --p_action
      SYSDATE,                                                                                                                                                                                                                                       --p_error_date
      IP_ESN,                                                                                                                                                                                                                                        --p_key
      'SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_PROG',                                                                                                                                                                                               --p_program_name
      'SP_DEENROLL_BUNDLE_PROG for ESN:'||IP_ESN||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID                                                                                                                                          --p_error_text
      );
      RETURN;
    END IF;
    DBMS_OUTPUT.PUT_LINE('Start - Check if this ESN is enrolled into program 1');
    FOR PROG1 IN
    (SELECT COLUMN_VALUE
    FROM TABLE(L_ELIG_PROG1_ARRAY)
    WHERE COLUMN_VALUE = PROG.X_PROGRAM_NAME
    )
    LOOP
      OPEN WEBXESN_CUR(IP_ESN);
      FETCH WEBXESN_CUR INTO WEBXESN_REC;
      -- check web objid for account
      IF WEBXESN_CUR%NOTFOUND THEN
        CLOSE WEBXESN_CUR;
        DBMS_OUTPUT.PUT_LINE( 'Do not have Web account');
        RETURN;
      ELSE
        DBMS_OUTPUT.PUT_LINE( 'Web account exist for ESN provided:'||WEBXESN_REC.OBJID);
        OPEN ELIGIBLE_ENROLLED_ESN_CUR(IP_ESN, WEBXESN_REC.OBJID, L_ELIG_PROG1_ARRAY);
        FETCH ELIGIBLE_ENROLLED_ESN_CUR INTO ELIGIBLE_ENROLLED_ESN_REC;
        IF ELIGIBLE_ENROLLED_ESN_CUR%NOTFOUND THEN
          CLOSE ELIGIBLE_ENROLLED_ESN_CUR;
          DBMS_OUTPUT.PUT_LINE( 'Do not have an eligible ESN in this web account on to which this promo can be transferred on to');
          UPDATE sa.X_PROGRAM_ENROLLED
          SET X_CHARGE_TYPE = NULL
          WHERE OBJID       = IP_PROGRAM_ENROLLED_OBJID
          AND X_ESN         = IP_ESN;
          DBMS_OUTPUT.PUT_LINE('Step 1 - Number of records update in SA.X_PROGRAM_ENROLLED: '||SQL%ROWCOUNT||'. Removing link with original record');
          UPDATE sa.X_PROGRAM_ENROLLED PE
          SET PE.X_CHARGE_TYPE     = NULL ,
            PE.PGM_ENROLL2PROG_HDR = NULL
          WHERE PE.OBJID           =
            (SELECT OBJID
            FROM sa.X_PROGRAM_ENROLLED PE1
            WHERE PE1.X_ESN IN
              (SELECT PI.PART_SERIAL_NO
              FROM sa.TABLE_PART_INST PI,
                sa.TABLE_X_CONTACT_PART_INST CPI ,
                sa.TABLE_WEB_USER WEB
              WHERE WEB.OBJID                     = WEBXESN_REC.OBJID
              AND PI.OBJID                        = CPI.X_CONTACT_PART_INST2PART_INST
              AND CPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT
              )
            AND PE1.PGM_ENROLL2PROG_HDR       = IP_PROGRAM_ENROLLED_OBJID
            AND NVL(PE1.X_CHARGE_TYPE,'NULL') = 'BUNDLE'
            );
          DBMS_OUTPUT.PUT_LINE('Step 2 - Number of records update in SA.X_PROGRAM_ENROLLED: '||SQL%ROWCOUNT||'. Removing link with original record');
        ELSE
          DBMS_OUTPUT.PUT_LINE( 'Found an eligible ESN in this web account on to which this promo can be transferred on to');
          DBMS_OUTPUT.PUT_LINE( 'ELIGIBLE_ENROLLED_ESN_REC.PART_SERIAL_NO: '||ELIGIBLE_ENROLLED_ESN_REC.PART_SERIAL_NO);
          DBMS_OUTPUT.PUT_LINE( 'ELIGIBLE_ENROLLED_ESN_REC.PROG_ENROLLED_OBJID: '||ELIGIBLE_ENROLLED_ESN_REC.PROG_ENROLLED_OBJID);
          DBMS_OUTPUT.PUT_LINE( 'ELIGIBLE_ENROLLED_ESN_REC.X_NEXT_CHARGE_DATE: '||ELIGIBLE_ENROLLED_ESN_REC.X_NEXT_CHARGE_DATE);
          UPDATE sa.X_PROGRAM_ENROLLED
          SET X_CHARGE_TYPE = NULL
          WHERE OBJID       = IP_PROGRAM_ENROLLED_OBJID
          AND X_ESN         = IP_ESN;
          DBMS_OUTPUT.PUT_LINE('Step 3 - Number of records update in SA.X_PROGRAM_ENROLLED: '||SQL%ROWCOUNT||'. Removing link with original record');
          UPDATE sa.X_PROGRAM_ENROLLED
          SET X_CHARGE_TYPE = 'BUNDLE'
          WHERE OBJID       = ELIGIBLE_ENROLLED_ESN_REC.PROG_ENROLLED_OBJID
          AND X_ESN         = ELIGIBLE_ENROLLED_ESN_REC.PART_SERIAL_NO;
          DBMS_OUTPUT.PUT_LINE('Step 4 - Number of records update in SA.X_PROGRAM_ENROLLED: '||SQL%ROWCOUNT||'. Adding link with new record');
          UPDATE sa.X_PROGRAM_ENROLLED PE
          SET PE.X_CHARGE_TYPE     = 'BUNDLE' ,
            PE.PGM_ENROLL2PROG_HDR = ELIGIBLE_ENROLLED_ESN_REC.PROG_ENROLLED_OBJID
          WHERE PE.OBJID           =
            (SELECT OBJID
            FROM sa.X_PROGRAM_ENROLLED PE1
            WHERE PE1.X_ESN IN
              (SELECT PI.PART_SERIAL_NO
              FROM sa.TABLE_PART_INST PI,
                sa.TABLE_X_CONTACT_PART_INST CPI ,
                sa.TABLE_WEB_USER WEB
              WHERE WEB.OBJID                     = WEBXESN_REC.OBJID
              AND PI.OBJID                        = CPI.X_CONTACT_PART_INST2PART_INST
              AND CPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT
              )
            AND PE1.PGM_ENROLL2PROG_HDR       = IP_PROGRAM_ENROLLED_OBJID
            AND NVL(PE1.X_CHARGE_TYPE,'NULL') = 'BUNDLE'
            );
          DBMS_OUTPUT.PUT_LINE('Step 5 - Number of records update in SA.X_PROGRAM_ENROLLED: '||SQL%ROWCOUNT||'. Adding link with new record');
          CLOSE ELIGIBLE_ENROLLED_ESN_CUR;
        END IF;
        CLOSE WEBXESN_CUR;
      END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('End - Check if this ESN is enrolled into program 1');
    DBMS_OUTPUT.PUT_LINE('Start - Check if this ESN is enrolled into program 2');
    FOR PROG2 IN
    (SELECT COLUMN_VALUE
    FROM TABLE(L_ELIG_PROG2_ARRAY)
    WHERE COLUMN_VALUE = PROG.X_PROGRAM_NAME
    )
    LOOP
      UPDATE sa.X_PROGRAM_ENROLLED PE1
      SET PE1.X_CHARGE_TYPE = NULL
      WHERE PE1.OBJID       =
        (SELECT PE.PGM_ENROLL2PROG_HDR
        FROM sa.X_PROGRAM_ENROLLED PE
        WHERE PE.OBJID = IP_PROGRAM_ENROLLED_OBJID
        AND PE.X_ESN   = IP_ESN
        );
      DBMS_OUTPUT.PUT_LINE('Step 6 - Number of records update in SA.X_PROGRAM_ENROLLED: '||SQL%ROWCOUNT||'. Adding link with new record');
      UPDATE sa.X_PROGRAM_ENROLLED PE
      SET PE.X_CHARGE_TYPE     = NULL ,
        PE.PGM_ENROLL2PROG_HDR = NULL
      WHERE PE.OBJID           = IP_PROGRAM_ENROLLED_OBJID
      AND PE.X_ESN             = IP_ESN;
      DBMS_OUTPUT.PUT_LINE('Step 7 - Number of records update in SA.X_PROGRAM_ENROLLED: '||SQL%ROWCOUNT||'. Adding link with new record');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('End - Check if this ESN is enrolled into program 2');
  END LOOP;
  sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING',                      --IP_X_PARAM_NAME
  'Debug - End of SP_DEENROLL_BUNDLE_PROG',                                                                  --p_action
  SYSDATE,                                                                                                   --p_error_date
  IP_ESN,                                                                                                    --p_key
  'SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_PROG',                                                           --p_program_name
  'Debug SP_DEENROLL_BUNDLE_PROG for ESN:'||IP_ESN||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID--p_error_text
  );
  DBMS_OUTPUT.PUT_LINE('End of SP_DEENROLL_BUNDLE_PROG');
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Error SP_DEENROLL_BUNDLE_PROG for ESN:'||IP_ESN||', IP_PROGRAM_ENROLLED_OBJID:'||IP_PROGRAM_ENROLLED_OBJID, --p_action
  SYSDATE,                                                                                                                                             --p_error_date
  IP_ESN,                                                                                                                                              --p_key
  'SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_PROG',                                                                                                     --p_program_name
  'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()             --p_error_text
  );
  RAISE;
END SP_DEENROLL_BUNDLE_PROG;
/***************************************************************************************************************
Program Name       :   SP_DEENROLL_BUNDLE_ESN
Program Type       :   Procedure
Program Arguments  :   IP_ESN
Returns            :   OP_ERROR_CODE
OP_ERROR_MSG
Program Called     :   SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_PROG
SA.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE
Description        :   This procedure will make all necessary changes that need to happen
during bundle promotion De-enrolment/Deactivation of an ESN.
Modified By            Modification     CR             Description
Date           Number
=============          ============     ======      ===================================
Jai Arza       07/06/2015       34962          Initial Creation
***************************************************************************************************************/
PROCEDURE SP_DEENROLL_BUNDLE_ESN(
    IP_ESN IN sa.TABLE_PART_INST.PART_SERIAL_NO%TYPE ,
    OP_ERROR_CODE OUT NUMBER ,
    OP_ERROR_MSG OUT VARCHAR2)
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('Start of SP_DEENROLL_BUNDLE_ESN for ESN:'||IP_ESN);
  sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING', --IP_X_PARAM_NAME
  'Debug - Start of SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_ESN',                      --p_action
  SYSDATE,                                                                              --p_error_date
  IP_ESN,                                                                               --p_key
  'SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_ESN',                                       --p_program_name
  'Debug SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_ESN for ESN:'||IP_ESN                 --p_error_text
  );
  FOR ENROLLED_PE IN
  (SELECT PE.*
  FROM X_PROGRAM_ENROLLED PE
  WHERE 1                          = 1
  AND PE.X_ESN                     = IP_ESN
  AND PE.X_ENROLLMENT_STATUS      IN ('ENROLLED', 'ENROLLMENTSCHEDULED')
  AND NVL(PE.X_CHARGE_TYPE,'NULL') = 'BUNDLE'
  )
  LOOP
    sa.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_PROG( IP_ESN => IP_ESN , IP_PROGRAM_ENROLLED_OBJID => ENROLLED_PE.OBJID , OP_ERROR_CODE => OP_ERROR_CODE , OP_ERROR_MSG => OP_ERROR_MSG );
  END LOOP;
  sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING', --IP_X_PARAM_NAME
  'Debug - End of SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_ESN',                        --p_action
  SYSDATE,                                                                              --p_error_date
  IP_ESN,                                                                               --p_key
  'SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_ESN',                                       --p_program_name
  'Debug SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_ESN for ESN:'||IP_ESN                 --p_error_text
  );
  DBMS_OUTPUT.PUT_LINE('End of SP_DEENROLL_BUNDLE_ESN');
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Error SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_ESN for ESN:'||IP_ESN,                          --p_action
  SYSDATE,                                                                                                                                --p_error_date
  IP_ESN,                                                                                                                                 --p_key
  'SA.BILLING_BUNDLE_PKG.SP_DEENROLL_BUNDLE_ESN',                                                                                         --p_program_name
  'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
  );
  RAISE;
END SP_DEENROLL_BUNDLE_ESN;
/***************************************************************************************************************
Program Name       :   SP_INSERT_PROG_PURCH_DTL
Program Type       :   Stored procedure
Program Arguments  :   SA.X_PROGRAM_PURCH_DTL table columns
Returns            :   OP_STATUS_CODE
OP_STATUS_MESSAGE
Program Called     :   SA.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE
Description        :   Inserts record into SA.X_PROGRAM_PURCH_DTL table
Modified By            Modification     CR             Description
Date           Number
=============          ============     ======      ===================================
Jai Arza             07/08/2015    CR34962             Initial Creation
***************************************************************************************************************/
PROCEDURE SP_INSERT_PROG_PURCH_DTL(
    IP_OBJID                      IN sa.X_PROGRAM_PURCH_DTL.OBJID%TYPE ,
    IP_X_ESN                      IN sa.X_PROGRAM_PURCH_DTL.X_ESN%TYPE ,
    IP_X_AMOUNT                   IN sa.X_PROGRAM_PURCH_DTL.X_AMOUNT%TYPE ,
    IP_X_CHARGE_DESC              IN sa.X_PROGRAM_PURCH_DTL.X_CHARGE_DESC%TYPE ,
    IP_X_CYCLE_START_DATE         IN sa.X_PROGRAM_PURCH_DTL.X_CYCLE_START_DATE%TYPE ,
    IP_X_CYCLE_END_DATE           IN sa.X_PROGRAM_PURCH_DTL.X_CYCLE_END_DATE%TYPE ,
    IP_PGM_PURCH_DTL2PGM_ENROLLED IN sa.X_PROGRAM_PURCH_DTL.PGM_PURCH_DTL2PGM_ENROLLED%TYPE ,
    IP_PGM_PURCH_DTL2PROG_HDR     IN sa.X_PROGRAM_PURCH_DTL.PGM_PURCH_DTL2PROG_HDR%TYPE ,
    IP_PGM_PURCH_DTL2PENAL_PEND   IN sa.X_PROGRAM_PURCH_DTL.PGM_PURCH_DTL2PENAL_PEND%TYPE ,
    IP_X_TAX_AMOUNT               IN sa.X_PROGRAM_PURCH_DTL.X_TAX_AMOUNT%TYPE ,
    IP_X_E911_TAX_AMOUNT          IN sa.X_PROGRAM_PURCH_DTL.X_E911_TAX_AMOUNT%TYPE ,
    IP_X_USF_TAXAMOUNT            IN sa.X_PROGRAM_PURCH_DTL.X_USF_TAXAMOUNT%TYPE ,
    IP_X_RCRF_TAX_AMOUNT          IN sa.X_PROGRAM_PURCH_DTL.X_RCRF_TAX_AMOUNT%TYPE ,
    IP_X_PRIORITY                 IN sa.X_PROGRAM_PURCH_DTL.X_PRIORITY%TYPE ,
    OP_STATUS_CODE OUT NUMBER ,
    OP_STATUS_MESSAGE OUT VARCHAR2 )
AS
BEGIN
  OP_STATUS_CODE    := 0;
  OP_STATUS_MESSAGE := 'Success';
  DBMS_OUTPUT.PUT_LINE('Start of SP_INSERT_PROG_PURCH_DTL. Inserting objid:'||IP_OBJID);
  --BILLING_SEQ('X_PROGRAM_PURCH_DTL')
  INSERT
  INTO sa.X_PROGRAM_PURCH_DTL
    (
      OBJID ,
      X_ESN ,
      X_AMOUNT ,
      X_CHARGE_DESC ,
      X_CYCLE_START_DATE ,
      X_CYCLE_END_DATE ,
      PGM_PURCH_DTL2PGM_ENROLLED ,
      PGM_PURCH_DTL2PROG_HDR ,
      PGM_PURCH_DTL2PENAL_PEND ,
      X_TAX_AMOUNT ,
      X_E911_TAX_AMOUNT ,
      X_USF_TAXAMOUNT ,
      X_RCRF_TAX_AMOUNT ,
      X_PRIORITY
    )
    VALUES
    (
      IP_OBJID ,
      IP_X_ESN ,
      IP_X_AMOUNT ,
      IP_X_CHARGE_DESC ,
      IP_X_CYCLE_START_DATE ,
      IP_X_CYCLE_END_DATE ,
      IP_PGM_PURCH_DTL2PGM_ENROLLED ,
      IP_PGM_PURCH_DTL2PROG_HDR ,
      IP_PGM_PURCH_DTL2PENAL_PEND ,
      IP_X_TAX_AMOUNT ,
      IP_X_E911_TAX_AMOUNT ,
      IP_X_USF_TAXAMOUNT ,
      IP_X_RCRF_TAX_AMOUNT ,
      IP_X_PRIORITY
    );
  IF SQL%ROWCOUNT      = 1 THEN
    OP_STATUS_CODE    := 0;
    OP_STATUS_MESSAGE := 'Success';
  ELSE
    OP_STATUS_CODE    := 1;
    OP_STATUS_MESSAGE := 'Failure to insert record into X_PROGRAM_PURCH_DTL';
  END IF;
  DBMS_OUTPUT.PUT_LINE('End of SP_INSERT_PROG_PURCH_DTL');
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Error SA.BILLING_BUNDLE_PKG.SP_INSERT_PROG_PURCH_DTL for ESN:'||IP_X_ESN,                      --p_action
  SYSDATE,                                                                                                                                --p_error_date
  IP_X_ESN,                                                                                                                               --p_key
  'SA.BILLING_BUNDLE_PKG.SP_INSERT_PROG_PURCH_DTL',                                                                                       --p_program_name
  'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
  );
  RAISE;
END SP_INSERT_PROG_PURCH_DTL;
/***************************************************************************************************************
Program Name       :   SP_INSERT_PROG_PURCH_HDR
Program Type       :   Stored procedure
Program Arguments  :   SA.X_PROGRAM_PURCH_HDR table columns
Returns            :   OP_STATUS_CODE
OP_STATUS_MESSAGE
Program Called     :   SA.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE
Description        :   Inserts data into SA.X_PROGRAM_PURCH_HDR table
Modified By            Modification     CR             Description
Date           Number
=============          ============     ======      ===================================
Jai Arza           07/08/2015    CR34962             Initial Creation
***************************************************************************************************************/
PROCEDURE SP_INSERT_PROG_PURCH_HDR
  (
    IP_OBJID                  IN sa.X_PROGRAM_PURCH_HDR.OBJID%TYPE ,
    IP_X_RQST_SOURCE          IN sa.X_PROGRAM_PURCH_HDR.X_RQST_SOURCE%TYPE ,
    IP_X_RQST_TYPE            IN sa.X_PROGRAM_PURCH_HDR.X_RQST_TYPE%TYPE ,
    IP_X_RQST_DATE            IN sa.X_PROGRAM_PURCH_HDR.X_RQST_DATE%TYPE ,
    IP_X_ICS_APPLICATIONS     IN sa.X_PROGRAM_PURCH_HDR.X_ICS_APPLICATIONS%TYPE ,
    IP_X_MERCHANT_ID          IN sa.X_PROGRAM_PURCH_HDR.X_MERCHANT_ID%TYPE ,
    IP_X_MERCHANT_REF_NUMBER  IN sa.X_PROGRAM_PURCH_HDR.X_MERCHANT_REF_NUMBER%TYPE ,
    IP_X_OFFER_NUM            IN sa.X_PROGRAM_PURCH_HDR.X_OFFER_NUM%TYPE ,
    IP_X_QUANTITY             IN sa.X_PROGRAM_PURCH_HDR.X_QUANTITY%TYPE ,
    IP_X_MERCHANT_PRODUCT_SKU IN sa.X_PROGRAM_PURCH_HDR.X_MERCHANT_PRODUCT_SKU%TYPE ,
    IP_X_PAYMENT_LINE2PROGRAM IN sa.X_PROGRAM_PURCH_HDR.X_PAYMENT_LINE2PROGRAM%TYPE ,
    IP_X_PRODUCT_CODE         IN sa.X_PROGRAM_PURCH_HDR.X_PRODUCT_CODE%TYPE ,
    IP_X_IGNORE_AVS           IN sa.X_PROGRAM_PURCH_HDR.X_IGNORE_AVS%TYPE ,
    IP_X_USER_PO              IN sa.X_PROGRAM_PURCH_HDR.X_USER_PO%TYPE ,
    IP_X_AVS                  IN sa.X_PROGRAM_PURCH_HDR.X_AVS%TYPE ,
    IP_X_DISABLE_AVS          IN sa.X_PROGRAM_PURCH_HDR.X_DISABLE_AVS%TYPE ,
    IP_X_CUSTOMER_HOSTNAME    IN sa.X_PROGRAM_PURCH_HDR.X_CUSTOMER_HOSTNAME%TYPE ,
    IP_X_CUSTOMER_IPADDRESS   IN sa.X_PROGRAM_PURCH_HDR.X_CUSTOMER_IPADDRESS%TYPE ,
    IP_X_AUTH_REQUEST_ID      IN sa.X_PROGRAM_PURCH_HDR.X_AUTH_REQUEST_ID%TYPE ,
    IP_X_AUTH_CODE            IN sa.X_PROGRAM_PURCH_HDR.X_AUTH_CODE%TYPE ,
    IP_X_AUTH_TYPE            IN sa.X_PROGRAM_PURCH_HDR.X_AUTH_TYPE%TYPE ,
    IP_X_ICS_RCODE            IN sa.X_PROGRAM_PURCH_HDR.X_ICS_RCODE%TYPE ,
    IP_X_ICS_RFLAG            IN sa.X_PROGRAM_PURCH_HDR.X_ICS_RFLAG%TYPE ,
    IP_X_ICS_RMSG             IN sa.X_PROGRAM_PURCH_HDR.X_ICS_RMSG%TYPE ,
    IP_X_REQUEST_ID           IN sa.X_PROGRAM_PURCH_HDR.X_REQUEST_ID%TYPE ,
    IP_X_AUTH_AVS             IN sa.X_PROGRAM_PURCH_HDR.X_AUTH_AVS%TYPE ,
    IP_X_AUTH_RESPONSE        IN sa.X_PROGRAM_PURCH_HDR.X_AUTH_RESPONSE%TYPE ,
    IP_X_AUTH_TIME            IN sa.X_PROGRAM_PURCH_HDR.X_AUTH_TIME%TYPE ,
    IP_X_AUTH_RCODE           IN sa.X_PROGRAM_PURCH_HDR.X_AUTH_RCODE%TYPE ,
    IP_X_AUTH_RFLAG           IN sa.X_PROGRAM_PURCH_HDR.X_AUTH_RFLAG%TYPE ,
    IP_X_AUTH_RMSG            IN sa.X_PROGRAM_PURCH_HDR.X_AUTH_RMSG%TYPE ,
    IP_X_BILL_REQUEST_TIME    IN sa.X_PROGRAM_PURCH_HDR.X_BILL_REQUEST_TIME%TYPE ,
    IP_X_BILL_RCODE           IN sa.X_PROGRAM_PURCH_HDR.X_BILL_RCODE%TYPE ,
    IP_X_BILL_RFLAG           IN sa.X_PROGRAM_PURCH_HDR.X_BILL_RFLAG%TYPE ,
    IP_X_BILL_RMSG            IN sa.X_PROGRAM_PURCH_HDR.X_BILL_RMSG%TYPE ,
    IP_X_BILL_TRANS_REF_NO    IN sa.X_PROGRAM_PURCH_HDR.X_BILL_TRANS_REF_NO%TYPE ,
    IP_X_CUSTOMER_FIRSTNAME   IN sa.X_PROGRAM_PURCH_HDR.X_CUSTOMER_FIRSTNAME%TYPE ,
    IP_X_CUSTOMER_LASTNAME    IN sa.X_PROGRAM_PURCH_HDR.X_CUSTOMER_LASTNAME%TYPE ,
    IP_X_CUSTOMER_PHONE       IN sa.X_PROGRAM_PURCH_HDR.X_CUSTOMER_PHONE%TYPE ,
    IP_X_CUSTOMER_EMAIL       IN sa.X_PROGRAM_PURCH_HDR.X_CUSTOMER_EMAIL%TYPE ,
    IP_X_STATUS               IN sa.X_PROGRAM_PURCH_HDR.X_STATUS%TYPE ,
    IP_X_BILL_ADDRESS1        IN sa.X_PROGRAM_PURCH_HDR.X_BILL_ADDRESS1%TYPE ,
    IP_X_BILL_ADDRESS2        IN sa.X_PROGRAM_PURCH_HDR.X_BILL_ADDRESS2%TYPE ,
    IP_X_BILL_CITY            IN sa.X_PROGRAM_PURCH_HDR.X_BILL_CITY%TYPE ,
    IP_X_BILL_STATE           IN sa.X_PROGRAM_PURCH_HDR.X_BILL_STATE%TYPE ,
    IP_X_BILL_ZIP             IN sa.X_PROGRAM_PURCH_HDR.X_BILL_ZIP%TYPE ,
    IP_X_BILL_COUNTRY         IN sa.X_PROGRAM_PURCH_HDR.X_BILL_COUNTRY%TYPE ,
    IP_X_ESN                  IN sa.X_PROGRAM_PURCH_HDR.X_ESN%TYPE ,
    IP_X_AMOUNT               IN sa.X_PROGRAM_PURCH_HDR.X_AMOUNT%TYPE ,
    IP_X_TAX_AMOUNT           IN sa.X_PROGRAM_PURCH_HDR.X_TAX_AMOUNT%TYPE ,
    IP_X_AUTH_AMOUNT          IN sa.X_PROGRAM_PURCH_HDR.X_AUTH_AMOUNT%TYPE ,
    IP_X_BILL_AMOUNT          IN sa.X_PROGRAM_PURCH_HDR.X_BILL_AMOUNT%TYPE ,
    IP_X_USER                 IN sa.X_PROGRAM_PURCH_HDR.X_USER%TYPE ,
    IP_X_CREDIT_CODE          IN sa.X_PROGRAM_PURCH_HDR.X_CREDIT_CODE%TYPE ,
    IP_PURCH_HDR2CREDITCARD   IN sa.X_PROGRAM_PURCH_HDR.PURCH_HDR2CREDITCARD%TYPE ,
    IP_PURCH_HDR2BANK_ACCT    IN sa.X_PROGRAM_PURCH_HDR.PURCH_HDR2BANK_ACCT%TYPE ,
    IP_PURCH_HDR2USER         IN sa.X_PROGRAM_PURCH_HDR.PURCH_HDR2USER%TYPE ,
    IP_PURCH_HDR2ESN          IN sa.X_PROGRAM_PURCH_HDR.PURCH_HDR2ESN%TYPE ,
    IP_PURCH_HDR2RMSG_CODES   IN sa.X_PROGRAM_PURCH_HDR.PURCH_HDR2RMSG_CODES%TYPE ,
    IP_PURCH_HDR2CR_PURCH     IN sa.X_PROGRAM_PURCH_HDR.PURCH_HDR2CR_PURCH%TYPE ,
    IP_PROG_HDR2X_PYMT_SRC    IN sa.X_PROGRAM_PURCH_HDR.PROG_HDR2X_PYMT_SRC%TYPE ,
    IP_PROG_HDR2WEB_USER      IN sa.X_PROGRAM_PURCH_HDR.PROG_HDR2WEB_USER%TYPE ,
    IP_PROG_HDR2PROG_BATCH    IN sa.X_PROGRAM_PURCH_HDR.PROG_HDR2PROG_BATCH%TYPE ,
    IP_X_PAYMENT_TYPE         IN sa.X_PROGRAM_PURCH_HDR.X_PAYMENT_TYPE%TYPE ,
    IP_X_E911_TAX_AMOUNT      IN sa.X_PROGRAM_PURCH_HDR.X_E911_TAX_AMOUNT%TYPE ,
    IP_X_USF_TAXAMOUNT        IN sa.X_PROGRAM_PURCH_HDR.X_USF_TAXAMOUNT%TYPE ,
    IP_X_RCRF_TAX_AMOUNT      IN sa.X_PROGRAM_PURCH_HDR.X_RCRF_TAX_AMOUNT%TYPE ,
    IP_X_PROCESS_DATE         IN sa.X_PROGRAM_PURCH_HDR.X_PROCESS_DATE%TYPE ,
    IP_X_DISCOUNT_AMOUNT      IN sa.X_PROGRAM_PURCH_HDR.X_DISCOUNT_AMOUNT%TYPE ,
    IP_X_PRIORITY             IN sa.X_PROGRAM_PURCH_HDR.X_PRIORITY%TYPE ,
    OP_STATUS_CODE OUT NUMBER ,
    OP_STATUS_MESSAGE OUT VARCHAR2
  )
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('Start of SP_INSERT_PROG_PURCH_HDR with IP_OBJID:'||IP_OBJID);
  OP_STATUS_CODE    := 0;
  OP_STATUS_MESSAGE := 'Success';
  INSERT
  INTO sa.X_PROGRAM_PURCH_HDR
    (
      OBJID ,
      X_RQST_SOURCE ,
      X_RQST_TYPE ,
      X_RQST_DATE ,
      X_ICS_APPLICATIONS ,
      X_MERCHANT_ID ,
      X_MERCHANT_REF_NUMBER ,
      X_OFFER_NUM ,
      X_QUANTITY ,
      X_MERCHANT_PRODUCT_SKU ,
      X_PAYMENT_LINE2PROGRAM ,
      X_PRODUCT_CODE ,
      X_IGNORE_AVS ,
      X_USER_PO ,
      X_AVS ,
      X_DISABLE_AVS ,
      X_CUSTOMER_HOSTNAME ,
      X_CUSTOMER_IPADDRESS ,
      X_AUTH_REQUEST_ID ,
      X_AUTH_CODE ,
      X_AUTH_TYPE ,
      X_ICS_RCODE ,
      X_ICS_RFLAG ,
      X_ICS_RMSG ,
      X_REQUEST_ID ,
      X_AUTH_AVS ,
      X_AUTH_RESPONSE ,
      X_AUTH_TIME ,
      X_AUTH_RCODE ,
      X_AUTH_RFLAG ,
      X_AUTH_RMSG ,
      X_BILL_REQUEST_TIME ,
      X_BILL_RCODE ,
      X_BILL_RFLAG ,
      X_BILL_RMSG ,
      X_BILL_TRANS_REF_NO ,
      X_CUSTOMER_FIRSTNAME ,
      X_CUSTOMER_LASTNAME ,
      X_CUSTOMER_PHONE ,
      X_CUSTOMER_EMAIL ,
      X_STATUS ,
      X_BILL_ADDRESS1 ,
      X_BILL_ADDRESS2 ,
      X_BILL_CITY ,
      X_BILL_STATE ,
      X_BILL_ZIP ,
      X_BILL_COUNTRY ,
      X_ESN ,
      X_AMOUNT ,
      X_TAX_AMOUNT ,
      X_AUTH_AMOUNT ,
      X_BILL_AMOUNT ,
      X_USER ,
      X_CREDIT_CODE ,
      PURCH_HDR2CREDITCARD ,
      PURCH_HDR2BANK_ACCT ,
      PURCH_HDR2USER ,
      PURCH_HDR2ESN ,
      PURCH_HDR2RMSG_CODES ,
      PURCH_HDR2CR_PURCH ,
      PROG_HDR2X_PYMT_SRC ,
      PROG_HDR2WEB_USER ,
      PROG_HDR2PROG_BATCH ,
      X_PAYMENT_TYPE ,
      X_E911_TAX_AMOUNT ,
      X_USF_TAXAMOUNT ,
      X_RCRF_TAX_AMOUNT ,
      X_PROCESS_DATE ,
      X_DISCOUNT_AMOUNT ,
      X_PRIORITY
    )
    VALUES
    (
      IP_OBJID ,
      IP_X_RQST_SOURCE ,
      IP_X_RQST_TYPE ,
      IP_X_RQST_DATE ,
      IP_X_ICS_APPLICATIONS ,
      IP_X_MERCHANT_ID ,
      IP_X_MERCHANT_REF_NUMBER ,
      IP_X_OFFER_NUM ,
      IP_X_QUANTITY ,
      IP_X_MERCHANT_PRODUCT_SKU ,
      IP_X_PAYMENT_LINE2PROGRAM ,
      IP_X_PRODUCT_CODE ,
      IP_X_IGNORE_AVS ,
      IP_X_USER_PO ,
      IP_X_AVS ,
      IP_X_DISABLE_AVS ,
      IP_X_CUSTOMER_HOSTNAME ,
      IP_X_CUSTOMER_IPADDRESS ,
      IP_X_AUTH_REQUEST_ID ,
      IP_X_AUTH_CODE ,
      IP_X_AUTH_TYPE ,
      IP_X_ICS_RCODE ,
      IP_X_ICS_RFLAG ,
      IP_X_ICS_RMSG ,
      IP_X_REQUEST_ID ,
      IP_X_AUTH_AVS ,
      IP_X_AUTH_RESPONSE ,
      IP_X_AUTH_TIME ,
      IP_X_AUTH_RCODE ,
      IP_X_AUTH_RFLAG ,
      IP_X_AUTH_RMSG ,
      IP_X_BILL_REQUEST_TIME ,
      IP_X_BILL_RCODE ,
      IP_X_BILL_RFLAG ,
      IP_X_BILL_RMSG ,
      IP_X_BILL_TRANS_REF_NO ,
      IP_X_CUSTOMER_FIRSTNAME ,
      IP_X_CUSTOMER_LASTNAME ,
      IP_X_CUSTOMER_PHONE ,
      IP_X_CUSTOMER_EMAIL ,
      IP_X_STATUS ,
      IP_X_BILL_ADDRESS1 ,
      IP_X_BILL_ADDRESS2 ,
      IP_X_BILL_CITY ,
      IP_X_BILL_STATE ,
      IP_X_BILL_ZIP ,
      IP_X_BILL_COUNTRY ,
      IP_X_ESN ,
      IP_X_AMOUNT ,
      IP_X_TAX_AMOUNT ,
      IP_X_AUTH_AMOUNT ,
      IP_X_BILL_AMOUNT ,
      IP_X_USER ,
      IP_X_CREDIT_CODE ,
      IP_PURCH_HDR2CREDITCARD ,
      IP_PURCH_HDR2BANK_ACCT ,
      IP_PURCH_HDR2USER ,
      IP_PURCH_HDR2ESN ,
      IP_PURCH_HDR2RMSG_CODES ,
      IP_PURCH_HDR2CR_PURCH ,
      IP_PROG_HDR2X_PYMT_SRC ,
      IP_PROG_HDR2WEB_USER ,
      IP_PROG_HDR2PROG_BATCH ,
      IP_X_PAYMENT_TYPE ,
      IP_X_E911_TAX_AMOUNT ,
      IP_X_USF_TAXAMOUNT ,
      IP_X_RCRF_TAX_AMOUNT ,
      IP_X_PROCESS_DATE ,
      IP_X_DISCOUNT_AMOUNT ,
      IP_X_PRIORITY
    );
  IF SQL%ROWCOUNT      = 1 THEN
    OP_STATUS_CODE    := 0;
    OP_STATUS_MESSAGE := 'Success';
  ELSE
    OP_STATUS_CODE    := 1;
    OP_STATUS_MESSAGE := 'Failure to insert record into X_PROGRAM_PURCH_HDR';
  END IF;
  DBMS_OUTPUT.PUT_LINE('End of SP_INSERT_PROG_PURCH_HDR');
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Error SA.BILLING_BUNDLE_PKG.SP_INSERT_PROG_PURCH_HDR for ESN:'||IP_X_ESN,                      --p_action
  SYSDATE,                                                                                                                                --p_error_date
  IP_X_ESN,                                                                                                                               --p_key
  'SA.BILLING_BUNDLE_PKG.SP_INSERT_PROG_PURCH_HDR',                                                                                       --p_program_name
  'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
  );
  RAISE;
END SP_INSERT_PROG_PURCH_HDR;
/***************************************************************************************************************
Program Name       :   SP_INSERT_X_CC_PROG_TRANS
Program Type       :   Stored procedure
Program Arguments  :   SA.X_CC_PROG_TRANS table columns
Returns            :   OP_STATUS_CODE
OP_STATUS_MESSAGE
Program Called     :   SA.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE
Description        :   Inserts data into SA.X_CC_PROG_TRANS table
Modified By            Modification     CR             Description
Date           Number
=============          ============     ==========      ===================================
Jai Arza          07/08/2015       CR34962             Initial Creation
***************************************************************************************************************/
PROCEDURE SP_INSERT_X_CC_PROG_TRANS
  (
    IP_OBJID                    IN sa.X_CC_PROG_TRANS.OBJID%TYPE ,
    IP_X_IGNORE_BAD_CV          IN sa.X_CC_PROG_TRANS.X_IGNORE_BAD_CV%TYPE ,
    IP_X_IGNORE_AVS             IN sa.X_CC_PROG_TRANS.X_IGNORE_AVS%TYPE ,
    IP_X_AVS                    IN sa.X_CC_PROG_TRANS.X_AVS%TYPE ,
    IP_X_DISABLE_AVS            IN sa.X_CC_PROG_TRANS.X_DISABLE_AVS%TYPE ,
    IP_X_AUTH_AVS               IN sa.X_CC_PROG_TRANS.X_AUTH_AVS%TYPE ,
    IP_X_AUTH_CV_RESULT         IN sa.X_CC_PROG_TRANS.X_AUTH_CV_RESULT%TYPE ,
    IP_X_SCORE_FACTORS          IN sa.X_CC_PROG_TRANS.X_SCORE_FACTORS%TYPE ,
    IP_X_SCORE_HOST_SEVERITY    IN sa.X_CC_PROG_TRANS.X_SCORE_HOST_SEVERITY%TYPE ,
    IP_X_SCORE_RCODE            IN sa.X_CC_PROG_TRANS.X_SCORE_RCODE%TYPE ,
    IP_X_SCORE_RFLAG            IN sa.X_CC_PROG_TRANS.X_SCORE_RFLAG%TYPE ,
    IP_X_SCORE_RMSG             IN sa.X_CC_PROG_TRANS.X_SCORE_RMSG%TYPE ,
    IP_X_SCORE_RESULT           IN sa.X_CC_PROG_TRANS.X_SCORE_RESULT%TYPE ,
    IP_X_SCORE_TIME_LOCAL       IN sa.X_CC_PROG_TRANS.X_SCORE_TIME_LOCAL%TYPE ,
    IP_X_CUSTOMER_CC_NUMBER     IN sa.X_CC_PROG_TRANS.X_CUSTOMER_CC_NUMBER%TYPE ,
    IP_X_CUSTOMER_CC_EXPMO      IN sa.X_CC_PROG_TRANS.X_CUSTOMER_CC_EXPMO%TYPE ,
    IP_X_CUSTOMER_CC_EXPYR      IN sa.X_CC_PROG_TRANS.X_CUSTOMER_CC_EXPYR%TYPE ,
    IP_X_CUSTOMER_CVV_NUM       IN sa.X_CC_PROG_TRANS.X_CUSTOMER_CVV_NUM%TYPE ,
    IP_X_CC_LASTFOUR            IN sa.X_CC_PROG_TRANS.X_CC_LASTFOUR%TYPE ,
    IP_X_CC_TRANS2X_CREDIT_CARD IN sa.X_CC_PROG_TRANS.X_CC_TRANS2X_CREDIT_CARD%TYPE ,
    IP_X_CC_TRANS2X_PURCH_HDR   IN sa.X_CC_PROG_TRANS.X_CC_TRANS2X_PURCH_HDR%TYPE ,
    OP_STATUS_CODE OUT NUMBER ,
    OP_STATUS_MESSAGE OUT VARCHAR2
  )
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('Start of SP_INSERT_X_CC_PROG_TRANS with IP_OBJID:'||IP_OBJID);
  OP_STATUS_CODE    := 0;
  OP_STATUS_MESSAGE := 'Success';
  INSERT
  INTO sa.X_CC_PROG_TRANS
    (
      OBJID ,
      X_IGNORE_BAD_CV ,
      X_IGNORE_AVS ,
      X_AVS ,
      X_DISABLE_AVS ,
      X_AUTH_AVS ,
      X_AUTH_CV_RESULT ,
      X_SCORE_FACTORS ,
      X_SCORE_HOST_SEVERITY ,
      X_SCORE_RCODE ,
      X_SCORE_RFLAG ,
      X_SCORE_RMSG ,
      X_SCORE_RESULT ,
      X_SCORE_TIME_LOCAL ,
      X_CUSTOMER_CC_NUMBER ,
      X_CUSTOMER_CC_EXPMO ,
      X_CUSTOMER_CC_EXPYR ,
      X_CUSTOMER_CVV_NUM ,
      X_CC_LASTFOUR ,
      X_CC_TRANS2X_CREDIT_CARD ,
      X_CC_TRANS2X_PURCH_HDR
    )
    VALUES
    (
      IP_OBJID ,
      IP_X_IGNORE_BAD_CV ,
      IP_X_IGNORE_AVS ,
      IP_X_AVS ,
      IP_X_DISABLE_AVS ,
      IP_X_AUTH_AVS ,
      IP_X_AUTH_CV_RESULT ,
      IP_X_SCORE_FACTORS ,
      IP_X_SCORE_HOST_SEVERITY ,
      IP_X_SCORE_RCODE ,
      IP_X_SCORE_RFLAG ,
      IP_X_SCORE_RMSG ,
      IP_X_SCORE_RESULT ,
      IP_X_SCORE_TIME_LOCAL ,
      IP_X_CUSTOMER_CC_NUMBER ,
      IP_X_CUSTOMER_CC_EXPMO ,
      IP_X_CUSTOMER_CC_EXPYR ,
      IP_X_CUSTOMER_CVV_NUM ,
      IP_X_CC_LASTFOUR ,
      IP_X_CC_TRANS2X_CREDIT_CARD ,
      IP_X_CC_TRANS2X_PURCH_HDR
    );
  IF SQL%ROWCOUNT      = 1 THEN
    OP_STATUS_CODE    := 0;
    OP_STATUS_MESSAGE := 'Success';
  ELSE
    OP_STATUS_CODE    := 1;
    OP_STATUS_MESSAGE := 'Failure to insert record into X_CC_PROG_TRANS';
  END IF;
  DBMS_OUTPUT.PUT_LINE('End of SP_INSERT_X_CC_PROG_TRANS');
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END SP_INSERT_X_CC_PROG_TRANS;
/***************************************************************************************************************
Program Name       :   SP_INSERT_X_ACH_PROG_TRANS
Program Type       :   Stored procedure
Program Arguments  :   SA.X_ACH_PROG_TRANS table columns
Returns            :   OP_STATUS_CODE
OP_STATUS_MESSAGE
Program Called     :   None
Description        :   Inserts data into SA.X_ACH_PROG_TRANS table
Modified By            Modification     CR             Description
Date           Number
=============          ============     ==========      ===================================
Jai Arza          07/08/2015       CR34962             Initial Creation
***************************************************************************************************************/
PROCEDURE SP_INSERT_X_ACH_PROG_TRANS
  (
    IP_OBJID                    IN sa.X_ACH_PROG_TRANS.OBJID%TYPE ,
    IP_X_BANK_NUM               IN sa.X_ACH_PROG_TRANS.X_BANK_NUM%TYPE ,
    IP_X_ECP_ACCOUNT_NO         IN sa.X_ACH_PROG_TRANS.X_ECP_ACCOUNT_NO%TYPE ,
    IP_X_ECP_ACCOUNT_TYPE       IN sa.X_ACH_PROG_TRANS.X_ECP_ACCOUNT_TYPE%TYPE ,
    IP_X_ECP_RDFI               IN sa.X_ACH_PROG_TRANS.X_ECP_RDFI%TYPE ,
    IP_X_ECP_SETTLEMENT_METHOD  IN sa.X_ACH_PROG_TRANS.X_ECP_SETTLEMENT_METHOD%TYPE ,
    IP_X_ECP_PAYMENT_MODE       IN sa.X_ACH_PROG_TRANS.X_ECP_PAYMENT_MODE%TYPE ,
    IP_X_ECP_DEBIT_REQUEST_ID   IN sa.X_ACH_PROG_TRANS.X_ECP_DEBIT_REQUEST_ID%TYPE ,
    IP_X_ECP_VERFICATION_LEVEL  IN sa.X_ACH_PROG_TRANS.X_ECP_VERFICATION_LEVEL%TYPE ,
    IP_X_ECP_REF_NUMBER         IN sa.X_ACH_PROG_TRANS.X_ECP_REF_NUMBER%TYPE ,
    IP_X_ECP_DEBIT_REF_NUMBER   IN sa.X_ACH_PROG_TRANS.X_ECP_DEBIT_REF_NUMBER%TYPE ,
    IP_X_ECP_DEBIT_AVS          IN sa.X_ACH_PROG_TRANS.X_ECP_DEBIT_AVS%TYPE ,
    IP_X_ECP_DEBIT_AVS_RAW      IN sa.X_ACH_PROG_TRANS.X_ECP_DEBIT_AVS_RAW%TYPE ,
    IP_X_ECP_RCODE              IN sa.X_ACH_PROG_TRANS.X_ECP_RCODE%TYPE ,
    IP_X_ECP_TRANS_ID           IN sa.X_ACH_PROG_TRANS.X_ECP_TRANS_ID%TYPE ,
    IP_X_ECP_REF_NO             IN sa.X_ACH_PROG_TRANS.X_ECP_REF_NO%TYPE ,
    IP_X_ECP_RESULT_CODE        IN sa.X_ACH_PROG_TRANS.X_ECP_RESULT_CODE%TYPE ,
    IP_X_ECP_RFLAG              IN sa.X_ACH_PROG_TRANS.X_ECP_RFLAG%TYPE ,
    IP_X_ECP_RMSG               IN sa.X_ACH_PROG_TRANS.X_ECP_RMSG%TYPE ,
    IP_X_ECP_CREDIT_REF_NUMBER  IN sa.X_ACH_PROG_TRANS.X_ECP_CREDIT_REF_NUMBER%TYPE ,
    IP_X_ECP_CREDIT_TRANS_ID    IN sa.X_ACH_PROG_TRANS.X_ECP_CREDIT_TRANS_ID%TYPE ,
    IP_X_DECLINE_AVS_FLAGS      IN sa.X_ACH_PROG_TRANS.X_DECLINE_AVS_FLAGS%TYPE ,
    IP_ACH_TRANS2X_PURCH_HDR    IN sa.X_ACH_PROG_TRANS.ACH_TRANS2X_PURCH_HDR%TYPE ,
    IP_ACH_TRANS2X_BANK_ACCOUNT IN sa.X_ACH_PROG_TRANS.ACH_TRANS2X_BANK_ACCOUNT%TYPE ,
    IP_ACH_TRANS2PGM_ENROLLED   IN sa.X_ACH_PROG_TRANS.ACH_TRANS2PGM_ENROLLED%TYPE ,
    OP_STATUS_CODE OUT NUMBER ,
    OP_STATUS_MESSAGE OUT VARCHAR2
  )
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('Start of SP_INSERT_X_ACH_PROG_TRANS with IP_OBJID:'||IP_OBJID);
  OP_STATUS_CODE    := 0;
  OP_STATUS_MESSAGE := 'Success';
  INSERT
  INTO sa.X_ACH_PROG_TRANS
    (
      OBJID ,
      X_BANK_NUM ,
      X_ECP_ACCOUNT_NO ,
      X_ECP_ACCOUNT_TYPE ,
      X_ECP_RDFI ,
      X_ECP_SETTLEMENT_METHOD ,
      X_ECP_PAYMENT_MODE ,
      X_ECP_DEBIT_REQUEST_ID ,
      X_ECP_VERFICATION_LEVEL ,
      X_ECP_REF_NUMBER ,
      X_ECP_DEBIT_REF_NUMBER ,
      X_ECP_DEBIT_AVS ,
      X_ECP_DEBIT_AVS_RAW ,
      X_ECP_RCODE ,
      X_ECP_TRANS_ID ,
      X_ECP_REF_NO ,
      X_ECP_RESULT_CODE ,
      X_ECP_RFLAG ,
      X_ECP_RMSG ,
      X_ECP_CREDIT_REF_NUMBER ,
      X_ECP_CREDIT_TRANS_ID ,
      X_DECLINE_AVS_FLAGS ,
      ACH_TRANS2X_PURCH_HDR ,
      ACH_TRANS2X_BANK_ACCOUNT ,
      ACH_TRANS2PGM_ENROLLED
    )
    VALUES
    (
      IP_OBJID ,
      IP_X_BANK_NUM ,
      IP_X_ECP_ACCOUNT_NO ,
      IP_X_ECP_ACCOUNT_TYPE ,
      IP_X_ECP_RDFI ,
      IP_X_ECP_SETTLEMENT_METHOD ,
      IP_X_ECP_PAYMENT_MODE ,
      IP_X_ECP_DEBIT_REQUEST_ID ,
      IP_X_ECP_VERFICATION_LEVEL ,
      IP_X_ECP_REF_NUMBER ,
      IP_X_ECP_DEBIT_REF_NUMBER ,
      IP_X_ECP_DEBIT_AVS ,
      IP_X_ECP_DEBIT_AVS_RAW ,
      IP_X_ECP_RCODE ,
      IP_X_ECP_TRANS_ID ,
      IP_X_ECP_REF_NO ,
      IP_X_ECP_RESULT_CODE ,
      IP_X_ECP_RFLAG ,
      IP_X_ECP_RMSG ,
      IP_X_ECP_CREDIT_REF_NUMBER ,
      IP_X_ECP_CREDIT_TRANS_ID ,
      IP_X_DECLINE_AVS_FLAGS ,
      IP_ACH_TRANS2X_PURCH_HDR ,
      IP_ACH_TRANS2X_BANK_ACCOUNT ,
      IP_ACH_TRANS2PGM_ENROLLED
    );
  IF SQL%ROWCOUNT      = 1 THEN
    OP_STATUS_CODE    := 0;
    OP_STATUS_MESSAGE := 'Success';
  ELSE
    OP_STATUS_CODE    := 1;
    OP_STATUS_MESSAGE := 'Failure to insert record into SA.X_ACH_PROG_TRANS';
  END IF;
  DBMS_OUTPUT.PUT_LINE('End of SP_INSERT_X_ACH_PROG_TRANS');
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
END SP_INSERT_X_ACH_PROG_TRANS;
/***************************************************************************************************************
Program Name       :   SP_GET_PAYMENT_SOURCE
Program Type       :   Stored procedure
Program Arguments  :   IP_PAY_SOURCE_OBJID
Returns            :   OP_PE_PAYMENT_SOURCE
OP_PAYMENT_SOURCE_TYPE
OP_CREDIT_CARD_OBJID
OP_BANK_ACCOUNT_OBJID
OP_RESULT
OP_MSG
Program Called     :   SA.ERROR_LOG_PKG.SP_INSERT_PROGRAM_ERROR_LOG
Description        :   This procedure will return the payment source for input
payment source objid.
Modified By            Modification     CR             Description
Date           Number
=============          ============     ======      ===================================
Jai Arza          07/08/2015      34962             Initial Creation
***************************************************************************************************************/
PROCEDURE SP_GET_PAYMENT_SOURCE
  (
    IP_PAY_SOURCE_OBJID IN sa.X_PAYMENT_SOURCE.OBJID%TYPE ,
    OP_PE_PAYMENT_SOURCE OUT sa.X_PAYMENT_SOURCE.OBJID%TYPE ,
    OP_PAYMENT_SOURCE_TYPE OUT sa.X_PAYMENT_SOURCE.X_PYMT_TYPE%TYPE ,
    OP_CREDIT_CARD_OBJID OUT sa.X_PAYMENT_SOURCE.PYMT_SRC2X_CREDIT_CARD%TYPE ,
    OP_BANK_ACCOUNT_OBJID OUT sa.X_PAYMENT_SOURCE.PYMT_SRC2X_BANK_ACCOUNT%TYPE ,
    OP_RESULT OUT NUMBER ,
    OP_MSG OUT VARCHAR2
  )
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Start of SP_GET_PAYMENT_SOURCE with IP_PAY_SOURCE_OBJID: '||IP_PAY_SOURCE_OBJID);
  OP_RESULT := 0;
  OP_MSG    := 'Success';
  SELECT PS.OBJID ,
    PS.X_PYMT_TYPE ,
    PS.PYMT_SRC2X_CREDIT_CARD ,
    PS.PYMT_SRC2X_BANK_ACCOUNT
  INTO OP_PE_PAYMENT_SOURCE ,
    OP_PAYMENT_SOURCE_TYPE ,
    OP_CREDIT_CARD_OBJID ,
    OP_BANK_ACCOUNT_OBJID
  FROM sa.X_PAYMENT_SOURCE PS
  WHERE PS.OBJID = IP_PAY_SOURCE_OBJID;
  DBMS_OUTPUT.PUT_LINE ('OP_PE_PAYMENT_SOURCE: '||OP_PE_PAYMENT_SOURCE);
  DBMS_OUTPUT.PUT_LINE ('OP_PAYMENT_SOURCE_TYPE: '||OP_PAYMENT_SOURCE_TYPE);
  DBMS_OUTPUT.PUT_LINE ('OP_CREDIT_CARD_OBJID: '||OP_CREDIT_CARD_OBJID);
  DBMS_OUTPUT.PUT_LINE ('OP_BANK_ACCOUNT_OBJID: '||OP_BANK_ACCOUNT_OBJID);
  DBMS_OUTPUT.PUT_LINE ('End of SP_GET_PAYMENT_SOURCE');
EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
  DBMS_OUTPUT.PUT_LINE ('NO_DATA_FOUND in payment source for objid: '||IP_PAY_SOURCE_OBJID);
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('Error in payment source for objid: '||IP_PAY_SOURCE_OBJID);
  GLOBAL_ERROR_MESSAGE := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  sa.ERROR_LOG_PKG.SP_INSERT_PROGRAM_ERROR_LOG( IP_SOURCE => 'SA.BILLING_BUNDLE_PKG.RECURRING_PAYMENT_BUNDLE', IP_ERROR_CODE => '-100', IP_ERROR_MSG => GLOBAL_ERROR_MESSAGE, IP_DATE => SYSDATE, IP_DESCRIPTION => 'NO PAYMENT SOURCE FOUND FOR '|| TO_CHAR (IP_PAY_SOURCE_OBJID), IP_SEVERITY => 2 );
  OP_RESULT := - 100;
  OP_MSG    := 'NO PAYMENT SOURCE FOUND FOR ' || TO_CHAR (IP_PAY_SOURCE_OBJID);
END SP_GET_PAYMENT_SOURCE;
/***************************************************************************************************************
Program Name       :   FN_GET_NEXT_CYCLE_DATE
Program Type       :   Stored procedure
Program Arguments  :   IP_PROG_PARAM_OBJID   IN NUMBER,
IP_CURRENT_CYCLE_DATE
Returns            :   Date
Program Called     :   None
Description        :   This function will return next charge date.
Modified By            Modification     PCR             Description
Date           Number
=============          ============     ======      ===================================
Jai Arza             07/08/2015                 Initial Creation
***************************************************************************************************************/
FUNCTION FN_GET_NEXT_CYCLE_DATE(
    IP_PROG_PARAM_OBJID   IN NUMBER,
    IP_CURRENT_CYCLE_DATE IN DATE )
  RETURN DATE
IS
  L_NEXT_CYCLE_DATE DATE;
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Start of FN_GET_NEXT_CYCLE_DATE with IP_PROG_PARAM_OBJID:'||IP_PROG_PARAM_OBJID||', IP_CURRENT_CYCLE_DATE:'||IP_CURRENT_CYCLE_DATE);
  SELECT DECODE (X_CHARGE_FRQ_CODE, 'MONTHLY', ADD_MONTHS ( IP_CURRENT_CYCLE_DATE, 1), 'LOWBALANCE', NULL, 'PASTDUE', NULL, TRUNC (NVL (IP_CURRENT_CYCLE_DATE, SYSDATE)) + TO_NUMBER (X_CHARGE_FRQ_CODE) )
  INTO L_NEXT_CYCLE_DATE
  FROM sa.X_PROGRAM_PARAMETERS
  WHERE OBJID = IP_PROG_PARAM_OBJID;
  RETURN L_NEXT_CYCLE_DATE;
  DBMS_OUTPUT.PUT_LINE ('End of FN_GET_NEXT_CYCLE_DATE');
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;
END FN_GET_NEXT_CYCLE_DATE;
/***************************************************************************************************************
Program Name       :   SP_GET_CREDIT_CARD_INFO
Program Type       :   Stored procedure
Program Arguments  :   IP_CREDIT_CARD_OBJID
Returns            :   OP_CREDIT_CARD_REC
OP_RESULT
OP_MSG
Program Called     :   SA.ERROR_LOG_PKG.SP_INSERT_PROGRAM_ERROR_LOG
Description        :   This procedure will return credit card information.
Modified By            Modification     PCR             Description
Date           Number
=============          ============     ======      ===================================
Jai Arza           07/23/2015      34962           Initial Creation
***************************************************************************************************************/
PROCEDURE SP_GET_CREDIT_CARD_INFO(
    IP_CREDIT_CARD_OBJID IN sa.TABLE_X_CREDIT_CARD.OBJID%TYPE ,
    OP_CREDIT_CARD_REC OUT sa.TABLE_X_CREDIT_CARD%ROWTYPE ,
    OP_RESULT OUT NUMBER ,
    OP_MSG OUT VARCHAR2 )
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Start of SP_GET_CREDIT_CARD_INFO with IP_CREDIT_CARD_OBJID:'||IP_CREDIT_CARD_OBJID);
  OP_RESULT := 0;
  OP_MSG    := 'Success';
  SELECT OBJID ,
    X_CUSTOMER_CC_NUMBER ,
    X_CUSTOMER_CC_EXPMO ,
    X_CUSTOMER_CC_EXPYR ,
    X_CC_TYPE ,
    X_CUSTOMER_CC_CV_NUMBER ,
    REGEXP_REPLACE(X_CUSTOMER_FIRSTNAME, '[^0-9 A-Za-z]', '') ,
    REGEXP_REPLACE(X_CUSTOMER_LASTNAME, '[^0-9 A-Za-z]', '') ,
    X_CUSTOMER_PHONE ,
    X_CUSTOMER_EMAIL ,
    X_MAX_PURCH_AMT ,
    X_MAX_TRANS_PER_MONTH ,
    X_MAX_PURCH_AMT_PER_MONTH ,
    X_CHANGEDATE ,
    X_ORIGINAL_INSERT_DATE ,
    X_CHANGEDBY ,
    X_CC_COMMENTS ,
    X_MOMS_MAIDEN ,
    X_CREDIT_CARD2CONTACT ,
    X_CREDIT_CARD2ADDRESS ,
    X_CARD_STATUS ,
    X_MAX_ILD_PURCH_AMT ,
    X_MAX_ILD_PURCH_MONTH ,
    X_CREDIT_CARD2BUS_ORG ,
    X_CUST_CC_NUM_KEY ,
    X_CUST_CC_NUM_ENC ,
    CREDITCARD2CERT
  INTO OP_CREDIT_CARD_REC
  FROM sa.TABLE_X_CREDIT_CARD
  WHERE OBJID = IP_CREDIT_CARD_OBJID;
  DBMS_OUTPUT.PUT_LINE ('End of SP_GET_CREDIT_CARD_INFO');
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE (' No CreditCard record found for '|| TO_CHAR (IP_CREDIT_CARD_OBJID));
  GLOBAL_ERROR_MESSAGE := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  sa.ERROR_LOG_PKG.SP_INSERT_PROGRAM_ERROR_LOG( IP_SOURCE => 'SA.BILLING_BUNDLE_PKG.SP_GET_CREDIT_CARD_INFO', IP_ERROR_CODE => '-101', IP_ERROR_MSG => GLOBAL_ERROR_MESSAGE, IP_DATE => SYSDATE, IP_DESCRIPTION => ' No CreditCard record found for '|| TO_CHAR (IP_CREDIT_CARD_OBJID), IP_SEVERITY => 2 );
  OP_RESULT := - 101;
  OP_MSG    := ' No CreditCard record found for ' || TO_CHAR (IP_CREDIT_CARD_OBJID);
END SP_GET_CREDIT_CARD_INFO;
/***************************************************************************************************************
Program Name       :   SP_GET_BANK_ACCOUNT
Program Type       :   Stored procedure
Program Arguments  :   L_BANK_ACCOUNT_OBJID
Returns            :   OP_BANK_ACCT_REC
OP_RESULT
OP_MSG
Program Called     :   SA.ERROR_LOG_PKG.SP_INSERT_PROGRAM_ERROR_LOG
Description        :   This procedure will return bank account details
Modified By            Modification     PCR             Description
Date           Number
=============          ============     ======      ===================================
Jai Arza           07/23/2015      34962           Initial Creation
***************************************************************************************************************/
PROCEDURE SP_GET_BANK_ACCOUNT(
    L_BANK_ACCOUNT_OBJID IN sa.TABLE_X_BANK_ACCOUNT.OBJID%TYPE ,
    OP_BANK_ACCT_REC OUT sa.TABLE_X_BANK_ACCOUNT%ROWTYPE ,
    OP_RESULT OUT NUMBER ,
    OP_MSG OUT VARCHAR2 )
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Start of SP_GET_BANK_ACCOUNT with L_BANK_ACCOUNT_OBJID:'||L_BANK_ACCOUNT_OBJID);
  OP_RESULT := 0;
  OP_MSG    := 'Success';
  SELECT OBJID ,
    X_BANK_NUM ,
    X_CUSTOMER_ACCT ,
    X_ROUTING ,
    X_ABA_TRANSIT ,
    X_BANK_NAME ,
    X_STATUS ,
    REGEXP_REPLACE(X_CUSTOMER_FIRSTNAME, '[^0-9 A-Za-z]', '') ,
    REGEXP_REPLACE(X_CUSTOMER_LASTNAME, '[^0-9 A-Za-z]', '') ,
    X_CUSTOMER_PHONE ,
    X_CUSTOMER_EMAIL ,
    X_MAX_PURCH_AMT ,
    X_MAX_TRANS_PER_MONTH ,
    X_MAX_PURCH_AMT_PER_MONTH ,
    X_CHANGEDATE ,
    X_ORIGINAL_INSERT_DATE ,
    X_CHANGEDBY ,
    X_CC_COMMENTS ,
    X_MOMS_MAIDEN ,
    X_BANK_ACCT2CONTACT ,
    X_BANK_ACCT2ADDRESS ,
    X_BANK_ACCOUNT2BUS_ORG ,
    BANK2CERT ,
    X_CUSTOMER_ACCT_KEY ,
    X_CUSTOMER_ACCT_ENC
  INTO OP_BANK_ACCT_REC
  FROM sa.TABLE_X_BANK_ACCOUNT
  WHERE OBJID = L_BANK_ACCOUNT_OBJID;
  DBMS_OUTPUT.PUT_LINE ('End of SP_GET_BANK_ACCOUNT');
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE ('Error while processing bank account: '|| TO_CHAR (L_BANK_ACCOUNT_OBJID));
  GLOBAL_ERROR_MESSAGE := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  sa.ERROR_LOG_PKG.SP_INSERT_PROGRAM_ERROR_LOG( IP_SOURCE => 'SA.BILLING_BUNDLE_PKG.SP_GET_BANK_ACCOUNT', IP_ERROR_CODE => '-100', IP_ERROR_MSG => GLOBAL_ERROR_MESSAGE, IP_DATE => SYSDATE, IP_DESCRIPTION => 'Error while processing bank account: '|| TO_CHAR (L_BANK_ACCOUNT_OBJID), IP_SEVERITY => 2 );
  OP_RESULT := -100;
  OP_MSG    := 'No record found for the bank account: '|| TO_CHAR (L_BANK_ACCOUNT_OBJID);
END SP_GET_BANK_ACCOUNT;
/***************************************************************************************************************
Program Name       :   SP_GET_ADDRESS_INFO
Program Type       :   Stored procedure
Program Arguments  :   IP_ADDRESS_OBJID
Returns            :   OP_ADDRESS_REC
OP_RESULT
OP_MSG
Program Called     :   SA.ERROR_LOG_PKG.SP_INSERT_PROGRAM_ERROR_LOG
Description        :   This procedure will get address information.
Modified By            Modification     PCR             Description
Date           Number
=============          ============     ======      ===================================
Jai Arza           07/23/2015      34962           Initial Creation
***************************************************************************************************************/
PROCEDURE SP_GET_ADDRESS_INFO(
    IP_ADDRESS_OBJID IN sa.TABLE_ADDRESS.OBJID%TYPE ,
    OP_ADDRESS_REC OUT sa.TABLE_ADDRESS%ROWTYPE ,
    OP_RESULT OUT NUMBER ,
    OP_MSG OUT VARCHAR2 )
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Start of SP_GET_ADDRESS_INFO with IP_ADDRESS_OBJID:'||IP_ADDRESS_OBJID);
  OP_RESULT := 0;
  OP_MSG    := 'Success';
  SELECT OBJID,
    REGEXP_REPLACE(ADDRESS, '[^0-9 A-ZA-Z.-]', ''),
    REGEXP_REPLACE(S_ADDRESS, '[^0-9 A-ZA-Z.-]', ''),
    REGEXP_REPLACE(CITY, '[^0-9 A-ZA-Z.-]', ''),
    REGEXP_REPLACE(S_CITY, '[^0-9 A-ZA-Z.-]', ''),
    REGEXP_REPLACE(STATE, '[^0-9 A-ZA-Z.-]', ''),
    REGEXP_REPLACE(S_STATE, '[^0-9 A-ZA-Z.-]', ''),
    REGEXP_REPLACE(ZIPCODE, '[^0-9 A-ZA-Z.-]', ''),
    REGEXP_REPLACE(ADDRESS_2, '[^0-9 A-ZA-Z.-]', ''),
    DEV,
    ADDRESS2TIME_ZONE,
    ADDRESS2COUNTRY,
    ADDRESS2STATE_PROV,
    UPDATE_STAMP,
    ADDRESS2E911
  INTO OP_ADDRESS_REC
  FROM sa.TABLE_ADDRESS
  WHERE OBJID = IP_ADDRESS_OBJID;
  DBMS_OUTPUT.PUT_LINE ('End of SP_GET_ADDRESS_INFO');
EXCEPTION
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE (' No Address record found for '|| TO_CHAR (IP_ADDRESS_OBJID));
  GLOBAL_ERROR_MESSAGE := SQLCODE || SUBSTR (SQLERRM, 1, 100);
  sa.ERROR_LOG_PKG.SP_INSERT_PROGRAM_ERROR_LOG( IP_SOURCE => 'SA.BILLING_BUNDLE_PKG.SP_GET_ADDRESS_INFO', IP_ERROR_CODE => SQLCODE, IP_ERROR_MSG => GLOBAL_ERROR_MESSAGE, IP_DATE => SYSDATE, IP_DESCRIPTION => ' No Address record found for '|| TO_CHAR (IP_ADDRESS_OBJID), IP_SEVERITY => 2 );
  OP_RESULT := SQLCODE;
  OP_MSG    := ' No Address record found for ' || TO_CHAR (IP_ADDRESS_OBJID);
  RAISE;
END SP_GET_ADDRESS_INFO;
/***************************************************************************************************************
Program Name       :   SP_RECURRING_PAYMENT_BUNDLE
Program Type       :   Stored procedure
Program Arguments  :   IP_BUS_ORG
IP_PRIORITY
Returns            :   OP_RESULT
OP_MSG
Program Called     :   SA.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE
SA.BILLING_SEQ
SP_GET_PAYMENT_SOURCE
SA.SP_TAXES.TAX_RULES_BILLING
SA.SP_TAXES.TAX_RULES_PROGS_DATA_BILLING
SP_TAXES.COMPUTEUSFTAX_BILLING
SP_TAXES.COMPUTEMISCTAX_BILLING
SA.ENROLL_PROMO_PKG.SP_VALIDATE_PROMO
SP_TAXES.COMPUTETAX_BILLING
SP_TAXES.COMPUTEE911TAX_BILLING
SP_TAXES.COMPUTEE911SURCHARGE_BILLING
SP_TAXES.GETTAX2_BILL
SP_TAXES.GETTAX_BILL
SA.BILLING_BUNDLE_PKG.FN_GET_NEXT_CYCLE_DATE
SA.BILLING_BUNDLE_PKG.SP_INSERT_PROG_PURCH_DTL
SA.BILLING_BUNDLE_PKG.SP_GET_CREDIT_CARD_INFO
SA.BILLING_BUNDLE_PKG.SP_GET_ADDRESS_INFO
SA.BILLING_BUNDLE_PKG.SP_INSERT_PROG_PURCH_HDR
SA.BILLING_BUNDLE_PKG.SP_INSERT_X_CC_PROG_TRANS
Description        :   This procedure will handle recurring payment for bundled ESNs
Modified By            Modification     PCR             Description
Date           Number
=============          ============     ======      ===================================
Jai Arza          07/08/2015      34962          Initial Creation
***************************************************************************************************************/
PROCEDURE SP_RECURRING_PAYMENT_BUNDLE(
    IP_BUS_ORG  IN VARCHAR2 DEFAULT 'TRACFONE',
    IP_PRIORITY IN VARCHAR2 DEFAULT NULL,
    OP_RESULT OUT NUMBER,
    OP_MSG OUT VARCHAR2 )
IS
  V_CREDIT_CARD_REC sa.TABLE_X_CREDIT_CARD%ROWTYPE;
  L_MER_REF_NO VARCHAR2 (200);
  ADDRESS sa.TABLE_ADDRESS%ROWTYPE;
  CLEAR_ADDRESS sa.TABLE_ADDRESS%ROWTYPE;
  BANK sa.TABLE_ADDRESS%ROWTYPE;
  L_CHILD_CHARGE_DESC      VARCHAR2 (255);
  X_PY_PUR_HDR_ID          NUMBER;
  L_PRIM_PRICE_ORIG        NUMBER (10, 2) := 0;
  L_PRIM_PRICE_P           NUMBER (10, 2) := 0;
  L_PRIM_USF_TAX_PERCENT   NUMBER;
  L_PRIM_USF_TAX           NUMBER (10, 2) := 0;
  L_PRIM_RCRF_TAX_PERCENT  NUMBER;
  L_PRIM_RCRF_TAX          NUMBER (10, 2) := 0;
  L_PRIM_SALES_TAX_PERCENT NUMBER;
  L_PRIM_TAX               NUMBER (10, 2) := 0;
  L_PRIM_E911_TAX_PERCENT  NUMBER;
  L_PRIM_E911_TAX          NUMBER (10, 2) := 0;
  L_PRIM_E911_SURCHARGE    NUMBER;
  L_PRIM_CURR_CYCLE_DATE   DATE;
  L_PRIM_NEXT_CYCLE_DATE   DATE;
  L_PRIM_CHARGE_DESC       VARCHAR2(255);
  L_CHILD_PRICE_ORIGINAL   NUMBER (10, 2) := 0;
  L_CHILD_PRICE_P          NUMBER (10, 2) := 0;
  L_CHILD_TAX              NUMBER (10, 2) := 0;
  L_CHILD_E911_TAX         NUMBER (10, 2) := 0;
  L_CHILD_E911_SURCHARGE   NUMBER (10, 2) := 0;
  L_CHILD_USF_TAX          NUMBER (10, 2) := 0;
  L_CHILD_RCRF_TAX         NUMBER (10, 2) := 0;
  L_CHILD_NEXT_CYCLE_DATE  DATE;
  TOTAL_PRICE              NUMBER (10, 2) := 0;
  L_PAYMENT_SOURCE_TYPE sa.X_PAYMENT_SOURCE.X_PYMT_TYPE%TYPE;
  L_PE_PAYMENT_SOURCE  NUMBER ;
  L_CREDIT_CARD_OBJID  NUMBER;
  L_BANK_ACCOUNT_OBJID NUMBER;
  L_MERCHANT_ID sa.TABLE_X_CC_PARMS.X_MERCHANT_ID%TYPE;
  L_IGNORE_BAD_CV sa.TABLE_X_CC_PARMS.X_IGNORE_BAD_CV%TYPE;
  L_TOTAL_ENROLL_AMOUNT     NUMBER := 0;
  L_CHILD_SALES_TAX_PERCENT NUMBER;
  L_CHILD_E911_TAX_PERCENT  NUMBER;
  L_CHILD_USF_TAX_PERCENT   NUMBER;
  L_CHILD_RCRF_TAX_PERCENT  NUMBER;
  L_PRIM_TAX_RULE           VARCHAR2(30) ;
  L_PRIM_DATA_TAX_RULE      VARCHAR2(30) ;
  L_CHILD_TAX_RULE          VARCHAR2(30) ;
  L_CHILD_DATA_TAX_RULE     VARCHAR2(30) ;
  TOTAL_PRICE_BUNDLE        NUMBER (10, 2) := 0;
  --TOTAL_PRICE_ORIG     NUMBER (10, 2) := 0;
  --TOTAL_AUTH_AMOUNT    NUMBER (10, 2) := 0;
  TOTAL_USF_TAX  NUMBER (10, 2) ;
  TOTAL_RCRF_TAX NUMBER (10, 2);
  TOTAL_E911_TAX NUMBER (10, 2);
  TOTAL_TAX      NUMBER (10, 2);
  --
  L_PROMO_OBJID sa.TABLE_X_PROMOTION.OBJID%TYPE;
  L_PROMO_CODE sa.TABLE_X_PROMOTION.X_PROMO_CODE%TYPE;
  L_PROMO_ENROLL_TYPE sa.TABLE_X_PROMOTION.X_TRANSACTION_TYPE%TYPE;
  L_PROMO_ENROLL_AMOUNT sa.TABLE_X_PROMOTION.X_DISCOUNT_AMOUNT%TYPE;
  L_PROMO_ENROLL_UNITS sa.TABLE_X_PROMOTION.X_UNITS%TYPE;
  L_PROMO_ENROLL_DAYS sa.TABLE_X_PROMOTION.X_ACCESS_DAYS%TYPE;
  L_PROMO_ERROR_CODE    NUMBER;
  L_PROMO_ERROR_MESSAGE VARCHAR2(400);
  CURSOR PGM_ENROLLED_CUR
  IS
    SELECT
      /*+ ORDERED INDEX(pe IDX_PRG_PARAM_CHARGEDT) */
      PE.*,
      MTMB.X_PRIORITY
    FROM X_PROGRAM_ENROLLED PE ,
      X_PROGRAM_PARAMETERS PP ,
      sa.MTM_BATCH_PROCESS_TYPE MTMB
    WHERE 1                          = 1
    AND PE.X_NEXT_CHARGE_DATE       <= SYSDATE
    AND PE.X_ENROLLMENT_STATUS      IN ('ENROLLED', 'ENROLLMENTSCHEDULED')
    AND PE.PGM_ENROLL2PROG_HDR      IS NULL
    AND NVL(PE.X_CHARGE_TYPE,'NULL') = 'BUNDLE'
    AND PE.X_WAIT_EXP_DATE          IS NULL
    AND PP.OBJID                     = PE.PGM_ENROLL2PGM_PARAMETER
    AND MTMB.X_PRGM_OBJID            = PE.PGM_ENROLL2PGM_PARAMETER
    AND NVL (MTMB.X_PRIORITY, '1')   = NVL (UPPER (IP_PRIORITY ), NVL (MTMB.X_PRIORITY, '1'));
  PGM_ENROLLED_REC PGM_ENROLLED_CUR%ROWTYPE;
  CURSOR C2(PE IN PGM_ENROLLED_CUR%ROWTYPE)
  IS
    SELECT *
    FROM
      (SELECT RANK() OVER (PARTITION BY TAB1.OBJID ORDER BY A.X_RQST_DATE DESC) RNK2 ,
        A.X_STATUS ,
        A.X_PAYMENT_TYPE ,
        TAB1.RNK
      FROM
        (SELECT
          /*+ index(c PGM_PURCH_DTL2PGM_ENROLLED)  use_nl(c) */
          PE.X_ENROLLED_DATE ,
          PE.OBJID ,
          C.OBJID DTL_OBJID ,
          C.PGM_PURCH_DTL2PROG_HDR ,
          RANK() OVER (PARTITION BY PE.OBJID ORDER BY PGM_PURCH_DTL2PROG_HDR DESC) RNK
        FROM X_PROGRAM_PURCH_DTL C
        WHERE 1                          = 1
        AND C.PGM_PURCH_DTL2PGM_ENROLLED = PE.OBJID
        AND C.PGM_PURCH_DTL2PENAL_PEND  IS NULL
        ) TAB1 ,
      X_PROGRAM_PURCH_HDR A
    WHERE TAB1.RNK         < 5
    AND A.OBJID            = TAB1.PGM_PURCH_DTL2PROG_HDR
    AND A.X_RQST_DATE + 0 >= TAB1.X_ENROLLED_DATE
      )TAB2
    WHERE TAB2.RNK2 = 1
    AND 1           = (
      CASE
        WHEN (TAB2.X_STATUS IN ('ENROLLACHPENDING', 'RECURACHPENDING','PAYNOWACHPENDING', 'INCOMPLETE', 'SUBMITTED', 'RECURINCOMPLETE' ) )
        THEN 1
        WHEN ( ( TAB2.X_STATUS  = 'FAILED'
        OR TAB2.X_STATUS        = 'FAILPROCESSED' )
        AND TAB2.X_PAYMENT_TYPE = 'RECURRING' )
        THEN 1
        ELSE 0
      END );
    C2_REC C2%ROWTYPE;
    CURSOR CUR_ACT_STNT_PROMO( P_ESN VARCHAR2, P_PROGRAM_ENROLLED_OBJID NUMBER )
    IS
      SELECT *
      FROM X_ENROLL_PROMO_GRP2ESN GRP2ESN
      WHERE 1                                   = 1
      AND GRP2ESN.X_ESN                         = P_ESN
      AND NVL(GRP2ESN.PROGRAM_ENROLLED_OBJID,0) = P_PROGRAM_ENROLLED_OBJID
      AND SYSDATE BETWEEN GRP2ESN.X_START_DATE AND NVL(GRP2ESN.X_END_DATE, SYSDATE + 1);
    REC_ACT_STNT_PROMO CUR_ACT_STNT_PROMO%ROWTYPE;
    CURSOR CUR_PROMO_DTL (P_PROMO_ID NUMBER)
    IS
      SELECT * FROM TABLE_X_PROMOTION WHERE OBJID = P_PROMO_ID;
    REC_PROMO_DTL CUR_PROMO_DTL%ROWTYPE;
    LV_STATUS_CODE    NUMBER(10)     := 0;
    LV_STATUS_MESSAGE VARCHAR2(4000) := 'Success';
    LV_MOBILE_PE_EXIST PLS_INTEGER   := 0;
    MOBILE_PE_REC sa.X_PROGRAM_ENROLLED%ROWTYPE;
    CLEAR_MOBILE_PE_REC sa.X_PROGRAM_ENROLLED%ROWTYPE;
    LV_X_ECP_ACCOUNT_TYPE sa.X_ACH_PROG_TRANS.X_ECP_ACCOUNT_TYPE%TYPE;
  BEGIN
    OP_RESULT := 0;
    OP_MSG    := 'Success';
    DBMS_OUTPUT.PUT_LINE ('Beginning of RECURRING_PAYMENT_BUNDLE');
    sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING' ,        --IP_X_PARAM_NAME
    'Debug - Start of RECURRING_PAYMENT_BUNDLE',                                                  --p_action
    SYSDATE,                                                                                      --p_error_date
    NULL,                                                                                         --p_key
    'SA.BILLING_BUNDLE_PKG.RECURRING_PAYMENT_BUNDLE',                                             --p_program_name
    'Start of RECURRING_PAYMENT_BUNDLE for IP_BUS_ORG:'||IP_BUS_ORG||', IP_PRIORITY:'||IP_PRIORITY--p_error_text
    );
    DBMS_OUTPUT.PUT_LINE ('Start - Processing all enrolled ESNs ');
    FOR PGM_ENROLLED_REC IN PGM_ENROLLED_CUR
    LOOP
      sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING',                                                       --IP_X_PARAM_NAME
      'Debug 1 - RECURRING_PAYMENT_BUNDLE',                                                                                                       --p_action
      SYSDATE,                                                                                                                                    --p_error_date
      PGM_ENROLLED_REC.X_ESN,                                                                                                                     --p_key
      'SA.BILLING_BUNDLE_PKG.RECURRING_PAYMENT_BUNDLE',                                                                                           --p_program_name
      'Start of Parent record processing for PGM_ENROLLED_REC.OBJID:'||PGM_ENROLLED_REC.OBJID||', PGM_ENROLLED_REC.X_ESN:'||PGM_ENROLLED_REC.X_ESN--p_error_text
      );
      DBMS_OUTPUT.PUT_LINE('--PGM_ENROLLED_REC.OBJID: '||PGM_ENROLLED_REC.OBJID);
      DBMS_OUTPUT.PUT_LINE('--PGM_ENROLLED_REC.X_ESN: '||PGM_ENROLLED_REC.X_ESN);
      ---
      --TOTAL_AUTH_AMOUNT := 0;
      TOTAL_PRICE_BUNDLE := 0;
      --TOTAL_PRICE_ORIG := 0;
      TOTAL_USF_TAX  := 0;
      TOTAL_RCRF_TAX := 0;
      TOTAL_E911_TAX := 0;
      TOTAL_TAX      := 0;
      --L_PRIM_PRICE_P := MOBILE_PE_REC.X_AMOUNT;
      --L_PRIM_PRICE_ORIG :=  MOBILE_PE_REC.X_AMOUNT;
      L_PRIM_USF_TAX_PERCENT   := 0;
      L_PRIM_USF_TAX           := 0;
      L_PRIM_RCRF_TAX_PERCENT  := 0;
      L_PRIM_RCRF_TAX          := 0;
      L_PRIM_SALES_TAX_PERCENT := 0;
      L_PRIM_TAX               := 0;
      L_PRIM_E911_TAX_PERCENT  := 0;
      L_PRIM_E911_TAX          := 0;
      L_PRIM_E911_SURCHARGE    := 0;
      L_PRIM_CURR_CYCLE_DATE   := NULL;
      L_PRIM_NEXT_CYCLE_DATE   := NULL;
      L_PRIM_CHARGE_DESC       := NULL;
      L_PRIM_CURR_CYCLE_DATE   := NULL;
      L_PRIM_NEXT_CYCLE_DATE   := NULL;
      L_MER_REF_NO             := sa.MERCHANT_REF_NUMBER;
      SELECT X_MERCHANT_ID,
        X_IGNORE_BAD_CV
      INTO L_MERCHANT_ID,
        L_IGNORE_BAD_CV
      FROM sa.TABLE_X_CC_PARMS
      WHERE X_BUS_ORG =
        (SELECT 'BILLING '
          ||(
          CASE
            WHEN x_program_name NOT IN ('Straight Talk REMOTE ALERT 30 D','Straight Talk REMOTE ALERT 365 D')
            THEN org_id
            ELSE 'REMOTE_ALERT'
          END)
        FROM sa.TABLE_BUS_ORG BO,
          sa.X_PROGRAM_PARAMETERS PP
        WHERE BO.OBJID = PROG_PARAM2BUS_ORG
        AND PP.OBJID   = PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER
        );
      IF (PGM_ENROLLED_REC.X_ESN IS NULL) THEN
        DBMS_OUTPUT.PUT_LINE ('PGM_ENROLLED_REC.X_ESN IS NULL');
        sa.ERROR_LOG_PKG.SP_INSERT_PROGRAM_ERROR_LOG( IP_SOURCE => 'SA.BILLING_BUNDLE_PKG.RECURRING_PAYMENT_BUNDLE', IP_ERROR_CODE => '-110', IP_ERROR_MSG => 'Program enrolled ESN is null', IP_DATE => SYSDATE, IP_DESCRIPTION => 'Program enrolled OBJID: '||TO_CHAR(PGM_ENROLLED_REC.OBJID), IP_SEVERITY => 2 );
      ELSE
        DBMS_OUTPUT.PUT_LINE ('Processing as PGM_ENROLLED_REC.X_ESN is not null');
        OPEN C2(PGM_ENROLLED_REC);
        FETCH C2 INTO C2_REC;
        IF C2%NOTFOUND THEN
          -- Process this enrollment only if there are no pending records in the payment header.
          DBMS_OUTPUT.PUT_LINE ('Entered into C2%NOTFOUND');
          sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING', --IP_X_PARAM_NAME
          'Debug 2 - RECURRING_PAYMENT_BUNDLE',                                                 --p_action
          SYSDATE,                                                                              --p_error_date
          PGM_ENROLLED_REC.X_ESN,                                                               --p_key
          'SA.BILLING_BUNDLE_PKG.RECURRING_PAYMENT_BUNDLE',                                     --p_program_name
          'C2%NOTFOUND'                                                                         --p_error_text
          );
          L_PRIM_PRICE_P        := PGM_ENROLLED_REC.X_AMOUNT;
          L_PRIM_PRICE_ORIG     := PGM_ENROLLED_REC.X_AMOUNT;
          L_PROMO_ENROLL_AMOUNT := 0;
          X_PY_PUR_HDR_ID       := BILLING_SEQ('X_PROGRAM_PURCH_HDR');
          -- Process this enrolment only if there are no pending records in the payment header.
          SP_GET_PAYMENT_SOURCE ( IP_PAY_SOURCE_OBJID => PGM_ENROLLED_REC.PGM_ENROLL2X_PYMT_SRC , OP_PE_PAYMENT_SOURCE => L_PE_PAYMENT_SOURCE , OP_PAYMENT_SOURCE_TYPE => L_PAYMENT_SOURCE_TYPE , OP_CREDIT_CARD_OBJID => L_CREDIT_CARD_OBJID , OP_BANK_ACCOUNT_OBJID => L_BANK_ACCOUNT_OBJID , OP_RESULT => OP_RESULT , OP_MSG => OP_MSG );
          ----start of mobile payment.
          L_PRIM_TAX_RULE      := sa.SP_TAXES.TAX_RULES_BILLING(PGM_ENROLLED_REC.X_ESN) ;
          L_PRIM_DATA_TAX_RULE := sa.SP_TAXES.TAX_RULES_PROGS_DATA_BILLING(PGM_ENROLLED_REC.OBJID) ;
          IF L_PRIM_TAX_RULE NOT IN ('SALES TAX ONLY','NO TAX') AND L_PRIM_DATA_TAX_RULE NOT IN ('SALES TAX ONLY','NO TAX') THEN
            L_PRIM_USF_TAX_PERCENT := SP_TAXES.COMPUTEUSFTAX_BILLING (PGM_ENROLLED_REC.PGM_ENROLL2WEB_USER , PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER,L_PE_PAYMENT_SOURCE --, PGM_ENROLLED_REC.X_ESN CR22380 REMOVING ESN
            );
            L_PRIM_RCRF_TAX_PERCENT := SP_TAXES.COMPUTEMISCTAX_BILLING (PGM_ENROLLED_REC.PGM_ENROLL2WEB_USER , PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER,L_PE_PAYMENT_SOURCE --, PGM_ENROLLED_REC.X_ESN CR22380 REMOVING ESN
            );                                                                                                                                                               --STUL
          ELSE
            L_PRIM_USF_TAX_PERCENT  := 0 ;
            L_PRIM_RCRF_TAX_PERCENT := 0 ;
          END IF ;
          IF PGM_ENROLLED_REC.PGM_ENROLL2X_PROMOTION IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE ('PGM_ENROLLED_REC.PGM_ENROLL2X_PROMOTION: '||PGM_ENROLLED_REC.PGM_ENROLL2X_PROMOTION);
            OPEN CUR_PROMO_DTL(PGM_ENROLLED_REC.PGM_ENROLL2X_PROMOTION);
            FETCH CUR_PROMO_DTL INTO REC_PROMO_DTL;
            IF CUR_PROMO_DTL%FOUND THEN
              DBMS_OUTPUT.PUT_LINE ('Entered into NVL(L_PROMO_ENROLL_AMOUNT,0)');
              L_PROMO_ERROR_CODE    := NULL;
              L_PROMO_ERROR_MESSAGE := NULL;
              L_PROMO_OBJID         := NULL;
              L_PROMO_CODE          := NULL;
              L_PROMO_ENROLL_TYPE   := NULL;
              L_PROMO_ENROLL_AMOUNT := NULL;
              L_PROMO_ENROLL_UNITS  := NULL;
              L_PROMO_ENROLL_DAYS   := NULL;
              L_TOTAL_ENROLL_AMOUNT := 0;
              OPEN CUR_ACT_STNT_PROMO(PGM_ENROLLED_REC.X_ESN, PGM_ENROLLED_REC.OBJID);
              FETCH CUR_ACT_STNT_PROMO
              INTO REC_ACT_STNT_PROMO;
              IF CUR_ACT_STNT_PROMO%FOUND THEN
                DBMS_OUTPUT.PUT_LINE ('Entering into CUR_ACT_STNT_PROMO%FOUND');
                L_PROMO_OBJID := REC_ACT_STNT_PROMO.PROMO_OBJID;
                DBMS_OUTPUT.PUT_LINE ('Start - SA.ENROLL_PROMO_PKG.SP_VALIDATE_PROMO');
                sa.ENROLL_PROMO_PKG.SP_VALIDATE_PROMO ( PGM_ENROLLED_REC.X_ESN , NULL -- P_PROGRAM_OBJID
                , 'RECURRING'                                                         -- P_PROCESS
                , L_PROMO_OBJID                                                       -- P_PROMO_OBJID
                , L_PROMO_CODE , L_PROMO_ENROLL_TYPE , L_PROMO_ENROLL_AMOUNT , L_PROMO_ENROLL_UNITS , L_PROMO_ENROLL_DAYS , L_PROMO_ERROR_CODE , L_PROMO_ERROR_MESSAGE );
                DBMS_OUTPUT.PUT_LINE ('End - SA.ENROLL_PROMO_PKG.SP_VALIDATE_PROMO');
                DBMS_OUTPUT.PUT_LINE ('L_PROMO_ERROR_CODE:'||L_PROMO_ERROR_CODE);
                DBMS_OUTPUT.PUT_LINE ('L_PROMO_CODE:'||L_PROMO_CODE);
                DBMS_OUTPUT.PUT_LINE ('L_PROMO_ENROLL_AMOUNT:'||L_PROMO_ENROLL_AMOUNT);
                IF ( L_PROMO_ERROR_CODE = 0 AND L_PROMO_CODE IS NOT NULL ) THEN
                  L_PRIM_PRICE_P       := L_PRIM_PRICE_P - L_PROMO_ENROLL_AMOUNT;
                  DBMS_OUTPUT.PUT_LINE ('Entered into if condition L_PRIM_PRICE_P:'||L_PRIM_PRICE_P);
                END IF;
              END IF;
              CLOSE CUR_ACT_STNT_PROMO;
            END IF;
            CLOSE CUR_PROMO_DTL;
            DBMS_OUTPUT.PUT_LINE ('L_PROMO_ERROR_CODE:'||L_PROMO_ERROR_CODE);
            DBMS_OUTPUT.PUT_LINE ('L_PROMO_CODE:'||L_PROMO_CODE);
            IF L_PROMO_ERROR_CODE = 0 AND L_PROMO_CODE IS NOT NULL THEN
              DBMS_OUTPUT.PUT_LINE ('Entering IF L_PROMO_ERROR_CODE = 0 AND L_PROMO_CODE IS NOT NULL');
              L_TOTAL_ENROLL_AMOUNT := L_PROMO_ENROLL_AMOUNT;
            END IF;
          END IF;
          DBMS_OUTPUT.PUT_LINE ('PGM_ENROLLED_REC.OBJID IS NOT NULL');
          L_PRIM_SALES_TAX_PERCENT := SP_TAXES.COMPUTETAX_BILLING (PGM_ENROLLED_REC.PGM_ENROLL2WEB_USER , PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER, PGM_ENROLLED_REC.X_ESN,L_PE_PAYMENT_SOURCE );
          L_PRIM_E911_TAX_PERCENT  := SP_TAXES.COMPUTEE911TAX_BILLING (PGM_ENROLLED_REC.PGM_ENROLL2WEB_USER , PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER,L_PE_PAYMENT_SOURCE);
          L_PRIM_E911_SURCHARGE    := SP_TAXES.COMPUTEE911SURCHARGE_BILLING(PGM_ENROLLED_REC.PGM_ENROLL2WEB_USER , PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER,L_PE_PAYMENT_SOURCE);
          SP_TAXES.GETTAX2_BILL(L_PRIM_PRICE_P,L_PRIM_USF_TAX_PERCENT,L_PRIM_RCRF_TAX_PERCENT,L_PRIM_USF_TAX,L_PRIM_RCRF_TAX);

           -- BEGIN CR52959 Calling the following procedure to override the l_usf_tax & l_rcrf_tax amounts if there flags are N
                 sp_taxes.GET_TAX_AMT(i_source_system => pgm_enrolled_rec.x_sourcesystem, o_usf_tax_amt => L_PRIM_USF_TAX, o_rcrf_tax_amt =>L_PRIM_RCRF_TAX,o_usf_percent  => L_PRIM_USF_TAX_PERCENT,o_rcrf_percent =>L_PRIM_RCRF_TAX_PERCENT  );

                 DBMS_OUTPUT.PUT_LINE( 'L_PRIM_USF_TAX :' || L_PRIM_USF_TAX ) ;
                 DBMS_OUTPUT.PUT_LINE( 'L_PRIM_RCRF_TAX:' || L_PRIM_RCRF_TAX ) ;
                 DBMS_OUTPUT.PUT_LINE( ' L_PRIM_USF_TAX_PERCENT :' ||  L_PRIM_USF_TAX_PERCENT ) ;
                 DBMS_OUTPUT.PUT_LINE( 'L_PRIM_RCRF_TAX_PERCENT  :' || L_PRIM_RCRF_TAX_PERCENT  ) ;
            ---END CR52959 Calling the above procedure to override the l_usf_tax & l_rcrf_tax amounts if there flags are N



          SP_TAXES.GETTAX_BILL(L_PRIM_PRICE_P,L_PRIM_SALES_TAX_PERCENT,L_PRIM_E911_TAX_PERCENT,L_PRIM_TAX,L_PRIM_E911_TAX);
          L_PRIM_E911_TAX := NVL(L_PRIM_E911_TAX,0) + NVL(L_PRIM_E911_SURCHARGE,0);
          ----------------------------------------------------------------------------------------------------------------------
          L_PRIM_CURR_CYCLE_DATE     := PGM_ENROLLED_REC.X_NEXT_CHARGE_DATE ;
          L_PRIM_NEXT_CYCLE_DATE     := sa.BILLING_BUNDLE_PKG.FN_GET_NEXT_CYCLE_DATE (PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER , PGM_ENROLLED_REC.X_NEXT_CHARGE_DATE );
          L_PRIM_CHARGE_DESC         := 'PROGRAM CHARGES FOR THE CYCLE ' || TO_CHAR ( PGM_ENROLLED_REC.X_NEXT_CHARGE_DATE, 'MM/DD/YYYY' );
          IF (L_PRIM_NEXT_CYCLE_DATE IS NOT NULL) THEN
            L_PRIM_CHARGE_DESC       := L_PRIM_CHARGE_DESC || ' ' || ' TO ' || TO_CHAR ( L_PRIM_NEXT_CYCLE_DATE - 1, 'MM/DD/YYYY');
          END IF;
          --DBMS_OUTPUT.PUT_LINE ('IF (l_price_p = 0 OR l_price_p IS NULL)');
          sa.BILLING_BUNDLE_PKG.SP_INSERT_PROG_PURCH_DTL ( BILLING_SEQ('X_PROGRAM_PURCH_DTL') --IP_OBJID
          ,PGM_ENROLLED_REC.X_ESN                                                             --IP_X_ESN
          ,L_PRIM_PRICE_ORIG                                                                  --IP_X_AMOUNT
          ,L_PRIM_CHARGE_DESC                                                                 --IP_X_CHARGE_DESC
          ,L_PRIM_CURR_CYCLE_DATE                                                             --IP_X_CYCLE_START_DATE
          ,L_PRIM_NEXT_CYCLE_DATE                                                             --IP_X_CYCLE_END_DATE
          ,PGM_ENROLLED_REC.OBJID                                                             --IP_PGM_PURCH_DTL2PGM_ENROLLED
          ,X_PY_PUR_HDR_ID                                                                    --IP_PGM_PURCH_DTL2PROG_HDR
          ,NULL                                                                               --IP_PGM_PURCH_DTL2PENAL_PEND
          ,ROUND(L_PRIM_TAX,2)                                                                --IP_X_TAX_AMOUNT
          ,ROUND(L_PRIM_E911_TAX,2)                                                           --IP_X_E911_TAX_AMOUNT
          ,ROUND(L_PRIM_USF_TAX,2)                                                            --IP_X_USF_TAXAMOUNT
          ,ROUND(L_PRIM_RCRF_TAX,2)                                                           --IP_X_RCRF_TAX_AMOUNT
          ,NVL (IP_PRIORITY,20)                                                               --IP_X_PRIORITY
          ,LV_STATUS_CODE                                                                     --OP_STATUS_CODE
          ,LV_STATUS_MESSAGE                                                                  --OP_STATUS_MESSAGE
          );
          ----end of mobile payment.
          TOTAL_PRICE_BUNDLE := NVL(L_PRIM_PRICE_P,0);
          --TOTAL_PRICE_ORIG := NVL(L_PRIM_PRICE_ORIG,0);
          TOTAL_USF_TAX  := NVL(L_PRIM_USF_TAX,0);
          TOTAL_RCRF_TAX := NVL(L_PRIM_RCRF_TAX,0);
          TOTAL_E911_TAX := NVL(L_PRIM_E911_TAX,0);
          TOTAL_TAX      := NVL(L_PRIM_TAX,0);
          DBMS_OUTPUT.PUT_LINE('L_PRIM_PRICE_ORIG: '||L_PRIM_PRICE_ORIG);
          DBMS_OUTPUT.PUT_LINE('L_PRIM_PRICE_P: '||L_PRIM_PRICE_P);
          DBMS_OUTPUT.PUT_LINE('L_PRIM_USF_TAX: '||L_PRIM_USF_TAX);
          DBMS_OUTPUT.PUT_LINE('L_PRIM_RCRF_TAX: '||L_PRIM_RCRF_TAX);
          DBMS_OUTPUT.PUT_LINE('L_PRIM_E911_TAX: '||L_PRIM_E911_TAX);
          DBMS_OUTPUT.PUT_LINE('L_PRIM_TAX: '||L_PRIM_TAX);
          --DBMS_OUTPUT.PUT_LINE('TOTAL_PRICE_ORIG: '||TOTAL_PRICE_ORIG);
          DBMS_OUTPUT.PUT_LINE('TOTAL_PRICE_BUNDLE: '||TOTAL_PRICE_BUNDLE);
          DBMS_OUTPUT.PUT_LINE('TOTAL_USF_TAX: '||TOTAL_USF_TAX);
          DBMS_OUTPUT.PUT_LINE('TOTAL_RCRF_TAX: '||TOTAL_RCRF_TAX);
          DBMS_OUTPUT.PUT_LINE('TOTAL_E911_TAX: '||TOTAL_E911_TAX);
          DBMS_OUTPUT.PUT_LINE('TOTAL_TAX: '||TOTAL_TAX);
          FOR CHILD_PGM_ENROLLED_REC IN
          (SELECT                     *
          FROM sa.X_PROGRAM_ENROLLED PE
          WHERE PE.PGM_ENROLL2PROG_HDR = PGM_ENROLLED_REC.OBJID
          )
          LOOP
            sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING',                                                                              --IP_X_PARAM_NAME
            'Debug 3- RECURRING_PAYMENT_BUNDLE',                                                                                                                               --p_action
            SYSDATE,                                                                                                                                                           --p_error_date
            CHILD_PGM_ENROLLED_REC.X_ESN,                                                                                                                                      --p_key
            'SA.BILLING_BUNDLE_PKG.RECURRING_PAYMENT_BUNDLE',                                                                                                                  --p_program_name
            'Start of Child record processing for CHILD_PGM_ENROLLED_REC.X_ESN:'||CHILD_PGM_ENROLLED_REC.X_ESN||', CHILD_PGM_ENROLLED_REC.OBJID:'||CHILD_PGM_ENROLLED_REC.OBJID--p_error_text
            );
            L_CHILD_PRICE_P                                  := CHILD_PGM_ENROLLED_REC.X_AMOUNT;
            L_CHILD_PRICE_ORIGINAL                           := CHILD_PGM_ENROLLED_REC.X_AMOUNT;
            IF CHILD_PGM_ENROLLED_REC.PGM_ENROLL2X_PROMOTION IS NOT NULL THEN
              DBMS_OUTPUT.PUT_LINE ('CHILD_PGM_ENROLLED_REC.PGM_ENROLL2X_PROMOTION: '||CHILD_PGM_ENROLLED_REC.PGM_ENROLL2X_PROMOTION);
              OPEN CUR_PROMO_DTL(CHILD_PGM_ENROLLED_REC.PGM_ENROLL2X_PROMOTION);
              FETCH CUR_PROMO_DTL INTO REC_PROMO_DTL;
              IF CUR_PROMO_DTL%FOUND THEN
                DBMS_OUTPUT.PUT_LINE ('Entered into CUR_PROMO_DTL%FOUND');
                L_PROMO_ERROR_CODE    := NULL;
                L_PROMO_ERROR_MESSAGE := NULL;
                L_PROMO_OBJID         := NULL;
                L_PROMO_CODE          := NULL;
                L_PROMO_ENROLL_TYPE   := NULL;
                L_PROMO_ENROLL_AMOUNT := 0;
                L_PROMO_ENROLL_UNITS  := NULL;
                L_PROMO_ENROLL_DAYS   := NULL;
                OPEN CUR_ACT_STNT_PROMO(CHILD_PGM_ENROLLED_REC.X_ESN, CHILD_PGM_ENROLLED_REC.OBJID);
                FETCH CUR_ACT_STNT_PROMO
                INTO REC_ACT_STNT_PROMO;
                IF CUR_ACT_STNT_PROMO%FOUND THEN
                  DBMS_OUTPUT.PUT_LINE ('Entering into CUR_ACT_STNT_PROMO%FOUND');
                  L_PROMO_OBJID := REC_ACT_STNT_PROMO.PROMO_OBJID;
                  DBMS_OUTPUT.PUT_LINE ('Start - SA.ENROLL_PROMO_PKG.SP_VALIDATE_PROMO');
                  sa.ENROLL_PROMO_PKG.SP_VALIDATE_PROMO ( CHILD_PGM_ENROLLED_REC.X_ESN , NULL -- P_PROGRAM_OBJID
                  , 'RECURRING'                                                               -- P_PROCESS
                  , L_PROMO_OBJID                                                             -- P_PROMO_OBJID
                  , L_PROMO_CODE , L_PROMO_ENROLL_TYPE , L_PROMO_ENROLL_AMOUNT , L_PROMO_ENROLL_UNITS , L_PROMO_ENROLL_DAYS , L_PROMO_ERROR_CODE , L_PROMO_ERROR_MESSAGE );
                  DBMS_OUTPUT.PUT_LINE ('End - SA.ENROLL_PROMO_PKG.SP_VALIDATE_PROMO');
                  DBMS_OUTPUT.PUT_LINE ('L_PROMO_ERROR_CODE:'||L_PROMO_ERROR_CODE);
                  DBMS_OUTPUT.PUT_LINE ('L_PROMO_CODE:'||L_PROMO_CODE);
                  DBMS_OUTPUT.PUT_LINE ('L_PROMO_ENROLL_AMOUNT:'||L_PROMO_ENROLL_AMOUNT);
                  IF ( L_PROMO_ERROR_CODE = 0 AND L_PROMO_CODE IS NOT NULL ) THEN
                    L_CHILD_PRICE_P      := L_CHILD_PRICE_P - L_PROMO_ENROLL_AMOUNT;
                    DBMS_OUTPUT.PUT_LINE ('Entered into if condition L_CHILD_PRICE_P:'||L_CHILD_PRICE_P);
                  END IF;
                END IF;
                CLOSE CUR_ACT_STNT_PROMO;
              END IF;
              CLOSE CUR_PROMO_DTL;
              DBMS_OUTPUT.PUT_LINE ('L_PROMO_ERROR_CODE:'||L_PROMO_ERROR_CODE);
              DBMS_OUTPUT.PUT_LINE ('L_PROMO_CODE:'||L_PROMO_CODE);
              IF L_PROMO_ERROR_CODE = 0 AND L_PROMO_CODE IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE ('Entering IF L_PROMO_ERROR_CODE = 0 AND L_PROMO_CODE IS NOT NULL');
                L_TOTAL_ENROLL_AMOUNT := L_PROMO_ENROLL_AMOUNT + L_TOTAL_ENROLL_AMOUNT;
              END IF;
            END IF;
            L_CHILD_TAX_RULE      := sa.SP_TAXES.TAX_RULES_BILLING(CHILD_PGM_ENROLLED_REC.X_ESN) ;
            L_CHILD_DATA_TAX_RULE := sa.SP_TAXES.TAX_RULES_PROGS_DATA_BILLING(CHILD_PGM_ENROLLED_REC.OBJID) ;
            IF L_CHILD_TAX_RULE NOT IN ('SALES TAX ONLY','NO TAX') AND L_CHILD_DATA_TAX_RULE NOT IN ('SALES TAX ONLY','NO TAX') THEN
              L_CHILD_USF_TAX_PERCENT  := SP_TAXES.COMPUTEUSFTAX_BILLING (CHILD_PGM_ENROLLED_REC.PGM_ENROLL2WEB_USER , CHILD_PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER,L_PE_PAYMENT_SOURCE );
              L_CHILD_RCRF_TAX_PERCENT := SP_TAXES.COMPUTEMISCTAX_BILLING (CHILD_PGM_ENROLLED_REC.PGM_ENROLL2WEB_USER , CHILD_PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER,L_PE_PAYMENT_SOURCE ); --STUL
            ELSE
              L_CHILD_USF_TAX_PERCENT  := 0 ;
              L_CHILD_RCRF_TAX_PERCENT := 0 ;
            END IF ;
            L_CHILD_SALES_TAX_PERCENT := SP_TAXES.COMPUTETAX_BILLING (CHILD_PGM_ENROLLED_REC.PGM_ENROLL2WEB_USER , CHILD_PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER, CHILD_PGM_ENROLLED_REC.X_ESN,L_PE_PAYMENT_SOURCE );
            L_CHILD_E911_TAX_PERCENT  := SP_TAXES.COMPUTEE911TAX_BILLING (CHILD_PGM_ENROLLED_REC.PGM_ENROLL2WEB_USER , CHILD_PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER,L_PE_PAYMENT_SOURCE);
            L_CHILD_E911_SURCHARGE    := SP_TAXES.COMPUTEE911SURCHARGE_BILLING(CHILD_PGM_ENROLLED_REC.PGM_ENROLL2WEB_USER , CHILD_PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER,L_PE_PAYMENT_SOURCE);
            sa.SP_TAXES.GETTAX2_BILL(L_CHILD_PRICE_P,L_CHILD_USF_TAX_PERCENT,L_CHILD_RCRF_TAX_PERCENT,L_CHILD_USF_TAX,L_CHILD_RCRF_TAX);

             -- BEGIN CR52959 Calling the following procedure to override the l_usf_tax & l_rcrf_tax amounts if there flags are N
                 sp_taxes.GET_TAX_AMT(i_source_system => CHILD_PGM_ENROLLED_REC.x_sourcesystem, o_usf_tax_amt => L_PRIM_USF_TAX, o_rcrf_tax_amt =>L_PRIM_RCRF_TAX,o_usf_percent  => L_PRIM_USF_TAX_PERCENT,o_rcrf_percent =>L_PRIM_RCRF_TAX_PERCENT  );

                 DBMS_OUTPUT.PUT_LINE( 'L_CHILD_USF_TAX :' || L_CHILD_USF_TAX ) ;
                 DBMS_OUTPUT.PUT_LINE( 'L_CHILD_RCRF_TAX:' || L_CHILD_RCRF_TAX) ;
                 DBMS_OUTPUT.PUT_LINE( 'L_CHILD_USF_TAX_PERCENT :' ||  L_CHILD_USF_TAX_PERCENT ) ;
                 DBMS_OUTPUT.PUT_LINE( 'L_CHILD_RCRF_TAX_PERCENT  :' || L_CHILD_RCRF_TAX_PERCENT ) ;
            ---END CR52959 Calling the above procedure to override the l_usf_tax & l_rcrf_tax amounts if there flags are N


            sa.SP_TAXES.GETTAX_BILL(L_CHILD_PRICE_P,L_CHILD_SALES_TAX_PERCENT,L_CHILD_E911_TAX_PERCENT,L_CHILD_TAX,L_CHILD_E911_TAX);
            L_CHILD_E911_TAX := NVL(L_CHILD_E911_TAX,0) + NVL(L_CHILD_E911_SURCHARGE,0); --CR24538
            DBMS_OUTPUT.PUT_LINE ('l_CHILD_e911_tax:'||L_CHILD_E911_TAX);
            ----------------------------------------------------------------------------------------------------------------------
            IF L_PRIM_NEXT_CYCLE_DATE IS NULL THEN
              L_CHILD_NEXT_CYCLE_DATE := sa.BILLING_BUNDLE_PKG.FN_GET_NEXT_CYCLE_DATE (PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER , PGM_ENROLLED_REC.X_NEXT_CHARGE_DATE );
            ELSE
              L_CHILD_NEXT_CYCLE_DATE := L_PRIM_NEXT_CYCLE_DATE;
            END IF;
            IF L_PRIM_CHARGE_DESC IS NULL THEN
              L_CHILD_CHARGE_DESC := 'PROGRAM CHARGES FOR THE CYCLE ' || TO_CHAR ( PGM_ENROLLED_REC.X_NEXT_CHARGE_DATE, 'MM/DD/YYYY' );
            ELSE
              L_CHILD_CHARGE_DESC := L_PRIM_CHARGE_DESC;
            END IF;
            sa.BILLING_BUNDLE_PKG.SP_INSERT_PROG_PURCH_DTL ( BILLING_SEQ('X_PROGRAM_PURCH_DTL') --IP_OBJID
            ,CHILD_PGM_ENROLLED_REC.X_ESN                                                       --IP_X_ESN
            ,L_CHILD_PRICE_ORIGINAL                                                             --IP_X_AMOUNT
            ,L_CHILD_CHARGE_DESC                                                                --IP_X_CHARGE_DESC
            ,NVL(L_PRIM_CURR_CYCLE_DATE, CHILD_PGM_ENROLLED_REC.X_NEXT_CHARGE_DATE)             --IP_X_CYCLE_START_DATE
            ,L_CHILD_NEXT_CYCLE_DATE                                                            --IP_X_CYCLE_END_DATE
            ,CHILD_PGM_ENROLLED_REC.OBJID                                                       --IP_PGM_PURCH_DTL2PGM_ENROLLED
            ,X_PY_PUR_HDR_ID                                                                    --IP_PGM_PURCH_DTL2PROG_HDR
            ,NULL                                                                               --IP_PGM_PURCH_DTL2PENAL_PEND
            ,ROUND(L_CHILD_TAX,2)                                                               --IP_X_TAX_AMOUNT
            ,ROUND(L_CHILD_E911_TAX,2)                                                          --IP_X_E911_TAX_AMOUNT
            ,ROUND(L_CHILD_USF_TAX,2)                                                           --IP_X_USF_TAXAMOUNT
            ,ROUND(L_CHILD_RCRF_TAX,2)                                                          --IP_X_RCRF_TAX_AMOUNT
            ,NVL (PGM_ENROLLED_REC.X_PRIORITY,20)                                               --IP_X_PRIORITY
            ,LV_STATUS_CODE                                                                     --OP_STATUS_CODE
            ,LV_STATUS_MESSAGE                                                                  --OP_STATUS_MESSAGE
            );
            --TOTAL_PRICE_ORIG := (NVL(L_CHILD_PRICE_ORIGINAL,0) + NVL(TOTAL_PRICE_ORIG,0));
            TOTAL_PRICE_BUNDLE := (NVL(L_CHILD_PRICE_P,0)  + NVL(TOTAL_PRICE_BUNDLE,0));
            TOTAL_USF_TAX      := (NVL(L_CHILD_USF_TAX,0)  + NVL(TOTAL_USF_TAX,0));
            TOTAL_RCRF_TAX     := (NVL(L_CHILD_RCRF_TAX,0) + NVL(TOTAL_RCRF_TAX,0));
            TOTAL_E911_TAX     := (NVL(L_CHILD_E911_TAX,0) + NVL(TOTAL_E911_TAX,0));
            TOTAL_TAX          := (NVL(L_CHILD_TAX,0)      + NVL(TOTAL_TAX,0));
            DBMS_OUTPUT.PUT_LINE('L_CHILD_PRICE_ORIGINAL: '||L_CHILD_PRICE_ORIGINAL);
            DBMS_OUTPUT.PUT_LINE('L_CHILD_PRICE_P: '||L_CHILD_PRICE_P);
            DBMS_OUTPUT.PUT_LINE('L_CHILD_USF_TAX: '||L_CHILD_USF_TAX);
            DBMS_OUTPUT.PUT_LINE('L_CHILD_RCRF_TAX: '||L_CHILD_RCRF_TAX);
            DBMS_OUTPUT.PUT_LINE('L_CHILD_E911_TAX: '||L_CHILD_E911_TAX);
            DBMS_OUTPUT.PUT_LINE('L_CHILD_TAX: '||L_CHILD_TAX);
            sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING' ,                                                                           --IP_X_PARAM_NAME
            'Debug 4- RECURRING_PAYMENT_BUNDLE',                                                                                                                             --p_action
            SYSDATE,                                                                                                                                                         --p_error_date
            CHILD_PGM_ENROLLED_REC.X_ESN,                                                                                                                                    --p_key
            'SA.BILLING_BUNDLE_PKG.RECURRING_PAYMENT_BUNDLE',                                                                                                                --p_program_name
            'End of Child record processing for CHILD_PGM_ENROLLED_REC.X_ESN:'||CHILD_PGM_ENROLLED_REC.X_ESN||', CHILD_PGM_ENROLLED_REC.OBJID:'||CHILD_PGM_ENROLLED_REC.OBJID--p_error_text
            );
          END LOOP;
          --TOTAL_AUTH_AMOUNT := TOTAL_PRICE_BUNDLE + TOTAL_USF_TAX + TOTAL_RCRF_TAX + TOTAL_E911_TAX + TOTAL_TAX;
          DBMS_OUTPUT.PUT_LINE('TOTAL_PRICE_BUNDLE: '||TOTAL_PRICE_BUNDLE);
          DBMS_OUTPUT.PUT_LINE('TOTAL_USF_TAX: '||TOTAL_USF_TAX);
          DBMS_OUTPUT.PUT_LINE('TOTAL_RCRF_TAX: '||TOTAL_RCRF_TAX);
          DBMS_OUTPUT.PUT_LINE('TOTAL_E911_TAX: '||TOTAL_E911_TAX);
          DBMS_OUTPUT.PUT_LINE('TOTAL_TAX: '||TOTAL_TAX);
          DBMS_OUTPUT.PUT_LINE('L_PAYMENT_SOURCE_TYPE:'||L_PAYMENT_SOURCE_TYPE);
          IF L_PAYMENT_SOURCE_TYPE = 'CREDITCARD' THEN
            DBMS_OUTPUT.PUT_LINE('IF L_PAYMENT_SOURCE_TYPE = CREDITCARD THEN');
            V_CREDIT_CARD_REC := NULL;
            sa.BILLING_BUNDLE_PKG.SP_GET_CREDIT_CARD_INFO ( IP_CREDIT_CARD_OBJID => L_CREDIT_CARD_OBJID , OP_CREDIT_CARD_REC => V_CREDIT_CARD_REC , OP_RESULT => OP_RESULT , OP_MSG => OP_MSG );
            BEGIN
              sa.BILLING_BUNDLE_PKG.SP_GET_ADDRESS_INFO ( IP_ADDRESS_OBJID => V_CREDIT_CARD_REC.X_CREDIT_CARD2ADDRESS , OP_ADDRESS_REC => ADDRESS , OP_RESULT => OP_RESULT , OP_MSG => OP_MSG );
            EXCEPTION
            WHEN OTHERS THEN
              sa.ERROR_LOG_PKG.SP_INSERT_PROGRAM_ERROR_LOG( IP_SOURCE => 'SA.BILLING_BUNDLE_PKG.SP_RECURRING_PAYMENT_BUNDLE', IP_ERROR_CODE => OP_RESULT, IP_ERROR_MSG => OP_MSG, IP_DATE => SYSDATE, IP_DESCRIPTION => ' No address found for the credit card address ( address objid ) ' || TO_CHAR (V_CREDIT_CARD_REC.X_CREDIT_CARD2ADDRESS) || ' cc(objid):' || TO_CHAR (V_CREDIT_CARD_REC.OBJID) || ' contact(objid):' || TO_CHAR(V_CREDIT_CARD_REC.X_CREDIT_CARD2CONTACT), IP_SEVERITY => 2 );
            END;
            sa.BILLING_BUNDLE_PKG.SP_INSERT_PROG_PURCH_HDR ( X_PY_PUR_HDR_ID                --IP_OBJID
            ,PGM_ENROLLED_REC.X_SOURCESYSTEM                                                -- TODO.. for mobile get mobile record  --, IP_X_RQST_SOURCE
            , 'CREDITCARD_PURCH'                                                            -- IP_X_RQST_TYPE
            , SYSDATE                                                                       -- IP_X_RQST_DATE
            , 'ccAuthService_run,ccCaptureService_run'                                      --IP_X_ICS_APPLICATIONS
            , L_MERCHANT_ID                                                                 --IP_X_MERCHANT_ID
            , L_MER_REF_NO                                                                  --IP_X_MERCHANT_REF_NUMBER
            , NULL                                                                          --IP_X_OFFER_NUM
            , NULL                                                                          --IP_X_QUANTITY
            , NULL                                                                          --IP_X_MERCHANT_PRODUCT_SKU
            , NULL                                                                          --IP_X_PAYMENT_LINE2PROGRAM
            , NULL                                                                          --IP_X_PRODUCT_CODE
            , 'YES'                                                                         --IP_X_IGNORE_AVS
            , NULL                                                                          --IP_X_USER_PO
            , NULL                                                                          --IP_X_AVS
            , NULL                                                                          --IP_X_DISABLE_AVS
            , NULL                                                                          --IP_X_CUSTOMER_HOSTNAME
            , NULL                                                                          --IP_X_CUSTOMER_IPADDRESS
            , NULL                                                                          --IP_X_AUTH_REQUEST_ID
            , NULL                                                                          --IP_X_AUTH_CODE
            , NULL                                                                          --IP_X_AUTH_TYPE
            , NULL                                                                          --IP_X_ICS_RCODE
            , NULL                                                                          --IP_X_ICS_RFLAG
            , NULL                                                                          --IP_X_ICS_RMSG
            , NULL                                                                          --IP_X_REQUEST_ID
            , NULL                                                                          --IP_X_AUTH_AVS
            , NULL                                                                          --IP_X_AUTH_RESPONSE
            , NULL                                                                          --IP_X_AUTH_TIME
            , NULL                                                                          --IP_X_AUTH_RCODE
            , NULL                                                                          --IP_X_AUTH_RFLAG
            , NULL                                                                          --IP_X_AUTH_RMSG
            , NULL                                                                          --IP_X_BILL_REQUEST_TIME
            , NULL                                                                          --IP_X_BILL_RCODE
            , NULL                                                                          --IP_X_BILL_RFLAG
            , NULL                                                                          --IP_X_BILL_RMSG
            , NULL                                                                          --IP_X_BILL_TRANS_REF_NO
            , NVL(V_CREDIT_CARD_REC.X_CUSTOMER_FIRSTNAME, 'No Name Provided')               --IP_X_CUSTOMER_FIRSTNAME
            , NVL(V_CREDIT_CARD_REC.X_CUSTOMER_LASTNAME, 'No Name Provided')                --IP_X_CUSTOMER_LASTNAME
            , V_CREDIT_CARD_REC.X_CUSTOMER_PHONE                                            --IP_X_CUSTOMER_PHONE
            , NVL (V_CREDIT_CARD_REC.X_CUSTOMER_EMAIL, 'null@cybersource.com' )             --IP_X_CUSTOMER_EMAIL
            , 'RECURINCOMPLETE'                                                             --IP_X_STATUS
            , NVL(ADDRESS.ADDRESS, 'No Address Provided')                                   --IP_X_BILL_ADDRESS1
            , NVL(ADDRESS.ADDRESS_2, 'No Address Provided')                                 --IP_X_BILL_ADDRESS2
            , ADDRESS.CITY                                                                  --IP_X_BILL_CITY
            , ADDRESS.STATE                                                                 --IP_X_BILL_STATE
            , ADDRESS.ZIPCODE                                                               --IP_X_BILL_ZIP
            , 'US'                                                                          --IP_X_BILL_COUNTRY
            , NULL                                                                          --IP_X_ESN
            , TOTAL_PRICE_BUNDLE                                                            --IP_X_AMOUNT
            , TOTAL_TAX                                                                     -- IP_X_TAX_AMOUNT
            , NULL                                                                          --IP_X_AUTH_AMOUNT
            , NULL                                                                          --IP_X_BILL_AMOUNT
            , 'System'                                                                      --IP_X_USER
            , NULL                                                                          --IP_X_CREDIT_CODE
            , V_CREDIT_CARD_REC.OBJID                                                       --IP_PURCH_HDR2CREDITCARD
            , NULL                                                                          --IP_PURCH_HDR2BANK_ACCT
            , NULL                                                                          --IP_PURCH_HDR2USER
            , NULL                                                                          --IP_PURCH_HDR2ESN
            , NULL                                                                          --IP_PURCH_HDR2RMSG_CODES
            , NULL                                                                          --IP_PURCH_HDR2CR_PURCH
            , PGM_ENROLLED_REC.PGM_ENROLL2X_PYMT_SRC                                        --TODO CHECK ..IP_PROG_HDR2X_PYMT_SRC
            , PGM_ENROLLED_REC.PGM_ENROLL2WEB_USER                                          --TODO CHECK IP_PROG_HDR2WEB_USER
            , NULL                                                                          --IP_PROG_HDR2PROG_BATCH
            , sa.BILLING_JOB_PKG.GETPAYMENTTYPE (PGM_ENROLLED_REC.PGM_ENROLL2PGM_PARAMETER) --IP_X_PAYMENT_TYPE
            , TOTAL_E911_TAX                                                                --  IP_X_E911_TAX_AMOUNT
            , TOTAL_USF_TAX                                                                 --IP_X_USF_TAXAMOUNT
            , TOTAL_RCRF_TAX                                                                --IP_X_RCRF_TAX_AMOUNT
            , SYSDATE                                                                       --IP_X_PROCESS_DATE
            , L_TOTAL_ENROLL_AMOUNT                                                         --IP_X_DISCOUNT_AMOUNT
            , NULL                                                                          --IP_X_PRIORITY
            , LV_STATUS_CODE                                                                --OP_STATUS_CODE
            , LV_STATUS_MESSAGE                                                             --OP_STATUS_MESSAGE
            );
            sa.BILLING_BUNDLE_PKG.SP_INSERT_X_CC_PROG_TRANS ( BILLING_SEQ ('X_CC_PROG_TRANS') --IP_OBJID
            ,L_IGNORE_BAD_CV                                                                  --IP_X_IGNORE_BAD_CV
            , NULL                                                                            --IP_X_IGNORE_AVS
            , NULL                                                                            --IP_X_AVS
            , NULL                                                                            --IP_X_DISABLE_AVS
            , NULL                                                                            --IP_X_AUTH_AVS
            , NULL                                                                            --IP_X_AUTH_CV_RESULT
            , NULL                                                                            --IP_X_SCORE_FACTORS
            , NULL                                                                            --IP_X_SCORE_HOST_SEVERITY
            , NULL                                                                            --IP_X_SCORE_RCODE
            , NULL                                                                            --IP_X_SCORE_RFLAG
            , NULL                                                                            --IP_X_SCORE_RMSG
            , NULL                                                                            --IP_X_SCORE_RESULT
            , NULL                                                                            --IP_X_SCORE_TIME_LOCAL
            , V_CREDIT_CARD_REC.X_CUSTOMER_CC_NUMBER                                          --IP_X_CUSTOMER_CC_NUMBER
            , V_CREDIT_CARD_REC.X_CUSTOMER_CC_EXPMO                                           --IP_X_CUSTOMER_CC_EXPMO
            , V_CREDIT_CARD_REC.X_CUSTOMER_CC_EXPYR                                           --IP_X_CUSTOMER_CC_EXPYR
            , V_CREDIT_CARD_REC.X_CUSTOMER_CC_CV_NUMBER                                       --IP_X_CUSTOMER_CVV_NUM
            , NULL                                                                            --IP_X_CC_LASTFOUR
            , V_CREDIT_CARD_REC.OBJID                                                         --IP_X_CC_TRANS2X_CREDIT_CARD
            , X_PY_PUR_HDR_ID                                                                 --IP_X_CC_TRANS2X_PURCH_HDR
            , LV_STATUS_CODE                                                                  --OP_STATUS_CODE
            , LV_STATUS_MESSAGE                                                               --OP_STATUS_MESSAGE
            );
          END IF;
        ELSE
          sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING', --IP_X_PARAM_NAME
          'Debug 2A - RECURRING_PAYMENT_BUNDLE',                                                --p_action
          SYSDATE,                                                                              --p_error_date
          PGM_ENROLLED_REC.X_ESN,                                                               --p_key
          'SA.BILLING_BUNDLE_PKG.RECURRING_PAYMENT_BUNDLE',                                     --p_program_name
          'C2%FOUND'                                                                            --p_error_text
          );
        END IF;
        CLOSE C2;
      END IF;
      sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING',                                                     --IP_X_PARAM_NAME
      'Debug 5 - RECURRING_PAYMENT_BUNDLE',                                                                                                     --p_action
      SYSDATE,                                                                                                                                  --p_error_date
      PGM_ENROLLED_REC.X_ESN,                                                                                                                   --p_key
      'SA.BILLING_BUNDLE_PKG.RECURRING_PAYMENT_BUNDLE',                                                                                         --p_program_name
      'End of Parent record processing for PGM_ENROLLED_REC.OBJID:'||PGM_ENROLLED_REC.OBJID||', PGM_ENROLLED_REC.X_ESN:'||PGM_ENROLLED_REC.X_ESN--p_error_text
      );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE ('End - Processing all enrolled ESNs ');
    sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING',       --IP_X_PARAM_NAME
    'Debug - End of RECURRING_PAYMENT_BUNDLE',                                                  --p_action
    SYSDATE,                                                                                    --p_error_date
    NULL,                                                                                       --p_key
    'SA.BILLING_BUNDLE_PKG.RECURRING_PAYMENT_BUNDLE',                                           --p_program_name
    'End of RECURRING_PAYMENT_BUNDLE for IP_BUS_ORG:'||IP_BUS_ORG||', IP_PRIORITY:'||IP_PRIORITY--p_error_text
    );
    DBMS_OUTPUT.PUT_LINE ('End of RECURRING_PAYMENT_BUNDLE');
  EXCEPTION
  WHEN OTHERS THEN
    OP_RESULT := - 900;
    OP_MSG    := 'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
    ROLLBACK;
    sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Error RECURRING_PAYMENT_BUNDLE for ESN: op_result := '||OP_RESULT,                             --p_action
    SYSDATE,                                                                                                                                --p_error_date
    NULL,                                                                                                                                   --p_key
    'SA.BILLING_BUNDLE_PKG.RECURRING_PAYMENT_BUNDLE',                                                                                       --p_program_name
    'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
    );
    RAISE;
  END SP_RECURRING_PAYMENT_BUNDLE;
  /***************************************************************************************************************
  Program Name       :   SP_BUNDLE_ELIGIBLE_ESN
  Program Type       :   Stored procedure
  Program Arguments  :   IP_PROCESS_DATE
  Returns            :   OP_RESULT
  OP_MSG
  Program Called     :   SA.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO
  SA.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE
  Description        :   In this procedure, we are trying to bundle ESNs (which are enrolled
  in child programs) to other ESNs in web account (which are enrolled
  in parent programs).
  For example:
  ESN 1 --> Activated with auto refill - Remote alert on Jan 1
  ESN 2 --> Activated with auto refill - ST unlimited on June 1
  After ESN2 activates, ESN1 is eligible for bundle offer.
  So this procedure will bundle both ESNs as part of nightly job
  on June 1.
  Modified By            Modification     PCR             Description
  Date           Number
  =============          ============     ======      ===================================
  Jai Arza           08/04/2015                 Initial Creation
  ***************************************************************************************************************/
PROCEDURE SP_BUNDLE_ELIGIBLE_ESN(
    IP_PROCESS_DATE IN DATE ,
    OP_RESULT OUT NUMBER ,
    OP_MSG OUT VARCHAR2 )
AS
  L_ESN_LIST_ARRAY sa.TYP_VARCHAR2_ARRAY := TYP_VARCHAR2_ARRAY();
  --LV_EMPTY_VARCHAR2_ARRAY     SA.TYP_VARCHAR2_ARRAY := TYP_VARCHAR2_ARRAY();
  WEBXESN_REC WEBXESN_CUR%ROWTYPE;
  LV_RECENTLY_ENROLLED PLS_INTEGER        := 0;
  L_PROG1_OBJID_ARRAY sa.TYP_NUMBER_ARRAY := TYP_NUMBER_ARRAY();
  --L_EMPTY_NUM_ARRAY          SA.TYP_NUMBER_ARRAY := TYP_NUMBER_ARRAY();
  LV_STATUS_CODE    NUMBER(10)     := 0;
  LV_STATUS_MESSAGE VARCHAR2(4000) := 'Success';
BEGIN
  sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING', --IP_X_PARAM_NAME
  'Debug - Start of SP_BUNDLE_ELIGIBLE_ESN',                                            --p_action
  SYSDATE,                                                                              --p_error_date
  NULL,                                                                                 --p_key
  'SA.BILLING_BUNDLE_PKG.SP_BUNDLE_ELIGIBLE_ESN',                                       --p_program_name
  'Start of SP_BUNDLE_ELIGIBLE_ESN for IP_PROCESS_DATE:'||IP_PROCESS_DATE               --p_error_text
  );
  DBMS_OUTPUT.PUT_LINE ('Start of SP_BUNDLE_ELIGIBLE_ESN');
  OP_RESULT:= 0;
  OP_MSG   := 'Success';
  --Get list of active Child programs to be considered
  FOR CHILD_PROG IN
  ( SELECT DISTINCT BPP.X_PROMO_OBJID ,
    BPP.X_PROMO_CODE ,
    BPP.X_CHILD_PROG_PARAM_OBJID ,
    BPP.X_CHILD_PROG_NAME ,
    BPP.X_BUNDLE_START_DATE ,
    BPP.X_BUNDLE_END_DATE
  FROM sa.X_BUNDLE_PROGRAM_PROMO BPP
  WHERE SYSDATE BETWEEN BPP.X_BUNDLE_START_DATE AND BPP.X_BUNDLE_END_DATE
  )
  LOOP
    DBMS_OUTPUT.PUT_LINE ('---Processing X_PROMO_OBJID:'||CHILD_PROG.X_PROMO_OBJID);
    DBMS_OUTPUT.PUT_LINE ('Start - Loading parent program objid which are linked to this promo.');
    L_PROG1_OBJID_ARRAY := sa.TYP_NUMBER_ARRAY();
    SELECT X_PARENT_PROG_PARAM_OBJID BULK COLLECT
    INTO L_PROG1_OBJID_ARRAY
    FROM sa.X_BUNDLE_PROGRAM_PROMO BPP
    WHERE BPP.X_PROMO_OBJID = CHILD_PROG.X_PROMO_OBJID;
    DBMS_OUTPUT.PUT_LINE ('End - Loading parent program objid which are linked to this promo.');
    FOR PROG_ENR IN
    (SELECT PE.*
    FROM X_PROGRAM_ENROLLED PE
    WHERE 1                         = 1
    AND PE.PGM_ENROLL2PGM_PARAMETER = CHILD_PROG.X_CHILD_PROG_PARAM_OBJID
    AND PE.X_ENROLLMENT_STATUS     IN ('ENROLLED', 'ENROLLMENTSCHEDULED')
    AND PE.X_CHARGE_TYPE           IS NULL
    AND PE.X_ENROLLED_DATE BETWEEN CHILD_PROG.X_BUNDLE_START_DATE AND CHILD_PROG.X_BUNDLE_END_DATE
    )
    LOOP
      DBMS_OUTPUT.PUT_LINE ('--Start of Processing X_ESN:'||PROG_ENR.X_ESN||' as this is enrolled into X_CHILD_PROG_PARAM_OBJID:'||CHILD_PROG.X_CHILD_PROG_PARAM_OBJID);
      LV_RECENTLY_ENROLLED := 0;
      L_ESN_LIST_ARRAY     := sa.TYP_VARCHAR2_ARRAY();
      LV_STATUS_CODE       := 0;
      LV_STATUS_MESSAGE    := 'Success';
      --Get web account associated to this ESN.
      OPEN WEBXESN_CUR(PROG_ENR.X_ESN);
      FETCH WEBXESN_CUR INTO WEBXESN_REC;
      -- check web objid for account
      IF WEBXESN_CUR%NOTFOUND THEN
        CLOSE WEBXESN_CUR;
        DBMS_OUTPUT.PUT_LINE( 'Do not have Web account');
      ELSE
        DBMS_OUTPUT.PUT_LINE( 'Web account exist for ESN provided:'||WEBXESN_REC.OBJID);
        CLOSE WEBXESN_CUR;
        --Get list of ESNs associated to this web account
        DBMS_OUTPUT.PUT_LINE ('Start - Loading ESNs which are in web account:'||WEBXESN_REC.OBJID);
        SELECT PI.PART_SERIAL_NO BULK COLLECT
        INTO L_ESN_LIST_ARRAY
        FROM sa.TABLE_PART_INST PI ,
          sa.TABLE_X_CONTACT_PART_INST CPI ,
          sa.TABLE_WEB_USER WEB
        WHERE WEB.OBJID                     = WEBXESN_REC.OBJID
        AND PI.OBJID                        = CPI.X_CONTACT_PART_INST2PART_INST
        AND CPI.X_CONTACT_PART_INST2CONTACT = WEB.WEB_USER2CONTACT ;
        DBMS_OUTPUT.PUT_LINE ('End - Loading ESNs which are in web account:'||WEBXESN_REC.OBJID);
        -- Checking if any ESN in this web account enrolled into parent programs
        -- within the span provided as input.
        DBMS_OUTPUT.PUT_LINE ('Checking if any ESN in the web account if recently enrolled into parent programs.');
        SELECT COUNT(1)
        INTO LV_RECENTLY_ENROLLED
        FROM X_PROGRAM_ENROLLED PE ,
          TABLE(L_ESN_LIST_ARRAY) ESN_LIST ,
          TABLE(L_PROG1_OBJID_ARRAY) PROG_LIST
        WHERE 1                         = 1
        AND PE.X_ESN                    = ESN_LIST.COLUMN_VALUE
        AND PE.X_ENROLLMENT_STATUS     IN ('ENROLLED', 'ENROLLMENTSCHEDULED')
        AND PE.X_CHARGE_TYPE           IS NULL
        AND PE.X_ENROLLED_DATE         >= TRUNC(IP_PROCESS_DATE)
        AND PE.PGM_ENROLL2PGM_PARAMETER = PROG_LIST.COLUMN_VALUE ;
        DBMS_OUTPUT.PUT_LINE ('Enrolled count LV_RECENTLY_ENROLLED:'||LV_RECENTLY_ENROLLED);
        IF LV_RECENTLY_ENROLLED > 0 THEN
          DBMS_OUTPUT.PUT_LINE ('Start - Establishing bundle link.');
          sa.BILLING_BUNDLE_PKG.SP_REGISTER_BUNDLE_PROMO ( PROG_ENR.X_ESN , CHILD_PROG.X_PROMO_OBJID , PROG_ENR.OBJID , LV_STATUS_CODE , LV_STATUS_MESSAGE ) ;
          DBMS_OUTPUT.PUT_LINE ('End - Establishing bundle link.');
          IF LV_STATUS_CODE != 0 THEN
            sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Error while processing SA.BILLING_BUNDLE_PKG.SP_BUNDLE_ELIGIBLE_ESN',                                                                                                                                                                           --p_action
            SYSDATE,                                                                                                                                                                                                                                                                                 --p_error_date
            PROG_ENR.X_ESN,                                                                                                                                                                                                                                                                          --p_key
            'SA.BILLING_BUNDLE_PKG.SP_BUNDLE_ELIGIBLE_ESN',                                                                                                                                                                                                                                          --p_program_name
            'Error while processing SA.BILLING_BUNDLE_PKG.SP_BUNDLE_ELIGIBLE_ESN for PROG_ENR.X_ESN:'||PROG_ENR.X_ESN||', CHILD_PROG.X_PROMO_OBJID:'||CHILD_PROG.X_PROMO_OBJID ||', PROG_ENR.OBJID:'||PROG_ENR.OBJID||', LV_STATUS_CODE: '||LV_STATUS_CODE||', LV_STATUS_MESSAGE:'||LV_STATUS_MESSAGE--p_error_text
            );
          END IF;
        END IF;
        DBMS_OUTPUT.PUT_LINE('PROG_ENR.X_ESN: '||PROG_ENR.X_ESN);
      END IF;
      DBMS_OUTPUT.PUT_LINE ('End of Processing X_ESN:'||PROG_ENR.X_ESN||' as this is enrolled into X_CHILD_PROG_PARAM_OBJID:'||CHILD_PROG.X_CHILD_PROG_PARAM_OBJID);
    END LOOP;
  END LOOP;
  sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING', --IP_X_PARAM_NAME
  'Debug - End of SP_BUNDLE_ELIGIBLE_ESN',                                              --p_action
  SYSDATE,                                                                              --p_error_date
  NULL,                                                                                 --p_key
  'SA.BILLING_BUNDLE_PKG.SP_BUNDLE_ELIGIBLE_ESN',                                       --p_program_name
  'End of SP_BUNDLE_ELIGIBLE_ESN for IP_PROCESS_DATE:'||IP_PROCESS_DATE                 --p_error_text
  );
  DBMS_OUTPUT.PUT_LINE ('End of SP_BUNDLE_ELIGIBLE_ESN');
EXCEPTION
WHEN OTHERS THEN
  OP_RESULT := -1;
  OP_MSG    := 'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
  ROLLBACK;
  sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Error while processing SA.BILLING_BUNDLE_PKG.SP_BUNDLE_ELIGIBLE_ESN for ESN: op_result := '||OP_RESULT, --p_action
  SYSDATE,                                                                                                                                         --p_error_date
  NULL,                                                                                                                                            --p_key
  'SA.BILLING_BUNDLE_PKG.SP_BUNDLE_ELIGIBLE_ESN',                                                                                                  --p_program_name
  'OP_RESULT : '|| OP_RESULT|| '; OP_MSG : '|| OP_MSG                                                                                              --p_error_text
  );
  RAISE;
END SP_BUNDLE_ELIGIBLE_ESN;
/***************************************************************************************************************
Program Name       :   SP_RECON_BUNDLED_ESNS
Program Type       :   Stored procedure
Program Arguments  :   IP_ESN
IP_PROG_ENR_OBJID
IP_PROG_PURCH_HDR_X_STATUS
Returns            :   OP_RESULT
OP_MSG
Program Called     :   SA.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE
Description        :   In this procedure, we are doing required updates for bundled ESNs
during re-con process
Modified By            Modification     PCR             Description
Date           Number
=============          ============     ======      ===================================
Jai Arza           08/04/2015      34962           Initial Creation
***************************************************************************************************************/
PROCEDURE SP_RECON_BUNDLED_ESNS(
    IP_ESN                     IN sa.X_PROGRAM_ENROLLED.X_ESN%TYPE ,
    IP_PROG_ENR_OBJID          IN sa.X_PROGRAM_ENROLLED.OBJID%TYPE ,
    IP_PROG_PURCH_HDR_X_STATUS IN sa.X_PROGRAM_PURCH_HDR.X_STATUS%TYPE ,
    OP_RESULT OUT NUMBER ,
    OP_MSG OUT VARCHAR2)
AS
  LV_X_CHARGE_DATE sa.X_PROGRAM_ENROLLED.X_CHARGE_DATE%TYPE;          --CR34962
  LV_X_NEXT_CHARGE_DATE sa.X_PROGRAM_ENROLLED.X_NEXT_CHARGE_DATE%TYPE;--CR34962
  LV_X_EXP_DATE sa.X_PROGRAM_ENROLLED.X_EXP_DATE%TYPE;                --CR34962
BEGIN
  DBMS_OUTPUT.PUT_LINE ('Start of SP_RECON_BUNDLED_ESNS for IP_ESN:' ||IP_ESN||', IP_PROG_ENR_OBJID:'||IP_PROG_ENR_OBJID||', IP_PROG_PURCH_HDR_X_STATUS:'||IP_PROG_PURCH_HDR_X_STATUS);
  sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING',                                                                        --IP_X_PARAM_NAME
  'Debug - Start of SP_RECON_BUNDLED_ESNS',                                                                                                                    --p_action
  SYSDATE,                                                                                                                                                     --p_error_date
  IP_ESN,                                                                                                                                                      --p_key
  'SA.BILLING_BUNDLE_PKG.SP_RECON_BUNDLED_ESNS',                                                                                                               --p_program_name
  'Start of SP_RECON_BUNDLED_ESNS for IP_ESN:' ||IP_ESN||', IP_PROG_ENR_OBJID:'||IP_PROG_ENR_OBJID||', IP_PROG_PURCH_HDR_X_STATUS:'||IP_PROG_PURCH_HDR_X_STATUS--p_error_text
  );
  OP_RESULT:= 0;
  OP_MSG   := 'Success';
  FOR X IN
  (SELECT PE.* ,
    PP.X_CHARGE_FRQ_CODE,
    PP.X_IS_RECURRING,
    PP.X_PROG_CLASS
  FROM sa.X_PROGRAM_ENROLLED PE,
    sa.X_PROGRAM_PARAMETERS PP
  WHERE PE.OBJID                   = IP_PROG_ENR_OBJID
  AND NVL(PE.X_CHARGE_TYPE,'NULL') = 'BUNDLE'
  AND PE.PGM_ENROLL2PROG_HDR      IS NULL
  AND PE.PGM_ENROLL2PGM_PARAMETER  = PP.OBJID
  )
  LOOP
    LV_X_CHARGE_DATE := NULL;
    SELECT
      CASE
        WHEN IP_PROG_PURCH_HDR_X_STATUS = 'SUCCESS'
        THEN NVL (X.X_NEXT_CHARGE_DATE, SYSDATE)
        ELSE X.X_CHARGE_DATE
      END
    INTO LV_X_CHARGE_DATE
    FROM DUAL;
    DBMS_OUTPUT.PUT_LINE ('LV_X_CHARGE_DATE:'||LV_X_CHARGE_DATE);
    LV_X_NEXT_CHARGE_DATE := NULL;
    SELECT
      CASE
        WHEN IP_PROG_PURCH_HDR_X_STATUS = 'SUCCESS'
        THEN sa.BILLING_PAYMENT_RECON_PKG.GET_NEXT_CYCLE_DATE (X.PGM_ENROLL2PGM_PARAMETER, X.X_NEXT_CHARGE_DATE )
        WHEN IP_PROG_PURCH_HDR_X_STATUS = 'RECURACHPENDING'
        THEN sa.BILLING_PAYMENT_RECON_PKG.GET_NEXT_CYCLE_DATE_DEACT (X.PGM_ENROLL2PGM_PARAMETER, X.X_NEXT_CHARGE_DATE )
        ELSE X.X_NEXT_CHARGE_DATE
      END
    INTO LV_X_NEXT_CHARGE_DATE
    FROM DUAL;
    DBMS_OUTPUT.PUT_LINE ('LV_X_NEXT_CHARGE_DATE:'||LV_X_NEXT_CHARGE_DATE);
    LV_X_EXP_DATE:= NULL;
    SELECT
      CASE
        WHEN IP_PROG_PURCH_HDR_X_STATUS = 'SUCCESS'
        AND X.X_CHARGE_FRQ_CODE         = '365'
        AND X.X_IS_RECURRING            = 1
        AND X.X_PROG_CLASS              = 'WARRANTY'
        THEN TRUNC (SYSDATE) + 365
        ELSE X.X_EXP_DATE
      END
    INTO LV_X_EXP_DATE
    FROM DUAL;
    DBMS_OUTPUT.PUT_LINE ('LV_X_EXP_DATE:'||LV_X_EXP_DATE);
    UPDATE sa.X_PROGRAM_ENROLLED
    SET X_ENROLLMENT_STATUS = DECODE (X_ENROLLMENT_STATUS, 'DEENROLLED', 'DEENROLLED', 'READYTOREENROLL', 'READYTOREENROLL', 'ENROLLED' ),
      X_CHARGE_DATE         = LV_X_CHARGE_DATE,
      X_NEXT_CHARGE_DATE    = LV_X_NEXT_CHARGE_DATE,
      X_COOLING_PERIOD      = NULL,
      X_EXP_DATE            = LV_X_EXP_DATE,
      X_UPDATE_STAMP        = SYSDATE
    WHERE OBJID             = X.OBJID;
    DBMS_OUTPUT.PUT_LINE('Number of records updated in X_PROGRAM_ENROLLED for primary ESN:'||SQL%ROWCOUNT);
    FOR CHILD_PGM_ENROLLED_REC IN
    (SELECT                     *
    FROM sa.X_PROGRAM_ENROLLED PE
    WHERE PE.PGM_ENROLL2PROG_HDR = X.OBJID
    )
    LOOP
      DBMS_OUTPUT.PUT_LINE('CHILD_PGM_ENROLLED_REC.OBJID:'||CHILD_PGM_ENROLLED_REC.OBJID);
      UPDATE sa.X_PROGRAM_ENROLLED
      SET X_ENROLLMENT_STATUS = DECODE (X_ENROLLMENT_STATUS, 'DEENROLLED', 'DEENROLLED', 'READYTOREENROLL', 'READYTOREENROLL', 'ENROLLED' ),
        X_CHARGE_DATE         = LV_X_CHARGE_DATE,
        X_NEXT_CHARGE_DATE    = LV_X_NEXT_CHARGE_DATE,
        X_COOLING_PERIOD      = NULL,
        X_EXP_DATE            = LV_X_EXP_DATE,
        X_UPDATE_STAMP        = SYSDATE
      WHERE OBJID             = CHILD_PGM_ENROLLED_REC.OBJID;
      DBMS_OUTPUT.PUT_LINE('Number of records updated in X_PROGRAM_ENROLLED for Child ESNs:'||SQL%ROWCOUNT);
    END LOOP;
  END LOOP;
  sa.ERROR_LOG_PKG.SP_DEBUG_INSERT_ERROR_TABLE( 'ENABLE_INSERTS_FOR_BILLING_DEBUGGING',                                                                      --IP_X_PARAM_NAME
  'Debug - End of SP_RECON_BUNDLED_ESNS',                                                                                                                    --p_action
  SYSDATE,                                                                                                                                                   --p_error_date
  IP_ESN,                                                                                                                                                    --p_key
  'SA.BILLING_BUNDLE_PKG.SP_RECON_BUNDLED_ESNS',                                                                                                             --p_program_name
  'End of SP_RECON_BUNDLED_ESNS for IP_ESN:' ||IP_ESN||', IP_PROG_ENR_OBJID:'||IP_PROG_ENR_OBJID||', IP_PROG_PURCH_HDR_X_STATUS:'||IP_PROG_PURCH_HDR_X_STATUS--p_error_text
  );
  DBMS_OUTPUT.PUT_LINE ('End of SP_RECON_BUNDLED_ESNS for IP_ESN:' ||IP_ESN||', IP_PROG_ENR_OBJID:'||IP_PROG_ENR_OBJID||', IP_PROG_PURCH_HDR_X_STATUS:'||IP_PROG_PURCH_HDR_X_STATUS);
EXCEPTION
WHEN OTHERS THEN
  OP_RESULT := -1;
  OP_MSG    := 'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
  ROLLBACK;
  sa.ERROR_LOG_PKG.SP_INSERT_ERROR_TABLE ('Error while processing SA.BILLING_BUNDLE_PKG.SP_RECON_BUNDLED_ESNS for IP_ESN:' ||IP_ESN||', IP_PROG_ENR_OBJID:'||IP_PROG_ENR_OBJID||', IP_PROG_PURCH_HDR_X_STATUS:'||IP_PROG_PURCH_HDR_X_STATUS, --p_action
  SYSDATE,                                                                                                                                                                                                                                   --p_error_date
  IP_ESN,                                                                                                                                                                                                                                    --p_key
  'SA.BILLING_BUNDLE_PKG.SP_RECON_BUNDLED_ESNS',                                                                                                                                                                                             --p_program_name
  'OP_RESULT : '|| OP_RESULT|| '; OP_MSG : '|| OP_MSG                                                                                                                                                                                        --p_error_text
  );
  RAISE;
END SP_RECON_BUNDLED_ESNS;
END BILLING_BUNDLE_PKG;


-- ANTHILL_TEST PLSQL/SA/PackageBodies/BILLING_BUNDLE_PKG.sql 	CR52959: 1.10
/