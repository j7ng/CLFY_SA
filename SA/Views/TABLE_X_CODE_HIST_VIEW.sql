CREATE OR REPLACE FORCE VIEW sa.table_x_code_hist_view (site_part_objid,instance_name,serial_no,s_serial_no,x_iccid,install_date,part_status,service_end_dt,x_service_id,x_min,x_pin,x_deact_reason,x_min_change_flag,x_notify_carrier,x_expire_dt,user_objid,login_name,s_login_name,contact_objid,first_name,s_first_name,last_name,s_last_name,phone,fax_number,e_mail,status,x_middle_initial,x_ss_number,x_dateofbirth,x_no_name_flag,x_no_address_flag,x_cust_id,x_contactrole_objid,x_site_objid,x_site_id,x_site_name,s_x_site_name,x_site_type,x_site_status,x_call_objid,x_transact_date,x_sourcesystem,x_line_status,x_action_type,x_action_text,x_total_units,x_reason,x_result,x_code_objid,x_gen_code,x_sequence,x_code_accepted,x_code_type,x_new_due_date) AS
SELECT table_site_part.objid, table_site_part.instance_name,
          table_site_part.serial_no, table_site_part.s_serial_no,
          table_site_part.x_iccid, table_site_part.install_date,
          table_site_part.part_status, table_site_part.service_end_dt,
          table_site_part.x_service_id, table_site_part.x_min,
          table_site_part.x_pin, table_site_part.x_deact_reason,
          table_site_part.x_min_change_flag, table_site_part.x_notify_carrier,
          table_site_part.x_expire_dt, table_user.objid,
          table_user.login_name, table_user.s_login_name, table_contact.objid,
          table_contact.first_name, table_contact.s_first_name,
          table_contact.last_name, table_contact.s_last_name,
          table_contact.phone, table_contact.fax_number, table_contact.e_mail,
          table_contact.status, table_contact.x_middle_initial,
          table_contact.x_ss_number, table_contact.x_dateofbirth,
          table_contact.x_no_name_flag, table_contact.x_no_address_flag,
          table_contact.x_cust_id, table_contact_role.objid, table_site.objid,
          table_site.site_id, table_site.NAME, table_site.s_name,
          table_site.TYPE, table_site.status, table_x_call_trans.objid,
          table_x_call_trans.x_transact_date,
          table_x_call_trans.x_sourcesystem, table_x_call_trans.x_line_status,
          table_x_call_trans.x_action_type, table_x_call_trans.x_action_text,
          table_x_call_trans.x_total_units, table_x_call_trans.x_reason,
          table_x_call_trans.x_result, table_x_code_hist.objid,
          table_x_code_hist.x_gen_code, table_x_code_hist.x_sequence,
          table_x_code_hist.x_code_accepted, table_x_code_hist.x_code_type,
          table_x_call_trans.x_new_due_date
     FROM table_site_part,
          table_user,
          table_contact,
          table_contact_role,
          table_site,
          table_x_call_trans,
          table_x_code_hist
    WHERE table_site.objid = table_contact_role.contact_role2site
      AND table_site.objid = table_site_part.site_part2site
      AND table_contact.objid = table_contact_role.contact_role2contact
      AND table_user.objid = table_x_call_trans.x_call_trans2user
      AND table_x_call_trans.objid = table_x_code_hist.code_hist2call_trans
      AND table_site_part.objid = table_x_call_trans.call_trans2site_part;
COMMENT ON TABLE sa.table_x_code_hist_view IS 'Used to display Transaction and User info for each code given';
COMMENT ON COLUMN sa.table_x_code_hist_view.site_part_objid IS 'Site Part Internal record number';
COMMENT ON COLUMN sa.table_x_code_hist_view.instance_name IS 'Default is the concatination of part name, part number, and part revision. May be customized';
COMMENT ON COLUMN sa.table_x_code_hist_view.serial_no IS 'Installed part serial number';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_iccid IS 'iccid';
COMMENT ON COLUMN sa.table_x_code_hist_view.install_date IS 'Part installation date';
COMMENT ON COLUMN sa.table_x_code_hist_view.part_status IS 'Active/Inactive/Obsolete';
COMMENT ON COLUMN sa.table_x_code_hist_view.service_end_dt IS 'Last day part was/will be in service';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_service_id IS 'Serial Number of the Phone for Wireless or Service Id for Wireline';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_min IS 'Line Number/Phone Number';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_pin IS 'Personal Identification Number given by Manufacturer';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_deact_reason IS 'Deactivation Reason';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_min_change_flag IS 'Flag used to denote that the user needs a MIN Change due to Fraud or Area Code Change: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_notify_carrier IS 'Flag to notify carrier during deactivation: 0=no, 1=yes';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_expire_dt IS 'Last day part was/will be in service';
COMMENT ON COLUMN sa.table_x_code_hist_view.user_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_code_hist_view.login_name IS 'User login name';
COMMENT ON COLUMN sa.table_x_code_hist_view.contact_objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_code_hist_view.first_name IS 'Contact s first name';
COMMENT ON COLUMN sa.table_x_code_hist_view.last_name IS 'Contact s last name';
COMMENT ON COLUMN sa.table_x_code_hist_view.phone IS 'Contact s phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_x_code_hist_view.fax_number IS 'Contact s fax number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_x_code_hist_view.e_mail IS 'Contact s electronic mail address';
COMMENT ON COLUMN sa.table_x_code_hist_view.status IS 'Status of contact; i.e., active/inactive/obsolete';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_middle_initial IS 'Middle Inital';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_ss_number IS 'Social Security Number';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_dateofbirth IS 'Date of Birth';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_no_name_flag IS 'Flag that shows that name is not provided: 0=does not apply, 1=does apply';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_no_address_flag IS 'Flag that shows that address is not provided: 0=does not apply, 1=does apply';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_cust_id IS 'Unique customer number (populated from site_id for customers)';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_contactrole_objid IS 'Contact Role internal record number';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_site_objid IS 'Customer Site internal record number';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_site_id IS 'Unique site number (populates cust_id for customers)';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_site_name IS 'Site name';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_site_type IS 'Site type';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_site_status IS 'Site status';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_call_objid IS 'Call transaction internal record number';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_transact_date IS 'Date/Time on which Transaction occurred';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_sourcesystem IS 'Source System of the Transaction (CSR/IVR)';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_line_status IS 'Status of the Line (Active/Inactive)';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_action_type IS 'Type of action taken during the Transaction -- Activation/Deactivation';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_action_text IS 'Text of transaction action type';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_total_units IS 'Total units redeemed in this transaction';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_reason IS 'Additional reason for particular transaction action type';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_result IS 'Result of call transaction, i.e. Completed or Failed';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_code_objid IS 'Code history internal record number';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_gen_code IS 'Code given to the phone';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_sequence IS 'sequence of the code given';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_code_accepted IS 'YES/NO if the code was accepted into the phone';
COMMENT ON COLUMN sa.table_x_code_hist_view.x_code_type IS 'The type of code being inserted, from the table_x_code_hist_temp';