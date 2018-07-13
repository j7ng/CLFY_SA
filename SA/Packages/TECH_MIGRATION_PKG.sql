CREATE OR REPLACE package sa.tech_migration_pkg as
  procedure create_campaign(ip_CAMPAIGN_NAME varchar2,
                            ip_campaign_description varchar2,
                            ip_alert_title varchar2,
                            ip_script_id varchar2,
                            ip_channels_to_display varchar2,
                            ip_alert_severity varchar2,
                            ip_case_type varchar2,
                            ip_case_title varchar2,
                            ip_repl_part_number varchar2,
                            ip_related_phone_statuses varchar2,
                            ip_related_cr varchar2,
                            ip_requestor varchar2,
                            ip_campaign_expiration_date number,
                            op_error_msg out varchar2,
                            op_error_num out varchar2);

  procedure campaign_alerts(esn            varchar2,
                            search_types   varchar2, -- NEW REQUIREMENT
                            step           number,
                            channel        varchar2,     -- Channel to display flash
                            title          out varchar2, -- Alert Title
                            CSR_TEXT       OUT VARCHAR2, -- Text to be used in WEBCSR
                            eng_text       out varchar2, -- Web Text English
                            SPA_TEXT       OUT VARCHAR2, -- Web Text Spanish
                            ivr_scr_id     out varchar2, -- IVR script ID
                            tts_english    OUT varchar2, -- Text to Speech English
                            tts_spanish    out varchar2, -- Text to Speech Spanish
                            HOT            OUT VARCHAR2, -- 0 Let customer continue, 1 Transfer
                            err            out varchar2, -- Error Number
                            op_msg         out varchar2, -- Additional Messages
                            OP_URL         OUT VARCHAR2,
                            op_url_text_en out varchar2,
                            op_url_text_es out varchar2,
                            op_sms_text    out varchar2,
                            op_bus_org     out varchar2,
                            op_case_action out varchar2,
                            op_case_type   out varchar2,
                            op_case_title  out varchar2,
                            op_case_hdr_objid  out varchar2,
                            op_case_repl_pn out varchar2,
                            OP_CAMPAIGN_MIGRATION out varchar2);

  function get_esn (ip_short_serial varchar2, ip_min varchar2)
  return varchar2;

  procedure get_device_info(p_esn varchar2,
                            p_min varchar2,
                            op_code_number out varchar2,
                            op_phone_gen out varchar2,
                            op_brand out varchar2,
                            op_queue_name out varchar2,
                            op_part_class out varchar2,
                            op_zipcode out varchar2);

  function flash_action (ip_esn varchar2,
                         ip_status varchar2,
                         ip_carrier varchar2,
                         ip_part_class varchar2)
  return varchar2;

  function is_beyond_eco_repair(ip_code_number varchar2)
  return varchar2;

  function has_a_warehouse_case(ip_esn varchar2,ip_flash_start_date date default null)
  return varchar2;

  procedure eligibility_validations(p_min varchar2, p_esn varchar2, op_rslt out boolean, op_err_msg out varchar2, op_err_num out varchar2);

  procedure VERIFY_ELEGIBILITY(
                                p_source_system  in   varchar2,
                                p_login_name     in   varchar2,
                                p_language       in   varchar2,
                                p_esn            in   varchar2,
                                p_min            in   varchar2,
                                p_zipcode        out varchar2,
                                p_result         out varchar2, -- (UPGRADE,PURCHASE,UPG_PURCH,NOT_ELEGIBLE)
                                P_purchase_link  out varchar2, --(If applicable)
                                p_ticket_id      out varchar2,  --(If already created)
                                p_brand          out varchar2,
                                p_err_code       out varchar2,
                                p_err_msg        out varchar2);

  procedure CREATE_REQUEST( p_source_system  in varchar2 DEFAULT 'TAS',
                            p_login_name     in varchar2 DEFAULT 'CBO',
                            p_language       in   varchar2,
                            p_esn            in   varchar2,
                            p_min            in   varchar2,
                            p_first_name in varchar2,
                            p_last_name in varchar2,
                            p_address_1 in varchar2,
                            p_address_2 in varchar2,
                            p_city in varchar2,
                            p_state in varchar2,
                            p_zipcode in varchar2,
                            p_email in varchar2,
                            p_contact_phone in varchar2,
                            p_units_to_transfer in varchar2,
                            p_call_trans_objid in varchar2,  -- OBJID OTA Balance Inquiry
                            p_ticket_id out varchar2,
                            p_err_code out varchar2,
                            p_err_msg  out varchar2);

  function add_case_dtl_records (p_case_id in varchar2)
  return varchar2;

end  TECH_MIGRATION_PKG;
/