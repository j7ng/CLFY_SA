CREATE OR REPLACE PACKAGE BODY sa.ILD_TRANSACTION_PKG
IS
  --********************************************************************************
  -- Function to check if a ESN device type is Featured phone or not -- CR32641
  --********************************************************************************
  FUNCTION FN_IS_IT_FEATURE_PHONE(
      IP_ESN sa.TABLE_PART_INST.PART_SERIAL_NO%type)
    RETURN VARCHAR2
  IS
    LV_COUNT PLS_INTEGER          := 0;
    LV_FEATURE_PHONE VARCHAR2(10) := 'NO';
  BEGIN
    SELECT COUNT(*)
    INTO LV_COUNT
    FROM sa.PC_PARAMS_VIEW
    WHERE 1         =1
    AND PARAM_VALUE ='FEATURE_PHONE' --PPE
    AND PARAM_NAME  = 'DEVICE_TYPE'
    AND PART_CLASS IN
      (SELECT PC.NAME
      FROM sa.TABLE_PART_INST PI ,
        sa.TABLE_MOD_LEVEL ML ,
        sa.TABLE_PART_NUM PN ,
        sa.TABLE_PART_CLASS PC
      WHERE PI.PART_SERIAL_NO     = IP_ESN
      AND PI.N_PART_INST2PART_MOD = ML.OBJID
      AND ML.PART_INFO2PART_NUM   = PN.OBJID
      AND PN.PART_NUM2PART_CLASS  = PC.OBJID
      )
    AND ROWNUM          <2 ;
    IF LV_COUNT         = 1 THEN
      LV_FEATURE_PHONE := 'YES';
    ELSIF LV_COUNT      = 0 THEN
      LV_FEATURE_PHONE := 'NO';
    END IF;
    RETURN LV_FEATURE_PHONE;
  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END FN_IS_IT_FEATURE_PHONE;
--********************************************************************************
-- Function to check if a ESN has Safelink handset or not -- CR32641
--********************************************************************************
  FUNCTION FN_IS_IT_SL_HANDSET(
      IP_ESN IN VARCHAR2)
    RETURN VARCHAR2
  IS
    LV_SL_HANDSET PLS_INTEGER     := 0;
    LV_HANDSET_EXIST VARCHAR2(10) := 'NO';
  BEGIN
    LV_SL_HANDSET := 0;
    SELECT COUNT(*)
    INTO LV_SL_HANDSET
    FROM sa.X_SL_CURRENTVALS CUR,
      sa.TABLE_SITE_PART TSP,
      sa.X_PROGRAM_ENROLLED PE
    WHERE 1                    = 1
    AND TSP.X_SERVICE_ID       = PE.X_ESN
    AND TSP.X_SERVICE_ID       = CUR.X_CURRENT_ESN
    AND PE.X_ENROLLMENT_STATUS = 'ENROLLED'
    AND CUR.X_CURRENT_ESN      = IP_ESN
    AND UPPER(TSP.PART_STATUS) = 'ACTIVE'
    AND ROWNUM                 <2;
    IF LV_SL_HANDSET           = 1 THEN
      LV_HANDSET_EXIST        := 'YES';
    ELSIF LV_SL_HANDSET        = 0 THEN
      LV_HANDSET_EXIST        := 'NO';
    END IF;
    RETURN LV_HANDSET_EXIST;
  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END FN_IS_IT_SL_HANDSET;
/*********************************************************************************************************************************************************************/
/* function Name: GET_ILD_PRD_DEF_BY_PRIORITY */
/* Description: return ILD PRODUCT CODE for default for Each Brand if not found brand return 'ERR_BRAND' */
/**********************************************************************************************************************************************************************/
  FUNCTION GET_ILD_PRD_DEF_BY_PRIORITY(
      V_BUS_ORG           IN VARCHAR2 ,
      in_default_priority IN NUMBER DEFAULT 1)
    RETURN VARCHAR2
  IS
    lv_default_value NUMBER;
    CURSOR GET_ILD_CURS
    IS
      SELECT ti.X_ILD_PRODUCT ILD_CODE
      FROM sa.TABLE_X_ILD_PRODUCT ti,
        table_bus_org bo
      WHERE bo.org_ID     = V_BUS_ORG
      AND bo.objid        = ti.X_BUS_ORG
      AND ti.X_IS_DEFAULT = lv_default_value;
    GET_ILD_REC GET_ILD_CURS%ROWTYPE;
  BEGIN
    IF in_default_priority IS NULL THEN
      lv_default_value     := 1;
    ELSE
      lv_default_value := in_default_priority;
    END IF;
    OPEN GET_ILD_CURS;
    FETCH GET_ILD_CURS INTO GET_ILD_REC;
    IF GET_ILD_CURS%NOTFOUND THEN
      CLOSE GET_ILD_CURS;
      RETURN 'ERR_BRAND' ;
    ELSE
      CLOSE GET_ILD_CURS;
      RETURN GET_ILD_REC.ILD_CODE;
    END IF;
  END GET_ILD_PRD_DEF_BY_PRIORITY;
  --********************************************************************************
 -- Function to get the flag of a region by Bus Org.
 -- If not found return 0
 -- CR43833
--********************************************************************************
	FUNCTION GET_DISPLAY_FLAG (
								i_country 		IN VARCHAR2,
								i_language		IN VARCHAR2 DEFAULT 'ENGLISH',
								i_bus_org_id	IN sa.TABLE_BUS_ORG.S_ORG_ID%TYPE
							)
		RETURN NUMBER
	IS
	l_flag NUMBER;

	BEGIN

		SELECT display_flag
			INTO l_flag
		FROM x_ild_regions
		WHERE ild_region2bus_org IN (SELECT objid FROM table_bus_org
											  WHERE s_org_id = upper(i_bus_org_id))
			AND  (CASE
						WHEN upper(i_language) = 'ENGLISH' AND (region_name_english = upper(i_country))
							THEN 1
						WHEN  upper(i_language) = 'SPANISH' AND (region_name_spanish = upper(i_country))
							THEN 1
					END = 1); --Handles Both Languages

		RETURN l_flag;

		EXCEPTION WHEN OTHERS
			THEN
				RETURN 0;

	END GET_DISPLAY_FLAG;
--********************************************************************************
-- Procedure to insert record into table_x_ild_transaction-- CR32641
--********************************************************************************
  PROCEDURE INSERT_TABLE_X_ILD_TRANS(
      IP_DEV                     IN sa.TABLE_X_ILD_TRANSACTION.DEV%TYPE ,
      IP_X_MIN                   IN sa.TABLE_X_ILD_TRANSACTION.X_MIN%TYPE ,
      IP_X_ESN                   IN sa.TABLE_X_ILD_TRANSACTION.X_ESN%TYPE ,
      IP_X_TRANSACT_DATE         IN sa.TABLE_X_ILD_TRANSACTION.X_TRANSACT_DATE%TYPE ,
      IP_X_ILD_TRANS_TYPE        IN sa.TABLE_X_ILD_TRANSACTION.X_ILD_TRANS_TYPE%TYPE ,
      IP_X_ILD_STATUS            IN sa.TABLE_X_ILD_TRANSACTION.X_ILD_STATUS%TYPE ,
      IP_X_LAST_UPDATE           IN sa.TABLE_X_ILD_TRANSACTION.X_LAST_UPDATE%TYPE ,
      IP_X_ILD_ACCOUNT           IN sa.TABLE_X_ILD_TRANSACTION.X_ILD_ACCOUNT%TYPE ,
      IP_ILD_TRANS2SITE_PART     IN sa.TABLE_X_ILD_TRANSACTION.ILD_TRANS2SITE_PART%TYPE ,
      IP_ILD_TRANS2USER          IN sa.TABLE_X_ILD_TRANSACTION.ILD_TRANS2USER%TYPE ,
      IP_X_CONV_RATE             IN sa.TABLE_X_ILD_TRANSACTION.X_CONV_RATE%TYPE ,
      IP_X_TARGET_SYSTEM         IN sa.TABLE_X_ILD_TRANSACTION.X_TARGET_SYSTEM%TYPE ,
      IP_X_PRODUCT_ID            IN sa.TABLE_X_ILD_TRANSACTION.X_PRODUCT_ID%TYPE ,
      IP_X_API_STATUS            IN sa.TABLE_X_ILD_TRANSACTION.X_API_STATUS%TYPE ,
      IP_X_API_MESSAGE           IN sa.TABLE_X_ILD_TRANSACTION.X_API_MESSAGE%TYPE ,
      IP_X_ILD_TRANS2IG_TRANS_ID IN sa.TABLE_X_ILD_TRANSACTION.X_ILD_TRANS2IG_TRANS_ID%TYPE ,
      IP_X_ILD_TRANS2CALL_TRANS  IN sa.TABLE_X_ILD_TRANSACTION.X_ILD_TRANS2CALL_TRANS%TYPE ,
      OP_OBJID OUT sa.TABLE_X_ILD_TRANSACTION.OBJID%TYPE ,
      OP_ERR_NUM OUT NUMBER ,
      OP_ERR_STRING OUT VARCHAR2 )
  AS
  	v_X_IG_ORDER_TYPE  			x_ig_order_type.X_IG_ORDER_TYPE%TYPE;
	v_INSERT_ILD_TRANS_FLAG  	x_ig_order_type.INSERT_ILD_TRANS_FLAG%TYPE;
	v_X_ILD_TRANS_TYPE  	     table_x_ild_transaction.X_ILD_TRANS_TYPE%TYPE := NULL;
	v_exists     NUMBER := 0; --CR54095
  BEGIN
    OP_OBJID := sequ_x_ild_transaction.nextval + 1 + POWER(2 ,28);
		----CR44773  Implementing x_ig_order_type flag logic
	BEGIN
	SELECT 	x_ig_order_type,
			insert_ild_trans_flag
	INTO   	v_x_ig_order_type,
			v_insert_ild_trans_flag
	FROM   	x_ig_order_type
	WHERE  	x_ig_order_type = ip_x_ild_trans_type
    AND ROWNUM = 1;
	EXCEPTION
	WHEN OTHERS THEN NULL;
	END;

	--CR54282,Added logic to replace id_trans_type with CR instead of R for below product_ids.
	IF IP_X_ILD_TRANS_TYPE = 'R'
	    AND IP_X_PRODUCT_ID IN  ( 'TF_PILD_P' , 'NT_PILD_P') THEN

	    v_x_ild_trans_type := 'CR';

	ELSE
	    v_x_ild_trans_type := IP_X_ILD_TRANS_TYPE;
	END IF;

    IF IP_X_ILD_TRANS_TYPE NOT IN ('UI') AND v_INSERT_ILD_TRANS_FLAG ='Y' THEN --CR36599, CR37461 added IF condition to suppress the APN information

    IF IP_X_ILD_TRANS_TYPE NOT                IN ('APN','SIMC','MINC','VP','E911') THEN --CR36599, CR37461 added IF condition to suppress the APN information
      --Added VP for CR38280
      --Added E911 for CR40690
    -- Added as part of CR54095
	SELECT COUNT(1)
	  INTO v_exists
      FROM sa.table_x_ild_transaction
     WHERE x_min                   = IP_X_MIN
       AND x_esn                   = IP_X_ESN
       AND x_product_id            = IP_X_PRODUCT_ID
       AND x_ild_trans2ig_trans_id = IP_X_ILD_TRANS2IG_TRANS_ID
       AND x_ild_trans2call_trans  = IP_X_ILD_TRANS2CALL_TRANS ;
    -- Ends CR54095
    IF v_exists = 0 THEN
		INSERT
		  INTO sa.table_x_ild_transaction a
			(
			  OBJID ,
			  DEV ,
			  X_MIN ,
			  X_ESN ,
			  X_TRANSACT_DATE ,
			  X_ILD_TRANS_TYPE ,
			  X_ILD_STATUS ,
			  X_LAST_UPDATE ,
			  X_ILD_ACCOUNT ,
			  ILD_TRANS2SITE_PART ,
			  ILD_TRANS2USER ,
			  X_CONV_RATE ,
			  X_TARGET_SYSTEM ,
			  X_PRODUCT_ID ,
			  X_API_STATUS ,
			  X_API_MESSAGE ,
			  X_ILD_TRANS2IG_TRANS_ID ,
			  X_ILD_TRANS2CALL_TRANS,
			  WEB_USER_OBJID
			)
			VALUES
			(
			  OP_OBJID ,
			  IP_DEV ,
			  IP_X_MIN ,
			  IP_X_ESN ,
			  IP_X_TRANSACT_DATE ,
			  v_x_ild_trans_type ,
			  IP_X_ILD_STATUS ,
			  IP_X_LAST_UPDATE ,
			  IP_X_ILD_ACCOUNT ,
			  IP_ILD_TRANS2SITE_PART ,
			  IP_ILD_TRANS2USER ,
			  IP_X_CONV_RATE ,
			  IP_X_TARGET_SYSTEM ,
			  IP_X_PRODUCT_ID ,
			  IP_X_API_STATUS ,
			  IP_X_API_MESSAGE ,
			  IP_X_ILD_TRANS2IG_TRANS_ID ,
			  IP_X_ILD_TRANS2CALL_TRANS,
			  sa.customer_info. get_web_user_attributes(IP_X_ESN,'WEB_USER_ID')
			);
		  OP_ERR_NUM    := 0;
		  OP_ERR_STRING := 'SUCCESS';
	  END IF;
	  END IF;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    OP_ERR_NUM    := 1;
    OP_ERR_STRING := 'Unexpected error while inserting record into table_x_ild_transaction';
    sa.OTA_UTIL_PKG.ERR_LOG ( OP_ERR_NUM||' - '||OP_ERR_STRING,                                                                             --p_action
    SYSDATE,                                                                                                                                --p_error_date
    IP_X_ESN,                                                                                                                               --p_key
    'SA.ILD_TRANSACTION_PKG.INSERT_TABLE_X_ILD_TRANS',                                                                                      --p_program_name
    'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
    );
  END INSERT_TABLE_X_ILD_TRANS;
--********************************************************************************
-- Procedure to give ILD product id based on site part objid -- CR32641
--********************************************************************************
  PROCEDURE GET_ILD_PARAMS_BY_SITEPART
    (
      IP_SITE_PART_OBJID IN sa.TABLE_SITE_PART.OBJID%TYPE ,
      IP_ESN             IN sa.TABLE_SITE_PART.X_SERVICE_ID%TYPE ,
      IP_BUS_ORG         IN sa.TABLE_BUS_ORG.S_ORG_ID%TYPE ,
      OP_ILD_PRODUCT_ID OUT sa.TABLE_X_ILD_TRANSACTION.X_PRODUCT_ID%TYPE ,
      OP_ILD_IG_ACCOUNT OUT sa.TABLE_X_ILD_TRANSACTION.X_ILD_ACCOUNT%TYPE ,
      OP_ERR_NUM OUT NUMBER ,
      OP_ERR_STRING OUT VARCHAR2
    )
  AS
    CURSOR UNLIMITED_CURS
      (
        P_SITE_PART_OBJID IN NUMBER
      )
    IS
      SELECT SPL.*
      FROM X_SERVICE_PLAN_SITE_PART SP2SP ,
        X_SERVICE_PLAN SPL
      WHERE 1                      = 1
      AND SPL.OBJID                = SP2SP.X_SERVICE_PLAN_ID
      AND SP2SP.TABLE_SITE_PART_ID = P_SITE_PART_OBJID;
    UNLIMITED_REC UNLIMITED_CURS%ROWTYPE;
    CURSOR ild_feature_cur(p_objid IN NUMBER)
    IS
      SELECT sp.objid,
        sp.mkt_name,
        spfvdef.value_name,
        spfvdef2.value_name property_value
      FROM x_serviceplanfeaturevalue_def spfvdef,
        x_serviceplanfeature_value spfv,
        x_service_plan_feature spf,
        x_serviceplanfeaturevalue_def spfvdef2,
        x_service_plan sp
      WHERE 1                           =1
      AND sp.objid                      = p_objid
      AND spf.sp_feature2service_plan   = sp.objid
      AND spf.sp_feature2rest_value_def = spfvdef.objid
      AND spf.objid                     = spfv.spf_value2spf
      AND SPFVDEF2.OBJID                = SPFV.VALUE_REF
      AND SPFVDEF.VALUE_NAME           IN ('ILD')
      AND SPFVDEF2.VALUE_NAME           = 'YES'
      -- CR46581 GO SMART
      -- ADDING CONDITION TO SKIP IF CREATING ILD TRANSACTION ENTRY
      -- IF BLOCK_ILD_TRANSACTION FEATURE IS SET TO "Y"
      AND NOT EXISTS
        ( SELECT 1 FROM service_plan_feat_pivot_mv mv
          WHERE    service_plan_objid = sp.objid
          AND      NVL(block_ild_transaction,'N') = 'Y' );
      -- END CR46581 GO SMART
    ILD_FEATURE_REC ILD_FEATURE_CUR%ROWTYPE;
    ILD_FEATURE_clear ILD_FEATURE_CUR%ROWTYPE;
    CURSOR VAS_SUB (p_esn IN VARCHAR2)
    IS
      SELECT v.product_id
      FROM x_vas_subscriptions sub,
        vas_programs_view v
      WHERE vas_esn              = p_esn
      AND sub.vas_name           =v.vas_name
      AND vas_category           = 'ILD_REUP'
      AND VAS_SUBSCRIPTION_DATE >= TRUNC(sysdate)
      AND rownum                 < 2 ;
    VAS_SUB_REC VAS_SUB%ROWTYPE ;
    LV_ILD               VARCHAR2(30) := NULL;
    LV_ACCOUNT           VARCHAR2(10);
    LV_CODE              NUMBER(10);
    LV_MESSAGE           VARCHAR2(1000);
    LV_DEFAULT_VALUE_SET VARCHAR2(10);
    LV_SL_PROG_ENROLL_COUNT PLS_INTEGER := 0;
  BEGIN
    LV_ILD                  := NULL;
    LV_ACCOUNT              := 1;
    LV_CODE                 := 0;
    LV_MESSAGE              := 'SUCCESS';
    LV_DEFAULT_VALUE_SET    := 'NO';
    LV_SL_PROG_ENROLL_COUNT := 0;
    DBMS_OUTPUT.PUT_LINE('IP_SITE_PART_OBJID: '||IP_SITE_PART_OBJID);
    DBMS_OUTPUT.PUT_LINE('IP_ESN: '||IP_ESN);
    DBMS_OUTPUT.PUT_LINE('IP_BUS_ORG: '||IP_BUS_ORG);
    -- check if this site part record has a service plan linked to it.
    OPEN UNLIMITED_CURS(IP_SITE_PART_OBJID);
    FETCH UNLIMITED_CURS INTO UNLIMITED_REC;
    IF UNLIMITED_CURS%FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Site part is linked to a Service plan with objid: '||UNLIMITED_REC.OBJID);
      ILD_FEATURE_REC := ILD_FEATURE_CLEAR;
      --Check if the service plan this record is linked to has ILD enabled (YES) or not
      OPEN ILD_FEATURE_CUR(UNLIMITED_REC.OBJID);
      FETCH ILD_FEATURE_CUR INTO ILD_FEATURE_REC;
      IF ILD_FEATURE_CUR%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Service plan this record is linked to has ILD enabled (YES)');

        --CR 53913,Get product ID in order to support monthly executive ILD redemptions.
        IF IP_BUS_ORG = 'SIMPLE_MOBILE' THEN

          dbms_output.put_line('Processing Executive SM ILDs');

          BEGIN

            SELECT x_product_id,
                   x_priority
              INTO LV_ILD,
                   LV_ACCOUNT
            FROM   x_multi_rate_plan_esns
            WHERE  1 = 1
              AND  x_esn  = IP_ESN
              AND  x_service_plan_id = UNLIMITED_REC.OBJID
              AND  ROWNUM = 1;

            dbms_output.put_line('Executive SM ILD,LV_ILD:'||LV_ILD);
          EXCEPTION WHEN OTHERS THEN
            LV_ILD := NULL;
            LV_ACCOUNT := 1; --CR53770, CR55110 SM ILD EME
          END;
        END IF; --IF IP_BUS_ORG = 'SIMPLE_MOBILE'

        IF LV_ILD IS NULL THEN
          --Get product id for this service plan
          LV_ILD := sa.DEVICE_UTIL_PKG.GET_ILD_PRD(IP_ESN);
        END IF;

        DBMS_OUTPUT.PUT_LINE('Product id for this service plan: '||LV_ILD);
        IF LV_ILD                        = 'NOT_EXIST' THEN
          IF FN_IS_IT_SL_HANDSET(IP_ESN) ='YES' THEN
            --As handset belongs to Safelink, we need to give SafeLink related product code
            DBMS_OUTPUT.PUT_LINE('This handset belongs to Safelink, we need to give SafeLink related product code');
            IF IP_BUS_ORG IN ('NET10' , 'TRACFONE') THEN
              LV_DEFAULT_VALUE_SET := 'YES';
              LV_ILD               := GET_ILD_PRD_DEF_BY_PRIORITY(IP_BUS_ORG, 2);--For SL send 2
              DBMS_OUTPUT.PUT_LINE('Giving SafeLink product code '||LV_ILD||' for bus org: '||IP_BUS_ORG);
            ELSE
              DBMS_OUTPUT.PUT_LINE('We are not giving SafeLink product code for bus org: '||IP_BUS_ORG);
            END IF;
          ELSE
            NULL;
            DBMS_OUTPUT.PUT_LINE('This handset does not belongs to Safelink - step 1');
          END IF;
        END IF;
      ELSIF ILD_FEATURE_CUR%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('Service plan this record is linked to has ILD dis-enabled (NO)/ does not exist');
        IF FN_IS_IT_SL_HANDSET(IP_ESN) ='YES' THEN
          DBMS_OUTPUT.PUT_LINE('This handset belongs to Safelink, we need to give SafeLink related product code');
          IF IP_BUS_ORG IN ('NET10') THEN
            -- LV_DEFAULT_VALUE_SET := 'YES';                                                     --Removed for CR45982 AB
            -- LV_ILD               := GET_ILD_PRD_DEF_BY_PRIORITY(IP_BUS_ORG, 2);--For SL send 2
            --DBMS_OUTPUT.PUT_LINE('Giving SafeLink product code '||LV_ILD||' for bus org: '||IP_BUS_ORG);
            DBMS_OUTPUT.PUT_LINE('Safelink handsets should not be given ILD benefits for: '||IP_BUS_ORG);
          ELSE
            DBMS_OUTPUT.PUT_LINE('We are not giving SafeLink product code for bus org: '||IP_BUS_ORG);
          END IF;
        ELSE
          NULL;
          DBMS_OUTPUT.PUT_LINE('This handset does not belongs to Safelink - step 2');
        END IF;
      END IF;
      CLOSE ILD_FEATURE_CUR;
      IF LV_DEFAULT_VALUE_SET = 'YES' THEN
        DBMS_OUTPUT.PUT_LINE('VAS value take priority over default value being set by us. So checking this ESN has a VAS, if it has assign that value');
        -- VAS value take priority over default value being set by us. So checking this ESN has a VAS, if it has assign that value.
        OPEN VAS_SUB(IP_ESN) ;
        FETCH VAS_SUB INTO VAS_SUB_REC ;
        IF (VAS_SUB%FOUND) THEN
          LV_ILD := VAS_SUB_REC.PRODUCT_ID ;
          DBMS_OUTPUT.PUT_LINE('VAS benefit exist with product id: '||LV_ILD);
          IF IP_BUS_ORG IN ('TRACFONE') THEN
            LV_ACCOUNT := 2;
          END IF;
        END IF ;
        CLOSE VAS_SUB;
      END IF;
      DBMS_OUTPUT.PUT_LINE('End of UNLIMITED_CURS%FOUND logic');
    ELSIF UNLIMITED_CURS%NOTFOUND THEN
      -- Check if this ESN is under VAS - ILD_REUP category
      DBMS_OUTPUT.PUT_LINE('Site part is not linked to any Service plan');
      OPEN VAS_SUB(IP_ESN) ;
      FETCH VAS_SUB INTO VAS_SUB_REC ;
      IF (VAS_SUB%FOUND) THEN
        LV_ILD := VAS_SUB_REC.PRODUCT_ID ;
        IF IP_BUS_ORG IN ('TRACFONE') THEN --TODO: Check this.. should it be only for LV_ILD ='TF_ILD_10'??
          LV_ACCOUNT := 2;
        END IF;
        DBMS_OUTPUT.PUT_LINE('VAS benefit exist with product id: '||LV_ILD);
      ELSIF VAS_SUB%NOTFOUND THEN
        --If product id does not exist based on service plan and VAS; get lv_ild based on bus org
        DBMS_OUTPUT.PUT_LINE('If product id does not exist based on service plan and VAS; get lv_ild based on bus org');
        IF FN_IS_IT_SL_HANDSET(IP_ESN) = 'YES' THEN
          --As handset belongs to Safelink, we need to give SafeLink related product code
          DBMS_OUTPUT.PUT_LINE('As handset belongs to Safelink, we need to give SafeLink related product code');
          IF FN_IS_IT_FEATURE_PHONE(IP_ESN) = 'YES' THEN
            DBMS_OUTPUT.PUT_LINE('This is a featured phone');
            IF IP_BUS_ORG IN ('TRACFONE') THEN
              SELECT COUNT(*)
              INTO LV_SL_PROG_ENROLL_COUNT
              FROM sa.X_PROGRAM_ENROLLED XPE ,
                sa.X_PROGRAM_PARAMETERS XPP
              WHERE 1                          =1
              AND XPE.X_ESN                    =IP_ESN
              AND XPE.X_ENROLLMENT_STATUS      = 'ENROLLED'
              AND XPE.PGM_ENROLL2PGM_PARAMETER = XPP.OBJID
              AND XPP.X_ILD                    = 1 ;
              IF LV_SL_PROG_ENROLL_COUNT       >0 THEN --CR35478
                --As handset belongs to Safelink, we need to give SafeLink related product code
                LV_DEFAULT_VALUE_SET := 'YES';
                LV_ILD               := GET_ILD_PRD_DEF_BY_PRIORITY(IP_BUS_ORG, 2);--For SL send 2
                DBMS_OUTPUT.PUT_LINE('Giving default product code '||LV_ILD||' for bus org: '||IP_BUS_ORG);
              END IF;
            ELSIF IP_BUS_ORG IN ('NET10') THEN
              --As handset belongs to Safelink, we need to give SafeLink related product code
              LV_DEFAULT_VALUE_SET := 'YES';
              LV_ILD               := GET_ILD_PRD_DEF_BY_PRIORITY(IP_BUS_ORG, 2);--For SL send 2
              DBMS_OUTPUT.PUT_LINE('Giving default product code '||LV_ILD||' for bus org: '||IP_BUS_ORG);
            ELSE
              LV_CODE    := 2;
              LV_MESSAGE := 'This is a SL device and a featured phone; But bus org is not one of Net10 or Tracfone';
              LV_ILD     := 'ERR_BRAND';
              DBMS_OUTPUT.PUT_LINE('This is a SL device and a featured phone; But bus org is not one of Net10 or Tracfone');
            END IF;
          ELSE
            NULL;
            DBMS_OUTPUT.PUT_LINE('This is not a featured phone');
          END IF;
        ELSE
          DBMS_OUTPUT.PUT_LINE('Handset does not belongs to Safelink');
          IF FN_IS_IT_FEATURE_PHONE(IP_ESN) = 'YES' THEN
            DBMS_OUTPUT.PUT_LINE('This is a featured phone');
            IF IP_BUS_ORG = 'NET10' THEN
              --As handset does not belong to Safelink, give Net10 product code
              LV_CODE    := 3;
              LV_MESSAGE := 'This is not a SL device and a featured phone; Bus org is Net10; Service plan attached to this should be giving ILD code';
              LV_ILD     := 'ERR_BRAND';
              --LV_DEFAULT_VALUE_SET := 'YES';
              --LV_ILD := 'NT_PILD_P';
            ELSIF IP_BUS_ORG = 'TRACFONE' THEN
              --If bus org is tracfone, give corresponding product id;
              LV_DEFAULT_VALUE_SET := 'YES';
              LV_ILD               := GET_ILD_PRD_DEF_BY_PRIORITY(IP_BUS_ORG, 1);
            ELSE
              --for everything else this should error
              LV_CODE    := 4;
              LV_MESSAGE := 'This is not a SL device and a featured phone; But bus org is not one of Net10 or Tracfone';
              LV_ILD     := 'ERR_BRAND';
            END IF;
            DBMS_OUTPUT.PUT_LINE('Setting default product code value: '||LV_ILD);
          ELSE
            NULL;
            DBMS_OUTPUT.PUT_LINE('This is not a featured phone');
          END IF;
        END IF;
      END IF;
      CLOSE VAS_SUB;
      DBMS_OUTPUT.PUT_LINE('End of UNLIMITED_CURS%NOTFOUND logic');
    END IF;
    IF LV_ILD    IS NULL THEN
      LV_ACCOUNT := NULL;
      LV_CODE    := 5;
      LV_MESSAGE := 'ILD product ID not found';
      DBMS_OUTPUT.PUT_LINE('ILD product ID not found');
    END IF;
    IF LV_ILD = 'ERR_BRAND' THEN
      sa.OTA_UTIL_PKG.ERR_LOG ( 'Error while checking ILD benefits for ESN:'||IP_ESN, --p_action
      SYSDATE,                                                                        --p_error_date
      IP_ESN,                                                                         --p_key
      'SA.ILD_TRANSACTION_PKG.GET_ILD_PARAMS_BY_SITEPART',                            --p_program_name
      'LV_CODE - '||LV_CODE ||' ; LV_MESSAGE '||LV_MESSAGE                            --p_error_text
      );
      OP_ILD_PRODUCT_ID := LV_ILD;
    END IF;
    CLOSE UNLIMITED_CURS;
    OP_ILD_PRODUCT_ID := LV_ILD;
    OP_ILD_IG_ACCOUNT := LV_ACCOUNT;
    OP_ERR_NUM        := LV_CODE;
    OP_ERR_STRING     := LV_MESSAGE;
    DBMS_OUTPUT.PUT_LINE('OP_ILD_PRODUCT_ID: '||OP_ILD_PRODUCT_ID);
    DBMS_OUTPUT.PUT_LINE('OP_ILD_IG_ACCOUNT: '||OP_ILD_IG_ACCOUNT);
    DBMS_OUTPUT.PUT_LINE('OP_ERR_NUM: '||OP_ERR_NUM);
    DBMS_OUTPUT.PUT_LINE('OP_ERR_STRING: '||OP_ERR_STRING);
  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    OP_ERR_NUM    := 6;
    OP_ERR_STRING := 'Unexpected error while retrieving ILD parameters based on site part objid';
    sa.OTA_UTIL_PKG.ERR_LOG ( OP_ERR_NUM||' - '||OP_ERR_STRING,                                                                             --p_action
    SYSDATE,                                                                                                                                --p_error_date
    IP_SITE_PART_OBJID,                                                                                                                     --p_key
    'SA.ILD_TRANSACTION_PKG.GET_ILD_PARAMS_BY_SITEPART',                                                                                    --p_program_name
    'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
    );
  END GET_ILD_PARAMS_BY_SITEPART;
  FUNCTION get_sl_ild_prd_def(
      v_bus_org IN VARCHAR2)
    RETURN VARCHAR2
  IS
    /*********************************************************************************************************************************************************************/
    /* function Name: GET_ILD_PRD_DEF */
    /* Description: return ILD PRODUCT CODE for default for Each Brand if not found brand return 'ERR_BRAND' */
    /**********************************************************************************************************************************************************************/
    CURSOR get_ild_curs
    IS
      SELECT ti.x_ild_product ild_code
      FROM sa.table_x_ild_product ti,
        table_bus_org bo
      WHERE bo.org_id     = v_bus_org
      AND bo.objid        = ti.x_bus_org
      AND ti.x_is_default = 2;
    get_ild_rec get_ild_curs%rowtype;
  BEGIN
    OPEN get_ild_curs;
    FETCH get_ild_curs INTO get_ild_rec;
    IF get_ild_curs%notfound THEN
      CLOSE get_ild_curs;
      RETURN 'ERR_BRAND' ;
    ELSE
      CLOSE get_ild_curs;
      RETURN get_ild_rec.ild_code;
    END IF;
  END get_sl_ild_prd_def;
  PROCEDURE p_insert_ild_transaction_sl_1(
      p_min            NUMBER,
      p_esn_from       VARCHAR2, -- UPGRADE/DEENROLL/PLAN CHANGE
      p_esn_to         VARCHAR2, --UPGRADE
      p_action         VARCHAR2, --UPGRADE ELSE NULL
      p_brand          VARCHAR2,
      p_ild_trans_type VARCHAR2, --D, A
      p_err_num OUT NUMBER,
      p_err_string OUT VARCHAR2)
  IS
    /**************************************************************************
    This procedure is used to insert the records for table_x_ild_transaction
    **************************************************************************/
    v_product_id table_x_ild_transaction.x_ild_account%TYPE;
    v_min table_site_part.x_min%TYPE;
    v_device_from table_x_part_class_values.x_param_value%TYPE;
    v_device_to table_x_part_class_values.x_param_value%TYPE;
    v_is_insert VARCHAR2(1) := 'N';
    CURSOR cur_get_min_for_sl(c_esn VARCHAR2)
    IS
      SELECT x_min x_min
      FROM table_site_part tsp
      WHERE 1              = 1
      AND tsp.x_service_id = c_esn
      AND part_status      = 'Active';
    rec_get_min_for_sl cur_get_min_for_sl%ROWTYPE;
    CURSOR cur_get_ild_transaction (c_min VARCHAR2, c_esn VARCHAR2)
    IS
      SELECT *
      FROM
        (SELECT *
        FROM table_x_ild_transaction
        WHERE 1              = 1
        AND x_min            = c_min
        AND x_esn            = c_esn
        AND X_ILD_TRANS_TYPE = 'A'
        AND X_ILD_STATUS     = 'COMPLETED'
        AND X_PRODUCT_ID     = v_product_id --only safelink ILD will be selected
        ORDER BY X_TRANSACT_DATE DESC
        )
    WHERE ROWNUM =1;
    rec_get_ild_transaction cur_get_ild_transaction%rowtype;
  BEGIN
    v_product_id   := get_sl_ild_prd_def(p_brand);
    p_err_num      := 0;
    p_err_string   := 'SUCCESS';
    v_min          := p_min;
    IF TRIM(p_min) IS NULL THEN
      OPEN cur_get_min_for_sl (NVL(p_esn_to,p_esn_from)) ;
      FETCH cur_get_min_for_sl INTO rec_get_min_for_sl;
      IF cur_get_min_for_sl%FOUND THEN
        v_min := rec_get_min_for_sl.x_min;
      END IF;
      CLOSE cur_get_min_for_sl;
    END IF;
    FOR rec IN cur_get_ild_transaction (v_min, p_esn_from)
    LOOP
      --v_product_id := get_sl_ild_prd_def(p_brand);
      v_is_insert          := 'N'; --re initialize to N at the start of the loop
      IF NVL(p_action, '~') = 'UPGRADE' THEN
        --sa.sp_get_esn_parameter_value(p_esn_from, 'DEVICE_TYPE', 0, v_device_from, p_err_num, p_err_string);
        v_device_from:=get_device_type(p_esn_from);
        /*IF p_err_num <> 0 THEN
        RETURN;
        END IF;*/
        --sa.sp_get_esn_parameter_value(p_esn_to, 'DEVICE_TYPE', 0, v_device_to, p_err_num, p_err_string);
        v_device_to:=get_device_type(p_esn_to);
        /*IF p_err_num <> 0 THEN
        RETURN;
        END IF;*/
        IF v_device_from IN ('FEATURE_PHONE') AND v_device_to IN ('SMARTPHONE', 'BYOP' ) THEN
          v_is_insert := 'Y';
        END IF; --if v_device_from in ('FEATURE_PHONE') and v_device_to in ('SMARTPHONE', 'BYOP' )
        -- if rec.x_product_id = v_product_id then
      ELSE                  --if p_action = 'UPGRADE' then
        v_is_insert := 'Y'; --FOR DEENROLL/PLAN CHANGE
      END IF;               --if p_action = 'UPGRADE' then
      IF v_is_insert = 'Y' THEN
        INSERT
        INTO sa.table_x_ild_transaction
          (
            objid ,
            x_min ,
            x_esn ,
            x_transact_date ,
            x_ild_trans_type ,
            x_ild_status ,
            ild_trans2site_part ,
            x_ild_account ,
            x_product_id,
            web_user_objid
          )
          VALUES
          (
            sa.seq('x_ild_transaction') ,
            NVL(p_min,v_min) ,
            p_esn_from ,
            SYSDATE ,
            p_ild_trans_type ,
            'PENDING' ,
            rec.ild_trans2site_part ,
            rec.x_ild_account ,
            rec.x_product_id,
            sa.customer_info. get_web_user_attributes(p_esn_from,'WEB_USER_ID')
          );
      END IF;
    END LOOP; --for rec in cur_get_ild_transaction (v_min, p_esn_from)
  EXCEPTION
  WHEN OTHERS THEN
    sa.ota_util_pkg.err_log ( p_action => 'p_insert_ild_transaction_sl', p_error_date => SYSDATE, p_key => p_esn_from, p_program_name => 'p_insert_ild_transaction_sl', p_error_text => SUBSTR(sqlerrm, 1, 4000) );
  END p_insert_ild_transaction_sl_1;

-- Procedure to create a refund ild transaction. Defect #258 (CR38687)
procedure p_insert_10ild_transaction (i_esn             in varchar2 ,
                                      i_min             in number ,
                                      i_brand           in varchar2 ,
                                      i_sourcesystem    in varchar2 ,
                                      i_action          in varchar2 , --REFUND
                                      i_ild_trans_type  in varchar2 , --'D'
                                      i_purch_hdr_objid in number ,
                                      o_err_num         out number ,
                                      o_err_str         out varchar2,
                                      i_pgm_hdr_objid   in number default  null --CR43101
                                     )
 as
   pragma autonomous_transaction;
   l_ild_product_id varchar2(30);

    --cursor to retrieve for $10ILD product id
   cursor cur_10ild_prd_id(i_purch_hdr_objid number)
   is
    select ild_prg.product_id ild_product_id
     from  table_x_purch_hdr hdr ,
           table_x_purch_dtl dtl ,
           table_part_num prt_num ,
           table_mod_level mod_level,
           table_x_red_card red_card ,
           vas_programs_view ild_prg
     where prt_num.objid             = mod_level.part_info2part_num
       and mod_level.objid             = red_card.x_red_card2part_mod
       and red_card.x_red_code         = dtl.x_red_card_number
       and ild_prg.vas_app_card        = prt_num.part_number
       and dtl.x_purch_dtl2x_purch_hdr = hdr.objid
       and hdr.objid                   = i_purch_hdr_objid;
   rec_10ild_prd_id cur_10ild_prd_id%rowtype;

    --cursor to retrieve for ild product id
   cursor cur_ild_prd_id(i_purch_hdr_objid number)
   is
    select spf.ild_product ild_product_id
      from table_x_purch_hdr hdr ,
           table_x_purch_dtl dtl ,
           table_part_num prt_num ,
           table_mod_level mod_level,
           table_x_red_card red_card ,
           service_plan_feat_pivot_mv spf
     where prt_num.objid               = mod_level.part_info2part_num
       and mod_level.objid               = red_card.x_red_card2part_mod
       and red_card.x_red_code           = dtl.x_red_card_number
       and spf.plan_purchase_part_number = prt_num.part_number
       and spf.plan_type                <> 'PAYGO' --Excluding the paygo plans
       and dtl.x_purch_dtl2x_purch_hdr   = hdr.objid
       and hdr.objid                     = i_purch_hdr_objid;
   rec_ild_prd_id cur_ild_prd_id%rowtype;

     --cursor to retrieve the existing record from table_x_ild_transaction
   cursor cur_ild_tran(i_esn varchar2, i_min varchar2, i_ild_product_id varchar2 )
   is
    select * from
            (select *
               from table_x_ild_transaction
              where 1   = 1
                and x_min = i_min
                and x_esn = i_esn
                and x_ild_status = 'COMPLETED'
                and x_product_id = i_ild_product_id
              order by x_transact_date desc )
     where rownum =1;
   rec_ild_rowtype table_x_ild_transaction%rowtype ;

     --cursor to retrieve the pgm refund ild prodcut id  --CR43101
   cursor cur_pgm_refund_ild (p_pgm_hdr_objid in number)
   is
    select fea.ild_product ild_product_id
      from x_program_purch_dtl dtl,
           x_program_purch_hdr hdr,
           x_program_enrolled pe,
           table_site_part sp,
           x_service_plan_site_part spsp,
           sa.service_plan_feat_pivot_mv fea
     where 1 = 1
       and hdr.objid = p_pgm_hdr_objid
       and dtl.pgm_purch_dtl2prog_hdr = hdr.objid
       and dtl.pgm_purch_dtl2pgm_enrolled = pe.objid
       and pe.pgm_enroll2site_part = sp.objid
       and sp.objid = spsp.table_site_part_id
       and spsp.x_service_plan_id = fea.service_plan_objid;
   rec_pgm_refund_ild  cur_pgm_refund_ild%rowtype;

  begin
    --
    if i_sourcesystem = 'TAS' and i_action = 'REFUND' then

         --cc_refund through redemption cards
        if i_purch_hdr_objid is not null then
            --
            open cur_10ild_prd_id(i_purch_hdr_objid);
            fetch cur_10ild_prd_id into rec_10ild_prd_id;
             --
            open cur_ild_prd_id(i_purch_hdr_objid);
            fetch cur_ild_prd_id into rec_ild_prd_id;
              --10 ild
              if cur_10ild_prd_id%found then
                 open cur_ild_tran(i_esn, i_min, rec_10ild_prd_id.ild_product_id);
                 fetch cur_ild_tran into rec_ild_rowtype;
              --other ild
              elsif cur_ild_prd_id%found then
                 open cur_ild_tran(i_esn, i_min, rec_ild_prd_id.ild_product_id);
                 fetch cur_ild_tran into rec_ild_rowtype;
              end if;

            close cur_10ild_prd_id;
            close cur_ild_prd_id;

         --billing_refund for the enrolments
        elsif i_pgm_hdr_objid is not null then
            --
            open cur_pgm_refund_ild (i_pgm_hdr_objid);
            fetch cur_pgm_refund_ild into rec_pgm_refund_ild;
              --
              if cur_pgm_refund_ild%found then
                open cur_ild_tran(i_esn, i_min, rec_pgm_refund_ild.ild_product_id);
                fetch cur_ild_tran into rec_ild_rowtype;
              end if;
             --
            close cur_pgm_refund_ild;
        end if;

        --insert into ild trans table
        if cur_ild_tran%isopen then  -- to fix the error in prod
            --
            if cur_ild_tran%found then
                --
                insert
                  into sa.table_x_ild_transaction
                       (objid ,
                        x_min ,
                        x_esn ,
                        x_transact_date ,
                        x_ild_trans_type ,
                        x_ild_status ,
                        x_ild_account ,
                        x_product_id ,
                        x_last_update )
                values (sa.seq('x_ild_transaction') ,
                        i_min ,
                        i_esn ,
                        sysdate ,
                        'ILDR' ,
                        'PENDING' ,
                        rec_ild_rowtype.x_ild_account,
                        rec_ild_rowtype.x_product_id,
                        sysdate );
            end if; --insert

            close cur_ild_tran;
        end if;




        o_err_num := 0;
        o_err_str := 'SUCCESS';

    else --otherthan TAS source
      o_err_num := 0;
      o_err_str := 'NO ACTION';
    end if;
    --
    commit;
    --
  exception
   when others then
     o_err_num :=sqlcode;
     o_err_str :=substr(sqlerrm,1,500);
     sa.ota_util_pkg.err_log ( p_action => 'p_insert_10ild_transaction', p_error_date => sysdate, p_key => i_esn, p_program_name => 'p_insert_10ild_transaction', p_error_text => substr(sqlerrm, 1, 4000) );
  end p_insert_10ild_transaction;
--********************************************************************************
 -- Procedure to return all regions that are available for specified Bus_org.
 -- CR43833
--********************************************************************************
	PROCEDURE GET_REGIONS (	i_language		IN VARCHAR2 DEFAULT 'ENGLISH',
									i_bus_org_id	IN sa.TABLE_BUS_ORG.S_ORG_ID%TYPE,
									o_regions		OUT ild_reg_tab,
									o_err_num		OUT VARCHAR2,
									o_err_string	OUT VARCHAR2)
		AS
	ir_tab ild_reg_tab := ild_reg_tab();

	BEGIN
		--Bus Org cannot be null
		IF i_bus_org_id IS NULL THEN
			o_err_num		:= 0;
			o_err_string  := 'Bus Org not Passed';
			RETURN;
		END IF;

		BEGIN
			--Based on language it will determine which column it collects
			SELECT ild_reg_type (a.ild_region)
			BULK COLLECT
			INTO ir_tab
			FROM	(	SELECT CASE upper(i_language)
									WHEN 'ENGLISH' THEN region_name_english
									WHEN 'SPANISH' THEN region_name_spanish
								END ild_region
						FROM x_ild_regions
						WHERE display_flag = 1
							AND ild_region2bus_org IN (SELECT objid FROM table_bus_org
																WHERE s_org_id = upper(i_bus_org_id))
					) a;
			EXCEPTION
				WHEN OTHERS THEN
					o_err_num		:= SQLCODE;
					o_err_string  := SQLERRM;
					RETURN;
		END;

		IF ( ir_tab.COUNT = 0 ) THEN
			o_err_num		:= '0';
			o_err_string  := 'SUCCESS | NO DATA FOUND';
			RETURN;
		END IF;

		o_regions 		:= ir_tab;
		o_err_num		:= '0';
		o_err_string	:= 'SUCCESS';

		EXCEPTION
			WHEN others THEN
				o_err_num 		:= SQLCODE;
				o_err_string  := 'Error Retrieving Regions : ' || SQLERRM;

	END GET_REGIONS;

-- Procedure to update min and ild status in table_x_ild_transaction
-- when MIN is available from INTERGATE
  PROCEDURE P_UPDATE_TABLE_X_ILD_TRAN(i_esn          IN VARCHAR2,
                                      i_order_type   IN VARCHAR2,
                                      i_min          IN VARCHAR2,
                                      o_err_num      OUT VARCHAR2,
                                      o_err_string   OUT VARCHAR2 )
  IS
  BEGIN
    IF (i_order_type='A' AND i_min NOT LIKE 'T%') THEN
      UPDATE
        /*+ index(ild,INDX_X_ILD_TRANSACTION) */
        sa.table_x_ild_transaction ild
      SET x_min        = i_min ,
        x_ild_status   = 'PENDING'
      WHERE x_esn      = i_esn
      AND x_ild_status = 'WAITING';
    END IF;
    o_err_num    := '0';
    o_err_string := 'SUCCESS';
  EXCEPTION
  WHEN OTHERS THEN
    o_err_num    := SQLCODE;
    o_err_string := 'Error Updating table_x_ild_transaction : ' || SUBSTR(SQLERRM,1,500);
  END P_UPDATE_TABLE_X_ILD_TRAN;

--CR53217 Net10 web common standards
PROCEDURE get_ild_transaction_flag(
    i_esn IN VARCHAR2,
    i_min IN VARCHAR2,
    o_ild_transaction_flag OUT VARCHAR2,
    o_err_num OUT NUMBER,
    o_err_string OUT VARCHAR2)
IS

  c customer_type := customer_type();

BEGIN
  --
  IF (i_esn      IS NULL AND i_min IS NULL)
  THEN
    o_err_num    := '1111';
    o_err_string := 'ESN/MIN name all cannot be null';
    RETURN;
  ELSE

    c.esn := NVL(i_esn, customer_info.get_esn ( i_min ));
    c.min := NVL(i_min, customer_info.get_min ( i_esn ));

  END IF;

  c.web_user_objid := sa.customer_info. get_web_user_attributes(c.esn,'WEB_USER_ID');
  --Get the web user objid
  SELECT
    CASE
      WHEN COUNT(*)>0
      THEN 'Y'
      ELSE 'N'
    END
  INTO o_ild_transaction_flag
  FROM table_x_ild_transaction ilt
  WHERE ilt.x_esn          = c.esn
  AND ilt.x_min            = c.min
  AND WEB_USER_OBJID       = c.web_user_objid
  AND ilt.x_ild_status    <>'FAILED';
  --If the ILD trasaction doesnt exist with web_user_objid check based on X_ILD_TRANS2CALL_TRANS
  IF NVL(o_ild_transaction_flag,'N') = 'N' THEN
    SELECT
      CASE
        WHEN COUNT(*)>0
        THEN 'Y'
        ELSE 'N'
      END
    INTO o_ild_transaction_flag
    FROM table_x_ild_transaction ilt,
      TABLE_X_CALL_TRANS CTP
    WHERE ilt.x_esn               = c.esn
    AND ilt.x_min                 = c.min
    AND ILT.X_ILD_TRANS2CALL_TRANS=CTP.OBJID
    AND ILT.x_esn                 =ctp.x_service_id
    AND ILT.X_MIN                 =ctp.x_min
    AND ilt.x_ild_status         <>'FAILED';
  END IF;
  o_err_num    := 0;
  o_err_string := 'SUCCESS';
EXCEPTION
WHEN OTHERS THEN
  o_ild_transaction_flag :='N';
  o_err_num              := 11111;
  o_err_string           := SUBSTR(SQLERRM ,1 ,100);
END get_ild_transaction_flag;

--CR53217 Net10 web common standards

--CR48260 SM MLD new procedure Starts here
PROCEDURE provision_10_ild(
    i_device_id          IN VARCHAR2,             --esn or min expected here.
    i_ild_pin            IN VARCHAR2,             --x_red_code
    i_Enroll_low_balance IN VARCHAR2 DEFAULT 'N', -- Y (Enroll)/N (donot enroll) / D (De-enroll)
    i_sourcesystem       IN VARCHAR2,
    o_err_num            OUT NUMBER,
    o_err_string         OUT VARCHAR2,
    o_call_trans_objid   OUT NUMBER)
IS
  l_vas_service_id NUMBER;
  l_vas_product_id VARCHAR2(50);
  l_rc_objid       NUMBER;
  l_ild_objid      NUMBER;

  CURSOR pin_details
  IS
    SELECT xct_red_card.x_code_name pin_status ,
      tpi_esn.part_serial_no esn
    FROM table_part_inst tpi_red_card
    JOIN table_x_code_table xct_red_card
    ON tpi_red_card.x_part_inst_status = xct_red_card.x_code_number
    LEFT OUTER JOIN table_part_inst tpi_esn
    ON tpi_red_card.part_to_esn2part_inst = tpi_esn.objid
    AND tpi_esn.x_domain                  = 'PHONES'
    WHERE tpi_red_card.x_red_code         = i_ild_pin
    AND tpi_red_card.x_domain             = 'REDEMPTION CARDS';
  pin_rec pin_details%ROWTYPE;

  ct sa.call_trans_type := sa.call_trans_type ();
  cst sa.customer_type  := sa.customer_type ();
  pi sa.part_inst_type  := sa.part_inst_type();

BEGIN
  --Assuming i_device_id has MIN
  cst.esn := sa.customer_info.get_esn ( i_min => i_device_id );
  cst.min := i_device_id ;
  --Unable to get esn from min, so assuming i_device_id has ESN
  IF cst.esn IS NULL THEN
    cst.min  := sa.customer_info.get_min ( i_esn => i_device_id );
    cst.esn  := i_device_id;
  END IF;

  IF cst.esn       IS NULL OR cst.min IS NULL THEN
    o_err_num    := '1';
    o_err_string := 'UNABLE TO RETRIEVE MIN / ESN';
    RETURN;
  END IF;

  IF NVL(i_Enroll_low_balance, 'X') = 'D' THEN
    BEGIN
       SELECT PRODUCT_ID INTO l_vas_product_id
       FROM sa.vas_programs_view
       WHERE vas_category = 'ILD_REUP'
       AND vas_bus_org    = sa.customer_info.get_bus_org_id (i_esn => cst.esn) ;
    EXCEPTION
    WHEN OTHERS THEN
        o_err_num    := '9';
        o_err_string := 'UNABLE TO RETRIEVE ILD PRODUCT ID';
        RETURN;
    END ;
    --Retrieve customer details
    cst := cst.retrieve_min ( i_min => cst.min );

    l_vas_product_id               := 'BP'|| l_vas_product_id ;
    --call insert table_x_ild_insert for BP enrolment
      INSERT
      INTO sa.table_x_ild_transaction a
        (
          OBJID                      ,
          X_MIN                      ,
          X_ESN                      ,
          X_TRANSACT_DATE            ,
          X_ILD_TRANS_TYPE           ,
          X_ILD_STATUS               ,
          X_LAST_UPDATE              ,
          X_ILD_ACCOUNT              ,
          ILD_TRANS2SITE_PART        ,
          X_CONV_RATE                ,
          X_PRODUCT_ID               ,
          WEB_USER_OBJID
        )
        VALUES
        (
          sequ_x_ild_transaction.nextval + 1 + POWER(2 ,28)                , --OBJID
          cst.min                                                          , --X_MIN
          cst.esn                                                          , --X_ESN
          SYSDATE                                                          , --X_TRANSACT_DATE
          'S'                                                              , --X_ILD_TRANS_TYPE
          'PENDING'                                                        , --X_ILD_STATUS
          SYSDATE                                                          , --X_LAST_UPDATE
          '1'                                                              , --X_ILD_ACCOUNT
          cst.site_part_objid                                              , --ILD_TRANS2SITE_PART
          '1'                                                              , --X_CONV_RATE
          l_vas_product_id                                                 , --X_PRODUCT_ID
          sa.customer_info.get_web_user_attributes(cst.esn,'WEB_USER_ID')   --WEB_USER_OBJID
        );
       o_err_num    := '0';
       o_err_string := 'SUCCESS';
    RETURN;
  END IF;

  --Validate pin is unused and  sitting in table_part_inst.
  OPEN pin_details;
  FETCH pin_details INTO pin_rec;
  IF pin_details%NOTFOUND THEN
    o_err_num    := '2';
    o_err_string := 'UNABLE TO RETRIEVE PIN DETAILS';
    CLOSE pin_details;
    RETURN;
  END IF;
  CLOSE pin_details;
  IF cst.esn       <> pin_rec.esn THEN
    o_err_num    := '3';
    o_err_string := 'PIN IS NOT ATTACHED ESN :' ||cst.esn;
    RETURN;
  END IF;

  IF pin_rec.pin_status NOT IN ('RESERVED','RESERVED QUEUED','NOT REDEEMED' ) THEN
    o_err_num    := '4';
    o_err_string := 'PIN IS IN STATUS:' ||pin_rec.pin_status;
    RETURN;
  END IF;

  -- GET vas PROGRAM OBJID based on PIN
  l_vas_service_id    := sa.VAS_MANAGEMENT_PKG.get_vas_service_id_by_pin(in_pin => i_ild_pin);
  IF l_vas_service_id IS NULL THEN
    o_err_num         := '5';
    o_err_string      := 'UNABLE TO FETCH VAS SERVICE ID';
    RETURN;
  END IF ;

  --get VAS product ID
  l_vas_product_id                 := sa.VAS_MANAGEMENT_PKG.get_vas_service_param_val(in_vas_id => l_vas_service_id, in_vas_param => 'PRODUCT_ID');
  IF l_vas_product_id IS NULL THEN
    o_err_num         := '6';
    o_err_string      := 'UNABLE TO FETCH VAS PRODUCT ID';
    RETURN;
  END IF ;

  --Retrieve customer details
  cst := cst.retrieve_min ( i_min => cst.min );

  --Create Call Trans
  ct := call_trans_type ( i_call_trans2site_part     => cst.site_part_objid ,
                        i_action_type                => '6'                 , -- Redemption
                        i_call_trans2carrier         => cst.carrier_objid   ,
                        i_call_trans2dealer          => cst.inv_bin_objid   ,
                        i_call_trans2user            => 268435556           , -- user objid for call trans 'SA'
                        i_line_status                => NULL                ,
                        i_min                        => cst.min             ,
                        i_esn                        => cst.esn             ,
                        i_sourcesystem               => i_sourcesystem      ,
                        i_transact_date              => SYSDATE             ,
                        i_total_units                => 0                   ,
                        i_action_text                => 'REDSWEEPALL'        ,
                        i_reason                     => 'Redemption'        ,
                        i_result                     => 'Completed'         ,
                        i_sub_sourcesystem           => cst.bus_org_id      ,
                        i_iccid                      => cst.iccid           ,
                        i_ota_req_type               => NULL                ,
                        i_ota_type                   => NULL                ,
                        i_call_trans2x_ota_code_hist => NULL                ,
                        i_new_due_date               => cst.expiration_date );
  -- save
  ct := ct.save;

  IF ct.response NOT LIKE '%SUCCESS%' THEN
    o_err_num         := '7';
    o_err_string      := 'UNABLE TO CREATE CALL TRANS: '|| ct.response;
    RETURN;
  END IF;

  o_call_trans_objid  := ct.call_trans_objid;

  pi := part_inst_type ( i_esn => sa.customer_info.convert_pin_to_smp ( i_red_card_code => i_ild_pin ) );

  -- create red card
  SELECT sa.seq('x_red_card') INTO l_rc_objid FROM dual;

  BEGIN
    INSERT
    INTO table_x_red_card
      (
        objid,
        red_card2call_trans,
        red_smp2inv_smp,
        red_smp2x_pi_hist,
        x_access_days,
        x_red_code,
        x_red_date,
        x_red_units,
        x_smp,
        x_status,
        x_result,
        x_created_by2user,
        x_inv_insert_date,
        x_last_ship_date,
        x_order_number,
        x_po_num,
        x_red_card2inv_bin,
        x_red_card2part_mod
      )
      VALUES
      (
        l_rc_objid,
        ct.call_trans_objid,
        NULL,
        NULL,
        0,
        pi.red_code,
        sysdate,
        0,
        pi.part_serial_no,
        NULL,
        'Completed',
        268435556, --'SA' user
        SYSDATE,
        SYSDATE,
        NULL,
        NULL,
        pi.part_inst2inv_bin,
        pi.n_part_inst2part_mod
      );
   EXCEPTION
  WHEN OTHERS
  THEN
    o_err_num         := '8';
    o_err_string      := 'ERROR CREATING RED CARD: '|| SQLERRM;
    RETURN;
  END;

  --Delete from table part inst after insert in table_x_red_card
  IF sql%rowcount > 0 THEN
    DELETE
    FROM sa.table_part_inst
    WHERE part_serial_no = pi.part_serial_no
    AND x_domain         = 'REDEMPTION CARDS';
  END IF;

  --call insert table_x_ild_insert
  ILD_TRANSACTION_PKG.INSERT_TABLE_X_ILD_TRANS(
    IP_DEV                          => NULL                ,
    IP_X_MIN                        => cst.min             ,
    IP_X_ESN                        => cst.esn             ,
    IP_X_TRANSACT_DATE              => SYSDATE             ,
    IP_X_ILD_TRANS_TYPE             => 'CRU'               ,
    IP_X_ILD_STATUS                 => 'PENDING'           ,
    IP_X_LAST_UPDATE                => SYSDATE             ,
    IP_X_ILD_ACCOUNT                => '1'                 ,
    IP_ILD_TRANS2SITE_PART          => cst.site_part_objid ,
    IP_ILD_TRANS2USER               => NULL                ,
    IP_X_CONV_RATE                  => '1'                 ,
    IP_X_TARGET_SYSTEM              => NULL                ,
    IP_X_PRODUCT_ID                 => l_vas_product_id    ,
    IP_X_API_STATUS                 => NULL                ,
    IP_X_API_MESSAGE                => NULL                ,
    IP_X_ILD_TRANS2IG_TRANS_ID      => NULL                ,
    IP_X_ILD_TRANS2CALL_TRANS       => ct.call_trans_objid ,
    OP_OBJID                        => l_ild_objid         ,
    OP_ERR_NUM                      => o_err_num           ,
    OP_ERR_STRING                   => o_err_string
  );


  IF NVL(i_Enroll_low_balance, 'N') = 'Y' THEN
    l_vas_product_id               := 'BP'|| l_vas_product_id ;
    --call insert table_x_ild_insert for BP enrolment
    ILD_TRANSACTION_PKG.INSERT_TABLE_X_ILD_TRANS(
      IP_DEV                          => NULL                ,
      IP_X_MIN                        => cst.min             ,
      IP_X_ESN                        => cst.esn             ,
      IP_X_TRANSACT_DATE              => SYSDATE             ,
      IP_X_ILD_TRANS_TYPE             => 'CRU'               ,
      IP_X_ILD_STATUS                 => 'PENDING'           ,
      IP_X_LAST_UPDATE                => SYSDATE             ,
      IP_X_ILD_ACCOUNT                => '1'                 ,
      IP_ILD_TRANS2SITE_PART          => cst.site_part_objid ,
      IP_ILD_TRANS2USER               => NULL                ,
      IP_X_CONV_RATE                  => '1'                 ,
      IP_X_TARGET_SYSTEM              => NULL                ,
      IP_X_PRODUCT_ID                 => l_vas_product_id    ,
      IP_X_API_STATUS                 => NULL                ,
      IP_X_API_MESSAGE                => NULL                ,
      IP_X_ILD_TRANS2IG_TRANS_ID      => NULL                ,
      IP_X_ILD_TRANS2CALL_TRANS       => ct.call_trans_objid ,
      OP_OBJID                        => l_ild_objid         ,
      OP_ERR_NUM                      => o_err_num           ,
      OP_ERR_STRING                   => o_err_string
    );
  END IF;


EXCEPTION
WHEN OTHERS THEN
  o_err_num    := SQLCODE;
  o_err_string := 'Error Provision : ' || SUBSTR(SQLERRM,1,500);
END provision_10_ild;
--CR48260 SM MLD new procedure ends here

END ILD_TRANSACTION_PKG;
/