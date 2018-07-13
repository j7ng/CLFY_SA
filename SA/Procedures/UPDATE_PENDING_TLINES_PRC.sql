CREATE OR REPLACE PROCEDURE sa."UPDATE_PENDING_TLINES_PRC"
/*****************************************************************************/
/*    Copyright ) 2005 Tracfone  Wireless Inc. All rights reserved
/*
/* NAME:         UPDATE_PENDING_TLINES_PRC.SQL
/* PURPOSE:      Updates any t-mobile numbers that have not yet been updated
/* FREQUENCY:
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.
/* REVISIONS:    VERSION  DATE        WHO         PURPOSE
/*               -------  ----------  ----------  -------------------
/*               1.0      08/09/05    GP          CR4351: Initial Revision
/*           1.1    05/30/05    VA       CR4981_4982 - Remove the 'T-MOBILE' template check
/*****************************************************************************/
IS
   CURSOR c1
   IS
      SELECT DISTINCT TRUNC (a.creation_date) creation_date, a.MIN,
                      a.TEMPLATE, a.msid, a.carrier_id, a.transaction_id,
                      b.part_serial_no mdn, b.part_inst2x_pers,
                      bb.objid esnobjid, bb.part_serial_no esn,
                      bb.x_part_inst_status esn_status
                 FROM ig_transaction a, table_part_inst b,
                      table_part_inst bb
                WHERE b.part_to_esn2part_inst = bb.objid
                  AND a.MIN = b.part_serial_no
                  AND a.esn = bb.part_serial_no
--     AND a.template = 'TMOBILE'
                  AND a.creation_date >= TRUNC (SYSDATE) - 1
                  AND a.order_type || '' = 'A'
                  AND a.status || '' = 'S'
                  AND a.new_msid_flag = 'Y'
                  AND a.MIN LIKE 'T%'
                  AND a.msid NOT LIKE 'T%';

   CURSOR c_carrier (c_carrier_id IN NUMBER)
   IS
      SELECT objid, carrier2personality
        FROM table_x_carrier
       WHERE x_carrier_id = c_carrier_id;

   r_carrier     c_carrier%ROWTYPE;

   TYPE sp_objid IS TABLE OF table_site_part.objid%TYPE;

   v_sp_objid    sp_objid;
   intmsid       NUMBER              := 0;
   err_counter   NUMBER              := 0;
   counter       NUMBER              := 0;
BEGIN
   FOR c1_rec IN c1
   LOOP
      BEGIN
         -- Gets carrier_info
         OPEN c_carrier (c1_rec.carrier_id);

         FETCH c_carrier
          INTO r_carrier;

         CLOSE c_carrier;

         -- Verifies new line existence
         SELECT COUNT (1)
           INTO intmsid
           FROM table_part_inst
          WHERE part_serial_no = c1_rec.msid;

         IF (intmsid = 0)
         THEN
            UPDATE table_part_inst
               SET x_order_number = c1_rec.TEMPLATE || '_' || SYSDATE,
                   part_serial_no = c1_rec.msid,
                   part_inst2carrier_mkt = r_carrier.objid,
                   part_inst2x_pers = r_carrier.carrier2personality,
                   x_part_inst_status =
                                 DECODE (c1_rec.esn_status,
                                         '52', '110',
                                         '37'
                                        ),
                   status2x_code_table =
                              DECODE (c1_rec.esn_status,
                                      '52', 268438300,
                                      969
                                     ),
                   x_msid = c1_rec.msid,
                   x_npa = SUBSTR (c1_rec.msid, 1, 3),
                   x_nxx = SUBSTR (c1_rec.msid, 4, 3),
                   x_ext = SUBSTR (c1_rec.msid, 7)
             WHERE part_serial_no = c1_rec.mdn;
         ELSE
            UPDATE table_part_inst
               SET x_order_number = c1_rec.TEMPLATE || '_' || SYSDATE,
                   part_inst2carrier_mkt =
                      DECODE (x_part_inst_status,
                              '13', part_inst2carrier_mkt,
                              r_carrier.objid
                             ),
                   part_inst2x_pers =
                      DECODE (x_part_inst_status,
                              '13', part_inst2x_pers,
                              r_carrier.carrier2personality
                             ),
                   x_part_inst_status =
                      DECODE (c1_rec.esn_status,
                              '52', '110',
                              DECODE (x_part_inst_status,
                                      '13', x_part_inst_status,
                                      '37'
                                     )
                             ),
                   status2x_code_table =
                      DECODE (c1_rec.esn_status,
                              '52', 268438300,
                              DECODE (status2x_code_table,
                                      960, status2x_code_table,
                                      969
                                     )
                             ),
                   part_to_esn2part_inst =
                      DECODE (x_part_inst_status,
                              '13', part_to_esn2part_inst,
                              c1_rec.esnobjid
                             )
             WHERE part_serial_no = c1_rec.msid;
         END IF;

         UPDATE table_x_pi_hist
            SET x_part_serial_no = c1_rec.msid,
                x_msid = c1_rec.msid,
                x_npa = SUBSTR (c1_rec.msid, 1, 3),
                x_nxx = SUBSTR (c1_rec.msid, 4, 3),
                x_ext = SUBSTR (c1_rec.msid, 7)
          WHERE x_part_serial_no = c1_rec.mdn;

         UPDATE table_part_inst
            SET part_inst2x_pers = c1_rec.part_inst2x_pers
          WHERE part_serial_no = c1_rec.esn;

         UPDATE gw1.ig_transaction
            SET new_msid_flag = 'PROCESSED'
          WHERE transaction_id = c1_rec.transaction_id;

         UPDATE    table_site_part
               SET x_min = c1_rec.msid,
                   x_msid = c1_rec.msid
             WHERE x_min = c1_rec.mdn
         RETURNING         objid
         BULK COLLECT INTO v_sp_objid;

         FOR i IN 1 .. v_sp_objid.COUNT
         LOOP
            UPDATE table_x_call_trans
               SET x_min = c1_rec.msid
             WHERE call_trans2site_part = v_sp_objid (i);
         END LOOP;

         counter := counter + 1;
         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            err_counter := err_counter + 1;
      END;
   END LOOP;

   DBMS_OUTPUT.put_line (   'Completed '
                         || counter
                         || ' successfully and '
                         || err_counter
                         || ' with errors'
                        );
END update_pending_tlines_prc;
/