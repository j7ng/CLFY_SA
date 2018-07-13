CREATE OR REPLACE function sa.clean_data_sqa_byop(p_pn_esn in varchar2)  return varchar2
is
   V_Esn Varchar2(30) := p_pn_esn;

BEGIN


  DELETE FROM table_x_ota_features
  WHERE X_OTA_FEATURES2PART_INST IN (SELECT objid FROM table_part_inst WHERE part_serial_no = v_esn);
  DELETE FROM table_site_part WHERE x_service_id = v_esn;
  DELETE FROM table_x_call_trans WHERE x_service_id = v_esn;
  DELETE FROM ig_transaction WHERE ig_transaction.ESN = v_esn and CREATION_DATE > sysdate - 15;
  DELETE FROM TABLE_X_OTA_TRANSACTION WHERE X_ESN = v_esn;
  DELETE FROM TABLE_X_PSMS_OUTBOX WHERE X_ESN = v_esn;
  delete from table_case where x_esn =v_esn;
  delete from table_x_group2esn where groupesn2part_inst in (select objid from table_part_inst where part_serial_no = v_esn);
  DELETE FROM x_program_enrolled WHERE x_esn = v_esn;
  delete from table_x_contact_part_inst  WHERE x_contact_part_inst2part_inst in (select objid from table_part_inst where part_serial_no= v_ESN);
  DELETE FROM table_x_ild_transaction WHERE x_esn = v_esn;
  DELETE FROM table_part_inst WHERE part_serial_no = v_esn;
  DELETE FROM table_x_ota_features WHERE X_OTA_FEATURES2PART_INST IN (SELECT objid FROM table_part_inst WHERE part_serial_no = v_esn);
  delete from  gw1.test_ota_esn where gw1.test_ota_esn.esn = v_esn;
   delete from  sa.TEST_IGATE_ESN  where esn=v_esn;
  DELETE from TABLE_X_BYOP where x_esn=v_esn;
 commit;
return('ESN Removed: '||V_Esn);
END;
/