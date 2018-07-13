CREATE OR REPLACE PROCEDURE sa."POSA_ATT_OUTBOUND_PRC2"
AS
/******************************************************************************/
/*    Copyright ) 2001 Tracfone  Wireless Inc. All rights reserved            */
/*                                                                            */
/* NAME:         SA.posa_att_outbound_prc2 (formerly prefixed by sp)           */
/* PURPOSE:                                                                   */
/* FREQUENCY:                                                                 */
/* PLATFORMS:    Oracle 8.0.6 AND newer versions.                             */
/* REVISIONS:                                                                 */
/*VERSION DATE        WHO               PURPOSE                               */
/* ----  -------- -------------  ----------------------------------------     */
/* 1.0            Vani Shimoga   Initial Revision                             */
/*                                                                            */
/* 1.1  09/07/01  Miguel Leon    Placed commit statements                     */
/*                                                                            */
/* 1.2  10/29/01  Miguel Leon   Changed select state to get invoiced number   */
/*                              into a cursor (c1). Added rowid to cursor     */
/*                              c_posa to later update posa_swp_loc_act_card  */
/*                              table by rowid. Added user defined exception  */
/*                              part_num_not_found.Changed exception          */
/*                              handling statements to more accurately log    */
/*                              errors in to error_table. Also changed        */
/*                              commits to be after each records is           */
/*                              processed                                     */
/*                                                                            */
/* 1.3 11/02/01   Miguel Leon   Added new rules to populate the toss_posa_date*/
/*                              into TF_TOSS_INTERFACE TABLE based on the posa*/
/*                              code (42,45) swipe/unswipe.                   */
/*                                                                            */
/* 1.4 11/12/01  VAdapa        Added a check not to update toss_posa_code if  */
/*                             the card is already redeemed                   */
/*                                                                            */
/* 1.5 11/26/01  Miguel Leon   Added new cursor (c2) to get the x_fin_cust_id */
/*                             from table_site when popultaing newly added    */
/*                             columns TF_ATT_MULTI_SWIPE table on OF.        */
/*                             Other two colums tf_cm_number and tf_error_id  */
/*                             will be nullified during insertion.            */
/*                                                                            */
/* 1.6 12/18/01  Miguel Leon   Changed posa_swp_loc_att table to x_posa_card  */
/*                             this table combines x_posa_trans and posa_swp  */
/*                             loc_att table while conserving the indexes.    */
/*                                                                            */
/* 1.7 09/16/02  VAdapa        Removed the prefix "SP" from the procedure name*/
/*                             Added the call to interface_jobs_fun to insert */
/*                             into x_toss_interface_jobs                     */
/*                             Added the call to insert_error_tab_proc to log */
/*                             the errors                                     */
/*                             Removed the check for toss_redemption_code     */
/*                                                                            */
/* 1.8 10/22/02  Miguel Leon   Modifications to look into the tf_toss         */
/*                             interface archive table if the esn is          */
/*                             not found in tf_toss_interface table.          */
/*                             if smp is not found anywhere, an exp           */
/*                             is raised and log in the error_table.          */
/*                             Also added RULE based hint on queries          */
/*                             analized interface tables (OF).                */
/* 1.9 03/17/03  SL            Clarify Upgrade - remove redeemed card         */
/*                             from table_part_inst                           */
/* 2.0 03/08/04  Syed Rizvi    Select statement of cursor c2 modified to pick */
/*                             the value for x_fin_cust_id.                   */
/******************************************************************************/

   CURSOR c_posa
   IS
      SELECT pac.*, pac.ROWID
        FROM x_posa_card pac
       WHERE -- tf_serial_num='179187387'
 tf_extract_flag = 'N'
       ORDER BY tf_serial_num, toss_posa_date;

   /* Get the Invoice Number from the interface table for the POSA activated serial numbers. */
   /* Also get the toss_redemption_date and toss_redemption_code to check whether the card has been redeemed -VaniA */
   CURSOR not_arch_cur (c_tf_serial_num IN VARCHAR2)
   IS
      SELECT /*+ RULE */tf_invoiced_number, toss_redemption_extracted,
             toss_redemption_date   --toss_redemption_code
        FROM tf.tf_toss_interface_table@OFSPRD
       WHERE c_tf_serial_num = tf_serial_num;

   CURSOR arch_cur (c_tf_serial_num IN VARCHAR2)
   IS
      SELECT /*+ RULE */tf_invoiced_number, toss_redemption_extracted,
             toss_redemption_date   --toss_redemption_code
        FROM tf.tf_toss_interface_archive@OFSPRD
       WHERE c_tf_serial_num = tf_serial_num;

   /* Select statement of cursor c2 was updated by Syed Rizvi dt. 03/08/04 */
   CURSOR c2 (c_tf_serial_num IN VARCHAR2)
   IS
   SELECT ts.x_fin_cust_id
   FROM   table_x_red_card pi,
          table_inv_bin ib,
          table_site ts
   WHERE      pi.x_red_card2inv_bin = ib.objid
          AND ib.bin_name           = ts.site_id
          AND pi.x_smp              = c_tf_serial_num
   UNION
   SELECT ts.x_fin_cust_id
   FROM   table_part_inst pi,
          table_inv_bin ib,
          table_site ts
   WHERE      pi.part_inst2inv_bin = ib.objid
          AND ib.bin_name          = ts.site_id
          AND pi.part_serial_no    = c_tf_serial_num
   UNION
   SELECT ts.x_fin_cust_id
   FROM   table_x_posa_card_inv pi,
          table_inv_bin ib,
          table_site ts
   WHERE      pi.x_posa_inv2inv_bin = ib.objid
          AND ib.bin_name           = ts.site_id
          AND pi.x_part_serial_no   = c_tf_serial_num;


     /* Comment out by Syed dt 03/08/04
        SELECT ts.x_fin_cust_id
        FROM table_x_red_card pi, table_inv_bin ib, table_site ts
        WHERE pi.x_smp = c_tf_serial_num
         AND pi.x_red_card2inv_bin = ib.objid
         AND ib.bin_name = ts.site_id;*/
      /* 03/17/03 SELECT ts.x_fin_cust_id
        FROM table_part_inst pi, table_inv_bin ib, table_site ts
       WHERE pi.part_serial_no = c_tf_serial_num
         AND pi.part_inst2inv_bin = ib.objid
         AND ib.bin_name = ts.site_id;*/



   arch_rec arch_cur%ROWTYPE;
   not_arch_rec not_arch_cur%ROWTYPE;
   card_smp_not_found EXCEPTION;

   c2_rec c2%ROWTYPE;
   sql_code NUMBER;
   sql_err VARCHAR2 (300);
   v_error_text VARCHAR2 (1000);
   --COUNTS               NUMBER         := 1;
   part_num_not_found EXCEPTION;
   card_smp VARCHAR2 (80) := NULL;
   v_toss_posa_date DATE := NULL;
   v_x_fin_cust_id VARCHAR2 (40) := NULL;
   v_procedure_name VARCHAR2 (80) := 'posa_att_outbound_prc2';
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
--               IF c1_rec.toss_redemption_Date IS NOT NULL AND c1_rec.toss_redemption_code = 'YES' THEN
               IF not_arch_rec.toss_redemption_date IS NOT NULL
               THEN
                  UPDATE tf.tf_toss_interface_table@OFSPRD
                     SET toss_posa_date = v_toss_posa_date,
                         last_update_date = SYSDATE,
                         last_updated_by = v_procedure_name ,
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
                         last_updated_by = v_procedure_name ,
                         toss_att_location = c_posa1.toss_att_location,
                         toss_att_customer = c_posa1.toss_att_customer
                   WHERE c_posa1.tf_part_num_parent = tf_part_num_parent
                     AND c_posa1.tf_serial_num = tf_serial_num;
               END IF;

               --COMMIT;

               /* After updating the interface table, update the
                  extract_flag and extract_date in TOSS side. */
               UPDATE x_posa_card
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
                       'POSA',
                       v_x_fin_cust_id,
                       NULL,
                       NULL
                    );

               /* After updating the interface table, update the
                  extract_flag and extract_date in TOSS side. */

               UPDATE x_posa_card
                  SET tf_extract_flag = 'Y',
                      tf_extract_date = SYSDATE
                WHERE ROWID = c_posa1.ROWID;


            END IF;
         ELSE



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
--               IF c1_rec.toss_redemption_Date IS NOT NULL AND c1_rec.toss_redemption_code = 'YES' THEN
               IF not_arch_rec.toss_redemption_date IS NOT NULL
               THEN
                  UPDATE tf.tf_toss_interface_archive@OFSPRD
                     SET toss_posa_date = v_toss_posa_date,
                         last_update_date = SYSDATE,
                         last_updated_by = v_procedure_name ,
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
                         last_updated_by = v_procedure_name ,
                         toss_att_location = c_posa1.toss_att_location,
                         toss_att_customer = c_posa1.toss_att_customer
                   WHERE c_posa1.tf_part_num_parent = tf_part_num_parent
                     AND c_posa1.tf_serial_num = tf_serial_num;
               END IF;

               --COMMIT;

               /* After updating the interface table, update the
                  extract_flag and extract_date in TOSS side. */
               UPDATE x_posa_card
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
                       'POSA',
                       v_x_fin_cust_id,
                       NULL,
                       NULL
                    );

               /* After updating the interface table, update the
                  extract_flag and extract_date in TOSS side. */

               UPDATE x_posa_card
                  SET tf_extract_flag = 'Y',
                      tf_extract_date = SYSDATE
                WHERE ROWID = c_posa1.ROWID;


            END IF;



         ELSE

		    raise card_smp_not_found;

         END IF;
      END IF ;
      EXCEPTION

         WHEN card_smp_not_found
         THEN
            /* Cleaning up */
            IF not_arch_cur%ISOPEN
            THEN
               CLOSE not_arch_cur;
            END IF;


			        /* Cleaning up */
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
               'Exception smp_not_found(arch or not arch)  ',
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


		    /* Cleaning up */
            IF arch_cur%ISOPEN
            THEN
               CLOSE arch_cur;
            END IF;


            IF c2%ISOPEN
            THEN
               CLOSE c2;
            END IF;


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

	  /* Cleaning up */
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



      IF toss_util_pkg.insert_interface_jobs_fun (
         v_procedure_name,
         v_start_date,
         SYSDATE,
         v_recs_processed,
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


      IF toss_util_pkg.insert_interface_jobs_fun (
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
END posa_att_outbound_prc2;
/