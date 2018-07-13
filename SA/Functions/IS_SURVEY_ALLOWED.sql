CREATE OR REPLACE FUNCTION sa."IS_SURVEY_ALLOWED" (p_min varchar2, p_channel varchar2)
return varchar2
as
--------------------------------------------------------------------------------------------
--$RCSfile: IS_SURVEY_ALLOWED.sql,v $
--$Revision: 1.3 $
--$Author: mmunoz $
--$Date: 2017/08/08 18:08:34 $
--$ $Log: IS_SURVEY_ALLOWED.sql,v $
--$ Revision 1.3  2017/08/08 18:08:34  mmunoz
--$ CR52932 we dona??t need the a??X unit of timea??. We also do not need to check against the DNC list when the survey is sent manually.
--$
--$ Revision 1.2  2017/08/08 17:25:37  mmunoz
--$ CR52932 excluding PPE so customer is not charged for the survey
--$
--$ Revision 1.1  2017/07/07 23:15:54  mmunoz
--$ 611611 Survey integration Phase II
--$
--------------------------------------------------------------------------------------------
  cursor get_esn_info (p_min varchar2) is
      select pi.x_part_inst_status, pi.x_part_inst2contact, pn.part_num2bus_org,
             sa.get_param_by_name_fun(ip_part_class_name=>pc.name,ip_parameter=>'DEVICE_TYPE') device_type
      from sa.table_part_inst lpi ,
           sa.table_part_inst pi,
           sa.table_mod_level ml,
           sa.table_part_num  pn,
           sa.table_part_class pc
      where lpi.part_serial_no = p_min
      and lpi.x_domain = 'LINES'
      and pi.objid = lpi.part_to_esn2part_inst
      and pi.x_domain = 'PHONES'
      and ml.objid = pi.n_part_inst2part_mod
      and pn.objid = ml.part_info2part_num
      and pc.objid = pn.part_num2part_class;
  esn_rec get_esn_info%rowtype;

  cursor get_contact_consent (p_contact_objid number, p_bus_org_objid in number) is
      select nvl(add_info.x_do_not_sms,0) do_not_sms
      from  sa.table_x_contact_add_info add_info
      where add_info.add_info2contact = p_contact_objid
      and add_info.add_info2bus_org =p_bus_org_objid;
  rec get_contact_consent%rowtype;

  v_survey_cnt number;
  v_survey_time number;
  v_survey_auto varchar2(10) := 'false';
begin
    if p_min is null then
       return 'false';
    end if;
    ------------------------------------------------------------------------------
    -- Check ESN
    ------------------------------------------------------------------------------
    open get_esn_info(p_min);
    fetch get_esn_info into esn_rec;
    close get_esn_info;

    --if NOT(esn_rec.x_part_inst_status = '52' and esn_rec.device_type in ('BYOP','FEATURE_PHONE','SMARTPHONE')) then
    --CR52932 excluding PPE so customer is not charged
    if NOT(esn_rec.x_part_inst_status = '52' and esn_rec.device_type in ('BYOP','SMARTPHONE')) then
       return 'false';
    end if;

    ------------------------------------------------------------------------------
    -- Find the parameter to verify if survey can be sent automatically
    ------------------------------------------------------------------------------
    begin
      select nvl(x_param_value,'false') survey_auto_flag
      into   v_survey_auto
      from   sa.table_x_parameters
      where  x_param_name = 'ADFCRM_SEND_SURVEY_AUTOMATICALLY';
    exception
    when others then
        v_survey_auto := 'false';
    end;

    if v_survey_auto = 'true' then --CR52932
        ------------------------------------------------------------------------------
        -- Check for contact consent
        ------------------------------------------------------------------------------
        open get_contact_consent(esn_rec.x_part_inst2contact, esn_rec.part_num2bus_org);
        fetch get_contact_consent into rec;
        close get_contact_consent;

        if nvl(rec.do_not_sms,0) = 1 then
           return 'false';
        end if;

        ------------------------------------------------------------------------------
        -- Find the parameter for configurable time, to verify survey has not been sent in X units of time (ex: 24 hrs)
        ------------------------------------------------------------------------------
        begin
          select nvl(x_param_value,0)/24 survey_time
          into   v_survey_time
          from   sa.table_x_parameters
          where  x_param_name = 'ADFCRM_SURVEY_WAIT_TIME';
        exception
        when others then
                v_survey_time := 1;
        end;

        ---------------------------------
        -- Check for recent survey
        ---------------------------------
        begin
          select count(*)
          into   v_survey_cnt
          from   sa.table_interact
          where  start_date >= sysdate-v_survey_time
          and        s_reason_1 = 'SURVEY OFFER'
          and        mobile_phone = p_min;
        exception
          when others then
                v_survey_cnt := 0;
        end;

        if v_survey_cnt > 0 then
            return 'false';
        end if;
  end if;

  return 'true';

exception
  when others then
    dbms_output.put_line('ERROR - Unable to validate interaction==> '||sqlerrm);
    return 'false';
end is_survey_allowed;
/