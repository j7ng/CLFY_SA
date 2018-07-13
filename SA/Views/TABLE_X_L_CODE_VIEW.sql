CREATE OR REPLACE FORCE VIEW sa.table_x_l_code_view (site_part_objid,instance_name,serial_no,s_serial_no,install_date,selected_prd,part_status,service_end_dt,x_service_id,x_min,x_pin,x_deact_reason,x_min_change_flag,x_notify_carrier,x_expire_dt,user_objid,login_name,s_login_name,contact_objid,first_name,s_first_name,last_name,s_last_name,phone,fax_number,e_mail,status,x_middle_initial,x_ss_number,x_dateofbirth,x_gender,x_mobilenumber,x_pagernumber,x_no_name_flag,x_no_address_flag,x_cust_id,x_call_objid,x_transact_date,x_sourcesystem,x_line_status,x_action_type,x_code_objid,x_gen_code,x_sequence) AS
select table_site_part.objid, table_site_part.instance_name,
 table_site_part.serial_no, table_site_part.S_serial_no, table_site_part.install_date,
 table_site_part.selected_prd, table_site_part.part_status,
 table_site_part.service_end_dt, table_site_part.x_service_id,
 table_site_part.x_min, table_site_part.x_pin,
 table_site_part.x_deact_reason, table_site_part.x_min_change_flag,
 table_site_part.x_notify_carrier, table_site_part.x_expire_dt,
 table_user.objid, table_user.login_name, table_user.S_login_name,
 table_contact.objid, table_contact.first_name, table_contact.S_first_name,
 table_contact.last_name, table_contact.S_last_name, table_contact.phone,
 table_contact.fax_number, table_contact.e_mail,
 table_contact.status, table_contact.x_middle_initial,
 table_contact.x_ss_number, table_contact.x_dateofbirth,
 table_contact.x_gender, table_contact.x_mobilenumber,
 table_contact.x_pagernumber, table_contact.x_no_name_flag,
 table_contact.x_no_address_flag, table_contact.x_cust_id,
 table_x_call_trans.objid, table_x_call_trans.x_transact_date,
 table_x_call_trans.x_sourcesystem, table_x_call_trans.x_line_status,
 table_x_call_trans.x_action_type, table_x_code_hist.objid,
 table_x_code_hist.x_gen_code, table_x_code_hist.x_sequence
 from mtm_site_part22_contact6, table_site_part, table_user, table_contact,
  table_x_call_trans, table_x_code_hist
 where table_site_part.objid = table_x_call_trans.call_trans2site_part
 AND table_x_call_trans.objid = table_x_code_hist.code_hist2call_trans
 AND table_user.objid = table_x_call_trans.x_call_trans2user
 AND table_site_part.objid = mtm_site_part22_contact6.site_part2contact
 AND mtm_site_part22_contact6.contact2site_part = table_contact.objid 
 ;
COMMENT ON TABLE sa.table_x_l_code_view IS 'Used to display Transaction and User info for each code given';
COMMENT ON COLUMN sa.table_x_l_code_view.site_part_objid IS 'Site Part Internal record number';
COMMENT ON COLUMN sa.table_x_l_code_view.instance_name IS 'Default is the concatination of part name, part number, and part revision. May be customized';
COMMENT ON COLUMN sa.table_x_l_code_view.serial_no IS 'Installed part serial number';
COMMENT ON COLUMN sa.table_x_l_code_view.install_date IS 'Part installation date';
COMMENT ON COLUMN sa.table_x_l_code_view.selected_prd IS 'Selected product';
COMMENT ON COLUMN sa.table_x_l_code_view.part_status IS 'Active/Inactive/Obsolete';
COMMENT ON COLUMN sa.table_x_l_code_view.service_end_dt IS 'Last day part was/will be in service';
COMMENT ON COLUMN sa.table_x_l_code_view.x_service_id IS 'Serial Number of the Phone for Wireless or Service Id for Wireline';
COMMENT ON COLUMN sa.table_x_l_code_view.x_min IS 'Line Number/Phone Number';
COMMENT ON COLUMN sa.table_x_l_code_view.x_pin IS 'Personal Identification Number given by Manufacturer';
COMMENT ON COLUMN sa.table_x_l_code_view.x_deact_reason IS 'Deactivation Reason';
COMMENT ON COLUMN sa.table_x_l_code_view.x_min_change_flag IS 'Flag used to denote that the user needs a MIN Change due to Fraud or Area Code Change: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_x_l_code_view.x_notify_carrier IS 'Flag to notify carrier during deactivation: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_x_l_code_view.x_expire_dt IS 'Last day part was/will be in service';
COMMENT ON COLUMN sa.table_x_l_code_view.user_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_l_code_view.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_x_l_code_view.contact_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_l_code_view.first_name IS 'Contact s first name';
COMMENT ON COLUMN sa.table_x_l_code_view.last_name IS 'Contact s last name';
COMMENT ON COLUMN sa.table_x_l_code_view.phone IS 'Contact s phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_x_l_code_view.fax_number IS 'Contact s fax number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_x_l_code_view.e_mail IS 'Contact s electronic mail address';
COMMENT ON COLUMN sa.table_x_l_code_view.status IS 'Status of contact; i.e., active/inactive/obsolete';
COMMENT ON COLUMN sa.table_x_l_code_view.x_middle_initial IS 'Middle Inital';
COMMENT ON COLUMN sa.table_x_l_code_view.x_ss_number IS 'Social Security Number';
COMMENT ON COLUMN sa.table_x_l_code_view.x_dateofbirth IS 'Date of Birth';
COMMENT ON COLUMN sa.table_x_l_code_view.x_gender IS 'Gender of Customer (Male/Female)';
COMMENT ON COLUMN sa.table_x_l_code_view.x_mobilenumber IS 'Cellular Phone Number';
COMMENT ON COLUMN sa.table_x_l_code_view.x_pagernumber IS 'Pager Number';
COMMENT ON COLUMN sa.table_x_l_code_view.x_no_name_flag IS 'Flag that shows that name is not provided: 0=does not apply, 1=does apply';
COMMENT ON COLUMN sa.table_x_l_code_view.x_no_address_flag IS 'Flag that shows that address is not provided: 0=does not apply, 1=does apply';
COMMENT ON COLUMN sa.table_x_l_code_view.x_cust_id IS 'Unique customer number (populated from site_id for customers)';
COMMENT ON COLUMN sa.table_x_l_code_view.x_call_objid IS 'Call transaction internal record number';
COMMENT ON COLUMN sa.table_x_l_code_view.x_transact_date IS 'Date/Time on which Transaction occurred';
COMMENT ON COLUMN sa.table_x_l_code_view.x_sourcesystem IS 'Source System of the Transaction (CSR/IVR)';
COMMENT ON COLUMN sa.table_x_l_code_view.x_line_status IS 'Status of the Line (Active/Inactive)';
COMMENT ON COLUMN sa.table_x_l_code_view.x_action_type IS 'Type of action taken during the Transaction -- Activation/Deactivation';
COMMENT ON COLUMN sa.table_x_l_code_view.x_code_objid IS 'Code history internal record number';
COMMENT ON COLUMN sa.table_x_l_code_view.x_gen_code IS 'Code given to the phone';
COMMENT ON COLUMN sa.table_x_l_code_view.x_sequence IS 'sequence of the code given';