CREATE OR REPLACE PROCEDURE sa."OUTBOUND_ROAD_REDEMPTION_PRC"
AS
/*************************************************************************************/
/* Copyright ) 2001 Tracfone Wireless Inc. All rights reserved                       */
/*                                                                                   */
/* Name         :   outbound_road_redemption_prc.sql                                 */
/* Purpose      :   To update redeemed roadside cards information into               */
/*                  TF_TOSS_INTERFACE_TABLE for revenue recognition                  */
/* Parameters   :   None                                                             */
/* Platforms    :   Oracle 8.0.6 AND newer versions                                  */
/* Author       :   Miguel Leon                                                      */
/* Date         :   09/25/01                                                         */
/* Revisions   :                                                                     */
/* Version  Date       Who       Purpose                                             */
/* ------   --------   -------   --------------------------------------------        */
/* 1.0      02/18/02   Mleon     Initial Revision                                    */
/*                                                                                   */
/* 1.1      07/01/02   VAdapa    Included logic to update X_STATUS field in          */
/*                               TABLE_X_RED_CARD with various values                */
/*                               NOT FOUND   --> SMP not in TF_TOSS_INTERFACE_TABLE  */
/*                               PROCESS AGAIN --> Unsuccessful Update               */
/*                               CREDIT CARD SALE --> 'APP' partnumbers              */
/*                               QUARANTINE    --> Redeemed SMP with invalid dealer  */
/*                               Also modified to select data for 'NOT FOUND',       */
/*                               'QUARANTINE', 'PROCESS AGAIN' statuses in the main  */
/*                               cursor get_card_cur and removed the '41' check in   */
/*                               the dealer validation cursor get_trans_cur          */
/*                               Changes are also done to update x_part_inst_status  */
/*                               to '41' for the redeemed card if it is not in       */
/*                               table_x_road_inst                                   */
/* 1.2     09/16/02    VAdapa    Modified to update TOSS_REDEMPTION_CODE with '41'   */
/*                               Modified to update X_STATUS field with a new value  */
/*                               REBATE CODE         --> For soft codes              */
/*                               Modified to add date and time to status 'PROCESSED' */
/*                               Added the call to interface_jobs_fun to insert into */
/*                               x_toss_interface_jobs                               */
/*                               Changed the passing of variable (which holds the    */
/*                               procedure name) instead of directly passing the     */
/*                               name of the procedure                               */
/*************************************************************************************/

   -- v_cnt         number;
   v_action VARCHAR2 (50) := ' ';
   v_err_text VARCHAR2 (4000);
   v_serial_num VARCHAR2 (50);
   v_procedure_name VARCHAR2 (50) := 'OUTBOUND_ROAD_REDEMPTION_PRC';
   v_inv_found BOOLEAN;
   v_recs_processed NUMBER := 0;
   v_start_date DATE := SYSDATE;
--

/* Cursor to get the redeemed cards object id */
   CURSOR get_card_cur
   IS
      (SELECT rf.*,
              rf.ROWID
         FROM x_road_ftp rf
        WHERE orafin_post IN
                 ('NO',
                 'PROCESS AGAIN',
                 'NOT FOUND',
                 'QUARANTINE'
                 )
          AND trans_type =
                 'N'   --new registration
       UNION
       SELECT rf.*,
              rf.ROWID
         FROM x_road_ftp rf
        WHERE trans_type =
                 'N'
          AND   --new registration
              (part_serial_no
              ) IN
                 (SELECT part_serial_no
                    FROM x_road_invalid_redemption
                   WHERE valid_dealer =
                            'Y'));
/*** EXPLAIN PLAN

SELECT STATEMENT    [RULE] Cost=0 Rows=0 Bytes=0
  SORT UNIQUE
    UNION-ALL
      TABLE ACCESS BY INDEX ROWID X_ROAD_FTP
        INDEX RANGE SCAN X_ROAD_FTP_IDX_N4
      NESTED LOOPS
        TABLE ACCESS BY INDEX ROWID X_ROAD_INVALID_REDEMPTION
          INDEX RANGE SCAN X_ROAD_INVALID_RED_INDX_N1
        TABLE ACCESS BY INDEX ROWID X_ROAD_FTP
          INDEX RANGE SCAN X_ROAD_FTP_IDX_N2
*/
--
   CURSOR get_trans_cur (ip_part_serial_no IN VARCHAR2)
   IS
      SELECT s.site_id, ri.x_part_inst_status
        FROM table_site s,
             table_inv_role ir,
             table_inv_bin ib,
             table_x_road_inst ri
       WHERE s.objid = inv_role2site
         AND s.site_type = 'RSEL'
         AND ir.inv_role2inv_locatn = ib.inv_bin2inv_locatn
         AND ib.objid = ri.road_inst2inv_bin
         AND ri.x_domain = 'ROADSIDE'
--         AND ri.x_part_inst_status = '41'

         AND ri.part_serial_no = ip_part_serial_no;


   get_trans_rec get_trans_cur%ROWTYPE;
--
   CURSOR get_invalid_red_cur (ip_part_serial_no IN VARCHAR2)
   IS
      SELECT 'X'
        FROM x_road_invalid_redemption
       WHERE part_serial_no = ip_part_serial_no;


   get_invalid_red_rec get_invalid_red_cur%ROWTYPE;
--
/* Cursor to identify the POSA ROADSIDE cards - 11/20/01 */
   CURSOR smp_type_cur (ip_smp IN VARCHAR2)
   IS
      SELECT 'X'
        FROM x_posa_road
       WHERE tf_serial_num = ip_smp;


   smp_type_rec smp_type_cur%ROWTYPE;
--
/* Cursor to check whether SMP exists in TF_TOSS_INTERFACE_TABLE */
   CURSOR c_interface_exists (c_ip_ser_num IN VARCHAR2)
   IS
      SELECT 'X'
        FROM tf_toss_interface_table@OFSPRD
       WHERE tf_serial_num = c_ip_ser_num;


   r_interface_exists c_interface_exists%ROWTYPE;
--
/* Cursor to get part number of SMP */
   CURSOR c_part_num (c_ip_serno IN VARCHAR2)
   IS
      SELECT part_number, x_card_type
        FROM table_part_num pn, table_mod_level ml, table_x_road_inst ri
       WHERE ri.n_road_inst2part_mod = ml.objid
         AND ml.part_info2part_num = pn.objid
         AND ri.part_serial_no = c_ip_serno;


   r_part_num c_part_num%ROWTYPE;
BEGIN

   FOR get_card_rec IN get_card_cur
   LOOP
      /* reset inventory found flag for every pass */
      v_inv_found := FALSE;
      v_recs_processed := v_recs_processed + 1;


      BEGIN

         v_serial_num := get_card_rec.part_serial_no;
         OPEN c_interface_exists (get_card_rec.part_serial_no);
         FETCH c_interface_exists INTO r_interface_exists;


         IF c_interface_exists%FOUND   --Continue only if card exists in TF_TOSS_INTERFACE_TABLE
         THEN

            OPEN get_trans_cur (get_card_rec.part_serial_no);
            FETCH get_trans_cur INTO get_trans_rec;


            IF get_trans_cur%FOUND
            THEN

               OPEN smp_type_cur (get_card_rec.part_serial_no);
               FETCH smp_type_cur INTO smp_type_rec;

               /* POSA card --> Update TOSS_POSA_CODE to '41' */
               IF smp_type_cur%FOUND
               THEN

                  v_action := 'Posa / Redemption Update';


                  UPDATE tf.tf_toss_interface_table@OFSPRD
                     SET toss_redemption_date =
                            TRUNC (get_card_rec.activation_date),
--                         toss_redemption_code = 'YES',
                         toss_redemption_code = '41',
                         toss_posa_code = '41',   --update the TOSS_POSA_CODE
                         last_update_date = SYSDATE,
                         last_updated_by = v_procedure_name
                   WHERE tf_serial_num = get_card_rec.part_serial_no
                     AND toss_redemption_date IS NULL;
--                     AND toss_redemption_code IS NULL
--                     AND tf_part_type = 'CARDS'
--                     AND toss_extract_flag = 'YES';
--
                  IF SQL%ROWCOUNT = 1
                  THEN
                     v_inv_found := TRUE;
                  END IF;
               ELSE

                  v_action := 'Non Posa / Redemption Update';


                  UPDATE tf.tf_toss_interface_table@OFSPRD
                     SET toss_redemption_date =
                            TRUNC (get_card_rec.activation_date),
--                         toss_redemption_code = 'YES',
                         toss_redemption_code = '41',
                         last_update_date = SYSDATE,
                         last_updated_by = v_procedure_name
                   WHERE tf_serial_num = get_card_rec.part_serial_no
                     AND toss_redemption_date IS NULL;
--                     AND toss_redemption_code IS NULL
--                     AND tf_part_type = 'CARDS'
--                     AND toss_extract_flag = 'YES';
--

               END IF;


               IF SQL%ROWCOUNT = 1
               THEN
                  v_inv_found := TRUE;
               END IF;

               CLOSE smp_type_cur;


               IF v_inv_found   --Update x_road_ftp and x_road_invalid_redemption only if interface table update is successful
               THEN
                  /**** UPDATE IF THE RECORD IS ON INVALID REDEMPTION TABLE ***/
                  OPEN get_invalid_red_cur (get_card_rec.part_serial_no);
                  FETCH get_invalid_red_cur INTO get_invalid_red_rec;


                  IF get_invalid_red_cur%FOUND
                  THEN

                     v_action := 'Update Invalid_Redemption Table';


                     UPDATE x_road_invalid_redemption
                        SET valid_dealer = 'C'   -- Completed the cycle
                      WHERE part_serial_no = get_card_rec.part_serial_no;
                  END IF;

                  CLOSE get_invalid_red_cur;

                  /* update x_road_ftp rec with 'PROCESSED' */
                  UPDATE x_road_ftp rf
--                     SET orafin_post = 'YES',

                     SET orafin_post = 'YES on ' || TO_CHAR(SYSDATE,'dd-mon-yy hh:mi:ss am'),
                         last_update_date = SYSDATE,
                         last_updated_by = v_procedure_name
                   WHERE rf.ROWID = get_card_rec.ROWID;

                  --        IF MOD(v_cnt, 100) = 0 THEN
                  IF get_trans_rec.x_part_inst_status <> '41'
                  THEN
                     UPDATE table_x_road_inst
                        SET x_part_inst_status = '41',
                            rd_status2x_code_table = 983
                      WHERE part_serial_no = get_card_rec.part_serial_no;
                  END IF;
--                  COMMIT;
               --   END IF;

               ELSE
                  UPDATE x_road_ftp rf
                     SET orafin_post = 'PROCESS AGAIN',
                         last_update_date = SYSDATE,
                         last_updated_by = v_procedure_name
                   WHERE rf.ROWID = get_card_rec.ROWID;
               END IF;   -- end of successful update check

            ELSIF get_trans_cur%NOTFOUND
            THEN
               UPDATE x_road_ftp rf
                  SET orafin_post = 'QUARANTINE',
                      last_update_date = SYSDATE,
                      last_updated_by = v_procedure_name
                WHERE rf.ROWID = get_card_rec.ROWID;
            END IF;   -- end of dealer validated card check

            CLOSE get_trans_cur;
         ELSE

            OPEN c_part_num (get_card_rec.part_serial_no);
            FETCH c_part_num INTO r_part_num;
            CLOSE c_part_num;


            IF r_part_num.part_number LIKE 'APP%'
            THEN
               UPDATE x_road_ftp rf
                  SET orafin_post = 'CREDIT CARD SALE',
                      last_update_date = SYSDATE,
                      last_updated_by = v_procedure_name
                WHERE rf.ROWID = get_card_rec.ROWID;
            ELSIF UPPER (r_part_num.x_card_type) LIKE 'REBATE'
            THEN
               UPDATE x_road_ftp rf
                  SET orafin_post = 'REBATE CODE',
                      last_update_date = SYSDATE,
                      last_updated_by = v_procedure_name
                WHERE rf.ROWID = get_card_rec.ROWID;
            ELSE
               UPDATE x_road_ftp rf
                  SET orafin_post = 'NOT FOUND',
                      last_update_date = SYSDATE,
                      last_updated_by = v_procedure_name
                WHERE rf.ROWID = get_card_rec.ROWID;
            END IF;
         END IF;   -- end of smp exists in interface table check

         CLOSE c_interface_exists;
         COMMIT;
      EXCEPTION

         WHEN OTHERS
         THEN
            toss_util_pkg.insert_error_tab_proc (
               'Inner Block Error:' || v_action,
               v_serial_num,
               v_procedure_name
            );
            COMMIT;
      END;


      IF get_invalid_red_cur%ISOPEN
      THEN
         CLOSE get_invalid_red_cur;
      END IF;


      IF get_trans_cur%ISOPEN
      THEN
         CLOSE get_trans_cur;
      END IF;


      IF smp_type_cur%ISOPEN
      THEN
         CLOSE smp_type_cur;
      END IF;


      IF c_interface_exists%ISOPEN
      THEN
         CLOSE c_interface_exists;
      END IF;


      IF c_part_num%ISOPEN
      THEN
         CLOSE c_part_num;
      END IF;
   END LOOP;   /* end of r_get_card loop */

   COMMIT;
--   IF toss_util_pkg.update_interface_jobs_fun (
   IF toss_util_pkg.insert_interface_jobs_fun (
--         'OUTBOUND_ROAD_REDEMPTION_PRC',
         v_procedure_name,
         v_start_date,
         SYSDATE,
         v_recs_processed,
--         'SUCESS',
         'SUCCESS',
         v_procedure_name
      )
   THEN
      COMMIT;
   END IF;

EXCEPTION

   WHEN OTHERS
   THEN
      toss_util_pkg.insert_error_tab_proc (
         v_action,
         v_serial_num,
         v_procedure_name
      );
      COMMIT;
      COMMIT;
--      IF toss_util_pkg.update_interface_jobs_fun (
      IF toss_util_pkg.insert_interface_jobs_fun (
--            'OUTBOUND_ROAD_REDEMPTION_PRC',
            v_procedure_name,
            v_start_date,
            SYSDATE,
            v_recs_processed,
            'FAILED',
            v_procedure_name
         )
      THEN
         COMMIT;
      END IF;
END outbound_road_redemption_prc;
/