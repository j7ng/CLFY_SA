CREATE OR REPLACE package sa.adfcrm_vas
AS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_VAS_PKG.sql,v $
--$Revision: 1.2 $
--$Author: mmunoz $
--$Date: 2017/11/27 23:29:15 $
--$ $Log: ADFCRM_VAS_PKG.sql,v $
--$ Revision 1.2  2017/11/27 23:29:15  mmunoz
--$ CR55214 Asurion HPP for TF Web & TF TAS
--$
--------------------------------------------------------------------------------------------
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
return sa.vas_program_details_tab pipelined;

--*************************************************************************************
  type get_eligible_vas_rec is record
  (
    vas_plan_id        number,
    vas_name        varchar2(100),
    vas_name_desc    varchar2(100),
    vas_plan_price    number,
    part_number        varchar2(100),
    part_class        varchar2(100),
    vas_category    varchar2(100),
    vas_script_text    varchar2(4000),
    program_objid    number,
    program_name    varchar2(4000),
    program_desc    varchar2(4000),
    is_recurring    number
  );

  type get_eligible_vas_tab is table of get_eligible_vas_rec;

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
return get_eligible_vas_tab pipelined;

--*************************************************************************************

function get_enrolled_vas_services(i_esn varchar2)
return sa.vas_program_details_tab pipelined;

--*************************************************************************************
function get_vas_refund(
  i_esn varchar2,
  i_vas_service_id varchar2,
  i_vas_subscription_id varchar2,
  i_program_id varchar2,
  i_cancel_effective_date date
  )
return varchar2;

END adfcrm_vas;
/