CREATE OR REPLACE FORCE VIEW sa.table_x_monitor_view (task_objid,task_id,s_task_id,task_create_date,task_close_date,contact_first,s_contact_first,contact_last,s_contact_last,"PRIORITY",s_priority,"CONDITION",s_condition,curr_queue,s_curr_queue,"OWNER",s_owner,status,s_status,order_type,s_order_type,carrier_name,carrier_mkt,esn,topp_error_code,current_method,x_min,x_iccid,transmission_method,fax_path) AS
select table_task.objid,
       table_task.task_id,
       table_task.S_task_id,
       table_task.start_date,
       table_task.comp_date,
       table_contact.first_name,
       table_contact.S_first_name,
       table_contact.last_name,
       table_contact.S_last_name,
       table_gbst_pri.title,
       table_gbst_pri.S_title,
       table_condition.title,
       table_condition.S_title,
       null, --table_queue.title,
       null, --table_queue.S_title,
       table_user.login_name,
       table_user.S_login_name,
       table_gbst_stat.title,
       table_gbst_stat.S_title,
       table_gbst_type.title,
       table_gbst_type.S_title,
       table_x_carrier_group.x_carrier_name,
       table_x_carrier.x_mkt_submkt_name,
       table_x_call_trans.x_service_id,
       table_x_topp_err_codes.x_code_name,
       --table_x_trans_profile.x_transmit_method,
       decode(table_part_num.x_technology,
              'ANALOG',table_x_trans_profile.x_transmit_method,
              'CDMA',table_x_trans_profile.x_d_transmit_method,
              'TDMA',table_x_trans_profile.x_d_transmit_method,
              'GSM',table_x_trans_profile.x_gsm_transmit_method,
                    table_x_trans_profile.x_transmit_method) x_transmit_method,                                            
       table_x_call_trans.x_min,
       table_x_call_trans.x_iccid,
       table_task.x_original_method,
       table_task.x_fax_file
  from
       table_x_topp_err_codes,
       table_contact,
--       table_queue,
       table_gbst_elm table_gbst_type,
       table_gbst_elm table_gbst_stat,
       table_gbst_elm table_gbst_pri,
       table_x_carrier_group,
       table_x_carrier,
       table_x_trans_profile,
--       table_site_part,
       table_x_call_trans,
       table_part_inst,
       table_mod_level,
       table_part_num,
--
       table_condition,
       table_x_order_type,
       table_user,
       table_task
 where table_x_topp_err_codes.objid (+) = table_task.x_task2x_topp_err_codes
   AND table_contact.objid (+)          = table_task.task2contact
--   AND table_queue.objid /*(+)*/            = table_task.task_currq2queue
--
   and table_gbst_type.objid            = table_task.type_task2gbst_elm
   AND table_gbst_pri.objid             = table_task.task_priority2gbst_elm
   AND table_gbst_stat.objid            = table_task.task_sts2gbst_elm
--
   and table_x_carrier_group.objid      = table_x_carrier.carrier2carrier_group
   AND table_x_carrier.objid            = table_x_call_trans.x_call_trans2carrier                                --
   AND table_x_trans_profile.objid(+)      = table_x_order_type.x_order_type2x_trans_profile
--   AND table_site_part.objid (+)        = table_x_call_trans.call_trans2site_part
   AND table_x_call_trans.x_service_id   = table_part_inst.part_serial_no
   AND table_part_inst.n_part_inst2part_mod = table_mod_level.objid
   AND table_mod_level.part_info2part_num = table_part_num.objid
   AND table_x_call_trans.objid         = table_task.x_task2x_call_trans
--
   AND table_condition.objid            = table_task.task_state2condition
   AND table_x_order_type.objid(+)         = table_task.x_task2x_order_type
   AND table_user.objid                 = table_task.task_owner2user
   and table_task.task_currq2queue is  null
union
select table_task.objid,
       table_task.task_id,
       table_task.S_task_id,
       table_task.start_date,
       table_task.comp_date,
       table_contact.first_name,
       table_contact.S_first_name,
       table_contact.last_name,
       table_contact.S_last_name,
       table_gbst_pri.title,
       table_gbst_pri.S_title,
       table_condition.title,
       table_condition.S_title,
       table_queue.title,
       table_queue.S_title,
       table_user.login_name,
       table_user.S_login_name,
       table_gbst_stat.title,
       table_gbst_stat.S_title,
       table_gbst_type.title,
       table_gbst_type.S_title,
       table_x_carrier_group.x_carrier_name,
       table_x_carrier.x_mkt_submkt_name,
       table_x_call_trans.x_service_id,
       table_x_topp_err_codes.x_code_name,
       --table_x_trans_profile.x_transmit_method,
       decode(table_part_num.x_technology,
              'ANALOG',table_x_trans_profile.x_transmit_method,
              'CDMA',table_x_trans_profile.x_d_transmit_method,
              'TDMA',table_x_trans_profile.x_d_transmit_method,
              'GSM',table_x_trans_profile.x_gsm_transmit_method,
                    table_x_trans_profile.x_transmit_method) x_transmit_method,                                            
       table_x_call_trans.x_min,
       table_x_call_trans.x_iccid,
       table_task.x_original_method,
       table_task.x_fax_file
  from
       table_x_topp_err_codes,
       table_contact,
       table_queue,
       table_gbst_elm table_gbst_type,
       table_gbst_elm table_gbst_stat,
       table_gbst_elm table_gbst_pri,
       table_x_carrier_group,
       table_x_carrier,
       table_x_trans_profile,
--       table_site_part,
       table_x_call_trans,
       table_part_inst,
       table_mod_level,
       table_part_num,
--
       table_condition,
       table_x_order_type,
       table_user,
       table_task
 where table_x_topp_err_codes.objid (+) = table_task.x_task2x_topp_err_codes
   AND table_contact.objid (+)          = table_task.task2contact
   AND table_queue.objid /*(+)*/        = table_task.task_currq2queue
--
   and table_gbst_type.objid            = table_task.type_task2gbst_elm
   AND table_gbst_pri.objid             = table_task.task_priority2gbst_elm
   AND table_gbst_stat.objid            = table_task.task_sts2gbst_elm
--
   and table_x_carrier_group.objid      = table_x_carrier.carrier2carrier_group
   AND table_x_carrier.objid            = table_x_call_trans.x_call_trans2carrier                                --
   AND table_x_trans_profile.objid(+)      = table_x_order_type.x_order_type2x_trans_profile
--   AND table_site_part.objid (+)        = table_x_call_trans.call_trans2site_part
   AND table_x_call_trans.x_service_id   = table_part_inst.part_serial_no
   AND table_part_inst.n_part_inst2part_mod = table_mod_level.objid
   AND table_mod_level.part_info2part_num = table_part_num.objid
   AND table_x_call_trans.objid         = table_task.x_task2x_call_trans
--
   AND table_condition.objid            = table_task.task_state2condition
   AND table_x_order_type.objid(+)         = table_task.x_task2x_order_type
   AND table_user.objid                 = table_task.task_owner2user
   and table_task.task_currq2queue is not null;
COMMENT ON TABLE sa.table_x_monitor_view IS 'Used by Activation Monitor; FORM #1859';
COMMENT ON COLUMN sa.table_x_monitor_view.task_objid IS 'task instance internal record number';
COMMENT ON COLUMN sa.table_x_monitor_view.task_id IS 'Task ID number';
COMMENT ON COLUMN sa.table_x_monitor_view.task_create_date IS 'creation date of task';
COMMENT ON COLUMN sa.table_x_monitor_view.task_close_date IS 'completion date of task';
COMMENT ON COLUMN sa.table_x_monitor_view.contact_first IS 'contact first name';
COMMENT ON COLUMN sa.table_x_monitor_view.contact_last IS 'contact last name';
COMMENT ON COLUMN sa.table_x_monitor_view."PRIORITY" IS 'priority of action item';
COMMENT ON COLUMN sa.table_x_monitor_view."CONDITION" IS 'condition of action item';
COMMENT ON COLUMN sa.table_x_monitor_view.curr_queue IS 'Current queue of action item';
COMMENT ON COLUMN sa.table_x_monitor_view."OWNER" IS 'Login ID of user';
COMMENT ON COLUMN sa.table_x_monitor_view.status IS 'status of action item';
COMMENT ON COLUMN sa.table_x_monitor_view.order_type IS 'type of transmission';
COMMENT ON COLUMN sa.table_x_monitor_view.carrier_name IS 'Name of Carrier';
COMMENT ON COLUMN sa.table_x_monitor_view.carrier_mkt IS 'Name of Carrier Market';
COMMENT ON COLUMN sa.table_x_monitor_view.esn IS 'ESN';
COMMENT ON COLUMN sa.table_x_monitor_view.topp_error_code IS 'Topp Error Code';
COMMENT ON COLUMN sa.table_x_monitor_view.current_method IS 'Current Transmit method';
COMMENT ON COLUMN sa.table_x_monitor_view.x_min IS 'MIN';
COMMENT ON COLUMN sa.table_x_monitor_view.x_iccid IS 'Sim Serial Number';
COMMENT ON COLUMN sa.table_x_monitor_view.transmission_method IS 'Transmit Method';
COMMENT ON COLUMN sa.table_x_monitor_view.fax_path IS 'fax path';