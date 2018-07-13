CREATE OR REPLACE PACKAGE sa."APEX_TKTNG_APP_PKG"
is
  procedure ins_trig (ip_star_rank number,
                      ip_auto_carrier number,
                      ip_hours2escalate number,
                      ip_prev_case_count number,
                      ip_prev_case_days number,
                      ip_re_open_count number,
                      ip_tat_hours number,
                      ip_ec_objid number,
                      op_msg_out out varchar2);

  procedure upd_trig (ip_objid number,
                      ip_hours2escalate number,
                      ip_prev_case_count number,
                      ip_prev_case_days number,
                      ip_re_open_count number,
                      ip_tat_hours number,
                      op_msg_out out varchar2);

  procedure del_trig (ip_objid number,
                      op_msg_out out varchar2);

  function config_check (ip_h_objid number,
                         ip_p_objid number,
                         ip_carrier_val number,
                         op_ec_objid out number) return boolean;

  procedure ins_conf (ip_objid number,
                      ip_hot_transfer number,
                      ip_script_id_hot varchar2,
                      ip_script_id_cold varchar2,
                      ip_script_id_grace varchar2,
                      ip_eval_escalation number,
                      ip_escal2conf_hdr number,
                      ip_from_prty2gbst_elm number,
                      ip_to_prty2gbst_elm number,
                      op_msg_out out varchar2);

  procedure upd_conf (ip_objid number,
                      ip_hot_transfer number,
                      ip_script_id_hot varchar2,
                      ip_script_id_cold varchar2,
                      ip_script_id_grace varchar2,
                      ip_eval_escalation number,
                      op_msg_out out varchar2);

  procedure del_conf (ip_objid number,
                      op_msg_out out varchar2);

  procedure ins_disp(ip_hdr_id number,
                     ip_s_id number,
                     ip_p_id number,
                     ip_q_id number,
                     op_msg_out out varchar2);

  procedure upd_disp(ip_objid number,
                     ip_dispatch2conf_hdr number,
                     ip_status2gbst_elm number,
                     ip_priority2gbst_elm number,
                     ip_dispatch2queue number,
                     op_msg_out out varchar2);

  procedure del_disp(ip_objid number,
                     op_msg_out out varchar2);

  procedure ins_single_or_bulk_trig(ip_hdr_id number,
                                   ip_auto_carrier varchar2,
                                   ip_star_rank varchar2,
                                   ip_priority number,
                                   ip_hours2escalate  number,
                                   ip_prev_case_count  number,
                                   ip_prev_case_days  number,
                                   ip_re_open_count  number,
                                   ip_tat_hours  number,
                                   op_msg_out out varchar2);

  procedure unassign_att(ip_objid number,
                         op_msg_out out varchar2);

  procedure assign_att(p_h_objid in number,
                       p_d_objid in number,
                       op_msg_out out varchar2);

  procedure upd_assigned_att (ip_objid number,
                              ip_mandatory number,
                              ip_order number,
                              ip_legacy_rule varchar2,
                              ip_legacy_name varchar2,
                              ip_read_only number,
                              op_msg_out out varchar2);

  procedure ins_att(p_objid number,
                    p_prompt varchar2,
                    p_field_name varchar2,
                    p_data_type varchar2,
                    p_format varchar2,
                    p_min_value number,
                    p_max_value number,
                    op_msg_out out varchar2);

  procedure upd_att(p_objid number,
                    p_prompt varchar2,
                    p_field_name varchar2,
                    p_data_type varchar2,
                    p_format varchar2,
                    p_min_value number,
                    p_max_value number,
                    op_msg_out out varchar2);

  procedure del_att(p_objid number,
                    op_msg_out out varchar2);

  procedure assign_int(p_objid number,
                       p_status varchar2,
                       p_action varchar2,
                       p_active number,
                       p_h_id number,
                       op_msg_out out varchar2);

  procedure unassign_int(p_objid number,
                         op_msg_out out varchar2);

  procedure ins_conf_hdr (ip_objid number,
                          ip_display_title varchar2,
                          ip_case_type varchar2,
                          ip_title varchar2,
                          ip_service number,
                          ip_avail_lhs_menu number,
                          ip_block_reopen number,
                          ip_reopen_days_check number,
                          ip_warehouse number,
                          ip_exch_type varchar2,
                          ip_required_return number,
                          ip_weight varchar2,
                          ip_instruct_type number,
                          ip_instruct_code varchar2,
                          ip_q_objid number,
                          op_msg_out out varchar2);

  procedure upd_conf_hdr (ip_objid number,
                          ip_display_title varchar2,
                          ip_case_type varchar2,
                          ip_title varchar2,
                          ip_service number,
                          ip_avail_lhs_menu number,
                          ip_block_reopen number,
                          ip_reopen_days_check number,
                          ip_warehouse number,
                          ip_exch_type varchar2,
                          ip_required_return number,
                          ip_weight varchar2,
                          ip_instruct_type number,
                          ip_instruct_code varchar2,
                          ip_default_queue number,
                          op_msg_out out varchar2);

  function script_exists (p_scpt_id varchar2) return boolean;
end apex_tktng_app_pkg;
/