CREATE OR REPLACE FORCE VIEW sa.table_wap_case_info (objid,id_number,title,s_title,"CONDITION",wipbin_title,s_wipbin_title,queue_title,s_queue_title,login_name,s_login_name,originator_phone,owner_phone,case_type,s_case_type,case_priority,s_case_priority,case_severity,s_case_severity,instance_name,contract_type,site_name,s_site_name,site_id,address,s_address,address_2,city,s_city,"STATE",s_state,zip_code,first_name,s_first_name,last_name,s_last_name,contact_phone) AS
select table_case.objid, table_case.id_number,
 table_case.title, table_case.S_title, table_condition.condition,
 table_wipbin.title, table_wipbin.S_title, table_queue.title, table_queue.S_title,
 table_e.login_name, table_e.S_login_name, table_f.phone,
 table_h.phone, table_a.title, table_a.S_title,
 table_b.title, table_b.S_title, table_c.title, table_c.S_title,
 table_site_part.instance_name, table_contract.type,
 table_site.name, table_site.S_name, table_site.site_id,
 table_address.address, table_address.S_address, table_address.address_2,
 table_address.city, table_address.S_city, table_address.state, table_address.S_state,
 table_address.zipcode, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.phone
 from table_employee table_f, table_employee table_h, table_gbst_elm table_a, table_gbst_elm table_b, table_gbst_elm table_c, table_user table_e, table_user table_g, table_case, table_condition, table_wipbin,
  table_queue, table_site_part, table_contract,
  table_site, table_address, table_contact
 where table_contract.objid (+) = table_case.entitlement2contract
 AND table_g.objid = table_h.employee2user
 AND table_site.objid = table_case.case_reporter2site
 AND table_a.objid = table_case.calltype2gbst_elm
 AND table_wipbin.objid = table_case.case_wip2wipbin
 AND table_condition.objid = table_case.case_state2condition
 AND table_queue.objid (+) = table_case.case_currq2queue
 AND table_site_part.objid (+) = table_case.case_prod2site_part
 AND table_c.objid = table_case.respsvrty2gbst_elm
 AND table_g.objid = table_case.case_owner2user
 AND table_b.objid = table_case.respprty2gbst_elm
 AND table_address.objid = table_case.case2address
 AND table_e.objid = table_f.employee2user
 AND table_contact.objid = table_case.case_reporter2contact
 AND table_e.objid = table_case.case_originator2user
 ;
COMMENT ON TABLE sa.table_wap_case_info IS 'WAP case Information';
COMMENT ON COLUMN sa.table_wap_case_info.objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_wap_case_info.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_wap_case_info.title IS 'Case or service call title; summary of case details';
COMMENT ON COLUMN sa.table_wap_case_info."CONDITION" IS 'The condition of the case';
COMMENT ON COLUMN sa.table_wap_case_info.wipbin_title IS 'Name of the case s wipbin';
COMMENT ON COLUMN sa.table_wap_case_info.queue_title IS 'Name of the case s queue';
COMMENT ON COLUMN sa.table_wap_case_info.login_name IS 'Database login of the user';
COMMENT ON COLUMN sa.table_wap_case_info.originator_phone IS 'Phone number of the case originator';
COMMENT ON COLUMN sa.table_wap_case_info.owner_phone IS 'Phone number of the case owner';
COMMENT ON COLUMN sa.table_wap_case_info.case_type IS 'Call type of case: This is a Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_wap_case_info.case_priority IS 'Response priority of case: This is a Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_wap_case_info.case_severity IS 'Response severity of case: This is a Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_wap_case_info.instance_name IS 'Name of the part instance the case is about';
COMMENT ON COLUMN sa.table_wap_case_info.contract_type IS 'The specific nature of the contract-standard. This is a user-defined pop up list with default name of CONTRACT_TYPE';
COMMENT ON COLUMN sa.table_wap_case_info.site_name IS 'Name of the site reporting the case';
COMMENT ON COLUMN sa.table_wap_case_info.site_id IS 'Unique identifier of the site reporting the case';
COMMENT ON COLUMN sa.table_wap_case_info.address IS 'Line 1 of site address which includes street number, street name, office, building, or suite number, etc';
COMMENT ON COLUMN sa.table_wap_case_info.address_2 IS 'Line 2 of the site address which typically includes office, building, or suite number, etc';
COMMENT ON COLUMN sa.table_wap_case_info.city IS 'The city for the specified address';
COMMENT ON COLUMN sa.table_wap_case_info."STATE" IS 'The state for the specified address';
COMMENT ON COLUMN sa.table_wap_case_info.zip_code IS 'The state for the specified address';
COMMENT ON COLUMN sa.table_wap_case_info.first_name IS 'First name of the case contact';
COMMENT ON COLUMN sa.table_wap_case_info.last_name IS 'Last name of the case contact';
COMMENT ON COLUMN sa.table_wap_case_info.contact_phone IS 'Phone number of the case contact';