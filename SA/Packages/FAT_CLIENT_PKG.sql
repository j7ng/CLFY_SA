CREATE OR REPLACE PACKAGE sa."FAT_CLIENT_PKG" as
procedure lm_show_technology
                       (p_in_min in varchar2,
                        p_out_ph_tech out varchar2,
                        p_out_carr_tech out varchar2,
                        p_out_msg out varchar2);
procedure lm_get_status_list
                       (p_in_codeType in varchar2,
                        status_list out sys_refcursor);
procedure lm_get_carrier_name_list
                       (carrier_name_list out sys_refcursor );
procedure get_state_list
                       (op_state_list out sys_refcursor );

type carr_dtl_list_ty is record(carrier_objid number,
                                x_carrier_id table_x_carrier.x_carrier_id%type,
                                x_mkt_submkt_name table_x_carrier.x_mkt_submkt_name%type,
                                x_city table_x_carrier.x_city%type,
                                x_state table_x_carrier.x_state%type,
                                x_carrier_name table_x_carrier_group.x_carrier_name%type,
                                exp_date  varchar2(30));
type carr_dtl_list_tab_ty is table of carr_dtl_list_ty;

function lm_get_carrier_detail_list(ip_carr_id varchar2,
                        ip_carr_name varchar2,
                        ip_carr_mkt varchar2)
return carr_dtl_list_tab_ty pipelined;

procedure lm_get_carrier_detail_list
                       (ip_carr_id varchar2,
                        ip_carr_name varchar2,
                        ip_carr_mkt varchar2,
                        carrier_dtl_list out sys_refcursor );

type lm_get_accounts_ty is record (objid table_x_account.objid%type,
                                   x_acct_num table_x_account.x_acct_num%type);

type lm_get_accounts_tab_ty is table of lm_get_accounts_ty;

function lm_get_accounts (ip_carr_id in number)
return lm_get_accounts_tab_ty pipelined;

procedure lm_get_accounts
                       (ip_carr_id in number,
                        account_list out sys_refcursor) ;

type lm_get_lines_ty is record(line_objid        table_part_inst.objid%type,
                               x_carrier_id      table_x_carrier.x_carrier_id%type,
                               npa               table_part_inst.x_npa%type,
                               nxx               table_part_inst.x_nxx%type,
                               ext               table_part_inst.x_ext%type,
                               msid              table_part_inst.x_msid%type,
                               min               table_part_inst.x_msid%type,
                               x_status          table_x_code_table.x_code_name%type,
                               x_carrier_name table_x_carrier_group.x_carrier_name%type,
                               x_mkt_submkt_name table_x_carrier.x_mkt_submkt_name%type,
                               exp_date  varchar2(30),
                               pi_sts            table_part_inst.x_part_inst_status%type);

type lm_get_lines_tab_ty is table of lm_get_lines_ty;

function lm_get_lines(ip_cool_edate in number,
                        ip_carr_id varchar2,
                        ip_carr_name varchar2,
                        ip_mkt_submkt_name varchar2,
                        ip_status varchar2,
                        ip_npa_start varchar2,
                        ip_npa_end varchar2,
                        ip_nxx_start varchar2,
                        ip_nxx_end varchar2,
                        ip_ext_start varchar2,
                        ip_ext_end varchar2)
return lm_get_lines_tab_ty pipelined;

procedure lm_get_lines (ip_cool_edate in number,
                        ip_carr_id varchar2,
                        ip_carr_name varchar2,
                        ip_mkt_submkt_name varchar2,
                        ip_status varchar2,
                        ip_npa_start varchar2,
                        ip_npa_end varchar2,
                        ip_nxx_start varchar2,
                        ip_nxx_end varchar2,
                        ip_ext_start varchar2,
                        ip_ext_end varchar2,
                        line_list out sys_refcursor);

procedure lm_change_msid
                       (ip_user_objid in number,
                        ip_pi_objid in varchar2,
                        ip_new_msid in varchar2,
                        ip_second_call in varchar2,
                        op_result out varchar2 );

type lm_get_deact_reason_ty is record(x_code_number table_x_code_table.x_code_number%type,
                                      x_code_name table_x_code_table.x_code_name%type);

type lm_get_deact_reason_tab_ty is table of lm_get_deact_reason_ty;


function lm_get_deact_reason(ip_privclass_objid in number,
                             ip_codeType in varchar2)
return lm_get_deact_reason_tab_ty pipelined;

-- OVERLOAD --------------------------------------------------------------------
function lm_get_deact_reason(ip_privclass_name in varchar2,
                             ip_codeType in varchar2)
return lm_get_deact_reason_tab_ty pipelined;

procedure lm_get_deact_reason
                       (ip_privclass_objid in number,
                        ip_codeType in varchar2,
                        deact_reason_list out sys_refcursor);
-- OVERLOAD --------------------------------------------------------------------
procedure lm_get_deact_reason
                       (ip_privclass_name in varchar2,
                        ip_codeType in varchar2,
                        deact_reason_list out sys_refcursor);

procedure lm_deactivate_lines
                       (ip_pi_objid_list in varchar2,
                        ip_user_objid in number,
                        ip_deact_reason in varchar2,
                        ip_create_action_item in varchar2,
                        op_ret out varchar2,
                        op_retmsg out varchar2);
procedure lm_extend_exp_date
                       (ip_pi_objid_list in varchar2,
                        ip_user_objid in number,
                        ip_exp_date in date,
                        result out varchar2);
procedure lm_return_to_carrier
                       (ip_user_objid in number,
                        ip_pi_objid_list in varchar2,
                        op_result out varchar2) ;
procedure lm_hold_lines(ip_user_objid in number,
                        ip_pi_objid_list in varchar2,
                        op_result out varchar2);
procedure lm_delete_lines
                       (ip_user_objid in number,
                        ip_pi_objid_list in varchar2,
                        op_result out varchar2 );
procedure lm_set_lines_ntn
                       (ip_user_objid in number,
                        ip_pi_objid_list in varchar2,
                        op_result out varchar2 );
procedure lm_add_lines (ip_user_objid number,
                        ip_carr_id varchar2,
                        ip_account_num varchar2,
                        ip_npa varchar2,
                        ip_nxx varchar2,
                        ip_from_ext varchar2,
                        ip_to_ext varchar2,
                        ip_exp_date varchar2,
                        ip_msid varchar2,
                        op_msg out varchar2);
procedure lm_area_code_change
                       (ip_grid_lines_cbox  number,
                        ip_change_ac_cbox number,
                        ip_serial_no_list in varchar2,
                        ip_user_objid in number,
                        ip_old_area_code in varchar2,
                        ip_old_nxx in varchar2,
                        ip_new_area_code in varchar2,
                        op_result out varchar2);
procedure lm_release_lines
                       (ip_user_objid in number,
                        ip_pi_objid_list varchar2,
                        op_result out varchar2);
procedure lm_change_carrier_id
                       (ip_pi_objid_list in varchar2,
                        ip_new_carr_id in number,
                        ip_user_objid in number,
                        op_msg out varchar2);
procedure cops_search  (ip_carr_name in varchar2,
                        ip_carr_group_id in varchar2,
                        ip_mkt_submkt_name in varchar2,
                        ip_carr_id in varchar2,
                        ip_state in varchar2,
                        ip_city in varchar2,
                        ip_parent_x_parent_name in varchar2,
                        ip_parent_x_parent_id in varchar2,
                        ip_include_inactive  in number,
                        op_carr_list out sys_refcursor);
procedure cops_carr_group_search
                       (ip_carr_name in varchar2,
                        ip_carr_group_id in varchar2,
                        op_carr_group_list out sys_refcursor);
procedure cops_search_detail
                       (ip_carr_name in varchar2,
                        ip_carr_group_id in varchar2,
                        ip_mkt_submkt_name in varchar2,
                        ip_carr_id in varchar2,
                        ip_state in varchar2,
                        ip_city in varchar2,
                        ip_parent_x_parent_name in varchar2,
                        ip_parent_x_parent_id in varchar2,
                        ip_include_inactive  in number,
                        op_carr_list out sys_refcursor);
procedure create_new_parent
                       (ip_parent_name in varchar2,
                        ip_psms_address in varchar2,
                        op_parent_id out varchar2);
procedure cops_search_parent
                       (ip_parent_id in varchar2,
                        ip_parent_name in varchar2,
                        op_parent_list out sys_refcursor);
procedure cops_edit_parent
                       (ip_parent_id in number,
                        ip_parent_name in varchar2,
                        ip_vm_access_num in varchar2,
                        ip_ota_psms_address in varchar2,
                        ip_status in number,
                        ip_no_msid in number,
                        ip_auto_port_in in number,
                        ip_ota_active in number,
                        ip_no_inventory in number,
                        ip_auto_port_out in number);
procedure cops_get_hq_address
                       (ip_carr_group_id varchar2,
                        op_carr_hq_address out sys_refcursor);
procedure cops_add_carrier_group(ip_address in out varchar2,
                           ip_address2 in out varchar2,
                           ip_city in out varchar2,
                           ip_state in out varchar2,
                           ip_zip   in out varchar2,
                           ip_hq_address in varchar2,
                           ip_hq_address2 in varchar2,
                           ip_hq_city in varchar2,
                           ip_hq_state in varchar2,
                           ip_hq_zip in varchar2,
                           ip_parent_id in varchar2,
                           ip_carr_group_objid in varchar2,
                           ip_mkt_submkt_name in varchar2, -- carr desc name
                           ip_carr_id in varchar2,
                           ip_carr_city in varchar2,
                           ip_carr_state in varchar2,
                           ip_mkt_type in varchar2,
                           ip_submkt_of in varchar2,
                           op_msg out varchar2);
procedure cops_display_ai_list
                       (ip_parent_id in number,
                        op_ai_list out sys_refcursor,
                        op_blocked_ai_list out sys_refcursor);
procedure cops_handle_ai
                       (ip_action in varchar2,
                        ip_parent_id in number,
                        ip_user_id in number,
                        ip_code_number in number,
                        ip_code_name in varchar2,
                        op_out_msg out varchar2 );
procedure cops_get_order_types
                       (ip_carr_objid in number,
                        ip_order_type in varchar2,
                        ip_npa in varchar2,
                        ip_nxx in varchar2,
                        ip_bill_cycle in varchar2,
                        ip_dealer_code in varchar2,
                        ip_account_num in varchar2,
                        op_order_type_list out sys_refcursor );
procedure cops_add_lines_useDOTM
                       (ip_carr_objid in number,
                        ip_npa in varchar2,
                        ip_nxx in varchar2,
                        ip_action in varchar2 default 'QUERY',
                        op_npa_nxx_list out sys_refcursor) ;
procedure cops_get_trans_profile
                       (ip_profile_name in varchar2,
                        ip_trans_method in varchar2,
                        ip_trans_desc in varchar2,
                        ip_prof_objid in varchar2 default null,
                        ip_del_flag in varchar2 default 'A',
                        op_profile_list out sys_refcursor) ;
procedure cops_get_tp_markets
                       (ip_prof_objid in number,
                        ip_mkt_list out sys_refcursor);
procedure cops_get_default_messages
                       (default_msg_list out sys_refcursor);
procedure cops_get_act_msg
                       (ip_carr_id in varchar2,
                        op_msg_list out sys_refcursor,
                        ip_action in varchar2 default 'QRY',
                        ip_msg_objid in number default null,
                        ip_msg_text in varchar2 default null);
procedure cops_add_act_msg
                       (ip_carr_id in varchar2,
                        ip_method in varchar2,
                        ip_msg_text in varchar2 );
procedure cops_fcc_markets
                       (ip_carr_id in varchar2,
                        op_fcc_mkt_list out sys_refcursor);
procedure cops_bta_markets
                       (ip_carr_id in varchar2,
                        op_bta_mkt_list out sys_refcursor);
procedure cops_carrier_accts
                       (ip_carr_id in varchar2,
                        op_acct_list out sys_refcursor,
                        op_msg_out out varchar2,
                        ip_action in varchar2 default 'QUERY',
                        ip_acct_num in varchar2 default null,
                        ip_new_acct_num in varchar2 default null,
                        ip_active in varchar2 default null);
procedure cops_add_upd_trans_profile
    (ip_objid number,ip_transmit_method varchar2,ip_exception varchar2,
    ip_fax_number varchar2,ip_online_number varchar2,ip_network_login varchar2,
    ip_network_password varchar2,ip_system_login varchar2,ip_system_password varchar2,
    ip_template varchar2,ip_email varchar2,ip_profile_name varchar2,
    ip_default_queue varchar2,ip_carrier_phone varchar2,ip_exception_queue varchar2,
    ip_batch_quantity varchar2,ip_batch_delay_max varchar2,ip_transmit_template varchar2,
    ip_online_num2 varchar2,ip_fax_num2 varchar2,ip_description varchar2,
    ip_ici_system varchar2,ip_analog_deact varchar2,ip_analog_rework varchar2,
    ip_digital_act varchar2,ip_digital_deact varchar2,ip_digital_rework varchar2,
    ip_upgrade varchar2,ip_d_transmit_method varchar2,ip_d_fax_number varchar2,
    ip_d_online_number varchar2,ip_d_network_login varchar2,ip_d_network_password varchar2,
    ip_d_system_login varchar2,ip_d_system_password varchar2,ip_d_template varchar2,
    ip_d_email varchar2,ip_d_carrier_phone varchar2,ip_d_batch_quantity varchar2,
    ip_d_batch_delay_max varchar2,ip_d_trans_template varchar2,ip_d_online_num2 varchar2,
    ip_d_fax_num2 varchar2,ip_d_ici_system varchar2,ip_gsm_act varchar2,
    ip_gsm_deact varchar2,ip_gsm_rework varchar2,ip_gsm_ici_system varchar2,
    ip_gsm_transmit_method varchar2,ip_gsm_trans_template varchar2,ip_gsm_carrier_phone varchar2,
    ip_gsm_fax_number varchar2,ip_gsm_online_number varchar2,ip_gsm_fax_num2 varchar2,
    ip_gsm_online_num2 varchar2,ip_gsm_network_password varchar2,ip_gsm_batch_quantity varchar2,
    ip_gsm_network_login varchar2,ip_gsm_batch_delay_max varchar2,ip_gsm_email varchar2,
    ip_sui_analog varchar2,ip_sui_digital varchar2,ip_sui_gsm varchar2,
    ip_timeout_analog varchar2,ip_timeout_digital varchar2,ip_timeout_gsm varchar2,
    ip_debug_analog varchar2,ip_debug_digital varchar2,ip_debug_gsm varchar2,
    ip_int_port_in_rework varchar2,ip_trans_profile2wk_work_hr varchar2,
    ip_d_trans_profile2wk_work_hr varchar2) ;
procedure cops_get_carrier_group (ip_carr_group_id in varchar2,
                                  ip_carr_id in varchar2,
                                  op_carr_group_rec out sys_refcursor);
procedure cops_upd_carrier_group (ip_parent_id in varchar2 default null,
                            ip_carr_group_id in varchar2 default null,
                            ip_group_status in number default null,
                            ip_hq_add_objid in varchar2 default null,
                            ip_hq_add1 in varchar2 default null,
                            ip_hq_add2 in varchar2 default null,
                            ip_hq_city in varchar2 default null,
                            ip_hq_state in varchar2 default null,
                            ip_hq_zip in varchar2 default null,
                            ip_carr_objid in varchar2 default null,
                            ip_mkt_submkt_name in varchar2 default null,
                            ip_carr_id in varchar2 default null,
                            ip_carr_city in varchar2 default null,
                            ip_carr_state in varchar2 default null,
                            ip_carr_status in varchar2 default null,--0 or 1
                            ip_special_mkt in varchar2 default null,
                            ip_add_objid in varchar2 default null,
                            ip_add1 in varchar2 default null,
                            ip_add2 in varchar2 default null,
                            ip_city in varchar2 default null,
                            ip_state in varchar2 default null,
                            ip_zipcode in varchar2 default null) ;


procedure cops_get_carrier_scripts( ip_carr_objid in varchar2,
                                ip_sourcesystem in varchar2,
                                ip_script_type in varchar2,
                                ip_script_id in varchar2,
                                ip_script_description in varchar2,
                                ip_language in varchar2,
                                ip_get_what in varchar2,
                                op_carr_scr_list out sys_refcursor) ;
procedure cops_get_carrier_profile( ip_carr_id in varchar2,
                              ip_technology in varchar2 ,
                              op_rules out sys_refcursor,
                              op_msg_out out varchar2);
procedure cops_action_item_maintenace(ip_carr_name in varchar2,
                            ip_carr_mkt in varchar2,
                            ip_esn in varchar2,
                            ip_task_id in varchar2,
                            ip_trans_method in varchar2,
                            ip_status in varchar2,
                            ip_queue_name in varchar2,
                            ip_condition in varchar2,
                            ip_order_type in varchar2,
                            ip_task_cdate in varchar2,
                            ip_task_cd_operator in varchar2 default '>',
                            ip_sort_by  varchar2,
                            op_ai_list out sys_refcursor );
procedure cops_save_carrier_profile( ip_carr_id in varchar2,
                              ip_act_technology in varchar2,
                              ip_act_analog in number,
                              ip_react_technology in varchar2,
                              ip_react_analog in number,
                              ip_automated in number,
                              ip_ld_provider in varchar2 ,
                              ip_ld_account in varchar2 ,
                              ip_ld_pic_code in varchar2 ,
                              ip_activeline_percent in varchar2 ,
                              ip_technology in varchar2 ,
                              ip_cooling_period in varchar2 ,
                              ip_cooling_after_insert in varchar2,
                              ip_used_line_expire_days in number,
                              ip_line_expire_days in number,
                              ip_gsm_grace_period in number,
                              ip_npa_nxx_flag in number,
                              ip_reserve_on_suspend in number,
                              ip_reserve_period in number,
                              ip_deac_after_grace in number,
                              ip_prl_preload in number,
                              ip_esn_change_flag in number,
                              ip_line_return_days in number,
                              ip_cancel_suspend in number,
                              ip_cancel_suspend_days in number,
                              op_msg out varchar2);

procedure cops_add_pref_tech(ip_technology in varchar2,
                             ip_frequency in varchar2,
                             ip_carr_id in varchar2,
                             ip_action in varchar2,
                             op_msg out varchar2);

procedure cops_get_list(which_list in varchar2,
                        op_list out sys_refcursor );
procedure cops_get_soc_id_list
                       (op_soc_id_list out sys_refcursor );
procedure cops_get_queue_list
                       (op_queue_list out sys_refcursor );
procedure cops_action_item_status_list
                       (op_ai_status_list out sys_refcursor );
procedure cops_process_action_item(aii_list in varchar2,
                                   ip_action in varchar2,
                                   ip_new_trans_method in varchar2,
                                   out_msg out varchar2 );
procedure cops_process_carrierdealer(ip_action in varchar2,
                                     ip_carr_id in varchar2,
                                     ip_dealer_id in varchar2,
                                     op_message out varchar2,
                                     op_dealer_list out sys_refcursor) ;
procedure cops_process_carrierpref(ip_action in varchar2,
                                   ip_pref_carr_id in varchar2,
                                   ip_sec_carr_id in varchar2,
                                   op_message out varchar2,
                                   op_pref_carr_list out sys_refcursor);
end fat_client_pkg;
/