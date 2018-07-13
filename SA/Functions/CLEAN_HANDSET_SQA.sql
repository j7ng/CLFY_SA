CREATE OR REPLACE function sa.clean_handset_sqa(p_pn_esn in varchar2)  return varchar2
is
   V_ESN Varchar2(30) := p_pn_esn;      
BEGIN
DELETE FROM table_site_part WHERE x_service_id IN (V_ESN);
DELETE FROM table_x_call_trans WHERE x_service_id IN (V_ESN);
UPDATE table_part_inst SET part_to_esn2part_inst = NULL WHERE part_to_esn2part_inst IN (SELECT objid FROM table_part_inst WHERE part_serial_no IN (V_ESN));
DELETE FROM ig_transaction WHERE ESN IN (V_ESN);
DELETE FROM TABLE_X_OTA_TRANSACTION WHERE X_ESN IN (V_ESN);
DELETE FROM TABLE_X_PSMS_OUTBOX WHERE X_ESN IN (V_ESN);
DELETE FROM table_case where x_esn IN (V_ESN);
update table_part_inst set x_Part_inst2contact = null,x_part_inst_status='50',status2x_code_table = '986' where part_serial_no IN (V_ESN);
delete from table_x_group2esn where groupesn2part_inst in (select objid from table_part_inst where part_serial_no IN (V_ESN));
update table_part_inst set warr_end_date = null, x_iccid = null, last_trans_time = '01-JAN-53', part_inst2x_pers = null, x_part_inst2site_part = null, 
x_reactivation_flag = null where part_serial_no IN (V_ESN);
DELETE FROM x_program_enrolled where x_esn IN (V_ESN);
DELETE FROM table_web_user where web_user2contact in (select x_Part_inst2contact from table_part_inst where part_serial_no IN (V_ESN));
DELETE FROM table_x_contact_part_inst  WHERE x_contact_part_inst2part_inst in (select objid from table_part_inst where part_serial_no IN (V_ESN));
update table_part_inst set X_Port_In = '0' where part_serial_no in (V_ESN);
commit;
DELETE FROM table_site_part WHERE x_service_id IN (V_ESN);
DELETE FROM table_x_call_trans WHERE x_service_id IN (V_ESN);
UPDATE table_part_inst SET part_to_esn2part_inst = NULL WHERE part_to_esn2part_inst IN (SELECT objid FROM table_part_inst WHERE part_serial_no IN (V_ESN));
DELETE FROM ig_transaction WHERE ESN IN (V_ESN);
DELETE FROM TABLE_X_OTA_TRANSACTION WHERE X_ESN IN (V_ESN);
DELETE FROM TABLE_X_PSMS_OUTBOX WHERE X_ESN IN (V_ESN);
DELETE FROM table_case where x_esn IN (V_ESN);
update table_part_inst set x_Part_inst2contact = null,x_part_inst_status='50',status2x_code_table = '986' where part_serial_no IN (V_ESN);
delete from table_x_group2esn where groupesn2part_inst in (select objid from table_part_inst where part_serial_no IN (V_ESN));
update table_part_inst set warr_end_date = null, x_iccid = null, last_trans_time = '01-JAN-53', part_inst2x_pers = null, x_part_inst2site_part = null, 
x_reactivation_flag = null where part_serial_no IN (V_ESN);
DELETE FROM x_program_enrolled where x_esn IN (V_ESN);
DELETE FROM table_web_user where web_user2contact in (select x_Part_inst2contact from table_part_inst where part_serial_no IN (V_ESN));
DELETE FROM table_x_contact_part_inst  WHERE x_contact_part_inst2part_inst in (select objid from table_part_inst where part_serial_no IN (V_ESN));
update table_part_inst set X_Port_In = '0' where part_serial_no in (V_ESN);
commit;
DELETE FROM table_site_part WHERE x_service_id IN (V_ESN);
DELETE FROM table_x_call_trans WHERE x_service_id IN (V_ESN);
UPDATE table_part_inst SET part_to_esn2part_inst = NULL WHERE part_to_esn2part_inst IN (SELECT objid FROM table_part_inst WHERE part_serial_no IN (V_ESN));
DELETE FROM ig_transaction WHERE ESN IN (V_ESN);
DELETE FROM TABLE_X_OTA_TRANSACTION WHERE X_ESN IN (V_ESN);
DELETE FROM TABLE_X_PSMS_OUTBOX WHERE X_ESN IN (V_ESN);
DELETE FROM table_case where x_esn IN (V_ESN);
update table_part_inst set x_Part_inst2contact = null,x_part_inst_status='50',status2x_code_table = '986' where part_serial_no IN (V_ESN);
delete from table_x_group2esn where groupesn2part_inst in (select objid from table_part_inst where part_serial_no IN (V_ESN));
update table_part_inst set warr_end_date = null, x_iccid = null, last_trans_time = '01-JAN-53', part_inst2x_pers = null, x_part_inst2site_part = null, 
x_reactivation_flag = null where part_serial_no IN (V_ESN);
DELETE FROM x_program_enrolled where x_esn IN (V_ESN);
DELETE FROM table_web_user where web_user2contact in (select x_Part_inst2contact from table_part_inst where part_serial_no IN (V_ESN));
DELETE FROM table_x_contact_part_inst  WHERE x_contact_part_inst2part_inst in (select objid from table_part_inst where part_serial_no IN (V_ESN));
DELETE FROM x_program_gencode where x_esn IN (V_ESN);
update table_part_inst set X_Port_In = '0' where part_serial_no in (V_ESN);
 commit;
return('ESN Removed: '||V_ESN);
END;
/