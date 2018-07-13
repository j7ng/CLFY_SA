CREATE OR REPLACE package sa.ADFCRM_TRANSACTION_SUMMARY
AS
--------------------------------------------------------------------------------------------
--$RCSfile: ADFCRM_TRANSACTION_SUMMARY_PKG.sql,v $
--$Revision: 1.36 $
--$Author: mmunoz $
--$Date: 2018/01/18 14:03:40 $
--$ $Log: ADFCRM_TRANSACTION_SUMMARY_PKG.sql,v $
--$ Revision 1.36  2018/01/18 14:03:40  mmunoz
--$ CR53171  Updated type for serv_plan_added_script to clob
--$
--$ Revision 1.35  2017/12/02 01:47:58  mmunoz
--$ Added current_esn for get_case_info required for upgrade scenarios
--$
--$ Revision 1.34  2017/12/01 18:02:25  mmunoz
--$ Added esn for get_case_info required for upgrade scenarios
--$
--$ Revision 1.33  2017/11/27 23:33:05  mmunoz
--$ CR55214 Asurion HPP for TF Web & TF TAS
--$
--$ Revision 1.32  2016/11/18 21:54:27  mmunoz
--$ CR45711 : Added bankaccount_id in type esnTransactionDetail_rec
--$
--$ Revision 1.31  2016/11/02 14:27:38  mmunoz
--$ CR 45463, 44787 : Changes for BOGO promotion in transaction summary, added ip_check_condition in getServiceVO and trans_script_group
--$
--$ Revision 1.29  2015/02/09 23:18:56  mmunoz
--$ Added quantity in getSafelink
--$
--$ Revision 1.28  2015/02/05 22:19:44  mmunoz
--$ added column paid_until in esnTransactionDetail_rec  record
--$
--$ Revision 1.27  2015/01/22 00:30:19  mmunoz
--$ added function trans_script_group
--$
--$ Revision 1.26  2014/09/26 13:56:56  mmunoz
--$ Added some columns to return in getServiceVO
--$
--$ Revision 1.25  2014/08/21 21:48:01  mmunoz
--$ TAS_2014_07 change varchar2 for clob
--$
--$ Revision 1.24  2014/08/21 00:43:45  mmunoz
--$ new function getServiceVO
--$
--$ Revision 1.23  2014/05/29 15:12:38  mmunoz
--$ Added language in getEsnTransactionDetail
--$
--$ Revision 1.22  2014/05/05 15:05:57  mmunoz
--$ moved out  function manual_code_required
--$
--$ Revision 1.21  2014/04/30 21:36:26  mmunoz
--$ moved getEsnRedemption to pkg adfcrm_get_redemption
--$
--$ Revision 1.20  2014/04/18 02:17:55  mmunoz
--$ TAS_2014_02
--$
--$ Revision 1.19  2014/04/16 22:42:53  mmunoz
--$ new function get_others_added
--$
--$ Revision 1.18  2014/04/15 20:42:52  mmunoz
--$ Added red_sms and red_data in type esnRedemption_rec
--$
--$ Revision 1.17  2014/03/12 14:25:20  mmunoz
--$ CR26941 TAS Straight Talk
--$
--$ Revision 1.16  2014/02/13 22:01:45  mmunoz
--$ New functions added getEasyExchangeScriptName and get_service_plan_added
--$
--$ Revision 1.15  2014/02/11 21:14:14  mmunoz
--$ CR17975 Enhancement Units
--$
--$ Revision 1.14  2013/12/18 19:53:33  mmunoz
--$ CR26679
--$
--$ Revision 1.13  2013/12/06 19:22:43  mmunoz
--$ CR26679 Added function adfcrm_refnumber_by_redcard
--$
--$ Revision 1.12  2013/11/01 19:50:17  mmunoz
--$ CR26018 TF Surepay Family Plan
--$
--$ Revision 1.11  2013/10/31 13:10:04  mmunoz
--$ CR26018 TF Surepay Family Plan
--$
--$ Revision 1.10  2013/09/10 16:30:23  mmunoz
--$ CR24397
--$
--$ Revision 1.9  2013/09/07 20:36:30  mmunoz
--$ CR24715 Added function get_ESN_buckets_info
--$
--$ Revision 1.8  2013/08/27 20:41:16  mmunoz
--$ CR24397
--$
--$ Revision 1.7  2013/08/13 22:06:51  mmunoz
--$ CR24397
--$
--$ Revision 1.6  2013/08/10 00:46:49  mmunoz
--$ CR24397
--$
--$ Revision 1.5  2013/08/09 22:39:01  mmunoz
--$ CR24397
--$
--$ Revision 1.4  2013/08/08 22:12:53  mmunoz
--$ CR24397 Added sequence in record type
--$
--$ Revision 1.3  2013/07/30 22:29:33  mmunoz
--$ CR24397
--$
--$ Revision 1.2  2013/07/29 23:09:26  mmunoz
--$ Net10 Family Plan
--$
--------------------------------------------------------------------------------------------

  type esnTransactionDetail_rec is record
  (esn            sa.table_part_inst.part_serial_no%type,
   ref_number     sa.x_program_purch_hdr.x_merchant_ref_number%type,
   creditcard_id  sa.table_x_credit_card.objid%type,
   bankaccount_id  sa.table_x_bank_account.objid%type,
   price          number,
   discount       number,
   e911_tax       number,
   usf_tax        number,
   rcrf_tax       number,
   tax            number,
   total          number,
   ota_pending    varchar(30),
   part_class     sa.table_part_class.name%type,
   x_sequence     number,
   contact_email  sa.table_contact.e_mail%type,
   payment_type   varchar2(50),
   red_code       VARCHAR2(4000),  --SA.TABLE_X_RED_CARD.x_red_code%type
   item_desc      varchar2(4000),
   paid_until     date,  --Payment will be valid until this date
   quantity       number
  );

  TYPE esnTransactionDetail_tab IS TABLE OF esnTransactionDetail_rec;

  type esnServiceVO_rec is record
  (
  serial_number                varchar2(100),
  orig_act_date                date,
  x_min                        varchar2(100),
  line_status                varchar2(100),
  upgrade_flow                varchar2(100),
  hide_min                    varchar2(100),
  x_manufacturer            varchar2(100),
  offer_vas                    varchar2(100),
  offer_vas_script_text        clob,
  easy_exchange_script_name    varchar2(100),
  offer_E_Exch                varchar2(100),
  easy_exchange_script_text    varchar2(4000),
  trans_script                clob,
  autorefill                varchar2(100),
  service_plan_objid        number,
  service_plan                varchar2(4000),
  service_plan_script        varchar2(4000),
  plan_added_objid            varchar2(100),
  serv_plan_added_script     clob,  --CR53171 updated type
  broadband                    varchar2(100),
  service_end_date            date,
  rate_plan                    varchar2(400),
  first_name                varchar2(400),
  last_name                    varchar2(400),
  e_mail                    varchar2(400),
  org_id                    varchar2(400),
  contact_objid                number,
  show_billing                varchar2(100),
  show_item_bill            varchar2(100),
  show_granted                varchar2(100),
  show_service                varchar2(100),
  show_email_opt            varchar2(100),
  vas_header_script            varchar2(4000),
  vas_footer_script            varchar2(4000),
  vas_prg_script_text        varchar2(4000),
  vas_auto_pay              varchar2(10),
  vas_enroll_date           varchar2(100),
  vas_next_charge_date      varchar2(100),
  vas_enroll_price            varchar2(50)
  );

  TYPE esnServiceVO_tab IS TABLE OF esnServiceVO_rec;

  function getServiceVO (
    p_solution_name in varchar2,
    p_esn in varchar2,
    p_language in varchar2,
    p_purchase_id in varchar2,
    p_transaction_id in varchar2,
    p_case_id in varchar2,
    p_check_condition varchar2 default 'BOGO=NO'
    )
  return esnServiceVO_tab pipelined;

  function getEsnTransactionDetail(
    ip_esn in varchar2,
    ip_call in varchar2,
    ip_purchase in varchar2,
    ip_language in varchar2
  )
  RETURN esnTransactionDetail_tab pipelined;

  function get_ESN_contact_info(
    ip_esn in varchar2
  ) return adfcrm_esn_structure;

  function get_Service_Plan_Script(
    ip_objid             sa.x_service_plan.objid%type,
    ip_language          varchar2,
    ip_brand_name         varchar2
  ) return varchar2;

  function get_Service_Plan_Script(
    ip_objid             sa.x_service_plan.objid%type,
    ip_language          varchar2
  ) return varchar2;

  type esnBucketsDetail_rec is record
  (esn            sa.table_part_inst.part_serial_no%type,
   days           number,
   voice_units    number,
   sms_units      number,
   data_units     number,
   due_date       date
  );

  TYPE esnBucketsDetail_tab IS TABLE OF esnBucketsDetail_rec;

  function get_ESN_buckets_info(
      ip_solution in varchar2,
      ip_esn in varchar2,
      ip_call in varchar2,
      ip_purchase in varchar2
  ) return esnBucketsDetail_tab pipelined;

  function refnumber_by_redcard (
    ip_red_card sa.table_x_red_card.x_red_code%type
  ) return varchar2;

    function get_service_plan_added(
/*************** ************************************************
 ** Return the service plan objid added in the                 **
 ** purchase, redemption, enrollment                           **
 ****************************************************************/
    ip_purchase in varchar2  --X_PROGRAM_PURCH_HDR.x_merchant_ref_number or TABLE_X_RED_CARD.x_red_code
) return number;

  function get_service_plan_added(
/*************** ************************************************
 ** Return the service plan objid added in the                 **
 ** purchase, redemption, enrollment                           **
 ****************************************************************/
    ip_esn in varchar2,
    ip_call in varchar2,
    ip_purchase in varchar2  --X_PROGRAM_PURCH_HDR.x_merchant_ref_number or TABLE_X_RED_CARD.x_red_code
) return number;

  function get_others_added (ip_solution_name sa.adfcrm_solution.solution_name%type,
                             ip_esn sa.table_part_inst.part_serial_no%type,
                             ip_language varchar2,
                             ip_param_list varchar2,
                             ip_transaction_id varchar2)
/*************** ************************************************
 ** Return the service/program description added in the        **
 ** purchase, redemption, enrollment                           **
 ****************************************************************/
   return varchar2;

  function getEasyExchangeScriptName (
  /*************** ************************************************
  ** Return the solution name to get solution script that applies *
  ****************************************************************/
    ip_esn in varchar2,      --just one esn
    ip_purchase in varchar2  --comma separated values
    )
  return varchar2;

  function getVASservice (
  /*************** ************************************************
   ** Return the vas service name that is available for the esn  **
   ****************************************************************/
    ip_esn in varchar2)      --just one esn
  return varchar2;

  /*************** ************************************************
   ** Return the script for each ESN in the transaction  **
   ****************************************************************/
  function trans_script_group   (ip_solution_name in sa.adfcrm_solution.solution_name%type,
                                 ip_esn  in varchar2,
                                 ip_language  in varchar2,
                                 ip_purchase in  varchar2,
                                 ip_call_id in varchar2,
                                 ip_case_id  in varchar2,
                                 ip_action_type in varchar2,
                                 ip_check_condition varchar2 default 'BOGO=NO') return clob;

  ------------------------------------------------------------------------------
  type get_case_info_rec is record
   (objid number,
    title_label varchar2(300),
    id_number varchar2(255),
    service_plan_id varchar2(200),
    service_plan varchar2(200),
    minutes number,
    data_units number,
    sms_units number,
    days number,
    s_title sa.table_case.s_title%type,
    case_address varchar2(400),
    esn varchar2(50),
	current_esn varchar2(50)
    );

  type get_case_info_tab is table of get_case_info_rec;

  function get_case_info (ip_case_id in varchar2)
  return get_case_info_tab pipelined;
  ------------------------------------------------------------------------------
END;
/