CREATE OR REPLACE FORCE VIEW sa.tktng_app_esc_triggers (title_type,h_objid,es_objid,p_objid,to_prty2gbst_elm,ec_objid,x_hot_transfer,x_script_id_hot,x_script_id_cold,x_script_id_grace,x_eval_escalation,escal2conf_hdr,carrier_value,carrier,priority_rank,from_priority,to_priority,start_ranking,frequency,freq_time,service_level,turn_around_time,reopens) AS
select "TITLE_TYPE","H_OBJID","ES_OBJID","P_OBJID","TO_PRTY2GBST_ELM","EC_OBJID","X_HOT_TRANSFER","X_SCRIPT_ID_HOT","X_SCRIPT_ID_COLD","X_SCRIPT_ID_GRACE","X_EVAL_ESCALATION","ESCAL2CONF_HDR","CARRIER_VALUE","CARRIER","PRIORITY_RANK","FROM_PRIORITY","TO_PRIORITY","START_RANKING","FREQUENCY","FREQ_TIME","SERVICE_LEVEL","TURN_AROUND_TIME","REOPENS"
  from (select hdr.x_case_type || ' - ' || hdr.x_title title_type,
               hdr.objid h_objid,
               speed.objid es_objid,
               conf.from_prty2gbst_elm p_objid,
               conf.to_prty2gbst_elm,
               conf.objid ec_objid,
               conf.x_hot_transfer,
               conf.x_script_id_hot,
               conf.x_script_id_cold,
               conf.x_script_id_grace,
               conf.x_eval_escalation,
               conf.escal2conf_hdr,
               speed.x_auto_carrier carrier_value,
               decode(speed.x_auto_carrier,'1','Automated','0','Not Automated',null) carrier,
               (select rank from table_gbst_elm g_elm where g_elm.objid = conf.from_prty2gbst_elm) priority_rank,
               (select rank || ' - ' || title from table_gbst_elm g_elm where g_elm.objid = conf.from_prty2gbst_elm) from_priority,
               (select rank || ' - ' || title from table_gbst_elm g_elm where g_elm.objid = conf.to_prty2gbst_elm) to_priority,
               speed.x_star_rank start_ranking,
               speed.x_prev_case_count frequency,
               speed.x_prev_case_days freq_time,
               speed.X_HOURS2ESCALATE service_level,
               speed.x_tat_hours turn_around_time,
               speed.x_re_open_count reopens
        from   table_x_escalation_speed speed,
               table_x_escalation_conf  conf,
               table_x_case_conf_hdr hdr
        where  conf.objid = speed.speed2escalation(+)
        and    conf.escal2conf_hdr = hdr.objid)
  order by priority_rank, start_ranking ;