CREATE OR REPLACE FORCE VIEW sa.table_qry_case_view (elm_objid,id_number,"OWNER",s_owner,"CONDITION",s_condition,status,s_status,title,s_title,site_name,s_site_name,first_name,s_first_name,last_name,s_last_name,"PRIORITY",s_priority,severity,s_severity,"TYPE",s_type,is_supercase,supercase_num,x_carrier_id,x_carrier_name,x_esn,x_min,creation_time,x_state,s_x_state,x_zipcode,victimcase_x_case_type,contact_objid,x_phone_model,x_retailer_name,x_activation_zip) AS
select table_victimcase.objid, table_victimcase.id_number,
 table_owner.login_name, table_owner.S_login_name, table_condition.title, table_condition.S_title,
 table_gse_status.title, table_gse_status.S_title, table_victimcase.title, table_victimcase.S_title,
 table_site.name, table_site.S_name, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_gse_priority.title, table_gse_priority.S_title,
 table_gse_severity.title, table_gse_severity.S_title, table_gse_type.title, table_gse_type.S_title,
 table_victimcase.is_supercase, table_victimcase.id_number, --table_supercase.id_number
 table_victimcase.x_text_car_id, table_victimcase.x_carrier_name,
 table_victimcase.x_esn, table_victimcase.x_min,
 table_victimcase.creation_time, table_address.state, table_address.S_state,
 table_address.zipcode, table_victimcase.x_case_type,
 table_contact.objid, table_victimcase.x_phone_model,
 table_victimcase.x_retailer_name, table_victimcase.x_activation_zip
 from table_case table_victimcase, table_gbst_elm table_gse_priority, table_gbst_elm table_gse_severity, table_gbst_elm table_gse_status, table_gbst_elm table_gse_type, table_user table_owner, table_condition, table_site, table_contact,
  table_address
 where table_condition.objid = table_victimcase.case_state2condition
 AND table_gse_type.objid = table_victimcase.calltype2gbst_elm
 AND table_gse_priority.objid = table_victimcase.respprty2gbst_elm
 AND table_site.objid = table_victimcase.case_reporter2site
 AND table_address.objid = table_site.cust_primaddr2address
 AND table_gse_severity.objid = table_victimcase.respsvrty2gbst_elm
 AND table_owner.objid = table_victimcase.case_owner2user
 AND table_contact.objid = table_victimcase.case_reporter2contact
 AND table_gse_status.objid = table_victimcase.casests2gbst_elm;
COMMENT ON TABLE sa.table_qry_case_view IS 'Used by form Cases from Query (807)';
COMMENT ON COLUMN sa.table_qry_case_view.elm_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_qry_case_view.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_qry_case_view."OWNER" IS 'User login name';
COMMENT ON COLUMN sa.table_qry_case_view."CONDITION" IS 'Condition of the case';
COMMENT ON COLUMN sa.table_qry_case_view.status IS 'Status of the case';
COMMENT ON COLUMN sa.table_qry_case_view.title IS 'Case or service call title; summary of case details';
COMMENT ON COLUMN sa.table_qry_case_view.site_name IS 'Name of the reporting site';
COMMENT ON COLUMN sa.table_qry_case_view.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_qry_case_view.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_qry_case_view."PRIORITY" IS 'Priority of the case';
COMMENT ON COLUMN sa.table_qry_case_view.severity IS 'Severity of the case';
COMMENT ON COLUMN sa.table_qry_case_view."TYPE" IS 'Type of case';
COMMENT ON COLUMN sa.table_qry_case_view.is_supercase IS 'Flag if the case is a super case';
COMMENT ON COLUMN sa.table_qry_case_view.supercase_num IS 'Unique case number if it is related to a super case';
COMMENT ON COLUMN sa.table_qry_case_view.x_carrier_id IS 'Carrier ID stored as text from the case';
COMMENT ON COLUMN sa.table_qry_case_view.x_carrier_name IS 'Carrier Market/Submarket Name';
COMMENT ON COLUMN sa.table_qry_case_view.x_esn IS 'Serial Number of the Phone for Wireless or Service Id for Wireline';
COMMENT ON COLUMN sa.table_qry_case_view.x_min IS 'Line Number/Phone Number';
COMMENT ON COLUMN sa.table_qry_case_view.creation_time IS 'The date and time the case was created';
COMMENT ON COLUMN sa.table_qry_case_view.x_state IS 'The state for the specified address';
COMMENT ON COLUMN sa.table_qry_case_view.x_zipcode IS 'The zip or other postal code for the specified address';
COMMENT ON COLUMN sa.table_qry_case_view.victimcase_x_case_type IS 'Case type';
COMMENT ON COLUMN sa.table_qry_case_view.contact_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_qry_case_view.x_phone_model IS 'Phone Model Number';
COMMENT ON COLUMN sa.table_qry_case_view.x_retailer_name IS 'Retailer name';
COMMENT ON COLUMN sa.table_qry_case_view.x_activation_zip IS 'Zip where phone will be activated';