CREATE OR REPLACE FUNCTION sa."ADFCRM_RET_ESN_INFO" (ip_esn in varchar2)
return adfcrm_esn_structure is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_RET_ESN_INFO.sql,v $
--$Revision: 1.14 $
--$Author: hcampano $
--$Date: 2015/03/05 21:34:32 $
--$ $Log: ADFCRM_RET_ESN_INFO.sql,v $
--$ Revision 1.14  2015/03/05 21:34:32  hcampano
--$ TAS_2015_06 - For the H350 Upgrade
--$
--$ Revision 1.13  2015/02/09 15:45:35  hcampano
--$ TAS_2015_04 - Fixes to make sure OTA devices that don't have a keypad are registered as OTA for balance inq not SWITCH_BASED
--$
--$ Revision 1.12  2014/10/15 21:47:06  mmunoz
--$ replacing service_plan_flat_summary for adfcrm_serv_plan_class_matview
--$
--$ Revision 1.11  2014/05/09 16:49:54  mmunoz
--$ Added esn_type, hide_min and hide_sim
--$
--$ Revision 1.10  2014/04/29 18:14:21  hcampano
--$ Development change added Balance Metering param to see if phone is surepay - TAS - TAS_2014_03
--$
--$ Revision 1.9  2014/04/16 18:04:09  hcampano
--$ Prioritizing the Balance inquiry for ppe handsets if it's a Switch Based Service Plan over OTA. - Defect 239 for release TAS_2014_02
--$
--$ Revision 1.8  2014/03/19 13:36:52  hcampano
--$ Added Contact Parent Objid (new return param) for New Upgrade Flow.
--$
--$ Revision 1.7  2013/10/14 20:56:47  mmunoz
--$ CR25435: Added service plan group check and is_hotspot
--$
--$ Revision 1.6  2013/09/09 16:51:39  hcampano
--$ SurePay Update - Added param to control balance inq requests.
--$
--$ Revision 1.5  2013/09/07 15:41:19  hcampano
--$ SurePay Update - Removed error check on switch based flag.
--$
--$ Revision 1.4  2013/08/28 18:04:40  hcampano
--$ Removed program query from view and function.
--$
--$ Revision 1.3  2013/08/27 14:54:38  hcampano
--$ Added Operating System to RetEsn Func
--$
--$ Revision 1.2  2013/08/10 00:39:29  mmunoz
--$ CR24397
--$
--$ Revision 1.1  2013/08/07 19:14:30  mmunoz
--$ CR24397 NET10 Family Plans
--$
--------------------------------------------------------------------------------------------
  esn_tab  sa.adfcrm_esn_structure := sa.adfcrm_esn_structure();
  v_pc varchar2(30) := null;
  v_org varchar2(30) := null;
  v_bi_type varchar2(50); -- THIS WILL DETERMINE IF THE PHONE IS OTA,SWITCH_BASED OR UNLIMITED/DATA
  v_svc_plan_id varchar2(50);
  v_sb_flag varchar2(30);
  v_unlimited_or_data_flag varchar2(30);
  v_ppe_flag varchar2(30);
  v_ota_flag varchar2(30);
  v_min varchar2(30);
  v_view_name varchar2(30) := 'ADFCRM_ESN_STRUCTURE_VIEW';
  this_value varchar2(300) := null;
  v_date_interval number;
  b_missing_key_pad_flag boolean := false;

  cursor c1 is
    select column_name
    from user_tab_columns dtc
    where dtc.table_name = v_view_name;

begin

  begin
    select to_number(x_param_value)
    into v_date_interval
    from table_x_parameters
    where x_param_name = 'ADFCRM_REF_BAL_INQ_INTERVAL';
  exception
    when others then
      v_date_interval := 10/(24*60);
  end;

  begin
    for i in c1 loop
      execute immediate 'select '||i.column_name||' from sa.'||v_view_name||' where part_serial_no = :ip_esn ' into this_value using ip_esn;
      if i.column_name = 'PART_CLASS' then
        v_pc := this_value;
      elsif i.column_name = 'ORG_ID' then
        v_org := this_value;
      end if;
      if i.column_name = 'SVC_PLAN_ID' then
        if this_value is null then
          this_value := '*** NO SERVICE PLAN ***';
        else
          v_svc_plan_id := this_value;
        end if;
      end if;
      if i.column_name = 'MIN' then
        v_min := this_value;
      end if;
      if this_value is not null then
        esn_tab.extend;
        esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type(i.column_name, this_value);
      end if;
    end loop;

    for i in (select count(*) cnt
              from   table_case c,
                     table_condition cn
              where  1=1
              and    c.case_state2condition = cn.objid
              and    c.x_esn = ip_esn
              and    cn.s_title like 'OPEN%'
              and    c.s_title = 'SIM CARD EXCHANGE'
              and    c.x_case_type = 'Technology Exchange')
    loop
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('SIM_CARD_CASE',i.cnt);
    end loop;

    -- QUERY CHECK AGAINST SERVICE PLANS
    /***for i in (select sp_mkt_name, fea_name,fea_value,fea_display
                     ,SA.GET_SERV_PLAN_VALUE(SP_OBJID,'SERVICE_PLAN_GROUP') service_plan_group
              FROM service_plan_flat_summary
              WHERE part_class_name =  v_pc
              and sp_objid =  v_svc_plan_id
              and fea_name in ('SWITCH BASED','VOICE'))
    ***/
    for i in (SELECT spmv.sp_mkt_name, featmv.fea_name,featmv.fea_value,featmv.fea_display
                     ,sa.adfcrm_get_serv_plan_value(spmv.SP_OBJID,'SERVICE_PLAN_GROUP') service_plan_group
              FROM sa.adfcrm_serv_plan_class_matview  spmv
                  ,sa.adfcrm_serv_plan_feat_matview featmv
              WHERE spmv.part_class_name = v_pc
              AND spmv.sp_objid = v_svc_plan_id
              AND featmv.sp_objid = spmv.sp_objid
              and featmv.fea_name in ('SWITCH BASED','VOICE'))
    loop
      if i.fea_name = 'VOICE' and i.fea_value = '0'
         and (i.service_plan_group like '%UNLIMITED%' OR
              i.service_plan_group like '%VOICE_ONLY%')
      then
        v_unlimited_or_data_flag := i.fea_value;
        esn_tab.extend;
        esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('SERVICE_PLAN_FEA VOICE',i.fea_display);
      elsif i.fea_name = 'SWITCH BASED' then
        v_sb_flag := i.fea_value;
        esn_tab.extend;
        esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('SERVICE_PLAN SWITCH BASED',i.fea_value);
      end if;
    end loop;

    -- NEXT QUERY PART CLASS PARAMS
    for i in (select decode(param_name,'NON_PPE','IS_PPE',param_name) param_name,decode(param_name,'NON_PPE',decode(param_value,'1','NO','0','YES',param_value),param_value) param_value
              from   pc_params_view
              where  part_class = v_pc -- 'NTBYOPC4'
              and    param_name in ('DEVICE_TYPE','NON_PPE','DLL','OTA_ALLOWED','BUS_ORG','TECHNOLOGY','OPERATING_SYSTEM','BALANCE_METERING','HAS_KEYPAD','MODEL_TYPE'))
    loop
      if i.param_name = 'OTA_ALLOWED' then
        v_ota_flag := i.param_value;
      elsif i.param_name = 'IS_PPE' then
        v_ppe_flag :=  i.param_value;
      end if;
      -- DONE FOR HOTSPOT 289 WHICH IS OTA AND HAS NO KEYPAD
      if i.param_name = 'HAS_KEYPAD' and i.param_value = 'N' then
      	b_missing_key_pad_flag := true;
      end if;
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('PC_PARAMS '||i.param_name,i.param_value);
    end loop;

    for i in (select count(swbtx.status) counter,
                     swbtx.status, swbtx.x_type cp_type
              from   sa.table_x_call_trans calltx,
                     sa.x_switchbased_transaction swbtx
              where  calltx.objid =  swbtx.x_sb_trans2x_call_trans
              and    calltx.x_service_id = ip_esn
              and    swbtx.status = 'CarrierPending'
              group by swbtx.status, swbtx.x_type)
    loop
      dbms_output.put_line('=========================================================================================');
      if i.counter is not null then
        esn_tab.extend;
        esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('CARRIER_PENDING ('||i.cp_type||')',i.counter);
      end if;
      if i.status is not null then
        esn_tab.extend;
        esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('CARRIER_PENDING_STATUS',i.status);
      end if;
    end loop;

    -- BUILD THE STRUCTURE VALUE RULES
    if v_unlimited_or_data_flag = '0' then
      v_bi_type := 'UNLIMITED_OR_DATA_ONLY';
    else
      -- THIS IS A SMARTPHONE
      if v_ppe_flag = 'NO' then
        -- REMOVED SERVICE PLAN FLAT TABLE COMPATIBILTY CHECK
        --if v_sb_flag = 'YES' then
          v_bi_type := 'SWITCH_BASED';
        --else
        --  v_bi_type := 'ERROR_SMARTPHONE';
        --end if;
      end if;

      -- THIS IS A PREPAID_PHONE (MOST TF HANDSETS ARE NON_PPE)
      if v_ppe_flag = 'YES' then
        -- THIS KEY PAD FLAG IS A NEW IMPLEMENATION THAT
        -- STARTED 2/2015 DUE TO DEVICES THAT DO NOT HAVE A KEYPAD
        -- WE'RE USING THIS LOGIC AS A TEMP FIX TO VALIDATE (FOR Z289)
        -- ALONG SIDE THE OTA FLAG TO DETERMINE, IF IT'S OTA OR SWITCHBASED
        -- NEEDS TO BE REVISITED DUE TO THE FACT THAT SERVICE PLANS
        -- SHOULD NOT DETERMINE IF IT'S SWITCH BASED OR OTA ANYMORE,
        -- THIS SHOULD BE DETERMINED BY THE CARRIER
      	if b_missing_key_pad_flag and v_ota_flag = 'Y' then
            v_bi_type := 'OTA';
      	else
          if v_sb_flag = 'YES' then
            v_bi_type := 'SWITCH_BASED';
          elsif v_ota_flag = 'Y' then
            v_bi_type := 'OTA';
          else
            v_bi_type := 'ERROR_PREPAID';
          end if;
	    end if;
      end if;
    end if;

    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('BALANCE_INQ_TYPE', v_bi_type); --'OTA');

    -- GET THE OBJID FROM TABLE_X_OTA_TRANSACTION OR TABLE_X_CALL_TRANS
    if v_bi_type = 'OTA' then
      for i in (select objid
                from   table_x_ota_transaction
                where  x_esn = ip_esn
                and    x_reason = 'OTA INQUIRY'
                and    x_transaction_date between sysdate-v_date_interval and sysdate
                and    rownum < 2
                order by x_transaction_date desc)
      loop
          esn_tab.extend;
          esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('OTA_TRANS_ID',i.objid);
      end loop;
    elsif v_bi_type = 'SWITCH_BASED' then
      for i in (select objid
                from   table_x_call_trans
                where  x_service_id = ip_esn
                and    x_min = v_min
                and    x_reason = 'Balance Inquiry'
                and    x_transact_date between sysdate-v_date_interval and sysdate
                and    rownum < 2
                order by x_transact_date desc)
      loop
          esn_tab.extend;
          esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('SWITCHBASED_CALL_TRANS_ID',i.objid);
      end loop;
    end if;
    /*********************************
     ***  Check if ESN is hotspot ****
     *********************************/
    for i in ( SELECT
                     DECODE(sa.device_util_pkg.IS_HOTSPOTS(ip_esn),0,'YES','NO') IS_HOTSPOT
               FROM DUAL)
    loop
      esn_tab.extend;
      esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('IS_HOTSPOT',i.IS_HOTSPOT);
    end loop;
  end;

  for i in (select x_contact_part_inst2contact
            from   table_x_contact_part_inst
            where   x_contact_part_inst2part_inst in (select objid from table_part_inst
                                                      where part_serial_no in (ip_esn)))
  loop
    esn_tab.extend;
    esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('CONTACT_PARENT_OBJID',i.x_contact_part_inst2contact);
  end loop;

  /************************************
  /**  From sa.adfcrm_cust_service ****
  *************************************/
  esn_tab.extend;
  esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('ESN_TYPE',sa.adfcrm_cust_service.esn_type(ip_esn));
  esn_tab.extend;
  esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('HIDE_MIN',sa.adfcrm_cust_service.hide_min(ip_esn));
  esn_tab.extend;
  esn_tab(esn_tab.last) := adfcrm_esn_structure_row_type('HIDE_SIM',sa.adfcrm_cust_service.hide_sim(ip_esn));

  return esn_tab;
end ADFCRM_RET_ESN_INFO;
/