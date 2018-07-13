CREATE OR REPLACE package body sa.adfcrm_vas
AS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_VAS_PKB.sql,v $
--$Revision: 1.3 $
--$Author: mmunoz $
--$Date: 2017/11/29 23:52:28 $
--$ $Log: ADFCRM_VAS_PKB.sql,v $
--$ Revision 1.3  2017/11/29 23:52:28  mmunoz
--$ Asurion HPP. Do not offer  one time payment program
--$
--$ Revision 1.2  2017/11/27 23:37:27  mmunoz
--$ CR55214 Asurion HPP for TF Web & TF TAS
--$
--------------------------------------------------------------------------------------------
--*************************************************************************************
function default_eligible_vas_rec
return get_eligible_vas_rec is
    get_eligible_vas_rslt get_eligible_vas_rec;
begin
    get_eligible_vas_rslt.vas_plan_id := null;
    get_eligible_vas_rslt.vas_name := null;
    get_eligible_vas_rslt.vas_name_desc := null;
    get_eligible_vas_rslt.vas_plan_price := null;
    get_eligible_vas_rslt.part_number := null;
    get_eligible_vas_rslt.part_class := null;
    get_eligible_vas_rslt.vas_category := null;
    get_eligible_vas_rslt.vas_script_text := null;
    get_eligible_vas_rslt.program_objid := null;
    get_eligible_vas_rslt.program_name := null;
    get_eligible_vas_rslt.program_desc := null;
    get_eligible_vas_rslt.is_recurring := null;
    return get_eligible_vas_rslt;
end;
--*************************************************************************************
function get_eligible_vas_services (
  i_esn varchar2,
  i_min varchar2,
  i_bus_org varchar2,
  i_ecommerce_orderid varchar2,
  i_phone_make varchar2,
  i_phone_model varchar2,
  i_phone_price number,
  i_activation_zipcode varchar2,
  i_is_byod varchar2,
  i_enrolled_only varchar2,
  i_to_esn varchar2,
  i_process_flow varchar2
  )
return sa.vas_program_details_tab pipelined is
  o_vas_program_details_tab sa.vas_program_details_tab;
  o_error_code varchar2(200);
  o_error_msg varchar2(200);
begin
  sa.vas_management_pkg.p_get_eligible_vas_services(
    i_esn => i_esn,
    i_min => i_min,
    i_bus_org => i_bus_org,
    i_ecommerce_orderid => i_ecommerce_orderid,
    i_phone_make => i_phone_make,
    i_phone_model => i_phone_model,
    i_phone_price => i_phone_price,
    i_activation_zipcode => i_activation_zipcode,
    i_is_byod => i_is_byod,
    i_enrolled_only => i_enrolled_only,
    i_to_esn => i_to_esn,
    i_process_flow => i_process_flow,
    o_vas_program_details_tab => o_vas_program_details_tab,
    o_error_code => o_error_code,
    o_error_msg => o_error_msg
  );
  if o_vas_program_details_tab.last > 0 then
      for i in o_vas_program_details_tab.first .. o_vas_program_details_tab.last
      loop
        --dbms_output.put_line('o_vas_program_details_tab = ' || i ||'  '||o_vas_program_details_tab(i).vas_name);
        pipe row (o_vas_program_details_tab(i));
      end loop;
   else
      dbms_output.put_line('o_vas_program_details_tab is empty');
   end if;

dbms_output.put_line('o_error_code = ' || o_error_code);
dbms_output.put_line('o_error_msg = ' || o_error_msg);
return;
end get_eligible_vas_services;

--*************************************************************************************
function get_enrolled_vas_services(i_esn varchar2)
return sa.vas_program_details_tab pipelined is
  o_vas_program_details_tab sa.vas_program_details_tab;
  o_error_code varchar2(200);
  o_error_msg varchar2(200);
begin

  sa.vas_management_pkg.p_get_enrolled_vas_services(
    i_esn => i_esn,
    o_vas_program_details_tab => o_vas_program_details_tab,
    o_error_code => o_error_code,
    o_error_msg => o_error_msg
  );

  if o_vas_program_details_tab.last > 0 then
      for i in o_vas_program_details_tab.first .. o_vas_program_details_tab.last
      loop
        --dbms_output.put_line('o_vas_program_details_tab = ' || i ||'  '||o_vas_program_details_tab(i).vas_name);
    pipe row (o_vas_program_details_tab(i));
      end loop;
   else
      dbms_output.put_line('o_vas_program_details_tab is empty');
   end if;

dbms_output.put_line('o_error_code = ' || o_error_code);
dbms_output.put_line('o_error_msg = ' || o_error_msg);
return;
end get_enrolled_vas_services;

--*************************************************************************************
function get_eligible_vas_services_tas (
  i_esn varchar2,
  i_min varchar2,
  i_bus_org varchar2,
  i_ecommerce_orderid varchar2,
  i_phone_make varchar2,
  i_phone_model varchar2,
  i_phone_price number,
  i_activation_zipcode varchar2,
  i_is_byod varchar2,
  i_enrolled_only varchar2,
  i_to_esn varchar2,
  i_process_flow varchar2,
  i_language varchar2
  )
return get_eligible_vas_tab pipelined is
  get_eligible_vas_rslt get_eligible_vas_rec;
begin
    for vasrec in (
                select vas.vas_service_id,
                       vas.vas_service_id vas_plan_id,
                       vas.vas_name vas_name,
                       vas.vas_description_english vas_name_desc,
                       vas.x_retail_price vas_plan_price,
                       vas.part_number part_number,
                       vas.part_class part_class,
                       vas.vas_category vas_category
                       ,vas_dtl.vas_script_text
                FROM TABLE(sa.ADFCRM_VAS.get_eligible_vas_services(i_esn, i_min, i_bus_org, i_ecommerce_orderid
                          ,i_phone_make, i_phone_model, i_phone_price, i_activation_zipcode, i_is_byod, i_enrolled_only, i_to_esn, i_process_flow)) vas
                     ,sa.adfcrm_vas_details_scripts_mv vas_dtl
                where vas_dtl.vas_service_id = vas.vas_service_id
                and vas_dtl.x_language = upper(i_language)
                and vas.status = 'ELIGIBLE'
                )
    loop
        get_eligible_vas_rslt := default_eligible_vas_rec();
        for pprec in (select
                            pp.objid,
                            mv.x_prg_script_text program_name,
                            mv.x_prg_desc_script_text program_desc,
                            pp.x_is_recurring
                        from
                              sa.vas_programs_view vasp,
                              sa.x_program_parameters pp,
                              sa.adfcrm_prg_enrolled_script_mv mv
                        where vasp.vas_service_id = vasrec.vas_service_id
                        --and pp.objid in (vasp.program_parameters_objid, vasp.auto_pay_program_objid)
                        and pp.objid = nvl(vasp.auto_pay_program_objid,vasp.program_parameters_objid)  --Do not show option for one time purchase
                        and mv.prg_objid = pp.objid
                        and mv.x_language = upper(i_language)
                        )
        loop
            get_eligible_vas_rslt.vas_plan_id := vasrec.vas_plan_id;
            get_eligible_vas_rslt.vas_name := vasrec.vas_name;
            get_eligible_vas_rslt.vas_name_desc := vasrec.vas_name_desc;
            get_eligible_vas_rslt.vas_plan_price := vasrec.vas_plan_price;
            get_eligible_vas_rslt.part_number := vasrec.part_number;
            get_eligible_vas_rslt.part_class := vasrec.part_class;
            get_eligible_vas_rslt.vas_category := vasrec.vas_category;
            get_eligible_vas_rslt.vas_script_text := vasrec.vas_script_text;
            get_eligible_vas_rslt.program_objid := pprec.objid;
            get_eligible_vas_rslt.program_name := pprec.program_name;
            get_eligible_vas_rslt.program_desc := pprec.program_desc;
            get_eligible_vas_rslt.is_recurring := pprec.x_is_recurring;
            pipe row (get_eligible_vas_rslt);
        end loop;
    end loop;
    return;
end get_eligible_vas_services_tas;

--*************************************************************************************
function get_vas_refund(
  i_esn varchar2,
  i_vas_service_id varchar2,
  i_vas_subscription_id varchar2,
  i_program_id varchar2,
  i_cancel_effective_date date
  )
return varchar2 is
  o_total_refund_amount number;
  o_tax_refund_amount number;
  o_e911_refund_amount number;
  o_usf_refund_amount number;
  o_rcrf_refund_amount number;
  o_error_code varchar2(4000);
  o_error_msg varchar2(4000);
  v_refund_amount varchar2(100);
begin
  vas_management_pkg.p_calculate_vas_refund(
    i_esn => i_esn,
    i_vas_service_id => i_vas_service_id,
    i_vas_subscription_id => i_vas_subscription_id,
    i_program_id => i_program_id,
    i_cancel_effective_date => nvl(i_cancel_effective_date,sysdate),
    o_total_refund_amount => o_total_refund_amount,
    o_tax_refund_amount => o_tax_refund_amount,
    o_e911_refund_amount => o_e911_refund_amount,
    o_usf_refund_amount => o_usf_refund_amount,
    o_rcrf_refund_amount => o_rcrf_refund_amount,
    o_error_code => o_error_code,
    o_error_msg => o_error_msg
  );

  v_refund_amount := to_char(round(o_total_refund_amount,2));
  return v_refund_amount;
END;

END adfcrm_vas;
/