CREATE OR REPLACE PACKAGE BODY sa."RIM_SERVICE_PKG"
IS
  /***************************************************************************************************************
  * Package Name: RIM_SERVICE_PKG
  * Description: The package is called by  IGATE_IN3
  *              to validate and register RIM transaction.
  *
  * Created by: YM
  * Date:  11/20/2012
  *
  * History
  * -------------------------------------------------------------------------------------------------------------------------------------
  * 12/03/2012         YM                 Initial Version                                CR20403
  * 2/05/2013          YM                 1.3                                          CR23362
  * 03/04/2013         YM                 1.4                                          CR22798      BYOP GSM RIM (SIMPLE MOBILE)
  * 04/20/2013         YM                 1.5                                          CR22452      Simple mobile
  * 04/26/2013         YM                 1.6                                          CR22452      Simple mobile
  * 06/10/2013         YM                 1.7                                          CR22966      Simple mobile $60
  *******************************************************************************************************************/
  --CR22798
FUNCTION VERIFY_BB_PC_ESN(
    P_ESN IN VARCHAR2)
  RETURN VARCHAR2
IS
  /***************************************************************************************************************/
  /* function Name:VERIFY_BB_PC_ESN                                                                              */
  /* Description: This function return true if ESN has part class with operation system for  Blackberry  Device  */
  /*                            return false otherwise .                                                         */
  /***************************************************************************************************************/
  CURSOR esn_curs
  IS
    SELECT bo.org_id,
      pc.name,
      pn.*
    FROM table_part_class pc,
      table_part_num pn ,
      table_bus_org bo,
      pc_params_view pv ,
      table_part_inst pi,
      table_mod_level ml
    WHERE pn.part_num2part_class = pc.objid
    AND pv.part_class            = pc.name
    AND pi.part_serial_no        = p_esn
    AND pi.n_part_inst2part_mod  = ml.objid
    AND ml.part_info2part_num    = pn.objid
    AND pc.objid                 = pn.part_num2part_class
    AND pn.part_num2bus_org      = bo.objid
    AND PV.PARAM_NAME            = 'OPERATING_SYSTEM'
    AND pv.param_value           = 'BBOS';
  esn_rec esn_curs%rowtype;
BEGIN
  OPEN esn_curs;
  FETCH esn_curs INTO esn_rec;
  IF esn_curs%notfound THEN
    CLOSE esn_curs;
    RETURN 'FALSE';
  END IF;
  CLOSE esn_curs;
  RETURN 'TRUE';
END;
--CR22798
FUNCTION IF_BB_ESN(
    P_ESN IN VARCHAR2)
  RETURN VARCHAR2
IS
  /*********************************************************************************************************************/
  /* function Name:IF_BB_ESN                                                                                          */
  /* Description: This function return true if ESN is Blackberry  for CDMA check device for BYOP check Service plan   */
  /*                            return false otherwise .                                                              */
  /********************************************************************************************************************/
  CURSOR ESN_SP_RIM_SM_CURS
  IS
    --CR22966
    SELECT sp.mkt_name ,
      pn.x_technology ,
      spfvdef2.value_name RATE,
      sp.objid,
      spfvdef.value_name feature,
      TSP.X_SERVICE_ID ---RIM SIMPLE MOBILE
    FROM x_serviceplanfeaturevalue_def spfvdef,
      X_SERVICEPLANFEATURE_VALUE SPFV,
      X_SERVICE_PLAN_FEATURE SPF,
      X_SERVICEPLANFEATUREVALUE_DEF SPFVDEF2,
      X_SERVICE_PLAN SP,
      TABLE_SITE_PART TSP,
      TABLE_PART_INST PI,
      TABLE_MOD_LEVEL ML,
      TABLE_PART_NUM PN,
      X_SERVICE_PLAN_SITE_PART SPSP
    WHERE SPSP.X_SERVICE_PLAN_ID      = SP.OBJID
    AND TSP.X_SERVICE_ID              = P_ESN
    AND UPPER(TSP.PART_STATUS) NOT   IN 'OBSOLETE'
    AND tsp.objid                     = spsp.table_site_part_id
    AND spf.sp_feature2service_plan   = sp.objid
    AND spf.sp_feature2rest_value_def = spfvdef.objid
    AND spf.objid                     = spfv.spf_value2spf
    AND SPFVDEF2.OBJID                = SPFV.VALUE_REF
    AND SPFVDEF.VALUE_NAME            = 'RIM_RATE_PLAN'
    AND PI.PART_SERIAL_NO             = tSP.X_SERVICE_ID
    AND PI.N_PART_INST2PART_MOD       = ML.OBJID
    AND ml.part_info2part_num         = pn.objid
    AND PI.X_DOMAIN                   = 'PHONES'
    AND pn.x_technology               = 'GSM';
  esn_sp_rim_SM_rec esn_sp_rim_SM_curs%rowtype;
BEGIN
  --IF org_id = 'SIMPLE_MOBILE'  THEN  --Verify if ESN is CDMA RIM (PART CLASS RIM)
  --   RETURN 'TRUE';
  --ELS
  IF VERIFY_BB_PC_ESN(P_ESN)= 'TRUE' THEN --Verify if ESN is CDMA RIM (PART CLASS RIM)
    RETURN 'TRUE';
  ELSIF BYOP_service_pkg.VERIFY_BYOP_ESN(P_ESN)= 'TRUE' THEN --Verify if ESN is BYOP
    OPEN ESN_SP_RIM_SM_CURS;                                 --Verify is ESN BYOP GSM is in service plan RIM
    FETCH ESN_SP_RIM_SM_CURS INTO ESN_SP_RIM_SM_REC;
    IF esn_sp_rim_sm_curs%notfound THEN
      CLOSE ESN_SP_RIM_SM_CURS;
      RETURN 'FALSE'; -- if not RIM ESN
    END IF;
    CLOSE ESN_SP_RIM_SM_CURS;
    RETURN 'TRUE'; --if RIM ESN
  ELSE
    RETURN 'FALSE';
  END IF;
END;
FUNCTION SP_RIM_SIM(
    P_ACTION_ITEM_ID IN VARCHAR2)
  RETURN VARCHAR2
IS
  /*********************************************************************************************************************************************************************/
  /* function Name:SP_RIM_SIM                                                                                                                                         */
  /* Description: This function return old_esn_hes if old_ESN is 0 for ESN CDMA and if old_esn is difernet 0 return site_part.x_iccid for ESN GSM                     */
  /**********************************************************************************************************************************************************************/
  CURSOR cur_x_ICCID
  IS
    SELECT DECODE(NVL(ig.old_esn,0),0,ig.old_esn_hex,DECODE(sp.state_value,'GSM',sp.x_iccid,0)) SIM
    FROM gw1.ig_transaction ig,
      table_site_part sp
    WHERE ig.action_item_id = p_action_item_id
    AND sp.x_service_id     = ig.old_esn
    ORDER BY sp.service_end_dt DESC;
  rec_x_ICCID cur_x_ICCID%rowtype;
BEGIN
  OPEN cur_x_ICCID;
  FETCH cur_x_ICCID INTO rec_x_ICCID;
  IF cur_x_ICCID%NOTFOUND THEN
    CLOSE cur_x_ICCID;
    RETURN NULL;
  ELSE
    CLOSE cur_x_ICCID;
    RETURN rec_x_ICCID.SIM;
  END IF;
END sp_rim_SIM;
FUNCTION SP_RIM_GSM_SIM(
    P_ACTION_ITEM_ID IN VARCHAR2)
  RETURN VARCHAR2
IS
  /***************************************************************************************************************/
  /* function Name:SP_RIM_GSM_SIM                                                                                    */
  /* Description: This function return SIM 0 for ESN CDMA  and site_part.x_iccid for ESN GSM                     */
  /***************************************************************************************************************/
  CURSOR CUR_X_ICCID
  IS
    SELECT DECODE(SP.STATE_VALUE,'GSM',NVL(SP.X_ICCID,NVL(PI.X_ICCID,NULL)),NULL) SIM --CR22452 SM 041613
    FROM GW1.IG_TRANSACTION IG,
      TABLE_TASK TK,
      TABLE_X_CALL_TRANS CT,
      TABLE_SITE_PART SP,
      table_part_inst pi
    WHERE IG.ACTION_ITEM_ID    = P_ACTION_ITEM_ID
    AND TK.TASK_ID             = IG.ACTION_ITEM_ID
    AND TK.X_TASK2X_CALL_TRANS = CT.OBJID
    AND SP.OBJID               = CT.CALL_TRANS2SITE_PART
    AND SP.X_SERVICE_ID
      ||''                = IG.ESN
    AND pi.part_serial_no = IG.ESN;
  rec_x_ICCID cur_x_ICCID%rowtype;
BEGIN
  OPEN CUR_X_ICCID;
  FETCH CUR_X_ICCID INTO REC_X_ICCID;
  IF cur_x_ICCID%NOTFOUND OR rec_x_iccid.sim IS NULL THEN
    CLOSE CUR_X_ICCID;
    RETURN NULL;
  ELSE
    CLOSE CUR_X_ICCID;
    RETURN REC_X_ICCID.SIM;
  END IF;
END sp_rim_GSM_SIM;


--------------------------------------------------------------------------------
PROCEDURE SP_CREATE_RIM_ACTION_ITEM
  /*******************************************************************************************************************************/
  /* Procedure  Name:SP_CREATE_RIM_ACTION_ITEM                                                                                    */
  /* Description: This procedure  insert into table gw1.Table_x_RIM_transaction by action_item in ig_transaction for RIM ESN      */
  /*              for succesfull ig_transaction igate_in3 call this procedure when completed sucesfull                            */
  /********************************************************************************************************************************/
  (
	p_action_item_id IN VARCHAR2, -- wg1.ig_transaction.ACTION_ITEM_ID VARCHAR2(30)
    op_msg OUT VARCHAR2,          -- Output Message
    op_status OUT VARCHAR2        -- Output Status S= Success, F= Failed,
  )
IS

  --
  CURSOR service_rate_curs(c_sp NUMBER )
  IS
    SELECT DISTINCT spfvdef2.value_name RATE,
      sp.objid,
      spfvdef.value_name feature
    FROM x_serviceplanfeaturevalue_def spfvdef,
      x_serviceplanfeature_value spfv,
      x_service_plan_feature spf,
      x_serviceplanfeaturevalue_def spfvdef2,
      x_service_plan sp
    WHERE sp.objid                    = c_sp
    AND spf.sp_feature2service_plan   = sp.objid
    AND spf.sp_feature2rest_value_def = spfvdef.objid
    AND spf.objid                     = spfv.spf_value2spf
    AND spfvdef2.objid                = spfv.value_ref
    AND spfvdef.value_name            = 'RIM_RATE_PLAN'
    ORDER BY sp.objid;
  service_rate_rec service_rate_curs%ROWTYPE;

  --
  CURSOR sp_ig_curs
  IS
    SELECT ct.call_trans2site_part objid_SP,
      spsp.x_service_plan_id objid_SVP,
      ct.objid objid_ct,
      ig.*
    FROM table_task tk,
      table_x_call_trans ct,
      x_service_plan_site_part spsp,
      gw1.ig_transaction ig
    WHERE 1                     =1
    AND ig.action_item_id       = p_action_item_id
    AND tk.task_id              = ig.action_item_id
    AND tk.x_task2x_call_trans  = ct.objid
    AND ct.call_trans2site_part = spsp.table_site_part_id(+);
  sp_ig_rec sp_ig_curs%ROWTYPE;

  --
  CURSOR order_type_curs(c_ot VARCHAR2 )
  IS
    SELECT x_status_rim FROM sa.TABLE_X_ORDER_TYPE_RIM WHERE x_order_type = c_ot;
  order_type_rec order_type_curs%ROWTYPE;
  --count_transaction_id number:= 0;
  --CR22798

  --
  CURSOR COUNT_TRANSACTION_ID_CURS(T_ID VARCHAR2 )
  IS
    SELECT X_TRANSACTION_ID
    FROM GW1.TABLE_X_RIM_TRANSACTION
    WHERE X_TRANSACTION_ID = T_ID;-- sp_ig_rec.TRANSACTION_ID;
  count_transaction_id_REC count_transaction_id_curs%ROWTYPE;
  V_X_CARRIER_ID TABLE_X_RIM_TRANSACTION.X_CARRIER_ID%TYPE := NULL; --CR43636


BEGIN

	OPEN sp_ig_curs;
	FETCH sp_ig_curs INTO sp_ig_rec;
		IF sp_ig_curs%NOTFOUND
		THEN
			op_msg    := 'not exist action item by service plan or task '; -- Output Message
			OP_STATUS := 'F';
			sa.ota_util_pkg.err_log(p_action => 'SP_IG_CURS NOT FOUND' ,p_error_date => SYSDATE ,P_KEY => P_ACTION_ITEM_ID ,P_PROGRAM_NAME => 'RIM_SERVICE_PKG.SP_CREATE_ACTION_ITEM_RIM' ,p_error_text => op_msg);

			CLOSE SP_IG_CURS;
			RETURN;
		END IF;
	CLOSE sp_ig_curs;

  --
	OPEN order_type_curs(sp_ig_rec.order_type);
	FETCH order_type_curs INTO order_type_rec;
		IF order_type_curs%NOTFOUND
		THEN
			op_msg    := 'not exist order type rim by order type'; -- Output Message
			OP_STATUS := 'F';
			--CR53398 - Removed error logging
			/*sa.ota_util_pkg.err_log(p_action => 'order_type_curs NOT FOUND' ,p_error_date => SYSDATE ,P_KEY => P_ACTION_ITEM_ID ,P_PROGRAM_NAME => 'RIM_SERVICE_PKG.SP_CREATE_ACTION_ITEM_RIM' ,p_error_text => op_msg);*/

			CLOSE order_type_curs;
			RETURN;
		END IF;
	CLOSE order_type_curs;

  dbms_output.put_line ('sp_ig_rec.objid_SVP'||TO_CHAR(sp_ig_rec.objid_SVP));

  --
  IF SP_IG_REC.ORDER_TYPE IN ('D','S')
  THEN
    SERVICE_RATE_REC.RATE   := 'Prosumer B';
  ELSIF SP_IG_REC.OBJID_SVP IS NOT NULL
  THEN
    OPEN service_rate_curs (sp_ig_rec.objid_SVP);
    FETCH SERVICE_RATE_CURS INTO SERVICE_RATE_REC;
		IF service_rate_curs%NOTFOUND
		THEN
			op_msg    := 'not exist rate feature by service plan'; -- Output Message
			OP_STATUS := 'F';
			--CR53398 - Removed error logging
			/*sa.ota_util_pkg.err_log(p_action => 'service_rate_curs NOT FOUND' ,p_error_date => SYSDATE ,P_KEY => P_ACTION_ITEM_ID ,P_PROGRAM_NAME => 'RIM_SERVICE_PKG.SP_CREATE_ACTION_ITEM_RIM' ,P_ERROR_TEXT => OP_MSG);*/

			CLOSE SERVICE_RATE_CURS;
			RETURN;
		END IF;
    CLOSE service_rate_curs;

  ELSE
    op_msg    := 'not exist service plan objid'; -- Output Message
    OP_STATUS := 'F';
    --CR53398 - Removed error logging
    /*sa.ota_util_pkg.err_log(p_action => 'SP_IG_REC.OBJID_SVP IS NULL' ,p_error_date => SYSDATE ,P_KEY => P_ACTION_ITEM_ID ,P_PROGRAM_NAME => 'RIM_SERVICE_PKG.SP_CREATE_ACTION_ITEM_RIM' ,P_ERROR_TEXT => OP_MSG);*/

	RETURN;
  END IF; ---end if condition for skip rate CR23362

  --
  --CR43636 Start
	V_X_CARRIER_ID:=sp_ig_rec.carrier_id;
	IF V_X_CARRIER_ID IS NULL
	THEN
		IF sp_ig_rec.ICCID IS NULL
		THEN
			V_X_CARRIER_ID:= '122794';
		ELSE
			V_X_CARRIER_ID:= '1113385';
		END IF;
	END IF;
	--CR43636 END

  --
	OPEN count_transaction_id_curs(sp_ig_rec.TRANSACTION_ID);
	FETCH COUNT_TRANSACTION_ID_CURS INTO count_transaction_id_rec;
		IF count_transaction_id_curs%NOTFOUND
		THEN

			INSERT
			INTO gw1.Table_x_RIM_transaction
			(
				OBJID,
				X_MIN,
				X_ESN,
				X_SIM,
				X_TRANSACT_DATE,
				X_RIM_TRANS_TYPE,
				X_RIM_STATUS,
				X_OLD_MIN,
				X_RATE_PLAN,
				X_LAST_UPDATE,
				X_RIM_ACCOUNT,
				RIM_TRANS2SITE_PART,
				RIM_TRANS2USER,
				X_TRAGET_SYSTEM,
				X_API_STATUS,
				X_API_MESSAGE,
				X_TRANSACTION_ID,
				X_RIM_TRANS2CALL_TRANS,
				X_ESN_HEX ,
				X_CARRIER_ID,
				X_OLD_BILLING_ID,
				X_MSID
			) --CR22452 SM 042013
			  VALUES
			(
				GW1.SEQU_TABLE_X_RIM_TRAN.NEXTVAL,
				sp_ig_rec.MIN,
				SP_IG_REC.ESN,
				SP_RIM_GSM_SIM(sp_ig_rec.action_item_id),-- NULL, --V_X_SIM,
				SYSDATE,
				NVL(order_type_rec.x_status_rim,'N/A'),                                               -- 'N/A is return by default if not exist rim status'
				DECODE(NVL(sp_ig_rec.order_type,'N/A'),'PIR','PENDPORT','EPIR','PENDPORT','PENDING'), --CR23362
				DECODE(sp_ig_rec.order_type,'MINC',sp_ig_rec.old_esn,0),
				service_rate_rec.rate,
				sysdate,
				DECODE(NVL(sp_ig_rec.order_type,'N/A'),'MINC',1,0),
				NVL(sp_ig_rec.objid_SP,0),
				NVL(sp_ig_rec.END_USER,0),
				'RIM',  --V_X_TRAGET_SYSTEM,
				0, --V_X_API_STATUS,--CR43636
				NULL, --V_X_API_MESSAGE,--CR43636
				NVL(SP_IG_REC.TRANSACTION_ID,0),
				NVL(SP_IG_REC.OBJID_CT,0),
				(
				CASE
				  WHEN SP_RIM_GSM_SIM(sp_ig_rec.action_item_id) IS NULL
				  THEN sp_ig_rec.ESN_HEX
				  ELSE NULL
				END), ---CR22452 SM041913
				V_X_CARRIER_ID,--CR43636  --NVL(sp_ig_rec.carrier_id,'N/A'),
				SP_RIM_SIM(SP_IG_REC.ACTION_ITEM_ID),
				sp_ig_rec.msid
			); --CR22452 SM042013

            	IF SQL%rowcount > 0
                THEN
                    op_status    := 'S';
                    op_msg       := 'Insert into table table_ig_RIM_transaction successful';
                END IF;

		ELSE
			-- found rim_transaction cursor then update
			UPDATE gw1.Table_x_RIM_transaction
			SET X_MIN                = sp_ig_rec.MIN,
			  X_ESN                  = sp_ig_rec.ESN,
			  X_RIM_TRANS_TYPE       = NVL(order_type_rec.x_status_rim,'N/A'),
			  X_OLD_MIN              = DECODE(NVL(sp_ig_rec.order_type,'N/A'),'MINC',sp_ig_rec.old_esn,0),
			  X_RATE_PLAN            = service_rate_rec.rate,
			  X_LAST_UPDATE          = sysdate,
			  X_RIM_ACCOUNT          =DECODE(sp_ig_rec.order_type,'MINC',1,0),
			  RIM_TRANS2SITE_PART    =sp_ig_rec.objid_SP,
			  RIM_TRANS2USER         = sp_ig_rec.END_USER,
			  X_RIM_TRANS2CALL_TRANS =sp_ig_rec.objid_ct,
			  X_ESN_HEX              =SP_IG_REC.ESN_HEX,
			  X_CARRIER_ID	         =V_X_CARRIER_ID,
			  x_RIM_STATUS           = DECODE(sp_ig_rec.order_type,'PIR','PENDING','EPIR','PENDING',x_RIM_STATUS) --CR23362
			WHERE x_transaction_id   = sp_ig_rec.TRANSACTION_ID;

                IF SQL%rowcount          > 0
                THEN
                	op_status             := 'S';
                    op_msg                := 'Update into table table_ig_RIM_transaction successful';
            	END IF;
        END IF;

EXCEPTION
WHEN OTHERS
THEN
  op_msg    := TO_CHAR(SQLCODE)||SQLERRM;
  op_status := 'F';
  sa.ota_util_pkg.err_log(p_action => 'when others:Insert or update into Table_ig_RIM_transaction' ,p_error_date => SYSDATE ,p_key => p_action_item_id ,p_program_name => 'SP_CREATE_ACTION_ITEM_RIM' ,p_error_text => op_msg);
END SP_CREATE_RIM_ACTION_ITEM;


--------------------------------------------------------------------------------
PROCEDURE SP_INS_RIM_DEACT_FOR_UPGRADE(
    IN_CALL_TRAN_OBJ IN NUMBER, -- WG1.IG_TRANSACTION.ACTION_ITEM_ID VARCHAR2(30)
    IP_MIN           IN VARCHAR2,
    IP_USEROBJID     IN VARCHAR2,
    IP_OLD_ESN       IN VARCHAR2,
    IP_NEW_ESN       IN VARCHAR2,
    OP_MSG OUT VARCHAR2,   -- OUTPUT MESSAGE
    OP_STATUS OUT VARCHAR2 -- OUTPUT STATUS S= SUCCESS, F= FAILED
  )
IS
  CURSOR CUR_IG
  IS
    SELECT ig.*
    FROM ig_transaction ig,
      table_task t,
      table_x_call_trans ct
    WHERE 1                   =1
    AND ct.objid              = IN_CALL_TRAN_OBJ
    AND ig.action_item_id     = t.task_id
    AND t.x_task2x_call_trans = ct.objid ;
  REC_IG CUR_IG%ROWTYPE;
  CURSOR ORDER_TYPE_CURS(C_OT VARCHAR2 )
  IS
    SELECT X_STATUS_RIM FROM sa.TABLE_X_ORDER_TYPE_RIM WHERE X_ORDER_TYPE = C_OT;
  ORDER_TYPE_REC ORDER_TYPE_CURS%ROWTYPE;
  CURSOR COUNT_TRANSACTION_ID_CURS(CT_OBJID NUMBER, TRANS_ID VARCHAR2 )
  IS
    SELECT X_TRANSACTION_ID
    FROM GW1.TABLE_X_RIM_TRANSACTION
    WHERE (X_RIM_TRANS2CALL_TRANS = CT_OBJID
    OR X_TRANSACTION_ID           = TRANS_ID) ;
  COUNT_TRANSACTION_ID_REC COUNT_TRANSACTION_ID_CURS%ROWTYPE;
  LV_GSM_SIM sa.TABLE_SITE_PART.X_ICCID%TYPE;
  LV_SP_OBJID sa.TABLE_SITE_PART.OBJID%TYPE;
  V_X_CARRIER_ID TABLE_X_RIM_TRANSACTION.X_CARRIER_ID%TYPE := NULL; --CR43070
BEGIN
  -- If there is an IG means record should get inserted from SP_CREATE_RIM_ACTION_ITEM procedure, not this procedure
  -- which is being called in igate_in3.
  -- Sometimes it gets stuck in lower environment.
  OPEN CUR_IG;
  FETCH CUR_IG INTO REC_IG;
  IF CUR_IG%FOUND THEN
    RETURN;
  END IF;
  CLOSE CUR_IG;
  OPEN ORDER_TYPE_CURS('D');
  FETCH ORDER_TYPE_CURS INTO ORDER_TYPE_REC;
  IF ORDER_TYPE_CURS%NOTFOUND THEN
    OP_MSG    := 'Order type does not exist in TABLE_X_ORDER_TYPE_RIM'; -- OUTPUT MESSAGE
    OP_STATUS := 'F';
    sa.OTA_UTIL_PKG.ERR_LOG(P_ACTION => 'Order type does not exist in TABLE_X_ORDER_TYPE_RIM' ,P_ERROR_DATE => SYSDATE ,P_KEY => IP_OLD_ESN ,P_PROGRAM_NAME => 'RIM_SERVICE_PKG.SP_INS_RIM_DEACT_FOR_UPGRADE' ,P_ERROR_TEXT => OP_MSG);
    CLOSE ORDER_TYPE_CURS;
    RETURN;
  END IF;
  CLOSE ORDER_TYPE_CURS;
  --IF SP_IG_REC.ORDER_TYPE IN ('D','S') THEN
  --    SERVICE_RATE_REC.RATE := 'Prosumer B';
  --Fetching carrier id for D and S CR43070 START
  -- CR43636 block below logic  to get a carrier id
  /*BEGIN
    SELECT txc.x_carrier_id x_carrier_id
    INTO v_x_carrier_id
    FROM table_x_carrier txc,
      table_x_call_trans ct
    WHERE ct.objid             = IN_CALL_TRAN_OBJ
    AND ct.X_CALL_TRANS2CARRIER=txc.objid;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_x_carrier_id := 'N/A';
  END;*/
   --Fetching carrier id for D and S CR43070 END
  SELECT DECODE(X.SP_STATE_VALUE,'GSM',NVL(X.SP_X_ICCID,NVL(X.PI_X_ICCID,NULL)),NULL) SIM,
    X.SP_OBJID
  INTO LV_GSM_SIM ,
    LV_SP_OBJID
  FROM
    (SELECT SP.OBJID SP_OBJID ,
      SP.STATE_VALUE SP_STATE_VALUE ,
      SP.X_ICCID SP_X_ICCID ,
      PI.X_ICCID PI_X_ICCID
    FROM sa.TABLE_SITE_PART SP,
      sa.TABLE_PART_INST PI
    WHERE 1               =1
    AND SP.X_SERVICE_ID   = PI.PART_SERIAL_NO
    AND PI.PART_SERIAL_NO = IP_OLD_ESN
    ORDER BY SP.OBJID DESC
    ) X
  WHERE ROWNUM = 1;

  -- CR43636 new logic  to get a carrier id Start

		IF LV_GSM_SIM IS NULL THEN V_X_CARRIER_ID:= '122794'; -- For RIM phones no sim means VZN carrier
		ELSE V_X_CARRIER_ID:= '1113385'; --TMO carrier
		END IF;

	--CR43636 END


  OPEN COUNT_TRANSACTION_ID_CURS(IN_CALL_TRAN_OBJ,REC_IG.TRANSACTION_ID);
  FETCH COUNT_TRANSACTION_ID_CURS INTO COUNT_TRANSACTION_ID_REC;
  IF COUNT_TRANSACTION_ID_CURS%NOTFOUND THEN
    INSERT
    INTO GW1.TABLE_X_RIM_TRANSACTION
      (
        OBJID,
        X_MIN,
        X_ESN,
        X_SIM,
        X_TRANSACT_DATE,
        X_RIM_TRANS_TYPE,
        X_RIM_STATUS,
        X_OLD_MIN,
        X_RATE_PLAN,
        X_LAST_UPDATE,
        X_RIM_ACCOUNT,
        RIM_TRANS2SITE_PART,
        RIM_TRANS2USER,
        X_TRAGET_SYSTEM,
        X_API_STATUS,
        X_API_MESSAGE,
        X_TRANSACTION_ID,
        X_RIM_TRANS2CALL_TRANS,
        X_ESN_HEX ,
        X_CARRIER_ID,
        X_OLD_BILLING_ID,
        X_MSID
      )
      VALUES
      (
        GW1.SEQU_TABLE_X_RIM_TRAN.NEXTVAL --OBJID,
        ,
        IP_MIN --X_MIN,
        ,
        IP_OLD_ESN --X_ESN,
        ,
        LV_GSM_SIM --X_SIM,
        ,
        SYSDATE --X_TRANSACT_DATE,
        ,
        NVL(ORDER_TYPE_REC.X_STATUS_RIM,'N/A') --X_RIM_TRANS_TYPE,
        ,
        'PENDING' --X_RIM_STATUS,
        ,
        IP_MIN --X_OLD_MIN,
        ,
        'Prosumer B' --X_RATE_PLAN,
        ,
        SYSDATE --X_LAST_UPDATE,
        ,
        '' --X_RIM_ACCOUNT,
        ,
        LV_SP_OBJID --RIM_TRANS2SITE_PART,
        ,
        IP_USEROBJID --RIM_TRANS2USER,
        ,
        'RIM' --X_TRAGET_SYSTEM,
        ,
        0 --X_API_STATUS, --CR43636
        ,
        NULL --X_API_MESSAGE,--CR43636
        ,
        REC_IG.TRANSACTION_ID --X_TRANSACTION_ID,
        ,
        IN_CALL_TRAN_OBJ --X_RIM_TRANS2CALL_TRANS,
        ,
      (
        CASE
          WHEN SP_RIM_GSM_SIM(REC_IG.action_item_id) IS NULL
          THEN REC_IG.ESN_HEX
          ELSE NULL
        END)  --NULL CR44632 --X_ESN_HEX ,REC_IG.ESN_HEX (add if it wint work sa.igate.f_get_hex_esn(IP_OLD_ESN))
       -- sa.igate.f_get_hex_esn(IP_OLD_ESN)
		,
        v_x_carrier_id--'N/A'                --X_CARRIER_ID,-- --Populating carrier id for D and S CR43070
        ,
        NULL --X_OLD_BILLING_ID,
        ,
        REC_IG.MSID --X_MSID
      ) ;
  ELSE
    UPDATE GW1.TABLE_X_RIM_TRANSACTION
    SET X_MIN          = IP_MIN,
      X_ESN            = IP_OLD_ESN,
      X_RIM_TRANS_TYPE = 'N/A',
      --X_OLD_MIN = decode(nvl(sp_ig_rec.order_type,'N/A'),'MINC',sp_ig_rec.old_esn,0),
      X_RATE_PLAN                 = 'Prosumer B',
      X_LAST_UPDATE               = sysdate ,
      X_TRANSACTION_ID            = DECODE(REC_IG.TRANSACTION_ID,'',X_TRANSACTION_ID,REC_IG.TRANSACTION_ID) ,
      X_RIM_TRANS2CALL_TRANS      = DECODE(IN_CALL_TRAN_OBJ,'',X_RIM_TRANS2CALL_TRANS,IN_CALL_TRAN_OBJ)
    WHERE (X_RIM_TRANS2CALL_TRANS = IN_CALL_TRAN_OBJ
    OR X_TRANSACTION_ID           = REC_IG.TRANSACTION_ID) ;
  END IF;
EXCEPTION
WHEN OTHERS THEN
  OP_MSG    := TO_CHAR(SQLCODE)||SQLERRM;
  OP_STATUS := 'F';
  sa.OTA_UTIL_PKG.ERR_LOG(P_ACTION => 'Exception when others:Insert or update into TABLE_IG_RIM_TRANSACTION' ,P_ERROR_DATE => SYSDATE ,P_KEY => IP_OLD_ESN ,P_PROGRAM_NAME => 'RIM_SERVICE_PKG.SP_INS_RIM_DEACT_FOR_UPGRADE' ,P_ERROR_TEXT => OP_MSG);
END SP_INS_RIM_DEACT_FOR_UPGRADE;
END RIM_SERVICE_PKG;
/