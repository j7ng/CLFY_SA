CREATE OR REPLACE PACKAGE BODY sa."ADFCRM_CUST_SERVICE" is
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_CUST_SERVICE_PKB.sql,v $
--$Revision: 1.94 $
--$Author: epaiva $
--$Date: 2018/02/12 17:00:19 $
--$ $Log: ADFCRM_CUST_SERVICE_PKB.sql,v $
--$ Revision 1.94  2018/02/12 17:00:19  epaiva
--$ REL947 - Regression defect#36811
--$
--$ Revision 1.93  2018/01/19 14:32:00  pkapaganty
--$ SMMLD Pre Merge to REL945
--$
--$ Revision 1.92  2018/01/16 18:12:29  mmunoz
--$ CR53924  Display informaction related with Account Customer ID. and for WFM display both account pin and member pin.
--$
--$ Revision 1.91  2018/01/11 22:15:15  epaiva
--$ CR52120 SMMLD WF pin changes for WFM & SM brand
--$
--$ Revision 1.90  2018/01/10 17:12:12  mmunoz
--$ CR53924 TAS Identity Challenge Page Clean up, fixed space
--$
--$ Revision 1.89  2018/01/09 14:32:25  mmunoz
--$ CR53924 TAS Identity Challenge Page Clean up, merged with prod. 1.88
--$
--$ Revision 1.88  2018/01/05 19:34:50  epaiva
--$ CR54687 WF Pins status for pay or non pay go plans
--$
--$ Revision 1.87  2018/01/05 16:50:17  epaiva
--$ CR54687 WF Pin status based on paygo or non pay go plans
--$
--$ Revision 1.84  2017/12/07 17:12:13  epaiva
--$ CR54687 Workforce pin status changes for paygo or non paygo plans
--$
--$ Revision 1.83  2017/10/19 14:59:28  syenduri
--$ CR52306- Passing esn to min_by_esn_cur - it required if ESN is not coming as IN param
--$
--$ Revision 1.82  2017/10/10 14:14:35  syenduri
--$ Merge REL902 changes into REL904
--$
--$ Revision 1.81  2017/10/05 15:03:41  syenduri
--$ CR52306 - Customer Purchase confirmation for TAS Transactions
--$
--$ Revision 1.80  2017/09/29 20:27:38  syenduri
--$ CR52306 Customer Purchase confirmation for TAS Transactions
--$
--$ Revision 1.79  2017/09/22 17:42:49  syenduri
--$ CR53274 WF PIN Ticket Update
--$
--$ Revision 1.78  2017/09/13 23:34:00  syenduri
--$ CR50956 - Workforce Pin Changes
--$
--$ Revision 1.75  2017/07/26 18:14:20  mmunoz
--$ CR49354 Function IS_SUREPAY_TECH_CASE overloaded, new parameter ip_transfer_min
--$
--$ Revision 1.74  2017/06/13 21:33:27  pkapaganty
--$ CR49838 - Fix for issue with TASK and IG creation during SIM change flow. action_item created in call IGATE.SP_CREATE_ACTION_ITEM is not found in next call IGATE.CALL_SP_DETERMINE_TRANS_METHOD.
--$
--$ Revision 1.73  2017/03/16 20:44:26  mmunoz
--$ Updated COMP_THRESHOLD, adding nvl in cursor agent_cur
--$
--$ Revision 1.72  2016/05/23 18:14:51  nguada
--$ CR42611
--$
--$ Revision 1.71  2016/04/11 16:10:08  mmunoz
--$ Return always false in block_promo_esn_upgrade.
--$
--$ Revision 1.70  2016/01/15 21:23:09  hcampano
--$ CR39389
--$
--$ Revision 1.69  2016/01/13 20:58:21  nguada
--$ CR 40373 - TRACFONE excluded from block_promo_esn_upgrade validation
--$
--$ Revision 1.68  2015/12/09 20:51:29  nguada
--$ CR39214 Upgrade Exchanges Fix
--$
--$ Revision 1.67  2015/11/23 19:41:52  syenduri
--$ TAS_2015_24 - CR37898 - TAS Upgrade Phone Model Script Correction
--$
--$ Revision 1.66  2015/11/03 14:48:20  hcampano
--$ CR39160 - TF TAS Upgrade Error when Old Phone has no My Account (Fixed issue where Service Profile goes blank if more than 9 ota pendings exist)
--$
--$ Revision 1.65  2015/07/22 20:40:08  mmunoz
--$ CR35336 updated call for  SP_SWB_CARR_RATE_PLAN passing old esn instead of new esn
--$
--$ Revision 1.64  2015/07/15 21:42:07  mmunoz
--$ CR35336 Updated function is_surepay_tech_case to check if it is ATT Carrier switch (Ericsson Prepaid System) then return UPGRADE_ATT_SWITCH
--$
--$ Revision 1.63  2015/06/30 20:31:34  hcampano
--$ CR34349 - New domain type "ALL" for certain cases that need to have both sim and phones returned during the case creation. TAS_2015_13
--$
--$ Revision 1.62  2015/03/18 18:45:40  nguada
--$ 31622    Upgrade Validations /  changes to is_sp_compatible to use ivr_id
--$
--$ Revision 1.61  2015/02/24 21:55:51  hcampano
--$ TAS_2015_05 - Changed hide_balance - removed logic that hid the balance for hotspots.
--$
--$ Revision 1.60  2015/02/16 17:22:09  nguada
--$ workforce pin fix
--$
--$ Revision 1.59  2015/01/29 21:04:25  hcampano
--$ TAS_2015_05 - CR30854 - Hotspot Z289L TAS Upgrades
--$
--$ Revision 1.58  2014/12/04 19:09:01  nguada
--$ upgrade_is_pin_required changed to use ivr_plan_id as compatibility check
--$
--$ Revision 1.57  2014/11/20 19:48:33  nguada
--$ Upgrade validation changes, using canenroll function from billing.
--$
--$ Revision 1.55  2014/11/12 18:05:09  nguada
--$  function change upgrade_is_pin_required change to use 'SERVICE_PLAN_GROUP'
--$
--$ Revision 1.54  2014/10/23 22:11:48  hcampano
--$ TAS_2014_09B
--$
--$ Revision 1.53  2014/10/23 20:20:47  hcampano
--$ TAS_2014_9B
--$
--$ Revision 1.52  2014/10/22 20:55:16  hcampano
--$ TAS_2014_10A
--$
--$ Revision 1.51  2014/10/15 22:14:27  nguada
--$ comp_threshold added.
--$
--$ Revision 1.50  2014/10/15 21:29:54  mmunoz
--$ replacing service_plan_flat_summary for adfcrm_serv_plan_class_matview
--$
--$ Revision 1.49  2014/10/01 20:14:57  mmunoz
--$ removing duplicate code
--$
--$ Revision 1.48  2014/10/01 17:35:55  nguada
--$ cross carrier sim change bug fix
--$
--$ Revision 1.47  2014/10/01 14:03:17  nguada
--$ bug fix for create_site_part_call_trans
--$
--$ Revision 1.46  2014/09/30 14:37:25  nguada
--$ Bug fix cross carrier sim change.
--$
--$ Revision 1.45  2014/09/29 18:34:55  nguada
--$ added update of call_trans into the sim exch case
--$
--$ Revision 1.44  2014/09/26 13:44:28  nguada
--$ Action type switched to reactivation for procedure create_site_part_call_trans
--$
--$ Revision 1.43  2014/09/22 20:46:35  hcampano
--$ TAS_2014_08B - Handset release 9/25
--$
--$ Revision 1.42  2014/09/18 16:18:51  hcampano
--$ TAS_2014_08B - Handset release 9/25
--$
--$ Revision 1.41  2014/09/18 14:55:50  nguada
--$ Bug fixes
--$
--$ Revision 1.40  2014/09/18 14:51:04  hcampano
--$ TAS_2014_08B - Handset release 9/25
--$
--$ Revision 1.39  2014/09/18 14:04:20  hcampano
--$ TAS_2014_08B - Handset release 9/25
--$
--$ Revision 1.38  2014/09/16 19:02:25  hcampano
--$ TAS_2014_09 - Update to hide_min function.
--$
--$ Revision 1.37  2014/09/16 18:17:51  nguada
--$ cross carrier sim change, keep min
--$
--$ Revision 1.36  2014/09/06 00:44:55  mmunoz
--$ added  procedure cross_carrier_sim_change
--$
--$ Revision 1.35  2014/09/05 23:24:15  mmunoz
--$ Added  check for RECURRING_SERVICE_PLAN feature
--$
--$ Revision 1.34  2014/08/26 20:37:27  mmunoz
--$ using materialized view
--$
--$ Revision 1.33  2014/08/25 15:39:05  mmunoz
--$ Changes in function is_sp_compatible
--$
--$ Revision 1.32  2014/08/25 13:49:51  mmunoz
--$ hide_min commented code that is not used
--$
--$ Revision 1.31  2014/07/31 13:32:18  hcampano
--$ TAS_2014_06 - Changes to PromoPinTool
--$
--$ Revision 1.30  2014/07/24 13:14:58  hcampano
--$ TAS_2014_06 - PinPromoTool
--$
--$ Revision 1.29  2014/07/23 21:42:57  hcampano
--$ TAS_2014_06 - PinPromoTool permission
--$
--$ Revision 1.28  2014/07/22 13:31:48  nguada
--$ Hide Balance added
--$
--$ Revision 1.27  2014/07/21 15:47:28  mmunoz
--$ updated hide_min to return false for HOTSPOT GSM
--$
--$ Revision 1.26  2014/07/16 17:01:45  hcampano
--$ 7/2014 TAS release (TAS_2014_06) validate_promo_tool. CR29272
--$
--$ Revision 1.25  2014/06/30 18:51:59  hcampano
--$ Updating for TAS_2014_05 rollout
--$
--$ Revision 1.24  2014/06/30 14:19:09  mmunoz
--$ Added function UPD_PORT_IN_FLAG
--$
--$ Revision 1.23  2014/06/24 14:16:58  hcampano
--$ Fixing defects TAS_2014_05
--$
--$ Revision 1.22  2014/06/20 18:08:22  nguada
--$ bug fix
--$
--$ Revision 1.21  2014/06/19 19:14:43  nguada
--$ Bug Fix,  Upgrade Project
--$
--$ Revision 1.20  2014/06/17 15:34:46  nguada
--$ block_promo_esn_upgrade
--$
--$ Revision 1.19  2014/06/02 13:33:53  mmunoz
--$ added Pn.x_dll in cursor
--$
--$ Revision 1.18  2014/06/02 13:22:25  mmunoz
--$ changes in upgrade_is_pin_required
--$
--$ Revision 1.17  2014/05/30 22:05:54  mmunoz
--$ Changes in is_manual_code_required
--$
--$ Revision 1.16  2014/05/21 18:22:29  hcampano
--$ added sp_enrollment_compatible func and updated upgrade_is_pin_required
--$
--$ Revision 1.15  2014/05/20 21:41:22  nguada
--$ upgrade_is_pin_required expanded to all brands
--$
--$ Revision 1.14  2014/05/19 23:54:37  mmunoz
--$ is_manual_code_required logic updated
--$
--$ Revision 1.13  2014/05/09 22:32:33  mmunoz
--$ Added CDMA check in hide_sim
--$
--$ Revision 1.12  2014/05/09 16:52:09  mmunoz
--$ Added function hide_sim
--$
--$ Revision 1.11  2014/05/08 22:08:00  mmunoz
--$ Changes in is_manual_code_required
--$
--$ Revision 1.10  2014/05/08 16:20:07  mmunoz
--$ updated function is_manual_code_required
--$
--$ Revision 1.9  2014/05/06 20:12:22  mmunoz
--$ TAS_2014_03
--$
--$ Revision 1.8  2014/05/05 15:13:50  mmunoz
--$ New functions is_manual_code_required and min_by_esn
--$
--$ Revision 1.7  2014/03/27 20:17:25  mmunoz
--$ Calling VALUE_ADDEDPRG functions
--$
--$ Revision 1.6  2014/03/14 18:20:42  mmunoz
--$ CR26941
--$
--$ Revision 1.5  2014/02/18 20:00:02  hcampano
--$ Adding workforce ild pin function
--$
--$ Revision 1.4  2014/01/09 15:30:52  mmunoz
--$ CR26679
--$
--$ Revision 1.3  2014/01/03 16:46:49  mmunoz
--$ CR26679  fixing case detail label
--$
--$ Revision 1.2  2013/12/16 15:35:40  nguada
--$ CR26679
--$
--$ Revision 1.1  2013/12/06 19:55:24  mmunoz
--$ CR26679  TAS Various Enhancments
--$
--------------------------------------------------------------------------------------------
  cursor get_esn_info (p_esn varchar2) is
            select pn.part_number,
                   pc.name part_class,
                   pn.part_num2part_class part_class_id,
                   pi.x_part_inst_status
            from  sa.table_part_inst           pi
                 ,sa.table_mod_level           ml
                 ,sa.table_part_num            pn
                 ,sa.table_part_class          pc
            where pi.part_serial_no = p_esn
            and pi.x_domain = 'PHONES'
            and ml.objid = pi.n_part_inst2part_mod
            and pn.objid = ml.part_info2part_num
            and pc.objid = pn.part_num2part_class;

  --------------------------------------------------------------------------------------------
  function end_promo (p_promo_objid number) return varchar2
  as
  begin

    if p_promo_objid is null then
    return 'A value is required.';
    end if;

    update sa.table_x_group2esn
    set x_end_date = sysdate
    where objid = p_promo_objid
    and x_end_date >= sysdate;

    if sql%rowcount > 0then
      return 'Successfully ended promotion';
    else
      return 'Promotion already ended';
    end if;

    commit;

  exception
    when others then
      return 'Unable to end promotion';
  end end_promo;
  --------------------------------------------------------------------------------------------
  function esn_by_min(p_min in varchar2) return varchar2
  as
    cursor c1 is
    select pi1.part_serial_no
    from sa.table_part_inst pi1,sa.table_part_inst pi2
    where pi2.part_serial_no = nvl(p_min,'NA')
    and pi2.x_domain = 'LINES'
    and pi2.part_to_esn2part_inst = pi1.objid
    and pi1.x_domain = 'PHONES';

    r1 c1%rowtype;
    result varchar2(30);

  begin

    open c1;
    fetch c1 into r1;

    if c1%found then
      result:=r1.part_serial_no;
    else
      result:=null;
    end if;
    close c1;

    return result;

  end esn_by_min;
  --------------------------------------------------------------------------------------------
  function min_by_esn(p_esn in varchar2) return varchar2
  as
    cursor c1 is
    select pi2.part_serial_no
    from sa.table_part_inst pi1,sa.table_part_inst pi2
    where 1=1
    and pi2.x_domain = 'LINES'
    and pi2.part_to_esn2part_inst = pi1.objid
    and pi1.x_domain = 'PHONES'
    and pi1.part_serial_no = nvl(p_esn,'NA');

    r1 c1%rowtype;
    result varchar2(30);

  begin

    open c1;
    fetch c1 into r1;

    if c1%found then
      result:=r1.part_serial_no;
    else
      result:=null;
    end if;
    close c1;

    return result;

  end min_by_esn;
  --------------------------------------------------------------------------------------------
  function esn_by_sim (sim in varchar2) return varchar2
  as
    cursor c_by_esn (ip_esn in  sa.table_part_inst.part_serial_no%type) is
    select part_serial_no, x_iccid
    from   sa.table_part_inst
    where  part_serial_no = ip_esn
    and    x_domain = 'PHONES';

    cursor c_by_sim (ip_sim in  sa.table_part_inst.x_iccid%type) is
    select part_serial_no, x_iccid
    from   sa.table_part_inst
    where  x_iccid = ip_sim
    and    x_domain = 'PHONES';

    r1 c_by_sim%rowtype;
    r2 c_by_esn%rowtype;
    result varchar2(30);
    sim_count number:=0;

  begin

    select count(*)
    into sim_count
    from sa.table_x_sim_inv
    where x_sim_serial_no = sim;

    if sim_count > 0 then
       open c_by_sim(sim);
       fetch c_by_sim into r1;
       if c_by_sim%found then
          result:= r1.part_serial_no;
       else
          result:= null;
       end if;
       close c_by_sim;
    else
       open c_by_esn(sim);
       fetch c_by_esn into r2;
       if c_by_esn%found then
          result:= r2.part_serial_no;
       else
          result:= null;
       end if;
       close c_by_esn;
    end if;

    return result;

  end esn_by_sim;
  --------------------------------------------------------------------------------------------
  function esn_type(p_esn in varchar2) return varchar2
  as
    cursor c1 is
    select
    case
    when sa.get_param_by_name_fun(pc.name,'DEVICE_TYPE') = 'WIRELESS_HOME_PHONE' then 'HOME PHONE'
    when sa.get_param_by_name_fun(pc.name,'DEVICE_TYPE') = 'MOBILE_BROADBAND' then 'HOTSPOT'
    when sa.get_param_by_name_fun(pc.name,'MODEL_TYPE')  = 'HOME ALERT' then 'HOME ALERT'
    when sa.get_param_by_name_fun(pc.name,'MANUFACTURER') = 'BYOT' then 'BYOT'
    when sa.get_param_by_name_fun(pc.name,'DEVICE_TYPE') = 'BYOP' then 'BYOP'
    when sa.get_param_by_name_fun(pc.name,'BALANCE_METERING') = 'SUREPAY' then 'SUREPAY'
    when sa.get_param_by_name_fun(pc.name,'MODEL_TYPE')  = 'CAR CONNECT' then 'CAR CONNECT'
    when sa.get_param_by_name_fun(pc.name,'OPERATING_SYSTEM')  = 'IOS' then 'IPHONE'
    else sa.get_param_by_name_fun(pc.name,'DEVICE_TYPE')
    end esn_type
    from  ( select pn.part_num2part_class
            from  sa.table_part_inst           pi
                 ,sa.table_mod_level           ml
                 ,sa.table_part_num            pn
            where pi.part_serial_no = p_esn
            and pi.x_domain = 'PHONES'
            and ml.objid = pi.n_part_inst2part_mod
            and pn.objid = ml.part_info2part_num
          ) a,
          sa.table_part_class pc
    where pc.objid = a.part_num2part_class;

    r1 c1%rowtype;
    result varchar2(100);

  begin

    open c1;
    fetch c1 into r1;

    if c1%found then
      result:=r1.esn_type;
    else
      result:=null;
    end if;
    close c1;

    return result;

  end esn_type;
  --------------------------------------------------------------------------------------------
  function hide_min(p_esn in varchar2) return varchar2
  AS
    result varchar2(30) := 'false';
  begin

    if sa.adfcrm_cust_service.esn_type(p_esn) in ('BYOT','CAR CONNECT','HOME ALERT','HOTSPOT') then
        result := 'true';
    end if;

    return result;

  end hide_min;
----------------------------------------------------------------------------------------------
  function allow_access_to_hot_spot(ip_esn in varchar2) return varchar2
  as
    result varchar2(30) := 'true';
  begin

    if sa.adfcrm_cust_service.esn_type(ip_esn) in ('HOTSPOT') then
      for i in (select sa.get_param_by_name_fun(pc.name,'PHONE_GEN') phone_gen
                from  ( select pn.part_num2part_class
                    from  sa.table_part_inst           pi
                       ,sa.table_mod_level           ml
                       ,sa.table_part_num            pn
                    where pi.part_serial_no = ip_esn
                    and pi.x_domain = 'PHONES'
                    and ml.objid = pi.n_part_inst2part_mod
                    and pn.objid = ml.part_info2part_num
                    ) a,
                    sa.table_part_class pc
                where pc.objid = a.part_num2part_class)
      loop
        if i.phone_gen not in ('4G_LTE') then
          result := 'false';
        end if;
      end loop;
    end if;

    return result;

  end allow_access_to_hot_spot;
----------------------------------------------------------------------------------------------
  function hide_balance (p_esn in varchar2) return varchar2
  as
    result varchar2(30);
    get_esn_rec get_esn_info%rowtype;
  begin
    open get_esn_info(p_esn);
    fetch get_esn_info into get_esn_rec;
    close get_esn_info;

    if sa.adfcrm_cust_service.esn_type(p_esn) in ('BYOT','CAR CONNECT','HOME ALERT')
    then
        result := 'true';
    else
        result := 'false';
    end if;

  return result;

  end hide_balance;
  --------------------------------------------------------------------------------------------
  function hide_sim(p_esn in varchar2) return varchar2
  as
    result varchar2(30);
    cursor c1 is
    select pn.x_technology
    from  sa.table_part_inst           pi
         ,sa.table_mod_level           ml
         ,sa.table_part_num            pn
    where pi.part_serial_no = p_esn
    and pi.x_domain = 'PHONES'
    and ml.objid = pi.n_part_inst2part_mod
    and pn.objid = ml.part_info2part_num;

    r1 c1%rowtype;
  begin
    open c1;
    fetch c1 into r1;

    if c1%found then
      result:=r1.x_technology;
    else
      result:=null;
    end if;
    close c1;

    if sa.adfcrm_cust_service.esn_type(p_esn) in ('CAR CONNECT') then
        result := 'true';
    -- BLOCK ALL CDMA, EXCEPT LTE SIM REMOVABLE SIM PHONES
    elsif r1.x_technology = 'CDMA' and
          lte_service_pkg.is_esn_lte_cdma(p_esn => p_esn) in (0,2) then
          -- return 1 if ESN is LTE Spring CDMA with SIM removable CR22799
          -- return 0 if ESN is not LTE Spring CDMA with SIM removable CR22799
          -- return 2 other errors
        result := 'true';
    else
        result := 'false';
    end if;

  return result;

  end hide_sim;
  --------------------------------------------------------------------------------------------
  function flash_alerts (p_action varchar2,
                                p_flash_objid number,
                                p_alert_text varchar2,
                                p_start_date varchar2,
                                p_end_date varchar2,
                                p_active number, -- 1 active, 0 inactive
                                p_title varchar2,
                                p_hot number, -- 1 yes, 0 no
                                p_u_objid number,
                                p_c_objid number,
                                p_x_web_text_en varchar2,
                                p_x_web_text_es varchar2) return varchar2
  as
    v_cnt number := 0;
    v_msg varchar2(200) := 'success.';
    v_active number:=1;
  begin

    if p_action is null or p_action not in ('INS','DEL','UPD') then
      return 'ERROR - An valid action (INS,DEL,UPD) is required.';
    end if;

    if (p_action = 'UPD' or p_action = 'DEL') and p_flash_objid is null then
      return 'ERROR - Missing flash objid.';
    end if;

    if p_u_objid is null or p_c_objid is null then
      return 'ERROR - Missing the user or contact objid.';
    end if;

    if p_active is not null then
      v_active:=p_active;
    end if;

    if p_action = 'INS' then

      insert into table_alert
        (objid,
         alert_text,
         start_date,
         end_date,
         active,
         title,
         hot,
         last_update2user,
         alert2contact,
         modify_stmp,
         x_web_text_english,
         x_web_text_spanish)
      values
        (sa.seq('alert'),
         p_alert_text,
         to_date(p_start_date,'MM/DD/YYYY'),
         to_date(p_end_date,'MM/DD/YYYY'),
         v_active,
         p_title,
         p_hot,
         p_u_objid,
         p_c_objid,
         sysdate,
         p_x_web_text_en,
         p_x_web_text_es);

      if sql%rowcount > 0 then
        v_cnt := sql%rowcount;
      end if;

      v_msg := 'Insert ('||v_cnt||') '||v_msg;

    end if;

    if p_action = 'UPD' then

      update table_alert
      set    title              = p_title,
             start_date         = to_date(p_start_date,'MM/DD/YYYY'),
             end_date           = to_date(p_end_date,'MM/DD/YYYY'),
             active             = v_active,
             hot                = p_hot,
             alert_text         = p_alert_text,
             x_web_text_english = p_x_web_text_en,
             x_web_text_spanish = p_x_web_text_es,
             last_update2user   = p_u_objid,
             alert2contact      = p_c_objid,
             modify_stmp        = sysdate
      where  objid = p_flash_objid;

      if sql%rowcount > 0 then
        v_cnt := sql%rowcount;
      end if;

      v_msg := 'Update ('||v_cnt||') '||v_msg;

    end if;

    if p_action = 'DEL' then

      delete table_alert
      where  objid = p_flash_objid;

      if sql%rowcount > 0 then
        v_cnt := sql%rowcount;
      end if;

      v_msg := 'Deleted ('||v_cnt||') '||v_msg;

    end if;

    return v_msg;

  exception
    when others then
      return 'ERROR - While trying to '||p_action||' '||sqlerrm ||dbms_utility.format_error_backtrace ;
  end flash_alerts;
  --------------------------------------------------------------------------------------------
  function get_byop_reg_pn (p_org_id in varchar2) return varchar2
  is
    ret_pn varchar2(30);
  begin

    -- THESE ARE THE CURRENT PARTNUMBERS
    -- USED WHEN PURCHASING A REGISTRATION
    -- PIN FOR BYOP TRANSACTIONS
    -- THIS IS THE SAME PART NUMBER BEING USED
    -- WHETHER IT'S A SPRINT OR VERIZON BYOP EXCHANGE

    if p_org_id = 'NET10' then
      ret_pn := 'NTBYOPVZP';
    elsif p_org_id = 'TELCEL' then
      ret_pn := 'TCBYOPVZP';
    elsif p_org_id = 'STRAIGHT_TALK' then
      ret_pn := 'STBYOPVZP';
    elsif p_org_id = 'TRACFONE' then
      ret_pn := 'TFAPPBYOCR80';
    else
      ret_pn := 'ENTER A VALID ORG ID';
    end if;

    return ret_pn;

  end get_byop_reg_pn;
  --------------------------------------------------------------------------------------------
  function get_msl (ip_esn varchar2) return varchar2
  as
    msl varchar2(30);
  begin

    select X_MSL_CODE
    into   msl
    from   sa.TABLE_X_BYOP
    where  x_esn = ip_esn;


    if msl is null then
      msl := 'No MSL found.';
    end if;

    return msl;
  exception
    when others then
      return 'Issue obtaining MSL for '||ip_esn;
  end get_msl;
  --------------------------------------------------------------------------------------------
  function has_ota_cdma_pending (ip_esn varchar2)
  return varchar2
  as
    cnt varchar2(3);
  begin

    select count(*)
    into   cnt
    from   table_x_ota_transaction
    where  1=1
    and    x_status = 'OTA PENDING'
    and    x_esn = ip_esn;

    if to_number(cnt) > 0 then
      return '1';
    else
      return '0';
    end if;

  end has_ota_cdma_pending;
  --------------------------------------------------------------------------------------------
  function is_phone_safelink (ip_esn varchar2) return number
  as
    cnt number;
  begin

    --1 Phone is safelink
    --0 Phone is not safelink
    -- TRACFONE Only

    --select count(*)
    --into   cnt
    --from   x_sl_currentvals
    --where  x_current_esn = ip_esn;

    --PCR3359 allow upgrade once they are no longer in the program
    select count(*)
    into   cnt
    from x_program_enrolled enroll, x_program_parameters param
    where enroll.x_esn = ip_esn
    and enroll.x_enrollment_status not in ('DEENROLLED' ,'ENROLLMENTFAILED' , 'READYTOREENROLL')
    and param.x_prog_class = 'LIFELINE'
    and enroll.pgm_enroll2pgm_parameter = param.objid;

    if cnt > 0 then
      return 1;
    else
      return 0;
    end if;

  end is_phone_safelink;
  --------------------------------------------------------------------------------------------
  function is_sp_compatible (sp_objid varchar2, part_class varchar2) return number
  as
    cnt number;
    v_sp_objid varchar2(100);
  begin
    -- IS THE NEW ESN COMPATIBLE W/THE CURRENT ESN'S SERVICE PLAN
    -- IF NO SERVICE PLAN, ARE THE MINUTES TRANSFERABLE TO THE NEW PHONE

    --select COUNT(*)
    --into   cnt
    --from   service_plan_flat_summary
    --where  part_class_name = part_class
    --and    sp_objid = sp_objid;
    v_sp_objid := sp_objid;

  --select count(*)
    --into   cnt
  --  from sa.adfcrm_serv_plan_class_matview spcm
  --  where spcm.part_class_name = part_class
  --  and   spcm.sp_objid = v_sp_objid;

    select count(spf2.sp_objid)
    into cnt
    from sa.adfcrm_serv_plan_class_matview spf2,
         sa.x_service_plan spf3
    where spf2.part_class_name = part_class
    and spf3.objid = Spf2.Sp_Objid
    and spf3.ivr_plan_id in (select spf4.ivr_plan_id from x_service_plan spf4 where spf4.objid = v_sp_objid);

    if cnt > 0 then
      return 1;
    else
      return 0;
    end if;
  end is_sp_compatible;

  function is_sp_enrollment_compatible (ip_esn varchar2, ip_new_esn varchar2) return number
  as

    -- 0 No Plan Found
    -- 1 Plan Found and Compatible
    -- 2 Plan Found and not Compatible

    cnt number;
    cursor c1 (v_esn varchar2) is
    SELECT p.objid, x.pgm_enroll2web_user
    from x_program_parameters p, x_program_enrolled x,
    (select mtm.x_sp2program_param, spmv.sp_objid objid
     from  sa.table_part_inst pi,
           sa.table_mod_level ml,
           sa.table_part_num pn,
           sa.adfcrm_serv_plan_class_matview spmv, sa.mtm_sp_x_program_param mtm
     where pi.part_serial_no = v_esn
     and   pi.x_domain ='PHONES'
     and   ml.objid = pi.n_part_inst2part_mod
     and   pn.objid = ml.part_info2part_num
     and  spmv.part_class_objid = pn.part_num2part_class
     and  mtm.program_para2x_sp = spmv.sp_objid
     AND   NVL(sa.adfcrm_GET_SERV_PLAN_VALUE(spmv.sp_OBJID,'SERVICE_PLAN_PURCHASE'),'NOT AVAILABLE') IN ('AVAILABLE','ENROLL_ALLOW')
     and   sa.ADFCRM_GET_SERV_PLAN_VALUE(spmv.sp_OBJID,'RECURRING_SERVICE_PLAN') is null
            ) X_SERVICE_PLAN
        WHERE X.PGM_ENROLL2PGM_PARAMETER = P.OBJID
        AND X.X_ESN = v_esn
        AND ((X.X_ENROLLMENT_STATUS = 'ENROLLED' )
            )
        and p.objid = X_SERVICE_PLAN.x_sp2program_param (+);
    r1 c1%rowtype;
    canenroll_result number;

  begin
    -- IS THE NEW ESN COMPATIBLE W/THE CURRENT ESN'S SERVICE PLAN
    -- IF NO SERVICE PLAN, ARE THE MINUTES TRANSFERABLE TO THE NEW PHONE

    open c1(ip_esn);
    fetch c1 into r1;
    if c1%found then
       close c1;
         canenroll_result := sa.CANENROLL(
              P_WEB_USER => r1.pgm_enroll2web_user,
              P_ESN => ip_new_esn,
              P_PROGRAM_TO_ENROLL => r1.objid,
              P_CHECK_ESN_FLAG => 0);

          if  canenroll_result> 0 and canenroll_result<= 10 then
             return 1;
          else
             return 2;
          end if;
    else
       close c1;
       return 0;
    end if;

  end is_sp_enrollment_compatible;



  --------------------------------------------------------------------------------------------
  function is_surepay_tech_case(ip_str_old_esn varchar2, ip_str_new_esn varchar2, ip_str_new_sim varchar2, ip_str_zip varchar2, ip_language varchar2
                               , ip_transfer_min varchar2  --YES same number, NO new number
                               )
  return varchar2
  as
    cursor get_esn_info (p_esn varchar2) is
            select pn.part_number,
             pn.x_technology,
                   pc.name part_class,
                   pn.part_num2part_class part_class_id,
                     pi.x_part_inst_status
            from  sa.table_part_inst           pi
                 ,sa.table_mod_level           ml
                 ,sa.table_part_num            pn
                 ,sa.table_part_class          pc
            where pi.part_serial_no = p_esn
            and pi.x_domain = 'PHONES'
            and ml.objid = pi.n_part_inst2part_mod
            and pn.objid = ml.part_info2part_num
            and pc.objid = pn.part_num2part_class;

    cursor get_sim_info (p_sim varchar2) is
      select pn.s_part_number, si.x_sim_inv_status
            ,(select x_code_name
              from table_x_code_table xct
              where xct.x_code_type = 'SIM'
              and  xct.x_code_number = si.x_sim_inv_status) SIM_STATUS_DESC
      from table_part_num pn, table_mod_level ml, sa.table_x_sim_inv si
      where 1 = 1
      and pn.objid = ml.part_info2part_num
      and ml.objid = si.x_sim_inv2part_mod
      and si.x_sim_serial_no = p_sim;

    rec_sim_info get_sim_info%rowtype;

    op_carrier_id varchar2(300);
    op_error_text varchar2(300);
    op_error_num varchar2(300);
    p_out_msg varchar2(300);
    p_pref_parent varchar2(300);
    p_repl_part varchar2(300);
    p_repl_tech varchar2(300);
    p_repl_sim varchar2(300);
    p_pref_carrier varchar2(300);
    ret_msg varchar2(300) := 'DO_NOT_PERFORM_EXCHANGE';
    p_commit varchar2(3) := 'no';
    p_sim_profile varchar2(300);
    p_part_serial_no varchar2(300);
    p_msg varchar2(300);
    p_pref_carrier_objid varchar2(300);
    debug_flag boolean := true;
    op_last_rate_plan_sent varchar2(60);
    op_is_swb_carr varchar2(200);
    op_error_code number;
    op_error_message varchar2(200);
    rec_esn_status get_esn_info%ROWTYPE; -- CR #37898
  begin
    sa.verify_phone_upgrade_pkg.verify(ip_str_old_esn => ip_str_old_esn,
                                    ip_str_new_esn => ip_str_new_esn,
                                    ip_str_zip => ip_str_zip,
                                    ip_str_iccid => ip_str_new_sim,
                                    op_carrier_id => op_carrier_id,
                                    op_error_text => op_error_text,
                                    op_error_num => op_error_num);

    if debug_flag then
      dbms_output.put_line('verify_phone_upgrade_pkg.verify rslt ================================================= '||op_error_text);
      dbms_output.put_line('verify_phone_upgrade_pkg.verify rslt ================================================= '||op_error_num);
      dbms_output.put_line('verify_phone_upgrade_pkg.op_carrier_id ================================================= '||op_carrier_id);
    end if;

    if op_error_num = '120' then
      return ret_msg||'_DIFF_GROUP';
    end if;

    if op_error_num = '0' and op_error_text in ('ESN EXCHANGE','MANUAL PORT','AUTO PORT') then
         --CR35336 check if this is ATT Carrier switch (Ericsson Prepaid System) to return UPGRADE_ATT_SWITCH
         if op_error_text = 'ESN EXCHANGE'
         then
                sa.SP_SWB_CARR_RATE_PLAN(
                IP_ESN => ip_str_old_esn,
                OP_LAST_RATE_PLAN_SENT => OP_LAST_RATE_PLAN_SENT,
                OP_IS_SWB_CARR => OP_IS_SWB_CARR,
                OP_ERROR_CODE => OP_ERROR_CODE,
                OP_ERROR_MESSAGE => OP_ERROR_MESSAGE
                );
         end if;
         if op_error_text = 'ESN EXCHANGE' and nvl(OP_IS_SWB_CARR,'#') = 'Switch Base' then
           if debug_flag then
              dbms_output.put_line('================================================= UPGRADE_ATT_SWITCH');
           end if;
           return 'UPGRADE_ATT_SWITCH';
         else
           --Start  CR #37898 - TAS Upgrade Phone Model Script Correct
              OPEN get_esn_info(ip_str_new_esn);
              FETCH get_esn_info INTO rec_esn_status;
              CLOSE get_esn_info;
              -- NEW ESN Status is in USED or PASTDUE
              -- Return as UPGRADE_ESN_EXCHANGE_REAC OR UPGRADE_AUTO_PORT_REAC
              IF rec_esn_status.x_part_inst_status IN ('51', '54') THEN
                if debug_flag then
                   dbms_output.put_line('================================================= UPGRADE_'||replace(op_error_text,' ','_')||'_REAC');
                end if;
                return 'UPGRADE_'||replace(op_error_text,' ','_')||'_REAC';
              END IF;
              -- End CR #37898 - TAS Upgrade Phone Model Script Correct
                if debug_flag then
                   dbms_output.put_line('=================================================UPGRADE_'||replace(op_error_text,' ','_'));
                end if;
             return 'UPGRADE_'||replace(op_error_text,' ','_');
         end if;
      --return 'CONTINUE_WITH_UPGRADE';
    end if;

    -- MANUAL PORT, AUTO PORT AND ESN EXCHANGES WILL ALWAYS RETURN ERR NUM ZERO, ANYTHING ELSE CHECK REPL PART PROC.
    if op_error_num != '0' then
      sa.get_repl_part_prc(p_zip => ip_str_zip, -- ZIPCODE REQUIRED
                        p_esn => ip_str_new_esn,
                        p_curr_carrier => null,
                        p_out_msg => p_out_msg,
                        p_pref_parent => p_pref_parent,
                        p_repl_part => p_repl_part,
                        p_repl_tech => p_repl_tech,
                        p_repl_sim => p_repl_sim,
                        p_pref_carrier => p_pref_carrier);

      if debug_flag then
        dbms_output.put_line('get_repl_part_prc rslt ================================================= '||p_out_msg);
        dbms_output.put_line('p_repl_part  ================================================= '||p_repl_part);
      end if;
    end if;

    -- ONLY HANDLE SIM EXCHANGE OUTPUT FROM GET REPL PART PRC TO VALIDATE
    -- if p_out_msg = 'SIM Exchange' then
    if instr(p_out_msg,'SIM Exchange') > 0 or instr(p_out_msg,'NO Replacement Found') >0 then
      sa.nap_digital(p_zip => ip_str_zip,
                  p_esn => ip_str_new_esn,
                  p_commit => p_commit,
                  p_language => ip_language,
                  p_sim => ip_str_new_sim,
                  p_source => 'TAS',
                  p_upg_flag => 'N',
                  p_repl_part => p_repl_part,
                  p_repl_tech => p_repl_tech,
                  p_sim_profile => p_sim_profile,
                  p_part_serial_no => p_part_serial_no,
                  p_msg => p_msg,
                  p_pref_parent => p_pref_parent,
                  p_pref_carrier_objid => p_pref_carrier_objid);

      dbms_output.put_line('nap_digital rslt ================================================= '||p_msg);
    end if;

    if instr(p_out_msg,'Replacement Part Found') > 0  or instr(p_msg,'Replacement Part Found') > 0 then
      ret_msg := 'PERFORM_DIGITAL_EXCHANGE';
    else
        if instr(upper(p_out_msg),'SIM EXCHANGE') > 0 then
           ret_msg := 'PERFORM_SIM_EXCHANGE';

           --CR49534 When New number the SIM Exchange is needed only for target GSM phones, used or past due, where the sim is EXPIRED.
           if ip_transfer_min = 'NO' --NEW number
           then
               open get_esn_info(ip_str_new_esn);
               fetch get_esn_info into rec_esn_status;
               close get_esn_info;

               open get_sim_info(ip_str_new_sim);
               fetch get_sim_info into rec_sim_info;
               close get_sim_info;

               dbms_output.put_line(chr(10)||'===== New MIN  '||rec_sim_info.sim_status_desc);
               if (rec_esn_status.x_part_inst_status in ('51','54') and --USED    51/PASTDUE 54
                   rec_esn_status.x_technology = 'GSM' and
                   rec_sim_info.x_sim_inv_status = '250' --SIM EXPIRED
                  )
               then
                   ret_msg := 'PERFORM_SIM_EXCHANGE';
               else
                  --nap_digital rslt ================== F Choice: MIN already attached to ESN.  Please verify.
                  if (instr(p_msg,'F Choice: MIN already attached to ESN') > 0 or
                      instr(p_msg,'MIN CHANGE ALLOWED') > 0
                     ) then
                     ret_msg := 'UPGRADE_AUTO_PORT_REAC';
                  end if;
               end if;
            end if;
        end if;
    end if;

    if debug_flag then
      dbms_output.put_line('================================================='||p_repl_part);
      dbms_output.put_line('================================================='||p_repl_tech);
      dbms_output.put_line('================================================='||p_sim_profile);
      dbms_output.put_line('================================================='||p_part_serial_no);
      dbms_output.put_line('================================================='||instr(upper(p_msg),'SIM EXCHANGE'));
    end if;

    if debug_flag then
      dbms_output.put_line('================================================='||ret_msg);
    end if;

    return ret_msg;
  end is_surepay_tech_case;
  --------------------------------------------------------------------------------------------
  function is_surepay_tech_case(ip_str_old_esn varchar2, ip_str_new_esn varchar2, ip_str_new_sim varchar2, ip_str_zip varchar2, ip_language varchar2)
  return varchar2
  as
  begin
    --OVERLOADED FOR CR49354
    return (is_surepay_tech_case(ip_str_old_esn, ip_str_new_esn, ip_str_new_sim, ip_str_zip, ip_language, 'YES'));
  end is_surepay_tech_case;
  --------------------------------------------------------------------------------------------
  procedure lte_sim_marriage_tool (p_esn varchar2,
                                          p_x_iccid varchar2,
                                          op_out_msg out varchar2,
                                          op_error_code out number)
  as
    p_sim_status varchar2(200);
    p_esn_status varchar2(200);
    p_error_code number;
    is_active_esn number;
    v_return number;
    v_iccid varchar2(30);
  begin
    op_error_code := 0;

    -- VERIFY SIM PASSED DOESN'T ALREADY BELONG TO THE ESN
    begin
      select x_iccid
      into   v_iccid
      from   table_part_inst
      where  part_serial_no = p_esn
      and    x_domain = 'PHONES';

      if v_iccid = p_x_iccid then
        op_out_msg := 'ESN AND SIM ARE ALREADY MARRIED';
        op_error_code := 100;
        return;
      end if;

    exception
      when others then
      op_out_msg := 'NO SIM ATTACHED';
    end;

    -- 1.VERIFY SIM IS NOT ALREADY MARRIED
    v_return := lte_service_pkg.is_lte_single(p_x_iccid => p_x_iccid);
    if v_return = 0 then
      op_out_msg := 'SIM SINGLE';
    else
      op_out_msg := 'ERROR - SIM IS ALREADY MARRIED';
      op_error_code := 200;
      return;
    end if;

    -- 2. VERIFY ESN IS LTE SIM REMOVABLE
    v_Return := LTE_SERVICE_PKG.IS_LTE_4G_SIM_REM(P_ESN => P_ESN);
    if v_return = 0 then
      op_out_msg := 'ESN IS LTE REMOVABLE';
    else
      op_out_msg := 'ERROR - ESN NOT LTE REMOVABLE OR NOT FOUND';
      op_error_code := 300;
      return;
    end if;

    -- 3.VERIFY ESN IS INACTIVE
    is_active_esn := LTE_SERVICE_PKG.is_lte_4g_inactive(p_esn);

    if is_active_esn = 0 then
      op_out_msg := 'PHONE IS NOT ACTIVE';
    else
      op_out_msg :='ERROR - PHONE IS ACTIVE';
      op_error_code := 400;
      return;
    end if;

    -- 4.VERIFY ESN IS NOT ALREADY MARRIED (NOT CONFIRMED IN REQUIREMENTS BUT, ADDED BECAUSE IT'S IN THE LTE PKG)
    LTE_SERVICE_PKG.IS_LTE_MARRIAGE(P_ESN => P_ESN,
                                    P_SIM_STATUS => P_SIM_STATUS,
                                    P_X_ICCID => v_iccid,
                                    P_ESN_STATUS => P_ESN_STATUS,
                                    p_error_code => p_error_code);

    if p_error_code = 1 then
      op_out_msg :='ESN IS NOT MARRIED';
    else
      op_out_msg :='ESN IS MARRIED';
    end if;

    -- 4.VERIFY ESN AND SIM IS LTE COMPATIBLE THIS DOES BOTH CHECKS
    -- P_ERROR_CODE DEFINITION OUTLINED IN IS_LTE_COMPATIBLE
    LTE_SERVICE_PKG.IS_LTE_COMPATIBLE(P_X_ICCID => P_X_ICCID,
                                      P_ESN => P_ESN,
                                      p_error_code => p_error_code);
    if p_error_code = 0 then
      op_out_msg :='ESN AND SIM ARE COMPATIBLE';
    elsif p_error_code = 2 then
      op_out_msg :='ERROR - SIM PART NUMBER NOT FOUND';
      op_error_code := 500;
      return;
    elsif p_error_code = 3 then
      op_out_msg :='ERROR - SIM IS NOT COMPATIBLE';
      op_error_code := 600;
      return;
    else
      op_out_msg :='ERROR - '||p_error_code;
      op_error_code := 700;
      return;
    end if;

    lte_service_pkg.lte_marriage(p_esn => p_esn,
                                 p_x_iccid => p_x_iccid,
                                 p_error_code => p_error_code);
    if p_error_code = 0 then
      op_out_msg :='ESN AND SIM HAVE BEEN SUCCESSFULLY MARRIED';
    elsif p_error_code = 1 then
      -- THIS CONDITION WILL PROBABLY NEVER RETURN BECAUSE OF VALIDATION ABOVE
      op_out_msg :='ESN NOT IN SITE PART';
      op_error_code := 800;
    elsif p_error_code = 2 then
      op_out_msg :='ERROR IN ESN ICCID MARRIAGE '||p_error_code;
      op_error_code := 900;
    end if;

  exception
    when others then
      op_out_msg := 'ERROR - '||sqlerrm;
      op_error_code := -2;
  end lte_sim_marriage_tool;
  --------------------------------------------------------------------------------------------
  function manual_unit_bal_cap (ip_esn varchar2,ip_user_ttl varchar2) return varchar2
  as
    user_ttl number := nvl(to_number(ip_user_ttl),0);
    tt_redeemed number;
    pending_units number;
    ttl_after_pending_units number;
    unit_cnt number;
    cap number;
  begin
    -- GET THE CAP, DEFAULT SHOULD BE 10K PER DISCUSSIONS W/SONIA 9.25.13
    select nvl(sum(to_number(x_param_value)),0) redeem_cap
    into   cap
    from   table_x_parameters
    where  x_param_name = 'ADFCRM_UNIT_TRANSFER_CAP';

    -- QUERY TO GET TTL UNITS BASED OFF CBO CALL
    select ttl_units
    into   tt_redeemed
    from   (select nvl(sum(ct.x_total_units),0) ttl_units
            from   table_x_call_trans ct,
                   table_site_part sp,
                   (select nvl(max(x_req_date_time),to_date('01/01/1900','MM/DD/YYYY')) x_req_date_time
                                          from table_x_zero_out_max zo
                                          where zo.x_esn= ip_esn
                                          and   zo.x_transaction_type=2) zero_max_date
            where  1=1
            and    sp.objid = ct.call_trans2site_part
            and    sp.x_service_id = ip_esn
            and    ct.x_transact_date >= x_req_date_time);

    -- GET PENDING UNITS
    select nvl(sum(units),0) pending_units
    into   pending_units
    from (select sum(pm1.x_units) units
          from   table_x_pending_redemption pr1
          join table_x_promotion pm1 on pr1.pend_red2x_promotion=pm1.objid
          join table_part_inst pi1 on pr1.pend_redemption2esn=pi1.objid
          where pi1.part_serial_no = ip_esn
          union
          select sum(pm2.x_units) units
          from   table_x_pending_redemption pr2
          join table_x_promotion pm2 on pr2.pend_red2x_promotion=pm2.objid
          join table_site_part sp2 on pr2.x_pend_red2site_part=sp2.objid and sp2.part_status='Active'
          where sp2.x_service_id = ip_esn);

    ttl_after_pending_units := tt_redeemed-pending_units;


    if user_ttl < ttl_after_pending_units then
      -- USE THE AGENTS ENTRY
      unit_cnt := user_ttl;
    else
      unit_cnt := ttl_after_pending_units;
    end if;

    if unit_cnt > cap then
      unit_cnt := cap;
    end if;

    dbms_output.put_line('ttl_after_pending_units == '||ttl_after_pending_units);
    dbms_output.put_line('user_ttl == '||user_ttl);
    dbms_output.put_line('cap == '||cap);
    dbms_output.put_line('UNITS == '||unit_cnt);

    return to_char(unit_cnt);

  end manual_unit_bal_cap;
  --------------------------------------------------------------------------------------------
  function new_due_date (ip_call_trans_objid number)
  return varchar2
  as
    v_out_msg varchar2(100) := 'Success';
    cursor c1 is
    select warranty_date
    from sa.table_site_part
    where objid in (select call_trans2site_part from sa.table_x_call_trans where objid = ip_call_trans_objid);
    r1 c1%rowtype;
  begin

    if ip_call_trans_objid is null then
      return 'ERROR - ip_call_trans_objid is null';
    end if;

    open c1;
    fetch c1 into r1;
    if c1%found then
       close c1;
       update sa.table_x_call_trans
       set x_new_due_date = r1.warranty_date
       where objid = ip_call_trans_objid;
       commit;
    else
       close c1;
       return 'ERROR - site_part record not found';
    end if;

    return v_out_msg;

  exception
    when others then
      return 'ERROR - '||sqlerrm;
  end new_due_date;
  --------------------------------------------------------------------------------------------
  function reset_sim(ip_iccid varchar2) return varchar2
  as
    v_out_msg varchar2(100) := 'SIM has been reset to new';
  begin

    if ip_iccid is null then
      return 'ERROR - SIM serial number is required to continue';
    end if;


    update table_x_sim_inv
    set x_sim_inv_status='253',
        x_sim_status2x_code_table = (select objid
                                     from table_x_code_table
                                     where x_code_number = '253')
    where x_sim_serial_no = ip_iccid;

    if sql%rowcount = 0 then
      return 'ERROR - SIM serial number not found';
    end if;

    commit;
    return v_out_msg;

  exception
    when others then
      return 'ERROR - While resetting SIM - '||sqlerrm;
  end reset_sim;
  --------------------------------------------------------------------------------------------
  function resetmin (p_reset_min    in varchar2,
                            p_reset_reason in varchar2,
                            p_login_name in varchar2,
                            p_expire_sim in varchar2) return varchar2
  as
     cursor pi_cur (ip_serial varchar2, ip_domain varchar2) is
     select * from table_part_inst
     where part_serial_no = ip_serial
     and x_domain = ip_domain;

     min_rec pi_cur%rowtype;
     pi_result number;
     user_objid number;
     ip_action number;
     op_result number;
     op_msg varchar2(200);
     g_print_success_message varchar2(2000) := 'Error';
  begin

     select objid
     into user_objid
     from table_user
     where upper(s_login_name) = upper(p_login_name);

     open pi_cur (p_reset_min,'LINES');
     fetch pi_cur into min_rec;
     if pi_cur%notfound then
         close pi_cur;
         g_print_success_message :=  'No record found on MIN';
         return g_print_success_message;
     end if;
     close pi_cur;
     if min_rec.x_part_inst_status='13' then
         g_print_success_message := 'This MIN is active';
         return g_print_success_message;
     else

      update table_part_inst
      set x_part_inst_status = '12',
          status2x_code_table = 959,
          part_to_esn2part_inst = null,
          x_cool_end_date = to_date('01/01/1753','mm/dd/yyyy')
      where objid = min_rec.objid;


      if p_expire_sim = 'Yes' then
         update table_x_sim_inv
         set x_sim_inv_status = '250', x_sim_status2x_code_table = 268438609
         where x_sim_serial_no in (select distinct x_iccid
                                   from table_site_part
                                   where x_min =p_reset_min
                                   and part_status||'' = 'Inactive'
                                   and x_iccid is not null);

      end if;

      g_print_success_message :=  'Reset Completed';
      --LOG Transaction
      sa.insert_pi_hist_prc(
       ip_user_objid => user_objid,
       ip_min => p_reset_min,
       ip_old_npa => substr(p_reset_min,1,3),
       ip_old_nxx => substr(p_reset_min,4,3),
       ip_old_ext => substr(p_reset_min,7,4),
       ip_reason => 'RESET TO USED',
       ip_out_val => pi_result);

       ip_action := 230;  --Reset Reserved Min
       toppapp.sp_tu_log(
           ip_agent => p_login_name,
           ip_action => ip_action,
           ip_esn => null,
           ip_min => p_reset_min,
           ip_smp => null,
           ip_reason => p_reset_reason,
           ip_storeid => null,
           op_result => op_result,
           op_msg => op_msg);

     end if;
   return g_print_success_message;

  exception
     when others then
        return  dbms_utility.format_error_stack || dbms_utility.format_error_backtrace;
  end resetmin;
  --------------------------------------------------------------------------------------------
  function serv_plan_site_part (ip_esn           varchar2,
                                       ip_program_objid varchar2) return varchar2
  as
    cursor c0
    is
      select spmv.sp_objid
      from mtm_sp_x_program_param mtm,
        sa.adfcrm_serv_plan_class_matview spmv,
        table_part_num pn,
        table_mod_level ml,
        table_part_inst pi
      where mtm.x_sp2program_param=ip_program_objid
      and spmv.sp_objid             = mtm.program_para2x_sp
      and spmv.part_class_objid     = pn.part_num2part_class
      and sa.ADFCRM_GET_SERV_PLAN_VALUE(spmv.sp_OBJID,'RECURRING_SERVICE_PLAN') is null
      and pn.objid                = ml.part_info2part_num
      and pi.n_part_inst2part_mod = ml.objid
      and pi.part_serial_no       = ip_esn
      and pi.x_domain             = 'PHONES'
      and rownum                  < 2;
    r0 c0%rowtype;
    cursor c1
    is
      select objid
      from sa.table_site_part
      where x_service_id = ip_esn
      and part_status   in ('Active','CarrierPending');
    r1 c1%rowtype;
    cursor c2 (sp_objid number)
    is
      select rowid
      from sa.x_service_plan_site_part
      where table_site_part_id = sp_objid;
    r2 c2%rowtype;
    v_out_msg       varchar2(200) := 'Successful';
  begin
    open c0;
    fetch c0 into r0;
    if c0%found then
      close c0;
      open c1;
      fetch c1 into r1;
      if c1%found then
        close c1;
        open c2(r1.objid);
        fetch c2 into r2;
        if c2%found then
          close c2;
          update sa.x_service_plan_site_part spsp
          set spsp.x_service_plan_id  = r0.sp_objid,
            spsp.x_last_modified_date = sysdate
          where rowid                 = r2.rowid;
        else
          close c2;
          insert
          into sa.x_service_plan_site_part
            (
              table_site_part_id,
              x_last_modified_date,
              x_service_plan_id,
              x_switch_base_rate
            )
            values
            (
              r1.objid,
              sysdate,
              r0.sp_objid,
              0
            );
        end if;
        insert
        into sa.x_service_plan_hist
          (
            plan_hist2service_plan,
            plan_hist2site_part,
            x_start_date
          )
          values
          (
            r0.sp_objid,
            r1.objid,
            sysdate
          );
      else
        close c1;
        v_out_msg:='ERROR - Site part record not found';
      end if;
    else
      close c0;
      v_out_msg:='ERROR - Service Plan not found';
    end if;
    commit;
    return v_out_msg;

  exception
    when others then
      return 'ERROR - '||sqlerrm;
  end serv_plan_site_part;
  --------------------------------------------------------------------------------------------
  function upd_ota_pending (p_esn varchar2) return varchar2
  as
    cnt number := 0;
  begin
    if p_esn is null or p_esn = '' then
      return 'ERROR - An ESN is required';
    end if;

    update table_x_call_trans
    set x_result='Completed'
    where x_service_id = p_esn
    and x_result= 'OTA PENDING';
    cnt := cnt+sql%rowcount;

    update table_x_code_hist
    set x_code_accepted = 'YES'
    where code_hist2call_trans in (select objid
                                   from table_x_call_trans
                                   where x_service_id = p_esn)
    and x_code_accepted = 'OTAPENDING';
    cnt := cnt+sql%rowcount;

    update table_x_ota_transaction
    set x_status = 'Completed'
    where x_esn = p_esn
    and x_status = 'OTA PENDING';
    cnt := cnt+sql%rowcount;

    if cnt > 0 then
      return 'OTA Update Successful ('||cnt||')';
    else
      return 'No Pending OTA status on ('||p_esn||')';
    end if;

    commit;

  exception
    when others then
      return 'ERROR - Unable to update OTA.';
  end upd_ota_pending;
  --------------------------------------------------------------------------------------------
  function upd_promo (p_promo_objid number,
                             p_new_end_date varchar2)
  return varchar2
  as
  begin
    if p_promo_objid is null then
      return 'A value is required.';
    end if;

    if p_new_end_date is null then
      return 'A new end date is required.';
    end if;

    update sa.table_x_group2esn
    set x_end_date = to_date(p_new_end_date,'MM/DD/YYYY')
    where objid = p_promo_objid;

    commit;

    return 'Successfully updated promotion date ('||p_new_end_date||')';
  exception
    when others then
      return 'Unable to update promotion date';
  end upd_promo;
  --------------------------------------------------------------------------------------------
  function upgrade_is_pin_required (ip_old_esn varchar2, ip_new_esn varchar2)
  return number
  as

  --0: PIN NOT REQUIRED AND ENROLLMENT CANCELLATION NOT REQUIRED
  --1: PIN REQUIRED AND ENROLLMENT CANCELLATION NOT REQUIRED
  --2: PIN REQUIRED AND ENROLLMENT CANCELLATION REQUIRED
  --3: PIN NOT REQUIRED AND ENROLLMENT CANCELLAION REQUIRED

    cursor comp_serv_plan_cur (old_esn varchar2,pc_objid number) is
    select spf.sp_objid
    from --service_plan_flat_summary spf
          sa.adfcrm_serv_plan_class_matview spf
    where spf.part_class_objid = pc_objid
    and spf.SP_OBJID in (select spsp.x_service_plan_id
                        from x_service_plan_site_part spsp,
                            table_site_part sp
                        where sp.x_service_id = old_esn
                        and sp.part_status in ('Active','CarrierPending')
                        and sp.objid = spsp.table_site_part_id)
    union
    select spf2.sp_objid
    from sa.adfcrm_serv_plan_class_matview spf2,
         sa.x_service_plan spf3
    where spf2.part_class_objid = pc_objid
    and spf3.objid = Spf2.Sp_Objid
    and spf3.ivr_plan_id in (select spf4.ivr_plan_id
                           from x_service_plan spf4, x_service_plan_site_part spsp2,table_site_part sp2
                           where sp2.x_service_id = old_esn
                           and sp2.part_status in ('Active','CarrierPending')
                           and sp2.objid = spsp2.table_site_part_id
                           and spf4.objid = Spsp2.X_Service_Plan_Id);


    comp_serv_plan_rec comp_serv_plan_cur%rowtype;

    cursor esn_cur (esn varchar2)
    is     select pc.objid pc_objid,pc.name part_class,pi.warr_end_date, bo.org_id,pi.x_part_inst_status,pn.x_dll
    from table_part_num pn,
         table_mod_level m1,
         table_part_inst pi,
         table_part_class pc,
         table_bus_org bo
    where pi.part_serial_no = esn
    and pi.x_domain = 'PHONES'
    and pi.n_part_inst2part_mod = m1.objid
    and m1.part_info2part_num = pn.objid
    and pn.part_num2bus_org = bo.objid
    and pn.part_num2part_class = pc.objid;

    old_esn_rec esn_cur%rowtype;
    new_esn_rec esn_cur%rowtype;

    old_esn_sp number;
    new_esn_sp number;

    v_enrollment number:=0;
    v_plan_flag number:=0;

  begin

    open esn_cur(ip_old_esn);
    fetch esn_cur into old_esn_rec;
    if esn_cur%notfound then
       close esn_cur;
       v_plan_flag:= 1;
    else
       close esn_cur;
       open esn_cur(ip_new_esn);
       fetch esn_cur into new_esn_rec;
       if esn_cur%notfound then
          close esn_cur;
          v_plan_flag:= 1;
       else
          close esn_cur;

          --old_esn_sp := sa.device_util_pkg.get_smartphone_fun(ip_old_esn);
          --new_esn_sp := sa.device_util_pkg.get_smartphone_fun(ip_new_esn);
          if old_esn_rec.x_dll<=0 then
             old_esn_sp := 0;
          else
             old_esn_sp := 1;
          end if;
          if new_esn_rec.x_dll<=0 then
             new_esn_sp := 0;
          else
             new_esn_sp := 1;
          end if;

          -- Return from: is_sp_enrollment_compatible
          -- 0 No Plan Found
          -- 1 Plan Found and Compatible
          -- 2 Plan Found and not Compatible
          v_enrollment := is_sp_enrollment_compatible (ip_old_esn,ip_new_esn);

          if old_esn_rec.org_id = 'TRACFONE' then
             if  new_esn_sp=0 and old_esn_sp=0 then  -- SmartPhones
                open comp_serv_plan_cur(ip_old_esn,new_esn_rec.pc_objid);
                fetch comp_serv_plan_cur into comp_serv_plan_rec;
                if comp_serv_plan_cur%found then
                   close comp_serv_plan_cur;
                   v_plan_flag:=  0;
                else
                   close comp_serv_plan_cur;
                   if new_esn_rec.warr_end_date > sysdate then
                      v_plan_flag:=  0;
                   else
                      if (new_esn_rec.x_part_inst_status = '50' or new_esn_rec.x_part_inst_status = '150')
                        and new_esn_sp=1 then
                        v_plan_flag:= 0;
                      else
                        v_plan_flag:= 1;
                      end if;
                   end if;
                end if;
             end if;
          elsif old_esn_rec.org_id = 'NET10'then
                open comp_serv_plan_cur(ip_old_esn,new_esn_rec.pc_objid);
                fetch comp_serv_plan_cur into comp_serv_plan_rec;
                if comp_serv_plan_cur%found then
                   close comp_serv_plan_cur;
                   v_plan_flag:=  0;
                else
                   close comp_serv_plan_cur;
                   if new_esn_rec.warr_end_date > sysdate and new_esn_sp=1 then
                      v_plan_flag:=  0;
                   else
                      if (new_esn_rec.x_part_inst_status = '50' or new_esn_rec.x_part_inst_status = '150')
                        and new_esn_sp=1 then
                        v_plan_flag:=  0;
                      else
                        v_plan_flag:=  1;
                      end if;
                   end if;
                end if;
          else  -- STRAIGHT_TALK, SIMPLE_MOBILE, TELCEL
                open comp_serv_plan_cur(ip_old_esn,new_esn_rec.pc_objid);
                fetch comp_serv_plan_cur into comp_serv_plan_rec;
                if comp_serv_plan_cur%found then
                   close comp_serv_plan_cur;
                   v_plan_flag:=  0;
                else
                   close comp_serv_plan_cur;
                   v_plan_flag:=  1;
                end if;
          end if;
       end if;
    end if;
  --0: PIN NOT REQUIRED AND ENROLLMENT CANCELLATION NOT REQUIRED
  --1: PIN REQUIRED AND ENROLLMENT CANCELLATION NOT REQUIRED
  --2: PIN REQUIRED AND ENROLLMENT CANCELLATION REQUIRED
  --3: PIN NOT REQUIRED AND ENROLLMENT CANCELLAION REQUIRED

    if v_plan_flag = 0 and v_enrollment = 0 then
       return 0;
    end if;
    if v_plan_flag = 1 and v_enrollment in(0,1) then
       return 1;
    end if;
    if v_plan_flag = 1 and v_enrollment = 2 then
       return 2;
    end if;
    if v_plan_flag = 0 and v_enrollment = 2 then
       return 3;
    end if;

    return 0;

  end upgrade_is_pin_required;

  --------------------------------------------------------------------------------------------
  procedure workforce_pin (ip_esn          varchar2,
                                  ip_pin_part_num varchar2,
                                  ip_login_name   varchar2,
                                  ip_reason       varchar2,
                                  ip_notes        varchar2,
                                  ip_contact_objid varchar2,
      ip_orgid        varchar2,   --added for CR54687
      ip_service_plan_objid        varchar2,  --added for CR54687
      ip_service_type    varchar2,        --added for CR54687
                                  op_pin out varchar2,
                                  op_case_id out varchar2,
                                  op_error_num out varchar2,
                                  op_error_msg out varchar2)
  AS
  -- THIS IS SPECIFICALLY FOR UNITS / COMPENSATION SERVICE PLAN CASES.
  -- FOR WORKFORCE TO GENERATE PINS
  -- USER INFO
  v_user_objid NUMBER;

  -- OUT INFO
  v_case_objid         NUMBER;
  v_case_detail        varchar2(4000);
  v_error_no           VARCHAR2(200);
  v_error_str          VARCHAR2(200);
  v_pin_part_serial_no VARCHAR2(30);
  v_esn_objid          NUMBER;
  v_hist_ret           BOOLEAN;
  v_activity           VARCHAR2(500);
  p_seq_name           VARCHAR2(30):='x_merch_ref_id';
  o_next_value         NUMBER;
  o_format             VARCHAR2(100);
  p_status             VARCHAR2(10);
  p_msg                VARCHAR2(200);
  v_new_pi_objid       NUMBER;
  v_esn                VARCHAR2(30);
  v_card_status        varchar2(10);
  n_pin_sp_id number;  --CR54687
 v_dest_sp_grp  varchar2(200); --CR54687

       v_result_set    SYS_REFCURSOR ;--CR54687
      v_err_num       INTEGER ;--CR54687
      v_err_string    VARCHAR2(100);--CR54687
      v_pin_sp_rec x_service_plan%ROWTYPE; --CR54687
      v_sub_bus_org varchar2(100);
      o_dummy varchar2(100);

  CURSOR ESN_cur
  IS
    SELECT objid,
      part_serial_no,
      x_part_inst2contact
    FROM table_part_inst
    WHERE part_serial_no = ip_esn
    AND x_domain         = 'PHONES';
  esn_rec esn_cur%rowtype;

  CURSOR CONTACT_cur
  IS
    SELECT objid
    FROM table_contact
    WHERE objid = ip_contact_objid;

  CONTACT_rec CONTACT_cur%rowtype;

  CURSOR Mod_Cur(v_part_number IN VARCHAR2)
  IS
    SELECT m2.objid
    FROM table_mod_level m2,
      table_part_num pn2
    WHERE 1                   =1
    AND pn2.part_number       = v_part_number
    AND m2.part_info2part_num = pn2.objid
    ORDER BY m2.eff_date DESC;
  mod_rec mod_cur%rowtype;
  CURSOR CC_INV_CUR (res_id VARCHAR2)
  IS
    SELECT x_red_card_number,
      X_SMP
    FROM Table_X_CC_Red_Inv
    WHERE x_reserved_id = res_id ;
  CC_INV_REC CC_INV_CUR%rowtype;
  CURSOR INV_BIN_CUR
  IS
    SELECT table_inv_bin.objid
    FROM table_inv_bin,
      table_inv_role,
      table_inv_locatn,
      table_site
    WHERE table_inv_role.inv_role2site     = table_site.objid
    AND table_inv_role.inv_role2inv_locatn = table_inv_locatn.objid
    AND table_inv_bin.inv_bin2inv_locatn   = table_inv_locatn.objid
    AND table_site.site_id                 = '7882';
  INV_BIN_REC INV_BIN_CUR%rowtype;
  CURSOR code_CUR (p_code varchar2)
  IS
    SELECT objid FROM table_x_code_table WHERE x_code_number = p_code;
  code_REC code_CUR%rowtype;
BEGIN
  op_pin       := NULL;
  op_case_id   := NULL;
  op_error_msg := 'Success';
  op_error_num := '0';


  -- GET THE RESERVED PIN FOR THE ESN REQUESTED --------------------------------
  -- IF YES RETURN PIN, NO CASE REQUIRED
  BEGIN
    SELECT pin.x_red_code
    INTO op_pin
    FROM table_part_inst pin,
      table_part_inst esn,
      table_part_num pn_pin,
      table_mod_level ml_pin
    WHERE 1                       =1
    AND pin.x_part_inst_status    in ('40','400') -- RESERVED  -- Regression defect#36811
    AND pin.part_to_esn2part_inst = esn.objid
    AND ml_pin.part_info2part_num = pn_pin.objid
    AND pin.n_part_inst2part_mod  = ml_pin.objid
    AND esn.part_serial_no        = ip_esn
    AND pn_pin.part_number        = ip_pin_part_num
    AND rownum                    <2;
    RETURN;
  EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('NO PIN RESERVED UNDER '||ip_pin_part_num);
  END;
  -- NO PIN RESERVED - CONTINUE ------------------------------------------------
  -- COLLECT ESN OBJID
  v_activity := 'OBTAINING ESN INFO';


IF ip_esn IS NOT NULL THEN
  OPEN esn_cur;
  FETCH esn_cur INTO esn_rec;
  IF esn_cur%notfound THEN
    CLOSE esn_cur;
    --op_error_num := '100';
    --op_error_msg := 'ERROR - Serial Number not found: '||TO_CHAR(ip_esn);
    --RETURN;
    v_esn        := null;
    v_card_status:='42';
  ELSE
    CLOSE esn_cur;
    v_esn        := ip_esn;
      --  v_card_status:='40'; commented for CR54687
        --CR54687 WF Pin NT/TF Paygo - 40/ all others 400
        --   n_pin_sp_id  := sa.service_plan.sp_get_pin_service_plan_id(ip_pin_part_num);

        sa.service_plan.sp_get_partnum_service_plan ( ip_part_number    => ip_pin_part_num  ,
                                op_result_set     =>    v_result_set,
                                op_err_num        =>    v_err_num,
                                op_err_string     =>    v_err_string);
        LOOP
        FETCH v_result_set
        INTO  v_pin_sp_rec;
        EXIT  WHEN v_result_set%NOTFOUND;
        End LOOP;

        if v_err_num = 0 then
        v_dest_sp_grp    := sa.get_serv_plan_value(v_pin_sp_rec.objid, 'SERVICE_PLAN_GROUP');
        end if;

	if ip_orgid = 'SIMPLE_MOBILE' then
        sa.phone_pkg.get_sub_brand(
          I_ESN => ip_esn,
          o_sub_brand => v_sub_bus_org,
          O_ERRNUM => o_dummy,
          o_errstr => o_dummy
        );
	end if;

        if ip_orgid='TRACFONE' and (v_dest_sp_grp ='PAY_GO' or v_dest_sp_grp ='' )then
         v_card_status:='40';
        elsif ip_orgid='NET10' and v_dest_sp_grp ='PAY_GO' then
        v_card_status:='40';
	elsif ip_orgid ='WFM' then
		v_card_status:='40';
	elsif ip_orgid = 'SIMPLE_MOBILE' then
		if v_sub_bus_org = 'GO_SMART' then
		v_card_status:='400';
		else
		v_card_status:='40';
		end if;
        else
         v_card_status:='400';
        end if;

      END IF;
ELSE
  v_card_status:='42';
  v_esn := null;
END IF;

IF ip_contact_objid IS NOT NULL THEN
    OPEN contact_cur;
    FETCH contact_cur INTO contact_rec;
    IF contact_cur%notfound THEN
      CLOSE contact_cur;
      op_error_num := '115';
      op_error_msg := 'ERROR - Contact not found: '||TO_CHAR(ip_contact_objid);
      RETURN;
    END IF;
    CLOSE contact_cur;
ELSE
   op_error_num := '115';
   op_error_msg := 'ERROR - Contact not found';
   RETURN;
END IF;


    v_activity := 'GETTING PART NUMBER MOD LEVEL';
  OPEN mod_cur(ip_pin_part_num);
  FETCH mod_cur INTO mod_rec;
  IF mod_cur%notfound THEN
    CLOSE mod_cur;
    op_error_num := '110';
    op_error_msg := 'ERROR - mod level not found: '||ip_pin_part_num;
    RETURN;
  END IF;
  CLOSE mod_cur;
    v_activity := 'GETTING INVENTORY BIN';
  OPEN inv_bin_cur;
  FETCH inv_bin_cur INTO inv_bin_rec;
  IF inv_bin_cur%notfound THEN
    CLOSE inv_bin_cur;
    op_error_num := '120';
    op_error_msg := 'ERROR - inv_bin value not found. ';
    RETURN;
  END IF;
  CLOSE inv_bin_cur;
    v_activity := 'GETTING REVERVED CODE OBJID';
  OPEN code_cur (v_card_status);
  FETCH code_cur INTO code_rec;
  IF code_cur%notfound THEN
    CLOSE code_cur;
    op_error_num := '130';
    op_error_msg := 'ERROR - code_table value not found.';
    RETURN;
  END IF;
  CLOSE code_cur;
  v_activity := 'OBTAINING PIN INFO';
  sa.NEXT_ID( P_SEQ_NAME => P_SEQ_NAME, O_NEXT_VALUE => O_NEXT_VALUE, O_FORMAT => O_FORMAT );
  sa.sp_reserve_app_card ( p_reserve_id => O_NEXT_VALUE, p_total => 1, p_domain => NULL, p_status => p_status, p_msg => p_msg);
  OPEN cc_inv_cur (O_NEXT_VALUE);
  FETCH cc_inv_cur INTO cc_inv_rec;
  IF cc_inv_cur%notfound THEN
    CLOSE cc_inv_cur;
    op_error_num := '140';
    op_error_msg := 'ERROR - pin inventory depleted';
    RETURN;
  END IF;
  CLOSE cc_inv_cur;
  -- GET THE USER OBJID
  v_activity := 'GETTING USER OBJID';
  SELECT objid
  INTO v_user_objid
  FROM table_user
  WHERE s_login_name = upper(ip_login_name);
  SELECT sa.seq('part_inst') INTO v_new_pi_objid FROM dual;
  /* insert into table_part_inst */
    v_activity := 'INSERTING RED CARD PART_INST';
  INSERT
  INTO table_part_inst
    (
      objid,
      last_pi_date,
      last_cycle_ct,
      next_cycle_ct,
      last_mod_time,
      last_trans_time,
      date_in_serv,
      repair_date,
      warr_end_date,
      x_cool_end_date,
      part_status,
      hdr_ind,
      x_sequence,
      x_insert_date,
      x_creation_date,
      x_domain,
      x_deactivation_flag,
      x_reactivation_flag,
      x_red_code,
      part_serial_no,
      x_part_inst_status,
      part_inst2inv_bin,
      created_by2user,
      status2x_code_table,
      n_part_inst2part_mod,
      part_to_esn2part_inst
    )
    VALUES
    (
      v_new_pi_objid,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss'),
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss'),
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss') ,
      TO_DATE('01/01/1753 00:00:00', 'mm/dd/yyyy hh24:mi:ss'),
      'Active',
      0,
      0,
      SYSDATE,
      SYSDATE,
      'REDEMPTION CARDS',
      0,
      0,
      cc_inv_rec.x_red_card_number,
      cc_inv_rec.X_SMP,
      v_card_status,
      inv_bin_rec.objid,
      v_user_objid,
      code_rec.objid,
      mod_rec.objid,
      decode(ip_esn,'BYOP',null,esn_rec.objid)
    ) ;

  op_pin := cc_inv_rec.x_red_card_number;
  -- UPDATE RED CARD PI HIST ---------------------------------------------------
  v_activity := 'INSERTING HISTORY';
  v_hist_ret := toss_util_pkg.insert_pi_hist_fun (ip_part_serial_no => v_pin_part_serial_no, ip_domain => NULL, -- DEAD PARAM
  ip_action => 'WORKFORCE PIN', ip_prog_caller => NULL                                                          -- DEAD PARAM
  );
  -- CREATE AND CLOSE UNITS CASE
  -- CREATE THE CASE
  v_activity := 'CREATING CASE';
  v_case_detail :=  'PART_NUMBER||' || ip_pin_part_num||'||'||
                    -- 'PIN||' || cc_inv_rec.x_red_card_number||'||'|| -- CR53274 WF PIN Ticket Update
                    'SNP||' || cc_inv_rec.X_SMP;

  sa.CLARIFY_CASE_PKG.CREATE_CASE(
                P_TITLE => 'Replacement Service Plan',
                P_CASE_TYPE => 'Units',
                P_STATUS => 'Solving',
                P_PRIORITY => 'High',
                P_ISSUE => ip_reason,
                P_SOURCE => 'TAS',
                P_POINT_CONTACT => NULL,
                P_CREATION_TIME => sysdate,
                P_TASK_OBJID => NULL,
                P_CONTACT_OBJID => nvl(contact_rec.objid,esn_rec.x_part_inst2contact),
                P_USER_OBJID => v_user_objid,
                P_ESN => v_esn,
                P_PHONE_NUM => NULL,
                P_FIRST_NAME => NULL,
                P_LAST_NAME => NULL,
                P_E_MAIL => null,
                P_DELIVERY_TYPE => null,
                P_ADDRESS => NULL,
                P_CITY => NULL,
                P_STATE => NULL,
                P_ZIPCODE => NULL,
                P_REPL_UNITS => null,
                P_FRAUD_OBJID => null,
                P_CASE_DETAIL => v_case_detail,
                P_PART_REQUEST => NULL,
                P_ID_NUMBER => op_case_id,
                P_CASE_OBJID => v_case_objid,
                P_ERROR_NO => v_error_no,
                P_ERROR_STR => v_error_str
              );

--  clarify_case_pkg.create_case (p_title => 'Compensation Service Plan', p_case_type => 'Units', p_status => 'Solving', p_priority => 'High', p_issue => ip_reason, p_source => 'TAS', p_point_contact => NULL, p_creation_time => sysdate, p_task_objid => NULL, p_contact_objid => v_contact_objid, p_user_objid => v_user_objid, p_esn => ip_esn, p_phone_num => NULL, p_first_name => NULL, p_last_name => NULL, p_e_mail => NULL, p_delivery_type => NULL, p_address => NULL, p_city => NULL, p_state => NULL, p_zipcode => NULL, p_repl_units => NULL, p_fraud_objid => NULL, p_case_detail => NULL, p_part_request => NULL, p_id_number => op_case_id, p_case_objid => v_case_objid, p_error_no => v_error_no, p_error_str => v_error_str);
  dbms_output.put_line('P_PIN = ' || op_pin);
  dbms_output.put_line('P_ID_NUMBER = ' || op_case_id);
  dbms_output.put_line('P_CASE_OBJID = ' || v_case_objid);
  dbms_output.put_line('P_ERROR_NO = ' || v_error_no);
  dbms_output.put_line('P_ERROR_STR = ' || v_error_str);

  -- ADD NOTES TO CASE -------------------------------------------------------
  v_activity := 'LOGGING NOTES';
  clarify_case_pkg.log_notes (p_case_objid => v_case_objid, p_user_objid => v_user_objid, p_notes => ip_notes||CHR(10)||' GENERATED WORKFORCE PN: '||ip_pin_part_num, p_action_type => NULL, p_error_no => v_error_no, p_error_str => v_error_str);
  -- CLOSE THE CASE ----------------------------------------------------------
  v_activity := 'CLOSING CASE';
  clarify_case_pkg.close_case(p_case_objid => v_case_objid, p_user_objid => v_user_objid, p_source => 'TAS', p_resolution => 'Closed', p_status => 'Closed', p_error_no => v_error_no, p_error_str => v_error_str);
  dbms_output.put_line('P_ERROR_NO = ' || v_error_no);
  dbms_output.put_line('P_ERROR_STR = ' || v_error_str);
EXCEPTION
WHEN OTHERS THEN
  op_error_msg := 'ERROR - '||v_activity;
  op_error_num := '200';
END workforce_pin;
---------------------------------------------------------------------------------------------
  --Overload for Optional PIN Invalidation
  procedure workforce_pin (ip_esn          varchar2,
                                  ip_pin_part_num varchar2,
                                  ip_login_name   varchar2,
                                  ip_reason       varchar2,
                                  ip_notes        varchar2,
                                  ip_contact_objid varchar2,
                                  ip_invalid_pin varchar2,
                                  ip_old_esn        varchar2,
                                  ip_current_esn    varchar2,
                                  ip_pin_or_marc_id    varchar2,
                                  ip_ticket_num        varchar2,
                                  ip_issue            varchar2,
                                  ip_action_taken    varchar2,
     ip_orgid        varchar2,  --added for CR54687
     ip_service_plan_objid        varchar2, --added for CR54687
      ip_service_type    varchar2,      --added for CR54687
                                  op_pin out varchar2,
                                  op_case_id out varchar2,
                                  op_error_num out varchar2,
                                  op_error_msg out varchar2) is

  -- UPDATE CASE DETAILS
  v_case_objid varchar2(30);
  v_case_detail varchar2(4000);
  v_user_objid NUMBER;

  cursor pin_cur is
  select part_serial_no,x_part_inst_status
  from sa.table_part_inst
  where x_red_code = trim(ip_invalid_pin)
  and (part_to_esn2part_inst in (select objid from sa.table_part_inst where part_serial_no = ip_esn and x_domain = 'PHONES') or part_to_esn2part_inst is null);

  pin_rec pin_cur%rowtype;
  v_return varchar2(100);
  v_pin_notes varchar2(500);
begin

   v_pin_notes:=ip_notes;

   if ip_invalid_pin is not null then
      open pin_cur;
      fetch pin_cur into pin_rec;
      if pin_cur%found then
         if pin_rec.x_part_inst_status <>'44' then
              v_Return := ADFCRM_CARRIER.MARK_CARD_INVALID(
                P_REASON => ip_reason,
                P_ESN => ip_esn,
                P_CARD_NO => trim(IP_INVALID_PIN),
                P_SNP => PIN_REC.PART_SERIAL_NO,
                P_LOGIN_NAME => IP_LOGIN_NAME
            );
            if v_Return like '%Card Update Complete%' then --Successful Invalidation
               v_pin_notes:=v_pin_notes||CHR(10)||' Card# '||IP_INVALID_PIN||' Invalidated '||CHR(10);
            else
               v_pin_notes:=v_pin_notes||CHR(10)||' Card# '||IP_INVALID_PIN||' '||v_return||' '||CHR(10);
            end if;
         else
            v_pin_notes:=v_pin_notes||CHR(10)||' Card# '||IP_INVALID_PIN||' Already Invalid '||CHR(10);
         end if;
      else
         v_pin_notes:=v_pin_notes||CHR(10)||' Card# '||IP_INVALID_PIN||' Not found or reserved to other ESN '||CHR(10);
      end if;
      close pin_cur;
   end if;
     --added for CR54687
      workforce_pin (ip_esn => ip_esn, ip_pin_part_num =>ip_pin_part_num, ip_login_name => ip_login_name, ip_reason =>ip_reason, ip_notes => v_pin_notes, ip_contact_objid => ip_contact_objid,ip_orgid => ip_orgid,ip_service_plan_objid => ip_service_plan_objid ,ip_service_type => ip_service_type , op_pin => op_pin, op_case_id => op_case_id, op_error_num => op_error_num, op_error_msg => op_error_msg);

  /*  --commented for CR54687
  workforce_pin (ip_esn => ip_esn,
                  ip_pin_part_num =>ip_pin_part_num,
                  ip_login_name => ip_login_name,
                  ip_reason =>ip_reason,
                  ip_notes => v_pin_notes,
                  ip_contact_objid => ip_contact_objid,
                  op_pin => op_pin,
                  op_case_id => op_case_id,
                  op_error_num => op_error_num,
                  op_error_msg => op_error_msg);*/


    -- CR50956 - Workforce Pin Changes
    if op_case_id is not null and op_error_num = '0' then

      select objid
      into   v_case_objid
      from   table_case
      where  id_number = op_case_id;

      SELECT objid
      INTO v_user_objid
      FROM table_user
      WHERE s_login_name = upper(ip_login_name);

      v_case_detail := 'OLD_ESN||'||ip_old_esn||
                       '||CURR_ESN||'||ip_current_esn||
                       '||OLD_PIN_OR_MERCHANT_ID||'||ip_pin_or_marc_id||
                       '||TICKET_NUMBER||'||ip_ticket_num||
                       '||ISSUE||'||ip_issue||
                       '||ACTION_TAKEN||'||ip_action_taken;

      clarify_case_pkg.update_case_dtl(p_case_objid  => v_case_objid,
                                       p_user_objid  => v_user_objid,
                                       p_case_detail => v_case_detail,
                                       p_error_no    => op_error_num,
                                       p_error_str   => op_error_msg);

    end if;



end;
---------------------------------------------------------------------------------------------

function workforce_ild_pin (ip_esn varchar2, ip_login_name varchar2) return varchar2 is

   cursor c1 is
   select i.pin
   from adfcrm_ild_pin_inventory i,
        adfcrm_ild_pin_part_num p,
        table_part_inst pi,
        table_mod_level ml,
        table_part_num pn,
        table_bus_org bo
   where i.ild_part_objid = p.objid
   and pi.part_serial_no = ip_esn
   and pi.n_part_inst2part_mod = ml.objid
   and pn.objid = ml.part_info2part_num
   and pn.part_num2bus_org = bo.objid
   and i.status = 'NOT REDEEMED'
   and p.org_id = bo.ORG_ID
   and rownum < 2;

   r1 c1%rowtype;
   check_count number;
   message varchar2(100);
begin

   select count(*)
   into check_count
   from adfcrm_ild_pin_inventory
   where rqst_esn = ip_esn
   and rqst_date >= sysdate - 1;   --24 hrs

   if check_count < 2 then
      open c1;
      fetch c1 into r1;
         if c1%found then
           update adfcrm_ild_pin_inventory
           set RQST_ESN = ip_esn,
               STATUS = 'REDEEMED',
               RQST_USER = ip_login_name,
               RQST_DATE = sysdate
           where pin = r1.pin;
           commit;
           message:=r1.pin;
         else
           message:='ILD PIN Inventory depleted';
         end if;
         close c1;
   else
      message:='ILD Workforce pin quota exceeded (Max 2 in 24hrs)';
   end if;
   return message;

end workforce_ild_pin;
  --------------------------------------------------------------------------------------------
  function family_plan_make_primary(ip_esn varchar2,
                                    ip_bp_objid varchar2) --Billing Program Objid
  return varchar2
  is
  -- Get Enrollment Record
    cursor new_primary_cur
    is
      select objid,
        pgm_enroll2pgm_group
      from sa.x_program_enrolled
      where x_esn                  = ip_esn
      and pgm_enroll2pgm_parameter = ip_bp_objid
      and x_enrollment_status      = 'ENROLLED';
    new_primary_rec new_primary_cur%rowtype;
    v_message varchar2(100):='Primary Changed';

  begin
    open new_primary_cur;
    fetch new_primary_cur into new_primary_rec;
    if new_primary_cur%notfound then
      close new_primary_cur;
      v_message := 'ESN cannot become primary until enrolled';
      return v_message;
    end if;
    close new_primary_cur;

    update sa.x_program_enrolled
    set x_is_grp_primary       = 0,
      pgm_enroll2pgm_group     = new_primary_rec.objid
    where pgm_enroll2pgm_group = new_primary_rec.pgm_enroll2pgm_group
    or objid                   = new_primary_rec.pgm_enroll2pgm_group;

    update sa.x_program_enrolled
    set x_is_grp_primary   = 1,
      pgm_enroll2pgm_group = null
    where objid            = new_primary_rec.objid;

    commit;
    return v_message;

  exception
    when others then
      return 'ERROR - '||sqlerrm;
  end family_plan_make_primary;
  --------------------------------------------------------------------------------------------

 --CR26941 Handset Protection begin
  FUNCTION is_restricted_handset_varchar2 (
    PP_OBJID  IN NUMBER,
    pc_objid  in number
  ) return varchar2 is
  begin
    if VALUE_ADDEDPRG.is_restricted_handset(pp_objid,pc_objid)
    then
       RETURN 'TRUE';
    else
      RETURN 'FALSE';
    end if;
  end;

  FUNCTION is_restricted_state_varchar2 (
    pp_objid    in number,
    ip_zipcode  in varchar2
  ) return varchar2 is
  begin
    if VALUE_ADDEDPRG.is_restricted_state(pp_objid,ip_zipcode)
    then
      RETURN 'TRUE';
    else
      RETURN 'FALSE';
    end if;
  end;

  FUNCTION is_valid_status_varchar2 (
    pp_objid  in number,
    ip_status in varchar2
  ) return varchar2 is
  begin
    if VALUE_ADDEDPRG.is_valid_status(pp_objid,ip_status)
    then
       RETURN 'TRUE';
    else
       RETURN 'FALSE';
    end if;
  end;
  --CR26941 Handset Protection  end

function is_manual_code_required(
    ip_esn in varchar2
  ) return varchar2 IS

    cursor get_esn_info(ip_esn in varchar2) is
        select
              pi.part_serial_no esn,
              li.part_serial_no line,
              pi.x_iccid iccid,
              pn.x_technology technology,
              nvl(pn.x_dll,0) dll,
              NVL(pn.x_ota_allowed, 'N') ota_allowed,
              pa.x_parent_id parent_id,
              upper(pa.x_parent_name) parent_name,
              ls.x_code_name li_status,
              nvl(pa.x_ota_carrier,'N') ota_carrier
        from  sa.table_part_inst           pi
             ,sa.table_mod_level           ml
             ,sa.table_part_num            pn
             ,sa.table_part_inst           li
             ,sa.table_x_carrier           ca
             ,sa.table_x_carrier_group     gr
             ,sa.table_x_parent            pa
             ,(select x_code_number, x_code_name
               from sa.table_x_code_table
               where x_code_type = 'LS') ls
        where pi.part_serial_no = ip_esn
        and pi.x_domain = 'PHONES'
        and ml.objid = pi.n_part_inst2part_mod
        and pn.objid = ml.part_info2part_num
        and li.part_to_esn2part_inst = pi.objid
        and ca.objid = li.part_inst2carrier_mkt
        and gr.objid = ca.carrier2carrier_group
        and pa.objid = gr.x_carrier_group2x_parent
        and ls.x_code_number = li.x_part_inst_status
        ;
    get_esn_info_rec  get_esn_info%rowtype;
    is_required varchar2(30);
    records_found number;
    call_trans_id number;
begin
    is_required := 'false';

        --CHECK IF EXIST CODES IN OTA PENDING
        select count(nvl(h.code_hist2call_trans,ht.x_code_temp2x_call_trans)) records_found,
            max(nvl(h.code_hist2call_trans,ht.x_code_temp2x_call_trans)) call_trans_id
        into   records_found, call_trans_id
        from   table_x_code_hist h,
               table_x_code_hist_temp ht,
               table_x_call_trans t
        where  t.x_service_id = ip_esn
        and    h.code_hist2call_trans (+) = t.objid
        and    ht.x_code_temp2x_call_trans (+) = t.objid
        and    nvl(h.x_code_accepted,'OTAPENDING') = 'OTAPENDING'
        and    nvl(h.x_gen_code,ht.x_code) is not null;


        if records_found > 0 then

            if has_ota_cdma_pending(ip_esn) = 0 then
            --IF OTA PENDING TRANSACTION NOT FOUND (table_x_ota_transaction) THEN MANUAL PROGRAMMING
               is_required := 'true';
            else
                open get_esn_info(ip_esn);
                fetch get_esn_info into get_esn_info_rec;
                if get_esn_info%found then
                   if get_esn_info_rec.iccid is null and
                      get_esn_info_rec.parent_id not in ('5','75') and
                      get_esn_info_rec.dll > 0 and
                      get_esn_info_rec.li_status not like '%RESERVED%'
                   then
                      --Above conditions were grabbed from WEBCSR
                      is_required := 'true';
                   end if;

                   /***
                       if get_esn_info_rec.ota_carrier = 'N' or
                          get_esn_info_rec.ota_allowed = 'N'
                       then
                          is_required := 'true';
                       end if;
                   ***/

                   if get_esn_info_rec.iccid is null and
                      get_esn_info_rec.parent_id in ('39')
                   then
                      is_required := 'true';
                   end if;
                end if;
                close get_esn_info;
            end if;
        end if;

    return is_required;
end is_manual_code_required;

/********************************************************
******  block_promo_esn_upgrade *************************
******  Promo TO ESNs are not candidate for upgrade ********
******  CR29387 *****************************************/
function block_promo_esn_upgrade (ip_esn in varchar2)
  return varchar2 is

  cursor promo_pin_cur is
  select pi.x_red_code
  from table_part_inst pi,
     table_mod_level ml,
     table_part_num pn
  where pi.part_to_esn2part_inst in (select esnpi.objid
                                from table_part_inst esnpi,
                                table_mod_level esnml,
                                table_part_num esnpn,
                                table_part_class esnpc,
                                table_bus_org bo
                                where esnpi.part_serial_no =  ip_esn
                                and esnpi.x_domain = 'PHONES'
                                and Esnpi.N_Part_Inst2part_Mod = esnml.objid
                                and Esnml.Part_Info2part_Num = esnpn.objid
                                and Esnpn.Part_Num2part_Class = esnpc.objid
                                and bo.objid = esnpn.part_num2bus_org
                                and bo.org_id <> 'TRACFONE' --TracFone exclusion added by CR40373
                                and sa.GET_PARAM_BY_NAME_FUN(esnpc.name,'DEVICE_TYPE') = 'BYOP')
  and pi.x_domain = 'REDEMPTION CARDS'
  and pi.x_part_inst_status in ('40','400')
  and Pi.N_Part_Inst2part_Mod = ml.objid
  and Ml.Part_Info2part_Num = pn.objid
  and Pn.Part_Type = 'FREE';

  promo_pin_rec promo_pin_cur%rowtype;

begin

--    if ip_esn is not null then
--      open promo_pin_cur;
--      fetch promo_pin_cur into promo_pin_rec;
--      if promo_pin_cur%found then
--         close promo_pin_cur;
--         return 'true';
--      else
--         close promo_pin_cur;
--         return 'false';
--      end if;
--    else
--      return 'false';
--    end if;
     return 'false';

end  block_promo_esn_upgrade;

function upd_port_in_flag (p_esn varchar2)
return varchar2 is
begin

  UPDATE table_part_inst
     SET x_port_in = 0
   WHERE part_serial_no = p_esn
   AND   x_domain = 'PHONES'
   ;
  commit;

  return '0';  --success
  exception
    when others then
      rollback;
      return 'ERROR - Unable to update port in flag.';
end upd_port_in_flag;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
  procedure validate_promo(ip_red_card varchar2,
                           ip_promo_code varchar2,
                           ip_esn varchar2,
                           ip_cust_id varchar2,
                           ip_contact_objid varchar2,
                           ip_user_objid varchar2,
                           ip_red_method varchar2,  -- THIS IS REQUIRED VALUES ARE 'IVR','WEB',' OTA HANDSET'
                           op_err_msg out varchar2,
                           op_err_num out varchar2)
  as

    p_red_card varchar2(30);
    p_smp varchar2(30);
    p_org_id table_bus_org.org_id%type;
    po_refcursor sys_refcursor;

    p_card_status varchar2(40);
    p_card_units varchar2(40);
    p_card_days varchar2(40);
    p_card_brand varchar2(40);
    var_7 varchar2(300);

    p_card_desc varchar2(300);
    p_card_partnum varchar2(30);
    p_card_type varchar2(300);
    p_part_type varchar2(300);
    p_web_card_desc varchar2(300);
    p_sp_web_card_desc varchar2(300);
    p_ild_type varchar2(300);
    p_esn_sp_objid number;
    p_login_name table_user.login_name%type;

    p_case_exists number;
    p_redemption_date varchar2(30);
    p_date_diff number;
    p_sourcesystem varchar2(30);
    p_trans_objid number;

    p_zipcode varchar2(30);
    p_technology varchar2(30) := null;
    p_language varchar2(30)  := 'ENGLISH';  -- THIS IS REQUIRED
    p_discount_amount varchar2(30) := null;
    p_promo_units number := null;
    p_access_days number := null;
    p_contact_objid number;
    p_cust_id varchar2(30);
    p_red_card_access_days number;
    p_red_card_red_units number;
    p_call_trans_reason varchar2(30) := 'Promo:PromoFailure';

    p_promo_objid number;
    p_x_units number;
    p_x_access_days number;
    p_x_promo_type varchar2(30);
    p_x_english_short_text clob;

    esn_invalid exception;
    outside_of_grace_period exception;
    redemption_case_exists exception;
    missing_parameters exception;
    redemption_card_unused exception;
    no_contact_found exception;
    less_than_ten_units exception;
    invalid_promo_code exception;

    -- NEW CASE VARIABLES
    p_case_type table_case.x_case_type%type := 'WEB/IVR Failure'; --  THIS IS TAKEN FROM file: caseDefMapping_en.properties -- caseType.27 (typeId = 27)
    p_case_title table_case.title%type := 'Promotion Failure'; --  THIS IS TAKEN FROM file: caseDefMapping_en.properties -- caseType.27 (typeId = 27)
    p_case_status varchar2(30) := 'Pending Credit'; -- UNABLE TO FIND MY ANSWER IN THE JAVA, CHOOSING PENDING CREDIT FOR NOW
    p_case_priority varchar2(30) := 'High'; -- UNABLE TO FIND MY ANSWER IN THE JAVA, CHOOSING HIGH FOR NOW
    p_case_source varchar2(30) := 'Customer'; -- UNABLE TO FIND MY ANSWER IN THE JAVA, CHOOSING HIGH FOR NOW
    p_case_poc varchar2(200) := 'TAS';
    p_case_issue varchar2(30) := p_case_title;
    p_case_part_req varchar2(200) := null;
    p_first_name varchar2(200);
    p_last_name varchar2(200);
    p_case_notes varchar2(200) := p_case_type||'-'||p_case_title;
    v_Return VARCHAR2(200);

    -- UPDATE CASE DETAILS
    p_case_id_number varchar2(30);
    p_case_detail varchar2(4000);

    -- CLOSE CASE VARIABLES
    p_case_objid number;
    p_resolution varchar2(30) := null; -- NOT ABLE TO FIND IT IN THE JAVA, LEFT NULL
    p_status varchar2(30) := 'Closed';
    p_notes varchar2(200);

    -- SET CALL TRANS VARS
    p_min varchar2(30);
    p_mod_level_objid number;
    p_dealer_objid number;
    p_dealer_id varchar2(80);
    p_dealer_name varchar2(80);
    p_carrier_objid number;

    -- WORKFORCE PIN CASE ID
    p_wfp_case_id_number varchar2(30);
    p_wfp_pin varchar2(30);
    p_wfp_flag number := 0;

    procedure ins_hist(ip_promo_code varchar2,ip_transact_type varchar2,ip_source_system varchar2,ip_zip_code varchar2,ip_esn varchar2,ip_promo_units varchar2,ip_access_days varchar2,ip_error_num varchar2)
    as
    begin
      dbms_output.put_line('=========== INSERT PROMOCODE HIST ======================================');
      dbms_output.put_line('ins_hist(ip_promo_code ='||ip_promo_code||
                                     ',ip_transact_type ='||ip_transact_type||
                                     ',ip_source_system ='||ip_source_system||
                                     ',ip_zip_code ='||ip_zip_code||
                                     ',ip_esn ='||ip_esn||
                                     ',ip_promo_units ='||ip_promo_units||
                                     ',ip_access_days ='||ip_access_days||
                                     ',ip_error_num ='||ip_error_num||')');
      insert into x_promocode_hist
        (promo_code,transact_type,source_system,zip_code,esn,promo_units,access_days,error_num,time_stamp)
      values
        (ip_promo_code,ip_transact_type,ip_source_system,ip_zip_code,ip_esn,ip_promo_units,ip_access_days,ip_error_num,sysdate);

    end ins_hist;

    procedure ins_pending_red(ip_pend_red2x_promotion number, -- PROMO OBJID
                              ip_pend_red2site_part number, -- ESN SITE PART OBJID
                              ip_pend_type varchar2, -- HARDCODED AS IN WEBCSR
                              ip_granted_from2x_call_trans number) -- CALL TRANS OBJID
    as
    begin

      dbms_output.put_line('ins_pending_red (ip_pend_red2x_promotion='||ip_pend_red2x_promotion||
                                            ',ip_pend_red2site_part='||ip_pend_red2site_part||
                                            ',ip_pend_type='||ip_pend_type||
                                            ',ip_granted_from2x_call_trans='||ip_granted_from2x_call_trans);

      insert into sa.table_x_pending_redemption
        (objid,pend_red2x_promotion,x_pend_red2site_part,x_pend_type,x_granted_from2x_call_trans)
      values
        (sa.seq('x_pending_redemption'),ip_pend_red2x_promotion,ip_pend_red2site_part,ip_pend_type,ip_granted_from2x_call_trans);

    end ins_pending_red;

    procedure process_units (ip_units_balance number,
                             ip_promo_objid number,
                             ip_esn_sp_objid number,
                             ip_call_trans_objid number)
    as
      number_of_cards number;
      units_balance number := ip_units_balance;
    begin
      dbms_output.put_line('=========== COMPENSATION UNITS RESULT ======================================');
      dbms_output.put_line('Number of units to give = '||units_balance);

      if ip_units_balance != 0 then
        for i in (select  max(objid), x_units units
                  from table_x_promotion
                  where x_promo_type = 'Customer Service'
                  and sysdate between x_start_date and x_end_date
                  and x_units between 9 and units_balance
                  group by x_units
                  order by x_units desc)

        loop
          if (units_balance >= i.units) then
           number_of_cards := floor(units_balance/i.units);
           units_balance := mod(units_balance, i.units);

           ins_pending_red(ip_pend_red2x_promotion => ip_promo_objid,
                           ip_pend_red2site_part => ip_esn_sp_objid,
                           ip_pend_type => 'REPL',
                           ip_granted_from2x_call_trans => ip_call_trans_objid);
          else
            continue;
          end if;
          dbms_output.put_line( i.units ||'- Number of cards = '|| number_of_cards);
        end loop;
      end if;

    end process_units;

    procedure process_days (ip_days_balance number,
                            ip_promo_objid number,
                            ip_esn_sp_objid number,
                            ip_call_trans_objid number)
    as
      number_of_cards number;
      days_balance number := ip_days_balance;
    begin
      dbms_output.put_line('=========== COMPENSATION DAYS RESULT ======================================');
      dbms_output.put_line('Number of days to give = '||days_balance);

      if ip_days_balance != 0 then
        for i in (select  max(objid), x_access_days days
                  from table_x_promotion
                  where x_promo_type = 'Customer Service'
                  and sysdate between x_start_date and x_end_date
                  and x_units between 9 and days_balance
                  group by x_access_days
                  order by x_access_days desc)

        loop
          if (days_balance >= i.days) then
           number_of_cards := floor(days_balance/i.days);
           days_balance := mod(days_balance, i.days);

           ins_pending_red(ip_pend_red2x_promotion => ip_promo_objid,
                           ip_pend_red2site_part => ip_esn_sp_objid,
                           ip_pend_type => 'REPL',
                           ip_granted_from2x_call_trans => ip_call_trans_objid);
          else
            continue;
          end if;
          dbms_output.put_line( i.days ||'- Number of (days) cards = '|| number_of_cards);
        end loop;

      end if;

    end process_days;

    procedure upd_pi_warr_end_date(ip_esn varchar2, ip_access_days number)
    as
    begin
      dbms_output.put_line('=========== UPDATING WARRANTY END DATE ======================================');
      dbms_output.put_line('update table_part_inst (ip_esn ='||ip_esn||',ip_access_days = '||ip_access_days);
      update table_part_inst
      set    warr_end_date = warr_end_date+ip_access_days
      where part_serial_no = ip_esn;
    end upd_pi_warr_end_date;

    procedure set_call_trans(ip_min varchar2,
                             ip_site_part_objid varchar2,
                             ip_carrier_objid varchar2,
                             ip_dealer_objid varchar2,
                             ip_user_objid varchar2,
                             ip_esn varchar2,
                             ip_sourcesystem varchar2,
                             ip_units varchar2,
                             ip_reason varchar2,
                             ip_sub_sourcesystem varchar2)
    as
    begin
      dbms_output.put_line('=========== CREATE CALL TRANS ======================================');

      dbms_output.put_line('insert table_x_call_trans (ip_site_part_objid='||ip_site_part_objid||
                                                     ',ip_carrier_objid='||ip_carrier_objid||
                                                     ',ip_dealer_objid='||ip_dealer_objid||
                                                     ',ip_user_objid='||ip_user_objid||
                                                     ',ip_min='||ip_min||
                                                     ',ip_esn='||ip_esn||
                                                     ',ip_sourcesystem='||ip_sourcesystem||
                                                     ',ip_units='||ip_units||
                                                     ',ip_reason='||ip_reason||
                                                     ',ip_sub_sourcesystem='||ip_sub_sourcesystem||')');

      insert into table_x_call_trans
        (objid,
         call_trans2site_part,
         x_action_type,
         x_call_trans2carrier,
         x_call_trans2dealer,
         x_call_trans2user,
         x_line_status,
         x_min,
         x_service_id,
         x_sourcesystem,
         x_transact_date,
         x_total_units,
         x_action_text,
         x_reason,
         x_result,
         x_sub_sourcesystem,
         x_iccid)
      values
        (sa.seq('x_call_trans'),
         ip_site_part_objid, -- call_trans2site_part
         '8', -- x_action_type
         ip_carrier_objid, -- x_call_trans2carrier
         ip_dealer_objid, -- x_call_trans2dealer
         ip_user_objid, --x_call_trans2user
         '', -- x_line_status
         ip_min, --x_min
         ip_esn, --x_service_id
         ip_sourcesystem, -- x_sourcesystem
         sysdate, -- x_transact_date
         ip_units, -- x_total_units
         'CUST SERVICE', -- x_action_text
         ip_reason, -- x_reason
         'Completed', -- x_result
         ip_sub_sourcesystem, -- x_sub_sourcesystem
         '' -- x_iccid
         );

    end set_call_trans;

    procedure display_vars
    as
    begin
      dbms_output.put_line('=========== DISPLAY VARS ======================================');
      dbms_output.put_line('ip_esn = ' || ip_esn);
      dbms_output.put_line('p_min = ' || p_min);
      dbms_output.put_line('p_mod_level_objid = ' || p_mod_level_objid);
      dbms_output.put_line('p_esn_sp_objid = ' || p_esn_sp_objid);
      dbms_output.put_line('p_carrier_objid = ' || p_carrier_objid);
      dbms_output.put_line('p_trans_objid = ' || p_trans_objid);
      dbms_output.put_line('p_red_card = ' || p_red_card);
      dbms_output.put_line('p_contact_objid = ' || p_contact_objid);
      dbms_output.put_line('p_promo_objid = ' || p_promo_objid);
      dbms_output.put_line('p_x_units =='||p_x_units);
      dbms_output.put_line('p_x_access_days =='||p_x_access_days);
      dbms_output.put_line('p_x_promo_type =='||p_x_promo_type);
      dbms_output.put_line('p_x_english_short_text =='||p_x_english_short_text);
      dbms_output.put_line('p_promo_units = ' || p_promo_units||'(out param from validate_promo_code)');
      dbms_output.put_line('p_access_days = ' || p_access_days||'(out param from validate_promo_code)');
      dbms_output.put_line('ip_promo_code = ' || ip_promo_code);
      dbms_output.put_line('p_sourcesystem = ' || p_sourcesystem);
      dbms_output.put_line('p_org_id = ' || p_org_id);
      dbms_output.put_line('p_red_card_access_days = ' || p_red_card_access_days);
      dbms_output.put_line('p_red_card_red_units = ' || p_red_card_red_units);
      dbms_output.put_line('p_call_trans_reason = ' || p_call_trans_reason);
      dbms_output.put_line('p_case_type = ' || p_case_type);
      dbms_output.put_line('p_case_title = ' || p_case_title);
      dbms_output.put_line('p_case_status = ' || p_case_status);
      dbms_output.put_line('p_case_priority = ' || p_case_priority);
      dbms_output.put_line('p_case_source = ' || p_case_source);
      dbms_output.put_line('p_case_poc = ' || p_case_poc);
      dbms_output.put_line('p_case_issue = ' || p_case_issue);
      dbms_output.put_line('p_case_notes = ' || p_case_notes);
      dbms_output.put_line('p_first_name = ' || p_first_name);
      dbms_output.put_line('p_last_name = ' || p_last_name);
      dbms_output.put_line('p_case_objid = ' || p_case_objid);
      dbms_output.put_line('ip_user_objid = ' || ip_user_objid);
      dbms_output.put_line('p_case_id_number = ' || p_case_id_number);
      dbms_output.put_line('p_wfp_case_id_number = ' || p_wfp_case_id_number);
      dbms_output.put_line('p_wfp_pin = ' || p_wfp_pin);

      dbms_output.put_line('op_err_num = ' || op_err_num);
      dbms_output.put_line('op_err_msg = ' || op_err_msg);
    end display_vars;
  begin

    -- COLLECT REDCARD,PROMO, and ESN INFO
    p_cust_id := ip_cust_id;
    p_contact_objid := ip_contact_objid;


    op_err_num := '-94';
    op_err_msg := 'Agent info not found';
    select s_login_name
    into p_login_name
    from table_user
    where objid  = ip_user_objid;

    op_err_num := '-95';
    op_err_msg := 'Customer info not found';
    if ip_cust_id is not null then
      select objid
      into   p_contact_objid
      from table_contact
      where x_cust_id = ip_cust_id;
    else
      select x_cust_id
      into   p_cust_id
      from table_contact
      where objid = ip_contact_objid;
    end if;

    op_err_num := '-96';
    op_err_msg := 'Promotion Info not found';
    select objid,x_units,x_access_days,x_promo_type,x_english_short_text
    into   p_promo_objid,p_x_units,p_x_access_days,p_x_promo_type,p_x_english_short_text
    from   sa.table_x_promotion promo
    where  x_promo_code = ip_promo_code
    and    x_start_date < sysdate and x_end_date > sysdate;

    op_err_num := '-97';
    op_err_msg := 'Contact not found';
    if p_cust_id is not null and
       p_contact_objid is null then
      select objid
      into   p_contact_objid
      from   sa.table_contact
      where  x_cust_id = p_cust_id;
    elsif p_cust_id is null and
          p_contact_objid is null then
      op_err_num := '-97';
      op_err_msg := 'Contact not found';
      raise no_contact_found;
    end if;

    op_err_num := '-98';
    op_err_msg := 'Redemption card entered does not exist';
    select  x_red_code,x_smp
    into    p_red_card,p_smp
    from   (select x_red_code,part_serial_no x_smp
            from table_part_inst where x_red_code = ip_red_card union
            select x_red_code,x_smp
            from table_x_red_card where x_red_code = ip_red_card);

    if ip_red_method is null or ip_promo_code is null then
      op_err_num := '-1578';
      op_err_msg := 'Error in input parameters (ip_red_method,promo_code,zipcode)';
      raise missing_parameters;
    end if;

    -- IF ESN LENGTH IS NOT 11,15,18 ESN IS INVALID - 'ESN Not Valid' -1578
    if length(ip_esn) not in ('11','15','18') then
      op_err_num := '-1578';
      op_err_msg := 'ESN Not Valid';
      raise esn_invalid;
    end if;

    op_err_num := '-1579'; --NEW ERR NUMBER
    op_err_msg := 'ESN Not Found';
    select decode(pn.x_technology,'ANALOG','ANALOG','DIGITAL') tech,n_part_inst2part_mod
    into p_technology,p_mod_level_objid
    from table_part_inst pi, table_mod_level ml, table_part_num pn
    where part_serial_no = iP_ESN
    and x_domain = 'PHONES'
    and ml.objid = pi.n_part_inst2part_mod
    and pn.objid = ml.part_info2part_num;

    op_err_num := '-1081';
    op_err_msg := 'No Redemption Records Found';
    select to_char(red.x_red_date,'mm/dd/yyyy') x_red_date,
           floor(sysdate-red.x_red_date) date_diff,
           x_sourcesystem,
           trans.objid trans_objid,
           x_sub_sourcesystem org_id,
           x_access_days,x_red_units
    into   p_redemption_date,p_date_diff,p_sourcesystem,p_trans_objid, p_org_id,p_red_card_access_days,p_red_card_red_units
    from   sa.table_x_call_trans trans,
           sa.table_x_red_card red
    where  trans.x_service_id = ip_esn
    and    red.x_red_code = p_red_card
    and    trans.x_action_text = 'REDEMPTION'
    and    red.red_card2call_trans = trans.objid;

    if p_date_diff >5 then
      op_err_num := '-1082';
      op_err_msg := 'Redemption was attempted more than 5 days ago we cannot give any promo units';
      raise outside_of_grace_period;
    end if;

    if p_red_card_red_units < 10 then
      op_err_num := '-100';
      op_err_msg := '0 Units can not be alloted.Please Contact IT Support';
      raise less_than_ten_units;
    end if;

    select count(extra.objid) -- RUN THIS QUERY IF YOU HAVE THE PROMO CODE
    into   p_case_exists
    from   sa.table_x_case_extra_info extra,
           table_case case1
    where  extra.x_promo_code = ip_promo_code
    and    extra.x_extra_info2x_case = case1.objid
    and    upper(case1.title) = 'PROMOTION FAILURE'
    and    case1.x_esn = ip_esn;

    select count(*) -- NEW VALIDATION BECAUSE I WASN'T HITTING THE ONE ABOVE (table_x_case_extra_info)
    into   p_case_exists
    from   table_case c,
           TABLE_X_CASE_DETAIL d
    where  c.objid = d.detail2case
    and    c.s_title like 'PROMOTION FAILURE'
    and    c.x_esn = ip_esn
    and    (d.x_name = 'AIRTIME_PIN_NUMBER'
    and    d.x_value = p_red_card);

    if p_case_exists > 0 then
      op_err_num := '-1083';
      op_err_msg := 'You already have a case for this redemption card';
      raise redemption_case_exists;
    end if;

    op_err_num := '-1578';
    op_err_msg := 'Error in input parameters (sourcesystem,promo_code,zipcode)';
    select x_zipcode,objid,x_min
    into   p_zipcode,p_esn_sp_objid,p_min
    from   table_site_part
    where  x_service_id = iP_ESN
    and    part_status = 'Active'
    order by install_date desc;

    -- COLLECT THE DEALER INFO
    op_err_num := '-101';
    op_err_msg := 'Error obtaining dealer info';
    select s.objid,s.site_id,s.name
           into p_dealer_objid, p_dealer_id, p_dealer_name  -- p_dealer_id, p_dealer_name are not needed
    from   table_site s,
           table_inv_locatn il,
           table_inv_bin ib,
           table_part_inst pi
    where  1=1
    and    pi.part_serial_no = ip_esn
    and    pi.x_domain = 'PHONES'
    and    s.objid = il.inv_locatn2site
    and    il.objid = ib.inv_bin2inv_locatn
    and    ib.objid = pi.part_inst2inv_bin;

    -- COLLECT THE CARRIER INFO (PENDING NATALIO'S RESPONSE TO WHICH TO USE FOR THIS PROCESS)
    op_err_num := '-102';
    op_err_msg := 'Error obtaining carrier info';
    select car.objid -- THIS IS HOW TAS OBTAINS THE CARRIER INFO
    into   p_carrier_objid
    from   table_x_carrier car,
           table_part_inst pi3
    where  pi3.part_inst2carrier_mkt = car.objid
    and    pi3.part_serial_no = p_min;

    sa.validate_red_card_pkg.main(strredcard => p_red_card,
                                  strsmpnumber => p_smp,
                                  strsourcesys => p_org_id,
                                  stresn => ip_esn,
                                  po_refcursor => po_refcursor);

    loop
      fetch po_refcursor into p_card_status,p_card_units,p_card_days,
                              p_card_brand,op_err_num,op_err_msg,var_7,
                              p_card_desc,p_card_partnum,p_card_type,p_part_type,
                              p_web_card_desc,p_sp_web_card_desc,p_ild_type;
      exit when PO_REFCURSOR %notfound;
    end loop;
    close po_refcursor;

    -- CARD HAS BEEN REDEEMED
    if op_err_num in ('402','41') then
      validate_promo_code(p_esn => ip_esn,
                          p_red_code01 => p_red_card,
                          p_red_code02 => null,
                          p_red_code03 => null,
                          p_red_code04 => null,
                          p_red_code05 => null,
                          p_red_code06 => null,
                          p_red_code07 => null,
                          p_red_code08 => null,
                          p_red_code09 => null,
                          p_red_code10 => null,
                          p_technology => p_technology,
                          p_transaction_amount => 0, -- IS HARDCODED TO 0 IN WEBCSR
                          p_source_system => p_sourcesystem, -- THIS VALUE SHOULD BE ONE OF THESE (ALL,CLARIFY,IVR,WEB,WEBCSR)
                          p_promo_code => ip_promo_code,
                          p_transaction_type => 'Redemption', -- WEBCSR HARDCODED REDEMPTION --REQUIRED VALUE CHOOSE FROM - 'REDEMPTION','ACTIVATION','REACTIVATION','PURCHASE'
                          p_zipcode => p_zipcode, -- NOT USED IN PROCEDURE (Passing it anyway)
                          p_language => p_language,
                          p_fail_flag => 1, -- IS HARDCODED TO 1 IN WEBCSR
                          p_discount_amount => p_discount_amount, -- OUT PARAM
                          p_promo_units => p_promo_units, -- OUT PARAM
                          p_access_days => p_access_days, -- OUT PARAM
                          p_status => op_err_num, -- OUT PARAM
                          p_msg => op_err_msg); -- OUT PARAM

      if op_err_num != 0 then
        raise invalid_promo_code; -- STOP THE PROCEDURE
      end if;
    end if;

      -- RESULT FROM VALIDATE PROMO CODE
    dbms_output.put_line('=========== VALIDATE_PROMO_CODE RESULT ======================================');
    dbms_output.put_line('p_sourcesystem = ' || p_sourcesystem);
    dbms_output.put_line('p_sourcesystem = ' || p_sourcesystem);
    dbms_output.put_line('p_discount_amount = ' || p_discount_amount);
    dbms_output.put_line('p_promo_units = (webcsr returns) ' || p_promo_units);
    dbms_output.put_line('p_access_days = (webcsr returns) ' || p_access_days);
    dbms_output.put_line('op_err_num = ' || op_err_num);
    dbms_output.put_line('p_err_msg = ' || op_err_msg);

    -- INSERT PROMOCODE HIST
    ins_hist(ip_promo_code,'Redemption',p_sourcesystem,p_zipcode,ip_esn,p_promo_units,p_access_days,op_err_num);
    -- commit;

  --  -- IT'S CREATING AN ENTRY  HERE W/THE ERROR_STRING 'THIS CARD HAS ALREADY BEEN REDEEMED'
  --  select * from sa.table_x_cbo_error where x_esn_imei like '100000000013346193'

    -- UPDATE THE WARRANTY END DATE
    upd_pi_warr_end_date(ip_esn => ip_esn,
                         ip_access_days => p_access_days);

    -- PROCESS THE UNITS + DAYS, INSERTS NEW ROWS TO PENDING REDEMPTION TABLE
    process_units (ip_units_balance => p_promo_units,
                   ip_promo_objid => p_promo_objid,
                   ip_esn_sp_objid => p_esn_sp_objid,
                   ip_call_trans_objid => p_trans_objid);

    process_days (ip_days_balance => p_access_days,
                  ip_promo_objid => p_promo_objid,
                  ip_esn_sp_objid => p_esn_sp_objid,
                  ip_call_trans_objid => p_trans_objid);

    -- CREATE and CLOSE THE CASE
    select s_first_name,s_last_name
    into p_first_name,p_last_name
    from table_contact where objid = p_contact_objid;

    p_case_id_number := adfcrm_case.create_case(p_case_type => p_case_type,
                                                p_case_title => p_case_title,
                                                p_case_status => p_case_status,
                                                p_case_priority => p_case_priority,
                                                p_case_source => p_case_source,
                                                p_case_poc => p_case_poc,
                                                p_case_issue => p_case_issue,
                                                p_contact_objid => p_contact_objid,
                                                p_first_name => p_first_name,
                                                p_last_name => p_last_name,
                                                p_user_objid => ip_user_objid,
                                                p_esn => ip_esn,
                                                p_case_part_req => p_case_part_req,
                                                p_case_notes => p_case_notes);

    if p_case_id_number is not null then

      select objid
      into   p_case_objid
      from   table_case
      where  id_number = p_case_id_number;

      p_case_detail := 'RATE_PLAN||||AIRTIME_PIN_NUMBER||'||p_red_card||
                       '||AIRTIME_UNITS||'||p_promo_units||
                       '||CHANNEL||'||p_sourcesystem||
                       '||PROMO_CODE||'||ip_promo_code||
                       '||PROMO_TYPE||'||p_x_promo_type;

      clarify_case_pkg.update_case_dtl(p_case_objid  => p_case_objid,
                                       p_user_objid  => ip_user_objid,
                                       p_case_detail => p_case_detail,
                                       p_error_no    => op_err_num,
                                       p_error_str   => op_err_msg);

      dbms_output.put_line('=========== CREATE CASE RESULT ======================================');
      dbms_output.put_line('p_case_id_number = ' || p_case_id_number);

      dbms_output.put_line('=========== CREATE DETAIL RESULT ======================================');

      v_return := adfcrm_case.close_case(p_case_objid => p_case_objid,
                                         p_user_objid => ip_user_objid,
                                         p_resolution => p_resolution,
                                         p_status => p_status,
                                         p_notes => p_notes);

      dbms_output.put_line('=========== CLOSE CASE RESULT ======================================');
      dbms_output.put_line('v_Return = ' || v_return);

    end if;

    -- SET CALL TRANS
    set_call_trans(ip_min => p_min,
                   ip_site_part_objid => p_esn_sp_objid,
                   ip_carrier_objid => p_carrier_objid,
                   ip_dealer_objid => p_dealer_objid,
                   ip_user_objid => ip_user_objid,
                   ip_esn => ip_esn,
                   ip_sourcesystem => p_sourcesystem,
                   ip_units => null,
                   ip_reason => p_call_trans_reason,
                   ip_sub_sourcesystem => p_org_id);



    select count(*)
    into   p_wfp_flag
    from   table_x_parameters
    where  x_param_name = 'ADFCRM_VALIDATE_PROMO_AS_WFP'
    and    x_param_value = 'Y';

    if p_wfp_flag > 0 then
      dbms_output.put_line('=========== GENERATE WORKFORCE PIN ======================================');

      -- APPLY THE MINUTES USING A WORKFORCE PIN, IF THE FLAG IS OFF, PENDING
      -- APPROVED BONUS UNITS WILL BE APPLIED ON THE NEXT REDEMPTION
      --added for CR54687
  workforce_pin(ip_esn => ip_esn, ip_pin_part_num => 'TFSREPLA0001', ip_login_name => p_login_name, ip_reason => p_call_trans_reason, ip_notes => p_call_trans_reason, ip_contact_objid => ip_contact_objid,ip_orgid => null,ip_service_plan_objid => null ,ip_service_type => null , op_pin => p_wfp_pin, op_case_id => p_wfp_case_id_number, op_error_num => op_err_num, op_error_msg => op_err_msg);
     /* workforce_pin(ip_esn => ip_esn,
                    ip_pin_part_num => 'TFSREPLA0001',
                    ip_login_name => p_login_name,
                    ip_reason => p_call_trans_reason,
                    ip_notes => p_call_trans_reason,
                    ip_contact_objid => ip_contact_objid,
                    op_pin => p_wfp_pin,
                    op_case_id => p_wfp_case_id_number,
                    op_error_num => op_err_num,
                    op_error_msg => op_err_msg);
            */
    end if;


    op_err_num := 0;
    op_err_msg := 'Success';

    -- PASS TO PENDUNITSTOCALLERESN METHOD
    display_vars;


  exception
    when others then
      display_vars;
  end validate_promo;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- OVERLOADED NEW VERSION - OP_PIN_OUT (NEW OUT PARAM) REMOVE ORIGINAL
--------------------------------------------------------------------------------
  procedure validate_promo(ip_red_card varchar2,
                           ip_promo_code varchar2,
                           ip_esn varchar2,
                           ip_cust_id varchar2,
                           ip_contact_objid varchar2,
                           ip_user_objid varchar2,
                           ip_red_method varchar2,  -- THIS IS REQUIRED VALUES ARE 'IVR','WEB',' OTA HANDSET'
                           op_pin out varchar2, -- NEW SIGNATURE (PIN FROM WORKFORCE)
                           op_err_msg out varchar2,
                           op_err_num out varchar2)
  as

    p_red_card varchar2(30);
    p_smp varchar2(30);
    p_org_id table_bus_org.org_id%type;
    po_refcursor sys_refcursor;

    p_card_status varchar2(40);
    p_card_units varchar2(40);
    p_card_days varchar2(40);
    p_card_brand varchar2(40);
    var_7 varchar2(300);

    p_card_desc varchar2(300);
    p_card_partnum varchar2(30);
    p_card_type varchar2(300);
    p_part_type varchar2(300);
    p_web_card_desc varchar2(300);
    p_sp_web_card_desc varchar2(300);
    p_ild_type varchar2(300);
    p_esn_sp_objid number;
    p_login_name table_user.login_name%type;

    p_case_exists number;
    p_redemption_date varchar2(30);
    p_date_diff number;
    p_sourcesystem varchar2(30);
    p_trans_objid number;

    p_zipcode varchar2(30);
    p_technology varchar2(30) := null;
    p_language varchar2(30)  := 'ENGLISH';  -- THIS IS REQUIRED
    p_discount_amount varchar2(30) := null;
    p_promo_units number := null;
    p_access_days number := null;
    p_contact_objid number;
    p_cust_id varchar2(30);
    p_red_card_access_days number;
    p_red_card_red_units number;
    p_call_trans_reason varchar2(30) := 'Promo:PromoFailure';

    p_promo_objid number;
    p_x_units number;
    p_x_access_days number;
    p_x_promo_type varchar2(30);
    p_x_english_short_text clob;

    esn_invalid exception;
    outside_of_grace_period exception;
    redemption_case_exists exception;
    missing_parameters exception;
    redemption_card_unused exception;
    no_contact_found exception;
    less_than_ten_units exception;
    invalid_promo_code exception;

    -- NEW CASE VARIABLES
    p_case_type table_case.x_case_type%type := 'WEB/IVR Failure'; --  THIS IS TAKEN FROM file: caseDefMapping_en.properties -- caseType.27 (typeId = 27)
    p_case_title table_case.title%type := 'Promotion Failure'; --  THIS IS TAKEN FROM file: caseDefMapping_en.properties -- caseType.27 (typeId = 27)
    p_case_status varchar2(30) := 'Pending Credit'; -- UNABLE TO FIND MY ANSWER IN THE JAVA, CHOOSING PENDING CREDIT FOR NOW
    p_case_priority varchar2(30) := 'High'; -- UNABLE TO FIND MY ANSWER IN THE JAVA, CHOOSING HIGH FOR NOW
    p_case_source varchar2(30) := 'Customer'; -- UNABLE TO FIND MY ANSWER IN THE JAVA, CHOOSING HIGH FOR NOW
    p_case_poc varchar2(200) := 'TAS';
    p_case_issue varchar2(30) := p_case_title;
    p_case_part_req varchar2(200) := null;
    p_first_name varchar2(200);
    p_last_name varchar2(200);
    p_case_notes varchar2(200) := p_case_type||'-'||p_case_title;
    v_Return VARCHAR2(200);

    -- UPDATE CASE DETAILS
    p_case_id_number varchar2(30);
    p_case_detail varchar2(4000);

    -- CLOSE CASE VARIABLES
    p_case_objid number;
    p_resolution varchar2(30) := null; -- NOT ABLE TO FIND IT IN THE JAVA, LEFT NULL
    p_status varchar2(30) := 'Closed';
    p_notes varchar2(200);

    -- SET CALL TRANS VARS
    p_min varchar2(30);
    p_mod_level_objid number;
    p_dealer_objid number;
    p_dealer_id varchar2(80);
    p_dealer_name varchar2(80);
    p_carrier_objid number;

    -- WORKFORCE PIN CASE ID
    p_wfp_case_id_number varchar2(30);
    p_wfp_flag number := 0;

    procedure ins_hist(ip_promo_code varchar2,ip_transact_type varchar2,ip_source_system varchar2,ip_zip_code varchar2,ip_esn varchar2,ip_promo_units varchar2,ip_access_days varchar2,ip_error_num varchar2)
    as
    begin
      dbms_output.put_line('=========== INSERT PROMOCODE HIST ======================================');
      dbms_output.put_line('ins_hist(ip_promo_code ='||ip_promo_code||
                                     ',ip_transact_type ='||ip_transact_type||
                                     ',ip_source_system ='||ip_source_system||
                                     ',ip_zip_code ='||ip_zip_code||
                                     ',ip_esn ='||ip_esn||
                                     ',ip_promo_units ='||ip_promo_units||
                                     ',ip_access_days ='||ip_access_days||
                                     ',ip_error_num ='||ip_error_num||')');
      insert into x_promocode_hist
        (promo_code,transact_type,source_system,zip_code,esn,promo_units,access_days,error_num,time_stamp)
      values
        (ip_promo_code,ip_transact_type,ip_source_system,ip_zip_code,ip_esn,ip_promo_units,ip_access_days,ip_error_num,sysdate);

    end ins_hist;

    procedure ins_pending_red(ip_pend_red2x_promotion number, -- PROMO OBJID
                              ip_pend_red2site_part number, -- ESN SITE PART OBJID
                              ip_pend_type varchar2, -- HARDCODED AS IN WEBCSR
                              ip_granted_from2x_call_trans number) -- CALL TRANS OBJID
    as
    begin

      dbms_output.put_line('ins_pending_red (ip_pend_red2x_promotion='||ip_pend_red2x_promotion||
                                            ',ip_pend_red2site_part='||ip_pend_red2site_part||
                                            ',ip_pend_type='||ip_pend_type||
                                            ',ip_granted_from2x_call_trans='||ip_granted_from2x_call_trans);

      insert into sa.table_x_pending_redemption
        (objid,pend_red2x_promotion,x_pend_red2site_part,x_pend_type,x_granted_from2x_call_trans)
      values
        (sa.seq('x_pending_redemption'),ip_pend_red2x_promotion,ip_pend_red2site_part,ip_pend_type,ip_granted_from2x_call_trans);

    end ins_pending_red;

    procedure process_units (ip_units_balance number,
                             ip_promo_objid number,
                             ip_esn_sp_objid number,
                             ip_call_trans_objid number)
    as
      number_of_cards number;
      units_balance number := ip_units_balance;
    begin
      dbms_output.put_line('=========== COMPENSATION UNITS RESULT ======================================');
      dbms_output.put_line('Number of units to give = '||units_balance);

      if ip_units_balance != 0 then
        for i in (select  max(objid), x_units units
                  from table_x_promotion
                  where x_promo_type = 'Customer Service'
                  and sysdate between x_start_date and x_end_date
                  and x_units between 9 and units_balance
                  group by x_units
                  order by x_units desc)

        loop
          if (units_balance >= i.units) then
           number_of_cards := floor(units_balance/i.units);
           units_balance := mod(units_balance, i.units);

           ins_pending_red(ip_pend_red2x_promotion => ip_promo_objid,
                           ip_pend_red2site_part => ip_esn_sp_objid,
                           ip_pend_type => 'REPL',
                           ip_granted_from2x_call_trans => ip_call_trans_objid);
          else
            continue;
          end if;
          dbms_output.put_line( i.units ||'- Number of cards = '|| number_of_cards);
        end loop;
      end if;

    end process_units;

    procedure process_days (ip_days_balance number,
                            ip_promo_objid number,
                            ip_esn_sp_objid number,
                            ip_call_trans_objid number)
    as
      number_of_cards number;
      days_balance number := ip_days_balance;
    begin
      dbms_output.put_line('=========== COMPENSATION DAYS RESULT ======================================');
      dbms_output.put_line('Number of days to give = '||days_balance);

      if ip_days_balance != 0 then
        for i in (select  max(objid), x_access_days days
                  from table_x_promotion
                  where x_promo_type = 'Customer Service'
                  and sysdate between x_start_date and x_end_date
                  and x_units between 9 and days_balance
                  group by x_access_days
                  order by x_access_days desc)

        loop
          if (days_balance >= i.days) then
           number_of_cards := floor(days_balance/i.days);
           days_balance := mod(days_balance, i.days);

           ins_pending_red(ip_pend_red2x_promotion => ip_promo_objid,
                           ip_pend_red2site_part => ip_esn_sp_objid,
                           ip_pend_type => 'REPL',
                           ip_granted_from2x_call_trans => ip_call_trans_objid);
          else
            continue;
          end if;
          dbms_output.put_line( i.days ||'- Number of (days) cards = '|| number_of_cards);
        end loop;

      end if;

    end process_days;

    procedure upd_pi_warr_end_date(ip_esn varchar2, ip_access_days number)
    as
    begin
      dbms_output.put_line('=========== UPDATING WARRANTY END DATE ======================================');
      dbms_output.put_line('update table_part_inst (ip_esn ='||ip_esn||',ip_access_days = '||ip_access_days);
      update table_part_inst
      set    warr_end_date = warr_end_date+ip_access_days
      where part_serial_no = ip_esn;
    end upd_pi_warr_end_date;

    procedure set_call_trans(ip_min varchar2,
                             ip_site_part_objid varchar2,
                             ip_carrier_objid varchar2,
                             ip_dealer_objid varchar2,
                             ip_user_objid varchar2,
                             ip_esn varchar2,
                             ip_sourcesystem varchar2,
                             ip_units varchar2,
                             ip_reason varchar2,
                             ip_sub_sourcesystem varchar2)
    as
    begin
      dbms_output.put_line('=========== CREATE CALL TRANS ======================================');

      dbms_output.put_line('insert table_x_call_trans (ip_site_part_objid='||ip_site_part_objid||
                                                     ',ip_carrier_objid='||ip_carrier_objid||
                                                     ',ip_dealer_objid='||ip_dealer_objid||
                                                     ',ip_user_objid='||ip_user_objid||
                                                     ',ip_min='||ip_min||
                                                     ',ip_esn='||ip_esn||
                                                     ',ip_sourcesystem='||ip_sourcesystem||
                                                     ',ip_units='||ip_units||
                                                     ',ip_reason='||ip_reason||
                                                     ',ip_sub_sourcesystem='||ip_sub_sourcesystem||')');

      insert into table_x_call_trans
        (objid,
         call_trans2site_part,
         x_action_type,
         x_call_trans2carrier,
         x_call_trans2dealer,
         x_call_trans2user,
         x_line_status,
         x_min,
         x_service_id,
         x_sourcesystem,
         x_transact_date,
         x_total_units,
         x_action_text,
         x_reason,
         x_result,
         x_sub_sourcesystem,
         x_iccid)
      values
        (sa.seq('x_call_trans'),
         ip_site_part_objid, -- call_trans2site_part
         '8', -- x_action_type
         ip_carrier_objid, -- x_call_trans2carrier
         ip_dealer_objid, -- x_call_trans2dealer
         ip_user_objid, --x_call_trans2user
         '', -- x_line_status
         ip_min, --x_min
         ip_esn, --x_service_id
         ip_sourcesystem, -- x_sourcesystem
         sysdate, -- x_transact_date
         ip_units, -- x_total_units
         'CUST SERVICE', -- x_action_text
         ip_reason, -- x_reason
         'Completed', -- x_result
         ip_sub_sourcesystem, -- x_sub_sourcesystem
         '' -- x_iccid
         );

    end set_call_trans;

    procedure display_vars
    as
    begin
      dbms_output.put_line('=========== DISPLAY VARS ======================================');
      dbms_output.put_line('ip_esn = ' || ip_esn);
      dbms_output.put_line('p_min = ' || p_min);
      dbms_output.put_line('p_mod_level_objid = ' || p_mod_level_objid);
      dbms_output.put_line('p_esn_sp_objid = ' || p_esn_sp_objid);
      dbms_output.put_line('p_carrier_objid = ' || p_carrier_objid);
      dbms_output.put_line('p_trans_objid = ' || p_trans_objid);
      dbms_output.put_line('p_red_card = ' || p_red_card);
      dbms_output.put_line('p_contact_objid = ' || p_contact_objid);
      dbms_output.put_line('p_promo_objid = ' || p_promo_objid);
      dbms_output.put_line('p_x_units =='||p_x_units);
      dbms_output.put_line('p_x_access_days =='||p_x_access_days);
      dbms_output.put_line('p_x_promo_type =='||p_x_promo_type);
      dbms_output.put_line('p_x_english_short_text =='||p_x_english_short_text);
      dbms_output.put_line('p_promo_units = ' || p_promo_units||'(out param from validate_promo_code)');
      dbms_output.put_line('p_access_days = ' || p_access_days||'(out param from validate_promo_code)');
      dbms_output.put_line('ip_promo_code = ' || ip_promo_code);
      dbms_output.put_line('p_sourcesystem = ' || p_sourcesystem);
      dbms_output.put_line('p_org_id = ' || p_org_id);
      dbms_output.put_line('p_red_card_access_days = ' || p_red_card_access_days);
      dbms_output.put_line('p_red_card_red_units = ' || p_red_card_red_units);
      dbms_output.put_line('p_call_trans_reason = ' || p_call_trans_reason);
      dbms_output.put_line('p_case_type = ' || p_case_type);
      dbms_output.put_line('p_case_title = ' || p_case_title);
      dbms_output.put_line('p_case_status = ' || p_case_status);
      dbms_output.put_line('p_case_priority = ' || p_case_priority);
      dbms_output.put_line('p_case_source = ' || p_case_source);
      dbms_output.put_line('p_case_poc = ' || p_case_poc);
      dbms_output.put_line('p_case_issue = ' || p_case_issue);
      dbms_output.put_line('p_case_notes = ' || p_case_notes);
      dbms_output.put_line('p_first_name = ' || p_first_name);
      dbms_output.put_line('p_last_name = ' || p_last_name);
      dbms_output.put_line('p_case_objid = ' || p_case_objid);
      dbms_output.put_line('ip_user_objid = ' || ip_user_objid);
      dbms_output.put_line('p_case_id_number = ' || p_case_id_number);
      dbms_output.put_line('p_wfp_case_id_number = ' || p_wfp_case_id_number);

      dbms_output.put_line('op_pin = ' || op_pin);
      dbms_output.put_line('op_err_num = ' || op_err_num);
      dbms_output.put_line('op_err_msg = ' || op_err_msg);
    end display_vars;
  begin

    -- COLLECT REDCARD,PROMO, and ESN INFO
    p_cust_id := ip_cust_id;
    p_contact_objid := ip_contact_objid;


    op_err_num := '-94';
    op_err_msg := 'Agent info not found';
    select s_login_name
    into p_login_name
    from table_user
    where objid  = ip_user_objid;

    op_err_num := '-95';
    op_err_msg := 'Customer info not found';
    if ip_cust_id is not null then
      select objid
      into   p_contact_objid
      from table_contact
      where x_cust_id = ip_cust_id;
    else
      select x_cust_id
      into   p_cust_id
      from table_contact
      where objid = ip_contact_objid;
    end if;

    op_err_num := '-96';
    op_err_msg := 'Promotion Info not found';
    select objid,x_units,x_access_days,x_promo_type,x_english_short_text
    into   p_promo_objid,p_x_units,p_x_access_days,p_x_promo_type,p_x_english_short_text
    from   sa.table_x_promotion promo
    where  x_promo_code = ip_promo_code
    and    x_start_date < sysdate and x_end_date > sysdate;

    op_err_num := '-97';
    op_err_msg := 'Contact not found';
    if p_cust_id is not null and
       p_contact_objid is null then
      select objid
      into   p_contact_objid
      from   sa.table_contact
      where  x_cust_id = p_cust_id;
    elsif p_cust_id is null and
          p_contact_objid is null then
      op_err_num := '-97';
      op_err_msg := 'Contact not found';
      raise no_contact_found;
    end if;

    op_err_num := '-98';
    op_err_msg := 'Redemption card entered does not exist';
    select  x_red_code,x_smp
    into    p_red_card,p_smp
    from   (select x_red_code,part_serial_no x_smp
            from table_part_inst where x_red_code = ip_red_card union
            select x_red_code,x_smp
            from table_x_red_card where x_red_code = ip_red_card);

    if ip_red_method is null or ip_promo_code is null then
      op_err_num := '-1578';
      op_err_msg := 'Error in input parameters (ip_red_method,promo_code,zipcode)';
      raise missing_parameters;
    end if;

    -- IF ESN LENGTH IS NOT 11,15,18 ESN IS INVALID - 'ESN Not Valid' -1578
    if length(ip_esn) not in ('11','15','18') then
      op_err_num := '-1578';
      op_err_msg := 'ESN Not Valid';
      raise esn_invalid;
    end if;

    op_err_num := '-1579'; --NEW ERR NUMBER
    op_err_msg := 'ESN Not Found';
    select decode(pn.x_technology,'ANALOG','ANALOG','DIGITAL') tech,n_part_inst2part_mod
    into p_technology,p_mod_level_objid
    from table_part_inst pi, table_mod_level ml, table_part_num pn
    where part_serial_no = iP_ESN
    and x_domain = 'PHONES'
    and ml.objid = pi.n_part_inst2part_mod
    and pn.objid = ml.part_info2part_num;

    op_err_num := '-1081';
    op_err_msg := 'No Redemption Records Found';
    select to_char(red.x_red_date,'mm/dd/yyyy') x_red_date,
           floor(sysdate-red.x_red_date) date_diff,
           x_sourcesystem,
           trans.objid trans_objid,
           x_sub_sourcesystem org_id,
           x_access_days,x_red_units
    into   p_redemption_date,p_date_diff,p_sourcesystem,p_trans_objid, p_org_id,p_red_card_access_days,p_red_card_red_units
    from   sa.table_x_call_trans trans,
           sa.table_x_red_card red
    where  trans.x_service_id = ip_esn
    and    red.x_red_code = p_red_card
    and    trans.x_action_text = 'REDEMPTION'
    and    red.red_card2call_trans = trans.objid;

    if p_date_diff >5 then
      op_err_num := '-1082';
      op_err_msg := 'Redemption was attempted more than 5 days ago we cannot give any promo units';
      raise outside_of_grace_period;
    end if;

    if p_red_card_red_units < 10 then
      op_err_num := '-100';
      op_err_msg := '0 Units can not be alloted.Please Contact IT Support';
      raise less_than_ten_units;
    end if;

    select count(extra.objid) -- RUN THIS QUERY IF YOU HAVE THE PROMO CODE
    into   p_case_exists
    from   sa.table_x_case_extra_info extra,
           table_case case1
    where  extra.x_promo_code = ip_promo_code
    and    extra.x_extra_info2x_case = case1.objid
    and    upper(case1.title) = 'PROMOTION FAILURE'
    and    case1.x_esn = ip_esn;

    select count(*) -- NEW VALIDATION BECAUSE I WASN'T HITTING THE ONE ABOVE (table_x_case_extra_info)
    into   p_case_exists
    from   table_case c,
           TABLE_X_CASE_DETAIL d
    where  c.objid = d.detail2case
    and    c.s_title like 'PROMOTION FAILURE'
    and    c.x_esn = ip_esn
    and    (d.x_name = 'AIRTIME_PIN_NUMBER'
    and    d.x_value = p_red_card);

    if p_case_exists > 0 then
      op_err_num := '-1083';
      op_err_msg := 'You already have a case for this redemption card';
      raise redemption_case_exists;
    end if;

    op_err_num := '-1578';
    op_err_msg := 'Error in input parameters (sourcesystem,promo_code,zipcode)';
    select x_zipcode,objid,x_min
    into   p_zipcode,p_esn_sp_objid,p_min
    from   table_site_part
    where  x_service_id = iP_ESN
    and    part_status = 'Active'
    order by install_date desc;

    -- COLLECT THE DEALER INFO
    op_err_num := '-101';
    op_err_msg := 'Error obtaining dealer info';
    select s.objid,s.site_id,s.name
           into p_dealer_objid, p_dealer_id, p_dealer_name  -- p_dealer_id, p_dealer_name are not needed
    from   table_site s,
           table_inv_locatn il,
           table_inv_bin ib,
           table_part_inst pi
    where  1=1
    and    pi.part_serial_no = ip_esn
    and    pi.x_domain = 'PHONES'
    and    s.objid = il.inv_locatn2site
    and    il.objid = ib.inv_bin2inv_locatn
    and    ib.objid = pi.part_inst2inv_bin;

    -- COLLECT THE CARRIER INFO (PENDING NATALIO'S RESPONSE TO WHICH TO USE FOR THIS PROCESS)
    op_err_num := '-102';
    op_err_msg := 'Error obtaining carrier info';
    select car.objid -- THIS IS HOW TAS OBTAINS THE CARRIER INFO
    into   p_carrier_objid
    from   table_x_carrier car,
           table_part_inst pi3
    where  pi3.part_inst2carrier_mkt = car.objid
    and    pi3.part_serial_no = p_min;

    sa.validate_red_card_pkg.main(strredcard => p_red_card,
                                  strsmpnumber => p_smp,
                                  strsourcesys => p_org_id,
                                  stresn => ip_esn,
                                  po_refcursor => po_refcursor);

    loop
      fetch po_refcursor into p_card_status,p_card_units,p_card_days,
                              p_card_brand,op_err_num,op_err_msg,var_7,
                              p_card_desc,p_card_partnum,p_card_type,p_part_type,
                              p_web_card_desc,p_sp_web_card_desc,p_ild_type;
      exit when PO_REFCURSOR %notfound;
    end loop;
    close po_refcursor;

    -- CARD HAS BEEN REDEEMED
    if op_err_num in ('402','41') then
      validate_promo_code(p_esn => ip_esn,
                          p_red_code01 => p_red_card,
                          p_red_code02 => null,
                          p_red_code03 => null,
                          p_red_code04 => null,
                          p_red_code05 => null,
                          p_red_code06 => null,
                          p_red_code07 => null,
                          p_red_code08 => null,
                          p_red_code09 => null,
                          p_red_code10 => null,
                          p_technology => p_technology,
                          p_transaction_amount => 0, -- IS HARDCODED TO 0 IN WEBCSR
                          p_source_system => p_sourcesystem, -- THIS VALUE SHOULD BE ONE OF THESE (ALL,CLARIFY,IVR,WEB,WEBCSR)
                          p_promo_code => ip_promo_code,
                          p_transaction_type => 'Redemption', -- WEBCSR HARDCODED REDEMPTION --REQUIRED VALUE CHOOSE FROM - 'REDEMPTION','ACTIVATION','REACTIVATION','PURCHASE'
                          p_zipcode => p_zipcode, -- NOT USED IN PROCEDURE (Passing it anyway)
                          p_language => p_language,
                          p_fail_flag => 1, -- IS HARDCODED TO 1 IN WEBCSR
                          p_discount_amount => p_discount_amount, -- OUT PARAM
                          p_promo_units => p_promo_units, -- OUT PARAM
                          p_access_days => p_access_days, -- OUT PARAM
                          p_status => op_err_num, -- OUT PARAM
                          p_msg => op_err_msg); -- OUT PARAM

      if op_err_num != 0 then
        raise invalid_promo_code; -- STOP THE PROCEDURE
      end if;
    end if;

      -- RESULT FROM VALIDATE PROMO CODE
    dbms_output.put_line('=========== VALIDATE_PROMO_CODE RESULT ======================================');
    dbms_output.put_line('p_sourcesystem = ' || p_sourcesystem);
    dbms_output.put_line('p_sourcesystem = ' || p_sourcesystem);
    dbms_output.put_line('p_discount_amount = ' || p_discount_amount);
    dbms_output.put_line('p_promo_units = (webcsr returns) ' || p_promo_units);
    dbms_output.put_line('p_access_days = (webcsr returns) ' || p_access_days);
    dbms_output.put_line('op_err_num = ' || op_err_num);
    dbms_output.put_line('p_err_msg = ' || op_err_msg);

    -- INSERT PROMOCODE HIST
    ins_hist(ip_promo_code,'Redemption',p_sourcesystem,p_zipcode,ip_esn,p_promo_units,p_access_days,op_err_num);
    -- commit;

  --  -- IT'S CREATING AN ENTRY  HERE W/THE ERROR_STRING 'THIS CARD HAS ALREADY BEEN REDEEMED'
  --  select * from sa.table_x_cbo_error where x_esn_imei like '100000000013346193'

    -- UPDATE THE WARRANTY END DATE
    upd_pi_warr_end_date(ip_esn => ip_esn,
                         ip_access_days => p_access_days);

    -- PROCESS THE UNITS + DAYS, INSERTS NEW ROWS TO PENDING REDEMPTION TABLE
    process_units (ip_units_balance => p_promo_units,
                   ip_promo_objid => p_promo_objid,
                   ip_esn_sp_objid => p_esn_sp_objid,
                   ip_call_trans_objid => p_trans_objid);

    process_days (ip_days_balance => p_access_days,
                  ip_promo_objid => p_promo_objid,
                  ip_esn_sp_objid => p_esn_sp_objid,
                  ip_call_trans_objid => p_trans_objid);

    -- CREATE and CLOSE THE CASE
    select s_first_name,s_last_name
    into p_first_name,p_last_name
    from table_contact where objid = p_contact_objid;

    p_case_id_number := adfcrm_case.create_case(p_case_type => p_case_type,
                                                p_case_title => p_case_title,
                                                p_case_status => p_case_status,
                                                p_case_priority => p_case_priority,
                                                p_case_source => p_case_source,
                                                p_case_poc => p_case_poc,
                                                p_case_issue => p_case_issue,
                                                p_contact_objid => p_contact_objid,
                                                p_first_name => p_first_name,
                                                p_last_name => p_last_name,
                                                p_user_objid => ip_user_objid,
                                                p_esn => ip_esn,
                                                p_case_part_req => p_case_part_req,
                                                p_case_notes => p_case_notes);

    if p_case_id_number is not null then

      select objid
      into   p_case_objid
      from   table_case
      where  id_number = p_case_id_number;

      p_case_detail := 'RATE_PLAN||||AIRTIME_PIN_NUMBER||'||p_red_card||
                       '||AIRTIME_UNITS||'||p_promo_units||
                       '||CHANNEL||'||p_sourcesystem||
                       '||PROMO_CODE||'||ip_promo_code||
                       '||PROMO_TYPE||'||p_x_promo_type;

      clarify_case_pkg.update_case_dtl(p_case_objid  => p_case_objid,
                                       p_user_objid  => ip_user_objid,
                                       p_case_detail => p_case_detail,
                                       p_error_no    => op_err_num,
                                       p_error_str   => op_err_msg);

      dbms_output.put_line('=========== CREATE CASE RESULT ======================================');
      dbms_output.put_line('p_case_id_number = ' || p_case_id_number);

      dbms_output.put_line('=========== CREATE DETAIL RESULT ======================================');

      v_return := adfcrm_case.close_case(p_case_objid => p_case_objid,
                                         p_user_objid => ip_user_objid,
                                         p_resolution => p_resolution,
                                         p_status => p_status,
                                         p_notes => p_notes);

      dbms_output.put_line('=========== CLOSE CASE RESULT ======================================');
      dbms_output.put_line('v_Return = ' || v_return);

    end if;

    -- SET CALL TRANS
    set_call_trans(ip_min => p_min,
                   ip_site_part_objid => p_esn_sp_objid,
                   ip_carrier_objid => p_carrier_objid,
                   ip_dealer_objid => p_dealer_objid,
                   ip_user_objid => ip_user_objid,
                   ip_esn => ip_esn,
                   ip_sourcesystem => p_sourcesystem,
                   ip_units => null,
                   ip_reason => p_call_trans_reason,
                   ip_sub_sourcesystem => p_org_id);



    select count(*)
    into   p_wfp_flag
    from   table_x_parameters
    where  x_param_name = 'ADFCRM_VALIDATE_PROMO_AS_WFP'
    and    x_param_value = 'Y';

    if p_wfp_flag > 0 then
      dbms_output.put_line('=========== GENERATE WORKFORCE PIN ======================================');

      -- APPLY THE MINUTES USING A WORKFORCE PIN, IF THE FLAG IS OFF, PENDING
      -- APPROVED BONUS UNITS WILL BE APPLIED ON THE NEXT REDEMPTION
      --added for cR54687
    workforce_pin(ip_esn => ip_esn, ip_pin_part_num => 'TFSREPLA0001', ip_login_name => p_login_name, ip_reason => p_call_trans_reason, ip_notes => p_call_trans_reason, ip_contact_objid => ip_contact_objid,ip_orgid => null,ip_service_plan_objid => null ,ip_service_type => null , op_pin => op_pin, op_case_id => p_wfp_case_id_number, op_error_num => op_err_num, op_error_msg => op_err_msg);

    --commented for CR54687
    /**  workforce_pin(ip_esn => ip_esn,
                    ip_pin_part_num => 'TFSREPLA0001',
                    ip_login_name => p_login_name,
                    ip_reason => p_call_trans_reason,
                    ip_notes => p_call_trans_reason,
                    ip_contact_objid => ip_contact_objid,
                    op_pin => op_pin,
                    op_case_id => p_wfp_case_id_number,
                    op_error_num => op_err_num,
                    op_error_msg => op_err_msg);
            **/
    end if;

    op_err_num := 0;
    op_err_msg := 'Success';

    -- PASS TO PENDUNITSTOCALLERESN METHOD
    display_vars;


  exception
    when others then
      display_vars;
  end validate_promo;
--------------------------------------------------------------------------------
-- END OVERLOADED VERSION OF VALIDATE PROMO
--------------------------------------------------------------------------------



  procedure cross_carrier_sim_change (ip_esn varchar2,
                           ip_new_sim varchar2,
                           ip_new_carrier_id varchar2,
                           ip_zip_code  varchar2,
                           ip_contact_objid varchar2,
                           ip_user_objid varchar2,
                           ip_source_system varchar2,
                           op_case_id out varchar2,
                           op_err_msg out varchar2,
                           op_err_num out varchar2) is

     v_case_type  varchar2(30):=  'Port In';
     v_case_title varchar2(30):=  'SIM Change Port';
     v_queue      varchar2(30):=  'TF/NT Port Pending';
     v_status     varchar2(30):=  'Pending';
     v_priority   varchar2(30):=  'Low';
     v_source     varchar2(30):=  'TAS';
     v_issue      varchar2(30):=  'SIM Change';

     -- Deact Parameters
     v_deact_reason varchar2(30):= 'PORTED NO A/I';
     v_bypass_order_type varchar2(2):= 0;
     v_same_min varchar2(10):='true';


     v_id_number  varchar2(30);
     v_case_objid varchar2(30);
     v_error_no   varchar2(30);
     v_error_str  varchar2(300);
     v_return     varchar2(100);
     v_return_msg     varchar2(300);
     v_current_carrier_id varchar2(30);
     v_curent_carrier   varchar2(30);
     v_assigned_carrier_id varchar2(30);
     v_assigned_carrier varchar2(30);
     v_activation_zip   varchar2(30);
     v_case_details     varchar2(1000);
     v_current_min      varchar2(30);
     v_pi_return        boolean;
     v_site_part_objid  varchar2(30);
     v_warranty_date    date;
     v_ct_objid           varchar2(30);

     /*Intergate Variables */
     v_status_code        number;
     v_action_item_objid  number;
     v_destination_queue  varchar2(100);
     v_application_system varchar2(100);
     v_order_type         varchar2(30):='Internal Port In';
     v_trans_method       varchar2(100);

     /*Serv Plan */
     v_serv_plan_objid    varchar2(30);

     cursor new_carrier_cur (p_carrier_id varchar2) is
     select objid,x_carrier_id,x_mkt_submkt_name
     from sa.table_x_carrier
     where x_carrier_id = p_carrier_id;

     new_carrier_rec new_carrier_cur%rowtype;

     cursor old_carrier_cur (p_esn varchar2) is
     select ca.objid,ca.x_carrier_id,ca.x_mkt_submkt_name,
            sp.x_zipcode,sp.x_min,sp.objid site_part_objid,sp.warranty_date,
            spsp.x_service_plan_id
     from sa.table_x_carrier ca,
          sa.table_part_inst pi,
          sa.table_site_part sp,
          sa.x_service_plan_site_part spsp
     where sp.x_service_id = p_esn
     and   sp.part_status = 'Active'
     and   pi.part_serial_no = sp.x_min
     and   pi.x_domain = 'LINES'
     and   ca.objid = pi.part_inst2carrier_mkt
     and   sp.objid = spsp.table_site_part_id (+);

     old_carrier_rec old_carrier_cur%rowtype;

  begin
     op_err_num := '0';
     op_err_msg := 'Success';

     open old_carrier_cur(ip_esn);
     fetch old_carrier_cur into old_carrier_rec;
     if old_carrier_cur%found then
        v_curent_carrier:=old_carrier_rec.x_mkt_submkt_name;
        v_current_carrier_id:=old_carrier_rec.x_carrier_id;
        v_activation_zip:=old_carrier_rec.x_zipcode;
        v_current_min:=old_carrier_rec.x_min;
        v_site_part_objid:=old_carrier_rec.site_part_objid;
        v_warranty_date:=old_carrier_rec.warranty_date;
        v_serv_plan_objid:=old_carrier_rec.x_service_plan_id;
        close old_carrier_cur;
     else
        close old_carrier_cur;
        op_err_num := '500';
        op_err_msg := 'Site Part Record Not Found';
        return;
     end if;

     open new_carrier_cur(ip_new_carrier_id);
     fetch new_carrier_cur into new_carrier_rec;
     if new_carrier_cur%found then
        v_assigned_carrier:=new_carrier_rec.x_mkt_submkt_name;
        v_assigned_carrier_id:=new_carrier_rec.x_carrier_id;
        close new_carrier_cur;
     else
        close new_carrier_cur;
        op_err_num := '510';
        op_err_msg := 'Site Part Record Not Found';
        return;
     end if;


     -- Create Case
     sa.clarify_case_pkg.create_case (P_TITLE => v_case_title,
                              P_CASE_TYPE => v_case_type,
                              P_STATUS => v_status,
                              P_PRIORITY => v_priority,
                              P_ISSUE => v_issue,
                              P_SOURCE => v_source,
                              P_POINT_CONTACT => null,
                              P_CREATION_TIME => sysdate,
                              P_TASK_OBJID => null,
                              P_CONTACT_OBJID => ip_contact_objid,
                              P_USER_OBJID => ip_user_objid,
                              P_ESN => ip_esn,
                              P_PHONE_NUM => null,
                              P_FIRST_NAME => null,
                              P_LAST_NAME => null,
                              P_E_MAIL => null,
                              P_DELIVERY_TYPE => null,
                              P_ADDRESS => null,
                              P_CITY => null,
                              P_STATE => null,
                              P_ZIPCODE => null,
                              P_REPL_UNITS => null,
                              P_FRAUD_OBJID => null,
                              P_CASE_DETAIL => null,
                              P_PART_REQUEST => null,
                              P_ID_NUMBER => v_id_number,
                              P_CASE_OBJID => v_case_objid,
                              P_ERROR_NO => v_error_no,
                              P_ERROR_STR => v_error_str);
  DBMS_OUTPUT.PUT_LINE('***********************************');
  DBMS_OUTPUT.PUT_LINE('create_case');
  DBMS_OUTPUT.PUT_LINE('P_ID_NUMBER = ' || v_id_number);
  DBMS_OUTPUT.PUT_LINE('P_ERROR_NO = ' || v_error_no);
  DBMS_OUTPUT.PUT_LINE('P_ERROR_STR = ' || v_error_str);
  DBMS_OUTPUT.PUT_LINE('***********************************');
  if v_error_no<>'0' then
      op_err_num := v_error_no;
      op_err_msg := v_error_str;
      return;
  end if;

  -- Update Case Details

  v_case_details:='CURRENT_CARRIER||'||v_curent_carrier;
  v_case_details:=v_case_details||'||CURRENT_CARRIER_ID||'||v_current_carrier_id;
  v_case_details:=v_case_details||'||ASSIGNED_CARRIER||'||v_assigned_carrier;
  v_case_details:=v_case_details||'||ASSIGNED_CARRIER_ID||'||v_assigned_carrier_id;
  v_case_details:=v_case_details||'||SIM_ID||'||ip_new_sim;
  v_case_details:=v_case_details||'||REPL_SIM_ID||'||ip_new_sim;
  v_case_details:=v_case_details||'||ACTIVATION_ZIP_CODE||'||v_activation_zip;
  v_case_details:=v_case_details||'||CURRENT_MIN||'||v_current_min;

  sa.CLARIFY_CASE_PKG.UPDATE_CASE_DTL(P_CASE_OBJID => v_case_objid,
                                      P_USER_OBJID => ip_user_objid,
                                      P_CASE_DETAIL => v_case_details,
                                      P_ERROR_NO => v_error_no,
                                      P_ERROR_STR => v_error_str);

  DBMS_OUTPUT.PUT_LINE('***********************************');
  DBMS_OUTPUT.PUT_LINE('UPDATE_CASE_DTL');
  DBMS_OUTPUT.PUT_LINE('P_ERROR_NO = ' || v_error_no);
  DBMS_OUTPUT.PUT_LINE('P_ERROR_STR = ' || v_error_str);
  DBMS_OUTPUT.PUT_LINE('***********************************');
  -- Dispatch Case
  sa.CLARIFY_CASE_PKG.DISPATCH_CASE(
    P_CASE_OBJID => v_case_objid,
    P_USER_OBJID => ip_user_objid,
    P_QUEUE_NAME => v_queue,
    P_ERROR_NO => v_error_no,
    P_ERROR_STR => v_error_str);

  DBMS_OUTPUT.PUT_LINE('***********************************');
  DBMS_OUTPUT.PUT_LINE('DISPATCH_CASE');
  DBMS_OUTPUT.PUT_LINE('P_ERROR_NO = ' || v_error_no);
  DBMS_OUTPUT.PUT_LINE('P_ERROR_STR = ' || v_error_str);
  DBMS_OUTPUT.PUT_LINE('***********************************');

  -- Deactivate Old Service
  sa.SERVICE_DEACTIVATION.DEACTSERVICE(
    IP_SOURCESYSTEM => ip_source_system,
    IP_USEROBJID => ip_user_objid,
    IP_ESN => ip_esn,
    IP_MIN => v_current_min,
    IP_DEACTREASON => v_deact_reason,
    INTBYPASSORDERTYPE => v_bypass_order_type,
    IP_NEWESN => ip_esn,
    IP_SAMEMIN => v_same_min,
    OP_RETURN => v_return,
    OP_RETURNMSG => v_return_msg);

  DBMS_OUTPUT.PUT_LINE('***********************************');
  DBMS_OUTPUT.PUT_LINE('DEACTSERVICE');
  DBMS_OUTPUT.PUT_LINE('OP_RETURN = ' || v_return);
  DBMS_OUTPUT.PUT_LINE('OP_RETURNMSG = ' || v_return_msg);
  DBMS_OUTPUT.PUT_LINE('***********************************');

    -- Move Line to New Carrier and Chnage Status to Reserved
    update sa.table_part_inst
    set part_inst2carrier_mkt = new_carrier_rec.objid,
        x_part_inst_status = '37',
        status2x_code_table = 969
    where part_serial_no = v_current_min
    and x_domain = 'LINES';

    -- Update PI Hist of the Line
    v_pi_Return := sa.TOSS_UTIL_PKG.INSERT_PI_HIST_FUN(
    IP_PART_SERIAL_NO => v_current_min,
    IP_DOMAIN => 'LINES',
    IP_ACTION => v_deact_reason,
    IP_PROG_CALLER => v_source);

    -- Update PI of the ESN  (new sim, por in flag = 1)
    update sa.table_part_inst
    set x_port_in = 1, x_iccid = ip_new_sim
    where part_serial_no = ip_esn
    and x_domain = 'PHONES';

    commit;

    create_site_part_call_trans (ip_site_part_objid => v_site_part_objid,
                                 ip_warr_date => v_warranty_date,
                                 ip_new_sim => ip_new_sim,
                                 ip_carrier_objid => new_carrier_rec.objid,
                                 ip_user_objid => ip_user_objid,
                                 ip_source => v_source,
                                 ip_serv_plan_id => v_serv_plan_objid,
                                 op_call_trans_objid => v_ct_objid );

  DBMS_OUTPUT.PUT_LINE('***********************************');
  DBMS_OUTPUT.PUT_LINE('create_site_part_call_trans');
  DBMS_OUTPUT.PUT_LINE('op_call_trans_objid = ' || v_ct_objid);
  DBMS_OUTPUT.PUT_LINE('***********************************');

    sa.CLARIFY_CASE_PKG.UPDATE_CASE_DTL(P_CASE_OBJID => v_case_objid,
                                      P_USER_OBJID => ip_user_objid,
                                      P_CASE_DETAIL => 'CALL_TRANSACTION_OBJID||'||v_ct_objid,
                                      P_ERROR_NO => v_error_no,
                                      P_ERROR_STR => v_error_str);



    sa.IGATE.SP_CREATE_ACTION_ITEM( P_CONTACT_OBJID => ip_contact_objid,
                                    P_CALL_TRANS_OBJID => v_ct_objid,
                                    P_ORDER_TYPE => v_order_type,
                                    P_BYPASS_ORDER_TYPE => 0,
                                    P_CASE_CODE => null,
                                    P_STATUS_CODE => v_status_code,
                                    P_ACTION_ITEM_OBJID => v_action_item_objid );

  DBMS_OUTPUT.PUT_LINE('***********************************');
  DBMS_OUTPUT.PUT_LINE('SP_CREATE_ACTION_ITEM');
  DBMS_OUTPUT.PUT_LINE('P_STATUS_CODE = ' || v_status_code);
  DBMS_OUTPUT.PUT_LINE('P_ACTION_ITEM_OBJID = ' || v_action_item_objid);
  DBMS_OUTPUT.PUT_LINE('***********************************');

  commit; -- Added to fix issue with TASK and IG creation in next call during SIM CHANGE flow CR49838

    sa.IGATE.CALL_SP_DETERMINE_TRANS_METHOD(P_ACTION_ITEM_OBJID => v_action_item_objid,
                                            P_ORDER_TYPE => v_order_type,
                                            P_TRANS_METHOD => v_trans_method,
                                            P_APPLICATION_SYSTEM => v_application_system,
                                            P_DESTINATION_QUEUE => v_destination_queue);

  DBMS_OUTPUT.PUT_LINE('***********************************');
  DBMS_OUTPUT.PUT_LINE('CALL_SP_DETERMINE_TRANS_METHOD');
  DBMS_OUTPUT.PUT_LINE('v_destination_queue = ' || v_destination_queue);
  DBMS_OUTPUT.PUT_LINE('***********************************');

   op_case_id:= v_id_number;

  end;

  /****************************************************/
  /*  Complemenets Procedure cross_carrier_sim_change */
  /****************************************************/
  procedure create_site_part_call_trans (ip_site_part_objid varchar2,
                                         ip_warr_date date,
                                         ip_new_sim varchar2,
                                         ip_carrier_objid varchar2,
                                         ip_user_objid varchar2,
                                         ip_source varchar2,
                                         ip_serv_plan_id varchar2,
                                         op_call_trans_objid out varchar2 ) is


     cursor site_part_cur is
     select sp.*,bo.org_id
     from sa.table_site_part sp,
          sa.table_part_inst pi,
          sa.table_mod_level ml,
          sa.table_part_num pn,
          sa.table_bus_org bo
     where sp.objid = ip_site_part_objid
     and pi.part_serial_no = sp.x_service_id
     and pi.x_domain = 'PHONES'
     and ml.objid = pi.n_part_inst2part_mod
     and pn.objid = ml.part_info2part_num
     and bo.objid = pn.part_num2bus_org;

     site_part_rec site_part_cur%rowtype;

     cursor call_trans_cur is
     select * from sa.table_x_call_trans
     where call_trans2site_part = ip_site_part_objid
     and x_action_type = '1'
     and rownum < 2;

     call_trans_rec call_trans_cur%rowtype;

     v_sp_objid varchar2(30);
     v_ct_objid varchar2(30);

  begin

     DBMS_OUTPUT.PUT_LINE('***********************************');
     dbms_output.put_line('create_site_part_call_trans');
     dbms_output.put_line('ip_site_part_objid = '||ip_site_part_objid);
     DBMS_OUTPUT.PUT_LINE('***********************************');

     if ip_site_part_objid is not null then

        open site_part_cur;
        fetch site_part_cur into site_part_rec;
        if site_part_cur%found then
           open call_trans_cur;
           fetch call_trans_cur into call_trans_rec;

           select sa.seq('site_part') into v_sp_objid from dual;

           if call_trans_cur%found then
                 Insert into sa.TABLE_SITE_PART (
                 OBJID,
                 INSTANCE_NAME,
                 SERIAL_NO,
                 S_SERIAL_NO,
                 INVOICE_NO,
                 SHIP_DATE,
                 INSTALL_DATE,
                 WARRANTY_DATE,
                 QUANTITY,
                 MDBK,
                 STATE_CODE,
                 STATE_VALUE,
                 MODIFIED,
                 LEVEL_TO_PART,
                 SELECTED_PRD,
                 PART_STATUS,
                 COMMENTS,
                 LEVEL_TO_BIN,
                 BIN_OBJID,
                 SITE_OBJID,
                 INST_OBJID,
                 DIR_SITE_OBJID,
                 MACHINE_ID,
                 SERVICE_END_DT,
                 DEV,
                 X_SERVICE_ID,
                 X_MIN,
                 X_PIN,
                 X_DEACT_REASON,
                 X_MIN_CHANGE_FLAG,
                 X_NOTIFY_CARRIER,
                 X_EXPIRE_DT,
                 X_ZIPCODE,
                 SITE_PART2PRODUCTBIN,
                 SITE_PART2SITE,
                 SITE_PART2SITE_PART,
                 SITE_PART2PART_INFO,
                 SITE_PART2PRIMARY,
                 SITE_PART2BACKUP,
                 ALL_SITE_PART2SITE,
                 SITE_PART2PART_DETAIL,
                 SITE_PART2X_NEW_PLAN,
                 SITE_PART2X_PLAN,
                 X_MSID,
                 X_REFURB_FLAG,
                 CMMTMNT_END_DT,
                 INSTANCE_ID,
                 SITE_PART_IND,
                 STATUS_DT,
                 X_ICCID,
                 X_ACTUAL_EXPIRE_DT,
                 UPDATE_STAMP)
                 values (
                 v_sp_objid, --OBJID,
                 site_part_rec.INSTANCE_NAME,
                 site_part_rec.SERIAL_NO,
                 site_part_rec.S_SERIAL_NO,
                 site_part_rec.INVOICE_NO,
                 site_part_rec.SHIP_DATE,
                 sysdate,
                 ip_warr_date, --WARRANTY_DATE,
                 site_part_rec.QUANTITY,
                 site_part_rec.MDBK,
                 site_part_rec.STATE_CODE,
                 site_part_rec.STATE_VALUE,
                 site_part_rec.MODIFIED,
                 site_part_rec.LEVEL_TO_PART,
                 site_part_rec.SELECTED_PRD,
                 'Pending',--PART_STATUS,
                 site_part_rec.COMMENTS,
                 site_part_rec.LEVEL_TO_BIN,
                 site_part_rec.BIN_OBJID,
                 site_part_rec.SITE_OBJID,
                 site_part_rec.INST_OBJID,
                 site_part_rec.DIR_SITE_OBJID,
                 site_part_rec.MACHINE_ID,
                 null, --SERVICE_END_DT,
                 site_part_rec.DEV,
                 site_part_rec.X_SERVICE_ID,
                 site_part_rec.X_MIN,
                 site_part_rec.X_PIN,
                 null, --X_DEACT_REASON,
                 null, --X_MIN_CHANGE_FLAG,
                 null, --X_NOTIFY_CARRIER,
                 ip_warr_date, --X_EXPIRE_DT,
                 site_part_rec.X_ZIPCODE,
                 site_part_rec.SITE_PART2PRODUCTBIN,
                 site_part_rec.SITE_PART2SITE,
                 site_part_rec.SITE_PART2SITE_PART,
                 site_part_rec.SITE_PART2PART_INFO,
                 site_part_rec.SITE_PART2PRIMARY,
                 site_part_rec.SITE_PART2BACKUP,
                 site_part_rec.ALL_SITE_PART2SITE,
                 site_part_rec.SITE_PART2PART_DETAIL,
                 site_part_rec.SITE_PART2X_NEW_PLAN,
                 site_part_rec.SITE_PART2X_PLAN,
                 site_part_rec.X_MSID,
                 site_part_rec.X_REFURB_FLAG,
                 site_part_rec.CMMTMNT_END_DT,
                 site_part_rec.INSTANCE_ID,
                 site_part_rec.SITE_PART_IND,
                 site_part_rec.STATUS_DT,
                 ip_new_sim, --X_ICCID,
                 null, --X_ACTUAL_EXPIRE_DT,
                 sysdate); --UPDATE_STAMP)

                 update table_part_inst
                 set x_part_inst2site_part = v_sp_objid
                 where part_serial_no = site_part_rec.X_SERVICE_ID
                 and x_domain = 'PHONES';

                 if ip_serv_plan_id is not null then
                   insert into sa.x_service_plan_site_part
                   (TABLE_SITE_PART_ID,X_SERVICE_PLAN_ID,X_LAST_MODIFIED_DATE)
                   values(v_sp_objid,ip_serv_plan_id,sysdate);
                 end if;

                 select sa.seq('x_call_trans') into v_ct_objid from dual;

                 Insert into sa.TABLE_X_CALL_TRANS (
                 OBJID,
                 CALL_TRANS2SITE_PART,
                 X_ACTION_TYPE,
                 X_CALL_TRANS2CARRIER,
                 X_CALL_TRANS2DEALER,
                 X_CALL_TRANS2USER,
                 X_LINE_STATUS,
                 X_MIN,
                 X_SERVICE_ID,
                 X_SOURCESYSTEM,
                 X_TRANSACT_DATE,
                 X_TOTAL_UNITS,
                 X_ACTION_TEXT,
                 X_REASON,
                 X_RESULT,
                 X_SUB_SOURCESYSTEM,
                 X_ICCID,
                 X_OTA_REQ_TYPE,
                 X_OTA_TYPE,
                 X_CALL_TRANS2X_OTA_CODE_HIST,
                 X_NEW_DUE_DATE,
                 UPDATE_STAMP)
                 values (
                 v_ct_objid, --OBJID,
                 v_sp_objid, --CALL_TRANS2SITE_PART,
                 '3', -- X_ACTION_TYPE (Reactivation),
                 ip_carrier_objid, --X_CALL_TRANS2CARRIER,
                 call_trans_rec.X_CALL_TRANS2DEALER,
                 ip_user_objid, --X_CALL_TRANS2USER,
                 call_trans_rec.X_LINE_STATUS,
                 site_part_rec.X_MIN, --X_MIN,
                 site_part_rec.X_SERVICE_ID,
                 ip_source, --X_SOURCESYSTEM,
                 sysdate, --X_TRANSACT_DATE,
                 null, --X_TOTAL_UNITS,
                 'REACTIVATION', --X_ACTION_TEXT,
                 call_trans_rec.X_REASON,
                 decode(site_part_rec.org_id,'STRAIGHT_TALK','Completed','Pending'), --X_RESULT,
                 call_trans_rec.X_SUB_SOURCESYSTEM,
                 ip_new_sim, --X_ICCID,
                 call_trans_rec.X_OTA_REQ_TYPE,
                 call_trans_rec.X_OTA_TYPE,
                 null, --X_CALL_TRANS2X_OTA_CODE_HIST,
                 null, --X_NEW_DUE_DATE,
                 sysdate); --UPDATE_STAMP

                 commit;
                 op_call_trans_objid:=  v_ct_objid;

           end if;
           close call_trans_cur;

        end if;
        close site_part_cur;
     end if;

  end;

  procedure comp_threshold (ip_esn in varchar2,
                            ip_user_objid in varchar2,
                            op_days  out number,
                            op_voice out number,
                            op_sms out number,
                            op_data out number)
  is

cursor agent_cur is
select
 (select nvl(sum(nvl(to_number(cd.x_value),0)),0)
 from sa.table_x_case_detail cd
 WHERE cd.detail2case = c.objid
 and Cd.X_Name in ('AIRTIME_UNITS','VOICE_UNITS','COMP_UNITS','REPLACE_UNITS','REPLACEMENT_UNITS','REPL_UNITS'))  Minutes,
 (select nvl(sum(nvl(to_number(cd.x_value),0)),0)
 from sa.table_x_case_detail cd
 WHERE cd.detail2case = c.objid
 and Cd.X_Name in ('AIRTIME_DATA','DATA_UNITS','REPL_DATA','COMP_DATA'))  Data_units,
 (select nvl(sum(nvl(to_number(cd.x_value),0)),0)
 from sa.table_x_case_detail cd
 WHERE cd.detail2case = c.objid
 and Cd.X_Name in ('AIRTIME_SMS','SMS_UNITS','REPL_SMS','COMP_SMS'))  sms_units,
 (SELECT nvl(sum(nvl(to_number(cd.x_value),0)),0)
 from sa.table_x_case_detail cd
 WHERE cd.detail2case = c.objid
 and Cd.X_Name in ('AIRTIME_DAYS','SERVICE_DAYS','COMP_SERVICE_DAYS','REPL_SERVICE_DAYS','REPLACEMENT_DAYS','REPL_DAYS','REPLACE_DAYS','COMP_DAYS'))  days
from  sa.table_case c
where 1=1
and c.case_originator2user = ip_user_objid
and   c.title ||'' in ('Compensation Units', 'Replacement Units','Compensation Service Plan', 'Replacement Service Plan')
and   c.creation_time >= trunc(sysdate);

agent_rec agent_cur%rowtype;

cursor agent_threshold_cur is
select * from sa.ADFCRM_COMP_THRESHOLD
where comp_level = 'AGENT' and comp_type='COMP'
and privclass_objid in (select user_access2privclass from table_user where objid = ip_user_objid);

agent_threshold_rec agent_threshold_cur%rowtype;


cursor transaction_threshold_cur is
select * from sa.ADFCRM_COMP_THRESHOLD
where comp_level = 'TRANSACTION' and comp_type='COMP'
and privclass_objid in (select user_access2privclass from table_user where objid = ip_user_objid);

transaction_threshold_rec transaction_threshold_cur%rowtype;

v_agent_days number:=0;
v_agent_voice number:=0;
v_agent_sms number:=0;
v_agent_data number:=0;

v_trans_days number:=0;
v_trans_voice number:=0;
v_trans_sms number:=0;
v_trans_data number:=0;

Begin

   for agent_threshold_rec in agent_threshold_cur loop
      if  agent_threshold_rec.comp_units = 'DAYS' then
         v_agent_days:=agent_threshold_rec.comp_value;
      end if;
      if  agent_threshold_rec.comp_units = 'VOICE' then
         v_agent_voice:=agent_threshold_rec.comp_value;
      end if;
      if  agent_threshold_rec.comp_units = 'SMS' then
         v_agent_sms:=agent_threshold_rec.comp_value;
      end if;
      if  agent_threshold_rec.comp_units = 'DATA' then
         v_agent_data:=agent_threshold_rec.comp_value;
      end if;
   end loop;

   for agent_rec in agent_cur loop
      v_agent_days:=v_agent_days-nvl(agent_rec.days,0);
      v_agent_voice:=v_agent_voice-nvl(agent_rec.minutes,0);
      v_agent_sms:=v_agent_sms-nvl(agent_rec.sms_units,0);
      v_agent_data:=v_agent_data-nvl(agent_rec.Data_units,0);
   end loop;

   for transaction_threshold_rec in transaction_threshold_cur loop
      if  transaction_threshold_rec.comp_units = 'DAYS' then
         v_trans_days:=transaction_threshold_rec.comp_value;
      end if;
      if  transaction_threshold_rec.comp_units = 'VOICE' then
         v_trans_voice:=transaction_threshold_rec.comp_value;
      end if;
      if  transaction_threshold_rec.comp_units = 'SMS' then
         v_trans_sms:=transaction_threshold_rec.comp_value;
      end if;
      if  transaction_threshold_rec.comp_units = 'DATA' then
         v_trans_data:=transaction_threshold_rec.comp_value;
      end if;
   end loop;

   if v_trans_days < v_agent_days then
      if v_trans_days>0 then
         op_days:=v_trans_days;
      end if;
   else
      if v_agent_days>0 then
        op_days:=v_agent_days;
      end if;
   end if;

   if v_trans_voice < v_agent_voice then
      if v_trans_voice >0 then
        op_voice:=v_trans_voice;
      end if;
   else
      if v_agent_voice>0 then
        op_voice:=v_agent_voice;
      end if;
   end if;

   if v_trans_sms < v_agent_sms then
      if v_trans_sms>0 then
        op_sms:=v_trans_sms;
      end if;
   else
      if v_agent_sms>0 then
        op_sms:=v_agent_sms;
      end if;
   end if;

   if v_trans_data < v_agent_data then
      if v_trans_data>0 then
        op_data:=v_trans_data;
      end if;
   else
      if v_agent_data>0 then
        op_data:=v_agent_data;
      end if;
   end if;

End;
  PROCEDURE SIM_MARRiAGE(P_ESN        IN VARCHAR2,
                         P_X_ICCID    IN VARCHAR2,
                         p_error_msg  OUT varchar2,
                         P_ERROR_CODE out NUMBER)
  AS
    v_SIM_INV_STATUS VARCHAR2(30);
    v_part_serial_no VARCHAR2(30);
  BEGIN
    -- (select * from table_x_code_table where x_code_type ='SIM');
    P_ERROR_CODE  :=  0;
    p_error_msg := 'SIM MARRIED SUCCESSFULLY';

    SELECT X_SIM_INV_STATUS
    INTO   v_SIM_INV_STATUS
    FROM   TABLE_X_SIM_INV
    where X_SIM_SERIAL_NO =  P_X_ICCID;

    if v_SIM_INV_STATUS != '253' then
      P_ERROR_CODE  :=  200;
      p_error_msg := 'SIM NOT NEW';
      return;
    end if;

    begin
      SELECT  pi.part_serial_no
      into   v_part_serial_no
      FROM   TABLE_PART_INST PI
      WHERE  pi.X_ICCID = P_X_ICCID;

      if v_part_serial_no = P_ESN then
        P_ERROR_CODE  :=  100;
        p_error_msg := 'ESN AND SIM ARE ALREADY MARRIED';
        return;
      end if;

    exception
      when others then
        null;
    end;


    for i in (SELECT  Pi.X_PART_INST_STATUS, PI.X_ICCID
              FROM   TABLE_PART_INST PI
              WHERE  pi.part_serial_no = P_ESN)
    loop
      if i.X_PART_INST_STATUS = '52' then
        UPDATE TABLE_X_SIM_INV
        SET X_SIM_INV_STATUS = '254' -- SET THE SIM TO SIM ACTIVE
        where X_SIM_SERIAL_NO =  P_X_ICCID;
      else
        UPDATE TABLE_X_SIM_INV
        SET X_SIM_INV_STATUS = '253'
        where X_SIM_SERIAL_NO = P_X_ICCID; -- SET THE SIM TO SIM NEW;
      end if;

      UPDATE TABLE_PART_INST
      SET X_ICCID = null
      where X_ICCID = P_X_ICCID; -- DIVORCE THE SIM

      UPDATE TABLE_PART_INST
      SET X_ICCID = P_X_ICCID
      where PART_SERIAL_NO = p_esn; -- MARRY THE SIM

    end loop;
    COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
        P_ERROR_CODE  :=  -300;
        p_error_msg := 'SIM NOT FOUND';
  end sim_marriage;
--------------------------------------------------------------------------------
  function has_keypad(ip_esn varchar2)
  return varchar2
  is
    ip_part_class_name varchar2(30);
    ret varchar2(30) := 'true';
  begin
    select pc.name part_class
    into   ip_part_class_name
    from   table_part_inst i,
           table_mod_level m,
           table_part_num pn,
           table_part_class pc
    where  1=1
    and    i.n_part_inst2part_mod = m.objid
    and    pn.objid = m.part_info2part_num
    and    pn.part_num2part_class = pc.objid
    and i.part_serial_no = ip_esn;

    ret := get_param_by_name_fun(
      ip_part_class_name => ip_part_class_name,
      ip_parameter => 'HAS_KEYPAD');

    if ret = 'N' then
      return 'false';
    else
      return 'true';
    end if;

  exception
    when others then
      return ret;
  end has_keypad;
--------------------------------------------------------------------------------

    FUNCTION get_phone_status_info(
            ip_esn IN VARCHAR2,
            ip_sim IN VARCHAR2,
            ip_min IN VARCHAR2)
        RETURN phone_status_rec_tab pipelined
    IS
        v_sim VARCHAR2(30);
        v_min VARCHAR2(30);

        CURSOR sim_by_esn_cur
        IS
            SELECT x_iccid
            FROM table_part_inst
            WHERE x_domain     = 'PHONES'
            AND part_serial_no = NVL(ip_esn,'NA');
        sim_by_esn_rec sim_by_esn_cur%rowtype;

        CURSOR min_by_esn_cur
        IS
            SELECT pi2.part_serial_no
            FROM sa.table_part_inst pi1,
                sa.table_part_inst pi2
            WHERE 1                       =1
            AND pi2.x_domain              = 'LINES'
            AND pi2.part_to_esn2part_inst = pi1.objid
            AND pi1.x_domain              = 'PHONES'
            AND pi1.part_serial_no        = NVL(ip_esn,'NA');
        min_by_esn_rec min_by_esn_cur%rowtype;

        --phone status
        CURSOR esn_status_cur
        IS
            SELECT tct.x_code_name esn_status
            FROM table_x_code_table tct,
                table_part_inst tpi
            WHERE tpi.x_domain     = 'PHONES'
            AND tpi.part_serial_no = NVL(ip_esn,'NA')
            AND tct.x_code_number  = tpi.x_part_inst_status;
        esn_status_rec esn_status_cur%rowtype;

        --sim status
        CURSOR sim_status_cur(in_sim IN VARCHAR2)
        IS
            SELECT c.x_code_name sim_status
            FROM table_x_sim_inv si,
                table_x_code_table c
            WHERE si.x_sim_inv_status = c.x_code_number
            AND si.x_sim_serial_no    = in_sim;
        sim_status_rec sim_status_cur%rowtype;

        --min status
        CURSOR min_status_cur(in_min IN VARCHAR2)
        IS
            SELECT ct3.x_code_name min_status
            FROM table_x_code_table ct3,
                table_part_inst tpi
            WHERE ct3.x_code_number = tpi.x_part_inst_status
            AND tpi.part_serial_no  = in_min;
        min_status_rec min_status_cur%rowtype;

        phone_status_rslt phone_status_rec;

    BEGIN

        IF ip_esn IS NOT NULL OR ip_esn != '' THEN

            IF ip_sim IS NULL OR ip_sim = '' THEN
                OPEN sim_by_esn_cur;
                FETCH sim_by_esn_cur INTO sim_by_esn_rec;
                IF sim_by_esn_cur%found THEN
                    v_sim:=sim_by_esn_rec.x_iccid;
                ELSE
                    v_sim:=NULL;
                END IF;
                CLOSE sim_by_esn_cur;
            ELSE
                v_sim:=ip_sim;
            END IF;

            IF ip_min IS NULL OR ip_min = '' THEN
                OPEN min_by_esn_cur;
                FETCH min_by_esn_cur INTO min_by_esn_rec;
                IF min_by_esn_cur%found THEN
                    v_min:=min_by_esn_rec.part_serial_no;
                ELSE
                    v_min:=NULL;
                END IF;
                CLOSE min_by_esn_cur;
            ELSE
                v_min:=ip_min;
            END IF;

            OPEN esn_status_cur;
            FETCH esn_status_cur INTO esn_status_rec;
            IF esn_status_cur%found THEN
                phone_status_rslt.esn_status := esn_status_rec.esn_status;
            END IF;
            CLOSE esn_status_cur;

            OPEN sim_status_cur(v_sim);
            FETCH sim_status_cur INTO sim_status_rec;
            IF sim_status_cur%found THEN
                phone_status_rslt.sim_status := sim_status_rec.sim_status;
            END IF;
            CLOSE sim_status_cur;

            OPEN min_status_cur(v_min);
            FETCH min_status_cur INTO min_status_rec;
            IF min_status_cur%found THEN
                phone_status_rslt.min_status := min_status_rec.min_status;
            END IF;
            CLOSE min_status_cur;

        END IF;
        pipe row(phone_status_rslt);
        RETURN;

    END get_phone_status_info;

--------------------------------------------------------------------------------

    FUNCTION get_contact_consent_info(
    ip_min     IN VARCHAR2,
    ip_channel IN VARCHAR2)
  RETURN contact_consent_rec_tab pipelined
    IS
        CURSOR get_esn_info_cur (p_min IN VARCHAR2)
        IS
            SELECT pi.x_part_inst_status,
                pi.x_part_inst2contact,
                pn.part_num2bus_org,
                sa.get_param_by_name_fun(ip_part_class_name=>pc.name,ip_parameter=>'DEVICE_TYPE') device_type
            FROM sa.table_part_inst lpi ,
                sa.table_part_inst pi,
                sa.table_mod_level ml,
                sa.table_part_num pn,
                sa.table_part_class pc
            WHERE lpi.part_serial_no = p_min
            AND lpi.x_domain         = 'LINES'
            AND pi.objid             = lpi.part_to_esn2part_inst
            AND pi.x_domain          = 'PHONES'
            AND ml.objid             = pi.n_part_inst2part_mod
            AND pn.objid             = ml.part_info2part_num
            AND pc.objid             = pn.part_num2part_class;
        esn_rec get_esn_info_cur%rowtype;

        CURSOR get_contact_consent_cur (p_contact_objid IN NUMBER, p_bus_org_objid IN NUMBER)
        IS
            SELECT NVL(add_info.x_do_not_email,0) do_not_email,
                NVL(add_info.x_do_not_sms,0) do_not_sms
            FROM sa.table_x_contact_add_info add_info
            WHERE add_info.add_info2contact = p_contact_objid
            AND add_info.add_info2bus_org   =p_bus_org_objid;
        get_contact_consent_rec get_contact_consent_cur%rowtype;
        contact_consent_rslt contact_consent_rec;

        v_x_part_inst2contact    sa.table_part_inst.x_part_inst2contact%type;
        v_part_num2bus_org         sa.table_part_num.part_num2bus_org%type;
        v_do_not_sms                     sa.table_x_contact_add_info.x_do_not_sms%type;
        v_do_not_email                sa.table_x_contact_add_info.x_do_not_email%type;

    BEGIN
        dbms_output.put_line('MIN is ================================= '||ip_min);
        IF ip_min IS NOT NULL AND ip_min != ' ' THEN

            dbms_output.put_line('MIN is NOT null======================= '||ip_min);
            ------------------------------------------------------------------------------
            -- Check ESN
            ------------------------------------------------------------------------------
            OPEN get_esn_info_cur(ip_min);
            FETCH get_esn_info_cur INTO esn_rec;
            CLOSE get_esn_info_cur;

            dbms_output.put_line('esn_rec.x_part_inst2contact============ '||esn_rec.x_part_inst2contact);
            dbms_output.put_line('esn_rec.part_num2bus_org=============== '||esn_rec.part_num2bus_org);

            ------------------------------------------------------------------------------
            -- Check for contact consent
            ------------------------------------------------------------------------------

            OPEN get_contact_consent_cur(esn_rec.x_part_inst2contact, esn_rec.part_num2bus_org);
            FETCH get_contact_consent_cur INTO get_contact_consent_rec;
            CLOSE get_contact_consent_cur;

            dbms_output.put_line('get_contact_consent_rec.do_not_sms=================== '||get_contact_consent_rec.do_not_sms);
            dbms_output.put_line('get_contact_consent_rec.do_not_email================= '||get_contact_consent_rec.do_not_email);

            contact_consent_rslt.sms_consent   := NVL(get_contact_consent_rec.do_not_sms,0);
            contact_consent_rslt.email_consent := NVL(get_contact_consent_rec.do_not_email,0);
        ELSE
            dbms_output.put_line('MIN is NULL');
            contact_consent_rslt.sms_consent   := 1;
            contact_consent_rslt.email_consent := 1;
        END IF;

        pipe row(contact_consent_rslt);
        RETURN;

    EXCEPTION
    WHEN OTHERS THEN
        contact_consent_rslt.sms_consent   := 1;
        contact_consent_rslt.email_consent := 1;
        pipe row(contact_consent_rslt);
        RETURN;

    END get_contact_consent_info;

    ----------------------------------------------------------------------------------

    FUNCTION can_auto_send_trans_summary(
            ip_esn_sim_min    IN VARCHAR2,
            ip_type                        IN VARCHAR2, -- LINE (MIN), SIM_CARD, HANDSET(ESN)
            ip_org_id                 IN VARCHAR2)
        RETURN send_trans_rec_tab pipelined
    IS
        CURSOR get_brand_consent_cur (p_org_id VARCHAR2)
        IS
            SELECT NVL(SMS_TRANS_SUMMARY_FLAG, 'N') brand_sms_consent,
                NVL(EMAIL_TRANS_SUMMARY_FLAG, 'N') brand_email_consent,
                NVL(SMS_TEMPLATE, 'N') sms_template
            FROM sa.table_bus_org
            WHERE org_id = p_org_id;
        get_brand_consent_rec get_brand_consent_cur%rowtype;
        brand_consent_rslt send_trans_rec;

        CURSOR min_by_esn_cur(in_esn IN VARCHAR2)
        IS
            SELECT pi2.part_serial_no
            FROM sa.table_part_inst pi1,
                sa.table_part_inst pi2
            WHERE 1                       =1
            AND pi2.x_domain              = 'LINES'
            AND pi2.part_to_esn2part_inst = pi1.objid
            AND pi1.x_domain              = 'PHONES'
            AND pi1.part_serial_no        = NVL(in_esn,'NA');
        min_by_esn_rec min_by_esn_cur%rowtype;

        CURSOR esn_by_sim_cur
        IS
            SELECT part_serial_no
            FROM table_part_inst
            WHERE x_domain     = 'PHONES'
            AND x_iccid = NVL(ip_esn_sim_min,'NA');
        esn_by_sim_rec esn_by_sim_cur%rowtype;

        v_contact_sms_consent   NUMBER;
        v_contact_email_consent NUMBER;
        v_min                   sa.table_part_inst.part_serial_no%type;
        v_esn                                     sa.table_part_inst.part_serial_no%type;

    BEGIN

        -- Direct ESN coming as input
        IF ip_esn_sim_min IS NOT NULL AND ip_type = 'HANDSET' THEN
            v_esn := ip_esn_sim_min;
        END IF;

        -- Get ESN from MIN
        IF ip_esn_sim_min IS NOT NULL AND ip_type = 'LINE' THEN
            SELECT sa.adfcrm_cust_service.esn_by_min(ip_esn_sim_min) esn
            INTO v_esn
            FROM dual;
        END IF;

        -- Get ESN from SIM
        IF ip_esn_sim_min IS NOT NULL AND ip_type = 'SIM_CARD' THEN
            OPEN esn_by_sim_cur;
            FETCH esn_by_sim_cur INTO esn_by_sim_rec;
            IF esn_by_sim_cur%found THEN
                v_esn                         := esn_by_sim_rec.part_serial_no;
            ELSE
                v_esn:=NULL;
            END IF;
            CLOSE esn_by_sim_cur;
        END IF;
        dbms_output.put_line('v_esn====================== '||v_esn);

        IF v_esn IS NOT NULL AND v_esn != ' ' THEN
            OPEN min_by_esn_cur(v_esn);
            FETCH min_by_esn_cur INTO min_by_esn_rec;
            IF min_by_esn_cur%found THEN
                v_min                         := min_by_esn_rec.part_serial_no;
            ELSE
                v_min:=NULL;
            END IF;
            CLOSE min_by_esn_cur;

            brand_consent_rslt.min_to_sms := NVL(v_min, '-1');
            dbms_output.put_line('v_min====================== '||v_min);

            ------------------------------------------------------------------------------
            -- Check for contact consent
            ------------------------------------------------------------------------------
            SELECT sms_consent,
                email_consent
            INTO v_contact_sms_consent,
                v_contact_email_consent
            FROM TABLE(get_contact_consent_info(ip_min => v_min, ip_channel => 'TAS'));
        ELSE
            v_contact_sms_consent   := 1;
            v_contact_email_consent := 1;
        END IF;

        dbms_output.put_line('v_contact_sms_consent====================== '||v_contact_sms_consent);
        dbms_output.put_line('v_contact_email_consent==================== '||v_contact_email_consent);
        ------------------------------------------------------------------------------
        -- Check for brand consent
        ------------------------------------------------------------------------------
        OPEN get_brand_consent_cur(ip_org_id);
        FETCH get_brand_consent_cur INTO get_brand_consent_rec;
        CLOSE get_brand_consent_cur;

        dbms_output.put_line('brand_sms_consent================================ '||get_brand_consent_rec.brand_sms_consent);
        dbms_output.put_line('brand_email_consent================================ '||get_brand_consent_rec.brand_email_consent);

        IF NVL(v_contact_sms_consent,0) = 1 OR NVL(get_brand_consent_rec.brand_sms_consent,'N') = 'N' THEN
            brand_consent_rslt.sms_trans_summary := 'N';
        ELSE
            brand_consent_rslt.sms_trans_summary := 'Y';
            brand_consent_rslt.sms_template      := NVL(get_brand_consent_rec.sms_template, 'N');
        END IF;

        IF NVL(v_contact_email_consent,0) = 1 OR NVL(get_brand_consent_rec.brand_email_consent,'N') = 'N' THEN
            brand_consent_rslt.email_trans_summary := 'N';
        ELSE
            brand_consent_rslt.email_trans_summary := 'Y';
        END IF;

        dbms_output.put_line('email_trans_summary================ '||brand_consent_rslt.email_trans_summary);
        dbms_output.put_line('sms_trans_summary================== '||brand_consent_rslt.sms_trans_summary);

        pipe row(brand_consent_rslt);
        RETURN;

    EXCEPTION
    WHEN OTHERS THEN
        brand_consent_rslt.sms_trans_summary   := 'N';
        brand_consent_rslt.email_trans_summary := 'N';
        brand_consent_rslt.sms_template        := 'N';
        brand_consent_rslt.min_to_sms          := '-1';
        pipe row(brand_consent_rslt);
        RETURN;

    END can_auto_send_trans_summary;
----------------------------------------------------------------------------------
    FUNCTION default_challenge_rec
    RETURN challenge_rec IS
        challenge_rslt challenge_rec;
    BEGIN
        challenge_rslt.priority := null;
        challenge_rslt.challenge := null;
        challenge_rslt.response := null;
        return challenge_rslt;
    END default_challenge_rec;

    FUNCTION get_challenge(
        p_web_user_objid IN VARCHAR2,
        p_contact_objid IN VARCHAR2)
    RETURN challenge_tab pipelined IS
        CURSOR get_web_user is
            select wu.login_name, wu.x_secret_questn, wu.x_secret_ans, wu.web_user2contact, wu.web_user2bus_org, bo.org_id
            from table_web_user wu, table_bus_org bo
            where wu.objid = p_web_user_objid
            and bo.objid = wu.web_user2bus_org;

        get_web_user_rec get_web_user%rowtype;
        challenge_rslt challenge_rec;
    BEGIN
        open get_web_user;
        fetch get_web_user into get_web_user_rec;
        close get_web_user;

        if get_web_user_rec.login_name is not null then
            challenge_rslt := default_challenge_rec();
            challenge_rslt.priority := 6;
            challenge_rslt.challenge := 'Email';
            challenge_rslt.response := get_web_user_rec.login_name;
            pipe row (challenge_rslt);
        end if;

        if get_web_user_rec.web_user2contact is not null
        then
            --    Security PIN
            for rec in (
                        select 'Security PIN Account' challenge,c.x_pin response
                        from table_x_contact_add_info c
                        where c.add_info2contact = get_web_user_rec.web_user2contact
                        and c.x_pin is not null
                        union
                        select 'Security PIN Member' challenge,c.x_pin response
                        from table_x_contact_add_info c, table_contact co
                        where co.objid = p_contact_objid
                        and co.objid = c.add_info2contact
                        and p_contact_objid != get_web_user_rec.web_user2contact
                        and get_web_user_rec.org_id = 'WFM'
                        and c.x_pin is not null
                        )
            loop
                if rec.response is not null then
                    challenge_rslt := default_challenge_rec();
                    challenge_rslt.priority := 1;
                    challenge_rslt.challenge := rec.challenge;
                    challenge_rslt.response := rec.response;
                    pipe row (challenge_rslt);
                end if;
            end loop;

            --    Security Questions
            if length(nvl(get_web_user_rec.x_secret_questn,'')) >0 and length(nvl(get_web_user_rec.x_secret_ans,'')) > 0 then
                challenge_rslt := default_challenge_rec();
                challenge_rslt.priority := 2;
                challenge_rslt.challenge := get_web_user_rec.x_secret_questn;
                challenge_rslt.response := get_web_user_rec.x_secret_ans;
                pipe row (challenge_rslt);
            end if;

            --    Date of Birth
            for rec in (select 'Date of Birth' challenge_dob, to_char(x_dateofbirth,'mm/dd/yyyy') response_dob,
                               'Zip Code' challenge_zipcode, zipcode response_zipcode
                        from table_contact
                        where objid = get_web_user_rec.web_user2contact
                        )
            loop
                if rec.response_dob is not null then
                    challenge_rslt := default_challenge_rec();
                    challenge_rslt.priority := 4;
                    challenge_rslt.challenge := rec.challenge_dob;
                    challenge_rslt.response := rec.response_dob;
                    pipe row (challenge_rslt);
                end if;
                if rec.response_zipcode is not null then
                    challenge_rslt := default_challenge_rec();
                    challenge_rslt.priority := 5;
                    challenge_rslt.challenge := rec.challenge_zipcode;
                    challenge_rslt.response := rec.response_zipcode;
                    pipe row (challenge_rslt);
                end if;
            end loop;
        end if;
        --    ESN/MIN
        for rec in (
                    select 'ESN/MIN combination' challenge, x_service_id||'/'||x_min response
                    from table_site_part
                    where x_service_id in (select part_serial_no from table_part_inst where x_part_inst2contact = p_contact_objid)
                    and part_status = 'Active'
                    )
        loop
        if rec.response is not null then
            challenge_rslt := default_challenge_rec();
            challenge_rslt.priority := 3;
            challenge_rslt.challenge := rec.challenge;
            challenge_rslt.response := rec.response;
            pipe row (challenge_rslt);
        end if;
        end loop;



        /***--    Zip Code
        for rec in (select 'Activation Zip Code MIN '||tsp.x_min challenge,tsp.x_zipcode response
                    from sa.table_web_user web,
                         sa.table_x_contact_part_inst conpi,
                         sa.table_part_inst pi,
                         sa.table_site_part tsp
                    where web.objid = p_web_user_objid
                    and   conpi.x_contact_part_inst2contact = web.web_user2contact
                    and   pi.objid = conpi.x_contact_part_inst2part_inst
                    and   tsp.objid  = pi.x_part_inst2site_part
                    union
                    select 'Activation Zip Code MIN '||tsp.x_min challenge,tsp.x_zipcode response
                    from sa.table_part_inst pi,
                        sa.table_site_part tsp
                    where pi.x_part_inst2contact = p_contact_objid
                    and   tsp.objid  = pi.x_part_inst2site_part
                    )
        loop
        if rec.response is not null then
            challenge_rslt := default_challenge_rec();
            challenge_rslt.priority := 5;
            challenge_rslt.challenge := rec.challenge;
            challenge_rslt.response := rec.response;
            pipe row (challenge_rslt);
        end if;
        end loop;


        --    Email
        for rec in (select 'Email' challenge, e_mail response
                    from table_contact
                    where objid = p_contact_objid
                    )
        loop
        if rec.response is not null then
            challenge_rslt := default_challenge_rec();
            challenge_rslt.priority := 6;
            challenge_rslt.challenge := rec.challenge;
            challenge_rslt.response := rec.response;
            pipe row (challenge_rslt);
        end if;
        end loop;

        *****/

        --    The Lifeline ID should be displayed only if the customer is a Safelink customer
        for rec in (select 'Safelink Lifeline ID' challenge, lid response
                    from sa.table_part_inst pi, sa.x_sl_currentvals slh
                    where pi.x_part_inst2contact = p_contact_objid
                    and   slh.x_current_esn =  pi.part_serial_no
                    and   rownum < 2
                    )
        loop
            challenge_rslt := default_challenge_rec();
            challenge_rslt.priority := 7;
            challenge_rslt.challenge := rec.challenge;
            challenge_rslt.response := rec.response;
            pipe row (challenge_rslt);
        end loop;
        return;
    END get_challenge;
end adfcrm_cust_service;
/