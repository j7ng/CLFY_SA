CREATE OR REPLACE function sa.get_data_sqa_byop(p_pn_sim in varchar2,p_pn_esn in varchar2,p_pn_pin in varchar2 )  return varchar2
is
   Simpart Varchar2(30):=p_pn_sim; 
   PARTNUMBER VARCHAR2(30):=p_pn_esn;
   V_Esn Varchar2(30);      
   DUMMYESN VARCHAR2(30);
   DUMMYsim VARCHAR2(30);
    DUMMYpin VARCHAR2(30);
   SIM VARCHAR2(30);
 BEGIN
  sim := sa.get_test_sim(p_pn_sim);
  v_esn:= substr(sim,-15);  
  Dummyesn:= sa.get_test_esn(Partnumber);
  DUMMYSIM:= sa.get_test_sim(SIMPART); 
  DELETE FROM table_x_ota_features 
  WHERE X_OTA_FEATURES2PART_INST IN (SELECT objid FROM table_part_inst WHERE part_serial_no = v_esn);
  DELETE FROM table_x_sim_inv WHERE x_sim_serial_no = sim;
  DELETE FROM table_site_part WHERE x_service_id = v_esn;
  DELETE FROM table_x_call_trans WHERE x_service_id = v_esn;
  DELETE FROM GW1.ig_transaction WHERE ig_transaction.ESN = v_esn and CREATION_DATE > sysdate - 30;
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
Update Table_Part_Inst
 Set Part_Serial_No = V_Esn,x_iccid = sim
 WHERE part_serial_no = dummyesn;
  UPDATE table_x_sim_inv
 SET x_sim_serial_no = sim
 where x_sim_serial_no = dummysim;
  delete from  gw1.test_ota_esn where gw1.test_ota_esn.esn = v_esn;
  insert into gw1.test_ota_esn values (v_esn);
  delete from  sa.TEST_IGATE_ESN  where esn=v_esn;
  insert into sa.TEST_IGATE_ESN   values(v_esn,'C');
  COMMIT;
  dbms_output.put_line ('PIN= '|| sa.get_test_pin(p_pn_pin)); ----NTP30750, NTPU0001 ,NTPMP02999 all you need --NTPMP00045 -- TCAPPUNL45 -- TCNS00060ILD
  Dbms_Output.Put_Line('pseudo ESN: '||V_Esn);
  Dbms_Output.Put_Line('SIM: '||sim);
      return V_Esn;
END;
/