CREATE OR REPLACE PROCEDURE sa."BREAK_UNUSED_RESERV_PRC"
AS
  /*********************************************************************************/
  /* Copyright (r) 2008 Tracfone Wireless Inc. All rights reserved */
  /* */
  /* Name : SA.BREAK_UNUSED_RESERV_PRC */
  /* Purpose : Collect and process where x_code_number */
  /* : includes reserved and redemption pending */
  /* : this is a DBMS JOB */
  /* Platforms : Oracle 10g */
  /* Revisions : */
  /* Version Date Who Purpose */
  /* ------- -------- ------- --------------------------------- */
  /* 1.0 09/01/08 ICanavan CR7777 Add x_code 263 */
  /* 1.1 09/30/08 CLinder CR7777 Tune cursor C1 */
  /* 1.2 10/21/08 ICanavan CR7777 Move delete to part inst */
  /******************************************************************************************/
  /* CVS FILE STRUCTURE
  /* 1.1 05/13/10 ICanavan CR12793 excluded Straight Talk Red Cards in main cursor
  /******************************************************************************************/
  --
  --********************************************************************************
  --$RCSfile: BREAK_UNUSED_RESERV_PRC.sql,v $
  --$
  --$ Revision 1.9  2017/04/27 17:00:00  mtoribiolopez
  --$ C83328  Extend Broken Card Process for APP and FREE pins
  --$
  --$Revision: 1.8 $
  --$Author: vyegnamurthy $
  --$Date: 2016/06/27 15:01:15 $
  --$ $Log: BREAK_UNUSED_RESERV_PRC.sql,v $
  --$ Revision 1.8  2016/06/27 15:01:15  vyegnamurthy
  --$ CR43600
  --$
  --$ Revision 1.6  2014/05/22 18:49:49  akhan
  --$ CR22877 Inv cards capure
  --$
  --$ Revision 1.5  2014/03/31 18:10:14  akhan
  --$ included straight_talk.
  --$
  --$ Revision 1.4  2013/11/06 16:35:51  lsatuluri
  --$ CR22877 Added the pin status 44
  --$
  --$ Revision 1.3 2012/03/21 14:11:43 kacosta
  --$ CR20137 Improve Broken Card Process
  --$
  --$
  --********************************************************************************
  --
  CURSOR c1
  IS
    -- CR7777 added 263 and tuned the cursor
    -- CR12793 excluded Straight Talk Redemption Cards in main cursor
    -- C83328 excluded filter for APP and FREE cards
    SELECT *
    FROM
      (SELECT part_serial_no ,
        x_part_inst_status ,
        last_trans_time ,
        part_inst2inv_bin ,
        n_part_inst2part_mod ,
        part_to_esn2part_inst,
        (SELECT pn.part_number
        FROM sa.table_mod_level ml ,
          sa.table_part_num pn
        WHERE 1      = 1
        AND pn.objid = ml.part_info2part_num
        AND ml.objid = pi.n_part_inst2part_mod
          --AND part_num2bus_org NOT IN (SELECT objid
          --                               FROM table_bus_org
          --                              WHERE org_id = 'STRAIGHT_TALK')
        ) part_number
    FROM sa.table_part_inst pi
    WHERE 1                  = 1
    AND x_domain = 'REDEMPTION CARDS'
    AND (x_part_inst_status IN ('40' ,'43' ,'263')
    OR (x_part_inst_status   = '44'
    AND EXISTS
      (SELECT 1
      FROM toppapp.x_tu_log
      WHERE "Smp"  = PI.part_serial_no
      AND "Action" = '500'
      ) ) )
    AND last_trans_time < TRUNC(SYSDATE) - 15
    AND last_trans_time > TRUNC(SYSDATE) - 16
      )
    --WHERE 1 = 1
    --AND part_number NOT LIKE '%APP%'
    --AND part_number NOT LIKE '%FREE%'
    ;
    CURSOR c0(ip_smp1 IN VARCHAR2)
    IS
      SELECT 1
      FROM sa.table_x_red_card
      WHERE x_smp = ip_smp1
      AND x_result
        || '' IN ('Completed' ,'Broken Card');
    r0 c0%ROWTYPE;
    CURSOR c2(ip_n_part_inst2part_mod IN NUMBER)
    IS
      SELECT pn.x_redeem_days ,
        pn.x_redeem_units
      FROM sa.table_part_num pn ,
        sa.table_mod_level ml
      WHERE 1      = 1
      AND pn.objid = ml.part_info2part_num
      AND ml.objid = ip_n_part_inst2part_mod;
    r2 c2%ROWTYPE;
    CURSOR c3(ip_smp IN VARCHAR2)
    IS
      SELECT x_red_code ,
        x_insert_date ,
        x_creation_date ,
        x_order_number ,
        x_po_num ,
        part_to_esn2part_inst
      FROM sa.table_part_inst
      WHERE part_serial_no = ip_smp
      AND x_domain = 'REDEMPTION CARDS';
    r3 c3%ROWTYPE;
    CURSOR c4(ip_esn_objid IN VARCHAR2)
    IS
      SELECT pimin.part_serial_no line ,
        pimin.part_inst2carrier_mkt ca_objid ,
        piesn.part_serial_no esn ,
        piesn.x_iccid ,
        ts.objid dlr_objid
      FROM sa.table_site ts ,
        sa.table_inv_bin ib ,
        sa.table_part_inst pimin ,
        sa.table_part_inst piesn
      WHERE ts.site_id                = ib.bin_name
      AND ib.objid                    = piesn.part_inst2inv_bin
      AND pimin.part_to_esn2part_inst = piesn.objid
      AND pimin.x_domain              = 'LINES'
      AND piesn.objid                 = ip_esn_objid;
    r4 c4%ROWTYPE;
    CURSOR c5(ip_esn IN VARCHAR2)
    IS
      SELECT MAX(objid) sp_objid
      FROM sa.table_site_part
      WHERE x_service_id = ip_esn
      AND part_status
        || '' IN ('Active' ,'Inactive');
    r5 c5%ROWTYPE;
    CURSOR c6(ip_esn_objid IN NUMBER)
    IS
      SELECT part_serial_no FROM sa.table_part_inst WHERE objid = ip_esn_objid;
    r6 c6%ROWTYPE;
    CURSOR c7(ip_sp_objid IN NUMBER)
    IS
      SELECT pi.part_inst2carrier_mkt carr_objid
      FROM sa.table_part_inst pi ,
        sa.table_site_part sp
      WHERE sp.objid        = pi.x_part_inst2site_part
      AND pi.part_serial_no = sp.x_min
      AND sp.objid          = ip_sp_objid;
    r7 c7%ROWTYPE;
    v_call_trans_objid     NUMBER;
    l_smp                  VARCHAR2(20);
    v_trans_time           DATE;
    v_errm                 VARCHAR2(4000);
    l_carr_objid           NUMBER;
    l_action               VARCHAR2(1000);
    v_call_trans2site_part NUMBER ; --CR43600
    l_flag_broken          VARCHAR2(10) := 'true';
    v_has_ct                NUMBER := 0;
  BEGIN
    FOR r1 IN c1
    LOOP
      BEGIN
        l_smp        := r1.part_serial_no;
        v_trans_time := SYSDATE + (3 / 24 / 60 / 60);
        l_action     := 'Red Card Check';
        l_flag_broken := 'true';
        OPEN c0(r1.part_serial_no);
        FETCH c0 INTO r0;
        IF c0%NOTFOUND THEN
          l_action := 'Part Num Check';
          OPEN c2(r1.n_part_inst2part_mod);
          FETCH c2 INTO r2;
          CLOSE c2;
          l_action := 'Part Inst Check';
          OPEN c3(r1.part_serial_no);
          FETCH c3 INTO r3;
          IF c3%FOUND THEN
            l_action := 'Line (part inst) Check';
            OPEN c4(r3.part_to_esn2part_inst);
            FETCH c4 INTO r4;
            IF c4%NOTFOUND THEN
              l_action := 'Line (site part) Check 1';
              OPEN c6(r3.part_to_esn2part_inst);
              FETCH c6 INTO r6;
              CLOSE c6;
              l_action := 'Line (site part) Check 2';
              OPEN c5(r6.part_serial_no);
              FETCH c5 INTO r5;
              CLOSE c5;
              l_action := 'Line (site part) Check 3';
              OPEN c7(r5.sp_objid);
              FETCH c7 INTO r7;
              CLOSE c7;
              l_carr_objid := r7.carr_objid;
            ELSIF c4%FOUND THEN
              l_carr_objid := r4.ca_objid;
              l_action     := 'Line (site part) Check 4';
              OPEN c5(r4.esn);
              FETCH c5 INTO r5;
              CLOSE c5;
            END IF;
            CLOSE c4;
            IF r1.part_to_esn2part_inst IS NOT NULL THEN
              -- C83328 FREE card can be moved to RC if there's a credit call trans link Completed
              IF r1.part_number like '%FREE%' THEN
                l_action := 'Checking FREE card relation to call trans';
                v_has_ct     := 0;
                select count(*) into v_has_ct
                from table_x_call_trans ct
                where x_Service_id = (select part_serial_no from table_part_inst
                                      where objid = r1.part_to_esn2part_inst)
                 and x_transact_date >= trunc(r1.last_trans_time,'MI')-1
                 and x_transact_date < trunc(r1.last_trans_time,'MI')+1
                 and x_action_type in ('1','111','3','6')
                 and x_result = 'Completed';
                IF v_has_ct = 0 THEN
                  l_flag_broken := 'false';
                END IF;
              END IF;
              IF l_flag_broken = 'true' THEN
                --  CR7777 moved this delete Exception errors on above tables were interferring
                l_action := 'Delete from part inst';
                DELETE FROM sa.table_part_inst WHERE part_serial_no = r1.part_serial_no  and x_domain='REDEMPTION CARDS';
                --CR20137 Start kacosta 03/20/2012
                --COMMIT;
                --CR20137 End kacosta 03/20/2012
                l_action := 'Insert into call trans';
                --call_trans
                v_call_trans2site_part    :=r5.sp_objid; ----CR43600 START
                IF v_call_trans2site_part IS NULL THEN
                  SELECT MAX(objid) sp_objid
                  INTO v_call_trans2site_part
                  FROM sa.table_site_part
                  WHERE x_service_id = r4.esn;
                END IF; ----CR43600 END
                v_call_trans_objid        := sa.seq('x_call_trans');
                INSERT
                INTO sa.table_x_call_trans
                  (
                    objid ,
                    call_trans2site_part ,
                    x_action_type , --'6'
                    x_call_trans2carrier ,
                    x_call_trans2dealer ,
                    x_call_trans2user ,
                    x_line_status ,
                    x_min ,
                    x_service_id ,
                    x_sourcesystem , --WEB
                    x_transact_date ,
                    --LAST_TRANS_TIME
                    x_total_units , --X_REDEEM_UNITS
                    x_action_text , --'REDEMPTION'
                    x_reason ,
                    x_result ,
                    --Completed
                    x_sub_sourcesystem ,
                    x_iccid ,
                    x_ota_req_type ,
                    x_ota_type ,
                    x_call_trans2x_ota_code_hist
                  )
                  VALUES
                  (
                    v_call_trans_objid ,
                    v_call_trans2site_part --r5.sp_objid   ----CR43600
                    ,
                    '6' ,
                    l_carr_objid ,
                    r4.dlr_objid ,
                    268435556 ,
                    NULL ,
                    r4.line ,
                    r4.esn ,
                    'WEB' ,
                    v_trans_time ,
                    r2.x_redeem_units ,
                    'REDEMPTION' ,
                    NULL ,
                    'Failed' ,
                    200 ,
                    r4.x_iccid ,
                    NULL ,
                    NULL ,
                    NULL
                  );
                l_action := 'Insert into red card';
                --red card
                INSERT
                INTO sa.table_x_red_card
                  (
                    objid ,
                    red_card2call_trans ,
                    red_smp2inv_smp ,
                    red_smp2x_pi_hist ,
                    x_access_days ,
                    x_red_code ,
                    x_red_date ,
                    x_red_units ,
                    x_smp ,
                    x_status ,
                    x_result ,
                    x_created_by2user ,
                    x_inv_insert_date ,
                    x_last_ship_date ,
                    x_order_number ,
                    x_po_num ,
                    x_red_card2inv_bin ,
                    x_red_card2part_mod
                  )
                  VALUES
                  (
                    sa.seq('x_red_card') ,
                    v_call_trans_objid ,
                    --objid of call trans,
                    NULL ,
                    NULL ,
                    r2.x_redeem_days ,
                    r3.x_red_code ,
                    v_trans_time ,
                    r2.x_redeem_units ,
                    r1.part_serial_no ,
                    'NOT PROCESSED' ,
                    'Broken Card' ,
                    268435556 , --sa user objid
                    r3.x_insert_date ,
                    r3.x_creation_date ,
                    r3.x_order_number ,
                    r3.x_po_num ,
                    r1.part_inst2inv_bin ,
                    r1.n_part_inst2part_mod
                  );
                --CR20137 Start kacosta 03/20/2012
              ELSE
                INSERT
                INTO sa.x_daily_card_status_log VALUES
                (
                  l_smp ,
                  SYSDATE ,
                  l_action|| ' NOT VALID TO BREAK'
                );
              END IF;
            ELSE
              -- C83328 if not attached to an esn, invalidate card
              UPDATE table_part_inst pi
              SET x_part_inst_status  = '44' ,
                  STATUS2X_CODE_TABLE   = (SELECT OBJID
                                            FROM sa.table_x_code_table
                                            WHERE X_CODE_TYPE = 'CS'
                                            AND X_CODE_NUMBER = '44')
              WHERE pi.part_serial_no   = r1.part_serial_no
              AND pi.x_domain           = 'REDEMPTION CARDS';
              INSERT
              INTO sa.x_daily_card_status_log VALUES
              (
                l_smp ,
                SYSDATE ,
                'NO ESN RELATION, INVALIDATED CARD. PREVIOUS STATUS '||r1.x_part_inst_status
              );
            END IF;
          ELSE
            --               DBMS_OUTPUT.put_line('NO PART INST:'|| l_smp);
            INSERT
            INTO sa.x_daily_card_status_log VALUES
              (
                l_smp ,
                SYSDATE ,
                'NO PART INST OR ESN RELATION'
              );
          END IF;
          CLOSE c3;
        ELSE
          -- C83328 delete from part inst if exists
          DELETE FROM table_part_inst WHERE part_serial_no = l_smp AND x_domain = 'REDEMPTION CARDS';
          INSERT
          INTO sa.x_daily_card_status_log VALUES
            (
              l_smp ,
              SYSDATE ,
              l_action
              || ' IN RED CARD'
            );
        END IF;
        CLOSE c0;
        COMMIT;
      EXCEPTION
      WHEN dup_val_on_index THEN
        --CR20137 Start kacosta 03/20/2012
        ROLLBACK;
        --CR20137 End kacosta 03/20/2012
        INSERT
        INTO sa.x_daily_card_status_log VALUES
          (
            l_smp ,
            SYSDATE ,
            l_action
            || ' DUPLICATE INDEX'
          );
        COMMIT;
      WHEN OTHERS THEN
        --CR20137 Start kacosta 03/20/2012
        ROLLBACK;
        --CR20137 End kacosta 03/20/2012
        v_errm := substr(SQLERRM,1,1000);
        INSERT
        INTO sa.x_daily_card_status_log VALUES
          (
            l_smp ,
            SYSDATE ,
            l_action
            || ' Inside Loop :'
            || v_errm
          );
        COMMIT;
      END;
      IF c0%ISOPEN THEN
        CLOSE c0;
      END IF;
      IF c2%ISOPEN THEN
        CLOSE c2;
      END IF;
      IF c3%ISOPEN THEN
        CLOSE c3;
      END IF;
      IF c4%ISOPEN THEN
        CLOSE c4;
      END IF;
      IF c5%ISOPEN THEN
        CLOSE c5;
      END IF;
      IF c6%ISOPEN THEN
        CLOSE c6;
      END IF;
      IF c7%ISOPEN THEN
        CLOSE c7;
      END IF;
    END LOOP;
    COMMIT;
  EXCEPTION
  WHEN OTHERS THEN
    --CR20137 Start kacosta 03/20/2012
    ROLLBACK;
    --CR20137 End kacosta 03/20/2012
    --      DBMS_OUTPUT.put_line(l_smp ||' '||SQLERRM);
    v_errm := substr(SQLERRM,1,1000);
    INSERT
    INTO sa.x_daily_card_status_log VALUES
      (
        l_smp ,
        SYSDATE ,
        l_action
        || v_errm
      );
    COMMIT;
  END break_unused_reserv_prc;
/