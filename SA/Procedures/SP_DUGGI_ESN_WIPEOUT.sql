CREATE OR REPLACE PROCEDURE sa."SP_DUGGI_ESN_WIPEOUT"
/**********************************************************************/
/*
/* NAME         :SP_DUMMYESN_WIPEOUT
/* PURPOSE      :CR3895: This procedure deletes records of all touch point
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
/* VERSION  DATE	     WHO		         PURPOSE
/* -------  ---------- --------------  -----------------------------
/*  1.0     04/20/2005 Gerald Pintado  CR3895: InitialRevision
/*  1.1     06/23/2005 Gerald Pintado  CR4070: Include NET10 phones
/*
/*************************************************************************/
(IP_ESN IN VARCHAR2,
 IP_ACTION IN VARCHAR2,
 OP_RESULT OUT VARCHAR2,
 OP_MSG OUT VARCHAR2
 )
AS
CURSOR c_part_inst(C_ESN IN VARCHAR2)
 IS
 SELECT a.*,c.X_RESTRICTED_USE
   FROM table_part_inst a, table_mod_level b, table_part_num c
  WHERE a.part_serial_no = C_ESN
    AND a.N_PART_INST2PART_MOD = b.OBJID
    AND b.PART_INFO2PART_NUM = c.OBJID;


CURSOR c_call_trans(C_ESN IN VARCHAR2)
 IS
 SELECT objid
   FROM table_x_call_trans
  WHERE x_service_id = C_ESN;

CURSOR c_site_part(C_ESN IN VARCHAR2)
 IS
 SELECT *
   FROM table_site_part
  WHERE x_service_id = C_ESN;

v_exception_id varchar2(5);
v_exception_msg varchar2(100);

e_wipeout_exception  EXCEPTION;
v_sim varchar2(20);
v_min varchar2(20);
v_pin varchar2(20);
v_smp varchar2(20);
v_restricted_use number := 0;
v_mod_level number := 0;

BEGIN
     /********* TRACFONE TEST DATA ********************/

     -- Used for Tracfone activations
     IF ip_esn = '010999999999999' THEN
        v_sim := '999999999999999999';
        v_pin := '186335777341567';
        v_smp := '44998776';
        v_min := '3059999999';
     ELSIF ip_esn = '010999999999991' THEN
        v_sim := '999999999999999991';
        v_pin := '186655773741595';
        v_smp := '44998812';
        v_min := '3059999991';
     ELSIF ip_esn = '010999999999992' THEN
        v_sim := '999999999999999992';
        v_pin := '185375775341320';
        v_smp := '44999078';
        v_min := '3059999992';
     ELSIF ip_esn = '010999999991810' THEN
        v_sim := '999999999999991810';
        v_pin := '269161374011244';
        v_smp := '211952219';
        v_min := '3059991810';
     ELSIF ip_esn = '010999999991820' THEN
        v_sim := '999999999999991820';
        v_pin := '178571841382113';
        v_smp := '211952220';
        v_min := '3059991820';
     ELSIF ip_esn = '010999999991830' THEN
        v_sim := '999999999999991830';
        v_pin := '170891730825894';
        v_smp := '211952221';
        v_min := '3059991830';
          ELSIF ip_esn = '010999999991840' THEN
        v_sim := '999999999999991840';
        v_pin := '269161374011244';
        v_smp := '211952225';
        v_min := '3059991840';
     ELSIF ip_esn = '010999999991850' THEN
        v_sim := '999999999999991850';
        v_pin := '178571841382113';
        v_smp := '211952226';
        v_min := '3059991850';
     ELSIF ip_esn = '010999999991860' THEN
        v_sim := '999999999999991860';
        v_pin := '170891730825894';
        v_smp := '211952227';
        v_min := '3059991860';

     /********* NET10 TEST DATA ********************/

     -- Used for NET10 activations
     ELSIF ip_esn = '010999999999993' THEN
        v_sim := '999999999999999993';
        v_pin := '117070094649293';
        v_smp := '40586757';
        v_min := '3059999993';
     ELSIF ip_esn = '010999999999994' THEN
        v_sim := '999999999999999994';
        v_pin := '112750096450941';
        v_smp := '40586965';
        v_min := '3059999994';
     ELSIF ip_esn = '010999999999995' THEN
        v_sim := '999999999999999995';
        v_pin := '113550100651158';
        v_smp := '40587064';
        v_min := '3059999995';
     ELSIF ip_esn = '010999999991910' THEN
        v_sim := '999999999999991910';
        v_pin := '451761044324482';
        v_smp := '211952222';
        v_min := '3059991910';
     ELSIF ip_esn = '010999999991920' THEN
        v_sim := '999999999999991920';
        v_pin := '719292003833543';
        v_smp := '211952223';
        v_min := '3059991920';
     ELSIF ip_esn = '010999999991930' THEN
        v_sim := '999999999999991930';
        v_pin := '346971355995082';
        v_smp := '211952224';
        v_min := '3059991930';
     ELSIF ip_esn = '010999999991940' THEN
        v_sim := '999999999999991940';
        v_pin := '451761044324482';
        v_smp := '211952228';
        v_min := '3059991940';
     ELSIF ip_esn = '010999999991950' THEN
        v_sim := '999999999999991950';
        v_pin := '719292003833543';
        v_smp := '211952229';
        v_min := '3059991950';
     ELSIF ip_esn = '010999999991960' THEN
        v_sim := '999999999999991960';
        v_pin := '346971355995082';
        v_smp := '211952230';
        v_min := '3059991960';
     ELSE
        v_exception_id := '5';
        v_exception_msg := 'ESN:'|| IP_ESN || ' - IS NOT A TEST ESN';
        RAISE e_wipeout_exception;
     END IF;


	  FOR r_part_inst IN c_part_inst(IP_ESN)LOOP

       IF IP_ACTION IN ('1','2') THEN  -- Only for activations and reactivations
          dbms_output.put_line('Updating part_inst for IP_ESN');
          UPDATE table_part_inst
             SET x_part_inst_status   = DECODE(IP_ACTION,'1','50','2','54',x_part_inst_status),
                 status2x_code_table  = DECODE(IP_ACTION,'1',986,'2',990,x_part_inst_status),
                 x_part_inst2site_part= DECODE(IP_ACTION,'1',NULL,x_part_inst2site_part),
                 x_part_inst2contact  = DECODE(IP_ACTION,'1',NULL,x_part_inst2contact),
                 part_inst2x_pers     = DECODE(IP_ACTION,'1',NULL,part_inst2x_pers),
                 part_inst2x_new_pers = DECODE(IP_ACTION,'1',NULL,part_inst2x_new_pers),
                 part_good_qty        = DECODE(IP_ACTION,'1',NULL,part_good_qty),
                 warr_end_date        = DECODE(IP_ACTION,'1',NULL,'2',SYSDATE-2,warr_end_date),
                 last_pi_date         = DECODE(IP_ACTION,'1',TO_DATE('01/01/1753','mm/dd/yyyy'),last_pi_date),
                 last_cycle_ct        = DECODE(IP_ACTION,'1',TO_DATE('01/01/1753','mm/dd/yyyy'), last_cycle_ct),
                 next_cycle_ct        = DECODE(IP_ACTION,'1',TO_DATE('01/01/1753','mm/dd/yyyy'), next_cycle_ct),
                 last_mod_time        = DECODE(IP_ACTION,'1',TO_DATE('01/01/1753','mm/dd/yyyy'), last_mod_time),
                 last_trans_time      = DECODE(IP_ACTION,'1',TO_DATE('01/01/1753','mm/dd/yyyy'), last_trans_time),
                 date_in_serv         = DECODE(IP_ACTION,'1',TO_DATE('01/01/1753','mm/dd/yyyy'), date_in_serv),
                 repair_date          = DECODE(IP_ACTION,'1',TO_DATE('01/01/1753','mm/dd/yyyy'), repair_date),
                 x_sequence           = DECODE(IP_ACTION,'1',0,x_sequence),
                 x_iccid              = DECODE(IP_ACTION,'1',NULL,x_iccid),
                 x_reactivation_flag  = DECODE(IP_ACTION,'1',NULL,x_reactivation_flag)
           WHERE objid = r_part_inst.objid;

           IF SQL%ROWCOUNT =0 THEN
             v_exception_id := '10';
             v_exception_msg := 'ESN:'|| IP_ESN || ' - NO ESN RECORD UPDATED';
             RAISE e_wipeout_exception;
           END IF;

           COMMIT;
       END IF;

       dbms_output.put_line('Updating part_inst for any reserved lines to the IP_ESN');
       UPDATE table_part_inst
          SET x_part_inst_status = decode(x_part_inst_status,'37','11','39','12') ,
              status2x_code_table = decode(x_part_inst_status,'37',958,'39',959),
              part_to_esn2part_inst = null
        WHERE part_to_esn2part_inst = r_part_inst.objid
          AND x_domain = 'LINES'
          AND x_part_inst_status in ('37','39');
       COMMIT;

        IF IP_ACTION IN ('1','2') THEN  -- Only for activations and reactivations
        dbms_output.put_line('Reserves v_min to IP_ESN');
           UPDATE TABLE_PART_INST
              SET X_PART_INST_STATUS = '37',
                  STATUS2X_CODE_TABLE = 969,
                  PART_TO_ESN2PART_INST = r_part_inst.objid
            WHERE part_serial_no = v_min;

            IF SQL%ROWCOUNT =0 THEN
              v_exception_id := '15';
              v_exception_msg := 'ESN:'|| IP_ESN || ' - NO MIN REC UPDATED';
              RAISE e_wipeout_exception;
            END IF;

            COMMIT;
        END IF;


        IF IP_ACTION = '1' THEN  -- Only for activation changes
          dbms_output.put_line('Deleting x_pi_hist for IP_ESN');
          DELETE table_x_pi_hist
           WHERE x_part_serial_no = r_part_inst.part_serial_no;
          COMMIT;

          dbms_output.put_line('Deleting x_contact_part_inst for IP_ESN');
          DELETE table_x_contact_part_inst
           WHERE x_contact_part_inst2part_inst = r_part_inst.objid;
          COMMIT;

           dbms_output.put_line('Deleting condition for IP_ESN case');
           DELETE table_condition
            WHERE objid in (SELECT case_state2condition
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
         WHERE x_ota_trans_dtl2x_ota_trans in (SELECT objid
                                                 FROM table_x_ota_transaction
                                                WHERE x_esn = r_part_inst.part_serial_no);

        DELETE table_x_ota_transaction
         WHERE X_ESN = r_part_inst.part_serial_no;
         COMMIT;

        v_restricted_use := r_part_inst.x_restricted_use;

    END LOOP;


    FOR  r_call_trans in c_call_trans(IP_ESN) LOOP


        dbms_output.put_line('Deleting red_card for IP_ESN redemptions');
        DELETE table_x_red_card
         WHERE red_card2call_trans = r_call_trans.objid;
        COMMIT;

        IF IP_ACTION = '1' THEN  -- Only for activation changes

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
            WHERE action_item_id in (SELECT task_id
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

    FOR r_site_part in c_site_part(IP_ESN) LOOP

        IF IP_ACTION = '1' THEN  -- Only for activation changes
           dbms_output.put_line('Deleting address record for IP_ESN');
           DELETE table_address
            WHERE objid in (SELECT cust_primaddr2address
                              FROM table_site
                             WHERE objid = r_site_part.site_objid);
            COMMIT;

           dbms_output.put_line('Deleting contact record for IP_ESN');
           DELETE table_contact
            WHERE objid in (SELECT contact_role2contact
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


        IF IP_ACTION = '1' THEN  -- Only for activation changes
           dbms_output.put_line('Deleting site_part for IP_ESN');
           DELETE table_site_part
            WHERE objid = r_site_part.objid;
           COMMIT;
        ELSIF IP_ACTION = '2' THEN  -- Only for reactivation changes
           UPDATE TABLE_SITE_PART
              SET part_status = 'Inactive',
                  x_expire_dt = SYSDATE-2,
                  service_end_dt = sysdate -1,
                  x_deact_reason = 'PASTDUE'
            WHERE objid = r_site_part.objid;

            IF SQL%ROWCOUNT =0 THEN
              v_exception_id := '20';
              v_exception_msg := 'ESN:'|| IP_ESN || ' - NO PASTDUE REC UPDATED';
              RAISE e_wipeout_exception;
            END IF;

            COMMIT;
        END IF;

    END LOOP;


      IF IP_ACTION IN ('1','2') THEN -- Only for activations and Reactivations
         dbms_output.put_line('Updating v_sim in table_x_sim_inv to new status');
         UPDATE table_x_sim_inv
            SET x_sim_inv_status = '253',
                x_sim_status2x_code_table = 268438606
          WHERE x_sim_serial_no = v_sim;

             IF SQL%ROWCOUNT =0 THEN
                 v_exception_id := '25';
                 v_exception_msg := 'ESN:'|| IP_ESN || ' - NO SIM REC UPDATED';
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
      	 v_mod_level := 280776001;  -- 250 unit mod
      ELSE
      	 v_mod_level := 12291067;	 -- 10 unit mod
      END IF;

      dbms_output.put_line('Inserting v_pin into part_inst');
      INSERT INTO table_part_inst(
                    objid,
                    part_serial_no,
                    x_domain,
                    x_red_code,
                    x_part_inst_status,
                    x_insert_date,
                    x_creation_date,
                    x_order_number,
                    created_by2user,
                    status2x_code_table,
                    n_part_inst2part_mod,
                    part_inst2inv_bin,
                    last_trans_time
                 )VALUES(
                    sa.seq('part_inst'),
                    v_smp,
                    'REDEMPTION CARDS',
                    v_pin,
                    '42',
                    sysdate,
                    sysdate,
                    NULL,
                    268435556, --USER sa
                    984,
                    v_mod_level, -- PartNum ModLevel
                    268489675, -- CORP FREE - IT DEVELOPMENT
                    SYSDATE
                 );
          COMMIT;
 OP_RESULT := '0';
 OP_MSG := 'ESN:'|| IP_ESN ||' - SUCCESSFUL';
EXCEPTION
 WHEN e_wipeout_exception THEN
  ROLLBACK;
  OP_RESULT := v_exception_id;
  OP_MSG := v_exception_msg;

 WHEN OTHERS THEN
   ROLLBACK;
   v_exception_msg := SUBSTR(SQLERRM,1,100);
   OP_RESULT := '-100';
   OP_MSG := 'ESN:'||IP_ESN ||' - '|| v_exception_msg;
END;
/