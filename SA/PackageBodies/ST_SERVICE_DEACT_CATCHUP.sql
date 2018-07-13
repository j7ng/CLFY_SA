CREATE OR REPLACE PACKAGE BODY sa."ST_SERVICE_DEACT_CATCHUP"
AS
/********************************************************************************/
   /*    Copyright ) 2010 Tracfone  Wireless Inc. All rights reserved
   /*
   /********************************************************************************/
   v_package_name VARCHAR2 (80) := '.ST_SERVICE_DEACT_CATCHUP()';
   /********************************************************************************/
   /*
   /* NAME:         ST_SERVICE_DEACT_CATCHUP (BODY)
   /* PURPOSE:      This package deactivate services attached to tracfone product
   /* FREQUENCY:
   /* PLATFORMS:    Oracle 8.0.6 AND newer versions.
   /*
   /* REVISIONS:
   /* VERSION  DATE        WHO     PURPOSE
   /* -------  ---------- ----- ---------------------------------------------
   /*  1.5                      Initial  Revision
   /*                             (clone of service_deactivation_code with a modified pastdue procedure logic)
   *****************************************************************************/

   /*****************************************************************************/
   /*                                                                           */
   /* Name:     deactivate_past_due                                             */
   /* Description : Available in the specification part of package              */
   /*****************************************************************************/
cursor check_esn_curs (c_esn in varchar2) is
       select 1
         from table_site_part sp2
        where 1=1
          AND NVL(sp2.PART_STATUS, 'Obsolete') in ('CarrierPending', 'Active')
          and sp2.x_service_id = c_esn
          and NVL(sp2.X_EXPIRE_DT, TO_DATE('1753-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss'))>trunc(sysdate);
      check_esn_rec check_esn_curs%rowtype;
      -------------------------------------------------------

PROCEDURE DEACTIVATE_PAST_DUE IS
--------------------------------------------------------------------
  v_user TABLE_USER.objid%TYPE;
  v_returnflag VARCHAR2 (20);
  v_returnmsg VARCHAR2 (200);
  dpp_regflag PLS_INTEGER;
  v_action VARCHAR2 (50) := 'x_service_id is null in Table_site_part';
  v_procedure_name VARCHAR2 (50) := '.ST_SERVICE_DEACT_CATCHUP.DEACTIVATE_PAST_DUE';
  intcalltranobj NUMBER := 0;
  blnotapending BOOLEAN := FALSE;
--------------------------------------------------------------------
  v_start        DATE              ;
  v_end          DATE;
  v_time_used    NUMBER (10, 2);
  v_start_1        DATE              ;
  v_end_1          DATE;
  v_time_used_1    NUMBER (10, 2);
  ctr number := 0;
--------------------------------------------------------------------
  CURSOR c1 IS
 SELECT /*+ ORDERED use_nl(pi2) use_nl(ca) use_nl(pi) use_nl(ib) use_nl(ir) use_nl(ml) use_nl(pn) */
           sp.objid site_part_objid,
           sp.x_expire_dt,
           sp.x_service_id x_service_id,
           sp.x_min x_min,
           sp.serial_no x_esn,
           sp.x_msid,
           ca.objid carrier_objid,
           ir.inv_role2site site_objid,
           ca.x_carrier_id x_carrier_id,
           sp.site_objid cust_site_objid,
           pi.objid esnobjid,
           pi.part_serial_no part_serial_no,
           pi.x_iccid,
           pn.x_ota_allowed,
           bo.org_id
      FROM (SELECT /*+ ORDERED INDEX(sp SP_STATUS_EXP_DT_IDX)*/
                   sp.objid,
                   sp.x_service_id,
                   sp.x_min,
                   sp.x_msid,
                   sp.site_objid,
                   sp.serial_no,
                   sp.x_expire_dt
              FROM TABLE_SITE_PART sp,
                   table_mod_level ml,
                   table_part_num pn,
                   table_bus_org bo
             WHERE 1 = 1
               AND NVL(sp.PART_STATUS, 'Obsolete') = 'Active'
              AND NVL(sp.X_EXPIRE_DT, TO_DATE('1753-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss'))  > TO_DATE('1753-02-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss')
              AND NVL(sp.X_EXPIRE_DT, TO_DATE('1753-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss')) < TRUNC(SYSDATE)
               AND ml.objid = sp.SITE_PART2PART_INFO
               AND pn.objid = ml.part_info2part_num
               AND bo.objid = pn.PART_NUM2BUS_ORG
               AND bo.org_id||'' = 'STRAIGHT_TALK') sp,
           TABLE_PART_INST pi2,
           TABLE_X_CARRIER ca,
           TABLE_PART_INST pi,
           TABLE_INV_BIN ib,
           TABLE_INV_ROLE ir,
           TABLE_MOD_LEVEL ml,
           TABLE_PART_NUM pn,
           TABLE_BUS_ORG bo
     WHERE 1 = 1
       AND pi2.x_domain||'' = 'LINES'
       AND pi2.part_serial_no = NVL(sp.x_min, 'NONE')
       AND ca.objid = pi2.part_inst2carrier_mkt
       AND not exists( SELECT e.x_carrier_id
                         FROM X_EXCLUDED_PASTDUEDEACT e
                         where ca.x_carrier_id = e.x_carrier_id )
       AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
       AND ib.objid = pi.part_inst2inv_bin
       AND ml.part_info2part_num = pn.objid
       AND pn.part_num2bus_org = bo.objid
       AND pi.n_part_inst2part_mod = ml.objid
       AND pi.x_domain = 'PHONES'
       AND PI.PART_SERIAL_NO = NVL(SP.X_SERVICE_ID, 'NONE')
       AND NOT EXISTS ( SELECT '1'
                          FROM TABLE_PART_INST PI3
                         WHERE PI3.PART_TO_ESN2PART_INST = PI.OBJID
                           AND PI3.X_DOMAIN = 'REDEMPTION CARDS'
                           AND PI3.X_PART_INST_STATUS = '400');
      -- AND ROWNUM <10001;

  CURSOR c_chkotapend( c_esn IN VARCHAR2) IS
    SELECT 'X'
      FROM TABLE_X_CALL_TRANS
     WHERE objid = ( SELECT MAX (objid)
                       FROM TABLE_X_CALL_TRANS
                      WHERE x_service_id = c_esn)
       AND x_result = 'OTA PENDING'
       AND x_action_type = '6';
    r_chkotapend c_chkotapend%ROWTYPE;

  cursor check_active_min_curs(c_min in varchar2) is
    select 1
      from table_site_part sp2
     where 1=1
       AND NVL(sp2.PART_STATUS, 'Obsolete') in('CarrierPending', 'Active')
       and sp2.x_min = c_min
       and NVL(sp2.X_EXPIRE_DT, TO_DATE('1753-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss'))>trunc(sysdate);
  check_active_min_rec check_active_min_curs%rowtype;

  cursor past_due_batch_check_curs(c_sp_objid in number) is
    select sp.objid
      FROM TABLE_SITE_PART sp
     WHERE 1 = 1
       AND sp.PART_STATUS = 'Active'
       AND NVL(sp.X_EXPIRE_DT, TO_DATE('1753-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss')) >
                               TO_DATE('1753-02-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss')
       AND NVL(sp.X_EXPIRE_DT, TO_DATE('1753-01-01 00:00:00', 'yyyy-mm-dd hh24:mi:ss')) < trunc(SYSDATE)
       and sp.objid = c_sp_objid;
  past_due_batch_check_rec past_due_batch_check_curs%rowtype;
------------------------------------------------------------------------------------------------
BEGIN
  v_start_1 := sysdate;

  SELECT objid INTO v_user
    FROM TABLE_USER
   WHERE s_login_name = 'SA';

  FOR c1_rec IN c1 LOOP
    dbms_output.put_line('c1_rec.x_service_id:'||c1_rec.x_service_id);
    open past_due_batch_check_curs(c1_rec.site_part_objid);
      fetch past_due_batch_check_curs into past_due_batch_check_rec;
      if past_due_batch_check_curs%notfound then
        dbms_output.put_line('past_due_batch_check_curs%notfound');
        close past_due_batch_check_curs;
        commit;
        goto skip_this_deactivation;
      end if;
    close past_due_batch_check_curs;

    open check_active_min_curs(c1_rec.x_min);
      fetch check_active_min_curs into check_active_min_rec;
      if check_active_min_curs%found then
        update table_site_part
           set part_status = 'Inactive'
         where objid = c1_rec.site_part_objid;
        dbms_output.put_line('check_active_min_curs%found');
        open check_esn_curs(c1_rec.x_service_id);
          fetch check_esn_curs into check_esn_rec;
          if check_esn_curs%notfound then
            dbms_output.put_line('check_esn_curs%found');
            update table_part_inst
           set x_part_inst_status = '54',
               status2x_code_table = 990
             where part_serial_no = c1_rec.x_service_id;
          end if;
        close check_esn_curs;
        close check_active_min_curs;
        commit;
        goto skip_this_deactivation;
      end if;
    close check_active_min_curs;

    IF (c1_rec.x_service_id IS NULL) THEN
      UPDATE TABLE_SITE_PART SET x_service_id = NVL (c1_rec.x_esn, c1_rec.part_serial_no)
       WHERE objid = c1_rec.site_part_objid;
      COMMIT;
    END IF;

    service_deactivation_code.check_dpp_registered_prc (c1_rec.x_service_id, dpp_regflag);
    IF dpp_regflag = 1 THEN
      service_deactivation_code.create_call_trans (c1_rec.site_part_objid, 84, c1_rec.carrier_objid
           , c1_rec.site_objid, v_user, c1_rec.x_min, c1_rec.x_service_id,
           'PROTECTION PLAN BATCH', SYSDATE, NULL, 'Monthly Payments',
          'PASTDUE', 'Pending', c1_rec.x_iccid, c1_rec.org_id, intcalltranobj );
    ELSE
      IF ( Billing_Deactprotect (c1_rec.x_service_id) = 1 ) THEN
        NULL;
      ELSE
        deactservice ('PAST_DUE_BATCH', v_user, c1_rec.x_service_id,
                      c1_rec.x_min, 'PASTDUE', 0, NULL, 'true', v_returnflag, v_returnmsg );
      END IF;
    END IF;

    FOR c2_rec IN ( SELECT ROWID
                      FROM TABLE_X_GROUP2ESN
                     WHERE groupesn2part_inst = c1_rec.esnobjid
                       AND groupesn2x_promo_group IN ( SELECT objid
                                                         FROM TABLE_X_PROMOTION_GROUP
                                                        WHERE group_name IN ('90_DAY_SERVICE', '52020_GRP'))) LOOP
      UPDATE TABLE_X_GROUP2ESN u SET x_end_date = SYSDATE
       WHERE u.ROWID = c2_rec.ROWID;
      COMMIT;
    END LOOP;
    <<skip_this_deactivation>>
    COMMIT;
  END LOOP;

  v_end_1 := sysdate;
  v_time_used_1 := (v_end_1 - v_start_1) * 24 * 60;
  DBMS_OUTPUT.put_line ('END_PROCEDURE  call Total time used for esn: ' || v_time_used_1);
END deactivate_past_due;

   /***********************************************************************************/
   /*
   /* Name: deactService
   /* Description: Ends carrier service for an ESN/MIN combination. Translated
   /*              from TFLinePart.java in the DeactivateService and
   /*              DeactivateGSMService method.
   /***********************************************************************************/
   PROCEDURE deactservice(
      ip_sourcesystem IN VARCHAR2,
      ip_userobjid IN VARCHAR2,
      ip_esn IN VARCHAR2,
      ip_min IN VARCHAR2,
      ip_deactreason IN VARCHAR2,
      intbypassordertype IN NUMBER,
      ip_newesn IN VARCHAR2,
      ip_samemin IN VARCHAR2,
      op_return OUT VARCHAR2,
      op_returnmsg OUT VARCHAR2
   )
   IS
      CURSOR cur_ph IS
      SELECT A.* ,a.rowid esn_rowid,
             c.x_technology,
             NVL (c.x_restricted_use, 0) x_restricted_use,
             e.objid siteobjid,
             f.service_end_dt,
         f.x_expire_dt,
             f.x_deact_reason,
             f.part_status f_part_status,
             f.x_notify_carrier,
             f.objid sitepartobjid,
             f.x_service_id,
             f.x_min,
             f.install_date,
             f.site_part2x_new_plan,
             f.site_part2x_plan,
         f.rowid site_part_rowid,bo.org_id,
             (select count(*)
                from x_program_enrolled c
               where 1=1
                 and c.x_esn = ip_esn
                 and c.x_enrollment_status in ('ENROLLED', 'SUSPENDED', 'ENROLLMENTPENDING', 'ENROLLMENTSCHEDULED')
                 and rownum <2) billing_rule_status
        FROM TABLE_PART_INST A,
             TABLE_MOD_LEVEL b,
             TABLE_PART_NUM c,
             TABLE_BUS_ORG bo,
             TABLE_INV_BIN d,
             TABLE_SITE e,
             TABLE_SITE_PART f
       WHERE 1=1
         and f.objid = (select max(sp.objid)
                          from table_site_part sp
                         where sp.part_status != 'Obsolete'
                           and sp.x_service_id = a.part_serial_no
                           and sp.x_min = ip_min)
         AND d.bin_name = e.site_id
         AND A.part_inst2inv_bin = d.objid
         AND c.PART_NUM2BUS_ORG = bo.objid
         AND b.part_info2part_num = c.objid
         AND A.n_part_inst2part_mod = b.objid
         AND A.part_serial_no = ip_esn
         AND A.x_domain = 'PHONES';
      rec_ph cur_ph%ROWTYPE;
      -------------------------------------------------------
      CURSOR cur_newesn IS
      SELECT objid
      FROM TABLE_PART_INST
      WHERE part_serial_no = LTRIM (RTRIM (ip_newesn));
      rec_newesn cur_newesn%ROWTYPE;
      -------------------------------------------------------
      CURSOR cur_min (ip_min in varchar2, c_tech in varchar2) IS
      SELECT pi.objid,
             pi.part_serial_no,
             pi.part_inst2carrier_mkt,
             nvl(pi.x_port_in,0) x_port_in,
             pi.x_part_inst_status,
             pi.x_npa,
             pi.x_nxx,
             pi.x_ext,
         pi.rowid min_rowid,
             pi.status2x_code_table ,
         pi.x_cool_end_date,
             pi.warr_end_date ,
         pi.last_trans_time,
         pi.repair_date,
             pi.part_inst2x_pers,
         pi.part_inst2x_new_pers,
             pi.part_to_esn2part_inst,
         pi.last_cycle_ct ,
         p.x_parent_id,
             cr.x_line_return_days,
             cr.x_cooling_period,
             cr.x_used_line_expire_days,
             cr.x_gsm_grace_period,
             cr.x_reserve_on_suspend,
             cr.x_reserve_period,
             cr.x_deac_after_grace,
             (SELECT COUNT(*)
                FROM TABLE_X_BLOCK_DEACT
               WHERE x_block_active = 1
                 AND x_parent_id = p.x_parent_id
                 AND x_code_name = ip_deactreason
                 and rownum<2) block_deact_exists
      FROM  TABLE_X_PARENT p,
            TABLE_X_CARRIER_GROUP cg,
            TABLE_X_CARRIER_RULES cr,
            TABLE_X_CARRIER c,
            TABLE_PART_INST pi
      WHERE 1=1
        AND p.objid = cg.x_carrier_group2x_parent
        and cg.objid = c.carrier2carrier_group
        and cr.objid =  DECODE (c_tech, 'GSM',  c.carrier2rules_gsm,
                            'CDMA', c.carrier2rules_cdma, c.carrier2rules)
        AND c.objid = pi.part_inst2carrier_mkt
        and pi.part_serial_no = ip_min
        AND pi.x_domain = 'LINES';
      rec_min cur_min%ROWTYPE;
      -------------------------------------------------------
      CURSOR curremovepromo(
         c_esnobjid IN NUMBER
      )
      IS
      SELECT /*+ INDEX(pg X_PROMOTION_GROUP_OBJINDEX) */
       g2e.*
        FROM TABLE_X_PROMOTION_GROUP pg,
             TABLE_X_GROUP2ESN g2e
       WHERE 1=1
         and pg.OBJID = g2e.GROUPESN2X_PROMO_GROUP +0
         and pg.GROUP_NAME IN ('TFU', 'ANNUALPLAN')
         AND g2e.GROUPESN2PART_INST =c_esnobjid;
      -------------------------------------------------------
      CURSOR currdeactcode( c_deactreason IN VARCHAR2,
                            c_deacttype IN VARCHAR2)
      IS
      SELECT *
      FROM TABLE_X_CODE_TABLE
      WHERE x_code_name = c_deactreason
      AND x_code_type = c_deacttype;
      recdeactcode currdeactcode%ROWTYPE;
      recdeactsim currdeactcode%ROWTYPE;
      -------------------------------------------------------
      CURSOR currstatcode(
         c_statcode IN VARCHAR2,
         c_codetype IN VARCHAR2
      )
      IS
      SELECT *
      FROM TABLE_X_CODE_TABLE
      WHERE x_code_number = c_statcode
      AND x_code_type = c_codetype;
      recphstatcode currstatcode%ROWTYPE;
      reclinestatcode currstatcode%ROWTYPE;
      -------------------------------------------------------

      CURSOR c_ota_features( c_ip_esn_objid IN number) IS
      SELECT 'X'
      FROM TABLE_X_OTA_FEATURES
      WHERE x_ota_features2part_inst = c_ip_esn_objid
      AND x_ild_carr_status = 'Active'
      and rownum <2;
      -------------------------------------------------------

      intcalltranobj NUMBER := 0;
      intstatcode NUMBER := 0;
      intactitemobj NUMBER := 0;
      intordtypeobj NUMBER := 0;
      intblackoutcode NUMBER := 0;
      intdummy NUMBER := 0;
      inttransmethod NUMBER := 0;
      intgrphistseq NUMBER := 0;
      strdeacttype VARCHAR2 (30) := '';
      strrettemp VARCHAR2 (200) := '';
      strsqlerrm VARCHAR2 (200);
      v_action VARCHAR2 (4000);
      e_deact_exception EXCEPTION;
      v_procedure_name VARCHAR2 (80) := v_package_name || '.DEACTSERVICE()';

      TYPE ac_change IS TABLE OF TABLE_part_inst.objid%TYPE;
      TYPE ac_change_rowid IS TABLE OF varchar2(200);
      v_ac_change ac_change;
      v_ac_change_rowid ac_change_rowid;
      TYPE call_trans IS TABLE OF TABLE_X_OTA_TRANSACTION.x_ota_trans2x_call_trans%TYPE;
      v_call_trans call_trans;

      strilderrnum VARCHAR2 (20);
      strilderrstr VARCHAR2 (200);

      op_result NUMBER;
      op_msg VARCHAR2(200);

   l_step number :=0;
   BEGIN
      if ltrim(ip_esn) is null then
         op_return := 'true';
         op_returnmsg := 'ESN is null';
         update table_part_inst
            set x_part_inst_status = '17',
                STATUS2X_CODE_TABLE = (select objid from table_x_code_table where x_code_number = '17')
          where part_serial_no = ip_min;
         COMMIT;
         return;
      else
        OPEN cur_ph;
          FETCH cur_ph INTO rec_ph;
          IF cur_ph%NOTFOUND THEN
            CLOSE cur_ph;
            op_returnmsg := 'ESN/IMEI is not Valid';
            RAISE e_deact_exception;
          end if;
        close cur_ph;
      end if;

      OPEN cur_min (ip_min,rec_ph.x_technology);
        FETCH cur_min INTO rec_min;
        IF cur_min%NOTFOUND THEN
          CLOSE cur_min;
          op_returnmsg := 'MIN is not Valid';
          RAISE e_deact_exception;
        END IF;
      CLOSE cur_min;

      IF (SUBSTR (rec_min.part_serial_no, 1, 1) = 'T') THEN
         OPEN currdeactcode ('DELETED', 'LS');
      ELSIF  (rec_min.x_part_inst_status = '34') THEN

        v_action := 'Updating account_hist of current line';
        UPDATE TABLE_X_ACCOUNT_HIST
           SET x_end_date = SYSDATE
         WHERE account_hist2part_inst = rec_min.objid
           AND (   x_end_date IS NULL OR x_end_date = TRUNC (TO_DATE ('01/01/1753', 'MM/DD/YYYY')) );
        OPEN currdeactcode ('AC VOIDED', 'LS');
      else
         OPEN currdeactcode (( case when ip_deactreason in ('STOLEN', 'PASTDUE', 'SELL PHONE', 'NO NEED OF PHONE',
                                                            'DEFECTIVE', 'WAREHOUSE PHONE', 'CLONED',
                                                            'SEQUENCE MISMATCH', 'RISK ASSESSMENT',
                                                            'SALE OF CELL PHONE', 'STOLEN CREDIT CARD', 'UPGRADE',
                                                            'OVERDUE EXCHANGE', 'WN-SYSTEM ISSUED', 'SIM DAMAGED',
                                                            'SIM EXCHANGE', 'CUSTOMER REQD', 'UNITS TRANSFER',
                                                            'CANCELFROMSUSPEND', 'ONE TIME DEACT',
                                                            'CUSTOMER REQUESTED', 'SIM CHANGE', 'SIM DAMAGE',
                                                            'UPGRADE', 'ACTIVE UPGRADE', 'NONUSAGE',
                                                            'PORT IN TO TRACFONE', 'PORT IN TO NET10') then
                                      'RESERVED USED'
                                    when ip_deactreason in ( 'NTN','REFURBISHED', 'PORT OUT', 'MINCHANGE',
                                                             'CHANGE OF ADDRESS', 'PORTED NO A/I', 'SENDCARRDEACT',
                                                             'SL PHONE NEVER RCVD', 'PORT CANCEL') then
                                         case when rec_min.x_line_return_days=0 then
                                                'USED'
                                              else
                               'RETURNED'
                                         end
                               end), 'LS');
      END IF;
        FETCH currdeactcode INTO recdeactcode;
      CLOSE currdeactcode;

      dbms_output.put_line('recdeactcode.x_code_number:'||recdeactcode.x_code_number);

      if ltrim(ip_newesn) is not null then
        OPEN cur_newesn;
          FETCH cur_newesn INTO rec_newesn;
          if cur_newesn%found then
            v_action := 'Clearing all the reserved lines except the one that is being deactivated' ;
            dbms_output.put_line('Clearing all the reserved lines except the one that is being deactivated');
            UPDATE TABLE_PART_INST
               SET part_to_esn2part_inst = NULL
             WHERE part_to_esn2part_inst = rec_newesn.objid
               AND objid != rec_min.objid
               AND (x_port_in IS NULL OR x_port_in = 0);
          end if;
        close cur_newesn;
      end if;


      v_action := 'Updating part_inst of current line';
      dbms_output.put_line('Updating part_inst of current line');

      UPDATE TABLE_PART_INST SET x_part_inst_status = recdeactcode.x_code_number
      , status2x_code_table = recdeactcode.objid, x_cool_end_date = DECODE (
      rec_min.x_cooling_period, 0, x_cool_end_date, SYSDATE + rec_min.x_cooling_period ),
      warr_end_date = DECODE (rec_min.x_used_line_expire_days, 0, TO_DATE ('01/01/1753',
      'mm/dd/yyyy'), SYSDATE + rec_min.x_used_line_expire_days ), last_trans_time = SYSDATE,
      repair_date = DECODE ((ltrim(ip_newesn)), null, repair_date, SYSDATE),
      part_inst2x_pers = DECODE (part_inst2x_new_pers, NULL, part_inst2x_pers,
      part_inst2x_new_pers ), part_inst2x_new_pers = NULL,
      part_to_esn2part_inst = DECODE ((ltrim(ip_newesn)), null,part_to_esn2part_inst,  rec_newesn.objid),
      last_cycle_ct = SYSDATE + rec_min.x_gsm_grace_period,
      x_port_in = DECODE (ip_samemin, 'true', rec_min.x_port_in, (DECODE (rec_min.x_port_in, 2,
      0, rec_min.x_port_in) ) )
      where rowid = rec_min.min_rowid;

      IF service_deactivation_code.writepihistory (ip_userobjid, rec_min.min_rowid , NULL, NULL, NULL ,
                         'DEACTIVATE', rec_ph.x_iccid ) = 1 THEN
        null;
      END IF;

      v_action := 'Updating active min site_part to inactive';
      dbms_output.put_line('Updating active min site_part to inactive');
      UPDATE TABLE_SITE_PART
         SET service_end_dt = SYSDATE,
         x_expire_dt = CASE WHEN ip_deactreason IN ('UPGRADE', 'ACTIVE UPGRADE', 'WAREHOUSE PHONE') THEN
                                  SYSDATE
                                ELSE
                                  x_expire_dt
                                END,
             x_deact_reason = ip_deactreason,
             x_notify_carrier = case when (rec_min.x_port_in in (1,2) or rec_min.x_line_return_days=1 ) THEN
                                       1
                                     else
                                       0
                                     end,
             part_status = 'Inactive' ,
         site_part2x_new_plan = NULL
       where x_min = rec_min.part_serial_no
       and part_status||'' in ('CarrierPending','Active');
      commit;

      v_action := 'Creating a call trans record';
      dbms_output.put_line('Creating a call trans record');
      service_deactivation_code.create_call_trans (rec_ph.sitepartobjid, 2, rec_min.part_inst2carrier_mkt ,
      rec_ph.siteobjid, ip_userobjid,rec_ph.x_min, ip_esn, ip_sourcesystem,
      SYSDATE, NULL, 'DEACTIVATION',ip_deactreason, 'Completed', rec_ph.x_iccid,
      rec_ph.org_id,intcalltranobj );

      if recdeactcode.x_code_name in ('RESERVED USED','USED') then
        strdeacttype := 'Suspend';
      elsif recdeactcode.x_code_name in ('RETURNED') then
        strdeacttype := 'Deactivation';
      else
        strdeacttype := '';
      end if;

      dbms_output.put_line('strdeacttype:'||strdeacttype);
      dbms_output.put_line('rec_min.block_deact_exists:'||rec_min.block_deact_exists);
      dbms_output.put_line('recdeactcode.x_code_name:'|| recdeactcode.x_code_name );
      dbms_output.put_line('rec_min.LAST_CYCLE_CT:'||rec_min.LAST_CYCLE_CT);
      IF (    rec_min.block_deact_exists = 0
          and recdeactcode.x_code_name is not null
          --and rec_min.LAST_CYCLE_CT > trunc(sysdate) -30
         ) THEN
         v_action := 'Creating action_item';
         dbms_output.put_line('Creating action_item');
--
         IF (rec_ph.x_part_inst2contact IS NULL) THEN
          op_returnmsg := 'Contact Information Can Not be Found';
          RAISE e_deact_exception;
         END IF;
--
         Igate.sp_create_action_item (rec_ph.x_part_inst2contact, intcalltranobj, strdeacttype,
                              intbypassordertype, 0, intstatcode, intactitemobj );

         IF (intstatcode = 2) THEN
            op_returnmsg := op_returnmsg ||
            ' The Action Item Has Not Been Created.  Please Contact The Line Management Data Adminstrator.' ;
         ELSIF (intstatcode = 4) THEN
            op_returnmsg := op_returnmsg ||
            ' There is no transmission method set for this carrier.';
         END IF;

         IF (intactitemobj = 0) THEN
            op_returnmsg := 'No Lines Were Deactivated';
            RAISE e_deact_exception;
         END IF;

         Igate.sp_get_ordertype (rec_min.part_serial_no, strdeacttype, rec_min.part_inst2carrier_mkt ,
                         rec_ph.x_technology, intordtypeobj );
         Igate.sp_check_blackout (intactitemobj, intordtypeobj, intblackoutcode);

         IF (intblackoutcode = 0) THEN

           Igate.sp_determine_trans_method (intactitemobj, strdeacttype, NULL, inttransmethod );
           IF (inttransmethod = 2) THEN
               op_returnmsg := op_returnmsg ||
                 ' The Action Item Has Not Been Created.  Please Contact The Line Management Data Adminstrator. ' ;
           ELSIF (inttransmethod = 4) THEN
               op_returnmsg := op_returnmsg ||
               ' There is no transmission method set for this carrier.';
           END IF;
         ELSIF (intblackoutcode = 1) THEN
            op_returnmsg := op_returnmsg || ' Currently in blackout.';
            Igate.sp_dispatch_task (intactitemobj, 'BlackOut', intdummy);
         ELSIF (intblackoutcode = 2) THEN
            op_returnmsg := op_returnmsg || ' No task record found.';
         ELSIF (intblackoutcode = 3) THEN
            op_returnmsg := op_returnmsg || ' No x_call_trans record found.';
         ELSIF (intblackoutcode = 4) THEN
            op_returnmsg := op_returnmsg || ' No x_carrier record found.';
         ELSIF (intblackoutcode IN (5, 6)) THEN
            Igate.sp_dispatch_task (intactitemobj, 'BlackOut', intdummy);
         ELSIF (intblackoutcode = 7) THEN
            op_returnmsg := op_returnmsg || ' Unspecified error.';
         END IF;
      END IF;

      open check_esn_curs(ip_esn);
        fetch check_esn_curs into check_esn_rec;
        if check_esn_curs%found then
          close check_esn_curs;
          op_returnmsg := 'ESN active in site_part with exp date in future';
          RAISE e_deact_exception;
        end if;
      close check_esn_curs;

      FOR ota_features_rec IN c_ota_features (rec_ph.objid) LOOP
         sa.Sp_Ild_Transaction (rec_min.part_serial_no, 'ILD_DEACT', '', strilderrnum, strilderrstr );
      END LOOP;

      UPDATE sa.TABLE_X_PSMS_OUTBOX
         SET x_status = 'Cancelled',
             x_last_update = SYSDATE
       WHERE x_esn = rec_ph.part_serial_no
         AND x_status = 'Pending';

      UPDATE sa.TABLE_X_OTA_FEATURES
         SET x_ild_account = NULL,
             x_ild_carr_status = 'Inactive',
         x_ild_prog_status = 'Pending'
       WHERE x_ota_features2part_inst = rec_ph.objid
         AND x_ild_prog_status = 'InQueue';

      commit;


      if rec_ph.billing_rule_status =1 then
        Billing_Deact_Rule_Engine (ip_esn, ip_DeactReason, ip_userObjId, op_result, op_msg );
      end if;

      IF (rec_ph.x_technology = 'GSM') and (rec_ph.x_iccid IS NOT NULL) THEN
        OPEN currdeactcode (( case when ip_deactreason in ('UPGRADE','SIM DAMAGED','SIM DAMAGE','ACTIVE UPGRADE',
                                                           'REFURBISHED','SENDCARRDEACT','SL PHONE NEVER RCVD') then
                                     'SIM EXPIRED'
                                   when ip_deactreason in ('NON TOPP LINE') then
                                     'SIM NEW'
                                   when  ip_deactreason in ('SIM EXCHANGE','CHANGE OF ADDRESS','CUSTOMER REQUESTED',
                                                            'SIM CHANGE')    then
                                     'SIM VOID'
                                   else
                                     'SIM RESERVED'
                               end), 'SIM');
          FETCH currdeactcode INTO recdeactsim;
        CLOSE currdeactcode;
        v_action := 'Updating SIM information';
        UPDATE TABLE_X_SIM_INV
           SET x_sim_inv_status = recdeactsim.x_code_number,
               x_sim_status2x_code_table = recdeactsim.objid
         WHERE x_sim_serial_no = rec_ph.x_iccid;
        COMMIT;
      END IF;

      IF ip_deactreason = 'NONUSAGE' THEN
         UPDATE x_nonusage_esns
          set x_deact_flag=2,x_rundate = sysdate
         where X_esn=rec_ph.x_service_id;
     commit;
      end if;

      OPEN currstatcode ((case when ip_deactreason = 'STOLEN' then
                                 '53'
                               when ip_deactreason in('PASTDUE','UPGRADE','ACTIVE UPGRADE', 'PORT IN TO TRACFONE',
                                                      'PORT IN TO NET10', 'NONUSAGE') then
                 '54'
                               when ip_deactreason in('SEQUENCE MISMATCH') then
                         '55'
                               when ip_deactreason in('RISK ASSESSMENT','STOLEN CREDIT CARD') then
                         '56'
                               when ip_deactreason in('OVERDUE EXCHANGE') then
                         '58'
                               else
                                 '51'
                          end), 'PS');
        FETCH currstatcode INTO recphstatcode;
      CLOSE currstatcode;
 v_action := 'Updating part_inst of ESN';
      UPDATE TABLE_PART_INST
         SET x_part_inst_status = recphstatcode.x_code_number ,
               status2x_code_table = recphstatcode.objid,
               last_trans_time = SYSDATE,
               x_reactivation_flag = DECODE (recdeactcode.x_value, 2, 1, x_reactivation_flag ),
               x_part_inst2contact = DECODE (ip_deactreason, 'SL PHONE NEVER RCVD', NULL,  x_part_inst2contact ),
               part_inst2x_new_pers = NULL
       where rowid = rec_ph.esn_rowid;

      IF service_deactivation_code.writepihistory (ip_userobjid, rec_ph.esn_rowid , NULL, NULL, NULL,
                          'DEACTIVATE', rec_ph.x_iccid ) = 1 THEN
         null;
      END IF;

      if ip_deactreason = 'SL PHONE NEVER RCVD' then
        DELETE table_x_contact_part_inst
         where x_contact_part_inst2part_inst = rec_ph.objid;
      end if;
      commit;

      v_action := 'Updating click plan hist';
      UPDATE TABLE_X_CLICK_PLAN_HIST
         SET x_end_date = SYSDATE
       WHERE curr_hist2site_part = rec_ph.sitepartobjid
             AND ( x_end_date IS NULL OR x_end_date = TRUNC (TO_DATE ('01/01/1753', 'MM/DD/YYYY')) );

      v_action := 'Updating Free voice mail';
      UPDATE sa.X_FREE_VOICE_MAIL SET x_fvm_status = 1, x_fvm_number = NULL,
      x_fvm_time_stamp = SYSDATE
      WHERE x_fvm_status = 2
      AND free_vm2part_inst = rec_ph.objid;

      v_action := 'Removing Group promos';
      FOR reccurremovepromo IN curremovepromo (rec_ph.objid) LOOP

         SELECT SEQU_X_GROUP_HIST.nextval INTO intgrphistseq FROM DUAL;
         INSERT
         INTO TABLE_X_GROUP_HIST(
            objid,
            x_start_date,
            x_end_date,
            x_action_date,
            x_action_type,
            x_annual_plan,
            grouphist2part_inst,
            grouphist2x_promo_group)
         VALUES(
            intgrphistseq,
            reccurremovepromo.x_start_date,
            reccurremovepromo.x_end_date,
            SYSDATE,
            'REMOVE',
            reccurremovepromo.x_annual_plan,
            reccurremovepromo.groupesn2part_inst,
            reccurremovepromo.groupesn2x_promo_group);

         DELETE
         FROM TABLE_X_GROUP2ESN
         WHERE objid = reccurremovepromo.objid;
      END LOOP;
      v_action := 'Removing autopay_prc';
      service_deactivation_code.remove_autopay_prc (rec_ph.part_serial_no,rec_ph.org_id, strrettemp);

      UPDATE TABLE_X_OTA_TRANSACTION A
         SET x_status = 'COMPLETED',
             x_reason = 'DEACT'
       WHERE x_status = 'OTA PENDING'
         AND x_esn = ip_esn RETURNING x_ota_trans2x_call_trans BULK COLLECT INTO v_call_trans;
      FOR i IN 1 .. v_call_trans.COUNT LOOP
         UPDATE TABLE_X_CALL_TRANS SET x_result = 'Completed'
         WHERE objid = v_call_trans (i);
         UPDATE TABLE_X_CODE_HIST SET x_code_accepted = 'YES'
         WHERE code_hist2call_trans = v_call_trans (i);
      END LOOP;

      op_return := 'true';
      op_returnmsg := op_returnmsg || ' ' || strrettemp;
      COMMIT;
      EXCEPTION WHEN e_deact_exception THEN
        if cur_ph%isopen then
          close cur_ph;
        end if;
        if cur_min%isopen then
          close cur_min;
        end if;
        ROLLBACK;
        op_return := 'false';
        Toss_Util_Pkg.Insert_Error_Tab_Proc (v_action||op_returnmsg, ip_esn, v_procedure_name );
      WHEN OTHERS THEN
        if cur_ph%isopen then
          close cur_ph;
        end if;
        if cur_min%isopen then
          close cur_min;
        end if;
        strsqlerrm := SUBSTR (SQLERRM, 1, 200);
        op_return := 'false';
        op_returnmsg := strsqlerrm;
        Toss_Util_Pkg.Insert_Error_Tab_Proc (v_action, ip_esn, v_procedure_name );
   END deactservice;
END ST_SERVICE_DEACT_CATCHUP;
/