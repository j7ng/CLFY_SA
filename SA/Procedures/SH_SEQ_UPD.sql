CREATE OR REPLACE PROCEDURE sa.sh_seq_upd
IS

   CURSOR c_esn_seq
   IS
      SELECT ct.x_service_id, ch.x_gen_code, ch.x_sequence,
             ch.x_code_accepted, pi.x_sequence ph_seq
        FROM table_part_inst pi, table_x_code_hist ch, table_x_call_trans ct
       WHERE ch.x_sequence = pi.x_sequence
         AND ct.x_service_id = pi.part_serial_no
         AND ch.x_code_accepted = 'NO'
         AND ch.x_code_type = 'Time_Code'
         AND ch.code_hist2call_trans = ct.objid
         AND ct.x_sourcesystem IN ('IVR',  'WEB')
         AND ct.x_result = 'Completed'
         AND ct.x_action_type = '6'
         AND ct.x_transact_date > TO_DATE ('21-OCT-03');
BEGIN

   FOR r_esn_seq IN c_esn_seq
   LOOP

      UPDATE table_part_inst
         SET x_sequence = r_esn_seq.ph_seq + 1
       WHERE part_serial_no = r_esn_seq.x_service_id;

      COMMIT;
   END LOOP;

   COMMIT;
END sh_seq_upd;
/