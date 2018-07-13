CREATE OR REPLACE FORCE VIEW sa.table_x_qry_case_view (elm_objid,id_number,"OWNER",s_owner,"CONDITION",s_condition,status,s_status,title,s_title,"PRIORITY",s_priority,severity,s_severity,"TYPE",s_type,x_carrier_id,x_carrier_name,x_esn,x_min,x_iccid,creation_time,victimcase_x_case_type,x_phone_model,x_retailer_name,x_activation_zip,x_currq_title,s_x_currq_title,x_prevq_title,s_x_prevq_title) AS
select table_victimcase.objid, table_victimcase.id_number,
 table_owner.login_name, table_owner.S_login_name, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_victimcase.title, table_victimcase.S_title,
 table_gse_priority.title, table_gse_priority.S_title, table_gse_severity.title, table_gse_severity.S_title,
 table_gse_type.title, table_gse_type.S_title, table_victimcase.x_text_car_id,
 table_victimcase.x_carrier_name, table_victimcase.x_esn,
 table_victimcase.x_min, table_victimcase.x_iccid, table_victimcase.creation_time,
 table_victimcase.x_case_type, table_victimcase.x_phone_model,
 table_victimcase.x_retailer_name, table_victimcase.x_activation_zip,
 table_currq.title, table_currq.S_title, table_prevq.title, table_prevq.S_title
 from table_case table_victimcase, table_gbst_elm table_gse_type, table_gbst_elm table_gse_priority, table_gbst_elm table_gse_status,
      table_gbst_elm table_gse_severity, table_user table_owner, table_queue table_currq, table_queue table_prevq, table_condition
 where table_condition.objid = table_victimcase.case_state2condition
 AND table_gse_type.objid = table_victimcase.calltype2gbst_elm
 AND table_gse_priority.objid = table_victimcase.respprty2gbst_elm
 AND table_gse_status.objid = table_victimcase.casests2gbst_elm
 AND table_gse_severity.objid = table_victimcase.respsvrty2gbst_elm
 AND table_owner.objid = table_victimcase.case_owner2user
 AND table_currq.objid(+) = table_victimcase.case_currq2queue
 AND table_prevq.objid(+) = table_victimcase.case_prevq2queue;
COMMENT ON TABLE sa.table_x_qry_case_view IS 'Used by form Case Maintenance';
COMMENT ON COLUMN sa.table_x_qry_case_view.elm_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_x_qry_case_view.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_x_qry_case_view."OWNER" IS 'User login name';
COMMENT ON COLUMN sa.table_x_qry_case_view."CONDITION" IS 'Condition of the case';
COMMENT ON COLUMN sa.table_x_qry_case_view.status IS 'Status of the case';
COMMENT ON COLUMN sa.table_x_qry_case_view.title IS 'Case or service call title; summary of case details';
COMMENT ON COLUMN sa.table_x_qry_case_view."PRIORITY" IS 'Priority of the case';
COMMENT ON COLUMN sa.table_x_qry_case_view.severity IS 'Severity of the case';
COMMENT ON COLUMN sa.table_x_qry_case_view."TYPE" IS 'Type of case';
COMMENT ON COLUMN sa.table_x_qry_case_view.x_carrier_id IS 'Carrier ID stored as text from the case';
COMMENT ON COLUMN sa.table_x_qry_case_view.x_carrier_name IS 'Carrier Market/Submarket Name';
COMMENT ON COLUMN sa.table_x_qry_case_view.x_esn IS 'Serial Number of the Phone for Wireless or Service Id for Wireline';
COMMENT ON COLUMN sa.table_x_qry_case_view.x_min IS 'Line Number/Phone Number';
COMMENT ON COLUMN sa.table_x_qry_case_view.x_iccid IS 'Sim Serial Number';
COMMENT ON COLUMN sa.table_x_qry_case_view.creation_time IS 'The date and time the case was created';
COMMENT ON COLUMN sa.table_x_qry_case_view.victimcase_x_case_type IS 'Case type';
COMMENT ON COLUMN sa.table_x_qry_case_view.x_phone_model IS 'Phone Model Number';
COMMENT ON COLUMN sa.table_x_qry_case_view.x_retailer_name IS 'Retailer name';
COMMENT ON COLUMN sa.table_x_qry_case_view.x_activation_zip IS 'Zip where phone will be activated';
COMMENT ON COLUMN sa.table_x_qry_case_view.x_currq_title IS 'Queue title';
COMMENT ON COLUMN sa.table_x_qry_case_view.x_prevq_title IS 'Queue title';