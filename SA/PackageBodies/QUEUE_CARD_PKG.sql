CREATE OR REPLACE PACKAGE BODY sa."QUEUE_CARD_PKG"
AS
 --
 ---------------------------------------------------------------------------------------------
 --$RCSfile: QUEUE_CARD_PKG.sql,v $
 --$Revision: 1.78 $
 --$Author: skambhammettu $
 --$Date: 2018/01/31 19:18:47 $
 --$ $Log: QUEUE_CARD_PKG.sql,v $
 --$ Revision 1.78  2018/01/31 19:18:47  skambhammettu
 --$ Added new column numberOfLines in sp_my_acct_get_queue_by_esn
 --$
 --$ Revision 1.77  2017/12/01 16:44:19  skambhammettu
 --$ Added Comments
 --$
 --$ Revision 1.76  2017/11/10 14:17:07  skambhammettu
 --$ Change in SP_MY_ACCT_GET_QUEUE_BY_ESN
 --$
 --$ Revision 1.75  2017/10/19 21:10:35  skota
 --$ Modified the call trans reason for ILD transactions
 --$
 --$ Revision 1.73  2017/03/01 23:41:37  sgangineni
 --$ CR47564 -WFM Changes
 --$
 --$ Revision 1.72  2017/03/01 00:59:26  sgangineni
 --$ CR47564 - WFM Changes
 --$
 --$ Revision 1.70  2017/02/08 23:06:22  sgangineni
 --$ CR47564 - Modified to get the service days from table_x_call_trans_ext for WFM based
 --$  on the brm applicable flag.
 --$
 --$ Revision 1.69  2017/02/01 20:54:08  sgangineni
 --$ CR47564 - WFM Changes
 --$
 --$ Revision 1.68  2017/01/05 15:27:54  tbaney
 --$ Modified query for performance.  CR47024
 --$
 --$ Revision 1.67  2016/11/30 16:30:53  tbaney
 --$ Modified query to use part status without hint.
 --$
 --$ Revision 1.66  2016/11/29 22:22:35  tbaney
 --$ Added date checks for CR42459.
 --$
  --$ Revision 1.65  2016/10/26 13:03:10  ddudhankar
  --$ CR44787 - BOGO update mtm_bogo_bi_info table
  --$
  --$ Revision 1.62  2015/10/21 18:15:51  ddevaraj
  --$ For CR38582
  --$
  --$ Revision 1.60  2015/07/01 18:32:32  rpednekar
  --$ Changes done for CR32144.
  --$
  --$ Revision 1.59  2015/06/30 21:55:23  rpednekar
  --$ Changes done for CR32144
  --$
  --$ Revision 1.58  2015/04/08 17:25:52  jarza
  --$ CR33035 - Getting service plan mobile desc based on script ids
  --$
  --$ Revision 1.57  2015/04/01 18:13:26  jarza
  --$ CR33035 changes
  --$
  --$ Revision 1.56  2015/03/26 07:12:01  jarza
  --$ CR33035  - My account native app release 2 changes
  --$
  --$ Revision 1.55  2015/01/12 16:36:16  jarza
  --$ CR32032 changes to select statement
  --$
  --$ Revision 1.54  2015/01/09 16:38:03  jarza
  --$ CR32032
  --$
  --$ Revision 1.52  2014/12/15 22:06:17  jarza
  --$ Added service plan objid as one of output parameter
  --$
  --$ Revision 1.51  2014/12/15 20:00:15  jarza
  --$ Changes to cr32032
  --$
  --$ Revision 1.50  2014/12/11 20:19:01  jarza
  --$ CR32032 - My account mobile app related changes.
  --$
  --$ Revision 1.48  2014/07/23 21:44:54  rramachandran
  --$ CR29381 - Net10 ATT and TMO BYOP Activation Promotion for IVR
  --$
  --$ Revision 1.47  2014/03/03 19:55:27  cpannala
  --$ CR25490 merge the code with production version
  --$
  --$ Revision 1.45  2013/11/22 18:32:05  ymillan
  --$ CR25686
  --$
  --$ Revision 1.44  2013/06/04 21:31:56  ymillan
  --$ CR22883
  --$
  --$ Revision 1.42  2013/04/30 16:00:16  icanavan
  --$ CR21443 CR22634 sp_redeem_card proc
  --$
  --$ Revision 1.39  2013/03/08 18:39:47  ymillan
  --$ CR19663
  --$
  --$ Revision 1.37  2012/08/17 19:56:08  icanavan
  --$ TELCEL and merge
  --$
  --$ Revision 1.34  2012/06/18 21:12:01  kacosta
  --$ CR21142 Enhance Queued Minutes Delivery Job
  --$
  --$ Revision 1.33  2011/12/07 22:35:52  icanavan
  --$ added CL changes
  --$
  --$ Revision 1.32  2011/12/06 22:23:46  icanavan
  --$ CHANGE cursor in SP_GET_QUEUE_ALL_ESN
  --$
  --$ Revision 1.31  2011/10/24 17:32:48  pmistry
  --$ New parameter for call trans creation flag for add queue card, new column added for ivr plan id for get queued by esn
  --$
  --$ Revision 1.30  2011/08/18 20:13:15  ymilan
  --$ CR16926
  --$
  --$ Revision 1.28  2011/07/30 01:21:58  skuthadi
  --$ CR17182 - Modified IS_PHN_PLAN_COMPTBLE_CURS to remove GOTO statement
  --$
  --$ Revision 1.27  2011/07/28 13:56:19  skuthadi
  --$ CR17182 - Modified SP_TRNSFR_QUEUE_TO_ACTIVE_ESN to handle Priorities, X_EXT in part inst
  --$
  --$ Revision 1.26  2011/07/27 15:01:59  skuthadi
  --$ CR17182 - Modified IS_PHN_PLAN_COMPTBLE_CURS query to check compatability of OLD CARD PINS with NEW ESN
  --$
  --$ Revision 1.25  2011/07/20 14:20:24  skuthadi
  --$ CR17182 - Modified SP_TRNSFR_QUEUE_TO_ACTIVE_ESN to handle OLD ESNS WARR END DATE > SYSDATE - 20, PARENT_OBJID = 0
  --$
  --$ Revision 1.30  2011/08/18  14:00:00 skutadi
  --$ CR16926
  --$
  --$
  ---------------------------------------------------------------------------------------------
  -- Revision 1.33 2011/12/06 clindner CR19288 - sp_get_queue_all_esn
  -- Revision 1.XX 2013/04/30 icanavan CR21443 CR22634
  --
PROCEDURE sp_get_queue_by_esn(
    p_esn IN VARCHAR2 ,
    p_queue_detail_by_esn OUT SYS_REFCURSOR ,
    p_err_num OUT NUMBER ,
    p_err_string OUT VARCHAR2 )
IS
  CURSOR cu_esn_dtl
  IS
    SELECT pi.objid esn_objid ,
      bo.objid bo_objid ,
      PI.X_PART_INST_STATUS,
      bo.org_flow
    FROM table_part_inst pi ,
      table_mod_level ml ,
      table_part_num pn ,
      table_bus_org bo
    WHERE ml.objid        = pi.n_part_inst2part_mod
    AND pn.objid          = ml.part_info2part_num
    AND bo.objid          = pn.part_num2bus_org
    AND pi.part_serial_no = p_esn;
  rec_esn_dtl cu_esn_dtl%ROWTYPE;
  v_esn_plan_desc VARCHAR2(1000) := NULL;
BEGIN
  --CR14786 STARTS
  IF p_esn       IS NULL THEN
    p_err_num    := 444;
    p_err_string := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
    GOTO procedure_end;
  END IF;
  --CR14786 ENDS
  OPEN cu_esn_dtl;
  FETCH cu_esn_dtl INTO rec_esn_dtl;
  IF cu_esn_dtl%FOUND THEN
    /*open   P_QUEUE_DETAIL_BY_ESN for
    select PI.OBJID PIN_OBJID, X_EXT PRIORITY, X_RED_CODE, PN.X_REDEEM_UNITS UNITS, PN.X_REDEEM_DAYS DAYS, pc.name part_class_name
    from  TABLE_PART_INST PI, TABLE_MOD_LEVEL ML, TABLE_PART_NUM PN, TABLE_BUS_ORG BO, table_part_class pc
    where ML.OBJID                  = PI.N_PART_INST2PART_MOD
    and   PN.OBJID                  = ML.PART_INFO2PART_NUM
    and   BO.OBJID                  = PN.PART_NUM2BUS_ORG
    and   PI.PART_TO_ESN2PART_INST  = REC_ESN_DTL.ESN_OBJID
    and   pc.objid                  = pn.part_num2part_class
    and   PI.X_DOMAIN               = 'REDEMPTION CARDS'
    and   PI.X_PART_INST_STATUS     = '400'
    and   bo.objid                  = rec_esn_dtl.bo_objid;
    */
    /* CR13919 Start (11/29/2010) - Return queued cards even if the esn is inactive except for Stolen. */
    IF rec_esn_dtl.x_part_inst_status = '53' THEN
      CLOSE cu_esn_dtl;
      p_err_num    := 437;
      p_err_string := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
      GOTO procedure_end;
    END IF;
    --CR 29381 RRS 07/23/2014
    BEGIN
      SELECT sp.description desc2
      INTO v_esn_plan_desc
      FROM x_service_plan_site_part spsp ,
        x_service_plan sp ,
        table_site_part tsp
      WHERE tsp.x_service_id = p_esn --tsp.part_status ='Active'
        -- CR15046 Start
      AND tsp.objid                                              = DECODE(
        (SELECT COUNT(1) FROM table_site_part WHERE x_service_id = p_esn
        AND part_status                                          = 'Active'
        ) ,1 ,
        (SELECT objid
        FROM table_site_part
        WHERE x_service_id = p_esn
        AND part_status    = 'Active'
        ) ,
        (SELECT MAX(objid)
        FROM table_site_part
        WHERE x_service_id = p_esn
        AND part_status   <> 'Obsolete'
        ))
        -- CR15046 End
      AND sp.objid                = spsp.x_service_plan_id
      AND spsp.table_site_part_id = tsp.objid;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_ESN_PLAN_DESC := NULL;
    END;
    /* CR13919 End (11/29/2010) */
    --CR29381 RRS 07/23/2014
    OPEN p_queue_detail_by_esn FOR SELECT card_plan.* ,
    NVL(v_esn_plan_desc,'NONE') esn_plan ,
    card_plan.desc1 card_plan ,
    DECODE(NVL(v_esn_plan_desc,'NONE'),card_plan.desc1 ,'FALSE' ,'TRUE')
  AS
    "SWAP_PLAN" FROM
    (SELECT DISTINCT sp.description desc1 ,
      pi.objid pin_objid ,
      x_ext priority ,
      x_red_code ,
      (SELECT DISTINCT spfvdef2.value_name property_value
      FROM x_serviceplanfeaturevalue_def spfvdef1 ,
        x_serviceplanfeature_value aspfv ,
        x_service_plan_feature aspf ,
        x_serviceplanfeaturevalue_def spfvdef2 ,
        x_service_plan asp
      WHERE aspf.sp_feature2service_plan = asp.objid
      AND aspf.sp_feature2rest_value_def = spfvdef1.objid
      AND aspf.objid                     = aspfv.spf_value2spf
      AND spfvdef2.objid                 = aspfv.value_ref
      AND spfvdef1.value_name           IN ('VOICE')
        --   AND asp.description                = sp.description  CR25686
      AND asp.objid = sp.objid --CR25686
      ) voice ,
      (SELECT DISTINCT spfvdef2.value_name property_value
      FROM x_serviceplanfeaturevalue_def spfvdef1 ,
        x_serviceplanfeature_value aspfv ,
        x_service_plan_feature aspf ,
        x_serviceplanfeaturevalue_def spfvdef2 ,
        x_service_plan asp
      WHERE aspf.sp_feature2service_plan = asp.objid
      AND aspf.sp_feature2rest_value_def = spfvdef1.objid
      AND aspf.objid                     = aspfv.spf_value2spf
      AND spfvdef2.objid                 = aspfv.value_ref
      AND spfvdef1.value_name           IN ('SMS')
        --    AND asp.description                = sp.description  --CR25686
      AND asp.objid = sp.objid --CR25686
      ) sms ,
      (SELECT DISTINCT spfvdef2.value_name property_value
      FROM x_serviceplanfeaturevalue_def spfvdef1 ,
        x_serviceplanfeature_value aspfv ,
        x_service_plan_feature aspf ,
        x_serviceplanfeaturevalue_def spfvdef2 ,
        x_service_plan asp
      WHERE aspf.sp_feature2service_plan = asp.objid
      AND aspf.sp_feature2rest_value_def = spfvdef1.objid
      AND aspf.objid                     = aspfv.spf_value2spf
      AND spfvdef2.objid                 = aspfv.value_ref
      AND spfvdef1.value_name           IN ('DATA')
        --   AND asp.description                = sp.description  --CR25686
      AND asp.objid = sp.objid --CR25686
      ) data ,
        --CR47564 Changes start
        sa.customer_info.get_service_plan_days (i_esn => p_esn,
                                              i_pin => pi.x_red_code,
                                              i_service_plan_objid => sp.objid) days,
        --CR47564 Changes end
      pc.name part_class_name ,
      pn.part_number ,
      pn.description part_description ,
      sp.customer_price ,
      pi.last_trans_time ,
      sp.ivr_plan_id -- CR15847 PM ST-Stacking
    FROM sa.table_part_class pc ,
      sa.table_part_num pn ,
      sa.table_mod_level ml ,
      sa.table_part_inst pi ,
      mtm_partclass_x_spf_value_def mtmspfv ,
      x_serviceplanfeature_value spfv ,
      x_service_plan_feature spf ,
      x_service_plan sp ,
      table_bus_org bo
    WHERE pc.objid                    = pn.part_num2part_class
    AND pn.objid                      = ml.part_info2part_num
    AND ml.objid                      = pi.n_part_inst2part_mod
    AND mtmspfv.part_class_id         = pc.objid
    AND mtmspfv.spfeaturevalue_def_id = spfv.value_ref
    AND spfv.spf_value2spf            = spf.objid
    AND spf.sp_feature2service_plan   = sp.objid
    AND bo.objid                      = pn.part_num2bus_org
    AND pi.x_domain                   = 'REDEMPTION CARDS'
    AND pi.x_part_inst_status         = '400'
    AND pi.part_to_esn2part_inst      = rec_esn_dtl.esn_objid
    AND bo.objid                      = rec_esn_dtl.bo_objid
    ) card_plan;
  ELSE
    CLOSE cu_esn_dtl;
    p_err_num    := 437;
    p_err_string := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
    GOTO procedure_end;
  END IF;
  CLOSE cu_esn_dtl;
  p_err_num    := 0;
  p_err_string := 'Successful.';
  <<procedure_end>>
  NULL;
  IF p_err_num <> 0 THEN
    OPEN p_queue_detail_by_esn FOR
    --SELECT NULL PIN_OBJID, NULL PRIORITY, NULL X_RED_CODE, NULL UNITS, NULL DAYS, NULL PART_CLASS_NAME
    --FROM  DUAL;
    SELECT NULL desc1 ,
    NULL pin_objid ,
    NULL priority ,
    NULL x_red_code ,
    NULL voice ,
    NULL sms ,
    NULL data ,
    NULL days ,
    NULL part_class_name ,
    NULL part_number ,
    NULL part_description ,
    NULL customer_price ,
    NULL last_trans_time ,
    NULL esn_plan ,
    NULL card_plan ,
    NULL swap_plan ,
    NULL ivr_plan_id -- CR15847 PM ST-Stacking
    FROM dual;
  END IF;
END sp_get_queue_by_esn;
-------------------------------------------------------------------------
--------------------------CR33035 Changes-----------------------------------------------
-------------------------------------------------------------------------
FUNCTION FN_GET_SCRIPT_TEXT_BY_SP_DESC(
  IP_SERVICEPLAN_OBJID  IN sa.X_SERVICE_PLAN.OBJID%TYPE
  , IP_FEATURE          IN sa.X_SERVICEPLANFEATUREVALUE_DEF.VALUE_NAME%TYPE
  , IP_ORG_ID           IN sa.TABLE_BUS_ORG.ORG_ID%TYPE
  )
  RETURN VARCHAR2
AS
  LV_COMPLETE_SCRIPT_ID     sa.X_SERVICEPLANFEATUREVALUE_DEF.DISPLAY_NAME%TYPE := NULL;
  LV_SCRIPT_TYPE            VARCHAR2(100):= NULL;
  LV_SCRIPT_ID              VARCHAR2(100):= NULL;
  LV_UNDERSCORE_COUNT       PLS_INTEGER := 0;
  LV_OBJID                  VARCHAR2(2000);
  LV_DESCRIPTION            VARCHAR2(2000):= NULL;
  LV_SCRIPT_TEXT            VARCHAR2(2000);
  LV_PUBLISH_BY             VARCHAR2(2000);
  LV_PUBLISH_DATE           DATE;
  LV_SM_LINK                VARCHAR2(2000);
BEGIN
  BEGIN
    SELECT  SPFVDEF2.DISPLAY_NAME       PROPERTY_NAME
    INTO    LV_COMPLETE_SCRIPT_ID
    FROM    sa.X_SERVICEPLANFEATUREVALUE_DEF SPFVDEF,
            sa.X_SERVICEPLANFEATURE_VALUE SPFV,
            sa.X_SERVICE_PLAN_FEATURE SPF,
            sa.X_SERVICEPLANFEATUREVALUE_DEF SPFVDEF2,
            sa.X_SERVICE_PLAN SP
    WHERE   1                           = 1
    AND     SPF.SP_FEATURE2SERVICE_PLAN   = SP.OBJID
    AND     SPF.SP_FEATURE2REST_VALUE_DEF = SPFVDEF.OBJID
    AND     SPF.OBJID                     = SPFV.SPF_VALUE2SPF
    AND     SPFVDEF2.OBJID                = SPFV.VALUE_REF
    AND     SPFVDEF.VALUE_NAME            = IP_FEATURE
    AND     SP.OBJID                      = IP_SERVICEPLAN_OBJID
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      LV_COMPLETE_SCRIPT_ID := NULL;
  END ;
  IF LV_COMPLETE_SCRIPT_ID IS NOT NULL THEN
    SELECT  INSTR(LV_COMPLETE_SCRIPT_ID,'_',1)
    INTO    LV_UNDERSCORE_COUNT
    FROM    DUAL;

    SELECT  SUBSTR(LV_COMPLETE_SCRIPT_ID,1,(LV_UNDERSCORE_COUNT-1))
            , SUBSTR(LV_COMPLETE_SCRIPT_ID,(LV_UNDERSCORE_COUNT+1))
    INTO    LV_SCRIPT_TYPE
            , LV_SCRIPT_ID
    FROM DUAL;

    sa.SCRIPTS_PKG.GET_SCRIPT_PRC(
      IP_SOURCESYSTEM => 'WEB',
      IP_BRAND_NAME => IP_ORG_ID,
      IP_SCRIPT_TYPE => LV_SCRIPT_TYPE,
      IP_SCRIPT_ID => LV_SCRIPT_ID,
      IP_LANGUAGE => 'ENGLISH',
      IP_CARRIER_ID => NULL,
      IP_PART_CLASS => 'ALL',
      OP_OBJID => LV_OBJID,
      OP_DESCRIPTION => LV_DESCRIPTION,
      OP_SCRIPT_TEXT => LV_SCRIPT_TEXT,
      OP_PUBLISH_BY => LV_PUBLISH_BY,
      OP_PUBLISH_DATE => LV_PUBLISH_DATE,
      OP_SM_LINK => LV_SM_LINK
    );
  END IF;
  RETURN LV_SCRIPT_TEXT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END FN_GET_SCRIPT_TEXT_BY_SP_DESC;
-------------------------------------------------------------------------
-----------------START CR32032 CHANGES - My account mobile app-----------
-------------------------------------------------------------------------
PROCEDURE sp_my_acct_get_queue_by_esn(
    p_esn IN VARCHAR2 ,
    p_queue_detail_by_esn OUT SYS_REFCURSOR ,
    p_err_num OUT NUMBER ,
    p_err_string OUT VARCHAR2 )
IS
  CURSOR cu_esn_dtl
  IS
    SELECT pi.objid esn_objid ,
      bo.objid bo_objid ,
      PI.X_PART_INST_STATUS,
      bo.org_flow
    FROM table_part_inst pi ,
      table_mod_level ml ,
      table_part_num pn ,
      table_bus_org bo
    WHERE ml.objid        = pi.n_part_inst2part_mod
    AND pn.objid          = ml.part_info2part_num
    AND bo.objid          = pn.part_num2bus_org
    AND pi.part_serial_no = p_esn;
  rec_esn_dtl cu_esn_dtl%ROWTYPE;
  v_esn_plan_desc VARCHAR2(1000) := NULL;
  LV_ESN_PHONE_PC_OBJID     sa.TABLE_PART_CLASS.OBJID%TYPE;
BEGIN
  --CR14786 STARTS
  IF p_esn       IS NULL THEN
    p_err_num    := 444;
    p_err_string := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
    GOTO procedure_end;
  END IF;
  --CR14786 ENDS
  OPEN cu_esn_dtl;
  FETCH cu_esn_dtl INTO rec_esn_dtl;
  IF cu_esn_dtl%FOUND THEN
    /* CR13919 Start (11/29/2010) - Return queued cards even if the esn is inactive except for Stolen. */
    IF rec_esn_dtl.x_part_inst_status = '53' THEN
      CLOSE cu_esn_dtl;
      p_err_num    := 437;
      p_err_string := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
      GOTO procedure_end;
    END IF;
    --CR 29381 RRS 07/23/2014
    BEGIN
      SELECT sp.description desc2
      INTO v_esn_plan_desc
      FROM x_service_plan_site_part spsp ,
        x_service_plan sp ,
        table_site_part tsp
      WHERE tsp.x_service_id = p_esn --tsp.part_status ='Active'
        -- CR15046 Start
      AND tsp.objid                                              = DECODE(
        (SELECT COUNT(1) FROM table_site_part WHERE x_service_id = p_esn
        AND part_status                                          = 'Active'
        ) ,1 ,
        (SELECT objid
        FROM table_site_part
        WHERE x_service_id = p_esn
        AND part_status    = 'Active'
        ) ,
        (SELECT MAX(objid)
        FROM table_site_part
        WHERE x_service_id = p_esn
        AND part_status   <> 'Obsolete'
        ))
        -- CR15046 End
      AND sp.objid                = spsp.x_service_plan_id
      AND spsp.table_site_part_id = tsp.objid;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_ESN_PLAN_DESC := NULL;
    END;

    SELECT PC.objid
    INTO    lv_esn_phone_pc_objid
    FROM sa.table_part_inst pi ,
      sa.table_mod_level ml ,
      sa.table_part_num pn ,
      sa.table_part_class PC,
      sa.table_bus_org bo
    WHERE ml.objid        = pi.n_part_inst2part_mod
    AND pn.objid          = ml.part_info2part_num
    AND bo.objid          = pn.part_num2bus_org
    AND pc.objid          = pn.part_num2part_class
    AND pi.objid          = rec_esn_dtl.esn_objid
    AND bo.objid          = rec_esn_dtl.bo_objid
    ;
    /* CR13919 End (11/29/2010) */
    --CR29381 RRS 07/23/2014
    OPEN p_queue_detail_by_esn FOR SELECT card_plan.* ,
    NVL(v_esn_plan_desc,'NONE') esn_plan ,
    card_plan.desc1 card_plan ,
    DECODE(NVL(v_esn_plan_desc,'NONE'),card_plan.desc1 ,'FALSE' ,'TRUE')
  AS
    "SWAP_PLAN" FROM
    (SELECT DISTINCT sp.objid Service_plan_objid,
      sp.description desc1 ,
      pi.objid pin_objid ,
      x_ext priority ,
      x_red_code ,
      sa.brand_x_pkg.get_feature_value  ( ip_service_plan_id => sp.objid, ip_fea_name => 'NUMBER_OF_LINES') numberOfLines, --Added  for TW Web common standards
      (SELECT spfvdef2.display_name property_name
      FROM x_serviceplanfeaturevalue_def spfvdef1 ,
        x_serviceplanfeature_value aspfv ,
        x_service_plan_feature aspf ,
        x_serviceplanfeaturevalue_def spfvdef2 ,
        x_service_plan asp
      WHERE aspf.sp_feature2service_plan = asp.objid
      AND aspf.sp_feature2rest_value_def = spfvdef1.objid
      AND aspf.objid                     = aspfv.spf_value2spf
      AND spfvdef2.objid                 = aspfv.value_ref
      AND spfvdef1.value_name           IN ('VOICE')
        --   AND asp.description                = sp.description  CR25686
      AND asp.objid = sp.objid --CR25686
      ) voice ,
      (SELECT spfvdef2.display_name property_name
      FROM x_serviceplanfeaturevalue_def spfvdef1 ,
        x_serviceplanfeature_value aspfv ,
        x_service_plan_feature aspf ,
        x_serviceplanfeaturevalue_def spfvdef2 ,
        x_service_plan asp
      WHERE aspf.sp_feature2service_plan = asp.objid
      AND aspf.sp_feature2rest_value_def = spfvdef1.objid
      AND aspf.objid                     = aspfv.spf_value2spf
      AND spfvdef2.objid                 = aspfv.value_ref
      AND spfvdef1.value_name           IN ('SMS')
        --    AND asp.description                = sp.description  --CR25686
      AND asp.objid = sp.objid --CR25686
      ) sms ,
      (SELECT spfvdef2.display_name property_name
      FROM x_serviceplanfeaturevalue_def spfvdef1 ,
        x_serviceplanfeature_value aspfv ,
        x_service_plan_feature aspf ,
        x_serviceplanfeaturevalue_def spfvdef2 ,
        x_service_plan asp
      WHERE aspf.sp_feature2service_plan = asp.objid
      AND aspf.sp_feature2rest_value_def = spfvdef1.objid
      AND aspf.objid                     = aspfv.spf_value2spf
      AND spfvdef2.objid                 = aspfv.value_ref
      AND spfvdef1.value_name           IN ('DATA')
        --   AND asp.description                = sp.description  --CR25686
      AND asp.objid = sp.objid --CR25686
      ) data ,
      --CR47564 changes start
        sa.customer_info.get_service_plan_days_name (i_esn => p_esn,
                                                   i_pin => pi.x_red_code,
                                                   i_service_plan_objid => sp.objid) days,
      --CR47564 changes end
      (sa.QUEUE_CARD_PKG.FN_GET_SCRIPT_TEXT_BY_SP_DESC(sp.objid,'MOBILE_DESCRIPTION1', bo.ORG_ID ) ) MOBILE_DESCRIPTION1,
      (sa.QUEUE_CARD_PKG.FN_GET_SCRIPT_TEXT_BY_SP_DESC(sp.objid,'MOBILE_DESCRIPTION2', bo.ORG_ID ) ) MOBILE_DESCRIPTION2,
      (sa.QUEUE_CARD_PKG.FN_GET_SCRIPT_TEXT_BY_SP_DESC(sp.objid,'MOBILE_DESCRIPTION3', bo.ORG_ID ) ) MOBILE_DESCRIPTION3,
      (sa.QUEUE_CARD_PKG.FN_GET_SCRIPT_TEXT_BY_SP_DESC(sp.objid,'MOBILE_DESCRIPTION4', bo.ORG_ID ) ) MOBILE_DESCRIPTION4,
      pc.name part_class_name ,
      pn.part_number ,
      pn.description part_description ,
      sp.customer_price ,
      pi.last_trans_time ,
      sp.ivr_plan_id ,-- CR15847 PM ST-Stacking
      (sa.QUEUE_CARD_PKG.FN_GET_SCRIPT_TEXT_BY_SP_DESC(sp.objid,'CUST_PROFILE_SCRIPT', bo.ORG_ID ) )  CUST_PROFILE_DESCRIPTION --CR53217 Add cust profile description
    FROM sa.table_part_class pc ,
      sa.table_part_num pn ,
      sa.table_mod_level ml ,
      sa.table_part_inst pi ,
      mtm_partclass_x_spf_value_def mtmspfv ,
      x_serviceplanfeature_value spfv ,
      mtm_partclass_x_spf_value_def mtmspfv_p,
      x_serviceplanfeature_value spfv_p,
      x_service_plan_feature spf ,
      x_service_plan sp ,
      table_bus_org bo
    WHERE pc.objid                    = pn.part_num2part_class
    AND pn.objid                      = ml.part_info2part_num
    AND ml.objid                      = pi.n_part_inst2part_mod
    AND mtmspfv.part_class_id         = pc.objid
    AND mtmspfv.spfeaturevalue_def_id = spfv.value_ref
    AND mtmspfv_p.part_class_id = LV_ESN_PHONE_PC_OBJID --Phone part class objid
    AND spfv.value_ref = spfv_p.value_ref
    AND mtmspfv_p.spfeaturevalue_def_id = spfv_p.value_ref
    AND spfv.spf_value2spf            = spf.objid
    AND spf.sp_feature2service_plan   = sp.objid
    AND bo.objid                      = pn.part_num2bus_org
    AND pi.x_domain                   = 'REDEMPTION CARDS'
    AND pi.x_part_inst_status         = '400'
    AND pi.part_to_esn2part_inst      = rec_esn_dtl.esn_objid
    AND bo.objid                      = rec_esn_dtl.bo_objid
    ) card_plan;
  ELSE
    CLOSE cu_esn_dtl;
    p_err_num    := 437;
    p_err_string := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
    GOTO procedure_end;
  END IF;
  CLOSE cu_esn_dtl;
  p_err_num    := 0;
  p_err_string := 'Successful.';
  <<procedure_end>>
  NULL;
  IF p_err_num <> 0 THEN
    OPEN p_queue_detail_by_esn FOR SELECT NULL Service_plan_objid,
    NULL desc1 ,
    NULL pin_objid ,
    NULL priority ,
    NULL x_red_code ,
    NULL numberOfLines,--Added  for TW Web common standards
    NULL voice ,
    NULL sms ,
    NULL data ,
    NULL days ,
    NULL MOBILE_DESCRIPTION1,
    NULL MOBILE_DESCRIPTION2,
    NULL MOBILE_DESCRIPTION3,
    NULL MOBILE_DESCRIPTION4,
    NULL part_class_name ,
    NULL part_number ,
    NULL part_description ,
    NULL customer_price ,
    NULL last_trans_time ,
    NULL esn_plan ,
    NULL card_plan ,
    NULL swap_plan ,
    NULL ivr_plan_id, -- CR15847 PM ST-Stacking
    NULL CUST_PROFILE_DESCRIPTION
    FROM dual;
  END IF;
END sp_my_acct_get_queue_by_esn;

PROCEDURE sp_get_queue_all_esn(
    p_queue_detail_all_esn OUT SYS_REFCURSOR ,
    p_err_num OUT NUMBER ,
    p_err_string OUT VARCHAR2 )
IS
  --
  --
BEGIN
  -- CR42459 Added COALESCE(sp.cmmtmnt_end_dt,sp.x_expire_dt) for date checks.
  DELETE FROM sa.x_queue_card_temp;
  COMMIT;
  INSERT INTO sa.x_queue_card_temp
  SELECT /*+ index(sp,IND_SITE_PART_CDATE */
         sp.rowid row_id
    FROM table_site_part sp
   WHERE sp.CMMTMNT_END_DT < trunc(sysdate) +1
     AND sp.part_status    = 'Active'
  UNION
  SELECT /*+ INDEX(sp ,SP_STATUS_EXP_DT_IDX) */
         sp.rowid row_id
    FROM table_site_part sp
  WHERE 1                                                                            = 1
     AND NVL(sp.part_status ,'Obsolete')                                              = 'Active'
     AND NVL(sp.x_expire_dt ,TO_DATE('1753-01-01 00:00:00' ,'yyyy-mm-dd hh24:mi:ss')) > TO_DATE('1753-02-01 00:00:00' ,'yyyy-mm-dd hh24:mi:ss')
     AND NVL(sp.x_expire_dt ,TO_DATE('1753-01-01 00:00:00' ,'yyyy-mm-dd hh24:mi:ss')) < TRUNC(SYSDATE) + 1
  AND sp.cmmtmnt_end_dt IS NULL
  ;



  COMMIT;
  /*
  -- use temp table so SQA can add ESNs
  DELETE FROM sa.x_queue_card_temp;
  COMMIT;
  INSERT INTO sa.x_queue_card_temp
  SELECT ROW_ID from sa.queue_card_esn;
  COMMIT;
  Delete from sa.queue_card_esn ;
  Commit;
  */
  --
  --CR21142 Start kacosta 06/18/2012
  UPDATE table_part_inst tpi_esn
  SET tpi_esn.x_part_inst_status   = '52' ,
    tpi_esn.status2x_code_table    = 988
  WHERE tpi_esn.x_part_inst_status = '56'
  AND tpi_esn.x_domain             = 'PHONES'
  AND EXISTS
    (SELECT 1
    FROM table_part_inst tpi_red_card
    WHERE tpi_red_card.part_to_esn2part_inst = tpi_esn.objid
    AND tpi_red_card.x_part_inst_status      = '400'
    AND tpi_red_card.x_domain                = 'REDEMPTION CARDS'
    )
  AND EXISTS
    (SELECT 1
    FROM sa.x_queue_card_temp qct
    JOIN table_site_part tsp
    ON tsp.rowid                                                                      = qct.row_id
    WHERE tsp.x_service_id                                                            = tpi_esn.part_serial_no
    AND tsp.part_status                                                               = 'Active'
    AND NVL(tsp.x_expire_dt ,TO_DATE('1753-01-01 00:00:00' ,'yyyy-mm-dd hh24:mi:ss')) > TO_DATE('1753-02-01 00:00:00' ,'yyyy-mm-dd hh24:mi:ss')
    AND NVL(tsp.x_expire_dt ,TO_DATE('1753-01-01 00:00:00' ,'yyyy-mm-dd hh24:mi:ss')) < TRUNC(SYSDATE) + 1
    );
  --
  COMMIT;
  --CR21142 End kacosta 06/18/2012
  --
  OPEN p_queue_detail_all_esn FOR SELECT esn ,
  esn_objid ,
  pin_objid ,
  priority ,
  x_red_code ,
  units ,
  days FROM
  (SELECT
    /*+ ORDERED FULL(c1) PARALLEL(c1 ,4) USE_NL(sp) INDEX(pi_pin, IND_PART_INST2SITE_PART_N5) */
    RANK() over(PARTITION BY pi_pin.part_to_esn2part_inst ORDER BY TO_NUMBER(pi_pin.x_ext) ASC) rnk ,
    pi_esn.part_serial_no esn ,
    pi_esn.objid esn_objid ,
    pi_pin.objid pin_objid ,
    pi_pin.x_ext priority ,
    pi_pin.x_red_code ,
    pn_pin.x_redeem_units units ,
    pn_pin.x_redeem_days days ,
    zt.timezone
  FROM sa.x_queue_card_temp c1 ,
    table_site_part sp ,
    sa.x_zip2time_zone zt ,
    table_part_inst pi_esn ,
    table_part_inst pi_pin ,
    table_mod_level ml_pin ,
    table_part_num pn_pin
  WHERE 1                                                                          = 1
  AND sp.rowid                                                                     = c1.row_id
  AND sp.part_status                                                               = 'Active'
  AND NVL(COALESCE(sp.cmmtmnt_end_dt,sp.x_expire_dt) ,TO_DATE('1753-01-01 00:00:00' ,'yyyy-mm-dd hh24:mi:ss')) > TO_DATE('1753-02-01 00:00:00' ,'yyyy-mm-dd hh24:mi:ss')
  AND NVL(COALESCE(sp.cmmtmnt_end_dt,sp.x_expire_dt) ,TO_DATE('1753-01-01 00:00:00' ,'yyyy-mm-dd hh24:mi:ss')) < TRUNC(SYSDATE) + 1
  AND sp.x_min not like 'T%'                    -- Added by Rahul for CR32144 to get acive ESNs on Jul012015
  AND zt.zip(+)                                                                    = sp.x_zipcode
  AND 1                                                                            =
    CASE
      WHEN timezone = 'EST'
      THEN 1
      WHEN timezone = 'CST'
      AND SYSDATE  >= TRUNC(SYSDATE) + 1 / 24
      THEN 1
      WHEN timezone = 'MTZ'
      AND SYSDATE  >= TRUNC(SYSDATE) + 2 / 24
      THEN 1
      WHEN timezone = 'PST'
      AND SYSDATE  >= TRUNC(SYSDATE) + 3 / 24
      THEN 1
      WHEN SYSDATE >= TRUNC(SYSDATE) + 4 / 24
      THEN 1
      ELSE 0
    END
  AND pi_esn.part_serial_no        = sp.x_service_id
  AND pi_esn.x_domain              = 'PHONES'
  AND pi_esn.x_part_inst_status || '' = '52'    -- Added by Rahul for CR32144 to get acive ESNs on Jun302015
  AND pi_pin.part_to_esn2part_inst = pi_esn.objid
  AND pi_pin.x_part_inst_status
    || '' = '400'
  AND pi_pin.x_domain
    || ''          = 'REDEMPTION CARDS'
  AND ml_pin.objid = pi_pin.n_part_inst2part_mod
  AND pn_pin.objid = ml_pin.part_info2part_num
  AND pn_pin.part_num2bus_org IN ( SELECT TO_NUMBER(x_param_value) FROM sa.table_x_parameters WHERE x_param_name = 'QUEUE_CARD_BRANDS' )
  AND ROWNUM       < 10100
  ) WHERE 1        = 1 AND rnk = 1
  AND ROWNUM < 10001;
  --
  p_err_num    := 0;
  p_err_string := 'Successful.';
  --
END sp_get_queue_all_esn;
-- CR16143 End KACOSTA 05/04/2011
-----------------------------------------------------------------------------
PROCEDURE sp_redeem_card(
    p_esn           IN VARCHAR2 ,
    p_red_card      IN VARCHAR2 ,
    p_source_system IN VARCHAR2 , -- WAP Redemption 12/29/2010
    p_call_trans_objid OUT NUMBER ,
    p_err_num OUT NUMBER ,
    p_err_string OUT VARCHAR2 )
IS
BEGIN
sp_redeem_card(p_esn, p_red_card, p_source_system, null, p_call_trans_objid, p_err_num, p_err_string);
END sp_redeem_card;

--CR#38582 - Added overloaded procedure to accept the call trans objid
PROCEDURE sp_redeem_card(
    p_esn           IN VARCHAR2 ,
    p_red_card      IN VARCHAR2 ,
    p_source_system IN VARCHAR2 , -- WAP Redemption 12/29/2010
    p_i_call_trans_objid IN NUMBER ,
    p_call_trans_objid OUT NUMBER ,
    p_err_num OUT NUMBER ,
    p_err_string OUT VARCHAR2 )
IS
  l_sourcesystem    VARCHAR2(50);
  p_annual_plan     NUMBER;
  p_total_units     NUMBER;
  p_redeem_days     NUMBER;
  p_errorcode       VARCHAR2(200);
  p_errormessage    VARCHAR2(200);
  p_conversion_rate NUMBER;
  p_action_type     VARCHAR2(10);
  p_reason          VARCHAR2(30);
  p_calltranobj     NUMBER;
  p_err_code        VARCHAR2(200);
  p_err_msg         VARCHAR2(200);
  l_red_code table_part_inst.x_red_code%TYPE;
  l_site_part_objid NUMBER;
  v_status          VARCHAR2(30) := 'Pending' ; -- icanavan VASCR21443 CR22634
  l_ild_addon_flag  VARCHAR2(1) := 'N';
  CURSOR cu_esn_dtl
  IS
    SELECT pi.objid esn_objid ,
      pi.part_serial_no ,
      NULL x_sourcesystem ,
      NULL x_reason ,
      pn.x_ota_allowed ,
      pi.x_part_inst_status ,
      bo.org_id brand_name ,
      DECODE(NVL(
      (SELECT pcv.x_param_value
      FROM table_part_class pc ,
        table_x_part_class_values pcv ,
        table_x_part_class_params pcp
      WHERE pc.objid           = pn.part_num2part_class
      AND pcv.value2part_class = pc.objid
      AND pcp.objid            = pcv.value2class_param
      AND pcp.x_param_name     = 'NON_PPE'
      ) ,'0') ,'1' ,'N' ,'Y') isota
    FROM table_part_inst pi ,
      table_mod_level ml ,
      table_part_num pn ,
      table_bus_org bo
    WHERE ml.objid        = pi.n_part_inst2part_mod
    AND pn.objid          = ml.part_info2part_num
    AND bo.objid          = pn.part_num2bus_org
    AND pi.part_serial_no = p_esn;
    rec_esn_dtl cu_esn_dtl%ROWTYPE;
    -- icanavan VASCR21443 CR22634
    CURSOR isVAS
    IS
      SELECT 'x'
      FROM table_part_inst pi,
        table_mod_level ml,
        table_part_num pn,
        table_part_class pc,
        vas_programs_view pv
      WHERE pi.n_part_inst2part_mod = ml.objid
      AND PI.X_DOMAIN               = 'REDEMPTION CARDS'
      AND pi.x_part_inst_status
        || ''                  IN ('42','40') --CR22883
      AND ml.part_info2part_num = pn.objid
      AND pn.domain             = 'REDEMPTION CARDS'
      AND pn.part_num2part_class=pc.objid
      AND pc.name               =pv.vas_card_class
      AND x_red_code            = p_red_card ;
    isVAS_r isVAS%ROWTYPE ;
  BEGIN
    dbms_output.put_line('sp_redeem_card 1');
    OPEN cu_esn_dtl;
    FETCH cu_esn_dtl INTO rec_esn_dtl;
    IF cu_esn_dtl%ROWCOUNT = 0 THEN
      CLOSE cu_esn_dtl;
      p_err_num    := '437';
      p_err_string := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
      GOTO procedure_end;
    END IF;
    CLOSE cu_esn_dtl;
    -- icanavan VASCR21443 CR22634
    OPEN isVAS ;
    FETCH isVAS INTO isVAS_r ;
    IF isVAS%ROWCOUNT > 0 THEN
      v_status          := 'Completed' ;
      l_ild_addon_flag  := 'Y' ;
    END IF ;
    CLOSE isVAS ;
    -- call tran attachment with redemtion card
    dbms_output.put_line('call trans attachment with red card : ' || p_esn || ' - red card - ' || p_red_card);
    convert_bo_to_sql_pkg.preprocess_redem_cards(p_esn --IN p_esn
    ,p_red_card                                        --IN p_cards
    ,rec_esn_dtl.isota                                 --IN P_ISOTA,
    ,p_annual_plan ,p_total_units ,p_redeem_days ,p_errorcode ,p_errormessage ,p_conversion_rate);
    IF TO_NUMBER(p_errorcode) <> 0 THEN
      p_err_num               := TO_NUMBER(p_errorcode);
      p_err_string            := 'PREPROCESS_REDEM_CARDS' || p_errormessage;
      GOTO procedure_end;
    END IF;
    -- call trans creation.
    dbms_output.put_line('sp_create_call_trans : ' || p_esn || ' - red card - ' || p_red_card || ' - P_ERRORCODE - ' || p_errorcode || ' - P_ERRORMESSAGE - ' || p_errormessage);
    dbms_output.put_line('rec_esn_dtl.x_part_inst_status : '||rec_esn_dtl.x_part_inst_status);
    IF rec_esn_dtl.x_part_inst_status IN ('51' ,'54') THEN
      p_action_type := '3';
      p_reason      := 'ReActivation';
    ELSIF rec_esn_dtl.x_part_inst_status IN ('50' ,'150') THEN
      p_action_type := '1';
      p_reason      := 'Activation';
      --cwl 3/9/13
    ELSIF rec_esn_dtl.x_part_inst_status IN ('151') THEN
      p_action_type     := '6';
      p_reason          := 'Redemption';
      l_site_part_objid := seq('site_part');
      INSERT
      INTO table_site_part
        (
          objid,
          x_service_id,
          x_min,
          part_status,
          install_date
        )
        VALUES
        (
          l_site_part_objid,
          p_esn,
          p_esn,
          'Obsolete',
          sysdate
        );
      UPDATE table_part_inst
      SET x_part_inst2site_part = l_site_part_objid
      WHERE part_serial_no      = p_esn;
      --cwl 3/9/13
    ELSIF rec_esn_dtl.x_part_inst_status IN ('52') THEN
      p_action_type := '6';
      p_reason      := CASE WHEN l_ild_addon_flag = 'Y' THEN 'ADD_ON' ELSE  'Redemption' END;
    END IF;
    -- WAP Redemption 12/29/2010
    --CR#38582 - If call trans objid received in input parameter then return the same otherwise create new one
    IF p_i_call_trans_objid is null THEN
      convert_bo_to_sql_pkg.sp_create_call_trans(p_esn --ip_esn
      ,p_action_type                                   --ip_action_type
      ,NVL(p_source_system ,'WEB')                     --IP_SOURCESYSTEM
      ,rec_esn_dtl.brand_name                          --IP_BRAND_NAME,
      ,p_reason                                        --ip_reason
      ,v_status                                        --'Pending' VAS CR21443 CR22634        --IP_RESULT
      ,NULL                                            --ip_ota_req_type,
      ,NULL                                            --IP_OTA_TYPE,
      ,p_total_units                                   --ip_total_units
      ,p_call_trans_objid ,p_err_code ,p_err_msg);
      IF TO_NUMBER(p_err_code) <> 0 THEN
        p_err_num              := TO_NUMBER(p_err_code);
        p_err_string           := 'SP_CREATE_CALL_TRANs ' || p_err_msg;
        GOTO procedure_end;
      END IF;
    ELSE
      p_call_trans_objid := p_i_call_trans_objid;
    END IF;

    --cwl 3/9/13
    IF rec_esn_dtl.x_part_inst_status IN ('151') THEN
      UPDATE table_x_call_trans
      SET x_reason = 'BYOP REGISTER' ,
        x_result   = 'Completed'
      WHERE objid  = p_call_trans_objid;
    END IF;
    --cwl 3/9/13
    -- call tran attachment with redemtion card
    dbms_output.put_line('call trans attachment with red card : ' || p_esn || ' - red card - ' || p_red_card || ' - P_ERR_CODE - ' || p_err_code || ' - P_ERR_MSG - ' || p_err_msg);
    UPDATE table_x_red_card_temp
    SET temp_red_card2x_call_trans = p_call_trans_objid
    WHERE x_red_code               = p_red_card;
    -- clear red card. (This will create new entry in table_x_red_card, remove row from temp table for perticular esn.)
    dbms_output.put_line('clear red card : ' || p_esn || ' - red card - ' || p_red_card || ' - P_CALL_TRANS_OBJID :- ' || p_call_trans_objid);
    convert_bo_to_sql_pkg.clearredcards_sql(p_call_trans_objid --P_CALL_TRANS_OBJID
    ,rec_esn_dtl.esn_objid                                     --P_ESN_OBJID
    ,1);                                                       --P_BLNBOOLSTATUS

    -- CR44787
    -- update mtm_bogo_bi_info for missing call_trans_objid
    UPDATE sa.mtm_bogo_bi_info
    SET call_trans_objid     = p_call_trans_objid,
        transaction_dt       = SYSDATE
    WHERE original_red_code  = p_red_card;

    p_err_num    := 0;
    p_err_string := 'Successful.';
    <<procedure_end>>
    NULL;
    -----------------------------------------------------------------------------
  END sp_redeem_card;
PROCEDURE sp_add_queue(
    p_esn               IN VARCHAR2 ,
    p_red_card          IN VARCHAR2 ,
    p_source_system     IN VARCHAR2 ,             -- WAP Redemption 12/29/2010
    p_create_call_trans IN VARCHAR2 DEFAULT 'Y' , -- CR15847 St Stacking
    p_call_trans_objid  IN OUT NUMBER ,           -- CR15847 ST Stacking
    p_err_num OUT NUMBER ,
    p_err_string OUT VARCHAR2 )
IS
  l_sourcesystem    VARCHAR2(50);
  p_annual_plan     NUMBER;
  p_total_units     NUMBER;
  p_redeem_days     NUMBER;
  p_errorcode       VARCHAR2(200);
  p_errormessage    VARCHAR2(200);
  p_conversion_rate NUMBER;
  p_action_type     VARCHAR2(10);
  p_reason          VARCHAR2(30);
  p_calltranobj     NUMBER;
  p_err_code        VARCHAR2(200);
  p_err_msg         VARCHAR2(200);
  l_red_code table_part_inst.x_red_code%TYPE;
  op_call_trans_objid NUMBER;
  CURSOR cu_pin_dtl
  IS
    SELECT pi.objid pin_objid ,
      part_to_esn2part_inst ,
      x_ext ,
      bo.objid bo_objid ,
      pi.x_part_inst_status ,
      pn.x_redeem_units
    FROM table_part_inst pi ,
      table_mod_level ml ,
      table_part_num pn ,
      table_bus_org bo
    WHERE ml.objid    = pi.n_part_inst2part_mod
    AND pn.objid      = ML.PART_INFO2PART_NUM
    AND BO.OBJID      = PN.PART_NUM2BUS_ORG
    AND pi.x_red_code = P_RED_CARD;
  rec_pin_dtl cu_pin_dtl%rowtype;
  -- CR20451 | CR20854: Add TELCEL Brand   ADDED ORG_FLOW TO THIS CURSOR
  CURSOR CU_ESN_DTL
  IS
    SELECT pi.objid esn_objid ,
      x_ext ,
      bo.objid bo_objid ,
      pi.x_part_inst_status ,
      bo.org_id brand_name ,
      BO.ORG_FLOW,
      pi.x_part_inst2site_part -- CR14786
    FROM table_part_inst pi ,
      table_mod_level ml ,
      table_part_num pn ,
      table_bus_org bo
    WHERE ml.objid        = pi.n_part_inst2part_mod
    AND pn.objid          = ml.part_info2part_num
    AND bo.objid          = pn.part_num2bus_org
    AND pi.part_serial_no = p_esn;
  rec_esn_dtl cu_esn_dtl%ROWTYPE;
  -- CR14786  STARTS
  CURSOR cu_sp_dtl(c_objid NUMBER)
  IS
    SELECT * FROM table_site_part WHERE objid = c_objid;
  rec_sp_dtl cu_sp_dtl%ROWTYPE;
  -- CR14786  ENDS
  --CR15157 STARTS
  CURSOR cu_is_cc_sch(c_objid NUMBER)
  IS
    SELECT *
    FROM x_service_plan_site_part spsp ,
      table_site_part tsp
    WHERE spsp.table_site_part_id   = tsp.objid
    AND tsp.objid                   = c_objid
    AND spsp.x_new_service_plan_id IS NOT NULL;
  --CR15157 ENDS
  rec_is_cc_sch cu_is_cc_sch%ROWTYPE;
  l_call_tx_exists NUMBER := 0;
BEGIN
  OPEN cu_esn_dtl;
  FETCH cu_esn_dtl INTO rec_esn_dtl;
  IF cu_esn_dtl%ROWCOUNT = 0 THEN
    CLOSE cu_esn_dtl;
    p_err_num    := 437;
    p_err_string := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
    GOTO procedure_end;
  END IF;
  CLOSE cu_esn_dtl;
  -- MEGACARD STARTS -- CR14032
  -- When the customer has pending purchase(queueable cards) and is reactivating,
  -- We should be able to add the pending purchase to the queue and use the card from the queue to reactivate
  -- When purchase is pending ESN will NOT be Active, hence we will do below validation for ST only
  --CR20451 | CR20854: Add TELCEL Brand USING THE ORG_FLOW TO INCLUDE OTHER ORGS
  -- IF REC_ESN_DTL.BRAND_NAME = 'STRAIGHT_TALK' AA
  IF REC_ESN_DTL.ORG_FLOW              = '3' THEN
    IF rec_esn_dtl.x_part_inst_status <> '52' THEN
      p_err_num                       := 442;
      p_err_string                    := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
      GOTO procedure_end;
    END IF;
  END IF;
  -- MEGACARD ENDS    -- CR14032
  OPEN cu_pin_dtl;
  FETCH cu_pin_dtl INTO rec_pin_dtl;
  IF cu_pin_dtl%ROWCOUNT = 0 THEN
    CLOSE cu_pin_dtl;
    p_err_num    := 438;
    p_err_string := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
    GOTO procedure_end;
  END IF;
  CLOSE cu_pin_dtl;
  IF rec_esn_dtl.bo_objid <> rec_pin_dtl.bo_objid THEN
    p_err_num             := 441;
    p_err_string          := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
    GOTO procedure_end;
  END IF;
  IF rec_pin_dtl.part_to_esn2part_inst  IS NOT NULL THEN
    IF rec_pin_dtl.part_to_esn2part_inst = rec_esn_dtl.esn_objid AND rec_pin_dtl.x_part_inst_status = '400' THEN
      p_err_num                         := 440;
      p_err_string                      := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
      GOTO procedure_end;
    ELSIF rec_pin_dtl.part_to_esn2part_inst <> rec_esn_dtl.esn_objid THEN
      p_err_num                             := 439;
      p_err_string                          := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
      GOTO procedure_end;
    END IF;
  END IF;
  --CR15157 STARTS
  -- CR20451 | CR20854: Add TELCEL Brand
  -- IF REC_ESN_DTL.BRAND_NAME = 'STRAIGHT_TALK'   -- MEGACARD  -- CR14032 AA
  IF REC_ESN_DTL.ORG_FLOW = '3' THEN
    OPEN cu_is_cc_sch(rec_esn_dtl.x_part_inst2site_part);
    FETCH cu_is_cc_sch INTO rec_is_cc_sch;
    IF cu_is_cc_sch%FOUND THEN
      --
      CLOSE cu_is_cc_sch;
      p_err_num    := 446;
      p_err_string := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
      GOTO procedure_end;
    END IF;
    CLOSE cu_is_cc_sch;
  END IF;
  --CR15157 WNDS
  -- CR14786  STARTS
  OPEN cu_sp_dtl(rec_esn_dtl.x_part_inst2site_part);
  FETCH cu_sp_dtl INTO rec_sp_dtl;
  IF cu_sp_dtl%ROWCOUNT = 0 THEN
    CLOSE cu_sp_dtl;
    p_err_num    := 445;
    p_err_string := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
    GOTO procedure_end;
  END IF;
  CLOSE cu_sp_dtl;
  -- CR14786  ENDS
  -- RESERVING THE CARD TO ESN
  UPDATE table_part_inst
  SET x_ext = NVL(
    (SELECT MAX(TO_NUMBER(x_ext) + 1)
    FROM table_part_inst
    WHERE part_to_esn2part_inst = rec_esn_dtl.esn_objid
    AND x_domain                = 'REDEMPTION CARDS'
    ) ,1) ,
    part_to_esn2part_inst = rec_esn_dtl.esn_objid ,
    x_part_inst_status    = '400' ,
    status2x_code_table   =
    (SELECT objid FROM table_x_code_table WHERE x_code_number = '400'
    ) ,
    last_trans_time = SYSDATE
  WHERE objid       = rec_pin_dtl.pin_objid;
  -- Start CR15847 PM for ST Stacking project.
  -- CR14786  STARTS
  /*
  SELECT COUNT(1)
  INTO L_CALL_TX_EXISTS
  FROM TABLE_X_CALL_TRANS
  WHERE X_SERVICE_ID = P_ESN
  AND X_MIN = REC_SP_DTL.x_min
  AND X_TRANSACT_DATE = SYSDATE
  AND X_ACTION_TYPE = '401';
  if l_call_tx_exists = 0 then
  */
  IF p_create_call_trans = 'Y' AND p_call_trans_objid IS NULL THEN
    p_action_type       := '401';
    p_reason            := p_red_card;
    -- WAP Redemption 12/29/2010
    convert_bo_to_sql_pkg.sp_create_call_trans(p_esn --ip_esn
    ,p_action_type                                   --ip_action_type
    ,NVL(p_source_system ,'WEB')                     --IP_SOURCESYSTEM
    ,rec_esn_dtl.brand_name                          --IP_BRAND_NAME,
    ,p_reason                                        --ip_reason
    ,'Completed'                                     --IP_RESULT
    ,NULL                                            --ip_ota_req_type,
    ,'402'                                           --IP_OTA_TYPE,      -- CR15847 PM ST Steaking
    ,rec_pin_dtl.x_redeem_units                      --ip_total_units
    ,op_call_trans_objid ,p_err_code ,p_err_msg);
    IF TO_NUMBER(p_err_code) <> 0 THEN
      p_err_num              := TO_NUMBER(p_err_code);
      p_err_string           := 'SP_CREATE_CALL_TRANs ' || p_err_msg;
      GOTO procedure_end;
    END IF;
    p_call_trans_objid     := op_call_trans_objid;
  ELSIF p_create_call_trans = 'Y' AND p_call_trans_objid IS NOT NULL THEN
    UPDATE table_x_call_trans
    SET x_reason = x_reason
      || ','
      || p_red_card
    WHERE objid = p_call_trans_objid;
  END IF;
  --END IF;
  /*
  update TABLE_X_CALL_TRANS
  set    X_REASON     = P_RED_CARD
  where  OBJID        = P_CALL_TRANS_OBJID;
  */
  -- End CR15847 PM for ST Stacking project.
  COMMIT;
  -- CR14786 ENDS
  p_err_num    := 0;
  p_err_string := 'Successful.';
  <<procedure_end>>
  NULL;
END sp_add_queue;
PROCEDURE sp_update_queue_priority(
    p_esn      IN VARCHAR2 ,
    p_red_card IN VARCHAR2 ,
    p_err_num OUT NUMBER ,
    p_err_string OUT VARCHAR2 )
IS
  CURSOR cu_pin_dtl
  IS
    SELECT pi.objid pin_objid ,
      part_to_esn2part_inst ,
      x_ext ,
      bo.objid bo_objid
    FROM table_part_inst pi ,
      table_mod_level ml ,
      table_part_num pn ,
      table_bus_org bo
    WHERE ml.objid    = pi.n_part_inst2part_mod
    AND pn.objid      = ml.part_info2part_num
    AND bo.objid      = pn.part_num2bus_org
    AND pi.x_red_code = p_red_card;
  rec_pin_dtl cu_pin_dtl%ROWTYPE;
  CURSOR cu_esn_dtl
  IS
    SELECT pi.objid esn_objid ,
      x_ext ,
      bo.objid bo_objid ,
      pi.x_part_inst_status
    FROM table_part_inst pi ,
      table_mod_level ml ,
      table_part_num pn ,
      table_bus_org bo
    WHERE ml.objid        = pi.n_part_inst2part_mod
    AND pn.objid          = ml.part_info2part_num
    AND bo.objid          = pn.part_num2bus_org
    AND pi.part_serial_no = p_esn;
  rec_esn_dtl cu_esn_dtl%ROWTYPE;
BEGIN
  OPEN cu_esn_dtl;
  FETCH cu_esn_dtl INTO rec_esn_dtl;
  IF cu_esn_dtl%ROWCOUNT = 0 THEN
    CLOSE cu_esn_dtl;
    p_err_num    := 437;
    p_err_string := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
    GOTO procedure_end;
  END IF;
  CLOSE cu_esn_dtl;
  IF rec_esn_dtl.x_part_inst_status <> '52' THEN
    p_err_num                       := 442;
    p_err_string                    := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
    GOTO procedure_end;
  END IF;
  OPEN cu_pin_dtl;
  FETCH cu_pin_dtl INTO rec_pin_dtl;
  IF cu_pin_dtl%ROWCOUNT = 0 THEN
    CLOSE cu_pin_dtl;
    p_err_num    := 438;
    p_err_string := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
    GOTO procedure_end;
  END IF;
  CLOSE cu_pin_dtl;
  IF rec_esn_dtl.bo_objid <> rec_pin_dtl.bo_objid THEN
    p_err_num             := 441;
    p_err_string          := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
    GOTO procedure_end;
  END IF;
  IF rec_pin_dtl.part_to_esn2part_inst           IS NOT NULL THEN
    IF NVL(rec_pin_dtl.part_to_esn2part_inst ,0) <> rec_esn_dtl.esn_objid THEN
      p_err_num                                  := 439;
      p_err_string                               := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
      GOTO procedure_end;
    END IF;
  END IF;
  UPDATE table_part_inst
  SET x_ext                   = DECODE(TO_NUMBER(x_ext) ,TO_NUMBER(rec_pin_dtl.x_ext) ,1 ,TO_NUMBER(x_ext) + 1)
  WHERE part_to_esn2part_inst = rec_esn_dtl.esn_objid
  AND x_domain                = 'REDEMPTION CARDS'
  AND TO_NUMBER(x_ext)       <= TO_NUMBER(rec_pin_dtl.x_ext);
  COMMIT;
  p_err_num    := 0;
  p_err_string := 'Successful.';
  <<procedure_end>>
  NULL;
END sp_update_queue_priority;
PROCEDURE sp_trnsfr_queue_to_active_esn(
    p_err_num OUT NUMBER ,
    p_err_string OUT VARCHAR2 )
IS
  CURSOR c1
  IS
    SELECT picard.objid pin_objid ,
      piesn.objid esn_objid ,
      picard.x_red_code old_queued_pins -- CR17182 added red code
    FROM table_part_inst picard ,
      table_part_inst piesn
    WHERE 1                          = 1
    AND picard.x_part_inst_status    = '400'
    AND picard.part_to_esn2part_inst = piesn.objid
    AND piesn.x_part_inst_status
      || ''                                 IN ('54' ,'51')
    AND piesn.warr_end_date > TRUNC(SYSDATE) - 20; -- CR17182 Skuthadi to handle port scenarios where the activation could take more than 1-2 days
  --AND piesn.warr_end_date > SYSDATE - 1; -- CR17182 Skuthadi to handle port scenarios where the activation could take more than 1-2 days
  r1 c1%ROWTYPE;
  CURSOR c2(p_objid NUMBER)
  IS
    SELECT sitepartobjid ,
      part_serial_no ,
      x_service_id ,
      x_min
    FROM
      (SELECT DISTINCT sp.objid sitepartobjid ,
        pi.part_serial_no ,
        sp.x_service_id ,
        sp.x_min
      FROM table_part_inst pi ,
        table_site_part sp
      WHERE 1                      = 1
      AND pi.x_part_inst2site_part = sp.objid
      AND pi.objid                 = p_objid
      AND UPPER(sp.part_status)    = 'INACTIVE'
      ) tab
  ORDER BY tab.sitepartobjid DESC;
  r2 c2%ROWTYPE;
  CURSOR other_esns_same_min_curs ( c_esn IN VARCHAR2 ,c_min IN VARCHAR2 )
  IS
    SELECT pi.objid ,
      pi.part_serial_no
    FROM table_site_part sp ,
      table_part_inst pi
    WHERE sp.x_service_id       != c_esn
    AND sp.x_min                 = c_min
    AND sp.part_status           = 'Active'
    AND pi.x_part_inst2site_part = sp.objid
    AND pi.x_domain              = 'PHONES';
  other_esns_same_min_rec other_esns_same_min_curs%ROWTYPE;
  CURSOR cmp_bus_org_curs1(c_esn IN VARCHAR2)
  IS
    SELECT pi.part_serial_no ,
      bo.org_id
    FROM table_part_inst pi ,
      table_part_num pn ,
      table_mod_level ml ,
      table_bus_org bo
    WHERE pi.part_serial_no     = c_esn
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid
    AND pn.part_num2bus_org     = bo.objid;
  cmp_bus_org_rec1 cmp_bus_org_curs1%ROWTYPE;
  CURSOR cmp_bus_org_curs2(c_esn IN VARCHAR2)
  IS
    SELECT pi.part_serial_no ,
      bo.org_id ,
      pc.objid newesnpcobjid -- E5_HANDSETS added part class table
    FROM table_part_inst pi ,
      table_part_num pn ,
      table_mod_level ml ,
      table_bus_org bo ,
      table_part_class pc
    WHERE pi.part_serial_no     = c_esn
    AND pi.n_part_inst2part_mod = ml.objid
    AND ml.part_info2part_num   = pn.objid
    AND pn.part_num2bus_org     = bo.objid
    AND pn.part_num2part_class  = pc.objid;
  cmp_bus_org_rec2 cmp_bus_org_curs2%ROWTYPE;
  v_count PLS_INTEGER := 0;
  -- E5_HANDSETS Starts
  -- L_NEW_ESN_IS_NOKIA            NUMBER := 0;
  -- L_OLD_ESN_IS_ALLYOUNEED       NUMBER := 0;
  CURSOR is_phn_plan_comptble_curs ( c_cls_objid IN NUMBER ,c_red_code IN VARCHAR2 )
  IS
    SELECT mtm.* -- CR17182 new cursor query checks for OLD ESNs PINS to NEW ESN compatability
    FROM mtm_partclass_x_spf_value_def mtm
    WHERE 1               = 1
    AND mtm.part_class_id = c_cls_objid
    AND EXISTS
      (SELECT 1
      FROM mtm_partclass_x_spf_value_def mtm2 ,
        table_part_class pc ,
        table_part_num pn ,
        table_mod_level ml ,
        table_part_inst pi
      WHERE 1                       = 1
      AND pi.x_red_code             = c_red_code
      AND pn.domain                 = 'REDEMPTION CARDS'
      AND pi.n_part_inst2part_mod   = ml.objid
      AND ml.part_info2part_num     = pn.objid
      AND pn.part_num2part_class    = pc.objid
      AND mtm2.part_class_id        = pc.objid
      AND mtm.spfeaturevalue_def_id = mtm2.spfeaturevalue_def_id
      );
  /* -- old query checks if OLD ESN/ NEW ESN compataible
  SELECT MTM.*
  FROM MTM_PARTCLASS_X_SPF_VALUE_DEF MTM
  WHERE 1=1
  AND MTM.PART_CLASS_ID = c_cls_objid
  AND EXISTS (SELECT 1
  FROM X_SERVICE_PLAN XSP,
  X_SERVICE_PLAN_FEATURE SPF,
  X_SERVICEPLANFEATUREVALUE_DEF SPDEFVAL1,
  X_SERVICEPLANFEATURE_VALUE SPFV,
  X_SERVICEPLANFEATUREVALUE_DEF SPDEF,
  X_SERVICE_PLAN_SITE_PART SPSP
  WHERE SPSP.TABLE_SITE_PART_ID = c_sp_objid
  AND SPF.SP_FEATURE2SERVICE_PLAN = XSP.OBJID+0
  AND SPDEF.OBJID = SPDEFVAL1.PARENT_OBJID + 0
  AND SPDEF.VALUE_NAME ||'' = 'SUPPORTED PART CLASS'
  -- AND SPDEF.PARENT_OBJID IS NULL -- CR17182 to handle NULLS
  AND NVL(SPDEF.PARENT_OBJID,0) = 0 -- CR17182 parent objid is 0
  AND SPFV.SPF_VALUE2SPF = SPF.OBJID + 0
  AND SPDEFVAL1.OBJID = SPFV.VALUE_REF + 0
  AND XSP.OBJID = SPSP.X_SERVICE_PLAN_ID + 0
  AND MTM.SPFEATUREVALUE_DEF_ID = SPDEFVAL1.OBJID);
  */
  is_phn_plan_comptble_rec is_phn_plan_comptble_curs%ROWTYPE;
  -- E5_HANDSETS Ends
BEGIN
  FOR r1 IN c1
  LOOP
    FOR r2 IN c2(r1.esn_objid)
    LOOP
      OPEN other_esns_same_min_curs(r2.x_service_id ,r2.x_min); -- checkign for active ESN with this min
      FETCH other_esns_same_min_curs INTO other_esns_same_min_rec;
      IF other_esns_same_min_curs%FOUND THEN
        --is active with some other esn
        -- Check Bus ORG
        OPEN cmp_bus_org_curs1(r2.part_serial_no); -- Bus Org of Old Inactive ESNS
        FETCH cmp_bus_org_curs1 INTO cmp_bus_org_rec1;
        OPEN cmp_bus_org_curs2(other_esns_same_min_rec.part_serial_no); -- Bus Org of New Active ESNS with SAME min
        FETCH cmp_bus_org_curs2 INTO cmp_bus_org_rec2;
        IF cmp_bus_org_rec1.org_id = cmp_bus_org_rec2.org_id THEN
          -- E5_HANDSETS Starts
          /*
          L_NEW_ESN_IS_NOKIA := 0;
          L_OLD_ESN_IS_ALLYOUNEED := 0;
          -- to chek if new ESN IS NOKIA
          SELECT COUNT(1)
          INTO L_NEW_ESN_IS_NOKIA
          FROM TABLE_PART_CLASS PC, TABLE_PART_NUM PN,
          table_part_inst pi, table_mod_level ml
          WHERE pn.part_num2part_class = pc.objid
          AND PI.N_PART_INST2PART_MOD = ML.OBJID
          AND ML.PART_INFO2PART_NUM = PN.OBJID
          AND PC.NAME IN ('STNKE71G','STNK6790G')
          AND PI.PART_SERIAL_NO = other_esns_same_min_rec.part_serial_no;
          -- to check if OLD ESN HAD ALL YOU NEED PLAN
          SELECT COUNT(1)
          INTO L_OLD_ESN_IS_ALLYOUNEED
          FROM x_service_plan_site_part spsp, x_service_plan sp
          WHERE SP.OBJID = SPSP.X_SERVICE_PLAN_ID
          AND SP.DESCRIPTION = 'All You Need'
          AND SPSP.TABLE_SITE_PART_ID = r2.sitepartobjid;
          */
          OPEN is_phn_plan_comptble_curs(cmp_bus_org_rec2.newesnpcobjid ,r1.old_queued_pins); -- CR17182 added old_queued_pins
          FETCH is_phn_plan_comptble_curs INTO is_phn_plan_comptble_rec;
          IF is_phn_plan_comptble_curs%NOTFOUND THEN
            CLOSE is_phn_plan_comptble_curs;
            --P_ERR_NUM     := 447;
            --P_ERR_STRING  := SA.GET_CODE_FUN ('QUEUE_CARD_PKG', P_ERR_NUM, 'ENGLISH');
            NULL; -- Skip and check for next pin if available
            -- GOTO PROCEDURE_END; CR17182
            -- TOSS_UTIL_PKG.INSERT_ERROR_TAB_PROC ('TRANSFER QUEUED CARDS ', OTHER_ESNS_SAME_MIN_REC.PART_SERIAL_NO,
            --                                      'QUEUE_CARD_PKG.SP_TRNSFR_QUEUE_TO_ACTIVE_ESN',
            --                                      'This New ESN Part Class and the Service Plan of Old ESN Queued Cards (to be transferred) are not Compatible '
            --                                     );
            -- ESN IS NOKIA AND OLD ESN ALL YOU NEED THEN SKIP TRANSFER OF CARDS
            -- DBMS_OUTPUT.PUT_LINE(' THE ESN IS A NOKIA PHONE AND THE OLD ESN WAS HAVING ALL YOU NEED PLAN ');
            -- DBMS_OUTPUT.PUT_LINE(' NOKIA TAKES ONLY UNLIMITED ');
          ELSE
            -- PIN and NEW ESN is compatiable
            -- Transfer all the reserved queue cards for the OLD esn to NEW ESN
            UPDATE table_part_inst
            SET part_to_esn2part_inst = other_esns_same_min_rec.objid , -- assign new esn objid
              last_trans_time         = SYSDATE ,                       -- E5_HANDSETS
              x_ext                   = NVL(
              (SELECT MAX(TO_NUMBER(x_ext)) + 1
              FROM table_part_inst
              WHERE x_domain            = 'REDEMPTION CARDS'
              AND x_part_inst_status    = '400'
              AND part_to_esn2part_inst = other_esns_same_min_rec.objid
              ) ,1)                    -- CR17182 ex: new esn has 1,2,3 cards so the old esns after transfer will become 4,5...
            WHERE objid            = r1.pin_objid -- objid of all the cards with old esn
            AND x_part_inst_status = '400'
            AND x_domain           = 'REDEMPTION CARDS'; --        -- E5_HANDSETS
            v_count               := v_count + SQL%ROWCOUNT;
            COMMIT;
          END IF;
          IF is_phn_plan_comptble_curs%ISOPEN THEN
            CLOSE is_phn_plan_comptble_curs;
          END IF;
          -- E5_HANDSETS Ends
        END IF;
        COMMIT;
        CLOSE cmp_bus_org_curs2;
        CLOSE cmp_bus_org_curs1;
      END IF;
      CLOSE other_esns_same_min_curs;
    END LOOP;
  END LOOP;
  COMMIT;
  p_err_num    := 0;
  p_err_string := 'Successful! Number of Queued Cards Transferred - ' || v_count;
  -- E5_HANDSETS Starts
  -- CR17182
  --<<PROCEDURE_END>>
  --   NULL;
  -- E5_HANDSETS Ends
EXCEPTION
WHEN OTHERS THEN
  -- '443'- 'Error Occured While Transfering the Reserved Queued Cards from INACTIVE ESNS to ACTIVE ESNS'
  dbms_output.put_line('Error ' || TO_CHAR(SQLCODE) || ': ' || SQLERRM);
  p_err_num    := 443;
  p_err_string := SUBSTR(SQLERRM ,1 ,100);
END sp_trnsfr_queue_to_active_esn;
--
FUNCTION sf_move_queue_oldesn_to_newesn(
    ip_old_esn IN VARCHAR2 ,
    ip_new_esn IN VARCHAR2 ,
    p_err_num OUT NUMBER ,
    p_err_string OUT VARCHAR2 )
  RETURN NUMBER
IS
  v_new_esn_objid table_part_inst.objid%TYPE;
  v_old_esn_objid table_part_inst.objid%TYPE;
  v_sql         VARCHAR2(32767) := '';
  op_move_count NUMBER          := 0;
  -- Start CR13249 GSM Upgrade project PM 07/13/2011
  CURSOR cur_old_esn_queue
  IS
    SELECT picard.objid pin_objid ,
      piesn.objid esn_objid ,
      pc.objid pin_pc_objid
    FROM table_part_inst picard ,
      table_part_inst piesn ,
      table_mod_level ml ,
      table_part_num pn ,
      table_part_class pc
    WHERE 1                          = 1
    AND picard.x_part_inst_status    = '400'
    AND picard.part_to_esn2part_inst = piesn.objid
    AND piesn.part_serial_no         = ip_old_esn
    AND ml.objid                     = picard.n_part_inst2part_mod
    AND pn.objid                     = ml.part_info2part_num
    AND pc.objid                     = pn.part_num2part_class;
  CURSOR cur_phone_detail(c_esn_objid NUMBER)
  IS
    SELECT pc.objid partclass_objid ,
      bo.org_id
    FROM table_part_inst pi ,
      table_mod_level ml ,
      table_part_num pn ,
      table_bus_org bo ,
      table_part_class pc
    WHERE 1      = 1
    AND pi.objid = c_esn_objid
    AND ml.objid = pi.n_part_inst2part_mod
    AND pn.objid = ml.part_info2part_num
    AND bo.objid = pn.part_num2bus_org
    AND pc.objid = pn.part_num2part_class;
  rec_old_phone_dtl cur_phone_detail%ROWTYPE;
  rec_new_phone_dtl cur_phone_detail%ROWTYPE;
  CURSOR cur_card_phone_sp_comptble ( c_new_phn_pc_objid NUMBER ,c_old_pin_pc_objid NUMBER )
  IS
    SELECT * --count(1)
    FROM mtm_partclass_x_spf_value_def mtm
    WHERE 1                        = 1
    AND mtm.part_class_id          = c_new_phn_pc_objid
    AND mtm.spfeaturevalue_def_id IN
      (SELECT def.objid
      FROM mtm_partclass_x_spf_value_def mtm ,
        table_part_class pc ,
        x_serviceplanfeaturevalue_def def
      WHERE mtm.part_class_id = pc.objid
      AND def.objid           = mtm.spfeaturevalue_def_id
      AND pc.objid           IN c_old_pin_pc_objid
      );
  rec_card_phone_sp_comptble cur_card_phone_sp_comptble%ROWTYPE;
  -- End CR13249 GSM Upgrade project PM 07/13/2011
BEGIN
  -- Mainly used in UPGRADE Flow in Java.
  -- 1) TARGET ESN CC SCHEDULED CHECK?
  -- 2) CREATE CALL TRANS FOR NEW ESN?
  -- 3) NO CHECK FOR STATUS
  -- 4) NO CHECK FOR BUS ORG
  -- 5) TRANSFER ONLY QUEUED(400) cards?
  v_sql := 'SELECT objid';
  v_sql := v_sql || ' FROM  table_part_inst ';
  v_sql := v_sql || ' WHERE part_serial_no = :a ';
  v_sql := v_sql || ' AND x_domain = ''PHONES'' ';
  EXECUTE IMMEDIATE v_sql INTO v_old_esn_objid USING ip_old_esn;
  EXECUTE IMMEDIATE v_sql INTO v_new_esn_objid USING ip_new_esn;
  -- Start CR13249 GSM Upgrade project PM 07/13/2011
  p_err_num    := 0;
  p_err_string := 'Success';
  OPEN cur_phone_detail(v_old_esn_objid);
  FETCH cur_phone_detail INTO rec_old_phone_dtl;
  CLOSE cur_phone_detail;
  OPEN cur_phone_detail(v_new_esn_objid);
  FETCH cur_phone_detail INTO rec_new_phone_dtl;
  CLOSE cur_phone_detail;
  IF rec_old_phone_dtl.org_id <> rec_new_phone_dtl.org_id THEN
    p_err_num                 := 448;
    p_err_string              := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
    RETURN 0;
  END IF;
  FOR rec_old_esn_queue IN cur_old_esn_queue
  LOOP
    OPEN cur_card_phone_sp_comptble(rec_new_phone_dtl.partclass_objid ,rec_old_esn_queue.pin_pc_objid);
    FETCH cur_card_phone_sp_comptble INTO rec_card_phone_sp_comptble;
    IF cur_card_phone_sp_comptble%NOTFOUND THEN
      p_err_num    := 447;
      p_err_string := sa.get_code_fun('QUEUE_CARD_PKG' ,p_err_num ,'ENGLISH');
      CLOSE cur_card_phone_sp_comptble;
      --return 0;
    ELSE
      UPDATE table_part_inst
      SET part_to_esn2part_inst = v_new_esn_objid ,
        last_trans_time         = SYSDATE ,
        x_ext                   = NVL(
        (SELECT MAX(TO_NUMBER(x_ext))
        FROM table_part_inst
        WHERE part_to_esn2part_inst = v_new_esn_objid
        AND x_domain                = 'REDEMPTION CARDS'
        AND x_part_inst_status      = '400'
        ) ,0) + 1
      WHERE part_to_esn2part_inst = v_old_esn_objid
      AND x_domain                = 'REDEMPTION CARDS'
      AND x_part_inst_status      = '400'
      AND objid                   = rec_old_esn_queue.pin_objid;
      op_move_count              := op_move_count + 1;
      CLOSE cur_card_phone_sp_comptble;
    END IF;
  END LOOP;
  -- End CR13249 GSM Upgrade project PM 07/13/2011
  COMMIT;
  RETURN op_move_count;
EXCEPTION
WHEN OTHERS THEN
  ROLLBACK;
  RETURN op_move_count;
END SF_MOVE_QUEUE_OLDESN_TO_NEWESN;
--------------------for CR22623-----------by Chaitanya
PROCEDURE queuepintoesn(
    p_esn_list      IN typ_q_esn_pin_tbl,
    p_source_system IN VARCHAR2,
    out_message OUT out_tbl)
IS
  i_count PLS_INTEGER;
  l_call_trans          NUMBER;
  l_err_num             NUMBER;
  l_err_string          VARCHAR2(4000);
  v_business_error_excp EXCEPTION;
BEGIN
  IF (p_esn_list.count = 0) THEN
    l_err_num         := 459;
    l_err_string      := sa.get_code_fun('ESNLIST', l_err_num, 'ENGLISH');
    RAISE v_business_error_excp;
  END IF;
  FOR i_count IN p_esn_list.FIRST..p_esn_list.LAST
  LOOP
    BEGIN
      l_call_trans := p_esn_list(i_count).call_trans_objid;
      queue_card_pkg.sp_add_queue(p_esn_list(i_count).esn, p_esn_list(i_count).pin, p_source_system, p_esn_list(i_count).create_call_trans, l_call_trans, l_err_num, l_err_string);
      out_message(i_count).call_trans_objid := l_call_trans;
      out_message(i_count).err_num          := l_err_num;
      out_message(i_count).err_string       := l_err_string;
    END;
  END LOOP;
  l_err_num    := 0;
  l_err_string := 'SUCCESS';
EXCEPTION
WHEN v_business_error_excp THEN
  --
  l_err_num    := l_err_num;
  l_err_string := l_err_string;
  --
WHEN OTHERS THEN
  --
  l_err_num    := SQLCODE;
  L_ERR_STRING := SQLERRM;
  ota_util_pkg.err_log(p_action => 'queuePintoEsn', p_error_date => SYSDATE, p_key => ('ESN'||'pin'), p_program_name => 'temp_queue_card_pkg.queueesntopin', p_error_text => l_err_string);
END QUEUEPINTOESN;
END QUEUE_CARD_PKG;
/