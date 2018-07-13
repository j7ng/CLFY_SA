CREATE OR REPLACE PROCEDURE sa."CLEARTANK_UPD_PRC"
AS
/********************************************************************************************/
/* Copyright ) 2003 Tracfone Wireless Inc. All rights reserved                              */
/*                                                                                          */
/* Name         :   cleartank_upd_prc                                                       */
/* Purpose      :   To update x_clear_tank field to 1 in table_part_inst for all pastdue    */
/*                  esns inactive more than 60 days                                         */
/* Parameters   :                                                                           */
/* Platforms    :   Oracle 8.0.6 AND newer versions                                         */
/* Author       :   Vanisri Adapa                                                           */
/* Date         :   11/13/03                                                                */
/* Revisions   :                                                                            */
/* Version  Date      Who       Purpose                                                     */
/* -------  --------  -------   ----------------------------------------------              */
/* 1.0     11/13/03  VAdapa     Initial Revision                                            */
/* 1.1/1.2 05/13/05  Mchinta    CR3740 Include for status 51                                */
/* 1.3      06/24/05 VAdapa     Fix for fine tuning the Update Statement (CR3740)           */
/* 1.4     08/17/05  Nguada     Apply different Exp rules for Net10 Phones                  */
/* 1.5/1.6/1.7     08/28/06  VAdapa      CR5552                                     */
/* 1.8     		   08/31/06  VAdapa      CR5566 (New Label Changed from CR5552 to CR5566)                                     */
/********************************************************************************************/
   CURSOR c_esn
   IS
      SELECT part_serial_no
        FROM table_part_inst pi, table_mod_level ml, table_part_num pn
       WHERE x_part_inst_status IN ('54', '51')                      --CR3740
         AND x_domain || '' = 'PHONES'
         AND x_clear_tank = 0                                   -- not flagged
         AND last_trans_time < TRUNC (SYSDATE - 60)
         AND pi.n_part_inst2part_mod = ml.objid
         AND ml.part_info2part_num = pn.objid
         AND pn.x_restricted_use <> 3
         AND pn.x_dll <> 2;

   CURSOR c_esn_net10
   IS
      SELECT part_serial_no
        FROM table_part_inst pi, table_mod_level ml, table_part_num pn
       WHERE x_part_inst_status IN
                           ('54', '51') --CING_GSM --x_part_inst_status = '51'
         AND x_domain || '' = 'PHONES'
         AND x_clear_tank = 0                                   -- not flagged
--     AND pi.WARR_END_DATE  < TRUNC(SYSDATE)
         AND pi.warr_end_date < TRUNC (SYSDATE - 31)                  --CR5566
         AND pi.n_part_inst2part_mod = ml.objid
         AND ml.part_info2part_num = pn.objid
         AND pn.x_restricted_use = 3;

   CURSOR c_max_esn_exists (c_ip_esn IN VARCHAR2)
   IS
      SELECT 'X'
        FROM table_x_zero_out_max
       WHERE x_esn = c_ip_esn
         AND x_reac_date_time IS NULL
         AND x_transaction_type = 2;

   r_max_esn_exists   c_max_esn_exists%ROWTYPE;
   l_recs_processed   NUMBER                                := 0;
   l_serial_num       table_part_inst.part_serial_no%TYPE;
   l_procedure_name   VARCHAR2 (80)                     := 'CLEARTANK_UPD_PRC';
   l_action           VARCHAR2 (50)                         := ' ';
   l_err_text         VARCHAR2 (4000);
   l_start_date       DATE                                  := SYSDATE;
BEGIN
   FOR r_esn IN c_esn
   LOOP
      BEGIN
         l_serial_num := r_esn.part_serial_no;
         l_action := 'Update Table_Part_Inst';

         UPDATE table_part_inst
            SET x_clear_tank = 1
          WHERE part_serial_no = r_esn.part_serial_no
               --AND x_part_inst_status ||''= '54';
            --AND x_part_inst_status in ('54','51');  ---CR3740
            AND x_part_inst_status || '' IN ('54', '51');      ---CR3740 (1.3)

         IF SQL%ROWCOUNT = 1
         THEN
            l_action := 'Insert Table_X_Zero_Out_Max';

            OPEN c_max_esn_exists (r_esn.part_serial_no);

            FETCH c_max_esn_exists
             INTO r_max_esn_exists;

            IF c_max_esn_exists%NOTFOUND
            THEN
               INSERT INTO table_x_zero_out_max
                           (objid, x_esn,
                            x_req_date_time, x_transaction_type
                           )
                    VALUES (seq ('x_zero_out_max'), r_esn.part_serial_no,
                            SYSDATE, 2
                           );

               l_recs_processed := l_recs_processed + 1;
            END IF;

            CLOSE c_max_esn_exists;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_err_text := SQLERRM;
            toss_util_pkg.insert_error_tab_proc
                                          ('Inner Block Error - When others',
                                           l_serial_num,
                                           l_procedure_name
                                          );
      END;

      COMMIT;
   END LOOP;

   COMMIT;

   FOR r_esn_net10 IN c_esn_net10
   LOOP
      BEGIN
         l_serial_num := r_esn_net10.part_serial_no;
         l_action := 'Update Table_Part_Inst';

         UPDATE table_part_inst
            SET x_clear_tank = 1
          WHERE part_serial_no = r_esn_net10.part_serial_no
               --AND x_part_inst_status ||''= '54';
            --AND x_part_inst_status in ('54','51');  ---CR3740
            AND x_part_inst_status || '' IN ('54', '51');      ---CR3740 (1.3)

         IF SQL%ROWCOUNT = 1
         THEN
            l_action := 'Insert Table_X_Zero_Out_Max';

            OPEN c_max_esn_exists (r_esn_net10.part_serial_no);

            FETCH c_max_esn_exists
             INTO r_max_esn_exists;

            IF c_max_esn_exists%NOTFOUND
            THEN
               INSERT INTO table_x_zero_out_max
                           (objid,
                            x_esn, x_req_date_time, x_transaction_type
                           )
                    VALUES (seq ('x_zero_out_max'),
                            r_esn_net10.part_serial_no, SYSDATE, 2
                           );

               l_recs_processed := l_recs_processed + 1;
            END IF;

            CLOSE c_max_esn_exists;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_err_text := SQLERRM;
            toss_util_pkg.insert_error_tab_proc
                                          ('Inner Block Error - When others',
                                           l_serial_num,
                                           l_procedure_name
                                          );
      END;

      COMMIT;
   END LOOP;

   COMMIT;

   IF toss_util_pkg.insert_interface_jobs_fun (l_procedure_name,
                                               l_start_date,
                                               SYSDATE,
                                               l_recs_processed,
                                               'SUCCESS',
                                               l_procedure_name
                                              )
   THEN
      COMMIT;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      l_err_text := SQLERRM;
      toss_util_pkg.insert_error_tab_proc (l_action,
                                           l_serial_num,
                                           l_procedure_name
                                          );

      IF toss_util_pkg.insert_interface_jobs_fun (l_procedure_name,
                                                  l_start_date,
                                                  SYSDATE,
                                                  l_recs_processed,
                                                  'FAILED',
                                                  l_procedure_name
                                                 )
      THEN
         COMMIT;
      END IF;
END cleartank_upd_prc;
/