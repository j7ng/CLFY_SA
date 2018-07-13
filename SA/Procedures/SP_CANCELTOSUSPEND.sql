CREATE OR REPLACE PROCEDURE sa."SP_CANCELTOSUSPEND" AS
  --
  ---------------------------------------------------------------------------------------------
  --$RCSfile: SP_CANCELTOSUSPEND.sql,v $
  --$Revision: 1.3 $
  --$Author: kacosta $
  --$Date: 2012/01/18 18:42:50 $
  --$ $Log: SP_CANCELTOSUSPEND.sql,v $
  --$ Revision 1.3  2012/01/18 18:42:50  kacosta
  --$ CR19537 Suspend to Cancel Enhancement
  --$
  --$
  ---------------------------------------------------------------------------------------------
  --
  CURSOR check_newer_deact_curs
  (
    c_min      IN VARCHAR2
   ,c_cs_objid IN NUMBER
  ) IS
    SELECT cs.objid
      FROM x_canceltosuspend cs
     WHERE cs.objid > c_cs_objid
       AND cs.x_min = c_min;
  check_newer_deact_rec check_newer_deact_curs%ROWTYPE;
  CURSOR deact_curs IS
    SELECT sp.*
          ,cs.objid cs_objid
          ,(SELECT objid
              FROM table_user
             WHERE s_login_name = 'SA') user_objid
          ,(SELECT ct.x_transact_date
              FROM table_x_call_trans ct
             WHERE ct.objid = cs.x_call_trans_objid) ct_transact_date
      FROM table_site_part   sp
          ,x_canceltosuspend cs
     WHERE sp.objid = cs.x_site_part_objid
       AND cs.x_status = 'PENDING'
       AND cs.x_cancelto_suspend_date < TRUNC(SYSDATE);
  CURSOR act_sp_curs(c_min IN VARCHAR2) IS
    SELECT *
      FROM table_site_part sp
     WHERE sp.x_min = c_min
       AND sp.part_status IN ('Active'
                             ,'Carrier Pending');
  act_sp_rec act_sp_curs%ROWTYPE;
  CURSOR max_call_trans_curs
  (
    c_min           IN VARCHAR2
   ,c_transact_date IN DATE
  ) IS
    SELECT ct.objid
      FROM table_x_call_trans ct
          ,table_site_part    sp
     WHERE 1 = 1
       AND ct.x_transact_date + 0 > c_transact_date
       AND ct.call_trans2site_part = sp.objid
       AND sp.x_min = c_min;
  max_call_trans_rec max_call_trans_curs%ROWTYPE;
  CURSOR cur_ph
  (
    c_esn IN VARCHAR2
   ,c_min IN VARCHAR2
  ) IS
    SELECT a.*
          ,a.rowid esn_rowid
          ,c.x_technology
          ,NVL(c.x_restricted_use
              ,0) x_restricted_use
          ,e.objid siteobjid
          ,f.service_end_dt
          ,f.x_expire_dt
          ,f.x_deact_reason
          ,f.part_status f_part_status
          ,f.x_notify_carrier
          ,f.objid sitepartobjid
          ,f.x_service_id
          ,f.x_min
          ,f.install_date
          ,f.site_part2x_new_plan
          ,f.site_part2x_plan
          ,f.x_iccid sp_iccid
          ,f.rowid site_part_rowid
          ,bo.org_id
      FROM table_part_inst a
          ,table_mod_level b
          ,table_part_num  c
          ,table_bus_org   bo
          ,table_inv_bin   d
          ,table_site      e
          ,table_site_part f
     WHERE 1 = 1
       AND f.objid = (SELECT MAX(sp.objid)
                        FROM table_site_part sp
                       WHERE sp.part_status != 'Obsolete'
                         AND sp.x_service_id = a.part_serial_no
                         AND sp.x_min = c_min)
       AND d.bin_name = e.site_id
       AND a.part_inst2inv_bin = d.objid
       AND c.part_num2bus_org = bo.objid
       AND b.part_info2part_num = c.objid
       AND a.n_part_inst2part_mod = b.objid
       AND a.part_serial_no = c_esn
       AND a.x_domain = 'PHONES';
  rec_ph cur_ph%ROWTYPE;
  CURSOR cur_min
  (
    ip_min IN VARCHAR2
   ,c_tech IN VARCHAR2
  ) IS
    SELECT pi.objid
          ,pi.part_serial_no
          ,pi.part_inst2carrier_mkt
          ,NVL(pi.x_port_in
              ,0) x_port_in
          ,pi.x_part_inst_status
          ,pi.x_npa
          ,pi.x_nxx
          ,pi.x_ext
          ,pi.rowid min_rowid
          ,pi.status2x_code_table
          ,pi.x_cool_end_date
          ,pi.warr_end_date
          ,pi.last_trans_time
          ,pi.repair_date
          ,pi.part_inst2x_pers
          ,pi.part_inst2x_new_pers
          ,pi.part_to_esn2part_inst
          ,pi.last_cycle_ct
          ,p.x_parent_id
          ,cr.x_line_return_days
          ,cr.x_cooling_period
          ,cr.x_used_line_expire_days
          ,cr.x_gsm_grace_period
          ,cr.x_reserve_on_suspend
          ,cr.x_reserve_period
          ,cr.x_deac_after_grace
          ,(SELECT COUNT(*)
              FROM table_x_block_deact
             WHERE x_block_active = 1
               AND x_parent_id = p.x_parent_id
               AND x_code_name = 'CANCELFROMSUSPEND'
               AND ROWNUM < 2) block_deact_exists
          -- CR19537 Start KACOSTA 01/09/2012
          ,cr.x_cancel_suspend
          -- CR19537 End KACOSTA 01/09/2012
      FROM table_x_parent        p
          ,table_x_carrier_group cg
          ,table_x_carrier_rules cr
          ,table_x_carrier       c
          ,table_part_inst       pi
     WHERE 1 = 1
       AND p.objid = cg.x_carrier_group2x_parent
       AND cg.objid = c.carrier2carrier_group
       AND cr.objid = DECODE(c_tech
                            ,'GSM'
                            ,c.carrier2rules_gsm
                            ,'CDMA'
                            ,c.carrier2rules_cdma
                            ,c.carrier2rules)
       AND c.objid = pi.part_inst2carrier_mkt
       AND pi.part_serial_no = ip_min
       AND pi.x_domain = 'LINES';
  rec_min cur_min%ROWTYPE;
  l_min   VARCHAR2(30) := NULL;
  l_step  VARCHAR2(300) := NULL;
  -------------------------------------------------------------------------------------------------------------
  intcalltranobj NUMBER;
  intstatcode    NUMBER;
  intactitemobj  NUMBER;
  intordtypeobj  NUMBER;
  inttransmethod NUMBER;
BEGIN
  FOR deact_rec IN deact_curs LOOP
    BEGIN
      l_min  := deact_rec.x_min;
      l_step := 'step 1';
      OPEN check_newer_deact_curs(deact_rec.x_min
                                 ,deact_rec.cs_objid);
      FETCH check_newer_deact_curs
        INTO check_newer_deact_rec;
      IF check_newer_deact_curs%FOUND THEN
        CLOSE check_newer_deact_curs;
        dbms_output.put_line('check_newer_deact_curs%found');
        UPDATE x_canceltosuspend
           SET x_status         = 'PROCESSED'
              ,x_processed_date = SYSDATE
              ,x_result         = 'newer deact found'
         WHERE objid = deact_rec.cs_objid; --CR16282
        COMMIT;
        GOTO nextdeactrec;
      END IF;
      CLOSE check_newer_deact_curs;
      l_step := 'step 2';
      OPEN act_sp_curs(deact_rec.x_min);
      FETCH act_sp_curs
        INTO act_sp_rec;
      IF act_sp_curs%FOUND THEN
        dbms_output.put_line('act_sp_curs%found');
        UPDATE x_canceltosuspend
           SET x_status         = 'PROCESSED'
              ,x_processed_date = SYSDATE
              ,x_result         = 'min is active'
         WHERE objid = deact_rec.cs_objid; --CR16282
        COMMIT;
        CLOSE act_sp_curs;
        GOTO nextdeactrec;
      END IF;
      CLOSE act_sp_curs;
      l_step := 'step 3';
      OPEN max_call_trans_curs(deact_rec.x_min
                              ,deact_rec.ct_transact_date);
      IF max_call_trans_curs%FOUND THEN
        dbms_output.put_line('max_call_trans_curs%found');
        UPDATE x_canceltosuspend
           SET x_status         = 'PROCESSED'
              ,x_processed_date = SYSDATE
              ,x_result         = 'newer call_trans found'
         WHERE objid = deact_rec.cs_objid; --CR16282
        COMMIT;
        CLOSE max_call_trans_curs;
        GOTO nextdeactrec;
      END IF;
      CLOSE max_call_trans_curs;
      l_step := 'step 4';
      dbms_output.put_line('deact_rec.x_service_id:' || deact_rec.x_service_id);
      dbms_output.put_line('deact_rec.x_min:' || deact_rec.x_min);
      OPEN cur_ph(deact_rec.x_service_id
                 ,deact_rec.x_min);
      FETCH cur_ph
        INTO rec_ph;
      IF cur_ph%NOTFOUND THEN
        dbms_output.put_line('cur_ph%notfound');
        UPDATE x_canceltosuspend
           SET x_status         = 'PROCESSED'
              ,x_processed_date = SYSDATE
              ,x_result         = 'esn not found'
         WHERE objid = deact_rec.cs_objid; --CR16282
        COMMIT;
        CLOSE cur_ph;
        GOTO nextdeactrec;
      END IF;
      CLOSE cur_ph;
      l_step := 'step 5';
      OPEN cur_min(deact_rec.x_min
                  ,rec_ph.x_technology);
      FETCH cur_min
        INTO rec_min;
      IF cur_min%NOTFOUND THEN
        dbms_output.put_line('cur_min%notfound');
        UPDATE x_canceltosuspend
           SET x_status         = 'PROCESSED'
              ,x_processed_date = SYSDATE
              ,x_result         = 'min not found'
         WHERE objid = deact_rec.cs_objid; --CR16282
        COMMIT;
        CLOSE cur_min;
        GOTO nextdeactrec;
        --
        -- CR19537 Start KACOSTA 01/09/2012
      ELSIF NVL(rec_min.x_cancel_suspend
               ,0) <> 1 THEN
        --
        dbms_output.put_line('rec_min.x_cancel_suspend <> 1');
        --
        UPDATE x_canceltosuspend
           SET x_status         = 'PROCESSED'
              ,x_processed_date = SYSDATE
              ,x_result         = 'rules changed'
         WHERE objid = deact_rec.cs_objid;
        --
        COMMIT;
        --
        CLOSE cur_min;
        --
        GOTO nextdeactrec;
        -- CR19537 End KACOSTA 01/09/2012
        --
      ELSIF rec_min.block_deact_exists > 0 THEN
        dbms_output.put_line('rec_min.block_deact_exists');
        UPDATE x_canceltosuspend
           SET x_status         = 'PROCESSED'
              ,x_processed_date = SYSDATE
              ,x_result         = 'deact blocked'
         WHERE objid = deact_rec.cs_objid; --CR16282
        COMMIT;
        CLOSE cur_min;
        GOTO nextdeactrec;
      END IF;
      CLOSE cur_min;
      l_step := 'step 6';
      dbms_output.put_line('Creating a call trans record');
      service_deactivation_code.create_call_trans(rec_ph.sitepartobjid
                                                 ,2
                                                 ,rec_min.part_inst2carrier_mkt
                                                 ,rec_ph.siteobjid
                                                 ,deact_rec.user_objid
                                                 ,deact_rec.x_min
                                                 ,deact_rec.x_service_id
                                                 ,'PAST_DUE_BATCH'
                                                 ,SYSDATE
                                                 ,NULL
                                                 ,'DEACTIVATION'
                                                 ,'CANCELFROMSUSPEND'
                                                 ,'Completed'
                                                 ,NVL(deact_rec.x_iccid
                                                     ,rec_ph.x_iccid)
                                                 ,rec_ph.org_id
                                                 ,intcalltranobj);
      IF intcalltranobj IS NULL THEN
        UPDATE x_canceltosuspend
           SET x_status         = 'PROCESSED'
              ,x_processed_date = SYSDATE
              ,x_result         = 'call_trans not created'
         WHERE objid = deact_rec.cs_objid; --CR16282
        COMMIT;
        GOTO nextdeactrec;
      END IF;
      --
      l_step := 'step 7';
      dbms_output.put_line('before sp_create_action_item');
      igate.sp_create_action_item(rec_ph.x_part_inst2contact
                                 ,intcalltranobj
                                 ,'Deactivation'
                                 ,0
                                 ,0
                                 ,intstatcode
                                 ,intactitemobj);
      IF intactitemobj IS NULL THEN
        UPDATE x_canceltosuspend
           SET x_status         = 'PROCESSED'
              ,x_processed_date = SYSDATE
              ,x_result         = 'action_item not created'
         WHERE objid = deact_rec.cs_objid; --CR16282
        COMMIT;
        GOTO nextdeactrec;
      END IF;
      dbms_output.put_line('after sp_create_action_item');
      l_step := 'step 8';
      igate.sp_get_ordertype(rec_min.part_serial_no
                            ,'Deactivation'
                            ,rec_min.part_inst2carrier_mkt
                            ,rec_ph.x_technology
                            ,intordtypeobj);
      l_step := 'step 9';
      igate.sp_determine_trans_method(intactitemobj
                                     ,'Deactivation'
                                     ,NULL
                                     ,inttransmethod);
      IF inttransmethod IS NULL THEN
        UPDATE x_canceltosuspend
           SET x_status         = 'PROCESSED'
              ,x_processed_date = SYSDATE
              ,x_result         = 'create trans method error'
         WHERE objid = deact_rec.cs_objid; --CR16282
        COMMIT;
        GOTO nextdeactrec;
      END IF;
      l_step := 'step 10';
      UPDATE x_canceltosuspend
         SET x_status         = 'PROCESSED'
            ,x_processed_date = SYSDATE
            ,x_result         = 'ig created'
       WHERE objid = deact_rec.cs_objid; --CR16282
      COMMIT;
      <<nextdeactrec>>
      l_step := 'step 11';
    EXCEPTION
      WHEN others THEN
        l_step := l_step || ' ' || SQLCODE || ' ' || SUBSTR(SQLERRM
                                                           ,1
                                                           ,200);
        toss_util_pkg.insert_error_tab_proc(l_step
                                           ,l_min
                                           ,'SA.sp_canceltosuspend');
    END;
  END LOOP;
END;
/