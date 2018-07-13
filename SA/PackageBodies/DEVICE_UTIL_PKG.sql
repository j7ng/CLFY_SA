CREATE OR REPLACE PACKAGE BODY sa."DEVICE_UTIL_PKG"
IS

/***************************************************************************************************/
 --$RCSfile: DEVICE_UTIL_PKG.sql,v $
 --$Revision: 1.20 $
 --$Author: vkashmire $
 --$Date: 2015/03/12 08:22:02 $
 --$ $Log: DEVICE_UTIL_PKG.sql,v $
 --$ Revision 1.20  2015/03/12 08:22:02  vkashmire
 --$ CR32396 - remove x_real_esn
 --$
 --$ Revision 1.17  2015/02/23 15:25:36  vkashmire
 --$ CR32396 - remove byop-esn and use pseudo-esn
 --$
 --$ Revision 1.16  2015/02/17 20:06:52  pvenkata
 --$  CR30854--IS_HOME_CENTER
 --$
 --$ Revision 1.15  2014/09/11 16:22:22  vkashmire
 --$ CR29489-log msg changed
 --$
 --$ Revision 1.14  2014/09/09 15:22:18  vkashmire
 --$ CR29489
 --$
 --$ Revision 1.13  2014/08/22 20:57:13  vkashmire
 --$ CR22313 HPP Phase 2
 --$ CR29489 HPP BYOP
 --$ CR27087
 --$ CR29638
 --$
 --$ Revision 1.12  2014/08/01 21:20:57  jarza
 --$ CR26502 - Updated error handling
 --$
 --$ Revision 1.11  2014/08/01 19:35:29  jarza
 --$ CR26502 - Created a generic procedure to return device related information
 --$
  --$ Revision 1.10  2014/07/16 20:45:38  mvadlapally
  --$ CR29606  Warranty Car Connection - to determine old esn
  --$
  --$ Revision 1.9  2014/05/01 22:24:03  icanavan
  --$ ADDED CAR CONNECT AND TABLET
  --$
  --$ Revision 1.8  2014/04/01 21:54:39  vtummalpally
  --$ Add new function body (IS_homealert)
  --$

  --$ Revision 1.8  2014/03/18 11:41:02  vtummalpally
  --$ CR27269
  --$ Revision 1.7  2014/03/14 15:41:02  ymillan
  --$ CR27015
  --$
  --$ Revision 1.6  2014/02/24 20:56:40  ymillan
  --$ CR27354
  --$
  --$ Revision 1.5  2013/10/07 14:48:31  ymillan
  --$ CR25435
  --$
  --$ Revision 1.4  2013/09/11 20:05:59  mvadlapally
  --$ CR23513 TF Surepay
  --$
  --$ Revision 1.2  2013/08/07 21:59:40  mvadlapally
  --$ CR23513 TF Surepay  new package
  --$
  --$ Revision 1.1  2013/08/07 14:07:11  icanavan
  --$ Surepay new package
  --$
  --$
  /***************************************************************************************************/
    /*===============================================================================================*/
    /*                                                                                               */
    /* Purpose: GET_ANDROID_FUN IS TO VALIDATE ANDROID ESN                           */
    /*                0 ---> ANDROID NON-PPE                                         */
    /*                1 ---> NOT AN ANDROID                                                      */
    /*                2 ---> ANDRIOD PPE                                                         */
    /*                                                                                   */
    /* REVISIONS  DATE       WHO            PURPOSE                                                  */
    /* --------------------------------------------------------------------------------------------- */
    /*            7/25/2013 MVadlapally  Initial                             */
    /*===============================================================================================*/

FUNCTION get_smartphone_fun
  ( in_esn IN VARCHAR2)
  RETURN  NUMBER  IS

      CURSOR c_droid( v_cls IN VARCHAR2) IS
        SELECT (select x_param_value
                  FROM table_x_part_class_params pcp,
                       table_x_part_class_values pcv
                 WHERE pcp.objid = pcv.value2class_param
                   AND pcv.value2part_class = pn.part_num2part_class
                   AND x_param_name = 'BALANCE_METERING') BALANCE_METERING,
               (select x_param_value
                  FROM table_x_part_class_params pcp,
                       table_x_part_class_values pcv
                 WHERE pcp.objid = pcv.value2class_param
                   AND pcv.value2part_class = pn.part_num2part_class
                   AND x_param_name = 'BUS_ORG') BUS_ORG,
               (select x_param_value
                  FROM table_x_part_class_params pcp,
                       table_x_part_class_values pcv
                 WHERE pcp.objid = pcv.value2class_param
                   AND pcv.value2part_class = pn.part_num2part_class
                   AND pcp.x_param_name = 'NON_PPE') non_ppe
          FROM
               table_part_num pn,
               table_mod_level ml,
               table_part_inst pi
         WHERE 1=1
           AND pn.objid = ml.part_info2part_num
           AND ml.objid = pi.n_part_inst2part_mod
           AND pi.part_serial_no = in_esn ;

      r_droid c_droid%ROWTYPE ;

   return_value                 NUMBER ;

BEGIN

           OPEN c_droid(in_esn);
           FETCH c_droid INTO r_droid;
           CLOSE c_droid;
                if (r_droid.BALANCE_METERING= 'SUREPAY') THEN
                  IF r_droid.non_ppe = 1 THEN
                      return_value := 0;      --------------------- surepay android non ppe phone
                  ELSE
                      return_value := 2;     --------------------- surepay android ppe phone
                  END IF ;
                else
                       return_value := 1; ---  not surepay phone (PPE_STT, PPE_MTT, Unlimited,)
                end if;

    RETURN return_value ;
EXCEPTION
   WHEN others THEN
       return_value:= NULL ;
END;
-- CR25435
FUNCTION IS_HOTSPOTS(P_ESN IN VARCHAR2) RETURN NUMBER AS
-- return 0 if ESN is hostpot device
-- return 1 if ESN is not hotspot device
-- return 2 if other errors
CURSOR hotspots_CUR IS
select pn.PART_NUMBER
from   table_part_class pc, table_bus_org bo, table_part_num pn, pc_params_view vw, table_part_inst pi, table_mod_level ml
where pn.part_num2bus_org=bo.objid
and   pn.pArt_num2part_class=pc.objid
AND   PC.NAME=VW.PART_CLASS
AND   VW.PARAM_NAME  = 'DEVICE_TYPE'
AND   VW.PARAM_VALUE = 'MOBILE_BROADBAND'
AND PI.N_PART_INST2PART_MOD=ML.OBJID
AND ML.PART_INFO2PART_NUM=PN.OBJID
And pi.part_serial_no = p_esn ;
hotspots_REC hotspots_CUR%ROWTYPE ;
op_msg varchar2(400);
BEGIN
    OPEN hotspots_cur ;
    FETCH hotspots_CUR
    INTO hotspots_rec;
    IF hotspots_cur%FOUND THEN
      CLOSE hotspots_CUR;
      RETURN 0;
    END IF;
     CLOSE hotspots_CUR;
     RETURN 1;
EXCEPTION
    WHEN OTHERS THEN
      OP_MSG  := TO_CHAR(SQLCODE)||SQLERRM;
      sa.ota_util_pkg.err_log(p_action       => 'when others'
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  P_ESN
                          ,P_PROGRAM_NAME => 'VALIDAT$E_RED_CARD_PKG.IS_HOTSPOTS'
                          ,P_ERROR_TEXT   => OP_MSG);
      RETURN 2;
END IS_HOTSPOTS;
--CR25435
FUNCTION IS_home_phone(P_ESN IN VARCHAR2) RETURN NUMBER AS
-- return 0 if ESN is home_phone device
-- return 1 if ESN is not home_phone device
-- return 2 if other errors
-- CURSOR IS_ST_HOME_PHONE_CUR(P_ESN IN VARCHAR2) IS
  CURSOR home_phone_cur IS   --CR22487
      SELECT DISTINCT pc.name --, pcv.*, pcp.*
        FROM table_part_class          pc
            ,table_x_part_class_values pcv
            ,table_x_part_class_params pcp
            ,table_part_inst           pi
            ,table_mod_level           ml
            ,TABLE_PART_NUM            PN
            ,TABLE_BUS_ORG              PB  --CR22487
       WHERE pi.n_part_inst2part_mod = ml.objid
         AND ml.part_info2part_num = pn.objid
         AND pn.part_num2part_class = pc.objid
         AND pcp.objid(+) = pcv.value2class_param
         AND pc.objid(+) = pcv.value2part_class
         AND pcp.x_param_name = 'DEVICE_TYPE'
         AND PCV.X_PARAM_VALUE = 'WIRELESS_HOME_PHONE'
         AND PN.PART_NUM2BUS_ORG  = PB.OBJID --CR22487
         AND PI.PART_SERIAL_NO = P_ESN;
 --   IS_st_HOME_PHONE_REC IS_ST_HOME_PHONE_CUR%ROWTYPE;
     home_phone_rec home_phone_cur%ROWTYPE;
op_msg varchar2(400);
BEGIN
    OPEN home_phone_cur ;
    FETCH home_phone_cur
    INTO home_phone_rec;
    IF home_phone_cur%FOUND THEN
      CLOSE home_phone_cur;
      RETURN 0;
    END IF;
     CLOSE home_phone_cur;
     RETURN 1;
EXCEPTION
    WHEN OTHERS THEN
      OP_MSG  := TO_CHAR(SQLCODE)||SQLERRM;
      sa.ota_util_pkg.err_log(p_action       => 'when others'
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  P_ESN
                          ,P_PROGRAM_NAME => 'DEVICE_UTIL_PKG.IS_HOME_PHONE'
                          ,P_ERROR_TEXT   => OP_MSG);
      RETURN 2;
END IS_HOME_PHONE;

FUNCTION GET_ILD_PRD ( P_ESN  IN VARCHAR2) RETURN VARCHAR2 IS
/*********************************************************************************************************************************************************************/
/* function Name: GET_ILD_PRD                                                                                                                                        */
/* Description: return  ILD PRODUCT CODE for ESN if not EXIST RETURN 'NOT_EXIST'                                                                                    */
/**********************************************************************************************************************************************************************/
CURSOR GET_ILD_CURS  IS
    SELECT DISTINCT
   sp.objid,sp.mkt_name,sp.description,spfvdef.value_name,spfvdef2.value_name ild_code ,tsp.x_service_id ,tSP.install_date
FROM
  X_SERVICEPLANFEATUREVALUE_DEF SPFVDEF,
  x_serviceplanfeature_value spfv,
  x_service_plan_feature spf,
  X_SERVICEPLANFEATUREVALUE_DEF SPFVDEF2,
  X_SERVICE_PLAN SP,
  TABLE_SITE_PART TSP, X_SERVICE_PLAN_SITE_PART SPSP
WHERE 1=1
  AND spf.sp_feature2service_plan = sp.objid
  AND SPF.SP_FEATURE2REST_VALUE_DEF = SPFVDEF.OBJID
  AND SPF.OBJID = SPFV.SPF_VALUE2SPF
  AND SPFVDEF2.OBJID = SPFV.VALUE_REF
  AND SPFVDEF.VALUE_NAME IN ('ILD_PRODUCT')
  AND TSP.X_SERVICE_ID IN (p_esn)
 AND SPSP.TABLE_SITE_PART_ID = TSP.OBJID(+)
 AND SP.OBJID = SPSP.X_SERVICE_PLAN_ID
 AND UPPER(TSP.PART_STATUS) NOT IN ('OBSOLETE')
ORDER BY tSP.install_date desc;

  GET_ILD_REC   GET_ILD_CURS%ROWTYPE;
begin
   OPEN GET_ILD_CURS;
                 FETCH GET_ILD_CURS
                 INTO GET_ILD_REC;

  if  GET_ILD_CURS%NOTFOUND THEN
      close GET_ILD_CURS;
    return 'NOT_EXIST';
  else
     close GET_ILD_CURS;
    return GET_ILD_REC.ILD_CODE;
  end if;
end GET_ILD_PRD;


FUNCTION GET_ILD_PRD_DEF (  V_BUS_ORG IN VARCHAR2) RETURN VARCHAR2 IS
/*********************************************************************************************************************************************************************/
/* function Name: GET_ILD_PRD_DEF                                                                                                                                        */
/* Description: return  ILD PRODUCT CODE for default for Each Brand if not found brand return 'ERR_BRAND'                                                                                 */
/**********************************************************************************************************************************************************************/
CURSOR GET_ILD_CURS  IS
   select ti.X_ILD_PRODUCT ILD_CODE
   from sa.TABLE_X_ILD_PRODUCT ti, table_bus_org bo
   where bo.org_ID = V_BUS_ORG
    and bo.objid = ti.X_BUS_ORG
    and ti.X_IS_DEFAULT = 1;
  GET_ILD_REC   GET_ILD_CURS%ROWTYPE;
begin
   OPEN GET_ILD_CURS;
                 FETCH GET_ILD_CURS
                 INTO GET_ILD_REC;

  if  GET_ILD_CURS%NOTFOUND THEN
      close GET_ILD_CURS;
    return 'ERR_BRAND' ;
  else
     close GET_ILD_CURS;
    return GET_ILD_REC.ILD_CODE;
  end if;
end GET_ILD_PRD_DEF;

-- CR27269
FUNCTION IS_HOMEALERT(H_ESN IN VARCHAR2) RETURN NUMBER AS

 CURSOR HOMEALERT_CUR IS
  select pn.PART_NUMBER
        from   table_part_class pc, table_bus_org bo,
                table_part_num pn, pc_params_view vw,
                table_part_inst pi, table_mod_level ml
        where pn.part_num2bus_org=bo.objid
        and   pn.pArt_num2part_class=pc.objid
        AND   PC.NAME=VW.PART_CLASS
        AND   VW.PARAM_NAME  = 'MODEL_TYPE'
        AND   VW.PARAM_VALUE = 'HOME ALERT'
        AND PI.N_PART_INST2PART_MOD=ML.OBJID
        AND ML.PART_INFO2PART_NUM=PN.OBJID
        And pi.part_serial_no = H_ESN ;

HOMEALERT_REC HOMEALERT_CUR%ROWTYPE ;
op_msg varchar2(400);

BEGIN
    OPEN HOMEALERT_cur ;
    FETCH HOMEALERT_CUR
    INTO HOMEALERT_rec;

    IF HOMEALERT_cur%FOUND THEN
      CLOSE HOMEALERT_CUR;
      RETURN 0;
    end if;
       CLOSE HOMEALERT_CUR;
     RETURN 1;
EXCEPTION
    WHEN OTHERS THEN
      OP_MSG  := TO_CHAR(SQLCODE)||SQLERRM;
      sa.ota_util_pkg.err_log(p_action       => 'when others'
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  H_ESN
                          ,P_PROGRAM_NAME => 'DEVICE_UTIL_PKG.IS_HOMEALERT'
                          ,P_ERROR_TEXT   => OP_MSG);
      RETURN 2;
END IS_HOMEALERT;
--CR27269

-- CR27538
FUNCTION IS_TABLET(H_ESN IN VARCHAR2) RETURN NUMBER AS

 CURSOR TABLET_CUR IS
  select pn.PART_NUMBER
        from   table_part_class pc, table_bus_org bo,
                table_part_num pn, pc_params_view vw,
                table_part_inst pi, table_mod_level ml
        where pn.part_num2bus_org=bo.objid
        and   pn.pArt_num2part_class=pc.objid
        AND   PC.NAME=VW.PART_CLASS
        AND   VW.PARAM_NAME  = 'MANUFACTURER'
        AND   VW.PARAM_VALUE = 'BYOT'
        AND PI.N_PART_INST2PART_MOD=ML.OBJID
        AND ML.PART_INFO2PART_NUM=PN.OBJID
        And pi.part_serial_no = H_ESN ;

TABLET_REC TABLET_CUR%ROWTYPE ;
op_msg varchar2(400);

BEGIN
    OPEN TABLET_cur ;
    FETCH TABLET_CUR
    INTO TABLET_rec;

    IF TABLET_cur%FOUND THEN
      CLOSE TABLET_CUR;
      RETURN 0;
    end if;
       CLOSE TABLET_CUR;
     RETURN 1;
EXCEPTION
    WHEN OTHERS THEN
      OP_MSG  := TO_CHAR(SQLCODE)||SQLERRM;
      sa.ota_util_pkg.err_log(p_action       => 'when others'
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  H_ESN
                          ,P_PROGRAM_NAME => 'DEVICE_UTIL_PKG.IS_TABLET'
                          ,P_ERROR_TEXT   => OP_MSG);
      RETURN 2;
END IS_TABLET;
--CR27538

--CR27270
FUNCTION IS_CONNECT(H_ESN IN VARCHAR2) RETURN NUMBER AS

 CURSOR CONNECT_CUR IS
  select pn.PART_NUMBER
        from   table_part_class pc, table_bus_org bo,
                table_part_num pn, pc_params_view vw,
                table_part_inst pi, table_mod_level ml
        where pn.part_num2bus_org=bo.objid
        and   pn.pArt_num2part_class=pc.objid
        AND   PC.NAME=VW.PART_CLASS
        AND   VW.PARAM_NAME  = 'MODEL_TYPE'
        AND   VW.PARAM_VALUE = 'CAR CONNECT'
        AND PI.N_PART_INST2PART_MOD=ML.OBJID
        AND ML.PART_INFO2PART_NUM=PN.OBJID
        And pi.part_serial_no = H_ESN ;

CONNECT_REC CONNECT_CUR%ROWTYPE ;
op_msg varchar2(400);

BEGIN
    OPEN CONNECT_cur ;
    FETCH CONNECT_CUR
    INTO CONNECT_rec;

    IF CONNECT_cur%FOUND THEN
      CLOSE CONNECT_CUR;
      RETURN 0;
    end if;
       CLOSE CONNECT_CUR;
     RETURN 1;
EXCEPTION
    WHEN OTHERS THEN
      OP_MSG  := TO_CHAR(SQLCODE)||SQLERRM;
      sa.ota_util_pkg.err_log(p_action       => 'when others'
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  H_ESN
                          ,P_PROGRAM_NAME => 'DEVICE_UTIL_PKG.IS_CONNECT'
                          ,P_ERROR_TEXT   => OP_MSG);
      RETURN 2;
END IS_CONNECT;
--CR27270


-- FUNCTION TO DETERMINE OLD ESN
-- Caller: SOA - To determine old esn for Car Connection ESN's

FUNCTION sf_get_old_esn (in_esn IN ig_transaction.esn%TYPE)
    RETURN VARCHAR2
IS
    l_oldesn       VARCHAR2 (50) := NULL;
BEGIN
    BEGIN
        SELECT x_old_esn esn
          INTO l_oldesn
          FROM x_min_esn_change
         WHERE x_new_esn = in_esn;
    EXCEPTION
        WHEN OTHERS
        THEN
            l_oldesn    := NULL;
    END;

    IF l_oldesn IS NULL
    THEN
        BEGIN
            SELECT tc.x_esn
              INTO l_oldesn
              FROM table_x_case_detail cd, table_case tc
             WHERE tc.objid = cd.detail2case
               AND cd.x_name = 'NEW_ESN'
               AND cd.x_value = in_esn;
        EXCEPTION
            WHEN OTHERS
            THEN
                l_oldesn    := NULL;
        END;
    END IF;

    IF l_oldesn IS NULL
    THEN
        BEGIN
            SELECT TRIM (cd.x_value)
              INTO l_oldesn
              FROM table_x_case_detail cd, table_case tc
             WHERE tc.objid = cd.detail2case
               AND cd.x_name in ('REFERENCE_ESN','CURRENT_ESN')
               AND tc.x_esn = in_esn;
        EXCEPTION
            WHEN OTHERS
            THEN
                l_oldesn    := NULL;
        END;
    END IF;

    IF l_oldesn IS NULL
    THEN
        l_oldesn    := 'unable to determine';
    END IF;

    RETURN l_oldesn;
EXCEPTION
    WHEN OTHERS
    THEN
        RETURN 'Exception Occurred';
END;
/***************************************************************************************************************
 Program Name       :  	SP_GET_DEVICE_INFO
 Program Type       :  	Stored procedure
 Program Arguments  :  	IN_ID
                        IN_TYPE
 Returns            :  	OUT_CUR_DEVICE_INFO   - ref_cur_type
 Program Called     :  	None
 Description        :  	This stored procedure returns device related information based on IN_ID and IN_TYPE
                        IN_ID can be a valid ESN or MIN or ICCID.
                        Depening on type of IN_ID, corresponding IN_TYPE should be set. Valid values for IN_TYPE
                          1. ESN
                          2. MIN
                          3. ICCID
 Modified By            Modification     CR             Description
                          Date           Number
 =============          ============     ======      ===================================
 Jai Arza        	  	    07/31/2014     CR26502  	        Initial Creation
***************************************************************************************************************/
  PROCEDURE SP_GET_DEVICE_INFO(
		IN_ID					    IN	VARCHAR2,
		IN_TYPE     		        IN	VARCHAR2,
		OUT_CUR_DEVICE_INFO			OUT sys_refcursor) IS
    sqlstmt                 VARCHAR2 (4000);
	v_action             	VARCHAR2 (1000) := NULL;
	user_exception       	EXCEPTION;
  BEGIN
    sqlstmt := sqlstmt || 'SELECT  PI.PART_SERIAL_NO AS PART_SERIAL_NO';
    sqlstmt := sqlstmt || ' , PI.X_PART_INST_STATUS AS PART_STATUS';
    sqlstmt := sqlstmt || ' , PC.NAME AS PART_CLASS_NAME';
    sqlstmt := sqlstmt || ' , PN.PART_NUMBER AS PART_NUMBER';
    sqlstmt := sqlstmt || ' , PN.DOMAIN AS DOMAIN';
    sqlstmt := sqlstmt || ' , BO.ORG_ID AS BUS_ORG';
    sqlstmt := sqlstmt || ' , PN.X_TECHNOLOGY AS TECHNOLOGY';
    sqlstmt := sqlstmt || ' , PN.PART_TYPE AS PART_TYPE';
	sqlstmt := sqlstmt || ' , NVL(( SELECT BYOP.X_MSL_CODE FROM   SA.TABLE_X_BYOP BYOP WHERE  BYOP.X_ESN = PI.PART_SERIAL_NO), ''No MSL found.'') AS MSL_CODE';
    sqlstmt := sqlstmt || ' FROM  TABLE_PART_CLASS PC';
    sqlstmt := sqlstmt || ' , TABLE_PART_NUM PN';
    sqlstmt := sqlstmt || ' , TABLE_PART_INST PI';
    sqlstmt := sqlstmt || ' , TABLE_MOD_LEVEL ML';
    sqlstmt := sqlstmt || ' , TABLE_BUS_ORG BO ';
    IF IN_TYPE = 'MIN' THEN
      sqlstmt := sqlstmt || ' ,TABLE_PART_INST PI2 ';
    END IF;
    sqlstmt := sqlstmt || ' WHERE  1 = 1 ';
    sqlstmt := sqlstmt || ' AND    PI.X_DOMAIN = ''PHONES''';
    sqlstmt := sqlstmt || ' AND    PN.PART_NUM2PART_CLASS = PC.OBJID ';
    sqlstmt := sqlstmt || ' AND    PI.N_PART_INST2PART_MOD = ML.OBJID ';
    sqlstmt := sqlstmt || ' AND    ML.PART_INFO2PART_NUM = PN.OBJID';
    sqlstmt := sqlstmt || ' AND    PN.PART_NUM2BUS_ORG = BO.OBJID';

    IF IN_TYPE = 'ESN' THEN
      sqlstmt := sqlstmt || ' AND     PI.PART_SERIAL_NO = :IN_ID';
    ELSIF IN_TYPE = 'MIN' THEN
      sqlstmt := sqlstmt || ' AND     PI.OBJID = pi2.part_to_esn2part_inst ';
      sqlstmt := sqlstmt || ' AND     PI2.X_MSID = :IN_ID';
    ELSIF IN_TYPE = 'ICCID' THEN
      sqlstmt := sqlstmt || ' AND     PI.x_iccid = :IN_ID';
    END IF;

	IF IN_ID IS NULL AND IN_TYPE IS NULL THEN
		v_action := ' Failed to retrieve records: IN_ID and IN_TYPE cannot be null';
        RAISE user_exception;
	END IF;

	IF IN_ID IS NULL THEN
		v_action := ' Failed to retrieve records: IN_ID cannot be null ';
        RAISE user_exception;
	END IF;

	IF IN_TYPE IS NULL THEN
		v_action := ' Failed to retrieve records: IN_TYPE cannot be null; Enter one of the following valid values "MIN", "ESN", "ICCID" ';
        RAISE user_exception;
	END IF;

    DBMS_OUTPUT.PUT_LINE('sqlstmt:'||sqlstmt);

    OPEN OUT_CUR_DEVICE_INFO FOR sqlstmt USING IN_ID;

  EXCEPTION
    WHEN OTHERS THEN
		OTA_UTIL_PKG.ERR_LOG(  v_action, --p_action
							SYSDATE, --p_error_date
							IN_ID ||'-'||IN_TYPE, --p_key
							'DEVICE_UTIL_PKG.SP_GET_DEVICE_INFO',--p_program_name
							'SQL Error Code : '|| TO_CHAR (SQLCODE)|| ' Error Message : '|| DBMS_UTILITY.FORMAT_ERROR_STACK || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE()--p_error_text
							);
		RAISE;
  END SP_GET_DEVICE_INFO;

  function f_remove_real_esn_link (in_pseudo_esn in varchar2 )
  return integer is
  /*********************
  21 august 2014
  HPP BYOP CR29489
  vkashmire@tracfone.com
  function f_remove_real_esn_link : created to remove the real-esn linked to pseudo esn
  when a hpp-byop program gets expired or byop handset gets deactivated
    then the link between pseudo-esn and real-esn has to be removed
  **************************/
    lv_retval integer;
  begin

    begin
      /*update sa.table_part_inst
      set x_parent_part_serial_no = null  --this column stores the byop esn
          ,pick_request = null            --this column stores the byop phone model
          ,part_bin = null                --this column stores the byop phone manufacturer
      where part_serial_no = in_pseudo_esn
      and x_domain= 'PHONES';
      */
      update sa.x_vas_subscriptions
      set vas_name = null
			  , x_real_esn = null
        , x_manufacturer = null
        , x_model_number = null
        , x_email = null
        , addl_info = substr('real-esn: '|| x_real_esn
                      ||', removed:'|| to_char(sysdate, 'mm/dd/rrrr hh24:mi'), 1, 50)
      where vas_esn = in_pseudo_esn
      and vas_name = 'HPP BYOP'
      ;

      dbms_output.put_line ('f_remove_real_esn_link. records updated='|| sql%rowcount);
      lv_retval := 0;

    exception
      when others then
        lv_retval := -1;
        dbms_output.put_line('f_remove_real_esn_link...ERR='|| sqlerrm);

        sa.ota_util_pkg.err_log(p_action  => 'when others'
                          ,p_error_date   => SYSDATE
                          ,P_KEY          =>  in_pseudo_esn
                          ,P_PROGRAM_NAME => 'f_remove_real_esn_link'
                          ,P_ERROR_TEXT   => sqlerrm);


    end;

    return lv_retval;

  end f_remove_real_esn_link;

  function f_get_real_esn_for_pseudo_esn (in_pseudo_esn in varchar2 )
  return varchar2
  /**********
  21 August 2014
  HPP BYOP CR29489
  vkashmire@tracfone.com
  function f_get_real_esn_for_pseudo_esn : created to return the pseudo ESN for the input BYOP ESN
  ************/
  is
    ---lv_retval x_vas_subscriptions.x_real_esn%type;
  begin
    return in_pseudo_esn;
    /*
    begin
      select x_real_esn
      into lv_retval
      from sa.x_vas_subscriptions
      where vas_esn = in_pseudo_esn
      and vas_name = 'HPP BYOP'
      and x_real_esn is not null; -- there might be records present with HPP BYOP and x_real_esn as null when f_remove_real_esn_link is invoked
    exception
      when others then
        lv_retval := null;
        dbms_output.put_line ('f_get_real_esn_for_pseudo_esn...ERR='||sqlerrm);
    end;

    return lv_retval;
    */

  end f_get_real_esn_for_pseudo_esn;

  function f_get_pseudo_esn_for_real_esn (in_byop_esn in varchar2 )
  return varchar2
  /**********
  21 August 2014
  HPP BYOP CR29489
  vkashmire@tracfone.com
  function f_get_pseudo_esn_for_real_esn : created to return the pseudo ESN for the input BYOP ESN
  ************/
  is
    --lv_retval x_vas_subscriptions.vas_esn%type;
  begin
    return in_byop_esn;
    /*
    begin
      select vas_esn
      into lv_retval
      from sa.x_vas_subscriptions
      where x_real_esn = in_byop_esn
      and vas_name = 'HPP BYOP';
    exception
      when others then
        lv_retval := null;
        dbms_output.put_line ('f_get_pseudo_esn_for_real_esn...ERR='||sqlerrm);
    end;

    return lv_retval;
    */

  end f_get_pseudo_esn_for_real_esn;



END DEVICE_UTIL_PKG;
/