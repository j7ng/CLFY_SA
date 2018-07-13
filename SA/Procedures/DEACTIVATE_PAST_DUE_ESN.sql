CREATE OR REPLACE PROCEDURE sa.deactivate_past_due_esn( P_ESN IN VARCHAR2) IS
    --------------------------------------------------------------------
    v_user           table_user.objid%TYPE;
    v_returnflag     VARCHAR2(20);
    v_returnmsg      VARCHAR2(200);
    dpp_regflag      PLS_INTEGER;
    v_action         VARCHAR2(50) := 'x_service_id is null in Table_site_part';
    v_procedure_name VARCHAR2(50) := '.ST_SERVICE_DEACT_CATCHUP.DEACTIVATE_PAST_DUE';
    intcalltranobj   NUMBER := 0;
    blnotapending    BOOLEAN := FALSE;
   --------------------------------------------------------------------
    v_start       DATE;
    v_end         DATE;
    v_time_used   NUMBER(10
                        ,2);
    v_start_1     DATE;
    v_end_1       DATE;
    v_time_used_1 NUMBER(10
                        ,2);
    ctr           NUMBER := 0;
    --
    --CR21179 Start Kacosta 06/21/2012
    l_i_error_code    PLS_INTEGER := 0;
    l_v_error_message VARCHAR2(32767) := 'SUCCESS';
	  --
  CURSOR check_esn_curs(c_esn IN VARCHAR2) IS
    SELECT 1
      FROM table_site_part sp2
     WHERE 1 = 1
       AND NVL(sp2.part_status
              ,'Obsolete') IN ('CarrierPending'
                              ,'Active')
       AND sp2.x_service_id = c_esn
       AND NVL(sp2.x_expire_dt
              ,TO_DATE('1753-01-01 00:00:00'
                      ,'yyyy-mm-dd hh24:mi:ss')) > TRUNC(SYSDATE);
  check_esn_rec check_esn_curs%ROWTYPE;
    --------------------------------------------------------------------
   cursor c1 is
    SELECT /*+ ORDERED use_nl(pi2) use_nl(ca) use_nl(ib) use_nl(ir) */
       sp.objid               site_part_objid
      ,sp.x_expire_dt
      ,sp.x_service_id        x_service_id
      ,sp.x_min               x_min
      ,sp.serial_no           x_esn
      ,sp.x_msid
      ,ca.objid               carrier_objid
      ,ir.inv_role2site       site_objid
      ,ca.x_carrier_id        x_carrier_id
      ,sp.site_objid          cust_site_objid
      ,sp.esnobjid            esnobjid
      ,sp.part_serial_no      part_serial_no
      ,sp.x_iccid
      ,sp.x_ota_allowed
      ,sp.org_id
      ,sp.site_part2part_info
      ,sp.esn2part_info
      --remove comment blanca (--)/*+ ORDERED INDEX(sp sp_status_exp_dt_idx)*/
        FROM (SELECT 
               sp.objid
              ,sp.x_service_id
              ,sp.x_min
              ,sp.x_msid
              ,sp.site_objid
              ,sp.serial_no
              ,sp.x_expire_dt
              ,tpi_esn.objid esnobjid
              ,tpi_esn.part_serial_no
              ,tpi_esn.x_iccid
              ,pn.x_ota_allowed
              ,bo.org_id
              ,tpi_esn.part_inst2inv_bin
              ,NVL(site_part2part_info
                  ,-1) site_part2part_info
              ,tpi_esn.n_part_inst2part_mod esn2part_info
                FROM table_site_part sp
                JOIN table_part_inst tpi_esn
                  ON sp.x_service_id = tpi_esn.part_serial_no
                JOIN table_mod_level ml
                  ON tpi_esn.n_part_inst2part_mod = ml.objid
                JOIN table_part_num pn
                  ON ml.part_info2part_num = pn.objid
                JOIN table_bus_org bo
                  ON pn.part_num2bus_org = bo.objid
               WHERE 1 = 1
               --blanca specify ESNs.  condition added sp.x_service_id='260710020940219'
              and sp.x_service_id=p_esn
                 AND NVL(sp.part_status
                        ,'Obsolete') = 'Active'
                 AND NVL(sp.x_expire_dt
                        ,TO_DATE('1753-01-01 00:00:00'
                                ,'yyyy-mm-dd hh24:mi:ss')) > TO_DATE('1753-02-01 00:00:00'
                                                                    ,'yyyy-mm-dd hh24:mi:ss')
                 AND NVL(sp.x_expire_dt
                        ,TO_DATE('1753-01-01 00:00:00'
                                ,'yyyy-mm-dd hh24:mi:ss')) < TRUNC(SYSDATE)
                -- AND MOD(sp.objid ,p_mod_divisor) = p_mod_remainder
                 AND tpi_esn.x_domain = 'PHONES'
               and tpi_esn.part_serial_no=p_esn
                 AND NOT EXISTS (SELECT '1'
                        FROM table_part_inst pi3
                       WHERE pi3.part_to_esn2part_inst = tpi_esn.objid
                         AND pi3.x_domain = 'REDEMPTION CARDS'
                         AND pi3.x_part_inst_status = '400')) sp
        LEFT OUTER JOIN table_inv_bin ib
          ON sp.part_inst2inv_bin = ib.objid
        LEFT OUTER JOIN table_inv_role ir
          ON ib.inv_bin2inv_locatn = ir.inv_role2inv_locatn
        LEFT OUTER JOIN table_part_inst pi2
          ON sp.x_min = pi2.part_serial_no
        LEFT OUTER JOIN table_x_carrier ca
          ON pi2.part_inst2carrier_mkt = ca.objid
       WHERE 1 = 1
         AND pi2.x_domain || '' = 'LINES';
    c1_rec c1%ROWTYPE;
    --
    CURSOR call_trans_igt_info_curs(c_n_site_part_objid IN sa.table_x_call_trans.call_trans2site_part%TYPE) IS
      SELECT igt.carrier_id igt_carrier_id
            ,txc.objid      igt_carrier_objid
        FROM sa.table_x_call_trans xct
        JOIN sa.table_task tbt
          ON xct.objid = tbt.x_task2x_call_trans
        JOIN gw1.ig_transaction igt
          ON tbt.task_id = igt.action_item_id
        JOIN table_x_carrier txc
          ON igt.carrier_id = txc.x_carrier_id
       WHERE xct.call_trans2site_part = c_n_site_part_objid
         AND xct.x_action_type <> '2'
         AND xct.x_result = 'Completed'
         AND igt.status = 'S'
         AND igt.order_type NOT IN ('S'
                                   ,'D')
         AND igt.creation_date = (SELECT MAX(igt_max_xact.creation_date)
                                    FROM sa.table_x_call_trans xct_max_xact
                                    JOIN sa.table_task tbt_max_xact
                                      ON xct_max_xact.objid = tbt_max_xact.x_task2x_call_trans
                                    JOIN gw1.ig_transaction igt_max_xact
                                      ON tbt_max_xact.task_id = igt_max_xact.action_item_id
                                   WHERE xct_max_xact.call_trans2site_part = c_n_site_part_objid
                                     AND xct_max_xact.x_action_type <> '2'
                                     AND xct_max_xact.x_result = 'Completed'
                                     AND igt_max_xact.status = 'S'
                                     AND igt_max_xact.order_type NOT IN ('S'
                                                                        ,'D'));
    --
    call_trans_igt_info_rec call_trans_igt_info_curs%ROWTYPE;
    --
    CURSOR call_trans_igth_info_curs(c_n_site_part_objid IN sa.table_x_call_trans.call_trans2site_part%TYPE) IS
      SELECT igh.carrier_id igh_carrier_id
            ,txc.objid      igh_carrier_objid
        FROM sa.table_x_call_trans xct
        JOIN sa.table_task tbt
          ON xct.objid = tbt.x_task2x_call_trans
        JOIN gw1.ig_transaction_history igh
          ON tbt.task_id = igh.action_item_id
        JOIN table_x_carrier txc
          ON igh.carrier_id = txc.x_carrier_id
       WHERE xct.call_trans2site_part = c_n_site_part_objid
         AND xct.x_action_type <> '2'
         AND xct.x_result = 'Completed'
         AND igh.status = 'S'
         AND igh.order_type NOT IN ('S'
                                   ,'D')
         AND igh.creation_date = (SELECT MAX(igh_max_xact.creation_date)
                                    FROM sa.table_x_call_trans xct_max_xact
                                    JOIN sa.table_task tbt_max_xact
                                      ON xct_max_xact.objid = tbt_max_xact.x_task2x_call_trans
                                    JOIN gw1.ig_transaction_history igh_max_xact
                                      ON tbt_max_xact.task_id = igh_max_xact.action_item_id
                                   WHERE xct_max_xact.call_trans2site_part = c_n_site_part_objid
                                     AND xct_max_xact.x_action_type <> '2'
                                     AND xct_max_xact.x_result = 'Completed'
                                     AND igh_max_xact.status = 'S'
                                     AND igh_max_xact.order_type NOT IN ('S'
                                                                        ,'D'));
    --
    call_trans_igth_info_rec call_trans_igth_info_curs%ROWTYPE;
    --
    CURSOR excluded_pastduedeact_curs(c_n_carrier_id x_excluded_pastduedeact.x_carrier_id%TYPE) IS
      SELECT xep.x_carrier_id excluded_pastduedeact
        FROM x_excluded_pastduedeact xep
       WHERE xep.x_carrier_id = c_n_carrier_id;
    --
    excluded_pastduedeact_rec excluded_pastduedeact_curs%ROWTYPE;
    --
    --CR21179 End Kacosta 06/21/2012
    --
    CURSOR c_chkotapend(c_esn IN VARCHAR2) IS
      SELECT 'X'
        FROM table_x_call_trans
       WHERE objid = (SELECT MAX(objid)
                        FROM table_x_call_trans
                       WHERE x_service_id = c_esn)
         AND x_result = 'OTA PENDING'
         AND x_action_type = '6';
    r_chkotapend c_chkotapend%ROWTYPE;
    CURSOR check_active_min_curs(c_min IN VARCHAR2) IS
      SELECT 1
        FROM table_site_part sp2
       WHERE 1 = 1
         AND NVL(sp2.part_status
                ,'Obsolete') IN ('CarrierPending'
                                ,'Active')
         AND sp2.x_min = c_min
         AND NVL(sp2.x_expire_dt
                ,TO_DATE('1753-01-01 00:00:00'
                        ,'yyyy-mm-dd hh24:mi:ss')) > TRUNC(SYSDATE);
    check_active_min_rec check_active_min_curs%ROWTYPE;
    CURSOR past_due_batch_check_curs(c_sp_objid IN NUMBER) IS
      SELECT sp.objid
        FROM table_site_part sp
       WHERE 1 = 1
         AND sp.part_status = 'Active'
         AND NVL(sp.x_expire_dt
                ,TO_DATE('1753-01-01 00:00:00'
                        ,'yyyy-mm-dd hh24:mi:ss')) > TO_DATE('1753-02-01 00:00:00'
                                                            ,'yyyy-mm-dd hh24:mi:ss')
         AND NVL(sp.x_expire_dt
                ,TO_DATE('1753-01-01 00:00:00'
                        ,'yyyy-mm-dd hh24:mi:ss')) < TRUNC(SYSDATE)
         AND sp.objid = c_sp_objid;
    past_due_batch_check_rec past_due_batch_check_curs%ROWTYPE;
    ------------------------------------------------------------------------------------------------
  BEGIN
FOR c1_rec IN c1 LOOP    --CR21179 Start Kacosta 06/21/2012
    BEGIN
      --
      bau_maintenance_pkg.fix_1753_due_dates(p_bus_org_id    => c1_rec.org_id
                                            ,p_mod_divisor   => 1--p_mod_divisor
                                            ,p_mod_remainder => 0--p_mod_remainder
                                            ,p_error_code    => l_i_error_code
                                            ,p_error_message => l_v_error_message);
      --
    EXCEPTION
      WHEN others THEN
        --
        NULL;
        --
    END;
    --CR21179 End Kacosta 06/21/2012
    --
    v_start_1 := SYSDATE;
    SELECT objid
      INTO v_user
      FROM table_user
     WHERE s_login_name = 'SA';
      --
      --CR21179 Start Kacosta 06/21/2012
      IF (c1_rec.site_part2part_info <> c1_rec.esn2part_info) THEN
        --
        UPDATE table_site_part tsp
           SET tsp.site_part2part_info = c1_rec.esn2part_info
         WHERE tsp.objid = c1_rec.site_part_objid;
        --
        COMMIT;
        --
      END IF;
      --
      IF (c1_rec.carrier_objid IS NULL) THEN
        --
        IF call_trans_igt_info_curs%ISOPEN THEN
          --
          CLOSE call_trans_igt_info_curs;
          --
        END IF;
        --
        OPEN call_trans_igt_info_curs(c_n_site_part_objid => c1_rec.site_part_objid);
        FETCH call_trans_igt_info_curs
          INTO call_trans_igt_info_rec;
        CLOSE call_trans_igt_info_curs;
        --
        IF (call_trans_igt_info_rec.igt_carrier_objid IS NULL) THEN
          --
          IF call_trans_igth_info_curs%ISOPEN THEN
            --
            CLOSE call_trans_igth_info_curs;
            --
          END IF;
          --
          OPEN call_trans_igth_info_curs(c_n_site_part_objid => c1_rec.site_part_objid);
          FETCH call_trans_igth_info_curs
            INTO call_trans_igth_info_rec;
          CLOSE call_trans_igth_info_curs;
          --
          IF (call_trans_igth_info_rec.igh_carrier_objid IS NULL) THEN
            --
            toss_util_pkg.insert_error_tab_proc(ip_action       => 'Get IG_TRANSACTIONS carrier id'
                                               ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                               ,ip_program_name => 'SERVICE_DEACTIVATION_CODE.DEACTIVATE_PAST_DUE'
                                               ,ip_error_text   => 'Unable to find IG_TRANSACTIONS carrier id');
            --
            GOTO skip_this_deactivation;
            --
          END IF;
          --
          call_trans_igt_info_rec.igt_carrier_id    := call_trans_igth_info_rec.igh_carrier_id;
          call_trans_igt_info_rec.igt_carrier_objid := call_trans_igth_info_rec.igh_carrier_objid;
          --
        END IF;
        --
        c1_rec.x_carrier_id  := call_trans_igt_info_rec.igt_carrier_id;
        c1_rec.carrier_objid := call_trans_igt_info_rec.igt_carrier_objid;
        --
        UPDATE table_part_inst
           SET part_inst2carrier_mkt = c1_rec.carrier_objid
         WHERE part_serial_no = c1_rec.x_min;
        --
        COMMIT;
        --
      END IF;
      --
      IF excluded_pastduedeact_curs%ISOPEN THEN
        --
        CLOSE excluded_pastduedeact_curs;
        --
      END IF;
      --
      OPEN excluded_pastduedeact_curs(c_n_carrier_id => c1_rec.x_carrier_id);
      FETCH excluded_pastduedeact_curs
        INTO excluded_pastduedeact_rec;
      CLOSE excluded_pastduedeact_curs;
      --
      IF (excluded_pastduedeact_rec.excluded_pastduedeact IS NOT NULL) THEN
        --
        BEGIN
          --
          toss_util_pkg.insert_error_tab_proc(ip_action       => 'Check if carrier is an excluded pastduedeact carrier'
                                             ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                             ,ip_program_name => 'SERVICE_DEACTIVATION_CODE.DEACTIVATE_PAST_DUE'
                                             ,ip_error_text   => 'Carrier is an excluded pastduedeact carrier');
          --
        EXCEPTION
          WHEN others THEN
            --
            NULL;
            --
        END;
        --
        GOTO skip_this_deactivation;
        --
      END IF;
      --CR21179 End Kacosta 06/21/2012
      --
      dbms_output.put_line('c1_rec.x_service_id:' || c1_rec.x_service_id);
      OPEN past_due_batch_check_curs(c1_rec.site_part_objid);
      FETCH past_due_batch_check_curs
        INTO past_due_batch_check_rec;
      IF past_due_batch_check_curs%NOTFOUND THEN
        dbms_output.put_line('past_due_batch_check_curs%notfound');
        CLOSE past_due_batch_check_curs;
        COMMIT;
        --
        --CR21179 Start Kacosta 06/21/2012
        BEGIN
          --
          toss_util_pkg.insert_error_tab_proc(ip_action       => 'Check past due batch'
                                             ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                             ,ip_program_name => 'SERVICE_DEACTIVATION_CODE.DEACTIVATE_PAST_DUE'
                                             ,ip_error_text   => 'Past due batch check not found');
          --
        EXCEPTION
          WHEN others THEN
            --
            NULL;
            --
        END;
        --CR21179 End Kacosta 06/21/2012
        --
        GOTO skip_this_deactivation;
      END IF;
      CLOSE past_due_batch_check_curs;
      OPEN check_active_min_curs(c1_rec.x_min);
      FETCH check_active_min_curs
        INTO check_active_min_rec;
      IF check_active_min_curs%FOUND THEN
        UPDATE table_site_part
           SET part_status = 'Inactive'
         WHERE objid = c1_rec.site_part_objid;
        dbms_output.put_line('check_active_min_curs%found');
        OPEN check_esn_curs(c1_rec.x_service_id);
        FETCH check_esn_curs
          INTO check_esn_rec;
        IF check_esn_curs%NOTFOUND THEN
          dbms_output.put_line('check_esn_curs%found');
          UPDATE table_part_inst
             SET x_part_inst_status  = '54'
                ,status2x_code_table = 990
           WHERE part_serial_no = c1_rec.x_service_id;
        END IF;
        CLOSE check_esn_curs;
        CLOSE check_active_min_curs;
        COMMIT;
        GOTO skip_this_deactivation;
      END IF;
      CLOSE check_active_min_curs;
      IF (c1_rec.x_service_id IS NULL) THEN
        UPDATE table_site_part
           SET x_service_id = NVL(c1_rec.x_esn
                                 ,c1_rec.part_serial_no)
         WHERE objid = c1_rec.site_part_objid;
        COMMIT;
      END IF;
      sa.service_deactivation_code.check_dpp_registered_prc(c1_rec.x_service_id
                                                           ,dpp_regflag);
      IF dpp_regflag = 1 THEN
        --CR21179 Start Kacosta 06/21/2012
        BEGIN
          --
          toss_util_pkg.insert_error_tab_proc(ip_action       => 'Calling service_deactivation_code.check_dpp_registered_prc'
                                             ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                             ,ip_program_name => 'SERVICE_DEACTIVATION_CODE.DEACTIVATE_PAST_DUE'
                                             ,ip_error_text   => 'service_deactivation_code.check_dpp_registered_prc prevents ESN to be deactivated');
          --
        EXCEPTION
          WHEN others THEN
            --
            NULL;
            --
        END;
        --CR21179 End Kacosta 06/21/2012
        --
        service_deactivation_code.create_call_trans(c1_rec.site_part_objid
                                                   ,84
                                                   ,c1_rec.carrier_objid
                                                   ,c1_rec.site_objid
                                                   ,v_user
                                                   ,c1_rec.x_min
                                                   ,c1_rec.x_service_id
                                                   ,'PROTECTION PLAN BATCH'
                                                   ,SYSDATE
                                                   ,NULL
                                                   ,'Monthly Payments'
                                                   ,'PASTDUE'
                                                   ,'Pending'
                                                   ,c1_rec.x_iccid
                                                   ,c1_rec.org_id
                                                   ,intcalltranobj);
      ELSE
        IF (billing_deactprotect(c1_rec.x_service_id) = 1) THEN
          NULL;
          --CR21179 Start Kacosta 06/21/2012
          BEGIN
            --
            toss_util_pkg.insert_error_tab_proc(ip_action       => 'Calling billing_deactprotect'
                                               ,ip_key          => 'Site Part Objid: ' || TO_CHAR(c1_rec.site_part_objid)
                                               ,ip_program_name => 'SERVICE_DEACTIVATION_CODE.DEACTIVATE_PAST_DUE'
                                               ,ip_error_text   => 'billing_deactprotect prevents ESN to be deactivated');
            --
          EXCEPTION
            WHEN others THEN
              --
              NULL;
              --
          END;
          --CR21179 End Kacosta 06/21/2012
          --
        ELSE
          Service_Deactivation_code.deactservice('PAST_DUE_BATCH'
                      ,v_user
                      ,c1_rec.x_service_id
                      ,c1_rec.x_min
                      ,'PASTDUE'
                      ,0
                      ,NULL
                      ,'true'
                      ,v_returnflag
                      ,v_returnmsg);
        END IF;
      END IF;
      FOR c2_rec IN (SELECT ROWID
                       FROM table_x_group2esn
                      WHERE groupesn2part_inst = c1_rec.esnobjid
                        AND groupesn2x_promo_group IN (SELECT objid
                                                         FROM table_x_promotion_group
                                                        WHERE group_name IN ('90_DAY_SERVICE'
                                                                            ,'52020_GRP'))) LOOP
        UPDATE table_x_group2esn u
           SET x_end_date = SYSDATE
         WHERE u.rowid = c2_rec.rowid;
        COMMIT;
      END LOOP;
      <<skip_this_deactivation>>
      COMMIT;
    END LOOP;
    v_end_1       := SYSDATE;
    v_time_used_1 := (v_end_1 - v_start_1) * 24 * 60;
    dbms_output.put_line('END_PROCEDURE call Total time used for esn: ' || v_time_used_1);
 END deactivate_past_due_esn;

/