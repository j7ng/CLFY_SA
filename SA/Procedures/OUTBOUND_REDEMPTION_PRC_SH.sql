CREATE OR REPLACE PROCEDURE sa."OUTBOUND_REDEMPTION_PRC_SH"
AS
/******* This is the replaced procedure to improve performance. The last update date on this procedure is 06/22/06
       Creation Date is UNKNOWN. The original procedure is OUTBOUND_REDEMPTION_PRC        ***************/

/********************************************************************************************/
/* Copyright ) 2001 Tracfone Wireless Inc. All rights reserved                              */
/*                                                                                          */
/* Name         :   outbound_redemption_prc.sql (formerly prefixed by sp)                   */
/* Purpose      :   To update redeemed cards information into                               */
/*                  TF_TOSS_INTERFACE_TABLE for revenue recognition                         */
/* Parameters   :                                                                           */
/* Platforms    :   Oracle 8.0.6 AND newer versions                                         */
/* Author       :   Vanisri Adapa, Miguel Leon                                              */
/* Date         :   09/25/01                                                                */
/* Revisions   :                                                                            */
/* Version  Date      Who       Purpose                                                     */
/* -------  --------  -------   ----------------------------------------------              */
/* Please refer OUTBOUND_REDEMPTION_PRC for any comments prior to this change.              */
/* 1.0/1.1 08/14/06  IC           CR5183  - Read merchant_id, send back the customer_id     */
/* 1.0/1.3 01/22/14  IC           CR24855 - Report queue cards from table_part_isnt to OFS  */
/********************************************************************************************/

   CURSOR red_card_cur
   IS
      SELECT   part_number, x_card_type, rc_row_id, x_smp, x_status,
               x_result, x_red_date, x_red_card2inv_bin, x_red_card2part_mod
          FROM table_part_num pn,
               table_mod_level ml,
               (SELECT ROWID rc_row_id, x_smp, x_status, x_result, x_red_date,
                       x_red_card2inv_bin, x_red_card2part_mod
                  FROM table_x_red_card r
--      WHERE r.x_result || '' = 'Completed' --CR4454
                WHERE  r.x_result || '' IN
                                         ('Completed', 'Broken Card') --CR4454
                   AND r.x_status IN
                                 ('NOT PROCESSED', 'NOT FOUND', 'QUARANTINE')) rc_tab
         WHERE rc_tab.x_red_card2part_mod = ml.objid
           AND ml.part_info2part_num = pn.objid
      ORDER BY x_red_card2inv_bin;

-- CR24855 need to report 400's
CURSOR QUEUE_card_cur
IS
  select pn.part_number, pn.x_card_type, pi1.rowid rc_row_id ,pi1.part_serial_no x_smp,
         pi1.x_part_inst_status x_status,'QUEUED' x_result, pi1.last_trans_time x_red_date ,
         pi1.part_inst2inv_bin x_red_card2inv_bin,  pi1.n_part_inst2part_mod x_red_card2part_mod,pi1.pi_tag_no, pi1.part_mod
  from table_part_inst pi1, table_part_inst pi2, table_mod_level ml, table_part_num pn
 where pi1.x_part_inst_status = '400'
   and pi1.part_to_esn2part_inst = pi2.objid
   and pi1.n_part_inst2part_mod=ml.objid
   and ml.part_info2part_num=pn.objid
   and pi1.PART_MOD  is null
--   and rownum < 10 -- FOR TESTING ONLY
   order by x_red_card2inv_bin ;

   CURSOR reseller_cur (red_card2inv_bin_in IN VARCHAR2)
   IS
      SELECT s.site_id, s.x_fin_cust_id, s.s_name, ib.objid ib1_objid --CR5183
        FROM table_site s, table_inv_bin ib
       WHERE s.site_type || '' = 'RSEL'
         AND ib.bin_name = s.site_id
         AND ib.objid = red_card2inv_bin_in;

   reseller_rec                  reseller_cur%ROWTYPE;

   CURSOR posa_card_cur (c_ip_smp IN VARCHAR2)
   IS
      SELECT toss_att_customer --'X' --CR5183
        FROM x_posa_card
       WHERE tf_serial_num = c_ip_smp;

   posa_card_rec                 posa_card_cur%ROWTYPE;

   --CR5183 start
   CURSOR tf_inter_info_cur (c_ip_smp IN VARCHAR2)
   IS
      SELECT tf_ret_location_code, tf_ret_location_name
        FROM tf_toss_interface_table@ofsprd
       WHERE tf_serial_num = c_ip_smp;

   tf_inter_info_rec             tf_inter_info_cur%ROWTYPE;

   CURSOR posa_site_id_cur (c_merchant_id IN VARCHAR2)
   IS
      SELECT ts.site_id, ts.x_fin_cust_id, ib.objid ib_objid, d.customer_name,
             TO_CHAR (d.customer_id) customer_id
        FROM table_site ts, table_inv_bin ib, tf_customers_v@ofsprd d
       WHERE ib.bin_name = ts.site_id
         AND d.merchant_id = c_merchant_id
         AND TYPE = '3'
         AND ts.x_fin_cust_id = TO_CHAR (d.customer_id)
         AND d.account_type <> 'PHONES';

   posa_site_id_rec              posa_site_id_cur%ROWTYPE;
   l_get_posa_site               VARCHAR2 (1)                := 'F';
   l_ib_objid                    NUMBER;
   l_fin_cust_id                 VARCHAR2 (20);
   l_site_name                   VARCHAR2 (200);
   l_merchant_id                 VARCHAR2 (20);
   --CR5183 end
   l_procedure_name     CONSTANT VARCHAR2 (80) := 'OUTBOUND_REDEMPTION_PRC_SH';
   l_current_red_card2inv_bin    NUMBER;
   l_previous_red_card2inv_bin   NUMBER;
   l_current_queue_card2inv_bin  NUMBER; -- CR24855
   l_previous_queue_card2inv_bin NUMBER; -- CR24855
   l_recs_processed              NUMBER                      := 0;
   l_start_date                  DATE                        := SYSDATE;
   l_action                      VARCHAR2 (50)               := ' ';
   l_err_text                    VARCHAR2 (4000);
   l_serial_num                  VARCHAR2 (50);
   l_commit_counter              NUMBER                      := 0;
   l_posa_code                   VARCHAR2 (100)              := NULL;
   l_site_id                     VARCHAR2 (100)              := NULL;
BEGIN

   /** Initial condition **/
   l_current_red_card2inv_bin := 0;
   l_previous_red_card2inv_bin := 0;
   l_current_queue_card2inv_bin := 0;  -- CR24855
   l_previous_queue_card2inv_bin := 0; -- CR24855

   FOR red_card_rec IN red_card_cur
   LOOP
      l_serial_num := red_card_rec.x_smp;
      l_recs_processed := l_recs_processed + 1;
      l_commit_counter := l_commit_counter + 1;
      /** set current **/
      l_current_red_card2inv_bin := red_card_rec.x_red_card2inv_bin;

      BEGIN
        /** MAIN BLOCK **/
        --CR5183 Start
         OPEN tf_inter_info_cur (l_serial_num);

         FETCH tf_inter_info_cur
          INTO tf_inter_info_rec;

         IF tf_inter_info_rec.tf_ret_location_code IS NULL
         THEN
            l_get_posa_site := 'T';
         ELSE
            l_get_posa_site := 'F';
            l_fin_cust_id := tf_inter_info_rec.tf_ret_location_code;
            l_site_name := tf_inter_info_rec.tf_ret_location_name;
         END IF;

         CLOSE tf_inter_info_cur;

         --CR5183 End
         IF red_card_rec.part_number LIKE 'APP%'
         THEN
            UPDATE table_x_red_card
               SET x_status = 'CREDIT CARD SALE'
             WHERE ROWID = red_card_rec.rc_row_id;
         ELSIF UPPER (red_card_rec.x_card_type) LIKE 'REBATE%'
         THEN
            UPDATE table_x_red_card
               SET x_status = 'REBATE CODE'
             WHERE ROWID = red_card_rec.rc_row_id;
         ELSE
            /** IS AN OFS INVENTORY CARD, should be **/
            /** check if it needs to get the site id info again or not **/
            IF l_current_red_card2inv_bin != l_previous_red_card2inv_bin
            THEN
               /** get reseller info **/
               OPEN reseller_cur (red_card_rec.x_red_card2inv_bin);

               FETCH reseller_cur
                INTO reseller_rec;

               IF reseller_cur%FOUND
               THEN
                  l_site_id := reseller_rec.site_id;
                  --CR5183 Start
                  l_fin_cust_id := reseller_rec.x_fin_cust_id;
                  l_site_name := reseller_rec.s_name;
                  l_ib_objid := reseller_rec.ib1_objid;
               --CR5183 End
               ELSE
                  l_site_id := NULL;
               END IF;

               CLOSE reseller_cur;
            END IF;                                /** of of site id check **/

            OPEN posa_card_cur (red_card_rec.x_smp);

            FETCH posa_card_cur
             INTO posa_card_rec;

            /* check if is a posa card **/
            IF posa_card_cur%FOUND
            THEN
               l_posa_code := '41';

               --CR5183 Start
               IF l_get_posa_site = 'T'
               THEN
                  IF l_site_id IS NULL
                  THEN
                     OPEN posa_site_id_cur (posa_card_rec.toss_att_customer);

                     FETCH posa_site_id_cur
                      INTO posa_site_id_rec;

                     l_site_id := posa_site_id_rec.site_id;
                     l_ib_objid := posa_site_id_rec.ib_objid;
                     l_fin_cust_id := posa_site_id_rec.customer_id;
                     l_site_name := posa_site_id_rec.customer_name;

                     CLOSE posa_site_id_cur;
                  END IF;
               END IF;
            --CR5183 End
            ELSE
               l_posa_code := NULL;
            END IF;                                        /* of posa check */

            CLOSE posa_card_cur;

            IF l_site_id IS NOT NULL
            THEN
               /** try to update tf_toss_interface_table **/
               INSERT INTO table_out_red_clfytopp2ofs
                           (toss_redemption_date, toss_redemption_code,
                            toss_posa_code, last_update_date,
                            last_updated_by, tf_serial_num,
                            red_card_update_status, tf_ret_location_code,
                            tf_ret_location_name, toss_ib_objid       --CR5183
                           )
                    VALUES (TRUNC (red_card_rec.x_red_date), '41',
                            l_posa_code, SYSDATE,
                            l_procedure_name, red_card_rec.x_smp,
                            NULL, l_fin_cust_id,
                            l_site_name, l_ib_objid
                           --CR5183
                           );
--
--  code commented out to use shell script
--
--
--               UPDATE /*+ RULE */
--               tf.tf_toss_interface_table@ofsprd SET toss_redemption_date =
--               TRUNC (red_card_rec.x_red_date), toss_redemption_code = '41',
--               toss_posa_code = NVL (l_posa_code, toss_posa_code),
--               last_update_date = SYSDATE, last_updated_by = l_procedure_name
--               WHERE tf_serial_num = red_card_rec.x_smp;
--               /** check if update was successful **/
--               IF SQL%ROWCOUNT = 1
--               THEN
--                  UPDATE table_x_red_card r SET x_status = 'PROCESSED on ' ||
--                  TO_CHAR (SYSDATE, 'dd-mon-yy hh:mi:ss am')
--                  WHERE ROWID = red_card_rec.rc_row_id;
--               ELSE
--/* try updating on the archive table */
--                  UPDATE /*+ RULE */
--                  tf.tf_toss_interface_archive@ofsprd SET toss_redemption_date
--                  = TRUNC (red_card_rec.x_red_date), toss_redemption_code =
--                  '41', toss_posa_code = NVL (l_posa_code, toss_posa_code),
--                  last_update_date = SYSDATE, last_updated_by =
--                  l_procedure_name
--                  WHERE tf_serial_num = red_card_rec.x_smp;
--                  /** check if update was successful **/
--                  IF SQL%ROWCOUNT = 1
--                  THEN
--                     UPDATE table_x_red_card r SET x_status = 'PROCESSED on '
--                     || TO_CHAR (SYSDATE, 'dd-mon-yy hh:mi:ss am')
--                     WHERE ROWID = red_card_rec.rc_row_id;
--                  ELSE
--                     UPDATE table_x_red_card SET x_status = 'NOT FOUND'
--                     WHERE ROWID = red_card_rec.rc_row_id;
--                  END IF;
--               END IF;
--
--  code commented out to use shell script
--
            ELSE
               /* RESELLER NOT FOUND , Quarantinne */
               UPDATE table_x_red_card
                  SET x_status = 'QUARANTINE'
                WHERE ROWID = red_card_rec.rc_row_id;
            END IF;
         END IF;         /** of card and part number check + ofs inventory **/
                 /** COMMIT every 1,000 **/

         IF MOD (l_commit_counter, 1000) = 0
         THEN
            COMMIT;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            l_err_text := SQLERRM;
            toss_util_pkg.insert_error_tab_proc (l_action,
                                                 l_serial_num,
                                                 l_procedure_name,
                                                    'Inner Block Error '
                                                 || l_err_text
                                                );
            COMMIT;

            IF reseller_cur%ISOPEN
            THEN
               CLOSE reseller_cur;
            END IF;

            IF posa_card_cur%ISOPEN
            THEN
               CLOSE posa_card_cur;
            END IF;
      END;                                        /** OF MAIN BLOCK **/
                                             /** swap  current to previous **/

      l_previous_red_card2inv_bin := l_current_red_card2inv_bin;
   END LOOP;

   COMMIT;

    --- loop again
   FOR queue_card_rec IN queue_card_cur
   LOOP
      l_serial_num     := queue_card_rec.x_smp;
      l_recs_processed := l_recs_processed + 1;
      l_commit_counter := l_commit_counter + 1;
      l_current_queue_card2inv_bin := queue_card_rec.x_red_card2inv_bin;

      BEGIN
        /** MAIN BLOCK **/
        OPEN tf_inter_info_cur (l_serial_num);

         FETCH tf_inter_info_cur
          INTO tf_inter_info_rec;

         IF tf_inter_info_rec.tf_ret_location_code IS NULL
         THEN
            l_get_posa_site := 'T';
         ELSE
            l_get_posa_site := 'F';
            l_fin_cust_id := tf_inter_info_rec.tf_ret_location_code;
            l_site_name := tf_inter_info_rec.tf_ret_location_name;
         END IF;

         CLOSE tf_inter_info_cur;

         /** IS AN OFS INVENTORY CARD, should be **/
         /** check if it needs to get the site id info again or not **/
         IF l_current_queue_card2inv_bin != l_previous_queue_card2inv_bin
         THEN
               /** get reseller info **/
               OPEN reseller_cur (queue_card_rec.x_red_card2inv_bin);

               FETCH reseller_cur
                INTO reseller_rec;

               IF reseller_cur%FOUND
               THEN
                  l_site_id     := reseller_rec.site_id;
                  l_fin_cust_id := reseller_rec.x_fin_cust_id;
                  l_site_name   := reseller_rec.s_name;
                  l_ib_objid    := reseller_rec.ib1_objid;
                ELSE
                  l_site_id := NULL;
               END IF;
               CLOSE reseller_cur;
          END IF;                                /** of of site id check **/

          OPEN posa_card_cur (queue_card_rec.x_smp);

          FETCH posa_card_cur
           INTO posa_card_rec;

            /* check if is a posa card **/

            IF posa_card_cur%FOUND
            THEN
               l_posa_code := '400';

               IF l_get_posa_site = 'T'
               THEN
                  IF l_site_id IS NULL
                  THEN
                     OPEN posa_site_id_cur (posa_card_rec.toss_att_customer);
                     FETCH posa_site_id_cur
                      INTO posa_site_id_rec;

                     l_site_id     := posa_site_id_rec.site_id;
                     l_ib_objid    := posa_site_id_rec.ib_objid;
                     l_fin_cust_id := posa_site_id_rec.customer_id;
                     l_site_name   := posa_site_id_rec.customer_name;

                     CLOSE posa_site_id_cur;
                  END IF;
               END IF;
             ELSE
               l_posa_code := NULL;
            END IF;                                        /* of posa check */

            CLOSE posa_card_cur;

            IF l_site_id IS NOT NULL
            THEN

               /** try to update tf_toss_interface_table **/
               INSERT INTO table_out_red_clfytopp2ofs
                           (TOSS_QUEUE_DATE, toss_redemption_code,
                            toss_posa_code, last_update_date,
                            last_updated_by, tf_serial_num,
                            red_card_update_status, tf_ret_location_code,
                            tf_ret_location_name, toss_ib_objid
                           )
                    VALUES (TRUNC (queue_card_rec.x_red_date), '400',
                            l_posa_code, SYSDATE,
                            l_procedure_name, queue_card_rec.x_smp,
                            NULL, l_fin_cust_id,
                            l_site_name, l_ib_objid );

              END IF;   /** of card and part number check + ofs inventory **/
                        /** COMMIT every 1,000 **/
         IF MOD (l_commit_counter, 1000) = 0
         THEN
            COMMIT;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK;
            l_err_text := SQLERRM;
            toss_util_pkg.insert_error_tab_proc
             (l_action,l_serial_num,l_procedure_name,'Inner Block Error ' || l_err_text);
            COMMIT;

            IF reseller_cur%ISOPEN
            THEN
               CLOSE reseller_cur;
            END IF;

            IF posa_card_cur%ISOPEN
            THEN
               CLOSE posa_card_cur;
            END IF;
      END;                 /** OF MAIN BLOCK **/
                           /** swap  current to previous **/

      l_previous_queue_card2inv_bin := l_current_queue_card2inv_bin;
   END LOOP;

/** log succesful completion **/
   IF toss_util_pkg.insert_interface_jobs_fun
    (l_procedure_name,l_start_date,SYSDATE,
     l_recs_processed,'SUCCESS',l_procedure_name )
   THEN
      COMMIT;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
      toss_util_pkg.insert_error_tab_proc
       (l_action,l_serial_num,l_procedure_name);

      IF toss_util_pkg.insert_interface_jobs_fun
      (l_procedure_name,l_start_date,SYSDATE,
       l_recs_processed,'FAILED',l_procedure_name )
      THEN
         COMMIT;
      END IF;
END outbound_redemption_prc_sh;
/