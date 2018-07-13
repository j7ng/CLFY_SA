CREATE OR REPLACE procedure sa.clean_esn_jt (v_esn varchar2) is
p_esn varchar2(30) :=v_esn ;
begin
Delete from table_x_group2esn where groupesn2part_inst in (select objid from table_part_inst where part_serial_no IN (p_esn));
DELETE FROM table_site_part WHERE x_service_id IN (p_esn);
DELETE FROM table_x_call_trans WHERE x_service_id IN (p_esn);
DELETE FROM TABLE_X_OTA_TRANSACTION WHERE X_ESN IN (p_esn);
DELETE FROM TABLE_X_PSMS_OUTBOX WHERE X_ESN IN (p_esn);
DELETE FROM table_case where x_esn IN (p_esn);
DELETE FROM table_x_ota_features WHERE X_OTA_FEATURES2PART_INST IN (SELECT objid FROM table_part_inst WHERE part_serial_no IN (p_esn));
DELETE FROM x_program_enrolled where x_esn IN (p_esn);
DELETE FROM table_x_contact_part_inst  WHERE x_contact_part_inst2part_inst in (select objid from table_part_inst where part_serial_no IN (p_esn));
DELETE FROM sa.table_x_byop where x_esn = p_esn;
delete from x_service_order_stage where esn = p_esn;
delete from x_account_group_member where esn= p_esn;
delete from x_soa_device_verification where x_esn = p_esn;
DELETE FROM table_part_inst WHERE part_serial_no = p_esn;
commit;
end;
/