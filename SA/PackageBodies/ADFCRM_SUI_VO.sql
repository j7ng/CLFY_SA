CREATE OR REPLACE PACKAGE BODY sa.ADFCRM_SUI_VO
AS
  --------------------------------------------------------------------------------------------
  FUNCTION ENABLE_ACTION_BUTTON (
                                  ip_rule_objid NUMBER,
                                  ip_action_objid NUMBER,
                                  ip_esn varchar2,
                                  ip_transaction_id number default null
                                  )
  RETURN VARCHAR2
  IS
    sqlstr clob := 'declare
  v_esn varchar2(30) := :ip_esn;
  n_rule_objid number := :ip_robj;
  n_action_objid number := :ip_aobj;
  n_transaction_id number := :ip_tid;
  v_out_var varchar2(10) := 0;
begin
  sql_string
  :v_out_var := v_out_var;
exception
  when others then
    null;
end;';

    ret_var varchar2(10);
  BEGIN

    for i in (
              select *
              from ADFCRM_SUI_DISACT_BUTTON_RULES
              where criteria = 'SQL'
              and rule_objid = ip_rule_objid
              and action_objid = ip_action_objid
              )
    loop
      sqlstr := replace(sqlstr,'sql_string',i.sql_string);
      --DBMS_OUTPUT.PUT_LINE(sqlstr);
      --DBMS_OUTPUT.PUT_LINE(ret_var);
      execute immediate sqlstr using ip_esn, ip_rule_objid, ip_action_objid, ip_transaction_id, out ret_var;

      if ret_var = 'FAIL' then
        return 'false';
      end if;

    end loop;
    RETURN 'true';
  exception
    when others then
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      return 'true'; -- return true because I can't confirm whether to block it or not
  END ENABLE_ACTION_BUTTON;
  --------------------------------------------------------------------------------------------
  function get_bucket_val(ip_transaction_id varchar2,ip_bucket_type varchar2)
  return varchar2
  is
    ret_val varchar2(4000);
  begin
    for i in (SELECT feature_value FROM table(sa.sui_pkg.fetch_sui_buckets (ip_transaction_id)) where feature_name = ip_bucket_type)
    loop
      ret_val := ret_val||','||i.feature_value;
    end loop;
    -- IF NOTHING IS FOUND RETURN NULL
    return SUBSTR(ret_val,2);
  end get_bucket_val;
  --------------------------------------------------------------------------------------------
  function get_carrier_feature_objid(ip_transaction_id varchar2)
  return varchar2
  is
    P_ORDER_TYPE VARCHAR2(200);
    P_ST_ESN_FLAG VARCHAR2(200);
    P_SITE_PART_OBJID NUMBER;
    P_ESN VARCHAR2(200);
    P_CARRIER_OBJID NUMBER;
    P_CARR_FEATURE_OBJID NUMBER;
    P_DATA_CAPABLE VARCHAR2(200);
    P_TEMPLATE VARCHAR2(200);
    P_SERVICE_PLAN_ID NUMBER;
    P_TASK_OBJID VARCHAR2(200);
    v_Return NUMBER;
  BEGIN
    -- I CREATED THIS FOR TESTING AN ISSUE W/THE NEW FUNCTION ITDS PROVIDED
    -- DUE TO INCREASED DML, NITIN REQUESTED FOR THIS (ig_transaction_features) TABLE TO BE REMOVED.
    -- igate.get_ig_transaction_features WAS CREATED TO REPLACE THAT TABLE WE PREVIOUSLY
    -- QUERIED. THIS NEW PIPELINED FUNCTION BEHAVES IN THE SAME MANNER EXCEPT IT LOOKS
    -- AT THE CONFIGURATIONS INSTEAD OF DATA THAT WAS ONCE IN THE TABLE.
    -- BOTTOM LINE DO NOT USE THIS IN PROD, BECAUSE IT HAS NOT BEEN CHECKED AND APPROVED
    -- FOR USE
    P_ST_ESN_FLAG := null;
    P_CARR_FEATURE_OBJID := null;

    P_DATA_CAPABLE := null;
    P_SERVICE_PLAN_ID := null;
    P_SITE_PART_OBJID := 1;

    P_ESN := null;
    P_CARRIER_OBJID := null;
    P_ORDER_TYPE := null;
    P_TEMPLATE := null;
    P_TASK_OBJID := null;

    for i in (SELECT
                tab1.esn,
                tab1.x_call_trans2carrier carrier_objid,
                tab1.order_type,
                tab1.template,
                tab1.task_objid
              FROM
                (SELECT tt.objid task_objid,
                  tt.task_id action_item_task_id,
                  tt.x_rate_plan,
                  ct.x_call_trans2carrier,
                  ct.call_trans2site_part,
                  ct.x_action_type,
                  ig.order_type,
                  ig.rate_plan,
                  ig.template,
                  ig.esn
                FROM sa.table_x_call_trans ct,
                     sa.table_task tt,
                     gw1.ig_transaction ig
                WHERE 1                    =1
                and tt.task_id = ig.action_item_id
                and  ig.transaction_id = ip_transaction_id
                AND tt.x_task2x_call_trans = ct.objid
                ORDER BY tt.start_date DESC
                ) tab1
            WHERE ROWNUM < 2)
    loop
      for j in (
                select get_param_by_name_fun(class_name,'DATA_CAPABLE')DATA_CAPABLE ,service_plan_objid,site_part_objid
                from table(adfcrm_vo.get_service_profile(i.esn,''))
                )
      loop
        v_Return := IGATE.SF_GET_CARR_FEAT (
                                            P_ORDER_TYPE => i.order_type,
                                            P_ST_ESN_FLAG => P_ST_ESN_FLAG,
                                            P_SITE_PART_OBJID => j.site_part_objid,
                                            P_ESN => i.esn,
                                            P_CARRIER_OBJID => i.carrier_objid,
                                            P_CARR_FEATURE_OBJID => P_CARR_FEATURE_OBJID,
                                            P_DATA_CAPABLE => j.DATA_CAPABLE,
                                            P_TEMPLATE => i.template,
                                            P_SERVICE_PLAN_ID => j.service_plan_objid,
                                            P_TASK_OBJID => i.task_objid
                                           );
      end loop;
    end loop;
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || v_Return);
    return v_Return;
  END get_carrier_feature_objid;
  --------------------------------------------------------------------------------------------
  function get_validate_features(ip_transaction_id in varchar2,ip_carrier_feature_objid in varchar2 default null)
  return validate_features_tab pipelined
  is
    validate_features_rslt  validate_features_rec;
    v_carrier_feature_objid varchar2(30) := ip_carrier_feature_objid; --get_carrier_feature_objid(ip_transaction_id =>ip_transaction_id); -- NOT TO BE USED ITDS WILL TAKE CARE OF THIS
  begin
    for i in (
              select clfy_fea fea_value,
                     is_valid
              from (
                    select /*b.fv carr_fea,*/ a.fv clfy_fea,case
                                 when a.feature_requirement in ('ADD') and b.fv is null then 'MISSING'
                                 when a.feature_requirement = 'OPT' and b.fv is null then 'NOT_REQ'
                                 when a.feature_requirement in ('ADD','OPT') then 'VALID'
                                 when a.feature_requirement = 'REM' and b.fv is null then 'DONT_ADD'
                                 when a.feature_requirement = 'REM' then 'IN_VALID'
                               end is_valid
                    from (
                          select feature_value fv,feature_requirement
                          from table(igate.get_ig_transaction_features (ip_transaction_id, v_carrier_feature_objid))
                          where feature_requirement in ('ADD','OPT','REM')) a,
                        (
                          select fv
                          from  (with t as (select (select feature_value
                                                    from table( sa.sui_pkg.fetch_sui_order(ip_transaction_id)) --400193853
                                                    where feature_name = 'FEATURE_LIST') fv  from dual)
                                 select replace(regexp_substr(fv,'[^,]+',1,lvl),'null','') fv
                                 from  (select fv, level lvl
                                        from   t
                                        connect by level <= length(fv) - length(replace(fv,',')) + 1)
                                 ) where fv is not null
                        ) b
                    where a.fv=b.fv(+))
              where is_valid not in ('DONT_ADD','NOT_REQ')
              union
              select fv, 'NEW' is_valid
              from  (with t as (select (select feature_value
                                        from table( sa.sui_pkg.fetch_sui_order(ip_transaction_id)) --400193853
                                        where feature_name = 'FEATURE_LIST') fv  from dual)
                     select replace(regexp_substr(fv,'[^,]+',1,lvl),'null','') fv
                     from  (select fv, level lvl
                            from   t
                            connect by level <= length(fv) - length(replace(fv,',')) + 1)
                     ) where fv is not null
              and fv not in (
                             select feature_value fv
                             from table(igate.get_ig_transaction_features (ip_transaction_id, v_carrier_feature_objid))
                             where feature_requirement in ('ADD','OPT','REM')
                            )
              order by is_valid,fea_value
              )
    loop
      validate_features_rslt.fea_value := i.fea_value;
      validate_features_rslt.is_valid := i.is_valid;
      pipe row (validate_features_rslt);
    end loop;
  end get_validate_features;
  --------------------------------------------------------------------------------------------
  function get_sui_inquiry(ip_esn varchar2, ip_rule_objid varchar2, ip_transaction_id varchar2)
  return sui_inquiry_tab pipelined
  is
    sui_inquiry_rslt  sui_inquiry_rec;
  begin
    for i in (
              SELECT ATTR.ATTR_OBJID,
                ATTR.ATTR_NAME,
                ATTR.DISPLAY_LABEL,
                CLARIFY.ATTRIBUTE_VALUE CLARIFY_VALUE,
                ATTR.PARENT_ATTR_ID,
                NVL(MTM.DISPLAY_SEQUENCE,(SELECT CHLD_DISP.DISPLAY_SEQUENCE + 0.5 FROM ADFCRM_SUI_ATTR_MTM CHLD_DISP WHERE ATTR.PARENT_ATTR_ID = CHLD_DISP.ATTR_OBJID AND CHLD_DISP.RULE_OBJID(+) = ip_rule_objid)) DISPLAY_SEQUENCE ,
                NVL(MTM.WINNER, (SELECT PAR_WIN.WINNER FROM ADFCRM_SUI_ATTR_MTM PAR_WIN WHERE  PAR_WIN.RULE_OBJID   = ip_rule_objid AND PAR_WIN.ATTR_OBJID = ATTR.PARENT_ATTR_ID )) WINNER,
                (SELECT FEATURE_VALUE FROM TABLE(sa.sui_pkg.fetch_sui_order(ip_transaction_id)) WHERE FEATURE_NAME = CARRIER_VALUE  AND ROWNUM =1) AS CARRIER_VALUE,
                TO_CHAR((SELECT COUNT(1) FROM ADFCRM_SUI_ATTRIBUTES CHLD WHERE CHLD.PARENT_ATTR_ID = ATTR.ATTR_OBJID ))  CHILD_COUNT
              FROM ADFCRM_SUI_ATTR_MTM MTM ,
                ADFCRM_SUI_ATTRIBUTES ATTR,
                TABLE(sa.ADFCRM_SUI_VO.GET_CLARIFY_PROFILE(ip_esn,ip_rule_objid,ip_transaction_id)) CLARIFY
              WHERE 1                     = 1
              AND MTM.RULE_OBJID(+)       = ip_rule_objid
              AND CLARIFY.ATTRIBUTE_OBJID = MTM.ATTR_OBJID(+)
              AND ATTR.ATTR_OBJID         = CLARIFY.ATTRIBUTE_OBJID
              ORDER BY DISPLAY_SEQUENCE,ATTR_OBJID
              )
    loop
      sui_inquiry_rslt.ATTR_OBJID           :=i.ATTR_OBJID;
      sui_inquiry_rslt.ATTR_NAME            :=i.ATTR_NAME;
      sui_inquiry_rslt.DISPLAY_LABEL        :=i.DISPLAY_LABEL;
      sui_inquiry_rslt.CLARIFY_VALUE        :=i.CLARIFY_VALUE;
      sui_inquiry_rslt.PARENT_ATTR_ID       :=i.PARENT_ATTR_ID;
      sui_inquiry_rslt.DISPLAY_SEQUENCE     :=i.DISPLAY_SEQUENCE;
      sui_inquiry_rslt.WINNER               :=i.WINNER;
      if instr(i.CARRIER_VALUE,':') > 0 then
        sui_inquiry_rslt.CARRIER_VALUE      :=substr(i.CARRIER_VALUE,0,instr(i.CARRIER_VALUE,':')-1);
        sui_inquiry_rslt.CARRIER_VALUE_ADDL :=substr(i.CARRIER_VALUE,instr(i.CARRIER_VALUE,':')+1);
      else
        sui_inquiry_rslt.CARRIER_VALUE      :=i.CARRIER_VALUE;
        sui_inquiry_rslt.CARRIER_VALUE_ADDL :=null;
      end if;
      sui_inquiry_rslt.CHILD_COUNT          :=i.CHILD_COUNT;
      if i.WINNER = 'DISPLAY' then
        sui_inquiry_rslt.CHECK_DIFFERENCES   :='INFO';
      else
        if instr(i.CARRIER_VALUE,':')>0 then
          if i.CLARIFY_VALUE = substr(i.CARRIER_VALUE,0,instr(i.CARRIER_VALUE,':')-1) then
            sui_inquiry_rslt.CHECK_DIFFERENCES   :='MATCH';
          else
            sui_inquiry_rslt.CHECK_DIFFERENCES   :='MISMATCH';
          end if;
        elsif i.ATTR_NAME = 'FEATURES' then
          select decode(to_char(cnt),'0','MATCH','MISMATCH') is_valid
          into sui_inquiry_rslt.CHECK_DIFFERENCES
          from (select count(*) cnt
                from table(sa.adfcrm_sui_vo.get_validate_features(ip_transaction_id))
                where is_valid in ('IN_VALID','MISSING'));
        elsif i.CLARIFY_VALUE IS NULL AND i.CARRIER_VALUE IS NULL then
          sui_inquiry_rslt.CHECK_DIFFERENCES   :='MATCH';
        elsif i.CLARIFY_VALUE = i.CARRIER_VALUE then
          sui_inquiry_rslt.CHECK_DIFFERENCES   :='MATCH';
        else
          sui_inquiry_rslt.CHECK_DIFFERENCES   :='MISMATCH';
        end if;
      end if;
      pipe row (sui_inquiry_rslt);
      sui_inquiry_rslt.ATTR_OBJID         :=null;
      sui_inquiry_rslt.ATTR_NAME          :=null;
      sui_inquiry_rslt.DISPLAY_LABEL      :=null;
      sui_inquiry_rslt.CLARIFY_VALUE      :=null;
      sui_inquiry_rslt.PARENT_ATTR_ID     :=null;
      sui_inquiry_rslt.DISPLAY_SEQUENCE   :=null;
      sui_inquiry_rslt.WINNER             :=null;
      sui_inquiry_rslt.CARRIER_VALUE      :=null;
      sui_inquiry_rslt.CARRIER_VALUE_ADDL :=null;
      sui_inquiry_rslt.CHILD_COUNT        :=null;
      sui_inquiry_rslt.CHECK_DIFFERENCES  :=null;
    end loop;
  end get_sui_inquiry;
  --------------------------------------------------------------------------------------------
  --********************************************************************************************************************
  function ret_sui_status_msg(ip_transaction_id varchar2)
  return varchar2
  is
    v_rssmsg varchar2(4000);
  begin
    begin
      select a.status_message
      into v_rssmsg
      from gw1.ig_transaction  a
      WHERE transaction_id = ip_transaction_id;
    exception
      when others then
        select a.status_message
        into v_rssmsg
        from gw1.ig_failed_log a
        WHERE a.transaction_id = ip_transaction_id
        and a.update_date = (select max(a2.update_date)
                             from gw1.ig_failed_log a2
                             where a2.action_item_id = a.action_item_id);
    end;
    return v_rssmsg;

  exception
    when others then
      return null;
  end ret_sui_status_msg;
  --------------------------------------------------------------------------------------------
  FUNCTION GET_PC_SCRIPT_TECH(IP_ESN IN VARCHAR2)
    RETURN GET_CLARIFY_TAB PIPELINED
  IS
    GET_CLARIFY_PROFILE_RSLT GET_CLARIFY_REC;
    V_ATTRIBUTE_NAME  VARCHAR2(50);
    V_ATTRIBUTE_VALUE VARCHAR2(300);
  BEGIN
    FOR i IN (select pc,TECH1||decode(tech2,'BYOP','','BYOD','','','','_'||tech2) tech
              from (
                    SELECT  pc.name pc,
                           GET_PARAM_BY_NAME_FUN(pc.name,'TECHNOLOGY') TECH1,
                           GET_PARAM_BY_NAME_FUN(pc.name,'PHONE_GEN') TECH2
                    FROM TABLE_PART_INST pi,
                        TABLE_MOD_LEVEL m,
                        TABLE_PART_NUM pn,
                        TABLE_PART_Class pc
                    WHERE 1 = 1
                    AND pi.N_PART_INST2PART_MOD = m.OBJID
                    AND m.PART_INFO2PART_NUM = pn.OBJID
                    AND pn.part_num2part_class = pc.objid
                    AND pi.PART_SERIAL_NO = IP_ESN
                    AND pi.X_DOMAIN = 'PHONES'
                    )
              )
    LOOP
      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_OBJID := 'PART_CLASS';
      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_VALUE := i.pc;
      PIPE ROW (GET_CLARIFY_PROFILE_RSLT);
      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_OBJID := 'TECH';
      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_VALUE := i.tech;
      PIPE ROW (GET_CLARIFY_PROFILE_RSLT);
    END LOOP;
  END GET_PC_SCRIPT_TECH;
  ------------------------------------------------------
  -- NEW OUT PARAM
  ------------------------------------------------------
  PROCEDURE GET_CARRIER_INFO(
      IP_PART_SERIAL_NO IN VARCHAR2,
      IP_MIN            IN VARCHAR2,
      IP_CASE_ID        IN VARCHAR2,
      ESN OUT VARCHAR2,
      CARRIER_NAME OUT VARCHAR2,
      CARRIER_MARKET_NAME OUT VARCHAR2,
      CARRIER_ID OUT VARCHAR2,-- NEW OUT PARAM
      RULE_OBJID OUT VARCHAR2,
      ERR_NUM OUT VARCHAR2,
      ERR_MESSAGE OUT VARCHAR2)
  AS
    V_PART_SERIAL_NO      VARCHAR2(30);
    V_PART_SERIAL_NO_BY_MIN      VARCHAR2(30);
    V_PART_SERIAL_NO_BY_SIM      VARCHAR2(30);
    V_MIN                 VARCHAR2(30);
    V_SIM             VARCHAR2(30);
    V_CARRIER_NAME        VARCHAR2(300);
    V_CARRIER_MARKET_NAME VARCHAR2(300);
    v_CARRIER_ID          VARCHAR2(300); -- NEW
    V_RULE_OBJID          VARCHAR2(30);
    V_ERR_NUM             VARCHAR2(10);
    V_ERR_MESSAGE         VARCHAR2(300);
  BEGIN
    V_PART_SERIAL_NO      := IP_PART_SERIAL_NO;
    V_MIN                 := IP_MIN;
    V_SIM             := IP_CASE_ID;
    ESN                 := IP_PART_SERIAL_NO;
    ERR_NUM               := '0';
    ERR_MESSAGE           := 'Success';

    IF (V_PART_SERIAL_NO IS NULL AND V_MIN IS NULL AND V_SIM IS NULL) THEN
      ERR_NUM             := '600';
      ERR_MESSAGE         := 'MISSING - ESN/MIN/SIM';
      RETURN;
    END IF;

    IF (V_MIN IS NOT NULL) THEN
      V_PART_SERIAL_NO_BY_MIN     := NVL(ADFCRM_CUST_SERVICE.ESN_BY_MIN(V_MIN),'NOT_FOUND');
      IF (V_PART_SERIAL_NO IS NULL) THEN
        V_PART_SERIAL_NO := LOWER(V_PART_SERIAL_NO_BY_MIN);
      END IF;
      IF (V_PART_SERIAL_NO_BY_MIN <> V_PART_SERIAL_NO) THEN
        ERR_NUM             := '601';
        ERR_MESSAGE         := 'INVALID - ESN/MIN/SIM';
        RETURN;
      END IF;
    END IF;

    IF (V_SIM IS NOT NULL) THEN
      V_PART_SERIAL_NO_BY_SIM     := NVL(ADFCRM_CUST_SERVICE.ESN_BY_SIM(V_SIM),'NOT_FOUND');
      IF (V_PART_SERIAL_NO IS NULL) THEN
        V_PART_SERIAL_NO := LOWER(V_PART_SERIAL_NO_BY_SIM);
      END IF;
      IF (V_PART_SERIAL_NO_BY_SIM <> V_PART_SERIAL_NO) THEN
        ERR_NUM             := '602';
        ERR_MESSAGE         := 'INVALID - ESN/MIN/SIM';
        RETURN;
      END IF;
    END IF;

    BEGIN
      SELECT NVL(P.SUI_RULE_OBJID,
        (SELECT X_PARAM_VALUE
        FROM TABLE_X_PARAMETERS
        WHERE X_PARAM_NAME = 'DEFAULT_SUI_RULE_OBJID'
        ) ) SUI_RULE_OBJID,
        C.X_MKT_SUBMKT_NAME,
        CG.X_CARRIER_NAME,
        c.x_carrier_id
      INTO V_RULE_OBJID,
        V_CARRIER_MARKET_NAME,
        V_CARRIER_NAME,
        v_CARRIER_ID
      FROM TABLE_PART_INST PI_ESN,
        TABLE_PART_INST PI_MIN,
        TABLE_X_PARENT P,
        TABLE_X_CARRIER_GROUP CG,
        TABLE_X_CARRIER C
      WHERE PI_ESN.PART_SERIAL_NO      = V_PART_SERIAL_NO
      AND ROWNUM = 1
      AND PI_ESN.X_DOMAIN              = 'PHONES'
      AND PI_MIN.PART_TO_ESN2PART_INST = PI_ESN.OBJID
      AND PI_MIN.X_DOMAIN              = 'LINES'
      AND PI_MIN.PART_INST2CARRIER_MKT = C.OBJID
      AND C.CARRIER2CARRIER_GROUP      = CG.OBJID
      AND CG.X_CARRIER_GROUP2X_PARENT  = P.OBJID;
    EXCEPTION
    WHEN OTHERS THEN
      ERR_NUM     := '603';
      ERR_MESSAGE := 'INVALID INPUT - NO CARRIER INFO FOUND';
      RETURN;
    END;

    ESN                 := V_PART_SERIAL_NO;
    CARRIER_MARKET_NAME := V_CARRIER_MARKET_NAME;
    CARRIER_NAME        := V_CARRIER_NAME;
    RULE_OBJID          := V_RULE_OBJID;
    CARRIER_ID          := v_CARRIER_ID;

    RETURN;
  END;

--********************************************************************************************************************
function get_4g_sim_status(ip_esn varchar2)
  return varchar2
  is
    v_4g_sim_status varchar2(10);
    v_parent varchar2(10);
  begin
    select sa.util_pkg.get_short_parent_name(sa.util_pkg.get_parent_name(i_esn => ip_esn))
    into v_parent
    from dual;

    if v_parent = 'VZW'
    then
       SELECT  CASE vw.phone_gen WHEN '4G_LTE' THEN 'CN' ELSE NULL END
        INTO   v_4g_sim_status
        FROM   table_part_class pc,
               table_part_num pn,
               pcpv_mv vw,
               table_part_inst pi,
               table_mod_level ml
        WHERE  pc.name                = vw.part_class
        AND    pn.part_num2part_class = pc.objid
        AND    ml.part_info2part_num  = pn.objid
        AND    pi.n_part_inst2part_mod= ml.objid
        AND    pi.part_serial_no      = ip_esn;
    end if;
    return v_4g_sim_status;
  exception
    when others then
      return null;
  end get_4g_sim_status;

--********************************************************************************************************************
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  -- AFTER I MOVED THIS INTO GET_SUI_INQUIRY, DON'T SEE THIS FUNCTION REFERENCED
  -- ANYWHERE IN TAS ANYMORE, I'M ALSO ADDED A NEW INPUT PARAMETER TO TAKE THE
  -- TRANSACTION ID
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  FUNCTION GET_CLARIFY_PROFILE(
      IP_PART_SERIAL_NO IN VARCHAR2,
      IP_RULE_OBJID     IN VARCHAR2,
      ip_transaction_id in varchar2)
    RETURN GET_CLARIFY_TAB PIPELINED
  IS
    --
    CURSOR C_ATTRIBUTES(P_RULE_OBJID IN VARCHAR2)
    IS
      SELECT ATTR_OBJID ,
        ATTR_NAME ,
        DISPLAY_LABEL ,
        PARENT_ATTR_ID ,
        CLARIFY_SQL ,
        CARRIER_VALUE
      FROM ADFCRM_SUI_ATTRIBUTES ATTR
        START WITH ATTR.PARENT_ATTR_ID IS NULL
      AND ATTR.ATTR_OBJID              IN
        (SELECT MTM.ATTR_OBJID
        FROM ADFCRM_SUI_ATTR_MTM MTM
        WHERE MTM.RULE_OBJID = P_RULE_OBJID
        )
      CONNECT BY PRIOR ATTR.ATTR_OBJID = ATTR.PARENT_ATTR_ID;
    V_ERR_NUM NUMBER;
    GET_CLARIFY_PROFILE_RSLT GET_CLARIFY_REC;
    ----------------------------------------------------------------------------
    V_ATTRIBUTE_NAME  VARCHAR2(50);
    V_ATTRIBUTE_VALUE VARCHAR2(300);
	n_policy_id VARCHAR2(300);
	c_data_suspended_flag VARCHAR2(300);
    L_SERVICE_PROFILE_DET sa.ADFCRM_VO.GET_SERVICE_PROFILE_TAB;
    c_sui_display_type_list clob;
  BEGIN
    -- COLLECT THE SUI DISPLAY TYPES
    for i in (select distinct sui_display_type from ig_buckets)
    loop
      c_sui_display_type_list := c_sui_display_type_list||','||i.sui_display_type;
    end loop;

    SELECT * BULK COLLECT
    INTO L_SERVICE_PROFILE_DET
    FROM TABLE (sa.ADFCRM_VO.GET_SERVICE_PROFILE(IP_PART_SERIAL_NO,NULL));
    --
    FOR EACH_REC IN C_ATTRIBUTES(IP_RULE_OBJID)
    LOOP
      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_OBJID := NULL;
      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_VALUE := NULL;
      V_ATTRIBUTE_NAME                         := EACH_REC.ATTR_NAME;
      V_ATTRIBUTE_VALUE                        := EACH_REC.CLARIFY_SQL;
      IF (V_ATTRIBUTE_NAME                      = 'ESN/IMEI/MEID') THEN
        V_ATTRIBUTE_VALUE                      := L_SERVICE_PROFILE_DET(1).PART_SERIAL_NO;
      ELSIF (V_ATTRIBUTE_NAME                  = 'SIM_STATUS_4G') THEN
        V_ATTRIBUTE_VALUE                      := ADFCRM_SUI_VO.get_4g_sim_status(ip_esn => IP_PART_SERIAL_NO);
      ELSIF (V_ATTRIBUTE_NAME                   = 'ESN HEX' AND L_SERVICE_PROFILE_DET(1).X_HEX_SERIAL_NO IS NOT NULL) THEN
        V_ATTRIBUTE_VALUE                      := L_SERVICE_PROFILE_DET(1).X_HEX_SERIAL_NO;
  	  ELSIF (V_ATTRIBUTE_NAME                   = 'ESN HEX' AND L_SERVICE_PROFILE_DET(1).X_HEX_SERIAL_NO IS NULL) THEN
        V_ATTRIBUTE_VALUE                      := IGATE.F_GET_HEX_ESN(IP_PART_SERIAL_NO);
      ELSIF (V_ATTRIBUTE_NAME                   = 'MIN') THEN
        V_ATTRIBUTE_VALUE                      := L_SERVICE_PROFILE_DET(1).X_MIN;
      ELSIF (V_ATTRIBUTE_NAME                   = 'MSID') THEN
        V_ATTRIBUTE_VALUE                      := L_SERVICE_PROFILE_DET(1).X_MSID;
      ELSIF (V_ATTRIBUTE_NAME                   = 'SIM') THEN
        V_ATTRIBUTE_VALUE                      := L_SERVICE_PROFILE_DET(1).SIM;
      ELSIF (V_ATTRIBUTE_NAME                   = 'BRAND') THEN
        V_ATTRIBUTE_VALUE                      := L_SERVICE_PROFILE_DET(1).BRAND;
      ELSIF (V_ATTRIBUTE_NAME                   = 'SERVICE PLAN') THEN
        V_ATTRIBUTE_VALUE                      := L_SERVICE_PROFILE_DET(1).SERVICE_TYPE;
      ELSIF (V_ATTRIBUTE_NAME                   = 'RATE PLAN') THEN
        V_ATTRIBUTE_VALUE                      := L_SERVICE_PROFILE_DET(1).RATE_PLAN;
      ELSIF (V_ATTRIBUTE_NAME                   = 'DUE DATE') THEN
        V_ATTRIBUTE_VALUE                      := L_SERVICE_PROFILE_DET(1).X_EXPIRE_DT;
      ELSIF (V_ATTRIBUTE_NAME                   = 'DEVICE TYPE') THEN
        V_ATTRIBUTE_VALUE                      := L_SERVICE_PROFILE_DET(1).DEVICE_TYPE;
      ELSIF (V_ATTRIBUTE_NAME                   = 'OS') THEN
        V_ATTRIBUTE_VALUE                      := GET_PARAM_BY_NAME_FUN(L_SERVICE_PROFILE_DET(1).CLASS_NAME,'OPERATING_SYSTEM') ;
      ELSIF (V_ATTRIBUTE_NAME                   = 'SITE PART STATUS') THEN
        V_ATTRIBUTE_VALUE                      := UPPER(L_SERVICE_PROFILE_DET(1).PART_STATUS);
      ELSIF instr(c_sui_display_type_list,V_ATTRIBUTE_NAME)>0 then
        V_ATTRIBUTE_VALUE                      := get_bucket_val(ip_transaction_id,V_ATTRIBUTE_NAME);
      ELSIF (V_ATTRIBUTE_NAME                   = 'THROTTLE STATE') THEN

	 BEGIN
		SELECT policy_id
		INTO   n_policy_id
		FROM   ( SELECT x_policy_id policy_id
				 FROM   w3ci.table_x_throttling_cache
				 WHERE  x_esn = IP_PART_SERIAL_NO
				 AND    x_status IN ('P','A')
				 ORDER BY objid DESC
			   )
		WHERE  ROWNUM = 1;
	  EXCEPTION
		 WHEN others THEN
		   n_policy_id := NULL;
	  END;

	  DBMS_OUTPUT.PUT_LINE ( 'n_policy_id : ' || n_policy_id );

	  -- if the customer is throttled (or data was suspended)
	  IF n_policy_id IS NOT NULL THEN
		-- get the data suspended flag from the policy
		BEGIN
		  SELECT NVL(data_suspended_flag,'N')
		  INTO   c_data_suspended_flag
		  FROM   w3ci.table_x_throttling_policy
		  WHERE  objid = n_policy_id;
		 EXCEPTION
		   WHEN others THEN
			 c_data_suspended_flag := 'N';
					END;
		-- if the data was suspended set the flag as data suspended
					IF c_data_suspended_flag = 'Y' THEN
					  V_ATTRIBUTE_VALUE := 'DATA SUSPENDED';
					ELSE
		  -- set as throttled
		  V_ATTRIBUTE_VALUE := 'THROTTLED';
		END IF;
	  ELSE
		-- set as not throttled
		V_ATTRIBUTE_VALUE := 'NOT THROTTLED';
	  END IF;



      ELSIF (V_ATTRIBUTE_NAME                   = 'PORT STATUS') THEN
            BEGIN
              SELECT CASE_TYPE_LVL3
              INTO V_ATTRIBUTE_VALUE
              FROM TABLE_CASE TCASE, TABLE_CONDITION TC
                WHERE
                  UPPER(TCASE.TITLE) = 'PORT IN'
                  AND TCASE.CASE_STATE2CONDITION = TC.OBJID
                  AND TCASE.X_ESN = IP_PART_SERIAL_NO
                  AND ROWNUM = 1
                  AND TC.TITLE = 'Closed';
            EXCEPTION
            WHEN OTHERS THEN
              V_ATTRIBUTE_VALUE := 'N/A';
            END;
      END IF;
      V_ATTRIBUTE_NAME                         := EACH_REC.ATTR_OBJID;
      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_VALUE := V_ATTRIBUTE_VALUE;
      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_OBJID := V_ATTRIBUTE_NAME;
      PIPE ROW (GET_CLARIFY_PROFILE_RSLT);
    END LOOP;
    --
  EXCEPTION
  WHEN OTHERS THEN
    NULL;
  END GET_CLARIFY_PROFILE;

  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  -- I DON'T SEE THIS FUNCTION CALLED ANYWHERE IN TAS
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
--  FUNCTION GET_CARRIER_PROFILE(
--      IP_TRANSACTION_ID IN VARCHAR2)
--    RETURN GET_CLARIFY_TAB PIPELINED
--  IS
--    --
--    V_ERR_NUM NUMBER;
--    GET_CLARIFY_PROFILE_RSLT GET_CLARIFY_REC;
--    ----------------------------------------------------------------------------
--    V_ATTRIBUTE_NAME  VARCHAR2(50);
--    V_ATTRIBUTE_VALUE VARCHAR2(300);
--  BEGIN
--    FOR L_SERVICE_PROFILE_DET IN
--    (SELECT ACTION_ITEM_ID ,
--      CARRIER_ID ,
--      ORDER_TYPE ,
--      MIN ,
--      ESN ,
--      ESN_HEX ,
--      PHONE_MANF ,
--      RATE_PLAN ,
--      STATUS ,
--      STATUS_MESSAGE ,
--      TRANSACTION_ID ,
--      TECHNOLOGY_FLAG ,
--      MSID ,
--      ICCID ,
--      EXP_DATE
--    FROM GW1.IG_TRANSACTION
--    WHERE TRANSACTION_ID = IP_TRANSACTION_ID
--    )
--    LOOP
--      V_ATTRIBUTE_NAME                         := 'ESN/IMEI/MEID';
--      V_ATTRIBUTE_VALUE                        := L_SERVICE_PROFILE_DET.ESN;
--      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_VALUE := V_ATTRIBUTE_VALUE;
--      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_OBJID := V_ATTRIBUTE_NAME;
--      PIPE ROW (GET_CLARIFY_PROFILE_RSLT);
--      V_ATTRIBUTE_NAME                         := 'ESN HEX';
--      V_ATTRIBUTE_VALUE                        := L_SERVICE_PROFILE_DET.ESN_HEX;
--      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_VALUE := V_ATTRIBUTE_VALUE;
--      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_OBJID := V_ATTRIBUTE_NAME;
--      PIPE ROW (GET_CLARIFY_PROFILE_RSLT);
--      V_ATTRIBUTE_NAME                         := 'MIN';
--      V_ATTRIBUTE_VALUE                        := L_SERVICE_PROFILE_DET.MIN;
--      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_VALUE := V_ATTRIBUTE_VALUE;
--      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_OBJID := V_ATTRIBUTE_NAME;
--      PIPE ROW (GET_CLARIFY_PROFILE_RSLT);
--      V_ATTRIBUTE_NAME                         := 'MSID';
--      V_ATTRIBUTE_VALUE                        := L_SERVICE_PROFILE_DET.MSID;
--      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_VALUE := V_ATTRIBUTE_VALUE;
--      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_OBJID := V_ATTRIBUTE_NAME;
--      PIPE ROW (GET_CLARIFY_PROFILE_RSLT);
--      V_ATTRIBUTE_NAME                         := 'SIM';
--      V_ATTRIBUTE_VALUE                        := L_SERVICE_PROFILE_DET.ICCID;
--      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_VALUE := V_ATTRIBUTE_VALUE;
--      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_OBJID := V_ATTRIBUTE_NAME;
--      PIPE ROW (GET_CLARIFY_PROFILE_RSLT);
--      V_ATTRIBUTE_NAME                         := 'RATE PLAN';
--      V_ATTRIBUTE_VALUE                        := L_SERVICE_PROFILE_DET.RATE_PLAN;
--      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_VALUE := V_ATTRIBUTE_VALUE;
--      GET_CLARIFY_PROFILE_RSLT.ATTRIBUTE_OBJID := V_ATTRIBUTE_NAME;
--      PIPE ROW (GET_CLARIFY_PROFILE_RSLT);
--    END LOOP;
--  END GET_CARRIER_PROFILE;

  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  -- I DON'T SEE THIS FUNCTION CALLED ANYWHERE IN TAS
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
--  PROCEDURE VERIFY_SUI_TRANSACTION(
--      IP_TRANSACTION_ID IN VARCHAR2,
--      OP_TRANSACTION_ID OUT VARCHAR2,
--      ERR_NUM OUT VARCHAR2,
--      ERR_MESSAGE OUT VARCHAR2)
--    IS
--      I_ESN VARCHAR2(200);
--      I_MIN VARCHAR2(200);
--      I_STATUS VARCHAR2(200);
--      I_CASE_ID NUMBER;
--      I_ORDER_TYPE VARCHAR2(200);
--      I_SOURCE_SYSTEM VARCHAR2(200);
--      O_CALL_TRANS_OBJID NUMBER;
--      O_TASK_OBJID NUMBER;
--
--    BEGIN
--
--      OP_TRANSACTION_ID := IP_TRANSACTION_ID;
--      ERR_NUM := '0';
--      ERR_MESSAGE := 'SUCCESS';
--
--      BEGIN
--        SELECT ORDER_TYPE,STATUS,ESN,MIN
--        INTO I_ORDER_TYPE, I_STATUS,I_ESN,I_MIN
--        FROM GW1.IG_TRANSACTION
--          WHERE TRANSACTION_ID = IP_TRANSACTION_ID;
--      EXCEPTION
--      WHEN OTHERS THEN
--        ERR_NUM := '501';
--        ERR_MESSAGE := 'INVALID TRANSACTION ID - ORDER NOT FOUND';
--        RETURN;
--      END;
--
--      IF I_STATUS NOT IN ('S','W') THEN
--        ERR_NUM := '502';
--        ERR_MESSAGE := 'ORDER PENDING';
--        RETURN;
--      END IF;
--
--      IF I_STATUS IN ('S','W') AND I_ORDER_TYPE = 'UI' THEN
--        ERR_NUM := '0';
--        ERR_MESSAGE := 'SUCCESS';
--        RETURN;
--      END IF;
--
--      IF I_STATUS IN ('S','W') AND I_ORDER_TYPE <> 'UI' THEN
--          BEGIN
--            I_ESN := I_ESN;
--            I_MIN := I_MIN;
--            I_CASE_ID := NULL;
--            I_ORDER_TYPE := 'UI';
--            I_SOURCE_SYSTEM := 'TAS';
--
--            SA.SUI_PKG.CREATE_SUI_ORDER(
--              I_ESN => I_ESN,
--              I_MIN => I_MIN,
--              I_CASE_ID => I_CASE_ID,
--              I_ORDER_TYPE => I_ORDER_TYPE,
--              I_SOURCE_SYSTEM => I_SOURCE_SYSTEM,
--              O_CALL_TRANS_OBJID => O_CALL_TRANS_OBJID,
--              O_TASK_OBJID => O_TASK_OBJID,
--              O_TRANSACTION_ID => OP_TRANSACTION_ID,
--              O_ERRORCODE => ERR_NUM,
--              O_ERRORMSG => ERR_MESSAGE
--            );
--
--            ERR_NUM := '502';
--            ERR_MESSAGE := 'ORDER PENDING';
--
--          END;
--        END IF;
--  END VERIFY_SUI_TRANSACTION;

END ADFCRM_SUI_VO;
-- ANTHILL_TEST PLSQL/SA/PackageBodies/ADFCRM_SUI_VO_PKB.sql 	CR51375: 1.7
/