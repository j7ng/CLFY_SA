CREATE OR REPLACE package sa.ubi_pkg
as
/*******************************************************************************************************
 --$RCSfile: ubi_package_spec.sql,v $
 --$Revision: 1.1 $
 --$Author: Hcampano $
 --$Date: 2017/12/19 21:43:40 $
 --$ $Log: ubi_package_spec.sql,v $
 --$ Revision 1.1  2017/12/19 21:43:40  Hcampano
 --$ Initial version
 --$
  * Description: New Package for procedures related to Universal Balance Inquiry
 * -----------------------------------------------------------------------------------------------------
 *******************************************************************************************************/
  function get_thresh(ip_get_esn varchar2)
  return varchar2;

  function get_addon_thresh(ip_get_esn varchar2)
  return varchar2;

  type pgm_info_rec is record
  (
    pgm_key             varchar2(30),
    pgm_value           varchar2(4000)
  );

  type pgm_info_tbl is table of pgm_info_rec;

  function get_pgm_info(ipgm_esn varchar2)
  return pgm_info_tbl pipelined;

  type return_bucket_bal_obj is record
  (
    objid                   number,
    balance_bucket2x_swb_tx number,
    x_type                  varchar2(80),
    x_value                 varchar2(80),
    recharge_date           date,
    expiration_date         date,
    bucket_desc             varchar2(80),
    bucket_group            varchar2(50)
   );

   type return_bucket_bal_tbl is table of return_bucket_bal_obj;

  procedure ret_min_and_obj(ip_rmao_esn varchar2, op_rmao_min out varchar2, op_rmao_objid out number);

  function convert_value(unit_value varchar2,convert_from varchar2,convert_to varchar2)
  return number;

  function convert_value(unit_value varchar2,convert_from varchar2,convert_to varchar2,another_param varchar2)
  return varchar2;

  function get_ubi_transaction_objid (ubi_to_esn varchar2)
  return number;

  type mtg_info_rec is record
  (
    ubi_objid number,
    mtg_src_val varchar2(50),
    mtg_src varchar2(50),
    config_id number,
    daily_attempts_threshold number,
    timeout_minutes_threshold number,
    attempts_made_today number,
    mtg_action varchar2(1000),
    max_call varchar2(1000) -- NEW USED TO DETERMINE THE TYPE OF MAX CALL OR FALLBACK MAX CALL
    --mtg_rslt varchar2(1000)
  );

  type mtg_info_tab is table of mtg_info_rec;

  function get_metering_info(ip_esn varchar2,ip_source_system varchar2)
  return mtg_info_tab pipelined;

  type brt_rec is record
  (
    balance_action varchar2(100),
    items_list varchar2(4000)
    --brt_items_list varchar2(1000)

  );

  type brt_tab is table of brt_rec;

  function get_balance_request_type(ip_esn varchar2,
                                    ip_source_system varchar2,
                                    ip_config_id_override number default null,
                                    --ip_mtg_src_override varchar2 default null,
                                    --ip_mtg_src_additional varchar2 default null,
                                    ip_external_request_override varchar2 default null
                                    )
  return brt_tab pipelined;

  procedure get_balance_request_type( i_esn                        in  varchar2,
                                      i_source_system              in  varchar2,
                                      i_config_id_override         in  number    default null,
                                      i_external_request_override  in  varchar2  default null,
                                      o_balance_request_rc         out sys_refcursor,
                                      o_err_num                    out number ,
                                      o_err_msg                    out varchar2 );

  type balance_and_usage_info_rec is record
  (
    balance_ele               varchar2(80),
    balance_ele_value         varchar2(4000), -- This value should not be more than 300, but a script can pass through (balance_ele_value,display_value) must be the same size
    balance_ele_measure_unit  varchar2(80)
  );

  type balance_and_usage_info_tab is table of balance_and_usage_info_rec;

  function get_balance_and_usage(ip_esn varchar2, ip_balance_action_list varchar2)
  return balance_and_usage_info_tab pipelined;

  function get_configured_ubi(ip_gcu_esn varchar2, ip_gcu_balance_action_list varchar2)
  return balance_and_usage_info_tab pipelined;
  --
  PROCEDURE get_configured_ubi( i_gcu_esn                   IN  VARCHAR2,
                                i_gcu_balance_action_list   IN  VARCHAR2,
                                o_configured_ubi_rc         OUT sys_refcursor,
                                o_err_num                   OUT NUMBER ,
                                o_err_msg                   OUT VARCHAR2 );
  --
  procedure ret_cos_and_threshold(ip_cat_esn varchar2, op_rate_plan out varchar2, op_cos out varchar2,op_threshold out varchar2);

  type balance_inq_page_elements_rec is record
  (
    ele_order         varchar2(100), -- CHANGE THESE TO THE APPROPRIATE SIZE
    mtg_short_name    varchar2(100), -- CHANGE THESE TO THE APPROPRIATE SIZE
    config_objid      varchar2(100), -- CHANGE THESE TO THE APPROPRIATE SIZE
    balance_element   varchar2(100), -- CHANGE THESE TO THE APPROPRIATE SIZE
    html_type         varchar2(100), -- CHANGE THESE TO THE APPROPRIATE SIZE
    html_label        varchar2(4000), -- CHANGE THESE TO THE APPROPRIATE SIZE
    source_system     varchar2(30), -- CHANGE THESE TO THE APPROPRIATE SIZE
    --value_action      varchar2(4000), -- CHANGE THESE TO THE APPROPRIATE SIZE
    display_row       varchar2(30),
    display_col       varchar2(30),
    display_unit      varchar2(30),
    balance_ele_value varchar2(4000), -- This value should not be more than 300, but a script can pass through (balance_ele_value,display_value) must be the same size
    display_value     varchar2(4000), -- This value should not be more than 300, but a script can pass through (balance_ele_value,display_value) must be the same size
    balance_ele_measure_unit varchar2(30),
    overwrite_val_with       varchar2(30),
    label_width       varchar2(30), -- NEW TO DETERMINE THE LABEL WIDTH
    field_width       varchar2(30) -- NEW TO DETERMINE THE FIELD WIDTH
  );

  type balance_inq_page_elements_tab is table of balance_inq_page_elements_rec;

  function balance_inq_page_elements(ip_esn varchar2, ip_language varchar2, ip_source_system varchar2, ip_balance_action_list varchar2)
  return balance_inq_page_elements_tab pipelined;

  function balance_inq_rslt(ip_esn varchar2, ip_language varchar2, ip_source_system varchar2, ip_balance_action_list varchar2)
  return balance_inq_page_elements_tab pipelined;

  type get_balance_buckets_rec is record
  (
    objid                   number,
    balance_bucket2x_swb_tx number,
    x_type                  varchar2(80),
    x_value                 varchar2(80),
    recharge_date           date,
    expiration_date         date,
    bucket_desc             varchar2(80),
    bucket_group            varchar2(50)
  );

  type get_balance_buckets_tab is table of get_balance_buckets_rec;

  function get_balance_buckets_rslt(ip_trans_id varchar2)
  return get_balance_buckets_tab pipelined;

  type simple_bucket_id_list_rec is record
  (
    bucket_id 		    varchar2(100)
  );

  type simple_bucket_id_list_tab is table of simple_bucket_id_list_rec;

  function skip_bucket_ids_rslt(ip_trans_id varchar2)
  return simple_bucket_id_list_tab pipelined;

  -- LOGIC TAKEN FROM ADFCRM_SAFELINK TO AVOID HAVING SOA DEPENDANCY ON TAS OBJECTS - TODO: CONSULT W/NATALIO
  function is_still_safelink (ip_esn varchar2, ip_org_id varchar2)
  return varchar2;

  function is_phone_safelink (ip_esn varchar2)
  return varchar2;

  FUNCTION is_past_safelink_enrolled(ip_esn varchar2)
  return varchar2;
  -- LOGIC TAKEN FROM ADFCRM_SAFELINK TO AVOID HAVING SOA DEPENDANCY ON TAS OBJECTS - TODO: CONSULT W/NATALIO

  type get_bi_trans_id_rec is record
  (
    mtg_src	                varchar2(50),
    mtg_type	              varchar2(50),
    trans_id	              varchar2(50),
    trans_date              date
  );

  type get_bi_trans_id_tab is table of get_bi_trans_id_rec;

  function get_bi_trans_id_rslt(ip_trans_id varchar2)
  return get_bi_trans_id_tab pipelined;

  function get_generic_script  (ip_script_type varchar2,
                                ip_script_id varchar2,
                                ip_language varchar2,
                                ip_sourcesystem  varchar2,
                                ip_brand varchar2,
                                ip_pc varchar2)
  return varchar2;
  --
  PROCEDURE create_ubi_transaction( i_esn                 IN    VARCHAR2,
                                    i_min                 IN    VARCHAR2,
                                    i_action_text         IN    VARCHAR2, -- 'PERSGENCODE'
                                    i_source_system       IN    VARCHAR2,
                                    i_reason              IN    VARCHAR2, -- 'Balance Inquiry'
                                    i_action_type         IN    VARCHAR2, -- 7
                                    i_rsid                IN    VARCHAR2, -- 5050
                                    i_swb_status          IN    VARCHAR2, -- 'CarrierPending'
                                    i_swb_order_type      IN    VARCHAR2, -- BI
                                    i_x_value             IN    VARCHAR2, -- 0
                                    i_ig_order_type       IN    VARCHAR2, -- 'Balance Inquiry'
                                    i_pcrf_order_type     IN    VARCHAR2, -- 'BI'
                                    i_pcrf_status_code    IN    VARCHAR2, -- 'Q'
                                    o_err_code            OUT   VARCHAR2,
                                    o_err_msg             OUT   VARCHAR2
                                  );
end ubi_pkg;
/