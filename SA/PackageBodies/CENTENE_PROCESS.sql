CREATE OR REPLACE PACKAGE BODY sa.CENTENE_PROCESS
AS
 --$RCSfile: CENTENE_PROCESS_PKB.sql,v $
 --$Revision: 1.7 $
 --$Author: sethiraj $
 --$Date: 2016/09/16 12:50:07 $
 --$ $Log: CENTENE_PROCESS_PKB.sql,v $
 --$ Revision 1.7  2016/09/16 12:50:07  sethiraj
 --$ CR41473-LRP2-Added Modification History Template
 --$
 --$ Revision 1.6  2016/09/02 11:53:21  pamistry
 --$ CR41473 - LRP2 modify the Table_Web_User insert to avoid compilation error for addition of new column (Insert_Timestamp)
 --$


/*
1.    PROCEDURE CNTN_INSERT_EXCEP_PRC(ip_esn varchar2,ip_exception varchar2);
2.    PROCEDURE CNTN_NET10_NEW_SUBS_PRC; -- step 1.1
3.    PROCEDURE CNTN_NET10_UPDATE_ACT_SUBS_PRC;--step 1.2
4.    PROCEDURE CNTN_UPDATE_UPGRADES_EXC_PRC;--step 1.3
5.    PROCEDURE CNTN_NET10_UPDATE_ACT_LOG_PRC; -- step 1.4
6.    PROCEDURE CNTN_NET10_SUBS_ESNS_NEW_PRC; -- calls steps 1.1 thru 1.4
7.    PROCEDURE CNTN_ENROLLMENT_PRC;
8.    PROCEDURE CNTN_DEENROLLMENT_PRC;
9.    PROCEDURE CNTN_PLAN_CHANGE_PRC;
10.   PROCEDURE CNTN_DAYS_EXTENSION_PRC;
11.   PROCEDURE CNTN_FLASH_PRC;
12.   PROCEDURE CNTN_MONTHLY_RECURRING_PROC;

*/

----------------------------------------------------*****************************************************************************************************-----------------------------------------------------------------------
PROCEDURE CNTN_INSERT_EXCEP_PRC(ip_esn varchar2,ip_exception varchar2)
IS
   pragma autonomous_transaction;
BEGIN
  insert into CNTN_EXCEP_TEMP_TABLE (esn,exception_text) values (ip_esn,ip_exception);
  commit;
END CNTN_INSERT_EXCEP_PRC;
----------------------------------------------------OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO-----------------------------------------------------------------------
PROCEDURE CNTN_NET10_NEW_SUBS_PRC -- step 1.1
AS
-- STEP 1. Get new active subs
BEGIN
     INSERT INTO sa.centene_net10_subs
     (X_ESN,
      X_MIN,
      PART_NUMBER,
      PHONE_DEALER,
      ACT_DATE,
      ESN_EXPIRY_DATE,
      PHONE_STATUS,
      CURRENT_PLAN,
      ENROLLMENT_STATUS,
      START_DATE,
      BILL,
      last_delivery_date,
      customer_commit_date
     )
    select  /*+ rule */
      pi.PART_SERIAL_NO X_ESN,
      sp.X_MIN,
      pn.PART_NUMBER,
      ts.s_name PHONE_DEALER,
      sp.INSTALL_DATE ACT_DATE,
      sp.X_EXPIRE_DT ESN_EXPIRY_DATE,
      code.x_code_name,
      pp.X_PROGRAM_NAME,
      'PENDING',
      trunc(sp.INSTALL_DATE) START_DATE,
      'Y' BILL,
      trunc(sp.INSTALL_DATE) last_delivery_date,
      (add_months(trunc(sp.INSTALL_DATE,'MM')
        ,1+floor(PR.X_ACCESS_DAYS/30))+13
      ) customer_commit_date
    from
      CENTENE_NET10_PHONE2PLAN CTP2P,
      X_PROGRAM_PARAMETERS PP,
      table_x_promotion pr,
      table_part_num pn,
      sa.table_mod_level pm,
      table_part_inst pi,
      table_part_class pc,
      table_bus_org bo,
      table_inv_bin ib,
      table_inv_locatn il,
      table_site ts,
      table_site_part sp,
      table_x_code_table code
    where CTP2P.PART_NUM_OBJID+0 = PN.OBJID
      AND CTP2P.PROGRAM_PARAM_OBJID+0 = PP.OBJID
      and n_part_inst2part_mod = pm.objid
      and part_info2part_num = pn.objid
      and pn.part_num2bus_org = bo.objid
      and pi.PART_INST2INV_BIN = ib.OBJID
      and ib.inv_bin2inv_locatn = il.objid
      and il.inv_locatn2site = ts.objid
      and pc.objid = pn.part_num2part_class
      and pi.x_part_inst_status||''='52'
      and sp.x_service_id = pi.part_Serial_no
      and sp.part_status||'' = 'Active'
      and sp.x_min not like 'T%'
      and code.objid = pi.status2x_code_table
      and ts.s_name||'' like 'CENTENE%'
      and PP.X_INCL_SERVICE_DAYS=pr.objid
      and not exists(select 1 from sa.centene_net10_subs x where x.x_esn = part_serial_no)
    ;
  dbms_output.put_line ('Step 1.1. New Centene active subs inserted into sa.CENTENE_NET10_SUBS:: '||SQL%ROWCOUNT);
COMMIT;
EXCEPTION WHEN OTHERS THEN NULL;
END CNTN_NET10_NEW_SUBS_PRC;
----------------------------------------------------OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO-----------------------------------------------------------------------
PROCEDURE CNTN_NET10_UPDATE_ACT_SUBS_PRC --step 1.2
AS
    -- STEP 2. Update phone status, MIN, due date
    count_updates number default 0;
    count_h2y number default 0;
    count_y2h number default 0;
    check_refurb varchar2(1) default 'N';
  cursor cur_esn_update is
   select *
   from
    (select
     cntn.rowid x_rowid
     ,cntn.x_esn
     ,code.x_code_name new_phone_status
     ,cntn.phone_status cntn_subs_ph_status
     ,cntn.x_min cntn_subs_min
     ,esn_expiry_date
     ,bill
     ,deenroll
     ,enrollment_status
     ,sp.x_min
     ,sp.x_expire_dt
     ,cntn.act_date
     ,rank() over
      (partition by cntn.rowid order by
       decode(sp.part_status,'Active',1,'Inactive',2,3)
       ,sp.install_date desc
       ,sp.objid desc
       ,decode(pe.x_enrollment_status,'ENROLLED',1,'READYTOREENROLL',2,3) asc
       ,pe.x_insert_date desc
       ,pe.objid desc
      )x_rank
     ,pe.x_enrollment_status
     ,pp.x_program_name
     ,cntn.current_plan
    from sa.centene_net10_subs cntn
     join table_part_inst pi on cntn.x_esn = part_serial_no
     join table_x_code_table code on status2x_code_table = code.objid
     join table_site_part sp on sp.x_service_id= pi.part_serial_no
     left outer join x_program_enrolled pe on pe.x_esn = cntn.x_esn and pe.x_sourcesystem = 'CENTENE'
     left outer join x_program_parameters pp on pp.objid = pe.pgm_enroll2pgm_parameter and pp.x_prog_class = 'HMO'
    ) x
  where    x_rank = 1
    and (x.cntn_subs_ph_status<>x.new_phone_status
    or nvl(x.enrollment_status,'x')<>x.x_enrollment_status
    or x.esn_expiry_date <> x.x_expire_dt
    or x.x_min <> x.cntn_subs_min)
    and x.cntn_subs_ph_status<>'REFURBISH';

BEGIN
   FOR rec_esn_update IN cur_esn_update LOOP
       BEGIN
          select 'Y' into check_refurb
          from table_x_pi_hist pih
          where pih.x_part_seriaL_no = rec_esn_update.x_esn
            and pih.x_change_date+0>rec_esn_update.act_date
            and pih.x_change_reason||'' = 'REFURBISHED'
            and rownum < 2;
       EXCEPTION
          WHEN no_data_found
          THEN check_refurb:='N';
       END;

   IF check_refurb = 'Y' THEN
        UPDATE sa.centene_net10_subs
        SET phone_status = 'REFURBISH',
            bill = decode(rec_esn_update.bill,'Y','P','H','P',rec_esn_update.bill),
            deenroll = decode(rec_esn_update.bill,'Y','1','H','1',rec_esn_update.deenroll),
            deenroll_date = nvl(deenroll_date,trunc(sysdate))
        where rowid = rec_esn_update.x_rowid;

   elsif rec_esn_update.new_phone_status<>'ACTIVE' and rec_esn_update.bill = 'Y' then
        update sa.centene_net10_subs
        set phone_status = rec_esn_update.new_phone_status,
            x_min = rec_esn_update.x_min,
            esn_expiry_date = rec_esn_update.x_expire_dt,
            enrollment_status = rec_esn_update.x_enrollment_status,
            bill = 'H',
            deenroll_date = trunc(sysdate)
        where rowid = rec_esn_update.x_rowid;
        count_y2h:=count_y2h+1;

   elsif rec_esn_update.new_phone_status='ACTIVE' and rec_esn_update.bill = 'H' then
          update sa.centene_net10_subs
          set phone_status = rec_esn_update.new_phone_status,
            x_min = rec_esn_update.x_min,
            esn_expiry_date = rec_esn_update.x_expire_dt,
            enrollment_status = rec_esn_update.x_enrollment_status,
            bill = 'Y',
            deenroll_date = null
          where rowid = rec_esn_update.x_rowid;
         count_h2y:=count_h2y+1;

   else
         update sa.centene_net10_subs
         set phone_status = rec_esn_update.new_phone_status,
            x_min = rec_esn_update.x_min,
            esn_expiry_date = rec_esn_update.x_expire_dt,
            enrollment_status = rec_esn_update.x_enrollment_status
         where rowid = rec_esn_update.x_rowid;

   end if;
    count_updates:=count_updates;
END LOOP;
COMMIT;

 dbms_output.put_line
    ('Step 2. Centene status updates completed.
      Rows effected:: '||count_updates||'
      Bill Y found inactive and moved to H:: '
      ||count_y2h||
     ' Bill H found active and moved back to Y:: '
     ||count_h2y
     );
EXCEPTION WHEN OTHERS THEN
    INSERT INTO  ERROR_TABLE (ERROR_TEXT, ERROR_DATE  , ACTION,  KEY,  PROGRAM_NAME)
     VALUES ('Step 1.2. Centene status updates failed', SYSDATE,'rec_esn_update',100,'CNTN_NET10_UPDATE_ACT_SUBS_PRC');
END CNTN_NET10_UPDATE_ACT_SUBS_PRC;
----------------------------------------------------OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO-----------------------------------------------------------------------
PROCEDURE CNTN_UPDATE_UPGRADES_EXC_PRC -- step 1.3
AS
-- STEP 3. Updates from ugrades and exchanges
CURSOR cur_cntn_upex
 IS
 SELECT upex.*,
     xnew.start_date new_esn_start_date,
     xnew.current_plan new_esn_curr_plan
FROM    (SELECT esn.x_value new_Esn,
            upex.x_esn old_esn,
            upex.title,
            upex.id_number upex_case_id,
            upex.creation_time new_upex_date,
            cntn.bill old_Esn_bill,
            cntn.deenroll old_Esn_deenroll,
            cntn.DEENROLL_DATE old_Esn_DEENROLL_DATE,
            cntn.PHONE_STATUS old_esn_phone_status,
            cntn.x_min old_Esn_min,
            cntn.start_date old_Esn_start_date,
            cntn.act_date old_Esn_act_date,
            cntn.current_plan old_Esn_curr_plan
       FROM sa.centene_net10_subs cntn,
            table_case upex,
            table_x_case_detail esn
      WHERE     1 = 1
            AND upex.creation_time + 0 >= TRUNC (SYSDATE) - 30
            AND upex.title IN ('Phone Upgrade', 'Unit Transfer')
            AND esn.detail2case = upex.objid
            AND esn.x_name || '' = 'NEW_ESN'
            AND cntn.x_esn = upex.x_esn
     UNION ALL
     SELECT upex.x_esn,
            esn.x_value,
            upex.title,
            upex.id_number,
            upex.creation_time new_upex_date,
            cntn.bill old_Esn_bill,
            cntn.deenroll old_Esn_deenroll,
            cntn.DEENROLL_DATE old_Esn_DEENROLL_DATE,
            cntn.PHONE_STATUS old_esn_phone_status,
            cntn.x_min old_Esn_min,
            cntn.start_date,
            cntn.act_date,
            cntn.current_plan
       FROM sa.centene_net10_subs cntn,
            table_case upex,
            table_x_case_detail esn
      WHERE     1 = 1
            AND upex.creation_time + 0 >= TRUNC (SYSDATE) - 30
            AND upex.title IN ('Internal', 'Auto Internal')
            AND esn.detail2case = upex.objid
            AND esn.x_name = 'CURRENT_ESN'
            AND esn.x_value = cntn.x_esn
     UNION ALL
     SELECT NEW_ESN,
            OLD_ESN,
            TITLE,
            UPEX_CASE_ID,
            NEW_UPEX_DATE,
            OLD_ESN_BILL,
            OLD_ESN_DEENROLL,
            OLD_ESN_DEENROLL_DATE,
            OLD_ESN_PHONE_STATUS,
            OLD_ESN_MIN,
            start_date,
            act_date,
            current_plan
       FROM (SELECT px.x_part_serial_no new_esn,
                    upex.x_esn old_Esn,
                    upex.title,
                    upex.id_number upex_case_id,
                    px.x_ship_date new_upex_date,
                    cntn.bill old_Esn_bill,
                    cntn.deenroll old_Esn_deenroll,
                    cntn.DEENROLL_DATE old_Esn_DEENROLL_DATE,
                    cntn.PHONE_STATUS old_esn_phone_status,
                    cntn.x_min old_Esn_min,
                    cntn.start_date,
                    cntn.act_date,
                    cntn.current_plan,
                    RANK ()
                    OVER (PARTITION BY upex.objid
                               ORDER BY px.X_SHIP_DATE DESC, px.objid DESC
                               ) exch_rank
                  FROM sa.centene_net10_subs cntn,
                    sa.table_x_part_request px,
                    table_case upex
                  WHERE     1 = 1
                    AND px.X_SHIP_DATE + 0 >= TRUNC (SYSDATE) - 30
                    AND upex.objid = px.request2case
                    AND px.x_part_serial_no IS NOT NULL
                    AND cntn.x_esn = upex.x_esn
                    AND NVL (px.x_part_num_domain, 'PHONES') = 'PHONES'
                 )
          WHERE exch_rank = 1
          ) upex
     LEFT OUTER JOIN
        sa.CENTENE_NET10_SUBS xnew
     ON xnew.x_esn = upex.new_esn
 WHERE NOT EXISTS
            (SELECT 1 FROM table_x_pi_hist pih
              WHERE pih.x_part_serial_no = upex.old_esn
                AND pih.x_change_date + 0 >= upex.old_esn_act_date + 5
                AND pih.x_change_date + 0 < upex.new_upex_date
                AND pih.x_change_reason || '' = 'REFURBISHED'
            );

count_old_Esn_update   NUMBER DEFAULT 0;
count_new_esn_update   NUMBER DEFAULT 0;

BEGIN  ----PROC BEGIN MIAN CNTN_UPDATE_UPGRADES_EXC_PRC --
FOR rec_cntn_upex IN cur_cntn_upex
LOOP
IF rec_cntn_upex.old_esn_bill <> 'P' OR rec_cntn_upex.new_upex_date <> rec_cntn_upex.old_Esn_deenroll_date THEN
 UPDATE sa.centene_net10_subs SET bill = 'P', deenroll = '1', deenroll_date = rec_cntn_upex.new_upex_date WHERE x_esn = rec_cntn_upex.old_esn;
 count_old_Esn_update := count_old_Esn_update + 1;
END IF;

IF rec_cntn_upex.new_esn_start_date <> rec_cntn_upex.old_Esn_start_date THEN
 UPDATE sa.centene_net10_subs SET start_date = rec_cntn_upex.old_Esn_start_date WHERE x_esn = rec_cntn_upex.new_esn;
 count_new_esn_update := count_new_esn_update + 1;
END IF;
END LOOP;
COMMIT;
DBMS_OUTPUT.put_line
 ('Step 3. Centene UPEX status updates completed.
  Old ESN rows effected:: '
  || count_old_esn_update
  || ' New ESN rows effected:: '
  || count_new_esn_update
 );
 EXCEPTION WHEN OTHERS THEN
    INSERT INTO  ERROR_TABLE (ERROR_TEXT, ERROR_DATE  , ACTION,  KEY,  PROGRAM_NAME)
     VALUES ('STEP 1.3. Updates from ugrades and exchanges failed', SYSDATE,'rec_cntn_upex.old_esn',200,'CNTN_UPDATE_UPGRADES_EXC_PRC');
END CNTN_UPDATE_UPGRADES_EXC_PRC;
----------------------------------------------------OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO-----------------------------------------------------------------------
PROCEDURE CNTN_NET10_UPDATE_ACT_LOG_PRC -- step 1.4
AS
BEGIN   -- MAIN CNTN_NET10_UPDATE_ACT_LOG_PRC
   DECLARE
      CURSOR cur_actions_log
      IS
       SELECT al.*,
              cntn.bill,
              cntn.deenroll,
              cntn.phone_status,
              cntn.current_plan,
              cntn.customer_commit_date,
              cntn.ROWID cntn_rowid,
              al.ROWID al_rowid
         FROM sa.CENTENE_ACTIONS_LOG al, sa.CENTENE_NET10_SUBS cntn
        WHERE al.x_status = 'PENDING' AND cntn.x_esn(+) = al.x_esn
     ORDER BY al.x_insert_date;

      count_enr_suc       NUMBER := 0;
      count_enr_fail      NUMBER := 0;
      count_deenr_suc     NUMBER := 0;
      count_deenr_fail    NUMBER := 0;
      count_plch_suc      NUMBER := 0;
      count_plch_fail     NUMBER := 0;
      count_ext_suc       NUMBER := 0;
      count_ext_fail      NUMBER := 0;
      count_invalid_req   NUMBER := 0;
      check_new_plan      VARCHAR2 (1);
   BEGIN
      FOR rec_actions_log IN cur_actions_log
      LOOP
         IF rec_actions_log.x_action_name = 'ENROLL'
         THEN
            IF rec_actions_log.bill <> 'Y' AND rec_actions_log.phone_status = 'ACTIVE'
            THEN
               UPDATE sa.CENTENE_NET10_SUBS
                  SET bill = 'Y', deenroll = NULL, deenroll_date = NULL
                WHERE ROWID = rec_actions_log.cntn_rowid;

               UPDATE sa.CENTENE_ACTIONS_LOG
                  SET x_status = 'COMPLETED'
                WHERE ROWID = rec_actions_log.al_rowid;

               count_enr_suc := count_enr_suc + 1;
            ELSE
               UPDATE sa.CENTENE_ACTIONS_LOG
                  SET x_status =
                         CASE
                            WHEN rec_actions_log.bill = 'Y' THEN 'IGNORED'
                            WHEN rec_actions_log.phone_status != 'ACTIVE' THEN 'FAILED INACTIVE'
                            WHEN rec_actions_log.cntn_rowid IS NULL THEN 'FAILED INVALID ESN'
                            ELSE 'FAILED OTHER'
                         END
                WHERE ROWID = rec_actions_log.al_rowid;

               count_enr_fail := count_enr_fail + 1;
            END IF;
         ELSIF rec_actions_log.x_action_name = 'DEENROLL'
         THEN
            IF rec_actions_log.bill != 'D' AND NVL (rec_actions_log.deenroll, 'x') != '3'
            THEN
               UPDATE sa.CENTENE_NET10_SUBS
                  SET bill = 'D', deenroll = '3', deenroll_date = SYSDATE
                WHERE ROWID = rec_actions_log.cntn_rowid;

               UPDATE sa.CENTENE_ACTIONS_LOG
                  SET x_status = 'COMPLETED'
                WHERE ROWID = rec_actions_log.al_rowid;

               count_deenr_suc := count_deenr_suc + 1;
            ELSE
               UPDATE sa.CENTENE_ACTIONS_LOG
                  SET x_status =
                         CASE
                            WHEN rec_actions_log.bill = 'D' AND rec_actions_log.deenroll = '3' THEN 'IGNORED'
                            WHEN rec_actions_log.cntn_rowid IS NULL THEN 'FAILED INVALID ESN'
                            ELSE 'FAILED OTHER'
                         END
                WHERE ROWID = rec_actions_log.al_rowid;

               count_deenr_fail := count_deenr_fail + 1;
            END IF;
         ELSIF rec_actions_log.x_action_name = 'PLAN_CHANGE'
         THEN
            BEGIN
               SELECT 'Y' INTO check_new_plan
                 FROM x_program_parameters pp
                WHERE x_program_name = rec_actions_log.new_plan AND x_prog_class = 'HMO';
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN  check_new_plan := 'N';
               WHEN OTHERS
               THEN  check_new_plan := 'X';
            END;

            IF  rec_actions_log.bill = 'Y'
               AND rec_actions_log.new_plan != NVL (rec_actions_log.current_plan, 'x')
               AND check_new_plan = 'Y'
            THEN
               UPDATE sa.CENTENE_NET10_SUBS
                  SET current_plan = rec_actions_log.new_plan
                WHERE ROWID = rec_actions_log.cntn_rowid;

               UPDATE sa.CENTENE_ACTIONS_LOG
                  SET x_status = 'COMPLETED'
                WHERE ROWID = rec_actions_log.al_rowid;

               count_plch_suc := count_plch_suc + 1;
            ELSE
               UPDATE sa.CENTENE_ACTIONS_LOG
                  SET x_status =
                     CASE
                        WHEN rec_actions_log.new_plan = rec_actions_log.current_plan THEN 'IGNORED'
                        WHEN rec_actions_log.phone_status != 'ACTIVE' THEN 'FAILED INACTIVE'
                        WHEN rec_actions_log.bill != 'Y' THEN 'FAILED DEENROLLED'
                        WHEN rec_actions_log.cntn_rowid IS NULL THEN 'FAILED INVALID ESN'
                        WHEN check_new_plan <> 'Y' THEN 'FAILED INVALID PLAN'
                        ELSE 'FAILED OTHER'
                        END
                WHERE ROWID = rec_actions_log.al_rowid;

               count_plch_fail := count_plch_fail + 1;
            END IF;
         ELSIF rec_actions_log.x_action_name = 'EXTEND_PLAN'
         THEN
            IF rec_actions_log.cntn_rowid IS NOT NULL
            THEN
               UPDATE sa.CENTENE_NET10_SUBS
                  SET customer_commit_date =
                          ADD_MONTHS
                          (CASE
                           WHEN NVL (rec_actions_log.customer_commit_date, SYSDATE - 1) < SYSDATE
                           THEN ADD_MONTHS (TRUNC (SYSDATE, 'MM'), 1) + 13
                           ELSE rec_actions_log.customer_commit_date
                           END,
                            rec_actions_log.extend_months
                           )
                WHERE ROWID = rec_actions_log.cntn_rowid;

               UPDATE sa.CENTENE_ACTIONS_LOG SET x_status = 'COMPLETED' WHERE ROWID = rec_actions_log.al_rowid;
               count_ext_suc := count_ext_suc + 1;
            ELSE
               UPDATE sa.CENTENE_ACTIONS_LOG
               SET x_status = CASE WHEN rec_actions_log.cntn_rowid IS NULL THEN 'FAILED INVALID ESN' ELSE 'FAILED OTHER' END
               WHERE ROWID = rec_actions_log.al_rowid;
               count_ext_fail := count_ext_fail + 1;
            END IF;
         ELSE
            UPDATE sa.CENTENE_ACTIONS_LOG SET x_status = 'INVALID ACTION NAME' WHERE ROWID = rec_actions_log.al_rowid;
            count_invalid_req := count_invalid_req + 1;
         END IF;
      END LOOP;

      COMMIT;
      DBMS_OUTPUT.put_line
      (  'Step 4. Centene UPEX status updates completed.
          Successful re-enrollments:: '
         || count_enr_suc
         || 'Failed or ignored re-enrollments:: '
         || count_enr_fail
         || ' Successful de-enrollments:: '
         || count_deenr_suc
         || ' Failed or ignored de-enrollments:: '
         || count_deenr_fail
         || ' Successful plan changes:: '
         || count_plch_suc
         || ' Failed or ignored plan changes:: '
         || count_plch_fail
         || ' Successful plan extensions:: '
         || count_ext_suc
         || ' Failed or ignored plan extensions:: '
         || count_ext_fail
         || ' Invalid request:: '
         || count_invalid_req
    );
   END;

EXCEPTION WHEN OTHERS THEN
         INSERT INTO  ERROR_TABLE (ERROR_TEXT, ERROR_DATE  , ACTION,  KEY,  PROGRAM_NAME)
         VALUES ('STEP 1.4. Centene UPEX status updates failed', SYSDATE,'rec_actions_log.x_esn',300,'CNTN_NET10_UPDATE_ACT_LOG_PRC');
END CNTN_NET10_UPDATE_ACT_LOG_PRC;
----------------------------------------------------OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO-----------------------------------------------------------------------
--ooooooooooooooooooooooooooooooooooooooooooo-----
PROCEDURE CNTN_NET10_SUBS_ESNS_NEW_PRC -- step1
AS
   pending_enrollments_count     NUMBER DEFAULT 0;
   pending_flash_count           NUMBER DEFAULT 0;
   pending_deenrollments_count   NUMBER DEFAULT 0;
   pending_plan_change           NUMBER DEFAULT 0;
   pending_free_dial_site        NUMBER DEFAULT 0;
   email_text clob;
   email_result varchar2(100);
BEGIN ----------- MAIN -------------------

  CNTN_NET10_NEW_SUBS_PRC; -- STEP 1. Get new active subs
  CNTN_NET10_UPDATE_ACT_SUBS_PRC;-- STEP 2. Update phone status, MIN, due date
  CNTN_UPDATE_UPGRADES_EXC_PRC;   -- STEP 3 Centene UPEX status updates
  CNTN_NET10_UPDATE_ACT_LOG_PRC; --- Step 4. Centene UPEX status updates

   SELECT COUNT (*)
     INTO pending_enrollments_count
     FROM sa.CENTENE_NET10_SUBS
    WHERE bill = 'Y' AND NVL (enrollment_status, 'x') <> 'ENROLLED';

   SELECT COUNT (*)
     INTO pending_flash_count
     FROM sa.CENTENE_NET10_SUBS cntn
    WHERE  bill = 'Y'
      AND NOT EXISTS (SELECT 1 FROM table_part_inst pi, table_alert ta
                       WHERE  pi.part_serial_no = cntn.x_esn AND pi.objid = ta.alert2contract
                      );

   SELECT COUNT (*)
     INTO pending_deenrollments_count
     FROM sa.CENTENE_NET10_SUBS
    WHERE bill <> 'Y' AND enrollment_status = 'ENROLLED';

   SELECT COUNT (*)
     INTO pending_plan_change
     FROM sa.CENTENE_NET10_SUBS cntn
    WHERE     bill = 'Y'
       AND EXISTS (SELECT 1 FROM x_program_enrolled pe, x_program_parameters pp
                   WHERE pe.x_esn = cntn.x_esn
                     AND pe.x_enrollment_status = 'ENROLLED'
                     AND pe.pgm_enroll2pgm_parameter = pp.objid
                     AND pp.x_program_name <> cntn.current_plan
                  );

   SELECT COUNT (*)
     INTO pending_free_dial_site
     FROM sa.centene_net10_subs cntn,
          table_parT_inst pi,
          table_x_ota_features otaf
    WHERE     cntn.x_esn = pi.part_serial_no
          AND otaf.x_ota_features2part_inst = pi.objid
          AND cntn.bill = 'Y'
          AND otaf.x_free_dial IS NULL;

---send email
  email_text := '========================== '||chr(10);
  email_text := email_text   ||' '
                             ||'Completed Centene_NET10_Subs inserts/updates on '
                             || TO_CHAR (SYSDATE, 'MM/DD/YY')
                             || ' at '
                             || TO_CHAR (SYSDATE, 'HH:MI:SS AM')
                             || ' ESNs pending enrollment: '
                             || pending_enrollments_count
                             || ' ESNs pending flash insert: '
                             || pending_flash_count
                             || ' ESNs pending de-enrollment: '
                             || pending_deenrollments_count
                             || ' ESNs pending plan change: '
                             || pending_plan_change
                             || ' ESNs pending free dial site setting: '
                             || pending_free_dial_site
                             ||chr(10) ;
 email_text := email_text ||' ============================';
  sa.SEND_MAIL ('CNTN Exception Report',
                'noreply@tracfone.com',
                'OARBAB@tracfone.com', --'BusinessSolutions@tracfone.com,SubscriberServices@tracfone.com'
                email_text,
                email_result
               );

EXCEPTION WHEN OTHERS THEN
    INSERT INTO  ERROR_TABLE (ERROR_TEXT, ERROR_DATE  , ACTION,  KEY,  PROGRAM_NAME)
     VALUES ('STEP 1. Centene UPEX status updates failed', SYSDATE,'Centene_NET10_Subs inserts/updates main proc',400,'CNTN_NET10_SUBS_ESNS_NEW_PRC');
END CNTN_NET10_SUBS_ESNS_NEW_PRC;
----------------------------------------------------*****************************************************************************************************-----------------------------------------------------------------------
PROCEDURE CNTN_ENROLLMENT_PRC
AS
   l_web_user_id         NUMBER;
   myaccount_esn         VARCHAR2 (50);
   l_login_name          VARCHAR2 (50);
   act_state             VARCHAR2 (40);
   act_city              VARCHAR2 (100);
   act_zip               VARCHAR2 (40);
   CON_STATE             VARCHAR2 (40);
   l_existing_web_id     NUMBER;
   CON_OBJID             NUMBER;
   PI_OBJID              NUMBER;
   current_dial_code     VARCHAR2 (50);
   correct_dial_code     VARCHAR2 (50);-------------
   l_esn_man_enr         VARCHAR2 (40);
   l_pgm_name_man_enr    VARCHAR2 (100);
   l_enroll_seq          NUMBER;
   l_purch_hdr_seq       NUMBER;
   l_purch_hdr_dtl_seq   NUMBER;
   l_program_trans_seq   NUMBER;
   l_tax                 NUMBER;
   l_e911_tax            NUMBER;
   l_esn_web             NUMBER := 0;
   l_prog_id             NUMBER;
   cnt                   NUMBER := 0;
   counter_E              NUMBER:=0;


   CURSOR cur_get_pend_myaccount
   IS
      SELECT ROWID, x_esn
        FROM sa.CENTENE_MYACCOUNT
       WHERE x_status = 'PENDING' AND x_insert_date >= TRUNC (SYSDATE) - 1;

   CURSOR cur_get_man_enr
   IS
   SELECT *
      FROM (SELECT C.*,
                        ROW_NUMBER() OVER(PARTITION BY C.X_ESN ORDER BY C.X_INSERT_DATE DESC) X_RANK
                FROM sa.CENTENE_MYACCOUNT C
               WHERE x_status = 'COMPLETED' AND x_insert_date >= TRUNC (SYSDATE) - 1
               AND NOT EXISTS (SELECT 1 FROM sa.CENTENE_MANUAL_ENROLLMENT ME
                                        WHERE ME.X_ESN = C.X_ESN
                                        AND ME.X_STATUS = 'PENDING'))
      WHERE X_RANK = 1;



   CURSOR c_list
   IS
      SELECT x_esn,
             pgm_enroll2site_part,
             pgm_enroll2part_inst,
             pgm_enroll2contact,
             pgm_enroll2web_user,
             x_zip_code,
             x_state,
             PGM_ENROLL2PGM_PARAMETER,
             (SELECT MAX (x_retail_price)
                FROM table_x_pricing pr, x_program_parameters pp
               WHERE     x_pricing2part_num = PROG_PARAM2PRTNUM_MONFEE
                     AND pr.x_end_date > SYSDATE
                     AND pr.x_start_date < SYSDATE
                     AND pp.objid = PGM_ENROLL2PGM_PARAMETER)
                x_amount
        FROM sa.CENTENE_MANUAL_ENROLLMENT lm
       WHERE     x_insert_date >= TRUNC (SYSDATE - 2)
             AND x_status = 'PENDING'
             AND x_state IS NOT NULL
             AND NOT EXISTS
                        (SELECT 1
                           FROM x_program_enrolled pe
                          WHERE     x_sourcesystem = 'CENTENE'
                                AND x_enrollment_status = 'ENROLLED'
                                AND pe.x_esn = lm.x_esn)
             AND ROWNUM < 1001;
BEGIN

------------- ###### ENROLLMENTS ###### ---------------

begin
    insert into sa.CENTENE_MYACCOUNT (x_esn, X_PROGRAM_NAME)
    select x_esn, CURRENT_PLAN from sa.CENTENE_NET10_SUBS p
    where NVL(p.ENROLLMENT_STATUS, 'DEENROLLED') <> 'ENROLLED'
        and p.phone_status = 'ACTIVE'
        and p.bill= 'Y'
        and not exists (select 1 from sa.CENTENE_MYACCOUNT y where p.x_esn = y.x_esn and y.x_status = 'PENDING') -- to make sure nothing is already Queued
        and not exists (select 1 from sa.X_PROGRAM_ENROLLED pe where p.x_esn = pe.x_esn and pe.x_enrollment_status = 'ENROLLED');  -- to make sure ESN is not already enrolled
    commit;
    counter_E:=counter_E + 1;
    dbms_output.put_line('Completed inserts into SA.CENTENE_MYACCOUNT Rows effected:: '||counter_E);
    commit;
   end;



   FOR rec_get_pend_myaccount IN cur_get_pend_myaccount
   LOOP
      l_web_user_id := sa.seq ('web_user');
      myaccount_esn := rec_get_pend_myaccount.x_esn;
      l_login_name := '';
      act_state := '';
      CON_STATE := '';
      CON_OBJID := 0;
      PI_OBJID := 0;

      BEGIN
         SELECT objid,
                PI_OBJID,
                Activation_State,
                Activation_City,
                Activation_Zip,
                Current_Dial_Code,
                correct_dial_code
           INTO CON_OBJID,
                PI_OBJID,
                ACT_STATE,
                ACT_CITY,
                ACT_ZIP,
                current_dial_code,
                correct_dial_code
           FROM (SELECT DISTINCT
                        pi.objid PI_OBJID,
                        pi.part_serial_no,
                        tc.objid,
                        TC.STATE Contact_State,
                        TC.ZIPCODE Contact_Zip,
                        TC.CITY CONTACT_CITY,
                        SP.X_ZIPCODE Activation_Zip,
                        ZIP.X_STATE Activation_State,
                        ZIP.X_CITY Activation_City,
                        (SELECT OTA.X_FREE_DIAL
                           FROM table_x_ota_features ota
                          WHERE OTA.X_OTA_FEATURES2PART_INST = pi.objid)
                           Current_Dial_Code,
                        (SELECT ts1.phone
                           FROM table_site ts1, table_site ts
                          WHERE     TS1.CHILD_SITE2SITE = ts.objid
                                AND TS.S_NAME = 'CENTENE CORPORATION'
                                AND ts1.s_name =
                                       ts.s_name || '-' || ZIP.X_STATE)
                           Correct_Dial_Code
                   FROM table_part_inst pi,
                        table_contact tc,
                        table_site_part sp,
                        table_x_zip_code zip
                  WHERE     part_serial_no = myaccount_esn
                        AND PI.X_PART_INST2CONTACT = tc.objid
                        AND sp.x_service_id = pi.part_serial_no
                        AND sp.part_status = 'Active'
                        AND ZIP.X_ZIP = SP.X_ZIPCODE)
          WHERE    contact_state <> activation_state
                OR NVL (current_dial_code, 'X') <> correct_dial_code;

         IF (NVL (CON_OBJID, 0) <> 0)
         THEN
            UPDATE table_contact
               SET STATE = act_state, city = ACT_CITY, zipcode = ACT_ZIP
             WHERE objid = CON_OBJID;

            COMMIT;
         END IF;

         IF NVL (current_dial_code, 'X') <> correct_dial_code
         THEN
            UPDATE table_x_ota_features
               SET x_free_dial = NULL
             WHERE x_ota_features2part_inst = PI_OBJID;

            COMMIT;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
      END;

      BEGIN
         SELECT web.objid, web.login_name
           INTO l_existing_web_id, l_login_name
           FROM table_part_inst pi,
                table_x_contact_part_inst cpi,
                table_web_user web
          WHERE     web.web_user2contact = CPI.X_CONTACT_PART_INST2CONTACT
                AND CPI.X_CONTACT_PART_INST2PART_INST = pi.objid
                AND PI.PART_SERIAL_NO = myaccount_esn;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            l_existing_web_id := 0;
      END;

      IF (NVL (l_existing_web_id, 0) = 0)
      THEN
         INSERT INTO table_web_user(OBJID
									,LOGIN_NAME
									,S_LOGIN_NAME
									,PASSWORD
									,USER_KEY
									,STATUS
									,PASSWD_CHG
									,DEV
									,SHIP_VIA
									,X_SECRET_QUESTN
									,S_X_SECRET_QUESTN
									,X_SECRET_ANS
									,S_X_SECRET_ANS
									,WEB_USER2USER
									,WEB_USER2CONTACT
									,WEB_USER2LEAD
									,WEB_USER2BUS_ORG
									,X_LAST_UPDATE_DATE
									,X_VALIDATED
									,X_VALIDATED_COUNTER
									,NAMED_USERID)
			  VALUES (
                        l_web_user_id,
                           'Centene'
                        || SUBSTR (l_web_user_id,
                                   LENGTH (l_web_user_id) - 3,
                                   4)
                        || SUBSTR (myaccount_esn,
                                   LENGTH (myaccount_esn) - 3,
                                   4)
                        || '@tracmail.com',
                           'CENTENE'
                        || SUBSTR (l_web_user_id,
                                   LENGTH (l_web_user_id) - 3,
                                   4)
                        || SUBSTR (myaccount_esn,
                                   LENGTH (myaccount_esn) - 3,
                                   4)
                        || '@TRACMAIL.COM',
                        '39413925378938053829390138933821',
                        NULL,
                        1,
                        NULL,
                        NULL,
                        NULL,
                        'What is your pets name',
                        'WHAT IS YOUR PETS NAME',
                        'Lacey',
                        'LACEY',
                        NULL,
                        (SELECT X_PART_INST2CONTACT
                           FROM table_part_inst
                          WHERE     part_serial_no = myaccount_esn
                                AND x_part_inst_status = '52'),
                        NULL,
                        268438258,
                        SYSDATE,
                        1,
                        1,
                        '' );-- CR42489 Named userid

         COMMIT;

         INSERT INTO table_x_contact_part_inst
              VALUES (
                        sa.seq ('x_contact_part_inst'),
                        (SELECT X_PART_INST2CONTACT
                           FROM table_part_inst
                          WHERE     part_serial_no = myaccount_esn
                                AND x_part_inst_status = '52'),
                        (SELECT OBJID
                           FROM table_part_inst
                          WHERE     part_serial_no = myaccount_esn
                                AND x_part_inst_status = '52'),
                        'TEST',
                        1,
                        0,
                        'Y');

         COMMIT;

         SELECT S_LOGIN_NAME
           INTO l_login_name
           FROM table_web_user
          WHERE objid = l_web_user_id;

         UPDATE sa.CENTENE_MYACCOUNT
            SET x_status = 'COMPLETED'
          WHERE ROWID = rec_get_pend_myaccount.ROWID;

         COMMIT;
      END IF;

      -- my account exists.
      IF (NVL (l_existing_web_id, 0) <> 0)
      THEN
         UPDATE sa.CENTENE_MYACCOUNT
            SET x_status = 'COMPLETED'
          WHERE ROWID = rec_get_pend_myaccount.ROWID;

         COMMIT;
      END IF;

      DBMS_OUTPUT.PUT_LINE (' Login name is :: ' || l_login_name);
   END LOOP;
-----------------------------------------------------------------------------------------
   BEGIN
      FOR rec_get_man_enr IN cur_get_man_enr
      LOOP
         l_esn_man_enr := rec_get_man_enr.x_esn;
         l_pgm_name_man_enr := rec_get_man_enr.x_program_name;

         INSERT INTO sa.CENTENE_MANUAL_ENROLLMENT
              VALUES (
                        l_esn_man_enr,
                        (SELECT objid
                           FROM table_site_part
                          WHERE     x_service_id = l_esn_man_enr
                                AND part_status = 'Active'),
                        (SELECT objid
                           FROM table_part_inst
                          WHERE     part_serial_no = l_esn_man_enr
                                AND x_part_inst_status = '52'),
                        (SELECT X_PART_INST2CONTACT
                           FROM table_part_inst
                          WHERE     part_serial_no = l_esn_man_enr
                                AND x_part_inst_status = '52'),
                        (SELECT web.objid
                           FROM table_web_user web,
                                table_x_contact_part_inst cpi,
                                table_part_inst pi
                          WHERE     web.web_user2contact =
                                       CPI.X_CONTACT_PART_INST2CONTACT
                                AND CPI.X_CONTACT_PART_INST2PART_INST =
                                       PI.objid
                                AND PI.part_serial_no = l_esn_man_enr
                                AND ROWNUM = 1),
                        (SELECT X_ZIPCODE
                           FROM table_site_part
                          WHERE     x_service_id = l_esn_man_enr
                                AND part_status = 'Active'),
                        'FL',
                        'PENDING',
                        (SELECT objid
                           FROM x_program_parameters
                          WHERE x_program_name = l_pgm_name_man_enr),
                        SYSDATE,
                        NULL);

         COMMIT;
      END LOOP;
   END;
--------------------------------------------------------------------------------------------
   BEGIN
      FOR c_rec IN c_list
      LOOP
         cnt := cnt + 1;
         /*DBMS_OUTPUT.put_line ('Loop Count :' || cnt);*/

         l_enroll_seq := sa.billing_seq ('X_PROGRAM_ENROLLED');
         l_purch_hdr_seq := sa.billing_seq ('X_PROGRAM_PURCH_HDR');
         l_purch_hdr_dtl_seq := sa.billing_seq ('X_PROGRAM_PURCH_DTL');
         l_program_trans_seq := sa.billing_seq ('X_PROGRAM_TRANS');
         l_tax := 0;
         l_e911_tax := 0;

         INSERT INTO x_program_enrolled (objid,
                                         x_esn,
                                         x_amount,
                                         x_type,
                                         x_sourcesystem,
                                         x_insert_date,
                                         x_charge_date,
                                         x_enrolled_date,
                                         x_start_date,
                                         x_reason,
                                         x_delivery_cycle_number,
                                         x_enroll_amount,
                                         x_language,
                                         x_enrollment_status,
                                         x_is_grp_primary,
                                         x_next_delivery_date,
                                         x_update_stamp,
                                         x_update_user,
                                         pgm_enroll2pgm_parameter,
                                         pgm_enroll2site_part,
                                         pgm_enroll2part_inst,
                                         pgm_enroll2contact,
                                         pgm_enroll2web_user,
                                         x_termscond_accepted)
              VALUES (l_enroll_seq,
                      c_rec.x_esn,
                      c_rec.x_amount,
                      'INDIVIDUAL',
                      'CENTENE',
                      SYSDATE,
                      SYSDATE,
                      SYSDATE,
                      SYSDATE,
                      'NET10 CENTENE MANUAL ENROLLMENT',
                      1,
                      0,
                      'ENGLISH',
                      'ENROLLED',
                      1,
                      NULL,
                      SYSDATE,
                      'OPERATIONS',
                      c_rec.PGM_ENROLL2PGM_PARAMETER,
                      c_rec.pgm_enroll2site_part,
                      c_rec.pgm_enroll2part_inst,
                      c_rec.pgm_enroll2contact,
                      c_rec.pgm_enroll2web_user,
                      1);

         COMMIT;

         INSERT INTO x_program_purch_hdr (objid,
                                          x_rqst_source,
                                          x_rqst_type,
                                          x_rqst_date,
                                          x_merchant_ref_number,
                                          x_ignore_avs,
                                          x_ics_rcode,
                                          x_ics_rflag,
                                          x_ics_rmsg,
                                          x_auth_rcode,
                                          x_auth_rflag,
                                          x_auth_rmsg,
                                          x_bill_rcode,
                                          x_bill_rflag,
                                          x_bill_rmsg,
                                          x_customer_email,
                                          x_status,
                                          x_bill_country,
                                          x_amount,
                                          x_tax_amount,
                                          x_e911_tax_amount,
                                          x_user,
                                          prog_hdr2web_user,
                                          x_payment_type)
              VALUES (l_purch_hdr_seq,
                      'CENTENE',
                      'CENTENE_PURCH',
                      SYSDATE,
                      sa.merchant_ref_number,
                      'YES',
                      '1',
                      'SOK',
                      'Request was processed successfully.',
                      '1',
                      'SOK',
                      'Request was processed successfully.',
                      '1',
                      'SOK',
                      'Request was processed successfully.',
                      'NULL@CYBERSOURCE.COM',
                      'CENTENEPROCESSED',
                      'USA',
                      c_rec.x_amount,
                      l_tax,
                      l_e911_tax,
                      'OPERATIONS',
                      c_rec.pgm_enroll2web_user,
                      'CE_ENROLL');

         COMMIT;

         /*DBMS_OUTPUT.put_line
                 (   'Record Inserted in x_program_purch_hdr :: Rows Effected : '
                  || SQL%ROWCOUNTe
                 );*/

         INSERT INTO x_program_purch_dtl (objid,
                                          x_esn,
                                          x_amount,
                                          x_tax_amount,
                                          x_e911_tax_amount,
                                          x_charge_desc,
                                          x_cycle_start_date,
                                          x_cycle_end_date,
                                          pgm_purch_dtl2pgm_enrolled,
                                          pgm_purch_dtl2prog_hdr)
              VALUES (l_purch_hdr_dtl_seq,
                      c_rec.x_esn,
                      c_rec.x_amount,
                      l_tax,
                      l_e911_tax,
                      'CHARGES FOR CENTENE CUSTOMERS',
                      TRUNC (SYSDATE),
                      TRUNC (SYSDATE) + 30,
                      l_enroll_seq,
                      l_purch_hdr_seq);

         COMMIT;

         /*DBMS_OUTPUT.put_line
                 (   'Record Inserted in x_program_purch_dtl :: Rows Effected : '
                  || SQL%ROWCOUNT
                 );*/

         INSERT INTO x_program_trans (objid,
                                      x_enrollment_status,
                                      x_enroll_status_reason,
                                      x_trans_date,
                                      x_action_text,
                                      x_action_type,
                                      x_reason,
                                      x_sourcesystem,
                                      x_esn,
                                      x_update_user,
                                      pgm_tran2pgm_entrolled,
                                      pgm_trans2web_user,
                                      pgm_trans2site_part)
              VALUES (l_program_trans_seq,
                      'ENROLLED',
                      'FIRST TIME ENROLLMENT',
                      SYSDATE,
                      'ENROLLMENT ATTEMPT',
                      'ENROLLMENT',
                      'CENTENE CUSTOMER MANUAL ENROLLMENT',
                      'SYSTEM',
                      c_rec.x_esn,
                      'OPERATIONS',
                      l_enroll_seq,
                      c_rec.pgm_enroll2web_user,
                      c_rec.pgm_enroll2site_part);

         /*DBMS_OUTPUT.put_line
                     (   'Record Inserted in X_PROGRAM_TRANS :: Rows Effected : '
                      || SQL%ROWCOUNT
                     );*/
         COMMIT;

         UPDATE sa.CENTENE_MANUAL_ENROLLMENT
            SET x_status = 'ENROLLED', x_update_date = SYSDATE
          WHERE     x_esn = c_rec.x_esn
                AND x_status = 'PENDING'
                AND x_insert_date >= TRUNC (SYSDATE - 2);

         COMMIT;

      END LOOP;

      COMMIT;
   END;
EXCEPTION WHEN OTHERS THEN
          INSERT INTO  ERROR_TABLE (ERROR_TEXT, ERROR_DATE  , ACTION,  KEY,  PROGRAM_NAME)
          VALUES ('Centene enrollment proc failed', SYSDATE,'Centene enrollment main proc',500,'CNTN_ENROLLMENT_PRC');
END CNTN_ENROLLMENT_PRC;
----------------------------------***************************************************--------------------------
PROCEDURE CNTN_DEENROLLMENT_PRC
AS

   CURSOR cur_get_deenr
   IS
      SELECT pe.objid, pe.x_esn, pe.pgm_enroll2web_user, pe.pgm_enroll2site_part
       FROM x_program_enrolled PE
       WHERE 1 = 1
         AND x_enrollment_status = 'ENROLLED'
         AND x_sourcesystem = 'CENTENE'
         AND x_enrolled_date >= '01-Jun-2013'
         AND EXISTS
               (SELECT 1 FROM sa.CENTENE_DEENROLLMENT x
                WHERE x.x_esn = pe.x_esn AND x.DEENROLL_DATE >= TRUNC (SYSDATE)-1
               )
         AND ROWNUM < 1001;

   cnt_deen   NUMBER := 0;
   counter_deenr number:=0;

BEGIN -- MAIN CNTN_DEENROLLMENT_PRC

    begin
       INSERT INTO sa.CENTENE_DEENROLLMENT (x_esn, DEENROLL_DATE)
       SELECT x_esn, TRUNC (SYSDATE)
       FROM sa.CENTENE_NET10_SUBS x
       WHERE ENROLLMENT_STATUS = 'ENROLLED'
        AND bill <> 'Y'
        AND EXISTS
             (SELECT 1 FROM x_program_enrolled pe
               WHERE pe.x_esn = x.x_esn
                 AND pe.x_enrollment_status = 'ENROLLED'
                 AND pe.x_sourcesystem = 'CENTENE'
             );
      commit;

      counter_deenr:=counter_deenr + 1;
      dbms_output.put_line('Completed inserts into SA.CENTENE_DEENROLLMENT Rows effected:: '|| counter_deenr);
    end;

   FOR rec_get_deenr IN cur_get_deenr
   LOOP
      UPDATE X_PROGRAM_ENROLLED
         SET X_UPDATE_STAMP = SYSDATE,
             X_ENROLLMENT_STATUS = 'READYTOREENROLL'
       WHERE objid = rec_get_deenr.objid;

      cnt_deen := cnt_deen + SQL%ROWCOUNT;

      COMMIT;

      INSERT INTO x_program_trans (objid,
                                   x_enrollment_status,
                                   x_enroll_status_reason,
                                   x_trans_date,
                                   x_action_text,
                                   x_action_type,
                                   x_reason,
                                   x_sourcesystem,
                                   x_esn,
                                   x_update_user,
                                   pgm_tran2pgm_entrolled,
                                   pgm_trans2web_user,
                                   pgm_trans2site_part)
           VALUES (sa.billing_seq ('X_PROGRAM_TRANS'),
                   'DEENROLLED',
                   'Centene DeEnrollment',
                   SYSDATE,
                   'Centene DeEnrollment',
                   'DE_ENROLL',
                   'Centene DeEnrollment',
                   'SYSTEM',
                   rec_get_deenr.x_esn,
                   'OPERATIONS',
                   rec_get_deenr.objid,
                   rec_get_deenr.pgm_enroll2web_user,
                   rec_get_deenr.pgm_enroll2site_part);

      COMMIT;

   END LOOP;

   DBMS_OUTPUT.PUT_LINE ('Total Centene De-Enrollments are .. ' || cnt_deen);

EXCEPTION WHEN OTHERS THEN
    INSERT INTO  ERROR_TABLE (ERROR_TEXT, ERROR_DATE  , ACTION,  KEY,  PROGRAM_NAME)
     VALUES ('Centene de-enrollment proc failed', SYSDATE,'Centene de-enrollment main proc',600,'CNTN_DEENROLLMENT_PRC');
END CNTN_DEENROLLMENT_PRC;
 ----------------------------------------------------*****************************************************************************************************-----------------------------------------------------------------------
PROCEDURE CNTN_PLAN_CHANGE_PRC
AS
   CURSOR cur_plan_change  IS
    select *
    from
     (select distinct x.x_esn, pp.objid NEW_PP_OBJID, X.CURRENT_PLAN NEW_PLAN, X.X_PROGRAM_NAME OLD_PLAN,
        (select max(pr.x_retail_price)
         from table_x_pricing pr
         where PP.PROG_PARAM2PRTNUM_MONFEE = pr.x_pricing2part_num
          and pr.x_end_date >sysdate
          and pr.x_start_date < sysdate
          and pr.x_channel = 'BILLING'
        ) x_retail_price,
        (select max(pe.objid) from x_program_enrolled pe where pe.x_esn=x.x_esn and pe.x_enrollment_status = 'ENROLLED') PE_OBJID,
        (select distinct pgm_enroll2web_user from x_program_enrolled pe where pe.x_esn=x.x_esn and pe.x_enrollment_status = 'ENROLLED') PGM_ENROLL2WEB_USER,
        (select distinct PGM_ENROLL2SITE_PART from x_program_enrolled pe where pe.x_esn=x.x_esn and pe.x_enrollment_status = 'ENROLLED') PGM_ENROLL2SITE_PART
                FROM sa.CENTENE_PLAN_CHANGE x,
                     x_program_parameters pp
               WHERE     1 = 1
                     AND x.x_insert_date >=trunc(sysdate)
                     and x.x_status='PENDING'
                     and X.CURRENT_PLAN = pp.x_program_name) where new_plan <> old_plan;

counter_P number:=0;

BEGIN
    begin
     insert into sa.CENTENE_PLAN_CHANGE
     select pe.x_esn, pe.x_enrolled_date, pe.x_enrollment_status, pp.x_program_name, X.CURRENT_PLAN, 'PENDING' x_status, sysdate
     from x_program_enrolled pe, x_program_parameters pp, sa.centene_net10_subs x
     where PE.PGM_ENROLL2PGM_PARAMETER=pp.objid
       and x.x_esn=pe.x_esn
       and pe.x_enrollment_status='ENROLLED'
       and PP.X_PROGRAM_NAME <> x.current_plan
       and x.bill = 'Y'
       and not exists (select 1 from sa.CENTENE_PLAN_CHANGE  y where pe.x_esn = y.x_esn and y.x_status = 'PENDING');
    commit;
    counter_P:=counter_P + 1;
    dbms_output.put_line('Completed inserts into SA.CENTENE_PLAN_CHANGE
    Rows effected:: '||counter_P);
    commit;
    end;
   FOR rec_plan_change IN cur_plan_change
   LOOP
      UPDATE x_program_enrolled pe
         SET pgm_enroll2pgm_parameter = rec_plan_change.NEW_PP_OBJID,
             x_amount = rec_plan_change.x_retail_price
       WHERE pe.objid = rec_plan_change.PE_OBJID;

      INSERT INTO X_PROGRAM_TRANS
           VALUES (
                     sa.billing_seq ('X_PROGRAM_TRANS'),
                     'ENROLLED',
                        'Changed the Plan to '
                     || rec_plan_change.NEW_PLAN
                     || ' from '
                     || rec_plan_change.OLD_PLAN,
                     NULL,
                     NULL,
                     NULL,
                     SYSDATE,
                     'PLAN CHANGE',
                     'PLAN_CHANGE',
                        'Changed the Plan to '
                     || rec_plan_change.NEW_PLAN
                     || ' from '
                     || rec_plan_change.OLD_PLAN,
                     'WEBCSR',
                     rec_plan_change.x_esn,
                     NULL,
                     NULL,
                     'I',
                     'CBO',
                     rec_plan_change.PE_OBJID,
                     rec_plan_change.PGM_ENROLL2WEB_USER,
                     rec_plan_change.PGM_ENROLL2SITE_PART);

      COMMIT;

      update sa.CENTENE_PLAN_CHANGE set x_status='COMPLETED'
      where x_status='PENDING'
      and x_esn = rec_plan_change.x_esn;

      commit;

   END LOOP;

EXCEPTION WHEN OTHERS THEN
   INSERT INTO  ERROR_TABLE (ERROR_TEXT, ERROR_DATE  , ACTION,  KEY,  PROGRAM_NAME)
   VALUES ('Centene plan change proc failed', SYSDATE,'Centene update plan change proc',700,'CNTN_PLAN_CHANGE_PRC');


END CNTN_PLAN_CHANGE_PRC;

 ----------------------------------------------------*****************************************************************************************************-----------------------------------------------------------------------
PROCEDURE CNTN_DAYS_EXTENSION_PRC
AS

   cursor cur_get_ext is
    select x_esn, customer_commit_date, esn_expiry_date, (customer_commit_date-esn_expiry_date) extend_days
    from sa.CENTENE_NET10_SUBS
    where customer_commit_date > esn_expiry_date
    and phone_status  = 'ACTIVE'
    and bill = 'Y';

   CURSOR cur_ext
   IS
      SELECT x.rowid x_rowid, x.*, sp.objid sp_objid, pi.objid pi_objid
        FROM sa.CENTENE_DAYS_EXTENSION x
        left outer join table_site_part sp on sp.x_service_id = x.x_esn and sp.part_status||''='Active'
        left outer join table_part_inst pi on pi.part_serial_no = x.x_esn
       WHERE x_status = 'PENDING';

   count_succ  NUMBER := 0;
   count_inactive number := 0;
   count_invalid number := 0;
   email_text clob;
   excp_count number := 0;
   email_result varchar2(100);
   counter_X number:=0;

BEGIN

    begin
      for r1 in cur_get_ext LOOP
      insert into sa.CENTENE_DAYS_EXTENSION (X_ESN, ESN_EXPIRY_DATE,EXTEND_DAYS,X_STATUS,X_INSERT_DATE)
      Select  r1.x_esn,r1.esn_expiry_date,r1.extend_days,'PENDING', sysdate from dual
      where not exists ( select 1 from sa.CENTENE_DAYS_EXTENSION  x    where x.x_esn = r1.x_esn and x_status = 'PENDING')
      ;
      counter_X:=counter_X + 1;
      END LOOP;
      commit;
      dbms_output.put_line('Completed inserts into SA.CENTENE_DAYS_EXTENSIONclfytopp Rows effected: '||counter_X);
    end;
   DBMS_OUTPUT.PUT_LINE ('Begin of service days extension ... '|| TO_CHAR (SYSDATE, 'MM/DD/YYYY HH:MI:SS'));

   FOR rec_ext IN cur_ext
   LOOP

   if rec_ext.sp_objid is not null then
      UPDATE table_site_part sp
         SET SP.X_EXPIRE_DT = SP.X_EXPIRE_DT + rec_ext.extend_days,
             SP.WARRANTY_DATE = SP.WARRANTY_DATE + rec_ext.extend_days
       WHERE sp.objid = rec_ext.sp_objid;

      UPDATE table_part_inst pi
         SET PI.WARR_END_DATE = PI.WARR_END_DATE + rec_ext.extend_days
       WHERE PI.objid = rec_ext.pi_objid;

      UPDATE sa.CENTENE_DAYS_EXTENSION
         SET x_status = 'COMPLETED'
       WHERE  rowid = rec_ext.x_rowid;
    count_succ:=count_succ+1;

    elsif rec_ext.pi_objid is null then

      UPDATE sa.CENTENE_DAYS_EXTENSION
         SET x_status = 'FAILED INVALID ESN'
       WHERE  rowid = rec_ext.x_rowid;
    count_invalid:=count_invalid+1;
    CNTN_INSERT_EXCEP_PRC( rec_ext.X_ESN, 'DAYS EXTENSION FAILED INVALID ESN');

    else
      UPDATE sa.CENTENE_DAYS_EXTENSION
         SET x_status = 'FAILED INACTIVE'
       WHERE  rowid = rec_ext.x_rowid;
    count_inactive:=count_inactive+1;
    CNTN_INSERT_EXCEP_PRC( rec_ext.X_ESN, 'DAYS EXTENSION FAILED INACTIVE ESN');
    end if;

commit;

   END LOOP;

select count(*)  into excp_count from CNTN_EXCEP_TEMP_TABLE;

 if excp_count> 0 then
---send email
  email_text := '==================================='||chr(10);
  for rec in (select * from CNTN_EXCEP_TEMP_TABLE)
  loop
        email_text := email_text || rec.esn||' '||rec.exception_text||chr(10);
  end loop;
  email_text := email_text ||'============================';
  sa.SEND_MAIL ('CNTN DAYS EXTENSION Exception Report',
                'noreply@tracfone.com',
                'OARBAB@tracfone.com', --'BusinessSolutions@tracfone.com,SubscriberServices@tracfone.com'
                email_text,
                email_result
              );
 end if;

EXCEPTION WHEN OTHERS THEN
    INSERT INTO  ERROR_TABLE (ERROR_TEXT, ERROR_DATE  , ACTION,  KEY,  PROGRAM_NAME)
     VALUES ('Centene days extension proc failed', SYSDATE,'Centene days extension proc',800,'CNTN_DAYS_EXTENSION_PRC');
END CNTN_DAYS_EXTENSION_PRC;

----------------------------------------------------*****************************************************************************************************-----------------------------------------------------------------------
PROCEDURE CNTN_FLASH_PRC
AS

   CURSOR cur_flash
    IS
      SELECT objid,
             x_part_inst2contact,
             part_serial_no esn,
             SYSDATE x_date
       FROM table_part_inst
       where part_serial_no in
              ( SELECT x_esn
                FROM sa.CENTENE_MYACCOUNT
                 WHERE x_status = 'COMPLETED'
                 AND x_insert_date >= TRUNC (SYSDATE)-1
              )
      ;

   counter_flash   NUMBER  := 0;
   str_title       VARCHAR2 (80);
   str_webcsr      VARCHAR2 (2000);
   str_webeng      VARCHAR2 (1000);
   str_webspa      VARCHAR2 (1000);
   str_ivr         VARCHAR2 (10);


BEGIN
   DBMS_OUTPUT.put_line ('Alert inserting started at  '|| TO_CHAR (SYSDATE, 'DD-MON-YYYY hh24:mi:ss AM'));

   str_title := 'Centene Enrollment';

   str_webcsr :=
   '<font face=arial color=brown>This phone belongs to Centene (HMO Provider) </a><br><br>
    <font color=red><li><b>REP: PLEASE READ THE FOLLOWING: </b></li><br></font>
    This phone belongs to Centene (HMO Provider).
    You should only communicate with the representative from this company who must provide the correct answer for the security question in order to receive assistance.
    If the customer calls (the person the phone was issued to), please advise them to contact their Health Plan Case Manager.
    Also, advise them that the number is programmed in their phonebook. All phone exchanges will be shipped to Centene?s corporate office.
    Please use this address when creating the exchange ticket: </a><br>
    <br>Centene Corporate Offices
    <br>7700 Forsyth Blvd
    <br>St. Louis, MO  63105</br>
    <p>For lost/stolen replacements, create a Warranty/Goodwill Replacement ticket in TAS for the replacement phone and advise the representative
    that only ONE replacement phone can be issued per 12 month period.</p>
   ';

   str_webeng :=
      '<p>This phone belongs to Centene (HMO Provider).
       You should only communicate with the representative from this company who must provide the correct answer for the security question in order to receive assistance.
       If the customer calls (the person the phone was issued to), please advise them to contact their Health Plan Case Manager.
       Also, advise them that the number is programmed in their phonebook.
       phone exchanges will be shipped to Centene?s corporate office.
       Please use this address when creating the exchange ticket: </p>
      ';
   str_webspa := '';
   str_ivr := '';

   FOR rec_flash IN cur_flash
   LOOP
      DELETE FROM sa.table_alert
             WHERE title = 'Centene Enrollment'
               AND alert2contract = rec_flash.objid;

      INSERT INTO sa.table_alert
                  (objid,
                   alert_text,
                   x_web_text_english,
                   x_web_text_spanish,
                   start_date,
                   end_date,
                   active,
                   title,
                   x_ivr_script_id,
                   last_update2user,
                   alert2contract,
                   hot,
                   TYPE,
                   x_cancel_sql,
                   alert2contact
                  )
      VALUES (sa.seq ('alert'),
              str_webcsr,
              str_webeng,
              str_webspa,
              SYSDATE,
              SYSDATE + 730,
              1,
              str_title,
              str_ivr,
              268435556,
              rec_flash.objid,
              0,
              'SQL',
              'select count(*)
                  from sa.x_program_enrolled
                  where X_ESN = :esn
                    and x_enrolled_date between :start_date and :end_date
                    and x_enrollment_status <> ''ENROLLED''',
              rec_flash.x_part_inst2contact
            );
     COMMIT;
    counter_flash := counter_flash + 1;

   END LOOP;

   DBMS_OUTPUT.put_line ('Total Alerts inserted  ' || counter_flash);
   DBMS_OUTPUT.put_line ('Alert inserting ended at  '|| TO_CHAR (SYSDATE, 'DD-MON-YYYY hh24:mi:ss AM'));
   COMMIT;

EXCEPTION WHEN OTHERS THEN
   INSERT INTO  ERROR_TABLE (ERROR_TEXT, ERROR_DATE  , ACTION,  KEY,  PROGRAM_NAME)
    VALUES ('Centene flash proc failed', SYSDATE,'Centene alert insert',900,'CNTN_FLASH_PRC');
END CNTN_FLASH_PRC;
----------------------------------------------------*****************************************************************************************************-----------------------------------------------------------------------
PROCEDURE CNTN_MONTHLY_RECURRING_PROC
AS

 CURSOR cur_recurring IS
    SELECT pe.objid,
         pe.x_esn,
         pe.pgm_enroll2site_part,
         pe.pgm_enroll2part_inst,
         pe.pgm_enroll2contact,
         pe.pgm_enroll2web_user,
         pe.PGM_ENROLL2PGM_PARAMETER,
         pp.X_PROMO_INCL_MIN_AT x_promo_objid,
         pp.x_sweep_and_add_flag,
         (select max(x_retail_price)
           from table_x_pricing pr, x_program_parameters pp
           where x_pricing2part_num=PROG_PARAM2PRTNUM_MONFEE
             and pp.objid=PGM_ENROLL2PGM_PARAMETER
         ) x_amount
    FROM x_program_enrolled PE, x_program_parameters pp
    WHERE  x_enrollment_status||'' = 'ENROLLED'
       AND x_sourcesystem||'' = 'CENTENE'
       AND x_enrolled_date >= '01-Jun-2013'
       and pp.x_prog_class||'' in ('HMO', 'SWITCHBASE')
       AND pp.objid = PE.PGM_ENROLL2PGM_PARAMETER
       and prog_param2bus_org=268438258
       AND upper(x_program_name) like '%CENTENE%'
       and LAST_DAY (ADD_MONTHS (TRUNC (SYSDATE), -1)) + 1 >=
              (select max(sp.install_date)
               from table_site_part sp
               where sp.x_service_id = pe.x_esn and sp.part_status||'' = 'Active'
              )
      AND ROWNUM < 5001;

   l_enroll_seq          NUMBER;
   l_purch_hdr_seq       NUMBER;
   l_purch_hdr_dtl_seq   NUMBER;
   l_program_trans_seq   NUMBER;
   l_tax                 NUMBER;
   l_e911_tax            NUMBER;
   l_esn_web             NUMBER := 0;
   l_prog_id             NUMBER;
   cnt                   NUMBER := 0;


BEGIN
   FOR rec_recurring IN cur_recurring
   LOOP
      cnt := cnt + 1;
      l_purch_hdr_seq := sa.billing_seq ('X_PROGRAM_PURCH_HDR');
      l_purch_hdr_dtl_seq := sa.billing_seq ('X_PROGRAM_PURCH_DTL');
      l_program_trans_seq := sa.billing_seq ('X_PROGRAM_TRANS');
      l_tax := 0;
      l_e911_tax := 0;


      UPDATE X_PROGRAM_ENROLLED
         SET X_CHARGE_DATE = SYSDATE,
             x_next_charge_date = NULL,
             X_NEXT_DELIVERY_DATE = NULL,
             X_DELIVERY_CYCLE_NUMBER = NVL(X_DELIVERY_CYCLE_NUMBER,0)+1,
             X_UPDATE_STAMP = SYSDATE
       WHERE 1 = 1 AND objid = rec_recurring.objid;
       COMMIT;

      INSERT INTO x_program_purch_hdr
                  (objid,
                   x_rqst_source,
                   x_rqst_type,
                   x_rqst_date,
                   x_merchant_ref_number,
                   x_ignore_avs,
                   x_ics_rcode,
                   x_ics_rflag,
                   x_ics_rmsg,
                   x_auth_rcode,
                   x_auth_rflag,
                   x_auth_rmsg,
                   x_bill_rcode,
                   x_bill_rflag,
                   x_bill_rmsg,
                   x_customer_email,
                   x_status,
                   x_bill_country,
                   x_amount,
                   x_tax_amount,
                   x_e911_tax_amount,
                   x_user,
                   prog_hdr2web_user,
                   x_payment_type
                  )
           VALUES (l_purch_hdr_seq,
                   'CENTENE',
                   'CENTENE_PURCH',
                   SYSDATE,
                   sa.merchant_ref_number,
                   'YES',
                   '1',
                   'SOK',
                   'Request was processed successfully.',
                   '1',
                   'SOK',
                   'Request was processed successfully.',
                   '1',
                   'SOK',
                   'Request was processed successfully.',
                   'NULL@CYBERSOURCE.COM',
                   'PROCESSED',
                   'USA',
                   rec_recurring.x_amount,
                   l_tax,
                   l_e911_tax,
                   'OPERATIONS',
                   rec_recurring.pgm_enroll2web_user,
                   'CE_RECURRING'
                  );
      COMMIT;

      INSERT INTO x_program_purch_dtl
                     (objid,
                       x_esn,
                       x_amount,
                       x_tax_amount,
                       x_e911_tax_amount,
                       x_charge_desc,
                       x_cycle_start_date,
                       x_cycle_end_date,
                       pgm_purch_dtl2pgm_enrolled,
                       pgm_purch_dtl2prog_hdr
                       )
           VALUES (l_purch_hdr_dtl_seq,
                   rec_recurring.x_esn,
                   rec_recurring.x_amount,
                   l_tax,
                   l_e911_tax,
                   'CHARGES FOR CENTENE CUSTOMERS',
                   TRUNC (SYSDATE),
                   TRUNC (SYSDATE) + 30,
                   rec_recurring.objid,
                   l_purch_hdr_seq
                  );
      COMMIT;

      INSERT INTO x_program_trans
                  (objid,
                   x_enrollment_status,
                   x_enroll_status_reason,
                   x_trans_date,
                   x_action_text,
                   x_action_type,
                   x_reason,
                   x_sourcesystem,
                   x_esn,
                   x_update_user,
                   pgm_tran2pgm_entrolled,
                   pgm_trans2web_user,
                   pgm_trans2site_part
                  )
           VALUES (l_program_trans_seq,
                   'ENROLLED',
                   'Benefits Delivery',
                   SYSDATE,
                   'Benefits Delivery',
                   'BENEFITS',
                   'CENTENE CUSTOMER Benefits Delivery',
                   'SYSTEM',
                   rec_recurring.x_esn,
                   'OPERATIONS',
                   l_enroll_seq,
                   rec_recurring.pgm_enroll2web_user,
                   rec_recurring.pgm_enroll2site_part
                  );
      COMMIT;

      IF (rec_recurring.x_promo_objid IS NOT NULL)
      THEN
         INSERT INTO table_x_pending_redemption
                        (objid,
                         pend_red2x_promotion,
                         x_pend_red2site_part,
                         x_pend_type,
                         pend_redemption2esn,
                         x_case_id,
                         x_granted_from2x_call_trans,
                         pend_red2prog_purch_hdr
                        )
              VALUES (sa.seq ('x_pending_redemption'),
                      rec_recurring.x_promo_objid,
                      rec_recurring.pgm_enroll2site_part,
                      'BPDelivery',
                      NULL,
                      NULL,
                      NULL,
                      l_purch_hdr_seq
                     );

         COMMIT;
      END IF;

      INSERT INTO x_program_gencode
                    (objid,
                     x_esn,
                     x_insert_date,
                     x_status,
                     gencode2prog_purch_hdr,
                     X_OTA_TRANS_ID,
                     X_SWEEP_AND_ADD_FLAG
                    )
           VALUES (sa.billing_seq ('x_program_gencode'),
                   rec_recurring.x_esn,
                   SYSDATE,
                   'INSERTED',
                   l_purch_hdr_seq,
                   '237',
                   rec_recurring.x_sweep_and_add_flag
                  );
      COMMIT;
   END LOOP;
   COMMIT;

EXCEPTION WHEN OTHERS THEN
   INSERT INTO  ERROR_TABLE (ERROR_TEXT, ERROR_DATE  , ACTION,  KEY,  PROGRAM_NAME)
    VALUES ('Centene monthly recurring proc failed', SYSDATE,'Centene rec_recurring insert',1000,'CNTN_MONTHLY_RECURRING_PROC');

END CNTN_MONTHLY_RECURRING_PROC;
PROCEDURE CNTN_611Autojob_PRC
AS
  V_JOB_DATA_ID NUMBER :=0;
BEGIN
  SELECT TO_CHAR(systimestamp,'yyyymmddhh24missff4')
  INTO V_JOB_DATA_ID
  FROM DUAL;
  BEGIN
  INSERT INTO x_job_data
    (JOB_DATA_ID,X_REQUEST_TYPE,X_REQUEST,ORDINAL
    )
  SELECT V_JOB_DATA_ID, -- Job data ID value
    'BPers611' X_REQUEST_TYPE,
    '<request><requestType>BPers611</requestType><lid>-1</lid><esn>'
    ||part_serial_no
    ||'</esn><reason></reason><data1>1</data1><data2>1</data2><data3>1</data3></request>' x_request,
    0 ORDINAL
  FROM
    (SELECT DISTINCT pi.objid PI_OBJID,
      pi.part_serial_no,
      tc.objid,
      TC.STATE Contact_State,
      TC.ZIPCODE Contact_Zip,
      TC.CITY CONTACT_CITY,
      SP.X_ZIPCODE Activation_Zip,
      ZIP.X_STATE Activation_State,
      ZIP.X_CITY Activation_City,
      (SELECT OTA.X_FREE_DIAL
      FROM table_x_ota_features ota
      WHERE OTA.X_OTA_FEATURES2PART_INST = pi.objid
      ) Current_Dial_Code,
      (SELECT ts1.phone
      FROM table_site ts1,
        table_site ts
      WHERE TS1.CHILD_SITE2SITE = ts.objid
      AND TS.S_NAME             = 'CENTENE CORPORATION'
      AND ts1.s_name            = ts.s_name
        || '-'
        || ZIP.X_STATE
      ) Correct_Dial_Code
    FROM sa.CENTENE_NET10_SUBS cntn,
      table_part_inst pi,
      table_contact tc,
      table_site_part sp,
      table_x_zip_code zip
    WHERE cntn.x_esn      = pi.part_serial_no
    AND CNTN.PHONE_STATUS = 'ACTIVE'
    AND PI.X_PART_INST_STATUS
      ||''                     ='52'
    AND PI.X_PART_INST2CONTACT = tc.objid
    AND sp.x_service_id        = pi.part_serial_no
    AND sp.part_status
      ||''        = 'Active'
    AND ZIP.X_ZIP = SP.X_ZIPCODE
    )
  WHERE NVL (current_dial_code, 'X') <> correct_dial_code;
  EXCEPTION
  WHEN OTHERS THEN
 INSERT INTO  ERROR_TABLE (ERROR_TEXT, ERROR_DATE  , ACTION,  KEY,  PROGRAM_NAME)
    VALUES ('Centene  proc failed', SYSDATE,'Centene alert insert',900,'CNTN_611Autojob_PRC');
    COMMIT;
  END;
  INSERT
  INTO sa.x_job_run_details
    (
      objid,
      job_data_id,
      x_priority,
      x_scheduled_run_date,
      x_actual_run_date,
      run_details2job_master,
      x_insert_date,
      x_status_code,
      owner_name,
      x_reason
    )
  SELECT sa.SEQ_X_job_run_details.nextval,
    V_JOB_DATA_ID,
    10,
    SYSDATE+1,
    SYSDATE+1,
    objid,
    SYSDATE,
    '501',
    'BATCH_PROC',
    'Autosys'
  FROM sa.x_job_master
  WHERE x_job_name='SL_PERS_611';
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
 INSERT INTO  ERROR_TABLE (ERROR_TEXT, ERROR_DATE  , ACTION,  KEY,  PROGRAM_NAME)
    VALUES ('Centene proc failed', SYSDATE,'Centene alert insert',900,'CNTN_611Autojob_PRC');
    COMMIT;
END CNTN_611Autojob_PRC;

-------------- END OF PACKAGE BODY ---------------
END CENTENE_PROCESS;
/