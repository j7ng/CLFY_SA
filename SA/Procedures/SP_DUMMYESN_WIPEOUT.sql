CREATE OR REPLACE PROCEDURE sa."SP_DUMMYESN_WIPEOUT"
/**********************************************************************/
  /* NAME         :sp_dummyesn_wipeout
  /* PURPOSE :CR3895: This procedure deletes records of all touch point
  /*              tables.
  /* INPUT PARAMS :IP_ESN
  /*              :IP_ACTION_TYPE: 1=ACTIVATION, 2= REACTIVATION, 3=REDEMPTION
  /*
  /* OUTPUT PARAMS: OP_RESULT:  0=SUCCESSFUL
                                5=NOT A TEST ESN
                               10=NO ESN REC UPDATED
                               15=NO MIN REC UPDATED
                               20=NO PASTDUE REC UPDATED
                               25=NO SIM REC UPDATED
                             -100=DATABASE ERROR
  /* REVISIONS:
  /* VERSION   DATE       WHO             PURPOSE
  /* -------   ---------- --------------  -----------------------------
  /*  1.0      04/20/2005 Gerald Pintado  CR3895: InitialRevision
  /*  1.1      06/23/2005 Gerald Pintado  CR4070: Include NET10 phones
  /*  1.2      04/14/2006 Ingrid Canavan  CR4749: Change dummy data used for testing 3:00 P
  /*  1.3..1.6 05/05/2006 Ingrid Canavan  Changes for CR4749
  /*  1.7      05/08/2006 Gerald Pintado  Changes for CR4749 Changed location of "if" statement.
  /*  1.8      05/11/2006 Gerald Pintado  CR4749 Added logic to delete call_trans for redemption transactions
  /*  1.9      09/08/2006 Tianyuan Zhou   CR5512 OVIS Data
  /*  1.10     09/28/2006 VAdapa          Fix for CR5512 OVIS Data
  /*  1.11     09/28/2006 VAdapa          CR5512 / CR5512-1
  /*  1.12     03/15/2007 Tianyuan Zhou   Modified
  /*  1.13     03/19/2007 Tianyuan Zhou   CR6103 New data for testing WEBCSR internally HP Open View(DASHBOARD)
  /*  1.14     05/17/2007 VAdapa           CR6103-1 To clean-up case records (technology and sim exchange cases)
  /*  1.15     06/26/2007 Cosmin Ioan      CR6103-2  Upgrade, Case Type 5;
  /*  1.18     09/06/2007 Ingrid Canavan CR6506 Remove all but 1 record in table_site_part for Reactivation testing
  /*  1.19     09/26/2007 Ingrid Canavan CR6506 Do not set contact information to null in ip4
  /*  1.20-21  10/19/2007 Ingrid Canavan CR6506 populate table_part_inst.x_iccid where stat=50 ie sim marriage project
  /*                                            Remove all table_x_pi_hist records
  /* 1.1.1.0-4   11/02/07 Ingrid Canavan CR6506 Upgrade,Case Type 5
  /*************************************************************************/
  --
  --********************************************************************************
  --$RCSfile: SP_DUMMYESN_WIPEOUT.sql,v $
  --$Revision: 1.2 $
  --$Author: kacosta $
  --$Date: 2012/06/08 14:09:09 $
  --$ $Log: SP_DUMMYESN_WIPEOUT.sql,v $
  --$ Revision 1.2  2012/06/08 14:09:09  kacosta
  --$ CR21060 Update SIM status to Active.
  --$
  --$
  --********************************************************************************
  --
(
  ip_esn    IN VARCHAR2
 ,ip_action IN VARCHAR2
 ,op_result OUT VARCHAR2
 ,op_msg    OUT VARCHAR2
) AS
  CURSOR c_part_inst(c_esn IN VARCHAR2) IS
    SELECT a.*
          ,c.x_restricted_use
          ,c.x_technology /*x_technology: CR5512*/
      FROM table_part_inst a
          ,table_mod_level b
          ,table_part_num  c
     WHERE a.part_serial_no = c_esn
       AND a.n_part_inst2part_mod = b.objid
       AND b.part_info2part_num = c.objid;

  CURSOR c_call_trans(c_esn IN VARCHAR2) IS
    SELECT objid
      FROM table_x_call_trans
     WHERE x_service_id = c_esn;

  CURSOR c_site_part(c_esn IN VARCHAR2) IS
    SELECT *
      FROM table_site_part
     WHERE x_service_id = c_esn;

  --CR6103
  CURSOR c_dummy_data
  (
    c_esn      IN VARCHAR2
   ,c_act_type IN NUMBER
  ) IS
    SELECT *
      FROM x_dummy_data
     WHERE x_esn = c_esn
       AND x_action_type = c_act_type;

  rec_dummy_data c_dummy_data%ROWTYPE;

  --CR6103-1
  CURSOR c_case_objid(c_esn IN VARCHAR2) IS
    SELECT objid
      FROM table_case
     WHERE x_esn = c_esn;

  r_case_objid c_case_objid%ROWTYPE;

  CURSOR c_user_objid IS
    SELECT objid
      FROM table_user
     WHERE login_name = 'sa';

  r_user_objid c_user_objid%ROWTYPE;

  v_exception_id  VARCHAR2(5);
  v_exception_msg VARCHAR2(100);
  e_wipeout_exception EXCEPTION;
  v_sim             VARCHAR2(20);
  v_min             VARCHAR2(20);
  v_pin             VARCHAR2(20);
  v_smp             VARCHAR2(20);
  v_restricted_use  NUMBER := 0;
  v_mod_level       NUMBER := 0;
  v_technology      VARCHAR2(20); /*CR5512*/
  v_new_esn         VARCHAR2(20); --CR6103-2
  v_site_part_objid NUMBER;
  p_error_no        VARCHAR2(20);
  p_error_str       VARCHAR2(200);

BEGIN
  -- CR4749 5/5/06   DELETE BY CR6103, move the dummy data to table
  -- CR5512          DELETE BY CR6103, move the dummy data to table
  -- CR6103 Begin
  OPEN c_dummy_data(ip_esn
                   ,ip_action);

  FETCH c_dummy_data
    INTO rec_dummy_data;

  IF c_dummy_data%NOTFOUND THEN
    CLOSE c_dummy_data;
    v_exception_id  := '5';
    v_exception_msg := 'ESN:' || ip_esn || ' - IS NOT A TEST ESN';
    RAISE e_wipeout_exception;
  ELSE
    v_sim     := rec_dummy_data.x_sim; --v_sim := '999999999999999999';
    v_pin     := rec_dummy_data.x_pin; --v_pin := '186335777341567';
    v_smp     := rec_dummy_data.x_smp; --v_smp := '44998776';
    v_min     := rec_dummy_data.x_min; --v_min := '3059999999';
    v_new_esn := rec_dummy_data.x_change_esn; --new esn for CR6103-2

    SELECT MAX(objid)
      INTO v_site_part_objid
      FROM table_site_part sp
     WHERE sp.x_service_id = ip_esn
       AND sp.part_status || '' = 'Inactive'
       AND sp.x_deact_reason = 'UPGRADE';
  END IF;

  CLOSE c_dummy_data;

  -- CR6103 END

  /*    DBMS_OUTPUT.put_line ('VALUES: ' || v_sim);
  DBMS_OUTPUT.put_line ('VALUES: ' || v_pin);
  DBMS_OUTPUT.put_line ('VALUES: ' || v_smp);
  DBMS_OUTPUT.put_line ('VALUES: ' || v_min);
  DBMS_OUTPUT.put_line ('VALUES: ' || ip_esn);
  DBMS_OUTPUT.put_line ('VALUES: ' || ip_action);*/

  FOR r_part_inst IN c_part_inst(ip_esn) LOOP
    --CR6103-2
    IF ip_action = '5' THEN
      DELETE FROM table_case
       WHERE x_esn IN (ip_esn
                      ,v_new_esn);
      DELETE FROM table_x_pi_hist
       WHERE x_part_serial_no = v_new_esn;

      UPDATE table_site_part
         SET part_status      = 'Active'
            ,service_end_dt   = '1-jan-1753'
            ,warranty_date    = SYSDATE + 150
            ,x_deact_reason   = NULL
            ,x_notify_carrier = NULL
            ,x_expire_dt      = SYSDATE + 150
       WHERE objid = v_site_part_objid;

      UPDATE table_part_inst
         SET x_part_inst_status    = '52'
            ,status2x_code_table  =
             (SELECT objid
                FROM table_x_code_table
               WHERE x_code_number = '52')
            ,x_port_in             = 0
            ,x_clear_tank          = 0
            ,part_good_qty         = 1
            ,part_bad_qty          = 0
            ,part_bin              = NULL
            ,warr_end_date         = SYSDATE + 150
            ,good_res_qty          = 0
            ,bad_res_qty           = 0
            ,x_deactivation_flag   = 0
            ,x_cool_end_date       = TO_DATE('01/01/1753'
                                            ,'mm/dd/yyyy')
            ,x_order_number        = NULL
            ,part_inst2carrier_mkt = NULL
            ,hdr_ind               = 0
       WHERE part_serial_no = ip_esn;
      --
      --CR21060 Start kacosta 06/05/2012
      UPDATE table_x_sim_inv xsi
         SET x_last_update_date        = SYSDATE
            ,x_sim_inv_status          = '254'
            ,x_sim_status2x_code_table = 268438607
       WHERE EXISTS (SELECT 1
                FROM table_part_inst tpi
                JOIN table_site_part tsp
                  ON tpi.part_serial_no = tsp.x_service_id
               WHERE tpi.x_iccid = xsi.x_sim_serial_no
                 AND tpi.part_serial_no = ip_esn
                 AND tpi.x_domain = 'PHONES'
                 AND tpi.x_part_inst_status = '52'
                 AND tsp.objid = v_site_part_objid
                 AND tsp.part_status = 'Active'
                 AND tsp.x_iccid = xsi.x_sim_serial_no)
         AND xsi.x_sim_inv_status IN ('251'
                                     ,'253');
      --CR21060 End kacosta 06/05/2012
      --
      ----
      UPDATE table_part_inst
         SET x_part_inst_status    = '13'
            ,status2x_code_table  =
             (SELECT objid
                FROM table_x_code_table
               WHERE x_code_number = '13')
            ,part_to_esn2part_inst =
             (SELECT objid
                FROM table_part_inst
               WHERE part_serial_no = ip_esn)
            ,x_port_in             = 0
       WHERE part_serial_no = v_min;

      DELETE FROM table_site_part
       WHERE x_service_id = v_new_esn;
      DELETE FROM table_x_call_trans
       WHERE x_service_id = v_new_esn;
      DELETE FROM table_x_zero_out_max
       WHERE x_esn = ip_esn;

      UPDATE table_part_inst
         SET x_part_inst_status  = '50'
            ,status2x_code_table =
             (SELECT objid
                FROM table_x_code_table
               WHERE x_code_number = '50')
            ,x_port_in           = 0
            ,x_clear_tank        = 0
       WHERE part_serial_no = v_new_esn;

      UPDATE table_x_sim_inv
         SET x_sim_inv_status          = '253'
            ,x_last_update_date        = NULL
            ,x_sim_status2x_code_table =
             (SELECT objid
                FROM table_x_code_table
               WHERE x_code_number = '253')
       WHERE x_sim_serial_no = v_sim;

    END IF; --end CR6103-2

    --CR6103-1
    IF ip_action = '4' THEN

      OPEN c_user_objid;

      FETCH c_user_objid
        INTO r_user_objid;

      CLOSE c_user_objid;

      OPEN c_case_objid(ip_esn);
      WHILE (1 = 1) LOOP
        EXIT WHEN c_case_objid%NOTFOUND;

        FETCH c_case_objid
          INTO r_case_objid;

        clarify_case_pkg.close_case(r_case_objid.objid
                                   ,r_user_objid.objid
                                   ,'WEBCSR'
                                   ,NULL
                                   ,NULL
                                   ,p_error_no
                                   ,p_error_str);

      END LOOP;

      CLOSE c_case_objid;

      DELETE FROM table_condition
       WHERE objid IN (SELECT case_state2condition
                         FROM table_case
                        WHERE x_esn = ip_esn);

      DELETE FROM table_act_entry
       WHERE act_entry2case IN (SELECT objid
                                  FROM table_case
                                 WHERE x_esn = ip_esn);

      DELETE FROM table_x_case_promotions
       WHERE case_promo2case IN (SELECT objid
                                   FROM table_case
                                  WHERE x_esn = ip_esn);

      DELETE FROM table_x_case_detail
       WHERE detail2case IN (SELECT objid
                               FROM table_case
                              WHERE x_esn = ip_esn);

      DELETE FROM table_x_part_request
       WHERE request2case IN (SELECT objid
                                FROM table_case
                               WHERE x_esn = ip_esn);

      DELETE FROM x_special_instructions_list
       WHERE x_esn = ip_esn;

      DELETE FROM table_notes_log
       WHERE case_notes2case IN (SELECT objid
                                   FROM table_case
                                  WHERE x_esn = ip_esn);

      DELETE FROM table_close_case
       WHERE last_close2case IN (SELECT objid
                                   FROM table_case
                                  WHERE x_esn = ip_esn);

      DELETE FROM table_case
       WHERE x_esn = ip_esn;

      DELETE FROM table_x_pi_hist
       WHERE x_part_serial_no = r_part_inst.part_serial_no;

      DELETE FROM table_x_zero_out_max
       WHERE x_esn = ip_esn;

      UPDATE table_part_inst
         SET x_clear_tank = 0
       WHERE part_serial_no = ip_esn;
      COMMIT;
    END IF;

    --End CR6103-1

    IF ip_action IN ('1'
                    ,'2') THEN
      -- Only for activations and reactivations
      dbms_output.put_line('Updating part_inst for IP_ESN');

      UPDATE table_part_inst
         SET x_part_inst_status    = DECODE(ip_action
                                           ,'1'
                                           ,'50'
                                           ,'2'
                                           ,'54'
                                           ,x_part_inst_status)
            ,status2x_code_table   = DECODE(ip_action
                                           ,'1'
                                           ,986
                                           ,'2'
                                           ,990
                                           ,status2x_code_table)
            ,x_part_inst2site_part = DECODE(ip_action
                                           ,'1'
                                           ,NULL
                                           ,x_part_inst2site_part)
            ,x_part_inst2contact   = DECODE(ip_action
                                           ,'1'
                                           ,NULL
                                           ,x_part_inst2contact)
            ,part_inst2x_pers      = DECODE(ip_action
                                           ,'1'
                                           ,NULL
                                           ,part_inst2x_pers)
            ,part_inst2x_new_pers  = DECODE(ip_action
                                           ,'1'
                                           ,NULL
                                           ,part_inst2x_new_pers)
            ,part_good_qty         = DECODE(ip_action
                                           ,'1'
                                           ,NULL
                                           ,part_good_qty)
            ,warr_end_date         = DECODE(ip_action
                                           ,'1'
                                           ,NULL
                                           ,'2'
                                           ,SYSDATE - 2
                                           ,warr_end_date)
            ,last_pi_date          = DECODE(ip_action
                                           ,'1'
                                           ,TO_DATE('01/01/1753'
                                                   ,'mm/dd/yyyy')
                                           ,last_pi_date)
            ,last_cycle_ct         = DECODE(ip_action
                                           ,'1'
                                           ,TO_DATE('01/01/1753'
                                                   ,'mm/dd/yyyy')
                                           ,last_cycle_ct)
            ,next_cycle_ct         = DECODE(ip_action
                                           ,'1'
                                           ,TO_DATE('01/01/1753'
                                                   ,'mm/dd/yyyy')
                                           ,next_cycle_ct)
            ,last_mod_time         = DECODE(ip_action
                                           ,'1'
                                           ,TO_DATE('01/01/1753'
                                                   ,'mm/dd/yyyy')
                                           ,last_mod_time)
            ,last_trans_time       = DECODE(ip_action
                                           ,'1'
                                           ,TO_DATE('01/01/1753'
                                                   ,'mm/dd/yyyy')
                                           ,last_trans_time)
            ,date_in_serv          = DECODE(ip_action
                                           ,'1'
                                           ,TO_DATE('01/01/1753'
                                                   ,'mm/dd/yyyy')
                                           ,date_in_serv)
            ,repair_date           = DECODE(ip_action
                                           ,'1'
                                           ,TO_DATE('01/01/1753'
                                                   ,'mm/dd/yyyy')
                                           ,repair_date)
            ,x_sequence            = 0
            ,x_iccid               = DECODE(ip_action
                                           ,'1'
                                           ,NULL
                                           ,v_sim)
            , --  CR6506 ie.sim marriage
             x_reactivation_flag   = DECODE(ip_action
                                           ,'1'
                                           ,NULL
                                           ,x_reactivation_flag)
       WHERE objid = r_part_inst.objid;

      IF SQL%ROWCOUNT = 0 THEN
        v_exception_id  := '10';
        v_exception_msg := 'ESN:' || ip_esn || ' - NO ESN RECORD UPDATED';
        RAISE e_wipeout_exception;
      END IF;

      COMMIT;
      dbms_output.put_line('Updating part_inst for any reserved lines to the IP_ESN');

      UPDATE table_part_inst
         SET x_part_inst_status    = DECODE(x_part_inst_status
                                           ,'37'
                                           ,'11'
                                           ,'39'
                                           ,'12')
            ,status2x_code_table   = DECODE(x_part_inst_status
                                           ,'37'
                                           ,958
                                           ,'39'
                                           ,959)
            ,part_to_esn2part_inst = NULL
       WHERE part_to_esn2part_inst = r_part_inst.objid
         AND x_domain = 'LINES'
         AND x_part_inst_status IN ('37'
                                   ,'39');

      COMMIT;
      --END IF;
      -- CR6506 REMOVE THIS TO CLEAN THE CODE
      --IF ip_action IN ('1', '2')
      -- THEN                           -- Only for activations and reactivations
      dbms_output.put_line('Reserves v_min to IP_ESN');

      UPDATE table_part_inst
         SET x_part_inst_status    = '37'
            ,status2x_code_table   = 969
            ,part_to_esn2part_inst = r_part_inst.objid
       WHERE part_serial_no = v_min;

      IF SQL%ROWCOUNT = 0 THEN
        v_exception_id  := '15';
        v_exception_msg := 'ESN:' || ip_esn || ' - NO MIN REC UPDATED';
        RAISE e_wipeout_exception;
      END IF;

      COMMIT;

      dbms_output.put_line('Deleting x_pi_hist for IP_ESN');
      DELETE table_x_pi_hist
       WHERE x_part_serial_no = r_part_inst.part_serial_no;
      COMMIT;

    END IF;

    IF ip_action = '1' THEN
      -- Only for activation changes
      dbms_output.put_line('Deleting x_contact_part_inst for IP_ESN');

      DELETE table_x_contact_part_inst
       WHERE x_contact_part_inst2part_inst = r_part_inst.objid;

      COMMIT;
      dbms_output.put_line('Deleting condition for IP_ESN case');

      DELETE table_condition
       WHERE objid IN (SELECT case_state2condition
                         FROM table_case
                        WHERE x_esn = r_part_inst.part_serial_no);

      COMMIT;
      dbms_output.put_line('Deleting cases for IP_ESN');

      DELETE table_case
       WHERE x_esn = r_part_inst.part_serial_no;

      COMMIT;
    END IF;

    dbms_output.put_line('Deleting OTA records');

    DELETE table_x_ota_features
     WHERE x_ota_features2part_inst = r_part_inst.objid;

    DELETE table_x_ota_trans_dtl
     WHERE x_ota_trans_dtl2x_ota_trans IN (SELECT objid
                                             FROM table_x_ota_transaction
                                            WHERE x_esn = r_part_inst.part_serial_no);

    DELETE table_x_ota_transaction
     WHERE x_esn = r_part_inst.part_serial_no;

    -- cr6506 remove from table_interact -- not good blows up in webcsr

    --DELETE from table_interact WHERE objid in
    -- (select ti.objid from table_interact ti , table_contact tc, table_part_inst pi
    -- where pi.x_part_inst2contact=tc.objid
    -- and tc.objid=ti.interact2contact
    -- and pi.part_serial_no in (v_new_esn,ip_esn)) ;

    COMMIT;
    v_restricted_use := r_part_inst.x_restricted_use;
    v_technology     := r_part_inst.x_technology;
  END LOOP;

  FOR r_call_trans IN c_call_trans(ip_esn) LOOP
    dbms_output.put_line('Deleting red_card for IP_ESN redemptions');

    DELETE table_x_red_card
     WHERE red_card2call_trans = r_call_trans.objid;
    COMMIT;

    IF ip_action = '3' -- Only for redemption transactions
     THEN
      --CR5512
      UPDATE table_part_inst
         SET x_sequence = 1
       WHERE part_serial_no = (SELECT x_service_id
                                 FROM table_x_call_trans
                                WHERE objid = r_call_trans.objid);

      --CR5512
      DELETE table_x_call_trans
       WHERE objid = r_call_trans.objid
         AND x_action_text = 'REDEMPTION';
      COMMIT;
    END IF;

    IF ip_action = '1' THEN
      -- Only for activation changes
      dbms_output.put_line('Deleting code_hist for IP_ESN transactions');

      DELETE table_x_code_hist
       WHERE code_hist2call_trans = r_call_trans.objid;

      COMMIT;
      dbms_output.put_line('Deleting promo_hist for IP_ESN promotions');

      DELETE table_x_promo_hist
       WHERE promo_hist2x_call_trans = r_call_trans.objid;

      COMMIT;
      dbms_output.put_line('Deleting Ig_transaction record for IP_ESN');

      DELETE gw1.ig_transaction
       WHERE action_item_id IN (SELECT task_id
                                  FROM table_task
                                 WHERE x_task2x_call_trans = r_call_trans.objid);

      COMMIT;
      dbms_output.put_line('Deleting task record for IP_ESN');

      DELETE table_task
       WHERE x_task2x_call_trans = r_call_trans.objid;

      COMMIT;
      dbms_output.put_line('Deleting call_trans for IP_ESN transactions');

      DELETE table_x_call_trans
       WHERE objid = r_call_trans.objid;

      COMMIT;
    END IF;

  END LOOP;

  FOR r_site_part IN c_site_part(ip_esn) LOOP
    IF ip_action = '1' THEN
      -- Only for activation changes
      dbms_output.put_line('Deleting address record for IP_ESN');

      DELETE table_address
       WHERE objid IN (SELECT cust_primaddr2address
                         FROM table_site
                        WHERE objid = r_site_part.site_objid);

      COMMIT;
      dbms_output.put_line('Deleting contact record for IP_ESN');

      DELETE table_contact
       WHERE objid IN (SELECT contact_role2contact
                         FROM table_contact_role
                        WHERE contact_role2site = r_site_part.site_objid);

      COMMIT;
      dbms_output.put_line('Deleting bus_site_role record for IP_ESN');

      DELETE table_bus_site_role
       WHERE bus_site_role2site = r_site_part.site_objid;

      COMMIT;
      dbms_output.put_line('Deleting web_user record for IP_ESN');

      DELETE table_web_user
       WHERE web_user2contact IN (SELECT contact_role2contact
                                    FROM table_contact_role
                                   WHERE contact_role2site = r_site_part.site_objid);

      dbms_output.put_line('Deleting contact_role record for IP_ESN');

      DELETE table_contact_role
       WHERE contact_role2site = r_site_part.site_objid;

      COMMIT;
      dbms_output.put_line('Deleting click_plan_hist for IP_ESN');

      DELETE table_x_click_plan_hist
       WHERE curr_hist2site_part = r_site_part.objid;

      COMMIT;
      dbms_output.put_line('Deleting pending_redemption for IP_ESN');

      DELETE table_x_pending_redemption
       WHERE x_pend_red2site_part = r_site_part.objid;

      COMMIT;
    END IF;

    IF ip_action = '1' THEN
      -- Only for activation changes
      dbms_output.put_line('Deleting site_part for IP_ESN');

      DELETE table_site_part
       WHERE objid = r_site_part.objid;

      COMMIT;
    ELSIF ip_action = '2' THEN
      -- Only for reactivation changes
      UPDATE table_site_part
         SET part_status    = 'Inactive'
            ,x_expire_dt    = SYSDATE - 2
            ,service_end_dt = SYSDATE - 1
            ,x_deact_reason = 'PASTDUE'
       WHERE objid = r_site_part.objid;

      IF SQL%ROWCOUNT = 0 THEN
        v_exception_id  := '20';
        v_exception_msg := 'ESN:' || ip_esn || ' - NO PASTDUE REC UPDATED';
        RAISE e_wipeout_exception;
      END IF;

      COMMIT;
    END IF;
  END LOOP;

  IF ip_action = '2' -- CR6506
   THEN
    -- Reactivations keep 1 record in table_site_part
    dbms_output.put_line('Deleting site_part for IP_ESN');
    DELETE FROM table_site_part
     WHERE x_service_id = ip_esn
       AND objid < (SELECT MAX(objid)
                      FROM table_site_part
                     WHERE x_service_id = ip_esn);
    COMMIT;
  END IF;
  IF ip_action IN ('1'
                  ,'2')
     AND v_technology = 'GSM' --CR5512
   THEN
    -- Only for activations and Reactivations
    dbms_output.put_line('Updating v_sim in table_x_sim_inv to new status');

    UPDATE table_x_sim_inv
       SET x_sim_inv_status          = '253'
          ,x_sim_status2x_code_table = 268438606
     WHERE x_sim_serial_no = v_sim;

    IF SQL%ROWCOUNT = 0 THEN
      v_exception_id  := '25';
      v_exception_msg := 'ESN:' || ip_esn || ' - NO SIM REC UPDATED';
      RAISE e_wipeout_exception;
    END IF;

    COMMIT;
  END IF;

  dbms_output.put_line('Deleting v_pin from part_inst');

  DELETE table_part_inst
   WHERE part_serial_no = v_smp;

  COMMIT;
  dbms_output.put_line('Deleting v_pin from red_card');

  DELETE table_x_red_card
   WHERE x_smp = v_smp;

  COMMIT;

  IF v_restricted_use = 3 THEN
    v_mod_level := 280776001; -- 250 unit mod
  ELSE
    v_mod_level := 12291067; -- 10 unit mod
  END IF;

  dbms_output.put_line('Inserting v_pin into part_inst');

  --CR6103-2; added wrapping "if condition" so that no bogus records are inserted;
  IF (v_pin IS NOT NULL) THEN
    INSERT INTO table_part_inst
      (objid
      ,part_serial_no
      ,x_domain
      ,x_red_code
      ,x_part_inst_status
      ,x_insert_date
      ,x_creation_date
      ,x_order_number
      ,created_by2user
      ,status2x_code_table
      ,n_part_inst2part_mod
      ,part_inst2inv_bin
      ,last_trans_time)
    VALUES
      (sa.seq('part_inst')
      ,v_smp
      ,'REDEMPTION CARDS'
      ,v_pin
      ,'42'
      ,SYSDATE
      ,SYSDATE
      ,NULL
      ,268435556
      , --USER sa
       984
      ,v_mod_level
      , -- PartNum ModLevel
       268489675
      , -- CORP FREE - IT DEVELOPMENT
       SYSDATE);
  END IF; --CR6103-2

  COMMIT;
  op_result := '0';
  op_msg    := 'ESN:' || ip_esn || ' - SUCCESSFUL';
EXCEPTION
  WHEN e_wipeout_exception THEN
    ROLLBACK;
    op_result := v_exception_id;
    op_msg    := v_exception_msg;
  WHEN others THEN
    ROLLBACK;
    v_exception_msg := SUBSTR(SQLERRM
                             ,1
                             ,100);
    op_result       := '-100';
    op_msg          := 'ESN:' || ip_esn || ' - ' || v_exception_msg;
END sp_dummyesn_wipeout;
/