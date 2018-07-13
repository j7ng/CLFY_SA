CREATE OR REPLACE PROCEDURE sa."SP_RELEASE_RESERVED_MIN_12HR"
/********************************************************************************/
/* Name         :   SP_RELEASE_RESERVED_MIN_12hr
/* Purpose      :   Unreserves a line that has been under reserved
/*                  status for more than 12hrs
/* Parameters   :   None
/* Platforms    :   Oracle 8.0.6 AND newer versions
/* Author       :
/* Date         :   12/27/2004
/* Revisions    :
/*
/* Version  Date        Who        Purpose
/* -------  --------    -------    --------------------------------------------
/* 1.0      12/27/04    GP         12hr release MIN change
/* 1.2     06/05/06    VA        CR5333
/* 1.3     06/06/07     AB         CR6254
/********************************************************************************/
IS
   CURSOR c1
   IS
      SELECT a.ROWID, a.part_serial_no, a.x_part_inst_status,
             a.last_cycle_ct,
             NVL (a.part_to_esn2part_inst, 0) part_to_esn2part_inst,
             a.part_inst2carrier_mkt, a.x_iccid
        FROM table_part_inst a
       WHERE a.x_part_inst_status IN ('37', '39') AND a.x_domain = 'LINES';

   --CR3327 AND a.last_cycle_ct <= SYSDATE - 1;
   CURSOR c2 (carr_objid NUMBER)
   IS
      SELECT p.x_no_inventory
        FROM table_x_carrier c, table_x_carrier_group cg, table_x_parent p
       WHERE c.objid = carr_objid
         AND c.carrier2carrier_group = cg.objid
         AND cg.x_carrier_group2x_parent = p.objid;

   CURSOR getsitepart (c_esn VARCHAR2, c_iccid VARCHAR2)
   IS
      SELECT   *
          FROM table_site_part
         WHERE x_service_id = c_esn
           AND x_iccid = c_iccid
           AND part_status = 'Inactive'
      ORDER BY service_end_dt DESC;

   recsitepart          getsitepart%ROWTYPE;

   CURSOR getcarrierrules (c_carr_objid NUMBER)
   IS
      SELECT cr.x_gsm_grace_period
        FROM table_x_carrier_rules cr, table_x_carrier c
       WHERE c.objid = c_carr_objid AND c.carrier2rules = cr.objid;

   -- CR3444 Gets ESN number and Status
   CURSOR getesninfo (c_esnobjid NUMBER)
   IS
      SELECT part_serial_no, x_part_inst_status
        FROM table_part_inst
       WHERE objid = c_esnobjid;

   gsm_grace            table_x_carrier_rules.x_gsm_grace_period%TYPE   := 0;
   esn_objid            NUMBER;
   esn                  table_part_inst.part_serial_no%TYPE;
   counter              NUMBER                                          := 0;
   v_part_serial_no     VARCHAR2 (15);
   v_gsm_status_objid   NUMBER;
   v_no_inv_carr        NUMBER                                          := 0;
   v_code_objid         NUMBER;
   v_part_status        table_part_inst.x_part_inst_status%TYPE;
   blnspfound           BOOLEAN;
   v_grace_date         DATE;                                         --CR5333
   blncdmasim            BOOLEAN := FALSE;                            --CR29812
BEGIN
   FOR c1_rec IN c1
   LOOP
      v_part_serial_no := c1_rec.part_serial_no;
      esn_objid := c1_rec.part_to_esn2part_inst;
      -- CR3444 Initialize variables
      esn := '99';                             --> Initialize to dummy values
      v_part_status := '99';                   --> Initialize to dummy values

      --CR 3153 - Starts -Expire the SIM when the line is unreserved - if it is attached to an Inactive phone

      -- CR3444 Checks if objid is >0 to re-initialize variables
      IF esn_objid > 0
      THEN
         FOR esninfo_rec IN getesninfo (esn_objid)
         LOOP
            esn := esninfo_rec.part_serial_no;
            v_part_status := esninfo_rec.x_part_inst_status;
         END LOOP;
      END IF;

--CR5333
      IF (v_part_status = '51' OR v_part_status = '54')
      THEN
         OPEN getsitepart (esn, c1_rec.x_iccid);

         FETCH getsitepart
          INTO recsitepart;

         IF getsitepart%NOTFOUND
         THEN
            blnspfound := FALSE;
         ELSE
            blnspfound := TRUE;
         END IF;

         CLOSE getsitepart;

         IF blnspfound
         THEN
            OPEN getcarrierrules (c1_rec.part_inst2carrier_mkt);

            --CR4579 Added technology parameter
            FETCH getcarrierrules
             INTO gsm_grace;

            CLOSE getcarrierrules;

            v_grace_date := recsitepart.service_end_dt + gsm_grace;
         END IF;
      ELSE
         v_grace_date := c1_rec.last_cycle_ct;
      END IF;

--CR5333

      --CR3327 Unreserves lines that are assoicated to an Active ESN or whose last_cycle_ct <= Sysdate-1
--CR5333
--      IF (v_part_status = '52'
--      OR c1_rec.last_cycle_ct <= SYSDATE - 12/24)
      IF (v_part_status = '52' OR v_grace_date <= SYSDATE - 12 / 24)
--CR5333
      THEN
         --CR 3153 - Return Lines for T-Mobile
         OPEN c2 (c1_rec.part_inst2carrier_mkt);

         FETCH c2
          INTO v_no_inv_carr;

         IF c2%NOTFOUND
         THEN
            v_no_inv_carr := 0;
         END IF;

         CLOSE c2;

         IF v_no_inv_carr IS NULL
         THEN
            v_no_inv_carr := 0;
         END IF;

         IF v_no_inv_carr = 0
         THEN
            --CR3153 - Ends
            UPDATE table_part_inst
               SET x_part_inst_status =
                      DECODE (x_part_inst_status,
                              '37', '11',
                              '39', '12',
                              x_part_inst_status
                             ),
                   status2x_code_table =
                      DECODE (status2x_code_table,
                              969, 958,
                              1040, 959,
                              status2x_code_table
                             )
             WHERE ROWID = c1_rec.ROWID;
         --CR 3153 - Starts
         ELSE
            SELECT objid
              INTO v_code_objid
              FROM table_x_code_table
             WHERE x_code_number = '17';

            UPDATE table_part_inst
               SET x_part_inst_status = 17,
                   status2x_code_table = v_code_objid
             WHERE ROWID = c1_rec.ROWID;
         END IF;

         counter := counter + 1;

         IF LENGTH(esn) = 15
            AND (v_part_status = '51' OR v_part_status = '54')
         THEN
            IF blnspfound
            THEN
               IF v_grace_date <= SYSDATE
               THEN
                    IF sa.Lte_service_pkg.IS_ESN_LTE_CDMA(esn) =  0 THEN
                          -- it is
                          SELECT objid
                            INTO v_gsm_status_objid
                            FROM table_x_code_table
                            WHERE x_code_number = '250';

                                UPDATE table_x_sim_inv
                                   SET x_sim_inv_status = 250,
                                       x_sim_status2x_code_table = v_gsm_status_objid
                                 WHERE x_sim_serial_no = c1_rec.x_iccid;
                    ELSE
                        SELECT objid
                            INTO v_gsm_status_objid
                            FROM table_x_code_table
                            WHERE x_code_number = '251';

                                UPDATE table_x_sim_inv
                                   SET x_sim_inv_status = 251,
                                       x_sim_status2x_code_table = v_gsm_status_objid
                                 WHERE x_sim_serial_no = c1_rec.x_iccid;
                    END IF;
               END IF;
            END IF;
         END IF;
         IF MOD (counter, 1000) = 0
         THEN
            COMMIT;
         END IF;

         blnspfound := TRUE;
      END IF;
   END LOOP;

   COMMIT;
   DBMS_OUTPUT.put_line ('total lines released: ' || counter);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Oracle Error: ' || SQLERRM);
      ROLLBACK;
      toss_util_pkg.insert_error_tab_proc
                                       ('Failed Unreserving a reserved line',
                                        v_part_serial_no,
                                        'SA.SP_RELEASE_RESERVED_MIN'
                                       );
      COMMIT;
END;
/