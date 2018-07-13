CREATE OR REPLACE PACKAGE BODY sa."CARRIER_IS_SWB_RATE_PLAN"
AS
  -- Private Package Variables
  --
  -- Public Stored Procedures
  --
  --*******************************************************************************************************************
  -- Procedure will retrieve the LAST rate plan SENT to the carrier and if the Carrier is Switch Base Or Not for an ESN
  --*******************************************************************************************************************
  --
PROCEDURE sp_swb_carr_rate_plan( ip_esn                 IN  VARCHAR2,
                                 op_last_rate_plan_sent OUT table_x_carrier_features.x_rate_plan%TYPE,
                                 op_is_swb_carr         OUT VARCHAR2,
                                 op_error_code          OUT INTEGER,
                                 op_error_message       OUT VARCHAR2 )
AS
  --- VARIABLES DECLARATION ---
  l_action        VARCHAR2(1000) := '';
  l_error_code    INTEGER        := 0;
  l_error_message VARCHAR2(100)  := '';
  l_exception     EXCEPTION;

BEGIN
  IF ip_esn IS NULL
  THEN
    l_error_code    := -20002;
    l_error_message := 'Input ESN is NULL';
    RAISE l_exception;
  END IF;
  sp_swb_carr_rate_plan( ip_esn             => ip_esn,
                         ip_service_plan_id => NULL,
                         op_rate_plan       => op_last_rate_plan_sent,
                         op_is_swb_carr     => op_is_swb_carr,
                         op_error_code      => op_error_code,
                         op_error_message   => op_error_message);
EXCEPTION WHEN l_exception
THEN
  op_last_rate_plan_sent := NULL;
  op_is_swb_carr         := NULL;
  op_error_code          := l_error_code;
  op_error_message       := l_error_message;
  -- write to error_table
  ota_util_pkg.err_log( p_action       => l_action,
                        p_error_date   => SYSDATE,
                        p_key          => ip_esn,
                        p_program_name => 'CARRIER_IS_SWB_RATE_PLAN.SP_SWB_CARR_RATE_PLAN',
                        p_error_text   => op_error_message );
END sp_swb_carr_rate_plan;
--
PROCEDURE sp_swb_carr_rate_plan( ip_esn             IN  VARCHAR2 ,
                                 ip_service_plan_id IN  NUMBER DEFAULT NULL ,
                                 op_rate_plan       OUT table_x_carrier_features.x_rate_plan%TYPE ,
                                 op_is_swb_carr     OUT VARCHAR2 ,
                                 op_error_code      OUT INTEGER ,
                                 op_error_message   OUT VARCHAR2 )
AS
  --
  -----------------------
  -- IP_SERVICE_PLAN_ID is added as a new input because the site part extension (X_SERVICE_PLAN_SITE_PART)
  -- is not created by that time, hence java will pass it as a input
  -- eventually later stages the site part extension will be created in Java
  -----------------------
  --- CURSORS Start ---
  CURSOR last_rp_from_task_curs ( c_esn IN table_part_inst.part_serial_no%TYPE)
  IS
    SELECT tab1.task_objid,
      tab1.action_item_task_id,
      tab1.x_rate_plan,
      tab1.x_call_trans2carrier,
      tab1.call_trans2site_part
    FROM
      (SELECT tt.objid task_objid,
        tt.task_id action_item_task_id,
        tt.x_rate_plan,
        ct.x_call_trans2carrier,
        ct.call_trans2site_part
      FROM table_x_call_trans ct,
        table_task tt
      WHERE 1                    =1
      AND ct.x_action_type      IN ('1','3','6')
      AND ct.x_service_id        = c_esn
      AND tt.x_task2x_call_trans = ct.objid
      ORDER BY tt.start_date DESC
      ) tab1
  WHERE ROWNUM < 2;
  last_rp_from_task_rec last_rp_from_task_curs%rowtype;
  ---------
  CURSOR get_last_rp_ig_tx_curs (c_action_item_task_id IN table_task.task_id%TYPE)
  IS
    SELECT last_ig_tx.*
    FROM
      (SELECT 'IG',
        ig.*
      FROM gw1.ig_transaction ig
      WHERE 1               =1
      AND ig.action_item_id = c_action_item_task_id
    UNION
    SELECT 'HIST',
      hist.*
    FROM gw1.ig_transaction_history hist
    WHERE 1                 =1
    AND hist.action_item_id = c_action_item_task_id
      )last_ig_tx;
    get_last_rp_ig_tx_rec get_last_rp_ig_tx_curs%rowtype;
    ---------
    CURSOR get_esn_details_curs(c_esn IN table_part_inst.part_serial_no%TYPE)
    IS
      SELECT pi.part_serial_no,
        NVL(pn.x_data_capable,0),
        NVL(
        (SELECT to_number(v.x_param_value)
        FROM table_x_part_class_values v,
          table_x_part_class_params n
        WHERE 1                 =1
        AND v.value2part_class  = pn.part_num2part_class
        AND v.value2class_param = n.objid
        AND n.x_param_name      = 'DATA_SPEED'
        AND rownum              <2
        ),NVL(x_data_capable,0)) data_speed,
        (SELECT to_number(v.x_param_value)
            FROM table_x_part_class_values v,
                table_x_part_class_params n
           WHERE 1                 =1
             AND v.value2part_class  = pn.part_num2part_class
             AND v.value2class_param = n.objid
             AND n.x_param_name      = 'NON_PPE'
             AND rownum              <2) PPE_FLAG, --CR38927 SL UPGRADE
        pn.x_technology,
        bo.org_id,
        pn.part_num2bus_org bus_org_objid,
        pi.x_part_inst2site_part,
        bo.org_flow -- CR20451 | CR20854: Add TELCEL Brand
      FROM table_part_num pn,
        table_part_inst pi,
        table_mod_level ml,
        table_bus_org bo,
        table_site_part sp
      WHERE 1                      =1
      AND pi.n_part_inst2part_mod  = ml.objid
      AND ml.part_info2part_num    = pn.objid
      AND pi.part_serial_no        = c_esn
      AND pn.part_num2bus_org      = bo.objid
      AND pi.x_part_inst2site_part = sp.objid;
      get_esn_details_rec get_esn_details_curs%rowtype;
      ------------------
      CURSOR carrier_features_curs1 ( c_objid IN NUMBER ,c_tech IN VARCHAR2 ,c_bus_org_objid IN NUMBER ,c_data_speed IN NUMBER )
      IS
        SELECT cf.*,
          1 col1
        FROM table_x_carrier_features cf
        WHERE x_feature2x_carrier = c_objid
        AND cf.x_technology       = c_tech
        AND cf.x_features2bus_org = c_bus_org_objid
        AND cf.x_data             = c_data_speed;
      ------------------
      CURSOR carrier_features_curs2 ( c_objid IN NUMBER ,c_tech IN VARCHAR2 ,c_bus_org_objid IN NUMBER ,c_data_speed IN NUMBER )
      IS
        SELECT cf.*,
          2 col1
        FROM table_x_carrier_features cf
        WHERE EXISTS
          (SELECT 1
          FROM table_x_carrier c,
            table_x_carrier_group cg,
            table_x_carrier_group cg2,
            table_x_carrier c2
          WHERE c.objid                    = c_objid
          AND cg.objid                     = c.carrier2carrier_group
          AND cg2.X_CARRIER_GROUP2X_PARENT = cg.X_CARRIER_GROUP2X_PARENT
          AND c2.carrier2carrier_group     = cg2.objid
          AND c2.objid                     = cf.X_FEATURE2X_CARRIER
          )
      AND cf.x_technology       = c_tech
      AND cf.X_FEATURES2BUS_ORG =
        (SELECT bo.objid
        FROM table_bus_org bo
        WHERE bo.org_id = 'NET10'
        AND bo.objid    = c_bus_org_objid
        )
      AND cf.x_data = c_data_speed;
      ------------------
      CURSOR feat_for_last_rp_cur ( last_rate_plan IN VARCHAR2)
      IS
        SELECT cf.*,
          4 col1
        FROM sa.TABLE_X_CARRIER_FEATURES CF
        WHERE CF.X_RATE_PLAN       = last_rate_plan
        AND CF.X_FEATURE2X_CARRIER = last_rp_from_task_rec.x_call_trans2carrier
        AND CF.X_TECHNOLOGY        = get_esn_details_rec.X_TECHNOLOGY
        AND CF.X_FEATURES2BUS_ORG  = get_esn_details_rec.bus_org_objid
        AND ROWNUM                 < 2;
      ------------------
      carr_feature_rec1 carrier_features_curs1%ROWTYPE;
      ------------------
      CURSOR final_carr_features_curs (c_objid IN table_x_carrier_features.objid%TYPE)
      IS
        SELECT * FROM table_x_carrier_features WHERE objid = c_objid;
      final_carr_features_rec final_carr_features_curs%rowtype;
      ---------------------------
      CURSOR line_carrier_curs (c_esn IN table_part_inst.part_serial_no%TYPE)
      IS
        SELECT pimin.part_inst2carrier_mkt carrier_objid,
          pimin.part_serial_no line
        FROM table_part_inst piesn,
          table_part_inst pimin,
          table_site_part sp --CR20492
        WHERE 1                         =1
        AND pimin.part_to_esn2part_inst = piesn.objid
        AND pimin.part_serial_no        = sp.x_min     --CR20492
        AND sp.part_status NOT         IN ('Inactive') --CR20492
        AND pimin.x_domain              = 'LINES'
        AND piesn.part_serial_no        = c_esn
          -- AND pimin.x_part_inst_status
        AND piesn.x_domain = 'PHONES';
      line_carrier_rec line_carrier_curs%rowtype;
      ---------------------------
      CURSOR get_parent_curs (c_objid IN table_x_carrier.objid%TYPE)
      IS
        SELECT p.*
        FROM TABLE_X_PARENT p,
          TABLE_X_CARRIER_GROUP g,
          TABLE_X_CARRIER c
        WHERE p.objid = g.x_carrier_group2x_parent
        AND g.objid   = c.carrier2carrier_group
        AND c.objid   = c_objid ;
      get_parent_rec get_parent_curs%rowtype;
      ---------------------------
      CURSOR get_template_curs (c_objid IN table_x_order_type.objid%TYPE)
      IS
        SELECT prof.*
        FROM table_x_order_type ot,
          table_x_trans_profile prof
        WHERE ot.x_order_type2x_trans_profile = prof.objid
        AND ot.objid                          = c_objid;
      GET_TEMPLATE_REC GET_TEMPLATE_CURS%ROWTYPE;
      ---------------------------
      --- VARIABLES DECLARATION ---
      l_carr_feat_objid table_x_carrier_features.objid%TYPE:=0;
      l_n_data table_x_carrier_features.x_data%TYPE;
      l_final_carr_feat_objid table_x_carrier_features.objid%TYPE:=0;
      l_st_esn_flag      NUMBER                                       :=0;
      l_exception        EXCEPTION;
      l_error_code       INTEGER        :=0;
      l_error_message    VARCHAR2(100)  := '';
      l_action           VARCHAR2(1000) := '';
      l_order_type_objid NUMBER;
      l_order_type table_x_order_type.x_order_type%TYPE;
      l_ig_order_type gw1.ig_transaction.order_type%TYPE;
      l_new_template gw1.ig_transaction.TEMPLATE%TYPE:= '-1';
      ---------------------------
    BEGIN
      -- Reinitialize global variable
      g_carrier_feature_objid :=  NULL; -- CRC87016
      --
      IF ip_esn         IS NULL THEN
        l_error_code    := -20002;
        l_error_message := 'Input ESN is NULL';
        RAISE l_exception;
      END IF;
      IF IP_SERVICE_PLAN_ID IS NULL THEN
        OPEN last_rp_from_task_curs(ip_esn);
        FETCH last_rp_from_task_curs INTO last_rp_from_task_rec;
        IF LAST_RP_FROM_TASK_CURS%NOTFOUND THEN
          l_action        := ' Executing LAST_RP_FROM_TASK_CURS Cursor in SP_IS_SWB_CARR_LAST_RATE_PLAN Procedure ';
          l_error_code    := -20003;
          l_error_message := 'TABLE_CALL_TRANS and TABLE_TASK Not Found for the input ESN - '||ip_esn;
          RAISE l_exception;
        END IF;
        OPEN get_last_rp_IG_TX_curs(last_rp_from_task_rec.action_item_task_id);
        FETCH get_last_rp_IG_TX_curs INTO get_last_rp_IG_TX_rec;
        IF GET_LAST_RP_IG_TX_CURS%NOTFOUND THEN
          l_action        := ' Executing GET_LAST_RP_IG_TX_CURS Cursor in SP_IS_SWB_CARR_LAST_RATE_PLAN Procedure ';
          l_error_code    := -20004;
          l_error_message := ' No IG_TRANSACTION and IG_TRANSCTION_HISTORY Not Found for the input ESN - '||ip_esn;
          RAISE l_exception;
        END IF;
        BEGIN
          op_rate_plan := get_last_rp_ig_tx_rec.rate_plan;
          -- DBMS_OUTPUT.PUT_LINE ('op_rate_plan - ' || op_rate_plan);
        END;
        IF LAST_RP_FROM_TASK_CURS%ISOPEN THEN
          CLOSE LAST_RP_FROM_TASK_CURS;
        ELSIF GET_LAST_RP_IG_TX_CURS%ISOPEN THEN
          CLOSE GET_LAST_RP_IG_TX_CURS;
        END IF;
        OPEN get_esn_details_curs(ip_esn);
        FETCH get_esn_details_curs INTO get_esn_details_rec;
        IF GET_ESN_DETAILS_CURS%NOTFOUND THEN
          l_action        := ' Executing GET_ESN_DETAILS_CURS Cursor in SP_IS_SWB_CARR_LAST_RATE_PLAN Procedure ';
          l_error_code    := -20005;
          L_ERROR_MESSAGE := ' TABLE_PART_INST data Not Found for the input ESN - '||IP_ESN;
          RAISE l_exception;
        END IF;
        CLOSE get_esn_details_curs;
        IF get_esn_details_rec.org_flow = '3' THEN
          l_st_esn_flag                := 1;
        ELSE
          l_st_esn_flag := 0;
        END IF;
        OPEN carrier_features_curs1(last_rp_from_task_rec.x_call_trans2carrier, get_esn_details_rec.x_technology, get_esn_details_rec.bus_org_objid, get_esn_details_rec.data_speed);
        FETCH carrier_features_curs1 INTO carr_feature_rec1;
        IF carrier_features_curs1%NOTFOUND THEN
          carr_feature_rec1.objid := NULL;
		  --CODE Changes for CR55230
          --L_ACTION                := 'carrier_features_curs1(' || last_rp_from_task_rec.x_call_trans2carrier ||',' || get_esn_details_rec.x_technology ||',' || get_esn_details_rec.bus_org_objid ||',' || get_esn_details_rec.data_speed ||')';
          -- write to error_table
          --OTA_UTIL_PKG.ERR_LOG(P_ACTION => L_ACTION, P_ERROR_DATE => SYSDATE, P_KEY => IP_ESN, P_PROGRAM_NAME => 'SP_SWB_CARR_RATE_PLAN', P_ERROR_TEXT => 'carrier_features_curs1%NOTFOUND' );
		  --CODE Changes for CR55230
        END IF;
        CLOSE carrier_features_curs1;
        --
        IF carr_feature_rec1.objid IS NULL AND get_esn_details_rec.org_id = 'NET10' THEN
          OPEN carrier_features_curs2(last_rp_from_task_rec.x_call_trans2carrier ,get_esn_details_rec.x_technology ,get_esn_details_rec.bus_org_objid ,get_esn_details_rec.data_speed);
          FETCH carrier_features_curs2 INTO carr_feature_rec1;
          IF carrier_features_curs2%NOTFOUND THEN
            carr_feature_rec1.objid := NULL;
			--CODE Changes for CR55230
            --L_ACTION                := 'carrier_features_curs2(' || last_rp_from_task_rec.x_call_trans2carrier ||',' || get_esn_details_rec.x_technology ||',' || get_esn_details_rec.bus_org_objid ||',' || get_esn_details_rec.data_speed ||')';
            -- write to error_table
            --OTA_UTIL_PKG.ERR_LOG(P_ACTION => L_ACTION, P_ERROR_DATE => SYSDATE, P_KEY => IP_ESN, P_PROGRAM_NAME => 'SP_SWB_CARR_RATE_PLAN', P_ERROR_TEXT => 'carrier_features_curs2%NOTFOUND' );
			--CODE Changes for CR55230
          END IF;
          CLOSE carrier_features_curs2;
        END IF;
        --
        IF carr_feature_rec1.objid IS NULL THEN
          L_ACTION                 := 'default carr_feature_rec1.objid is null - before calling igate.sf_get_carrier_feat';
          -- write to error_table
          OTA_UTIL_PKG.ERR_LOG(P_ACTION => L_ACTION, P_ERROR_DATE => SYSDATE, P_KEY => IP_ESN, P_PROGRAM_NAME => 'SP_SWB_CARR_RATE_PLAN', P_ERROR_TEXT => 'carr_feature_rec1.objid is null');
          --
          OPEN feat_for_last_rp_cur (get_last_rp_ig_tx_rec.rate_plan);
          FETCH feat_for_last_rp_cur INTO carr_feature_rec1;
          CLOSE feat_for_last_rp_cur;
        END IF;
        L_ACTION := ' Start Calling SA.IGATE.SF_GET_CARR_FEAT Procedure ';
        --- DBMS_OUTPUT.PUT_LINE ('L_ACTION - ' || L_ACTION);
        --    l_carr_feat_objid := SA.IGATE.SF_GET_CARR_FEAT(get_last_rp_ig_tx_rec.order_type, L_ST_ESN_FLAG, last_rp_from_task_rec.call_trans2site_part, ip_esn, LAST_RP_FROM_TASK_REC.X_CALL_TRANS2CARRIER, carr_feature_rec1.objid, l_n_data, NVL(get_last_rp_ig_tx_rec.template,'NOT SUREPAY'), NULL -- P_SERVICE_PLAN_ID
        --    );
        l_carr_feat_objid := sa.IGATE.SF_GET_CARR_FEAT(get_last_rp_ig_tx_rec.order_type, L_ST_ESN_FLAG, last_rp_from_task_rec.call_trans2site_part, ip_esn, LAST_RP_FROM_TASK_REC.X_CALL_TRANS2CARRIER, carr_feature_rec1.objid, get_esn_details_rec.data_speed, NVL(get_last_rp_ig_tx_rec.template,'NOT SUREPAY'), NULL -- P_SERVICE_PLAN_ID
        );
        L_ACTION := ' Finish Executing SA.IGATE.SF_GET_CARR_FEAT Procedure ';
        --- DBMS_OUTPUT.PUT_LINE ('L_ACTION - ' || L_ACTION);
        L_ACTION := ' Start gettting the l_final_carr_feat_objid ';
        --- DBMS_OUTPUT.PUT_LINE ('L_ACTION - ' || L_ACTION);
        IF NVL(l_carr_feat_objid,0) = 0 THEN
          -- write to error_table
          OTA_UTIL_PKG.ERR_LOG(P_ACTION => L_ACTION, P_ERROR_DATE => SYSDATE, P_KEY => IP_ESN, P_PROGRAM_NAME => 'SP_SWB_CARR_RATE_PLAN', P_ERROR_TEXT => 'carr_feature returned null from igate.sf_get_carrier_feat');
          l_final_carr_feat_objid := carr_feature_rec1.objid;
          g_carrier_feature_objid := carr_feature_rec1.objid;  -- CRC87016
        ELSE
          l_final_carr_feat_objid := l_carr_feat_objid;
          g_carrier_feature_objid := l_carr_feat_objid;  -- CRC87016
        END IF;
        L_ACTION := ' Finish gettting the l_final_carr_feat_objid ';
        --- DBMS_OUTPUT.PUT_LINE ('L_ACTION - ' || L_ACTION);
        OPEN final_carr_features_curs( l_final_carr_feat_objid);
        FETCH final_carr_features_curs INTO final_carr_features_rec;
        CLOSE final_carr_features_curs;
        -- DBMS_OUTPUT.PUT_LINE ('l_final_carr_feat_objid - ' || l_final_carr_feat_objid);

         OPEN get_parent_curs(carr_feature_rec1.x_feature2x_carrier);
         FETCH get_parent_curs INTO get_parent_rec;
         CLOSE get_parent_curs;

          IF final_carr_features_rec.x_is_swb_carrier            = 1 THEN

          --op_is_swb_carr      := 'Switch Base' ;

         --Added by phaneendra on 5/18/2015 for ATT Carrier Switch Upgrades to Display   STBYOT ,TMO AS Non-Switch Base.

            IF (get_parent_rec.x_parent_name like 'T-MOB%' and get_esn_details_rec.org_id='STRAIGHT_TALK')
               THEN
                op_is_swb_carr    := 'Non-Switch Base' ;
			ELSIF 	 get_esn_details_rec.org_id='TRACFONE' AND get_esn_details_rec.PPE_FLAG =0
				THEN op_is_swb_carr := 'Non-Switch Base';
                ELSE
                op_is_swb_carr      := 'Switch Base' ;
            END IF;

         ELSIF NVL(final_carr_features_rec.x_is_swb_carrier, 0) = 0 THEN
          op_is_swb_carr                                      := 'Non-Switch Base';
        END IF;
      ELSE -- P_SERVICE_PLAN_ID IS NOT NULL  -- FOR sp_is_swb_carr_best_rate_plan
        OPEN get_esn_details_curs(ip_esn);
        FETCH get_esn_details_curs INTO get_esn_details_rec;
        IF GET_ESN_DETAILS_CURS%NOTFOUND THEN
          l_action        := ' Executing GET_ESN_DETAILS_CURS Cursor in SP_IS_SWB_CARR_LAST_RATE_PLAN Procedure ';
          l_error_code    := -20005;
          L_ERROR_MESSAGE := ' TABLE_PART_INST data Not Found for the input ESN - '||IP_ESN;
          RAISE l_exception;
        END IF;
        CLOSE get_esn_details_curs;
        --CR20451 | CR20854: Add TELCEL Brand -- changed from brand to flow to allow TELCEL to follow Straight talk logic
        --IF get_esn_details_rec.org_id = 'STRAIGHT_TALK' THEN
        IF get_esn_details_rec.org_flow = '3' THEN
          l_st_esn_flag                := 1;
        ELSE
          l_st_esn_flag := 0;
        END IF;
        OPEN line_carrier_curs(ip_esn);
        FETCH line_carrier_curs INTO line_carrier_rec;
        -----------------------
        -- LINE INFO NOT FOUND  OR CARRIER NOT FOUND THEN RETURN - SKuthadi
        -- Since this function is supposed to be called before Table_Task, IG_TX or TABLE_X_CALL_TRANS population
        -- The carrier info is taken from LINE
        -----------------------
        IF line_carrier_curs%NOTFOUND OR line_carrier_rec.carrier_objid IS NULL THEN
          l_action                                                      := ' Executing LINE_CARRIER_CURS Cursor in SP_IS_SWB_CARR_LAST_RATE_PLAN Procedure ';
          L_ERROR_CODE                                                  := -20006;
          L_ERROR_MESSAGE                                               := ' Line/Carrier Info Not Found for the input ESN - '||IP_ESN;
          RAISE l_exception;
        END IF;
        CLOSE LINE_CARRIER_CURS;
        --- get carrier, parent
        -----------------------
        -- The order type need to be determined in here and not before calling the procedure(say with input order type)
        -- In the Java process not sure what the order type going to be at the time of calling this procedure
        -- Later stage the below similiar logic is used in Java to determine the order type and call create action item
        -- Always used for Activation -- hence determining Activation on Activation Payment
        -- For Others say redemption or re-act the service plan id is sent as NULL as we already have IG_TX,TASK and CALL_TRANS
        -----------------------
        OPEN get_parent_curs(line_carrier_rec.carrier_objid);
        FETCH get_parent_curs INTO get_parent_rec;
        CLOSE get_parent_curs;
        IF get_parent_rec.x_parent_name    = 'SPRINT' AND get_parent_rec.x_parent_id = '99' THEN
          l_order_type                    := 'Activation';
          l_ig_order_type                 := 'A';
        ELSIF get_parent_rec.x_parent_name = 'VERIZON PREPAY PLATFORM' AND get_parent_rec.x_parent_id = '66' THEN
          l_order_type                    := 'Activation Payment';
          l_ig_order_type                 := 'AP';
        ELSE
          l_order_type    := 'Activation';
          l_ig_order_type := 'A';
        END IF;
        -- get the order type based on the carrier and then template
        sa.IGATE.SP_GET_ORDERTYPE(LINE_CARRIER_REC.LINE, L_ORDER_TYPE, -- 'Activation Payment' OR 'Activation'
        line_carrier_rec.carrier_objid, GET_ESN_DETAILS_REC.X_TECHNOLOGY, l_order_type_objid );
        -- get the template
        OPEN get_template_curs(l_order_type_objid);
        FETCH get_template_curs INTO get_template_rec;
        CLOSE get_template_curs;
        IF get_esn_details_rec.x_technology IN ('CDMA', 'TDMA') THEN
          l_new_template := get_template_rec.x_d_trans_template;
        ELSIF get_esn_details_rec.x_technology IN ('GSM') THEN
          l_new_template := get_template_rec.x_gsm_trans_template;
        ELSE
          l_new_template := get_template_rec.x_transmit_template;
        END IF;
        OPEN carrier_features_curs1(line_carrier_rec.carrier_objid, get_esn_details_rec.x_technology, get_esn_details_rec.bus_org_objid, get_esn_details_rec.data_speed);
        FETCH carrier_features_curs1 INTO carr_feature_rec1;
        IF carrier_features_curs1%NOTFOUND THEN
          carr_feature_rec1.objid := NULL;
		  --CODE Changes for CR55230
          --L_ACTION                := 'carrier_features_curs1(' || last_rp_from_task_rec.x_call_trans2carrier ||',' || get_esn_details_rec.x_technology ||',' || get_esn_details_rec.bus_org_objid ||',' || get_esn_details_rec.data_speed ||')';
          -- write to error_table
          --OTA_UTIL_PKG.ERR_LOG(P_ACTION => L_ACTION, P_ERROR_DATE => SYSDATE, P_KEY => IP_ESN, P_PROGRAM_NAME => 'SP_SWB_CARR_RATE_PLAN', P_ERROR_TEXT => 'carrier_features_curs1%NOTFOUND' );
		  --CODE Changes for CR55230
        END IF;
        CLOSE carrier_features_curs1;
        --
        IF carr_feature_rec1.objid IS NULL AND get_esn_details_rec.org_id = 'NET10' THEN
          OPEN carrier_features_curs2(line_carrier_rec.carrier_objid ,get_esn_details_rec.x_technology ,get_esn_details_rec.bus_org_objid ,get_esn_details_rec.data_speed);
          FETCH carrier_features_curs2 INTO carr_feature_rec1;
          IF carrier_features_curs2%NOTFOUND THEN
            carr_feature_rec1.objid := NULL;
			--CODE Changes for CR55230
            --L_ACTION                := 'carrier_features_curs2(' || last_rp_from_task_rec.x_call_trans2carrier ||',' || get_esn_details_rec.x_technology ||',' || get_esn_details_rec.bus_org_objid ||',' || get_esn_details_rec.data_speed ||')';
            -- write to error_table
            --OTA_UTIL_PKG.ERR_LOG(P_ACTION => L_ACTION, P_ERROR_DATE => SYSDATE, P_KEY => IP_ESN, P_PROGRAM_NAME => 'SP_SWB_CARR_RATE_PLAN', P_ERROR_TEXT => 'carrier_features_curs2%NOTFOUND' );
			--CODE Changes for CR55230
          END IF;
          CLOSE carrier_features_curs2;
        END IF;
        --
        IF carr_feature_rec1.objid IS NULL THEN
          L_ACTION                 := 'default carr_feature_rec1.objid is null - before calling igate.sf_get_carrier_feat';
          -- write to error_table
          OTA_UTIL_PKG.ERR_LOG(P_ACTION => L_ACTION, P_ERROR_DATE => SYSDATE, P_KEY => IP_ESN, P_PROGRAM_NAME => 'SP_SWB_CARR_RATE_PLAN', P_ERROR_TEXT => 'carr_feature_rec1.objid is null');
          --
          OPEN feat_for_last_rp_cur (get_last_rp_ig_tx_rec.rate_plan);
          FETCH feat_for_last_rp_cur INTO carr_feature_rec1;
          CLOSE feat_for_last_rp_cur;
        END IF;
        L_ACTION          := ' Start Calling SA.IGATE.SF_GET_CARR_FEAT Procedure ';
        l_carr_feat_objid := sa.IGATE.SF_GET_CARR_FEAT( l_ig_order_type,                                                                                                                                                        -- 'A' OR 'AP'
        l_st_esn_flag, get_esn_details_rec.x_part_inst2site_part, ip_esn, NVL(line_carrier_rec.carrier_objid,0), carr_feature_rec1.objid, get_esn_details_rec.data_speed, NVL(l_new_template,'NOT SUREPAY'), ip_service_plan_id -- P_SERVICE_PLAN_ID
        );
        IF NVL(l_carr_feat_objid,0) = 0 THEN
          l_final_carr_feat_objid  := carr_feature_rec1.objid;
          g_carrier_feature_objid := carr_feature_rec1.objid; -- CRC87016
        ELSE
          l_final_carr_feat_objid := l_carr_feat_objid;
          g_carrier_feature_objid := l_carr_feat_objid; -- CRC87016
        END IF;
        OPEN final_carr_features_curs( l_final_carr_feat_objid);
        FETCH final_carr_features_curs INTO final_carr_features_rec;
        CLOSE final_carr_features_curs;
        IF final_carr_features_rec.x_is_swb_carrier = 1 THEN
          --
          op_rate_plan   := final_carr_features_rec.x_rate_plan;
          op_is_swb_carr := 'Switch Base' ;
          --
        ELSIF NVL(final_carr_features_rec.x_is_swb_carrier, 0) = 0 THEN
          --
          op_rate_plan   := final_carr_features_rec.x_rate_plan;
          op_is_swb_carr := 'Non-Switch Base';
          --
        END IF;
      END IF;
      -- DBMS_OUTPUT.PUT_LINE ('op_rate_plan - ' || op_rate_plan);
      -- DBMS_OUTPUT.PUT_LINE ('op_is_swb_carr - ' || OP_IS_SWB_CARR);
      op_error_code    := 0;
      op_error_message := 'Success';
    EXCEPTION WHEN l_exception
    THEN
      op_rate_plan     := NULL;
      op_is_swb_carr   := NULL;
      op_error_code    := l_error_code;
      op_error_message := l_error_message;
      -- CR52315 - do not write l_exceptions to error_table
      DBMS_OUTPUT.PUT_LINE(op_error_code || '  ' || op_error_message);
      --ota_util_pkg.err_log(p_action => L_ACTION, p_error_date => SYSDATE, p_key => ip_esn, p_program_name => 'SP_IS_SWB_CARR_LAST_RATE_PLAN', p_error_text => op_error_message );
      -- CR52315
      IF last_rp_from_task_curs%ISOPEN
      THEN--{
        CLOSE last_rp_from_task_curs;
      ELSIF get_last_rp_ig_tx_curs%ISOPEN
      THEN
        CLOSE get_last_rp_ig_tx_curs;
      ELSIF get_esn_details_curs%ISOPEN
      THEN
        CLOSE get_esn_details_curs;
      ELSIF final_carr_features_curs%ISOPEN
      THEN
        CLOSE final_carr_features_curs;
      ELSIF line_carrier_curs%ISOPEN
      THEN
        CLOSE line_carrier_curs;
      END IF;--}
    WHEN OTHERS
    THEN
      op_rate_plan     := NULL;
      op_is_swb_carr   := NULL;
      op_error_code    := SQLCODE;
      op_error_message := SQLERRM;
      -- write to error_table
      OTA_UTIL_PKG.ERR_LOG(P_ACTION => L_ACTION, P_ERROR_DATE => SYSDATE, P_KEY => IP_ESN, P_PROGRAM_NAME => 'SP_IS_SWB_CARR_LAST_RATE_PLAN', P_ERROR_TEXT => OP_ERROR_MESSAGE );
      IF last_rp_from_task_curs%ISOPEN
      THEN--{
        CLOSE last_rp_from_task_curs;
      ELSIF get_last_rp_ig_tx_curs%ISOPEN
      THEN
        CLOSE get_last_rp_ig_tx_curs;
      ELSIF get_esn_details_curs%ISOPEN
      THEN
        CLOSE get_esn_details_curs;
      ELSIF final_carr_features_curs%ISOPEN
      THEN
        CLOSE final_carr_features_curs;
      ELSIF line_carrier_curs%ISOPEN
      THEN
        CLOSE line_carrier_curs;
      END IF;--}
END sp_swb_carr_rate_plan;

--
-- CRC87016 changes starts..
-- new procedure to get carrier feature objid
PROCEDURE get_carrier_feature_id ( i_esn                IN  VARCHAR2            ,
                                   i_service_plan_id    IN  NUMBER DEFAULT NULL ,
                                   o_carrier_feature_id OUT NUMBER              ,
                                   o_response           OUT VARCHAR2            )
IS
  c_rate_plan      VARCHAR2(100);
  c_is_swb_carr    VARCHAR2(100);
  i_error_code     INTEGER;
  c_error_message  VARCHAR2(1000);

BEGIN
  g_carrier_feature_objid :=  NULL;
  -- call original procedure
  sp_swb_carr_rate_plan ( ip_esn                     => i_esn             ,
                          ip_service_plan_id         => i_service_plan_id ,
                          op_rate_plan               => c_rate_plan       ,
                          op_is_swb_carr             => c_is_swb_carr     ,
                          op_error_code              => i_error_code      ,
                          op_error_message           => c_error_message   );

  -- set the output variable
  o_carrier_feature_id := g_carrier_feature_objid;

  --
  o_response := 'SUCCESS';
 EXCEPTION
   WHEN others THEN
     o_response := 'ERROR GETTING CARRIER FEATURE ID: ' || SQLERRM;
END get_carrier_feature_id;
-- CRC87016 changes ends.
END CARRIER_IS_SWB_RATE_PLAN;
/