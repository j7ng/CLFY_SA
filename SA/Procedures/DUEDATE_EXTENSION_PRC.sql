CREATE OR REPLACE PROCEDURE sa."DUEDATE_EXTENSION_PRC"
/*********************************************************************************************/
/* Name         :   duedate_extension_prc
/* Type         :   Procedure
/* Purpose      :   Gives a 10-day or 15-day extension for net10/tracfone ESNs
/* Author       :   Gerald Pintado
/* Date         :   05/23/2005
/* Revisions    :   Version  Date       Who             Purpose
/*                  -------  --------   -------         -----------------------
/*                  1.0      05/23/2005 Gpintado        CR4035 - Initial revision
/*                  1.1      05/24/2005 Gpintado        CR4035 - Added = sign
/*                  1.4      06/13/2005 Gpintado        CR4089 - Add Tracfone 15 day extension
/*                  1.5      06/23/2005 Gpintado        CR4209 - Bug fix on extension days.
/*                  1.6      06/28/2005 Gpintado        CR4220 - Included reactivated customers
/*                  1.7      01/03/2006 Nguada          CR4952 - Remove redemption condition
/*                  1.8      02/10/2006 Gpintado        CR4952 - Includes new activations that have not redeemed
/*             1.9       08/11/2006 VAdapa         CR5510 -  Extend the promise to pay for Net10
/*          1.10      08/28/06   VAdapa         CING_GSM
/*          1.11    09/26/06   VAdapa        CR5607-1 Exclude Verizon CDMA customers from PTP

/*********************************************************************************************/
/* new pvcs structure NEW_PLSQL
/* 1.0  09/01/09  NGuada   BRAND_SEP Separate the Brand and Source System
/*                         incorporate use of new table TABLE_BUS_ORG to retrieve
/*                         brand information that was previously identified by the fields
/*                         x_restricted_use and/or amigo from table_part_num
/*
/*********************************************************************************************/
IS
   -- Gets all phones that expire next day
   -- BRAND_SEP
   CURSOR c1
   IS
      --CING_GSM
      SELECT tab1.part_serial_no esn,
             tab1.warr_end_date,
             tab1.x_part_inst2site_part,
             tab1.x_parent_name,
             tab1.x_parent_id,
             pn.x_technology,
             bo.org_id
        FROM table_part_num pn,
             table_mod_level ml,
             table_bus_org bo,
             (SELECT DISTINCT pi_esn.n_part_inst2part_mod,
                              pi_esn.part_serial_no, pi_esn.warr_end_date,
                              pi_esn.x_part_inst2site_part, cp.x_parent_name,
                              cp.x_parent_id
                         FROM table_x_parent cp,
                              table_x_carrier_group cg,
                              table_x_carrier ca,
                              table_part_inst pi_min,
                              (SELECT          /*+ FULL(pi_esn) PARALLEL(pi_esn,8) */
                                      DISTINCT pi_esn.n_part_inst2part_mod,
                                               pi_esn.part_serial_no,
                                               pi_esn.warr_end_date,
                                               pi_esn.x_part_inst2site_part,
                                               pi_esn.objid
                                          FROM table_part_inst pi_esn
                                         WHERE 1 = 1
                                           AND pi_esn.warr_end_date <
                                                            TRUNC (SYSDATE)
                                                            + 2
                                           AND pi_esn.warr_end_date IS NOT NULL
                                           AND pi_esn.warr_end_date !=
                                                  TO_DATE ('01-jan-1753',
                                                           'dd-mon-yyyy'
                                                          )
                                           AND pi_esn.x_part_inst_status =
                                                                          '52'
                                           AND ROWNUM < 1000000000) pi_esn
                        WHERE 1 = 1
                          AND cp.objid = cg.x_carrier_group2x_parent
                          AND cg.objid = ca.carrier2carrier_group
                          AND ca.objid = pi_min.part_inst2carrier_mkt
                          AND pi_min.part_to_esn2part_inst = pi_esn.objid
                          AND UPPER (cp.x_status) = 'ACTIVE'
                          AND UPPER (ca.x_status) = 'ACTIVE') tab1
       WHERE 1 = 1
         AND pn.objid = ml.part_info2part_num
         AND ml.objid = tab1.n_part_inst2part_mod
         AND bo.objid = pn.part_num2bus_org;

--       SELECT tab1.part_serial_no esn, tab1.warr_end_date,
--              tab1.x_part_inst2site_part, pn.x_restricted_use
--         FROM table_mod_level ml,
--              table_part_num pn,
--              (SELECT /*+ FULL(pi) PARALLEL(pi,8) */
--                      n_part_inst2part_mod, part_serial_no, warr_end_date,
--                      x_part_inst2site_part
--                 FROM table_part_inst pi
--                WHERE warr_end_date BETWEEN TRUNC (SYSDATE) + 1
--                                        AND   TRUNC (SYSDATE + 1)
--                                            + 23.9996 / 24  /** 11:59:59 PM **/
--                  AND x_part_inst_status = '52') tab1
--        WHERE 1 = 1
--          AND pn.objid = ml.part_info2part_num
--          AND ml.objid = tab1.n_part_inst2part_mod;
--CING_GSM
   -- Gets all pending phones for duedate extention
   CURSOR c2
   IS
      SELECT a.ROWID, a.*
        FROM sa.x_duedate_ext_esn a
       WHERE updt_yn IS NULL;

   -- Gets ESN active site_part
   CURSOR c3 (ip_esn IN VARCHAR2)
   IS
      SELECT objid, x_expire_dt
        FROM table_site_part
       WHERE x_service_id = ip_esn AND part_status || '' = 'Active';

   r3               c3%ROWTYPE;
   l_cnt            NUMBER        := 0;
   l_sp_objid       NUMBER;
   l_ext_days       NUMBER        := 15;
   l_max_upd_date   DATE          := NULL;
   l_red_cnt        NUMBER        := 0;
   l_bus_org        VARCHAR2 (25) := 'TRACFONE';
   l_active_days    NUMBER        := 0;         -- CR4952 : Added new variable
BEGIN
   FOR c1_rec IN c1
   LOOP
      l_bus_org := c1_rec.org_id;
      l_sp_objid := 0;

      BEGIN
         SELECT objid
           INTO l_sp_objid
           FROM table_site_part
          WHERE objid = c1_rec.x_part_inst2site_part;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      IF l_sp_objid > 0
      THEN
--CING_GSM
--          INSERT INTO x_duedate_ext_esn
--                      (esn, MIN, old_expy_dt, x_bus_org
--                      )
--               VALUES (c1_rec.esn, l_sp_objid, c1_rec.warr_end_date, l_bus_org
--                      );
         INSERT INTO x_duedate_ext_esn
                     (esn, MIN, old_expy_dt,
                      x_bus_org, x_parent_name, x_parent_id,
                      x_technology                                   --New PTP
                     )
              VALUES (c1_rec.esn, l_sp_objid, c1_rec.warr_end_date,
                      l_bus_org, c1_rec.x_parent_name, c1_rec.x_parent_id,
                      c1_rec.x_technology                            --New PTP
                     );

--CING_GSM
         l_cnt := l_cnt + 1;
      END IF;

      IF MOD (l_cnt, 100) = 0
      THEN
         COMMIT;
      END IF;
   END LOOP;

   COMMIT;
   DBMS_OUTPUT.put_line ('Total processed: ' || l_cnt);
   l_cnt := 0;

   FOR r2 IN c2
   LOOP
      --CING_GSM
      IF r2.x_parent_id = '6' AND r2.x_technology = 'GSM'
      THEN
         UPDATE x_duedate_ext_esn
            SET updt_yn = 'N',
                updt_dt = SYSDATE
          WHERE ROWID = r2.ROWID;
--CING_GSM
--CR5607-1
      ELSIF r2.x_parent_id = '5' AND r2.x_technology = 'CDMA'
      THEN
         UPDATE x_duedate_ext_esn
            SET updt_yn = 'N',
                updt_dt = SYSDATE
          WHERE ROWID = r2.ROWID;
--CR5607-1
      ELSE
         IF r2.x_bus_org = 'NET10'
         THEN
--        l_ext_days := 10;
            l_ext_days := 15;                                        --CR5510
         ELSIF r2.x_bus_org = 'TRACFONE'
         THEN
            l_ext_days := 15;
         END IF;

         l_red_cnt := 0;
         l_active_days := 0;                    -- CR4952 : Added new variable

         OPEN c3 (r2.esn);

         FETCH c3
          INTO r3;

         IF c3%FOUND
         THEN                                        -- Active site_part found
            IF r3.x_expire_dt > TRUNC (SYSDATE) + 2
            THEN             /*** Active site_part (expire_dt) is already
                                  greater than part_inst (warr_end_date) ***/
               UPDATE x_duedate_ext_esn
                  SET updt_yn = 'N',
                      updt_dt = SYSDATE
                WHERE ROWID = r2.ROWID;
            ELSE
               SELECT MAX (updt_dt)
                 INTO l_max_upd_date
                 FROM x_duedate_ext_esn t
                WHERE t.esn = r2.esn AND updt_yn || '' = 'Y';

               IF l_max_upd_date IS NULL
               THEN               -- No prior extention, check activation date
                  BEGIN
                     SELECT x_transact_date,
                            -- CR4952 : Added new variable to check daysActive for a newly active phone
                            DECODE (x_action_type,
                                    1, TRUNC (SYSDATE)
                                     - TRUNC (x_transact_date),
                                    0
                                   ) daysactive
                       INTO l_max_upd_date,
                            l_active_days
                       FROM table_x_call_trans
                      WHERE call_trans2site_part = r3.objid
                        AND x_action_type || '' IN ('1', '3')
                        AND x_result || '' = 'Completed'
                        AND ROWNUM < 2;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        UPDATE x_duedate_ext_esn
                           SET updt_yn = 'N',
                               updt_dt = SYSDATE
                         WHERE ROWID = r2.ROWID;
                  END;
               END IF;

-- CR4952 Removing redemption condition
-- CR4952 Uncommenting redemption condition 02/10/2006
               SELECT COUNT (1)
                 -- check redemption exists after l_max_upd_date
               INTO   l_red_cnt
                 FROM table_x_red_card rc, table_x_call_trans ct
                WHERE 1 = 1
                  AND ct.objid = rc.red_card2call_trans
                  AND ct.x_action_type || '' IN ('1', '6', '3')
                  AND ct.x_result || '' = 'Completed'
                  AND ct.x_transact_date + 0 >= l_max_upd_date
                  AND call_trans2site_part = r3.objid;

               IF l_red_cnt > 0
                  OR (l_active_days > 1 AND l_active_days <= 65)
               THEN
-- CR4952 Checks if newly Active phone falls between 1 and 65 days of service.
                  UPDATE table_site_part
                     SET x_expire_dt = l_ext_days + x_expire_dt,
                         warranty_date = warranty_date + l_ext_days
                   WHERE objid = r3.objid;

                  UPDATE table_part_inst
                     SET warr_end_date = warr_end_date + l_ext_days
                   WHERE part_serial_no = r2.esn;

                  UPDATE x_duedate_ext_esn
                     SET updt_yn = 'Y',
                         updt_dt = SYSDATE,
                         new_expy_dt = r3.x_expire_dt + l_ext_days
                   WHERE ROWID = r2.ROWID;
               ELSE
                  UPDATE x_duedate_ext_esn
                     SET updt_yn = 'N',
                         updt_dt = SYSDATE
                   WHERE ROWID = r2.ROWID;
               END IF;
            END IF;
         ELSE
            UPDATE x_duedate_ext_esn
               SET updt_yn = 'N',
                   updt_dt = SYSDATE
             WHERE ROWID = r2.ROWID;
         END IF;

         CLOSE c3;

         l_cnt := l_cnt + 1;

         IF MOD (l_cnt, 100) = 0
         THEN
            COMMIT;
         END IF;
      END IF;                                                       --CING_GSM
   END LOOP;

   COMMIT;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (SQLERRM || ': Contact System Administrator');
      raise_application_error (-20001,
                               SQLERRM || ': Contact System Administrator'
                              );
END duedate_extension_prc;
/