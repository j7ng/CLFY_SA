CREATE OR REPLACE FORCE VIEW sa.table_x_task_history (contact_objid,task_objid,title,s_title,"TYPE",s_type,status,s_status,age,esn,task_id,s_task_id,carrier_mkt,end_date,activation_timeframe) AS
select table_task.task2contact, table_task.objid,
 table_task.title, table_task.S_title, table_gbst_type.title, table_gbst_type.S_title,
 table_gbst_sts.title, table_gbst_sts.S_title, table_task.start_date,
 table_site_part.x_service_id, table_task.task_id, table_task.S_task_id,
 table_x_carrier.x_mkt_submkt_name, table_task.comp_date,
 table_task.x_activation_timeframe
 from table_gbst_elm table_gbst_sts, table_gbst_elm table_gbst_type, table_task, table_site_part, table_x_carrier,
  table_x_call_trans
 where table_site_part.objid = table_x_call_trans.call_trans2site_part
 AND table_x_carrier.objid = table_x_call_trans.x_call_trans2carrier
 AND table_gbst_sts.objid = table_task.task_sts2gbst_elm
 AND table_gbst_type.objid = table_task.type_task2gbst_elm
 AND table_task.task2contact IS NOT NULL
 AND table_x_call_trans.objid = table_task.x_task2x_call_trans
 ;
COMMENT ON TABLE sa.table_x_task_history IS 'Used by cust interaction 11400, on form 1872.';
COMMENT ON COLUMN sa.table_x_task_history.contact_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_task_history.task_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_task_history.title IS 'Title of the task';
COMMENT ON COLUMN sa.table_x_task_history."TYPE" IS 'Name of the item/element';
COMMENT ON COLUMN sa.table_x_task_history.status IS 'Name of the item/element';
COMMENT ON COLUMN sa.table_x_task_history.age IS 'Desired start date of the task';
COMMENT ON COLUMN sa.table_x_task_history.esn IS 'Serial Number of the Phone for Wireless or Service Id for Wireline';
COMMENT ON COLUMN sa.table_x_task_history.task_id IS 'System-generated task ID number';
COMMENT ON COLUMN sa.table_x_task_history.carrier_mkt IS 'Carrier Market/Submarket Name';
COMMENT ON COLUMN sa.table_x_task_history.end_date IS 'Actual completion date of the task';
COMMENT ON COLUMN sa.table_x_task_history.activation_timeframe IS 'Activation Time frame from pull down list';