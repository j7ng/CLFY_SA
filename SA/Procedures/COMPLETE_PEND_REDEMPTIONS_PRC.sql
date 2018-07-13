CREATE OR REPLACE PROCEDURE sa.complete_pend_redemptions_prc
AS
   CURSOR c1
   IS
      SELECT c.x_red_code, d.part_serial_no, d.x_part_inst_status,
             b.x_sourcesystem, b.x_transact_date, b.objid call_tran_objid,
             d.objid part_inst_objid, f.x_redeem_days, f.x_redeem_units,
             d.x_insert_date, d.x_order_number, d.x_po_num,
             d.part_inst2inv_bin, d.n_part_inst2part_mod
        FROM table_x_code_hist a,
             table_x_call_trans b,
             table_x_red_card_temp c,
             table_part_inst d,
             table_mod_level e,
             table_part_num f
       WHERE a.code_hist2call_trans = b.objid
         AND b.x_transact_date >= TRUNC (SYSDATE - 2)
         AND a.x_code_type = 'MO_Address'
         AND b.x_action_type = '6'
         AND b.x_result = 'Completed'
         -- CR21961 VAS_APP added APP
         AND b.x_sourcesystem IN ('WEB', 'WEBCSR', 'IVR', 'APP')
         AND b.objid = c.temp_red_card2x_call_trans
         AND NOT EXISTS (SELECT 'x'
                           FROM table_x_red_card e
                          WHERE e.red_card2call_trans = b.objid)
         AND c.x_red_code = d.x_red_code
         AND d.x_part_inst_status || '' IN ('40', '43')
         AND d.n_part_inst2part_mod = e.objid
         AND e.part_info2part_num = f.objid;

   counter   NUMBER := 0;
BEGIN
   FOR c1_rec IN c1
   LOOP
      INSERT INTO toppapp.temp_smp_reserve_fix
           VALUES (c1_rec.x_red_code, c1_rec.x_part_inst_status,
                   c1_rec.x_transact_date, SYSDATE, c1_rec.x_sourcesystem);

      COMMIT;

      BEGIN
         INSERT INTO table_x_red_card
              VALUES (sa.seq ('X_RED_CARD'), c1_rec.call_tran_objid,
                      c1_rec.part_inst_objid, NULL, c1_rec.x_redeem_days,
                      c1_rec.x_red_code, c1_rec.x_transact_date,
                      c1_rec.x_redeem_units, c1_rec.part_serial_no,
                      'NOT PROCESSED', 'Completed', 268435556,
                      c1_rec.x_insert_date, c1_rec.x_insert_date,
                      c1_rec.x_order_number, c1_rec.x_po_num,
                      c1_rec.part_inst2inv_bin, c1_rec.n_part_inst2part_mod);
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      counter := counter + 1;

      DELETE      table_part_inst
            WHERE objid = c1_rec.part_inst_objid;

      IF MOD (counter, 1000) = 0
      THEN
         COMMIT;
      END IF;
   END LOOP;

   COMMIT;
END;
/