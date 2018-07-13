CREATE OR REPLACE function sa.get_data_sqa_gsm(p_esn in varchar2, p_pn_esn in varchar2,p_sequence in number,p_sim in varchar2,p_pn_sim in varchar2 )  return varchar2
is
    v_ESN VARCHAR2(30):=p_esn; -- SERIAL NUMBER TO YOUR LEFT (IN BLUE)
   partnumber VARCHAR2(30):=p_pn_esn; -- PHONE MODEL TO YOUR LEFT (IN BLUE)
   esn_sequence number:=p_sequence ; --  NUMBER TO YOUR LEFT (IN GREEN)
   sim VARCHAR2(30):=p_sim ; -- GSM ONLY // SIM CARD SERIAL NUMBER TO YOUR LEFT
   simpart VARCHAR2(30):=p_pn_sim; -- GSM ONLY // SIM CARD MODEL # TO YOUR LEFT (TF64SIMT5 - TMOBILE // TF64SIMC4 - ATT-CINGULAR)
   DUMMYESN VARCHAR2(30);
   DUMMYsim VARCHAR2(30);
BEGIN
  DUMMYESN:= sa.GET_TEST_ESN(PARTNUMBER);
  DUMMYSIM:= sa.get_test_sim(SIMPART);
  DELETE FROM table_x_ota_features 
  WHERE X_OTA_FEATURES2PART_INST IN (SELECT objid FROM table_part_inst WHERE part_serial_no = v_esn);
  DELETE FROM table_x_sim_inv WHERE x_sim_serial_no = sim;
  DELETE FROM table_site_part WHERE x_service_id = v_esn;
  DELETE FROM table_x_call_trans WHERE x_service_id = v_esn;
  DELETE FROM ig_transaction WHERE ig_transaction.ESN = v_esn  and CREATION_DATE > sysdate - 30;
  DELETE FROM TABLE_X_OTA_TRANSACTION WHERE X_ESN = v_esn;
  DELETE FROM TABLE_X_PSMS_OUTBOX WHERE X_ESN = v_esn;
  delete from table_case where x_esn =v_esn;
  delete from table_x_group2esn where groupesn2part_inst in (select objid from table_part_inst where part_serial_no = v_esn);
  DELETE FROM x_program_enrolled WHERE x_esn = v_esn;
  delete from table_x_contact_part_inst  WHERE x_contact_part_inst2part_inst in (select objid from table_part_inst where part_serial_no= v_ESN);
  DELETE FROM table_x_ild_transaction WHERE x_esn = v_esn;
  DELETE FROM table_part_inst WHERE part_serial_no = v_esn;
  DELETE FROM table_x_ota_features 
  WHERE X_OTA_FEATURES2PART_INST IN (SELECT objid FROM table_part_inst WHERE part_serial_no = DUMMYESN);
  UPDATE table_part_inst
  SET part_serial_no = v_esn,x_sequence=esn_sequence
  WHERE part_serial_no = dummyesn;
  UPDATE table_x_sim_inv
  SET x_sim_serial_no = sim
  where x_sim_serial_no = dummysim;
  update table_part_inst
  set x_iccid = sim
  where part_serial_no = v_esn;
  delete from  gw1.test_ota_esn where gw1.test_ota_esn.esn = v_esn;
  insert into gw1.test_ota_esn values (v_esn);
  INSERT INTO TABLE_X_OTA_FEATURES ( OBJID, DEV, X_REDEMPTION_MENU, X_HANDSET_LOCK, X_LOW_UNITS,
  X_OTA_FEATURES2PART_NUM, X_OTA_FEATURES2PART_INST, X_PSMS_DESTINATION_ADDR, X_ILD_ACCOUNT,
  X_ILD_CARR_STATUS, X_ILD_PROG_STATUS, X_ILD_COUNTER, X_CURRENT_CONV_RATE,
  X_CLOSE_COUNT ) VALUES ( 
  sa.seq('x_ota_features'), NULL, 'N', 'Y', 'N', NULL, (SELECT objid FROM table_part_inst WHERE 
  part_serial_no = v_esn),
  '99999', NULL, 'Inactive', 'Completed', NULL, 0, 0);  
  COMMIT;
      dbms_output.put_line ('DUMMY ESN:' ||DUMMYESN);
      dbms_output.put_line ('DUMMY SIM:' ||DUMMYsim);
      return DUMMYESN;
END;
/