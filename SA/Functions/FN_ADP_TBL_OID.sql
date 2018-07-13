CREATE OR REPLACE FUNCTION sa."FN_ADP_TBL_OID" (p_type_id in number) return number as
r number;
begin
  case p_type_id
  when 0 then
    select sa.sequ_case.nextval into r from dual;
  when 1 then
    select sa.sequ_probdesc.nextval into r from dual;
  when 2 then
    select sa.sequ_workaround.nextval into r from dual;
  when 4 then
    select sa.sequ_queue.nextval into r from dual;
  when 5 then
    select sa.sequ_wipbin.nextval into r from dual;
  when 6 then
    select sa.sequ_gbkp_set.nextval into r from dual;
  when 7 then
    select sa.sequ_gbkp_cat.nextval into r from dual;
  when 8 then
    select sa.sequ_gbkp_subc.nextval into r from dual;
  when 9 then
    select sa.sequ_gb_kp.nextval into r from dual;
  when 10 then
    select sa.sequ_prtkp_set.nextval into r from dual;
  when 11 then
    select sa.sequ_prtkp_cat.nextval into r from dual;
  when 12 then
    select sa.sequ_prtkp_subc.nextval into r from dual;
  when 13 then
    select sa.sequ_keyphrase.nextval into r from dual;
  when 14 then
    select sa.sequ_diag_hint.nextval into r from dual;
  when 15 then
    select sa.sequ_site_part.nextval into r from dual;
  when 16 then
    select sa.sequ_sitprt_cf.nextval into r from dual;
  when 17 then
    select sa.sequ_prtnum_kp.nextval into r from dual;
  when 18 then
    select sa.sequ_prog_logic.nextval into r from dual;
  when 20 then
    select sa.sequ_user.nextval into r from dual;
  when 21 then
    select sa.sequ_act_entry.nextval into r from dual;
  when 22 then
    select sa.sequ_reject_msg.nextval into r from dual;
  when 24 then
    select sa.sequ_subcase.nextval into r from dual;
  when 25 then
    select sa.sequ_web_lease.nextval into r from dual;
  when 26 then
    select sa.sequ_disptchfe.nextval into r from dual;
  when 27 then
    select sa.sequ_notes_log.nextval into r from dual;
  when 28 then
    select sa.sequ_phone_log.nextval into r from dual;
  when 29 then
    select sa.sequ_resrch_log.nextval into r from dual;
  when 30 then
    select sa.sequ_commit_log.nextval into r from dual;
  when 31 then
    select sa.sequ_escalation.nextval into r from dual;
  when 32 then
    select sa.sequ_onsite_log.nextval into r from dual;
  when 33 then
    select sa.sequ_privclass.nextval into r from dual;
  when 36 then
    select sa.sequ_condition.nextval into r from dual;
  when 40 then
    select sa.sequ_recv_parts.nextval into r from dual;
  when 41 then
    select sa.sequ_ct_bus_role.nextval into r from dual;
  when 42 then
    select sa.sequ_inv_role.nextval into r from dual;
  when 43 then
    select sa.sequ_bus_site_role.nextval into r from dual;
  when 44 then
    select sa.sequ_employee.nextval into r from dual;
  when 45 then
    select sa.sequ_contact.nextval into r from dual;
  when 46 then
    select sa.sequ_group.nextval into r from dual;
  when 47 then
    select sa.sequ_address.nextval into r from dual;
  when 48 then
    select sa.sequ_demand_hdr.nextval into r from dual;
  when 49 then
    select sa.sequ_demand_dtl.nextval into r from dual;
  when 51 then
    select sa.sequ_monitor.nextval into r from dual;
  when 52 then
    select sa.sequ_site.nextval into r from dual;
  when 63 then
    select sa.sequ_gl_sum_log.nextval into r from dual;
  when 64 then
    select sa.sequ_gl_summary.nextval into r from dual;
  when 66 then
    select sa.sequ_trans_map.nextval into r from dual;
  when 67 then
    select sa.sequ_map_field.nextval into r from dual;
  when 68 then
    select sa.sequ_trans_record.nextval into r from dual;
  when 69 then
    select sa.sequ_dataset.nextval into r from dual;
  when 76 then
    select sa.sequ_com_tmplte.nextval into r from dual;
  when 77 then
    select sa.sequ_time_bomb.nextval into r from dual;
  when 78 then
    select sa.sequ_gbst_lst.nextval into r from dual;
  when 79 then
    select sa.sequ_gbst_elm.nextval into r from dual;
  when 83 then
    select sa.sequ_device.nextval into r from dual;
  when 84 then
    select sa.sequ_behavior_map.nextval into r from dual;
  when 85 then
    select sa.sequ_behavior.nextval into r from dual;
  when 86 then
    select sa.sequ_contract.nextval into r from dual;
  when 87 then
    select sa.sequ_source.nextval into r from dual;
  when 89 then
    select sa.sequ_map_path.nextval into r from dual;
  when 95 then
    select sa.sequ_alert.nextval into r from dual;
  when 98 then
    select sa.sequ_prtnum_cat.nextval into r from dual;
  when 99 then
    select sa.sequ_price_factor.nextval into r from dual;
  when 109 then
    select sa.sequ_productbin.nextval into r from dual;
  when 111 then
    select sa.sequ_catalog.nextval into r from dual;
  when 114 then
    select sa.sequ_price_role.nextval into r from dual;
  when 115 then
    select sa.sequ_close_case.nextval into r from dual;
  when 117 then
    select sa.sequ_entitlement.nextval into r from dual;
  when 120 then
    select sa.sequ_status_chg.nextval into r from dual;
  when 123 then
    select sa.sequ_num_scheme.nextval into r from dual;
  when 124 then
    select sa.sequ_country.nextval into r from dual;
  when 125 then
    select sa.sequ_state_prov.nextval into r from dual;
  when 126 then
    select sa.sequ_time_zone.nextval into r from dual;
  when 127 then
    select sa.sequ_ripbin.nextval into r from dual;
  when 128 then
    select sa.sequ_response_level.nextval into r from dual;
  when 131 then
    select sa.sequ_dist_birth.nextval into r from dual;
  when 132 then
    select sa.sequ_dist_obj.nextval into r from dual;
  when 133 then
    select sa.sequ_to_do_entry.nextval into r from dual;
  when 135 then
    select sa.sequ_cls_group.nextval into r from dual;
  when 136 then
    select sa.sequ_cls_factory.nextval into r from dual;
  when 137 then
    select sa.sequ_cls_ref.nextval into r from dual;
  when 138 then
    select sa.sequ_cls_prop.nextval into r from dual;
  when 141 then
    select sa.sequ_c_site_role.nextval into r from dual;
  when 142 then
    select sa.sequ_contr_itm.nextval into r from dual;
  when 143 then
    select sa.sequ_doc_inst.nextval into r from dual;
  when 144 then
    select sa.sequ_doc_path.nextval into r from dual;
  when 145 then
    select sa.sequ_svc_intrup.nextval into r from dual;
  when 146 then
    select sa.sequ_phone.nextval into r from dual;
  when 150 then
    select sa.sequ_message.nextval into r from dual;
  when 154 then
    select sa.sequ_email_log.nextval into r from dual;
  when 156 then
    select sa.sequ_contr_inst.nextval into r from dual;
  when 157 then
    select sa.sequ_contr_pr.nextval into r from dual;
  when 163 then
    select sa.sequ_account.nextval into r from dual;
  when 173 then
    select sa.sequ_bus_org.nextval into r from dual;
  when 174 then
    select sa.sequ_acd_call.nextval into r from dual;
  when 184 then
    select sa.sequ_hint_inst.nextval into r from dual;
  when 192 then
    select sa.sequ_bug.nextval into r from dual;
  when 193 then
    select sa.sequ_module.nextval into r from dual;
  when 194 then
    select sa.sequ_close_bug.nextval into r from dual;
  when 200 then
    select sa.sequ_rpt.nextval into r from dual;
  when 201 then
    select sa.sequ_rpt_param.nextval into r from dual;
  when 202 then
    select sa.sequ_rpt_output.nextval into r from dual;
  when 203 then
    select sa.sequ_query.nextval into r from dual;
  when 204 then
    select sa.sequ_query_elm.nextval into r from dual;
  when 205 then
    select sa.sequ_sort_elm.nextval into r from dual;
  when 206 then
    select sa.sequ_keywd_elm.nextval into r from dual;
  when 210 then
    select sa.sequ_fix_bug.nextval into r from dual;
  when 211 then
    select sa.sequ_trnd.nextval into r from dual;
  when 212 then
    select sa.sequ_trnd_inst.nextval into r from dual;
  when 213 then
    select sa.sequ_trnd_rslt.nextval into r from dual;
  when 216 then
    select sa.sequ_hgbst_lst.nextval into r from dual;
  when 217 then
    select sa.sequ_hgbst_elm.nextval into r from dual;
  when 218 then
    select sa.sequ_hgbst_show.nextval into r from dual;
  when 219 then
    select sa.sequ_rule.nextval into r from dual;
  when 220 then
    select sa.sequ_retrn_info.nextval into r from dual;
  when 222 then
    select sa.sequ_log_info.nextval into r from dual;
  when 223 then
    select sa.sequ_part_stats.nextval into r from dual;
  when 224 then
    select sa.sequ_price_prog.nextval into r from dual;
  when 225 then
    select sa.sequ_price_inst.nextval into r from dual;
  when 226 then
    select sa.sequ_purchase_ord.nextval into r from dual;
  when 228 then
    select sa.sequ_inv_locatn.nextval into r from dual;
  when 229 then
    select sa.sequ_part_auth.nextval into r from dual;
  when 232 then
    select sa.sequ_options.nextval into r from dual;
  when 233 then
    select sa.sequ_wake_up.nextval into r from dual;
  when 236 then
    select sa.sequ_qry_grp.nextval into r from dual;
  when 237 then
    select sa.sequ_ping.nextval into r from dual;
  when 239 then
    select sa.sequ_part_inst.nextval into r from dual;
  when 243 then
    select sa.sequ_inv_bin.nextval into r from dual;
  when 244 then
    select sa.sequ_part_trans.nextval into r from dual;
  when 245 then
    select sa.sequ_recv_prob.nextval into r from dual;
  when 249 then
    select sa.sequ_queue_cc.nextval into r from dual;
  when 250 then
    select sa.sequ_fcs_header.nextval into r from dual;
  when 251 then
    select sa.sequ_part_role.nextval into r from dual;
  when 252 then
    select sa.sequ_fcs_detail.nextval into r from dual;
  when 253 then
    select sa.sequ_bus_empl_role.nextval into r from dual;
  when 255 then
    select sa.sequ_bus_addr_role.nextval into r from dual;
  when 256 then
    select sa.sequ_wk_work_hr.nextval into r from dual;
  when 257 then
    select sa.sequ_work_hr.nextval into r from dual;
  when 258 then
    select sa.sequ_biz_cal_hdr.nextval into r from dual;
  when 259 then
    select sa.sequ_schedule.nextval into r from dual;
  when 260 then
    select sa.sequ_appointment.nextval into r from dual;
  when 261 then
    select sa.sequ_variable.nextval into r from dual;
  when 263 then
    select sa.sequ_window_db.nextval into r from dual;
  when 264 then
    select sa.sequ_control_db.nextval into r from dual;
  when 265 then
    select sa.sequ_ctx_obj_db.nextval into r from dual;
  when 266 then
    select sa.sequ_value_item.nextval into r from dual;
  when 268 then
    select sa.sequ_expense_log.nextval into r from dual;
  when 269 then
    select sa.sequ_daylight_hr.nextval into r from dual;
  when 270 then
    select sa.sequ_contact_role.nextval into r from dual;
  when 271 then
    select sa.sequ_asaf_result.nextval into r from dual;
  when 273 then
    select sa.sequ_rpn.nextval into r from dual;
  when 276 then
    select sa.sequ_loc_inq.nextval into r from dual;
  when 282 then
    select sa.sequ_modem.nextval into r from dual;
  when 283 then
    select sa.sequ_holiday_grp.nextval into r from dual;
  when 284 then
    select sa.sequ_holiday.nextval into r from dual;
  when 286 then
    select sa.sequ_biz_cal.nextval into r from dual;
  when 287 then
    select sa.sequ_rule_cond.nextval into r from dual;
  when 290 then
    select sa.sequ_part_qty.nextval into r from dual;
  when 291 then
    select sa.sequ_config_mgr.nextval into r from dual;
  when 294 then
    select sa.sequ_prop_name.nextval into r from dual;
  when 299 then
    select sa.sequ_asaf_rpt.nextval into r from dual;
  when 300 then
    select sa.sequ_transition.nextval into r from dual;
  when 302 then
    select sa.sequ_sqr_param.nextval into r from dual;
  when 305 then
    select sa.sequ_lic_count.nextval into r from dual;
  when 306 then
    select sa.sequ_part_used.nextval into r from dual;
  when 310 then
    select sa.sequ_config_itm.nextval into r from dual;
  when 314 then
    select sa.sequ_site_addr_role.nextval into r from dual;
  when 315 then
    select sa.sequ_ship_parts.nextval into r from dual;
  when 316 then
    select sa.sequ_backorder.nextval into r from dual;
  when 317 then
    select sa.sequ_sce_object.nextval into r from dual;
  when 318 then
    select sa.sequ_menu_bar.nextval into r from dual;
  when 319 then
    select sa.sequ_menu_item.nextval into r from dual;
  when 320 then
    select sa.sequ_readonly.nextval into r from dual;
  when 324 then
    select sa.sequ_sce_revision.nextval into r from dual;
  when 326 then
    select sa.sequ_string_db.nextval into r from dual;
  when 327 then
    select sa.sequ_cursor_db.nextval into r from dual;
  when 328 then
    select sa.sequ_part_num.nextval into r from dual;
  when 329 then
    select sa.sequ_mod_level.nextval into r from dual;
  when 330 then
    select sa.sequ_part_class.nextval into r from dual;
  when 331 then
    select sa.sequ_prt_domain.nextval into r from dual;
  when 333 then
    select sa.sequ_btn_action.nextval into r from dual;
  when 334 then
    select sa.sequ_tracking.nextval into r from dual;
  when 335 then
    select sa.sequ_mod_display.nextval into r from dual;
  when 338 then
    select sa.sequ_db_geom.nextval into r from dual;
  when 339 then
    select sa.sequ_rc_config.nextval into r from dual;
  when 340 then
    select sa.sequ_btn_argument.nextval into r from dual;
  when 347 then
    select sa.sequ_fld_info.nextval into r from dual;
  when 348 then
    select sa.sequ_bus_bus_role.nextval into r from dual;
  when 349 then
    select sa.sequ_prt_prt_role.nextval into r from dual;
  when 350 then
    select sa.sequ_person.nextval into r from dual;
  when 351 then
    select sa.sequ_per_per_role.nextval into r from dual;
  when 352 then
    select sa.sequ_per_addr_role.nextval into r from dual;
  when 353 then
    select sa.sequ_per_site_role.nextval into r from dual;
  when 356 then
    select sa.sequ_fts_result.nextval into r from dual;
  when 357 then
    select sa.sequ_time_log.nextval into r from dual;
  when 361 then
    select sa.sequ_search_control.nextval into r from dual;
  when 362 then
    select sa.sequ_search_limits.nextval into r from dual;
  when 363 then
    select sa.sequ_value_map.nextval into r from dual;
  when 364 then
    select sa.sequ_path_cobj_map.nextval into r from dual;
  when 365 then
    select sa.sequ_keyword_text.nextval into r from dual;
  when 366 then
    select sa.sequ_fts_index_status.nextval into r from dual;
  when 374 then
    select sa.sequ_dist_srvr.nextval into r from dual;
  when 375 then
    select sa.sequ_to_do_list.nextval into r from dual;
  when 376 then
    select sa.sequ_dist_index.nextval into r from dual;
  when 377 then
    select sa.sequ_ver_index.nextval into r from dual;
  when 385 then
    select sa.sequ_act_rule_name.nextval into r from dual;
  when 388 then
    select sa.sequ_object_secure.nextval into r from dual;
  when 399 then
    select sa.sequ_currency.nextval into r from dual;
  when 400 then
    select sa.sequ_web_user.nextval into r from dual;
  when 401 then
    select sa.sequ_web_log.nextval into r from dual;
  when 405 then
    select sa.sequ_bin_role.nextval into r from dual;
  when 418 then
    select sa.sequ_bus_per_role.nextval into r from dual;
  when 419 then
    select sa.sequ_cas_cas_role.nextval into r from dual;
  when 420 then
    select sa.sequ_bus_prt_role.nextval into r from dual;
  when 421 then
    select sa.sequ_per_prt_role.nextval into r from dual;
  when 422 then
    select sa.sequ_sit_prt_role.nextval into r from dual;
  when 423 then
    select sa.sequ_part_event.nextval into r from dual;
  when 424 then
    select sa.sequ_cls_alias.nextval into r from dual;
  when 425 then
    select sa.sequ_filterset.nextval into r from dual;
  when 427 then
    select sa.sequ_e_addr.nextval into r from dual;
  when 2000 then
    select sa.sequ_x_call_trans.nextval into r from dual;
  when 2001 then
    select sa.sequ_x_carr_personality.nextval into r from dual;
  when 2002 then
    select sa.sequ_x_carrier.nextval into r from dual;
  when 2003 then
    select sa.sequ_x_carrier_group.nextval into r from dual;
  when 2004 then
    select sa.sequ_x_carrier_log.nextval into r from dual;
  when 2005 then
    select sa.sequ_x_carrier_rules.nextval into r from dual;
  when 2006 then
    select sa.sequ_x_churn_charge.nextval into r from dual;
  when 2007 then
    select sa.sequ_x_click_plan.nextval into r from dual;
  when 2008 then
    select sa.sequ_x_code_hist.nextval into r from dual;
  when 2009 then
    select sa.sequ_x_credit_card.nextval into r from dual;
  when 2010 then
    select sa.sequ_x_act_message.nextval into r from dual;
  when 2011 then
    select sa.sequ_x_inv_charge.nextval into r from dual;
  when 2012 then
    select sa.sequ_x_lac.nextval into r from dual;
  when 2013 then
    select sa.sequ_x_ld_provider.nextval into r from dual;
  when 2014 then
    select sa.sequ_x_line_charge.nextval into r from dual;
  when 2015 then
    select sa.sequ_x_promo_text.nextval into r from dual;
  when 2016 then
    select sa.sequ_x_pending_redemption.nextval into r from dual;
  when 2017 then
    select sa.sequ_x_promotion.nextval into r from dual;
  when 2018 then
    select sa.sequ_x_ez_enrollment.nextval into r from dual;
  when 2019 then
    select sa.sequ_x_cc_ild_inv.nextval into r from dual;
  when 2020 then
    select sa.sequ_x_red_card.nextval into r from dual;
  when 2021 then
    select sa.sequ_x_sids.nextval into r from dual;
  when 2022 then
    select sa.sequ_x_ild_inst.nextval into r from dual;
  when 2023 then
    select sa.sequ_x_bank_account.nextval into r from dual;
  when 2024 then
    select sa.sequ_x_account.nextval into r from dual;
  when 2025 then
    select sa.sequ_x_ild_hist.nextval into r from dual;
  when 2026 then
    select sa.sequ_x_code_table.nextval into r from dual;
  when 2027 then
    select sa.sequ_x_exch_options.nextval into r from dual;
  when 2028 then
    select sa.sequ_x_pi_hist.nextval into r from dual;
  when 2029 then
    select sa.sequ_x_account_hist.nextval into r from dual;
  when 2030 then
    select sa.sequ_x_promo_hist.nextval into r from dual;
  when 2031 then
    select sa.sequ_x_carr_script.nextval into r from dual;
  when 2032 then
    select sa.sequ_x_part_script.nextval into r from dual;
  when 2033 then
    select sa.sequ_x_click_plan_hist.nextval into r from dual;
  when 2034 then
    select sa.sequ_x_esn_prefix.nextval into r from dual;
  when 2035 then
    select sa.sequ_x_zip_code.nextval into r from dual;
  when 2036 then
    select sa.sequ_x_carrierdealer.nextval into r from dual;
  when 2037 then
    select sa.sequ_x_carrierpreference.nextval into r from dual;
  when 2040 then
    select sa.sequ_x_topp_err_codes.nextval into r from dual;
  when 2041 then
    select sa.sequ_x_carrier_err_codes.nextval into r from dual;
  when 2043 then
    select sa.sequ_x_order_type.nextval into r from dual;
  when 2045 then
    select sa.sequ_x_trans_profile.nextval into r from dual;
  when 2048 then
    select sa.sequ_x_topp_message.nextval into r from dual;
  when 2051 then
    select sa.sequ_x_purch_hdr.nextval into r from dual;
  when 2052 then
    select sa.sequ_x_purch_dtl.nextval into r from dual;
  when 2053 then
    select sa.sequ_x_cc_parms.nextval into r from dual;
  when 2054 then
    select sa.sequ_x_sales_tax.nextval into r from dual;
  when 2055 then
    select sa.sequ_x_purch_codes.nextval into r from dual;
  when 2056 then
    select sa.sequ_x_cc_red_inv.nextval into r from dual;
  when 2057 then
    select sa.sequ_x_purch_postings.nextval into r from dual;
  when 2059 then
    select sa.sequ_x_app_menu.nextval into r from dual;
  when 2060 then
    select sa.sequ_x_add_lines.nextval into r from dual;
  when 2061 then
    select sa.sequ_x_event_stats.nextval into r from dual;
  when 2062 then
    select sa.sequ_x_code_hist_temp.nextval into r from dual;
  when 2063 then
    select sa.sequ_x_red_card_temp.nextval into r from dual;
  when 2065 then
    select sa.sequ_x_soc.nextval into r from dual;
  when 2066 then
    select sa.sequ_x_soc_sid.nextval into r from dual;
  when 2067 then
    select sa.sequ_x_parent.nextval into r from dual;
  when 2068 then
    select sa.sequ_x_parent_hist.nextval into r from dual;
  when 2069 then
    select sa.sequ_x_rate_min_hist.nextval into r from dual;
  when 2071 then
    select sa.sequ_x_default_preload.nextval into r from dual;
  when 2073 then
    select sa.sequ_x_alt_esn.nextval into r from dual;
  when 2074 then
    select sa.sequ_x_modelscores.nextval into r from dual;
  when 2075 then
    select sa.sequ_x_address_hist.nextval into r from dual;
  when 2076 then
    select sa.sequ_x_road_inst.nextval into r from dual;
  when 2077 then
    select sa.sequ_x_road_hist.nextval into r from dual;
  when 2078 then
    select sa.sequ_x_dependents.nextval into r from dual;
  when 2079 then
    select sa.sequ_x_resol_by_case_type.nextval into r from dual;
  when 2081 then
    select sa.sequ_x_hist_stats.nextval into r from dual;
  when 2082 then
    select sa.sequ_x_carrier_logins.nextval into r from dual;
  when 2084 then
    select sa.sequ_x_promotion_group.nextval into r from dual;
  when 2085 then
    select sa.sequ_x_group2esn.nextval into r from dual;
  when 2086 then
    select sa.sequ_x_carriergroup_hist.nextval into r from dual;
  when 2087 then
    select sa.sequ_x_non_sales_tax.nextval into r from dual;
  when 2088 then
    select sa.sequ_x_pricing.nextval into r from dual;
  when 2089 then
    select sa.sequ_x_campaign.nextval into r from dual;
  when 2090 then
    select sa.sequ_x_link.nextval into r from dual;
  when 2091 then
    select sa.sequ_x_campaign_hist.nextval into r from dual;
  when 2092 then
    select sa.sequ_x_scr.nextval into r from dual;
  when 2093 then
    select sa.sequ_x_group_hist.nextval into r from dual;
  when 2094 then
    select sa.sequ_x_tracking_visitor.nextval into r from dual;
  when 2095 then
    select sa.sequ_x_tracking_site.nextval into r from dual;
  when 2096 then
    select sa.sequ_x_tracking_campaign.nextval into r from dual;
  when 2097 then
    select sa.sequ_x_tracking_element.nextval into r from dual;
  when 2098 then
    select sa.sequ_x_tracking_position.nextval into r from dual;
  when 2099 then
    select sa.sequ_x_tracking_target_url.nextval into r from dual;
  when 2100 then
    select sa.sequ_x_carrier_features.nextval into r from dual;
  when 2101 then
    select sa.sequ_x_psms_outbox.nextval into r from dual;
  when 2102 then
    select sa.sequ_x_webcsr_log.nextval into r from dual;
  when 2103 then
    select sa.sequ_x_webcsr_log_param.nextval into r from dual;
  when 2104 then
    select sa.sequ_x_asurion_warranty.nextval into r from dual;
  when 2105 then
    select sa.sequ_x_subsidy_cost.nextval into r from dual;
  when 2106 then
    select sa.sequ_x_sec_grp.nextval into r from dual;
  when 2107 then
    select sa.sequ_x_sec_func.nextval into r from dual;
  when 2108 then
    select sa.sequ_x_sec_threshold.nextval into r from dual;
  when 2109 then
    select sa.sequ_x_deffered_rule.nextval into r from dual;
  when 2110 then
    select sa.sequ_x_case_extra_info.nextval into r from dual;
  when 2111 then
    select sa.sequ_x_psms_template.nextval into r from dual;
  when 2112 then
    select sa.sequ_x_ild_transaction.nextval into r from dual;
  when 2113 then
    select sa.sequ_x_class_exch_options.nextval into r from dual;
  when 2114 then
    select sa.sequ_x_ild_rate_deck.nextval into r from dual;
  when 2115 then
    select sa.sequ_x_ild_country.nextval into r from dual;
  when 2116 then
    select sa.sequ_x_ext_conversion_hist.nextval into r from dual;
  when 2117 then
    select sa.sequ_x_parameters.nextval into r from dual;
  when 2118 then
    select sa.sequ_x_ff_center.nextval into r from dual;
  when 2119 then
    select sa.sequ_x_scripts.nextval into r from dual;
  when 2120 then
    select sa.sequ_x_script_types.nextval into r from dual;
  when 2121 then
    select sa.sequ_x_scripts_hist.nextval into r from dual;
  when 2122 then
    select sa.sequ_x_case_conf_hdr.nextval into r from dual;
  when 2123 then
    select sa.sequ_x_case_conf_dtl.nextval into r from dual;
  when 2124 then
    select sa.sequ_x_mtm_case_hdr_dtl.nextval into r from dual;
  when 2125 then
    select sa.sequ_x_mtm_ffc2conf_hdr.nextval into r from dual;
  when 2126 then
    select sa.sequ_x_case_resolutions.nextval into r from dual;
  when 2127 then
    select sa.sequ_x_case_migr_conf.nextval into r from dual;
  when 2128 then
    select sa.sequ_x_case_dispatch_conf.nextval into r from dual;
  when 2129 then
    select sa.sequ_x_escalation_conf.nextval into r from dual;
  when 2130 then
    select sa.sequ_x_escalation_speed.nextval into r from dual;
  when 2131 then
    select sa.sequ_x_case_detail.nextval into r from dual;
  when 2132 then
    select sa.sequ_x_courier.nextval into r from dual;
  when 2133 then
    select sa.sequ_x_shipping_method.nextval into r from dual;
  when 2134 then
    select sa.sequ_x_shipping_master.nextval into r from dual;
  when 2135 then
    select sa.sequ_x_part_request.nextval into r from dual;
  when 2136 then
    select sa.sequ_x_model_features.nextval into r from dual;
  when 2137 then
    select sa.sequ_x_case_promotions.nextval into r from dual;
  when 2139 then
    select sa.sequ_x_case_conf_int.nextval into r from dual;
  when 2142 then
    select sa.sequ_x_upg_units2esn.nextval into r from dual;
  when 2143 then
    select sa.sequ_x_password_hist.nextval into r from dual;
  when 2144 then
    select sa.sequ_x_block_deact.nextval into r from dual;
  when 2145 then
    select sa.sequ_x_data_config.nextval into r from dual;
  when 2146 then
    select sa.sequ_x_not_certify_models.nextval into r from dual;
  when 2148 then
    select sa.sequ_x_part_class_params.nextval into r from dual;
  when 2149 then
    select sa.sequ_x_part_class_values.nextval into r from dual;
  when 3000 then
    select sa.sequ_x_tracking_account.nextval into r from dual;
  when 3001 then
    select sa.sequ_x_campaign_codes.nextval into r from dual;
  when 3002 then
    select sa.sequ_x_campaign_lists.nextval into r from dual;
  when 3003 then
    select sa.sequ_x_disposition_codes.nextval into r from dual;
  when 3004 then
    select sa.sequ_x_tracking_status.nextval into r from dual;
  when 3005 then
    select sa.sequ_x_autopay_details.nextval into r from dual;
  when 3010 then
    select sa.sequ_x_promotion_mtm.nextval into r from dual;
  when 3011 then
    select sa.sequ_x_discount_hist.nextval into r from dual;
  when 3012 then
    select sa.sequ_x_amigo_pers.nextval into r from dual;
  when 3016 then
    select sa.sequ_x_frequency.nextval into r from dual;
  when 3017 then
    select sa.sequ_x_posa_card_inv.nextval into r from dual;
  when 3018 then
    select sa.sequ_x_cust_profile.nextval into r from dual;
  when 3019 then
    select sa.sequ_x_cust_membership.nextval into r from dual;
  when 3020 then
    select sa.sequ_x_script_controls.nextval into r from dual;
  when 3021 then
    select sa.sequ_x_sim_inv.nextval into r from dual;
  when 3022 then
    select sa.sequ_x_cbo_error.nextval into r from dual;
  when 3023 then
    select sa.sequ_x_contact_add_info.nextval into r from dual;
  when 3024 then
    select sa.sequ_x_pref_tech.nextval into r from dual;
  when 3025 then
    select sa.sequ_x_zero_out_max.nextval into r from dual;
  when 3026 then
    select sa.sequ_x_contact_part_inst.nextval into r from dual;
  when 3027 then
    select sa.sequ_x_cust_survey.nextval into r from dual;
  when 3028 then
    select sa.sequ_x_gsm_mnc.nextval into r from dual;
  when 3029 then
    select sa.sequ_x_ota_features.nextval into r from dual;
  when 3030 then
    select sa.sequ_x_ota_code_hist.nextval into r from dual;
  when 3031 then
    select sa.sequ_x_ota_reload_options.nextval into r from dual;
  when 3032 then
    select sa.sequ_x_ota_error_info.nextval into r from dual;
  when 3033 then
    select sa.sequ_x_ota_ack.nextval into r from dual;
  when 3034 then
    select sa.sequ_x_ota_transaction.nextval into r from dual;
  when 3035 then
    select sa.sequ_x_ota_trans_dtl.nextval into r from dual;
  when 3036 then
    select sa.sequ_x_ota_mrkt_info.nextval into r from dual;
  when 3037 then
    select sa.sequ_x_ota_params.nextval into r from dual;
  when 3038 then
    select sa.sequ_x_ota_program_codes.nextval into r from dual;
  when 3039 then
    select sa.sequ_x_ota_params_hist.nextval into r from dual;
  when 5000 then
    select sa.sequ_opportunity.nextval into r from dual;
  when 5001 then
    select sa.sequ_per_opp_role.nextval into r from dual;
  when 5002 then
    select sa.sequ_territory.nextval into r from dual;
  when 5003 then
    select sa.sequ_terr_defn.nextval into r from dual;
  when 5004 then
    select sa.sequ_industry.nextval into r from dual;
  when 5005 then
    select sa.sequ_per_ter_role.nextval into r from dual;
  when 5006 then
    select sa.sequ_bus_opp_role.nextval into r from dual;
  when 5007 then
    select sa.sequ_frcst_grp.nextval into r from dual;
  when 5009 then
    select sa.sequ_frcst_itm.nextval into r from dual;
  when 5012 then
    select sa.sequ_life_cycle.nextval into r from dual;
  when 5013 then
    select sa.sequ_cycle_stage.nextval into r from dual;
  when 5014 then
    select sa.sequ_stage_task.nextval into r from dual;
  when 5015 then
    select sa.sequ_stage_metric.nextval into r from dual;
  when 5016 then
    select sa.sequ_campaign.nextval into r from dual;
  when 5017 then
    select sa.sequ_lead_source.nextval into r from dual;
  when 5018 then
    select sa.sequ_per_sce_role.nextval into r from dual;
  when 5019 then
    select sa.sequ_mail_list.nextval into r from dual;
  when 5020 then
    select sa.sequ_lst_per_role.nextval into r from dual;
  when 5024 then
    select sa.sequ_curr_conv.nextval into r from dual;
  when 5025 then
    select sa.sequ_cam_per_role.nextval into r from dual;
  when 5026 then
    select sa.sequ_cr_person_role.nextval into r from dual;
  when 5027 then
    select sa.sequ_org_ter_role.nextval into r from dual;
  when 5029 then
    select sa.sequ_mtl_log.nextval into r from dual;
  when 5030 then
    select sa.sequ_unit_convert.nextval into r from dual;
  when 5032 then
    select sa.sequ_tsk_stg_role.nextval into r from dual;
  when 5033 then
    select sa.sequ_cyc_cyc_role.nextval into r from dual;
  when 5035 then
    select sa.sequ_part_detail.nextval into r from dual;
  when 5036 then
    select sa.sequ_part_delta.nextval into r from dual;
  when 5040 then
    select sa.sequ_cls_parm.nextval into r from dual;
  when 5041 then
    select sa.sequ_cls_opn.nextval into r from dual;
  when 5046 then
    select sa.sequ_job.nextval into r from dual;
  when 5051 then
    select sa.sequ_contr_schedule.nextval into r from dual;
  when 5052 then
    select sa.sequ_bug_module.nextval into r from dual;
  when 5053 then
    select sa.sequ_stage_assign.nextval into r from dual;
  when 5054 then
    select sa.sequ_price_qty.nextval into r from dual;
  when 5055 then
    select sa.sequ_amort_dtl.nextval into r from dual;
  when 5056 then
    select sa.sequ_period_amt.nextval into r from dual;
  when 5057 then
    select sa.sequ_bill_itm.nextval into r from dual;
  when 5058 then
    select sa.sequ_ship_dtl.nextval into r from dual;
  when 5059 then
    select sa.sequ_con_csc_role.nextval into r from dual;
  when 5060 then
    select sa.sequ_sit_csc_role.nextval into r from dual;
  when 5061 then
    select sa.sequ_lst_con_role.nextval into r from dual;
  when 5067 then
    select sa.sequ_task_set.nextval into r from dual;
  when 5076 then
    select sa.sequ_emp_ter_role.nextval into r from dual;
  when 5078 then
    select sa.sequ_con_opp_role.nextval into r from dual;
  when 5079 then
    select sa.sequ_qq_comment.nextval into r from dual;
  when 5080 then
    select sa.sequ_task.nextval into r from dual;
  when 5081 then
    select sa.sequ_call_script.nextval into r from dual;
  when 5082 then
    select sa.sequ_script_qstn.nextval into r from dual;
  when 5083 then
    select sa.sequ_quick_quote.nextval into r from dual;
  when 5084 then
    select sa.sequ_qq_line_item.nextval into r from dual;
  when 5086 then
    select sa.sequ_opp_qstn.nextval into r from dual;
  when 5091 then
    select sa.sequ_opp_data.nextval into r from dual;
  when 5096 then
    select sa.sequ_cls_prop_map.nextval into r from dual;
  when 5110 then
    select sa.sequ_csc_incident.nextval into r from dual;
  when 5111 then
    select sa.sequ_csc_agreement.nextval into r from dual;
  when 5112 then
    select sa.sequ_csc_activity.nextval into r from dual;
  when 5113 then
    select sa.sequ_csc_contact.nextval into r from dual;
  when 5114 then
    select sa.sequ_csc_org.nextval into r from dual;
  when 5115 then
    select sa.sequ_csc_address.nextval into r from dual;
  when 5116 then
    select sa.sequ_csc_person.nextval into r from dual;
  when 5117 then
    select sa.sequ_csc_state_prov.nextval into r from dual;
  when 5118 then
    select sa.sequ_csc_country.nextval into r from dual;
  when 5119 then
    select sa.sequ_csc_tzone.nextval into r from dual;
  when 5120 then
    select sa.sequ_csc_problem.nextval into r from dual;
  when 5121 then
    select sa.sequ_csc_solution.nextval into r from dual;
  when 5122 then
    select sa.sequ_csc_category.nextval into r from dual;
  when 5123 then
    select sa.sequ_csc_admin.nextval into r from dual;
  when 5124 then
    select sa.sequ_csc_expression.nextval into r from dual;
  when 5125 then
    select sa.sequ_csc_statement.nextval into r from dual;
  when 5126 then
    select sa.sequ_csc_feature.nextval into r from dual;
  when 5127 then
    select sa.sequ_csc_product.nextval into r from dual;
  when 5128 then
    select sa.sequ_csc_resolution.nextval into r from dual;
  when 5129 then
    select sa.sequ_csc_location.nextval into r from dual;
  when 5130 then
    select sa.sequ_csc_resource.nextval into r from dual;
  when 5131 then
    select sa.sequ_csc_attach.nextval into r from dual;
  when 5133 then
    select sa.sequ_csc_revision.nextval into r from dual;
  when 5134 then
    select sa.sequ_csc_part.nextval into r from dual;
  when 5135 then
    select sa.sequ_csc_part_rev.nextval into r from dual;
  when 5136 then
    select sa.sequ_csc_inst_part.nextval into r from dual;
  when 5137 then
    select sa.sequ_msg_process.nextval into r from dual;
  when 5138 then
    select sa.sequ_msg_text.nextval into r from dual;
  when 5139 then
    select sa.sequ_msg_id_gen.nextval into r from dual;
  when 5140 then
    select sa.sequ_exchange.nextval into r from dual;
  when 5141 then
    select sa.sequ_exch_protocol.nextval into r from dual;
  when 5142 then
    select sa.sequ_exch_log.nextval into r from dual;
  when 5147 then
    select sa.sequ_object_bind.nextval into r from dual;
  when 5148 then
    select sa.sequ_eco_hdr.nextval into r from dual;
  when 5149 then
    select sa.sequ_eco_mod_role.nextval into r from dual;
  when 5150 then
    select sa.sequ_eco_dtl.nextval into r from dual;
  when 5152 then
    select sa.sequ_opp_analysis.nextval into r from dual;
  when 5153 then
    select sa.sequ_question.nextval into r from dual;
  when 5154 then
    select sa.sequ_anlys_rspns.nextval into r from dual;
  when 5155 then
    select sa.sequ_scrqstn_rspns.nextval into r from dual;
  when 5156 then
    select sa.sequ_opp_response.nextval into r from dual;
  when 5157 then
    select sa.sequ_opp_scr_role.nextval into r from dual;
  when 5174 then
    select sa.sequ_count_setup.nextval into r from dual;
  when 5175 then
    select sa.sequ_inv_count.nextval into r from dual;
  when 5191 then
    select sa.sequ_frcst_target.nextval into r from dual;
  when 5200 then
    select sa.sequ_dialogue.nextval into r from dual;
  when 5203 then
    select sa.sequ_exch_txn.nextval into r from dual;
  when 5204 then
    select sa.sequ_exch_cat.nextval into r from dual;
  when 5205 then
    select sa.sequ_cat_txn_role.nextval into r from dual;
  when 5206 then
    select sa.sequ_medium.nextval into r from dual;
  when 5207 then
    select sa.sequ_channel.nextval into r from dual;
  when 5208 then
    select sa.sequ_communication.nextval into r from dual;
  when 5209 then
    select sa.sequ_scr_run.nextval into r from dual;
  when 5210 then
    select sa.sequ_key_word.nextval into r from dual;
  when 5212 then
    select sa.sequ_scr_response.nextval into r from dual;
  when 5218 then
    select sa.sequ_usr_opp_role.nextval into r from dual;
  when 5219 then
    select sa.sequ_usr_ter_role.nextval into r from dual;
  when 5224 then
    select sa.sequ_pro_hgl_role.nextval into r from dual;
  when 5225 then
    select sa.sequ_interact.nextval into r from dual;
  when 5226 then
    select sa.sequ_interact_txt.nextval into r from dual;
  when 5227 then
    select sa.sequ_ver_control.nextval into r from dual;
  when 5233 then
    select sa.sequ_exch_timebomb.nextval into r from dual;
  when 5236 then
    select sa.sequ_rollup.nextval into r from dual;
  when 5237 then
    select sa.sequ_bus_rol_itm.nextval into r from dual;
  when 5238 then
    select sa.sequ_loc_rol_itm.nextval into r from dual;
  when 5239 then
    select sa.sequ_ter_rol_itm.nextval into r from dual;
  when 5240 then
    select sa.sequ_x79accnt.nextval into r from dual;
  when 5241 then
    select sa.sequ_x79person.nextval into r from dual;
  when 5242 then
    select sa.sequ_x79ptr_loc_role.nextval into r from dual;
  when 5243 then
    select sa.sequ_x79location.nextval into r from dual;
  when 5244 then
    select sa.sequ_x79address.nextval into r from dual;
  when 5245 then
    select sa.sequ_x79state_prov.nextval into r from dual;
  when 5246 then
    select sa.sequ_x79country.nextval into r from dual;
  when 5247 then
    select sa.sequ_x79tzone.nextval into r from dual;
  when 5248 then
    select sa.sequ_x79interval.nextval into r from dual;
  when 5249 then
    select sa.sequ_x79service.nextval into r from dual;
  when 5250 then
    select sa.sequ_x79srvc_role.nextval into r from dual;
  when 5251 then
    select sa.sequ_x79part_rev.nextval into r from dual;
  when 5252 then
    select sa.sequ_x79part.nextval into r from dual;
  when 5253 then
    select sa.sequ_x79provider_tr.nextval into r from dual;
  when 5254 then
    select sa.sequ_x79alias.nextval into r from dual;
  when 5255 then
    select sa.sequ_x79trfmt_defn.nextval into r from dual;
  when 5256 then
    select sa.sequ_x79telcom_tr.nextval into r from dual;
  when 5257 then
    select sa.sequ_x79repair_act.nextval into r from dual;
  when 5258 then
    select sa.sequ_x79tr_txt.nextval into r from dual;
  when 5259 then
    select sa.sequ_x79mo_inst.nextval into r from dual;
  when 5260 then
    select sa.sequ_x79tr_number.nextval into r from dual;
  when 5261 then
    select sa.sequ_x79ttr_itv_role.nextval into r from dual;
  when 5262 then
    select sa.sequ_x79act_dur.nextval into r from dual;
  when 5263 then
    select sa.sequ_x79auth.nextval into r from dual;
  when 5264 then
    select sa.sequ_x79activity.nextval into r from dual;
  when 5265 then
    select sa.sequ_x79mo_cls.nextval into r from dual;
  when 5266 then
    select sa.sequ_x79attribute.nextval into r from dual;
  when 5267 then
    select sa.sequ_x79tr_hist.nextval into r from dual;
  when 5268 then
    select sa.sequ_x79alarm_rec.nextval into r from dual;
  when 5269 then
    select sa.sequ_x79ttr_per_role.nextval into r from dual;
  when 5270 then
    select sa.sequ_x79escal.nextval into r from dual;
  when 5271 then
    select sa.sequ_x79ttr_loc_role.nextval into r from dual;
  when 5272 then
    select sa.sequ_x79esc_per_role.nextval into r from dual;
  when 5273 then
    select sa.sequ_x79ttr_ttr_role.nextval into r from dual;
  when 5274 then
    select sa.sequ_x79mit.nextval into r from dual;
  when 5275 then
    select sa.sequ_vendor_part.nextval into r from dual;
  when 5287 then
    select sa.sequ_exc_con_role.nextval into r from dual;
  when 5288 then
    select sa.sequ_exc_usr_role.nextval into r from dual;
  when 5292 then
    select sa.sequ_cycle_setup.nextval into r from dual;
  when 5293 then
    select sa.sequ_rpr_inst_qty.nextval into r from dual;
  when 5294 then
    select sa.sequ_close_exch.nextval into r from dual;
  when 5295 then
    select sa.sequ_cl_exch_dtl.nextval into r from dual;
  when 5299 then
    select sa.sequ_exc_sit_role.nextval into r from dual;
  when 5300 then
    select sa.sequ_exc_bch_role.nextval into r from dual;
  when 5301 then
    select sa.sequ_cycle_count.nextval into r from dual;
  when 5302 then
    select sa.sequ_inv_ctrl.nextval into r from dual;
  when 5306 then
    select sa.sequ_qualifier.nextval into r from dual;
  when 5307 then
    select sa.sequ_qual_user.nextval into r from dual;
  when 5309 then
    select sa.sequ_lit_req.nextval into r from dual;
  when 5310 then
    select sa.sequ_lit_req_itm.nextval into r from dual;
  when 5311 then
    select sa.sequ_lit_ship_req.nextval into r from dual;
  when 5312 then
    select sa.sequ_lead.nextval into r from dual;
  when 5313 then
    select sa.sequ_mui_mui_role.nextval into r from dual;
  when 5314 then
    select sa.sequ_bus_lsc_role.nextval into r from dual;
  when 5315 then
    select sa.sequ_con_lsc_role.nextval into r from dual;
  when 5316 then
    select sa.sequ_lead_extn.nextval into r from dual;
  when 5317 then
    select sa.sequ_auth_stats.nextval into r from dual;
  when 5321 then
    select sa.sequ_participant.nextval into r from dual;
  when 5325 then
    select sa.sequ_cmcn_email.nextval into r from dual;
  when 5326 then
    select sa.sequ_edr_com_role.nextval into r from dual;
  when 5334 then
    select sa.sequ_usr_bus_role.nextval into r from dual;
  when 5335 then
    select sa.sequ_task_desc.nextval into r from dual;
  when 5360 then
    select sa.sequ_list_struct.nextval into r from dual;
  when 5361 then
    select sa.sequ_choice_fld.nextval into r from dual;
  when 5365 then
    select sa.sequ_acd.nextval into r from dual;
  when 5366 then
    select sa.sequ_agent.nextval into r from dual;
  when 5367 then
    select sa.sequ_web_filter.nextval into r from dual;
  when 5370 then
    select sa.sequ_shp_sit_role.nextval into r from dual;
  when 5371 then
    select sa.sequ_template.nextval into r from dual;
  when 5373 then
    select sa.sequ_batch_info.nextval into r from dual;
  when 5376 then
    select sa.sequ_locale.nextval into r from dual;
  when 5378 then
    select sa.sequ_r_rqst.nextval into r from dual;
  when 5379 then
    select sa.sequ_skill.nextval into r from dual;
  when 5380 then
    select sa.sequ_rsrc.nextval into r from dual;
  when 5381 then
    select sa.sequ_rqst_skill.nextval into r from dual;
  when 5382 then
    select sa.sequ_rsrc_skill.nextval into r from dual;
  when 5383 then
    select sa.sequ_rsc_rqt_scr.nextval into r from dual;
  when 5385 then
    select sa.sequ_cl_rule.nextval into r from dual;
  when 5386 then
    select sa.sequ_cl_action.nextval into r from dual;
  when 5387 then
    select sa.sequ_cl_result.nextval into r from dual;
  when 5388 then
    select sa.sequ_cl_param.nextval into r from dual;
  when 5389 then
    select sa.sequ_cl_act_src.nextval into r from dual;
  when 5390 then
    select sa.sequ_disp_req.nextval into r from dual;
  when 5391 then
    select sa.sequ_cl_keyword.nextval into r from dual;
  when 5392 then
    select sa.sequ_r_rqst_ctx.nextval into r from dual;
  when 5400 then
    select sa.sequ_N_Product.nextval into r from dual;
  when 5401 then
    select sa.sequ_N_Option.nextval into r from dual;
  when 5403 then
    select sa.sequ_N_Attachments.nextval into r from dual;
  when 5405 then
    select sa.sequ_N_BreakPoints.nextval into r from dual;
  when 5406 then
    select sa.sequ_N_Categories.nextval into r from dual;
  when 5407 then
    select sa.sequ_N_CategoryMembers.nextval into r from dual;
  when 5408 then
    select sa.sequ_N_Competitors.nextval into r from dual;
  when 5409 then
    select sa.sequ_N_ExtraMenuItems.nextval into r from dual;
  when 5410 then
    select sa.sequ_N_Functions.nextval into r from dual;
  when 5411 then
    select sa.sequ_N_Info.nextval into r from dual;
  when 5412 then
    select sa.sequ_N_ItemTypes.nextval into r from dual;
  when 5413 then
    select sa.sequ_N_JobSummary.nextval into r from dual;
  when 5414 then
    select sa.sequ_N_CategoryTrees.nextval into r from dual;
  when 5415 then
    select sa.sequ_N_PackageMembers.nextval into r from dual;
  when 5416 then
    select sa.sequ_N_Packages.nextval into r from dual;
  when 5417 then
    select sa.sequ_N_PrivatePreferences.nextval into r from dual;
  when 5418 then
    select sa.sequ_N_Properties.nextval into r from dual;
  when 5420 then
    select sa.sequ_N_Templates.nextval into r from dual;
  when 5422 then
    select sa.sequ_N_Watches.nextval into r from dual;
  when 5424 then
    select sa.sequ_NRW_Resources.nextval into r from dual;
  when 5425 then
    select sa.sequ_NRW_RuleChecksums.nextval into r from dual;
  when 5426 then
    select sa.sequ_NRW_RuleEventInfo.nextval into r from dual;
  when 5427 then
    select sa.sequ_NRW_RuleInstances.nextval into r from dual;
  when 5428 then
    select sa.sequ_NRW_RuleTemplates.nextval into r from dual;
  when 5431 then
    select sa.sequ_N_Reports.nextval into r from dual;
  when 5438 then
    select sa.sequ_N_ItemTypesEx.nextval into r from dual;
  when 5440 then
    select sa.sequ_pay_means.nextval into r from dual;
  when 5441 then
    select sa.sequ_con_pym_role.nextval into r from dual;
  when 5442 then
    select sa.sequ_bus_prf_role.nextval into r from dual;
  when 5443 then
    select sa.sequ_preference.nextval into r from dual;
  when 5444 then
    select sa.sequ_address_extn.nextval into r from dual;
  when 5447 then
    select sa.sequ_new_receipts.nextval into r from dual;
  when 5448 then
    select sa.sequ_receipts_directives.nextval into r from dual;
  when 5450 then
    select sa.sequ_N_TableAlias.nextval into r from dual;
  when 5451 then
    select sa.sequ_N_ColumnAlias.nextval into r from dual;
  when 5452 then
    select sa.sequ_N_EventAlias.nextval into r from dual;
  when 5464 then
    select sa.sequ_user_touch.nextval into r from dual;
  when 5465 then
    select sa.sequ_xfilter.nextval into r from dual;
  when 5466 then
    select sa.sequ_axfprops.nextval into r from dual;
  when 5467 then
    select sa.sequ_xfilterset.nextval into r from dual;
  when 5468 then
    select sa.sequ_N_Attribute.nextval into r from dual;
  when 5469 then
    select sa.sequ_N_AttributeValue.nextval into r from dual;
  when 5470 then
    select sa.sequ_N_AttributeDefinition.nextval into r from dual;
  when 5471 then
    select sa.sequ_N_AttributeCondition.nextval into r from dual;
  when 5472 then
    select sa.sequ_bus_led_role.nextval into r from dual;
  when 5473 then
    select sa.sequ_bug_bug_role.nextval into r from dual;
  when 5474 then
    select sa.sequ_page_class.nextval into r from dual;
  when 5481 then
    select sa.sequ_access_control.nextval into r from dual;
  when 5488 then
    select sa.sequ_install_history.nextval into r from dual;
  when 5504 then
    select sa.sequ_con_rol_itm.nextval into r from dual;
  when 5505 then
    select sa.sequ_opp_rol_itm.nextval into r from dual;
  when 5508 then
    select sa.sequ_web_object.nextval into r from dual;
  when 5513 then
    select sa.sequ_NWS_Properties.nextval into r from dual;
  when 5514 then
    select sa.sequ_NWS_TreeFolders.nextval into r from dual;
  when 5515 then
    select sa.sequ_NWS_FolderMembers.nextval into r from dual;
  when 5516 then
    select sa.sequ_NWS_Trees.nextval into r from dual;
  when 5633 then
    select sa.sequ_report_info.nextval into r from dual;
  when 5634 then
    select sa.sequ_parameter_info.nextval into r from dual;
  when 5653 then
    select sa.sequ_win_locale_info.nextval into r from dual;
  when 5670 then
    select sa.sequ_extern_id.nextval into r from dual;
  when 5683 then
    select sa.sequ_server_stats.nextval into r from dual;
  when 5684 then
    select sa.sequ_server.nextval into r from dual;
  when 5694 then
    select sa.sequ_fin_accnt.nextval into r from dual;
  when 5695 then
    select sa.sequ_blg_argmnt.nextval into r from dual;
  when 5696 then
    select sa.sequ_pay_channel.nextval into r from dual;
  when 5698 then
    select sa.sequ_con_blg_argmnt_role.nextval into r from dual;
  when 5699 then
    select sa.sequ_con_fin_accnt_role.nextval into r from dual;
  when 5700 then
    select sa.sequ_addr_ba_role.nextval into r from dual;
  when 5701 then
    select sa.sequ_con_sp_role.nextval into r from dual;
  when 5702 then
    select sa.sequ_con_pc_role.nextval into r from dual;
  when 5703 then
    select sa.sequ_bus_org_extern.nextval into r from dual;
  when 5704 then
    select sa.sequ_site_part_extern.nextval into r from dual;
  when 5708 then
    select sa.sequ_fin_accnt_extern.nextval into r from dual;
  when 5709 then
    select sa.sequ_blg_argmnt_extern.nextval into r from dual;
  when 5711 then
    select sa.sequ_pay_chnl_extern.nextval into r from dual;
  when 5732 then
    select sa.sequ_ba_pc_role.nextval into r from dual;
  when 5733 then
    select sa.sequ_fa_pc_role.nextval into r from dual;
  when 5746 then
    select sa.sequ_appln_group_codes.nextval into r from dual;
  when 9751 then
    select sa.sequ_process.nextval into r from dual;
  when 9752 then
    select sa.sequ_func_group.nextval into r from dual;
  when 9753 then
    select sa.sequ_function.nextval into r from dual;
  when 9754 then
    select sa.sequ_svc_rqst.nextval into r from dual;
  when 9755 then
    select sa.sequ_svc_fld.nextval into r from dual;
  when 9756 then
    select sa.sequ_proc_inst.nextval into r from dual;
  when 9757 then
    select sa.sequ_group_inst.nextval into r from dual;
  when 9758 then
    select sa.sequ_rqst_inst.nextval into r from dual;
  when 9759 then
    select sa.sequ_fld_inst.nextval into r from dual;
  when 9760 then
    select sa.sequ_rqst_pending.nextval into r from dual;
  when 9761 then
    select sa.sequ_rqst_queue.nextval into r from dual;
  when 9762 then
    select sa.sequ_rqst_def.nextval into r from dual;
  when 9764 then
    select sa.sequ_svc_type.nextval into r from dual;
  when 9765 then
    select sa.sequ_tbl_def.nextval into r from dual;
  when 9766 then
    select sa.sequ_fld_def.nextval into r from dual;
  when 9767 then
    select sa.sequ_rqst_fld_role.nextval into r from dual;
  when 9768 then
    select sa.sequ_proc_forecast.nextval into r from dual;
  when 9769 then
    select sa.sequ_proc_fc_item.nextval into r from dual;
  when 9770 then
    select sa.sequ_proc_fc_data.nextval into r from dual;
  end case;
  return r;
end;
/