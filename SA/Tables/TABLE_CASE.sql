CREATE TABLE sa.table_case (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  id_number VARCHAR2(255 BYTE),
  creation_time DATE,
  internal_case NUMBER,
  hangup_time DATE,
  alt_phone_num VARCHAR2(20 BYTE),
  phone_num VARCHAR2(20 BYTE),
  pickup_ext VARCHAR2(8 BYTE),
  case_history LONG,
  topics_title VARCHAR2(255 BYTE),
  yank_flag NUMBER,
  server_status VARCHAR2(2 BYTE),
  support_type VARCHAR2(2 BYTE),
  warranty_flag VARCHAR2(2 BYTE),
  support_msg VARCHAR2(80 BYTE),
  alt_first_name VARCHAR2(30 BYTE),
  alt_last_name VARCHAR2(30 BYTE),
  alt_fax_number VARCHAR2(20 BYTE),
  alt_e_mail VARCHAR2(80 BYTE),
  alt_site_name VARCHAR2(80 BYTE),
  alt_address VARCHAR2(200 BYTE),
  alt_city VARCHAR2(30 BYTE),
  alt_state VARCHAR2(30 BYTE),
  alt_zipcode VARCHAR2(20 BYTE),
  fcs_cc_notify NUMBER,
  symptom_code VARCHAR2(10 BYTE),
  cure_code VARCHAR2(10 BYTE),
  site_time DATE,
  alt_prod_serial VARCHAR2(30 BYTE),
  msg_wait_count NUMBER,
  reply_wait_count NUMBER,
  reply_state NUMBER,
  oper_system VARCHAR2(20 BYTE),
  case_sup_type VARCHAR2(2 BYTE),
  payment_method VARCHAR2(30 BYTE),
  ref_number VARCHAR2(80 BYTE),
  doa_check_box NUMBER,
  customer_satis NUMBER,
  customer_code VARCHAR2(20 BYTE),
  service_id VARCHAR2(30 BYTE),
  alt_phone VARCHAR2(20 BYTE),
  forward_check NUMBER,
  cclist1 VARCHAR2(255 BYTE),
  cclist2 VARCHAR2(255 BYTE),
  keywords VARCHAR2(255 BYTE),
  ownership_stmp DATE,
  modify_stmp DATE,
  dist NUMBER,
  arch_ind NUMBER,
  is_supercase NUMBER,
  dev NUMBER,
  case_soln2workaround NUMBER,
  case_prevq2queue NUMBER,
  case_currq2queue NUMBER,
  case_wip2wipbin NUMBER,
  case_logic2prog_logic NUMBER,
  case_owner2user NUMBER,
  case_state2condition NUMBER,
  case_originator2user NUMBER,
  case_empl2employee NUMBER,
  calltype2gbst_elm NUMBER,
  respprty2gbst_elm NUMBER,
  respsvrty2gbst_elm NUMBER,
  case_prod2site_part NUMBER,
  case_reporter2site NUMBER,
  case_reporter2contact NUMBER,
  entitlement2contract NUMBER,
  casests2gbst_elm NUMBER,
  case_rip2ripbin NUMBER,
  covrd_ppi2site_part NUMBER,
  case_distr2site NUMBER,
  case2address NUMBER,
  case_node2site_part NUMBER,
  de_product2site_part NUMBER,
  case_prt2part_info NUMBER,
  de_prt2part_info NUMBER,
  alt_contact2contact NUMBER,
  task2opportunity NUMBER,
  case2life_cycle NUMBER,
  case_victim2case NUMBER,
  entitle2contr_itm NUMBER,
  x_case_type VARCHAR2(30 BYTE),
  x_carrier_id NUMBER,
  x_carrier_name VARCHAR2(30 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_phone_model VARCHAR2(30 BYTE),
  x_retailer_name VARCHAR2(80 BYTE),
  x_text_car_id VARCHAR2(10 BYTE),
  x_activation_zip VARCHAR2(20 BYTE),
  x_model VARCHAR2(20 BYTE),
  x_replacement_units NUMBER,
  x_require_return NUMBER,
  x_stock_type VARCHAR2(20 BYTE),
  x_case2task NUMBER,
  x_order_number VARCHAR2(7 BYTE),
  x_po_number VARCHAR2(30 BYTE),
  x_return_desc VARCHAR2(255 BYTE),
  x_waive_fee NUMBER,
  x_msid VARCHAR2(30 BYTE),
  case2blg_argmnt NUMBER,
  case2fin_accnt NUMBER,
  case2pay_channel NUMBER,
  case_type_lvl1 VARCHAR2(255 BYTE),
  case_type_lvl2 VARCHAR2(30 BYTE),
  case_type_lvl3 VARCHAR2(30 BYTE),
  x_iccid VARCHAR2(30 BYTE),
  x_repl_part_num VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_case ADD SUPPLEMENTAL LOG GROUP dmtsora1279253291_1 (alt_phone, arch_ind, calltype2gbst_elm, case_currq2queue, case_empl2employee, case_logic2prog_logic, case_originator2user, case_owner2user, case_prevq2queue, case_prod2site_part, case_reporter2site, case_soln2workaround, case_state2condition, case_sup_type, case_wip2wipbin, cclist1, cclist2, customer_code, customer_satis, dev, dist, doa_check_box, forward_check, is_supercase, keywords, modify_stmp, oper_system, ownership_stmp, payment_method, ref_number, respprty2gbst_elm, respsvrty2gbst_elm, service_id) ALWAYS;
ALTER TABLE sa.table_case ADD SUPPLEMENTAL LOG GROUP dmtsora1279253291_2 (alt_contact2contact, case2address, case2life_cycle, casests2gbst_elm, case_distr2site, case_node2site_part, case_prt2part_info, case_reporter2contact, case_rip2ripbin, case_victim2case, covrd_ppi2site_part, de_product2site_part, de_prt2part_info, entitle2contr_itm, entitlement2contract, task2opportunity, x_activation_zip, x_carrier_id, x_carrier_name, x_case2task, x_case_type, x_esn, x_min, x_model, x_order_number, x_phone_model, x_po_number, x_replacement_units, x_require_return, x_retailer_name, x_return_desc, x_stock_type, x_text_car_id) ALWAYS;
ALTER TABLE sa.table_case ADD SUPPLEMENTAL LOG GROUP dmtsora1279253291_3 (case2blg_argmnt, case2fin_accnt, case2pay_channel, case_type_lvl1, case_type_lvl2, case_type_lvl3, x_iccid, x_msid, x_repl_part_num, x_waive_fee) ALWAYS;
ALTER TABLE sa.table_case ADD SUPPLEMENTAL LOG GROUP dmtsora1279253291_0 (alt_address, alt_city, alt_e_mail, alt_fax_number, alt_first_name, alt_last_name, alt_phone_num, alt_prod_serial, alt_site_name, alt_state, alt_zipcode, creation_time, cure_code, fcs_cc_notify, hangup_time, id_number, internal_case, msg_wait_count, objid, phone_num, pickup_ext, reply_state, reply_wait_count, server_status, site_time, support_msg, support_type, symptom_code, s_title, title, topics_title, warranty_flag, yank_flag) ALWAYS;
COMMENT ON TABLE sa.table_case IS 'Main case object, contains details of service call information';
COMMENT ON COLUMN sa.table_case.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_case.title IS 'Case or service call title; summary of case details';
COMMENT ON COLUMN sa.table_case.id_number IS 'Unique case number assigned based on auto-numbering definition';
COMMENT ON COLUMN sa.table_case.creation_time IS 'The date and time the case was created';
COMMENT ON COLUMN sa.table_case.internal_case IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_case.hangup_time IS 'The date and time the initial case phone call was completed; recorded when dispatch or hang up command is executed';
COMMENT ON COLUMN sa.table_case.alt_phone_num IS 'The alternate phone number for the contact';
COMMENT ON COLUMN sa.table_case.phone_num IS 'The primary phone number for the contact; copied from contact object';
COMMENT ON COLUMN sa.table_case.pickup_ext IS 'The extension phone number of the employee taking the call which is used for ACD routing of the case information';
COMMENT ON COLUMN sa.table_case.case_history IS 'The multi-line field that contains the history of the case';
COMMENT ON COLUMN sa.table_case.topics_title IS 'Filled in automatically for ESS cases received through ClearServer. Reserved; custom';
COMMENT ON COLUMN sa.table_case.yank_flag IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_case.server_status IS 'Call server status. Reserved; custom';
COMMENT ON COLUMN sa.table_case.support_type IS 'Type of support the case site/contact is eligible for. Reserved; custom';
COMMENT ON COLUMN sa.table_case.warranty_flag IS 'Indicates whether the case subject is covered under warranty. Reserved; custom';
COMMENT ON COLUMN sa.table_case.support_msg IS 'Details of support coverage. Reserved; not used';
COMMENT ON COLUMN sa.table_case.alt_first_name IS 'Alternate contact first name. Reserved; custom';
COMMENT ON COLUMN sa.table_case.alt_last_name IS 'Alternate contact last name. Reserved; custom';
COMMENT ON COLUMN sa.table_case.alt_fax_number IS 'Alternate contact fax number. Reserved; custom';
COMMENT ON COLUMN sa.table_case.alt_e_mail IS 'Alternate contact email address. Reserved; custom';
COMMENT ON COLUMN sa.table_case.alt_site_name IS 'Alternate site name. Reserved; custom';
COMMENT ON COLUMN sa.table_case.alt_address IS 'Alternate site address. Reserved; custom';
COMMENT ON COLUMN sa.table_case.alt_city IS 'Alternate site city. Reserved; custom';
COMMENT ON COLUMN sa.table_case.alt_state IS 'Alternate site state. Reserved; custom';
COMMENT ON COLUMN sa.table_case.alt_zipcode IS 'Alternate site zip or other postal code. Reserved; custom';
COMMENT ON COLUMN sa.table_case.fcs_cc_notify IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_case.symptom_code IS 'Problem symptom code. Reserved; not used';
COMMENT ON COLUMN sa.table_case.cure_code IS 'Problem cure code. Reserved; custom';
COMMENT ON COLUMN sa.table_case.site_time IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_case.alt_prod_serial IS 'Serial number for alternate product. Reserved; custom';
COMMENT ON COLUMN sa.table_case.msg_wait_count IS 'Number of IVR messages waiting. Reserved; not used';
COMMENT ON COLUMN sa.table_case.reply_wait_count IS 'Number of IVR messages waiting. Reserved; not used';
COMMENT ON COLUMN sa.table_case.reply_state IS 'State of customer reply; i.e., 0=no first replay, 1=first reply done. Reserved; not used';
COMMENT ON COLUMN sa.table_case.oper_system IS 'Operating system. Reserved; not used';
COMMENT ON COLUMN sa.table_case.case_sup_type IS 'Level of support customer is eligible for. Reserved; not used';
COMMENT ON COLUMN sa.table_case.payment_method IS 'Method by which customer will pay for call. Reserved; custom';
COMMENT ON COLUMN sa.table_case.ref_number IS 'Reference number; e.g., credit card #, check #, etc.; for payment method. Reserved; custom';
COMMENT ON COLUMN sa.table_case.doa_check_box IS 'Check indicates part was dead on arrival. Reserved; custom';
COMMENT ON COLUMN sa.table_case.customer_satis IS 'Check indicates a customer satisfaction issue to be reviewed. Reserved; not used';
COMMENT ON COLUMN sa.table_case.customer_code IS 'Customer classification code. Reserved; custom';
COMMENT ON COLUMN sa.table_case.service_id IS 'Service or support ID number. Reserved; not used';
COMMENT ON COLUMN sa.table_case.alt_phone IS 'Case alternate phone number. Reserved; custom';
COMMENT ON COLUMN sa.table_case.forward_check IS 'Checked indicates forward operation tried';
COMMENT ON COLUMN sa.table_case.cclist1 IS 'Recipient on carbon copy list 1';
COMMENT ON COLUMN sa.table_case.cclist2 IS 'Recipient on carbon copy list 2';
COMMENT ON COLUMN sa.table_case.keywords IS 'Keywords for the case; used with FTS';
COMMENT ON COLUMN sa.table_case.ownership_stmp IS 'The date and time when ownership changed; reserved, not used';
COMMENT ON COLUMN sa.table_case.modify_stmp IS 'The date and time when object was last saved';
COMMENT ON COLUMN sa.table_case.dist IS 'Used by ELINK to indicate extrnal creation source of case';
COMMENT ON COLUMN sa.table_case.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_case.is_supercase IS 'Indicates whether the case is a super or a victim case; i.e., 0=normal or victim case, 1=supercase';
COMMENT ON COLUMN sa.table_case.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_case.case_soln2workaround IS 'Workaround that is applicable to the case';
COMMENT ON COLUMN sa.table_case.case_prevq2queue IS 'Used to record which queue case was accepted from; for temporary accept';
COMMENT ON COLUMN sa.table_case.case_currq2queue IS 'The queue the case is currently dispatched to';
COMMENT ON COLUMN sa.table_case.case_wip2wipbin IS 'The WIPbin the case is accepted into';
COMMENT ON COLUMN sa.table_case.case_logic2prog_logic IS 'Internal logic which determines applicable solution/workaround. Reserved; not used';
COMMENT ON COLUMN sa.table_case.case_owner2user IS 'User that owns the case';
COMMENT ON COLUMN sa.table_case.case_state2condition IS 'The condition of the case';
COMMENT ON COLUMN sa.table_case.case_originator2user IS 'User that originated the case';
COMMENT ON COLUMN sa.table_case.case_empl2employee IS 'Employee who created the case. Reserved; obsolete';
COMMENT ON COLUMN sa.table_case.calltype2gbst_elm IS 'Call type of case:  This is a Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_case.respprty2gbst_elm IS 'Response priority of case: This is a Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_case.respsvrty2gbst_elm IS 'Response severity of case: This is a Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_case.case_prod2site_part IS 'Installed part the caller is calling about';
COMMENT ON COLUMN sa.table_case.case_reporter2site IS 'Reporting customer site';
COMMENT ON COLUMN sa.table_case.case_reporter2contact IS 'Reporting customer contact for the case';
COMMENT ON COLUMN sa.table_case.entitlement2contract IS 'Contract for part that caller is reporting';
COMMENT ON COLUMN sa.table_case.casests2gbst_elm IS 'Case status: This is a Clarify-defined pop up list';
COMMENT ON COLUMN sa.table_case.case_rip2ripbin IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_case.covrd_ppi2site_part IS 'Service-entitled part for case';
COMMENT ON COLUMN sa.table_case.case_distr2site IS 'Reseller site related to the case';
COMMENT ON COLUMN sa.table_case.case2address IS 'Reporting site address';
COMMENT ON COLUMN sa.table_case.case_node2site_part IS 'System-level installed part for case';
COMMENT ON COLUMN sa.table_case.de_product2site_part IS 'Installed part used for diagnosis';
COMMENT ON COLUMN sa.table_case.case_prt2part_info IS 'Problem part revision selected for the case';
COMMENT ON COLUMN sa.table_case.de_prt2part_info IS 'Catalog (generic) part selection for case (DE) part';
COMMENT ON COLUMN sa.table_case.alt_contact2contact IS 'Alternate contact for the case';
COMMENT ON COLUMN sa.table_case.task2opportunity IS 'Reserved; future';
COMMENT ON COLUMN sa.table_case.case2life_cycle IS 'Reserved; future';
COMMENT ON COLUMN sa.table_case.case_victim2case IS 'Super case owner of the case';
COMMENT ON COLUMN sa.table_case.entitle2contr_itm IS 'Contract item that entitles service';
COMMENT ON COLUMN sa.table_case.x_case_type IS 'Case type';
COMMENT ON COLUMN sa.table_case.x_carrier_id IS 'Carrier Market Identification Number';
COMMENT ON COLUMN sa.table_case.x_carrier_name IS 'Carrier Market/Submarket Name';
COMMENT ON COLUMN sa.table_case.x_esn IS 'Serial Number of the Phone for Wireless or Service Id for Wireline';
COMMENT ON COLUMN sa.table_case.x_min IS 'Line Number/Phone Number';
COMMENT ON COLUMN sa.table_case.x_phone_model IS 'Phone Model Number';
COMMENT ON COLUMN sa.table_case.x_retailer_name IS 'Retailer name';
COMMENT ON COLUMN sa.table_case.x_text_car_id IS 'Carrier ID stored as text';
COMMENT ON COLUMN sa.table_case.x_activation_zip IS 'Zip where phone will be activated';
COMMENT ON COLUMN sa.table_case.x_model IS 'Replacement phone model';
COMMENT ON COLUMN sa.table_case.x_replacement_units IS 'Replacement units';
COMMENT ON COLUMN sa.table_case.x_require_return IS 'ALR - 04/16/01 Added flag for exchanges requiring returns';
COMMENT ON COLUMN sa.table_case.x_stock_type IS 'A or B for type of replacement';
COMMENT ON COLUMN sa.table_case.x_case2task IS 'Relation to task for Feature failures';
COMMENT ON COLUMN sa.table_case.x_order_number IS 'Direct Sales - Order Number';
COMMENT ON COLUMN sa.table_case.x_po_number IS 'Direct Sales - Purchase Order Number';
COMMENT ON COLUMN sa.table_case.x_return_desc IS 'Direct Sales - Return Description';
COMMENT ON COLUMN sa.table_case.x_waive_fee IS 'Direct Sales - Waive re-stocking fee checkbox';
COMMENT ON COLUMN sa.table_case.x_msid IS 'MSID';
COMMENT ON COLUMN sa.table_case.case2blg_argmnt IS 'Billing arrangement used by a case';
COMMENT ON COLUMN sa.table_case.case2fin_accnt IS 'Financial account used by a case';
COMMENT ON COLUMN sa.table_case.case2pay_channel IS 'Pay channel used by a case';
COMMENT ON COLUMN sa.table_case.case_type_lvl1 IS 'Multi-level case type - level1';
COMMENT ON COLUMN sa.table_case.case_type_lvl2 IS 'Multi-level case type - level2';
COMMENT ON COLUMN sa.table_case.case_type_lvl3 IS 'Multi-level case type - level3';
COMMENT ON COLUMN sa.table_case.x_iccid IS 'SIM Serial Number';
COMMENT ON COLUMN sa.table_case.x_repl_part_num IS 'Handset Exch Part Number(Technology Exch) or SIM Exch Part Number(SIM Exch)';