CREATE OR REPLACE PROCEDURE sa."POSA_ATT_OUTBOUND_RS_PRC"
AS
/******************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         SA.POSA_ATT_OUTBOUND_RS_PRC                                  */
/* PURPOSE:                                                                   */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/* REVISIONS:                                                                 */
/* VERSION  DATE        WHO           PURPOSE                                 */
/* ---- ----------  ------------  --------------------------------------------*/
/* 1.0  04/30/02    Miguel Leon   Initial Revision                            */
/*                                                                            */
/* 1.1 09/16/02    VAdapa        Removed the check for toss_redemption_       */
/*                               Added the call to interface_jobs_fun to      */
/*                               insert into x_toss_interface_jobs            */
/*                               Changed the status passed to interface_      */
/*                               jobs function from 'SUCESS' to 'FAILED'      */
/*                                                                            */
/* 1.8 10/22/02  Miguel Leon   Modifications to look into the tf_toss         */
/*                             interface archive table if the esn is          */
/*                             not found in tf_toss_interface table.          */
/*                             if rs smp is not found anywhere, an exp        */
/*                             is raised and log in the error_table.          */
/*                             Also added RULE based hint on queries          */
/*                             analized interface tables (OF).                */
/******************************************************************************/

   CURSOR c_posa
   IS
      SELECT par.*, par.ROWID
        FROM x_posa_road par
       WHERE tf_extract_flag = 'N'
	   ORDER BY tf_serial_num, toss_posa_date;

   /* Get the Invoice Number from the interface table for the POSA activated */
   /* serial numbers.                                                        */
   /* Also get the toss_redemption_date and toss_redemption_code to check    */
   /* whether the card has been redeemed -VaniA                              */
   CURSOR not_arch_cur (c_tf_serial_num IN VARCHAR2)
   IS
      SELECT /*+ RULE */tf_invoiced_number, toss_redemption_extracted,
             toss_redemption_date
--          toss_redemption_code, toss_redemption_date

        FROM tf.tf_toss_interface_table@OFSPRD
       WHERE c_tf_serial_num = tf_serial_num;

   CURSOR arch_cur (c_tf_serial_num IN VARCHAR2)
   IS
      SELECT /*+ RULE */tf_invoiced_number, toss_redemption_extracted,
             toss_redemption_date
--          toss_redemption_code, toss_redemption_date

        FROM tf.tf_toss_interface_archive@OFSPRD
       WHERE c_tf_serial_num = tf_serial_num;



   CURSOR c2 (c_tf_serial_num IN VARCHAR2)
   IS
      SELECT ts.x_fin_cust_id
        FROM table_x_road_inst ri, table_inv_bin ib, table_site ts
       WHERE ri.part_serial_no = c_tf_serial_num
         AND ri.road_inst2inv_bin = ib.objid
         AND ib.bin_name = ts.site_id;


   not_arch_rec not_arch_cur%ROWTYPE;
   arch_rec     arch_cur%ROWTYPE;
   rs_smp_not_found EXCEPTION;
   c2_rec c2%ROWTYPE;
   sql_code NUMBER;
   sql_err VARCHAR2 (300);
   v_error_text VARCHAR2 (1000);
   --COUNTS               NUMBER         := 1;
   part_num_not_found EXCEPTION;
   card_smp VARCHAR2 (80) := NULL;
   v_toss_posa_date DATE := NULL;
   v_x_fin_cust_id VARCHAR2 (40) := NULL;
   v_procedure_name VARCHAR2 (80) := 'POSA_ATT_OUTBOUND_RS_PRC';
   v_recs_processed NUMBER := 0;
   v_start_date DATE := SYSDATE;
BEGIN

   FOR c_posa1 IN c_posa
   LOOP
      /* Added for logging purposes */
      card_smp := c_posa1.tf_serial_num;
      v_recs_processed := v_recs_processed + 1;


      BEGIN   /* of Inner Block with exception handler */
         /* Fetch the Invoice Number from the interface table for the
               POSA activated serial numbers. */
         OPEN not_arch_cur (c_posa1.tf_serial_num);
         FETCH not_arch_cur INTO not_arch_rec;


         IF not_arch_cur%FOUND
         THEN
            /* If the Invoice number is null, then update the interface
               table from the TOSS information. */
            IF (not_arch_rec.tf_invoiced_number IS NULL)
            THEN
               /* if is an activation then update the record with */
               /* the toss_posa_date as requested by Phoenix changes*/
               /* request form (Oct 25,2001)                        */
               IF c_posa1.toss_posa_code = '42'
               THEN
                  v_toss_posa_date := c_posa1.toss_posa_date;
               ELSE
                  /* if is an deact (45) then reset to NULL */
                  v_toss_posa_date := NULL;
               END IF;

               /* If the card has been redeemed do not update the TOSS_POSA_CODE - VAdapa 11/12/01*/
               /* Removed the check for toss_redemption_code - Vadapa 9/16/02 */

--               IF c1_rec.toss_redemption_Date IS NOT NULL AND c1_rec.toss_redemption_code = 'YES' THEN
               IF not_arch_rec.toss_redemption_date IS NOT NULL
               THEN
                  UPDATE tf.tf_toss_interface_table@OFSPRD
                     SET toss_posa_date = v_toss_posa_date,
                         last_update_date = SYSDATE,
                         last_updated_by = v_procedure_name,
                         toss_att_location = c_posa1.toss_att_location,
                         toss_att_customer = c_posa1.toss_att_customer
                   WHERE c_posa1.tf_part_num_parent = tf_part_num_parent
                     AND c_posa1.tf_serial_num = tf_serial_num;
               ELSE
                  UPDATE tf.tf_toss_interface_table@OFSPRD
                     SET toss_posa_code = c_posa1.toss_posa_code,
                         --toss_posa_date = c_posa1.toss_posa_date,
                         toss_posa_date = v_toss_posa_date,
                         last_update_date = SYSDATE,
                         last_updated_by = v_procedure_name,
                         toss_att_location = c_posa1.toss_att_location,
                         toss_att_customer = c_posa1.toss_att_customer
                   WHERE c_posa1.tf_part_num_parent = tf_part_num_parent
                     AND c_posa1.tf_serial_num = tf_serial_num;
               END IF;

               --COMMIT;

               /* After updating the interface table, update the
                  extract_flag and extract_date in TOSS side. */
               UPDATE x_posa_road
                  SET tf_extract_flag = 'Y',
                      tf_extract_date = SYSDATE
                WHERE ROWID = c_posa1.ROWID;
            /*tf_serial_num = c_posa1.tf_serial_num
              AND tf_part_num_parent = c_posa1.tf_part_num_parent;*/
            --COMMIT;

            ELSE
               /* If the transaction is invoiced, then insert those records
                  in the TF_ATT_MULTI_SWIPE@OFSPRD table.          */

               /* get the x_fin_cust_id */
               OPEN c2 (c_posa1.tf_serial_num);
               FETCH c2 INTO c2_rec;

               /* if available */
               IF c2%FOUND
               THEN
                  v_x_fin_cust_id := c2_rec.x_fin_cust_id;
               ELSE
                  v_x_fin_cust_id := NULL;
               END IF;


               INSERT INTO tf.tf_att_multi_swipe@OFSPRD
                           (
                                          tf_part_num_parent,
                                          tf_serial_num,
                                          toss_att_customer,
                                          toss_att_location,
                                          tf_invoiced_number,
                                          toss_posa_code,
                                          toss_posa_date,
                                          last_update_date,
                                          last_updated_by,
                                          toss_fin_cust_id,
                                          tf_cm_number,
                                          tf_error_id
                           )
                    VALUES(
                       c_posa1.tf_part_num_parent,
                       c_posa1.tf_serial_num,
                       c_posa1.toss_att_customer,
                       c_posa1.toss_att_location,
                       not_arch_rec.tf_invoiced_number,
                       c_posa1.toss_posa_code,
                       c_posa1.toss_posa_date,
                       SYSDATE,
                       v_procedure_name,
                       v_x_fin_cust_id,
                       NULL,
                       NULL
                    );

               /* After updating the interface table, update the
                  extract_flag and extract_date in TOSS side. */
               --COMMIT;
               UPDATE x_posa_road
                  SET tf_extract_flag = 'Y',
                      tf_extract_date = SYSDATE
                WHERE ROWID = c_posa1.ROWID;
            /*tf_serial_num = c_posa1.tf_serial_num
              AND tf_part_num_parent = c_posa1.tf_part_num_parent;*/
            --COMMIT;

            END IF;
         ELSE
		    /***************** NEW ****************/
	     OPEN arch_cur (c_posa1.tf_serial_num);
         FETCH arch_cur INTO arch_rec;


         IF arch_cur%FOUND
         THEN
            /* If the Invoice number is null, then update the interface
               table from the TOSS information. */
            IF (arch_rec.tf_invoiced_number IS NULL)
            THEN
               /* if is an activation then update the record with */
               /* the toss_posa_date as requested by Phoenix changes*/
               /* request form (Oct 25,2001)                        */
               IF c_posa1.toss_posa_code = '42'
               THEN
                  v_toss_posa_date := c_posa1.toss_posa_date;
               ELSE
                  /* if is an deact (45) then reset to NULL */
                  v_toss_posa_date := NULL;
               END IF;

               /* If the card has been redeemed do not update the TOSS_POSA_CODE - VAdapa 11/12/01*/
               /* Removed the check for toss_redemption_code - Vadapa 9/16/02 */

--               IF c1_rec.toss_redemption_Date IS NOT NULL AND c1_rec.toss_redemption_code = 'YES' THEN
               IF arch_rec.toss_redemption_date IS NOT NULL
               THEN
                  UPDATE tf.tf_toss_interface_archive@OFSPRD
                     SET toss_posa_date = v_toss_posa_date,
                         last_update_date = SYSDATE,
                         last_updated_by = v_procedure_name,
                         toss_att_location = c_posa1.toss_att_location,
                         toss_att_customer = c_posa1.toss_att_customer
                   WHERE c_posa1.tf_part_num_parent = tf_part_num_parent
                     AND c_posa1.tf_serial_num = tf_serial_num;
               ELSE
                  UPDATE tf.tf_toss_interface_archive@OFSPRD
                     SET toss_posa_code = c_posa1.toss_posa_code,
                         --toss_posa_date = c_posa1.toss_posa_date,
                         toss_posa_date = v_toss_posa_date,
                         last_update_date = SYSDATE,
                         last_updated_by = v_procedure_name,
                         toss_att_location = c_posa1.toss_att_location,
                         toss_att_customer = c_posa1.toss_att_customer
                   WHERE c_posa1.tf_part_num_parent = tf_part_num_parent
                     AND c_posa1.tf_serial_num = tf_serial_num;
               END IF;

               --COMMIT;

               /* After updating the interface table, update the
                  extract_flag and extract_date in TOSS side. */
               UPDATE x_posa_road
                  SET tf_extract_flag = 'Y',
                      tf_extract_date = SYSDATE
                WHERE ROWID = c_posa1.ROWID;
            /*tf_serial_num = c_posa1.tf_serial_num
              AND tf_part_num_parent = c_posa1.tf_part_num_parent;*/
            --COMMIT;

            ELSE
               /* If the transaction is invoiced, then insert those records
                  in the TF_ATT_MULTI_SWIPE@OFSPRD table.          */

               /* get the x_fin_cust_id */
               OPEN c2 (c_posa1.tf_serial_num);
               FETCH c2 INTO c2_rec;

               /* if available */
               IF c2%FOUND
               THEN
                  v_x_fin_cust_id := c2_rec.x_fin_cust_id;
               ELSE
                  v_x_fin_cust_id := NULL;
               END IF;


               INSERT INTO tf.tf_att_multi_swipe@OFSPRD
                           (
                                          tf_part_num_parent,
                                          tf_serial_num,
                                          toss_att_customer,
                                          toss_att_location,
                                          tf_invoiced_number,
                                          toss_posa_code,
                                          toss_posa_date,
                                          last_update_date,
                                          last_updated_by,
                                          toss_fin_cust_id,
                                          tf_cm_number,
                                          tf_error_id
                           )
                    VALUES(
                       c_posa1.tf_part_num_parent,
                       c_posa1.tf_serial_num,
                       c_posa1.toss_att_customer,
                       c_posa1.toss_att_location,
                       arch_rec.tf_invoiced_number,
                       c_posa1.toss_posa_code,
                       c_posa1.toss_posa_date,
                       SYSDATE,
                       v_procedure_name,
                       v_x_fin_cust_id,
                       NULL,
                       NULL
                    );

               /* After updating the interface table, update the
                  extract_flag and extract_date in TOSS side. */
               --COMMIT;
               UPDATE x_posa_road
                  SET tf_extract_flag = 'Y',
                      tf_extract_date = SYSDATE
                WHERE ROWID = c_posa1.ROWID;
            /*tf_serial_num = c_posa1.tf_serial_num
              AND tf_part_num_parent = c_posa1.tf_part_num_parent;*/
            --COMMIT;
         END IF;

         ELSE

			/**** NEW **/









            /* raise user defined exception when part num not found */
            RAISE rs_smp_not_found;
         END IF;
     END IF;
      EXCEPTION

         WHEN rs_smp_not_found
         THEN
            /* Cleaning up */
            IF not_arch_cur%ISOPEN
            THEN
               CLOSE not_arch_cur;
            END IF;

			IF arch_cur%ISOPEN
            THEN
               CLOSE arch_cur;
            END IF;


            IF c2%ISOPEN
            THEN
               CLOSE c2;
            END IF;

            /* logging errors */
            toss_util_pkg.insert_error_tab_proc (
               'Exception smp_not_found(arch or not arch)   ',
               NVL (card_smp, 'NOT DEFINED'),
               v_procedure_name
            );
            COMMIT;

         WHEN OTHERS
         THEN
            /* Cleaning up */
            IF not_arch_cur%ISOPEN
            THEN
               CLOSE not_arch_cur;
            END IF;

			IF arch_cur%ISOPEN
            THEN
               CLOSE arch_cur;
            END IF;


            IF c2%ISOPEN
            THEN
               CLOSE c2;
            END IF;

            /* logging errors */
            toss_util_pkg.insert_error_tab_proc (
               'Exception caught by when others (inner)',
               NVL (card_smp, 'NOT DEFINED'),
               v_procedure_name
            );
            COMMIT;
      END;   /* of Inner Block with exception handler */

      /* RESET TO NULL AFTER EACH LOOP */
      card_smp := NULL;
      v_toss_posa_date := NULL;
      v_x_fin_cust_id := NULL;

      /* Cleaning up */
      IF not_arch_cur%ISOPEN
      THEN
         CLOSE not_arch_cur;
      END IF;

	  IF arch_cur%ISOPEN
            THEN
               CLOSE arch_cur;
      END IF;

      IF c2%ISOPEN
      THEN
         CLOSE c2;
      END IF;

      COMMIT;
   END LOOP;

   COMMIT;


--   IF toss_util_pkg.update_interface_jobs_fun (
      IF toss_util_pkg.insert_interface_jobs_fun (
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
      ROLLBACK;
      toss_util_pkg.insert_error_tab_proc (
         'Exception caught by when others (outer)',
         NVL (card_smp, 'NOT DEFINED'),
         v_procedure_name
      );
      COMMIT;
--      IF toss_util_pkg.update_interface_jobs_fun (
      IF toss_util_pkg.insert_interface_jobs_fun (
            v_procedure_name,
            v_start_date,
            SYSDATE,
            v_recs_processed,
--            'SUCESS',
            'FAILED',
            v_procedure_name
         )
      THEN
         COMMIT;
      END IF;
END;
/